import json
import uuid
import time
from typing import List, Dict, Any, Optional
from src.core.router.dispatcher import Dispatcher
from src.memory.context.session_store import SessionStore
from src.core.agents.research_agent import ResearchAgent
from src.core.agents.action_agent import ActionAgent
from src.utils.logger import MissionLogger

class MissionState:
    PENDING = "pending"
    PLANNING = "planning"
    EXECUTING = "executing"
    VALIDATING = "validating"
    COMPLETED = "completed"
    FAILED = "failed"

class MissionController:
    """
    Antigravity Phase 2 Controller
    Responsibility: Coordinate complex tasks, manage state transitions, 
    and implement error recovery across the agentic loop.
    """
    
    def __init__(self, dispatcher: Optional[Dispatcher] = None, session_store: Optional[SessionStore] = None):
        self.dispatcher = dispatcher or Dispatcher()
        self.session_store = session_store or SessionStore()
        self.active_missions: Dict[str, Dict[str, Any]] = {}
        self.logger = MissionLogger()
        
        # Initialize specialized agents
        self.agents = {
            "research": ResearchAgent(self.dispatcher),
            "code": ActionAgent(self.dispatcher),
            "automation": ActionAgent(self.dispatcher)
        }

    def create_mission(self, objective: str) -> str:
        """Initializes a new mission with a unique ID and persists it."""
        mission_id = str(uuid.uuid4())
        mission = {
            "id": mission_id,
            "objective": objective,
            "state": MissionState.PENDING,
            "plan": [],
            "current_step": 0,
            "history": [],
            "created_at": time.time()
        }
        self.active_missions[mission_id] = mission
        self.session_store.save_mission(mission)
        self.logger.log_event("mission_created", {"mission_id": mission_id, "objective": objective})
        return mission_id

    def decompose_task(self, mission_id: str) -> List[Dict[str, Any]]:
        """Uses the 'smart' model pool to break the objective into subtasks."""
        mission = self.active_missions.get(mission_id) or self.session_store.load_mission(mission_id)
        if not mission:
            return []
        self.active_missions[mission_id] = mission
        
        mission["state"] = MissionState.PLANNING
        self.session_store.save_mission(mission)
        
        prompt = f"""
        Break this objective into a sequential list of atomic subtasks. 
        For each task, specify if it is 'research', 'code', or 'automation'.
        
        Objective: {mission['objective']}
        
        Output accurately formatted valid JSON only:
        {{"subtasks": [{{"id": 1, "task": "description", "type": "research|code|automation"}}]}}
        """
        
        response = self.dispatcher.resilient_completion(
            [{"role": "user", "content": prompt}],
            complexity="smart"
        )
        
        try:
            # Basic JSON extraction from markdown or raw text
            content = response['choices'][0]['message']['content']
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            
            plan_data = json.loads(content)
            mission["plan"] = plan_data.get("subtasks", [])
            self.session_store.save_mission(mission)
            return mission["plan"]
        except Exception as e:
            mission["state"] = MissionState.FAILED
            mission["history"].append({"action": "decomposition", "error": str(e)})
            self.session_store.save_mission(mission)
            return []

    def execute_mission(self, mission_id: str):
        """Standard ReAct loop: Plan -> Execute -> Next."""
        mission = self.active_missions.get(mission_id) or self.session_store.load_mission(mission_id)
        if not mission:
            return None
        self.active_missions[mission_id] = mission
        
        if not mission["plan"]:
            self.decompose_task(mission_id)
            
        if mission["state"] == MissionState.FAILED:
            self.session_store.save_mission(mission)
            return mission
            
        mission["state"] = MissionState.EXECUTING
        self.session_store.save_mission(mission)
        
        while mission["current_step"] < len(mission["plan"]):
            step = mission["plan"][mission["current_step"]]
            print(f"🚀 Mission {str(mission_id)[:8]}: Routing to {step['type']} agent...")
            
            # Select specialized agent
            agent = self.agents.get(step['type'], self.agents['research'])
            
            # Execute via specialized agent
            result_content = agent.execute(step['task'], mission['history'])
            
            step_history = {
                "step_id": step['id'],
                "type": step['type'],
                "result": result_content,
                "timestamp": time.time()
            }
            mission["history"].append(step_history)
            self.session_store.add_history(mission_id, step_history)
            
            mission["current_step"] += 1
            self.session_store.save_mission(mission)
            self.logger.log_mission_summary(mission_id, mission['objective'], mission['state'], len(mission['history']))
            
        mission["state"] = MissionState.COMPLETED
        self.session_store.save_mission(mission)
        self.logger.log_mission_summary(mission_id, mission['objective'], mission['state'], len(mission['history']))
        return mission

    def get_mission_status(self, mission_id: str) -> Dict[str, Any]:
        return self.active_missions.get(mission_id, {})

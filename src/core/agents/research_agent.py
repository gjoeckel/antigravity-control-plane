from typing import List, Dict, Any
from src.core.agents.base_agent import BaseAgent

class ResearchAgent(BaseAgent):
    """
    Antigravity Research Agent
    Specialization: Deep analysis, documentation parsing, and strategic planning.
    Pool: Smart Pool (Gemini 3.1 Flash Lite)
    """
    def __init__(self, dispatcher):
        super().__init__(dispatcher, role="researcher")

    def execute(self, task: str, context: List[Dict[str, Any]]) -> str:
        prompt = f"""
        Role: Senior Research & Architecture Agent
        Task: {task}
        
        System Context (Past steps):
        {self._format_context(context)}
        
        Instruction: Provide a detailed, analytical technical response. 
        Focus on architecture, patterns, and dependency mapping.
        """
        
        response = self.dispatcher.resilient_completion(
            [{"role": "user", "content": prompt}],
            complexity="smart"
        )
        
        return response['choices'][0]['message']['content'] if 'choices' in response else str(response)

from abc import ABC, abstractmethod
from typing import Dict, Any, List
from src.core.router.dispatcher import Dispatcher

class BaseAgent(ABC):
    """
    Antigravity Base Agent
    Interface for specialized agents within the control plane.
    """
    def __init__(self, dispatcher: Dispatcher, role: str):
        self.dispatcher = dispatcher
        self.role = role

    @abstractmethod
    def execute(self, task: str, context: List[Dict[str, Any]]) -> str:
        """Executes the specific atomic task."""
        pass

    def _format_context(self, context: List[Dict[str, Any]]) -> str:
        """Helper to format the history context for the LLM."""
        if not context:
            return "No previous history."
        
        formatted = []
        for entry in context:
            # Handle list or dict history format
            step_id = entry.get("step_id", "?")
            result = entry.get("result", "")
            formatted.append(f"Step {step_id} Result: {result[:500]}...")
        return "\n".join(formatted)

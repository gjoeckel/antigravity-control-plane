from typing import List, Dict, Any
from src.core.agents.base_agent import BaseAgent
from src.utils.terminal import SafeTerminalTool

class ActionAgent(BaseAgent):
    """
    Antigravity Action Agent
    Specialization: Code generation, script writing, and automation execution.
    Pool: Fast Pool (Gemma 3)
    """
    def __init__(self, dispatcher):
        super().__init__(dispatcher, role="executor")
        self.terminal = SafeTerminalTool()

    def execute(self, task: str, context: List[Dict[str, Any]]) -> str:
        prompt = f"""
        Role: Senior Software Automation Agent
        Task: {task}
        
        System Context (Past steps):
        {self._format_context(context)}
        
        Instruction: 
        1. If you need to run a shell command, output exactly: EXECUTE: [command]
        2. Otherwise, provide the technical solution.
        3. Keep explanations minimal.
        """
        
        # Action agent uses the 'fast' pool for responsiveness
        response = self.dispatcher.resilient_completion(
            [{"role": "user", "content": prompt}],
            complexity="fast"
        )
        
        content = response['choices'][0]['message']['content'] if 'choices' in response else str(response)
        
        # Look for execution requests
        if "EXECUTE:" in content:
            command = content.split("EXECUTE:")[1].strip().split("\n")[0]
            result = self.terminal.execute(command)
            return f"Action: Ran command [{command}]\nOutput: {result.get('output')}"
            
        return content

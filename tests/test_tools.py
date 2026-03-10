from src.core.controller.mission_controller import MissionController
import os

def test_tool_use():
    print("🎬 Testing Antigravity Phase 3: Action Agent Tool Use...")
    
    controller = MissionController()
    
    # Mission: Check the contents of the current directory using shell
    objective = "Use the shell to list all files in the 'src/utils' directory and report back."
    mission_id = controller.create_mission(objective)
    
    print(f"🆔 Mission Created: {mission_id}")
    
    # 1. Decompose
    print("🧠 Decomposing...")
    plan = controller.decompose_task(mission_id)
    
    # 2. Execute
    print("🚀 Executing with Tool Use capability...")
    mission = controller.execute_mission(mission_id)
    
    print(f"✅ Mission State: {mission['state']}")
    print("--- Execution History ---")
    for entry in mission['history']:
        print(f"Step {entry['step_id']} Result:\n{entry['result']}")

if __name__ == "__main__":
    test_tool_use()

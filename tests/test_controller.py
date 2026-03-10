from src.core.controller.mission_controller import MissionController, MissionState
import json
import time

def test_mission_lifecycle():
    print("🎬 Testing Antigravity Phase 2 Mission Controller...")
    
    controller = MissionController()
    
    # 1. Create Mission
    objective = "Analyze the current project mapping and propose a 3-step feature roadmap."
    mission_id = controller.create_mission(objective)
    print(f"🆔 Mission Created: {mission_id}")
    
    # 2. Decompose Task
    print("🧠 Decomposing high-level objective into atomic subtasks...")
    plan = controller.decompose_task(mission_id)
    
    if not plan:
        print("❌ Planning failed. (Are we rate limited?)")
        return

    print(f"📋 Plan Generated ({len(plan)} steps):")
    for step in plan:
        print(f"  - [{step['type']}] {step['task']}")
    
    # 3. Execute Mission (First step only for this unit test)
    print("\n🚀 Starting Mission Execution (Initial steps)...")
    mission = controller.execute_mission(mission_id)
    
    print(f"\n✅ Mission Final State: {mission['state']}")
    print("--- Final History ---")
    for entry in mission['history']:
        print(f"Step {entry['step_id']} Result: {entry['result'][:100]}...")

if __name__ == "__main__":
    test_mission_lifecycle()

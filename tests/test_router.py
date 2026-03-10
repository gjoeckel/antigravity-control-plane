from src.core.router.dispatcher import Dispatcher
import sys
import json

def test_dispatcher_routing():
    print("🎬 Testing Antigravity Core Router Dispatcher...")
    
    # Initialize dispatcher
    dispatcher = Dispatcher()
    
    # Get state
    state = dispatcher.get_active_provider_state()
    print(f"📍 Active Provider State: {state.get('provider', 'unknown')}")
    
    # Test logic routing
    smart_model = dispatcher.route("smart")
    fast_model = dispatcher.route("fast")
    print(f"🛤️ Smart Routing: {smart_model}")
    print(f"🛤️ Fast Routing: {fast_model}")
    
    # Test actual Proxy Connectivity
    print("📡 Sending test request to LiteLLM Proxy via Dispatcher...")
    messages = [{"role": "user", "content": "Say 'Dispatcher is Online' if you can read this."}]
    
    response = dispatcher.resilient_completion(messages, complexity="fast")
    
    if "error" in response:
        print(f"❌ Dispatcher Test Failed: {response['error']}")
        sys.exit(1)
        
    content = response['choices'][0]['message']['content']
    print(f"✅ Dispatcher Response: {content}")
    print("🎉 Core Router verification complete.")

if __name__ == "__main__":
    test_dispatcher_routing()

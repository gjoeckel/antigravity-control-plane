import time
from typing import List, Dict, Optional

class RotationManager:
    """
    Antigravity Rotation Logic
    Responsibility: Select the next available key and manage cooldowns for rate-limited keys.
    """
    
    def __init__(self, keys: List[str], provider: str):
        self.provider = provider
        # Track health: {key: cooldown_until_timestamp}
        self.key_health: Dict[str, float] = {key: 0.0 for key in keys}
        self.current_index = 0
        self.keys = keys

    def get_next_available_key(self) -> Optional[str]:
        """Returns the next healthy key in the pool, using round-robin."""
        if not self.keys:
            return None
            
        now = time.time()
        start_index = self.current_index
        
        while True:
            key = self.keys[self.current_index]
            if self.key_health[key] <= now:
                # Key is healthy
                # Move index forward for next time
                self.current_index = (self.current_index + 1) % len(self.keys)
                return key
            
            # Move to next key
            self.current_index = (self.current_index + 1) % len(self.keys)
            
            # If we've looped through all keys and none are healthy
            if self.current_index == start_index:
                return None

    def mark_rate_limited(self, key: str, cooldown_seconds: int = 60):
        """Places a key on cooldown after a 429 error."""
        if key in self.key_health:
            print(f"⚠️ Provider {self.provider} key rate-limited. Cooldown: {cooldown_seconds}s")
            self.key_health[key] = time.time() + cooldown_seconds

    def reset_all_health(self):
        """Clears all cooldowns."""
        for key in self.key_health:
            self.key_health[key] = 0.0

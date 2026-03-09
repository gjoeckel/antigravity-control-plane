#!/bin/bash

# Antigravity MCP Context Budget Diagnostic
# Optimizes reliability by preventing "Context Rot" (accuracy drop)
# Targets the established < 40-tool efficiency sweet spot.

echo "🔍 Checking Antigravity MCP Configuration..."

# 1. Primary Config Path
PRIMARY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
LEGACY_CONFIG="$HOME/Library/Application Support/Antigravity/User/mcp.json"

echo "------------------------------------------------"
if [ -L "$PRIMARY_CONFIG" ]; then
    echo "✅ Global config is a SYMLINK: $PRIMARY_CONFIG"
    echo "   Target: $(readlink "$PRIMARY_CONFIG")"
elif [ -f "$PRIMARY_CONFIG" ]; then
    echo "⚠️ Global config is a REGULAR FILE: $PRIMARY_CONFIG"
    echo "   Recommendation: Link it to your git repo for portability."
else
    echo "❌ Global config NOT FOUND at $PRIMARY_CONFIG"
fi

if [ -f "$LEGACY_CONFIG" ]; then
    echo "⚠️ Legacy config found at $LEGACY_CONFIG"
    echo "   Recommendation: Consolidate into ~/.gemini/antigravity/mcp_config.json"
fi

echo "------------------------------------------------"
echo "📊 Current Tool Count Breakdown (Targets < 40)"

# This is a rough estimate based on standard server versions
# Actual count depends on the specific npx versions loaded
echo "| Server             | Est. Tools | Priority |"
echo "|--------------------|------------|----------|"

count=0

if grep -q "filesystem" "$PRIMARY_CONFIG"; then
    echo "| filesystem         | 15         | Critical |"
    ((count+=15))
fi

if grep -q "memory" "$PRIMARY_CONFIG"; then
    echo "| memory             | 8          | High     |"
    ((count+=8))
fi

if grep -q "github-minimal" "$PRIMARY_CONFIG"; then
    echo "| github-minimal     | 4          | High     |"
    ((count+=4))
fi

if grep -q "shell-minimal" "$PRIMARY_CONFIG"; then
    echo "| shell-minimal      | 4          | High     |"
    ((count+=4))
fi

if grep -q "playwright-minimal" "$PRIMARY_CONFIG"; then
    echo "| playwright-minimal | 4          | Med      |"
    ((count+=4))
fi

if grep -q "agent-autonomy" "$PRIMARY_CONFIG"; then
    echo "| agent-autonomy     | 4          | Med      |"
    ((count+=4))
fi

if grep -q "gas-fakes" "$PRIMARY_CONFIG"; then
    echo "| gas-fakes          | 1          | Low      |"
    ((count+=1))
fi

echo "------------------------------------------------"
echo "🔥 TOTAL ESTIMATED TOOLS: $count / 40"

if [ $count -gt 40 ]; then
    echo "🚨 ALERT: You are OVER the 40-tool limit!"
    echo "   Antigravity will likely disable some servers randomly."
    echo "   Recommendation: Remove non-essential servers."
elif [ $count -eq 40 ]; then
    echo "⚠️ WARNING: You are EXACTLY at the limit."
elif [ $count -eq 39 ]; then
    echo "✅ OPTIMAL: 39 tools (1-tool buffer for safety)."
else
    echo "✅ SAFE: You have $count tools configured."
fi
echo "------------------------------------------------"

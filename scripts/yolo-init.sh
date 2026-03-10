#!/usr/bin/env bash
# Unified & Optimized YOLO Initialization Script
# Version: 2.0.0
# Consolidates health checks, tool count, and project context into a single fast execution.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$ROOT_DIR/config"
MCP_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
[[ ! -f "$MCP_CONFIG" ]] && MCP_CONFIG="$CONFIG_DIR/mcp.json"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 YOLO Optimized Startup${NC}"
echo "=================================="

# 1. Resolve Project Context (Single Call)
PROJECT_JSON=$("$SCRIPT_DIR/get-current-project.sh" 2>/dev/null || echo "{}")
PROJECT_NAME=$(echo "$PROJECT_JSON" | jq -r '.project // empty')

if [[ -z "$PROJECT_NAME" ]]; then
    # Fallback/Default for this workflow
    export CURSOR_CURRENT_PROJECT="antigravity"
    PROJECT_JSON=$("$SCRIPT_DIR/get-current-project.sh")
    PROJECT_NAME=$(echo "$PROJECT_JSON" | jq -r '.project // empty')
fi

DEV_PATH=$(echo "$PROJECT_JSON" | jq -r '.development_path // empty')
RES_PATH=$(echo "$PROJECT_JSON" | jq -r '.resources_path // empty')
STARTUP_DOC=$(echo "$PROJECT_JSON" | jq -r '.agent_startup_path // empty')

# 2. Fast System Check
MISSING_DEPS=()
for cmd in jq node npm git; do
    command -v "$cmd" &> /dev/null || MISSING_DEPS+=("$cmd")
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Missing dependencies: ${MISSING_DEPS[*]}${NC}"
else
    echo -e "✅ System: ${GREEN}jq, node, npm, git ready${NC}"
fi

# 3. Consolidated Tool Count (Estimator)
count=0
if [[ -f "$MCP_CONFIG" ]]; then
    grep -q "filesystem" "$MCP_CONFIG" && ((count+=15))
    grep -q "memory" "$MCP_CONFIG" && ((count+=8))
    grep -q "github-minimal" "$MCP_CONFIG" && ((count+=4))
    grep -q "shell-minimal" "$MCP_CONFIG" && ((count+=4))
    grep -q "playwright-minimal" "$MCP_CONFIG" && ((count+=4))
    grep -q "agent-autonomy" "$MCP_CONFIG" && ((count+=4))
    grep -q "gas-fakes" "$MCP_CONFIG" && ((count+=1))
    
    TOOL_STATUS="${GREEN}$count/40${NC}"
    [[ $count -ge 40 ]] && TOOL_STATUS="${RED}$count/40 [LIMIT]${NC}"
    echo -e "📊 Tools: $TOOL_STATUS"
else
    echo -e "📊 Tools: ${YELLOW}Config not found${NC}"
fi

# 4. Project Context Dashboard
echo "----------------------------------"
if [[ -n "$PROJECT_NAME" ]]; then
    echo -e "📌 Project: ${YELLOW}$PROJECT_NAME${NC}"
    echo "📂 Dev: $DEV_PATH"
    echo "📂 Res: $RES_PATH"
    
    if [[ -n "$STARTUP_DOC" && -f "$STARTUP_DOC" ]]; then
        echo "----------------------------------"
        echo "📄 AGENT-STARTUP.md Snippet:"
        head -n 15 "$STARTUP_DOC"
    else
        echo -e "${YELLOW}⚠️  No AGENT-STARTUP.md found at expected path.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No project detected. Run /start-project to initialize.${NC}"
fi

echo "=================================="
echo -e "${GREEN}✅ System Initialized.${NC}"

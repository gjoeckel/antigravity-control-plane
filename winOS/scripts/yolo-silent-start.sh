#!/bin/bash
# scripts/yolo-silent-start.sh
# Version: 3.0.0
# Unified, silent startup for YOLO Autonomy.
# Returns "Ready" on success.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$ROOT_DIR/config/project-paths.json"
MCP_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"
[[ ! -f "$MCP_CONFIG" ]] && MCP_CONFIG="$ROOT_DIR/config/mcp.json"

# 1. Prompt for Project Paths (macOS picker)
PROJECT_NAME="${1:-antigravity}"
echo "🚀 Initializing YOLO for project: $PROJECT_NAME"
CURRENT_DEV_PATH=$(jq -r ".[\"$PROJECT_NAME\"].development.folder // \"\$HOME/Projects\"" "$CONFIG_FILE" 2>/dev/null || echo "$HOME/Projects")
CURRENT_RES_PATH=$(jq -r ".[\"$PROJECT_NAME\"].resources.folder // \"\$HOME/Agents/resources\"" "$CONFIG_FILE" 2>/dev/null || echo "$HOME/Agents/resources")

expand_home() { echo "${1//\$HOME/$HOME}"; }
normalize_path() {
  local path="$(expand_home "$1")"
  if [ -d "$path" ]; then
    (cd "$path" && pwd)
  else
    echo "$path"
  fi
}

DEV_FOLDER=$(osascript -e "POSIX path of (choose folder with prompt \"Select Antigravity development folder:\" default location (POSIX file \"$(normalize_path "$CURRENT_DEV_PATH")\"))" 2>/dev/null || echo "")
RES_FOLDER=$(osascript -e "POSIX path of (choose folder with prompt \"Select Antigravity resources folder:\" default location (POSIX file \"$(normalize_path "$CURRENT_RES_PATH")\"))" 2>/dev/null || echo "")

DEV_FOLDER=${DEV_FOLDER:-$(normalize_path "$CURRENT_DEV_PATH")}
RES_FOLDER=${RES_FOLDER:-$(normalize_path "$CURRENT_RES_PATH")}
DEV_FOLDER=${DEV_FOLDER%/}
RES_FOLDER=${RES_FOLDER%/}

# 2. Update Configuration
mkdir -p "$(dirname "$CONFIG_FILE")"
tmp_file="$(mktemp)"
if [ -f "$CONFIG_FILE" ]; then
  jq --arg project "$PROJECT_NAME" --arg dev "$DEV_FOLDER" --arg res "$RES_FOLDER" \
     ".[\$project].development.folder = \$dev | .[\$project].resources.folder = \$res" \
     "$CONFIG_FILE" > "$tmp_file"
else
  jq -n --arg project "$PROJECT_NAME" --arg dev "$DEV_FOLDER" --arg res "$RES_FOLDER" \
     "{(\$project): {development: {folder: \$dev, description: \"\"}, resources: {folder: \$res, description: \"\"}}}" \
     > "$tmp_file"
fi
mv "$tmp_file" "$CONFIG_FILE"

# 3. Validation (Silent)
for cmd in jq node npm git; do
  command -v "$cmd" &> /dev/null || { echo "Error: $cmd missing"; exit 1; }
done

# 4. Read AGENT-STARTUP.md (Internal/Silent)
# We check existence; the agent will read it directly if needed.
STARTUP_FILE=""
if [[ -f "$RES_FOLDER/AGENT-STARTUP.md" ]]; then
  STARTUP_FILE="$RES_FOLDER/AGENT-STARTUP.md"
elif [[ -f "$RES_FOLDER/Agent-Start.md" ]]; then
  STARTUP_FILE="$RES_FOLDER/Agent-Start.md"
fi

# 5. Output Ready
if [[ -n "$STARTUP_FILE" ]]; then
  echo "Ready"
else
  echo "Ready (No AGENT-STARTUP.md found)"
fi

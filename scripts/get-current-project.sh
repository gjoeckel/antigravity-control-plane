#!/usr/bin/env bash
# get-current-project.sh
# Resolves the current project name and paths from config/project-paths.json.
# Supports setting an override via CURSOR_CURRENT_PROJECT.
# Output is JSON for programmatic use.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$ROOT_DIR/config/project-paths.json"

# Expand $HOME in paths read from config
expand_home() { echo "${1//\$HOME/$HOME}"; }

# 1. Resolve Project Name
if [[ -n "${CURSOR_CURRENT_PROJECT:-}" ]]; then
    PROJECT_NAME="$CURSOR_CURRENT_PROJECT"
elif [[ -f "$CONFIG_FILE" ]]; then
    # Default to first key in config
    PROJECT_NAME=$(jq -r 'keys[0] // empty' "$CONFIG_FILE")
else
    PROJECT_NAME=""
fi

if [[ -z "$PROJECT_NAME" ]]; then
    echo "{}"
    exit 0
fi

# 2. Extract Paths
if [[ -f "$CONFIG_FILE" ]]; then
    DEV_PATH=$(jq -r ".\"$PROJECT_NAME\".development.folder // empty" "$CONFIG_FILE")
    RES_PATH=$(jq -r ".\"$PROJECT_NAME\".resources.folder // empty" "$CONFIG_FILE")
else
    DEV_PATH=""
    RES_PATH=""
fi

[[ -n "$DEV_PATH" ]] && DEV_PATH=$(expand_home "$DEV_PATH")
[[ -n "$RES_PATH" ]] && RES_PATH=$(expand_home "$RES_PATH")

# 3. Handle Startup Doc (always in resources)
STARTUP_PATH=""
if [[ -n "$RES_PATH" ]]; then
    STARTUP_PATH="$RES_PATH/AGENT-STARTUP.md"
fi

# 4. JSON Output
jq -n \
  --arg project "$PROJECT_NAME" \
  --arg dev "$DEV_PATH" \
  --arg res "$RES_PATH" \
  --arg startup "$STARTUP_PATH" \
  '{project: $project, development_path: $dev, resources_path: $res, agent_startup_path: $startup}'

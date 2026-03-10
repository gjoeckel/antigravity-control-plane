#!/bin/bash
# Display Project Directory Purposes
# Reads config/project-paths.json and explains the purpose of each directory

set -euo pipefail

# ========================================
# AUTO-DETECT SCRIPT LOCATION (Portable)
# ========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_GLOBAL_DIR="$(dirname "$SCRIPT_DIR")"

# Derived paths
CONFIG_DIR="$CURSOR_GLOBAL_DIR/config"
CONFIG_FILE="$CONFIG_DIR/project-paths.json"

echo ""
echo "📁 Project Directory Purposes"
echo "============================"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠️  Config file not found: $CONFIG_FILE"
    echo "   Run /start-project to set paths. Default placeholders: \$HOME/Projects, \$HOME/Agents/resources"
    echo ""
    exit 0
fi

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found. Install with: brew install jq"
    echo "   Run /start-project after installing jq to set paths."
    echo ""
    exit 0
fi

# Expand $HOME in path values from config
expand_home() { echo "${1//\$HOME/$HOME}"; }

# Read and display each project's directories
PROJECTS=$(jq -r 'keys[]' "$CONFIG_FILE" 2>/dev/null || echo "canvas_reports")

for project in $PROJECTS; do
    echo "🔹 Project: $project"
    echo ""

    # Get development folder
    DEV_FOLDER=$(jq -r ".[\"$project\"].development.folder // empty" "$CONFIG_FILE" 2>/dev/null)
    DEV_DESC=$(jq -r ".[\"$project\"].development.description // empty" "$CONFIG_FILE" 2>/dev/null)

    if [ -n "$DEV_FOLDER" ] && [ "$DEV_FOLDER" != "null" ]; then
        DEV_FOLDER=$(expand_home "$DEV_FOLDER")
        echo "📂 Development Folder: $DEV_FOLDER"
        if [ -d "$DEV_FOLDER" ]; then
            echo "   ✅ Directory exists"
        else
            echo "   ⚠️  Directory does not exist"
        fi
        if [ -n "$DEV_DESC" ] && [ "$DEV_DESC" != "null" ]; then
            echo "   Purpose: $DEV_DESC"
        fi
        echo ""
    fi

    # Get resources folder
    RES_FOLDER=$(jq -r ".[\"$project\"].resources.folder // empty" "$CONFIG_FILE" 2>/dev/null)
    RES_DESC=$(jq -r ".[\"$project\"].resources.description // empty" "$CONFIG_FILE" 2>/dev/null)

    if [ -n "$RES_FOLDER" ] && [ "$RES_FOLDER" != "null" ]; then
        RES_FOLDER=$(expand_home "$RES_FOLDER")
        echo "📂 Resources Folder: $RES_FOLDER"
        if [ -d "$RES_FOLDER" ]; then
            echo "   ✅ Directory exists"
        else
            echo "   ⚠️  Directory does not exist"
        fi
        if [ -n "$RES_DESC" ] && [ "$RES_DESC" != "null" ]; then
            echo "   Purpose: $RES_DESC"
        fi
        echo ""
    fi
done

echo "✅ Directory purposes displayed"
echo ""


#!/bin/bash
# Version: 1.0.0
# Show current project and its AGENT-STARTUP.md path; optionally print first N lines.
# Run from cursor-ops or with CURSOR_OPS set.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_OPS="${CURSOR_OPS:-$(dirname "$SCRIPT_DIR")}"
LINES="${1:-25}"

echo ""
echo "📌 Current project startup"
echo "=========================="

JSON=$("$SCRIPT_DIR/get-current-project.sh" 2>/dev/null || echo "{}")
PROJECT=$(echo "$JSON" | jq -r '.project // empty')
STARTUP=$(echo "$JSON" | jq -r '.agent_startup_path // empty')

if [[ -z "$PROJECT" ]]; then
  echo "No project from config. Set CURSOR_CURRENT_PROJECT or add projects to config/project-paths.json."
  echo ""
  exit 0
fi

echo "Project: $PROJECT"
echo "Startup doc: $STARTUP"
echo ""

if [[ -n "$STARTUP" && -f "$STARTUP" ]]; then
  echo "--- First $LINES lines of AGENT-STARTUP.md ---"
  head -n "$LINES" "$STARTUP"
  echo "---"
  echo ""
else
  echo "No AGENT-STARTUP.md at $STARTUP (create from docs/AGENT-STARTUP-TEMPLATE.md)."
  echo ""
fi

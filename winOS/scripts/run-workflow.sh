#!/usr/bin/env bash
# Version: 1.0.0
# Wrapper that sets CURSOR_OPS and runs a script from cursor-ops/scripts/.
# Usage: run-workflow.sh <script-name> [args...]
# Example: run-workflow.sh session-start
#          run-workflow.sh validate-autonomous-mode --json
# Workflows in config/workflows.json can point to this script; run setup.sh
# after clone to rewrite paths for your machine.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CURSOR_OPS="${CURSOR_OPS:-$(dirname "$SCRIPT_DIR")}"
NAME="${1:-}"
if [[ -z "$NAME" ]]; then
  echo "Usage: run-workflow.sh <script-name> [args...]" >&2
  exit 1
fi
# Allow script name with or without .sh
BASE="${NAME%.sh}"
SCRIPT="${SCRIPT_DIR}/${BASE}.sh"
if [[ ! -x "$SCRIPT" ]]; then
  echo "run-workflow.sh: script not found or not executable: $SCRIPT" >&2
  exit 1
fi
shift
exec bash "$SCRIPT" "$@"

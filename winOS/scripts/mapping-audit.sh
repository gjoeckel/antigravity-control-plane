#!/usr/bin/env bash
# mapping-audit — Run full mapping/divergence process: tree comparison, optional server vs local, DB call map.
# Invoke: mapping-audit (workflow) or bash scripts/mapping-audit.sh [--skip-ssh]
# Output: relocate/docs/status/mapping-audit-YYYY-MM-DD-HHMMSS.txt and stdout summary.
# After report: updates "Last updated" and "Last audit" (Source, Git ref) in mapping docs; updates ONLY-IN-TEST-PATHS.md checklist (project resources).
# See project resources: MAPPING-DIVERGENCE-METHODS.md, DB-CALL-MAP.md.
# Version: 1.2.0

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_OPS="${CURSOR_OPS:-$(dirname "$SCRIPT_DIR")}"
PROJECT_PATHS="${CURSOR_OPS}/config/project-paths.json"
PROD_TREE="${PROD_TREE:-}"
TEST_TREE="${TEST_TREE:-}"
RESOURCES_OTTER="${RESOURCES_OTTER:-}"
SKIP_SSH=false
SSH_HOST="${SSH_HOST:-webaim-deploy}"
SERVER_PROD="/var/websites/webaim/htdocs/onlinecourses"
SERVER_TEST="/var/websites/webaim/htdocs/onlinecourses-otter"

for arg in "$@"; do
  [[ "$arg" == "--skip-ssh" ]] && SKIP_SSH=true
done

# Resolve paths from project-paths.json (development/resources only; set PROD_TREE via env if needed)
if [[ -f "$PROJECT_PATHS" ]] && command -v jq &>/dev/null; then
  TEST_TREE="${TEST_TREE:-$(jq -r '.canvas_reports.development.folder // .otter.development.folder // empty' "$PROJECT_PATHS")}"
  RESOURCES_OTTER="${RESOURCES_OTTER:-$(jq -r '.canvas_reports.resources.folder // .otter.resources.folder // empty' "$PROJECT_PATHS")}"
fi
PROD_TREE="${PROD_TREE:-$HOME/Projects/onlinecourses}"
TEST_TREE="${TEST_TREE:-$HOME/Projects/otter}"
RESOURCES_OTTER="${RESOURCES_OTTER:-$HOME/Agents/resources/otter}"
# Expand $HOME in paths from config
[[ -n "$TEST_TREE" && "$TEST_TREE" == *'$HOME'* ]] && TEST_TREE="${TEST_TREE//\$HOME/$HOME}"
[[ -n "$RESOURCES_OTTER" && "$RESOURCES_OTTER" == *'$HOME'* ]] && RESOURCES_OTTER="${RESOURCES_OTTER//\$HOME/$HOME}"
[[ -n "$PROD_TREE" && "$PROD_TREE" == *'$HOME'* ]] && PROD_TREE="${PROD_TREE//\$HOME/$HOME}"

REPORT_DIR="${CURSOR_OPS}/relocate/docs/status"
mkdir -p "$REPORT_DIR"
REPORT_FILE="${REPORT_DIR}/mapping-audit-$(date '+%Y-%m-%d-%H%M%S').txt"

exec 3>&1
exec 1>"$REPORT_FILE"
echo "Mapping audit — $(date '+%Y-%m-%d %H:%M:%S')"
echo "PROD_TREE=$PROD_TREE"
echo "TEST_TREE=$TEST_TREE"
echo "SKIP_SSH=$SKIP_SSH"
echo ""

# --- 1. Local tree comparison (prod vs test) ---
echo "========== 1. Local app tree: prod vs test =========="
echo ""
PROD_LIST=$(mktemp)
TEST_LIST=$(mktemp)
ONLY_IN_TEST_LIST=$(mktemp)
trap "rm -f '$PROD_LIST' '$TEST_LIST' '$ONLY_IN_TEST_LIST'" EXIT

(cd "$PROD_TREE" && find . -type f -o -type d | grep -v '^\./\.git' | grep -v '.DS_Store' | sort) | sed 's|^\./||' | sort -u > "$PROD_LIST"
(cd "$TEST_TREE" && find . -type f -o -type d | grep -v '^\./\.git' | grep -v '.DS_Store' | grep -v node_modules | sort) | sed 's|^\./||' | sort -u > "$TEST_LIST"

echo "Only in production (local):"
diff "$TEST_LIST" "$PROD_LIST" | sed -n 's/^> //p' || true
echo ""
echo "Only in test (local):"
diff "$PROD_LIST" "$TEST_LIST" | sed -n 's/^> //p' | tee "$ONLY_IN_TEST_LIST" || true
echo ""
echo "Tag only-in-test paths as: required | legacy-deprecated | unclassified (see MAPPING-DIVERGENCE-METHODS; checklist: ONLY-IN-TEST-PATHS.md)."
echo ""

# --- 2. Optional: server vs local ---
if [[ "$SKIP_SSH" != true ]]; then
  echo "========== 2. Server vs local (test) =========="
  echo ""
  if ssh -o ConnectTimeout=5 -o BatchMode=yes "$SSH_HOST" "find $SERVER_TEST -type f -o -type d 2>/dev/null | grep -v .git | sort" 2>/dev/null | sed "s|$SERVER_TEST/||" | sed 's|^/||' | sort -u > "${TEST_LIST}.server"; then
    echo "Server test tree saved. Diff vs local test:"
    diff "${TEST_LIST}.server" "$TEST_LIST" | head -80 || true
    echo "(First 80 lines of diff; full report in temp files.)"
    rm -f "${TEST_LIST}.server"
  else
    echo "SSH to $SSH_HOST failed or timed out. Run with --skip-ssh to skip server comparison."
  fi
  echo ""
else
  echo "========== 2. Server vs local =========="
  echo "Skipped (--skip-ssh)."
  echo ""
fi

# --- 3. DB call map (otter) ---
echo "========== 3. DB usage map (otter) =========="
echo ""
export CURSOR_OPS
"$SCRIPT_DIR/map-otter-db-usage.sh" "$TEST_TREE" 2>&1 || true
echo ""

# --- 4. Reminder ---
AUDIT_DATE=$(date '+%Y-%m-%d')
GIT_REF=$(git -C "$TEST_TREE" rev-parse --short HEAD 2>/dev/null || echo 'n/a')
BRANCH=$(git -C "$TEST_TREE" branch --show-current 2>/dev/null || echo 'n/a')
echo "========== Next steps =========="
echo "• \"Last updated\" in PRODUCTION-SERVER-MAPPING.md, TEST-SERVER-MAPPING.md, and DB-CALL-MAP.md is set automatically to this run date."
echo "• Deploy/snapshot suggestion (written to mapping docs): Date $AUDIT_DATE, Source: Local ($TEST_TREE), Git ref: $GIT_REF (branch: $BRANCH)."
echo "• Tag only-in-test paths in ONLY-IN-TEST-PATHS.md as required / legacy-deprecated / unclassified."
echo "• If schema or DB-touching code changed, refresh production_database_schema.md and the table list in DB-CALL-MAP.md in project resources."
echo "• Report saved to: $REPORT_FILE"
echo ""

exec 1>&3 3>&-
echo "✅ Mapping audit complete. Report: $REPORT_FILE"

# --- 5. Update mapping docs (project resources) ---
UPDATED=""
if [[ -d "$RESOURCES_OTTER" ]]; then
  for f in "PRODUCTION-SERVER-MAPPING.md" "TEST-SERVER-MAPPING.md" "DB-CALL-MAP.md"; do
    F_PATH="${RESOURCES_OTTER}/${f}"
    if [[ -f "$F_PATH" ]]; then
      if sed -i '' "s/\*\*Last updated:\*\* [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/**Last updated:** $AUDIT_DATE/" "$F_PATH" 2>/dev/null; then
        UPDATED="${UPDATED} $f"
      fi
    fi
  done
  # Add or replace "Last audit" (Source, Git ref) in mapping docs (prod and test only)
  for f in "PRODUCTION-SERVER-MAPPING.md" "TEST-SERVER-MAPPING.md"; do
    F_PATH="${RESOURCES_OTTER}/${f}"
    if [[ -f "$F_PATH" ]]; then
      sed -i '' "s|^\*\*Last audit:\*\*.*|**Last audit:** $AUDIT_DATE, Source: Local, Git ref: $GIT_REF|" "$F_PATH" 2>/dev/null || true
      grep -q '\*\*Last audit:\*\*' "$F_PATH" 2>/dev/null || \
        sed -i '' "/^\*\*Source:\*\*/a\\
**Last audit:** $AUDIT_DATE, Source: Local, Git ref: $GIT_REF" "$F_PATH" 2>/dev/null || true
    fi
  done
  # Only-in-test checklist: path list with Category column for required | legacy-deprecated | unclassified
  ONLY_IN_TEST_MD="${RESOURCES_OTTER}/ONLY-IN-TEST-PATHS.md"
  if [[ -s "$ONLY_IN_TEST_LIST" ]]; then
    {
      echo "# Only-in-test paths — tag each as required | legacy-deprecated | unclassified"
      echo ""
      echo "Generated by mapping-audit on $AUDIT_DATE. Fill the Category column; see MAPPING-DIVERGENCE-METHODS."
      echo ""
      echo "| Path | Category |"
      echo "|------|----------|"
      while IFS= read -r p || [[ -n "$p" ]]; do
        [[ -z "$p" ]] && continue
        echo "| $p | |"
      done < "$ONLY_IN_TEST_LIST"
    } > "$ONLY_IN_TEST_MD"
    echo "   Wrote ONLY-IN-TEST-PATHS.md (path list with Category column to fill)."
  fi
  if [[ -n "$UPDATED" ]]; then
    echo "   Updated \"Last updated\" to $AUDIT_DATE in:$UPDATED"
    echo "   Set \"Last audit\" to $AUDIT_DATE, Source: Local, Git ref: $GIT_REF in PRODUCTION-SERVER-MAPPING.md and TEST-SERVER-MAPPING.md."
  else
    echo "   Could not update mapping docs in $RESOURCES_OTTER (check path or permissions)."
  fi
else
  echo "   Skipped doc updates: RESOURCES_OTTER not found ($RESOURCES_OTTER)."
fi
echo "   Next: Fill Category in ONLY-IN-TEST-PATHS.md (required/legacy-deprecated/unclassified) as needed."

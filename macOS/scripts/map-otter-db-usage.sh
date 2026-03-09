#!/usr/bin/env bash
# Map DB usage in onlinecourses-otter for PDO migration planning.
# Output: per-file list of methods used (query, fetchArray, fetchAll, affectedRows, lastInsertID)
#         and source of $db (new db() vs getDbConnection()).
#
# Usage: bash scripts/map-otter-db-usage.sh [path/to/otter]
#   If path omitted: uses OTTER_ROOT or development folder from config/project-paths.json (canvas_reports).
#   From cursor-ops: CURSOR_OPS=/path/to/cursor-ops or run from repo root.
# Version: 1.0.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_OPS="${CURSOR_OPS:-$(dirname "$SCRIPT_DIR")}"
CONFIG="$CURSOR_OPS/config/project-paths.json"

# Resolve otter root
OTTER_ROOT="${1:-${OTTER_ROOT:-}}"
if [[ -z "$OTTER_ROOT" && -f "$CONFIG" ]]; then
  # Prefer canvas_reports.development.folder (otter)
  OTTER_ROOT="$(node -e "
    try {
      const j = require('fs').readFileSync('$CONFIG','utf8');
      const c = JSON.parse(j);
      const dev = (c.canvas_reports && c.canvas_reports.development && c.canvas_reports.development.folder)
        || (c.otter && c.otter.development && c.otter.development.folder);
      if (dev) console.log(dev);
    } catch (_) {}
  " 2>/dev/null)"
fi
if [[ -z "$OTTER_ROOT" || ! -d "$OTTER_ROOT" ]]; then
  echo "Usage: $0 [path/to/otter]" >&2
  echo "  Or set OTTER_ROOT or configure project-paths.json (canvas_reports.development.folder)." >&2
  exit 1
fi

echo "Otter DB usage map — $(date '+%Y-%m-%d %H:%M')"
echo "OTTER_ROOT=$OTTER_ROOT"
echo ""

# Files that use DB layer (exclude vendor and this script's repo)
FILES=()
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "$OTTER_ROOT" -type f -name "*.php" \
  ! -path "*/vendor/*" \
  ! -path "*/.git/*" \
  -print0 2>/dev/null)

# Patterns: method calls and DB source
query_count=0
fetchArray_count=0
fetchAll_count=0
affectedRows_count=0
lastInsertID_count=0
getDbConnection_count=0
new_db_count=0
DbMysqliWrapper_count=0
includes_db_count=0

print_file() {
  local file="$1"
  local rel="${file#$OTTER_ROOT/}"
  local q farr fall aff last get new_ wrap inc
  q=$(grep -c '\$db->query\(' "$file" 2>/dev/null || true)
  farr=$(grep -c '\$db->fetchArray()' "$file" 2>/dev/null || true)
  fall=$(grep -c '\$db->fetchAll()' "$file" 2>/dev/null || true)
  aff=$(grep -c '->affectedRows()' "$file" 2>/dev/null || true)
  last=$(grep -c '->lastInsertID()' "$file" 2>/dev/null || true)
  get=$(grep -c 'getDbConnection()' "$file" 2>/dev/null || true)
  new_=$(grep -c 'new db(' "$file" 2>/dev/null || true)
  wrap=$(grep -c 'DbMysqliWrapper' "$file" 2>/dev/null || true)
  inc=$(grep -c 'includes/db\.php\|db\.php' "$file" 2>/dev/null || true)

  # Also check $this->db-> for session handler
  if [[ $q -eq 0 ]]; then
    q=$(grep -c '\$this->db->query(' "$file" 2>/dev/null || true)
  fi
  if [[ $farr -eq 0 ]]; then
    farr=$(grep -c '\$this->db->fetchArray()' "$file" 2>/dev/null || true)
  fi
  if [[ $aff -eq 0 ]]; then
    aff=$(grep -c '\$this->db->affectedRows()' "$file" 2>/dev/null || true)
  fi

  [[ $q -eq 0 && $farr -eq 0 && $fall -eq 0 && $aff -eq 0 && $last -eq 0 && $get -eq 0 && $new_ -eq 0 && $wrap -eq 0 && $inc -eq 0 ]] && return

  echo "--- $rel"
  [[ $q -gt 0 ]]     && echo "    query: $q"        && ((query_count+=q))
  [[ $farr -gt 0 ]]   && echo "    fetchArray: $farr" && ((fetchArray_count+=farr))
  [[ $fall -gt 0 ]]   && echo "    fetchAll: $fall"   && ((fetchAll_count+=fall))
  [[ $aff -gt 0 ]]    && echo "    affectedRows: $aff" && ((affectedRows_count+=aff))
  [[ $last -gt 0 ]]   && echo "    lastInsertID: $last" && ((lastInsertID_count+=last))
  [[ $get -gt 0 ]]    && echo "    getDbConnection: $get" && ((getDbConnection_count+=get))
  [[ $new_ -gt 0 ]]   && echo "    new db(): $new_"  && ((new_db_count+=new_))
  [[ $wrap -gt 0 ]]   && echo "    DbMysqliWrapper refs: $wrap" && ((DbMysqliWrapper_count+=wrap))
  [[ $inc -gt 0 ]]    && echo "    includes/db.php refs: $inc" && ((includes_db_count+=inc))
  echo ""
}

for f in "${FILES[@]}"; do
  print_file "$f"
done

echo "=== Totals (approximate)"
echo "  query: $query_count"
echo "  fetchArray: $fetchArray_count"
echo "  fetchAll: $fetchAll_count"
echo "  affectedRows: $affectedRows_count"
echo "  lastInsertID: $lastInsertID_count"
echo "  getDbConnection: $getDbConnection_count"
echo "  new db(): $new_db_count"
echo "  DbMysqliWrapper refs: $DbMysqliWrapper_count"
echo "  includes/db.php refs: $includes_db_count"
echo ""
echo "Use this map to guide Phase 2 (migrate call sites) and Phase 3 (verify no legacy usage)."

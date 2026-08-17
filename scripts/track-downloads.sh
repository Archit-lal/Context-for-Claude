#!/usr/bin/env bash
# Record the current GitHub release download count in metrics/downloads.csv.
# One row per UTC day; re-running the same day replaces that day's row.
set -euo pipefail

REPO="BasedHardware/omi"
TAG="context-for-claude-latest"
ASSET="ContextForClaude.dmg"
OUT="$(cd "$(dirname "$0")/.." && pwd)/metrics/downloads.csv"

auth=()
[ -n "${GH_API_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GH_API_TOKEN")

json=$(curl -fsSL -m 20 "${auth[@]}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$REPO/releases/tags/$TAG")

count=$(printf '%s' "$json" | ASSET="$ASSET" TAG="$TAG" python3 -c '
import json, os, sys
asset, tag = os.environ["ASSET"], os.environ["TAG"]
hit = [a for a in json.load(sys.stdin).get("assets", []) if a["name"] == asset]
if not hit:
    sys.exit("asset " + asset + " not found in release " + tag)
print(hit[0]["download_count"])
')

today=$(date -u +%F)
mkdir -p "$(dirname "$OUT")"
[ -f "$OUT" ] || echo "date,downloads" > "$OUT"

prev_line=$(grep -v -e "^date," -e "^$today," "$OUT" | tail -1 || true)

# Drop today's existing row, then append the fresh reading.
if grep -q "^$today," "$OUT"; then
  tmp=$(mktemp)
  grep -v "^$today," "$OUT" > "$tmp"
  mv "$tmp" "$OUT"
fi
echo "$today,$count" >> "$OUT"

if [ -n "$prev_line" ]; then
  prev_date=${prev_line%%,*}
  prev_count=${prev_line##*,}
  echo "$today: $count downloads (+$((count - prev_count)) since $prev_date)"
else
  echo "$today: $count downloads (first reading)"
fi

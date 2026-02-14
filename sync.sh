#!/usr/bin/env bash
set -euo pipefail

PROJECT=${1:-}
DIRECTION=${2:-}
CONF_FILE="$(pwd)/sync.json"

if [[ -z "$PROJECT" || -z "$DIRECTION" ]]; then
  echo "❌ Usage: ./sync.sh <project> <push|pull>"
  exit 1
fi

if [[ "$DIRECTION" != "push" && "$DIRECTION" != "pull" ]]; then
  echo "❌ Direction must be 'push' or 'pull'"
  exit 1
fi

ENTRIES=$(jq -c ".projects[\"$PROJECT\"][]" "$CONF_FILE" 2>/dev/null || true)

if [[ -z "$ENTRIES" ]]; then
  echo "❌ No config found for project: $PROJECT"
  exit 1
fi

echo "🔄 Project: $PROJECT"
echo "➡️  Mode   : $DIRECTION"
echo

echo "$ENTRIES" | while read -r entry; do
  NAME=$(jq -r '.name' <<< "$entry")
  MASTER=$(jq -r '.master' <<< "$entry")
  PROJECT_DIR=$(jq -r '.project' <<< "$entry")

  if [[ "$DIRECTION" == "push" ]]; then
    SRC="$MASTER"
    DEST="$PROJECT_DIR"
  else
    SRC="$PROJECT_DIR"
    DEST="$MASTER"
  fi

  if [[ ! -d "$SRC" ]]; then
    echo "⚠️  [$NAME] Source missing: $SRC"
    continue
  fi

  echo "→ [$NAME]"
  echo "   SRC : $SRC"
  echo "   DEST: $DEST"

  mkdir -p "$DEST"
  rsync -av --delete "$SRC/" "$DEST/"
  echo
done

echo "✅ Sync complete"


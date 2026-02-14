#!/usr/bin/env bash
set -euo pipefail

PROJECT=$1
CONF_FILE="$(cd "$(dirname "$0")/.." && pwd)/sync.json"

if [[ -z "${PROJECT:-}" ]]; then
  echo "❌ Usage: sync.sh <project-name>"
  exit 1
fi

if [[ ! -f "$CONF_FILE" ]]; then
  echo "❌ Config not found: sync.json"
  exit 1
fi

ENTRIES=$(jq -c ".projects[\"$PROJECT\"][]" "$CONF_FILE" 2>/dev/null || true)

if [[ -z "$ENTRIES" ]]; then
  echo "❌ No config found for project: $PROJECT"
  exit 1
fi

echo "🔄 Syncing project: $PROJECT"
echo

echo "$ENTRIES" | while read -r entry; do
  NAME=$(jq -r '.name' <<< "$entry")
  SRC=$(jq -r '.source' <<< "$entry")
  DEST=$(jq -r '.dest' <<< "$entry")

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

echo "✅ Sync complete for $PROJECT"


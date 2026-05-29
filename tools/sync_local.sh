#!/usr/bin/env bash
# Fast local-test sync: stage the mod, then copy it directly into the
# subscribed Workshop content folder. DST loads the mod from there, so this
# skips the entire Workshop upload→Steam-sync cycle.
#
# Workflow:  edit code → ./tools/sync_local.sh → restart DST → test
#
# The Workshop content folder IS writable (it's NOT inside the code-signed
# .app bundle). We only avoid touching mod.manifest (Steam's own metadata).

set -euo pipefail

MOD_ID="3732043578"
WS="$HOME/Library/Application Support/Steam/steamapps/workshop/content/322330/$MOD_ID"
STAGED="$HOME/Desktop/pham-nhan-tu-tien-upload"

if [[ ! -d "$WS" ]]; then
    echo "✗ Workshop folder not found: $WS"
    echo "  Are you subscribed to the mod on Steam? Subscribe once, then this works."
    exit 1
fi

# 1. Re-stage from source (runs checks via the staging script's own logic)
echo "→ Staging mod..."
"$(dirname "$0")/prepare_workshop_upload.sh" > /dev/null

# 2. Mirror staged → workshop folder (preserve Steam's mod.manifest)
echo "→ Syncing to Workshop content folder..."
rsync -a --delete --exclude="mod.manifest" "$STAGED/" "$WS/"

echo "✓ Synced version $(grep '^version' "$WS/modinfo.lua" | sed 's/version *= *//')"
echo ""
echo "Next: fully quit DST (Cmd+Q) and relaunch, then Host Game."
echo "(DST caches mod code at launch — a restart is required to pick up changes.)"

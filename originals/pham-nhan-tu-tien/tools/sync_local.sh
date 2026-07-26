#!/usr/bin/env bash
# Fast local-test sync: stage the mod, then copy it as a REAL FOLDER into the
# game's local mods directory (Contents/mods/). DST scans that dir and shows
# local mods in the Server Mods menu — no Workshop upload needed.
#
# Workflow:  edit code → ./tools/sync_local.sh → restart DST → enable in Mods menu → test
#
# Why a real folder (not symlink, not workshop content):
#   - Symlinks into Contents/mods/ can go stale/broken (we hit this — a dead
#     symlink to /tmp silently failed to load).
#   - User-created folders under Contents/mods/ ARE writable (the macOS
#     provenance lock only applies to Steam-installed files in the bundle).
#   - This matches how the working `tu-tien-lite` local mod is set up.

set -euo pipefail

MODS_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
DEST="$MODS_DIR/pham-nhan-tu-tien"
STAGED="$HOME/Desktop/pham-nhan-tu-tien-upload"

if [[ ! -d "$MODS_DIR" ]]; then
    echo "✗ DST mods dir not found: $MODS_DIR"
    exit 1
fi

# 1. Re-stage from source
echo "→ Staging mod..."
"$(dirname "$0")/prepare_workshop_upload.sh" > /dev/null

# 2. Replace the local mod folder with the fresh staged copy
echo "→ Copying into local mods folder..."
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$STAGED/" "$DEST/"

echo "✓ Synced version $(grep '^version' "$DEST/modinfo.lua" | sed 's/version *= *//') to:"
echo "  $DEST"
echo ""
echo "Next:"
echo "  1. Fully quit DST (Cmd+Q) and relaunch."
echo "  2. Mods → Server Mods → enable 'Phàm Nhân Tu Tiên [Alpha]'."
echo "  3. Host Game and test."

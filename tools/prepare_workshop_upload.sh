#!/usr/bin/env bash
# Stage the mod for Workshop upload — copies only files that should ship,
# excludes dev docs, reference, PDF, etc. Output: a clean folder under /tmp
# that ModUploader can point at.

set -euo pipefail

SRC="/Users/kimdat546/Desktop/pham-nhan-tu-tien-mod"
DEST="/tmp/pntt_mod_workshop"

echo "→ Cleaning staging dir at $DEST..."
rm -rf "$DEST"
mkdir -p "$DEST"

echo "→ Copying mod files (excluding dev artifacts)..."

# Required mod root files
cp "$SRC/modinfo.lua"    "$DEST/"
cp "$SRC/modmain.lua"    "$DEST/"
cp "$SRC/modicon.tex"    "$DEST/"
cp "$SRC/modicon.xml"    "$DEST/"
[ -f "$SRC/PLACEHOLDER.md" ] && cp "$SRC/PLACEHOLDER.md" "$DEST/"

# Steam Workshop preview image (512x512 RGBA PNG, separate from in-game modicon)
if [ -f "$SRC/preview.png" ]; then
    cp "$SRC/preview.png" "$DEST/"
    echo "    + preview.png (Workshop cover)"
else
    echo "    ⚠ no preview.png at mod root — Workshop upload form will prompt for one"
fi

# Game content directories
for dir in scripts images bigportraits anim strings; do
    if [ -d "$SRC/$dir" ]; then
        cp -R "$SRC/$dir" "$DEST/"
        echo "    + $dir/"
    fi
done

# Remove dev-only files from staged scripts
# (debug.lua and reference paths get pruned even though we ship them)
# Per Plan 7: debug.lua stays — useful for testers. Just remove obvious cruft:
find "$DEST" -name ".DS_Store" -delete
find "$DEST" -name "*.bak"     -delete

# Size sanity check
SIZE_MB=$(du -sm "$DEST" | cut -f1)
echo ""
echo "→ Staged mod size: ${SIZE_MB} MB (Workshop limit: 250 MB)"

if [ "$SIZE_MB" -gt 250 ]; then
    echo "✗ Mod is too large for Workshop! Reduce assets before upload."
    exit 1
fi

echo "✓ Staging done at $DEST"
echo ""
echo "Next steps (Klei in-game Workshop upload flow):"
echo ""
echo "1. Point DST at the staged folder:"
echo "   DST_MODS=\"\$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods\""
echo "   ln -sfn $DEST \"\$DST_MODS/pntt_mod\""
echo ""
echo "2. Open DST → Main menu → Mods → find 'Phàm Nhân Tu Tiên' in list"
echo "3. Click on it → press 'Submit Mod To Workshop' button"
echo "4. In upload form: choose preview image, set visibility to Unlisted, add changelog"
echo "5. Click Submit. Workshop URL appears when done."

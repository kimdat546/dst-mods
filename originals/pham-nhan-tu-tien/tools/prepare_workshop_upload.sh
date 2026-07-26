#!/usr/bin/env bash
# Stage the mod for Workshop upload — copies only files that should ship,
# excludes dev docs, reference, PDF, etc. Output: a clean folder under /tmp
# that ModUploader can point at.

set -euo pipefail

SRC="/Users/kimdat546/Desktop/pham-nhan-tu-tien-mod"
DEST="/Users/kimdat546/Desktop/pham-nhan-tu-tien-upload"

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
echo "Next steps:"
echo "  1. Open your Klei mod upload tool (the same one you used for dang-tien-viet-mod-upload)"
echo "  2. When asked to select the mod folder, browse to:"
echo "       $DEST"
echo "  3. Fill metadata (most auto-loaded from modinfo.lua)"
echo "  4. Choose preview image, set visibility = Unlisted, write changelog"
echo "  5. Submit"

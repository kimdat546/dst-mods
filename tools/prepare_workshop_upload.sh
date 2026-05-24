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
echo "Next: open Don't Starve Mod Tools / ModUploader.app and point it at:"
echo "  $DEST"

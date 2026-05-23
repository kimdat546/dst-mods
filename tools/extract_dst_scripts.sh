#!/usr/bin/env bash
set -euo pipefail

DST_BUNDLE="/Users/kimdat546/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip"
OUT_DIR="$(dirname "$0")/../reference/dst-scripts"

if [[ ! -f "$DST_BUNDLE" ]]; then
    echo "✗ DST scripts.zip not found at expected path:"
    echo "  $DST_BUNDLE"
    exit 1
fi

mkdir -p "$OUT_DIR"
unzip -o "$DST_BUNDLE" -d "$OUT_DIR" > /dev/null
echo "✓ Extracted $(find "$OUT_DIR" -name '*.lua' | wc -l | tr -d ' ') Lua files to $OUT_DIR"

#!/usr/bin/env bash
# Dựng bản build TEST: giống bản thật, chỉ thêm cờ bật selftest.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/../.." && pwd)"
DST="$(dirname "$0")/build/food-buff-hud"
rm -rf "$DST"; mkdir -p "$DST"
rsync -a --exclude 'tools' --exclude '.git' --exclude 'README.md' "$SRC"/ "$DST"/
sed -i '' 's|^local _G = GLOBAL$|local _G = GLOBAL\n_G.FOODBUFFHUD_SELFTEST = true|' "$DST/modmain.lua"
grep -n "FOODBUFFHUD_SELFTEST = true" "$DST/modmain.lua" | head -1
for f in $(find "$DST" -name "*.lua"); do luac -p "$f" || { echo "✗ $f"; exit 1; }; done
echo "✓ bản build test sẵn sàng ($(find "$DST" -name '*.lua' | wc -l | tr -d ' ') file lua)"

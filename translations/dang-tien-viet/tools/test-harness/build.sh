#!/usr/bin/env bash
# Dựng bản build TEST của mod dịch: giống bản thật, chỉ khác 2 điểm
#   1. client_only_mod = false  → dedicated server mới chịu nạp
#   2. bật cờ DANGTIEN_SELFTEST → selftest.lua chạy và in kết quả ra log
set -euo pipefail
SRC="$1"; DST="$2"
rm -rf "$DST"; mkdir -p "$DST"
rsync -a --exclude '.git' --exclude '*.txt' --exclude 'translation_pipeline' \
      --exclude '.claude' "$SRC"/ "$DST"/
sed -i '' 's/^client_only_mod = true/client_only_mod = false/' "$DST/modinfo.lua"
sed -i '' 's|^modimport("scripts/main.lua")|_G.DANGTIEN_SELFTEST = true\nmodimport("scripts/main.lua")|' "$DST/modmain.lua"
grep -E '^client_only_mod|^all_clients_require_mod' "$DST/modinfo.lua"
grep -n 'SELFTEST' "$DST/modmain.lua"

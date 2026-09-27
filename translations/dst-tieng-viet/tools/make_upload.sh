#!/usr/bin/env bash
# Dựng thư mục SẠCH để upload Workshop (ID 3683660917): upload/dst-tieng-viet
#
#   ./tools/make_upload.sh 2026.9      # số version mới (bắt buộc)
#
# Thay quy trình cũ "rsync tay sang ~/Desktop/dst-viet-mod". Tự làm:
#   1. đồng bộ khoá với strings.pot + kiểm placeholder (sync_check)
#   2. sinh lại textfix từ .po (tao_textfix) — hai lớp dịch luôn khớp
#   3. kiểm cú pháp mọi file .lua bằng luajit (cùng cú pháp 5.1 với DST)
#   4. chép đúng các file cần, đặt version + ngày vào modinfo bản upload
# ⚠ KHÔNG chép mod.manifest — xem ghi chú forcemanifest trong modinfo.lua.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:?cần số version, vd ./tools/make_upload.sh 2026.9}"
OUT="$SRC/upload/dst-tieng-viet"

echo "▸ Đồng bộ + kiểm với strings.pot…"
python3 "$SRC/tools/sync_check.py" | sed 's/^/  /'
python3 "$SRC/tools/sync_check.py" | grep -q "placeholder lệch *0" || { echo "✗ còn placeholder lệch"; exit 1; }

echo "▸ Sinh textfix từ .po…"
python3 "$SRC/tools/tao_textfix.py" | sed 's/^/  /'

echo "▸ Kiểm cú pháp Lua…"
for f in "$SRC"/modinfo.lua "$SRC"/modmain.lua "$SRC"/scripts/*.lua "$SRC"/scripts/textfix/*.lua; do
    luajit -bl "$f" >/dev/null || { echo "✗ lỗi cú pháp: $f"; exit 1; }
done
echo "  ✓ OK"

echo "▸ Chép sang upload/…"
rm -rf "$OUT"; mkdir -p "$OUT"
cp "$SRC"/{modinfo.lua,modmain.lua,vietnamese.po,DST_Vietnamese.tex,DST_Vietnamese.xml,preview.png} "$OUT/"
rsync -a "$SRC/scripts/" "$OUT/scripts/"
NGAY="$(date +%d/%m/%Y)"
python3 - "$OUT/modinfo.lua" "$VER" "$NGAY" <<'PY'
import re,sys
p,ver,ngay=sys.argv[1:]; s=open(p,encoding='utf-8').read()
s=re.sub(r'^version = ".*"', f'version = "{ver}"', s, flags=re.M)
s=re.sub(r'Cập nhật lần cuối ngày [0-9/]+', f'Cập nhật lần cuối ngày {ngay}', s)
open(p,'w',encoding='utf-8').write(s)
PY
grep -E '^version|Cập nhật' "$OUT/modinfo.lua" | sed 's/^/  /'
P=$(( $(stat -f%z "$OUT/preview.png") / 1024 )); [[ $P -le 1024 ]] || { echo "✗ preview.png ${P}KB > 1MB"; exit 1; }
echo
echo "✓ Sẵn sàng: $OUT"
echo "  Don't Starve Mod Tools → Upload Existing Mod → chọn thư mục trên → Workshop ID 3683660917"

#!/usr/bin/env bash
# Dựng thư mục SẠCH để đẩy AI Làng lên Steam Workshop.
#
#   ./tools/make_upload.sh
#
# Chỉ đóng gói phần người chơi cần. KHÔNG đưa lên:
#   tam-tri/                  dịch vụ suy nghĩ bằng Python, chạy ngoài game
#   tools/                    công cụ + server test (hàng GB)
#   scripts/ailang/tu_kiem.lua  bộ tự kiểm 3.500 dòng cho người phát triển.
#                             Chỉ gọi qua c_ailang_kiem bằng pcall, nên vắng nó
#                             thì lệnh đó báo lỗi nhẹ chứ không hỏng gì.
#
# Ảnh: đặt assets/icon_source.png (vuông) và assets/preview_source.png
# (tuỳ, ngang) rồi chạy lại — script tự dựng modicon + preview bằng
# tools/make_modicon.py dùng chung ở gốc kho.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
GOC="$(cd "$SRC/../.." && pwd)"
OUT="$SRC/upload/dst-ai-village"

if command -v luajit >/dev/null; then CHECK="luajit -bl"; else
    CHECK="luac -p"
    echo "⚠ không có luajit, dùng luac (5.5) — không bắt được khác biệt Lua 5.1"
fi

echo "▸ Ảnh…"
if [[ -f "$SRC/assets/icon_source.png" ]]; then
    python3 "$GOC/tools/make_modicon.py" "$SRC/assets/icon_source.png" "$SRC/assets" | sed 's/^/  /'
    # Ảnh preview ngang riêng thì ưu tiên nó hơn bản vuông make_modicon sinh ra.
    if [[ -f "$SRC/assets/preview_source.png" ]]; then
        python3 - "$SRC/assets/preview_source.png" "$SRC/assets/preview.png" <<'PY'
import sys
from PIL import Image
src, out = sys.argv[1], sys.argv[2]
img = Image.open(src).convert("RGB")
for w in (1280, 1024, 896, 768, 640):
    h = round(img.height * w / img.width)
    img.resize((w, h), Image.LANCZOS).save(out, "PNG", optimize=True)
    import os
    if os.path.getsize(out) <= 1024 * 1024:
        print(f"  ✓ preview.png {w}x{h} ({os.path.getsize(out)//1024} KB)")
        break
PY
    fi
else
    echo "  ⚠ chưa có assets/icon_source.png — gói sẽ KHÔNG có icon/preview"
fi

echo "▸ Kiểm cú pháp Lua…"
n=0
while IFS= read -r f; do
    $CHECK "$f" >/dev/null || { echo "✗ lỗi cú pháp: $f"; exit 1; }
    n=$((n + 1))
done < <(find "$SRC/scripts" "$SRC/modmain.lua" "$SRC/modinfo.lua" -name '*.lua')
echo "  ✓ $n file .lua hợp lệ"

echo "▸ Soát modmain gọi global mà DST không cấp…"
# ⚠ Kiểm cú pháp KHÔNG bắt được lỗi này. modmain chạy trong môi trường mod chỉ
#   có pairs/ipairs/print/math/table/type/string/tostring/require/Class/TUNING/
#   GLOBAL (scripts/mods.lua:369). Mod dịch Functional Medal từng lên Workshop
#   với pcall gọi thẳng và làm rớt client ngay khi vào world.
if grep -nE '(^|[^.A-Za-z_])(pcall|xpcall|os\.|io\.|setmetatable|getmetatable|rawget|rawset|unpack|error|assert)\b' \
        "$SRC/modmain.lua" | grep -vE '^\s*[0-9]+:\s*--' | grep -v 'GLOBAL\.'; then
    echo "✗ modmain gọi thẳng global ở trên — lấy qua GLOBAL"; exit 1
fi
echo "  ✓ sạch"

echo "▸ Chép sang upload/…"
rm -rf "$OUT"; mkdir -p "$OUT"
rsync -a --exclude 'ailang/tu_kiem.lua' "$SRC/scripts" "$OUT/"
cp "$SRC/modmain.lua" "$SRC/modinfo.lua" "$OUT/"
for f in modicon.tex modicon.xml preview.png; do
    [[ -f "$SRC/assets/$f" ]] && cp "$SRC/assets/$f" "$OUT/"
done
# Chỉ khai icon trong BẢN UPLOAD, và chỉ khi file thật có mặt — modinfo trong
# kho cố ý không khai, xem chú thích ở đó.
if [[ -f "$OUT/modicon.tex" && -f "$OUT/modicon.xml" ]]; then
    printf '\nicon_atlas = "modicon.xml"\nicon = "modicon.tex"\n' >> "$OUT/modinfo.lua"
    $CHECK "$OUT/modinfo.lua" >/dev/null
    echo "  ✓ đã khai icon trong bản upload"
fi

P="$OUT/preview.png"
if [[ -f "$P" ]]; then
    kb=$(( $(stat -f%z "$P" 2>/dev/null || stat -c%s "$P") / 1024 ))
    [[ $kb -le 1024 ]] || { echo "✗ preview.png $kb KB > 1 MB, Steam từ chối"; exit 1; }
fi
[[ -f "$OUT/scripts/ailang/tu_kiem.lua" ]] && { echo "✗ tu_kiem.lua lọt vào gói"; exit 1; }

echo
echo "✓ Sẵn sàng: $OUT ($(du -sh "$OUT" | cut -f1), $(find "$OUT" -type f | wc -l | tr -d ' ') file)"
echo "  version: $(grep -m1 '^version' "$OUT/modinfo.lua")"
[[ -f "$P" ]] || echo "  ⚠ CHƯA có preview.png — Mod Uploader cần ảnh preview"

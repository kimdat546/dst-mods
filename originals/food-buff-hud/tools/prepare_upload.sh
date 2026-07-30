#!/usr/bin/env bash
# Dựng thư mục build sạch để upload lên Steam Workshop.
#   ./tools/prepare_upload.sh  →  _archive/food-buff-hud-upload/
#
# DANH SÁCH TRẮNG: chỉ file khai ở đây mới được đưa vào. Thêm file mới vào mod
# thì phải khai, quên thì bước kiểm cuối báo lỗi chứ không im lặng ship thiếu.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$(cd "$SRC/../.." && pwd)/_archive/food-buff-hud-upload"

FILES=(
    modinfo.lua
    modmain.lua
    preview.png                       # ảnh Workshop, 512x512
    scripts/widgets/foodbuffhud.lua   # HUD phía client
)
# KHÔNG ship: scripts/selftest.lua (chỉ dùng cho test headless)

rm -rf "$DEST"; mkdir -p "$DEST/scripts/widgets"
for f in "${FILES[@]}"; do
    [[ -f "$SRC/$f" ]] || { echo "✗ Thiếu file nguồn: $f"; exit 1; }
    cp "$SRC/$f" "$DEST/$f"
done

# Kiểm 1: cú pháp
while IFS= read -r -d '' f; do luac -p "$f" || { echo "✗ Lỗi cú pháp: $f"; exit 1; }; done \
    < <(find "$DEST" -name "*.lua" -print0)

# Kiểm 2: mọi require widget đều có file trong bản build
while read -r w; do
    [[ -f "$DEST/scripts/$w.lua" ]] || { echo "✗ modmain require(\"$w\") nhưng bản build không có"; exit 1; }
done < <(grep -oE 'require\("widgets/[^"]+"\)' "$DEST/modmain.lua" | sed 's/require("//;s/")//')

# Kiểm 3: không lẫn dấu vết dev.
# Chỉ cấm log DIAG và chỗ BẬT cờ selftest. Câu lệnh RÀO (if rawget(...SELFTEST))
# thì giữ lại được: bản phát hành không bao giờ đặt cờ nên nhánh đó không chạy,
# và giữ nó thì source với bản ship không lệch nhau.
if grep -qE "\[DIAG\]|SELFTEST *= *true" "$DEST"/modmain.lua "$DEST"/scripts/widgets/*.lua; then
    echo "✗ Bản build còn log DIAG hoặc cờ selftest bật sẵn"; exit 1
fi

echo "✓ Bản upload sẵn sàng → $DEST"
echo "  $(find "$DEST" -type f | wc -l | tr -d ' ') file, $(du -sh "$DEST" | cut -f1)"
grep -E '^(name|version|version_compatible|all_clients_require_mod|client_only_mod)' "$DEST/modinfo.lua" | sed 's/^/  /'
# preview phải vuông, Workshop hiển thị thumbnail vuông
if [[ -f "$DEST/preview.png" ]]; then
    w=$(sips -g pixelWidth "$DEST/preview.png" | awk '/pixelWidth/{print $2}')
    h=$(sips -g pixelHeight "$DEST/preview.png" | awk '/pixelHeight/{print $2}')
    [[ "$w" == "$h" ]] && echo "  preview.png ${w}x${h} ✓" || echo "  ⚠ preview.png ${w}x${h} — nên cắt vuông"
fi

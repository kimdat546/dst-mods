#!/usr/bin/env bash
# Dựng thư mục SẠCH để đẩy lên Steam Workshop.
#
#   ./tools/make_upload.sh
#
# ⚠ Vì sao không trỏ thẳng Mod Uploader vào build/: build.py ghi đè build/ mỗi
#   lần chạy. Lỡ build trong lúc đang upload thì thư mục đổi giữa chừng.
#   upload/ là bản đông cứng, chỉ đổi khi chạy script này.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MOD="functional-medal-vi"
OUT="$SRC/upload/$MOD"

echo "▸ Dựng ảnh (modicon + preview)…"
python3 "$SRC/tools/make_anh.py" | sed 's/^/  /'

echo "▸ Dựng mod (tự soát placeholder)…"
python3 "$SRC/tools/build.py" | sed 's/^/  /'

echo "▸ Kiểm cú pháp Lua…"
# DST chạy Lua 5.1. `luac` trên máy là 5.5 và CHẤP NHẬN cú pháp mà DST từ chối
# -> dùng luajit (cùng cú pháp 5.1) nếu có. `brew install luajit`.
if command -v luajit >/dev/null; then CHECK="luajit -bl"; else
    CHECK="luac -p"
    echo "  ⚠ không có luajit, dùng luac (5.5) — không bắt được khác biệt 5.1"
fi
n=0
while IFS= read -r f; do
    $CHECK "$f" >/dev/null || { echo "✗ lỗi cú pháp: $f"; exit 1; }
    n=$((n + 1))
done < <(find "$SRC/build/$MOD" -name '*.lua')
echo "  ✓ $n file .lua hợp lệ"

echo "▸ Kiểm đủ file bắt buộc…"
for f in modinfo.lua modmain.lua modicon.tex modicon.xml scripts/medal_vi_strings.lua; do
    [[ -f "$SRC/build/$MOD/$f" ]] || { echo "✗ thiếu $f"; exit 1; }
done
# ⚠ Steam từ chối ảnh preview lớn hơn 1 MB.
P="$SRC/build/$MOD/preview.png"
if [[ -f "$P" ]]; then
    kb=$(( $(stat -f%z "$P" 2>/dev/null || stat -c%s "$P") / 1024 ))
    [[ $kb -le 1024 ]] || { echo "✗ preview.png $kb KB > 1 MB, Steam sẽ từ chối"; exit 1; }
    echo "  ✓ preview.png $kb KB"
fi
echo "  ✓ đủ file"

echo "▸ Chép sang upload/…"
rm -rf "$OUT"; mkdir -p "$OUT"
rsync -a --exclude 'mod.manifest' "$SRC/build/$MOD/" "$OUT/"

echo
echo "✓ Sẵn sàng: $OUT"
echo
echo "Tiếp theo — Don't Starve Mod Tools → Mod Uploader:"
echo "  1. Chọn thư mục trên"
echo "  2. Mod nào MỚI thì để trống ô Workshop ID; cập nhật thì nhập ID cũ"
echo "  3. preview.png nằm sẵn trong thư mục, Uploader tự nhận"
echo "  4. Upload xong nhớ ghi Workshop ID vào README gốc của kho"

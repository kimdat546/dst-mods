#!/usr/bin/env bash
# Dựng thư mục SẠCH để đẩy lên Steam Workshop.
#
#   ./tools/make_upload.sh
#
# Vì sao không trỏ thẳng ModUploader vào build/: build.py xoá trắng build/ mỗi
# lần chạy (shutil.rmtree). Nếu lỡ build trong lúc đang upload thì thư mục biến
# mất giữa chừng. upload/ là bản đông cứng, chỉ đổi khi chạy script này.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MOD="than-binh-phu-an-vi"
OUT="$SRC/upload/$MOD"

echo "▸ Dựng lại bản Việt hoá…"
python3 "$SRC/tools/build.py" | sed 's/^/  /'

echo "▸ Kiểm chữ tràn khung…"
python3 "$SRC/tools/check_layout.py" | sed 's/^/  /'

echo "▸ Kiểm cú pháp Lua…"
# DST chạy Lua 5.1. `luac` trên máy là 5.5 và CHẤP NHẬN cú pháp mà DST từ chối
# -> dùng luajit (cùng cú pháp 5.1) nếu có. `brew install luajit`.
if command -v luajit >/dev/null; then
    CHECK="luajit -bl"
else
    CHECK="luac -p"
    echo "  ⚠ không có luajit, dùng luac (5.5) — không bắt được khác biệt 5.1"
fi
n=0
while IFS= read -r f; do
    $CHECK "$f" >/dev/null || { echo "✗ lỗi cú pháp: $f"; exit 1; }
    n=$((n + 1))
done < <(find "$SRC/build/$MOD" -name '*.lua')
echo "  ✓ $n file .lua hợp lệ"

echo "▸ Chép sang upload/…"
rm -rf "$OUT"; mkdir -p "$OUT"
rsync -a --delete \
      --exclude 'mod.manifest' \
      "$SRC/build/$MOD/" "$OUT/"
# mod.manifest của bản gốc trỏ về Workshop item KHÁC; ModUploader tự sinh cái mới.

echo "▸ Kiểm tra trước khi đẩy…"
for f in modinfo.lua modmain.lua modicon.tex modicon.xml; do
    [[ -f "$OUT/$f" ]] || { echo "✗ thiếu $f"; exit 1; }
done
grep -qE '^name = ' "$OUT/modinfo.lua"    || { echo "✗ modinfo thiếu name"; exit 1; }
grep -qE '^api_version = 10' "$OUT/modinfo.lua" || echo "  ⚠ api_version khác 10"
printf '  name    : %s\n' "$(grep -m1 '^name = ' "$OUT/modinfo.lua" | cut -d'"' -f2)"
printf '  author  : %s\n' "$(grep -m1 '^author = ' "$OUT/modinfo.lua" | cut -d'"' -f2)"
printf '  version : %s\n' "$(grep -m1 '^version = ' "$OUT/modinfo.lua" | cut -d'"' -f2)"
printf '  dung lượng: %s, %s file\n' "$(du -sh "$OUT" | cut -f1)" "$(find "$OUT" -type f | wc -l | tr -d ' ')"
[[ -f "$OUT/preview.png" ]] || echo "  ⚠ chưa có preview.png — chọn ảnh trong ModUploader"

echo
echo "✓ Sẵn sàng: $OUT"
echo
echo "Steam → Don't Starve Mod Tools → Publish New Mod → chọn thư mục trên."
echo "Lần sau cập nhật thì dùng Upload Existing Mod + nhập Workshop ID."

#!/usr/bin/env bash
# Dựng thư mục SẠCH để đẩy lên Steam Workshop.
#
#   ./tools/make_upload.sh
#
# Vì sao không trỏ thẳng ModUploader vào build/: build_client_mod.py xoá trắng
# build/montfluv-vi mỗi lần chạy (shutil.rmtree). Lỡ build trong lúc đang upload
# thì thư mục biến mất giữa chừng. upload/ là bản đông cứng, chỉ đổi khi chạy
# script này.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MOD="montfluv-vi"
OUT="$SRC/upload/$MOD"

echo "▸ Dựng lại mod client…"
python3 "$SRC/tools/build_client_mod.py" | sed 's/^/  /'

echo "▸ Kiểm cú pháp Lua (LuaJIT = Lua 5.1, đúng bản DST dùng)…"
# luac trên máy là 5.5, KHÔNG bắt được cú pháp 5.1 không hợp lệ → phải dùng luajit
n=0
while IFS= read -r f; do
    luajit -bl "$f" >/dev/null || { echo "✗ lỗi cú pháp: $f"; exit 1; }
    n=$((n + 1))
done < <(find "$SRC/build/$MOD" -name '*.lua')
echo "  ✓ $n file .lua hợp lệ"

echo "▸ Chép sang upload/…"
rm -rf "$OUT"; mkdir -p "$OUT"
rsync -a --delete "$SRC/build/$MOD/" "$OUT/"

echo "▸ Kiểm tra trước khi đẩy…"
for f in modinfo.lua modmain.lua modicon.tex modicon.xml preview.png; do
    [[ -f "$OUT/$f" ]] || { echo "✗ thiếu $f"; exit 1; }
done
grep -q 'icon_atlas = "modicon.xml"' "$OUT/modinfo.lua" || { echo "✗ modinfo chưa khai báo icon"; exit 1; }
grep -q 'client_only_mod = true' "$OUT/modinfo.lua"     || { echo "✗ phải là client_only_mod"; exit 1; }
grep -qE '^api_version = 10' "$OUT/modinfo.lua"         || echo "  ⚠ api_version khác 10"
# Steam chặn preview trên 1 MB
kb=$(( $(stat -f%z "$OUT/preview.png") / 1024 ))
(( kb <= 1000 )) || { echo "✗ preview.png $kb KB > 1 MB, Steam sẽ từ chối"; exit 1; }

printf '  name    : %s\n' "$(grep -m1 '^name = ' "$OUT/modinfo.lua" | cut -d'"' -f2)"
printf '  author  : %s\n' "$(grep -m1 '^author = ' "$OUT/modinfo.lua" | cut -d'"' -f2)"
printf '  version : %s\n' "$(grep -m1 '^version = ' "$OUT/modinfo.lua" | cut -d'"' -f2)"
printf '  preview : %s KB\n' "$kb"
printf '  dung lượng: %s, %s file\n' "$(du -sh "$OUT" | cut -f1)" "$(find "$OUT" -type f | wc -l | tr -d ' ')"

echo
echo "✓ Sẵn sàng: $OUT"
echo
echo "Steam → Don't Starve Mod Tools → Don't Starve Together Mod Uploader"
echo "  • lần đầu   : Publish New Mod → chọn thư mục trên"
echo "  • cập nhật  : Upload Existing Mod → nhập Workshop ID của mod này"
echo "Ảnh trang Workshop: $OUT/preview.png"
echo
echo "⚠ Đổi tên/mô tả trong modinfo.lua KHÔNG tự đổi tiêu đề trang Workshop."
echo "  Sửa tiêu đề ngay trên trang Workshop (Edit Title) nếu muốn khớp."

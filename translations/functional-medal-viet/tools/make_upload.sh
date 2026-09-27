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
# Bản server dùng CHUNG modmain với bản client, chỉ khác modinfo (build.py).
CAC_BAN=("$MOD" "$MOD-server")

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
done < <(for b in "${CAC_BAN[@]}"; do find "$SRC/build/$b" -name '*.lua'; done)
echo "  ✓ $n file .lua hợp lệ"

echo "▸ Chạy thử modmain trong môi trường giả lập DST…"
# ⚠ Kiểm cú pháp KHÔNG bắt được việc gọi global mà DST không cấp cho mod.
#   Đã mất một lần upload vì `pcall` — xem tools/thu_modmain.lua.
if command -v luajit >/dev/null; then
    (cd "$SRC" && luajit tools/thu_modmain.lua) | sed 's/^/  /' || exit 1
else
    echo "  ⚠ không có luajit — BỎ QUA phép thử quan trọng nhất"
fi

echo "▸ Kiểm đủ file bắt buộc…"
for b in "${CAC_BAN[@]}"; do
    for f in modinfo.lua modmain.lua modicon.tex modicon.xml scripts/medal_vi_strings.lua; do
        [[ -f "$SRC/build/$b/$f" ]] || { echo "✗ $b thiếu $f"; exit 1; }
    done
done
cmp -s "$SRC/build/$MOD/modmain.lua" "$SRC/build/$MOD-server/modmain.lua" \
    || { echo "✗ modmain bản server khác bản client"; exit 1; }
# ⚠ Steam từ chối ảnh preview lớn hơn 1 MB.
P="$SRC/build/$MOD/preview.png"
if [[ -f "$P" ]]; then
    kb=$(( $(stat -f%z "$P" 2>/dev/null || stat -c%s "$P") / 1024 ))
    [[ $kb -le 1024 ]] || { echo "✗ preview.png $kb KB > 1 MB, Steam sẽ từ chối"; exit 1; }
    echo "  ✓ preview.png $kb KB"
fi
echo "  ✓ đủ file"

echo "▸ Chép sang upload/…"
for b in "${CAC_BAN[@]}"; do
    OUT="$SRC/upload/$b"
    rm -rf "$OUT"; mkdir -p "$OUT"
    rsync -a --exclude 'mod.manifest' "$SRC/build/$b/" "$OUT/"
done

echo
echo "✓ Sẵn sàng:"
echo "    $SRC/upload/$MOD          (client — Workshop 3802626143)"
echo "    $SRC/upload/$MOD-server   (server — Workshop ID: xem README)"
echo
echo "Tiếp theo — Don't Starve Mod Tools → Mod Uploader:"
echo "  1. Chọn từng thư mục trên (upload MỖI BẢN là một Workshop item riêng)"
echo "  2. Mod nào MỚI thì để trống ô Workshop ID; cập nhật thì nhập ID cũ"
echo "  3. preview.png nằm sẵn trong thư mục, Uploader tự nhận"
echo "  4. Upload xong nhớ ghi Workshop ID vào README gốc của kho"

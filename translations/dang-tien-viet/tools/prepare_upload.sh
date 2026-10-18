#!/usr/bin/env bash
# Dựng thư mục build sạch để upload lên Steam Workshop.
#
#   ./tools/prepare_upload.sh
#   → _archive/dang-tien-viet-upload/
#
# Dùng DANH SÁCH TRẮNG chứ không loại trừ: chỉ file có tên ở đây mới được đưa
# vào. Thêm file mới vào mod thì phải khai báo ở đây, nếu quên thì bước kiểm
# cuối sẽ báo lỗi chứ không im lặng ship thiếu.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$(cd "$SRC/../.." && pwd)/_archive/dang-tien-viet-upload"

# ── File bắt buộc ────────────────────────────────────────────────────────────
FILES=(
    modinfo.lua
    modmain.lua
    preview.png

    scripts/main.lua                      # entry, hook + set_str
    scripts/wiki_glossary.lua             # tên riêng chuẩn từ PDF wiki
    scripts/textfix_dynamic.lua           # pattern + word_fix cho chuỗi động

    scripts/phase2_strings.lua            # tên item / recipe / action
    scripts/phase3_speech_wangmazi.lua    # thoại Vương Ma Tử
    scripts/phase8_speech_chenpingan.lua  # thoại Trần Bình An
    scripts/phase4_mod_private.lua        # STRINGS private của mod gốc
    scripts/phase5_book_strings_data.lua  # tên/mô tả vật phẩm (fork tiếng Anh)
    scripts/phase5_book_strings.lua
    scripts/phase6_v19_strings.lua        # chuỗi mới của mod gốc v19.0
    scripts/phase7_runtime_gaps.lua       # chuỗi chỉ lộ ra lúc chạy
    scripts/phase9_v20_strings.lua        # mod gốc v20.0: Phương Nguyên, cổ trùng, Tiên Khiếu
    scripts/phase10_speech_gyfy.lua       # thoại Cổ Nguyệt Phương Nguyên
    scripts/book_images.lua               # tráo ảnh trang sách bản tiếng Việt

    # Nạp theo option người dùng bật trong settings — THIẾU là mod crash
    scripts/diag_speech.lua               # option "Log string thiếu"
    scripts/strings_scanner.lua           # option "Scanner"
    scripts/global_scanner.lua            # option "Scanner"
    scripts/runtime_dump.lua              # option "Scanner"
)
# KHÔNG ship: selftest.lua (chỉ chạy ở bản test headless),
#             book_dump.lua (đã tắt trong main.lua)

rm -rf "$DEST"; mkdir -p "$DEST/scripts"
for f in "${FILES[@]}"; do
    [[ -f "$SRC/$f" ]] || { echo "✗ Thiếu file nguồn: $f"; exit 1; }
    cp "$SRC/$f" "$DEST/$f"
done

# Trang sách vẽ lại (tools/book/). Mỗi trang khai trong PAGES của
# book_images.lua phải có đủ .tex + .xml, thiếu là game báo lỗi asset.
mkdir -p "$DEST/images/vn_book"
while read -r page; do
    for ext in tex xml; do
        [[ -f "$SRC/images/vn_book/$page.$ext" ]] || { echo "✗ Thiếu images/vn_book/$page.$ext"; exit 1; }
        cp "$SRC/images/vn_book/$page.$ext" "$DEST/images/vn_book/"
    done
done < <(sed -n '/^local PAGES/,/^}/p' "$SRC/scripts/book_images.lua" | grep -oE '"xd_info_[a-z0-9_]+"' | tr -d '"')

# ── Kiểm 1: cú pháp ──────────────────────────────────────────────────────────
FAILED=0
while IFS= read -r -d '' f; do
    # luajit = Lua 5.1 như DST; luac trên máy là 5.5, nhận cả cú pháp DST từ chối
    luajit -bl "$f" >/dev/null || { echo "✗ Lỗi cú pháp: $f"; FAILED=1; }
done < <(find "$DEST" -name "*.lua" -print0)
[[ $FAILED -eq 1 ]] && exit 1

# ── Kiểm 2: mọi modimport đều có file trong bản build ────────────────────────
# Bỏ qua dòng chú thích, và bỏ qua file cố tình không ship (chỉ chạy khi có cờ
# mà bản phát hành không bao giờ bật).
NOT_SHIPPED="scripts/selftest.lua"
MISS=0
while read -r target; do
    [[ " $NOT_SHIPPED " == *" $target "* ]] && continue
    [[ -f "$DEST/$target" ]] || { echo "✗ main.lua gọi modimport(\"$target\") nhưng bản build KHÔNG có file này"; MISS=1; }
done < <(grep -hvE '^\s*--' "$DEST/scripts/main.lua" "$DEST/modmain.lua" | grep -oE 'modimport\("[^"]+"\)' | sed 's/modimport("//;s/")//')
[[ $MISS -eq 1 ]] && exit 1

# ── Kiểm 3: không lẫn dấu vết bản dev ────────────────────────────────────────
if grep -qE '\[LOCAL\]|DANGTIEN_SELFTEST *= *true|DANGTIEN_DEBUG_MISSING *= *true' "$DEST/modinfo.lua" "$DEST/modmain.lua"; then
    echo "✗ Bản build còn dấu vết dev (tên [LOCAL] hoặc cờ debug bật sẵn)"
    exit 1
fi

echo "✓ Bản upload sẵn sàng → $DEST"
echo "  $(find "$DEST" -type f | wc -l | tr -d ' ') file, $(du -sh "$DEST" | cut -f1)"
grep -E '^(name|version|author|priority|client_only_mod|all_clients_require_mod)' "$DEST/modinfo.lua" | sed 's/^/  /'
echo
echo "  Bước tiếp: Steam → Don't Starve Mod Tools → Upload Existing Mod"
echo "             chọn thư mục trên → nhập Workshop ID 3719981130"

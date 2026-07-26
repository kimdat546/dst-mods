#!/usr/bin/env bash
# Cài bản mod dịch hiện tại vào thư mục mod LOCAL của game để chơi thử.
#
#   ./tools/sync_local.sh          # cài/cập nhật
#   ./tools/sync_local.sh --clean  # gỡ ra
#
# Khác với tools/test-harness/build.sh (dựng bản cho dedicated server headless),
# script này ship ĐÚNG bản người chơi sẽ dùng: client_only, không có selftest.
#
# ⚠ Vì sao phải đi vòng qua Finder:
# Thư mục mod của DST nằm BÊN TRONG dontstarve_steam.app. macOS (App Management)
# chặn mọi tiến trình dòng lệnh ghi vào bundle của app khác — kể cả khi đã
# `sudo`, kể cả Terminal của chính bạn: "Operation not permitted".
# Finder có entitlement riêng nên vẫn copy được. Engine DST quy định cứng
# MODS_ROOT trỏ vào thư mục này, không có đường thay thế
# (~/Documents/Klei/.../mods KHÔNG được game quét).
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
MODNAME="dang-tien-viet"
STAGE="$(mktemp -d)/$MODNAME"

finder_rm() {
    osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true
}

if [[ ! -d "$MODS_DIR" ]]; then
    echo "✗ Không tìm thấy thư mục mod của DST: $MODS_DIR"
    exit 1
fi

if [[ "${1:-}" == "--clean" ]]; then
    finder_rm "$MODS_DIR/$MODNAME"
    echo "✓ Đã gỡ $MODS_DIR/$MODNAME"
    exit 0
fi

# Kiểm cú pháp trước khi cài — Lua chỉ báo lỗi cú pháp lúc chạy tới dòng đó,
# đừng để vào tận trong game mới phát hiện.
FAILED=0
while IFS= read -r -d '' f; do
    luac -p "$f" || { echo "✗ Lỗi cú pháp: $f"; FAILED=1; }
done < <(find "$SRC/scripts" "$SRC/modmain.lua" "$SRC/modinfo.lua" -name "*.lua" -print0)
[[ $FAILED -eq 1 ]] && { echo "✗ Dừng lại, sửa cú pháp trước đã."; exit 1; }

# Dựng bản sạch ở thư mục tạm, đặt sẵn đúng tên để Finder copy thẳng sang.
mkdir -p "$STAGE"
rsync -a \
    --exclude '.git' --exclude '.gitignore' --exclude '.claude' \
    --exclude 'tools' --exclude 'translation_pipeline' \
    --exclude '*.txt' --exclude '.DS_Store' \
    "$SRC"/ "$STAGE"/

finder_rm "$MODS_DIR/$MODNAME"
osascript >/dev/null <<EOF
tell application "Finder"
    duplicate (POSIX file "$STAGE" as alias) to (POSIX file "$MODS_DIR" as alias) with replacing
end tell
EOF
rm -rf "$(dirname "$STAGE")"

if [[ ! -d "$MODS_DIR/$MODNAME" ]]; then
    echo "✗ Finder không copy được. Mở System Settings → Privacy & Security →"
    echo "  App Management và bật cho Terminal, rồi chạy lại."
    exit 1
fi

echo "✓ Đã cài → $MODS_DIR/$MODNAME"
echo "  $(find "$MODS_DIR/$MODNAME" -name '*.lua' | wc -l | tr -d ' ') file lua, $(du -sh "$MODS_DIR/$MODNAME" | cut -f1)"
grep -E '^(version|client_only_mod|priority)' "$MODS_DIR/$MODNAME/modinfo.lua" | sed 's/^/  /'
echo "  → Khởi động lại DST, bật 【登仙】 ở Server Mods và mod này ở Client Mods."

#!/usr/bin/env bash
# Cài AI Làng vào thư mục mod LOCAL của game để tự host world mà chơi thử.
#
#   ./tools/sync_local.sh          # cài / cập nhật
#   ./tools/sync_local.sh --clean  # gỡ ra
#
# ⚠ KHÔNG dùng symlink được. Thư mục mod của DST nằm BÊN TRONG
#   dontstarve_steam.app, mà macOS (App Management) chặn mọi tiến trình dòng
#   lệnh ghi vào bundle app khác — kể cả `ln -s` và `touch`. Nhưng thao tác XOÁ
#   thì lại thành công, nên `rsync --delete` làm tay sẽ xoá sạch rồi không ghi
#   lại được. Finder có entitlement riêng nên vẫn copy được.
#
# ⚠ Kiểm cú pháp bằng `luajit -bl`, KHÔNG dùng `luac -p`: luac trên máy này là
#   Lua 5.5, nó nhận cú pháp mà DST (Lua 5.1) từ chối.
#
# ⚠ Đây là SERVER MOD → khi tạo world phải bật ở tab "Server Mods".
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
MODNAME="dst-ai-village"
STAGE="$(mktemp -d)/$MODNAME"

finder_rm() {
    osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true
}

[[ -d "$MODS_DIR" ]] || { echo "✗ Không tìm thấy thư mục mod của DST: $MODS_DIR"; exit 1; }

if [[ "${1:-}" == "--clean" ]]; then
    finder_rm "$MODS_DIR/$MODNAME"
    echo "✓ Đã gỡ $MODS_DIR/$MODNAME"
    exit 0
fi

if command -v luajit >/dev/null 2>&1; then
    FAILED=0
    while IFS= read -r -d '' f; do
        luajit -bl "$f" >/dev/null || { echo "✗ Lỗi cú pháp: $f"; FAILED=1; }
    done < <(find "$SRC" -name "*.lua" -not -path "*/tools/*" -print0)
    [[ $FAILED -eq 1 ]] && { echo "✗ Dừng lại, sửa cú pháp trước đã."; exit 1; }
else
    echo "… không có luajit trên máy, bỏ qua bước kiểm cú pháp"
fi

mkdir -p "$STAGE"
rsync -a --exclude 'tools' --exclude 'tam-tri' --exclude '.git' --exclude '.gitignore' \
      --exclude 'README.md' --exclude '.DS_Store' "$SRC"/ "$STAGE"/

finder_rm "$MODS_DIR/$MODNAME"
osascript >/dev/null <<EOF
tell application "Finder"
    duplicate (POSIX file "$STAGE" as alias) to (POSIX file "$MODS_DIR" as alias) with replacing
end tell
EOF
rm -rf "$(dirname "$STAGE")"

[[ -d "$MODS_DIR/$MODNAME" ]] || {
    echo "✗ Finder không copy được. System Settings → Privacy & Security →"
    echo "  App Management → bật cho Terminal, rồi chạy lại."
    exit 1
}

echo "✓ Đã cài → $MODS_DIR/$MODNAME"
echo "  $(find "$MODS_DIR/$MODNAME" -name '*.lua' | wc -l | tr -d ' ') file lua, $(du -sh "$MODS_DIR/$MODNAME" | cut -f1)"
echo
echo "  Khởi động lại DST (engine chỉ quét thư mục mod một lần lúc mở game)."
echo "  Rồi: Play → Host Game → Create New World → tab SERVER MODS → bật 'AI Làng'."

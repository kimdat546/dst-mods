#!/usr/bin/env bash
# Cài mod vào thư mục mod LOCAL của game để chơi thử.
#
#   ./tools/sync_local.sh          # cài/cập nhật
#   ./tools/sync_local.sh --clean  # gỡ ra
#
# ⚠ Đây là SERVER MOD (all_clients_require_mod = true) → khi tạo world phải bật ở
#   tab "Server Mods", KHÔNG phải "Client Mods". Khác với mod dịch Đăng Tiên.
#
# ⚠ Vì sao đi vòng qua Finder: thư mục mod của DST nằm BÊN TRONG
#   dontstarve_steam.app. macOS (App Management) chặn mọi tiến trình dòng lệnh
#   ghi vào bundle của app khác, kể cả Terminal của chính bạn. Finder có
#   entitlement riêng nên vẫn copy được.
#
# KHÔNG chèn cờ selftest — bản này để chơi thật. Bản test headless nằm ở
# tools/test-harness/build.sh.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
MODNAME="food-buff-hud"
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

# Kiểm cú pháp trước khi cài — Lua chỉ báo lỗi lúc chạy tới dòng đó
FAILED=0
while IFS= read -r -d '' f; do
    luac -p "$f" || { echo "✗ Lỗi cú pháp: $f"; FAILED=1; }
done < <(find "$SRC" -name "*.lua" -not -path "*/tools/*" -print0)
[[ $FAILED -eq 1 ]] && { echo "✗ Dừng lại, sửa cú pháp trước đã."; exit 1; }

mkdir -p "$STAGE"
rsync -a --exclude 'tools' --exclude '.git' --exclude '.gitignore' \
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
grep -E '^(version|all_clients_require_mod|client_only_mod)' "$MODS_DIR/$MODNAME/modinfo.lua" | sed 's/^/  /'
echo "  → Bật ở tab SERVER MODS khi tạo world (không phải Client Mods)."

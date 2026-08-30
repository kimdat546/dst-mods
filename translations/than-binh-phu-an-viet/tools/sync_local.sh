#!/usr/bin/env bash
# Cài bản Việt hoá "Thần Binh Phù Ấn" vào thư mục mod LOCAL của game.
#
#   ./tools/sync_local.sh          # dựng rồi cài
#   ./tools/sync_local.sh --clean  # gỡ ra
#
# ⚠ Vì sao đi vòng qua Finder:
# Thư mục mod của DST nằm BÊN TRONG dontstarve_steam.app. macOS (App Management)
# chặn mọi tiến trình dòng lệnh ghi vào bundle của app khác — kể cả sudo. Finder
# có entitlement riêng nên vẫn copy được. Engine DST quy định cứng MODS_ROOT trỏ
# vào đây, không có đường thay thế.
#
# ⚠ Nhớ TẮT mod workshop-3096210166 khi bật mod này: hai bản cùng bật sẽ trùng
# prefab và công thức.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
MOD="than-binh-phu-an-vi"

finder_rm() {
    osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true
}

[[ -d "$MODS_DIR" ]] || { echo "✗ Không thấy thư mục mod của DST: $MODS_DIR"; exit 1; }

if [[ "${1:-}" == "--clean" ]]; then
    finder_rm "$MODS_DIR/$MOD"
    echo "✓ đã gỡ $MOD"
    exit 0
fi

echo "▸ Dựng lại bản Việt hoá…"
python3 "$SRC/tools/build.py" | sed 's/^/  /'

echo "▸ Kiểm tra cú pháp Lua…"
n=0
while IFS= read -r f; do
    luac -p "$f" || { echo "✗ lỗi cú pháp: $f"; exit 1; }
    n=$((n + 1))
done < <(find "$SRC/build/$MOD" -name '*.lua')
echo "  ✓ $n file .lua hợp lệ"

echo "▸ Cài vào game (qua Finder)…"
finder_rm "$MODS_DIR/$MOD"
osascript -e "tell application \"Finder\" to duplicate (POSIX file \"$SRC/build/$MOD\" as alias) to (POSIX file \"$MODS_DIR\" as alias)" >/dev/null

[[ -d "$MODS_DIR/$MOD" ]] || { echo "✗ copy thất bại"; exit 1; }
echo "✓ đã cài $MOD"
echo
echo "Trong game: Mods → Server Mods, bật 'Thần Binh Phù Ấn',"
echo "và TẮT mod gốc 传奇武器-附魔强化 (workshop-3096210166) nếu đang bật."

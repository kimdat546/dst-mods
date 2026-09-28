#!/usr/bin/env bash
# Cài bản đang làm vào game để CHƠI THỬ, tên "… (bản LOCAL)" để khỏi lẫn bản Workshop.
#
#   ./tools/sync_local.sh            # dựng (make_upload) + cài
#   ./tools/sync_local.sh --clean    # gỡ khỏi game
#
# ⚠ PHẢI ĐI VÒNG QUA FINDER: macOS chặn GHI vào dontstarve_steam.app/Contents từ
#   dòng lệnh (kể cả sudo) nhưng KHÔNG chặn XOÁ — rsync --delete từng xoá sạch mod.
# ⚠ Trong game chỉ bật MỘT bản: tắt "DST Tiếng Việt" (Workshop) khi thử bản LOCAL.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
MOD="dst-tieng-viet-local"
MODS=~/"Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
[[ -d "$MODS" ]] || { echo "✗ không thấy thư mục mod của game"; exit 1; }

finder_rm() {
    osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true
}

if [[ "${1:-}" == "--clean" ]]; then
    finder_rm "$MODS/$MOD"; echo "✓ đã gỡ $MOD khỏi game"; exit 0
fi

VER=$(sed -n 's/^version = "\(.*\)"/\1/p' "$SRC/modinfo.lua")
"$SRC/tools/make_upload.sh" "$VER" | grep -E "✓|✗|game đọc" | sed 's/^/  /'

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp -R "$SRC/upload/dst-tieng-viet" "$T/$MOD"
sed -i '' 's/^name = "\(.*\)"/name = "\1 (bản LOCAL)"/' "$T/$MOD/modinfo.lua"

echo "▸ Cài vào game (qua Finder)…"
finder_rm "$MODS/$MOD"
osascript -e "tell application \"Finder\" to duplicate (POSIX file \"$T/$MOD\" as alias) to (POSIX file \"$MODS\" as alias) with replacing" >/dev/null
[[ -f "$MODS/$MOD/vietnamese.po" && -d "$MODS/$MOD/fonts" ]] || { echo "✗ cài không đủ file"; exit 1; }
echo "✓ đã cài $MOD ($(ls "$MODS/$MOD/fonts" | wc -l | tr -d ' ') font)"
echo
echo "Trong game: Mods → Client Mods → TẮT \"DST Tiếng Việt - Đừng Chết Đói :)\" (Workshop),"
echo "            BẬT \"DST Tiếng Việt - Đừng Chết Đói :) (bản LOCAL)\" → khởi động lại game."

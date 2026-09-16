#!/usr/bin/env bash
# Cài mod client vào game để CHƠI THỬ.
#
#   ./tools/sync_local.sh            # dựng + cài
#   ./tools/sync_local.sh --clean    # gỡ khỏi game
#
# ⚠ PHẢI ĐI VÒNG QUA FINDER. macOS App Management chặn GHI vào
#   dontstarve_steam.app/Contents/ từ dòng lệnh — kể cả sudo — nhưng KHÔNG chặn
#   XOÁ. Nên `rsync --delete` xoá sạch mod rồi không chép lại được gì: kho này
#   từng mất trắng một mod đã cài vì đúng lỗi đó. Finder có entitlement nên gọi
#   qua osascript thì ghi được.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MOD="functional-medal-vi"
GAME="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together"
MODS="$GAME/dontstarve_steam.app/Contents/mods"

finder_rm() {
    osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true
}

[[ -d "$MODS" ]] || { echo "✗ không thấy thư mục mod của game: $MODS"; exit 1; }

if [[ "${1:-}" == "--clean" ]]; then
    finder_rm "$MODS/$MOD"
    echo "✓ đã gỡ $MOD khỏi game"
    exit 0
fi

echo "▸ Dựng mod…"
python3 "$SRC/tools/build.py" | sed 's/^/  /'

echo "▸ Cài vào game (qua Finder)…"
finder_rm "$MODS/$MOD"
osascript -e "tell application \"Finder\" to duplicate (POSIX file \"$SRC/build/$MOD\" as alias) to (POSIX file \"$MODS\" as alias) with replacing" >/dev/null
echo "✓ đã cài $MOD"
echo
echo "Trong game: Mods → Client Mods → bật \"Functional Medal Tiếng Việt\""
echo "Mod gốc (workshop-1909182187) để language_switch = eng."

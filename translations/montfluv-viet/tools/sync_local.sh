#!/usr/bin/env bash
# Cài mod client vào game để CHƠI THỬ.
#
#   ./tools/sync_local.sh            # dựng + cài
#   ./tools/sync_local.sh --clean    # gỡ khỏi game
#
# ⚠ PHẢI ĐI VÒNG QUA FINDER
#
# macOS App Management chặn GHI vào dontstarve_steam.app/Contents/ từ dòng
# lệnh — kể cả sudo, kể cả tắt sandbox. Nhưng nó KHÔNG chặn XOÁ. Nên `rsync
# --delete` sẽ xoá sạch mod rồi không chép lại được gì: từng mất trắng mod đã
# cài vì lỗi này. Finder có entitlement, gọi qua osascript thì ghi được.
#
# ⚠ VÌ SAO KHÔNG CÒN GHI ĐÈ translation_es/
#
# Cách cũ: mod Workshop mang `mod.manifest` — danh mục file nhị phân, DST chỉ
# thấy file có trong đó. Thêm translation_vi/ thì "module not found"; xoá
# manifest thì hỏng cả asset. Nên bản thử từng phải ghi đè translation_es/.
# Cách đó bẩn (Steam cập nhật là mất, và sửa file của tác giả khác), đã bỏ.
# Mod client tự có manifest riêng nên không vướng gì.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MOD="montfluv-vi"
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

echo "▸ Dựng mod client…"
python3 "$SRC/tools/build_client_mod.py" | sed 's/^/  /'

echo "▸ Cài vào game (qua Finder)…"
finder_rm "$MODS/$MOD"
osascript -e "tell application \"Finder\" to duplicate (POSIX file \"$SRC/build/$MOD\" as alias) to (POSIX file \"$MODS\" as alias) with replacing" >/dev/null

[[ -f "$MODS/$MOD/modmain.lua" ]] || { echo "✗ cài hụt — kiểm quyền App Management"; exit 1; }
printf '  %s  v%s\n' \
    "$(grep -m1 '^name = ' "$MODS/$MOD/modinfo.lua" | cut -d'"' -f2)" \
    "$(grep -m1 '^version = ' "$MODS/$MOD/modinfo.lua" | cut -d'"' -f2)"

echo
echo "✓ Xong. Khởi động lại DST, bật mod trong Mods → Client Mods."
echo "  Mod gốc (workshop-3401927745) nên để language = \"en\"."

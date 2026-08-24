#!/usr/bin/env bash
# Cài bản dựng NewConstant Việt vào thư mục mod LOCAL của game để chơi thử.
#
#   ./tools/sync_local.sh          # dựng rồi cài
#   ./tools/sync_local.sh --clean  # gỡ ra
#
# ⚠ Vì sao đi vòng qua Finder:
# Thư mục mod của DST nằm BÊN TRONG dontstarve_steam.app. macOS (App Management)
# chặn mọi tiến trình dòng lệnh ghi vào bundle của app khác — kể cả sudo.
# Finder có entitlement riêng nên vẫn copy được. Engine DST quy định cứng
# MODS_ROOT trỏ vào đây, không có đường thay thế.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
MODS=(newconstant-core-vi newconstant-nightmare-vi newconstant-base-vi)

finder_rm() {
    osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true
}

[[ -d "$MODS_DIR" ]] || { echo "✗ Không thấy thư mục mod của DST: $MODS_DIR"; exit 1; }

if [[ "${1:-}" == "--clean" ]]; then
    for m in "${MODS[@]}"; do finder_rm "$MODS_DIR/$m"; echo "✓ đã gỡ $m"; done
    exit 0
fi

echo "▸ Dựng lại bản mod…"
python3 "$SRC/tools/build.py" | sed 's/^/  /'

for m in "${MODS[@]}"; do
    [[ -d "$SRC/build/$m" ]] || { echo "✗ thiếu build/$m"; exit 1; }
    finder_rm "$MODS_DIR/$m"
    osascript >/dev/null <<EOF
tell application "Finder"
    duplicate (POSIX file "$SRC/build/$m" as alias) to (POSIX file "$MODS_DIR" as alias) with replacing
end tell
EOF
    if [[ ! -d "$MODS_DIR/$m" ]]; then
        echo "✗ Finder không copy được $m."
        echo "  Mở System Settings → Privacy & Security → App Management, bật cho Terminal rồi chạy lại."
        exit 1
    fi
    echo "✓ đã cài $m  ($(du -sh "$MODS_DIR/$m" | cut -f1))"
done

cat <<'NOTE'

⚠ TRƯỚC KHI VÀO CHƠI — phải TẮT hai mod gốc, nếu không sẽ xung đột:
     永恒新界-核心 / NewConstant Core        (workshop 3645179905)
     永恒新界-基础 / NewConstant Base        (workshop 3191348907)
     永恒新界-暗影王朝 / NewConstant Nightmare (workshop 3645181516)
   Hai bản đăng ký Workshop vẫn nằm trong máy và khai báo CÙNG prefab với bản
   này. Bật cả hai là trùng prefab, hỏng world.

   Bật thay vào đó CẢ BA:
     "NewConstant Core - Việt hoá"
     "NewConstant Nightmare - Việt hoá"
     "NewConstant Base - Việt hoá"
   Ngôn ngữ mặc định đã là Tiếng Việt; đổi được trong phần cấu hình của mod Core.
NOTE

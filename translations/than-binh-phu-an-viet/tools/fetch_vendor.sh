#!/usr/bin/env bash
# Cập nhật vendor/ từ bản Steam Workshop đã cài trên máy.
#
# Dùng khi tác giả ra bản mới: chạy script này rồi `git diff` để thấy đúng
# những gì tác giả đã đổi, trước khi dịch tiếp và dựng lại.
#
#   ./tools/fetch_vendor.sh
set -euo pipefail
SRC="$HOME/Library/Application Support/Steam/steamapps/workshop/content/322330/3096210166"
DST="$(cd "$(dirname "$0")/.." && pwd)/vendor"

[[ -d "$SRC" ]] || {
    echo "✗ Chưa có mod gốc trên máy: $SRC"
    echo "  Đăng ký mod 3096210166 trên Workshop rồi mở DST một lần cho Steam tải về."
    exit 1
}
rsync -a --delete "$SRC/" "$DST/"
echo "✓ vendor/ ← Workshop 3096210166 ($(find "$DST" -type f | wc -l | tr -d ' ') file)"
echo "  Đối chiếu phiên bản với vendor.json rồi chạy: python3 tools/extract_strings.py"

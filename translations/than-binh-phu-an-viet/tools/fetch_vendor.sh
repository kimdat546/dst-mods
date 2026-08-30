#!/usr/bin/env bash
# Lấy lại vendor/ (mã nguồn mod gốc) từ bản Steam Workshop đã cài trên máy.
#
# vendor/ KHÔNG nằm trong git: đó là tác phẩm của tác giả khác, còn repo này
# public. Mỗi máy tự lấy từ bản Workshop của mình.
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

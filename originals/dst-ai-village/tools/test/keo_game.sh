#!/usr/bin/env bash
# Kéo thư mục game bản MỚI từ server thật trên ThinkPad về máy này.
#
# ⚠ Cần vì ảnh Docker tải file game lúc chạy bằng steamcmd, mà steamcmd là ELF
#   32-bit — Rosetta trên Apple Silicon không chạy 32-bit, nó segfault. Nên bản
#   game trong ảnh đứng yên ở 726875 còn client đã 747465, người chơi nhận
#   "máy chủ ở phiên bản cũ hơn bạn". ThinkPad là x86_64 thật nên tự cập nhật
#   được, chép về từ đó là xong.
#
# Khoảng 4,3 GB, đo được ~5 MB/s qua Tailscale nên mất chừng 15 phút.
set -euo pipefail
DICH="$(cd "$(dirname "$0")" && pwd)/game"
NGUON_CT="${1:-dst-master-than-binh-phu-an}"
mkdir -p "$DICH"
echo "… kéo từ $NGUON_CT trên thinkpad về $DICH"
ssh thinkpad "docker exec $NGUON_CT tar cf - -C /usr/share/game --exclude=./mods --exclude=./steamapps ." \
  | tar xf - -C "$DICH"
mkdir -p "$DICH/mods"
echo "✓ xong — bản $(cat "$DICH/version.txt" 2>/dev/null), $(du -sh "$DICH" | cut -f1)"

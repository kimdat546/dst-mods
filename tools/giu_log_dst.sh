#!/usr/bin/env bash
# Giữ lại client_log.txt của phiên DST bị crash.
#
#   ./tools/giu_log_dst.sh          # chạy nền, Ctrl-C để dừng
#   ./tools/giu_log_dst.sh --list   # xem các phiên đã lưu
#
# Vì sao cần: DST XOÁ TRẮNG client_log.txt mỗi lần mở game, nên log của đúng
# phiên vừa chết biến mất ngay khi bạn mở lại game để thử tiếp. Script này chụp
# lại file trước thời điểm đó.
#
# Cách nhận biết phiên mới: file bị ghi đè từ đầu nên NGẮN LẠI. Khi thấy số dòng
# tụt xuống, bản chụp gần nhất chính là log đầy đủ của phiên vừa kết thúc.
set -uo pipefail

LOG="$HOME/Documents/Klei/DoNotStarveTogether/client_log.txt"
OUT="$HOME/Documents/Klei/DoNotStarveTogether/log-luu"
mkdir -p "$OUT"

if [[ "${1:-}" == "--list" ]]; then
    ls -lt "$OUT" | awk 'NR>1 {printf "  %s %s %s  %8s  %s\n", $6,$7,$8,$5,$9}'
    exit 0
fi

echo "▸ Đang canh $LOG"
echo "  Lưu vào $OUT"
echo "  Ctrl-C để dừng."

truoc=0
while true; do
    if [[ -f "$LOG" ]]; then
        nay=$(wc -l < "$LOG" | tr -d ' ')
        # file ngắn lại = game vừa khởi động lại = phiên trước đã kết thúc
        if (( nay < truoc )); then
            ts=$(date +%Y%m%d-%H%M%S)
            cp "$OUT/.dang-chay" "$OUT/phien-$ts.txt" 2>/dev/null \
                && echo "  ✓ đã giữ phiên vừa kết thúc → phien-$ts.txt ($truoc dòng)"
        fi
        cp "$LOG" "$OUT/.dang-chay" 2>/dev/null
        truoc=$nay
    fi
    sleep 2
done

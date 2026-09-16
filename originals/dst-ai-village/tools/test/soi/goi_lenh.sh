#!/usr/bin/env bash
# Gửi một tệp Lua vào server test đang chạy rồi chờ kết quả.
#
#   ./tools/test/soi/goi_lenh.sh dung_canh.lua X5
#   ./tools/test/soi/goi_lenh.sh soi_ket.lua   SOI
#
# Tham số 2 là NHÃN mà kịch bản in ra khi xong (kịch bản phải in "[<NHÃN>] HET").
#
# ⚠ ĐỪNG BỎ CHÚ THÍCH `--` VÀO KỊCH BẢN. Lệnh được ép về MỘT DÒNG trước khi
#   nhét qua console, nên dấu `--` nuốt sạch mọi thứ phía sau nó. Đã mất một
#   lượt vì đúng chuyện này.
#
# ⚠ VÀ ĐỪNG CHỜ BẰNG `grep` THÔNG THƯỜNG. `docker logs` GIỮ LOG CŨ qua các lần
#   restart, nên vòng chờ khớp ngay vào dòng của lượt TRƯỚC và in kết quả cũ ra
#   như kết quả mới. Đã dẫm hai lần. Cách đúng là ĐẾM số lần xuất hiện trước
#   khi gửi rồi chờ số đó tăng — chính là thứ script này làm.
set -euo pipefail

CT=dst-ailang-test
TEP="${1:?dùng: goi_lenh.sh <tệp.lua> <NHÃN>}"
NHAN="${2:?thiếu nhãn, ví dụ X5}"
cd "$(dirname "$0")"
[[ -f "$TEP" ]] || { echo "không thấy $TEP"; exit 1; }

docker ps --format '{{.Names}}' | grep -qx "$CT" || {
    echo "server test chưa chạy. Bật bằng:"
    echo "  (cd ../ && docker compose up -d)"
    exit 1
}

CU=$(docker logs "$CT" 2>&1 | grep -ac "$NHAN. HET" || true)
LUA="$(tr '\n' ' ' < "$TEP")"
docker exec --privileged -u root -e DST_LUA="$LUA" "$CT" sh -c '
for p in /proc/[0-9]*; do c=$(cat "$p/comm" 2>/dev/null); case "$c" in *dontstarve*) gp=${p#/proc/}; break;; esac; done
[ -n "$gp" ] && printf "%s\n" "$DST_LUA" > /proc/$gp/fd/0'

echo "… đã gửi $TEP, chờ kết quả"
for _ in $(seq 1 120); do
    N=$(docker logs "$CT" 2>&1 | grep -av RemoteCommandInput | grep -ac "$NHAN. HET" || true)
    [[ "$N" -gt "$CU" ]] && break
    sleep 10
done

docker logs --tail 6000 "$CT" 2>&1 | grep -av RemoteCommandInput \
    | grep -a "\[$NHAN\]" | sed 's/^\[[0-9:]*\]: //' | tail -30

echo
echo "⚠ Xong thì nhớ dừng server:  docker stop $CT"

#!/usr/bin/env bash
# Chạy bộ tự kiểm cây hành vi trên server test. Không cần người chơi.
#
#   ./tools/test/chay_tu_kiem.sh          # dựng lại server sạch rồi kiểm
#   ./tools/test/chay_tu_kiem.sh --nhanh  # dùng lại server đang chạy
#
# ⚠ MẶC ĐỊNH PHẢI DỰNG LẠI CONTAINER. Bản đầu dùng lại container đang chạy cho
#   nhanh, và đúng một lần đó đã để lọt lỗi chí mạng: mã mới vi phạm strict
#   globals làm mod KHÔNG NẠP ĐƯỢC và cả world không khởi động, nhưng container
#   cũ vẫn giữ mod đã nạp từ trước nên 8/8 phép kiểm vẫn ĐẠT. Người chơi mới là
#   người phát hiện. Nạp được mod là điều kiện tiên quyết — phải kiểm trước.
set -euo pipefail

MOD="$(cd "$(dirname "$0")/../.." && pwd)"
CT=dst-ailang-test
NHANH=0
[[ "${1:-}" == "--nhanh" ]] && NHANH=1

cd "$MOD/tools/test"
[[ -f test.env ]] || cp test.env.example test.env

if [[ $NHANH -eq 0 ]] || ! docker ps --format '{{.Names}}' | grep -qx "$CT"; then
    echo "… dựng lại server test sạch"
    docker rm -f "$CT" >/dev/null 2>&1 || true
    docker compose up -d >/dev/null 2>&1
    for _ in $(seq 1 90); do
        docker logs "$CT" 2>&1 | grep -qaE '\[ailang\] làng có|MOD ERROR' && break
        sleep 8
    done
fi

# ── điều kiện tiên quyết: mod có nạp được không ──────────────────────────
in_loi() {
    echo
    echo "✗ $1 — dừng lại, KHÔNG chạy phép kiểm nào."
    echo "─────────────────────────────────────────────────────────────"
    docker logs "$CT" 2>&1 \
        | grep -aE "MOD ERROR|LUA ERROR|assign to undeclared|attempt to|\.lua\([0-9]+,[0-9]+\)|\[ailang\]\[LỖI\]" \
        | head -15 | sed 's/^/  /'
    echo "─────────────────────────────────────────────────────────────"
    echo "  Xem đầy đủ:  docker logs $CT 2>&1 | grep -aB2 -A12 'MOD ERROR'"
    exit 1
}

# Chụp log MỘT LẦN rồi mới xét. Đọc hai lần thì dính đua: lần đầu chưa thấy
# MOD ERROR vì log chưa xả xong, lần sau thấy — và dán sai nhãn chẩn đoán.
NHAT_KY="$(docker logs "$CT" 2>&1 || true)"
if grep -qa 'MOD ERROR' <<<"$NHAT_KY"; then
    in_loi "MOD KHÔNG NẠP ĐƯỢC"
elif ! grep -qa '\[ailang\] làng có' <<<"$NHAT_KY"; then
    in_loi "Mod nạp nhưng KHÔNG sinh được dân làng nào"
fi
echo "✓ mod nạp sạch, dân làng đã sinh"

# ⚠ ĐỪNG gộp cả bộ kiểm thành một dòng rồi nhét qua console — console DST có
#   giới hạn độ dài, chạm 10.402 ký tự là im lặng không chạy gì, hoặc cụt giữa
#   chừng rồi báo trơ trọi "attempt to call a nil value" không kèm dòng nào.
#   Nên bộ kiểm nằm thẳng trong scripts/ailang/ và chỉ cần require — lệnh gửi
#   đi luôn ngắn bất kể bộ kiểm dài bao nhiêu.
#
# ⚠ Cũng ĐỪNG mount riêng tu_kiem.lua vào trong scripts/: scripts đã mount
#   read-only nên Docker không tạo nổi điểm mount lồng bên trong, container
#   chết ngay lúc khởi tạo với "create mountpoint ...: read-only file system".
LUA='package.loaded["ailang/tu_kiem"] = nil local ok, err = pcall(require, "ailang/tu_kiem") if not ok then print("[TU-KIEM] LOI NAP: " .. tostring(err)) end'

MOC=$(date -u +%Y-%m-%dT%H:%M:%S)
docker exec --privileged -u root -e DST_LUA="$LUA" "$CT" sh -c '
for p in /proc/[0-9]*; do c=$(cat "$p/comm" 2>/dev/null); case "$c" in *dontstarve*) gp=${p#/proc/}; break;; esac; done
[ -n "$gp" ] && printf "%s\n" "$DST_LUA" > /proc/$gp/fd/0'

echo "… chờ chạy xong"
for _ in $(seq 1 40); do
    docker logs --since "$MOC" "$CT" 2>&1 | grep -qa 'TU-KIEM.*XONG' && break
    sleep 3
done

echo
docker logs --since "$MOC" "$CT" 2>&1 | grep -a 'TU-KIEM' | grep -v RemoteCommandInput \
    | sed 's/^\[[0-9:]*\]: //'
docker logs --since "$MOC" "$CT" 2>&1 | grep -aE 'LUA ERROR|\[ailang\]\[LỖI\]' | head -5 || true

# Mã thoát theo kết quả, để dùng được trong chuỗi lệnh.
docker logs --since "$MOC" "$CT" 2>&1 | grep -qa 'XONG: [0-9]* đạt, 0 hỏng'

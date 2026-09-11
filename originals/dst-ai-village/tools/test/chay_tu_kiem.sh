#!/usr/bin/env bash
# Chạy bộ tự kiểm cây hành vi trên server test. Không cần người chơi.
#
#   ./tools/test/chay_tu_kiem.sh
#
# Nó tự dựng server nếu chưa chạy, gửi tools/tu_kiem.lua vào, rồi in kết quả.
set -euo pipefail

MOD="$(cd "$(dirname "$0")/../.." && pwd)"
CT=dst-ailang-test

cd "$MOD/tools/test"
[[ -f test.env ]] || cp test.env.example test.env

if ! docker ps --format '{{.Names}}' | grep -qx "$CT"; then
    echo "… dựng server test"
    docker compose up -d >/dev/null 2>&1
    for _ in $(seq 1 60); do
        docker logs "$CT" 2>&1 | grep -qa '\[ailang\] làng có' && break
        sleep 8
    done
fi

# Bỏ dòng comment rồi gộp một dòng: console DST đọc bằng printf '%s\n' nên Lua
# phải nằm trên MỘT dòng, mà gộp thẳng thì `--` nuốt sạch phần còn lại.
LUA=$(python3 - "$MOD/tools/tu_kiem.lua" <<'PY'
import sys, pathlib
ra = [l.strip() for l in pathlib.Path(sys.argv[1]).read_text(encoding='utf-8').splitlines()
      if l.strip() and not l.strip().startswith('--')]
print('do ' + ' '.join(ra) + ' end', end='')
PY
)

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
docker logs --since "$MOC" "$CT" 2>&1 | grep -a 'TU-KIEM' | sed 's/^\[[0-9:]*\]: //'
docker logs --since "$MOC" "$CT" 2>&1 | grep -aE 'LUA ERROR|\[ailang\]\[LỖI\]' | head -5 || true

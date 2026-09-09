#!/usr/bin/env bash
# Dựng server headless CHỈ bật Montfluv, ép dùng bản dịch, rồi soi log.
# Dùng để tự kiểm trước khi đưa cho người chơi — không cần mở game.
#
#   ./tools/test_server.sh
#
# Cách hoạt động: chạy thẳng dontstarve_dedicated_server_nullrenderer với một
# cụm thế giới riêng (Cluster_9, offline). Server standalone KHÔNG thấy mod
# Workshop, nên phải chép mod vào <game>/mods/ trước — mà thư mục đó nằm trong
# app bundle bị macOS chặn ghi, phải đi vòng qua Finder (osascript).
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
APP="$HOME/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents"
WORKSHOP="$HOME/Library/Application Support/Steam/steamapps/workshop/content/322330/3401927745"
MODS="$APP/mods"
CLUSTER="$HOME/Documents/Klei/DoNotStarveTogether/1245874757/Cluster_9"
LOG="${TMPDIR:-/tmp}/montfluv_test.log"

finder_rm() { osascript -e "tell application \"Finder\" to if exists (POSIX file \"$1\" as text as alias) then delete (POSIX file \"$1\" as alias)" >/dev/null 2>&1 || true; }

echo "▸ Cài bản dịch…"
"$SRC/tools/sync_local.sh" | sed 's/^/  /'

echo "▸ Chép mod vào <game>/mods/ (qua Finder)…"
finder_rm "$MODS/workshop-3401927745"
osascript -e "tell application \"Finder\" to duplicate (POSIX file \"$WORKSHOP\" as alias) to (POSIX file \"$MODS\" as alias) with replacing" >/dev/null 2>&1
osascript -e "tell application \"Finder\" to set name of (POSIX file \"$MODS/3401927745\" as alias) to \"workshop-3401927745\"" >/dev/null 2>&1
[[ -d "$MODS/workshop-3401927745" ]] || { echo "✗ chép thất bại"; exit 1; }

echo "▸ Dựng cụm thế giới test…"
mkdir -p "$CLUSTER/Master"
[[ -f "$CLUSTER/cluster.ini" ]] || cat > "$CLUSTER/cluster.ini" <<INI
[GAMEPLAY]
game_mode = survival
max_players = 2
pause_when_empty = true

[NETWORK]
offline_cluster = true
cluster_name = Montfluv VI test

[SHARD]
shard_enabled = false
INI
# language = es  ->  bản dịch tiếng Việt (xem chú thích trong sync_local.sh)
printf 'return {\n  ["workshop-3401927745"] = {\n    configuration_options = { language = "es" },\n    enabled = true,\n  },\n}\n' > "$CLUSTER/Master/modoverrides.lua"

echo "▸ Chạy server…"
( cd "$APP/MacOS" && ./dontstarve_dedicated_server_nullrenderer \
    -persistent_storage_root "$HOME/Documents/Klei" -conf_dir DoNotStarveTogether \
    -cluster 1245874757/Cluster_9 -shard Master > "$LOG" 2>&1 & )

until grep -qa "Sim paused\|Shutting down\|MOD ERROR" "$LOG" 2>/dev/null; do sleep 5; done
pkill -f "Cluster_9" 2>/dev/null || true

echo
echo "▸ Kết quả  ($(wc -l < "$LOG") dòng log)"
n=$(grep -ac "MOD ERROR\|LUA ERROR" "$LOG" || true)
grep -a "Loading mod: workshop-3401927745" "$LOG" | head -1 | sed 's/^/  /'
grep -a "option language" "$LOG" | head -1 | sed 's/^/  /'
if [[ "$n" == "0" ]]; then echo "  ✓ 0 lỗi mod"; else echo "  ✗ $n lỗi:"; grep -a -A3 "MOD ERROR\|LUA ERROR" "$LOG" | head -12; fi
grep -qa "Sim paused" "$LOG" && echo "  ✓ thế giới lên xong (Sim paused)"

echo "▸ Dọn bản sao trong app bundle…"
finder_rm "$MODS/workshop-3401927745"
echo "log đầy đủ: $LOG"

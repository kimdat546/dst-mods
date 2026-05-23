#!/usr/bin/env bash
# Headless smoke test — start DST dedicated server with pntt_mod enabled,
# wait for stabilization, scan logs for Lua errors.

set -euo pipefail

DST_SERVER_DIR="/Users/kimdat546/Desktop/dst-server-docker"
COMPOSE_BASE="$DST_SERVER_DIR/cli/compose.yml"
COMPOSE_OVERRIDE="$DST_SERVER_DIR/cli/compose.override.yml"
ENV_FILE="$DST_SERVER_DIR/.world.env"

if [[ ! -f "$COMPOSE_OVERRIDE" ]]; then
    echo "✗ compose.override.yml missing — did you run Phase F?"
    exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
    echo "✗ .world.env missing at $ENV_FILE — generate it via 'python3 cli/extract-env.py server/docker-compose.yml > .world.env'"
    exit 1
fi

cd "$DST_SERVER_DIR"

# Make sure we're on pntt-dev branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "pntt-dev" ]]; then
    echo "✗ dst-server-docker is on branch '$CURRENT_BRANCH', expected 'pntt-dev'"
    echo "  Run: cd $DST_SERVER_DIR && git checkout pntt-dev"
    exit 1
fi

COMPOSE="docker compose --env-file $ENV_FILE -f $COMPOSE_BASE -f $COMPOSE_OVERRIDE"

echo "→ Starting DST server (pntt-dev branch, mod mounted)..."
$COMPOSE up -d master

echo "→ Waiting 90s for server to initialize and load mod..."
sleep 90

echo "→ Scanning logs for errors..."
LOG=$($COMPOSE logs master --tail 500 2>&1)

if echo "$LOG" | grep -qE "(Lua error|LUA ERROR|Mod failed|Failed to load mod|^\[ERROR\])"; then
    echo "✗ Smoke test FAILED — errors found in log:"
    echo "$LOG" | grep -E "(error|fail|Error|Fail)" -A 3 | head -40
    $COMPOSE down
    exit 1
fi

if echo "$LOG" | grep -q "\[PN\] Phàm Nhân Tu Tiên mod loaded"; then
    echo "✓ Mod init message found"
else
    echo "✗ Smoke test FAILED — mod init message not in logs"
    echo "    (Expected: '[PN] Phàm Nhân Tu Tiên mod loaded')"
    $COMPOSE down
    exit 1
fi

echo "✓ Smoke test PASSED"
docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_OVERRIDE" down

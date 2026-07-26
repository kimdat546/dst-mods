#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

FAILED=0
COUNT=0
while IFS= read -r -d '' file; do
    COUNT=$((COUNT + 1))
    if ! luac -p "$file" 2>&1; then
        echo "✗ Syntax error in: $file"
        FAILED=$((FAILED + 1))
    fi
done < <(find . -name "*.lua" -not -path "./reference/*" -not -path "./.git/*" -print0)

if [[ $FAILED -gt 0 ]]; then
    echo ""
    echo "✗ $FAILED file(s) failed syntax check"
    exit 1
fi

echo "✓ All $COUNT Lua files pass syntax check"

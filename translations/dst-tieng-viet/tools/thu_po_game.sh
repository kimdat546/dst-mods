#!/usr/bin/env bash
# Nạp vietnamese.po bằng CHÍNH bộ đọc .po của game (scripts/translator.lua lấy từ bản game
# trên máy — không commit code Klei) → chắc game đọc đủ, dấu nháy/xuống dòng ra đúng.
#   ./tools/thu_po_game.sh [file.po]
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
PO="${1:-$SRC/vietnamese.po}"
Z=~/"Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
unzip -p "$Z" scripts/translator.lua > "$T/translator.lua"
cat > "$T/thu.lua" <<'LUA'
function Class(base, ctor) local c={} c.__index=c setmetatable(c,{__call=function(t,...) local o=setmetatable({},c) if ctor then ctor(o,...) elseif type(base)=="function" then base(o,...) end return o end}) return c end
function resolvefilepath(p) return p end
package.loaded["class"]=true package.loaded["util"]=true
dofile(arg[1]) local T=Translator() T:LoadPOFile(arg[2],"vi")
local s=T.languages.vi local n,bad=0,0
for _,v in pairs(s) do n=n+1 if v:find('\\"',1,true) then bad=bad+1 end end
print(("game đọc được %d mục, %d mục còn \\\" chưa giải"):format(n,bad))
if n < 80000 or bad > 0 then os.exit(1) end
LUA
luajit "$T/thu.lua" "$T/translator.lua" "$PO" | grep -v "^Translator:"

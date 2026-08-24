# Plan 1 — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up project skeleton + dev environment + minimal "phàm nhân" player class that loads in DST without errors. Vanilla characters are hidden from select screen. Docker headless smoke test passes.

**Architecture:** Mod root at `/Users/kimdat546/Desktop/pham-nhan-tu-tien-mod/`. Standard DST mod structure (`modinfo.lua` + `modmain.lua` + `scripts/`). Local DST client tests via symlink into `Don't Starve Together.app/Contents/mods/`. Headless tests via Docker dedicated server (`~/Desktop/dst-server-docker/` on branch `pntt-dev` with our mod folder bind-mounted).

**Tech Stack:** Lua 5.1 (DST runtime), `luac` (syntax check), Python 3 (asset check), Docker + Compose + OrbStack, git, bash.

**Prerequisites verified:**
- macOS Darwin 25.x with Homebrew installed (`brew --version` works)
- DST installed at `~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/`
- DST Mod Tools installed (has ModUploader)
- Docker + docker-compose at `/usr/local/bin/`, OrbStack app installed
- `~/Desktop/dst-server-docker/` exists with `cli/compose.yml` + Klei cluster token configured
- DST script bundle at `~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip`

**Out of scope** (defer to Plan 2+): linh căn / tu vi / cảnh giới / lifespan / linh mạch / pháp bảo / HUD widgets. Plan 1 produces a character that exists and runs — nothing more.

---

## File summary

**Created in mod repo:**
- `.gitignore`
- `modinfo.lua` (~50 lines)
- `modmain.lua` (~30 lines)
- `modicon.tex`, `modicon.xml` (placeholder, copied from a vanilla mod template)
- `scripts/prefabs/phamnhan.lua` (~40 lines)
- `scripts/pn/charselect_override.lua` (~30 lines)
- `tools/check_syntax.sh`
- `tools/check_assets.py`
- `tools/smoke_test.sh`
- `tools/extract_dst_scripts.sh`
- `reference/dst-scripts/` (gitignored — extracted vanilla DST scripts for grep/reference)

**Created in `~/Desktop/dst-server-docker/` on new branch `pntt-dev`:**
- `cli/compose.override.yml`
- `server/config/Master/modoverrides.lua` (overwrite default)

**Modified:** none (existing reference docs `dengxian_*.md`, `Đăng-Tiên.pdf` stay untouched).

---

## Task 1: Install `luac` via Homebrew

**Files:** none

- [ ] **Step 1: Install lua**

```bash
brew install lua
```

- [ ] **Step 2: Verify**

```bash
luac -v
```

Expected output: `Lua 5.4.x  Copyright ...` (any 5.x version works for our syntax-only check; DST runtime is 5.1 but `luac` 5.4 catches the same syntax errors except a few edge cases that aren't relevant here).

---

## Task 2: Extract DST vanilla scripts for reference

**Files:**
- Create: `tools/extract_dst_scripts.sh`
- Create: `reference/dst-scripts/` (output dir, gitignored)

DST scripts are bundled in `scripts.zip` inside the app. We unpack into `reference/` so we can grep vanilla code without opening the zip every time.

- [ ] **Step 1: Write the extraction script**

Create `tools/extract_dst_scripts.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

DST_BUNDLE="/Users/kimdat546/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip"
OUT_DIR="$(dirname "$0")/../reference/dst-scripts"

if [[ ! -f "$DST_BUNDLE" ]]; then
    echo "✗ DST scripts.zip not found at expected path:"
    echo "  $DST_BUNDLE"
    echo "  Adjust path in this script if DST is installed elsewhere."
    exit 1
fi

mkdir -p "$OUT_DIR"
unzip -o "$DST_BUNDLE" -d "$OUT_DIR" > /dev/null
echo "✓ Extracted $(find "$OUT_DIR" -name '*.lua' | wc -l | tr -d ' ') Lua files to $OUT_DIR"
```

- [ ] **Step 2: Make executable and run**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
chmod +x tools/extract_dst_scripts.sh
./tools/extract_dst_scripts.sh
```

Expected: `✓ Extracted 1500+ Lua files to .../reference/dst-scripts`

- [ ] **Step 3: Verify key reference files exist**

```bash
ls reference/dst-scripts/scripts/prefabs/wilson.lua
ls reference/dst-scripts/scripts/components/sanity.lua
ls reference/dst-scripts/scripts/playerprofile.lua
```

Expected: all 3 paths print (no `No such file`).

---

## Task 3: Initialize git repository

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Init git in mod folder**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
git init
git branch -M main
```

- [ ] **Step 2: Write `.gitignore`**

Create `.gitignore`:

```gitignore
# OS
.DS_Store
Thumbs.db

# DST extracted reference (large, regeneratable via tools/extract_dst_scripts.sh)
reference/

# Editor
.vscode/
.idea/
*.swp
*~

# Built artifacts
*.tex.bak

# Local config (if any)
.env
```

- [ ] **Step 3: First commit (existing docs + new gitignore)**

```bash
git add .gitignore
git add docs/ dengxian_architecture.md dengxian_gameplay_glossary.md dengxian_wiki_data.md
git add 'Đăng-Tiên.pdf'
git commit -m "chore: initial commit (reference docs + design spec + plan 1)"
```

- [ ] **Step 4: Verify clean state**

```bash
git status
```

Expected: `nothing to commit, working tree clean` (or only `tools/` if you've already created scripts above — that's OK, add and commit those too).

---

## Task 4: Write syntax check tool

**Files:**
- Create: `tools/check_syntax.sh`

- [ ] **Step 1: Write the script**

Create `tools/check_syntax.sh`:

```bash
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
```

- [ ] **Step 2: Make executable and run on empty project**

```bash
chmod +x tools/check_syntax.sh
./tools/check_syntax.sh
```

Expected: `✓ All 0 Lua files pass syntax check` (no `.lua` files yet — that's the baseline).

- [ ] **Step 3: Commit**

```bash
git add tools/check_syntax.sh tools/extract_dst_scripts.sh
git commit -m "feat(tools): add syntax check + DST scripts extractor"
```

---

## Task 5: Write asset check tool

**Files:**
- Create: `tools/check_assets.py`

- [ ] **Step 1: Write the script**

Create `tools/check_assets.py`:

```python
#!/usr/bin/env python3
"""Verify all Asset() references in .lua files point to existing files,
and all .xml atlas references point to existing .tex files."""

import re
import sys
from pathlib import Path

MOD_ROOT = Path(__file__).parent.parent
ASSET_RE = re.compile(r'Asset\s*\(\s*"([A-Z]+)"\s*,\s*"([^"]+)"\s*\)')
XML_TEX_RE = re.compile(r'<Texture\s+filename="([^"]+)"')

def main() -> int:
    errors = []

    # 1. Check Asset() references in Lua files
    for lua_file in MOD_ROOT.rglob("*.lua"):
        if "reference" in lua_file.parts or ".git" in lua_file.parts:
            continue
        text = lua_file.read_text(encoding="utf-8", errors="ignore")
        for kind, path in ASSET_RE.findall(text):
            full = MOD_ROOT / path
            if not full.exists():
                errors.append(f"{lua_file.relative_to(MOD_ROOT)}: Asset(\"{kind}\", \"{path}\") not found")

    # 2. Check .xml atlases reference existing .tex
    for xml in MOD_ROOT.rglob("*.xml"):
        if "reference" in xml.parts or ".git" in xml.parts:
            continue
        text = xml.read_text(encoding="utf-8", errors="ignore")
        for tex_ref in XML_TEX_RE.findall(text):
            tex_path = xml.parent / tex_ref
            if not tex_path.exists():
                errors.append(f"{xml.relative_to(MOD_ROOT)}: <Texture filename=\"{tex_ref}\"> not found")

    if errors:
        for e in errors:
            print(f"✗ {e}")
        print(f"\n✗ {len(errors)} asset reference error(s)")
        return 1

    print("✓ All asset references valid")
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 2: Make executable and run**

```bash
chmod +x tools/check_assets.py
./tools/check_assets.py
```

Expected: `✓ All asset references valid` (no Lua files yet, vacuously true).

- [ ] **Step 3: Commit**

```bash
git add tools/check_assets.py
git commit -m "feat(tools): add asset reference check"
```

---

## Task 6: Write `modinfo.lua`

**Files:**
- Create: `modinfo.lua`

DST reads this file to show the mod in the in-game mods list and to know what mod options to expose. Reference: `reference/dst-scripts/scripts/main.lua` and existing user mod `~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods/dang-tien-vietnamese/modinfo.lua`.

- [ ] **Step 1: Write `modinfo.lua`**

```lua
name = "Phàm Nhân Tu Tiên"
description = [[
Mod tu tiên lấy cảm hứng từ tiểu thuyết 「凡人修仙传」(Phàm Nhân Tu Tiên Truyện) của 忘语.

Tất cả player bắt đầu từ phàm nhân với linh căn ngẫu nhiên, tự tìm linh dược, tu cảnh giới qua tích lũy linh khí.

MVP1 (Plan 1): mod skeleton — character "phàm nhân" tồn tại, chưa có gameplay cultivation.
]]
author = "kimdat546"
version = "0.1.0-p1"

forumthread = ""

api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "phamnhan", "tu tiên", "xianxia" }

priority = -50  -- chạy sau hầu hết mod khác để override character list cuối

configuration_options = {
    -- Plan 1: chưa có config option nào. Plan 2+ sẽ thêm.
}
```

- [ ] **Step 2: Run syntax check**

```bash
./tools/check_syntax.sh
```

Expected: `✓ All 1 Lua files pass syntax check`

- [ ] **Step 3: Commit**

```bash
git add modinfo.lua
git commit -m "feat: add modinfo.lua with mod metadata"
```

---

## Task 7: Write minimal `modmain.lua`

**Files:**
- Create: `modmain.lua`

For Plan 1, modmain only needs to: register the `phamnhan` prefab and register it as a playable character. Plan 2+ will extend with `AddAction`, `AddPrefabPostInit`, etc.

- [ ] **Step 1: Write `modmain.lua`**

```lua
-- Phàm Nhân Tu Tiên — modmain entry
-- Plan 1: register phamnhan character only

GLOBAL.setmetatable(env, {
    __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end,
})

PrefabFiles = {
    "phamnhan",
}

Assets = {
    Asset("IMAGE", "images/saveslot_portraits/phamnhan.tex"),
    Asset("ATLAS", "images/saveslot_portraits/phamnhan.xml"),

    Asset("IMAGE", "bigportraits/phamnhan.tex"),
    Asset("ATLAS", "bigportraits/phamnhan.xml"),

    Asset("IMAGE", "images/map_icons/phamnhan.tex"),
    Asset("ATLAS", "images/map_icons/phamnhan.xml"),

    Asset("IMAGE", "images/avatars/avatar_phamnhan.tex"),
    Asset("ATLAS", "images/avatars/avatar_phamnhan.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_phamnhan.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_phamnhan.xml"),

    Asset("IMAGE", "images/names_phamnhan.tex"),
    Asset("ATLAS", "images/names_phamnhan.xml"),
}

AddMinimapAtlas("images/map_icons/phamnhan.xml")

-- Register phamnhan as a playable character
-- (4th arg = gender, 5th = base skin set)
AddModCharacter("phamnhan", "MALE")

-- Character select override (load deferred until Task 13)
-- modimport("scripts/pn/charselect_override.lua")  -- enabled in Task 14

print("[PN] Phàm Nhân Tu Tiên mod loaded (Plan 1 — Foundation)")
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

Expected: `✓ All 2 Lua files pass syntax check`

- [ ] **Step 3: Asset check (will fail — assets not yet created)**

```bash
./tools/check_assets.py
```

Expected output: errors listing missing `images/saveslot_portraits/phamnhan.tex`, `bigportraits/phamnhan.tex`, etc. **This is expected for now** — we'll create placeholder assets in Task 11.

- [ ] **Step 4: Commit**

```bash
git add modmain.lua
git commit -m "feat: add modmain.lua skeleton with phamnhan registration"
```

---

## Task 8: Symlink mod into DST client mods folder

**Files:** none in mod repo (filesystem symlink)

This lets you test the mod in the DST client without uploading to Workshop. The symlink points the DST mods folder at our git checkout.

- [ ] **Step 1: Create symlink**

```bash
DST_MODS="/Users/kimdat546/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods"
ln -sf /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod "$DST_MODS/pntt_mod"
```

- [ ] **Step 2: Verify**

```bash
ls -la "$DST_MODS/pntt_mod"
```

Expected: `pntt_mod -> /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod` (symlink arrow visible).

- [ ] **Step 3: Manual test — launch DST and check mod list**

Open DST → Main menu → Mods → Server mods → Look for "Phàm Nhân Tu Tiên" in the list. **Expected:** mod appears but with a yellow warning icon (because `phamnhan.lua` and assets don't exist yet — that's fine, fix in next tasks).

Note: this step requires running DST locally. If running automated, skip this step and proceed — Task 17 covers headless verification.

---

## Task 9: Create minimal `phamnhan` prefab

**Files:**
- Create: `scripts/prefabs/phamnhan.lua`

For Plan 1, the prefab uses DST's `MakePlayerCharacter` helper with **NO** custom components. It's a Wilson clone with no perks. Reference: `reference/dst-scripts/scripts/prefabs/wilson.lua`.

- [ ] **Step 1: Write the prefab**

```lua
-- scripts/prefabs/phamnhan.lua
-- Plan 1: minimal player character, no perks, no cultivation yet.
-- Future plans will add pn_linhcan, pn_tuvi, pn_canhgioi, pn_lifespan, etc.

local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
    -- Re-use vanilla player skeleton for MVP1. Future plans add anim/phamnhan.zip.
}

local prefabs = {}

local start_inv = {
    -- Phàm nhân spawn không có gì (đúng tinh thần PNTT novel).
}

local function common_postinit(inst)
    -- Add network tag for future mod features
    inst:AddTag("phamnhan")
end

local function master_postinit(inst)
    -- Base stats matching Wilson default (no perks for MVP1)
    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)

    inst.components.combat.damagemultiplier = 1.0
    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE

    -- Plan 1: NO mod components added. Plan 2 adds pn_linhcan, etc.
end

return MakePlayerCharacter("phamnhan", prefabs, assets, common_postinit, master_postinit, start_inv)
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

Expected: `✓ All 3 Lua files pass syntax check`

- [ ] **Step 3: Commit**

```bash
git add scripts/prefabs/phamnhan.lua
git commit -m "feat: add minimal phamnhan player prefab (no perks, no cultivation)"
```

---

## Task 10: Add character strings

**Files:**
- Create: `scripts/speech_phamnhan.lua` (placeholder; full speech in P7)

DST requires every playable character to have a speech table. For Plan 1, copy Wilson's speech and rename — we'll customize later.

- [ ] **Step 1: Copy Wilson speech**

```bash
mkdir -p /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod/scripts
cp /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod/reference/dst-scripts/scripts/speech_wilson.lua \
   /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod/scripts/speech_phamnhan.lua
```

- [ ] **Step 2: Append speech registration to modmain.lua**

Edit `modmain.lua`, before the final `print(...)` line, add:

```lua
-- Register character speech
STRINGS.CHARACTER_TITLES.phamnhan      = "Phàm Nhân"
STRINGS.CHARACTER_NAMES.phamnhan       = "Phàm Nhân"
STRINGS.CHARACTER_DESCRIPTIONS.phamnhan= "Một phàm nhân bình thường, mơ ước con đường tu tiên."
STRINGS.CHARACTER_QUOTES.phamnhan      = "\"Tu đạo chi lộ, nghịch thiên mà hành.\""
```

- [ ] **Step 3: Syntax check**

```bash
./tools/check_syntax.sh
```

Expected: `✓ All 4 Lua files pass syntax check`

- [ ] **Step 4: Commit**

```bash
git add scripts/speech_phamnhan.lua modmain.lua
git commit -m "feat: add phamnhan speech (Wilson copy) and character strings"
```

---

## Task 11: Create placeholder portrait assets

**Files:**
- Create: `images/saveslot_portraits/phamnhan.tex`, `.xml`
- Create: `bigportraits/phamnhan.tex`, `.xml`
- Create: `images/map_icons/phamnhan.tex`, `.xml`
- Create: `images/avatars/avatar_phamnhan.tex`, `.xml`
- Create: `images/avatars/avatar_ghost_phamnhan.tex`, `.xml`
- Create: `images/names_phamnhan.tex`, `.xml`
- Create: `modicon.tex`, `modicon.xml`

For Plan 1 we use placeholder = copy Wilson's portraits. Visual polish in Plan 7.

- [ ] **Step 1: Copy Wilson portrait assets**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
DST_INSTALL="/Users/kimdat546/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents"

mkdir -p images/saveslot_portraits bigportraits images/map_icons images/avatars

# saveslot_portraits
cp "$DST_INSTALL/data/anim/wilson.zip" /tmp/wilson_anim.zip 2>/dev/null || true

# Alternative: extract from existing user mod (dang-tien-vietnamese) for simpler placeholder
# OR generate simple solid-color textures via a script.
# For Plan 1 we ship with TODO placeholders; if missing assets cause crash, switch to copy-from-wilson.
```

Realistically, `.tex` files are binary Klei texture format. The simplest path: **copy from an existing user mod that already ships portraits**. The user has `dang-tien-vietnamese` installed locally — use its portraits as placeholders.

```bash
SRC="/Users/kimdat546/Library/Application Support/Steam/steamapps/common/Don't Starve Together/dontstarve_steam.app/Contents/mods/dang-tien-vietnamese"
DEST="/Users/kimdat546/Desktop/pham-nhan-tu-tien-mod"

# Examine source first
ls "$SRC/images/saveslot_portraits/" | head -5
```

- [ ] **Step 2: Copy each required asset**

For each portrait DST expects, copy one from `dang-tien-vietnamese` (or any other vanilla character with extracted assets) and rename. Example for one file:

```bash
# saveslot portrait — use any character from dang-tien-vietnamese
# Adjust source filename to match what's in that mod's directory
cp "$SRC/images/saveslot_portraits/wilson.tex" "$DEST/images/saveslot_portraits/phamnhan.tex" 2>/dev/null || \
    echo "FALLBACK: please supply phamnhan.tex manually"
cp "$SRC/images/saveslot_portraits/wilson.xml" "$DEST/images/saveslot_portraits/phamnhan.xml" 2>/dev/null

# Edit .xml to rename internal reference from wilson.tex → phamnhan.tex
sed -i.bak 's/wilson\.tex/phamnhan.tex/g' "$DEST/images/saveslot_portraits/phamnhan.xml"
rm -f "$DEST/images/saveslot_portraits/phamnhan.xml.bak"
```

Repeat for all 6 asset pairs (saveslot, bigportrait, map_icon, avatar, avatar_ghost, names) **+ modicon**. If `dang-tien-vietnamese` doesn't have the exact filenames, fall back to copying from `Don't Starve Mod Tools/mod_tools/scripts/...` templates.

**Note:** This step is fiddly because `.tex` is binary. If you can't get the copy approach to work in 30 minutes, the alternative is using `ktools` (`brew install ktools`) to generate `.tex` from PNG. For Plan 1, accept rough-looking portraits — they're placeholders.

- [ ] **Step 3: Verify with asset check**

```bash
./tools/check_assets.py
```

Expected: `✓ All asset references valid` (all `Asset(...)` calls in `modmain.lua` now resolve).

- [ ] **Step 4: Commit**

```bash
git add modicon.tex modicon.xml images/ bigportraits/
git commit -m "feat: add placeholder portrait assets (copied from dang-tien-vietnamese)"
```

---

## Task 12: Manual test — phamnhan visible in DST character select

**Files:** none (manual verification only)

- [ ] **Step 1: Launch DST**

Open DST client.

- [ ] **Step 2: Enable mod**

Main menu → Mods → Server mods → Find "Phàm Nhân Tu Tiên" → click to enable.

- [ ] **Step 3: Start a single-player world (host game)**

Click "Host game" → pick any world preset → Start.

- [ ] **Step 4: Verify character select**

Expected: at the character selection screen, you should see **Phàm Nhân** as one of the characters (alongside Wilson, Willow, etc.). Portrait may look like a vanilla character (placeholder), but the name should read "Phàm Nhân".

- [ ] **Step 5: Pick Phàm Nhân and spawn**

Expected: game loads, you spawn into the world as a character. Health/Hunger/Sanity HUD shows 100/150/200. No mod errors in console.

- [ ] **Step 6: Quit and document result**

Quit to main menu. If verification passed, proceed to Task 13. If failed, note the error message (check `documents/Klei/DoNotStarveTogether/client_log.txt` for crash details) and debug before continuing.

---

## Task 13: Write character select override

**Files:**
- Create: `scripts/pn/charselect_override.lua`

This hides all vanilla characters from the select screen, leaving only `phamnhan`.

- [ ] **Step 1: Write the override module**

```lua
-- scripts/pn/charselect_override.lua
-- Hide vanilla DST characters from the character select screen.
-- Only "phamnhan" should be selectable.

local PN_CHARS = { "phamnhan" }

-- Client-side: hide non-phamnhan characters from select UI.
AddClassPostConstruct("screens/redux/characterselectscreen", function(self)
    -- self.heroportraits is a table of HeroPortrait widgets.
    -- Replace the character list with only phamnhan.
    if self.heroes ~= nil then
        local filtered = {}
        for _, hero in ipairs(self.heroes) do
            if hero == "phamnhan" then
                table.insert(filtered, hero)
            end
        end
        self.heroes = filtered
    end

    -- Refresh portraits if API exposes it
    if self.RefreshPortraits then
        self:RefreshPortraits()
    end
end)

-- Server-side: if a player joins as a non-phamnhan character (via console or
-- another mod), forcibly convert them.
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end

    inst:ListenForEvent("ms_playerjoined", function(_, player)
        if player.prefab ~= "phamnhan" then
            print(string.format("[PN] Player %s joined as %s — converting to phamnhan", tostring(player.userid), player.prefab))
            -- Use DST's despawn+replace flow
            GLOBAL.TheWorld:PushEvent("ms_playerdespawnandreplace", {
                player    = player,
                newprefab = "phamnhan",
            })
        end
    end)
end)
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

Expected: `✓ All 5 Lua files pass syntax check`

- [ ] **Step 3: Commit**

```bash
git add scripts/pn/charselect_override.lua
git commit -m "feat: add character select override (hide vanilla, force phamnhan)"
```

---

## Task 14: Wire override into `modmain.lua`

**Files:**
- Modify: `modmain.lua`

- [ ] **Step 1: Uncomment the modimport line**

In `modmain.lua`, find the line:

```lua
-- modimport("scripts/pn/charselect_override.lua")  -- enabled in Task 14
```

Replace with:

```lua
modimport("scripts/pn/charselect_override.lua")
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

Expected: `✓ All 5 Lua files pass syntax check`

- [ ] **Step 3: Manual test — verify only phamnhan in select**

Launch DST → host game → reach character select screen.

Expected: **only Phàm Nhân portrait visible**, no Wilson/Willow/etc.

If multiple portraits still show, the `AddClassPostConstruct` hook may need adjustment for the current DST version. Check `reference/dst-scripts/scripts/screens/redux/characterselectscreen.lua` for the current property names (`self.heroes`, `self.character_list`, `self.heroportraits` — names changed between versions) and update `charselect_override.lua` accordingly.

- [ ] **Step 4: Commit**

```bash
git add modmain.lua
git commit -m "feat: wire charselect_override into modmain"
```

---

## Task 15: Create `pntt-dev` branch in dst-server-docker

**Files (in `~/Desktop/dst-server-docker/`):**
- Create: branch `pntt-dev`
- Create: `cli/compose.override.yml`
- Modify: `server/config/Master/modoverrides.lua`

- [ ] **Step 1: Create branch**

```bash
cd /Users/kimdat546/Desktop/dst-server-docker
git status   # ensure clean working tree
git checkout -b pntt-dev
```

- [ ] **Step 2: Write `cli/compose.override.yml`**

Create `cli/compose.override.yml`:

```yaml
# Override for local development — mounts the pntt_mod folder into the container.
# Use via: dst-dev start (see Task 16 alias)

services:
  master:
    volumes:
      - /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod:/home/steam/dst/mods/pntt_mod:ro
    environment:
      DST_FORCE_ENABLE_MODS: "pntt_mod"
      DEBUG_PNTT: "true"
```

- [ ] **Step 3: Write `server/config/Master/modoverrides.lua`**

Overwrite (or create) `server/config/Master/modoverrides.lua`:

```lua
return {
    ["pntt_mod"] = {
        enabled = true,
        configuration_options = {
            -- Plan 1: no config options yet
        },
    },
}
```

- [ ] **Step 4: Commit on pntt-dev branch**

```bash
cd /Users/kimdat546/Desktop/dst-server-docker
git add cli/compose.override.yml server/config/Master/modoverrides.lua
git commit -m "feat: add pntt-dev local dev override (mount local mod folder)"
```

---

## Task 16: Write smoke test script

**Files (in mod repo):**
- Create: `tools/smoke_test.sh`

- [ ] **Step 1: Write the script**

Create `tools/smoke_test.sh`:

```bash
#!/usr/bin/env bash
# Headless smoke test — start DST dedicated server with pntt_mod enabled,
# wait for stabilization, scan logs for Lua errors.

set -euo pipefail

DST_SERVER_DIR="/Users/kimdat546/Desktop/dst-server-docker"
COMPOSE_BASE="$DST_SERVER_DIR/cli/compose.yml"
COMPOSE_OVERRIDE="$DST_SERVER_DIR/cli/compose.override.yml"

if [[ ! -f "$COMPOSE_OVERRIDE" ]]; then
    echo "✗ compose.override.yml missing — did you run Task 15?"
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

echo "→ Starting DST server (pntt-dev branch, mod mounted)..."
docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_OVERRIDE" up -d

echo "→ Waiting 90s for server to initialize and load mod..."
sleep 90

echo "→ Scanning logs for errors..."
LOG=$(docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_OVERRIDE" logs --tail 500 2>&1)

# Pattern: real errors (not "0 errors" type)
if echo "$LOG" | grep -qE "(Lua error|LUA ERROR|Mod failed|Failed to load mod|^\[ERROR\])"; then
    echo "✗ Smoke test FAILED — errors found in log:"
    echo "$LOG" | grep -E "(error|fail|Error|Fail)" -A 3 | head -40
    docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_OVERRIDE" down
    exit 1
fi

# Confirm we saw the expected init message
if echo "$LOG" | grep -q "\[PN\] Phàm Nhân Tu Tiên mod loaded"; then
    echo "✓ Mod init message found"
else
    echo "✗ Smoke test FAILED — mod init message not in logs"
    echo "    (Expected: '[PN] Phàm Nhân Tu Tiên mod loaded')"
    docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_OVERRIDE" down
    exit 1
fi

echo "✓ Smoke test PASSED"
docker compose -f "$COMPOSE_BASE" -f "$COMPOSE_OVERRIDE" down
```

- [ ] **Step 2: Make executable**

```bash
chmod +x tools/smoke_test.sh
```

- [ ] **Step 3: Commit**

```bash
git add tools/smoke_test.sh
git commit -m "feat(tools): add Docker smoke test script"
```

---

## Task 17: Run smoke test end-to-end

**Files:** none (test execution only)

- [ ] **Step 1: Ensure OrbStack/Docker daemon running**

```bash
open -a OrbStack
sleep 5
docker version
```

Expected: `Server` section shows. If not, OrbStack may need first-time setup.

- [ ] **Step 2: Run smoke test**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/smoke_test.sh
```

Expected output:
```
→ Starting DST server (pntt-dev branch, mod mounted)...
→ Waiting 90s for server to initialize and load mod...
→ Scanning logs for errors...
✓ Mod init message found
✓ Smoke test PASSED
```

- [ ] **Step 3: If test fails, debug**

If errors appear, common causes and fixes:

| Error pattern | Likely cause | Fix |
|---|---|---|
| `Failed to load mod: pntt_mod` | Mount path wrong inside container | Verify `cli/compose.override.yml` volume path matches actual container Steam dir |
| `Cannot find prefab 'phamnhan'` | `PrefabFiles` mismatch | Check `modmain.lua` `PrefabFiles = {"phamnhan"}` line |
| `Asset not found: ...phamnhan.tex` | Placeholder asset missing | Verify Task 11 — re-copy missing files |
| `attempt to index a nil value` in `charselect_override.lua` | DST API field renamed | Check `reference/dst-scripts/scripts/screens/redux/characterselectscreen.lua` for current field name |

Fix the issue, then re-run from Step 2 until pass.

- [ ] **Step 4: No commit needed if pass; if fixes made, commit them**

```bash
git status
git add -A   # only if fixes were needed
git commit -m "fix: smoke test debugging fixes" || true
```

---

## Task 18: Final integration verification + tag

**Files:** none

- [ ] **Step 1: Run full check pipeline**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
./tools/smoke_test.sh
```

Expected: all 3 pass.

- [ ] **Step 2: Manual integration test (DST client)**

Launch DST → enable mod → host single-player game → reach character select.

Expected:
1. Only **Phàm Nhân** is selectable
2. Pick Phàm Nhân → spawn into world
3. No errors in `~/Documents/Klei/DoNotStarveTogether/client_log.txt`
4. Player HUD shows vanilla DST UI (no cultivation widgets — that's Plan 2)

- [ ] **Step 3: Tag the completed plan**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
git tag -a p1-foundation-complete -m "Plan 1 (Foundation) complete: mod loads, phamnhan spawnable, vanilla chars hidden, smoke test green"
git log --oneline -20   # review what was built in Plan 1
```

Expected: ~12-15 commits all tagged on `p1-foundation-complete`.

- [ ] **Step 4: Update project memory (optional but recommended)**

```bash
# This memory file should note Plan 1 is complete + any key learnings
# (e.g. correct CharacterSelectScreen field name discovered during Task 14)
```

Add a note in `/Users/kimdat546/.claude/projects/-Users-kimdat546-Desktop-pham-nhan-tu-tien-mod/memory/` if any DST API quirks were learned that should persist for future plans.

---

## Self-review

After completing all tasks, this plan covers the spec's MVP1 §1.3 "Plan 1 Foundation" scope:

- ✅ §2.1 file structure laid down (partial — only files Plan 1 needs)
- ✅ Mod registration via `modinfo.lua` + `modmain.lua`
- ✅ Phamnhan character prefab (skeleton, no cultivation components yet — that's Plan 2)
- ✅ §7.4 character select override (client + server-side)
- ✅ §9.2 dev tools (check_syntax, check_assets, smoke_test, extract_dst_scripts)
- ✅ §9.3 Docker workflow (pntt-dev branch + compose.override + modoverrides)
- ✅ Git init (resolves spec §15 open question #7)

**Not in Plan 1 (deferred to Plan 2+):**
- 8 cultivation components (Plan 2 = 4 of them, Plan 3 = lifespan, Plan 4 = aura/meditation, Plan 5 = mob cultivation)
- Linh mạch entity, worldgen scatter
- Items (nội đan, linh thảo)
- HUD widgets
- Tuning constants files (no balance logic yet to tune)

**Risks acknowledged inline:**
- Task 11: placeholder portrait assets may need manual fixup if `.tex` copy approach fails
- Task 14: CharacterSelectScreen API field names may differ between DST versions
- Task 17: smoke test debugging if mount/path/asset issues surface

---

**End of Plan 1.**

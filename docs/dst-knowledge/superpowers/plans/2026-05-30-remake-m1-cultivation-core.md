# Remake M1 — Cultivation Core — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`).

**Goal:** Build a clean, extensible Cultivation Core for the Phàm Nhân Tu Tiên remake: a "phàm nhân" character who gains tu vi only by killing monsters, advances through the 13 layers of Luyện Khí (data-driven realm ladder), gains meaningful stats, shown on a Dengxian-style đan điền HUD. No lifespan, no meditation — vanilla survival intact.

**Architecture:** Bootstrap-layer mod (thin `modmain.lua` → `scripts/main/import.lua` → one file per registration concern, like Dengxian). 4 event-driven server components (+3 replicas) on the player. Realm ladder is pure data (`pn/realms.lua`) so adding realms later needs no logic changes. Built strictly per `docs/analysis/dst-api-foundation.md` to avoid MVP1's 8 known pitfalls.

**Tech Stack:** Lua 5.x (DST runtime), `luac` (syntax), Python 3 + Pillow (KTEX tools), git, bash. DST modding API (components/replicas/widgets/AddPrefabPostInit).

**Spec:** `docs/superpowers/specs/2026-05-30-remake-m1-cultivation-core-design.md`

**Testing note (DST-specific):** DST mods cannot be unit-tested with a normal test runner — they need the game runtime. So each task's "verification" = `tools/check_syntax.sh` (luac -p) + `tools/check_assets.py` where relevant, and a clear in-game verification step the user runs after `tools/sync_local.sh`. Static checks gate every commit; in-game checks are batched at milestone end.

**Reference docs to consult while implementing:**
- `docs/analysis/dst-api-foundation.md` — verified API + 8-pitfall cheat sheet (READ the relevant section before each component)
- `docs/analysis/pntt-novel-systems.md` — realm/linh căn canon
- `docs/superpowers/specs/2026-05-30-remake-m1-cultivation-core-design.md` — the spec

**Existing reusable assets (already in repo / recoverable):**
- `tools/`: check_syntax.sh, check_assets.py, sync_local.sh, ktex_to_png.py, png_to_ktex.py, extract_dst_scripts.sh
- `reference/dst-scripts/` — DST source (regenerate with extract_dst_scripts.sh if missing)
- Dengxian UI atlas: copy `images/pn_ui.tex` + `.xml` from MVP1 archive (git tag `mvp1-archive`) or re-copy from `~/Desktop/dengxian-assets-review/raw_tex/images/xd_ui.*`
- phàm nhân character build: recover `anim/phamnhan.zip` + `ghost_phamnhan_build.zip` + portrait assets from `git show mvp1-archive` or `~/Desktop/dengxian-assets-review`

---

## File summary

**Created (mod root):**
- `modinfo.lua`, `modmain.lua`
- `scripts/main/{import,assets,strings,character,components,widgets,mob_hooks,debug}.lua`
- `scripts/pn/{config,events,linhcan_data,realms}.lua`
- `scripts/components/pn_linhcan.lua` + `pn_linhcan_replica.lua`
- `scripts/components/pn_tuvi.lua` + `pn_tuvi_replica.lua`
- `scripts/components/pn_canhgioi.lua` + `pn_canhgioi_replica.lua`
- `scripts/components/pn_breakthrough.lua`
- `scripts/widgets/pn_hud_dantian.lua`
- `scripts/prefabs/phamnhan.lua`
- `scripts/speech_phamnhan.lua`
- assets: `anim/phamnhan.zip`, `anim/ghost_phamnhan_build.zip`, `images/pn_ui.{tex,xml}`, portrait `.tex/.xml` set, `modicon.{tex,xml}`

---

## Task 1: Verify environment + recover reusable assets

**Files:** none created (setup only)

- [ ] **Step 1: Confirm tools + git state**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
luac -v
ls tools/
git tag | grep mvp1-archive
[ -d reference/dst-scripts/scripts ] && echo "DST source OK" || ./tools/extract_dst_scripts.sh
```
Expected: luac prints version; tools/ has check_syntax.sh etc.; `mvp1-archive` tag exists; DST source present.

- [ ] **Step 2: Recover reusable binary assets from the MVP1 archive into a holding dir**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
mkdir -p /tmp/pn_recover
git --work-tree=/tmp/pn_recover checkout mvp1-archive -- \
  images/pn_ui.tex images/pn_ui.xml \
  anim/phamnhan.zip anim/ghost_phamnhan_build.zip \
  modicon.tex modicon.xml \
  images/saveslot_portraits/phamnhan.tex images/saveslot_portraits/phamnhan.xml \
  bigportraits/phamnhan.tex bigportraits/phamnhan.xml \
  images/map_icons/phamnhan.tex images/map_icons/phamnhan.xml \
  images/avatars/avatar_phamnhan.tex images/avatars/avatar_phamnhan.xml \
  images/avatars/avatar_ghost_phamnhan.tex images/avatars/avatar_ghost_phamnhan.xml \
  images/names_phamnhan.tex images/names_phamnhan.xml \
  scripts/speech_phamnhan.lua 2>&1 | tail -2
# git checkout of a tag stages files into index; reset index but keep files on disk under /tmp
git reset -q 2>/dev/null
find /tmp/pn_recover -type f | wc -l
```
Expected: ~20 files recovered to /tmp/pn_recover (the index may get the paths; we copy from there in later tasks). If `git --work-tree` approach fails, fall back to: `git show mvp1-archive:images/pn_ui.tex > /tmp/pn_recover/...` per file, OR copy `images/xd_ui.*` from `~/Desktop/dengxian-assets-review/raw_tex/`.

- [ ] **Step 3: No commit (setup task).** Proceed to Task 2.

---

## Task 2: modinfo.lua + thin modmain.lua + bootstrap import

**Files:**
- Create: `modinfo.lua`, `modmain.lua`, `scripts/main/import.lua`

- [ ] **Step 1: Write `modinfo.lua`**

```lua
name = "Phàm Nhân Tu Tiên [Alpha]"
description = [[
Mod tu tiên lấy cảm hứng từ 凡人修仙传 (Phàm Nhân Tu Tiên). Remake.

Mọi người chơi là phàm nhân với linh căn ngẫu nhiên, tu Luyện Khí bằng cách
giết yêu thú hấp thu tinh khí. Cảnh giới cao = mạnh hơn (nhưng vẫn là phàm
nhân — vanilla mechanics nguyên vẹn).

ALPHA — Milestone 1: Cultivation Core.
]]
author = "kimdat546"
version = "0.2.0-remake-m1"
forumthread = ""
api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = { "phamnhan", "tu tiên", "xianxia" }
priority = -50
configuration_options = {}
```

- [ ] **Step 2: Write thin `modmain.lua`**

```lua
-- Phàm Nhân Tu Tiên (remake) — thin entry. All registration lives in scripts/main/*.
GLOBAL.setmetatable(env, {
    __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end,
})

modimport("scripts/main/import.lua")

print("[PN] Phàm Nhân Tu Tiên (remake M1) loaded")
```

- [ ] **Step 3: Write `scripts/main/import.lua` (orchestrator)**

```lua
-- scripts/main/import.lua — modimport every other bootstrap file in order.
-- Order matters: assets/strings/character first, then components, widgets, hooks.
modimport("scripts/main/assets.lua")
modimport("scripts/main/strings.lua")
modimport("scripts/main/character.lua")
modimport("scripts/main/components.lua")
modimport("scripts/main/widgets.lua")
modimport("scripts/main/mob_hooks.lua")
modimport("scripts/main/debug.lua")
```

- [ ] **Step 4: Syntax check**

```bash
./tools/check_syntax.sh
```
Expected: `✓ All N Lua files pass syntax check` (the main/* files referenced don't exist yet, but modimport is runtime — luac only checks syntax of files that exist; this passes).

- [ ] **Step 5: Commit**

```bash
git add modinfo.lua modmain.lua scripts/main/import.lua
git commit -m "feat(remake): modinfo + thin modmain + bootstrap import orchestrator"
```

---

## Task 3: Data modules — config, events, linhcan_data, realms

**Files:**
- Create: `scripts/pn/config.lua`, `scripts/pn/events.lua`, `scripts/pn/linhcan_data.lua`, `scripts/pn/realms.lua`

- [ ] **Step 1: Write `scripts/pn/events.lua`**

```lua
-- Centralized event-name constants.
return {
    TUVI_GAIN    = "pn_tuvi_gain",      -- {amount, source}
    TUVI_CHANGED = "pn_tuvi_changed",   -- {new_value, old_value, cap}
    CANHGIOI_UP  = "pn_canhgioi_up",    -- {new_tier, old_tier}
    LINHCAN_ROLLED = "pn_linhcan_rolled",
}
```

- [ ] **Step 2: Write `scripts/pn/config.lua`**

```lua
-- All balance constants. Tune here, never in logic files.
return {
    TU_VI = {
        THRESHOLD_BASE = 80,
        THRESHOLD_EXPONENT = 1.6,
    },
    STATS_PER_LAYER = {
        HP_BONUS          = 12,     -- +12 max HP per Luyện Khí layer
        DMG_MULT_DELTA    = 0.06,   -- +6% damage per layer
        SPEED_MULT_DELTA  = 0.008,  -- +0.8% move speed per layer
        HUNGER_MULT_DELTA = -0.02,  -- -2% hunger drain per layer
    },
    -- tu vi granted per monster kill (by prefab). Tunable starting values.
    TUVI_PER_MOB = {
        spider = 8, spider_warrior = 15, spider_hider = 12, spider_spitter = 14, spider_dropper = 12,
        hound = 20, firehound = 28, icehound = 28,
        frog = 10, killerbee = 6, bee = 4, mosquito = 4,
        merm = 18, pigman = 25, pigguard = 40, bunnyman = 12,
        rook = 60, knight = 70, bishop = 80,
        -- bosses
        deerclops = 400, moose = 350, bearger = 400, dragonfly = 600,
    },
    MOB_BUFF = { hp_mult = 1.4, dmg_mult = 1.25 },
    -- which mobs get patched (tu vi grant + buff). Combat-capable only.
    MOBS_TO_PATCH = {
        "spider", "spider_warrior", "spider_hider", "spider_spitter", "spider_dropper",
        "hound", "firehound", "icehound",
        "frog", "killerbee", "bee", "mosquito",
        "merm", "pigman", "pigguard", "bunnyman",
        "rook", "knight", "bishop",
        "deerclops", "moose", "bearger", "dragonfly",
    },
}
```

- [ ] **Step 3: Write `scripts/pn/linhcan_data.lua`**

```lua
-- Linh căn (spiritual root) data. tu_vi_mult capped 1.0–1.3 for MP fairness;
-- differentiation comes from element affinity (future), not raw speed.
local data = {}

data.ELEMENTS = { "KIM", "MOC", "THUY", "HOA", "THO" }
data.ELEMENT_DISPLAY = { KIM="Kim", MOC="Mộc", THUY="Thủy", HOA="Hỏa", THO="Thổ" }

data.TYPES = {
    NGUY    = { weight=65, element_count={4,5}, tu_vi_mult=1.0, display="Ngụy Linh Căn" },
    CHAN    = { weight=30, element_count={2,3}, tu_vi_mult=1.1, display="Chân Linh Căn" },
    BIEN_DI = { weight=3,  element_count={2,3}, tu_vi_mult=1.2, display="Biến Dị Linh Căn", special=true },
    THIEN   = { weight=2,  element_count={1,1}, tu_vi_mult=1.3, display="Thiên Linh Căn" },
}
-- ascending-weight order for the weighted roll
data.ROLL_ORDER = { "THIEN", "BIEN_DI", "CHAN", "NGUY" }

data.BIEN_DI_COMBOS = {
    { elements={"KIM","THUY"}, tag="BANG",   display="Băng Linh Căn" },
    { elements={"KIM","HOA"},  tag="LOI",    display="Lôi Linh Căn" },
    { elements={"MOC","HOA"},  tag="PHUONG", display="Phượng Linh Căn" },
    { elements={"MOC","THUY"}, tag="PHONG",  display="Phong Linh Căn" },
    { elements={"THUY","HOA"}, tag="AM_DUONG", display="Âm Dương Linh Căn" },
    { elements={"THO","KIM"},  tag="THACH",  display="Thạch Linh Căn" },
}

-- which dantian medallion (level1-6 in pn_ui) for a primary element
data.ELEMENT_MEDALLION = {
    THUY="level1.tex", KIM="level3.tex", MOC="level4.tex",
    THO="level5.tex", HOA="level6.tex",
}
data.DEFAULT_MEDALLION = "level2.tex"

return data
```

- [ ] **Step 4: Write `scripts/pn/realms.lua`**

```lua
-- Realm ladder — pure data. M1 only enables LUYEN_KHI (13 layers). Higher realms
-- are defined (enabled=false) so later milestones flip a flag, no logic changes.
local config = require("pn/config")

local M = {}

M.macro_tiers = { "PHAM_NHAN", "LINH_GIOI", "TIEN_GIOI" }

M.realms = {
    { id="LUYEN_KHI",  macro="PHAM_NHAN", display="Luyện Khí",  mode="layers", layer_count=13, enabled=true },
    { id="TRUC_CO",    macro="LINH_GIOI", display="Trúc Cơ",    mode="quarters", enabled=false },
    { id="KET_DAN",    macro="LINH_GIOI", display="Kết Đan",    mode="quarters", enabled=false },
    { id="NGUYEN_ANH", macro="LINH_GIOI", display="Nguyên Anh", mode="quarters", enabled=false },
    { id="HOA_THAN",   macro="LINH_GIOI", display="Hoá Thần",   mode="quarters", enabled=false },
    { id="LUYEN_HU",   macro="TIEN_GIOI", display="Luyện Hư",   mode="quarters", enabled=false },
    { id="HOP_THE",    macro="TIEN_GIOI", display="Hợp Thể",    mode="quarters", enabled=false },
    { id="DAI_THUA",   macro="TIEN_GIOI", display="Đại Thừa",   mode="quarters", enabled=false },
}

-- Total cultivation "tiers" enabled in M1 = number of Luyện Khí layers.
function M.GetMaxTier()
    for _, r in ipairs(M.realms) do
        if r.id == "LUYEN_KHI" then return r.layer_count end
    end
    return 13
end

-- tu vi needed to reach tier N (1..max). threshold(N) = BASE * N^EXP.
function M.GetThreshold(target_tier)
    if target_tier <= 0 then return 0 end
    return math.floor(config.TU_VI.THRESHOLD_BASE * (target_tier ^ config.TU_VI.THRESHOLD_EXPONENT))
end

-- Display string for a tier. 0 = Phàm Nhân; 1..13 = Luyện Khí tầng N.
function M.GetDisplay(tier)
    if tier <= 0 then return "Phàm Nhân" end
    if tier <= M.GetMaxTier() then return string.format("Luyện Khí tầng %d", tier) end
    return "Vô danh"
end

-- HUD colour by tier (white phàm nhân → light-blue early → cyan high)
function M.GetColor(tier)
    if tier <= 0 then return {1,1,1,1} end
    if tier <= 6 then return {0.7,0.9,1,1} end
    return {0.3,1,1,1}
end

return M
```

- [ ] **Step 5: Syntax check + verify threshold math**

```bash
./tools/check_syntax.sh
cd reference/dst-scripts 2>/dev/null; cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
lua5.4 -e 'package.path="./scripts/?.lua;"..package.path; local R=require("pn/realms"); for n=1,13 do io.write(n..":"..R.GetThreshold(n).." ") end; print()' 2>/dev/null || echo "(lua standalone optional; threshold = 80*N^1.6)"
```
Expected: syntax passes. Threshold tier1≈80, tier13≈80*13^1.6≈80*65≈5200 per-step; cumulative ~16k. (If standalone lua errors on require path, that's fine — it's verified at runtime.)

- [ ] **Step 6: Commit**

```bash
git add scripts/pn/config.lua scripts/pn/events.lua scripts/pn/linhcan_data.lua scripts/pn/realms.lua
git commit -m "feat(pn): data modules — config, events, linhcan_data, realms (data-driven ladder)"
```

---

## Task 4: pn_linhcan component + replica

**Files:**
- Create: `scripts/components/pn_linhcan.lua`, `scripts/components/pn_linhcan_replica.lua`

**Before writing:** read `docs/analysis/dst-api-foundation.md` §3 (components/replicas) — note: NO `GLOBAL.` prefix here (these load via require), use bare engine globals; push initial state via DoTaskInTime(0).

- [ ] **Step 1: Write `scripts/components/pn_linhcan.lua`**

```lua
local LinhCanData = require("pn/linhcan_data")
local Events = require("pn/events")

local PnLinhCan = Class(function(self, inst)
    self.inst = inst
    self.type = nil
    self.elements = nil
    self.bien_di_tag = nil
    self.rolled = false
    if inst then
        inst:DoTaskInTime(0, function() self:_PushToReplica() end)
    end
end)

function PnLinhCan:RollNew(force)
    if self.rolled and not force then return end
    local roll = math.random() * 100
    local cumulative, picked = 0, "NGUY"
    for _, t in ipairs(LinhCanData.ROLL_ORDER) do
        cumulative = cumulative + LinhCanData.TYPES[t].weight
        if roll <= cumulative then picked = t; break end
    end
    self.type = picked
    local tdef = LinhCanData.TYPES[picked]
    local n = math.random(tdef.element_count[1], tdef.element_count[2])
    local all = {}
    for _, e in ipairs(LinhCanData.ELEMENTS) do table.insert(all, e) end
    for i = #all, 2, -1 do local j = math.random(i); all[i], all[j] = all[j], all[i] end
    self.elements = {}
    for i = 1, n do table.insert(self.elements, all[i]) end
    table.sort(self.elements)
    self.bien_di_tag = nil
    if picked == "BIEN_DI" and n == 2 then
        for _, c in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            local a, b = c.elements[1], c.elements[2]
            if (self.elements[1]==a and self.elements[2]==b) or (self.elements[1]==b and self.elements[2]==a) then
                self.bien_di_tag = c.tag; break
            end
        end
    end
    self.rolled = true
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LINHCAN_ROLLED, { type=self.type, elements=self.elements })
    end
end

function PnLinhCan:GetTuViMult()
    return self.type and LinhCanData.TYPES[self.type].tu_vi_mult or 1.0
end

function PnLinhCan:GetPrimaryElement()
    return self.elements and self.elements[1] or nil
end

function PnLinhCan:GetDisplay()
    if not self.type then return "?" end
    if self.bien_di_tag then
        for _, c in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if c.tag == self.bien_di_tag then return c.display end
        end
    end
    return LinhCanData.TYPES[self.type].display
end

function PnLinhCan:GetElementDisplay()
    if not self.elements then return "" end
    local out = {}
    for _, e in ipairs(self.elements) do table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e) end
    return table.concat(out, "/")
end

function PnLinhCan:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_linhcan) then return end
    self.inst.replica.pn_linhcan:SetType(self.type or "")
    self.inst.replica.pn_linhcan:SetElements(table.concat(self.elements or {}, ","))
    self.inst.replica.pn_linhcan:SetBienDiTag(self.bien_di_tag or "")
end

function PnLinhCan:OnSave()
    return { type=self.type, elements=self.elements, bien_di_tag=self.bien_di_tag, rolled=self.rolled }
end

function PnLinhCan:OnLoad(data)
    if not data then return end
    self.type, self.elements, self.bien_di_tag, self.rolled =
        data.type, data.elements, data.bien_di_tag, data.rolled or false
    self:_PushToReplica()
end

return PnLinhCan
```

- [ ] **Step 2: Write `scripts/components/pn_linhcan_replica.lua`**

```lua
local LinhCanData = require("pn/linhcan_data")

local Replica = Class(function(self, inst)
    self.inst = inst
    self.type_net     = net_string(inst.GUID, "pn_linhcan.type", "pn_linhcan_dirty")
    self.elements_net = net_string(inst.GUID, "pn_linhcan.elements", "pn_linhcan_dirty")
    self.tag_net      = net_string(inst.GUID, "pn_linhcan.tag", "pn_linhcan_dirty")
end)

function Replica:SetType(v)      self.type_net:set(v or "") end
function Replica:SetElements(v)  self.elements_net:set(v or "") end
function Replica:SetBienDiTag(v) self.tag_net:set(v or "") end
function Replica:GetType()      return self.type_net:value() end
function Replica:GetElements()  return self.elements_net:value() end
function Replica:GetBienDiTag() return self.tag_net:value() end

function Replica:HasData() return self:GetType() ~= "" end

function Replica:GetPrimaryElement()
    local raw = self:GetElements()
    return raw ~= "" and string.match(raw, "[^,]+") or nil
end

function Replica:GetDisplay()
    local t, tag = self:GetType(), self:GetBienDiTag()
    if t == "" then return "?" end
    if tag ~= "" then
        for _, c in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if c.tag == tag then return c.display end
        end
    end
    return LinhCanData.TYPES[t] and LinhCanData.TYPES[t].display or "?"
end

function Replica:GetElementDisplay()
    local raw = self:GetElements()
    if raw == "" then return "" end
    local out = {}
    for e in string.gmatch(raw, "[^,]+") do table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e) end
    return table.concat(out, "/")
end

return Replica
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_linhcan.lua scripts/components/pn_linhcan_replica.lua
git commit -m "feat(pn): pn_linhcan component + replica (weighted roll, ≤+30% mult, affinity-focused)"
```

---

## Task 5: pn_tuvi component + replica

**Files:**
- Create: `scripts/components/pn_tuvi.lua`, `scripts/components/pn_tuvi_replica.lua`

- [ ] **Step 1: Write `scripts/components/pn_tuvi.lua`**

```lua
local Events = require("pn/events")
local Realms = require("pn/realms")

local PnTuVi = Class(function(self, inst)
    self.inst = inst
    self.current = 0
    self.cap = Realms.GetThreshold(1)
    if inst then
        inst:ListenForEvent(Events.TUVI_GAIN, function(_, d) self:_OnGain(d) end)
        inst:DoTaskInTime(0, function() self:_PushToReplica() end)
    end
end)

function PnTuVi:_OnGain(data)
    if not data or not data.amount then return end
    local amount = data.amount
    if self.inst.components.pn_linhcan then
        amount = amount * self.inst.components.pn_linhcan:GetTuViMult()
    end
    local old = self.current
    self.current = math.min(self.current + amount, self.cap)
    if self.current ~= old then
        self:_PushToReplica()
        self.inst:PushEvent(Events.TUVI_CHANGED, { new_value=self.current, old_value=old, cap=self.cap })
    end
end

function PnTuVi:SetCapForTier(tier) self.cap = Realms.GetThreshold(tier); self:_PushToReplica() end
function PnTuVi:ConsumeForBreakthrough(amount) self.current = math.max(0, self.current - amount); self:_PushToReplica() end
function PnTuVi:Get() return self.current end
function PnTuVi:GetCap() return self.cap end

function PnTuVi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_tuvi) then return end
    self.inst.replica.pn_tuvi:SetCurrent(self.current)
    self.inst.replica.pn_tuvi:SetCap(self.cap)
end

function PnTuVi:OnSave() return { current=self.current, cap=self.cap } end
function PnTuVi:OnLoad(data)
    if not data then return end
    self.current = data.current or 0
    self.cap = data.cap or Realms.GetThreshold(1)
    self:_PushToReplica()
end

return PnTuVi
```

- [ ] **Step 2: Write `scripts/components/pn_tuvi_replica.lua`**

```lua
local Replica = Class(function(self, inst)
    self.inst = inst
    self.current_net = net_float(inst.GUID, "pn_tuvi.current", "pn_tuvi_dirty")
    self.cap_net     = net_float(inst.GUID, "pn_tuvi.cap", "pn_tuvi_dirty")
end)

function Replica:SetCurrent(v) self.current_net:set(v or 0) end
function Replica:SetCap(v)     self.cap_net:set(v or 1) end
function Replica:GetCurrent()  return self.current_net:value() end
function Replica:GetCap()      return self.cap_net:value() end
function Replica:GetPercent()
    local cap = self:GetCap()
    return cap > 0 and math.min(1, self:GetCurrent()/cap) or 0
end
function Replica:HasData() return self:GetCap() > 0 end

return Replica
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_tuvi.lua scripts/components/pn_tuvi_replica.lua
git commit -m "feat(pn): pn_tuvi component + replica (capped accumulator, linhcan mult)"
```

---

## Task 6: pn_canhgioi component + replica

**Files:**
- Create: `scripts/components/pn_canhgioi.lua`, `scripts/components/pn_canhgioi_replica.lua`

**Before writing:** read api-foundation §3 + pitfall #4 (locomotor `SetExternalSpeedMultiplier`).

- [ ] **Step 1: Write `scripts/components/pn_canhgioi.lua`**

```lua
local Events = require("pn/events")
local Realms = require("pn/realms")
local config = require("pn/config")

local PnCanhGioi = Class(function(self, inst)
    self.inst = inst
    self.tier = 0
    if inst then
        inst:ListenForEvent(Events.CANHGIOI_UP, function(_, d) self:_OnUp(d) end)
        inst:DoTaskInTime(0, function() self:_PushToReplica() end)
    end
end)

function PnCanhGioi:_OnUp(data)
    if not data or not data.new_tier or data.new_tier <= self.tier then return end
    local old = self.tier
    self.tier = data.new_tier
    self:_ApplyStatDelta(old, self.tier)
    self:_PushToReplica()
end

function PnCanhGioi:_ApplyStatDelta(old_tier, new_tier)
    local d = new_tier - old_tier
    if d <= 0 or not self.inst then return end
    local s = config.STATS_PER_LAYER
    if self.inst.components.health then
        self.inst.components.health:SetMaxHealth(self.inst.components.health.maxhealth + s.HP_BONUS * d)
    end
    if self.inst.components.combat then
        self.inst.components.combat.damagemultiplier =
            (self.inst.components.combat.damagemultiplier or 1) + s.DMG_MULT_DELTA * d
    end
    if self.inst.components.hunger then
        self.inst.components.hunger.hungerrate =
            self.inst.components.hunger.hungerrate * (1 + s.HUNGER_MULT_DELTA * d)
    end
    if self.inst.components.locomotor then
        local cur = self.inst.components.locomotor:GetExternalSpeedMultiplier(self.inst, "pn_canhgioi") or 1.0
        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "pn_canhgioi", cur + s.SPEED_MULT_DELTA * d)
    end
end

function PnCanhGioi:GetTier() return self.tier end
function PnCanhGioi:GetDisplay() return Realms.GetDisplay(self.tier) end

function PnCanhGioi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_canhgioi) then return end
    self.inst.replica.pn_canhgioi:SetTier(self.tier)
end

function PnCanhGioi:OnSave() return { tier=self.tier } end
function PnCanhGioi:OnLoad(data)
    if not data then return end
    self.tier = data.tier or 0  -- stats already baked into the save; do NOT re-apply
    self:_PushToReplica()
end

return PnCanhGioi
```

- [ ] **Step 2: Write `scripts/components/pn_canhgioi_replica.lua`**

```lua
local Realms = require("pn/realms")

local Replica = Class(function(self, inst)
    self.inst = inst
    self.tier_net = net_tinybyte(inst.GUID, "pn_canhgioi.tier", "pn_canhgioi_dirty")
end)

function Replica:SetTier(v) self.tier_net:set(v or 0) end
function Replica:GetTier()  return self.tier_net:value() end
function Replica:GetDisplay() return Realms.GetDisplay(self:GetTier()) end
function Replica:GetColor()   return Realms.GetColor(self:GetTier()) end

return Replica
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_canhgioi.lua scripts/components/pn_canhgioi_replica.lua
git commit -m "feat(pn): pn_canhgioi component + replica (tier tracker + strong stat deltas)"
```

---

## Task 7: pn_breakthrough component (server-only)

**Files:**
- Create: `scripts/components/pn_breakthrough.lua`

- [ ] **Step 1: Write `scripts/components/pn_breakthrough.lua`**

```lua
local Events = require("pn/events")
local Realms = require("pn/realms")

local PnBreakthrough = Class(function(self, inst)
    self.inst = inst
    if inst then
        inst:ListenForEvent(Events.TUVI_CHANGED, function(_, d) self:_OnChanged(d) end)
    end
end)

function PnBreakthrough:_OnChanged(data)
    if not data or data.new_value < data.cap then return end
    self:TryBreakthrough()
end

function PnBreakthrough:TryBreakthrough()
    local cg = self.inst.components.pn_canhgioi
    local tv = self.inst.components.pn_tuvi
    if not (cg and tv) then return end
    local cur = cg:GetTier()
    if cur >= Realms.GetMaxTier() then return end
    local next_tier = cur + 1
    local cost = Realms.GetThreshold(next_tier)
    -- M1: auto-pass (Luyện Khí has no tribulation in canon)
    self.inst:PushEvent(Events.CANHGIOI_UP, { new_tier=next_tier, old_tier=cur })
    tv:ConsumeForBreakthrough(cost)
    tv:SetCapForTier(math.min(next_tier + 1, Realms.GetMaxTier()))
end

function PnBreakthrough:OnSave() return {} end
function PnBreakthrough:OnLoad() end

return PnBreakthrough
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_breakthrough.lua
git commit -m "feat(pn): pn_breakthrough orchestrator (auto-pass for Luyện Khí)"
```

---

## Task 8: Recover assets into the repo + main/assets.lua + main/strings.lua

**Files:**
- Create: `images/pn_ui.{tex,xml}`, `anim/phamnhan.zip`, `anim/ghost_phamnhan_build.zip`, portrait set, `modicon.{tex,xml}`, `scripts/speech_phamnhan.lua`, `scripts/main/assets.lua`, `scripts/main/strings.lua`

- [ ] **Step 1: Copy recovered assets from /tmp/pn_recover into the repo**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
mkdir -p images/inventoryimages images/saveslot_portraits images/map_icons images/avatars bigportraits anim scripts
cp /tmp/pn_recover/images/pn_ui.tex images/ ; cp /tmp/pn_recover/images/pn_ui.xml images/
cp /tmp/pn_recover/anim/phamnhan.zip anim/ ; cp /tmp/pn_recover/anim/ghost_phamnhan_build.zip anim/
cp /tmp/pn_recover/modicon.tex . ; cp /tmp/pn_recover/modicon.xml .
cp /tmp/pn_recover/images/saveslot_portraits/phamnhan.* images/saveslot_portraits/
cp /tmp/pn_recover/bigportraits/phamnhan.* bigportraits/
cp /tmp/pn_recover/images/map_icons/phamnhan.* images/map_icons/
cp /tmp/pn_recover/images/avatars/avatar_phamnhan.* images/avatars/
cp /tmp/pn_recover/images/avatars/avatar_ghost_phamnhan.* images/avatars/
cp /tmp/pn_recover/images/names_phamnhan.* images/
cp /tmp/pn_recover/scripts/speech_phamnhan.lua scripts/
ls anim/ images/*.tex images/saveslot_portraits/ bigportraits/
```
Expected: all asset files present. If `/tmp/pn_recover` is incomplete, recover the missing ones with `git show mvp1-archive:<path> > <path>` (text/binary safe) per file.

- [ ] **Step 2: Write `scripts/main/assets.lua`**

```lua
PrefabFiles = {
    "phamnhan",
}

Assets = {
    Asset("ATLAS", "images/pn_ui.xml"),
    Asset("IMAGE", "images/pn_ui.tex"),

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
```

- [ ] **Step 3: Write `scripts/main/strings.lua`**

```lua
STRINGS.CHARACTER_TITLES.phamnhan       = "Phàm Nhân"
STRINGS.CHARACTER_NAMES.phamnhan        = "Phàm Nhân"
STRINGS.CHARACTER_DESCRIPTIONS.phamnhan = "Một phàm nhân bình thường, mơ ước con đường tu tiên."
STRINGS.CHARACTER_QUOTES.phamnhan       = "\"Tu đạo chi lộ, nghịch thiên mà hành.\""
```

- [ ] **Step 4: Syntax + asset check + commit**

```bash
./tools/check_syntax.sh
./tools/check_assets.py
git add images anim bigportraits modicon.tex modicon.xml scripts/speech_phamnhan.lua scripts/main/assets.lua scripts/main/strings.lua
git commit -m "feat(remake): recover UI/character assets + main/assets + main/strings"
```

---

## Task 9: phamnhan prefab + main/character.lua + main/components.lua

**Files:**
- Create: `scripts/prefabs/phamnhan.lua`, `scripts/main/character.lua`, `scripts/main/components.lua`

**Before writing:** read api-foundation §2 (MakePlayerCharacter arg order; common vs master postinit; build name == prefab name) + pitfall #6/#8.

- [ ] **Step 1: Write `scripts/prefabs/phamnhan.lua`**

```lua
local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
    Asset("ANIM", "anim/phamnhan.zip"),
    Asset("ANIM", "anim/ghost_phamnhan_build.zip"),
}
local prefabs = {}
local start_inv = {}

local function common_postinit(inst)
    inst:AddTag("phamnhan")
    -- Build name == prefab name == "phamnhan" (baked into anim/phamnhan.zip).
    inst.AnimState:SetBuild("phamnhan")
end

local function master_postinit(inst)
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_breakthrough")

    inst:DoTaskInTime(0, function()
        if inst.components.pn_linhcan and not inst.components.pn_linhcan.rolled then
            inst.components.pn_linhcan:RollNew()
            print(string.format("[PN] %s linh căn: %s [%s]",
                tostring(inst.userid or "?"),
                inst.components.pn_linhcan:GetDisplay(),
                inst.components.pn_linhcan:GetElementDisplay()))
        end
    end)

    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)
    inst.components.combat.damagemultiplier = 1.0
    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE
end

return MakePlayerCharacter("phamnhan", prefabs, assets, common_postinit, master_postinit, start_inv)
```

- [ ] **Step 2: Write `scripts/main/character.lua`**

```lua
AddModCharacter("phamnhan", "MALE")

-- Only "Phàm Nhân" is selectable.
local VANILLA = {
    "wilson","willow","wendy","wolfgang","wx78","wickerbottom","woodie","wes",
    "waxwell","wathgrithr","webber","winona","warly","wormwood","wortox","wurt",
    "walter","wanda",
}
for _, c in ipairs(VANILLA) do RemoveDefaultCharacter(c) end
```

- [ ] **Step 3: Write `scripts/main/components.lua`**

```lua
AddReplicableComponent("pn_linhcan")
AddReplicableComponent("pn_tuvi")
AddReplicableComponent("pn_canhgioi")
-- pn_breakthrough is server-only (no replica).
```

- [ ] **Step 4: Syntax + asset check + commit**

```bash
./tools/check_syntax.sh
./tools/check_assets.py
git add scripts/prefabs/phamnhan.lua scripts/main/character.lua scripts/main/components.lua
git commit -m "feat(remake): phamnhan prefab + character registration + replica registration"
```

---

## Task 10: main/mob_hooks.lua (tu vi from kills + monster buff)

**Files:**
- Create: `scripts/main/mob_hooks.lua`

**Before writing:** read api-foundation §7 (events: "death", combat.lastattacker) + pitfall #1 (in main/* the GLOBAL wrapper IS available since it's modimported; use GLOBAL.* for engine refs here, unlike component files).

- [ ] **Step 1: Write `scripts/main/mob_hooks.lua`**

```lua
-- Grant tu vi to a phàm nhân who kills a monster, and buff monster stats so the
-- world stays dangerous as players grow. Runs in modmain env → GLOBAL available.
local config = GLOBAL.require("pn/config")
local Events = GLOBAL.require("pn/events")

local function PatchMob(prefab_name)
    AddPrefabPostInit(prefab_name, function(inst)
        if not GLOBAL.TheWorld.ismastersim then return end

        -- Flat stat buff (M1 static; dynamic scaling = world-scaling milestone)
        if inst.components.health then
            local m = config.MOB_BUFF.hp_mult
            inst.components.health:SetMaxHealth(inst.components.health.maxhealth * m)
            inst.components.health:SetPercent(1)
        end
        if inst.components.combat then
            inst.components.combat.damagemultiplier =
                (inst.components.combat.damagemultiplier or 1) * config.MOB_BUFF.dmg_mult
        end

        -- Grant tu vi to the killer
        inst:ListenForEvent("death", function()
            local killer = inst.components.combat and inst.components.combat.lastattacker
            if not (killer and killer:HasTag("phamnhan")) then return end
            local amount = config.TUVI_PER_MOB[inst.prefab] or 5
            killer:PushEvent(Events.TUVI_GAIN, { amount=amount, source="kill_"..tostring(inst.prefab) })
        end)
    end)
end

for _, name in ipairs(config.MOBS_TO_PATCH) do PatchMob(name) end
print(string.format("[PN] patched %d mob prefabs for tu vi + buff", #config.MOBS_TO_PATCH))
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/main/mob_hooks.lua
git commit -m "feat(remake): mob_hooks — tu vi on kill + flat monster buff"
```

---

## Task 11: HUD widget + main/widgets.lua

**Files:**
- Create: `scripts/widgets/pn_hud_dantian.lua`, `scripts/main/widgets.lua`

**Before writing:** read api-foundation §9 (widgets; AddClassPostConstruct; top_root; reading player.replica). Keep medallion at native aspect (186:206) — do NOT distort.

- [ ] **Step 1: Write `scripts/widgets/pn_hud_dantian.lua`**

```lua
local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")
local LinhCanData = require("pn/linhcan_data")

local ATLAS = "images/pn_ui.xml"
local FONT = CHATFONT

-- Medallion native aspect 186:206 ≈ 0.903. Pick a height, derive width to keep ratio.
local MED_H = 64
local MED_W = math.floor(MED_H * 186 / 206)  -- ≈ 57

local SAVE_KEY = "pn_hud_position"

local function LoadPos(cb)
    TheSim:GetPersistentString(SAVE_KEY, function(ok, data)
        if ok and data and data ~= "" then
            local x,y = string.match(data, "([%-%d%.]+),([%-%d%.]+)")
            if x and y then cb(tonumber(x), tonumber(y)) end
        end
    end)
end
local function SavePos(x,y) TheSim:SetPersistentString(SAVE_KEY, string.format("%.1f,%.1f", x, y), false) end

local PnHud = Class(Widget, function(self, owner)
    Widget._ctor(self, "PnHudDantian")
    self.owner = owner

    self.medallion = self:AddChild(Image(ATLAS, LinhCanData.DEFAULT_MEDALLION))
    self.medallion:SetSize(MED_W, MED_H)
    self.medallion:SetClickable(true)
    self._cur = LinhCanData.DEFAULT_MEDALLION

    self.tuvi_text = self:AddChild(Text(FONT, 11, ""))
    self.tuvi_text:SetPosition(0, -(MED_H/2) - 6)
    self.canhgioi_text = self:AddChild(Text(FONT, 15, ""))
    self.canhgioi_text:SetPosition(0, -(MED_H/2) - 22)

    self._dragging = false
    LoadPos(function(x,y) if self.inst and self.inst:IsValid() then self:SetPosition(x,y) end end)
    self:StartUpdating()
end)

function PnHud:OnMouseButton(button, down)
    if button ~= MOUSEBUTTON_RIGHT then return false end
    if down then
        self._dragging = true
        local mx,my = TheInput:GetScreenPosition():Get()
        self._m0 = {x=mx,y=my}; local p=self:GetPosition(); self._w0={x=p.x,y=p.y}
        return true
    elseif self._dragging then
        self._dragging = false; local p=self:GetPosition(); SavePos(p.x,p.y); return true
    end
    return false
end

local function PickMedallion(lc)
    if not (lc and lc:HasData()) then return LinhCanData.DEFAULT_MEDALLION end
    local el = lc:GetPrimaryElement()
    return LinhCanData.ELEMENT_MEDALLION[el or ""] or LinhCanData.DEFAULT_MEDALLION
end

function PnHud:OnUpdate()
    if self._dragging then
        if not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
            self._dragging=false; local p=self:GetPosition(); SavePos(p.x,p.y)
        else
            local mx,my = TheInput:GetScreenPosition():Get()
            self:SetPosition(self._w0.x+(mx-self._m0.x), self._w0.y+(my-self._m0.y))
        end
    end
    local p = self.owner
    if not (p and p.replica) then return end
    local lc, tv, cg = p.replica.pn_linhcan, p.replica.pn_tuvi, p.replica.pn_canhgioi

    local want = PickMedallion(lc)
    if want ~= self._cur then self.medallion:SetTexture(ATLAS, want); self._cur = want end

    if cg then
        local d = cg:GetDisplay(); if d=="" then d="Phàm Nhân" end
        self.canhgioi_text:SetString(d)
        local c = cg:GetColor(); if c then self.canhgioi_text:SetColour(c[1],c[2],c[3],c[4]) end
    else
        self.canhgioi_text:SetString("Phàm Nhân")
    end

    if tv and tv:HasData() then
        self.tuvi_text:SetString(string.format("%d/%d", math.floor(tv:GetCurrent()), math.floor(tv:GetCap())))
    else
        self.tuvi_text:SetString("")
    end
end

return PnHud
```

- [ ] **Step 2: Write `scripts/main/widgets.lua`**

```lua
AddClassPostConstruct("widgets/controls", function(self)
    local PnHud = require("widgets/pn_hud_dantian")
    self.pn_hud = self.top_root:AddChild(PnHud(self.owner))
    self.pn_hud:SetPosition(-560, -90)
end)
```

- [ ] **Step 3: Syntax + asset check + commit**

```bash
./tools/check_syntax.sh
./tools/check_assets.py
git add scripts/widgets/pn_hud_dantian.lua scripts/main/widgets.lua
git commit -m "feat(remake): đan điền HUD (native-aspect medallion) + attach to controls"
```

---

## Task 12: main/debug.lua

**Files:**
- Create: `scripts/main/debug.lua`

- [ ] **Step 1: Write `scripts/main/debug.lua`**

```lua
local Events = GLOBAL.require("pn/events")
local LinhCanData = GLOBAL.require("pn/linhcan_data")
local Realms = GLOBAL.require("pn/realms")

function GLOBAL.c_addtuvi(amount, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    player:PushEvent(Events.TUVI_GAIN, { amount=amount or 100, source="debug" })
    print("[PN] +"..tostring(amount or 100).." tu vi (raw)")
end

function GLOBAL.c_settier(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not (player and player.components.pn_canhgioi) then return end
    local cur = player.components.pn_canhgioi:GetTier()
    for t = cur+1, tier do
        player:PushEvent(Events.CANHGIOI_UP, { new_tier=t, old_tier=t-1 })
    end
    if player.components.pn_tuvi then
        player.components.pn_tuvi:SetCapForTier(math.min(tier+1, Realms.GetMaxTier()))
    end
    print("[PN] set tier → "..tostring(tier))
end

function GLOBAL.c_setlinhcan(t, elements, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    local lc = player and player.components.pn_linhcan
    if not lc or not LinhCanData.TYPES[t] then print("[PN] valid: NGUY/CHAN/BIEN_DI/THIEN") return end
    lc.type, lc.elements, lc.bien_di_tag, lc.rolled = t, elements or {"KIM"}, nil, true
    lc:_PushToReplica()
    print("[PN] linh căn = "..lc:GetDisplay().." ["..lc:GetElementDisplay().."]")
end

function GLOBAL.c_pnstate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local lc, tv, cg = player.components.pn_linhcan, player.components.pn_tuvi, player.components.pn_canhgioi
    print("===== PN state =====")
    if lc then print(string.format("  Linh căn: %s [%s] mult=%.2f", lc:GetDisplay(), lc:GetElementDisplay(), lc:GetTuViMult())) end
    if cg then print(string.format("  Cảnh giới: %s (tier %d)", cg:GetDisplay(), cg:GetTier())) end
    if tv then print(string.format("  Tu vi: %d/%d", tv:Get(), tv:GetCap())) end
end

print("[PN] debug loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/main/debug.lua
git commit -m "feat(remake): debug console commands"
```

---

## Task 13: Integration — sync local + in-game verification

**Files:** none (verification)

- [ ] **Step 1: Static checks all pass**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
```
Expected: both green.

- [ ] **Step 2: Sync to local DST**

```bash
./tools/sync_local.sh
```
Expected: copies a real folder into Contents/mods/pham-nhan-tu-tien.

- [ ] **Step 3: USER in-game verification (manual; ask the user to run it)**

Tell the user: quit DST fully (Cmd+Q), relaunch, Mods → Server Mods → enable "Phàm Nhân Tu Tiên [Alpha]", Host Game. Verify:
1. Character select shows ONLY Phàm Nhân.
2. Spawn → HUD đan điền shows in top-left: a medallion + "0/80" + "Phàm Nhân".
3. Console (`~`): `c_pnstate()` prints a random linh căn + tier 0 + tu vi.
4. Kill spiders/mobs → tu vi rises (check HUD number climbs).
5. `c_addtuvi(200)` → breakthrough to Luyện Khí tầng 1 → HUD updates → HP max rises (check with `c_pnstate` and the health badge).
6. `c_settier(13)` → "Luyện Khí tầng 13", HP ~256, damage strong; nearby buffed mobs are tougher than vanilla.
7. Night with no light → still die (vanilla intact). Die + revive (touchstone) → cảnh giới persists.

If any Lua error appears, capture it from `~/Documents/Klei/DoNotStarveTogether/client_log.txt` and the Cluster_1/Master/server_log.txt, and fix before tagging.

- [ ] **Step 4: Tag milestone complete (after user confirms in-game)**

```bash
git tag -a remake-m1-complete -m "Remake M1 — Cultivation Core complete.

Bootstrap-layer architecture, data-driven realm ladder (Luyện Khí 13 layers),
linh căn (≤+30% mult), tu vi from monster kills only, strong per-layer stats +
monster buff, đan điền HUD (Dengxian art, native aspect), no lifespan (vanilla
intact). Verified in-game."
git tag --list | grep remake
```

---

## Self-review

**Spec coverage:**
- §2 architecture (bootstrap layer, data-driven realm, pitfall compliance) → Tasks 2,3,9,10 ✓
- §3 linh căn → Task 4 ✓
- §4 tu vi + mob kills → Tasks 5,10 ✓
- §5 cảnh giới + breakthrough + stats → Tasks 6,7 ✓
- §6 HUD → Task 11 ✓
- §7 prefab → Task 9 ✓
- §8 vanilla intact → verified Task 13 step 3.7 (no lifespan component exists; nothing disables vanilla) ✓
- §9 testing → Tasks use check_syntax/check_assets each commit; Task 13 sync+in-game ✓
- §12 known-unknowns: build name (Task 9 uses recovered "phamnhan" build), TUVI_PER_MOB starting values (Task 3), scaffold (Task 2) ✓

**Placeholder scan:** No TBD/TODO. TUVI_PER_MOB / MOB_BUFF are concrete starting values (spec-sanctioned tunables), not placeholders. Asset recovery has a documented fallback. ✓

**Type consistency:** Event names from events.lua used consistently (TUVI_GAIN/TUVI_CHANGED/CANHGIOI_UP). Component method names match across components ↔ replicas ↔ HUD ↔ debug (GetTuViMult, GetPrimaryElement, GetDisplay, GetTier, Get/GetCap/GetPercent, SetCapForTier, ConsumeForBreakthrough). Realms API (GetThreshold/GetMaxTier/GetDisplay/GetColor) consistent. `main/*` files use `GLOBAL.require`; `components/*` + `widgets/*` use bare `require` (correct per env). ✓

---

**End of Remake M1 plan.**

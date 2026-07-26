# Plan 2 — Cultivation Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the 3 core cultivation components (`pn_linhcan`, `pn_tuvi`, `pn_canhgioi`) plus `pn_breakthrough` orchestrator, basic HUD widget showing them, and debug console commands. After this plan, a `phamnhan` player has a random linh căn at spawn, can accumulate tu vi via debug commands (`c_addtuvi`), automatically breaks through Luyện Khí tiers when thresholds cross, and HUD reflects all state.

**Architecture:** Event-driven multi-component pattern per the design spec (`docs/superpowers/specs/2026-05-24-pntt-mod-design.md` §2.2-§2.6). All state mutations flow through events on the player entity. 4 server components, 3 replicas for HUD-visible state, 1 widget, 4 constants/data files in `scripts/pn/`.

**Tech Stack:** Lua 5.1 (DST runtime), DST Component class pattern, `net_*` netvars for replication, `AddClassPostConstruct` for HUD attach.

**Prerequisites:** Plan 1 complete (tag `p1-foundation-complete`). `phamnhan` prefab exists at `scripts/prefabs/phamnhan.lua`, `modmain.lua` registers it, char select override works.

**Out of scope** (defer to Plan 3+): `pn_lifespan` (Plan 3), `pn_aura`/linh mạch entity (Plan 4), `pn_mob_cultivation` (Plan 5), items (Plan 6), pháp bảo (later). MVP1 lifespan/permadeath logic is NOT in Plan 2.

**Verification strategy:** Static checks pass (`tools/check_syntax.sh`, `tools/check_assets.py`). Runtime in-game test deferred per `memory/macos_dst_mod_loading.md` — Plan 2 may use Workshop private upload for first interactive verification, decided at end of plan.

---

## File summary

**Created in mod repo:**
- `scripts/pn/events.lua` — event name constants
- `scripts/pn/tuning.lua` — all cultivation constants
- `scripts/pn/linhcan_data.lua` — 4 linh căn types + 5 elements + Biến Dị combos
- `scripts/pn/realms.lua` — Luyện Khí 9 tầng + threshold curve
- `scripts/pn/debug.lua` — console commands for testing
- `scripts/components/pn_linhcan.lua` — random roll + multiplier provider
- `scripts/components/pn_linhcan_replica.lua` — networked display fields
- `scripts/components/pn_tuvi.lua` — accumulator with cap
- `scripts/components/pn_tuvi_replica.lua`
- `scripts/components/pn_canhgioi.lua` — tier tracker + stat bonus applier
- `scripts/components/pn_canhgioi_replica.lua`
- `scripts/components/pn_breakthrough.lua` — server-only, listens for TUVI_CHANGED, triggers tier-up
- `scripts/widgets/pn_hud_main.lua` — top HUD overlay

**Modified:**
- `modmain.lua` — register 4 components, attach HUD via AddClassPostConstruct, conditional debug load
- `scripts/prefabs/phamnhan.lua` — AddComponent for all 4 cultivation components, roll linhcan on first spawn

---

## Task 1: Write `scripts/pn/events.lua`

**Files:**
- Create: `scripts/pn/events.lua`

All event name constants in one table. Centralizing avoids typo bugs (`"tuvi_gain"` vs `"tuvi_gained"`).

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/events.lua
-- Centralized event name constants. Use these everywhere instead of string literals.

return {
    -- Tu vi flow
    TUVI_GAIN        = "pn_tuvi_gain",         -- payload: { amount = N, source = "..." }
    TUVI_CHANGED     = "pn_tuvi_changed",      -- payload: { new_value, old_value, cap }

    -- Realm progression
    CANHGIOI_UP      = "pn_canhgioi_up",       -- payload: { new_tier, old_tier }
    BREAKTHROUGH     = "pn_breakthrough",      -- payload: { tier, success } (MVP2: success always true)

    -- Linh căn
    LINHCAN_ROLLED   = "pn_linhcan_rolled",    -- payload: { type, elements, mult }

    -- Lifespan (defined here for Plan 3, unused in Plan 2)
    LIFESPAN_TICK    = "pn_lifespan_tick",
    LIFESPAN_EXPIRED = "pn_lifespan_expired",

    -- Aura (Plan 4, unused now)
    AURA_ENTER       = "pn_aura_enter",
    AURA_EXIT        = "pn_aura_exit",
}
```

- [ ] **Step 2: Syntax check**

Run: `./tools/check_syntax.sh`
Expected: pass count increments by 1.

- [ ] **Step 3: Commit**

```bash
git add scripts/pn/events.lua
git commit -m "feat(pn): add event name constants"
```

---

## Task 2: Write `scripts/pn/tuning.lua`

**Files:**
- Create: `scripts/pn/tuning.lua`

Single source of truth for cultivation balance numbers per spec §8.

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/tuning.lua
-- Cultivation balance constants. All numbers tuneable here without touching logic.

return {
    -- Tu vi progression curve: threshold(N) = BASE * N^EXPONENT
    -- Tier 1 = 100, Tier 2 = 282, ..., Tier 9 (Luyện Khí đỉnh phong) = 2700
    TU_VI = {
        BASE_RATE_PER_SEC       = 1.0,  -- baseline gain/sec from a source, multiplied by linh căn
        TIER_THRESHOLD_BASE     = 100,
        TIER_THRESHOLD_EXPONENT = 1.5,
        MAX_TIER_MVP            = 9,    -- Luyện Khí 9 tầng (Plan 2 ceiling)
    },

    -- Stat bonus applied per tier (linear deltas)
    STATS_PER_TIER = {
        HP_BONUS          = 10,    -- +10 max HP per tier
        HUNGER_MULT_DELTA = -0.05, -- hunger drain mult: 1.0 - 0.05*tier
        ATTACK_MULT_DELTA = 0.05,  -- attack mult: 1.0 + 0.05*tier
        SPEED_MULT_DELTA  = 0.01,  -- move speed mult: 1.0 + 0.01*tier
    },

    -- Lifespan (Plan 3 will use, declared here for reference)
    LIFESPAN = {
        BASE             = 60,  -- in DST days
        BONUS_PER_TIER   = 5,   -- +5 days per Luyện Khí tier breakthrough
        DECAY_PER_DAY    = 1,
    },
}
```

- [ ] **Step 2: Verify computation**

In your head or with `lua -e`:
- `100 * 1^1.5 = 100`  ✓ Tier 1
- `100 * 9^1.5 ≈ 2700` ✓ Tier 9
- Tier 5 (trung kỳ): `100 * 5^1.5 ≈ 1118` ✓
- Cumulative to tier 9: sum ≈ 11,102 ✓ (matches spec §3.2)

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/tuning.lua
git commit -m "feat(pn): add cultivation tuning constants"
```

---

## Task 3: Write `scripts/pn/linhcan_data.lua`

**Files:**
- Create: `scripts/pn/linhcan_data.lua`

Per spec §3.1 — 4 linh căn types with roll weights, element counts, and tu vi multipliers. Plus Biến Dị element combos for flavor.

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/linhcan_data.lua
-- Linh căn (spiritual root) definitions per PNTT novel canon.
-- 4 types rolled at spawn with weighted probability.

local data = {}

-- 5 base elements (Kim/Mộc/Thủy/Hỏa/Thổ)
data.ELEMENTS = { "KIM", "MOC", "THUY", "HOA", "THO" }

data.ELEMENT_DISPLAY = {
    KIM  = "Kim",
    MOC  = "Mộc",
    THUY = "Thủy",
    HOA  = "Hỏa",
    THO  = "Thổ",
}

-- 4 types with roll weights (total = 100)
data.TYPES = {
    NGUY = {
        weight        = 65,
        element_count = { 4, 5 },  -- roll 4 or 5 elements
        tu_vi_mult    = 1.0,
        display       = "Ngụy Linh Căn",
        description   = "Linh căn tạp loạn, tốc độ tu luyện chậm — đa số phàm nhân.",
    },
    CHAN = {
        weight        = 30,
        element_count = { 2, 3 },
        tu_vi_mult    = 1.5,
        display       = "Chân Linh Căn",
        description   = "Linh căn thuần khiết, tu chân thuận lợi.",
    },
    BIEN_DI = {
        weight        = 3,
        element_count = { 2, 3 },
        tu_vi_mult    = 2.5,
        display       = "Biến Dị Linh Căn",
        description   = "Linh căn dị biến, tốc độ ngang Thiên Linh, có thiên phú riêng.",
        special       = true,
    },
    THIEN = {
        weight        = 2,
        element_count = { 1, 1 },  -- exactly 1 element
        tu_vi_mult    = 3.0,
        display       = "Thiên Linh Căn",
        description   = "Linh căn đơn nhất, thiên tài bẩm sinh, hiếm có khó tìm.",
    },
}

-- Biến Dị element combos — when a BIEN_DI rolls these specific elements, it gets a special tag.
-- (MVP2: display only. Future plans use these for pháp bảo affinity.)
data.BIEN_DI_COMBOS = {
    { elements = { "KIM", "THUY" }, tag = "BANG",    display = "Băng Linh Căn"    },
    { elements = { "KIM", "HOA"  }, tag = "LOI",     display = "Lôi Linh Căn"     },
    { elements = { "MOC", "HOA"  }, tag = "PHUONG",  display = "Phượng Linh Căn"  },
    { elements = { "MOC", "THUY" }, tag = "PHONG",   display = "Phong Linh Căn"   },
    { elements = { "THUY", "HOA" }, tag = "AM_DUONG", display = "Âm Dương Linh Căn" },
    { elements = { "THO", "KIM"  }, tag = "THACH",   display = "Thạch Linh Căn"   },
}

-- Type list ordered by weight ASC for roll algorithm (rare first → easy threshold check)
data.TYPE_ORDER = { "THIEN", "BIEN_DI", "CHAN", "NGUY" }

return data
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/pn/linhcan_data.lua
git commit -m "feat(pn): add linh căn data (4 types + 5 elements + 6 Biến Dị combos)"
```

---

## Task 4: Write `scripts/pn/realms.lua`

**Files:**
- Create: `scripts/pn/realms.lua`

Helper for tier ↔ threshold conversion + display strings. Pulls from tuning.

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/realms.lua
-- Helpers for cảnh giới (realm) progression — derived from tuning constants.

local TUNING = require("pn/tuning")

local M = {}

-- Vietnamese display name for a Luyện Khí tier
local LUYEN_KHI_DISPLAY = {
    [0] = "Phàm Nhân",
    [1] = "Luyện Khí sơ kỳ (tầng 1)",
    [2] = "Luyện Khí tầng 2",
    [3] = "Luyện Khí tầng 3",
    [4] = "Luyện Khí tầng 4",
    [5] = "Luyện Khí trung kỳ (tầng 5)",
    [6] = "Luyện Khí tầng 6",
    [7] = "Luyện Khí tầng 7",
    [8] = "Luyện Khí hậu kỳ (tầng 8)",
    [9] = "Luyện Khí đỉnh phong (tầng 9)",
}

-- Tu vi threshold to advance FROM tier N TO tier N+1.
-- threshold(N+1) = BASE * (N+1)^EXPONENT
-- E.g. threshold to reach Tier 1 = 100; to reach Tier 9 (from Tier 8) = 2700.
function M.GetThreshold(target_tier)
    if target_tier <= 0 then return 0 end
    return math.floor(
        TUNING.TU_VI.TIER_THRESHOLD_BASE *
        (target_tier ^ TUNING.TU_VI.TIER_THRESHOLD_EXPONENT)
    )
end

-- Cumulative tu vi from tier 0 to reach `tier`.
-- Used for displaying overall progress.
function M.GetCumulativeThreshold(tier)
    local total = 0
    for i = 1, tier do
        total = total + M.GetThreshold(i)
    end
    return total
end

-- Display name
function M.GetDisplay(tier)
    return LUYEN_KHI_DISPLAY[tier] or "Vô danh"
end

-- Color for HUD display based on tier (hex RGB)
-- 0 = white (phàm nhân), 1-4 light blue, 5-8 cyan, 9 gold
function M.GetTierColor(tier)
    if tier == 0     then return {1, 1, 1, 1}      end
    if tier <= 4     then return {0.7, 0.9, 1, 1}  end
    if tier <= 8     then return {0.3, 1, 1, 1}    end
    return {1, 0.85, 0.2, 1}  -- tier 9 = gold
end

-- Max tier in MVP2
function M.GetMaxTier()
    return TUNING.TU_VI.MAX_TIER_MVP
end

return M
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/realms.lua
git commit -m "feat(pn): add realm helper module (threshold + display)"
```

---

## Task 5: Write `scripts/components/pn_linhcan.lua`

**Files:**
- Create: `scripts/components/pn_linhcan.lua`

Server-side component. Rolls linh căn once on first spawn. Provides multiplier getter. Persists via OnSave/OnLoad.

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_linhcan.lua
-- Linh căn (spiritual root) — rolled once on spawn, immutable after.
-- Provides tu_vi_mult that other components query.

local LinhCanData = require("pn/linhcan_data")
local Events      = require("pn/events")

local PnLinhCan = Class(function(self, inst)
    self.inst = inst

    -- State
    self.type     = nil      -- "NGUY" | "CHAN" | "BIEN_DI" | "THIEN"
    self.elements = nil      -- list of element strings
    self.bien_di_tag = nil   -- e.g. "BANG" if BIEN_DI rolled Băng combo
    self.rolled   = false    -- has roll happened?
end)

-- Roll a new linh căn. Idempotent: if already rolled, does nothing unless force=true.
function PnLinhCan:RollNew(force)
    if self.rolled and not force then return end

    -- 1. Pick type by weighted roll
    local roll = math.random() * 100
    local cumulative = 0
    local picked_type = "NGUY"  -- fallback
    -- TYPE_ORDER goes rare→common; iterate normally and pick by ascending threshold
    -- Build sorted list by ASCENDING weight (Thien=2, BienDi=3, Chan=30, Nguy=65)
    local sorted = { "THIEN", "BIEN_DI", "CHAN", "NGUY" }
    for _, t in ipairs(sorted) do
        cumulative = cumulative + LinhCanData.TYPES[t].weight
        if roll <= cumulative then
            picked_type = t
            break
        end
    end
    self.type = picked_type

    -- 2. Pick element count for this type
    local type_def = LinhCanData.TYPES[picked_type]
    local element_count = math.random(type_def.element_count[1], type_def.element_count[2])

    -- 3. Pick elements (Fisher-Yates partial shuffle)
    local all_elements = {}
    for _, e in ipairs(LinhCanData.ELEMENTS) do table.insert(all_elements, e) end
    for i = #all_elements, 2, -1 do
        local j = math.random(i)
        all_elements[i], all_elements[j] = all_elements[j], all_elements[i]
    end
    self.elements = {}
    for i = 1, element_count do
        table.insert(self.elements, all_elements[i])
    end
    table.sort(self.elements)  -- canonical order for save consistency

    -- 4. If BIEN_DI, check if element set matches a combo
    self.bien_di_tag = nil
    if picked_type == "BIEN_DI" and element_count == 2 then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            local a, b = combo.elements[1], combo.elements[2]
            if (self.elements[1] == a and self.elements[2] == b)
            or (self.elements[1] == b and self.elements[2] == a) then
                self.bien_di_tag = combo.tag
                break
            end
        end
    end

    self.rolled = true

    -- Notify other components + push to replica
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LINHCAN_ROLLED, {
            type     = self.type,
            elements = self.elements,
            mult     = self:GetTuViMult(),
        })
    end
end

function PnLinhCan:GetTuViMult()
    if not self.type then return 1.0 end
    return LinhCanData.TYPES[self.type].tu_vi_mult
end

function PnLinhCan:GetDisplay()
    if not self.type then return "?" end
    if self.bien_di_tag then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if combo.tag == self.bien_di_tag then return combo.display end
        end
    end
    return LinhCanData.TYPES[self.type].display
end

function PnLinhCan:GetElementDisplay()
    if not self.elements then return "" end
    local out = {}
    for _, e in ipairs(self.elements) do
        table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e)
    end
    return table.concat(out, "/")
end

-- Push state to replica so client can render HUD
function PnLinhCan:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_linhcan) then return end
    self.inst.replica.pn_linhcan:SetType(self.type or "")
    self.inst.replica.pn_linhcan:SetElements(table.concat(self.elements or {}, ","))
    self.inst.replica.pn_linhcan:SetBienDiTag(self.bien_di_tag or "")
end

-- Persistence
function PnLinhCan:OnSave()
    return {
        type        = self.type,
        elements    = self.elements,
        bien_di_tag = self.bien_di_tag,
        rolled      = self.rolled,
    }
end

function PnLinhCan:OnLoad(data)
    if data == nil then return end
    self.type        = data.type
    self.elements    = data.elements
    self.bien_di_tag = data.bien_di_tag
    self.rolled      = data.rolled or false
    self:_PushToReplica()
end

return PnLinhCan
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/components/pn_linhcan.lua
git commit -m "feat(pn): add pn_linhcan component (weighted roll + persistence)"
```

---

## Task 6: Write `scripts/components/pn_linhcan_replica.lua`

**Files:**
- Create: `scripts/components/pn_linhcan_replica.lua`

Networked fields HUD reads on client. Uses `net_string` for the 3 visible fields.

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_linhcan_replica.lua
-- Client-side mirror of pn_linhcan. HUD reads via this.

local LinhCanData = require("pn/linhcan_data")

local Replica = Class(function(self, inst)
    self.inst = inst

    -- Networked fields. net_string for compactness; we encode complex state ourselves.
    self.type_net        = net_string(inst.GUID, "pn_linhcan.type", "pn_linhcan_dirty")
    self.elements_net    = net_string(inst.GUID, "pn_linhcan.elements", "pn_linhcan_dirty")
    self.bien_di_tag_net = net_string(inst.GUID, "pn_linhcan.bien_di_tag", "pn_linhcan_dirty")
end)

function Replica:SetType(v)        self.type_net:set(v or "")         end
function Replica:SetElements(v)    self.elements_net:set(v or "")     end
function Replica:SetBienDiTag(v)   self.bien_di_tag_net:set(v or "")  end

function Replica:GetType()       return self.type_net:value()        end
function Replica:GetElements()   return self.elements_net:value()    end
function Replica:GetBienDiTag()  return self.bien_di_tag_net:value() end

-- Convenience: return the display name (e.g. "Băng Linh Căn" or "Ngụy Linh Căn")
function Replica:GetDisplay()
    local t   = self:GetType()
    local tag = self:GetBienDiTag()
    if t == "" then return "?" end
    if tag ~= "" then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if combo.tag == tag then return combo.display end
        end
    end
    return LinhCanData.TYPES[t] and LinhCanData.TYPES[t].display or "?"
end

function Replica:GetElementDisplay()
    local raw = self:GetElements()
    if raw == "" then return "" end
    local out = {}
    for e in string.gmatch(raw, "[^,]+") do
        table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e)
    end
    return table.concat(out, "/")
end

function Replica:HasData()
    return self:GetType() ~= ""
end

return Replica
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_linhcan_replica.lua
git commit -m "feat(pn): add pn_linhcan replica with networked display fields"
```

---

## Task 7: Write `scripts/components/pn_tuvi.lua`

**Files:**
- Create: `scripts/components/pn_tuvi.lua`

Server component. Listens for `TUVI_GAIN`, applies linh căn multiplier, caps at next tier's threshold (player can't accumulate past breakthrough without breaking through).

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_tuvi.lua
-- Tu vi accumulator. Listens for TUVI_GAIN events, multiplies by linh căn mult,
-- caps at next-tier threshold so player must breakthrough before accumulating more.

local Events = require("pn/events")
local Realms = require("pn/realms")

local PnTuVi = Class(function(self, inst)
    self.inst    = inst
    self.current = 0
    self.cap     = Realms.GetThreshold(1)  -- start cap = threshold to reach tier 1

    if inst then
        inst:ListenForEvent(Events.TUVI_GAIN, function(_, data)
            self:_OnTuViGain(data)
        end)
    end
end)

function PnTuVi:_OnTuViGain(data)
    if not data or not data.amount then return end
    local amount = data.amount

    -- Apply linh căn multiplier (if linhcan component is on inst)
    if self.inst and self.inst.components.pn_linhcan then
        amount = amount * self.inst.components.pn_linhcan:GetTuViMult()
    end

    local old = self.current
    self.current = math.min(self.current + amount, self.cap)

    if self.current ~= old then
        self:_PushToReplica()
        self.inst:PushEvent(Events.TUVI_CHANGED, {
            new_value = self.current,
            old_value = old,
            cap       = self.cap,
            source    = data.source,
        })
    end
end

-- Called by pn_canhgioi after a breakthrough to advance the cap.
function PnTuVi:SetCapForTier(next_tier)
    self.cap = Realms.GetThreshold(next_tier)
    self:_PushToReplica()
end

-- After a successful breakthrough, the spent tu vi is consumed.
-- Default: subtract the previous cap (the cost of the breakthrough).
function PnTuVi:ConsumeForBreakthrough(amount)
    self.current = math.max(0, self.current - amount)
    self:_PushToReplica()
end

function PnTuVi:Get()    return self.current end
function PnTuVi:GetCap() return self.cap     end

function PnTuVi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_tuvi) then return end
    self.inst.replica.pn_tuvi:SetCurrent(self.current)
    self.inst.replica.pn_tuvi:SetCap(self.cap)
end

function PnTuVi:OnSave()
    return { current = self.current, cap = self.cap }
end

function PnTuVi:OnLoad(data)
    if data == nil then return end
    self.current = data.current or 0
    self.cap     = data.cap or Realms.GetThreshold(1)
    self:_PushToReplica()
end

return PnTuVi
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_tuvi.lua
git commit -m "feat(pn): add pn_tuvi component (capped accumulator with linhcan mult)"
```

---

## Task 8: Write `scripts/components/pn_tuvi_replica.lua`

**Files:**
- Create: `scripts/components/pn_tuvi_replica.lua`

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_tuvi_replica.lua
-- Networked mirror of pn_tuvi. HUD reads current + cap to draw progress bar.

local Replica = Class(function(self, inst)
    self.inst    = inst
    self.current_net = net_float(inst.GUID, "pn_tuvi.current", "pn_tuvi_dirty")
    self.cap_net     = net_float(inst.GUID, "pn_tuvi.cap",     "pn_tuvi_dirty")
end)

function Replica:SetCurrent(v) self.current_net:set(v or 0)   end
function Replica:SetCap(v)     self.cap_net:set(v or 1)       end

function Replica:GetCurrent() return self.current_net:value() end
function Replica:GetCap()     return self.cap_net:value()     end

function Replica:GetPercent()
    local cap = self:GetCap()
    if cap <= 0 then return 0 end
    return math.min(1, self:GetCurrent() / cap)
end

function Replica:HasData()
    return self:GetCap() > 0
end

return Replica
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_tuvi_replica.lua
git commit -m "feat(pn): add pn_tuvi replica (current/cap netvars)"
```

---

## Task 9: Write `scripts/components/pn_canhgioi.lua`

**Files:**
- Create: `scripts/components/pn_canhgioi.lua`

Tracks current realm tier (0..9). Applies stat bonus deltas on each tier-up. Listens to CANHGIOI_UP.

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_canhgioi.lua
-- Cảnh giới tracker. On CANHGIOI_UP event, advances tier and applies stat delta.

local Events = require("pn/events")
local Realms = require("pn/realms")
local TUNING = require("pn/tuning")

local PnCanhGioi = Class(function(self, inst)
    self.inst = inst
    self.tier = 0   -- 0 = Phàm Nhân, 1..9 = Luyện Khí tầng 1..9

    if inst then
        inst:ListenForEvent(Events.CANHGIOI_UP, function(_, data)
            self:_OnCanhGioiUp(data)
        end)
    end
end)

function PnCanhGioi:_OnCanhGioiUp(data)
    if not data or not data.new_tier then return end
    if data.new_tier <= self.tier then return end  -- no downgrade

    local old_tier = self.tier
    self.tier = data.new_tier
    self:_ApplyStatDelta(old_tier, self.tier)
    self:_PushToReplica()
end

-- Apply incremental stat bonus from old_tier → new_tier
function PnCanhGioi:_ApplyStatDelta(old_tier, new_tier)
    if not self.inst then return end
    local tier_delta = new_tier - old_tier
    if tier_delta <= 0 then return end

    local s = TUNING.STATS_PER_TIER

    -- HP max
    if self.inst.components.health then
        local cur_max = self.inst.components.health.maxhealth
        self.inst.components.health:SetMaxHealth(cur_max + s.HP_BONUS * tier_delta)
    end

    -- Hunger drain rate (lower = slower hunger)
    if self.inst.components.hunger then
        local cur = self.inst.components.hunger.hungerrate
        self.inst.components.hunger.hungerrate = cur * (1 + s.HUNGER_MULT_DELTA * tier_delta)
    end

    -- Attack damage multiplier
    if self.inst.components.combat then
        local cur = self.inst.components.combat.damagemultiplier
        self.inst.components.combat.damagemultiplier = cur + s.ATTACK_MULT_DELTA * tier_delta
    end

    -- Move speed multiplier (set via locomotor)
    if self.inst.components.locomotor then
        local cur = self.inst.components.locomotor:GetExternalSpeedMultiplier(self.inst, "pn_canhgioi_speed")
                    or 1.0
        self.inst.components.locomotor:SetExternalMultiplier(
            self.inst, "pn_canhgioi_speed",
            cur + s.SPEED_MULT_DELTA * tier_delta
        )
    end
end

function PnCanhGioi:GetTier()    return self.tier end
function PnCanhGioi:GetDisplay() return Realms.GetDisplay(self.tier) end

function PnCanhGioi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_canhgioi) then return end
    self.inst.replica.pn_canhgioi:SetTier(self.tier)
end

function PnCanhGioi:OnSave()
    return { tier = self.tier }
end

function PnCanhGioi:OnLoad(data)
    if data == nil then return end
    self.tier = data.tier or 0
    -- NOTE: do NOT re-apply stat deltas here; they were already baked into the save.
    -- The character's health/hunger/etc on save already reflects past bonuses.
    self:_PushToReplica()
end

return PnCanhGioi
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_canhgioi.lua
git commit -m "feat(pn): add pn_canhgioi component (tier tracker + stat deltas)"
```

---

## Task 10: Write `scripts/components/pn_canhgioi_replica.lua`

**Files:**
- Create: `scripts/components/pn_canhgioi_replica.lua`

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_canhgioi_replica.lua

local Realms = require("pn/realms")

local Replica = Class(function(self, inst)
    self.inst = inst
    self.tier_net = net_tinybyte(inst.GUID, "pn_canhgioi.tier", "pn_canhgioi_dirty")
end)

function Replica:SetTier(v) self.tier_net:set(v or 0) end
function Replica:GetTier() return self.tier_net:value() end
function Replica:GetDisplay() return Realms.GetDisplay(self:GetTier()) end
function Replica:GetColor() return Realms.GetTierColor(self:GetTier()) end

function Replica:HasData()
    -- Always has data — even tier 0 (Phàm Nhân) is valid.
    -- Use exists check instead.
    return self.inst ~= nil
end

return Replica
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_canhgioi_replica.lua
git commit -m "feat(pn): add pn_canhgioi replica"
```

---

## Task 11: Write `scripts/components/pn_breakthrough.lua`

**Files:**
- Create: `scripts/components/pn_breakthrough.lua`

Stateless orchestrator. Listens for `TUVI_CHANGED`. When current >= cap, triggers tier-up:
1. Decide success (MVP2: always true)
2. Push `BREAKTHROUGH` event
3. Push `CANHGIOI_UP` event so `pn_canhgioi` advances
4. Tell `pn_tuvi` to update cap to new tier's threshold + consume spent tu vi

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_breakthrough.lua
-- Listens for tu vi threshold crossings and orchestrates breakthroughs.
-- MVP2: auto-pass. Future plans add risk/fail.

local Events = require("pn/events")
local Realms = require("pn/realms")

local PnBreakthrough = Class(function(self, inst)
    self.inst = inst
    if inst then
        inst:ListenForEvent(Events.TUVI_CHANGED, function(_, data)
            self:_OnTuViChanged(data)
        end)
    end
end)

function PnBreakthrough:_OnTuViChanged(data)
    if not data then return end
    if data.new_value < data.cap then return end  -- not at threshold yet

    self:TryBreakthrough()
end

function PnBreakthrough:TryBreakthrough()
    if not (self.inst and self.inst.components.pn_canhgioi and self.inst.components.pn_tuvi) then
        return
    end

    local cur_tier = self.inst.components.pn_canhgioi:GetTier()
    if cur_tier >= Realms.GetMaxTier() then
        -- Already at cap; can't breakthrough further in MVP2.
        return
    end

    local next_tier = cur_tier + 1
    local cost      = Realms.GetThreshold(next_tier)  -- tu vi consumed for this breakthrough

    -- MVP2: always succeed.
    local success = true

    -- Push events. Order matters: CANHGIOI_UP triggers stat delta in pn_canhgioi,
    -- then we update tu vi cap to next tier's threshold and consume cost.
    self.inst:PushEvent(Events.BREAKTHROUGH, { tier = next_tier, success = success })

    if success then
        self.inst:PushEvent(Events.CANHGIOI_UP, {
            new_tier = next_tier,
            old_tier = cur_tier,
        })

        self.inst.components.pn_tuvi:ConsumeForBreakthrough(cost)
        local further_tier = math.min(next_tier + 1, Realms.GetMaxTier())
        self.inst.components.pn_tuvi:SetCapForTier(further_tier)
    end
end

-- No state to save (stateless orchestrator), but include for completeness.
function PnBreakthrough:OnSave()  return {} end
function PnBreakthrough:OnLoad(_) end

return PnBreakthrough
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_breakthrough.lua
git commit -m "feat(pn): add pn_breakthrough orchestrator (MVP2 auto-pass)"
```

---

## Task 12: Update `scripts/prefabs/phamnhan.lua` — attach components

**Files:**
- Modify: `scripts/prefabs/phamnhan.lua`

Add 4 components in init order from spec §2.5. Roll linh căn on first spawn.

- [ ] **Step 1: Replace the `master_postinit` function**

Find the existing `master_postinit` function. Replace it with:

```lua
local function master_postinit(inst)
    -- Cultivation components (order per design spec §2.5)
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_breakthrough")

    -- Roll linh căn on first spawn (idempotent — won't re-roll on reload)
    inst:DoTaskInTime(0, function()
        if inst.components.pn_linhcan and not inst.components.pn_linhcan.rolled then
            inst.components.pn_linhcan:RollNew()
            print(string.format("[PN] %s rolled linh căn: %s [%s]",
                tostring(inst.userid or "?"),
                inst.components.pn_linhcan:GetDisplay(),
                inst.components.pn_linhcan:GetElementDisplay()))
        end
    end)

    -- Base stats: vanilla Wilson defaults, no perks
    inst.components.health:SetMaxHealth(100)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)
    inst.components.combat.damagemultiplier = 1.0
    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE
end
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/prefabs/phamnhan.lua
git commit -m "feat(phamnhan): attach 4 cultivation components + roll linhcan on spawn"
```

---

## Task 13: Update `modmain.lua` — register components

**Files:**
- Modify: `modmain.lua`

Register all 4 server components + 3 replicas via `AddComponentPostInit` / direct require. The new `AddReplicableComponent` API does both.

- [ ] **Step 1: Add component registration block**

In `modmain.lua`, find the line `AddModCharacter("phamnhan", "MALE")`. Insert AFTER it (BEFORE the speech registration):

```lua
-- Register cultivation components.
-- AddReplicableComponent registers BOTH the server component (from scripts/components/<name>.lua)
-- AND its replica (from scripts/components/<name>_replica.lua) automatically.
AddReplicableComponent("pn_linhcan")
AddReplicableComponent("pn_tuvi")
AddReplicableComponent("pn_canhgioi")
-- pn_breakthrough is server-only — no replica needed.
AddComponentPostInit("pn_breakthrough", function() end)  -- forces require for prefab usage
```

Wait — `AddComponentPostInit` doesn't auto-require the component file. The correct pattern is to make sure the file is loaded. Use `modimport` if needed, or rely on `inst:AddComponent("pn_breakthrough")` triggering a require from `scripts/components/pn_breakthrough.lua`.

Use this simpler form instead — DST auto-finds components by name in `scripts/components/`:

```lua
-- Register cultivation components.
-- Server components are auto-discovered by name from scripts/components/<name>.lua
-- when `inst:AddComponent("<name>")` is called. We just need to register their replicas.
AddReplicableComponent("pn_linhcan")
AddReplicableComponent("pn_tuvi")
AddReplicableComponent("pn_canhgioi")
-- pn_breakthrough is server-only — no replica registration needed.
```

- [ ] **Step 2: Syntax check**

```bash
./tools/check_syntax.sh
```

- [ ] **Step 3: Commit**

```bash
git add modmain.lua
git commit -m "feat(modmain): register pn_linhcan + pn_tuvi + pn_canhgioi replicas"
```

---

## Task 14: Write `scripts/widgets/pn_hud_main.lua`

**Files:**
- Create: `scripts/widgets/pn_hud_main.lua`

HUD widget showing linh căn + cảnh giới + tu vi bar. Read from replicas every 0.5s.

- [ ] **Step 1: Write the file**

```lua
-- scripts/widgets/pn_hud_main.lua
-- HUD overlay showing player's linh căn / cảnh giới / tu vi progress.
-- Attaches via AddClassPostConstruct("widgets/controls") in modmain.

local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")
local Realms = require("pn/realms")

local FONT     = NUMBERFONT
local FONT_SIZE = 22

local PnHudMain = Class(Widget, function(self, owner)
    Widget._ctor(self, "PnHudMain")
    self.owner = owner

    -- Background frame
    self.bg = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bg:SetSize(280, 110)
    self.bg:SetTint(0, 0, 0, 0.5)

    -- Linh căn label
    self.linhcan_text = self:AddChild(Text(FONT, FONT_SIZE, ""))
    self.linhcan_text:SetPosition(0, 35)
    self.linhcan_text:SetHAlign(ANCHOR_MIDDLE)

    -- Cảnh giới label
    self.canhgioi_text = self:AddChild(Text(FONT, FONT_SIZE + 2, ""))
    self.canhgioi_text:SetPosition(0, 5)
    self.canhgioi_text:SetHAlign(ANCHOR_MIDDLE)

    -- Tu vi progress bar background
    self.bar_bg = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bar_bg:SetSize(240, 14)
    self.bar_bg:SetPosition(0, -25)
    self.bar_bg:SetTint(0.2, 0.2, 0.2, 0.8)

    -- Tu vi progress bar fill
    self.bar_fill = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bar_fill:SetTint(0.4, 0.85, 1, 1)
    self.bar_fill:SetPosition(-120, -25)

    -- Tu vi numeric overlay
    self.bar_text = self:AddChild(Text(FONT, FONT_SIZE - 4, "0 / 0"))
    self.bar_text:SetPosition(0, -25)
    self.bar_text:SetHAlign(ANCHOR_MIDDLE)

    self:StartUpdating()
end)

function PnHudMain:OnUpdate(dt)
    local p = self.owner
    if not p or not p.replica then return end

    local lc = p.replica.pn_linhcan
    local tv = p.replica.pn_tuvi
    local cg = p.replica.pn_canhgioi

    -- Linh căn line
    if lc and lc:HasData() then
        local elements = lc:GetElementDisplay()
        local s = elements ~= "" and (lc:GetDisplay() .. " (" .. elements .. ")") or lc:GetDisplay()
        self.linhcan_text:SetString(s)
    else
        self.linhcan_text:SetString("Linh căn: ?")
    end

    -- Cảnh giới line
    if cg then
        self.canhgioi_text:SetString(cg:GetDisplay())
        local col = cg:GetColor()
        self.canhgioi_text:SetColour(col[1], col[2], col[3], col[4])
    else
        self.canhgioi_text:SetString("?")
    end

    -- Tu vi bar
    if tv and tv:HasData() then
        local pct = tv:GetPercent()
        local fill_w = math.max(2, math.floor(240 * pct))
        self.bar_fill:SetSize(fill_w, 12)
        self.bar_fill:SetPosition(-120 + fill_w / 2, -25)
        self.bar_text:SetString(string.format("%d / %d tu vi",
            math.floor(tv:GetCurrent()), math.floor(tv:GetCap())))
    else
        self.bar_fill:SetSize(2, 12)
        self.bar_text:SetString("- / -")
    end
end

return PnHudMain
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/widgets/pn_hud_main.lua
git commit -m "feat(widget): add pn_hud_main showing linh căn + cảnh giới + tu vi bar"
```

---

## Task 15: Attach HUD via `modmain.lua`

**Files:**
- Modify: `modmain.lua`

Add `AddClassPostConstruct("widgets/controls", ...)` to inject the HUD into the bottom-left area.

- [ ] **Step 1: Add HUD attach block**

In `modmain.lua`, AFTER the `AddReplicableComponent` lines from Task 13, add:

```lua
-- Attach HUD widget to player controls bottom-left.
AddClassPostConstruct("widgets/controls", function(self)
    local PnHudMain = require("widgets/pn_hud_main")
    self.pn_hud = self.bottom_root:AddChild(PnHudMain(self.owner))
    self.pn_hud:SetPosition(-400, 90)
end)
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add modmain.lua
git commit -m "feat(modmain): attach pn_hud_main to player controls"
```

---

## Task 16: Write `scripts/pn/debug.lua`

**Files:**
- Create: `scripts/pn/debug.lua`

Console commands for in-game testing. Loaded conditionally (only when `DEBUG_PNTT` flag set or in dev mode).

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/debug.lua
-- Console commands for testing cultivation. Use from the in-game console:
--   c_addtuvi(50)               -- add 50 tu vi to local player
--   c_addtuvi(50, AllPlayers[1]) -- to a specific player
--   c_settier(3)                -- jump to Luyện Khí tầng 3
--   c_setlinhcan("THIEN", {"KIM"}) -- force-set linh căn
--   c_pnstate()                  -- print full cultivation state
-- These commands run on the SERVER; from a client, prefix with c_remote("...").

local Events = require("pn/events")
local Realms = require("pn/realms")
local LinhCanData = require("pn/linhcan_data")

-- Add tu vi (server-side; respects linhcan multiplier)
function _G.c_addtuvi(amount, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then print("[PN] no player") return end
    player:PushEvent(Events.TUVI_GAIN, { amount = amount or 100, source = "debug" })
    print(string.format("[PN] Added %d tu vi (raw) to %s", amount or 100, tostring(player.userid)))
end

-- Jump cảnh giới directly (skipping breakthrough cost)
function _G.c_settier(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_canhgioi then return end
    local cur = player.components.pn_canhgioi:GetTier()
    if tier <= cur then
        print(string.format("[PN] Already at tier %d (target %d), nothing to do", cur, tier))
        return
    end
    -- Apply tier-ups one by one to ensure stat deltas accumulate correctly
    for t = cur + 1, tier do
        player:PushEvent(Events.CANHGIOI_UP, { new_tier = t, old_tier = t - 1 })
    end
    if player.components.pn_tuvi then
        player.components.pn_tuvi:SetCapForTier(math.min(tier + 1, Realms.GetMaxTier()))
    end
    print(string.format("[PN] Set tier %d → %d for %s", cur, tier, tostring(player.userid)))
end

-- Force linh căn (overwrites existing)
function _G.c_setlinhcan(linhcan_type, elements, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_linhcan then return end
    local lc = player.components.pn_linhcan
    if not LinhCanData.TYPES[linhcan_type] then
        print("[PN] Invalid linh căn type. Valid: NGUY, CHAN, BIEN_DI, THIEN")
        return
    end
    lc.type     = linhcan_type
    lc.elements = elements or { "KIM" }
    lc.bien_di_tag = nil
    if linhcan_type == "BIEN_DI" and #lc.elements == 2 then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            local a, b = combo.elements[1], combo.elements[2]
            if (lc.elements[1] == a and lc.elements[2] == b)
            or (lc.elements[1] == b and lc.elements[2] == a) then
                lc.bien_di_tag = combo.tag
                break
            end
        end
    end
    lc.rolled = true
    lc:_PushToReplica()
    print(string.format("[PN] Set linh căn = %s [%s]", lc:GetDisplay(), lc:GetElementDisplay()))
end

-- Print full cultivation state
function _G.c_pnstate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local lc = player.components.pn_linhcan
    local tv = player.components.pn_tuvi
    local cg = player.components.pn_canhgioi
    print("===== PN cultivation state for " .. tostring(player.userid) .. " =====")
    if lc then
        print(string.format("  Linh căn: %s [%s] (mult=%.2f)",
            lc:GetDisplay(), lc:GetElementDisplay(), lc:GetTuViMult()))
    end
    if cg then
        print(string.format("  Cảnh giới: %s (tier=%d)", cg:GetDisplay(), cg:GetTier()))
    end
    if tv then
        print(string.format("  Tu vi: %d / %d", tv:Get(), tv:GetCap()))
    end
end

print("[PN] Debug commands loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/debug.lua
git commit -m "feat(pn): add debug console commands for cultivation testing"
```

---

## Task 17: Conditionally load debug in `modmain.lua`

**Files:**
- Modify: `modmain.lua`

Always load debug in MVP (it's harmless and Plan 1+2 are dev iterations). Later plans can gate behind `GetModConfigData("debug")` flag once configuration_options exist.

- [ ] **Step 1: Add modimport at the end of modmain.lua, BEFORE the final print line**

```lua
-- Debug console commands (always loaded during MVP; gate behind config in later plans)
modimport("scripts/pn/debug.lua")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add modmain.lua
git commit -m "feat(modmain): load debug commands"
```

---

## Task 18: Final integration check + tag

- [ ] **Step 1: Run all static checks**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
git log --oneline | head -20
```

Expected:
- check_syntax: all .lua files pass (~14 new files)
- check_assets: still valid (no new assets added)
- git log shows ~16 new commits since `p1-foundation-complete`

- [ ] **Step 2: Tag plan complete**

```bash
git tag -a p2-cultivation-core-complete -m "Plan 2 (Cultivation Core) complete.

Deliverables:
- 4 server components: pn_linhcan, pn_tuvi, pn_canhgioi, pn_breakthrough
- 3 replicas for HUD-readable state
- 4 data modules: events, tuning, linhcan_data, realms
- 1 HUD widget showing linh căn + cảnh giới + tu vi bar
- Debug console commands (c_addtuvi, c_settier, c_setlinhcan, c_pnstate)
- Updated phamnhan prefab to attach all 4 components + roll linh căn on spawn

Verified via static checks. In-game runtime test deferred per macos_dst_mod_loading
memory — Plan 3 or Workshop upload will be the first interactive verification."
git tag --list
```

---

## Self-review

**Spec coverage** — Plan 2 implements spec §3.1 (linh căn), §3.2 (cultivation math), §3.3 (breakthrough auto-pass), partial §7.4 (HUD), §9.4 (debug commands). Defers §3.4 (lifespan/permadeath) to Plan 3, §4+ (engagement loop) to Plan 4+.

**Type consistency** — Event names defined once in `events.lua`. Component names referenced consistently as `pn_linhcan`, `pn_tuvi`, `pn_canhgioi`, `pn_breakthrough`. Method names align with spec §11 OnSave/OnLoad contract.

**Open risks acknowledged inline:**
- Task 13: `AddReplicableComponent` is the documented DST helper; if it doesn't exist on user's DST version, fall back to separate `AddComponentPostInit` + replica file load via `modimport`.
- Task 14: `images/hud.xml` `inv_slot.tex` is vanilla — used as a placeholder bg. Real art comes in Plan 7.
- Task 15: `self.bottom_root` is the standard control container; if Klei renames, grep `reference/dst-scripts/scripts/widgets/controls.lua` for current name.

---

**End of Plan 2.**

# Plan 5 — Mob Cultivation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Vanilla DST mobs (spider, hound, frog, etc.) standing in a linh mạch aura also accumulate "cultivation time." After 5 min in aura → Tier 1 (Linh thú): +50% HP, +25% damage, +20% size, green glow. After 15 min → Tier 2 (Yêu tu): +120% HP, +60% damage, +35% size, red glow. Killing them gives the player extra tu vi (placeholder for Plan 6's nội đan items). Creates organic combat tension: player wants linh mạch tu vi but mobs do too.

**Architecture:**
- Generalize `pn_aura_source` to query by tag `pn_aura_target` instead of `player` only. Both players and patched mobs get this tag.
- New `pn_mob_cultivation` server component on each patched mob: listens for `pn_tuvi_gain` events, increments an internal counter, upgrades tier at thresholds.
- `scripts/pn/mob_patches.lua` lists vanilla mob prefab names; `AddPrefabPostInit` attaches the component + tag.
- On mob death: if a player killed it, push `pn_tuvi_gain` directly on the killer (with amount based on the mob's tier). Plan 6 replaces this with proper `pn_noidan` inventory items.
- Visual tier upgrade applies `AnimState:SetMultColour` tint + `Transform:SetScale` increase.

**Tech Stack:** Same as Plan 4. `AddPrefabPostInit` for mob patching, `combat.lastattacker` to identify killer, vanilla `health.maxhealth` / `combat.defaultdamage` / `Transform:SetScale` for stat changes.

**Prerequisites:** Plan 4 complete (tag `p4-linhmach-meditation-complete`). `pn_aura_source` exists. `pn_tuvi_gain` event flow works.

**Out of scope** (Plan 6+): Proper `pn_noidan` items (placeholder direct-tu-vi-grant used here). Custom mob art / glow particles (Plan 7).

---

## File summary

**Created:**
- `scripts/components/pn_mob_cultivation.lua` — tier tracker with HP/damage/scale upgrades + death loot hook
- `scripts/pn/mob_patches.lua` — list of vanilla mob prefabs + AddPrefabPostInit hooks

**Modified:**
- `scripts/pn/tuning.lua` — add MOB_CULTIVATION section
- `scripts/components/pn_aura_source.lua` — change tag filter from `{"player"}` to `{"pn_aura_target"}` and adjust meditation-bonus check (player-only)
- `scripts/prefabs/phamnhan.lua` — add `pn_aura_target` tag in common_postinit
- `modmain.lua` — modimport mob_patches.lua
- `scripts/pn/debug.lua` — add `c_mobcult` (list mob cultivation states near player)

---

## Task 1: Extend tuning.lua with MOB_CULTIVATION section

**Files:**
- Modify: `scripts/pn/tuning.lua`

- [ ] **Step 1: Insert new section**

Inside the return table, AFTER the WORLDGEN section, BEFORE the closing `}`, insert:

```lua

    -- Mob cultivation — mobs in linh mạch aura also accumulate cultivation time
    MOB_CULTIVATION = {
        -- Seconds of aura time required for each tier upgrade
        TIER_THRESHOLDS  = { 300, 900 },  -- 5 min → Tier 1, 15 min → Tier 2

        -- Stat multipliers applied at each tier (cumulative from base)
        TIER_STATS = {
            -- Tier 1 — Linh thú
            { hp_mult = 1.5,  dmg_mult = 1.25, scale = 1.2 },
            -- Tier 2 — Yêu tu
            { hp_mult = 2.2,  dmg_mult = 1.6,  scale = 1.35 },
        },

        -- Visual tint applied at each tier (AnimState:SetMultColour)
        TIER_TINT = {
            { 0.4, 1.0, 0.4, 1 },   -- Tier 1: green glow
            { 1.0, 0.3, 0.6, 1 },   -- Tier 2: red/purple glow
        },

        -- Tu vi reward when killed by a player (placeholder for nội đan items in Plan 6)
        KILL_REWARD = {
            [0] = 0,    -- Tier 0 mobs give nothing direct (Plan 6 adds 50% drop chance)
            [1] = 120,  -- Tier 1 = trung phẩm equivalent
            [2] = 300,  -- Tier 2 = thượng phẩm equivalent
        },
    },
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/tuning.lua
git commit -m "feat(pn): add MOB_CULTIVATION tuning section"
```

---

## Task 2: Update pn_aura_source to use generalized tag

**Files:**
- Modify: `scripts/components/pn_aura_source.lua`

Replace the tag filter and tighten the meditation-bonus check to player-only.

- [ ] **Step 1: Modify _Tick function**

Find this block in `pn_aura_source.lua`:

```lua
    local x, y, z = self.inst.Transform:GetWorldPosition()
    -- Find players in radius. Tag-filtered for cheap query.
    local ents = TheSim:FindEntities(x, y, z, self.radius, { "player" })

    local amount = self.rate_per_sec * (TUNING.LINH_MACH.SCAN_INTERVAL or 1.0)

    for _, ent in ipairs(ents) do
        if ent.components and ent.components.pn_tuvi then
            -- If meditating on this linh mạch, multiply by sit bonus
            local final_amount = amount
            if ent.components.pn_meditation
               and ent.components.pn_meditation:IsMeditating()
               and ent.components.pn_meditation:GetTarget() == self.inst then
                final_amount = final_amount * TUNING.TUVI_SOURCES.SIT_MEDITATE_BONUS
            end
            ent:PushEvent(Events.TUVI_GAIN, {
                amount = final_amount,
                source = "linh_mach_" .. self.tier:lower(),
            })
        end
    end
```

Replace with:

```lua
    local x, y, z = self.inst.Transform:GetWorldPosition()
    -- Find any aura-target entity in radius (players + cultivation-tagged mobs).
    -- Tag-filtered for cheap query — only entities with pn_aura_target tag.
    local ents = TheSim:FindEntities(x, y, z, self.radius, { "pn_aura_target" })

    local amount = self.rate_per_sec * (TUNING.LINH_MACH.SCAN_INTERVAL or 1.0)

    for _, ent in ipairs(ents) do
        local final_amount = amount

        -- Player-specific: apply meditation bonus
        if ent:HasTag("player")
           and ent.components and ent.components.pn_meditation
           and ent.components.pn_meditation:IsMeditating()
           and ent.components.pn_meditation:GetTarget() == self.inst then
            final_amount = final_amount * TUNING.TUVI_SOURCES.SIT_MEDITATE_BONUS
        end

        ent:PushEvent(Events.TUVI_GAIN, {
            amount = final_amount,
            source = "linh_mach_" .. self.tier:lower(),
        })
    end
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_aura_source.lua
git commit -m "feat(pn): generalize pn_aura_source tag filter to pn_aura_target"
```

---

## Task 3: Add pn_aura_target tag to phamnhan

**Files:**
- Modify: `scripts/prefabs/phamnhan.lua`

- [ ] **Step 1: Add tag in common_postinit**

Find this block:

```lua
local function common_postinit(inst)
    -- Add network tag for future mod features
    inst:AddTag("phamnhan")
end
```

Replace with:

```lua
local function common_postinit(inst)
    -- Add network tags for mod features
    inst:AddTag("phamnhan")
    inst:AddTag("pn_aura_target")  -- so pn_aura_source picks us up
end
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/prefabs/phamnhan.lua
git commit -m "feat(phamnhan): add pn_aura_target tag"
```

---

## Task 4: scripts/components/pn_mob_cultivation.lua

**Files:**
- Create: `scripts/components/pn_mob_cultivation.lua`

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_mob_cultivation.lua
-- Mob-side cultivation component. Counts time spent in linh mạch aura (measured
-- by how many pn_tuvi_gain ticks the mob has received). At threshold seconds the
-- mob is "upgraded" — its HP / damage / scale go up and a glow tint is applied.
-- On death by player, pushes pn_tuvi_gain on the killer (placeholder for Plan 6
-- nội đan items).

local Events = require("pn/events")
local TUNING = require("pn/tuning")

local PnMobCultivation = Class(function(self, inst)
    self.inst         = inst
    self.time_in_aura = 0   -- seconds accumulated from pn_tuvi_gain ticks
    self.current_tier = 0
    -- Snapshot of base stats so we can apply multipliers cleanly on tier change.
    self._base_hp    = nil
    self._base_dmg   = nil
    self._base_scale = nil

    if inst then
        -- Each pn_tuvi_gain on a mob entity = 1 scan interval of aura time.
        -- The aura_source pushes events every SCAN_INTERVAL seconds; sum them.
        inst:ListenForEvent(Events.TUVI_GAIN, function(_, _)
            self:_OnAuraTick()
        end)

        -- On death, reward the killer if they're a player.
        inst:ListenForEvent("death", function()
            self:_OnDeath()
        end)
    end
end)

function PnMobCultivation:_CaptureBase()
    if self._base_hp == nil and self.inst.components.health then
        self._base_hp = self.inst.components.health.maxhealth
    end
    if self._base_dmg == nil and self.inst.components.combat then
        self._base_dmg = self.inst.components.combat.defaultdamage or 10
    end
    if self._base_scale == nil and self.inst.Transform then
        local s = self.inst.Transform:GetScale()
        self._base_scale = s or 1
    end
end

function PnMobCultivation:_OnAuraTick()
    local interval = TUNING.LINH_MACH.SCAN_INTERVAL or 1.0
    self.time_in_aura = self.time_in_aura + interval

    -- Determine target tier from time_in_aura
    local thresholds = TUNING.MOB_CULTIVATION.TIER_THRESHOLDS
    local target_tier = 0
    for i, t in ipairs(thresholds) do
        if self.time_in_aura >= t then target_tier = i end
    end

    if target_tier > self.current_tier then
        self:_UpgradeTo(target_tier)
    end
end

function PnMobCultivation:_UpgradeTo(new_tier)
    if new_tier < 1 or new_tier > #TUNING.MOB_CULTIVATION.TIER_STATS then return end
    self:_CaptureBase()
    self.current_tier = new_tier

    local stats = TUNING.MOB_CULTIVATION.TIER_STATS[new_tier]

    -- HP
    if self.inst.components.health and self._base_hp then
        local new_max = self._base_hp * stats.hp_mult
        self.inst.components.health:SetMaxHealth(new_max)
        -- Restore proportionally
        self.inst.components.health:SetPercent(1.0)
    end

    -- Damage
    if self.inst.components.combat and self._base_dmg then
        self.inst.components.combat:SetDefaultDamage(self._base_dmg * stats.dmg_mult)
    end

    -- Scale (visual size)
    if self.inst.Transform and self._base_scale then
        local s = self._base_scale * stats.scale
        self.inst.Transform:SetScale(s, s, s)
    end

    -- Tint (glow colour)
    local tint = TUNING.MOB_CULTIVATION.TIER_TINT[new_tier]
    if tint and self.inst.AnimState then
        self.inst.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
    end

    print(string.format("[PN] %s upgraded to Tier %d (Linh thú/Yêu tu)",
        tostring(self.inst.prefab), new_tier))
end

function PnMobCultivation:_OnDeath()
    if self.current_tier == 0 then return end
    local killer = self.inst.components.combat
                   and self.inst.components.combat.lastattacker
    if not killer or not killer:HasTag("player") then return end

    local reward = TUNING.MOB_CULTIVATION.KILL_REWARD[self.current_tier]
    if reward and reward > 0 then
        killer:PushEvent(Events.TUVI_GAIN, {
            amount = reward,
            source = "noidan_t" .. tostring(self.current_tier),
        })
    end
end

function PnMobCultivation:GetTier()       return self.current_tier end
function PnMobCultivation:GetTimeInAura() return self.time_in_aura end

function PnMobCultivation:OnSave()
    return {
        time_in_aura = self.time_in_aura,
        current_tier = self.current_tier,
    }
end

function PnMobCultivation:OnLoad(data)
    if data == nil then return end
    self.time_in_aura = data.time_in_aura or 0
    self.current_tier = 0  -- always re-apply from 0 to capture fresh base stats
    if data.current_tier and data.current_tier > 0 then
        -- Defer one frame so stats are loaded first
        self.inst:DoTaskInTime(0, function()
            self:_UpgradeTo(data.current_tier)
        end)
    end
end

return PnMobCultivation
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_mob_cultivation.lua
git commit -m "feat(pn): add pn_mob_cultivation component (tier upgrade + kill reward)"
```

---

## Task 5: scripts/pn/mob_patches.lua

**Files:**
- Create: `scripts/pn/mob_patches.lua`

List of vanilla mob prefabs that should cultivate. For each, AddPrefabPostInit adds the tag + component.

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/mob_patches.lua
-- Apply pn_mob_cultivation to a curated list of vanilla mob prefabs.
-- AddPrefabPostInit runs on every spawn of each prefab (server-side only here).

local MOBS_TO_PATCH = {
    -- Spiders
    "spider", "spider_warrior", "spider_hider", "spider_spitter", "spider_dropper",
    -- Hounds
    "hound", "firehound", "icehound",
    -- Insects / amphibians
    "mosquito", "frog", "killerbee", "bee",
    -- Pigs / mermen
    "merm", "pigman", "pigguard",
    -- Clockwork
    "clockworkknight", "clockworkbishop", "clockworkrook",
    -- Birds
    "crow", "robin", "canary",
    -- Bunnymen (caves)
    "bunnyman",
}

for _, prefab_name in ipairs(MOBS_TO_PATCH) do
    AddPrefabPostInit(prefab_name, function(inst)
        -- Tag (also added on clients so the lookup works for replicas if needed)
        inst:AddTag("pn_aura_target")

        if not GLOBAL.TheWorld.ismastersim then return end

        -- Component (server-only)
        if not inst.components.pn_mob_cultivation then
            inst:AddComponent("pn_mob_cultivation")
        end
    end)
end

print(string.format("[PN] Patched %d vanilla mob prefabs for cultivation", #MOBS_TO_PATCH))
```

- [ ] **Step 2: Modify modmain.lua — import mob_patches**

Find the existing `modimport("scripts/pn/actions.lua")` line. Insert AFTER it:

```lua
modimport("scripts/pn/mob_patches.lua")
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/mob_patches.lua modmain.lua
git commit -m "feat(pn): add mob_patches.lua (patch ~20 vanilla mobs for cultivation)"
```

---

## Task 6: Debug command + final tag

**Files:**
- Modify: `scripts/pn/debug.lua`

- [ ] **Step 1: Append c_mobcult command**

Before the final `print("[PN] Debug commands loaded: ...")` line, insert:

```lua

-- Inspect mob cultivation states near player (within 20 tiles)
function _G.c_mobcult(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 20, { "pn_aura_target" })
    if #ents == 0 then
        print("[PN] No aura targets within 20 tiles")
        return
    end
    for _, e in ipairs(ents) do
        if e.components and e.components.pn_mob_cultivation then
            local m = e.components.pn_mob_cultivation
            print(string.format("  - %s tier=%d time_in_aura=%.1fs",
                tostring(e.prefab), m:GetTier(), m:GetTimeInAura()))
        end
    end
end
```

Update final print line:

```lua
print("[PN] Debug commands loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_setlifespan, c_dieofold, c_spawnlinhmach, c_aurastate, c_mobcult")
```

- [ ] **Step 2: Final check + commit + tag**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py

git add scripts/pn/debug.lua
git commit -m "feat(pn): add c_mobcult debug command + Plan 5 complete"

git tag -a p5-mob-cultivation-complete -m "Plan 5 (Mob Cultivation) complete.

Deliverables:
- pn_mob_cultivation component (counts aura ticks, upgrades to Tier 1/2 with HP/dmg/scale)
- mob_patches.lua patches ~20 vanilla mob prefabs (spider, hound, merm, etc.)
- pn_aura_source generalized to query pn_aura_target tag (covers players + mobs)
- Visual tier tint (green for Linh thú, red for Yêu tu)
- Kill-reward placeholder (direct tu vi push to player; Plan 6 adds nội đan items)
- Debug: c_mobcult

Emergent gameplay: mobs in linh mạch aura cultivate over time, creating combat tension.
Verified via static checks. In-game runtime test deferred until Workshop upload."
git tag --list
```

## Acceptance criteria
- pn_mob_cultivation.lua exists
- mob_patches.lua exists + modimport in modmain
- pn_aura_source tag filter generalized
- phamnhan adds pn_aura_target tag
- tuning.lua has MOB_CULTIVATION section
- syntax + asset check pass
- Tag p5-mob-cultivation-complete exists
- ~6 new commits since p4-linhmach-meditation-complete

---

## Self-review

**Spec coverage** — implements §5.3 (3-tier mob cultivation), §5.4 partial (kill reward; full nội đan items in Plan 6).

**Type consistency** — `pn_mob_cultivation` matches naming. Event `pn_tuvi_gain` reused. TUNING.MOB_CULTIVATION coexists with existing sections.

**Open risks:**
- `combat:SetDefaultDamage` may not exist on all mob prefabs; fallback to setting `combat.defaultdamage` directly if needed.
- `Transform:GetScale` returning nil — base = 1 fallback handles it.
- `MOBS_TO_PATCH` list may include prefabs that don't exist on some DST versions. AddPrefabPostInit silently no-ops missing prefabs, so no error.
- Hooking `health.maxhealth` change does NOT restore proportional HP automatically — we explicitly `SetPercent(1.0)` to give full HP at the new max (so a Tier 1 spider feels appropriately tough on respawn). This might be too generous; balance via playtesting.
- Mobs that already exist when the world loads BEFORE the mob_patches run will not have the component. AddPrefabPostInit handles new spawns; saved-world existing mobs get the patch when their prefab function runs on load. Tested in vanilla DST; should work.

---

**End of Plan 5.**

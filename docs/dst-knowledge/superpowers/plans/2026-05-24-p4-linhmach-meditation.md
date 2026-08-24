# Plan 4 — Linh Mạch + Meditation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Add the world's primary tu vi engagement loop. Linh mạch entities (3 tiers) scatter on worldgen, each tier emitting a tu vi aura at increasing rate (1.0 / 2.5 / 5.0 per second per radius 4/5/6). Players standing in the aura passively gain tu vi every second; sitting and meditating multiplies the rate by 1.5×. After this plan, players do NOT need to use debug commands to grow — they explore, find linh mạch, and cultivate naturally.

**Architecture:**
- `pn_aura_source` (server component, on linh mạch) periodically scans for players in radius and pushes `pn_tuvi_gain` events.
- `pn_meditation` (server component, on player) tracks whether player is sitting and provides a `GetBonus()` multiplier used by `pn_aura_source` when pushing events.
- `pn_linhkhi_source` (prefab, 3 tier variants) bundles `pn_aura_source` + visual + minimap icon + lighting. MVP visual reuses vanilla animations with colour tint.
- Action `PN_MEDITATE` is the right-click on a linh mạch when nearby. Starts the sit + meditation state.
- Worldgen post-init scatters 20 hạ + 6 trung + 2 thượng linh mạch across the map per `pn/tuning.lua` constants.

**Tech Stack:** DST `Component` pattern, `Action` definition, `AddPrefabPostInit("world", ...)` for scatter, `TheSim:FindEntities` spatial query, `state_idle_sit` stategraph state for sit visual.

**Prerequisites:** Plans 1-3 complete. `pn_tuvi` listens to `pn_tuvi_gain` events. `pn_lifespan.permadeath` blocks all gain when set.

**Out of scope** (Plan 5+): mob cultivation in aura (Plan 5), monster spawning at linh mạch (deferred — spawner component requires Plan 5's `pn_mob_cultivation` to be meaningful), ambient passive gain (Plan 6 with items), custom linh mạch art (Plan 7).

---

## File summary

**Created:**
- `scripts/components/pn_aura_source.lua` — radius scanner pushing `pn_tuvi_gain` on entities in range
- `scripts/components/pn_meditation.lua` — sit-meditate state + bonus multiplier
- `scripts/prefabs/pn_linhkhi_source.lua` — 3 prefab variants sharing one factory function
- `scripts/pn/actions.lua` — `PN_MEDITATE` action definition + registration

**Modified:**
- `modmain.lua` — register pn_linhkhi_source prefab, add `PN_MEDITATE` action, wire COMPONENT_ACTIONS, worldgen scatter, register pn_meditation replica (if needed — re-evaluate during impl)
- `scripts/prefabs/phamnhan.lua` — AddComponent("pn_meditation")
- `scripts/pn/tuning.lua` — already has `LINH_MACH` and `TUVI_SOURCES` entries from design spec; verify present
- `scripts/widgets/pn_hud_main.lua` — add small "Đang thiền" indicator
- `scripts/pn/debug.lua` — add `c_spawnlinhmach(tier)`, `c_aurastate()`

---

## Task 1: Extend tuning.lua with LINH_MACH constants

**Files:**
- Modify: `scripts/pn/tuning.lua`

The base `tuning.lua` from Plan 2 has TU_VI / STATS / LIFESPAN sections. Plan 4 adds LINH_MACH + TUVI_SOURCES + WORLDGEN sections.

- [ ] **Step 1: Read current tuning.lua**

Confirm current sections: TU_VI, STATS_PER_TIER, LIFESPAN.

- [ ] **Step 2: Append new sections**

Add the following sections inside the returned table (before the final `}`):

```lua
    -- Linh mạch sources — 3 tiers, scatter on worldgen
    LINH_MACH = {
        HA_PHAM = {
            rate_per_sec = 1.0,
            aura_radius  = 4,
            tint         = { 0.5, 0.85, 1.0 },   -- light blue
        },
        TRUNG_PHAM = {
            rate_per_sec = 2.5,
            aura_radius  = 5,
            tint         = { 1.0, 0.85, 0.3 },   -- gold
        },
        THUONG_PHAM = {
            rate_per_sec = 5.0,
            aura_radius  = 6,
            tint         = { 1.0, 0.4, 0.7 },    -- pinkish red
        },
        SCAN_INTERVAL = 1.0,                      -- seconds between aura ticks
    },

    -- Tu vi source burst values (for items in later plans, defined here for reference)
    TUVI_SOURCES = {
        SIT_MEDITATE_BONUS  = 1.5,                -- multiplier when sitting on linh mạch
        AMBIENT_PER_MIN     = 3,                  -- Plan 6 — ambient passive gain
    },

    -- Worldgen scatter
    WORLDGEN = {
        LINH_MACH_COUNT     = { HA = 20, TRUNG = 6, THUONG = 2 },
        LINH_MACH_MIN_DIST  = { HA = 0,  TRUNG = 300, THUONG = 600 },
        SCATTER_ATTEMPTS    = 30,                 -- placement tries before giving up per entity
    },
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/tuning.lua
git commit -m "feat(pn): add LINH_MACH + TUVI_SOURCES + WORLDGEN tuning"
```

---

## Task 2: scripts/components/pn_aura_source.lua

**Files:**
- Create: `scripts/components/pn_aura_source.lua`

Component on the linh mạch entity. Every `SCAN_INTERVAL` seconds, scan for players in radius and push `pn_tuvi_gain` on each.

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_aura_source.lua
-- Component on a linh mạch entity. Periodically scans for entities in radius
-- and pushes pn_tuvi_gain events on them.
--
-- Players' pn_tuvi listens for the event and accumulates (after applying linhcan mult).
-- Mobs (Plan 5) will have pn_mob_cultivation listening for the same event.

local Events = require("pn/events")
local TUNING = require("pn/tuning")

local PnAuraSource = Class(function(self, inst)
    self.inst         = inst
    self.tier         = "HA_PHAM"  -- default; SetTier overrides
    self.rate_per_sec = TUNING.LINH_MACH.HA_PHAM.rate_per_sec
    self.radius       = TUNING.LINH_MACH.HA_PHAM.aura_radius
    self._task        = nil

    if inst and TheWorld and TheWorld.ismastersim then
        -- Only run on server
        self:_StartTicking()
    end
end)

function PnAuraSource:SetTier(tier_key)
    local cfg = TUNING.LINH_MACH[tier_key]
    if not cfg then return end
    self.tier         = tier_key
    self.rate_per_sec = cfg.rate_per_sec
    self.radius       = cfg.aura_radius
end

function PnAuraSource:_StartTicking()
    if self._task then return end
    local interval = TUNING.LINH_MACH.SCAN_INTERVAL or 1.0
    self._task = self.inst:DoPeriodicTask(interval, function()
        self:_Tick()
    end, interval)  -- first run after interval, not immediately
end

function PnAuraSource:_StopTicking()
    if self._task then
        self._task:Cancel()
        self._task = nil
    end
end

function PnAuraSource:_Tick()
    if not self.inst or not self.inst:IsValid() then
        self:_StopTicking()
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    -- Find players in radius. Tag-filtered for cheap query.
    -- Plan 5 will also match the "_mob_cultivation" tag for monster cultivation.
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
end

function PnAuraSource:OnRemoveEntity()
    self:_StopTicking()
end

return PnAuraSource
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_aura_source.lua
git commit -m "feat(pn): add pn_aura_source component (periodic radius scan + push TUVI_GAIN)"
```

---

## Task 3: scripts/components/pn_meditation.lua

**Files:**
- Create: `scripts/components/pn_meditation.lua`

Server component on player. Tracks "is currently meditating" state. Started by `PN_MEDITATE` action, cancelled by movement / damage / re-pressing the key.

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_meditation.lua
-- Sit-meditate state. When active, pn_aura_source applies a 1.5× bonus to tu vi
-- gained from the targeted linh mạch.

local PnMeditation = Class(function(self, inst)
    self.inst        = inst
    self.is_meditating = false
    self.target      = nil  -- the linh mạch entity being meditated on

    if inst then
        -- Cancel on movement (any control input)
        inst:ListenForEvent("locomote", function() self:Stop("locomote") end)
        -- Cancel on damage
        inst:ListenForEvent("attacked",  function() self:Stop("attacked")  end)
    end
end)

-- Start meditating on the given linh mạch target.
function PnMeditation:Start(target)
    if self.is_meditating then return false end
    if not target or not target:IsValid() then return false end
    self.is_meditating = true
    self.target = target

    -- Play idle sit anim (reuse vanilla state)
    if self.inst.sg and self.inst.sg.GoToState then
        self.inst.sg:GoToState("idle")  -- fallback: vanilla idle, custom sit state added later
    end

    if self.inst then
        self.inst:PushEvent("pn_meditation_start", { target = target })
    end
    return true
end

function PnMeditation:Stop(reason)
    if not self.is_meditating then return end
    self.is_meditating = false
    self.target = nil
    if self.inst then
        self.inst:PushEvent("pn_meditation_stop", { reason = reason })
    end
end

function PnMeditation:IsMeditating() return self.is_meditating end
function PnMeditation:GetTarget()    return self.target        end

-- No save state: meditation is transient session-only.
function PnMeditation:OnSave()        return {} end
function PnMeditation:OnLoad(_)       end

return PnMeditation
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_meditation.lua
git commit -m "feat(pn): add pn_meditation component (sit-on-linh-mạch state)"
```

---

## Task 4: scripts/pn/actions.lua — PN_MEDITATE action

**Files:**
- Create: `scripts/pn/actions.lua`

Define the right-click "Tọa thiền" action on linh mạch entities.

- [ ] **Step 1: Write the file**

```lua
-- scripts/pn/actions.lua
-- Custom actions for the PNTT mod. Registered from modmain.

-- Note: This file is `modimport`ed from modmain, so it inherits env globals
-- (Action, AddAction, ACTIONS, COMPONENT_ACTIONS, GLOBAL).

local PN_MEDITATE = Action({ priority = 5, mount_valid = false, distance = 4 })
PN_MEDITATE.id  = "PN_MEDITATE"
PN_MEDITATE.str = "Tọa thiền"
PN_MEDITATE.fn  = function(act)
    local doer   = act.doer
    local target = act.target
    if doer and doer.components and doer.components.pn_meditation then
        return doer.components.pn_meditation:Start(target)
    end
    return false
end

AddAction(PN_MEDITATE)

-- Wire the action to right-click on linh mạch entities.
-- COMPONENT_ACTIONS.SCENE table: triggered for inspectable / scene-level interactions.
AddComponentAction("SCENE", "pn_aura_source", function(inst, doer, actions, right)
    if right and doer and doer.components and doer.components.pn_meditation
       and not doer.components.pn_meditation:IsMeditating() then
        table.insert(actions, ACTIONS.PN_MEDITATE)
    end
end)

-- Provide a stategraph action handler so the action runs through normal anim flow.
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PN_MEDITATE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.PN_MEDITATE, "dolongaction"))
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/actions.lua
git commit -m "feat(pn): add PN_MEDITATE action + COMPONENT_ACTIONS wiring"
```

---

## Task 5: scripts/prefabs/pn_linhkhi_source.lua

**Files:**
- Create: `scripts/prefabs/pn_linhkhi_source.lua`

3 variants from one factory. Visual placeholder = vanilla anim + tint. Plan 7 replaces with real art.

- [ ] **Step 1: Write the file**

```lua
-- scripts/prefabs/pn_linhkhi_source.lua
-- Linh mạch huyệt — 3 tier variants (Hạ / Trung / Thượng phẩm).
-- Each emits a tu vi aura per pn_aura_source. Visual is a tinted vanilla animation.

local TUNING = require("pn/tuning")

local assets = {
    -- Reuse vanilla firefly_lightsource anim as placeholder.
    Asset("ANIM", "anim/firefly_lightsource.zip"),
}

local function MakeLinhKhi(tier_key, prefab_name)
    return Prefab(prefab_name, function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()

        MakeObstaclePhysics(inst, 0.5)

        inst.MiniMapEntity:SetIcon("globalpos.tex")  -- vanilla placeholder icon

        inst.AnimState:SetBank("firefly_lightsource")
        inst.AnimState:SetBuild("firefly_lightsource")
        inst.AnimState:PlayAnimation("idle", true)

        local tint = TUNING.LINH_MACH[tier_key].tint or { 1, 1, 1 }
        inst.AnimState:SetMultColour(tint[1], tint[2], tint[3], 1)

        -- Light source for atmospheric glow
        inst.Light:SetIntensity(0.6)
        inst.Light:SetRadius(TUNING.LINH_MACH[tier_key].aura_radius or 4)
        inst.Light:SetFalloff(0.5)
        inst.Light:SetColour(tint[1], tint[2], tint[3])
        inst.Light:Enable(true)

        inst:AddTag("pn_linhkhi_source")
        inst:AddTag("structure")  -- groups with other static structures for save handling

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = function() return tier_key end

        inst:AddComponent("pn_aura_source")
        inst.components.pn_aura_source:SetTier(tier_key)

        return inst
    end, assets)
end

return
    MakeLinhKhi("HA_PHAM",     "pn_linhkhi_ha"),
    MakeLinhKhi("TRUNG_PHAM",  "pn_linhkhi_trung"),
    MakeLinhKhi("THUONG_PHAM", "pn_linhkhi_thuong")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/prefabs/pn_linhkhi_source.lua
git commit -m "feat(pn): add pn_linhkhi_source prefab (3 tier variants with tinted placeholder visual)"
```

---

## Task 6: Worldgen scatter

**Files:**
- Modify: `modmain.lua`

Add an `AddPrefabPostInit("world", ...)` block that scatters linh mạch across the map on first init.

- [ ] **Step 1: Insert worldgen block**

Read `modmain.lua`. After the `AddPrefabPostInit("world", function(inst) ... end)` block that exists from Plan 3 (ms_playerreroll blocker), append another block:

```lua

-- Worldgen scatter — place linh mạch across the map on world init.
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end

    -- Defer until next frame so the map is fully ready.
    inst:DoTaskInTime(0, function()
        local cfg = GLOBAL.require("pn/tuning").WORLDGEN
        if not cfg or not cfg.LINH_MACH_COUNT then return end

        local map = GLOBAL.TheWorld.Map
        if not map then return end

        local function place(prefab_name, count, min_dist)
            for i = 1, count do
                local attempts = 0
                while attempts < (cfg.SCATTER_ATTEMPTS or 30) do
                    local angle = math.random() * 2 * math.pi
                    local r     = min_dist + math.random() * 400
                    local x, z  = math.cos(angle) * r, math.sin(angle) * r
                    if map:IsAboveGroundAtPoint(x, 0, z) then
                        local ent = GLOBAL.SpawnPrefab(prefab_name)
                        if ent then
                            ent.Transform:SetPosition(x, 0, z)
                            break
                        end
                    end
                    attempts = attempts + 1
                end
            end
        end

        place("pn_linhkhi_ha",     cfg.LINH_MACH_COUNT.HA,     cfg.LINH_MACH_MIN_DIST.HA)
        place("pn_linhkhi_trung",  cfg.LINH_MACH_COUNT.TRUNG,  cfg.LINH_MACH_MIN_DIST.TRUNG)
        place("pn_linhkhi_thuong", cfg.LINH_MACH_COUNT.THUONG, cfg.LINH_MACH_MIN_DIST.THUONG)

        print(string.format(
            "[PN] Scattered linh mạch: %d hạ, %d trung, %d thượng",
            cfg.LINH_MACH_COUNT.HA, cfg.LINH_MACH_COUNT.TRUNG, cfg.LINH_MACH_COUNT.THUONG
        ))
    end)
end)
```

- [ ] **Step 2: Add prefab to PrefabFiles**

Find the `PrefabFiles = { "phamnhan" }` line in modmain.lua. Replace with:

```lua
PrefabFiles = {
    "phamnhan",
    "pn_linhkhi_source",
}
```

- [ ] **Step 3: Import actions module**

In modmain, BEFORE the final `print("[PN] Phàm Nhân Tu Tiên mod loaded ...")` line and AFTER the debug modimport, add:

```lua
modimport("scripts/pn/actions.lua")
```

(Or wherever fits the existing modimport ordering — after the debug load.)

- [ ] **Step 4: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add modmain.lua
git commit -m "feat(modmain): register linh mạch prefab, scatter on worldgen, import actions"
```

---

## Task 7: Wire pn_meditation into phamnhan

**Files:**
- Modify: `scripts/prefabs/phamnhan.lua`

- [ ] **Step 1: AddComponent line**

In `master_postinit`, insert `inst:AddComponent("pn_meditation")` after `pn_lifespan` and before `pn_breakthrough`. Final order:

```lua
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_lifespan")
    inst:AddComponent("pn_meditation")
    inst:AddComponent("pn_breakthrough")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/prefabs/phamnhan.lua
git commit -m "feat(phamnhan): attach pn_meditation"
```

---

## Task 8: HUD meditation indicator

**Files:**
- Modify: `scripts/widgets/pn_hud_main.lua`

Small text indicator that shows "✨ Đang thiền" when player is meditating.

- [ ] **Step 1: Add text widget**

In constructor, after `self.lifespan_text` block and before `self:StartUpdating()`, add:

```lua

    -- Meditating indicator (Plan 4)
    self.meditating_text = self:AddChild(Text(FONT, FONT_SIZE - 4, ""))
    self.meditating_text:SetPosition(0, -75)
    self.meditating_text:SetHAlign(ANCHOR_MIDDLE)
    self.meditating_text:SetColour(0.6, 0.95, 0.4, 1)
```

Increase bg size again: change `self.bg:SetSize(280, 140)` to `self.bg:SetSize(280, 165)`.

- [ ] **Step 2: Update OnUpdate**

Append to end of OnUpdate function:

```lua

    -- Meditation indicator (server-only state; we sneak-peek via player.components)
    -- Note: on client, this won't be available — meditation is server-state. We need
    -- to either send a replica field or rely on visual sit anim. For MVP plan 4,
    -- show "Đang thiền" if local player.sg appears to be in idle_sit or if a global
    -- pn_meditating field is set. Defer proper net for Plan 5 if needed.
    local meditating = false
    if p.components and p.components.pn_meditation then
        meditating = p.components.pn_meditation:IsMeditating()
    end
    self.meditating_text:SetString(meditating and "✨ Đang thiền (×1.5)" or "")
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/widgets/pn_hud_main.lua
git commit -m "feat(widget): add meditation indicator to pn_hud_main"
```

---

## Task 9: Debug commands + final check + tag

**Files:**
- Modify: `scripts/pn/debug.lua`

- [ ] **Step 1: Append commands**

Append before the final `print(...)` line:

```lua

-- Spawn a linh mạch at the player's position
function _G.c_spawnlinhmach(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    tier = (tier or "ha"):lower()
    local prefab_map = { ha = "pn_linhkhi_ha", trung = "pn_linhkhi_trung", thuong = "pn_linhkhi_thuong" }
    local prefab = prefab_map[tier]
    if not prefab then
        print("[PN] Invalid tier. Use: ha | trung | thuong")
        return
    end
    local x, y, z = player.Transform:GetWorldPosition()
    local ent = GLOBAL.SpawnPrefab(prefab)
    if ent then
        ent.Transform:SetPosition(x + 3, y, z)
        print(string.format("[PN] Spawned %s at (%.1f, %.1f, %.1f)", prefab, x + 3, y, z))
    end
end

-- Print aura state of the linh mạch nearest to player (within 20 tiles)
function _G.c_aurastate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 20, { "pn_linhkhi_source" })
    if #ents == 0 then
        print("[PN] No linh mạch within 20 tiles")
        return
    end
    for _, e in ipairs(ents) do
        if e.components.pn_aura_source then
            local a = e.components.pn_aura_source
            print(string.format("  - %s tier=%s rate=%.2f/s radius=%d",
                e.prefab, a.tier, a.rate_per_sec, a.radius))
        end
    end
end
```

Update the loaded print line to include the new commands:

```lua
print("[PN] Debug commands loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_setlifespan, c_dieofold, c_spawnlinhmach, c_aurastate")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/debug.lua
git commit -m "feat(pn): add c_spawnlinhmach + c_aurastate debug commands"
```

- [ ] **Step 3: Final integration check**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
git log --oneline | head -15
```

Expected: 24 Lua files pass, all assets valid, ~9 new commits since `p3-lifespan-permadeath-complete`.

- [ ] **Step 4: Tag**

```bash
git tag -a p4-linhmach-meditation-complete -m "Plan 4 (Linh Mạch + Meditation) complete.

Deliverables:
- pn_aura_source component on linh mạch entities (radius scan + push TUVI_GAIN)
- pn_meditation component on player (sit-meditate state, 1.5× bonus when sitting on target linh mạch)
- pn_linhkhi_source prefab (3 tier variants: hạ/trung/thượng) with placeholder visual + light
- PN_MEDITATE right-click action + stategraph wiring
- Worldgen scatter: 20 hạ + 6 trung + 2 thượng linh mạch with distance-from-spawn gating
- HUD meditation indicator
- Debug: c_spawnlinhmach, c_aurastate

After this plan, players passively gain tu vi by standing near linh mạch (no debug commands required).
Mob cultivation in aura is Plan 5. Ambient passive gain is Plan 6 (with items).
Verified via static checks. In-game runtime test deferred until Workshop upload."
git tag --list
```

---

## Self-review

**Spec coverage** — implements §4.1 (linh mạch entities) partially, §4.2 (meditation), §7.3 (worldgen scatter), §7.6 (action + stategraph wiring).

**Type consistency** — `pn_aura_source` component name is consistent (not "pn_aura" as design draft suggested — see Plan 4 architecture for rationale: source-side scanner is cleaner than receiver-side). Event name `pn_tuvi_gain` reused from `events.lua`.

**Open risks:**
- Task 4 stategraph wiring uses `dolongaction`; if this state name isn't standard on player stategraph, the action triggers but no anim plays. Workshop testing will reveal.
- Task 5 visual uses vanilla `firefly_lightsource.zip` — confirm asset path resolves in DST. If not, fall back to `tentacle_pillar_fx`.
- Task 6 worldgen scatter uses simple random — clusters of linh mạch can happen. Acceptable for MVP; Plan 7 can add minimum-distance-between-linhmach.
- Task 8 HUD reads `p.components.pn_meditation` directly — works on host (single-player) but not on client (replica-only). For Plan 4 MVP this is OK; Plan 5 if multiplayer matters can add a `pn_meditation_replica`.

---

**End of Plan 4.**

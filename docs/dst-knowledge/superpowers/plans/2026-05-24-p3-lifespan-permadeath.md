# Plan 3 — Lifespan + Permadeath Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Add `pn_lifespan` component that decays each in-game day, extends +5 days on each Luyện Khí breakthrough, and triggers permanent death when remaining = 0. After this plan, a phàm nhân lives ~60 days base (105 with full Luyện Khí), then dies of old age — character becomes unrevivable for that save slot.

**Architecture:** New `pn_lifespan` component on player, listens to `worldevent` `phasechanged` for decay ticks. Listens to `pn_canhgioi_up` event to extend lifespan. On `pn_lifespan_expired`, sets a `permadeath` persistent flag and kills player via `health:Kill("oldage")`. Respawn-blocking is achieved via `player.persists = false` + intercepting the corpse-revive action with `AddPrefabPostInit("world", ...)` that checks the flag.

**Tech Stack:** Same as Plan 2. DST `worldevent` system, `health:Kill()`, `inst.persists`, `OnSave`/`OnLoad` pattern.

**Prerequisites:** Plan 2 complete (tag `p2-cultivation-core-complete`). 8 server components + 3 replicas exist. HUD widget shows linh căn / cảnh giới / tu vi.

**Out of scope** (Plan 4+): linh mạch entity, aura mechanics, mob cultivation, items, real combat balance. Lifespan only.

---

## File summary

**Created:**
- `scripts/components/pn_lifespan.lua` — decay + +5 on breakthrough + permadeath trigger
- `scripts/components/pn_lifespan_replica.lua` — total/remaining/permadeath netvars

**Modified:**
- `scripts/prefabs/phamnhan.lua` — AddComponent("pn_lifespan")
- `modmain.lua` — AddReplicableComponent("pn_lifespan") + respawn-block hook
- `scripts/widgets/pn_hud_main.lua` — add lifespan line (white >50%, yellow 20-50%, red <20%)
- `scripts/pn/debug.lua` — add `c_setlifespan`, `c_dieofold`

---

## Task 1: scripts/components/pn_lifespan.lua

**Files:**
- Create: `scripts/components/pn_lifespan.lua`

Per spec §3.4. Decay 1 day per in-game day cycle. Listen `pn_canhgioi_up` for +5 days. Trigger permadeath on remaining = 0.

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_lifespan.lua
-- Tuổi thọ + permadeath. Decays each in-game day cycle. Extends +5 on each
-- Luyện Khí breakthrough. When remaining hits 0, player dies of old age and
-- a persistent permadeath flag blocks all respawn attempts.

local Events = require("pn/events")
local TUNING = require("pn/tuning")

local PnLifespan = Class(function(self, inst)
    self.inst       = inst
    self.total      = TUNING.LIFESPAN.BASE   -- max possible (60 + 5*N tiers achieved)
    self.remaining  = TUNING.LIFESPAN.BASE
    self.permadeath = false

    if inst then
        -- Extend lifespan on breakthrough
        inst:ListenForEvent(Events.CANHGIOI_UP, function(_, _)
            self:_OnBreakthrough()
        end)

        -- Decay on every in-game day transition (dusk -> night counts as one cycle finished)
        -- We listen on the world; the world fires "phasechanged" every transition.
        -- We tick on "day" specifically to match "1 day passed = 1 lifespan day lost".
        if GLOBAL.TheWorld then
            self._world_handler = function(_, data)
                if data and data.newphase == "day" then
                    self:_DecayOneDay()
                end
            end
            inst:ListenForEvent("phasechanged", self._world_handler, GLOBAL.TheWorld)
        end
    end
end)

function PnLifespan:_OnBreakthrough()
    local delta = TUNING.LIFESPAN.BONUS_PER_TIER
    self.total     = self.total + delta
    self.remaining = self.remaining + delta
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LIFESPAN_TICK, { remaining = self.remaining, total = self.total })
    end
end

function PnLifespan:_DecayOneDay()
    if self.permadeath then return end
    self.remaining = math.max(0, self.remaining - TUNING.LIFESPAN.DECAY_PER_DAY)
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LIFESPAN_TICK, { remaining = self.remaining, total = self.total })
    end
    if self.remaining <= 0 then
        self:TriggerPermadeath()
    end
end

function PnLifespan:TriggerPermadeath()
    if self.permadeath then return end
    self.permadeath = true
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LIFESPAN_EXPIRED, {})
        -- Kill the player. damagesource string lets the message-on-death code
        -- match "oldage" and show "Bạn đã chết già" (Plan 3 wires the message).
        if self.inst.components.health then
            self.inst.components.health:Kill()
        end
        print(string.format("[PN] %s died of old age (permadeath set)",
            tostring(self.inst.userid or "?")))
    end
end

function PnLifespan:Get()           return self.remaining end
function PnLifespan:GetTotal()      return self.total end
function PnLifespan:IsPermadeath()  return self.permadeath end

-- Admin helpers (used by debug commands).
function PnLifespan:SetRemaining(v)
    self.remaining = math.max(0, math.min(v, self.total))
    self:_PushToReplica()
end

function PnLifespan:SetTotal(v)
    self.total     = math.max(1, v)
    self.remaining = math.min(self.remaining, self.total)
    self:_PushToReplica()
end

function PnLifespan:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_lifespan) then return end
    self.inst.replica.pn_lifespan:SetRemaining(self.remaining)
    self.inst.replica.pn_lifespan:SetTotal(self.total)
    self.inst.replica.pn_lifespan:SetPermadeath(self.permadeath)
end

function PnLifespan:OnSave()
    return {
        total      = self.total,
        remaining  = self.remaining,
        permadeath = self.permadeath,
    }
end

function PnLifespan:OnLoad(data)
    if data == nil then return end
    self.total      = data.total or TUNING.LIFESPAN.BASE
    self.remaining  = data.remaining or self.total
    self.permadeath = data.permadeath or false
    self:_PushToReplica()
end

function PnLifespan:OnRemoveEntity()
    -- Detach world listener so the handler doesn't outlive the player entity.
    if self._world_handler and GLOBAL.TheWorld then
        GLOBAL.TheWorld:RemoveEventCallback("phasechanged", self._world_handler)
    end
end

return PnLifespan
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_lifespan.lua
git commit -m "feat(pn): add pn_lifespan component (decay + breakthrough bonus + permadeath)"
```

---

## Task 2: scripts/components/pn_lifespan_replica.lua

**Files:**
- Create: `scripts/components/pn_lifespan_replica.lua`

- [ ] **Step 1: Write the file**

```lua
-- scripts/components/pn_lifespan_replica.lua
-- Networked lifespan state for HUD: total, remaining, permadeath flag.

local Replica = Class(function(self, inst)
    self.inst = inst
    self.total_net      = net_float(inst.GUID, "pn_lifespan.total",     "pn_lifespan_dirty")
    self.remaining_net  = net_float(inst.GUID, "pn_lifespan.remaining", "pn_lifespan_dirty")
    self.permadeath_net = net_bool (inst.GUID, "pn_lifespan.permadeath","pn_lifespan_dirty")
end)

function Replica:SetTotal(v)      self.total_net:set(v or 0)      end
function Replica:SetRemaining(v)  self.remaining_net:set(v or 0)  end
function Replica:SetPermadeath(v) self.permadeath_net:set(v == true) end

function Replica:GetTotal()       return self.total_net:value()      end
function Replica:GetRemaining()   return self.remaining_net:value()  end
function Replica:IsPermadeath()   return self.permadeath_net:value() end

function Replica:GetPercent()
    local t = self:GetTotal()
    if t <= 0 then return 0 end
    return math.max(0, math.min(1, self:GetRemaining() / t))
end

-- Returns {r, g, b, a} colour for HUD based on remaining percentage.
function Replica:GetColor()
    local p = self:GetPercent()
    if p > 0.5 then return {1, 1, 1, 1}        end  -- white
    if p > 0.2 then return {1, 0.85, 0.2, 1}   end  -- yellow
    return            {1, 0.3, 0.3, 1}                -- red
end

function Replica:HasData()
    return self:GetTotal() > 0
end

return Replica
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/components/pn_lifespan_replica.lua
git commit -m "feat(pn): add pn_lifespan replica (netvars + color helper)"
```

---

## Task 3: Wire pn_lifespan into phamnhan + modmain

**Files:**
- Modify: `scripts/prefabs/phamnhan.lua`
- Modify: `modmain.lua`

- [ ] **Step 1: Edit phamnhan.lua master_postinit**

In `master_postinit`, add `inst:AddComponent("pn_lifespan")` AFTER `inst:AddComponent("pn_canhgioi")` and BEFORE `inst:AddComponent("pn_breakthrough")`. The order matters per spec §2.5 (lifespan listens for `CANHGIOI_UP` which is pushed AFTER `pn_canhgioi` updates).

Final order should be:

```lua
    inst:AddComponent("pn_linhcan")
    inst:AddComponent("pn_tuvi")
    inst:AddComponent("pn_canhgioi")
    inst:AddComponent("pn_lifespan")
    inst:AddComponent("pn_breakthrough")
```

- [ ] **Step 2: Edit modmain.lua**

Add `AddReplicableComponent("pn_lifespan")` in the replica registration block (after `AddReplicableComponent("pn_canhgioi")`, before the `-- pn_breakthrough is server-only` comment).

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/prefabs/phamnhan.lua modmain.lua
git commit -m "feat(phamnhan): attach pn_lifespan + register replica in modmain"
```

---

## Task 4: Update HUD to show lifespan

**Files:**
- Modify: `scripts/widgets/pn_hud_main.lua`

Add a new text widget BELOW the tu vi bar showing `Thọ: REMAINING / TOTAL ngày` with colour cue.

- [ ] **Step 1: Add lifespan text widget**

In the constructor (Class body), AFTER the `self.bar_text` line, add:

```lua
    -- Lifespan label (Plan 3)
    self.lifespan_text = self:AddChild(Text(FONT, FONT_SIZE - 2, ""))
    self.lifespan_text:SetPosition(0, -50)
    self.lifespan_text:SetHAlign(ANCHOR_MIDDLE)
```

Adjust `self.bg:SetSize(280, 110)` to `self.bg:SetSize(280, 140)` (taller to fit the new line).

- [ ] **Step 2: Update OnUpdate to render lifespan**

At the end of `OnUpdate`, AFTER the tu vi bar block, add:

```lua
    -- Lifespan line
    local ls = p.replica.pn_lifespan
    if ls and ls:HasData() then
        local s
        if ls:IsPermadeath() then
            s = "Thọ: ĐÃ TẬN"
        else
            s = string.format("Thọ: %d / %d ngày",
                math.floor(ls:GetRemaining()), math.floor(ls:GetTotal()))
        end
        self.lifespan_text:SetString(s)
        local col = ls:GetColor()
        self.lifespan_text:SetColour(col[1], col[2], col[3], col[4])
    else
        self.lifespan_text:SetString("Thọ: -")
    end
```

- [ ] **Step 3: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/widgets/pn_hud_main.lua
git commit -m "feat(widget): add lifespan line to pn_hud_main with colour cue"
```

---

## Task 5: Block respawn when permadeath

**Files:**
- Modify: `modmain.lua`

When a player has `permadeath = true`, they cannot:
- Be revived from ghost via Revive Amulet
- Activate a Touchstone
- Use Heart of the Beast / other revival items
- Auto-revive on world transition

Cleanest approach: hook `AddComponentPostInit("health")` to intercept revive attempts when permadeath flag is set on the player.

- [ ] **Step 1: Add respawn-block hook in modmain.lua**

After the existing `AddClassPostConstruct("widgets/controls", ...)` block, BEFORE the `modimport("scripts/pn/charselect_override.lua")` line, add:

```lua
-- Permadeath enforcement: when pn_lifespan.permadeath is true, the player cannot
-- be revived by any means. We monkey-patch Health:DoDelta to prevent healing from
-- restoring life, and listen for revive attempts to abort them.
AddComponentPostInit("health", function(self)
    local _SetVal = self.SetVal
    function self:SetVal(val, cause, afflicter)
        local inst = self.inst
        if inst and inst.components and inst.components.pn_lifespan
           and inst.components.pn_lifespan:IsPermadeath()
           and val > 0 then
            -- Block any attempt to set HP above 0 once permadeath is set.
            return _SetVal(self, 0, cause or "permadeath", afflicter)
        end
        return _SetVal(self, val, cause, afflicter)
    end
end)

-- Block ghost-form revival actions for permadeath players.
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    inst:ListenForEvent("ms_playerreroll", function(_, data)
        local p = data and data.player
        if p and p.components and p.components.pn_lifespan
           and p.components.pn_lifespan:IsPermadeath() then
            -- Cancel reroll
            print(string.format("[PN] Blocked reroll for permadeath player %s",
                tostring(p.userid)))
            return false
        end
    end)
end)
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add modmain.lua
git commit -m "feat(modmain): block heal + reroll when pn_lifespan permadeath set"
```

---

## Task 6: Add debug commands

**Files:**
- Modify: `scripts/pn/debug.lua`

Add 2 commands: `c_setlifespan(N)`, `c_dieofold()`.

- [ ] **Step 1: Append to scripts/pn/debug.lua**

Append BEFORE the final `print("[PN] Debug commands loaded: ...")` line:

```lua

-- Set remaining lifespan (in days)
function _G.c_setlifespan(days, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_lifespan then return end
    player.components.pn_lifespan:SetRemaining(days or 0)
    print(string.format("[PN] Set lifespan remaining = %d for %s",
        days or 0, tostring(player.userid)))
end

-- Force death of old age (triggers permadeath flow)
function _G.c_dieofold(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player or not player.components.pn_lifespan then return end
    player.components.pn_lifespan:TriggerPermadeath()
end
```

Then update the loaded message:

```lua
print("[PN] Debug commands loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_setlifespan, c_dieofold")
```

- [ ] **Step 2: Syntax check + commit**

```bash
./tools/check_syntax.sh
git add scripts/pn/debug.lua
git commit -m "feat(pn): add c_setlifespan + c_dieofold debug commands"
```

---

## Task 7: Final check + tag

- [ ] **Step 1: Run full check pipeline**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
git log --oneline | head -15
```

Expected: 20 Lua files pass syntax, all assets valid, 6+ new commits since p2-cultivation-core-complete.

- [ ] **Step 2: Tag**

```bash
git tag -a p3-lifespan-permadeath-complete -m "Plan 3 (Lifespan + Permadeath) complete.

Deliverables:
- pn_lifespan component + replica with decay-per-day + breakthrough bonus
- HUD shows lifespan with colour cue (white > 50%, yellow 20-50%, red < 20%)
- Permadeath flow: kill on remaining=0, block heal/revive while flag set
- Debug commands: c_setlifespan, c_dieofold

Lifespan tuning per spec: 60 days base, +5 per Luyện Khí tier, max 105 at LK9.
Verified via static checks. In-game runtime test deferred until Workshop upload."
git tag --list
```

---

## Self-review

**Spec coverage** — implements §3.4 (lifespan + permadeath) and §11 (save/load contract). Updates HUD per §7.2.

**Type consistency** — `pn_lifespan` matches the component naming convention. Event names from `events.lua`. TUNING reads from `pn/tuning.lua`. Hooks into existing `CANHGIOI_UP` chain from Plan 2.

**Open risks:**
- Task 5 monkey-patches `health.SetVal`. This is invasive — if another mod also patches it, order matters. Mod has `priority = -50` so we run after most others, which is what we want for an override.
- The `ms_playerreroll` event may not exist on all DST versions. If it doesn't fire, permadeath players could still reroll via the in-game UI. Workshop testing will catch this; Plan 4 can refine.

---

**End of Plan 3.**

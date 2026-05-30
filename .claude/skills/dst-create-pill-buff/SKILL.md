---
name: dst-create-pill-buff
description: Use when adding a timed buff/status effect, a đan dược (cultivation pill) consumable, or a HUD panel showing buffs in the DST mod — buff component lifecycle (attach/extend/detach), stat modifiers, buff hierarchy/replacement by tier, pill recipes that grant tu vi or buffs, client/server replica sync, and buff HUD widget layout.
---

# DST — Tạo BUFF/STATUS + ĐAN DƯỢC (Phàm Nhân Tu Tiên)

How to build timed buffs, cultivation pills, replica sync, and a buff HUD in this mod.
Studied from ref mod 3046680574 (`docs/analysis/refmods/3046680574-shanhai.md`) and verified against
`docs/analysis/dst-api-foundation.md`. Item-prefab/food basics live in **dst-create-item-food** — this
skill only covers the buff + pill-effect layer. Cross-link, don't duplicate.

## Kiến trúc / Bootstrap (where things register)

`modmain.lua` is thin → `scripts/main/import.lua` modimports the rest. Register new pieces there:
- New server component → `scripts/components/X.lua`, replica → `scripts/components/X_replica.lua`,
  then add `AddReplicableComponent("X")` in `scripts/main/components.lua`.
- Add component to players: in a bootstrap file use `AddPlayerPostInit` guarded by `if not TheWorld.ismastersim then return end`.
- New widget → `scripts/widgets/X.lua`, mounted in `scripts/main/widgets.lua` via `AddClassPostConstruct("widgets/controls", ...)`.
- Buff prefabs / pill prefabs → registered through `scripts/main/assets.lua` / prefab list.
- Events use string constants in `scripts/pn/events.lua`; balance numbers go in `scripts/pn/config.lua` (never inline).

DST golden rule: gameplay mutation is **server-only** (`TheWorld.ismastersim`); client only reads replicas.

## 1. Buff component pattern (data table + factory)

A buff is an invisible prefab parented to the target, driven by the stock `debuff` component + a `timer`.
Define each buff in one data table with three lifecycle callbacks. `type`+`level` give auto-replacement.

```lua
-- scripts/pn/buff_data.lua
BUFF_LEVEL = { H = 0, X = 1, D = 2, T = 3 }   -- Hoàng/Huyền/Địa/Thiên tier
return {
  pn_huyetkhi_h = {
    type = "huyetkhi", level = BUFF_LEVEL.H,
    duration = TUNING.TOTAL_DAY_TIME * 3,
    tex = "buff_huyetkhi", str = "Hoàng cấp Huyết Khí Đan",
    onattachedfn = function(inst, target)              -- apply modifiers
      if target.components.combat then
        target.components.combat.externaldamagemultipliers:SetModifier(inst, 1.2, "pn_huyetkhi")
      end
    end,
    onextendedfn = function(inst, target) end,         -- re-eat: refresh, re-top-up
    ondetachedfn = function(inst, target)              -- MUST remove every modifier set above
      if target.components.combat then
        target.components.combat.externaldamagemultipliers:RemoveModifier(inst, "pn_huyetkhi")
      end
    end,
  },
}
```

**Modifier rule:** every `SetModifier(inst, val, key)` / `AddBonus(inst, val, key)` in attach needs a paired
`RemoveModifier(inst, key)` in detach, or the bonus leaks forever. Common targets:
`combat.externaldamagemultipliers`, `locomotor:SetExternalSpeedMultiplier(inst,key,m)`,
`hunger.burnratemodifiers`, `planardefense:AddBonus`, `moisture.waterproofnessmodifiers`.

Buff prefab factory (one per buff, registered in prefab list):

```lua
-- scripts/prefabs/pn_buffs.lua
local BUFFS = require("pn/buff_data")
local function MakeBuff(name, data)
  local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity); inst.Transform:SetPosition(0,0,0)
    -- HIERARCHY: drop lower-tier buff of same type; refuse if a higher one exists
    if target.components.debuffable then
      for k,v in pairs(target.components.debuffable.debuffs) do
        if v.inst and v.inst.pn_buff_type == inst.pn_buff_type then
          if v.inst.pn_buff_level < inst.pn_buff_level then target:RemoveDebuff(k)
          elseif v.inst.pn_buff_level > inst.pn_buff_level then target:RemoveDebuff(inst.components.debuff.name) end
        end
      end
    end
    if data.onattachedfn then data.onattachedfn(inst, target) end
  end
  local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform(); inst.entity:Hide(); inst.entity:AddNetwork()
    inst.persists = false; inst:AddTag("CLASSIFIED")
    inst.entity:SetPristine(); if not TheWorld.ismastersim then return inst end
    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(data.ondetachedfn)
    inst.components.debuff:SetExtendedFn(data.onextendedfn)
    inst.components.debuff.keepondespawn = true
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("buffover", data.duration)
    inst:ListenForEvent("timerdone", function(i,d)
      if d.name=="buffover" and i.components.debuff then i.components.debuff:Stop() end end)
    inst.pn_buff_type = data.type; inst.pn_buff_level = data.level or 0
    if data.on_save then inst.OnSave = data.on_save end   -- stateful buffs persist
    if data.on_load then inst.OnLoad = data.on_load end
    return inst
  end
  return Prefab(name, fn, nil, nil)
end
local prefabs = {}
for name,data in pairs(BUFFS) do table.insert(prefabs, MakeBuff(name, data)) end
return unpack(prefabs)
```

Attach a buff to a player from anywhere server-side:

```lua
target:AddDebuff(buff_name, buff_name)   -- AddDebuff(uid, prefab); re-call to extend
```

## 2. ĐAN DƯỢC (pills) — on-eat effect

Pill = a food item (build the prefab with **dst-create-item-food**) whose `edible.oneatenfn` either
attaches a buff OR grants tu vi through our `pn_tuvi` component. Pill tier/grade scales the payload.

```lua
-- Effect helper attached in the pill prefab's oneatenfn (server side)
local PILL_GRADE = { H = 1, X = 2, D = 3, T = 4 }   -- Hoàng/Huyền/Địa/Thiên
local config = require("pn/config")
local Events = require("pn/events")

-- A) buff pill: attach the matching buff
local function OnEaten_Buff(inst, eater)
  if eater.components.debuffable then eater:AddDebuff("pn_huyetkhi_h", "pn_huyetkhi_h") end
end

-- B) tu-vi pill: feed our cultivation core via the canonical event (DO NOT touch .current directly)
local function MakeTuViPill(grade)
  return function(inst, eater)
    local amount = config.TU_VI.THRESHOLD_BASE * 0.25 * grade   -- tune in config, not here
    eater:PushEvent(Events.TUVI_GAIN, { amount = amount, source = "pill" })
  end
end
-- in the pill prefab: inst.components.edible:SetOnEatenFn(MakeTuViPill(PILL_GRADE.X))
```

`PushEvent(TUVI_GAIN, {amount,source})` is the contract: `pn_tuvi` applies linh-căn multiplier, clamps to
cap, pushes to replica, fires `TUVI_CHANGED`. Higher grade → bigger amount. Use `oneatenfn = OnEaten_Buff`
for status pills (御火/御水-style) and `MakeTuViPill(grade)` for breakthrough/cultivation pills.

## 3. Replica sync (server → client, throttled)

Buff list is server truth. Sync a JSON string on a **periodic 2s task — never per-frame**.

```lua
-- scripts/components/pn_bufftime.lua  (server)
local function onbuffinfo(self, v)
  if self.inst.replica.pn_bufftime then self.inst.replica.pn_bufftime._buffinfo:set(v) end
end
local PnBuffTime = Class(function(self, inst)
  self.inst = inst; self.buffinfo = ""
  self.task = inst:DoPeriodicTask(2, function() self:Refresh() end)  -- 2s, throttled
end, nil, { buffinfo = onbuffinfo })
function PnBuffTime:Refresh()
  local out, d = {}, self.inst.components.debuffable
  if d and d.debuffs then for name,v in pairs(d.debuffs) do
    if v.inst and v.inst.components.timer then
      table.insert(out, { n = name, t = math.floor(v.inst.components.timer:GetTimeLeft("buffover") or 0) })
    end end end
  self.buffinfo = (#out > 0) and json.encode(out) or ""
end
return PnBuffTime
```

```lua
-- scripts/components/pn_bufftime_replica.lua  (client)
local PnBuffTime = Class(function(self, inst)
  self.inst = inst
  self._buffinfo = net_string(inst.GUID, "pn_bufftime._buffinfo")
end)
function PnBuffTime:Get() return self._buffinfo:value() end
return PnBuffTime
```

Register: `AddReplicableComponent("pn_bufftime")` in `scripts/main/components.lua`; add the server component
in an `AddPlayerPostInit` guarded by `if not TheWorld.ismastersim then return end`.

## 4. Buff HUD widget (horizontal cards)

Mount alongside the dantian HUD (`AddClassPostConstruct("widgets/controls", ...)`). Client reads the replica
every 1s, lays cards out horizontally, shows/hides by count.

```lua
-- scripts/widgets/pn_buff_panel.lua
local Widget, Image, Text = require("widgets/widget"), require("widgets/image"), require("widgets/text")
local BUFFS = require("pn/buff_data")
local CARD, MAXN, ATLAS = 48, 12, "images/pn_buffs.xml"
local function fmt(t) if t > 99999999 then return "∞" end
  return string.format("%02d:%02d", math.floor(t/60), math.floor(t%60)) end

local PnBuffPanel = Class(Widget, function(self, owner)
  Widget._ctor(self, "PnBuffPanel"); self.owner = owner
  self.cards = {}
  for i=1,MAXN do
    local w = self:AddChild(Widget())
    w:SetPosition(CARD * (i-1), 0)                 -- horizontal: offset * index
    w.img  = w:AddChild(Image(ATLAS, "blank.tex")); w.img:SetSize(CARD, CARD)
    w.time = w:AddChild(Text(CHATFONT, 18, "")); w.time:SetPosition(0, -CARD*0.6)
    w:Hide(); self.cards[i] = w
  end
  self:StartUpdating()
end)

function PnBuffPanel:OnUpdate(dt)
  self._t = (self._t or 0) + dt; if self._t < 1 then return end; self._t = 0
  local rep = self.owner and self.owner.replica.pn_bufftime
  local s = rep and rep:Get(); local data = s and s ~= "" and json.decode(s)
  local n = 0
  if data then for _,b in ipairs(data) do
    local def = BUFFS[b.n]; if def then
      n = n + 1; local c = self.cards[n]
      c.img:SetTexture(ATLAS, def.tex..".tex")
      c.img:SetSize(CARD, CARD)        -- CRITICAL: SetTexture resets to native size — re-apply SetSize AFTER it
      c.time:SetString(fmt(b.t)); c:Show()
      if n >= MAXN then break end
    end end end
  for i=n+1,MAXN do self.cards[i]:Hide() end
end
return PnBuffPanel
```

> ⚠️ **Image:SetTexture resets size to the atlas region's native dimensions.** Always call `SetSize` *after*
> every `SetTexture`, never only once at construction. We hit this exact bug on the dantian medallion
> (`scripts/widgets/pn_hud_dantian.lua`) — re-applying `SetSize` after `SetTexture` is the fix.

## 5. Integration với cultivation core

- Tu-vi pills → `PushEvent(Events.TUVI_GAIN, {amount, source})`; `pn_tuvi` does the rest. Never write
  `replica.pn_tuvi` or `tuvi.current` from a pill.
- Realm-gated effects: read `target.replica.pn_canhgioi` (client) / canhgioi component (server) to scale or
  gate a buff by tier; listen `Events.CANHGIOI_UP` to grant/strip realm buffs on breakthrough.
- Stat-per-layer numbers already live in `config.STATS_PER_LAYER` — reuse, don't invent parallel constants.
- Event + tuning names: `scripts/pn/events.lua`, `scripts/pn/config.lua` only.

## Checklist (mỗi buff/pill mới)

- [ ] Buff entry in `buff_data.lua` with attach **and** matching detach removals.
- [ ] `type`+`level` set for auto-replacement; stateful buffs add `on_save`/`on_load`.
- [ ] Buff prefab guards `if not TheWorld.ismastersim then return inst end` after `SetPristine`.
- [ ] Pill prefab built via **dst-create-item-food**; `oneatenfn` attaches buff or fires `TUVI_GAIN`.
- [ ] Replica via `net_string` JSON, refreshed on a **2s periodic task** (not per-frame); `AddReplicableComponent` registered.
- [ ] HUD re-applies `SetSize` after every `SetTexture`.

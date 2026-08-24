---
name: dst-mob-ai-mount
description: Use when modifying monster AI/brains, scaling or buffing mobs (world-scaling), adding new behaviors via stategraphs, cleanly hooking vanilla prefabs (AddPrefabPostInit/AddStategraphPostInit), or building a rideable mount / phi kiếm (flying sword) travel mechanic in the DST mod.
---

# DST Mob AI, Buffs & Mounts (Phàm Nhân Tu Tiên)

Cách thêm/sửa AI quái (brain + stategraph), buff/scale quái theo tu vi, và làm
**mount cưỡi được** (kể cả **phi kiếm** bay). Tham chiếu mod Move!!Dragonfly
(`reference/workshop-mods/3670669065/`) đã được phân tích trong
`docs/analysis/refmods/3670669065-dragonfly.md`.

## Kiến trúc bootstrap của mod (đọc trước)

- `modmain.lua` là entry mỏng: chỉ `modimport("scripts/main/import.lua")`.
  `env` có metatable fallback về `GLOBAL`, nên **trong `scripts/main/*` các global
  như `AddPrefabPostInit`, `TheWorld`, `TUNING` đã có sẵn — không cần `GLOBAL.`**
  (mob_hooks.lua dùng `GLOBAL.require`/`GLOBAL.TheWorld` để rõ ràng; cả hai đều chạy).
- File trong `scripts/prefabs/*`, `scripts/brains/*`, `scripts/components/*` chạy ở
  **strict mode**: global thật (`Class`, `Brain`, `PriorityNode`, `SpawnPrefab`,
  `State`, `TimeEvent`) dùng trực tiếp, **KHÔNG** wrap `GLOBAL.`. Global do mod tự
  định nghĩa phải khai báo trước trong modmain.
- Balance đặt trong `scripts/pn/config.lua`, không hardcode trong logic.

---

## 1. Override prefab sạch vs. dựng prefab mới

**Khi nào dùng `AddPrefabPostInit` (sửa quái vanilla):** chỉ buff stat, thêm loot,
gắn listener, đổi tốc độ. KHÔNG đập vỡ prefab gốc. Đây là cách `mob_hooks.lua`
buff HP/dmg + grant tu vi.

Quy tắc bắt buộc (xem `scripts/main/mob_hooks.lua`):
1. **Guard `TheWorld.ismastersim`** ở dòng đầu — logic gameplay chỉ chạy server.
   `ismastersim == true` trên **cả master lẫn cave shard**.
2. **Chống double-buff / re-entrancy**: PostInit có thể chạy lại; đặt cờ trên inst.

```lua
AddPrefabPostInit("hound", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    if inst._pn_buffed then return end   -- chống nhân đôi buff
    inst._pn_buffed = true
    local m = config.MOB_BUFF.hp_mult
    if inst.components.health then
        inst.components.health:SetMaxHealth(inst.components.health.maxhealth * m)
        inst.components.health:SetPercent(1)
    end
    if inst.components.combat then
        inst.components.combat.damagemultiplier =
            (inst.components.combat.damagemultiplier or 1) * config.MOB_BUFF.dmg_mult
    end
end)
```

**Khi nào dựng prefab mới từ đầu:** khi cần thay đổi căn bản — physics bay, bộ
component lớn (rideable/hunger/growable), brain riêng. Dragonfly mod KHÔNG sửa
dragonfly gốc thành mount; nó tạo prefab riêng `dragonfly_mount` và chỉ thêm loot
vào dragonfly vanilla. Composition > mutation: dễ bật/tắt, không xung đột vanilla.

---

## 2. Brain / behavior tree

Brain dùng **behavior tree** (`PriorityNode` + behaviours), không phải state machine
phẳng. PriorityNode chạy node đầu tiên thỏa điều kiện, tự rơi xuống node sau.

```lua
-- scripts/brains/pn_spirit_brain.lua  (strict mode: KHÔNG GLOBAL.)
local SpiritBrain = Class(Brain, function(self, inst) Brain._ctor(self, inst) end)
function SpiritBrain:OnStart()
    local root = PriorityNode({
        WhileNode(function() return self.inst.targetmem.flee end, "Flee",
            RunAway(self.inst, "scarytoprey", 6, 10)),
        ChaseAndAttack(self.inst, 12),
        Wander(self.inst, function() return self.inst.spawnpt end, 8),
    }, 0.25)
    self.bt = BT(self.inst, root)
end
return SpiritBrain
```

**Target memory** (né thông minh): mỗi frame ghi state/khoảng cách của mục tiêu để
quyết né. Hook `combat.SetTarget` để gắn listener khi có mục tiêu mới:

```lua
inst.targetmem = { flee = false }
local _SetTarget = inst.components.combat.SetTarget
inst.components.combat.SetTarget = function(self, target, ...)
    _SetTarget(self, target, ...)
    if target then inst:DoPeriodicTask(0, function()
        inst.targetmem.distsq = inst:GetDistanceSqToInst(target)
        local sg = target.sg
        inst.targetmem.flee = sg and sg:HasStateTag("attack")
            and (inst.targetmem.distsq or 1e6) < 9
    end) end
end
```

Gắn brain: `inst:SetBrain(GLOBAL.require("brains/pn_spirit_brain"))` (trong prefab
file dùng `require("brains/...")` trực tiếp).

---

## 3. Sửa stategraph (thêm state / chặn event)

`AddStategraphPostInit` để **thêm state mới và override behavior gốc mà không phá vỡ**.

```lua
AddStategraphPostInit("hound", function(sg)
    sg.states.pn_dash = State{           -- state mới
        name = "pn_dash", tags = {"busy", "nointerrupt"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:SetMotorVelOverride(20, 0, 0)  -- lao tới
        end,
        onexit = function(inst) inst.Physics:ClearMotorVelOverride() end,
        timeline = { TimeEvent(8*FRAMES, function(inst) inst.sg:GoToState("idle") end) },
    }
    local old_idle = sg.states.idle.onenter   -- bọc, KHÔNG thay thế
    sg.states.idle.onenter = function(inst, ...)
        if inst:HasTag("pn_enraged") then return inst.sg:GoToState("pn_dash") end
        return old_idle(inst, ...)
    end
end)
```

**Hijack di chuyển/animation**: bọc `sg.events.locomote.fn` và tạm override
`inst.sg.GoToState` bên trong để chuyển hướng `run_start` → state custom (kỹ thuật
dragonfly dùng cho rider — tránh chép lại toàn bộ logic locomote):

```lua
local _loco = sg.events.locomote.fn
sg.events.locomote.fn = function(inst, data)
    local mount = inst.replica.rider and inst.replica.rider:GetMount()
    if not (mount and mount:HasTag("pn_feijian")) then return _loco(inst, data) end
    local _goto = inst.sg.GoToState
    inst.sg.GoToState = function(self, st, ...)
        if st == "run_start" then st = "feijian_fly_pre" end
        return _goto(self, st, ...)
    end
    _loco(inst, data)
    inst.sg.GoToState = _goto   -- khôi phục ngay
end
```

---

## 4. World-scaling (preview milestone)

Hiện `mob_hooks.lua` buff tĩnh từ `config.MOB_BUFF`. Bước tiếp theo: nhân stat
**theo tier tu vi của người chơi / world-tier**, data-driven từ config.

```lua
-- config.lua thêm:
-- SCALE_BY_TIER = { [1]=1.0, [2]=1.3, [3]=1.7, [4]=2.2, [5]=3.0 }
local function ScaledMult(base_mult)
    local tier = GLOBAL.TheWorld.components.pn_worldtier  -- component sẽ thêm sau
    local t = tier and tier:GetTier() or 1
    return base_mult * (config.SCALE_BY_TIER[t] or 1.0)
end
-- dùng ScaledMult(config.MOB_BUFF.hp_mult) thay cho m trong PatchMob.
```

Tách dữ liệu (bảng nhân theo tier) khỏi logic; tier đọc từ component thế giới.
Chỉ apply 1 lần khi spawn (giữ cờ `_pn_buffed`), không re-scale động trừ khi có
event đổi tier rõ ràng — re-scale động dễ làm HP nhảy lung tung.

---

## 5. Mount cưỡi được + template phi kiếm

Checklist (từ §6.2 doc dragonfly): `rideable` + `follower` + `locomotor` (pathcaps
bay) + tag `flying` + physics override + stategraph rider + player postinit.

```lua
-- scripts/prefabs/pn_feijian.lua  (master_postinit, sau if not TheWorld.ismastersim)
inst:AddTag("pn_feijian")
inst:AddComponent("locomotor")
inst.components.locomotor.pathcaps = { ignorewalls = true, allowocean = true }
inst.components.locomotor.runspeed = 10
inst:AddComponent("follower")           -- trước rideable
inst:AddComponent("rideable")
inst.components.rideable:SetSaddleable(true)
inst.components.rideable:SetCustomRiderTest(function(inst, rider)
    return rider:HasTag("phamnhan")     -- chỉ tu sĩ mới cưỡi phi kiếm
end)
inst:SetStateGraph("SGpn_feijian")      -- gắn SG trước
inst:SetBrain(require("brains/pn_feijian_brain"))   -- rồi brain
```

State locomotion của mount (trong `SGpn_feijian`):

```lua
State{ name = "fly_loop", tags = {"moving","canrotate","flight"},
    onenter = function(inst)
        inst.components.locomotor:RunForward()
        inst.AnimState:PlayAnimation("fly_loop", true)
    end }
```

Player postinit khi cưỡi: thêm tag `flying`, tắt drowning, đổi collision mask để
no-clip; khi xuống thì khôi phục (xem `postinit/prefabs/player.lua` của dragonfly).
Saddle là prefab item riêng với component `saddler` (`SetBonusSpeedMult`,
`SetBonusDamage`) + `finiteuses` (độ bền) nếu cần buff khi cưỡi.

---

## 6. Pitfalls

- **GLOBAL scope**: trong `scripts/main/*` global đã có sẵn (env fallback). Trong
  `scripts/prefabs|brains|components/*` (strict mode) **dùng global thật, không
  `GLOBAL.`**; ngược lại trong modmain phải `GLOBAL.`.
- **`ismastersim`**: luôn guard logic gameplay. `true` trên cả master và cave —
  nếu chỉ muốn master: `TheWorld.ismastersim and not TheWorld:HasTag("cave")`.
- **Event names**: dùng `"death"` (không phải `"die"`); killer lấy từ
  `inst.components.combat.lastattacker` và kiểm tra `HasTag("phamnhan")` trước khi
  grant tu vi (như mob_hooks.lua).
- **Re-entrancy**: PostInit/buff chạy lại → giữ cờ `_pn_buffed` chống nhân đôi.
- **Thứ tự attach**: `SetStateGraph` trước, `SetBrain` sau.
- **GoToState hijack**: luôn khôi phục `inst.sg.GoToState` gốc ngay sau khi gọi,
  nếu không sẽ rò rỉ sang state transition khác.
- **Component order**: `follower` trước `rideable`.

---

## File reference

| Việc | File |
|------|------|
| Buff + tu vi hook hiện tại | `scripts/main/mob_hooks.lua` |
| Balance (mult, tier, tuvi/kill) | `scripts/pn/config.lua` |
| Mod reference đầy đủ | `reference/workshop-mods/3670669065/` |
| Phân tích chi tiết | `docs/analysis/refmods/3670669065-dragonfly.md` |
| API/pitfall verified | `docs/analysis/dst-api-foundation.md` |

# DST API Foundation — Tài liệu tham chiếu cho mod Tu Tiên

> Tài liệu này được rút ra trực tiếp từ source code thật của game tại
> `reference/dst-scripts/scripts/`. **Mọi tên API đều được verify với file thật**
> (có ghi `file:line`). Mục tiêu: tránh lặp lại ~19 vòng fix bug do dùng sai API
> như lần trước.
>
> Quy ước: mọi đường dẫn `file:line` đều tương đối với
> `reference/dst-scripts/scripts/`. Code/identifier giữ nguyên gốc tiếng Anh.

---

## 1. Môi trường mod (Mod environment)

### 1.1 Hai môi trường hoàn toàn khác nhau

Có **hai loại context** khi viết mod, và đây là nguồn gốc của rất nhiều bug:

| Context | File | Có `GLOBAL`? | Có `env`? | Strict mode? |
|---|---|---|---|---|
| **modmain.lua / modworldgenmain.lua** | chạy trong `env` sandbox | ✅ CÓ | ✅ CÓ (chính là fenv) | sandbox riêng |
| **scripts/components/\*.lua, prefabs/\*.lua** (nạp qua `require`) | chạy trong `_G` thật + `strict.lua` | ❌ KHÔNG | ❌ KHÔNG | ✅ chặn biến chưa khai báo |

**Bằng chứng:**

- `env` được tạo trong `CreateEnvironment` ở `mods.lua:295`, và bảng env chứa
  `GLOBAL = _G` (`mods.lua:327`) cùng `env.modname`, `env.MODROOT`. Tức là
  `GLOBAL` **chỉ tồn tại bên trong modmain**, không phải mọi nơi.
- `strict.lua:8-27`: khi `__STRICT = true`, mọi truy cập biến global chưa
  `global("x")` sẽ `error("variable 'x' is not declared")`. File component/prefab
  nạp qua `require` chạy trong `_G` này.

**Hệ quả thực tế (PITFALL #1):**

```lua
-- modmain.lua — ĐÚNG: phải qua GLOBAL
local TUNING = GLOBAL.TUNING
local TheWorld = GLOBAL.TheWorld
local require = GLOBAL.require
GLOBAL.TUNING.PHAMNHAN_TUVI_MAX = 1000

-- scripts/prefabs/feijian.lua — ĐÚNG: dùng global trực tiếp, KHÔNG có GLOBAL
local assets = { Asset("ANIM", "anim/feijian.zip") }   -- Asset là global thật
local inst = CreateEntity()                            -- OK
-- GLOBAL.TheWorld  -> SAI: 'GLOBAL' is not declared (strict.lua error)
local x = TheWorld.ismastersim                          -- ĐÚNG
```

Trong file prefab/component, các global như `CreateEntity`, `Prefab`, `Asset`,
`TUNING`, `TheWorld`, `TheNet`, `ACTIONS`, `EQUIPSLOTS`, `FOODTYPE`,
`SpawnPrefab`, `MakeInventoryPhysics`... đều có sẵn (đã `global()` ở `consts.lua`,
`mainfunctions.lua`, v.v.). **Không** wrap bằng `GLOBAL`.

> Nếu trong file prefab cần một global mod tự định nghĩa, hãy khai báo trong
> modmain: `GLOBAL.global("MY_MOD_SHARED")` rồi gán, hoặc tốt hơn là dùng
> `modimport` / require module thường.

### 1.2 Bảng Add\* API (verify với `modutil.lua`)

Tất cả gắn vào `env` trong `InsertPostInitFunctions` (`modutil.lua`), nên gọi
**trong modmain** (không cần `GLOBAL.`):

| Hàm | Signature | Dùng khi nào | Verify |
|---|---|---|---|
| `AddModCharacter` | `(name, gender, modes)` | Đăng ký nhân vật custom. `gender`: "MALE"/"FEMALE"/"ROBOT"/"NEUTRAL"/"PLURAL" | `modutil.lua:73, 655` |
| `RemoveDefaultCharacter` | `(name)` | Ẩn nhân vật gốc | `modutil.lua:92, 660` |
| `AddComponentPostInit` | `(component, fn)` — fn(self) self là component | Patch một component có sẵn (vd "health") cho MỌI entity | `modutil.lua:567` |
| `AddPrefabPostInit` | `(prefab, fn)` — fn(inst) | Patch một prefab cụ thể sau khi spawn (vd "world", "wilson") | `modutil.lua:593` |
| `AddPrefabPostInitAny` | `(fn)` — fn(inst) | Chạy trên MỌI prefab (cẩn thận performance) | `modutil.lua:580` |
| `AddPlayerPostInit` | `(fn)` — fn(inst) chỉ entity có tag "player" | Thêm component/logic cho mọi người chơi | `modutil.lua:586` |
| `AddClassPostConstruct` | `(package, postfn)` — postfn(self,...) | Patch class (vd "widgets/controls") sau ctor | `modutil.lua:351` |
| `AddGlobalClassPostConstruct` | `(package, classname, fn)` | Như trên nhưng cho class lồng trong package | `modutil.lua:346` |
| `AddReplicableComponent` | `(name)` | Đăng ký component có replica để engine sync | `modutil.lua:852` → `entityreplica.lua:98` |
| `AddAction` | `(id, str, fn)` | Tạo Action mới; trả về object Action | `modutil.lua:442` |
| `AddComponentAction` | `(actiontype, component, fn)` | Gắn action vào component (xem §6) | `modutil.lua:478` → `componentactions.lua:3079` |
| `AddStategraphActionHandler` | `(stategraph, handler)` | Thêm ActionHandler vào SG có sẵn | `modutil.lua:518` |
| `AddStategraphState` | `(stategraph, state)` | Thêm State | `modutil.lua:527` |
| `AddStategraphPostInit` | `(stategraph, fn)` | Patch toàn SG | `modutil.lua:557` |
| `AddBrainPostInit` | `(brain, fn)` | Patch brain mob | `modutil.lua:627` |
| `AddRecipe2` | `(name, ingredients, tech, config, filters)` | Công thức chế tạo (API mới) | `modutil.lua:732` |
| `AddCharacterRecipe` | `(name, ingredients, tech, config, extra_filters)` | Recipe riêng nhân vật | `modutil.lua:758` |
| `AddMinimapAtlas` | `(atlaspath)` | Đăng ký atlas icon minimap | `modutil.lua:512` |
| `AddSimPostInit` / `AddGamePostInit` | `(fn)` | Hook sau khi sim/game init | `modutil.lua:341, 335` |

`Prefab`, `Asset`, `Ingredient`, `Class` cũng có sẵn trong env
(`mods.lua:309`, `modutil.lua:830-834`).

---

## 2. Custom character (MakePlayerCharacter)

### 2.1 Signature — VERIFY thứ tự tham số

```lua
-- prefabs/player_common.lua:1980
local function MakePlayerCharacter(name, customprefabs, customassets,
                                   common_postinit, master_postinit,
                                   starting_inventory)
```

Thứ tự **chính xác**: `name, customprefabs, customassets, common_postinit,
master_postinit, starting_inventory`. Hàm trả về `Prefab(name, fn, assets, prefabs)`
(`player_common.lua:2982`).

Trong modmain, dùng qua GLOBAL:

```lua
-- modmain.lua
local MakePlayerCharacter = GLOBAL.require("prefabs/player_common")

local prefabs = {}
local assets = {
    Asset("ANIM", "anim/phamnhan.zip"),
    Asset("ANIM", "anim/ghost_phamnhan_build.zip"),
}

local function common_postinit(inst) -- chạy CLIENT + SERVER
    -- visual / HUD setup ở ĐÂY
end

local function master_postinit(inst) -- chỉ SERVER (ismastersim)
    inst.components.health:SetMaxHealth(GLOBAL.TUNING.WILSON_HEALTH)
    inst.components.hunger:SetMax(GLOBAL.TUNING.WILSON_HUNGER)
    inst.components.sanity:SetMax(GLOBAL.TUNING.WILSON_SANITY)
    inst.components.locomotor.walkspeed = GLOBAL.TUNING.WILSON_WALK_SPEED
end

return MakePlayerCharacter("phamnhan", prefabs, assets,
                           common_postinit, master_postinit)
```

### 2.2 common_postinit vs master_postinit (PITFALL #5)

- `common_postinit(inst)` được gọi tại `player_common.lua:2546` — **chạy cả client
  lẫn server**. Mọi thứ liên quan **hiển thị/visual và replica** phải đặt ở đây
  (vd: `OverrideSymbol` cố định, gắn widget data, set scale).
- `master_postinit(inst)` được gọi tại `player_common.lua:2937` — **chỉ server**
  (`if master_postinit ~= nil then master_postinit(inst) end`, nằm sau khối
  `if not TheWorld.ismastersim then return inst end`). Mọi logic gameplay thật
  (component server-side: health, hunger, combat, custom tu-vi component) đặt ở đây.

Bằng chứng visual nằm trong common: `SetBank("wilson")`, `SetBuild(name)`,
`MakeCharacterPhysics`, `AddTag("player")` đều ở vùng `player_common.lua:2425-2460`,
TRƯỚC khi `master_postinit` được gọi.

### 2.3 Quy tắc tên build (PITFALL #8)

Tại `player_common.lua:2432`: `inst.AnimState:SetBuild(name)`. Tức là engine set
build = đúng tên prefab nhân vật. **Tên build nội bộ trong `build.bin` của bạn
PHẢI trùng tên prefab** (vd prefab `phamnhan` → file art build cũng tên `phamnhan`).
Sai tên build = nhân vật vô hình / dùng nhầm build wilson.

Ngoài ra cần `Asset("ANIM", "anim/ghost_<name>_build.zip")` cho dạng ma, và icon
minimap `inst.MiniMapEntity:SetIcon(name..".png")` (`player_common.lua:2441`).

---

## 3. Components & Replicas

### 3.1 Mô hình tổng quát

- **Component server-side**: `scripts/components/<tên>.lua` — chỉ tồn tại trên
  master sim, chứa state thật + logic.
- **Replica client-side**: `scripts/components/<tên>_replica.lua` — bản sao đọc
  được trên client, dùng `net_*` vars để sync.
- Đăng ký để engine biết tạo replica: `AddReplicableComponent("tuvi")`
  (`modutil.lua:852` → set `REPLICATABLE_COMPONENTS[name] = true` tại
  `entityreplica.lua:98`).

### 3.2 net_\* types (verify `netvars.lua:6-19`)

| Type | Tầm trị | Ghi chú |
|---|---|---|
| `net_bool` | 0/1 | 1-bit |
| `net_smallbyte` | 0..63 | 6-bit |
| `net_byte` | 0..255 | 8-bit |
| `net_shortint` | -32767..32767 | 16-bit signed |
| `net_ushortint` | 0..65535 | 16-bit unsigned |
| `net_int` | ±2.1 tỷ | 32-bit signed |
| `net_uint` | 0..4.29 tỷ | 32-bit unsigned |
| `net_float` | 32-bit float | |
| `net_hash` | hash chuỗi | set bằng string hoặc hash |
| `net_string` | chuỗi dài tùy biến | tốn băng thông, hạn chế dùng |
| `net_entity` | 1 entity | |
| `net_bytearray` / `net_smallbytearray` | mảng ≤31 phần tử | |

Constructor: `net_<type>(GUID, name, dirtyevent)` — verify ở
`sanity_replica.lua:6`:

```lua
self._issane = net_bool(inst.GUID, "sanity._issane", "issanedirty")
```

Tham số 3 là **tên event** sẽ được push trên client khi giá trị thay đổi.

### 3.3 Mẫu component + replica đầy đủ (tu-vi làm ví dụ)

**`scripts/components/tuvi.lua`** (server):

```lua
local Tuvi = Class(function(self, inst)
    self.inst = inst
    self.current = 0
    self.max = 1000
end)

function Tuvi:SetCurrent(v)
    self.current = math.clamp(v, 0, self.max)
    -- đẩy state xuống replica (chạy trên server, replica đọc qua net var):
    if self.inst.replica.tuvi ~= nil then
        self.inst.replica.tuvi:SetCurrent(self.current)
    end
    self.inst:PushEvent("tuvidelta", { current = self.current, max = self.max })
end

function Tuvi:OnSave() return { current = self.current, max = self.max } end
function Tuvi:OnLoad(data)
    if data then self.max = data.max or self.max; self:SetCurrent(data.current or 0) end
end

return Tuvi
```

**`scripts/components/tuvi_replica.lua`** (client):

```lua
local TuviReplica = Class(function(self, inst)
    self.inst = inst
    self._current = net_float(inst.GUID, "tuvi._current", "tuvidirty")
    self._max     = net_float(inst.GUID, "tuvi._max",     "tuvidirty")
end)

-- gọi từ server component
function TuviReplica:SetCurrent(v) self._current:set(v) end
function TuviReplica:SetMax(v)     self._max:set(v) end

-- client đọc:
function TuviReplica:GetCurrent() return self._current:value() end
function TuviReplica:GetMax()     return self._max:value() end
```

Trong modmain:

```lua
GLOBAL.require("components/tuvi")
GLOBAL.require("components/tuvi_replica")
AddReplicableComponent("tuvi")
AddPlayerPostInit(function(inst)
    if inst.components.tuvi == nil and GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("tuvi")
    end
end)
```

**Mẫu dirty-event trên client** (verify `sanity_replica.lua:32-68`):

```lua
local function OnTuviDirty(inst)
    -- chạy trên client khi net var đổi; cập nhật widget/HUD ở đây
    inst:PushEvent("tuvihudupdate")
end
-- trong OnReplicaConstruct / khi gắn:
self.inst:ListenForEvent("tuvidirty", OnTuviDirty)
```

> Với các net var dùng chung 1 dirty event ("tuvidirty"), khi BẤT KỲ var nào đổi,
> event được push một lần — đọc lại tất cả var trong handler.

> `:set(v)` chỉ trigger dirty nếu giá trị thực sự khác; muốn force luôn push
> initial state, set sau khi entity đã có network (sau `master_postinit`).

---

## 4. Custom prefabs

### 4.1 Khung dựng entity + ismastersim split (verify `prefabs/axe.lua:43-90`)

```lua
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()      -- BẮT BUỘC nếu entity cần sync

    MakeInventoryPhysics(inst)    -- hoặc MakeObstaclePhysics(inst, radius) cho vật cản

    inst.AnimState:SetBank("feijian")
    inst.AnimState:SetBuild("feijian")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")         -- tag thêm vào pristine state để client biết trước

    inst.entity:SetPristine()     -- chốt phần "tiền-mạng"; SAU dòng này là server-only

    if not TheWorld.ismastersim then
        return inst                -- client dừng ở đây
    end

    -- ===== chỉ chạy SERVER =====
    inst:AddComponent("inventoryitem")
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)

    return inst
end

return Prefab("feijian", fn, assets, prefabs)
```

**Quy tắc vàng:** mọi thứ TRƯỚC `SetPristine()` chạy cả client+server (visual,
tags, bank/build). Mọi `AddComponent` chạy SAU `if not TheWorld.ismastersim then
return inst end`.

### 4.2 PITFALL #6 — `ismastersim` đúng trên CẢ hai shard

`TheWorld.ismastersim` = `true` trên **cả master world lẫn cave** (mỗi shard có
master sim riêng). Muốn phân biệt loại shard, dùng tag:

```lua
-- SAI: tưởng chỉ chạy ở mặt đất
if TheWorld.ismastersim then ... end
-- ĐÚNG: gate theo loại shard
if TheWorld.ismastersim and not TheWorld:HasTag("cave") then
    -- chỉ mặt đất (overworld)
end
if TheWorld:HasTag("cave") then -- chỉ hang động
end
```

### 4.3 Anim bank/build & swap (PITFALL #2)

- `SetBank(bank)` = bộ animation (skeleton); `SetBuild(build)` = bộ texture/symbol;
  `PlayAnimation(anim [, loop])`.
- Các loại gem dùng chung bank/build `"gems"` rồi đổi symbol — nhiều prefab share
  một bank/build, phân biệt bằng symbol.
- **Swap khi cầm trên tay** (vũ khí): không đổi build của người chơi, mà override
  symbol `"swap_object"` trên AnimState của owner (verify `axe.lua:20-30`):

```lua
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_feijian", "swap_feijian")
    --                              ^slot          ^build           ^symbol trong build
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("swap_object")
end
```

Cần asset `Asset("ANIM", "anim/swap_feijian.zip")` riêng cho build swap.

---

## 5. Items & equipment

### 5.1 inventoryitem — imagename vs atlasname (PITFALL #3)

Verify `components/inventoryitem.lua:1-6, 72-95, 365`:

```lua
local function onatlasname(self, atlasname) self.inst.replica.inventoryitem:SetAtlas(atlasname) end
local function onimagename(self, imagename) self.inst.replica.inventoryitem:SetImage(imagename) end
```

- `inst.components.inventoryitem.imagename` = tên ảnh (icon) bên trong atlas, KHÔNG
  có phần mở rộng (vd `"feijian"`).
- `inst.components.inventoryitem.atlasname` = **đường dẫn tới file .xml atlas do MOD
  ship kèm**, ví dụ `"images/inventoryimages/feijian.xml"`.

```lua
inst.components.inventoryitem.atlasname = "images/inventoryimages/feijian.xml"
inst.components.inventoryitem.imagename = "feijian"
```

**KHÔNG bao giờ** trỏ `atlasname` vào atlas gốc của game (bundled, không truy cập
được runtime) — đây chính là một trong các nguyên nhân icon không hiện ở lần trước.
Phải khai báo asset:

```lua
Asset("ATLAS", "images/inventoryimages/feijian.xml"),
Asset("IMAGE", "images/inventoryimages/feijian.tex"),
```

### 5.2 equippable (verify `components/equippable.lua:29-77`)

```lua
inst:AddComponent("equippable")
inst.components.equippable.equipslot = EQUIPSLOTS.HANDS  -- default đã là HANDS
inst.components.equippable:SetOnEquip(onequip)           -- :SetOnEquip(fn) -> self.onequipfn
inst.components.equippable:SetOnUnequip(onunequip)       -- :SetOnUnequip(fn) -> self.onunequipfn
```

`onequip(inst, owner)` / `onunequip(inst, owner)` chính là nơi gọi `OverrideSymbol`
ở §4.3.

### 5.3 weapon (verify `components/weapon.lua:44-53`)

```lua
inst:AddComponent("weapon")
inst.components.weapon:SetDamage(34)
inst.components.weapon:SetRange(attack_range, hit_range)  -- :SetRange(attack, hit)
inst.components.weapon:SetOnAttack(function(inst, attacker, target) ... end)
```

### 5.4 edible (verify `components/edible.lua:24-52`)

```lua
inst:AddComponent("edible")
inst.components.edible.foodtype = FOODTYPE.GENERIC        -- secondaryfoodtype tùy chọn
inst.components.edible.healthvalue = 10
inst.components.edible.hungervalue = 25
inst.components.edible.sanityvalue = 5
-- oneaten là CALLBACK trên component (edible.lua:26), KHÔNG phải event:
inst.components.edible.oneaten = function(inst, eater)
    if eater.components.tuvi then eater.components.tuvi:SetCurrent(...) end
end
```

> Lưu ý: eater còn push event `"oneat"` riêng; nhưng để gắn hiệu ứng món ăn dùng
> field `edible.oneaten`.

### 5.5 finiteuses & stackable (verify `prefabs/axe.lua:79-86`)

```lua
inst:AddComponent("finiteuses")
inst.components.finiteuses:SetMaxUses(TUNING.AXE_USES)
inst.components.finiteuses:SetUses(TUNING.AXE_USES)
inst.components.finiteuses:SetOnFinished(inst.Remove)
inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)

-- stackable:
inst:AddComponent("stackable")
inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
```

---

## 6. Actions

### 6.1 AddAction (verify `modutil.lua:442`)

```lua
-- modmain.lua
local TUTIEN_MEDITATE = AddAction("TUTIEN_MEDITATE", "Đả tọa", function(act)
    local doer = act.doer
    if doer and doer.components.tuvi then
        doer.components.tuvi:SetCurrent(doer.components.tuvi.current + 10)
        return true
    end
    return false
end)
-- ACTIONS[id] được set + STRINGS.ACTIONS[id] = str (modutil.lua:471-474)
```

### 6.2 AddComponentAction — loại nào chạy CLIENT-side?

`AddComponentAction(actiontype, component, fn)` (`modutil.lua:478`). Các loại
actiontype và signature của fn (verify trong `componentactions.lua`):

| actiontype | fn args | Verify | Ý nghĩa |
|---|---|---|---|
| `"SCENE"` | `inst, doer, actions, right` | `componentactions.lua:140` | Hành động lên entity trong thế giới |
| `"USEITEM"` | `inst, doer, target, actions, right` | `:1036` | Dùng item trong túi lên target |
| `"POINT"` | `inst, doer, pos, actions, right, target` | `:1982` | Nhắm vào một điểm |
| `"EQUIPPED"` | `inst, doer, target, actions, right` | `:2195` | Item đang trang bị tác động target |
| `"INVENTORY"` | `inst, doer, actions, right` | `:2495` | Hành động trên item trong túi |
| `"ISVALID"` | `inst, action, right` | `:3020` | Kiểm tra hợp lệ |

> **Quan trọng (collection client-side):** việc *thu thập danh sách action khả dụng*
> (component actions) chạy trên client để hiển thị nút bấm — vì vậy `fn` trong
> `AddComponentAction` phải an toàn khi gọi ở client (chỉ đọc tag/replica, KHÔNG
> đọc `inst.components.<server>` vì client không có). Hành động được register qua
> `RegisterComponentActions` (`componentactions.lua:3092`) và sync xuống replica
> bằng `actionreplica.actioncomponents:set(...)`. Còn `act.fn` (logic thật) thì chạy
> server.

```lua
AddComponentAction("SCENE", "tuvi_altar", function(inst, doer, actions, right)
    if not right and doer:HasTag("can_meditate") then
        table.insert(actions, ACTIONS.TUTIEN_MEDITATE)
    end
end)
```

### 6.3 AddStategraphActionHandler (verify `modutil.lua:518`)

```lua
-- modmain.lua
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(
    GLOBAL.ACTIONS.TUTIEN_MEDITATE,
    function(inst) return "meditate" end   -- chuyển sang state "meditate"
))
```

---

## 7. Events & tasks

### 7.1 Signatures (verify `entityscript.lua`)

```lua
inst:ListenForEvent(event, fn, source)        -- entityscript.lua:1188; source mặc định = inst
inst:RemoveEventCallback(event, fn, source)   -- :1223
inst:PushEvent(event, data)                   -- :1317
inst:PushEventImmediate(event, data)          -- :1321 (xử lý ngay, không hoãn frame)
inst:DoTaskInTime(time, fn, ...)              -- :1522; fn(inst, ...)
inst:DoPeriodicTask(time, fn, initialdelay, ...) -- :1512
inst:PushEventInTime(time, eventname, data)   -- :1532
```

`fn` của ListenForEvent có dạng `fn(inst, data)` (với data là arg của PushEvent).
Task trả về handle; lưu lại để `:Cancel()`.

### 7.2 Các world event hay dùng

- `"ms_playerspawn"` — push lên `TheWorld` khi người chơi spawn
  (`player_common.lua:2962`: `TheWorld:PushEvent("ms_playerspawn", inst)`).
- `"ms_playerjoined"` — người chơi join (listen trên `TheWorld`).
- `"ms_respawnedfromghost"` — hồi sinh từ ma (verify dùng tại
  `prefabs/wolfgang.lua:130`, `prefabs/skilltree_wortox.lua:188`).
- `"phasechanged"` — ngày/đêm đổi pha (verify `prefabs/beefaloherd.lua:142`:
  `inst:ListenForEvent("phasechanged", fn, TheWorld)`); data = "day"/"dusk"/"night".

Ví dụ định kỳ hồi tu vi:

```lua
-- trong master_postinit
inst:DoPeriodicTask(5, function(inst)
    if inst.components.tuvi then
        inst.components.tuvi:SetCurrent(inst.components.tuvi.current + 1)
    end
end)
inst:ListenForEvent("phasechanged", function(src, phase)
    if phase == "night" and inst.components.tuvi then
        inst.components.tuvi:SetCurrent(inst.components.tuvi.current + 5) -- thiền đêm
    end
end, GLOBAL.TheWorld)
```

---

## 8. Worldgen & đặt entity

### 8.1 Patch world (verify `modutil.lua:593`)

```lua
-- modmain.lua
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    -- gate shard:
    if GLOBAL.TheWorld:HasTag("cave") then return end   -- chỉ overworld
    -- ... logic worldgen runtime
end)
```

> `AddPrefabPostInit("world", ...)` chạy runtime sau khi world prefab init, KHÔNG
> phải lúc generate map. Để chèn task/room lúc gen dùng `AddTaskPreInit`,
> `AddRoomPreInit`, `AddLevelPreInit` (`modutil.lua:238-275`).

### 8.2 Đặt entity an toàn (verify `prefabs/abigail_flower.lua:267`)

Không có hàm tên `IsAboveGroundAtPoint` trong source này — API thực tế là
`Map:IsPassableAtPoint(x, y, z [, allow_water])` và `Map:IsGroundTargetBlocked(pos)`:

```lua
local map = GLOBAL.TheWorld.Map
local x, y, z = pos:Get()
if map:IsPassableAtPoint(x, 0, z) and not map:IsGroundTargetBlocked(pos) then
    local ent = GLOBAL.SpawnPrefab("tuvi_altar")
    ent.Transform:SetPosition(x, 0, z)
end
```

Dùng `map:GetTileAtPoint(x, 0, z)` để kiểm tra loại tile nếu cần (vd tránh ocean).

---

## 9. Widgets / HUD

### 9.1 Extend Widget + AddClassPostConstruct

HUD chính là class `widgets/controls`. Patch nó (verify `controls.lua:127-153`):
nó có sẵn `self.top_root`, `self.bottom_root`, `self.topleft_root`. StatusDisplays
gắn vào `topleft_root`, inventory vào `bottom_root`.

```lua
-- modmain.lua
local Widget = GLOBAL.require("widgets/widget")
local Image  = GLOBAL.require("widgets/image")
local Text   = GLOBAL.require("widgets/text")

AddClassPostConstruct("widgets/controls", function(self)
    local owner = self.owner   -- player entity (client side)
    self.tuvi_badge = self.top_root:AddChild(Widget("TuviBadge"))
    self.tuvi_badge:SetPosition(-80, 60, 0)

    local bg = self.tuvi_badge:AddChild(Image(
        "images/hud/tuvi.xml", "tuvi_bg.tex"))
    local label = self.tuvi_badge:AddChild(Text(GLOBAL.NUMBERFONT, 28, ""))

    -- đọc state qua replica (client KHÔNG có inst.components.tuvi):
    local function refresh()
        if owner.replica.tuvi then
            label:SetString(tostring(owner.replica.tuvi:GetCurrent()))
        end
    end
    refresh()
    self.inst:ListenForEvent("tuvidirty", refresh, owner) -- dirty event từ §3
end)
```

- `Image(atlas, tex)` rồi `:SetTexture(atlas, tex)` để đổi ảnh runtime; nhớ khai bá
  `Asset("ATLAS", ...)` + `Asset("IMAGE", ...)` cho atlas HUD do mod ship.
- `top_root` neo trên màn hình; `bottom_root` neo dưới (gần inventory).
- HUD luôn là **client-side** → mọi state phải đọc qua `player.replica.<component>`,
  không bao giờ `player.components.<component>`.

---

## 10. Stategraphs (tóm tắt cho state/mob custom)

Cấu trúc một State (tham khảo `stategraphs/SGwilson.lua`):

```lua
local states = {
    State{
        name = "meditate",
        tags = { "busy", "doing" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("meditate_pre")
            inst.AnimState:PushAnimation("meditate_loop", true)
        end,
        timeline = {
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
        onexit = function(inst) end,
    },
}
local actionhandlers = {
    ActionHandler(ACTIONS.TUTIEN_MEDITATE, "meditate"),
}
```

- Thêm vào SG có sẵn từ modmain: `AddStategraphState("wilson", state)`,
  `AddStategraphActionHandler("wilson", ActionHandler(...))` (§6.3).
- Mob mới: tạo `stategraphs/SG<mob>.lua` rồi trong prefab gọi
  `inst:SetStateGraph("SG<mob>")` (giống `player_common.lua:2906`:
  `inst:SetStateGraph("SGwilson")`).
- `PerformBufferedAction()` trong timeline là nơi action thật được thực thi.

---

## 11. Cheat-sheet 8 pitfalls (WRONG vs RIGHT)

| # | Vấn đề | WRONG | RIGHT |
|---|---|---|---|
| 1 | `GLOBAL` chỉ có trong modmain | Trong `prefabs/x.lua`: `GLOBAL.TheWorld` → *'GLOBAL' is not declared* | modmain: `local TUNING = GLOBAL.TUNING`. File prefab/component: dùng `TheWorld`, `TUNING` trực tiếp |
| 2 | Anim swap khi cầm tay | Đổi `owner.AnimState:SetBuild("feijian")` | `owner.AnimState:OverrideSymbol("swap_object", "swap_feijian", "swap_feijian")` + `Show("ARM_carry")` |
| 3 | atlas của inventory icon | `atlasname = "images/inventoryimages.xml"` (atlas gốc bundled) | `atlasname = "images/inventoryimages/feijian.xml"` (atlas mod ship) + `Asset("ATLAS",...)` |
| 4 | Speed multiplier | `locomotor:SetSpeedMultiplier(1.5)` (không tồn tại) | `locomotor:SetExternalSpeedMultiplier(inst, "tuvi_buff", 1.5)` / `:RemoveExternalSpeedMultiplier(inst, "tuvi_buff")` (verify `locomotor.lua:490, 514`) |
| 5 | postinit | Set visual trong `master_postinit` → client không thấy | Visual trong `common_postinit`; gameplay component trong `master_postinit` |
| 6 | ismastersim 2 shard | `if TheWorld.ismastersim then -- tưởng chỉ overworld` | `if TheWorld.ismastersim and not TheWorld:HasTag("cave")` |
| 7 | Component/replica | Client đọc `player.components.tuvi` (nil ở client) | Server có `components.tuvi`; client đọc `player.replica.tuvi`; sync qua `net_*` + dirty event; `AddReplicableComponent("tuvi")` |
| 8 | Tên build nhân vật | build trong art tên `"my_character_art"` ≠ prefab `phamnhan` | Tên build nội bộ trong `build.bin` PHẢI == tên prefab (`SetBuild(name)` tại `player_common.lua:2432`) |

### Phụ lục: signature `SetExternalSpeedMultiplier` (PITFALL #4, verify `locomotor.lua:490`)

```lua
function LocoMotor:SetExternalSpeedMultiplier(source, key, m)
-- source: entity gây buff (thường là inst hoặc item)
-- key: chuỗi định danh buff (cho phép nhiều buff cùng source)
-- m: hệ số nhân (m == 1 hoặc nil => tự gỡ buff)
function LocoMotor:RemoveExternalSpeedMultiplier(source, key) -- key optional
```

```lua
-- thêm buff tốc độ khi đạt cảnh giới:
inst.components.locomotor:SetExternalSpeedMultiplier(inst, "tuvi_realm", 1.25)
-- gỡ:
inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "tuvi_realm")
```

> Lưu ý: nếu `m == nil` hoặc `== 1`, hàm tự gọi Remove (`locomotor.lua:492-494`),
> nên đừng dùng `1` với ý "không buff mà vẫn giữ key".

---

*Mọi snippet trên dựa trên source verify được. Khi nghi ngờ một API, luôn grep lại
trong `reference/dst-scripts/scripts/` trước khi code — đừng đoán.*

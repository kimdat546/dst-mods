---
name: dst-create-character
description: Use when creating or modifying a custom player character in the DST mod — prefab setup (MakePlayerCharacter, common vs master postinit), custom stats, skill trees, character-specific abilities/items, replicas, and the assets/strings/character registration. Covers the 8 known DST pitfalls.
---

# Tạo / sửa Player Character cho mod Tu Tiên

Recipe cụ thể để thêm một nhân vật chơi được. Mọi tên API đã verify trong
`docs/analysis/dst-api-foundation.md` (đọc trước khi nghi ngờ). Code/identifier
giữ English; chỉ section header tiếng Việt.

## Kiến trúc bootstrap của project (BẮT BUỘC theo)

- `modmain.lua` chỉ `modimport("scripts/main/import.lua")`.
- `scripts/main/*.lua` chạy trong **env sandbox** → có `GLOBAL`, `Asset`,
  `AddModCharacter`, `AddReplicableComponent`. Nạp qua `modimport`, theo thứ tự
  trong `import.lua`: assets → strings → character → components → widgets → hooks.
- `scripts/components/*.lua` và `scripts/prefabs/*.lua` chạy trong `_G` thật +
  strict mode → **KHÔNG có `GLOBAL`**, dùng `TUNING`, `TheWorld`, `Class`,
  `net_float` trực tiếp. Nạp qua `require`. (PITFALL #1)

## Checklist thêm một nhân vật

1. **Prefab** `scripts/prefabs/<name>.lua` — copy house style từ
   `scripts/prefabs/phamnhan.lua`. `require("prefabs/player_common")`,
   return `MakePlayerCharacter(name, prefabs, assets, common_postinit,
   master_postinit, start_inv)`. Thứ tự tham số chính xác như vậy.
2. **Build name == prefab name.** `common_postinit` gọi `inst.AnimState:SetBuild("<name>")`
   và tên build nội bộ trong `anim/<name>.zip` PHẢI bằng `<name>`. Sai = vô hình. (PITFALL #8)
3. **Assets** trong `scripts/main/assets.lua`: `Asset("ANIM","anim/<name>.zip")`,
   `Asset("ANIM","anim/ghost_<name>_build.zip")`. Portraits/minimap atlas xem mục
   "Portraits & registration" bên dưới.
4. **common_postinit** (client+server): tags, `SetBuild`, `MiniMapEntity:SetIcon`,
   `talker.colour`. KHÔNG đụng server component ở đây. (PITFALL #5)
5. **master_postinit** (server-only): `health:SetMaxHealth`, `hunger:SetMax`,
   `sanity:SetMax`, `combat.damagemultiplier`, `AddComponent("<custom>")`.
6. **strings** trong `scripts/main/strings.lua`:
   `STRINGS.CHARACTERS.<UPPERNAME>` + `STRINGS.CHARACTER_TITLES.<name>` +
   `STRINGS.CHARACTER_NAMES.<name>`.
7. **Đăng ký** trong `scripts/main/character.lua`: `AddModCharacter("<name>","MALE")`
   (gender: MALE/FEMALE/ROBOT/NEUTRAL/PLURAL). Optional `RemoveDefaultCharacter(...)`.
8. **Components** đăng ký replica trong `scripts/main/components.lua` (xem mục Replica).

### Template prefab (sao chép, ~18 dòng)

```lua
local MakePlayerCharacter = require("prefabs/player_common")
local assets = {
    Asset("ANIM", "anim/newchar.zip"),
    Asset("ANIM", "anim/ghost_newchar_build.zip"),
}
local prefabs, start_inv = {}, {}

local function common_postinit(inst)       -- CLIENT + SERVER
    inst:AddTag("newchar")
    inst.AnimState:SetBuild("newchar")     -- build name == prefab name (PITFALL #8)
    inst.MiniMapEntity:SetIcon("newchar.png")
end

local function master_postinit(inst)       -- SERVER only
    inst.components.health:SetMaxHealth(150)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)
    inst.components.combat.damagemultiplier = 1.1
    inst:AddComponent("pn_tuvi")            -- custom server component
    inst:DoTaskInTime(0, function() --[[ init that needs network ]] end)
end

return MakePlayerCharacter("newchar", prefabs, assets, common_postinit, master_postinit, start_inv)
```

## Abilities / Skills: skilltree native vs custom component

| Dùng | Khi nào |
|---|---|
| **Native `skilltree`** (DST) | Tiến trình mở khóa theo skill point, cây nhánh, lock/unlock có UI sẵn. Định nghĩa node trong `scripts/prefabs/<name>_skilltree.lua` (xem setsuro: `ORDERS`, node có `title/desc/icon/pos/group/tags/connects/onactivate`). Best cho passive unlock lâu dài. |
| **Custom component** (`pn_*`) | Resource/cooldown realtime (tu vi, linh căn, cảnh giới), state đổi liên tục cần sync xuống HUD. Đây là cách project đang dùng (`pn_tuvi`, `pn_canhgioi`, `pn_linhcan`). |

**Cooldown / resource pattern** (server component): giữ state, clamp, push event
khi đổi, đẩy xuống replica để HUD đọc:

```lua
function Comp:DoDelta(d)
    local old = self.val
    self.val = math.clamp(self.val + d, 0, self.max)
    if self.val ~= old then
        self:_PushToReplica()
        self.inst:PushEvent("comp_changed", { val = self.val })
    end
end
```

**Cooldown** = lưu timestamp `self.ready_at = GetTime() + cd`; check
`GetTime() >= self.ready_at` trước khi cho dùng. Đừng đếm bằng `DoPeriodicTask`
cho mỗi skill — tốn task.

**Tie ability vào character state**: trong `master_postinit` dùng
`inst:ListenForEvent("comp_changed", fn)` hoặc gate qua tag (`inst:AddTag`/`RemoveTag`)
để stategraph / component action biết đủ điều kiện. Buff tốc độ: dùng
`locomotor:SetExternalSpeedMultiplier(inst,"key",m)` — KHÔNG `SetSpeedMultiplier`. (PITFALL #4)

Skill kích hoạt cần animation → thêm state/action handler vào SGwilson từ một
hook file (`AddStategraphState("wilson", State{...})`, `AddStategraphActionHandler`).
Logic thật chạy trong `PerformBufferedAction()` của timeline. Xem dst-api-foundation §6, §10.

## Character-specific items

Không lặp lại đây. Dùng skill làm food/item (recipe đầy đủ: inventoryitem
`atlasname`/`imagename` PITFALL #3, equippable swap-symbol PITFALL #2, edible,
finiteuses). Từ phía nhân vật chỉ cần: liệt kê tên item trong `start_inv` /
`prefabs` của `MakePlayerCharacter`, và gate bằng tag nhân vật nếu là item độc quyền.

## Replica (BẮT BUỘC cho mọi server component có state client cần thấy)

Client KHÔNG có `inst.components.<comp>` (nil) — chỉ có `inst.replica.<comp>`. (PITFALL #7)
Mọi component server giữ state mà HUD/UI hiển thị PHẢI có:

1. File replica `scripts/components/<comp>_replica.lua` với `net_*` vars.
2. `AddReplicableComponent("<comp>")` trong `scripts/main/components.lua`.
3. Server component đẩy state qua replica + **initial push bằng `DoTaskInTime(0)`**
   (đợi entity có network rồi mới push, nếu không initial state mất).

### Template replica (~14 dòng, theo `pn_tuvi_replica.lua`)

```lua
local Replica = Class(function(self, inst)
    self.inst = inst
    self.val_net = net_float(inst.GUID, "newcomp.val", "newcomp_dirty")
    self.max_net = net_float(inst.GUID, "newcomp.max", "newcomp_dirty")
end)
function Replica:SetVal(v) self.val_net:set(v or 0) end
function Replica:SetMax(v) self.max_net:set(v or 1) end
function Replica:GetVal() return self.val_net:value() end
function Replica:GetMax() return self.max_net:value() end
return Replica
```

### Server component đẩy + initial push (theo `pn_tuvi.lua`)

```lua
local Comp = Class(function(self, inst)
    self.inst = inst
    self.val, self.max = 0, 100
    if inst then inst:DoTaskInTime(0, function() self:_Push() end) end  -- initial push
end)
function Comp:_Push()
    if not (self.inst and self.inst.replica and self.inst.replica.newcomp) then return end
    self.inst.replica.newcomp:SetVal(self.val)
    self.inst.replica.newcomp:SetMax(self.max)
end
```

HUD đọc trên client: `owner.replica.newcomp:GetVal()`, refresh qua dirty event
`inst:ListenForEvent("newcomp_dirty", refresh, owner)`. Nhiều net var dùng chung
một dirty event ("newcomp_dirty") → đọc lại tất cả trong handler. Server-only
component (không có UI) thì KHÔNG cần replica (vd `pn_breakthrough`).

## Portraits & registration assets

Trong `assets.lua` (mod ship atlas riêng, không trỏ atlas bundled — PITFALL #3 áp cho cả icon):

```lua
Asset("ATLAS", "images/saveslot_portraits/newchar.xml"),
Asset("ATLAS", "images/selectscreen_portraits/newchar.xml"),
Asset("ATLAS", "bigportraits/newchar.xml"),
Asset("ATLAS", "images/map_icons/newchar.xml"),
```
Rồi `AddMinimapAtlas("images/map_icons/newchar.xml")` và `AddModCharacter(...)` trong `character.lua`.

## 8 pitfalls liên quan (tham chiếu nhanh)

| # | WRONG | RIGHT |
|---|---|---|
| 1 | Trong prefab/component: `GLOBAL.TheWorld` | dùng `TheWorld`/`TUNING` trực tiếp; `GLOBAL` chỉ ở `scripts/main/*` |
| 4 | `locomotor:SetSpeedMultiplier(1.5)` | `SetExternalSpeedMultiplier(inst,"key",1.5)` |
| 5 | Set visual trong `master_postinit` | visual ở `common_postinit`, gameplay ở `master_postinit` |
| 7 | Client đọc `player.components.<comp>` | client đọc `player.replica.<comp>`; `AddReplicableComponent`; init push `DoTaskInTime(0)` |
| 8 | Build trong art tên khác prefab | build name nội bộ == prefab name (`SetBuild(name)`) |

Atlas icon (PITFALL #3): mọi `atlasname` trỏ vào file `.xml` mod ship kèm, kèm
`Asset("ATLAS",...)` + `Asset("IMAGE",...)`, không bao giờ atlas bundled của game.

> Nghi ngờ API nào → grep `reference/dst-scripts/scripts/` trước khi code, đừng đoán.

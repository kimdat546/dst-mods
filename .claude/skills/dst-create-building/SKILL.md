---
name: dst-create-building
description: Use when adding a buildable structure, placeable/deployable object, wall, or station to the DST mod — structure prefab setup, placer, recipe/crafting registration (AddRecipe2, filters), container/workable integration, multi-state animations, and clean at-scale hooking of vanilla prefabs.
---

# Tạo Building / Structure cho mod DST (Phàm Nhân Tu Tiên)

Recipe cụ thể để thêm một công trình đặt được vào thế giới. Verify trước với
`docs/analysis/dst-api-foundation.md` (API + 8 pitfalls) và prefab thật trong
`reference/workshop-mods/3730126500/atbooks1/scripts/prefabs/07_tbat_buildings/`.

**Bootstrap:** mod là thin `modmain.lua` → `modimport("scripts/main/import.lua")`
→ modimport từng file. Code building sống ở `scripts/prefabs/<name>.lua`; đăng ký
asset/recipe trong các file `scripts/main/*.lua`. File prefab chạy trong `_G` thật
(strict) → KHÔNG dùng `GLOBAL` ở đó (Pitfall #1). `GLOBAL.` chỉ trong modmain/bootstrap.

---

## 1. Prefab building cơ bản (`scripts/prefabs/tuvi_altar.lua`)

Khung giống item nhưng dùng **obstacle physics** + tag `"structure"` + minimap +
`MakePlacer` cho ghost preview. Mọi `AddComponent` nằm SAU `SetPristine()` /
`if not TheWorld.ismastersim`.

```lua
local assets = { Asset("ANIM", "anim/tuvi_altar.zip") }
local prefabs = { "collapse_big" }

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big"); fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone"); inst:Remove()
end

local function onbuilt(inst) inst.AnimState:PlayAnimation("place"); inst.AnimState:PushAnimation("idle", true) end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform(); inst.entity:AddAnimState(); inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity(); inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, 0.5)                       -- vật cản, bán kính
    inst.MiniMapEntity:SetIcon("tuvi_altar.tex")         -- icon từ atlas đăng ký ở §5
    inst.AnimState:SetBank("tuvi_altar")                 -- bank == build == tên file .zip (Pitfall #2)
    inst.AnimState:SetBuild("tuvi_altar")
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("structure")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end     -- client dừng ở đây (Pitfall #5/7)

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")                        -- cho phép đập búa phá
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    MakeHauntableLaunch(inst)
    inst:ListenForEvent("onbuilt", onbuilt)              -- chạy khi vừa đặt từ recipe
    return inst
end

return Prefab("tuvi_altar", fn, assets, prefabs),
    -- placer: name, prefab-để-soi, build, anim, [bgImage, ...], postinit_fn
    MakePlacer("tuvi_altar_placer", "tuvi_altar", "tuvi_altar", "idle")
```

`MakePlacer(placername, bank, build, anim, ...)` tạo ghost preview lúc đặt. Trả về
**cả hai** prefab từ file (`return Prefab(...), MakePlacer(...)`) — loader nạp cả 2.

Cho object **deployable** (đặt từ inventory, không qua crafting), thêm component
`deployable` + `inventoryitem` thay vì onbuilt; dùng `recipe.testfn` / placement
test thay onbuilt.

---

## 2. Recipe & crafting tab (`scripts/main/*.lua`, trong env modmain)

`AddRecipe2(name, ingredients, tech, config, filters)` (verify `modutil.lua:732`).
`config.placer` LINK tới placer ở §1. `filters` là tên tab/filter viết HOA.

```lua
-- chạy trong bootstrap (có GLOBAL): khai báo local đầu file
local Ingredient = GLOBAL.Ingredient
local TECH       = GLOBAL.TECH

AddRecipe2(
    "tuvi_altar",
    { Ingredient("cutstone", 3), Ingredient("goldnugget", 2) },
    TECH.SCIENCE_ONE,                                    -- cần Science Machine
    {
        placer = "tuvi_altar_placer",                    -- LINK §1
        atlas  = "images/inventoryimages/tuvi_altar.xml",-- atlas recipe icon (mod ship)
        image  = "tuvi_altar.tex",
        min_spacing = 1.5,                               -- khoảng cách đặt tối thiểu
    },
    { "STRUCTURES" }                                     -- filter có sẵn; hoặc tab custom
)
```

**Tab/filter:** dùng filter vanilla (`"STRUCTURES"`, `"DECOR"`, `"LIGHT"`...). Muốn
tab riêng cho mod thì gói `AddRecipe2` trong một wrapper như mod tham chiếu
(`07_recipes/00_recipe_api.lua`: map `"building"→"TBAT_RECIPE_FILTER_BUILDING"`, gọi
`RemoveRecipeFromFilter(prefab, "MODS")` để bỏ khỏi tab MODS mặc định).

`tech`: `TECH.NONE` (tay không), `TECH.SCIENCE_ONE/TWO`, `TECH.MAGIC_TWO`, v.v.

---

## 3. Building có kho chứa (container)

Đăng ký widget container **một lần** vào `require("containers").params`, rồi gắn
`container` component CHỈ trên server + listen replica event trên client (Pitfall #7).

```lua
local containers = require("containers")
local WIDGETNAME = "tuvi_altar"                           -- phải độc nhất
if containers.params[WIDGETNAME] == nil then
    containers.params[WIDGETNAME] = {
        widget = { slotpos = { Vector3(0, 0, 0) }, slotbg = {},
                   animbank = "ui_chest_1x1", animbuild = "ui_chest_1x1",
                   pos = Vector3(0, 200, 0) },
        type = "chest",
        itemtestfn = function(container, item, slot) return item:HasTag("tuvi_pill") end, -- lọc item
    }
end
local function setup(c) c:WidgetSetup(WIDGETNAME) end

-- trong fn(), TRƯỚC `if not ismastersim` để client cũng setup replica:
inst:ListenForEvent("OnEntityReplicated.container", function(_, replica) setup(replica) end)
-- SAU `if not ismastersim then return inst end`:
inst:AddComponent("container"); setup(inst.components.container)
-- trong onhammered: inst.components.container:DropEverything()
```

`scripts/prefabs/07_tbat_buildings/03_stump_table.lua` là ví dụ đầy đủ (container +
hiển thị item bằng Follower lên symbol "slot").

---

## 4. CLEAN HOOK ở quy mô lớn (cho milestone world-scaling)

Khi cần inject data/behavior vào **nhiều prefab vanilla cùng lúc** mà không sửa
file gốc — đây là kiến trúc của mod tham chiếu (`04_origin_components_hook`).

**4a. Inject component qua AddComponentPostInit** (an toàn, ưu tiên dùng):
```lua
-- modmain/bootstrap. Tự thêm data component vào MỌI entity có inspectable:
AddComponentPostInit("inspectable", function(self)
    if self.inst.AnimState and self.inst.components.pn_affinity == nil
       and GLOBAL.TheWorld.ismastersim then
        self.inst:AddComponent("pn_affinity")               -- tu-vi affinity của ta
    end
end)
```

**4b. Hook hàm internal qua debug.getupvalue/setupvalue** (mạnh nhưng nguy hiểm):
chỉ dùng khi behavior bị đóng kín trong closure, không expose qua API component.
PHẢI có **depth guard + visited set** chống đệ quy vô hạn.
```lua
local function HookUpvalue(root_fn, target, wrap)
    local visited = {}
    local function search(fn, depth)
        if depth > 50 or visited[fn] then return false end  -- guards BẮT BUỘC
        visited[fn] = true
        for i = 1, math.huge do
            local name, val = debug.getupvalue(fn, i)
            if not name then break end
            if name == target and type(val) == "function" then
                debug.setupvalue(fn, i, function(...) return wrap(val, ...) end)
                return true
            elseif type(val) == "function" and search(val, depth + 1) then return true end
        end
        return false
    end
    return search(root_fn, 0)
end
```

> ⚠️ CẢNH BÁO: `debug.setupvalue` patch live closure — fragile khi Klei cập nhật
> game, dễ xung đột với mod khác, và chia sẻ upvalue giữa instance. Dùng 4a (component
> post-init) hoặc `AddSimPostInit` override method bình thường TRƯỚC. Chỉ rơi xuống 4b
> khi không còn cách. Luôn giữ ref hàm gốc và gọi lại trong wrapper.

---

## 5. Pitfalls liên quan (xem foundation §11)

- **#1 GLOBAL scope:** file `scripts/prefabs/*.lua` dùng `CreateEntity`, `Prefab`,
  `SpawnPrefab`, `TheWorld` trực tiếp — KHÔNG `GLOBAL.`. `AddRecipe2`/`Ingredient`/
  `TECH` ở bootstrap cần `GLOBAL.` (hoặc local cache đầu file).
- **#2 anim bank/build:** `SetBank`/`SetBuild` phải khớp tên build nội bộ trong
  `.zip` art (thường == tên prefab). Sai → công trình vô hình.
- **minimap atlas:** `MiniMapEntity:SetIcon("x.tex")` cần atlas đăng ký qua
  `AddMinimapAtlas("images/map_icons/x.xml")` (verify `modutil.lua:512`) +
  `Asset("ATLAS"/"IMAGE", ...)`. Quên → icon không hiện.
- **recipe icon atlas (#3):** `config.atlas` trỏ tới file `.xml` MOD ship trong
  `images/inventoryimages/`, không phải atlas bundled gốc của game.
- **#5/#7 server/client split:** visual/tag/bank/build TRƯỚC `SetPristine`; mọi
  `AddComponent` (workable, container, lootdropper) SAU `if not ismastersim`.

---

## 6. Checklist & asset declaration

Trong `scripts/main/assets.lua` (bootstrap):
```lua
Assets = Assets or {}
table.insert(Assets, Asset("ANIM",  "anim/tuvi_altar.zip"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/tuvi_altar.xml")) -- recipe icon
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/tuvi_altar.tex"))
table.insert(Assets, Asset("ATLAS", "images/map_icons/tuvi_altar.xml"))       -- minimap
table.insert(Assets, Asset("IMAGE", "images/map_icons/tuvi_altar.tex"))
AddMinimapAtlas("images/map_icons/tuvi_altar.xml")
PrefabFiles = PrefabFiles or {}
table.insert(PrefabFiles, "tuvi_altar")                                       -- nạp prefab + placer
```

Checklist khi thêm 1 building:
1. `scripts/prefabs/<name>.lua` — `fn()` + `return Prefab(...), MakePlacer(...)`.
2. Thêm vào `PrefabFiles` + 5 Asset + `AddMinimapAtlas` ở `assets.lua`.
3. `AddRecipe2` với `placer`, `atlas`, `image`, filter ở bootstrap (§2).
4. STRINGS tên/inspect trong `scripts/main/strings.lua`.
5. Có kho? → container §3. Đa trạng thái? → animation theo `health`/`level` event
   như `02_sunflower_hamster.lua` (`level_up` → đổi `PlayAnimation`).

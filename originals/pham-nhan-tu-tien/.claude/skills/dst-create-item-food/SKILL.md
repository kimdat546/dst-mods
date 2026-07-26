---
name: dst-create-item-food
description: Use when adding an inventory item, edible/food, drink, or consumable to the DST mod — item prefab setup, inventoryitem atlas/imagename, edible component (health/hunger/sanity, on-eat effects), stackable/perishable, AddIngredientValues + cook-pot recipe test functions, and data-driven registration at scale.
---

# DST — Tạo Item / Food / Consumable cho mod Phàm Nhân Tu Tiên

Hướng dẫn tạo vật phẩm túi đồ, đồ ăn, đồ uống, và công thức nồi nấu cho DST.
Dựa trên source verify (`docs/analysis/dst-api-foundation.md`) và mod Hall of Food
(`docs/analysis/refmods/3731336839-halloffood.md`). Code tiếng Anh, header tiếng Việt.

## 0. Nguyên tắc nền (đọc trước)

- File trong `scripts/prefabs/*.lua` chạy trong `_G` thật + strict mode → dùng global
  trực tiếp (`TUNING`, `FOODTYPE`, `Prefab`, `Asset`), **KHÔNG** wrap `GLOBAL.` (PITFALL #1).
- Mọi entity cần `inst.entity:AddNetwork()` và `inst.entity:SetPristine()`; mọi
  `AddComponent` đặt SAU `if not TheWorld.ismastersim then return inst end` (§4.1 foundation).
- Hằng số (health/hunger/sanity/perish) sống trong `scripts/pn/config.lua`, KHÔNG hardcode
  trong prefab. Bootstrap nạp qua `scripts/main/import.lua` → `components.lua` v.v.

## 1. Item túi đồ cơ bản (stackable)

`scripts/prefabs/pn_<item>.lua`:

```lua
local assets = {
    Asset("ANIM",  "anim/pn_linhthach.zip"),
    Asset("ATLAS", "images/inventoryimages/pn_linhthach.xml"),  -- atlas MOD ship
    Asset("IMAGE", "images/inventoryimages/pn_linhthach.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pn_linhthach")
    inst.AnimState:SetBuild("pn_linhthach")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("pn_spirit_stone")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM  -- 8

    inst:AddComponent("inventoryitem")
    -- PITFALL #3: atlasname = ĐƯỜNG DẪN .xml mod ship; imagename = tên sprite KHÔNG đuôi
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pn_linhthach.xml"
    inst.components.inventoryitem.imagename = "pn_linhthach"
    return inst
end

return Prefab("pn_linhthach", fn, assets)
```

## 2. Làm cho item ăn được (edible)

Thêm trong nhánh `ismastersim` (verify `components/edible.lua:24-52`):

```lua
inst:AddComponent("edible")
inst.components.edible.foodtype   = FOODTYPE.GENERIC      -- hoặc VEGGIE/MEAT/GOODIES
inst.components.edible.healthvalue = TUNING.PN_PILL_HEALTH
inst.components.edible.hungervalue = TUNING.PN_PILL_HUNGER
inst.components.edible.sanityvalue = TUNING.PN_PILL_SANITY

-- on-eat: oneaten là CALLBACK trên component (KHÔNG phải event "oneat")
inst.components.edible.oneaten = function(inst, eater)
    if eater.components.pn_tuvi then
        eater.components.pn_tuvi:AddTuVi(TUNING.PN_PILL_TUVI)
    end
end

-- perishable (đồ ăn hư theo thời gian); bỏ qua nếu item bền (linh thạch)
inst:AddComponent("perishable")
inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
inst.components.perishable:StartPerishing()
inst.components.perishable.onperishreplacement = "spoiled_food"
```

Muốn cấp buff lâu dài thay vì cộng thẳng stat → tạo buff prefab và gọi
`eater:AddDebuff("pn_buff", "pn_buff")` trong `oneaten`. Xem skill tạo pill/buff
để dựng prefab buff (preload bằng `prefabs = {"pn_buff"}` ở bảng recipe / prefab).

## 3. Công thức (cook-pot & craft)

### 3.1 Đăng ký tag nguyên liệu (AddIngredientValues — trong modmain/bootstrap)

```lua
-- scripts/main/cooking.lua (modimport từ import.lua) — chạy trong env modmain
AddIngredientValues({"pn_linhthach"}, {pn_spirit = 1})           -- tag ngữ nghĩa
AddIngredientValues({"pn_herb"},      {veggie = 1, pn_herb = 1}, true)  -- arg3=perishable
```

Cooker tích lũy `names` (đếm chính xác từng prefab) và `tags` (tổng giá trị tag).
Tag ngữ nghĩa (`pn_spirit`, `pn_herb`) cho phép hàng trăm công thức từ ít nguyên liệu.

### 3.2 Recipe test function + AddCookerRecipe

```lua
-- scripts/recipes/pn_cookpot_recipes.lua  → return bảng
local recipes = {
    pn_dan_duoc = {
        -- test(cooker, names, tags): khớp số đếm và/hoặc ngưỡng tag
        test = function(cooker, names, tags)
            return (names.pn_linhthach or 0) >= 1 and (tags.pn_herb or 0) >= 2
        end,
        priority = 30,                  -- thấp hơn = xét trước (chặn recipe tham lam)
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.PN_DAN_HEALTH, hunger = TUNING.PN_DAN_HUNGER, sanity = 20,
        perishtime = TUNING.PERISH_SLOW,
        cooktime = 1,
        oneatenfn = function(inst, eater)              -- buff sau khi ăn xong
            if eater.components.pn_tuvi then eater.components.pn_tuvi:AddTuVi(50) end
        end,
        card_def = {ingredients = {{"pn_linhthach",1},{"pn_herb",2}}}, -- hiển thị cookbook
    },
}
for k, r in pairs(recipes) do
    r.name = k
    r.weight = r.weight or 1
    r.overridebuild = r.overridebuild or k       -- anim build món nấu xong
end
return recipes
```

Đăng ký vào mọi nồi (modmain context):

```lua
local recipes = require("recipes/pn_cookpot_recipes")
for _, cooker in ipairs({"cookpot", "portablecookpot", "archive_cookpot"}) do
    for _, recipe in pairs(recipes) do AddCookerRecipe(cooker, recipe) end
end
```

### 3.3 Item chế tạo (craft) — AddRecipe2 (verify `modutil.lua:732`)

```lua
-- modmain context. tech: TECH.NONE / TECH.SCIENCE_ONE ...
AddRecipe2("pn_linhthach",
    { Ingredient("rocks", 2), Ingredient("nightmarefuel", 1) },
    TECH.NONE,
    { atlas = "images/inventoryimages/pn_linhthach.xml", image = "pn_linhthach.tex" },
    { "pn_filter" })   -- crafting filter/tab
```

## 4. Đăng ký data-driven ở quy mô lớn

### 4.1 Hằng số tập trung — `scripts/pn/config.lua`

```lua
return {
    FOOD = {
        PN_PILL_HEALTH = 10, PN_PILL_HUNGER = 12.5, PN_PILL_SANITY = 5, PN_PILL_TUVI = 30,
        PN_DAN_HEALTH = 20,  PN_DAN_HUNGER = 25,
    },
}
```

Trong bootstrap, ánh xạ vào `TUNING` một lần (modmain context):

```lua
local C = GLOBAL.require("pn/config")
for k, v in pairs(C.FOOD) do GLOBAL.TUNING[k] = v end
```

### 4.2 Bảng item + loop nạp (1 file định nghĩa, 1 loader)

```lua
-- scripts/prefabs/pn_items.lua — định nghĩa nhiều item bằng data, sinh prefab trong loop
local DEFS = {
    pn_linhthach = { stack = "STACK_SIZE_SMALLITEM", edible = false },
    pn_herb      = { stack = "STACK_SIZE_SMALLITEM", edible = true, foodtype = "VEGGIE",
                     health = "PN_PILL_HEALTH", hunger = "PN_PILL_HUNGER" },
}
local function MakeItem(name, def)
    local assets = {
        Asset("ANIM",  "anim/"..name..".zip"),
        Asset("ATLAS", "images/inventoryimages/"..name..".xml"),
        Asset("IMAGE", "images/inventoryimages/"..name..".tex"),
    }
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform(); inst.entity:AddAnimState(); inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst.AnimState:SetBank(name); inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING[def.stack]
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name..".xml"
        inst.components.inventoryitem.imagename = name      -- == prefab name = sprite key
        if def.edible then
            inst:AddComponent("edible")
            inst.components.edible.foodtype    = FOODTYPE[def.foodtype]
            inst.components.edible.healthvalue = TUNING[def.health] or 0
            inst.components.edible.hungervalue = TUNING[def.hunger] or 0
        end
        return inst
    end
    return Prefab(name, fn, assets)
end
local prefabs = {}
for name, def in pairs(DEFS) do table.insert(prefabs, MakeItem(name, def)) end
return unpack(prefabs)
```

Đăng ký file: thêm `"pn_items"` vào `PrefabFiles` (modmain) hoặc list loader của mod.

## 5. QUY TẮC ATLAS — nguyên nhân icon biến mất (PITFALL #3)

`inventoryitem` cần đúng hai field, sai một là icon trống lặng lẽ (không error):

| Field | Giá trị | Sai thường gặp |
|---|---|---|
| `atlasname` | đường dẫn `.xml` MOD ship, vd `"images/inventoryimages/pn_herb.xml"` | trỏ vào `"images/inventoryimages.xml"` (atlas gốc bundled, runtime không đọc được) |
| `imagename` | tên sprite **trong** xml, **KHÔNG** đuôi `.tex`, vd `"pn_herb"` | thừa `.tex`, hoặc lệch tên với key trong xml |

Bắt buộc khai báo `Asset("ATLAS", ...)` + `Asset("IMAGE", ...)` cho cùng đường dẫn.
Quy ước đặt tên: `pn_<item>` cho item gốc, `pn_<item>_cooked` cho biến thể nấu chín.
imagename = prefab name = sprite key → giữ ba thứ này luôn trùng để tránh typo.

## 6. Làm icon — KTEX tooling

DST đọc `.tex` (KTEX), không đọc `.png`. Dùng `tools/png_to_ktex.py`:

```bash
python3 tools/png_to_ktex.py art/pn_herb.png images/inventoryimages/pn_herb.tex 64
```

Rồi viết file `pn_herb.xml` map sprite `pn_herb` → vùng texture (atlas 1 sprite cho
item đơn, hoặc atlas gộp như Hall of Food `hof_inventoryimages.xml`). imagename trong
xml phải khớp với `inventoryitem.imagename`.

## Checklist trước khi commit

- [ ] `atlasname` trỏ .xml MOD ship + có `Asset("ATLAS"/"IMAGE")`; `imagename` không đuôi
- [ ] `imagename` == sprite key trong xml == prefab name
- [ ] `AddComponent` nằm sau `SetPristine()` + check `ismastersim`
- [ ] Stat đọc từ `TUNING.*` (đã map từ `scripts/pn/config.lua`), không hardcode
- [ ] `edible.oneaten` (callback) chứ không nghe event `"oneat"`
- [ ] Recipe `priority` đủ thấp; nguyên liệu đã `AddIngredientValues` với tag ngữ nghĩa
- [ ] `.tex` build bằng `tools/png_to_ktex.py`, không ship `.png`

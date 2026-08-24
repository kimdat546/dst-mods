# M-Items-1 Plan A — Linh Thảo & Linh Điền (Farming) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement task-by-task. Steps use checkbox (`- [ ]`).

**Goal:** Build the farming half of the pill loop: wild spirit-herb plants you harvest (→ herb item + seed), seeds you plant, a Linh Điền (spirit field) structure that accelerates nearby spirit-herb crop growth, and the crops themselves with grow stages.

**Architecture:** Bootstrap-layer (thin modmain → `scripts/main/*` via modimport; `scripts/components/*` + `scripts/prefabs/*` via require). Data-driven herb table (`pn/herbs.lua`). Custom lightweight crop with a stage timer (NO vanilla soil-tilling/farm_plant — simpler, fewer moving parts). Linh Điền sets an acceleration multiplier on crops within radius. Approach A: write clean `pn_*` code, reuse only ART (anim builds) from 山海秘藏.

**Tech Stack:** Lua 5.x (DST runtime), `luac` (syntax), Python3+Pillow (KTEX tools), git, bash.

**Spec:** `docs/superpowers/specs/2026-05-31-items-pill-loop-design.md`

**Reference (READ relevant section before each task):**
- `.claude/skills/dst-create-item-food/SKILL.md` — item/edible/inventoryitem atlas conventions (pitfall #3)
- `.claude/skills/dst-create-building/SKILL.md` — structure prefab + MakePlacer + AddRecipe2
- `docs/analysis/dst-api-foundation.md` — 8 pitfalls (anim bank/build, GLOBAL scope, atlasname, minimap atlas)
- `docs/analysis/refmods/3046680574-shanhai.md` and `reference/workshop-mods/3046680574/scripts/prefabs/08_plants/00_fsm_plantables.lua` — plantable/deploy pattern
- `reference/workshop-mods/3730126500/...17_farm_plant_defs/` — grow-stage reference
- `reference/dst-scripts/scripts/components/pickable.lua` (`SetUp`, `Pick`), `scripts/prefabs/seeds.lua` (deployable `OnDeploy`, `can_plant_seed`)

**Testing note (DST-specific):** No unit runner. Per-commit gate = `tools/check_syntax.sh` + `tools/check_assets.py`. In-game verification batched at end (Task 10) via `tools/sync_local.sh` + Host.

**4 herbs for v1** (asset build names from 山海秘藏, re-encoded into our mod):
| herb id | build (anim) | rarity | feeds pill |
|---|---|---|---|
| `pn_herb_huangcao` | `pn_huangcao` (from fsm_huang_grass) | COMMON | tu vi hạ |
| `pn_herb_caochanzhi` | `pn_caochanzhi` (from fsm_caochanzhi) | COMMON | tu vi trung |
| `pn_herb_zhuguo` | `pn_zhuguo` (from fsm_zhuguocong) | UNCOMMON | tu vi thượng / buff / hồi phục |
| `pn_herb_fusang` | `pn_fusang` (from fsm_fusang) | RARE | Bổ Thiên Đan |

---

## File summary

**Created:**
- `scripts/pn/herbs.lua` (data) + additions to `scripts/pn/config.lua`
- `scripts/components/pn_linhdien.lua`
- `scripts/prefabs/pn_herb_plant.lua` (wild pickable, factory over the 4 herbs)
- `scripts/prefabs/pn_herb_items.lua` (herb inventory items + seeds, factories)
- `scripts/prefabs/pn_herb_crop.lua` (planted crop with stage timer, factory)
- `scripts/prefabs/pn_linhdien.lua` (structure + placer)
- `scripts/main/items.lua` (PrefabFiles + Assets + minimap + regrowth + world scatter)
- `scripts/main/recipes.lua` (Linh Điền recipe)
- assets: `anim/pn_<herb>.zip` ×4, `images/inventoryimages/pn_herbs.{tex,xml}`, `anim/pn_linhdien.zip` (+ placer), `images/map_icons/pn_linhdien.{tex,xml}`
- Modify: `scripts/main/import.lua` (add items.lua, recipes.lua)

---

## Task 1: Data — herbs.lua + config additions

**Files:**
- Create: `scripts/pn/herbs.lua`
- Modify: `scripts/pn/config.lua`

- [ ] **Step 1: Write `scripts/pn/herbs.lua`**

```lua
-- Linh thảo (spirit herb) definitions. Data-driven: add a row to add a herb.
-- build = the anim build baked into anim/pn_<x>.zip (build name == file stem).
-- inv = sprite key (extensionless) in images/inventoryimages/pn_herbs.xml.
local M = {}

M.RARITY = { COMMON = "COMMON", UNCOMMON = "UNCOMMON", RARE = "RARE" }

-- ordered list; each: id (herb item prefab), build, inv image, plant/crop/seed
-- prefab names derive as <id>, <id>_plant (wild), <id>_crop (planted), <id>_seed.
M.herbs = {
    {
        id = "pn_herb_huangcao", display = "Hoang Thảo", rarity = "COMMON",
        build = "pn_huangcao", inv = "pn_herb_huangcao",
        wild_regrow = 4,        -- days between wild regrowth
        crop_grow = 3,          -- in-game days seed->mature (before linh điền accel)
        seed_chance = 0.5,      -- chance a harvest also yields a seed
    },
    {
        id = "pn_herb_caochanzhi", display = "Thảo Triền Chi", rarity = "COMMON",
        build = "pn_caochanzhi", inv = "pn_herb_caochanzhi",
        wild_regrow = 5, crop_grow = 4, seed_chance = 0.5,
    },
    {
        id = "pn_herb_zhuguo", display = "Chu Quả", rarity = "UNCOMMON",
        build = "pn_zhuguo", inv = "pn_herb_zhuguo",
        wild_regrow = 8, crop_grow = 6, seed_chance = 0.33,
    },
    {
        id = "pn_herb_fusang", display = "Phù Tang", rarity = "RARE",
        build = "pn_fusang", inv = "pn_herb_fusang",
        wild_regrow = 16, crop_grow = 10, seed_chance = 0.2,
    },
}

-- index by id for O(1) lookup
M.by_id = {}
for _, h in ipairs(M.herbs) do M.by_id[h.id] = h end

function M.Get(id) return M.by_id[id] end

return M
```

- [ ] **Step 2: Append farming constants to `scripts/pn/config.lua`**

Open `scripts/pn/config.lua`. It currently `return {...}` a table. Add these keys INSIDE the returned table (after `MOBS_TO_PATCH`), keeping it one table:

```lua
    -- Farming (Plan A)
    LINHDIEN = {
        ACCEL_MULT = 2.0,   -- crops in range grow 2x faster
        RADIUS = 6,         -- tiles-ish world units
        SCAN_PERIOD = 2,    -- seconds between linh điền rescans
    },
    HERB = {
        WILD_SCATTER_COUNT = 24,  -- wild herbs scattered near spawn on world start
        WILD_SCATTER_RADIUS = 60,
        CROP_STAGES = 3,          -- seed -> sprout -> mature
    },
```

- [ ] **Step 3: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/pn/herbs.lua scripts/pn/config.lua
git commit -m "feat(items-A): herbs data table + farming config constants"
```
Expected: `✓ All N Lua files pass syntax check`.

---

## Task 2: Recover/prepare art assets (herb anims + inventory atlas + linh điền)

**Files:** binary assets only (no Lua). This task makes the art the prefabs need exist on disk.

**Before:** read api-foundation pitfall #2 (each herb needs its OWN anim build name to avoid shared-bank bugs) and the KTEX tooling notes (`tools/png_to_ktex.py`, `tools/rename_build.py`).

- [ ] **Step 1: Copy the 4 herb anim zips from 山海秘藏 and rename their internal build**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
SRC="reference/workshop-mods/3046680574/anim"
mkdir -p anim
cp "$SRC/fsm_huang_grass.zip"  anim/pn_huangcao.zip
cp "$SRC/fsm_caochanzhi.zip"   anim/pn_caochanzhi.zip
cp "$SRC/fsm_zhuguocong.zip"   anim/pn_zhuguo.zip
cp "$SRC/fsm_fusang.zip"       anim/pn_fusang.zip
# Patch each zip's internal build name to match our file stem (pitfall #8: build==expected name).
for h in huangcao caochanzhi zhuguo fusang; do
  python3 tools/rename_build.py anim/pn_$h.zip pn_$h 2>&1 | tail -1 || echo "check rename_build usage for anim/pn_$h.zip"
done
ls -la anim/pn_*.zip
```
Expected: 4 zips present. If `rename_build.py` needs a different invocation, read `tools/rename_build.py` header for its CLI and adapt. The goal: each `anim/pn_<h>.zip` has internal build name `pn_<h>`.

- [ ] **Step 2: Inspect each herb build's bank + animations so prefabs use correct names**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
for h in huangcao caochanzhi zhuguo fusang; do
  echo "=== pn_$h ==="
  python3 - "anim/pn_$h.zip" <<'PY'
import sys,zipfile
z=zipfile.ZipFile(sys.argv[1])
print(z.namelist())
PY
done
```
Expected: each zip lists `build.bin`, `anim.bin`, atlas .tex. Note the bank/animation names by decoding if needed (`tools/ktex_to_png.py` not needed here; bank/anim names live in build.bin/anim.bin). If bank/anim names are unknown, fall back to a safe default in the prefab: use `AnimState:GetBuild()` anims discovered in-game (Task 10 will surface errors). Record the per-herb bank/anim used into a comment in the prefab in Task 3.

- [ ] **Step 3: Build the herb inventory atlas `images/inventoryimages/pn_herbs.{tex,xml}`**

The 4 herb items need inventory icons. Reuse 山海秘藏 herb inv images if present, else generate simple ones.

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
mkdir -p images/inventoryimages /tmp/pn_herbicons
# Try to pull existing herb inv pngs from the source atlas (decode), else placeholder 64x64.
python3 - <<'PY'
import os
from PIL import Image
names = ["pn_herb_huangcao","pn_herb_caochanzhi","pn_herb_zhuguo","pn_herb_fusang"]
colors = {"pn_herb_huangcao":(120,180,90),"pn_herb_caochanzhi":(80,160,120),
          "pn_herb_zhuguo":(200,80,80),"pn_herb_fusang":(230,200,90)}
for n in names:
    im = Image.new("RGBA",(64,64),(0,0,0,0))
    from PIL import ImageDraw
    d=ImageDraw.Draw(im); c=colors[n]
    d.ellipse((10,10,54,54),fill=c+(255,))
    im.save(f"/tmp/pn_herbicons/{n}.png")
print("placeholder icons written")
PY
```
Then pack into a single atlas. If the repo lacks an atlas packer, build a simple 2x2 256x256 atlas + XML by hand:

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
python3 - <<'PY'
from PIL import Image
names = ["pn_herb_huangcao","pn_herb_caochanzhi","pn_herb_zhuguo","pn_herb_fusang"]
atlas = Image.new("RGBA",(256,256),(0,0,0,0))
pos = {}
for i,n in enumerate(names):
    im = Image.open(f"/tmp/pn_herbicons/{n}.png").resize((64,64))
    x=(i%2)*64; y=(i//2)*64
    atlas.paste(im,(x,y)); pos[n]=(x,y,64,64)
atlas.save("/tmp/pn_herbs_atlas.png")
# write XML (u/v normalized; DST Atlas uses u1<v? It uses u1,u2,v1,v2 with v from bottom)
W=H=256
with open("images/inventoryimages/pn_herbs.xml","w") as f:
    f.write('<Atlas>\n  <Texture filename="pn_herbs.tex" />\n  <Elements>\n')
    for n,(x,y,w,h) in pos.items():
        u1=x/W; u2=(x+w)/W; v1=1-(y+h)/H; v2=1-y/H
        f.write(f'    <Element name="{n}.tex" u1="{u1}" u2="{u2}" v1="{v1}" v2="{v2}" />\n')
    f.write('  </Elements>\n</Atlas>\n')
print("xml written")
PY
python3 tools/png_to_ktex.py /tmp/pn_herbs_atlas.png images/inventoryimages/pn_herbs.tex
ls -la images/inventoryimages/pn_herbs.*
```
Expected: `pn_herbs.tex` + `pn_herbs.xml` with 4 elements named `pn_herb_<x>.tex`. (Placeholder art is acceptable for v1; real art is a polish task.)

- [ ] **Step 4: Linh Điền structure art**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
# Reuse a planter/altar-like anim from 山海秘藏 if available; else use vanilla as placeholder.
SRC="reference/workshop-mods/3046680574/anim"
if [ -f "$SRC/fsm_lotus_pond.zip" ]; then cp "$SRC/fsm_lotus_pond.zip" anim/pn_linhdien.zip; python3 tools/rename_build.py anim/pn_linhdien.zip pn_linhdien 2>&1 | tail -1; fi
# minimap icon (simple 32x32)
mkdir -p images/map_icons /tmp/pn_mi
python3 - <<'PY'
from PIL import Image,ImageDraw
im=Image.new("RGBA",(32,32),(0,0,0,0)); d=ImageDraw.Draw(im)
d.ellipse((4,4,28,28),fill=(90,200,140,255)); im.save("/tmp/pn_mi/pn_linhdien.png")
PY
python3 tools/png_to_ktex.py /tmp/pn_mi/pn_linhdien.png images/map_icons/pn_linhdien.tex
cat > images/map_icons/pn_linhdien.xml <<'XML'
<Atlas>
  <Texture filename="pn_linhdien.tex" />
  <Elements>
    <Element name="pn_linhdien.tex" u1="0.0" u2="1.0" v1="0.0" v2="1.0" />
  </Elements>
</Atlas>
XML
ls -la anim/pn_linhdien.zip images/map_icons/pn_linhdien.*
```
Expected: `anim/pn_linhdien.zip` (if source existed) + map icon files. If `fsm_lotus_pond.zip` is absent, note it and Task 7 will use a vanilla build (`"chest"`) as placeholder.

- [ ] **Step 5: Commit assets**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
git add anim/pn_huangcao.zip anim/pn_caochanzhi.zip anim/pn_zhuguo.zip anim/pn_fusang.zip \
        images/inventoryimages/pn_herbs.tex images/inventoryimages/pn_herbs.xml \
        anim/pn_linhdien.zip images/map_icons/pn_linhdien.tex images/map_icons/pn_linhdien.xml 2>/dev/null
git commit -m "feat(items-A): recover/prepare herb anims + inv atlas + linh điền art (placeholder icons)"
```

---

## Task 3: Herb inventory items + seeds (`pn_herb_items.lua`)

**Files:**
- Create: `scripts/prefabs/pn_herb_items.lua`

**Before:** read dst-create-item-food SKILL §inventoryitem (atlasname = the mod xml; imagename = sprite key == prefab name). Pitfall #3.

- [ ] **Step 1: Write `scripts/prefabs/pn_herb_items.lua`**

```lua
-- Herb inventory items (pn_herb_<x>) and their seeds (pn_herb_<x>_seed).
-- Seeds are deployable on tillable/walkable ground → spawn the matching crop.
local Herbs = require("pn/herbs")

local ATLAS = "images/inventoryimages/pn_herbs.xml"

local function MakeHerbItem(def)
    local assets = { Asset("ATLAS", ATLAS), Asset("IMAGE", "images/inventoryimages/pn_herbs.tex") }

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("seeds")            -- reuse vanilla seeds bank for a small item idle
        inst.AnimState:SetBuild("seeds")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("pn_herb")
        MakeInventoryFloatable(inst, "small", 0.1, 0.75)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = ATLAS
        inst.components.inventoryitem.imagename = def.id  -- sprite key == prefab name
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 40
        inst:AddComponent("tradable")
        return inst
    end
    return Prefab(def.id, fn, assets)
end

local function OnDeploySeed(def)
    return function(inst, pt, deployer)
        local crop = SpawnPrefab(def.id .. "_crop")
        if crop then
            crop.Transform:SetPosition(pt.x, 0, pt.z)
            if crop.components.pn_herb_crop then crop.components.pn_herb_crop:OnPlanted() end
            if inst.components.stackable then inst.components.stackable:Get():Remove() else inst:Remove() end
            if deployer and deployer.SoundEmitter then deployer.SoundEmitter:PlaySound("dontstarve/common/plant") end
        end
    end
end

local function CanPlant(inst, pt, mouseover, deployer)
    return TheWorld.Map:IsPassableAtPoint(pt.x, 0, pt.z) and not TheWorld.Map:IsPointNearHole(pt)
end

local function MakeSeedItem(def)
    local assets = { Asset("ATLAS", ATLAS), Asset("IMAGE", "images/inventoryimages/pn_herbs.tex") }
    local sid = def.id .. "_seed"

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("seeds")
        inst.AnimState:SetBuild("seeds")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("pn_herb_seed")
        MakeInventoryFloatable(inst, "small", 0.1, 0.7)

        inst._custom_candeploy_fn = CanPlant
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = ATLAS
        inst.components.inventoryitem.imagename = def.id  -- share herb icon for v1
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = 20

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
        inst.components.deployable.ondeploy = OnDeploySeed(def)
        return inst
    end
    return Prefab(sid, fn, assets)
end

local prefabs = {}
for _, def in ipairs(Herbs.herbs) do
    table.insert(prefabs, MakeHerbItem(def))
    table.insert(prefabs, MakeSeedItem(def))
end
return unpack(prefabs)
```

- [ ] **Step 2: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/prefabs/pn_herb_items.lua
git commit -m "feat(items-A): herb inventory items + deployable seeds"
```

---

## Task 4: `pn_linhdien` component (growth accelerator)

**Files:**
- Create: `scripts/components/pn_linhdien.lua`

**Before:** read api-foundation §3 (bare globals in components, no GLOBAL prefix).

- [ ] **Step 1: Write `scripts/components/pn_linhdien.lua`**

```lua
-- Linh Điền field: periodically tags nearby pn herb crops with an accel multiplier
-- so their grow timer runs faster. Server-only (no replica needed).
local config = require("pn/config")

local PnLinhDien = Class(function(self, inst)
    self.inst = inst
    self.radius = config.LINHDIEN.RADIUS
    self.mult = config.LINHDIEN.ACCEL_MULT
    if inst then
        self._task = inst:DoPeriodicTask(config.LINHDIEN.SCAN_PERIOD, function() self:_Scan() end)
        inst:DoTaskInTime(0, function() self:_Scan() end)
    end
end)

function PnLinhDien:_Scan()
    if not (self.inst and self.inst:IsValid()) then return end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.radius, { "pn_herb_crop" })
    for _, e in ipairs(ents) do
        if e.components.pn_herb_crop then
            e.components.pn_herb_crop:SetAccel(self.mult, self.inst)
        end
    end
end

function PnLinhDien:OnRemoveFromEntity()
    if self._task then self._task:Cancel(); self._task = nil end
end

return PnLinhDien
```

- [ ] **Step 2: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/components/pn_linhdien.lua
git commit -m "feat(items-A): pn_linhdien component (accelerate nearby crops)"
```

---

## Task 5: `pn_herb_crop` component + crop prefab (`pn_herb_crop.lua`)

**Files:**
- Create: `scripts/prefabs/pn_herb_crop.lua` (contains both the `pn_herb_crop` component class and the crop prefab factory)

**Design:** crop has `CROP_STAGES` stages. Each stage schedules the next after `stage_time / accel`. Accel decays back to 1.0 if no linh điền refreshes it (linh điền calls SetAccel every SCAN_PERIOD). When mature, becomes pickable → harvest gives the herb item (+ seed chance), then resets to stage 1 (regrows in place).

- [ ] **Step 1: Write `scripts/prefabs/pn_herb_crop.lua`**

```lua
local Herbs = require("pn/herbs")
local config = require("pn/config")

local TOTAL_DAY = TUNING.TOTAL_DAY_TIME or 480

----------------------------------------------------------------------
-- component: pn_herb_crop
----------------------------------------------------------------------
local PnHerbCrop = Class(function(self, inst)
    self.inst = inst
    self.stage = 1
    self.maxstage = config.HERB.CROP_STAGES
    self.accel = 1.0
    self._accel_until = 0
    self.herb_id = nil          -- set by prefab fn
    self.stage_time = TOTAL_DAY -- set by prefab fn from def.crop_grow
end)

function PnHerbCrop:Configure(def)
    self.herb_id = def.id
    self.stage_time = (def.crop_grow * TOTAL_DAY) / self.maxstage
    self.seed_chance = def.seed_chance
end

function PnHerbCrop:OnPlanted()
    self.stage = 1
    self:_Refresh()
    self:_ScheduleNext()
end

function PnHerbCrop:SetAccel(mult, source)
    self.accel = mult
    self._accel_until = GetTime() + (config.LINHDIEN.SCAN_PERIOD * 2.5)
end

function PnHerbCrop:_CurAccel()
    if GetTime() <= self._accel_until then return self.accel end
    return 1.0
end

function PnHerbCrop:_ScheduleNext()
    if self._task then self._task:Cancel() end
    if self.stage >= self.maxstage then return end  -- mature: stop growing
    local dt = self.stage_time / self:_CurAccel()
    self._task = self.inst:DoTaskInTime(dt, function() self:_Advance() end)
end

function PnHerbCrop:_Advance()
    if self.stage < self.maxstage then
        self.stage = self.stage + 1
        self:_Refresh()
        self:_ScheduleNext()
    end
end

function PnHerbCrop:_Refresh()
    local anim = (self.stage >= self.maxstage) and "mature"
        or (self.stage == 1 and "stage1" or "stage" .. self.stage)
    if self.inst.AnimState then self.inst.AnimState:PlayAnimation(anim, false) end
    -- mature crop is harvestable
    if self.inst.components.pickable then
        self.inst.components.pickable.canbepicked = (self.stage >= self.maxstage)
    end
end

function PnHerbCrop:OnHarvest(picker)
    -- give a seed by chance, then regrow from stage 1
    if math.random() < (self.seed_chance or 0) and picker and picker.components.inventory then
        local seed = SpawnPrefab(self.herb_id .. "_seed")
        if seed then picker.components.inventory:GiveItem(seed) end
    end
    self.stage = 1
    self:_Refresh()
    self:_ScheduleNext()
end

function PnHerbCrop:OnSave() return { stage = self.stage } end
function PnHerbCrop:OnLoad(data)
    if data and data.stage then self.stage = data.stage end
    self:_Refresh(); self:_ScheduleNext()
end

----------------------------------------------------------------------
-- prefab factory
----------------------------------------------------------------------
local function MakeCrop(def)
    local assets = { Asset("ANIM", "anim/" .. def.build .. ".zip") }
    local cid = def.id .. "_crop"

    local function onpicked(inst, picker)
        if inst.components.pn_herb_crop then inst.components.pn_herb_crop:OnHarvest(picker) end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeObstaclePhysics(inst, 0.1)

        inst.AnimState:SetBank(def.build)   -- if build uses a different bank, fix here after Task 2 inspection
        inst.AnimState:SetBuild(def.build)
        inst.AnimState:PlayAnimation("stage1", false)

        inst:AddTag("pn_herb_crop")
        inst:AddTag("plant")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
        inst.components.pickable.onpickedfn = onpicked
        inst.components.pickable.product = def.id          -- gives the herb item
        inst.components.pickable.canbepicked = false

        inst:AddComponent("pn_herb_crop")
        inst.components.pn_herb_crop:Configure(def)

        return inst
    end
    return Prefab(cid, fn, assets)
end

-- register the component class name so AddComponent("pn_herb_crop") works:
-- DST resolves components from scripts/components/<name>.lua, so we ALSO expose a thin
-- component module (see Task 5 Step 2). Here we only build the prefabs.
local prefabs = {}
for _, def in ipairs(Herbs.herbs) do table.insert(prefabs, MakeCrop(def)) end
return unpack(prefabs)
```

- [ ] **Step 2: Extract the component to `scripts/components/pn_herb_crop.lua`**

DST resolves `AddComponent("pn_herb_crop")` from `scripts/components/pn_herb_crop.lua`, so the class must live there (not inline in the prefab). Move the `PnHerbCrop` class out:

Create `scripts/components/pn_herb_crop.lua` with the entire `PnHerbCrop` class block from Step 1 (the section between the two `---` rulers), ending with `return PnHerbCrop`. Then in `scripts/prefabs/pn_herb_crop.lua`, DELETE the inline class block and its `return`-less body, leaving only the `require`s, `MakeCrop`, the loop, and `return unpack(prefabs)`. The prefab no longer defines the class; it just uses `AddComponent("pn_herb_crop")`.

Resulting `scripts/components/pn_herb_crop.lua` top:
```lua
local Herbs = require("pn/herbs")
local config = require("pn/config")
local TOTAL_DAY = TUNING.TOTAL_DAY_TIME or 480

local PnHerbCrop = Class(function(self, inst)
    -- ... (exact body from Step 1) ...
end)
-- ... all PnHerbCrop methods from Step 1 ...
return PnHerbCrop
```

- [ ] **Step 3: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/prefabs/pn_herb_crop.lua scripts/components/pn_herb_crop.lua
git commit -m "feat(items-A): pn_herb_crop component + planted crop prefab (stage timer, accel-aware)"
```

---

## Task 6: Wild herb plant prefab (`pn_herb_plant.lua`)

**Files:**
- Create: `scripts/prefabs/pn_herb_plant.lua`

**Design:** wild version is a pickable that regenerates on its own timer (vanilla `pickable:SetUp(product, regen)`). Harvest gives herb + seed chance. Simpler than the crop (no stages). Tag `pn_herb_wild` for the scatter/regrowth.

- [ ] **Step 1: Write `scripts/prefabs/pn_herb_plant.lua`**

```lua
local Herbs = require("pn/herbs")

local TOTAL_DAY = TUNING.TOTAL_DAY_TIME or 480

local function MakeWild(def)
    local assets = { Asset("ANIM", "anim/" .. def.build .. ".zip") }
    local wid = def.id .. "_plant"

    local function onpicked(inst, picker)
        if math.random() < def.seed_chance and picker and picker.components.inventory then
            local seed = SpawnPrefab(def.id .. "_seed")
            if seed then picker.components.inventory:GiveItem(seed) end
        end
        if inst.AnimState then inst.AnimState:PlayAnimation("picked", false) end
    end

    local function onregen(inst)
        if inst.AnimState then inst.AnimState:PlayAnimation("mature", false) end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeObstaclePhysics(inst, 0.1)

        inst.AnimState:SetBank(def.build)
        inst.AnimState:SetBuild(def.build)
        inst.AnimState:PlayAnimation("mature", false)

        inst:AddTag("pn_herb_wild")
        inst:AddTag("plant")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("pickable")
        inst.components.pickable:SetUp(def.id, def.wild_regrow * TOTAL_DAY)
        inst.components.pickable.onpickedfn = onpicked
        inst.components.pickable.onregenfn = onregen
        inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
        return inst
    end
    return Prefab(wid, fn, assets)
end

local prefabs = {}
for _, def in ipairs(Herbs.herbs) do table.insert(prefabs, MakeWild(def)) end
return unpack(prefabs)
```

- [ ] **Step 2: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/prefabs/pn_herb_plant.lua
git commit -m "feat(items-A): wild herb plant prefab (pickable + regen + seed drop)"
```

---

## Task 7: Linh Điền structure prefab + placer (`pn_linhdien.lua`)

**Files:**
- Create: `scripts/prefabs/pn_linhdien.lua`

**Before:** read dst-create-building SKILL (structure + MakePlacer + onbuilt). Use build `pn_linhdien` if Task 2 produced it, else fall back to vanilla `"chest"` build (note in a comment).

- [ ] **Step 1: Write `scripts/prefabs/pn_linhdien.lua`**

```lua
local BUILD = "pn_linhdien"   -- if anim/pn_linhdien.zip missing, change BUILD/BANK to "chest"
local BANK = "pn_linhdien"

local assets = {
    Asset("ANIM", "anim/" .. BUILD .. ".zip"),
    Asset("ANIM", "anim/pn_linhdien.zip"),
    Asset("MINIMAP_IMAGE", "pn_linhdien"),
}
local prefabs = { "collapse_small" }

local function onbuilt(inst)
    if inst.AnimState then inst.AnimState:PlayAnimation("idle", true) end
    if inst.SoundEmitter then inst.SoundEmitter:PlaySound("dontstarve/common/together/sand_castle/place") end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)
    inst.MiniMapEntity:SetIcon("pn_linhdien.tex")

    inst.AnimState:SetBank(BANK)
    inst.AnimState:SetBuild(BUILD)
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddTag("pn_linhdien")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(function(i, worker)
        i.components.lootdropper:DropLoot()
        SpawnPrefab("collapse_small").Transform:SetPosition(i.Transform:GetWorldPosition())
        i:Remove()
    end)

    inst:AddComponent("pn_linhdien")

    inst.OnLoad = onbuilt
    return inst
end

return Prefab("pn_linhdien", fn, assets),
       MakePlacer("pn_linhdien_placer", BANK, BUILD, "idle")
```

- [ ] **Step 2: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/prefabs/pn_linhdien.lua
git commit -m "feat(items-A): linh điền structure prefab + placer + hammer/loot"
```

---

## Task 8: Registration — `main/items.lua` + `main/recipes.lua` + import

**Files:**
- Create: `scripts/main/items.lua`, `scripts/main/recipes.lua`
- Modify: `scripts/main/import.lua`

**Before:** read api-foundation pitfall #1 (main/* use GLOBAL.* + bare modutil names via env metatable; PrefabFiles/Assets are env globals).

- [ ] **Step 1: Write `scripts/main/items.lua`**

```lua
-- Register all Plan-A prefabs + their assets, the herb regrowth, and a world scatter.
local Herbs = GLOBAL.require("pn/herbs")
local config = GLOBAL.require("pn/config")

PrefabFiles = PrefabFiles or {}
local function addfiles(...) for _, f in ipairs({...}) do table.insert(PrefabFiles, f) end end
addfiles("pn_herb_items", "pn_herb_crop", "pn_herb_plant", "pn_linhdien")

Assets = Assets or {}
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/pn_herbs.xml"))
table.insert(Assets, Asset("IMAGE", "images/inventoryimages/pn_herbs.tex"))
table.insert(Assets, Asset("IMAGE", "images/map_icons/pn_linhdien.tex"))
table.insert(Assets, Asset("ATLAS", "images/map_icons/pn_linhdien.xml"))
for _, def in ipairs(Herbs.herbs) do
    table.insert(Assets, Asset("ANIM", "anim/" .. def.build .. ".zip"))
end

AddMinimapAtlas("images/map_icons/pn_linhdien.xml")

-- Wild herb regrowth (replenishes harvested-and-removed wild herbs over time).
AddSimPostInit(function(world)
    if not world.ismastersim then return end
    if world.components.regrowthmanager then
        for _, def in ipairs(Herbs.herbs) do
            world.components.regrowthmanager:SetRegrowthForType(
                def.id .. "_plant", def.wild_regrow * (GLOBAL.TUNING.TOTAL_DAY_TIME or 480))
        end
    end
end)

-- Scatter some wild herbs near spawn on first world start (no worldgen edits).
AddSimPostInit(function(world)
    if not world.ismastersim then return end
    world:DoTaskInTime(2, function()
        local map = world.Map
        local cx, cy, cz = 0, 0, 0
        local R = config.HERB.WILD_SCATTER_RADIUS
        local placed = 0
        local tries = 0
        while placed < config.HERB.WILD_SCATTER_COUNT and tries < config.HERB.WILD_SCATTER_COUNT * 8 do
            tries = tries + 1
            local a = math.random() * 2 * math.pi
            local d = math.random() * R
            local x, z = cx + math.cos(a) * d, cz + math.sin(a) * d
            if map:IsPassableAtPoint(x, 0, z) then
                local def = Herbs.herbs[math.random(#Herbs.herbs)]
                local p = GLOBAL.SpawnPrefab(def.id .. "_plant")
                if p then p.Transform:SetPosition(x, 0, z); placed = placed + 1 end
            end
        end
        print(string.format("[PN] scattered %d wild herbs", placed))
    end)
end)
```

- [ ] **Step 2: Write `scripts/main/recipes.lua`**

```lua
-- Linh Điền craftable. (Đan lô recipe arrives in Plan B.)
local TECH = GLOBAL.TECH

AddRecipe2("pn_linhdien",
    { Ingredient("cutgrass", 6), Ingredient("twigs", 4), Ingredient("rocks", 2) },
    TECH.SCIENCE_ONE,
    { placer = "pn_linhdien_placer", atlas = "images/map_icons/pn_linhdien.xml", image = "pn_linhdien.tex" },
    { "STRUCTURES" })

STRINGS.NAMES.PN_LINHDIEN = "Linh Điền"
STRINGS.RECIPE_DESC.PN_LINHDIEN = "Linh khí tụ — linh thảo trồng quanh đây lớn nhanh hơn."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PN_LINHDIEN = "Linh khí nồng đậm."

-- Herb item + seed display names
local Herbs = GLOBAL.require("pn/herbs")
for _, def in ipairs(Herbs.herbs) do
    STRINGS.NAMES[string.upper(def.id)] = def.display
    STRINGS.NAMES[string.upper(def.id) .. "_SEED"] = def.display .. " (hạt)"
    STRINGS.NAMES[string.upper(def.id) .. "_PLANT"] = def.display
    STRINGS.NAMES[string.upper(def.id) .. "_CROP"] = def.display
end
```

- [ ] **Step 3: Add to `scripts/main/import.lua`**

Insert these two lines after `modimport("scripts/main/strings.lua")` and before `modimport("scripts/main/character.lua")`:
```lua
modimport("scripts/main/items.lua")
modimport("scripts/main/recipes.lua")
```

- [ ] **Step 4: Syntax + asset check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
git add scripts/main/items.lua scripts/main/recipes.lua scripts/main/import.lua
git commit -m "feat(items-A): register herb/crop/seed/linh điền prefabs + assets + recipe + regrowth + scatter"
```

---

## Task 9: Debug commands for farming

**Files:**
- Modify: `scripts/main/debug.lua`

- [ ] **Step 1: Append farming debug commands to `scripts/main/debug.lua`** (before the final `print(...)`; update that print's list too)

```lua
local Herbs = GLOBAL.require("pn/herbs")

function GLOBAL.c_giveherbs(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not (player and player.components.inventory) then return end
    for _, def in ipairs(Herbs.herbs) do
        local h = GLOBAL.SpawnPrefab(def.id); if h then player.components.inventory:GiveItem(h) end
        local s = GLOBAL.SpawnPrefab(def.id .. "_seed"); if s then player.components.inventory:GiveItem(s) end
    end
    print("[PN] gave all herbs + seeds")
end

function GLOBAL.c_spawnwild(id, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local def = Herbs.Get(id) or Herbs.herbs[1]
    local x, y, z = player.Transform:GetWorldPosition()
    local p = GLOBAL.SpawnPrefab(def.id .. "_plant")
    if p then p.Transform:SetPosition(x + 2, 0, z); print("[PN] spawned " .. def.id .. "_plant") end
end
```

Then update the trailing print line to:
```lua
print("[PN] debug loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_pnhud, c_giveherbs, c_spawnwild")
```

- [ ] **Step 2: Syntax check + commit**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
git add scripts/main/debug.lua
git commit -m "feat(items-A): debug c_giveherbs + c_spawnwild"
```

---

## Task 10: Integration — sync + in-game verification

**Files:** none.

- [ ] **Step 1: Static checks all pass**

```bash
cd /Users/kimdat546/Desktop/pham-nhan-tu-tien-mod
./tools/check_syntax.sh
./tools/check_assets.py
```
Expected: both green.

- [ ] **Step 2: Sync to local DST**

```bash
./tools/sync_local.sh
```

- [ ] **Step 3: USER in-game verification (ask the user to run it)**

Tell the user: quit DST fully, relaunch, enable mod, Host Game. In-game checks (console `~`, remember Remote vs Local — these touch server components so use **Remote/default**, except HUD-only):
1. Spawn → some wild herbs scattered near spawn (or run `c_spawnwild("pn_herb_huangcao")`).
2. Harvest a wild herb → get the herb item (+ sometimes a seed).
3. `c_giveherbs()` → inventory gets all 4 herbs + seeds.
4. Build **Linh Điền** (Structures tab, costs 6 cutgrass/4 twigs/2 rocks).
5. Deploy a seed ON THE GROUND near the Linh Điền → a crop appears (stage1).
6. Deploy another seed FAR from any Linh Điền. Wait/observe: the near-Linh-Điền crop advances stages ~2x faster than the far one (use `c_speedup()` if available, or fast-forward days).
7. When a crop shows the `mature` anim → harvest → get the herb (+ seed chance) → crop resets to stage1 and regrows.
8. Hammer the Linh Điền → it breaks and drops loot.

If a Lua error or missing-anim appears, capture it from `client_log.txt` / `server_log.txt`. The most likely issue is a wrong bank/anim name on a herb build — fix the `SetBank`/`PlayAnimation` names per the build's real contents (Task 2 Step 2) and re-sync.

- [ ] **Step 4: Tag (after user confirms)**

```bash
git tag -a items-A-farming-complete -m "M-Items-1 Plan A — linh thảo + linh điền farming loop complete (verified in-game)."
git tag --list | grep items-A
```

---

## Self-review

**Spec coverage (Plan A portion of spec §4):**
- §4.1 wild herb pickable + regrowth → Task 6 + Task 8 ✓
- §4.2 seeds deployable → Task 3 ✓
- §4.3 Linh Điền structure + accel component → Task 4 + Task 7 ✓
- §4.4 crop with grow stages + accel → Task 5 ✓
- §3.1 herbs data + §3.3 config → Task 1 ✓
- §6 registration → Task 8 ✓; §10 testing → Task 10 ✓
- Art (§4.1 reuse 山海秘藏) → Task 2 ✓

**Placeholder scan:** Placeholder ICONS are intentional (real art = polish, spec §8). Bank/anim names have a documented fallback (Task 2 Step 2 + Task 10 note). No TBD logic.

**Type consistency:** prefab name scheme consistent everywhere — `<id>` (herb item), `<id>_seed`, `<id>_plant` (wild), `<id>_crop` (planted). Component `pn_herb_crop` methods (Configure/OnPlanted/SetAccel/OnHarvest/OnSave/OnLoad) match between component file (Task 5 Step 2) and callers (crop prefab Task 5, linh điền Task 4). `config.LINHDIEN.*` and `config.HERB.*` keys match Task 1 ↔ Tasks 4/5/8. `pickable:SetUp(product, regen)` matches verified signature.

**NOT in Plan A (Plan B):** đan lô, pills, pn_buff, pill recipes — herbs are the inputs Plan B consumes.

---

**End of Plan A.**

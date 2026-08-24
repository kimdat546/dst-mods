# Reference Mod Study — Patterns vs. PNTT Mod

Date: 2026-05-24. Compared 5 workshop mods against `pham-nhan-tu-tien-mod` to find
crash-prone or non-idiomatic patterns. Focus: server-side stability for dedicated server.

## 1. Summary

| Mod                                       | Status                | Used as reference for                          |
| ----------------------------------------- | --------------------- | ---------------------------------------------- |
| 1699194522 Myth Characters                | **Encrypted** (skip)  | n/a                                            |
| 1991746508 Myth Words                     | **Encrypted** (skip)  | n/a                                            |
| 3046680574 Mountain and Sea Treasure Ch3  | Readable              | custom item prefabs, worldgen scatter, replicas |
| 3730126500 Book of Everything (TBAT)      | Readable, multi-mod   | worldgen patterns, replicas, postinit hooks    |
| 3731336839 Heap of Foods                  | Readable, large       | modmain layout, AddComponentPostInit, world postinit |

The two encrypted mods use the Dengxian loader (`local e=_G or GLOBAL; ... kleiloadlua`)
and their Lua source is unrecoverable without decryption — they were skipped.

## 2. `modmain.lua` patterns

### What references do well

- **HoF** organises modmain as pure require-list (`hof_init/misc/*`, `hof_init/world/*`,
  `hof_init/foods/*`). Almost nothing is defined inline. modmain stays under 180 lines.
- **MSE** uses `modimport("mod_key_modules_for_mountain_and_sea/...")` to delegate, then
  pulls a single `PrefabFiles = {"fountains_and_sea_are_mysterious__all_prefabs"}`
  aggregator file.
- **TBAT** uses a sub-mod loader (overkill for us). Its sub-modmain re-implements
  `AddComponentAction` so multiple registrations on the same `(typename, cmpname)`
  pair don't clobber each other — useful future pattern when we add custom actions.
- All three keep `AddPrefabPostInit("world", ...)` callbacks **very short** —
  they delegate to a `main_spawn_task(inst)` function. PNTT inlines two large
  closures with `DoTaskInTime`.

### What PNTT does that diverges

- `modmain.lua` lines 89-168 contain **two separate** `AddPrefabPostInit("world", ...)`
  blocks that each do a `DoTaskInTime` then a hand-rolled rejection-sampling scatter
  via `math.random()` angles + `IsAboveGroundAtPoint`. None of the reference mods do
  this. They either:
  - place via `topology.nodes[zoneid].cent` + `TheWorld.Map:CanDeployAtPoint`
    (TBAT, see `10_resources_memory_crystal_ore_spawner.lua`), or
  - use `AddTaskPreInit` / `AddPrefabSetpiece` worldgen registration (MSE).
- TBAT scatters use `inst:StartThread(function() Sleep(10 + math.random(10)); ... end)`
  rather than `DoTaskInTime(0, ...)`. The thread approach is safer because it
  yields between `SpawnPrefab` calls and won't block the main tick if we ever
  place hundreds of entities.
- TBAT gates with `if not TheWorld.ismastersim or TheWorld:HasTag("cave") then return end`.
  PNTT only checks `ismastersim`; on caves world this means scatter runs and tries
  to spawn `pn_linhkhi_ha` 20× on **the cave map**. If the points all fail
  `IsAboveGroundAtPoint` we just leak attempts. Worse, we'd duplicate Linh Mạch on
  both shards.

## 3. Custom prefab patterns

### MSE `01_fsm_miyi_snakeskin.lua` (template for inventory items)

```lua
local assets = {
    Asset("ANIM",  "anim/fsm_miyi_snakeskin.zip"),
    Asset("ATLAS", "images/inventoryimages/fsm_miyi_snakeskin.xml"),
}
...
inst.AnimState:SetBank("fsm_miyi_snakeskin")
inst.AnimState:SetBuild("fsm_miyi_snakeskin")
inst.AnimState:PlayAnimation("idle")
...
inst.components.inventoryitem.imagename = "fsm_miyi_snakeskin"
inst.components.inventoryitem.atlasname = "images/inventoryimages/fsm_miyi_snakeskin.xml"
return Prefab("fsm_miyi_snakeskin", fn, assets)
```

**Three invariants** every MSE/HoF custom item follows:

1. **Both** `Asset("ANIM", "anim/<name>.zip")` **and** `Asset("ATLAS", "images/inventoryimages/<name>.xml")` declared locally.
2. Bank and build use the **mod-private** name (`fsm_miyi_snakeskin`) — never a vanilla bank name.
3. `imagename` (without `.tex`) **and** `atlasname` (full XML path) both set on `inventoryitem`.

### What PNTT does

- `pn_noidan.lua` / `pn_linhthao.lua` / `pn_linhkhi_source.lua` all use `SetBank("gems")` + `SetBuild("gems")` and rely on the engine auto-loading `anim/gems.zip`. **Asset list is empty** (`assets = {}`). This works because `gems.zip` is unconditionally loaded by Klei's `gem.lua`, but only if some `gem` prefab is referenced in the world — on a fresh dedicated server with no gems spawned yet the bank may not be resident when our prefab gets constructed.
- Comment in `pn_noidan.lua:16-19` explicitly leaves `inventoryitem.atlasname` unset. This is correct for now (matches vanilla gem.lua) — but **`imagename` is also unset**, which means HUD will render a missing-texture placeholder when the item enters inventory. MSE always sets `imagename = "<prefab>"`.

### Recommended fix

Declare the vanilla anim explicitly to guarantee the bank is loaded before our prefabs construct:

```lua
-- in pn_noidan.lua, pn_linhthao.lua, pn_linhkhi_source.lua
local assets = {
    Asset("ANIM", "anim/gems.zip"),
}
```

This is cheap (already-bundled file, no duplication) and prevents the AnimState corruption you already hit when you used non-existent bank names.

## 4. Component / replica patterns

### Reference pattern (TBAT `01_replica_register.lua`)

- Each `*_replica.lua` is a `Class(function(self, inst) ... self.classified = SpawnPrefab("...classified") end)` OR a pure `net_*` field wrapper.
- Modmain calls `AddReplicableComponent("foo")` — `_replica` suffix discovered automatically.
- Replica file MUST be at `scripts/components/<name>_replica.lua`.

### PNTT status — looks correct

Verified files:
- `pn_canhgioi_replica.lua` — uses `net_tinybyte`. ✓
- `pn_tuvi_replica.lua` — uses `net_float`. ✓
- `pn_lifespan_replica.lua` — uses `net_float` + `net_bool`. ✓
- `pn_linhcan_replica.lua` — present, registered. ✓

`modmain.lua:43-46` registers all four. **Bug to flag:**

- `pn_breakthrough` is added in `phamnhan.lua:30` (`inst:AddComponent("pn_breakthrough")`) but the comment in modmain says "server-only — no replica". That's fine IF and only if no client code calls `inst.replica.pn_breakthrough`. **Verify no client widget reads it** — otherwise add an empty replica or `AddReplicableComponent("pn_breakthrough")` to suppress the auto-warning.
- `pn_meditation`, `pn_aura_source`, `pn_mob_cultivation` are server-only too. None registered — that's correct, but again: client HUD must not touch `inst.replica.pn_meditation`.

## 5. Worldgen scatter

### Where references differ from us

PNTT uses `AddPrefabPostInit("world", ...)` + random-angle scatter. Reference mods use one of:

| Approach                                | Used by      | When                          |
| --------------------------------------- | ------------ | ----------------------------- |
| `AddTaskPreInit` + `room_choices`       | MSE          | Add custom rooms to biomes    |
| `AddTaskSetPreInit` + `set_pieces`      | MSE          | Static-layout islands         |
| `AddPrefabSetpiece`                     | HoF, MSE     | Pre-baked layouts             |
| `AddPrefabPostInit("world", ...)` + `StartThread` + `topology.nodes` walk | TBAT (`10_resources_memory_crystal_ore_spawner.lua`) | Resource scatter post-worldgen |

TBAT's pattern (`02_the_world_upgrade/10_*.lua`) is the **closest analog** to what we want for Linh Mạch. It:

1. Stores a flag in `TheWorld.components.tbat_data` so the scatter only runs **once per save**, not on every `world` reload.
2. Iterates `TheWorld.topology.ids` filtering by task name (e.g. `"Mole Colony Rocks"`).
3. Validates each candidate point with `TheWorld.Map:CanDeployAtPoint(pt, test_inst)`.
4. Uses a single placeholder `test_inst = SpawnPrefab(...)` for collision checking and `:Remove()`s it at the end.

### Concrete PNTT issues

- **Re-runs every server boot.** `modmain.lua:89-128` and `131-168` don't persist a "scattered" flag. On every world load they will spawn another 28 Linh Mạch + 90 Linh Thảo. Within ~5 saves the map will have hundreds.
- **No cave gate.** `if not GLOBAL.TheWorld.ismastersim then return end` runs on both forest and cave shards. Cave shard will try to scatter onto cave biomes.
- **`SpawnPrefab` directly from postinit can leak entities.** A spawn that fails `IsAboveGroundAtPoint` after spawn (you spawn first then check — wait, you check first, OK). But you never test with `Map:CanDeployAtPoint`, so points on cliffs, in ruins, on roads, inside set pieces will silently succeed.

## 6. Specific recommendations

### A. Gate worldgen scatter on shard + persist a "done" flag

**File:** `/Users/kimdat546/Desktop/pham-nhan-tu-tien-mod/modmain.lua` lines 88-168

Replace both scatter blocks with a single shard-gated, idempotent version. Sketch:

```lua
AddPrefabPostInit("forest", function(inst)   -- not "world" — explicit forest only
    if not GLOBAL.TheWorld.ismastersim then return end
    inst:DoTaskInTime(0, function()
        if inst.pn_scattered then return end -- in-memory dedupe per session
        inst.pn_scattered = true
        -- TODO: persist via OnSave/OnLoad or a dummy component
        local cfg = GLOBAL.require("pn/tuning").WORLDGEN
        ...
    end)
end)
```

Persistence (matching TBAT pattern): create a tiny `pn_worldstate` component on the forest world, save `{ linh_mach_scattered = true, linh_thao_scattered = true }` in `OnSave`, skip scatter if set on `OnLoad`.

### B. Use `Map:CanDeployAtPoint` instead of `IsAboveGroundAtPoint`

Same file, inside the inner `place` function:

```lua
local pt = GLOBAL.Vector3(x, 0, z)
if map:IsAboveGroundAtPoint(x, 0, z)
   and map:CanDeployAtPoint(pt, test_inst) then  -- add this
   ...
end
```

You'll need a `test_inst = SpawnPrefab("pn_linhkhi_ha")` at the top of the task and `test_inst:Remove()` at the bottom — see TBAT line 38 & 77.

### C. Declare `anim/gems.zip` in prefab assets

**Files:**
- `scripts/prefabs/pn_linhkhi_source.lua` line 10
- `scripts/prefabs/pn_noidan.lua` (currently has no `assets` table at top)
- `scripts/prefabs/pn_linhthao.lua` (same)

Change `local assets = {}` (or add it) to:

```lua
local assets = {
    Asset("ANIM", "anim/gems.zip"),
}
```

Then pass `assets` as the 3rd arg to `Prefab(...)`. Currently `pn_noidan` passes `{}` and `pn_linhthao` passes `{}` — replace with the variable.

### D. Set `inventoryitem.imagename`

Even without `atlasname`, set `imagename` so the inventory grid can attempt resolution. Vanilla gems use the global `inventoryimages` atlas which IS accessible from mods (HoF and MSE both do this). Sketch in `pn_noidan.lua` around line 43:

```lua
inst:AddComponent("inventoryitem")
inst.components.inventoryitem.imagename = "redgem"  -- or "bluegem" / "purplegem" per tier
-- atlasname omitted, engine falls back to inventoryimages.tex/xml
```

This is the pattern Klei uses internally for compound atlases. Verify with `inst.components.inventoryitem:GetImage()` after spawn.

### E. `AddComponentPostInit("health", ...)` — risky

**File:** `modmain.lua:59-71`

HoF uses `AddComponentPostInit` 12 times — all on **non-critical** components (`edible`, `debuffable`, `foodaffinity`, `fishingrod`, etc.). HoF does **not** patch `health`. Patching every entity's `Health.SetVal` runs on **mobs, bosses, structures with health** — anything that gets `AddComponent("health")`. Our guard `inst.components.pn_lifespan` skips non-players in practice, but the function chain still executes on every `health:SetVal` server-wide.

Two concerns:
1. **Performance:** `SetVal` is called several times per combat tick per entity.
2. **Correctness:** `_SetVal` is captured per-instance via closure but the upvalue `self:SetVal` lookup is unusual — verify it's actually capturing the method, not re-binding. Safer pattern:

```lua
AddComponentPostInit("health", function(self)
    local _SetVal = self.SetVal
    self.SetVal = function(self, val, cause, afflicter)
        local inst = self.inst
        if inst and inst.components.pn_lifespan
           and inst.components.pn_lifespan:IsPermadeath() and val > 0 then
            return _SetVal(self, 0, cause or "permadeath", afflicter)
        end
        return _SetVal(self, val, cause, afflicter)
    end
end)
```

Note `self.SetVal = function(self, ...)` instead of `function self:SetVal(val,...)`. The `function self:SetVal` form inside an `AddComponentPostInit` callback rebinds the **local** `self`, not the component class — meaning the override may only apply to the first instance. **This is a likely-real bug.** Check by spawning two players and verifying both block reroll.

### F. `TUNING.LINH_MACH` key mismatch

**File:** `scripts/prefabs/pn_linhkhi_source.lua:57-59`

Prefab names are `pn_linhkhi_ha/trung/thuong` (lowercase, abbreviated). Tier keys passed to `MakeLinhKhi` are `HA_PHAM`, `TRUNG_PHAM`, `THUONG_PHAM`. `TUNING.LINH_MACH` (tuning.lua:30-47) uses `HA_PHAM/TRUNG_PHAM/THUONG_PHAM`. ✓ consistent.

But `TUNING.WORLDGEN.LINH_MACH_COUNT` (tuning.lua:57) uses bare `HA/TRUNG/THUONG`. `modmain.lua:119-121` reads those. ✓ also consistent but with a **different** key namespace. Not a bug, just confusing — consider unifying to a single suffix convention.

### G. Replica registration for `pn_breakthrough`

**File:** `modmain.lua:47`

Comment claims pn_breakthrough is server-only. If any client widget ever calls `player.replica.pn_breakthrough`, you'll crash. Audit `scripts/widgets/` and `scripts/pn/` for any such reference; if none, leave it. If unsure, add:

```lua
-- Empty replica to satisfy auto-replica lookup on clients (no networked state needed).
AddReplicableComponent("pn_breakthrough")
```

…and create a stub `scripts/components/pn_breakthrough_replica.lua`:

```lua
return Class(function(self, inst) self.inst = inst end)
```

## Priority ranking

1. **E** — broken `AddComponentPostInit("health")` override semantics. Likely-real bug, server-wide impact.
2. **A** — worldgen runs every reload. Will fill the map with garbage Linh Mạch over time.
3. **C** — declare `anim/gems.zip` asset. Cheap fix; prevents potential AnimState crashes.
4. **B** — `CanDeployAtPoint` validation. Quality fix.
5. **D** — `imagename` for inventoryitem. UX fix.
6. **G**, **F** — verify-only.

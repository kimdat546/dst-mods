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

local TOTAL_DAY = GLOBAL.TUNING.TOTAL_DAY_TIME or 480

-- Wild herb regrowth (replenishes harvested-and-removed wild herbs over time).
AddSimPostInit(function(world)
    if not world.ismastersim then return end
    if world.components.regrowthmanager then
        for _, def in ipairs(Herbs.herbs) do
            world.components.regrowthmanager:SetRegrowthForType(
                def.id .. "_plant", def.wild_regrow * TOTAL_DAY, def.id .. "_plant")
        end
    end
end)

-- Scatter some wild herbs near spawn on world start (no worldgen edits).
AddSimPostInit(function(world)
    if not world.ismastersim then return end
    world:DoTaskInTime(2, function()
        local map = world.Map
        local R = config.HERB.WILD_SCATTER_RADIUS
        local placed, tries = 0, 0
        while placed < config.HERB.WILD_SCATTER_COUNT and tries < config.HERB.WILD_SCATTER_COUNT * 8 do
            tries = tries + 1
            local a = math.random() * 2 * math.pi
            local d = math.random() * R
            local x, z = math.cos(a) * d, math.sin(a) * d
            if map:IsPassableAtPoint(x, 0, z) then
                local def = Herbs.herbs[math.random(#Herbs.herbs)]
                local p = GLOBAL.SpawnPrefab(def.id .. "_plant")
                if p then p.Transform:SetPosition(x, 0, z); placed = placed + 1 end
            end
        end
        print(string.format("[PN] scattered %d wild herbs", placed))
    end)
end)

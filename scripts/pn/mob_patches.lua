-- scripts/pn/mob_patches.lua
-- Apply pn_mob_cultivation to a curated list of vanilla mob prefabs.
-- AddPrefabPostInit runs on every spawn of each prefab (server-side only here).

local MOBS_TO_PATCH = {
    -- Spiders
    "spider", "spider_warrior", "spider_hider", "spider_spitter", "spider_dropper",
    -- Hounds
    "hound", "firehound", "icehound",
    -- Insects / amphibians
    "mosquito", "frog", "killerbee", "bee",
    -- Pigs / mermen
    "merm", "pigman", "pigguard",
    -- Clockwork
    "clockworkknight", "clockworkbishop", "clockworkrook",
    -- Birds
    "crow", "robin", "canary",
    -- Bunnymen (caves)
    "bunnyman",
}

for _, prefab_name in ipairs(MOBS_TO_PATCH) do
    AddPrefabPostInit(prefab_name, function(inst)
        -- Tag (also added on clients so the lookup works for replicas if needed)
        inst:AddTag("pn_aura_target")

        if not GLOBAL.TheWorld.ismastersim then return end

        -- Component (server-only)
        if not inst.components.pn_mob_cultivation then
            inst:AddComponent("pn_mob_cultivation")
        end
    end)
end

print(string.format("[PN] Patched %d vanilla mob prefabs for cultivation", #MOBS_TO_PATCH))

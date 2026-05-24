-- Phàm Nhân Tu Tiên — modmain entry
-- Plan 1: register phamnhan character only

GLOBAL.setmetatable(env, {
    __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end,
})

PrefabFiles = {
    "phamnhan",
    "pn_linhkhi_source",
}

Assets = {
    Asset("IMAGE", "images/saveslot_portraits/phamnhan.tex"),
    Asset("ATLAS", "images/saveslot_portraits/phamnhan.xml"),

    Asset("IMAGE", "bigportraits/phamnhan.tex"),
    Asset("ATLAS", "bigportraits/phamnhan.xml"),

    Asset("IMAGE", "images/map_icons/phamnhan.tex"),
    Asset("ATLAS", "images/map_icons/phamnhan.xml"),

    Asset("IMAGE", "images/avatars/avatar_phamnhan.tex"),
    Asset("ATLAS", "images/avatars/avatar_phamnhan.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_phamnhan.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_phamnhan.xml"),

    Asset("IMAGE", "images/names_phamnhan.tex"),
    Asset("ATLAS", "images/names_phamnhan.xml"),
}

AddMinimapAtlas("images/map_icons/phamnhan.xml")

-- Register phamnhan as a playable character
AddModCharacter("phamnhan", "MALE")

-- Register cultivation components.
-- Server components are auto-discovered by name from scripts/components/<name>.lua
-- when `inst:AddComponent("<name>")` is called. We just need to register their replicas.
AddReplicableComponent("pn_linhcan")
AddReplicableComponent("pn_tuvi")
AddReplicableComponent("pn_canhgioi")
AddReplicableComponent("pn_lifespan")
-- pn_breakthrough is server-only — no replica registration needed.

-- Attach HUD widget to player controls bottom-left.
AddClassPostConstruct("widgets/controls", function(self)
    local PnHudMain = require("widgets/pn_hud_main")
    self.pn_hud = self.bottom_root:AddChild(PnHudMain(self.owner))
    self.pn_hud:SetPosition(-400, 90)
end)

-- Permadeath enforcement: when pn_lifespan.permadeath is true, the player cannot
-- be revived by any means. We monkey-patch Health:DoDelta to prevent healing from
-- restoring life, and listen for revive attempts to abort them.
AddComponentPostInit("health", function(self)
    local _SetVal = self.SetVal
    function self:SetVal(val, cause, afflicter)
        local inst = self.inst
        if inst and inst.components and inst.components.pn_lifespan
           and inst.components.pn_lifespan:IsPermadeath()
           and val > 0 then
            -- Block any attempt to set HP above 0 once permadeath is set.
            return _SetVal(self, 0, cause or "permadeath", afflicter)
        end
        return _SetVal(self, val, cause, afflicter)
    end
end)

-- Block ghost-form revival actions for permadeath players.
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    inst:ListenForEvent("ms_playerreroll", function(_, data)
        local p = data and data.player
        if p and p.components and p.components.pn_lifespan
           and p.components.pn_lifespan:IsPermadeath() then
            -- Cancel reroll
            print(string.format("[PN] Blocked reroll for permadeath player %s",
                tostring(p.userid)))
            return false
        end
    end)
end)

-- Worldgen scatter — place linh mạch across the map on world init.
AddPrefabPostInit("world", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end

    -- Defer until next frame so the map is fully ready.
    inst:DoTaskInTime(0, function()
        local cfg = GLOBAL.require("pn/tuning").WORLDGEN
        if not cfg or not cfg.LINH_MACH_COUNT then return end

        local map = GLOBAL.TheWorld.Map
        if not map then return end

        local function place(prefab_name, count, min_dist)
            for i = 1, count do
                local attempts = 0
                while attempts < (cfg.SCATTER_ATTEMPTS or 30) do
                    local angle = math.random() * 2 * math.pi
                    local r     = min_dist + math.random() * 400
                    local x, z  = math.cos(angle) * r, math.sin(angle) * r
                    if map:IsAboveGroundAtPoint(x, 0, z) then
                        local ent = GLOBAL.SpawnPrefab(prefab_name)
                        if ent then
                            ent.Transform:SetPosition(x, 0, z)
                            break
                        end
                    end
                    attempts = attempts + 1
                end
            end
        end

        place("pn_linhkhi_ha",     cfg.LINH_MACH_COUNT.HA,     cfg.LINH_MACH_MIN_DIST.HA)
        place("pn_linhkhi_trung",  cfg.LINH_MACH_COUNT.TRUNG,  cfg.LINH_MACH_MIN_DIST.TRUNG)
        place("pn_linhkhi_thuong", cfg.LINH_MACH_COUNT.THUONG, cfg.LINH_MACH_MIN_DIST.THUONG)

        print(string.format(
            "[PN] Scattered linh mạch: %d hạ, %d trung, %d thượng",
            cfg.LINH_MACH_COUNT.HA, cfg.LINH_MACH_COUNT.TRUNG, cfg.LINH_MACH_COUNT.THUONG
        ))
    end)
end)

-- Character select override (Phase E / Task 14)
modimport("scripts/pn/charselect_override.lua")

-- Register character speech
STRINGS.CHARACTER_TITLES.phamnhan      = "Phàm Nhân"
STRINGS.CHARACTER_NAMES.phamnhan       = "Phàm Nhân"
STRINGS.CHARACTER_DESCRIPTIONS.phamnhan= "Một phàm nhân bình thường, mơ ước con đường tu tiên."
STRINGS.CHARACTER_QUOTES.phamnhan      = "\"Tu đạo chi lộ, nghịch thiên mà hành.\""

-- Debug console commands (always loaded during MVP; gate behind config in later plans)
modimport("scripts/pn/debug.lua")
modimport("scripts/pn/actions.lua")
modimport("scripts/pn/mob_patches.lua")

print("[PN] Phàm Nhân Tu Tiên mod loaded (Plan 1 — Foundation)")

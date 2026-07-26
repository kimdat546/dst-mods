-- Grant tu vi to a phàm nhân who kills a monster, and buff monster stats so the
-- world stays dangerous as players grow. Runs in modmain env → GLOBAL available.
local config = GLOBAL.require("pn/config")
local Events = GLOBAL.require("pn/events")

local function PatchMob(prefab_name)
    AddPrefabPostInit(prefab_name, function(inst)
        if not GLOBAL.TheWorld.ismastersim then return end

        -- Flat stat buff (M1 static; dynamic scaling = world-scaling milestone)
        if inst.components.health then
            local m = config.MOB_BUFF.hp_mult
            inst.components.health:SetMaxHealth(inst.components.health.maxhealth * m)
            inst.components.health:SetPercent(1)
        end
        if inst.components.combat then
            inst.components.combat.damagemultiplier =
                (inst.components.combat.damagemultiplier or 1) * config.MOB_BUFF.dmg_mult
        end

        -- Grant tu vi to the killer
        inst:ListenForEvent("death", function()
            local killer = inst.components.combat and inst.components.combat.lastattacker
            if not (killer and killer:HasTag("phamnhan")) then return end
            local amount = config.TUVI_PER_MOB[inst.prefab] or 5
            killer:PushEvent(Events.TUVI_GAIN, { amount=amount, source="kill_"..tostring(inst.prefab) })
        end)
    end)
end

for _, name in ipairs(config.MOBS_TO_PATCH) do PatchMob(name) end
print(string.format("[PN] patched %d mob prefabs for tu vi + buff", #config.MOBS_TO_PATCH))

local HH_UTILS = require("utils/hh_utils")
local HH_ITEMS = {
    ["a_punchStone"] = { ["name"] = "打孔石", },
    ["a_stoneDecoder"] = { ["name"] = "解石器", },
    ["a_refreshStone"] = { ["name"] = "重置宝石", },
    --耐久恢复
    ["durableGem"] = { ["name"] = "耐用宝珠", },
    --固定增伤
    ["damageBoostGem"] = { ["name"] = "增伤宝珠", },
    --伤害加成
    ["powerMettleStone"] = { ["name"] = "力势石", },
    --移速加成
    ["strideBead"] = { ["name"] = "步伐珠", },
    --吸血效果
    --["strideBead"] = { ["name"] = "血战晶", },
    --夜晚造成伤害增加
    ["shadowNightBead"] = { ["name"] = "暗袭珠", },
    ["followCritical"] = { ["name"] = "灵兽-暴", },
    ["followDamage"] = { ["name"] = "灵兽-攻", },
    ["followArmor"] = { ["name"] = "灵兽-御", },
    --黄昏伤害增加
    ["twilightBead"] = { ["name"] = "昏光珠", },
    --白天伤害增加
    ["dayShineBead"] = { ["name"] = "光耀珠", },
    --增加暴击率和暴击效果
    ["critStrikeStone"] = { ["name"] = "暴击石", },
    --伤害减免
    ["resistDamageGem"] = { ["name"] = "抗伤石", },
    --增加血量上限
    ["vigorousStone"] = { ["name"] = "蓬勃石", ["person_only"] = true, },
    --免疫过冷
    ["frostGuardCrystal"] = { ["name"] = "防寒晶", ["person_only"] = true, },
    --免疫过热
    ["heatGuardCrystal"] = { ["name"] = "防暑晶", ["person_only"] = true, },
    --免疫过冷 过热 火焰伤害 冰冻
    ["elementBead"] = { ["name"] = "元素之星", ["person_only"] = true, },
    --造成反弹伤害
    ["retaliateGem"] = { ["name"] = "反伤石", },
    --对蜘蛛造成的伤害增加
    ["spiderVengeance"] = { ["name"] = "蜘蛛打击", },
    --昆虫类
    ["insectStrikeCrystal"] = { ["name"] = "昆虫打击", },
    --暗影生物
    ["shadowStrikeLuminary"] = { ["name"] = "暗影打击", },
    --boss
    ["bossStrikeGem"] = { ["name"] = "首领打击", },
    ["z_clean_stone"] = { ["name"] = "净化符", },

    ["eightPigGem"] = { ["name"] = "音音石", ["person_only"] = true, },
    ["nkGem"] = { ["name"] = "嘉心糖", ["person_only"] = true, },

    ["baconOmeletteBlessArmor"] = { ["name"] = "极致-防", ["person_only"] = true, },
    ["baconOmeletteBlessAtk"] = { ["name"] = "极致-攻", ["person_only"] = true, },
    ["baconOmeletteBlessCritical"] = { ["name"] = "极致-暴", ["person_only"] = true, },
    ["baconOmeletteTrueDamage"] = { ["name"] = "极-真伤", ["person_only"] = true, },
    ["fxGem"] = { ["name"] = "特效宝石", ["person_only"] = true, },

    --["z_map_blink"] = { ["name"] = "地图传送", ["person_only"] = true, },
    --宝藏宝石
    ["treasure_atk"] = { ["name"] = "宝★攻击", ["person_only"] = true, },
    ["treasure_bj"] = { ["name"] = "宝★暴击", ["person_only"] = true, },
    ["treasure_armor"] = { ["name"] = "宝★回耐", ["person_only"] = true, },
    ------------------------------------道具类物品---------------------------------------------------
    ["z_fertilizer"] = {
        ["name"] = "术:施肥", ["person_only"] = true,
        ["is_item"] = true,
        ["item_fn"] = function(inst)
            if not HH_UTILS:NotIsDead(inst) or not inst["Transform"] then
                return false
            end
            local x, y, z = inst["Transform"]:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 28, nil, { "FX", "DECOR", "INLIMBO", "burnt" })
            for i, v in ipairs(ents) do
                if v["components"]["burnable"] ~= nil then
                    if HH_UTILS:HasComponents(v, "witherable") then
                        --枯萎的施肥
                        v["components"]["witherable"]:Protect(TUNING["FIRESUPPRESSOR_PROTECTION_TIME"])
                    end
                    if HH_UTILS:HasComponents(v, "burnable") then
                        --灭火
                        if v["components"]["burnable"]:IsBurning() then
                            v["components"]["burnable"]:Extinguish(true, TUNING["WATERINGCAN_EXTINGUISH_HEAT_PERCENT"])
                        elseif v["components"]["burnable"]:IsSmoldering() then
                            v["components"]["burnable"]:Extinguish(true)
                        end
                    end
                end
            end
            for k1 = -28, 28, 4 do
                for k2 = -28, 28, 4 do
                    local tile = TheWorld["Map"]:GetTileAtPoint(x + k1, 0, z + k2)
                    if tile == GROUND["FARMING_SOIL"] then
                        TheWorld["components"]["farming_manager"]:AddSoilMoistureAtPoint(x + k1, 0, z + k2, 100)--水满
                        local tile_x, tile_z = TheWorld["Map"]:GetTileCoordsAtPoint(x + k1, 0, z + k2)
                        TheWorld["components"]["farming_manager"]:AddTileNutrients(tile_x, tile_z, 100, 100, 100)----回满肥料
                    end
                end
            end
            return true
        end
    },
    ["z_plant"] = {
        ["name"] = "术:催熟", ["person_only"] = true,
        ["is_item"] = true,
        ["item_fn"] = function(player)
            if not HH_UTILS:NotIsDead(player) or not player["Transform"] then
                return false
            end
            local x, y, z = player["Transform"]:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 30, nil, { "pickable", "stump", "withered", "INLIMBO" })
            if #ents > 0 then
                HH_UTILS:TryGrowth(table["remove"](ents, math["random"](#ents)), player)
                if #ents > 0 then
                    local timevar = 1 - 1 / (#ents + 1)
                    for i, v in ipairs(ents) do
                        v:DoTaskInTime(timevar * math["random"]() / 3, function()
                            HH_UTILS:TryGrowth(v, player)
                        end)
                    end
                end
            end
            return true
        end
    },
    ["z_soil"] = {
        ["name"] = "术:耕地", ["person_only"] = true,
        ["is_item"] = true,
        ["item_fn"] = function(player)
            if not HH_UTILS:NotIsDead(player) or not player["Transform"] then
                return false
            end
            local x, y, z = player["Transform"]:GetWorldPosition()
            for k1 = -28, 28, 4 do
                for k2 = -28, 28, 4 do
                    local tile = TheWorld["Map"]:GetTileAtPoint(x + k1, 0, z + k2)
                    if tile == GROUND["FARMING_SOIL"] then
                        local x1, y1, z1 = TheWorld["Map"]:GetTileCenterPoint(x + k1, y, z + k2)--获取当前地皮中心坐标点
                        local spacing = 1.3--土堆间距
                        local farm_plant_pos = {}--农场作物坐标
                        --清除这块地皮上多余的土堆
                        local ents = TheWorld["Map"]:GetEntitiesOnTileAtPoint(x1, 0, z1)
                        for _, ent in ipairs(ents) do
                            if ent:HasTag("soil") then
                                ent:PushEvent("collapsesoil")
                            end
                        end
                        --生成整齐的土堆
                        for i = 0, 2 do
                            for j = 0, 2 do
                                local nx = x1 + spacing * i - spacing
                                local nz = z1 + spacing * j - spacing
                                if TheWorld["Map"]:IsDeployPointClear(
                                        Vector3(nx, 0, nz), nil, GetFarmTillSpacing(), nil, nil, nil,
                                        { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM", "soil", "medal_farm_plow" }
                                ) then
                                    SpawnPrefab("farm_soil")["Transform"]:SetPosition(nx, 0, nz)
                                end
                            end
                        end
                    end
                end
            end
            return true
        end
    },
    ["z_rain"] = {
        ["name"] = "术:雨书", ["person_only"] = true,
        ["is_item"] = true,
        ["item_fn"] = function(player)
            if not HH_UTILS:NotIsDead(player) or not player["Transform"] then
                return false
            end
            if TheWorld["state"]["israining"] or TheWorld["state"]["issnowing"] then
                TheWorld:PushEvent("ms_forceprecipitation", false)
            else
                TheWorld:PushEvent("ms_forceprecipitation", true)
            end
            return true
        end
    },
    ["z_sleep"] = {
        ["name"] = "术:催眠", ["person_only"] = true,
        ["is_item"] = true,
        ["item_fn"] = function(player)
            if not HH_UTILS:NotIsDead(player) or not player["Transform"] then
                return false
            end
            local x, y, z = player["Transform"]:GetWorldPosition()
            local range = 30
            local ents = TheNet:GetPVPEnabled() and
                    TheSim:FindEntities(x, y, z, range, nil, { "playerghost" }, { "sleeper", "player" }) or
                    TheSim:FindEntities(x, y, z, range, { "sleeper" }, { "player" })
            for i, v in ipairs(ents) do
                if v ~= player and
                        not (HH_UTILS:HasComponents(v, "freezable") and v["components"]["freezable"]:IsFrozen()) and
                        not (HH_UTILS:HasComponents(v, "pinnable") and v["components"]["pinnable"]:IsStuck()) then
                    if v["components"]["sleeper"] ~= nil then
                        v["components"]["sleeper"]:AddSleepiness(10, 20)
                    elseif v["components"]["grogginess"] ~= nil then
                        v["components"]["grogginess"]:AddGrogginess(10, 20)
                    else
                        v:PushEvent("knockedout")
                    end
                end
            end
            return true
        end
    },
    ["z_stone"] = {
        ["name"] = "术:石化", ["person_only"] = true,
        ["is_item"] = true,
        ["item_fn"] = function(player)
            if not HH_UTILS:NotIsDead(player) or not player["Transform"] then
                return false
            end
            local x, y, z = player["Transform"]:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 25)
            for i, v in ipairs(ents) do
                if (v:HasTag("evergreens")) and not v:HasTag("stump") and v["components"]["growable"] and v["components"]["growable"]["stage"] then
                    local stage = v["components"]["growable"]["stage"]
                    HH_UTILS:StoneTree(v, stage, true)
                elseif v:HasTag("hound") and v["components"]["health"] then
                    HH_UTILS:StoneDog(v)
                elseif v:HasTag("pig") and v["components"]["health"] then
                    HH_UTILS:StonePig(v)
                end
            end
            return true
        end
    },
    --["z_soil"] = {
    --    ["name"] = "术:耕地", ["person_only"] = true,
    --    ["is_item"] = true,
    --    ["item_fn"] = function(player)
    --        if not HH_UTILS:NotIsDead(player) or not player["Transform"] then
    --            return false
    --        end
    --        return true
    --    end
    --},
}

return HH_ITEMS

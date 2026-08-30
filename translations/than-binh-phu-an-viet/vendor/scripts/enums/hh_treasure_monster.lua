----
---宝藏出品的怪物加强-特殊id+特殊称号
---
local HH_UTILS = require("utils/hh_utils")
local function getLogLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("log", str_index)
end
local function getGemLanguage(str_index)
    return HH_UTILS:GetLanguageByKey("gem", str_index)
end
local function addTextFx(inst, text_config)
    if not HH_UTILS:IsHHType(text_config, "table") or not inst or inst["hh_treasure_fx"] then
        return
    end
    inst["hh_treasure_fx"] = SpawnPrefab("hh_treasure_text")
    if inst["hh_treasure_fx"] and inst["hh_treasure_fx"]["entity"] then
        inst["hh_treasure_fx"]["entity"]:SetParent(inst["entity"])
        if inst["hh_treasure_fx"]["SetTreasureStr"] then
            inst["hh_treasure_fx"]:SetTreasureStr(HH_UTILS:TableToStr(text_config))
        end
    end
    --宝箱怪参数
    inst["hh_is_treasure"] = true
end
----
---给物品一个初速度
---
local function launchItem(item, angle)
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    item["Physics"]:SetVel(speed * math["cos"](angle), math["random"]() * 2 + 8, speed * math["sin"](angle))
end
local function checkContainerFull(inst)
    return HH_UTILS:HasComponents(inst, "container") and inst["components"]["container"]:IsFull()
end
--生成特效
local function spawnComFx(inst, fx_id)
    if not inst or not inst["Transform"] or not HH_UTILS:IsHHType(fx_id, "string") then
        return
    end
    local spawn_fx = SpawnPrefab(fx_id)
    if spawn_fx and spawn_fx["Transform"] then
        local x, y, z = inst["Transform"]:GetWorldPosition()
        spawn_fx["Transform"]:SetPosition(x, y, z)
    end
end
local function spawnChest(inst, reward_list)
    if not inst or not inst["Transform"] then
        return
    end
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local hh_chest = SpawnPrefab("treasurechest")
    if hh_chest and hh_chest["Transform"] then
        hh_chest["Transform"]:SetPosition(x, y, z)
        spawnComFx(hh_chest, "explode_firecrackers")
        --校验概率
        --if HH_UTILS:IsHHType(inst["hh_treasure_chance"], "number") then
        --    local random_num = math["random"]()
        --    if random_num > inst["hh_treasure_chance"] then
        --        return
        --    end
        --end
        --开始塞奖品
        if HH_UTILS:IsHHType(reward_list, "table") and HH_UTILS:HasComponents(hh_chest, "container") then
            for i, v in ipairs(reward_list) do
                --满了就不添加奖品了
                if checkContainerFull(hh_chest) then
                    break
                end
                if v and v["type"] then
                    local item_config = v
                    local item_type = v["type"]
                    ---------------塞指定附魔石-----------------------------------
                    if item_type == "stone" and item_config["effect"] then
                        local spawn_stone = HHSpawnStoneById(item_config["effect"])
                        if spawn_stone then
                            local hh_chest_pos = hh_chest:GetPosition()
                            hh_chest["components"]["container"]:GiveItem(spawn_stone, nil, hh_chest_pos)
                        end
                    end
                    ---------------塞指定词条的装备-----------------------------------
                    if item_type == "equip" and item_config["prefab_id"] then

                    end
                    ---------------塞道具-----------------------------------
                    if item_type == "item" and item_config["prefab_id"] then
                        local item_id = item_config["prefab_id"]
                        local item_inst = SpawnPrefab(item_id)
                        if item_inst and item_inst["Transform"] then
                            if HH_UTILS:HasComponents(item_inst, "inventoryitem") then
                                if HH_UTILS:HasComponents(item_inst, "stackable") and HH_UTILS:IsHHType(item_config["num"], "number") and item_config["num"] > 0
                                        and HH_UTILS:HasComponents(item_inst, "inventoryitem")
                                then
                                    local new_num = item_config["num"]
                                    local max_num = item_inst["components"]["stackable"]["maxsize"] or 1
                                    item_inst["components"]["stackable"]:SetStackSize(math["min"](new_num, max_num))
                                end
                                local hh_chest_pos = hh_chest:GetPosition()
                                hh_chest["components"]["container"]:GiveItem(item_inst, nil, hh_chest_pos)
                            else
                                item_inst["Transform"]:SetPosition(x, 0, z)
                            end
                        end
                    end
                end
            end
        end
    end
end
----
---添加怪物词条
---
local function addMonsterEffect(inst, monster_data)
    if not HH_UTILS:IsHHType(monster_data, "table") or not inst then
        return
    end
    ----词条上限
    inst["components"]["hh_monster"]:SetMaxEffectLimit(#monster_data)
    ----指定词条库
    for i, v in ipairs(monster_data) do
        inst["components"]["hh_monster"]:AddBuffByName(v)
    end

end
--坎普斯大王受击函数
local function krampusKingAttacked(hh_inst, data)
    if not data or not data["attacker"] or not HH_UTILS:HasComponents(data["attacker"], "hh_player") then
        return
    end
    if not hh_inst or not hh_inst["Transform"] then
        return
    end
    --HH_UTILS:HHPrint(data)
    --local hh_player = data["attacker"]
    --local hh_damage = data["damage"]
    ----伤害大于一千才有概率掉落
    --if not HH_UTILS:IsHHType(hh_damage, "number") or hh_damage < 1000 then
    --    return
    --end
    local current_random = math["random"]()
    local spawn_stone = nil
    if current_random < 0.005 then
        spawn_stone = HHSpawnRareEffectStone()
    elseif current_random < 0.02 then
        spawn_stone = HHSpawnGoodEffectStone()
    elseif current_random < 0.1 then
        spawn_stone = HHSpawnComEffectStone()
    end
    if spawn_stone and spawn_stone["Transform"] then
        local angle = math["random"](1, 360)
        local x, y, z = hh_inst["Transform"]:GetWorldPosition()
        spawn_stone["Transform"]:SetPosition(x, 2.5, z)
        launchItem(spawn_stone, angle)
    end
end
local function CatYouAttacked(hh_inst, data)
    if not data or not data["attacker"] or not HH_UTILS:HasComponents(data["attacker"], "hh_player") then
        return
    end
    if not hh_inst or not hh_inst["Transform"] then
        return
    end
    local player = data["attacker"]
    if HH_UTILS:NotIsDead(player) then
        player["components"]["hh_player"]:DropRandomGem()
    end
end
--指定概率判断 1之下
local function comCheckChance(hh_random)
    if not HH_UTILS:IsHHType(hh_random, "number") then
        return false
    end
    local random_num = math["random"]()
    return random_num <= hh_random
end
--修改宝藏怪掉落物
local function hookLoot(inst)
    if HH_UTILS:HasComponents(inst, "lootdropper") then
        inst["components"]["lootdropper"]:SetLoot(nil)
        inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
    end
end
----
---修改最大生命
---
local function hookMaxHealth(inst, new_max)
    if not inst or not HH_UTILS:IsHHType(new_max, "number") or new_max <= 0 then
        return
    end
    local current_percent = inst["components"]["health"]:GetPercent()
    if current_percent > 0 then
        inst["components"]["health"]:SetMaxHealth(new_max)
        inst["components"]["health"]:SetPercent(math["min"](current_percent, 1))
    end
end
--可以踏水
local function makeCanWater(inst)
    if inst and inst["Physics"] then
        inst["Physics"]:ClearCollisionMask()
        inst["Physics"]:CollidesWith(COLLISION["GROUND"])
        inst["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
        inst["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
        inst["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
        inst["Physics"]:CollidesWith(COLLISION["GIANTS"])
    end
end
--local function hookCombat(inst)
--    if not HH_UTILS:HasComponents(inst, "combat") then
--        return
--    end
--    local oldGetAtk = inst["components"]["combat"]["GetAttacked"]
--    inst["components"]["combat"]["GetAttacked"] = function(self, attacker, damage, hh_weapon, ...)
--        if HH_UTILS:HasComponents(hh_weapon, "weapon") then
--            local weapon_com = hh_weapon["components"]["weapon"]
--            if HH_UTILS:IsHHType(weapon_com["attackrange"], "number") and weapon_com["attackrange"] > 3 then
--                damage = 0
--            end
--            if weapon_com["projectile"] then
--                damage = 0
--            end
--        end
--        print("伤害", damage, "武器", hh_weapon)
--        return oldGetAtk(self, attacker, damage, hh_weapon, ...)
--    end
--end

--生成附魔石函数
local function spawnStoneByInst(inst, stone_id)
    if not inst or not inst["Transform"] then
        return
    end
    local spawn_stone = HHSpawnStoneById(stone_id)
    if spawn_stone then
        local x, y, z = inst["Transform"]:GetWorldPosition()
        spawn_stone["Transform"]:SetPosition(x, 2.5, z)
        launchItem(spawn_stone, math["random"](1, 360))
    end
end
local function GivePlayerGem(hh_player, monster_name)
    if not hh_player then
        return
    end
    local player_name = hh_player["name"] or hh_player["prefab"]
    HH_UTILS:NetSay(string["format"]("%s拿下%s的尾刀，奖励特殊宝石一份", tostring(player_name), tostring(monster_name)))
    local random_num = math["random"]()
    local base_gem_name = ""
    if random_num < 0.3 then
        hh_player["components"]["hh_player"]:AddItemsByKey("treasure_atk", 1, true)
        base_gem_name = getGemLanguage("treasure_atk")
    elseif random_num < 0.6 then
        hh_player["components"]["hh_player"]:AddItemsByKey("treasure_bj", 1, true)
        base_gem_name = getGemLanguage("treasure_bj")
    else
        hh_player["components"]["hh_player"]:AddItemsByKey("treasure_armor", 1, true)
        base_gem_name = getGemLanguage("treasure_armor")
    end
    HH_UTILS:AddLog({ "treasure", "stone", "gem" }, HH_UTILS:Template(getLogLanguage("kill_treasure_boss"),
            {
                ["data_player"] = player_name,
                ["data_monster"] = monster_name,
                ["data_gem"] = base_gem_name,
            }
    ))
end
----
---hook生物生命赋值函数
---
local function hookHealthSetValue(inst)
    if not HH_UTILS:HasComponents(inst, "health") then
        return
    end
    local health_com = inst["components"]["health"]
    local oldSetVal = health_com["SetVal"]
    health_com["SetVal"] = function(self, val, cause, afflicter, ...)
        if not HH_UTILS:IsHHType(afflicter, "table") or not HH_UTILS:HasComponents(afflicter, "hh_player") then
            return
        end
        if not HH_UTILS:IsHHType(val, "number") then
            return
        end
        local old_health = self["currenthealth"]
        if val > 0 and val < old_health and old_health > 0 then
            val = math["max"](old_health - 1000, 0)
            --推事件
            self["inst"]:PushEvent("hh_kps_health_delta", { ["attacker"] = afflicter })
        end
        if oldSetVal then
            oldSetVal(self, val, cause, afflicter, ...)
        end
    end

end
--宝箱怪的指定函数
local MONSTER_CONFIG = {
    ["treasure_kps"] = {
        ["start_fn"] = function(inst)
            --袋子染色krampus_bag
            inst["AnimState"]:SetSymbolMultColour("krampus_bag", 255 / 255, 229 / 255, 0 / 255, 1)
            hookMaxHealth(inst, 1000000)
            addTextFx(inst, { ["name"] = "超级坎普斯大王\n星级:∞\n受到一千以上伤害掉落附魔石", ["color"] = { 255 / 255, 61 / 255, 0 / 255 }, ["pos"] = { 0, 5, 0 } })
            addMonsterEffect(inst, {
                "addComDamageNum", --增伤
                "addComDamageNum", --增伤
                "addComDamagePercent", --百分比加成
                "addCriticalHitRate", --暴击
                "addReduceAttackedDamage", --减伤
                "addReduceAttackedDamage", --减伤
                "immuneTearing", --免疫撕裂
            })
            --掉落置空
            hookLoot(inst)
            --限制伤害为1000
            hookHealthSetValue(inst)
            --限伤函数
            inst["hh_is_treasure_kps"] = true
            inst:ListenForEvent("hh_kps_health_delta", krampusKingAttacked)
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    local player_name = hh_player["name"] or hh_player["prefab"]
                    HH_UTILS:NetSay(string["format"]("%s拿下坎普斯大王的尾刀，奖励特殊宝石三份", tostring(player_name)))
                    hh_player["components"]["hh_player"]:AddItemsByKey("treasure_atk", 1, true)
                    hh_player["components"]["hh_player"]:AddItemsByKey("treasure_bj", 1, true)
                    hh_player["components"]["hh_player"]:AddItemsByKey("treasure_armor", 1, true)
                    HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("kill_treasure_kps"), { ["data_player"] = player_name, }))
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            --spawnChest(inst, {
            --    { ["effect"] = "special_bhtg", ["type"] = "stone", },
            --    { ["effect"] = "special_true_damage", ["type"] = "stone", },
            --})
            local back_inst = SpawnPrefab("krampus_sack")
            if back_inst and inst["Transform"] then
                local x, y, z = inst["Transform"]:GetWorldPosition()
                back_inst["Transform"]:SetPosition(x, 2.5, z)
                launchItem(back_inst, math["random"](1, 360))
            end
        end,
    },
    ["treasure_cat_you"] = {
        ["start_fn"] = function(inst)
            inst["AnimState"]:SetBuild("ticoon_build")
            hookMaxHealth(inst, 1000000)
            addTextFx(inst, { ["name"] = "超级猫悠大王\n星级:∞\n受到一千以上伤害掉落附魔的宝石", ["color"] = { 255 / 255, 61 / 255, 0 / 255 }, ["pos"] = { 0, 5, 0 } })
            addMonsterEffect(inst, {
                "addComDamageNum", --增伤
                "addComDamageNum", --增伤
                "addComDamagePercent", --百分比加成
                "addCriticalHitRate", --暴击
                "addReduceAttackedDamage", --减伤
                "addReduceAttackedDamage", --减伤
                "immuneTearing", --免疫撕裂
            })
            if inst["Transform"] then
                inst["Transform"]:SetScale(3, 3, 3)
            end
            --inst["AnimState"]:SetSymbolMultColour("catcoon_head", 0 / 255, 255 / 255, 0 / 255, 1)
            --掉落置空
            hookLoot(inst)
            --限制伤害为1000
            hookHealthSetValue(inst)
            --限伤函数
            inst["hh_is_treasure_kps"] = true
            inst:ListenForEvent("hh_kps_health_delta", CatYouAttacked)
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    local player_name = hh_player["name"] or hh_player["prefab"]
                    HH_UTILS:NetSay(string["format"]("%s暴打超级猫悠大王，奖励稀有附魔石三份", tostring(player_name)))
                    hh_player["components"]["hh_player"]:TestSpawnStone("special_sgsy")
                    hh_player["components"]["hh_player"]:TestSpawnStone("special_true_damage")
                    hh_player["components"]["hh_player"]:TestSpawnStone("special_true_damage")
                    HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("kill_treasure_cat_you"), { ["data_player"] = player_name, }))
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            --spawnChest(inst, {
            --    { ["effect"] = "special_bhtg", ["type"] = "stone", },
            --    { ["effect"] = "special_true_damage", ["type"] = "stone", },
            --})
            local back_inst = SpawnPrefab("krampus_sack")
            if back_inst and inst["Transform"] then
                local x, y, z = inst["Transform"]:GetWorldPosition()
                back_inst["Transform"]:SetPosition(x, 2.5, z)
                launchItem(back_inst, math["random"](1, 360))
            end
        end,
    },
    ["pig_tank"] = {
        ["start_fn"] = function(inst)
            --print("宝箱怪初始化", inst)
            addTextFx(inst, {
                ["name"] = "★★坦克猪猪★★\n超强的防御",
                ["color"] = { 27 / 255, 255 / 255, 0 / 255 },
                ["pos"] = { 0, 3.4, 0 },
                ["scale"] = 18,
            })
            addMonsterEffect(inst, {
                "addMaxHealthNum",
                "addMaxHealthPercent",
                "addReduceAttackedDamage",
                "addHealth3sNum",
                "addHealth5sNum",
                "reducePercentDamage",
            })
        end,
        --死亡触发
        ["death_fn"] = function(inst)
            --print("宝箱怪死亡", inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
        end,
    },
    ["pig_attack"] = {
        ["start_fn"] = function(inst)
            addTextFx(inst, {
                ["name"] = "★★暴力猪猪★★\n强化伤害",
                ["color"] = { 27 / 255, 255 / 255, 0 / 255 },
                ["pos"] = { 0, 3.4, 0 },
                ["scale"] = 18,
            })
            addMonsterEffect(inst, {
                "addComDamageNum", --伤害提高
                "addComDamageNum", --伤害提高
                "addComDamagePercent", --百分比加成
                "atkChanceReduceSpeed", --攻击减速
                "addCriticalHitRate", --暴击
                "atkBlood", --吸血
            })
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
        end,
    },
    ["pig_buff"] = {
        ["start_fn"] = function(inst)
            addTextFx(inst, {
                ["name"] = "★★打工猪猪★★\n我要爆炸了",
                ["color"] = { 27 / 255, 255 / 255, 0 / 255 },
                ["pos"] = { 0, 3.4, 0 },
                ["scale"] = 18,
            })
            addMonsterEffect(inst, {
                "hitAddPoison", --使攻击者中毒
                "hitChanceAddFreeze", --使攻击者冰冻
                "hitChanceReduceSpeed", --使攻击者减速
                "addReboundDamageNum", --反弹伤害
                "reducePercentDamage", --忍耐
            })
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
        end,
    },
    ["pig_wsz"] = {
        ["start_fn"] = function(inst)
            addTextFx(inst, {
                ["name"] = "★★沃时柱★★\n你是好人,我跟着你",
                ["color"] = { 27 / 255, 255 / 255, 0 / 255 },
                ["pos"] = { 0, 3.4, 0 },
                ["scale"] = 18,
            })
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
        end,
    },
    ["super_pig"] = {
        ["start_fn"] = function(inst)
            addTextFx(inst, {
                ["name"] = "★★★猪猪擂主★★★\n我要打十个",
                ["color"] = { 0, 0, 255 },
                ["pos"] = { 0, 3.4, 0 },
                ["scale"] = 18,
            })
            hookMaxHealth(inst, 8000)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
        end,
    },
    --海象强化
    ["walrus_adc"] = {
        ["start_fn"] = function(inst)
            hookLoot(inst)
            hookMaxHealth(inst, 100000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addSuppressAddHealth", --制裁
                "addCriticalHitRate", --暴击
                "immuneFreeze", --免疫冰冻
                "atkChanceReduceSpeed", --减速
                "atkAddPoison", --中毒
                "addComDamageNum", --攻击力
                "addSpeedPercent", --移速
                "atkBlood", --吸血
            })
            addTextFx(inst, { ["name"] = string["format"]("★★★★★超级ADC★★★★★\n死亡掉落极品增伤(%s)/无尽(%s)", 0.5, 0.5),
                              ["color"] = { 211 / 255, 0 / 255, 255 / 255 }, ["pos"] = { 0, 5, 0 } })
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            if comCheckChance(0.5) then
                spawnChest(inst, { { ["effect"] = "add_critical_hit_rate_damage", ["type"] = "stone", }, })
            else
                spawnChest(inst, { { ["effect"] = "atk_add_good_damage", ["type"] = "stone", }, })
            end
        end,
    },
    --月后巨鹿
    ["mutateddeerclops_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true--免疫远程
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★★★★★巨鹿大王★★★★★★\n死亡掉落朱雀附魔石(免疫远程武器伤害)",
                              ["color"] = { 255 / 255, 110 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            hookMaxHealth(inst, 300000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addComDamageNum", --伤害提升
                "addComDamageNum", --伤害提升
                "addComDamagePercent", --伤害提升
                "immuneFreeze", --免疫冰冻
                "addCriticalHitRate", --暴击
                "addSuppressAddHealth", --攻击制裁
                "iceTurret", --炮塔
                "iceLaser", --激光
                "atkBlood", --吸血
                "addHealthPercent10", --3s百分比回血
            })
            --覆盖掉这个函数 防止脱视野加载刷新掉
            inst["WantsToLeave"] = function(_inst)
                return false
            end
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    GivePlayerGem(hh_player, "超级巨鹿")
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            spawnStoneByInst(inst, "special_zqrf")
        end,
    },
    --装甲熊獾
    ["mutatedbearger_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true--免疫远程
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★★★★★超级熊大★★★★★★\n死亡掉落白虎附魔石(免疫远程武器伤害)",
                              ["color"] = { 255 / 255, 110 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            hookMaxHealth(inst, 300000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addComDamageNum", --伤害提升
                "addComDamageNum", --伤害提升
                "addComDamagePercent", --伤害提升
                "immuneFreeze", --免疫冰冻
                "addCriticalHitRate", --暴击
                "addSuppressAddHealth", --攻击制裁
                "poisonTurret", --炮塔
                "iceLaser", --激光
                "atkBlood", --吸血
                "addHealthPercent10", --3s百分比回血
            })
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    GivePlayerGem(hh_player, "超级熊大")
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            spawnStoneByInst(inst, "special_bhtg")
        end,
    },
    --超级鲨鱼
    ["hh_sharkboi_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true--免疫远程
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★★★★★超级鲨鱼★★★★★★\n死亡掉落护甲锁定附魔石(免疫远程武器伤害)",
                              ["color"] = { 255 / 255, 110 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            hookMaxHealth(inst, 300000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addComDamageNum", --伤害提升
                "addComDamageNum", --伤害提升
                "addComDamagePercent", --伤害提升
                "immuneFreeze", --免疫冰冻
                "addCriticalHitRate", --暴击
                "addSuppressAddHealth", --攻击制裁
                "poisonTurret", --炮塔
                "iceLaser", --激光
                "atkBlood", --吸血
                "addHealthPercent10", --3s百分比回血
            })
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    GivePlayerGem(hh_player, "超级鲨鱼")
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            spawnStoneByInst(inst, "armor_immune_amount")
        end,
    },
    --附身狼王
    ["mutatedwarg_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true--免疫远程
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★★★★★附身狼王★★★★★★\n死亡掉落神龟守御附魔石(免疫远程武器伤害)",
                              ["color"] = { 255 / 255, 110 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            hookMaxHealth(inst, 300000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addComDamageNum", --伤害提升
                "addComDamageNum", --伤害提升
                "addComDamagePercent", --伤害提升
                "immuneFreeze", --免疫冰冻
                "addCriticalHitRate", --暴击
                "addSuppressAddHealth", --攻击制裁
                "iceTurret", --炮塔
                "iceLaser", --激光
                "atkBlood", --吸血
                "addHealthPercent10", --3s百分比回血
            })
            --覆盖掉这个函数 防止脱视野加载刷新掉
            inst["WantsToLeave"] = function(_inst)
                return false
            end
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    GivePlayerGem(hh_player, "附身狼王")
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            spawnStoneByInst(inst, "special_sgsy")
        end,
    },
    ["hh_beetle_pig_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true--免疫远程
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★★★★★大猪知非★★★★★★\n死亡掉落免疫控制附魔石(免疫远程武器伤害)",
                              ["color"] = { 255 / 255, 110 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            hookMaxHealth(inst, 300000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addComDamageNum", --伤害提升
                "addComDamageNum", --伤害提升
                "addComDamagePercent", --伤害提升
                "immuneFreeze", --免疫冰冻
                "addCriticalHitRate", --暴击
                "addSuppressAddHealth", --攻击制裁
                "poisonTurret", --炮塔
                "iceLaser", --激光
                "atkBlood", --吸血
                "addHealthPercent10", --3s百分比回血
            })
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    GivePlayerGem(hh_player, "大猪知非")
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            spawnStoneByInst(inst, "special_immune_control")
        end,
    },
    ["hh_dual_wield_pig_boss"] = {
        ["start_fn"] = function(inst)
            inst["hh_is_treasure_boss"] = true--免疫远程
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★★★★★笨比林猪★★★★★★\n死亡掉落真伤附魔石(免疫远程武器伤害)",
                              ["color"] = { 255 / 255, 110 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            hookMaxHealth(inst, 300000)
            addMonsterEffect(inst, {
                "immuneTearing", --免疫撕裂
                "addComDamageNum", --伤害提升
                "addComDamageNum", --伤害提升
                "addComDamagePercent", --伤害提升
                "immuneFreeze", --免疫冰冻
                "addCriticalHitRate", --暴击
                "addSuppressAddHealth", --攻击制裁
                "poisonTurret", --炮塔
                "iceLaser", --激光
                "atkBlood", --吸血
                "addHealthPercent10", --3s百分比回血
            })
            inst:ListenForEvent("death", function(hh_inst, data)
                if data and HH_UTILS:HasComponents(data["afflicter"], "hh_player") then
                    local hh_player = data["afflicter"]
                    GivePlayerGem(hh_player, "笨比林猪")
                end
            end)
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            spawnStoneByInst(inst, "special_true_damage")
        end,
    },
    --树精
    ["leif_hot"] = {
        ["start_fn"] = function(inst)
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★树精★★\n低概率掉落免疫过热",
                              ["color"] = { 11 / 255, 255 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            if HH_UTILS:HasComponents(inst, "hh_monster") then
                inst["components"]["hh_monster"]:AddBuffByName("hitAddHot")
            end
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            if comCheckChance(0.1) then
                spawnStoneByInst(inst, "add_immune_hot")
            end
        end,
    },
    ["leif_cold"] = {
        ["start_fn"] = function(inst)
            hookLoot(inst)
            addTextFx(inst, { ["name"] = "★★树精★★\n低概率掉落免疫过冷",
                              ["color"] = { 11 / 255, 255 / 255, 0 / 255 }, ["pos"] = { 0, 10, 0 } })
            if HH_UTILS:HasComponents(inst, "hh_monster") then
                inst["components"]["hh_monster"]:AddBuffByName("hitAddCold")
            end
        end,
        ["death_fn"] = function(inst)
            HH_UTILS:HHRemoveFx(inst, "hh_treasure_fx")
            if comCheckChance(0.1) then
                spawnStoneByInst(inst, "add_immune_cold")
            end
        end,
    },

}
local function addTreasureId(inst, tt_id, player)
    if HH_UTILS:HasComponents(inst, "hh_monster") then
        --自定义词条
        inst["components"]["hh_monster"]:SetTreasureId(tt_id)
        --玩家锁头
        --if HH_UTILS:HasComponents(inst, "combat") and HH_UTILS:NotIsDead(player)
        --        and HH_UTILS:HasComponents(player, "hh_player")
        --then
        --    inst["components"]["combat"]:SetTarget(player)
        --end
    end
end
local function checkChest(chest)
    if not chest or not chest["Transform"] then
        return false
    end
    return true
end
local function spawnTreasureMonster(chest_inst, player, data)
    if checkChest(chest_inst) and HH_UTILS:IsHHType(data, "table") then
        local x, y, z = chest_inst["Transform"]:GetWorldPosition()
        for i, v in ipairs(data) do
            if HH_UTILS:IsHHType(v, "table") then
                local monster_id = v["prefab_id"]
                local spawn_monster = SpawnPrefab(monster_id)
                if spawn_monster and spawn_monster["Transform"] then
                    spawn_monster["Transform"]:SetPosition(x, y, z)
                    local effect_id = v["treasure_id"]
                    if effect_id then
                        addTreasureId(spawn_monster, effect_id, player)
                    end
                end
            end
        end
    end
end
----
---生成蜜蜂走廊
---
local function spawnSpecialBuild(chest_inst, player, data)
    if checkChest(chest_inst) and HH_UTILS:IsHHType(data, "table") then
        local x, y, z = chest_inst["Transform"]:GetWorldPosition()
        local spawn_distance = 10
        if HH_UTILS:IsHHType(data["radius"], "number") and data["radius"] > 0 then
            spawn_distance = data["radius"]
        end
        local new_pos_x, new_pos_z = x, z
        local one_angle = math["pi"] / 180
        --围成圈的实体
        local round_data = data["child"]
        if HH_UTILS:IsHHType(round_data, "table") and HH_UTILS:IsHHType(round_data["prefab_id"], "string")
                and HH_UTILS:IsHHType(round_data["prefab_num"], "number")
                and round_data["prefab_num"] > 0
        then
            local spawn_num = round_data["prefab_num"]
            local every_angle = 360 / spawn_num
            local spawn_id = round_data["prefab_id"]
            for i = 0, (spawn_num - 1) do
                new_pos_x = x + spawn_distance * math["sin"](i * every_angle * one_angle)
                new_pos_z = z + spawn_distance * math["cos"](i * every_angle * one_angle)
                --校验是不是在陆地上
                if TheWorld["Map"]:IsPassableAtPoint(new_pos_x, 0, new_pos_z)
                        and not TheWorld["Map"]:IsOceanTileAtPoint(new_pos_x, 0, new_pos_z)
                then
                    local spawn_build = SpawnPrefab(spawn_id)
                    if spawn_build and spawn_build["Transform"] then
                        spawn_build["Transform"]:SetPosition(new_pos_x, y, new_pos_z)
                        if HH_UTILS:IsHHType(round_data["start_fn"], "function") then
                            round_data["start_fn"](spawn_build)
                        end
                    end
                end
            end
        end
        --中心点实体
        local center_data = data["center"]
        if HH_UTILS:IsHHType(center_data, "table")
                and HH_UTILS:IsHHType(center_data["prefab_id"], "string")
        then
            local spawn_id = center_data["prefab_id"]
            local spawn_build = SpawnPrefab(spawn_id)
            if spawn_build and spawn_build["Transform"] then
                spawn_build["Transform"]:SetPosition(x, y, z)
                if HH_UTILS:IsHHType(center_data["start_fn"], "function") then
                    center_data["start_fn"](spawn_build)
                end
            end
        end
    end
end
--食材宝藏放置在一个表中进行随机 防止降低其他权重
local food_config = {
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "好像是哪个木木的家伙藏起来的食物")--肥料集合
            spawnChest(chest_inst, {
                { ["prefab_id"] = "poop", ["type"] = "item", ["num"] = 10, },
                { ["prefab_id"] = "spoiled_food", ["type"] = "item", ["num"] = 25, },
                { ["prefab_id"] = "compostwrap", ["type"] = "item", ["num"] = 10, },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "搬雕像的伙计最喜欢的食物")--土豆/西红柿
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "potato", ["num"] = 10, },
                { ["type"] = "item", ["prefab_id"] = "tomato", ["num"] = 10, },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "倒霉的孩子也该走走运了")--黄油
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "butter", ["num"] = 1, },
                { ["type"] = "item", ["prefab_id"] = "berries", ["num"] = 1, },
                { ["type"] = "item", ["prefab_id"] = "berries", ["num"] = 1, },
                { ["type"] = "item", ["prefab_id"] = "bird_egg", ["num"] = 1, },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "奖励给勇敢无畏的女战士")--女武神的奖励
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "lightninggoathorn", ["num"] = 2, }, --伏特羊角
                { ["type"] = "item", ["prefab_id"] = "beefalowool", ["num"] = 4, }, --牛毛
                { ["type"] = "item", ["prefab_id"] = "rocks", ["num"] = 4, }, --石头
                { ["type"] = "item", ["prefab_id"] = "goldnugget", ["num"] = 4, }, --金子
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "我砍-我砍-我砍-我砍不动了")--吴迪
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "leif_idol", ["num"] = 2, },
                { ["type"] = "item", ["prefab_id"] = "log", ["num"] = 20, },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "吃上了豪华海鲜大餐")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "fishmeat_small", ["num"] = 10, },
                { ["type"] = "item", ["prefab_id"] = "fishmeat", ["num"] = 3, },
                { ["type"] = "item", ["prefab_id"] = "ice", ["num"] = 10, },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "宝石大礼包-紫橙黄")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "purplegem", ["num"] = 5, },
                { ["type"] = "item", ["prefab_id"] = "orangegem", ["num"] = 3, },
                { ["type"] = "item", ["prefab_id"] = "yellowgem", ["num"] = 3, },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "宝石大礼包-绿红蓝")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "greengem", ["num"] = 2, },
                { ["type"] = "item", ["prefab_id"] = "redgem", ["num"] = 5, },
                { ["type"] = "item", ["prefab_id"] = "bluegem", ["num"] = 5, },
            })
        end,
    },
    --彩虹宝石
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "彩彩彩彩彩彩彩虹宝石")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "opalpreciousgem", ["num"] = 1, }, --彩虹宝石
            })
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                ["child"] = { ["prefab_id"] = "hound", ["prefab_num"] = 4, }, --刷新狗进行保护
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "复活大礼包")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "amulet", },
                { ["type"] = "item", ["prefab_id"] = "reviver", },
                { ["type"] = "item", ["prefab_id"] = "lifeinjector", },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "我应该不喜欢种地")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "yotc_seedpacket", },
                { ["type"] = "item", ["prefab_id"] = "yotc_seedpacket", },
                { ["type"] = "item", ["prefab_id"] = "yotc_seedpacket_rare", },
                { ["type"] = "item", ["prefab_id"] = "yotc_seedpacket_rare", },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "开始战斗吧")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "voltgoatjelly_spice_chili", }, --辣闪
                { ["type"] = "item", ["prefab_id"] = "jellybean_spice_garlic", }, --蒜糖豆
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "它真的好吵")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "mandrake", }, --曼德拉草
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "咬起来有点崩牙")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "marblebean", ["num"] = 5, }, --大理石豆
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "终于不用吃注水肉丸了")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "dug_rock_avocado_bush", ["num"] = 3, }, --石果灌木丛
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "你是好人 我跟着你")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "pigskin", ["num"] = 1, }, --猪皮
                { ["type"] = "item", ["prefab_id"] = "twigs", ["num"] = 2, }, --树枝
                { ["type"] = "item", ["prefab_id"] = "meat", ["num"] = 2, }, --大肉
            })
        end,
    },
    --拓展道具
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "科技废料")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "wagpunk_bits", ["num"] = 3, }, --废料
                { ["type"] = "item", ["prefab_id"] = "twigs", ["num"] = 3, }, --树枝
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "鸟类百科全书？")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "feather_canary", ["num"] = 3, }, --黄色羽毛
                { ["type"] = "item", ["prefab_id"] = "feather_crow", ["num"] = 3, }, --黑色羽毛
                { ["type"] = "item", ["prefab_id"] = "feather_robin", ["num"] = 3, }, --红色羽毛
                { ["type"] = "item", ["prefab_id"] = "feather_robin_winter", ["num"] = 3, }, --蓝色羽毛
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "骨头拼接起来的怪物")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "fossil_piece", ["num"] = 3, }, --化石碎片
                { ["type"] = "item", ["prefab_id"] = "nightmarefuel", ["num"] = 5, }, --噩梦燃料
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "好像充满了毒素")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "batwing", ["num"] = 2, }, --洞穴蝙蝠翅膀
                { ["type"] = "item", ["prefab_id"] = "guano", ["num"] = 5, }, --鸟粪
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "鹅鹅鹅 曲项向天歌")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "goose_feather", ["num"] = 3, }, --麋鹿鹅羽毛
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "带角的鱼，我好像没见过")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "gnarwail_horn", }, --一角鲸的角
                { ["type"] = "item", ["prefab_id"] = "fishmeat", ["num"] = 4, }, --生鱼肉
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "神奇的月亮碎片")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "moonglass", ["num"] = 3, }, --月亮碎片
                { ["type"] = "item", ["prefab_id"] = "moonrocknugget", ["num"] = 3, }, --月岩
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "这就是偷种子和打果蝇的下场")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "coontail", ["num"] = 1, }, --猫尾
                { ["type"] = "item", ["prefab_id"] = "meat", ["num"] = 1, }, --大肉
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "没想到吧 我带肉了")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "manrabbit_tail", ["num"] = 2, }, --兔绒
                { ["type"] = "item", ["prefab_id"] = "carrot", ["num"] = 3, }, --胡萝卜
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "源源不绝的小蜘蛛")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "spidereggsack", ["num"] = 1, }, --蜘蛛卵
                { ["type"] = "item", ["prefab_id"] = "silk", ["num"] = 4, }, --蜘蛛丝
                { ["type"] = "item", ["prefab_id"] = "spidergland", ["num"] = 2, }, --腺体
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "这可真的是好好好好好好好恶心的家伙")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "steelwool", ["num"] = 1, }, --钢丝绵
                { ["type"] = "item", ["prefab_id"] = "phlegm", ["num"] = 2, }, --脓鼻涕
                { ["type"] = "item", ["prefab_id"] = "meat", ["num"] = 4, }, --大肉
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "再也不当赌狗了")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "hh_essence", ["num"] = 5, }, --水晶小人
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "知识就是力量")
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "dug_monkeytail", ["num"] = 2, }, --猴尾草
            })
        end,
    },
}
--建筑配置表
local build_config = {
    {
        --火鸡陷阱
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "咯咯咯咯咯咯")
            --火鸡-鸡你太美
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                ["child"] = { ["prefab_id"] = "perd", ["prefab_num"] = 10, }, --火鸡
            })
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 6,
                ["child"] = { ["prefab_id"] = "wall_stone", ["prefab_num"] = 30, }, --石墙
            })
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 8,
                ["child"] = { ["prefab_id"] = "berrybush", ["prefab_num"] = 4, }, --浆果从
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            --月岩矿
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                ["child"] = { ["prefab_id"] = "rock_moon", ["prefab_num"] = 10, }, --月岩矿
                ["center"] = { ["prefab_id"] = "goldenpickaxe", }, --黄金鹤嘴锄
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            --杀人蜂巢
            spawnSpecialBuild(chest_inst, player, {
                --一圈实体
                ["child"] = { ["prefab_id"] = "wasphive", ["prefab_num"] = 10, },
                --中心点
                ["center"] = { ["prefab_id"] = "lightning_rod", ["start_fn"] = function(inst)
                    if inst and inst["AnimState"] then
                        inst["AnimState"]:PlayAnimation("place")
                        inst["AnimState"]:PushAnimation("idle")
                    end
                end },
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "我好像要完蛋了")
            --兔子
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                --["child"] = { ["prefab_id"] = "rabbithouse", ["prefab_num"] = 10, },--兔屋
                ["child"] = { ["prefab_id"] = "bunnyman", ["prefab_num"] = 6, }, --兔人
                --中心点
                ["center"] = { ["prefab_id"] = "hammer", }, --锤子
            })
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 6,
                --["child"] = { ["prefab_id"] = "skeleton", ["prefab_num"] = 12, }, --骷髅
                --["child"] = { ["prefab_id"] = "stalagmite", ["prefab_num"] = 12, }, --石笋
                ["child"] = { ["prefab_id"] = "wall_moonrock", ["prefab_num"] = 30, }, --月岩墙
                --["child"] = { ["prefab_id"] = "marbleshrub_short", ["prefab_num"] = 10, }, --大理石树-小
            })
        end,
    },
    {
        --主教陷阱
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "我好像又要完蛋惹")
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                ["child"] = { ["prefab_id"] = "bishop", ["prefab_num"] = 4, }, --主教
            })
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 3,
                ["child"] = { ["prefab_id"] = "wall_stone", ["prefab_num"] = 10, }, --石墙
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "快跑！")
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                ["child"] = { ["prefab_id"] = "frog", ["prefab_num"] = 15, }, --青蛙
            })
            --add_speed_percent
            spawnStoneByInst(chest_inst, "add_speed_percent")
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "好像看到了附魔石")
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 2,
                ["child"] = { ["prefab_id"] = "koalefant_winter", ["prefab_num"] = 2, }, --考拉象
            })
            spawnSpecialBuild(chest_inst, player, {
                ["radius"] = 4,
                ["child"] = { ["prefab_id"] = "koalefant_summer", ["prefab_num"] = 2, }, --考拉象
            })
        end,
    },
    {
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:HHSay(player, "咩")
            spawnSpecialBuild(chest_inst, player, {
                ["center"] = { ["prefab_id"] = "lightninggoat", }, --伏特羊
            })
        end,
    },
}
--宝藏权重表
local TREASURE_CONFIG = {
    {
        ["prefab_id"] = "甲虫猪", ["chance"] = 5,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("强化的大猪知非已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "hh_beetle_pig", ["treasure_id"] = "hh_beetle_pig_boss", }, })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "pigman",
                        ["data_monster"] = "大猪知非",
                    }))
        end
    },
    {
        ["prefab_id"] = "双持猪", ["chance"] = 5,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("强化的林猪已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "hh_dual_wield_pig", ["treasure_id"] = "hh_dual_wield_pig_boss", }, })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "pigman",
                        ["data_monster"] = "双持林猪",
                    }))
        end
    },
    {
        ["prefab_id"] = "超级猫悠", ["chance"] = 1,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("携带宝石的超级猫悠已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "catcoon", ["treasure_id"] = "treasure_cat_you", },
            })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "catcoon",
                        ["data_monster"] = "超级猫悠",
                    }))
        end
    },
    -- grassgekko草蜥蜴 pigman
    {
        ["prefab_id"] = "坎普斯大王", ["chance"] = 1,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("携带宝藏的坎普斯已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "krampus", ["treasure_id"] = "treasure_kps", },
                { ["prefab_id"] = "pigman", ["treasure_id"] = "pig_tank", },
                { ["prefab_id"] = "pigman", ["treasure_id"] = "pig_attack", },
            })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "krampus",
                        ["data_monster"] = "坎普斯大王",
                    }))
        end
    },
    --星空蛋
    {
        ["prefab_id"] = "星空蛋", ["chance"] = 1,
        ["start_fn"] = function(chest_inst, player)
            spawnChest(chest_inst, {
                { ["type"] = "item", ["prefab_id"] = "hh_egg_starry_sky", ["num"] = 1, },
            })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "egg_starry_sky",
                        ["data_monster"] = "星空蛋",
                    }))
        end
    },
    {
        ["prefab_id"] = "月后巨鹿", ["chance"] = 5,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("强化的巨鹿大王已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "mutateddeerclops", ["treasure_id"] = "mutateddeerclops_boss", }, })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "mutateddeerclops",
                        ["data_monster"] = "月后巨鹿",
                    }))
        end
    },
    --TheWorld:HasTag("cave")
    {
        ["prefab_id"] = "月后座狼", ["chance"] = 5,
        ["start_fn"] = function(chest_inst, player)
            if TheWorld and TheWorld:HasTag("cave") then
                HH_UTILS:HHSay(player, "洞穴中禁止生成座狼,补偿蠕虫")
                spawnTreasureMonster(chest_inst, player, {
                    { ["prefab_id"] = "worm", }, --洞穴蠕虫
                    { ["prefab_id"] = "worm", }, --洞穴蠕虫
                    { ["prefab_id"] = "worm", }, --洞穴蠕虫
                })
            else
                HH_UTILS:NetSay("强化的附身狼王已经出现,请及时击杀(补刀的玩家有特殊奖励)")
                spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "mutatedwarg", ["treasure_id"] = "mutatedwarg_boss", }, })
                HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                        {
                            ["data_player"] = player and player["name"],
                            ["data_image"] = "mutatedwarg",
                            ["data_monster"] = "月后座狼",
                        }))
            end
        end
    },
    {
        ["prefab_id"] = "装甲熊獾", ["chance"] = 5,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("强化的超级熊大已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "mutatedbearger", ["treasure_id"] = "mutatedbearger_boss", }, })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "mutatedbearger",
                        ["data_monster"] = "装甲熊獾",
                    }))
        end
    },
    {
        ["prefab_id"] = "超级鲨鱼", ["chance"] = 5,
        ["start_fn"] = function(chest_inst, player)
            HH_UTILS:NetSay("强化的超级鲨鱼已经出现,请及时击杀(补刀的玩家有特殊奖励)")
            spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "hh_sharkboi", ["treasure_id"] = "hh_sharkboi_boss", }, })
            HH_UTILS:AddLog("treasure", HH_UTILS:Template(getLogLanguage("dig_treasure_monster"),
                    {
                        ["data_player"] = player and player["name"],
                        ["data_image"] = "sharkboi",
                        ["data_monster"] = "超级鲨鱼",
                    }))
        end
    },
    {
        ["prefab_id"] = "海象强化", ["chance"] = 10,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, { { ["prefab_id"] = "walrus", ["treasure_id"] = "walrus_adc", }, })
        end
    },
    {
        ["prefab_id"] = "猪人护卫", ["chance"] = 40,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "pigman", }, --无指定词条
                { ["prefab_id"] = "pigman", }, --强化坦克
                { ["prefab_id"] = "pigman", }, --攻击
                { ["prefab_id"] = "pigman", }, --负面
            })
        end
    },
    {
        ["prefab_id"] = "树精", ["chance"] = 50,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "leif", }, --
                { ["prefab_id"] = "leif", }, --
            })
        end
    },
    {
        ["prefab_id"] = "洞穴蠕虫", ["chance"] = 50,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "worm", }, --洞穴蠕虫
                { ["prefab_id"] = "worm", }, --洞穴蠕虫
                { ["prefab_id"] = "worm", }, --洞穴蠕虫
            })
        end
    },
    {
        ["prefab_id"] = "皮弗娄牛", ["chance"] = 40,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "beefalo", }, --皮弗娄牛
            })
        end
    },
    {
        ["prefab_id"] = "齿轮怪", ["chance"] = 40,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "bishop", }, --发条主教
                { ["prefab_id"] = "rook", }, --发条战车
                { ["prefab_id"] = "knight", }, --发条骑士
            })
        end
    },
    {
        ["prefab_id"] = "蘑菇地精", ["chance"] = 40,
        ["start_fn"] = function(chest_inst, player)
            spawnTreasureMonster(chest_inst, player, {
                { ["prefab_id"] = "mushgnome", }, --蘑菇地精
                { ["prefab_id"] = "mushgnome", }, --蘑菇地精
                { ["prefab_id"] = "mushgnome", }, --蘑菇地精
            })
        end
    },
    ------------------------宝藏箱子
    {
        ["prefab_id"] = "食材大全", ["chance"] = 85,
        ["start_fn"] = function(chest_inst, player)
            local random_index = math["random"](1, #food_config)
            if food_config[random_index] and food_config[random_index]["start_fn"] then
                food_config[random_index]["start_fn"](chest_inst, player)
            end
        end
    },
    --生成建筑
    {
        ["prefab_id"] = "建筑", ["chance"] = 15,
        ["start_fn"] = function(chest_inst, player)
            local random_index = math["random"](1, #build_config)
            if build_config[random_index] and build_config[random_index]["start_fn"] then
                build_config[random_index]["start_fn"](chest_inst, player)
            end
        end
    },
    --{
    --    ["prefab_id"] = "棱镜盾反", ["chance"] = 5,
    --    ["start_fn"] = function(chest_inst, player)
    --        if TUNING["mod_legion_enabled"] then
    --            HH_UTILS:HHSay(player, "我无敌惹")
    --            spawnChest(chest_inst, {
    --                { ["type"] = "item", ["prefab_id"] = "agronssword", }, --艾力冈的剑
    --            })
    --        else
    --            HH_UTILS:HHSay(player, "有股神秘的力量消失了")
    --            spawnChest(chest_inst, {
    --                { ["type"] = "item", ["prefab_id"] = "steelwool", ["num"] = 1, }, --钢丝绵
    --            })
    --        end
    --    end
    --},
}
return {
    ["TREASURE_MONSTER_CONFIG"] = MONSTER_CONFIG,
    ["CHANCE_CONFIG"] = TREASURE_CONFIG,
}
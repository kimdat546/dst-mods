local HH_UTILS = require("utils/hh_utils")
local HH_PREFAB_LIST = require("enums/hh_prefab_list")
local HH_EQUIP_DROP = HH_PREFAB_LIST["drop_equip"]
--星星法杖特效
local HH_FX_CONFIG = {
    --球状
    { ["name"] = "紫色法球", ["fx_list"] = { "hh_ball_fx_purple", "hh_sparkle_fx", } },
    { ["name"] = "绿色法球", ["fx_list"] = { "hh_ball_fx_green", "hh_sparkle_fx", } },
    { ["name"] = "红色法球", ["fx_list"] = { "hh_ball_fx_red", "hh_sparkle_fx", } },
    { ["name"] = "蓝色法球", ["fx_list"] = { "hh_ball_fx_blue", "hh_sparkle_fx", } },
    { ["name"] = "橙色法球", ["fx_list"] = { "hh_ball_fx_orange", "hh_sparkle_fx", } },
    --星星
    { ["name"] = "白色星星", ["fx_list"] = { "hh_fx_star_white", "hh_sparkle_fx", } },
    { ["name"] = "红色星星", ["fx_list"] = { "hh_fx_star_red", "hh_sparkle_fx", } },
    { ["name"] = "橙色星星", ["fx_list"] = { "hh_fx_star_orange", "hh_sparkle_fx", } },
    { ["name"] = "黄色星星", ["fx_list"] = { "hh_fx_star_yellow", "hh_sparkle_fx", } },
    { ["name"] = "绿色星星", ["fx_list"] = { "hh_fx_star_green", "hh_sparkle_fx", } },
    { ["name"] = "蓝色星星", ["fx_list"] = { "hh_fx_star_blue", "hh_sparkle_fx", } },
    { ["name"] = "紫色星星", ["fx_list"] = { "hh_fx_star_purple", "hh_sparkle_fx", } },

    { ["name"] = "白色猪猪", ["fx_list"] = { "hh_fx_pig_white", } },
    { ["name"] = "紫色猪猪", ["fx_list"] = { "hh_fx_pig_purple", } },
    { ["name"] = "蓝色猪猪", ["fx_list"] = { "hh_fx_pig_blue", } },
    { ["name"] = "橙色猪猪", ["fx_list"] = { "hh_fx_pig_orange", } },
}
local staff_gem_list = {
    ["gears"] = "a_stoneDecoder", --齿轮:使用解石器
    ["horn"] = "a_punchStone", --牛角:装备打孔(消耗打孔石)
    ["greengem"] = "a_refreshStone", --绿宝石:刷新词条数值(消耗重置宝石)
    ["walrus_tusk"] = "strideBead", --海象牙:镶嵌步伐珠(已打孔)
    ["redgem"] = "critStrikeStone", --红宝石:镶嵌暴击石(已打孔)
    ["lightninggoathorn"] = "bossStrikeGem", --电羊角:镶嵌首领打击(已打孔)
    ["silk"] = "spiderVengeance", --蜘蛛丝:镶嵌蜘蛛打击(已打孔)
    ["stinger"] = "insectStrikeCrystal", --蜂刺:镶嵌昆虫打击(已打孔)
    ["townportaltalisman"] = "powerMettleStone", --沙之石:镶嵌力势石(已打孔)
    ["steelwool"] = "damageBoostGem", --刚羊毛:镶嵌增伤宝珠(已打孔)
    ["dragon_scales"] = "treasure_atk", --龙蝇皮:镶嵌宝★攻击(已打孔)
    ["minotaurhorn"] = "treasure_bj", --犀牛角:镶嵌宝★暴击(已打孔)
    ["deerclops_eyeball"] = "treasure_armor", --巨鹿眼球:镶嵌宝★回耐(已打孔)
}
----
---获取不同数值的余数
---
local GetDifRemainder = function(hh_num_data)
    local hh_num = hh_num_data % 6
    local one_angle = math["pi"] / 12
    return hh_num == 1 and one_angle * 5
            or (hh_num == 2 and one_angle * 3)
            or (hh_num == 3 and one_angle * 1)
            or (hh_num == 4 and -one_angle * 1)
            or (hh_num == 5 and -one_angle * 3)
            or -one_angle * 5
end
local function createStarFx()
    local hh_fx = SpawnPrefab("hh_common_fx")
    hh_fx["AnimState"]:SetBank("hh_star_fx")
    hh_fx["AnimState"]:SetBuild("hh_star_fx")
    hh_fx["AnimState"]:PlayAnimation("idle", true)
    hh_fx["entity"]:AddFollower()
    hh_fx["not_need_remove"] = true
    return hh_fx
end
local function SetFxOwner(inst, owner)
    HH_UTILS:HHRemoveFx(inst, "hh_follow_fx")
    inst["hh_follow_fx"] = createStarFx()
    if owner ~= nil then
        inst["hh_follow_fx"]["entity"]:SetParent(owner["entity"])
        inst["hh_follow_fx"]["Follower"]:FollowSymbol(owner["GUID"], "swap_object", 0, -220, -0.1)
    else
        inst["hh_follow_fx"]["entity"]:SetParent(inst["entity"])
        inst["hh_follow_fx"]["Follower"]:FollowSymbol(inst["GUID"], "hh_staff_star", 0, -220, -0.1)
    end
end
----
---增加生成抛射物任务
---
local function AddStarTask(inst, attacker)

end

local function GetFollowFx(hh_table, fx_index)
    if HH_UTILS:IsHHType(HH_FX_CONFIG[fx_index], "table")
            and HH_FX_CONFIG[fx_index]["fx_list"]
    then
        hh_table = HH_FX_CONFIG[fx_index]["fx_list"]
    end
    return hh_table
end
local EQUIP_BLACK_TAG = {
    "INLIMBO", "NOCLICK", "irreplaceable", "knockbackdelayinteraction", "event_trigger",
    "minesprung", "mineactive", "catchable",
    "fire", "light", "spider", "cursed", "paired", "bundle",
    "heatrock", "deploykititem", "boatbuilder", "singingshell",
    "archive_lockbox", "simplebook", "furnituredecor",
    "flower", "gemsocket", "structure",
    "donotautopick",
}
local function checkEquipOwner(inst)
    return inst["components"]["inventoryitem"] and inst["components"]["inventoryitem"]["owner"] == nil or true
end
--拆解法杖函数
local function addEffectEquip(hh_inst, target, pos, caster)
    if HH_UTILS:IsHHType(pos, "table") and pos["x"] and pos["y"] and pos["z"] then
        local equip_ent = TheSim:FindEntities(pos["x"], pos["y"], pos["z"], 8, { "hh_equip" }, EQUIP_BLACK_TAG, { "_inventoryitem", "pickable" })
        local has_tally = true
        local remove_tally_num = 0
        if equip_ent and #equip_ent > 0 then
            for i, v in ipairs(equip_ent) do
                local hh_equip = v
                if HH_UTILS:HasComponents(hh_equip, "hh_equip")
                        and checkEquipOwner(hh_equip)
                        and HH_UTILS:HasComponents(hh_equip, "equippable")
                        and not hh_equip["components"]["equippable"]:IsEquipped()
                then
                    local current_num = hh_equip["components"]["hh_equip"]:GetEffectsNum()
                    local add_num = 3 - current_num
                    if add_num > 0 then
                        for kk = 1, add_num do
                            if HH_UTILS:HasComponents(hh_inst, "container")
                                    and hh_inst["components"]["container"]:Has("hh_effect_tally", 1)
                            then
                                local add_result = hh_equip["components"]["hh_equip"]:AddEquipBuff(nil)
                                if add_result then
                                    hh_inst["components"]["container"]:ConsumeByName("hh_effect_tally", 1)
                                    remove_tally_num = remove_tally_num + 1
                                end
                            else
                                has_tally = false
                                break
                            end
                        end
                    end
                end
                if not has_tally then
                    HH_UTILS:HHSay(caster, string["format"]("批量附魔结束,消耗卷轴%s个", remove_tally_num))
                    break
                end
            end
        end
    end
end
local function addOneEffectToEquip(hh_inst, target, pos, caster)
    local container_components = hh_inst["components"]["container"]
    local hh_stone = container_components:GetItemInSlot(1)
    if hh_stone and hh_stone["hh_effect"] and HH_UTILS:HasComponents(target, "hh_equip") then
        local success, message = target["components"]["hh_equip"]:AddEquipBuff(hh_stone["hh_effect"])
        if success then
            container_components:ConsumeByName("hh_effect_stone", 1)
        end
        HH_UTILS:HHSay(caster, tostring(message))
    else
        HH_UTILS:HHSay(caster, "未查询到附魔石")
    end
end
--清除附魔
local function removeRandomEffectToEquip(hh_inst, target, pos, caster)
    local container_components = hh_inst["components"]["container"]
    local hh_stone = container_components:GetItemInSlot(1)
    if hh_stone and HH_UTILS:HasComponents(target, "hh_equip") then
        local success, message = target["components"]["hh_equip"]:ReduceEquipBuffByIndex(nil)
        if success then
            container_components:ConsumeByName("hh_remove_stone", 1)
        end
        HH_UTILS:HHSay(caster, tostring(message))
    else
        HH_UTILS:HHSay(caster, "右键装备进行操作")
    end
end
local function hasItemByKey(player, item_id)
    local result = false
    if HH_UTILS:HasComponents(player, "hh_player")
            and HH_UTILS:IsHHType(item_id, "string")
            and player["components"]["hh_player"]:HasItemsByKey(item_id)
    then
        result = true
    end
    return result
end
local function removeGemByKey(player, item_id)
    if HH_UTILS:HasComponents(player, "hh_player") then
        player["components"]["hh_player"]:RemoveItemsByKey(item_id, 1)
    end
end
--宝石处理
local function addGemEffectToEquip(caster, target, prefab_id)
    if not HH_UTILS:HasComponents(target, "hh_equip") then
        HH_UTILS:HHSay(caster, "右键附魔装备操作")
        return
    end
    if not staff_gem_list[prefab_id] then
        HH_UTILS:HHSay(caster, "请放正确的道具进行操作")
        return
    end
    if not HH_UTILS:HasComponents(caster, "hh_player") then
        HH_UTILS:HHSay(caster, "非玩家无法操作")
        return
    end
    local gem_id = staff_gem_list[prefab_id]
    if not HH_UTILS:IsHHType(gem_id, "string") then
        HH_UTILS:HHSay(caster, "宝石id错误")
        return
    end
    if not hasItemByKey(caster, gem_id) then
        HH_UTILS:HHSay(caster, "宝石数量不足")
        return
    end
    local success, message = true, "操作成功"
    if prefab_id == "horn" then
        --打孔
        success, message = target["components"]["hh_equip"]:AddGemCurrentLimit()
    elseif prefab_id == "gears" then
        --删除宝石
        success, message = target["components"]["hh_equip"]:ReduceGemByIndex()
    elseif prefab_id == "greengem" then
        --刷新数值
        success, message = target["components"]["hh_equip"]:UpdateEffectValue()
    else
        --镶嵌宝石
        success, message = target["components"]["hh_equip"]:AddNewGem(gem_id)
    end
    if success then
        removeGemByKey(caster, gem_id)
    end
    HH_UTILS:HHSay(caster, tostring(message))
end

local function removeEquip(hh_inst, target, pos, caster)
    if HH_UTILS:IsHHType(pos, "table")
            and pos["x"] and pos["y"] and pos["z"]
    then
        --先拆除附魔石
        local stone_ent = TheSim:FindEntities(pos["x"], pos["y"], pos["z"], 8, { "hh_add_stone" }, EQUIP_BLACK_TAG, { "_inventoryitem", "pickable" })
        if stone_ent and #stone_ent > 0 then
            local goodEffectList = HHGetComEquipEffect()
            for i, v in ipairs(stone_ent) do
                if v and v["prefab"] == "hh_effect_stone" then
                    if v["hh_effect"] and goodEffectList and table["contains"](goodEffectList, v["hh_effect"]) then
                        local x, y, z = v["Transform"]:GetWorldPosition()
                        local essence_stone = SpawnPrefab("hh_essence")
                        if essence_stone then
                            essence_stone["Transform"]:SetPosition(x, y, z)
                        end
                        v:Remove()
                    end
                end
            end
        end
        local equip_ent = TheSim:FindEntities(pos["x"], pos["y"], pos["z"], 8, { "hh_equip" }, EQUIP_BLACK_TAG, { "_inventoryitem", "pickable" })
        if equip_ent and #equip_ent > 0 then
            local hh_check_list = {}
            for i, v in ipairs(HH_EQUIP_DROP) do
                if v and v["id"] then
                    local equip_id = v["id"]
                    hh_check_list[equip_id] = true
                end
            end
            for i, v in ipairs(equip_ent) do
                if HH_UTILS:HasComponents(v, "hh_equip")
                        and checkEquipOwner(v)
                        and HH_UTILS:HasComponents(v, "equippable")
                        and not v["components"]["equippable"]:IsEquipped()
                        and hh_check_list[v["prefab"]]
                then
                    local effect_num = v["components"]["hh_equip"]:GetEffectsNum()
                    local x, y, z = v["Transform"]:GetWorldPosition()
                    if effect_num and effect_num > 0 then
                        local can_spawn_stone = true
                        --随机的词条id
                        local random_effect_name = v["components"]["hh_equip"]:GetRandomEffect()
                        if effect_num < 3 then
                            local chance = math["random"]()
                            if chance > 0.1 then
                                can_spawn_stone = false
                            end
                        end
                        if can_spawn_stone then
                            local effect_stone = SpawnPrefab("hh_effect_stone")
                            if effect_stone then
                                effect_stone["hh_effect"] = random_effect_name
                                if effect_stone["HH_Update_Server"] then
                                    effect_stone:HH_Update_Server()
                                end
                                --兼容一下皮肤
                                HH_UTILS:UpdateSkinItem(caster, effect_stone)
                                effect_stone["Transform"]:SetPosition(x, y, z)
                            end
                        end
                    end
                    v:Remove()
                end
            end
        end
    end
end
local HH_EQUIP = {
    ["hh_staff_dis"] = {
        ["client_fn"] = function(inst)
            inst:AddTag("quickcast")
            if not TheWorld["ismastersim"] then
                inst["OnEntityReplicated"] = function(_inst)
                    _inst["replica"]["container"]:WidgetSetup("hh_staff_dis")
                end
            end
        end,
        ["start_fn"] = function(inst)
            --加容器
            inst:AddComponent("container")
            inst["components"]["container"]:WidgetSetup("hh_staff_dis")
            inst:AddComponent("spellcaster")
            --右键拆解
            inst["components"]["spellcaster"]:SetSpellFn(function(hh_inst, target, pos, caster)
                --print(hh_inst, target, pos, caster)
                --有卷轴 自动附魔
                if HH_UTILS:HasComponents(hh_inst, "container") then
                    local hh_slot_item = hh_inst["components"]["container"]:GetItemInSlot(1)
                    if not hh_slot_item then
                        removeEquip(hh_inst, target, pos, caster)
                        return
                    end
                    local prefab_id = hh_slot_item["prefab"]
                    if hh_inst["components"]["container"]:Has("hh_effect_tally", 1) then
                        addEffectEquip(hh_inst, target, pos, caster)
                    elseif hh_inst["components"]["container"]:Has("hh_effect_stone", 1) then
                        addOneEffectToEquip(hh_inst, target, pos, caster)
                    elseif hh_inst["components"]["container"]:Has("hh_remove_stone", 1) then
                        removeRandomEffectToEquip(hh_inst, target, pos, caster)
                    elseif staff_gem_list[prefab_id] then
                        --宝石部分处理 加异常处理
                        addGemEffectToEquip(caster, target, prefab_id)
                    else
                    end
                end
            end)
            inst["components"]["spellcaster"]["canuseontargets"] = true
            inst["components"]["spellcaster"]["canuseonpoint"] = true
            inst["components"]["spellcaster"]["canuseonpoint_water"] = true
            inst["components"]["spellcaster"]["quickcast"] = true
            --覆盖校验方法
            inst["components"]["spellcaster"]["CanCast"] = function(self, doer, target, pos)
                if self["spell"] == nil then
                    return false
                elseif target == nil then
                    if pos == nil then
                        return self["canusefrominventory"]
                    end
                    if self["canuseonpoint"] then
                        local px, py, pz = pos:Get()
                        return TheWorld["Map"]:IsAboveGroundAtPoint(px, py, pz, self["canuseonpoint_water"]) and not TheWorld["Map"]:IsGroundTargetBlocked(pos)
                    elseif self["canuseonpoint_water"] then
                        return TheWorld["Map"]:IsOceanAtPoint(pos:Get()) and not TheWorld["Map"]:IsGroundTargetBlocked(pos)
                    end
                elseif target:IsValid() and not target:IsInLimbo() and target:HasTag("hh_equip")
                        --and HH_UTILS:HasComponents(target, "hh_equip") and target["components"]["hh_equip"]:CanAddEquipBuff()
                        and HH_UTILS:HasComponents(target, "hh_equip")
                then
                    return true
                end
                return false
            end
            inst["GetHHSpDesc01"] = function(_inst, player)
                return {
                    ["title"] = "特殊",
                    ["desc"] = "放入不同的道具右键装备\n附魔石:装备附魔\n洗蕴石:清除词条\n其他道具见左下角帮助中拆除法杖功能",
                }
            end
            inst["GetHHSpDesc02"] = function(_inst, player)
                return {
                    ["title"] = "附魔",
                    ["desc"] = string["format"]("放卷轴可以范围内装备随机附魔至%s个", 3),
                }
            end
            inst["GetHHSpDesc03"] = function(_inst, player)
                return {
                    ["title"] = "拆除",
                    ["desc"] = string["format"]("容器为空,右键地面拆除范围%s码内的装备/附魔石", 8),
                }
            end
        end,
        ["equip_fn"] = function(inst, owner)
            if inst["components"]["container"] ~= nil then
                inst["components"]["container"]:Open(owner)
            end
        end,
        ["unequip_fn"] = function(inst, owner)
            if inst["components"]["container"] ~= nil then
                inst["components"]["container"]:Close()
            end
        end,
    },

    ["hh_ice_knife"] = {
        ["client_fn"] = function(inst)
        end,
        ["start_fn"] = function(inst)
            inst["components"]["weapon"]:SetRange(1.5, 1.8)
            inst["components"]["weapon"]:SetOnAttack(function(_inst, attacker, target)
                local random_index = math["random"]()
                if random_index > 0.7 then
                    return
                end
                if not attacker or not attacker["GetPosition"] then
                    return
                end
                if attacker["hh_atk_task"] then
                    return
                end
                if not (target and target["Transform"]) then
                    return
                end
                local spawn_num = 0
                local hh_pos = attacker:GetPosition()

                local pos_x, pos_y, pos_z = target["Transform"]:GetWorldPosition()
                -----------------------------------------------------------------------------
                -----------------------------------------------------------------------------
                local start_x = hh_pos["x"]
                local start_z = hh_pos["z"]
                local hh_angle = attacker:GetAngleToPoint(Vector3(pos_x, pos_y, pos_z))
                if hh_angle < 0 then
                    hh_angle = hh_angle + 360
                end
                hh_angle = -hh_angle
                attacker["hh_save_target_id"] = {}
                --攻击目标剔除
                if target and target["GUID"] then
                    table["insert"](attacker["hh_save_target_id"], target["GUID"])
                end
                attacker["hh_atk_task"] = attacker:DoPeriodicTask(0.05, function()
                    local hh_range = 1.5 * spawn_num
                    for i = 1, 3 do
                        local hh_fx_angle = hh_angle
                        if i == 1 then
                            hh_fx_angle = hh_fx_angle - 30
                        elseif i == 2 then
                        else
                            hh_fx_angle = hh_fx_angle + 30
                        end
                        local end_x, end_z = start_x + hh_range * math["cos"](hh_fx_angle * DEGREES), start_z + hh_range * math["sin"](hh_fx_angle * DEGREES)
                        local list_fx = {
                            "halloween_firepuff_cold_1",
                            "halloween_firepuff_cold_2",
                            "halloween_firepuff_cold_3",
                        }
                        local fire_fx = SpawnPrefab(list_fx[math["random"](#list_fx)])
                        if fire_fx and fire_fx["Transform"] then
                            fire_fx["Transform"]:SetPosition(end_x, 0, end_z)
                            -- 造成伤害
                            if not attacker["hh_save_target_id"] then
                                attacker["hh_save_target_id"] = {}
                            end
                            local ents = TheSim:FindEntities(end_x, 0, end_z, 1.7,
                                    { "_combat" },
                                    {
                                        "INLIMBO", "NOCLICK", "notarget", "player",
                                        "noattack", "playerghost", "wall", "structure", "balloon",
                                        "companion", "glommer", "friendlyfruitfly", "abigail", "shadowminion"
                                    })
                            if not ents then
                                return
                            end
                            for k, ent in ipairs(ents) do
                                if HH_UTILS:HasComponents(ent, "combat")
                                        and ent ~= target and HH_UTILS:NotIsDead(ent)
                                        and HH_UTILS:CanHitTarget(attacker, ent)
                                        and attacker["components"]["combat"]:IsValidTarget(ent)
                                then
                                    if ent["GUID"] and not table["contains"](attacker["hh_save_target_id"], ent["GUID"]) then
                                        ent["components"]["combat"]:GetAttacked(attacker, 50)
                                        table["insert"](attacker["hh_save_target_id"], ent["GUID"])
                                    end
                                end
                            end
                        end
                    end
                    spawn_num = spawn_num + 1
                    if spawn_num > 8 then
                        HH_UTILS:HHKillTask(attacker, "hh_atk_task")
                    end

                end)
            end)

            inst:AddComponent("finiteuses")
            inst["components"]["finiteuses"]:SetOnFinished(inst["Remove"])
            inst["components"]["finiteuses"]:SetMaxUses(360)
            inst["components"]["finiteuses"]:SetUses(360)

            inst:AddComponent("trader")  --交易者组件
            inst["components"]["trader"]["acceptnontradable"] = true  --可交易
            --可接受的物品
            inst["components"]["trader"]:SetAcceptTest(function(_inst, item)
                if not HH_UTILS:HasComponents(_inst, "finiteuses") then
                    return false
                end
                return item and item["prefab"] == "hh_essence" and _inst["components"]["finiteuses"]:GetPercent() < 1 or false
            end)
            --获得物品时执行函数
            inst["components"]["trader"]["onaccept"] = function(_inst, giver, item)
                --处理耐久
                if item and item["prefab"] == "hh_essence" and _inst["components"]["finiteuses"] then
                    _inst["components"]["finiteuses"]:Use(-50)
                    if _inst["components"]["finiteuses"]:GetPercent() > 1 then
                        --百分比超过1，则耐久为1，防止耐久修复溢出
                        _inst["components"]["finiteuses"]:SetPercent(1)
                    end
                end
            end
            --拒绝材料时执行
            inst["components"]["trader"]["onrefuse"] = function(_inst, giver, item)
                HH_UTILS:HHSay(giver, "水晶道具回复耐久")
            end

            inst["GetHHSpDesc01"] = function(_inst, player)
                return {
                    ["title"] = "效果",
                    ["desc"] = string["format"]("攻击%s%%概率造成三段火焰沟壑,伤害:%s(享受加成)", 70, 50),
                }
            end
            inst["GetHHSpDesc02"] = function(_inst, player)
                return { ["title"] = "可修复", ["desc"] = "消耗水晶道具回复耐久", }
            end
        end,

    },
    ["hh_staff_star"] = {
        ["client_fn"] = function(inst)

            --快速施法
            inst:AddTag("hh_fast_spell")
            inst:AddTag("rechargeable")
            inst:AddComponent("aoetargeting")
            inst["components"]["aoetargeting"]:SetTargetFX("weaponsparks")
            inst["components"]["aoetargeting"]["reticule"]["reticuleprefab"] = "reticuleaoe"
            inst["components"]["aoetargeting"]["reticule"]["pingprefab"] = "reticuleaoeping"
            inst["components"]["aoetargeting"]["reticule"]["targetfn"] = function()
                local player = ThePlayer
                local ground = TheWorld["Map"]
                local pos = Vector3()
                for r = 7, 0, -0.25 do
                    pos["x"], pos["y"], pos["z"] = player["entity"]:LocalToWorldSpace(r, 0, 0)
                    if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
                        return pos
                    end
                end
                return pos
            end
            inst["components"]["aoetargeting"]["reticule"]["validcolour"] = { 126 / 255, 240 / 255, 165 / 255, 1 }
            inst["components"]["aoetargeting"]["reticule"]["invalidcolour"] = { 178 / 255, 100 / 255, 50 / 255, 1 }
            inst["components"]["aoetargeting"]["reticule"]["ease"] = true
            inst["components"]["aoetargeting"]["reticule"]["mouseenabled"] = true
            inst["components"]["aoetargeting"]:SetRange(16)
        end,
        ["start_fn"] = function(inst)
            --技能cd
            inst["hh_spell_cd"] = 10
            --施法技能
            inst:AddComponent("aoespell")
            inst["components"]["aoespell"]:SetSpellFn(function(_inst, doer, pos)
                local hh_start_pos = pos
                _inst["components"]["rechargeable"]:Discharge(_inst["hh_spell_cd"])
                if HH_UTILS:NotIsDead(doer) and hh_start_pos and not doer["hh_spell_task"] then
                    --指示器
                    HH_UTILS:SpawnIndicatorFx(hh_start_pos, 1.5, { 1, 1, 1, 1 }, 1.8)
                    local spawn_num = 0
                    local hh_weapon_inst = _inst
                    doer["hh_spell_task"] = doer:DoPeriodicTask(0.1, function(player)
                        if not hh_weapon_inst or not player then
                            HH_UTILS:HHKillTask(player, "hh_spell_task")
                            return
                        end
                        if not HH_UTILS:NotIsDead(player) then
                            HH_UTILS:HHKillTask(player, "hh_spell_task")
                            return
                        end
                        --随机范围
                        --local hh_com_num = 1.2
                        local hh_com_num = 3
                        local hh_random_angle = math["random"]() * math["pi"] * 2
                        local start_pos = player:GetPosition()
                        --增加距离限制 如果超过30码直接取消
                        local check_distance = start_pos:Dist(hh_start_pos)
                        if check_distance > 30 then
                            HH_UTILS:HHKillTask(player, "hh_spell_task")
                            return
                        end
                        local hh_GetNormalized = (hh_start_pos - start_pos):GetNormalized()
                        local hh_distance_a = math["atan2"](hh_start_pos["x"] - start_pos["x"], hh_start_pos["z"] - start_pos["z"])
                        local hh_distance_pos = Vector3(math["sin"](hh_distance_a + math["pi"] / 2), 0, math["cos"](hh_distance_a + math["pi"] / 2))
                        local com_vect = Vector3(0, 1, 0)
                        local hh_dif_num = GetDifRemainder(spawn_num % 2 == 1 and (spawn_num + 1) / 2 or -spawn_num / 2)
                        local hh_num_five = 5--数值越大 弧度越大
                        local hh_random_offset_pos = start_pos - hh_GetNormalized * 5 + com_vect * 9 + com_vect * math["cos"](hh_dif_num) * hh_num_five + hh_distance_pos * math["sin"](hh_dif_num) * hh_num_five
                        local hh_random_offset_pos_end = (hh_start_pos + hh_random_offset_pos) / 2 + Vector3(0, 5, 0)
                        local end_pos = Vector3(hh_start_pos["x"] + hh_com_num * math["sin"](hh_random_angle), 0, hh_start_pos["z"] + hh_com_num * math["cos"](hh_random_angle))
                        local bezierDist = start_pos:Dist(hh_random_offset_pos) + hh_random_offset_pos:Dist(end_pos)

                        local proj = SpawnPrefab("hh_bow_project")
                        if proj then
                            if proj["components"]["projectile"] ~= nil then
                                proj["components"]["projectile"]:SetSpeed(55)
                                proj["components"]["projectile"]["onhit"] = function(hh_inst, owner, target)
                                    HH_UTILS:SpawnExplodeFx(hh_inst)
                                    local pos_x, pos_y, pos_z = hh_inst["Transform"]:GetWorldPosition()
                                    local ents = TheSim:FindEntities(pos_x, 0, pos_z, 4,
                                            { "_combat" }, { "INLIMBO", "NOCLICK", "notarget", "player",
                                                             "noattack", "playerghost", "wall", "structure", "balloon",
                                                             "companion", "glommer", "friendlyfruitfly", "abigail", "shadowminion" })
                                    if not ents then
                                        return
                                    end
                                    local range_damage = 30
                                    for k, ent in ipairs(ents) do
                                        if HH_UTILS:HasComponents(ent, "combat")
                                                and HH_UTILS:HasComponents(owner, "hh_player")
                                                and HH_UTILS:NotIsDead(owner)
                                                and ent ~= owner and HH_UTILS:NotIsDead(ent)
                                                and HH_UTILS:CanHitTarget(owner, ent)
                                                and owner["components"]["combat"]:IsValidTarget(ent)
                                        then
                                            ent["components"]["combat"]:GetAttacked(owner, range_damage)
                                        end
                                    end
                                    hh_inst:Remove()
                                end

                                local x, y, z = player["Transform"]:GetWorldPosition()
                                local hh_pos = player:GetPosition()
                                proj["Transform"]:SetPosition(x, y, z)
                                --proj["components"]["projectile"]:SetBezier(1.5, 90 + (spawn_num - 1) * 45)
                                local offset_vector = Vector3(-10, 2, -10)
                                proj["components"]["projectile"]:SetBezier3(hh_random_offset_pos, hh_random_offset_pos_end)
                                proj["components"]["projectile"]:SetBezierCalcDist(bezierDist)
                                proj["components"]["projectile"]:Throw(hh_weapon_inst or player, end_pos, player)

                                --同步炫彩特效
                                local fx_index = hh_weapon_inst and hh_weapon_inst["proj_fx_index"] or 1
                                local current_fxs = {}
                                current_fxs = GetFollowFx(current_fxs, fx_index)
                                for i, v in ipairs(current_fxs) do
                                    proj["hh_fx_" .. i] = proj:SpawnChild(v)
                                end
                            end
                        end
                        --每一发消耗3点耐久
                        if HH_UTILS:HasComponents(hh_weapon_inst, "finiteuses") then
                            local reduce = math["min"](hh_weapon_inst["components"]["finiteuses"]["current"] or 3, 3)
                            hh_weapon_inst["components"]["finiteuses"]:Use(reduce)
                        end
                        spawn_num = spawn_num + 1
                        if spawn_num > 9 then
                            HH_UTILS:HHKillTask(player, "hh_spell_task")
                        end
                    end)
                end
            end)


            --冷却组件
            inst:AddComponent("rechargeable")
            inst["components"]["rechargeable"]:SetOnDischargedFn(function(_inst)
                _inst["components"]["aoetargeting"]:SetEnabled(false)
            end)
            inst["components"]["rechargeable"]:SetOnChargedFn(function(_inst)
                _inst["components"]["aoetargeting"]:SetEnabled(true)
            end)

            inst["components"]["weapon"]:SetRange(15, 18)
            inst["components"]["weapon"]:SetOnAttack(function(_inst, attacker, target)
            end)
            inst["components"]["weapon"]:SetProjectile("hh_bow_project")

            --inst["components"]["weapon"]:SetOnAttack(function(_inst, attacker, target)
            --end)
            local oldLaunchProjectile = inst["components"]["weapon"]["LaunchProjectile"]
            inst["components"]["weapon"]["LaunchProjectile"] = function(self, attacker, target, ...)
                if attacker and target then
                    if self["inst"]["atk_task"] then
                        return
                    end
                    HH_UTILS:HHKillTask(self["inst"], "hh_atk_task")
                    ----查询抛射物皮肤
                    local fx_index = self["inst"]["proj_fx_index"] or 1
                    local current_fxs = {}
                    current_fxs = GetFollowFx(current_fxs, fx_index)
                    local spawn_num = 0
                    local hh_target = target
                    local hh_attacker = attacker
                    self["inst"]["hh_atk_task"] = self["inst"]:DoPeriodicTask(0.1, function(weapon_inst)
                        if not (HH_UTILS:NotIsDead(hh_target) and HH_UTILS:NotIsDead(hh_attacker)) then
                            HH_UTILS:HHKillTask(weapon_inst, "hh_atk_task")
                            return
                        end
                        local proj = SpawnPrefab("hh_bow_project")
                        if proj then
                            if proj["components"]["projectile"] ~= nil then
                                local x, y, z = hh_attacker["Transform"]:GetWorldPosition()
                                local hh_pos = hh_attacker:GetPosition()
                                local hh_target_pos = hh_target:GetPosition()
                                proj["Transform"]:SetPosition(x, y, z)
                                proj["components"]["projectile"]:SetBezier(1.5, 90 + (spawn_num - 1) * 45)
                                local offset_vector = Vector3(-10, 2, -10)
                                --proj["components"]["projectile"]:SetBezier3(hh_pos + offset_vector, hh_target_pos + offset_vector)
                                --proj["components"]["projectile"]:SetBezierCalcDist(hh_pos:Dist(hh_target_pos))
                                proj["components"]["projectile"]:Throw(weapon_inst, hh_target, hh_attacker)

                                --跟随特效
                                for i, v in ipairs(current_fxs) do
                                    proj["hh_fx_" .. i] = proj:SpawnChild(v)
                                end
                            end
                            --if self["onprojectilelaunched"] ~= nil then
                            --    self["onprojectilelaunched"](weapon_inst, hh_attacker, target, proj)
                            --end
                        end
                        spawn_num = spawn_num + 1
                        if spawn_num >= 3 then
                            HH_UTILS:HHKillTask(weapon_inst, "hh_atk_task")
                        end
                    end, 0)
                else
                    return oldLaunchProjectile(self, attacker, target, ...)
                end
            end

            inst:AddComponent("finiteuses")
            inst["components"]["finiteuses"]:SetOnFinished(inst["Remove"])
            inst["components"]["finiteuses"]:SetMaxUses(360)
            inst["components"]["finiteuses"]:SetUses(360)

            inst["GetHHSpDesc01"] = function(_inst, player)
                return { ["title"] = "效果", ["desc"] = string["format"]("右键召唤流星击打范围(%s)目标(cd:%s秒)", 4, 10), }
            end
            inst["GetHHSpDesc02"] = function(_inst, player)
                return { ["title"] = "可修复", ["desc"] = "水晶道具回复耐久,金块切换特效", }
            end
            --特效
            inst["GetHHSpDesc03"] = function(_inst, player)
                if _inst["proj_fx_index"] and HH_FX_CONFIG[_inst["proj_fx_index"]] then
                    local fx_name = HH_FX_CONFIG[_inst["proj_fx_index"]]["name"]
                    return { ["title"] = "炫彩特效", ["desc"] = string["format"]("%s(%s/%s)", tostring(fx_name), _inst["proj_fx_index"], #HH_FX_CONFIG) }
                end
                return nil
            end
            inst["GetHHSpDesc04"] = function(_inst, player)
                return { ["title"] = "画师", ["desc"] = "余音音", }
            end
            inst:AddComponent("trader")  --交易者组件
            inst["components"]["trader"]["acceptnontradable"] = true  --可交易
            --可接受的物品
            inst["components"]["trader"]:SetAcceptTest(function(_inst, item)
                if item and item["prefab"] == "goldnugget" then
                    return true
                end
                if not HH_UTILS:HasComponents(_inst, "finiteuses") then
                    return false
                end
                return item and item["prefab"] == "hh_essence" and _inst["components"]["finiteuses"]:GetPercent() < 1 or false
            end)
            --获得物品时执行函数
            inst["components"]["trader"]["onaccept"] = function(_inst, giver, item)
                --处理耐久
                if item and item["prefab"] == "hh_essence" and _inst["components"]["finiteuses"] then
                    _inst["components"]["finiteuses"]:Use(-50)
                    if _inst["components"]["finiteuses"]:GetPercent() > 1 then
                        --百分比超过1，则耐久为1，防止耐久修复溢出
                        _inst["components"]["finiteuses"]:SetPercent(1)
                    end
                end
                --金块顺序切换特效
                if item and item["prefab"] == "goldnugget" then
                    local all_fx_num = #HH_FX_CONFIG
                    if _inst["proj_fx_index"] >= all_fx_num then
                        _inst["proj_fx_index"] = 1
                    else
                        _inst["proj_fx_index"] = _inst["proj_fx_index"] + 1
                    end
                    --_inst["proj_fx_index"] = math["random"](1, all_fx_num)
                end
            end
            --拒绝材料时执行
            inst["components"]["trader"]["onrefuse"] = function(_inst, giver, item)
                HH_UTILS:HHSay(giver, "金块切换特效,水晶道具回复耐久")
            end

            ----增加挂载特效
            inst["hh_follow_fx"] = createStarFx()
            SetFxOwner(inst, nil)
            inst["proj_fx_index"] = 1

            inst["OnSave"] = function(_inst, data)
                if data then
                    data["proj_fx_index"] = _inst["proj_fx_index"] or 0
                end
            end
            inst["OnPreLoad"] = function(_inst, data)
                if data and data["proj_fx_index"] then
                    _inst["proj_fx_index"] = data["proj_fx_index"]
                end
            end
        end,
        ["equip_fn"] = function(inst, owner)
            SetFxOwner(inst, owner)
        end,
        ["unequip_fn"] = function(inst, owner)
            SetFxOwner(inst, nil)
        end,


    },

}
return HH_EQUIP
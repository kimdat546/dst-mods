local HH_UTILS = require("utils/hh_utils")
--回血词条黑名单
local HEALTH_REPLY_BLACK_LIST = {
    ["sharkboi"] = true,
    ["daywalker"] = true,
    ["daywalker2"] = true,
}
--检查是否允许添加回血buff
local function checkReplyBlack(inst)
    if not inst or not inst["prefab"] then
        return false
    end
    if HEALTH_REPLY_BLACK_LIST[inst["prefab"]] then
        --不允许添加回血
        return false
    end
    return true
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local function doHealthDamage(inst, attacker, damage, atk_type)
    if not inst or not inst["Transform"] then
        return
    end
    --根据天数来增加炮塔伤害 最高20点
    local nowDays = 0
    if TheWorld["state"] and TheWorld["state"]["cycles"] then
        nowDays = TheWorld["state"]["cycles"]
    end
    local base_health_damage = damage
    local add_percent = math["floor"](nowDays / 30)
    base_health_damage = base_health_damage * (1 + add_percent)
    --上限-20
    if base_health_damage <= -20 then
        base_health_damage = -20
    end
    --print("炮塔", base_health_damage, nowDays)
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 2, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
    for i, v in ipairs(ents) do
        if HH_UTILS:CanHitTarget(attacker, v) and HH_UTILS:NotIsDead(v) then
            --print(v, inst["hh_atk_type"])
            ----十点真伤(怪物100)
            if HH_UTILS:HasComponents(v, "hh_monster") then
                v["components"]["health"]:DoDelta(-100)
            else
                local damage_str = "hh_turret"
                if HH_UTILS:IsHHType(atk_type, "string") then
                    damage_str = "hh_turret_" .. atk_type
                end
                v["components"]["health"]:DoDelta(base_health_damage, false, damage_str)
            end
            --挂个制裁
            if HH_UTILS:HasComponents(v, "hh_buff") then
                if HH_UTILS:HasComponents(v, "hh_monster") then
                    v["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 5)
                elseif HH_UTILS:HasComponents(v, "hh_player") then
                    v["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 5)
                end
            end
            if inst["hh_atk_type"] and HH_UTILS:NotIsDead(v) then
                if inst["hh_atk_type"] == "ice" then
                    if HH_UTILS:HasComponents(v, "freezable") then
                        v["components"]["freezable"]:AddColdness(0.3)
                    end
                    --烫伤效果
                elseif inst["hh_atk_type"] == "fire" then
                    if HH_UTILS:HasComponents(v, "hh_buff") then
                        v["components"]["hh_buff"]:AddBuff("turret_fire", 10)
                    end
                    --剧毒效果
                elseif inst["hh_atk_type"] == "poison" then
                    if HH_UTILS:HasComponents(v, "hh_buff") then
                        v["components"]["hh_buff"]:AddBuff("turret_poison", 10)
                    end
                end
            end
        end
    end
end
local atk_type_config = {
    ["ice"] = {
        ["color"] = { 0 / 255, 101 / 255, 255 / 255, 1 },
        ["lz_fx"] = { "hh_turret_fx_ice", "hh_sparkle_fx", },
        ["hit_fn"] = function(inst, attacker, atk_type)
            doHealthDamage(inst, attacker, -5, atk_type)
        end,
    },
    ["fire"] = {
        ["color"] = { 255 / 255, 11 / 255, 0 / 255, 1 },
        ["lz_fx"] = { "hh_turret_fx_fire", "hh_sparkle_fx", },
        ["hit_fn"] = function(inst, attacker, atk_type)
            doHealthDamage(inst, attacker, -5, atk_type)
        end,
    },
    ["poison"] = {
        ["color"] = { 101 / 255, 255 / 255, 0 / 255, 1 },
        ["lz_fx"] = { "hh_turret_fx_poison", "hh_sparkle_fx", },
        ["hit_fn"] = function(inst, attacker, atk_type)
            doHealthDamage(inst, attacker, -5, atk_type)
        end,
    },
}
----
---炮塔技能
---
local function bossProjectLaunch()

end

local function bossProjectHit(inst, attacker)
    if inst then
        local x, y, z = inst["Transform"]:GetWorldPosition()
        local scorch = SpawnPrefab("fused_shadeling_bomb_scorch")
        if scorch then
            scorch["Transform"]:SetPosition(x, 0, z)
            scorch["Transform"]:SetScale(0.9, 0.9, 0.9)
        end
        if inst["hh_atk_type"] and atk_type_config[inst["hh_atk_type"]] then
            local hh_config = atk_type_config[inst["hh_atk_type"]]
            if hh_config["hit_fn"] then
                hh_config["hit_fn"](inst, attacker, inst["hh_atk_type"])
            end
            HH_UTILS:SpawnExplodeFx(inst, hh_config["color"])
        end
        inst:Remove()
    end
end
----
---处理炮塔函数
---
local function handleTurretTask(inst, task_name, task_cd_name, attack_type)
    local cd_name = task_cd_name .. "_cd"
    local task_name_bool = task_name .. "_bool"
    --抛射物次数
    local attack_num = 5
    --任务间隔
    local max_cd_num = 15
    --奔跑状态偏移
    local offset_num = 4
    inst[task_name_bool] = false
    inst[cd_name] = 0--初始cd为0
    --先清空原任务
    HH_UTILS:HHKillTask(inst, task_name)
    inst[task_name] = inst:DoPeriodicTask(1.5, function()
        if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "combat")
                and inst["components"]["combat"]["target"]
        then
            if HH_UTILS:IsHHType(inst[cd_name], "number") then
                if inst[cd_name] > max_cd_num then
                    --print("刷新cd")
                    inst[cd_name] = 0
                    return
                elseif inst[cd_name] > attack_num then
                    --print("进入cd")
                    inst[cd_name] = inst[cd_name] + 1
                    return
                else
                    inst[cd_name] = inst[cd_name] + 1
                    local hh_is_run = false
                    --处理抛射物
                    local attack_target = inst["components"]["combat"]["target"]
                    if not attack_target["Transform"] then
                        --print("没有Transform")
                        return
                    end
                    --炮塔增加范围 防止地图炮
                    local pos_x, pos_y, pos_z = inst["Transform"]:GetWorldPosition()
                    local target_x, target_y, target_z = attack_target["Transform"]:GetWorldPosition()
                    local hh_distance = HH_UTILS:GetDistance(pos_x, pos_z, target_x, target_z)
                    if math["abs"](hh_distance) > 30 then
                        --print("超出30码范围 炮塔跳过")
                        return
                    end
                    --是否处于奔跑状态
                    if attack_target["sg"] and attack_target["sg"]:HasStateTag("running") then
                        hh_is_run = true
                    end
                    --y轴设置为0 防止y轴变化有问题
                    if hh_is_run then
                        local run_angle = attack_target["Transform"]:GetRotation()
                        --print("角度:", run_angle)
                        if run_angle < 0 then
                            run_angle = run_angle + 360
                        end
                        target_x = target_x + offset_num * math["cos"](-run_angle * DEGREES)
                        target_z = target_z + offset_num * math["sin"](-run_angle * DEGREES)
                    end

                    local hh_fx = SpawnPrefab("hh_project_fx")
                    if hh_fx and hh_fx["Transform"] then
                        hh_fx["Transform"]:SetPosition(pos_x, 0, pos_z)
                        hh_fx["hh_atk_type"] = attack_type
                        local add_color = { 0, 0 / 255, 100 / 255, 0 / 255 }
                        local lz_fx_list = { "hh_sparkle_fx" }
                        if attack_type and atk_type_config[attack_type] and atk_type_config[attack_type]["color"] then
                            add_color = atk_type_config[attack_type]["color"]
                            if atk_type_config[attack_type]["lz_fx"] then
                                lz_fx_list = atk_type_config[attack_type]["lz_fx"]
                            end
                        end
                        hh_fx:AddComponent("hh_project")
                        hh_fx["components"]["hh_project"]:Throw(inst, Vector3(target_x, 0, target_z), 1)
                        hh_fx["components"]["hh_project"]:SetHitFn(bossProjectHit)
                        --增加粒子特效
                        for a, b in ipairs(lz_fx_list) do
                            hh_fx["hh_lz_" .. a] = hh_fx:SpawnChild(b)
                        end
                    end
                    HH_UTILS:SpawnIndicatorFx(Vector3(target_x, 0, target_z), 2, { 255 / 255, 11 / 255, 0 / 255, 1 })
                end
            end
        else
            --print("未查询到目标")
            --初始化cd
            inst[cd_name] = 0
        end
    end)
end
local HH_CONFIG = {
    ["common_monster"] = {
        ["addMaxHealthNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthNum"], ["only_one"] = false,
            ["rangeValue"] = { ["min"] = 100, ["max"] = 500, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthNum", value)
                    --推个时间 及时同步血量上限
                    inst:PushEvent("hh_monster_buff_health")
                end
            end,
            --死亡触发
            ["end_fn"] = function(inst, value)
            end,
        },
        ["addMaxHealthPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthPercent"],
            ["rangeValue"] = { ["min"] = 50, ["max"] = 100, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthPercent", value)
                    inst:PushEvent("hh_monster_buff_health")
                end
            end,
        },
        ["addComDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 50, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", value)
                end
            end,
        },
        ["addComDamageNum1"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = { ["min"] = 15, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", value)
                end
            end,
        },
        ["addComDamageNum2"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = { ["min"] = 15, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", value)
                end
            end,
        },
        ["addComDamageNum3"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = { ["min"] = 15, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", value)
                end
            end,
        },
        ["addComDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamagePercent"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 50, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamagePercent", value)
                end
            end,
        },
        ["atkAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkAddPoison"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddPoison", value)
                end
            end,
        },
        ["hitAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddPoison"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddPoison", value)
                end
            end,
        },
        ["atkChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceAddFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 5, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddFreeze", value)
                end
            end,
        },
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 5, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", value)
                end
            end,
        },
        ["atkChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceReduceSpeed"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceReduceSpeed", value)
                end
            end,
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", value)
                end
            end,
        },
        ["addSpeedPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSpeedPercent"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addSpeedPercent", value)
                end
            end,
        },
        ["atkBlood"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkBlood"],
            ["rangeValue"] = { ["min"] = 3, ["max"] = 5, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkBlood", value)
                end
            end,
        },
        ["addCriticalHitRate"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addCriticalHitRate"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("criticalHitRate", value)
                    inst["components"]["hh_monster"]:AddEffectValueByKey("criticalHitEffect", 50)
                end
            end,
        },
        ["addReduceAttackedDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReduceAttackedDamage"],
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceAttackedDamage", value)
                end
            end,
        },
        ["addReboundDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReboundDamageNum"],
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reboundDamageNum", value)
                end
            end,
        },
        ["addDayDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addDayDamage"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("sunlightStrike", value)
                end
            end,
        },
        ["addDuskDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addDuskDamage"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("afterglowStrike", value)
                end
            end,
        },
        ["addNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addNightDamage"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("nightMenace", value)
                end
            end,
        },
        ["addHealth3sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth3sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 2, ["max"] = 5, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:IsHHType(value, "number") then
                    return
                end
                HH_UTILS:HHKillTask(inst, "addHealth3sNumTask")
                inst["addHealth3sNumTask"] = inst:DoPeriodicTask(3, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addHealth5sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth5sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:IsHHType(value, "number") then
                    return
                end
                HH_UTILS:HHKillTask(inst, "addHealth5sNumTask")
                inst["addHealth5sNumTask"] = inst:DoPeriodicTask(5, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addHealth10sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth10sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                HH_UTILS:HHKillTask(inst, "addHealth10sNumTask")
                inst["addHealth10sNumTask"] = inst:DoPeriodicTask(10, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addTargetDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addTargetDamage"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 5, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addTargetDamage", value)
                end
            end,
        },
        --过冷过热
        ["hitAddCold"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddCold"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 5, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addColdBuffValue", value)
                end
            end,
        },
        ["hitAddHot"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddHot"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 5, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addHotBuffValue", value)
                end
            end,
        },
        --特殊时段减伤
        ["reduceNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceNightDamage"],
            ["rangeValue"] = { ["min"] = 8, ["max"] = 16, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceNightDamage", value)
                end
            end,
        },
        ["reduceSunlightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceSunlightDamage"],
            ["rangeValue"] = { ["min"] = 8, ["max"] = 16, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceSunlightDamage", value)
                end
            end,
        },
        ["reduceAfterglowDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceAfterglowDamage"],
            ["rangeValue"] = { ["min"] = 8, ["max"] = 16, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceAfterglowDamage", value)
                end
            end,
        },
        --护甲易损
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", value)
                end
            end,
        },
        ["reducePercentDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reducePercentDamage"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reducePercentDamage", value)
                end
            end,
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"], ["only_one"] = true,
            ["check_fn"] = function(inst)
                return inst["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end,
        },
    },
    ["elite_monster"] = {
        ["addMaxHealthNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthNum"], ["only_one"] = false,
            ["rangeValue"] = { ["min"] = 500, ["max"] = 1000, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthNum", value)
                    --推个时间 及时同步血量上限
                    inst:PushEvent("hh_monster_buff_health")
                end
            end,
        },
        ["addMaxHealthPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthPercent"],
            ["rangeValue"] = { ["min"] = 100, ["max"] = 200, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthPercent", value)
                    inst:PushEvent("hh_monster_buff_health")
                end
            end,
        },
        ["addSpeedPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSpeedPercent"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 35, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addSpeedPercent", value)
                end
            end,
        },
        ["addComDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = { ["min"] = 50, ["max"] = 100, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", value)
                end
            end,
        },
        ["addComDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamagePercent"],
            ["rangeValue"] = { ["min"] = 30, ["max"] = 70, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamagePercent", value)
                end
            end,
        },
        ["atkAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkAddPoison"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 8, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddPoison", value)
                end
            end,
        },
        ["hitAddPoison"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddPoison"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 8, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddPoison", value)
                end
            end,
        },
        ["atkChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceAddFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddFreeze", value)
                end
            end,
        },
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", value)
                end
            end,
        },
        ["atkChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceReduceSpeed"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 20, ["max"] = 50, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceReduceSpeed", value)
                end
            end,
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 20, ["max"] = 50, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", value)
                end
            end,
        },
        ["addSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSuppressAddHealth"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addSuppressAddHealth", value)
                end
            end,
        },
        ["hitSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitSuppressAddHealth"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitSuppressAddHealth", value)
                end
            end,
        },
        ["atkBlood"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkBlood"],
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkBlood", value)
                end
            end,
        },
        ["addCriticalHitRate"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addCriticalHitRate"],
            ["rangeValue"] = { ["min"] = 20, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("criticalHitRate", value)
                    inst["components"]["hh_monster"]:AddEffectValueByKey("criticalHitEffect", 50)
                end
            end,
        },
        ["addReduceAttackedDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReduceAttackedDamage"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceAttackedDamage", value)
                end
            end,
        },
        ["addReboundDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReboundDamageNum"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reboundDamageNum", value)
                end
            end,
        },
        ["reboundDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reboundDamagePercent"],
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reboundDamagePercent", value)
                end
            end,
        },
        ["addHealth3sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth3sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:IsHHType(value, "number") then
                    return
                end
                HH_UTILS:HHKillTask(inst, "addHealth3sNumTask")
                inst["addHealth3sNumTask"] = inst:DoPeriodicTask(3, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addHealth5sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth5sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 20, ["max"] = 40, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:IsHHType(value, "number") then
                    return
                end
                HH_UTILS:HHKillTask(inst, "addHealth5sNumTask")
                inst["addHealth5sNumTask"] = inst:DoPeriodicTask(5, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addHealth10sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth10sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 30, ["max"] = 70, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                HH_UTILS:HHKillTask(inst, "addHealth10sNumTask")
                inst["addHealth10sNumTask"] = inst:DoPeriodicTask(10, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addTargetDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addTargetDamage"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addTargetDamage", value)
                end
            end,
        },
        ["immuneFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("immuneFreeze", 1)
                end
            end,
        },
        ["hitAddMoisture"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddMoisture"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitAddMoisture", value)
                end
            end,
        },

        ["addHealthPercent03"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent03"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                local _task_name = "addHealthPercent10Task"
                HH_UTILS:HHKillTask(inst, _task_name)
                inst[_task_name] = inst:DoPeriodicTask(3, function()
                    if HH_UTILS:NotIsDead(inst) then
                        local max_health = inst["components"]["health"]["maxhealth"]
                        inst["components"]["health"]:DoDelta(value * max_health / 100)
                    end
                end)
            end,
        },
        ["addHealthPercent05"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent05"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 5, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                local _task_name = "addHealthPercent05Task"
                HH_UTILS:HHKillTask(inst, _task_name)
                inst[_task_name] = inst:DoPeriodicTask(5, function()
                    if HH_UTILS:NotIsDead(inst) then
                        local max_health = inst["components"]["health"]["maxhealth"]
                        inst["components"]["health"]:DoDelta(value * max_health / 100)
                    end
                end)
            end,
        },
        ["addHealthPercent10"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent10"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                local _task_name = "addHealthPercent10Task"
                HH_UTILS:HHKillTask(inst, _task_name)
                inst[_task_name] = inst:DoPeriodicTask(10, function()
                    if HH_UTILS:NotIsDead(inst) then
                        local max_health = inst["components"]["health"]["maxhealth"]
                        inst["components"]["health"]:DoDelta(value * max_health / 100)
                    end
                end)
            end,
        },

        ["hitAddCold"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddCold"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addColdBuffValue", value)
                end
            end,
        },
        ["hitAddHot"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddHot"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addHotBuffValue", value)
                end
            end,
        },

        ["reduceNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceNightDamage"],
            ["rangeValue"] = { ["min"] = 15, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceNightDamage", value)
                end
            end,
        },
        ["reduceSunlightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceSunlightDamage"],
            ["rangeValue"] = { ["min"] = 15, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceSunlightDamage", value)
                end
            end,
        },
        ["reduceAfterglowDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceAfterglowDamage"],
            ["rangeValue"] = { ["min"] = 15, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceAfterglowDamage", value)
                end
            end,
        },
        --护甲易损
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 8, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", value)
                end
            end,
        },
        ["reducePercentDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reducePercentDamage"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 15, ["max"] = 30, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reducePercentDamage", value)
                end
            end,
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"], ["only_one"] = true,
            ["check_fn"] = function(inst)
                return inst["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end,
        },
    },
    ["boss_monster"] = {

        ["addMaxHealthNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthNum"], ["only_one"] = false,
            ["rangeValue"] = { ["min"] = 2000, ["max"] = 3000, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthNum", value)
                    --推个时间 及时同步血量上限
                    inst:PushEvent("hh_monster_buff_health")
                end
            end,
        },
        ["addMaxHealthPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addMaxHealthPercent"],
            ["rangeValue"] = { ["min"] = 100, ["max"] = 200, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addMaxHealthPercent", value)
                    inst:PushEvent("hh_monster_buff_health")
                end
            end,
        },
        ["addSpeedPercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSpeedPercent"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 50, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addSpeedPercent", value)
                end
            end,
        },
        ["addComDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamageNum"],
            ["rangeValue"] = { ["min"] = 50, ["max"] = 100, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamageNum", value)
                end
            end,
        },
        ["addComDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addComDamagePercent"],
            ["rangeValue"] = { ["min"] = 70, ["max"] = 120, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addComDamagePercent", value)
                end
            end,
        },
        --["atkAddPoison"] = {
        --    ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkAddPoison"], ["only_one"] = true,
        --    ["rangeValue"] = { ["min"] = 20, ["max"] = 35, },
        --    ["start_fn"] = function(inst, value)
        --        if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
        --            inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddPoison", value)
        --        end
        --    end,
        --},
        --["hitAddPoison"] = {
        --    ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddPoison"], ["only_one"] = true,
        --    ["rangeValue"] = { ["min"] = 20, ["max"] = 35, },
        --    ["start_fn"] = function(inst, value)
        --        if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
        --            inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddPoison", value)
        --        end
        --    end,
        --},
        ["atkChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceAddFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 20, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceAddFreeze", value)
                end
            end,
        },
        ["hitChanceAddFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceAddFreeze"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 20, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceAddFreeze", value)
                end
            end,
        },
        ["atkChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkChanceReduceSpeed"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 50, ["max"] = 70, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkChanceReduceSpeed", value)
                end
            end,
        },
        ["hitChanceReduceSpeed"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitChanceReduceSpeed"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 50, ["max"] = 70, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitChanceReduceSpeed", value)
                end
            end,
        },
        ["addSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addSuppressAddHealth"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 50, ["max"] = 70, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("addSuppressAddHealth", value)
                end
            end,
        },
        ["hitSuppressAddHealth"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitSuppressAddHealth"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 50, ["max"] = 70, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitSuppressAddHealth", value)
                end
            end,
        },
        ["atkBlood"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkBlood"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 25, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkBlood", value)
                end
            end,
        },
        ["addCriticalHitRate"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["bossAddCriticalHitRate"],
            ["rangeValue"] = { ["min"] = 30, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("criticalHitRate", value)
                    inst["components"]["hh_monster"]:AddEffectValueByKey("criticalHitEffect", 120)
                end
            end,
        },
        ["addReduceAttackedDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReduceAttackedDamage"],
            ["rangeValue"] = { ["min"] = 20, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceAttackedDamage", value)
                end
            end,
        },
        ["addReboundDamageNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addReboundDamageNum"],
            ["rangeValue"] = { ["min"] = 30, ["max"] = 40, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reboundDamageNum", value)
                end
            end,
        },
        ["reboundDamagePercent"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reboundDamagePercent"],
            ["rangeValue"] = { ["min"] = 10, ["max"] = 25, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reboundDamagePercent", value)
                end
            end,
        },
        ["iceTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["iceTurret"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    handleTurretTask(inst, "iceTurretTask", "iceTurretCdTask", "ice")
                end
            end,
        },
        ["fireTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["fireTurret"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    handleTurretTask(inst, "fireTurretTask", "fireTurretCdTask", "fire")
                end
            end,
        },
        ["poisonTurret"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["poisonTurret"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    handleTurretTask(inst, "poisonTurretTask", "poisonTurretCdTask", "poison")
                end
            end,
        },
        ["iceLaser"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["iceLaser"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("iceLaser", 1)
                end
            end,
        },
        ["immuneFreeze"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneFreeze"], ["only_one"] = true,
            ["check_fn"] = function(inst)
                --去掉蚁狮
                if inst and inst["prefab"] == "antlion" then
                    return false
                end
                return true
            end,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("immuneFreeze", 1)
                end
            end,
        },
        ["addHealth3sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth3sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 100, ["max"] = 200, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:IsHHType(value, "number") then
                    return
                end
                HH_UTILS:HHKillTask(inst, "addHealth3sNumTask")
                inst["addHealth3sNumTask"] = inst:DoPeriodicTask(3, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addHealth5sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth5sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 150, ["max"] = 300, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                if not HH_UTILS:NotIsDead(inst) or not HH_UTILS:IsHHType(value, "number") then
                    return
                end
                HH_UTILS:HHKillTask(inst, "addHealth5sNumTask")
                inst["addHealth5sNumTask"] = inst:DoPeriodicTask(5, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["addHealth10sNum"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealth10sNum"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 300, ["max"] = 400, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                HH_UTILS:HHKillTask(inst, "addHealth10sNumTask")
                inst["addHealth10sNumTask"] = inst:DoPeriodicTask(10, function()
                    if HH_UTILS:NotIsDead(inst) then
                        inst["components"]["health"]:DoDelta(value)
                    end
                end)
            end,
        },
        ["noHitDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["noHitDamage"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("replaceDamageChance", value)
                end
            end,
        },
        ["hitAddMoisture"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["hitAddMoisture"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 10, ["max"] = 20, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("hitAddMoisture", value)
                end
            end,
        },
        ["addHealthPercent03"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent03"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                local _task_name = "addHealthPercent10Task"
                HH_UTILS:HHKillTask(inst, _task_name)
                inst[_task_name] = inst:DoPeriodicTask(3, function()
                    if HH_UTILS:NotIsDead(inst) then
                        local max_health = inst["components"]["health"]["maxhealth"]
                        inst["components"]["health"]:DoDelta(value * max_health / 100)
                    end
                end)
            end,
        },
        ["addHealthPercent05"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent05"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 3, ["max"] = 5, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                local _task_name = "addHealthPercent05Task"
                HH_UTILS:HHKillTask(inst, _task_name)
                inst[_task_name] = inst:DoPeriodicTask(5, function()
                    if HH_UTILS:NotIsDead(inst) then
                        local max_health = inst["components"]["health"]["maxhealth"]
                        inst["components"]["health"]:DoDelta(value * max_health / 100)
                    end
                end)
            end,
        },
        ["addHealthPercent10"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["addHealthPercent10"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 5, ["max"] = 10, },
            ["check_fn"] = checkReplyBlack,
            ["start_fn"] = function(inst, value)
                local _task_name = "addHealthPercent10Task"
                HH_UTILS:HHKillTask(inst, _task_name)
                inst[_task_name] = inst:DoPeriodicTask(10, function()
                    if HH_UTILS:NotIsDead(inst) then
                        local max_health = inst["components"]["health"]["maxhealth"]
                        inst["components"]["health"]:DoDelta(value * max_health / 100)
                    end
                end)
            end,
        },

        ["reduceNightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceNightDamage"],
            ["rangeValue"] = { ["min"] = 30, ["max"] = 60, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceNightDamage", value)
                end
            end,
        },
        ["reduceSunlightDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceSunlightDamage"],
            ["rangeValue"] = { ["min"] = 30, ["max"] = 60, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceSunlightDamage", value)
                end
            end,
        },
        ["reduceAfterglowDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reduceAfterglowDamage"],
            ["rangeValue"] = { ["min"] = 30, ["max"] = 60, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reduceAfterglowDamage", value)
                end
            end,
        },
        --护甲易损
        ["atkReduceArmor"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["atkReduceArmor"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 20, ["max"] = 35, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("atkAddArmorReduceBuff", value)
                end
            end,
        },
        ["reducePercentDamage"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["reducePercentDamage"], ["only_one"] = true,
            ["rangeValue"] = { ["min"] = 25, ["max"] = 45, },
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("reducePercentDamage", value)
                end
            end,
        },
        ["immuneTearing"] = {
            ["name"] = TUNING["HH_FORMAT_CONFIG"]["MONSTER_CONFIG"]["immuneTearing"], ["only_one"] = true,
            ["check_fn"] = function(inst)
                return inst["hh_is_treasure"] ~= nil
            end,
            ["start_fn"] = function(inst, value)
                if HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(inst, "hh_monster") then
                    inst["components"]["hh_monster"]:AddEffectValueByKey("immuneTearing", 1)
                end
            end,
        },
        --["deerClopIceLance"] = {
        --    ["name"] = "巨鹿的支援", ["only_one"] = true,
        --    ["rangeValue"] = { ["min"] = 1, ["max"] = 2, },
        --    ["start_fn"] = function(inst, value)
        --        HH_UTILS:HHKillTask(inst, "deerClopIceLanceTask")
        --        inst["deerClopIceLanceTask"] = inst:DoPeriodicTask(5, function()
        --            if HH_UTILS:HasComponents(inst, "combat")
        --                    and inst["components"]["combat"]["target"]
        --            then
        --                local hh_target = inst["components"]["combat"]["target"]
        --                if hh_target["Transform"] then
        --                    HH_UTILS:SpawnDeerClopFx(inst, hh_target)
        --                end
        --            end
        --        end)
        --    end,
        --},
    },


}
return HH_CONFIG
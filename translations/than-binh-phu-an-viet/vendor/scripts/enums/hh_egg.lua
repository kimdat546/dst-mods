local HH_UTILS = require("utils/hh_utils")

local function spawnGifFn(nest_inst, table_config)
    if not (HH_UTILS:IsHHType(table_config, "table") and #table_config > 0) then
        return
    end
    local math_num = math["random"](1, #table_config)
    local gif_table = table_config[math_num]
    if not HH_UTILS:IsHHType(gif_table, "table") then
        return
    end
    for i, v in pairs(gif_table) do
        if HH_UTILS:IsHHType(i, "string") and HH_UTILS:IsHHType(v, "number") then
            HH_UTILS:SpawnLaunchItem(nest_inst, i, v)
        end
    end
end
local function spawnStarEquip(nest_inst, nest_star_num, is_fixed)
    if not (nest_inst and nest_inst["Transform"]) then
        return
    end
    local x, y, z = nest_inst["Transform"]:GetWorldPosition()
    local hh_spawn_item = SpawnPrefab("hh_hat_star")
    if hh_spawn_item and hh_spawn_item["Transform"] then
        if HH_UTILS:IsHHType(nest_star_num, "number") and nest_star_num > 0
                and HH_UTILS:HasComponents(hh_spawn_item, "hh_hat_star")
        then
            if is_fixed then
                hh_spawn_item["components"]["hh_hat_star"]:SetFixedUse(true)
            end
            hh_spawn_item["components"]["hh_hat_star"]:SetStarNum(nest_star_num)
        end
        hh_spawn_item["Transform"]:SetPosition(x, 1.5, z)
        local angle = math["random"](1, 360)
        if hh_spawn_item["Physics"] then
            local speed = math["random"]() * 4 + 2
            angle = (angle + math["random"]() * 60 - 30) * DEGREES
            hh_spawn_item["Physics"]:SetVel(speed * math["cos"](angle), 5, speed * math["sin"](angle))
        end
    end
end
local function spawnStarBoss(nest_inst)
    local math_silver_star = math["random"](1, 10)
    if math_silver_star == 1 then
        --生成星级装备
        local spawn_star_num = math["random"](5, 8)
        spawnStarEquip(nest_inst, spawn_star_num, false)
    end
end
local function spawnStarSilver(nest_inst)
    local math_silver_star = math["random"](1, 10)
    if math_silver_star == 1 then
        --生成星级装备
        local spawn_star_num = math["random"](1, 6)
        spawnStarEquip(nest_inst, spawn_star_num, false)
    end
end

local function spawnStarSky(nest_inst)
    local math_silver_star = math["random"](1, 10)
    if math_silver_star == 1 then
        --生成星级装备
        local spawn_star_num = 10
        spawnStarEquip(nest_inst, spawn_star_num, true)
    end
end
local function launchEquip(test_equip)
    local angle = math["random"](1, 360)
    if test_equip["Physics"] then
        local speed = math["random"]() * 4 + 2
        angle = (angle + math["random"]() * 60 - 30) * DEGREES
        test_equip["Physics"]:SetVel(speed * math["cos"](angle), 5, speed * math["sin"](angle))
    end
end
local function spawnEggEquip(nest_inst, equip_id, affix_data, net_str)
    if not (nest_inst and nest_inst["Transform"]
            and HH_UTILS:IsHHType(equip_id, "string")) then
        return
    end
    local x, y, z = nest_inst["Transform"]:GetWorldPosition()
    local test_equip = SpawnPrefab(equip_id)
    if test_equip and HH_UTILS:HasComponents(test_equip, "hh_equip") then
        local new_equip_com = test_equip["components"]["hh_equip"]
        if HH_UTILS:IsHHType(affix_data, "table") then
            for i, v in ipairs(affix_data) do
                if HH_UTILS:IsHHType(v, "table") and HH_UTILS:IsHHType(v["id"], "string") then
                    local affix_id = v["id"]
                    local affix_value = tonumber(v["value"]) or nil
                    new_equip_com:AddEquipBuff(affix_id, affix_value)
                end
            end

        end
        test_equip["Transform"]:SetPosition(x, 1.5, z)
        launchEquip(test_equip)
        if net_str then
            HH_UTILS:NetSay(tostring(net_str))
        end
    end
end
----
---亮茄剑
---
local function spawnBestWeapon(nest_inst)
    spawnEggEquip(nest_inst, "sword_lunarplant", {
        {
            ["id"] = "special_bhtg",
            ["id"] = "special_true_damage",
        }
    })
end
----
---亮茄头
---
local function spawnBestHat(nest_inst)
    spawnEggEquip(nest_inst, "lunarplanthat", {
        {
            ["id"] = "special_sgsy",
        }
    })
end
----
---亮茄甲
---
local function spawnBestArmor(nest_inst)
    spawnEggEquip(nest_inst, "armor_lunarplant", {
        {
            ["id"] = "special_zqrf",
            ["id"] = "armor_immune_amount",
        }
    })
end
----
---村里最好的长矛
---
local function spawnBestSpear(nest_inst)
    --词条突破（指定数值-拆出来的词条会变成原有数值）
    local affix_list = {
        --普通暴击
        { ["id"] = "add_critical_hit_rate", ["value"] = 60, },
        --普通暴击效果
        { ["id"] = "add_critical_hit_effect", ["value"] = 300, },
        --普通增伤
        { ["id"] = "add_com_damage", ["value"] = 100, },
        --双倍变五倍
        { ["id"] = "more_damage_20_200", ["value"] = 521, },

    }
    local random_index = math["random"](1, #affix_list)
    local spawn_affix = {}
    table["insert"](spawn_affix, affix_list[random_index])
    spawnEggEquip(nest_inst, "spear", spawn_affix, nil)
end
local BLACK_GIF = {
    {
        ["charcoal"] = 40, --木炭
    },
}
--普通蛋
local COMMON_GIF = {
    {
        ["cutgrass"] = 10, --草
        ["twigs"] = 10, --树枝
        ["log"] = 10, --木头
    },
    {
        ["cutreeds"] = 10, --芦苇
        ["petals"] = 10, --花瓣
        ["lightbulb"] = 10, --荧光果
    },
    {
        ["nightmarefuel"] = 5, --噩梦燃料
        ["livinglog"] = 5, --活木
    },
    {
        ["marblebean"] = 5, --大理石豆
        ["nitre"] = 10, --硝石
    },
    {
        ["rocks"] = 10, --石头
        ["flint"] = 10, --燧石
    },
    {
        ["gears"] = 1, --齿轮
    },
    {
        ["honeycomb"] = 1, --蜂巢
    },
    {
        ["saltrock"] = 10, --盐晶
    },
    {
        ["pigskin"] = 3, --猪皮
    },
    {
        ["beefalowool"] = 5, --牛毛
    },
    {
        ["manrabbit_tail"] = 3, --兔子毛
    },
    {
        ["silk"] = 10, --蜘蛛丝
        ["spidergland"] = 10, --蜘蛛腺体
    },
    {
        ["poop"] = 20, --便便
        ["spoiled_food"] = 20, --便便
    },
    {
        ["houndstooth"] = 5, --狗牙
    },
}

local MEDIUM_GIF = {
    {
        ["gears"] = 3, --齿轮
    },
    {
        ["redgem"] = 1, --红宝石
        ["bluegem"] = 1, --蓝宝石
    },
    {
        ["greengem"] = 1, --绿宝石
    },
    {
        ["purplegem"] = 2, --紫宝石
    },
    {
        ["orangegem"] = 1, --橙宝石
    },
    {
        ["yellowgem"] = 1, --黄宝石
    },
    {
        ["moonrocknugget"] = 5, --月岩
    },
    {
        ["moonglass"] = 5, --月亮碎片
    },
    {
        ["thulecite"] = 3, --铥矿
    },
}
local BOSS_EGG_GIF = {
    {
        ["thulecite"] = 10, --铥矿
    },
    {
        ["orangegem"] = 3, --橙宝石
        ["yellowgem"] = 3, --黄宝石
        ["purplegem"] = 5, --紫宝石
    },
    {
        ["greengem"] = 3, --绿宝石
        ["redgem"] = 4, --红宝石
        ["bluegem"] = 4, --蓝宝石
    },
    {
        ["horrorfuel"] = 3, --纯粹恐惧
    },
    {
        ["purebrilliance"] = 3, --纯粹辉煌
    },
    {
        ["lunarplant_husk"] = 10, --亮茄碎片
    },
    {
        ["dragon_scales"] = 1, --龙鳞皮
    },
    {
        ["shroom_skin"] = 1, --蘑菇皮
    },
    {
        ["deerclops_eyeball"] = 1, --巨鹿眼球
    },
    {
        ["bearger_fur"] = 1, --熊皮
    },
    {
        ["goose_feather"] = 5, --鸭毛
    },
    {
        ["malbatross_feather"] = 5, --邪天翁毛
    },
    {
        ["townportaltalisman"] = 5, --沙之石
    },
}
-- 权重随机函数：key=方法名, value=权重值
local skyEggWeightFns = {
    {
        ["weight"] = 50,
        ["fn"] = spawnStarSky,
    },
    {
        ["weight"] = 50,
        ["fn"] = spawnBestWeapon,
    },
    {
        ["weight"] = 50,
        ["fn"] = spawnBestHat,
    },
    {
        ["weight"] = 50,
        ["fn"] = spawnBestArmor,
    },
    {
        ["weight"] = 50,
        ["fn"] = spawnBestSpear,
    },
}
local com_egg_time = 480 * 2
local silver_egg_time = 480 * 3
local boss_egg_time = 480 * 5
local HH_EGG = {
    ["hh_egg_black"] = {
        ["time"] = com_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BLACK_GIF)
        end,
    },
    ["hh_egg_common"] = {
        ["time"] = com_egg_time,
        --nest_inst孵蛋巢实体
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, COMMON_GIF)
        end,
    },
    ["hh_egg_silver"] = {
        ["time"] = silver_egg_time,
        ["finish_fn"] = function(nest_inst)
            local math_silver = math["random"](1, 10)
            spawnStarSilver(nest_inst)
            if math_silver < 4 then
                spawnGifFn(nest_inst, COMMON_GIF)
                spawnGifFn(nest_inst, COMMON_GIF)
                spawnGifFn(nest_inst, COMMON_GIF)
            else
                spawnGifFn(nest_inst, MEDIUM_GIF)
            end
        end,
    },
    ["hh_egg_gold"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_cat_claw_orange"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_cat_claw_purple"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_cat_claw_green"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_cat_claw_blue"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_blue_star"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_green_black"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_purple_black"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_red_black"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_red_blue"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_yellow_green"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_figure_yellow_green_purple"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            spawnGifFn(nest_inst, BOSS_EGG_GIF)
            spawnStarBoss(nest_inst)
        end,
    },
    ["hh_egg_starry_sky"] = {
        ["time"] = boss_egg_time,
        ["finish_fn"] = function(nest_inst)
            -- 执行权重随机
            local total_weight = 0
            for _, v in ipairs(skyEggWeightFns) do
                if HH_UTILS:IsHHType(v["weight"], "number") then
                    total_weight = total_weight + v["weight"]
                end
            end
            local rnd = math["random"](total_weight)
            local current = 0
            for _, v in ipairs(skyEggWeightFns) do
                if HH_UTILS:IsHHType(v["weight"], "number") then
                    current = current + v["weight"]
                    if rnd <= current then
                        if HH_UTILS:IsHHType(v["fn"], "function") then
                            v["fn"](nest_inst) -- 执行抽到的方法
                        end
                        break
                    end
                end
            end
        end,
    },


}
return
{
    ["EGG"] = HH_EGG,
}
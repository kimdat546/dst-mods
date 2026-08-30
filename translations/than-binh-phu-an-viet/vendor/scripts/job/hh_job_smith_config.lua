----
---铁匠相关的词条 装备 职业专属 图纸等等
---
local HH_UTILS = require("utils/hh_utils")
--锻造词条
local HH_EQUIP_EFFECT = {
    ["level_up_damage_goldnugget"] = {
        ["name"] = "可升级-",
        ["desc"] = "使用金块提升攻击力",
        ["check_fn"] = function(inst, player)

        end,
        ["start_fn"] = function(inst, player)

        end,
        ["load_fn"]  = function(inst, data)

        end,
        ["save_fn"] = function(inst, data)

        end,

    },
}
--玩家能力-解锁可锻造的词条-部分同一类别按等级解锁上级属性
local PLAYER_ABILITY = {
    ["level_up_damage_goldnugget"] = { ["name"] = "武器升级组件-金块", },

}
--装备贴图
local EQUIP_IMAGE = {
    ["hambat"] = {
        ["name"] = "火腿棒", ["slot"] = EQUIPSLOTS["HANDS"], --装备类型
        ["tex"] = "", ["xml"] = "",
        ["equip_fn"] = function(inst, player)
        end,
        ["un_equip_fn"] = function(inst, player)
        end,
    },
}
--装备命名列表 根据等级获取索引进行随机
local EFFECT_NAME = {
    {
        "铁铸的", "铜锻的", "石刻的", "木雕的",
        "皮革的", "棉布的", "铁片的", "铅制的",
        "锡焊的", "铜环的", "粗铁的", "铁屑的",
        "青铜的", "铸铁的", "锻钢的", "碳钢的",
        "铅灰的", "碎岩的", "抛光的", "刀痕的",
        "崩裂的", "坑洼的", "裂纹的", "铁砧的",
        "粗糙的", "朴素的", "毛糙的", "笨重的",
        "粗犷的", "拙劣的", "结实的", "锈迹的",
        "拼补的", "焦黑的", "灰暗的", "钝重的",
    },
    {
        "华丽的", "精密的", "金纹的", "晶耀的",
        "淬火的", "精雕的", "雕花的", "锻纹的",
        "瑰银的", "星钢的", "暗金的", "霜纹的",
        "星芒的", "流焰的", "晨曦的", "凛霜的",
    },
    {

    },
    {

    },
    { "" },
    --神匠师(隐藏职业)
    {
        "★",
        "★",
        "神匠淬火★", "名匠雕琢★", "天工匠心★",
        "匠魂凝华★", "精铸无瑕★", "炼魂火铸★",
        "锻火精魂★", "天匠传承★", "炼魂觉醒★",
        "淬火真魂★", "金工铭纹★", "凝魂刻印★",
        "淬炼之锋★", "铸魂震空★", "炎匠夺魄★",
        "寂匠冷焰★", "铸辉耀世★", "铭匠至尊★",
        "神纹永恒★", "圣匠之辉★",
    },
}
return {
    ["EFFECT"] = HH_EQUIP_EFFECT,
    ["ABILITY"] = PLAYER_ABILITY,
    ["IMAGE"] = EQUIP_IMAGE,
    ["NAMES"] = EFFECT_NAME,
}
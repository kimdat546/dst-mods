local HH_STRING = {}
local function addString(prefab_id, hh_name, hh_desc, hh_recipe_str)
    HH_STRING[prefab_id] = {
        ["name"] = hh_name,
        ["desc"] = hh_desc,
        ["recipe_str"] = hh_recipe_str,
    }
end
addString("hh_effect_stone", "特殊附魔石", "含有特殊的附魔词条", "含有特殊的附魔词条")
addString("hh_effect_tally", "普通附魔卷轴", "普通附魔卷轴", "普通附魔卷轴")
addString("hh_remove_stone", "洗蕴石", "洗掉装备的词条", "洗掉装备的词条")
addString("hh_knife_atk", "bbbb", "bbbb", "bbbb")
addString("hh_knife_atk_super", "vvvv\nvvvvvv", "vvvv", "vvvv")
addString("hh_sword_angry", "dddd", "dddd", "dddd")
addString("hh_sword_atk", "qqqq", "qqqq", "qqqq")
addString("hh_sword_atk_super", "rrrr", "rrrr", "rrrr")
addString("hh_red_spear", "hh_red_spear", "hh_red_spear", "hh_red_spear")
addString("hh_epee", "hh_epee", "hh_epee", "hh_epee")

addString("hh_true_damage", "hh_true_damage", "描述", "描述")
addString("hh_suit_build", "附魔合成台", "右键进行操作", "右键进行操作")
addString("hh_staff_dis", "拆除法杖", "拆解装备", "拆解装备")
addString("hh_essence", "水晶道具", "水晶道具", "水晶道具")
addString("hh_ui_container", "附魔容器", "附魔容器", "附魔容器")
addString("hh_forge_container", "套装容器", "套装容器", "套装容器")
addString("hh_staff_star", "星星法杖", "直上青天揽星辰", "直上青天揽星辰")
addString("hh_ice_knife", "冰刃", "攻击造成火焰沟壑", "火焰的威力")
--buff伤害描述
addString("hh_bramble_damage", "反甲词条", "反甲词条", "反甲词条")
addString("hh_turret_poison", "毒炮塔-流血", "毒炮塔-流血", "毒炮塔-流血")
addString("hh_poison", "中毒词条", "中毒词条", "中毒词条")
addString("hh_monster_kj", "恐惧词条", "恐惧词条", "恐惧词条")
addString("hh_turret", "炮塔", "炮塔", "炮塔")
addString("hh_turret_ice", "寒冰炮塔", "炮塔", "炮塔")
addString("hh_turret_fire", "火焰炮塔", "炮塔", "炮塔")
addString("hh_turret_poison", "剧毒炮塔", "炮塔", "炮塔")
addString("hh_treasure_tally_a", "寻宝卷轴", "寻宝卷轴", "寻宝卷轴")
addString("hh_treasure_tally_b", "寻宝卷轴", "寻宝卷轴", "寻宝卷轴")
addString("hh_treasure_tally_a_blueprint", "寻宝卷轴蓝图", "寻宝卷轴", "寻宝卷轴")
addString("hh_treasure_tally_b_blueprint", "寻宝卷轴蓝图", "寻宝卷轴", "寻宝卷轴")
for i, v in pairs(HH_STRING) do
    STRINGS["NAMES"][string["upper"](i)] = v["name"] or "未定义"
    STRINGS["RECIPE_DESC"][string["upper"](i)] = v["recipe_str"] or "未定义"
    STRINGS["CHARACTERS"]["GENERIC"]["DESCRIBE"][string["upper"](i)] = v["desc"] or "未定义"
end
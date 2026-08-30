local big_scale = 30--大
local medium_scale = 20--中
local small_scale = 15--小
local hh_red = { 255 / 255, 11 / 255, 0 / 255, 1 }
local hh_blue = { 0 / 255, 101 / 255, 255 / 255, 1 }
local hh_orange = { 255 / 255, 102 / 255, 0 / 255, 1 }
local hh_yellow = { 255 / 255, 242 / 255, 0 / 255, 1 }
local hh_green = { 101 / 255, 255 / 255, 0 / 255, 1 }
local hh_purple = { 143 / 255, 0 / 255, 255 / 255, 1 }
local hh_black = { 0, 0, 0, 1 }
local hh_white = { 1, 1, 1, 1 }
local hh_component_desc_list = {
    ["hh_01_name"] = { ["bool"] = false, ["name"] = "    ", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_yellow, },
    ["hh_01_guid"] = { ["bool"] = false, ["name"] = "guid:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_white, },
    ["hh_01_text"] = { ["bool"] = false, ["name"] = "描述:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_white, },
    ["hh_02_boss_equip"] = { ["bool"] = false, ["name"] = "星级:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 }, },
    ["hh_02_health"] = { ["bool"] = false, ["name"] = "血量:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s 免伤%s%%", ["str_color"] = { 70 / 255, 139 / 255, 101 / 255, 1 }, },
    ["hh_02_hunger"] = { ["bool"] = false, ["name"] = "饥饿:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s", ["str_color"] = { 70 / 255, 139 / 255, 101 / 255, 1 }, },
    ["hh_03_combat"] = { ["bool"] = false, ["name"] = "伤害:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s 范围:%s 系数:%s", ["str_color"] = { 194 / 255, 186 / 255, 132 / 255, 1 }, },
    ["hh_03_weapon"] = { ["bool"] = false, ["name"] = "武器:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s 范围:%s", ["str_color"] = { 127 / 255, 116 / 255, 255 / 255, 1 }, },
    ["hh_04_edible"] = { ["bool"] = false, ["name"] = "食用:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s 饱食:%s 精神:%s 血量:%s", ["str_color"] = { 255 / 255, 20 / 255, 147 / 255, 1 }, },
    ["hh_05_food_tag"] = { ["bool"] = false, ["name"] = "食物标签:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 210 / 255, 140 / 255, 210 / 255, 1 }, },
    ["hh_06_armor"] = { ["bool"] = false, ["name"] = "护甲:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 124 / 255, 162 / 255, 80 / 255, 1 }, },
    ["hh_07_finiteuses"] = { ["bool"] = false, ["name"] = "耐久:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s", ["str_color"] = { 190 / 255, 166 / 255, 174 / 255, 1 }, },
    ["hh_08_fueled"] = { ["bool"] = false, ["name"] = "燃料:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s", ["str_color"] = { 213 / 255, 199 / 255, 111 / 255, 1 }, },
    ["hh_09_tool"] = { ["bool"] = false, ["name"] = "工具:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 113 / 255, 140 / 255, 210 / 255, 1 }, },
    ["hh_10_stackable"] = { ["bool"] = false, ["name"] = "堆叠:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s", ["str_color"] = { 140 / 255, 140 / 255, 210 / 255, 1 }, },
    ["hh_11_naughty_value"] = { ["bool"] = false, ["name"] = "淘气值:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 210 / 255, 140 / 255, 210 / 255, 1 }, },
    ["hh_12_container"] = { ["bool"] = false, ["name"] = "容器:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s%s", ["str_color"] = { 113 / 255, 210 / 255, 113 / 255, 1 }, },
    ["hh_13_perishable"] = { ["bool"] = false, ["name"] = "距离腐烂:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s天", ["str_color"] = { 213 / 255, 113 / 255, 80 / 255, 1 }, },
    ["hh_14_unwrappable"] = { ["bool"] = false, ["name"] = "包裹:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 213 / 255, 113 / 255, 80 / 255, 1 }, },
    ["hh_15_stewer"] = { ["bool"] = false, ["name"] = "烹饪:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s 剩余:%s秒", ["str_color"] = { 213 / 255, 88 / 255, 80 / 255, 1 }, },
    ["hh_16_growable"] = { ["bool"] = false, ["name"] = "阶段:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s 下一阶段:%s天", ["str_color"] = { 80 / 255, 204 / 255, 46 / 255, 1 }, },
    ["hh_17_pickable"] = { ["bool"] = false, ["name"] = "成熟:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s天", ["str_color"] = { 80 / 255, 204 / 255, 46 / 255, 1 }, },
    ["hh_18_insulator"] = { ["bool"] = false, ["name"] = "绝缘:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 210 / 255, 181 / 255, 63 / 255, 1 }, },
    --["hh_19_healer"] = { ["bool"] = false, ["name"] = "治疗:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 210 / 255, 181 / 255, 63 / 255, 1 }, },
    ["hh_20_fishable"] = { ["bool"] = false, ["name"] = "可钓:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s次", ["str_color"] = hh_orange, },
    ["hh_21_follower"] = { ["bool"] = false, ["name"] = "主人:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s 时间:%s秒", ["str_color"] = hh_yellow, },
    --["hh_22_sanityaura"] = { ["bool"] = false, ["name"] = "理智光环:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/分", ["str_color"] = { 213 / 255, 88 / 255, 80 / 255, 1 }, },
    ["hh_23_equippable"] = { ["bool"] = false, ["name"] = "移速:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s%%", ["str_color"] = { 213 / 255, 88 / 255, 80 / 255, 1 }, },
    ["hh_24_tradable"] = { ["bool"] = false, ["name"] = "价值:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "金子:+%s,石头:+%s", ["str_color"] = hh_yellow, },
    --["hh_25_temperature"] = { ["bool"] = false, ["name"] = "温度:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s时间:%s秒", ["str_color"] = { 255 / 255, 41 / 255, 0 / 255, 1 }, },
    ["hh_26_childspawner"] = { ["bool"] = false, ["name"] = "生物:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s/%s", ["str_color"] = { 255 / 255, 0 / 255, 238 / 255, 1 }, },
    ["hh_27_domesticatable"] = { ["bool"] = false, ["name"] = "驯服:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 255 / 255, 0 / 255, 238 / 255, 1 }, },
    ["hh_28_dryer"] = { ["bool"] = false, ["name"] = "晾干:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 255 / 255, 0 / 255, 238 / 255, 1 }, },
    ["hh_29_farmplantstress"] = { ["bool"] = false, ["name"] = "作物:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s点压力", ["str_color"] = { 80 / 255, 204 / 255, 46 / 255, 1 }, },
    ["hh_30_cookable"] = { ["bool"] = false, ["name"] = "火烤:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 255 / 255, 0 / 255, 238 / 255, 1 }, },
    ["hh_31_locomotor"] = { ["bool"] = false, ["name"] = "移速:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "跑:%s 走:%s", ["str_color"] = hh_yellow, },
    ["hh_31_hh_tag"] = { ["bool"] = false, ["name"] = "特殊标签:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = { 210 / 255, 140 / 255, 210 / 255, 1 }, },
    ["hh_32_hh_gem"] = { ["bool"] = false, ["name"] = "宝石:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange }, --child_ui用于显示宝石之类的
    ["hh_32_hh_gem_check"] = { ["bool"] = false, ["name"] = "前置条件:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange }, --child_ui用于显示宝石之类的
    ["hh_32_hh_equip"] = { ["bool"] = false, ["name"] = "附魔:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange }, --child_ui用于显示宝石之类的
    ["hh_32_hh_equip_star"] = { ["bool"] = false, ["name"] = "星级:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_green },
    ["hh_32_hh_equip_suit"] = { ["bool"] = false, ["name"] = "套装:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_green },
    ["hh_32_hh_monster"] = { ["bool"] = false, ["name"] = "强化:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange }, --child_ui用于显示宝石之类的
    ["hh_33_hh_follow"] = { ["bool"] = false, ["name"] = "主仆强化:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_red }, --child_ui用于显示宝石之类的
    ["hh_32_hh_save"] = { ["bool"] = false, ["name"] = "归属:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s-%s", ["str_color"] = hh_orange },
    ["hh_32_hh_player"] = { ["bool"] = false, ["name"] = "属性:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange }, --child_ui用于显示宝石之类的
    ["hh_33_hh_level"] = { ["bool"] = false, ["name"] = "等级:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_34_boss_equip"] = { ["bool"] = false, ["name"] = "绑定:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_99_special_01"] = { ["bool"] = false, ["name"] = "特殊:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_99_special_02"] = { ["bool"] = false, ["name"] = "特殊:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_99_special_03"] = { ["bool"] = false, ["name"] = "特殊:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_99_special_04"] = { ["bool"] = false, ["name"] = "特殊:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_99_painter"] = { ["bool"] = false, ["name"] = "画师:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_orange },
    ["hh_99_prefab"] = { ["bool"] = false, ["name"] = "代码:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_yellow, },
    --["hh_99_image"] = { ["bool"] = false, ["name"] = "图标:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_yellow, },
    ["hh_99_idle"] = { ["bool"] = false, ["name"] = "动画:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s %s %s", ["str_color"] = hh_orange, },
    ["hh_99_path"] = { ["bool"] = false, ["name"] = "路径:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_red, },
    ["hh_99_exception"] = { ["bool"] = false, ["name"] = "异常:", ["name_color"] = hh_white, ["str"] = "", ["format"] = "%s", ["str_color"] = hh_red, },
}
return hh_component_desc_list

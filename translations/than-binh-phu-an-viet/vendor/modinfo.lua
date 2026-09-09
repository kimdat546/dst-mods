name = "【附魔-强化】"  ---mod名字
description = [[
装备附魔/生物强化
| 煎蛋牛牛牛牛牛牛牛牛牛牛牛牛牛牛牛牛煎蛋 |
]]  --mod描述
author = "宇宙超级霹雳闪电大煎蛋" --作者
version = "3.21" -- mod版本 上传mod需要两次的版本不一样

forumthread = ""

api_version = 10 --api版本

dst_compatible = true --兼容联机

dont_starve_compatible = false --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

all_clients_require_mod = true --所有人mod

icon_atlas = "modicon.xml" --mod图标
icon = "modicon.tex"

server_filter_tags = {  --服务器标签
    "hh_hh", "高冷恐龙爱上甜妹煎蛋", "史上无敌超级霹雳闪电暴风霸王龙",
}
local key_config = {
    { ["hover"] = "按键B打开强化容器", ["description"] = "B", ["data"] = 98, },
    { ["hover"] = "按键G打开强化容器", ["description"] = "G", ["data"] = 103, },
    { ["hover"] = "按键H打开强化容器", ["description"] = "H", ["data"] = 104, },
    { ["hover"] = "按键I打开强化容器", ["description"] = "I", ["data"] = 105, },
    { ["hover"] = "按键J打开强化容器", ["description"] = "J", ["data"] = 106, },
    { ["hover"] = "按键K打开强化容器", ["description"] = "K", ["data"] = 107, },
    { ["hover"] = "按键L打开强化容器", ["description"] = "L", ["data"] = 108, },
    { ["hover"] = "按键N打开强化容器", ["description"] = "N", ["data"] = 110, },
    { ["hover"] = "按键O打开强化容器", ["description"] = "O", ["data"] = 111, },
    { ["hover"] = "按键P打开强化容器", ["description"] = "P", ["data"] = 112, },
    { ["hover"] = "按键R打开强化容器", ["description"] = "R", ["data"] = 114, },
    { ["hover"] = "按键T打开强化容器", ["description"] = "T", ["data"] = 116, },
    { ["hover"] = "按键V打开强化容器", ["description"] = "V", ["data"] = 118, },
    { ["hover"] = "按键X打开强化容器", ["description"] = "X", ["data"] = 120, },
    { ["hover"] = "按键Z打开强化容器", ["description"] = "Z", ["data"] = 122, },
    { ["hover"] = "按键F1打开强化容器", ["description"] = "F1", ["data"] = 282, },
    { ["hover"] = "按键F2打开强化容器", ["description"] = "F2", ["data"] = 283, },
    { ["hover"] = "按键F3打开强化容器", ["description"] = "F3", ["data"] = 284, },
    { ["hover"] = "按键F4打开强化容器", ["description"] = "F4", ["data"] = 285, },
    { ["hover"] = "按键F5打开强化容器", ["description"] = "F5", ["data"] = 286, },
    { ["hover"] = "按键F6打开强化容器", ["description"] = "F6", ["data"] = 287, },
    { ["hover"] = "按键F7打开强化容器", ["description"] = "F7", ["data"] = 288, },
    { ["hover"] = "按键F8打开强化容器", ["description"] = "F8", ["data"] = 289, },
    { ["hover"] = "按键F9打开强化容器", ["description"] = "F9", ["data"] = 290, },
    { ["hover"] = "按键F10打开强化容器", ["description"] = "F10", ["data"] = 291, },
    { ["hover"] = "按键F11打开强化容器", ["description"] = "F11", ["data"] = 292, },
    { ["hover"] = "按键F12打开强化容器", ["description"] = "F12", ["data"] = 293, },
}
configuration_options = {
    {
        name = "hoverer_pos_config",
        label = "信息面版位置",
        hover = "设置信息面版默认位置",
        options = {
            { description = "跟随鼠标", data = 0, hover = "跟随鼠标" },
            { description = "左上", data = 1, hover = "左上" },
            { description = "左下", data = 2, hover = "左下" },
        },
        default = 0,
    },
    {
        name = "hoverer_text",
        label = "面板显示原版文本",
        hover = "面板显示原版文本",
        options = {
            { description = "显示", data = false, hover = "显示" },
            { description = "不显示", data = true, hover = "不显示" },
        },
        default = true,
    },
    {
        name = "hoverer_effect",
        label = "面板只显示词条信息",
        hover = "面板只显示词条信息",
        options = {
            { description = "所有信息", data = true, hover = "所有信息" },
            { description = "只显示词条信息", data = false, hover = "只显示词条信息" },
        },
        default = true,
    },
    {
        name = "key_config",
        label = "快捷键打开强化页面",
        hover = "快捷键打开强化页面",
        options = key_config,
        default = 120,
    },
    {
        name = "equip_drop",
        label = "装备掉率",
        hover = "装备掉率",
        options = {
            { description = "普通", data = true, hover = "普通" },
            { description = "高", data = false, hover = "高" },
        },
        default = true,
    },
    {
        name = "monster",
        label = "开启部分怪物加强",
        hover = "开启部分怪物加强",
        options = {
            { description = "开启", data = true, hover = "怪物加强" },
            { description = "关闭", data = false, hover = "关闭" },
        },
        default = true,
    },
    {
        name = "monster_difficulty",
        label = "怪物强化难度",
        hover = "怪物强化难度",
        options = {
            { description = "简单", data = "1", hover = "简单" },
            { description = "中等", data = "2", hover = "中等" },
            { description = "困难", data = "3", hover = "困难" },
        },
        default = "3",
    },
    {
        name = "equip",
        label = "开启所有装备强化(mod武器可能崩溃)",
        hover = "开启所有装备强化(mod武器可能崩溃)",
        options = {
            { description = "官方装备", data = false, hover = "官方装备" },
            { description = "所有装备", data = true, hover = "所有装备" },
        },
        default = false,
    },
    {
        name = "monster_day",
        label = "生物每日血量提高不限制天数",
        hover = "生物每日血量提高不限制天数",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = false,
    },
    {
        name = "can_drop_equip",
        label = "生物是否掉落装备(推荐后期关)",
        hover = "生物是否掉落装备(推荐后期关)",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "atk_speed_is_sure",
        label = "攻速修改",
        hover = "攻速修改(关闭后词条不再生效)",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "medal_tr_num",
        label = "泰拉/勋章是否可以附魔",
        hover = "泰拉/勋章是否可以附魔",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "can_show_equip",
        label = "是否可以公屏展示装备属性",
        hover = "快捷键:shift+alt+鼠标左键",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "can_show_text_fx",
        label = "是否显示文字特效(攻击效果类特效)",
        hover = "是否显示文字特效(攻击效果类特效)",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "can_build_duck_box",
        label = "是否可以制作鸭鸭盒子",
        hover = "功能:随身的猪王容器",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "worm_config",
        label = "蠕虫是否掉落额外战利品",
        hover = "功能:蠕虫是否掉落额外战利品",
        options = {
            { description = "关闭", data = false, hover = "关闭" },
            { description = "开启", data = true, hover = "开启" },
        },
        default = true,
    },
    {
        name = "show_stone_text",
        label = "附魔石显示文字提示",
        hover = "地面上是否显示文字提示",
        options = {
            { description = "显示", data = true, hover = "显示" },
            { description = "不显示", data = false, hover = "不显示" },
        },
        default = true,
    },
    --增加每日掉落上限
    {
        name = "limit_drop_equip",
        label = "每日装备掉落上限",
        hover = "每日装备掉落上限",
        options = {
            { description = "40", data = 40, hover = "40" },
            { description = "80", data = 80, hover = "80" },
            { description = "160", data = 160, hover = "160" },
            { description = "99999999", data = 99999999, hover = "99999999" },
        },
        default = 40,
    },
    {
        name = "limit_drop_tally",
        label = "每日卷轴/洗蕴石掉落上限",
        hover = "每日卷轴/洗蕴石掉落上限",
        options = {
            { description = "40", data = 40, hover = "40" },
            { description = "80", data = 80, hover = "80" },
            { description = "160", data = 160, hover = "160" },
            { description = "99999999", data = 99999999, hover = "99999999" },
        },
        default = 40,
    },
    {
        name = "limit_drop_stone",
        label = "每日极品附魔石掉落上限",
        hover = "每日极品附魔石掉落上限",
        options = {
            { description = "40", data = 40, hover = "40" },
            { description = "80", data = 80, hover = "80" },
            { description = "160", data = 160, hover = "160" },
            { description = "99999999", data = 99999999, hover = "99999999" },
        },
        default = 40,
    },
}
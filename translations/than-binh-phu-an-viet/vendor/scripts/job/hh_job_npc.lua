--职业npc
local HH_NPC = {
    --铁匠
    ["smith"] = {
        ["uncle_liu"] = {
            ["id"] = "uncle_liu",
            ["name"] = "刘大叔", --名字
            ["max_goodwill"] = 1000, --好感度上限
            ["like_item"] = { ["goldnugget"] = 10, }, --可以送的礼物
        },
    },
    --通用npc
    ["common_npc"] = {
        ["hh_hh"] = {
            ["id"] = "hh_hh",
            ["name"] = "煎蛋", --名字
            ["max_goodwill"] = 1000, --好感度上限
            ["like_item"] = { ["goldnugget"] = 10, }, --可以送的礼物
        },

    },

}
return HH_NPC
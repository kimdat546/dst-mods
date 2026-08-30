TUNING["HH_MOD_G"] = true
TUNING["HH_CHANCE_CONFIG"] = {
    ["DROP_EQUIP_CHANCE"] = {
        ["common_monster"] = 0.1,
        ["elite_monster"] = 0.5,
        ["boss_monster"] = 0.8,
    },
    --攻击概率获得10s回血效果
    ["ATK_10s_HEALTH"] = 0.1,
    --怪物增加词条的时间间隔
    ["MONSTER_ADD_EFFECT_DATE"] = 12,
    --怪物加强血量天数上限
    ["MONSTER_ADD_HEALTH_DAY"] = 200,
    --怪物最多存在的词条
    ["MONSTER_EFFECT_NUM"] = {
        ["base_num"] = 3,
        ["common_monster"] = 5,
        ["elite_monster"] = 7,
        ["boss_monster"] = 10,
    },
    --怪物每日血量加成
    ["MONSTER_DAY_HEALTH"] = {
        ["common_monster"] = { ["min"] = 1, ["max"] = 5 },
        ["elite_monster"] = { ["min"] = 10, ["max"] = 20 },
        ["boss_monster"] = { ["min"] = 50, ["max"] = 100 },
    },
    --奖励掉落概率
    ["GIF_CHANCE"] = {
        --宝石类道具
        ["player_gem_chance"] = 0.05,
        --附魔卷轴和洗蕴石概率
        ["player_stone_chance"] = 0.1,
        --清除宝石(洗蕴石)概率
        ["monster_remove_chance"] = 0.01,
        --精英掉落极品附魔石
        ["elite_monster_stone"] = 0.05,
        --精英掉落包裹
        ["elite_monster_gif"] = 0.01,
        --boss掉落极品附魔石
        ["boss_monster_stone"] = 0.2,
        --boss掉落包裹
        ["boss_monster_gif"] = 0.03,
    },
}
local equip_drop_config = GetModConfigData("equip_drop")
TUNING["HH_CAN_DROP_EQUIP"] = GetModConfigData("can_drop_equip")
local monster_day_config = GetModConfigData("monster_day")
if not equip_drop_config then
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["common_monster"] = 0.3
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["elite_monster"] = 0.7
    TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["boss_monster"] = 1
    --奖励掉落概率
    TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_gem_chance"] = 0.1
    TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_stone_chance"] = 0.1
end
-----
---怪物强化难度
---1-简单
---2-普通
---3-困难 默认困难
---
local monster_difficulty_config = GetModConfigData("monster_difficulty")
if monster_difficulty_config == "1" then
    --初始词条数量
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"] = 1
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"] = 2
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["elite_monster"] = 3
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["boss_monster"] = 4
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"] = 20
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"] = 100
elseif monster_difficulty_config == "2" then
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"] = 2
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"] = 3
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["elite_monster"] = 5
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["boss_monster"] = 7
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"] = 15
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"] = 150
end
--怪物天数加成限制
if monster_day_config then
    TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"] = 99999
end
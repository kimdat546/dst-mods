TUNING["HH_ATK_SPEED_BOOL"] = GetModConfigData("atk_speed_is_sure")
TUNING["HH_FORMAT_CONFIG"] = {
    ["BUFF"] = {
        ["add_health"] = "每秒回复1点血量",
        ["buff_10s_1_health"] = "每秒回复1点血量",
        ["add_hunger"] = "每秒回复1点饥饿",
        ["add_sanity"] = "每秒回复1点精神",
        ["poison"] = "每3秒掉1点血量",
        ["monster_poison"] = "每2秒掉5点血量(怪物生效)",
        ["reduce_speed"] = "移动速度-40%",
        ["player_healthSuppressNum"] = "治疗效果-90%",
        ["monster_healthSuppressNum"] = "治疗效果-90%",
        ["turret_fire"] = "1s受到1点火焰伤害",
        ["turret_poison"] = "0.5s受到1点伤害",
        ["monster_add_target_damage"] = "每秒掉1点理智",
        ["add_cold"] = "每1s体温下降5度",
        ["add_hot"] = "每1s体温上升5度",
        ["hh_beetle_pig_speed"] = "移速强化",
        ["test_01"] = "测01",
        ["test_02"] = "测02",
        ["test_03"] = "测03",
        ["test_04"] = "测04",
        ["test_05"] = "测05",
        ["test_06"] = "测06",
        ["test_07"] = "测07",
        ["test_08"] = "测08",
        ["test_09"] = "测09",
        ["test_10"] = "测10",
        ------------------套装部分ui展示效果通过buff实现----------------
        ["suit_yhby"] = "免疫制裁,中毒,潮湿\n受到攻击范围附加回血buff",
    },
    ["EQUIP_EFFECT"] = {
        ["restore_use_10s_1use_name"] = "耐久回复10s+1",
        ["restore_use_10s_1use"] = "每10秒回复1点耐久",
        ["restore_use_5s_1use_name"] = "耐久回复5s+1",
        ["restore_use_5s_1use"] = "每5秒回复1点耐久",
        ["restore_use_3s_1use_name"] = "耐久回复3s+1",
        ["restore_use_3s_1use"] = "每3秒回复1点耐久",
        ["restore_use_1s_2_percent_name"] = "耐久回复1s+2%耐久",
        ["restore_use_1s_2_percent"] = "每1秒回复2%耐久",
        ["add_max_use"] = "增加耐久%s点(通用)",
        ["add_max_use_armor_01"] = "增加耐久%s点(护甲)",
        ["add_max_use_armor_02"] = "增加耐久%s点(护甲)",
        ["add_max_use_armor_03"] = "增加耐久%s点(护甲)",
        ["reduce_com_attacked_damage"] = "固定减伤%s点",
        ["reduce_good_damage"] = "固定减伤%s点",
        ["add_com_damage"] = "造成的伤害增加%s",
        ["atk_add_good_damage"] = "造成的伤害增加%s",
        ["atk_add_poison"] = "%s%%概率使怪物中毒(2s扣5血-60s)",
        ["add_night_damage"] = "夜晚造成的伤害增加%s点",
        ["add_day_damage"] = "白天造成的伤害增加%s点",
        ["add_dusk_damage"] = "黄昏造成的伤害增加%s点",
        ["add_moisture_damage"] = "潮湿状态造成的伤害增加%s点",
        ["blood_outburst"] = "血量越低伤害越高(最高加成百分之五十)",
        ["spirit_fade"] = "精神越低伤害越高(最高加成百分之五十)",
        ["hunger_assault"] = "饥饿越低伤害越高(最高加成百分之五十)",
        ["reflexive_injury"] = "受到伤害时，反弹%s伤害给攻击者",
        ["add_hit_damage_pig"] = "增加对猪类的伤害%s点",
        ["add_hit_damage_fish"] = "增加对鱼类的伤害%s点",
        ["add_hit_damage_monkey"] = "增加对猴类的伤害%s点",
        ["add_hit_damage_gear"] = "增加对齿轮生物的伤害%s点",
        ["add_hit_damage_spider"] = "增加对蜘蛛生物的伤害%s点",
        ["add_hit_damage_dog"] = "增加对犬类生物的伤害%s点",
        ["add_hit_damage_frog"] = "增加对蛙类生物的伤害%s点",
        ["add_hit_damage_insect"] = "增加对昆虫生物的伤害%s点",
        ["add_hit_damage_shadow"] = "增加对暗影生物的伤害%s点",
        ["add_hit_damage_boss"] = "增加对巨型生物的伤害%s点",
        ["add_hit_damage_plant"] = "增加对植物的伤害%s点",
        ["add_extra_damage_percent"] = "伤害加成%s%%",
        ["add_critical_hit_rate"] = "%s%%暴击率",
        ["add_critical_hit_effect"] = "%s%%暴击效果",
        ["reduce_fire_damage"] = "火焰伤害减免%s%%",
        ["atk_blood_01"] = "吸血%s%%",
        ["atk_blood_suck_02"] = "吸血%s%%",
        ["atk_blood_suck_03"] = "吸血%s%%",
        ["atk_add_san"] = "回神%s%%",
        ["add_speed_percent"] = "增加移速%s%%",
        ["add_immune_cold"] = "免疫过冷",
        ["add_immune_hot"] = "免疫过热",
        ["add_max_health_01"] = "血量上限提升%s点",
        ["add_max_health_02"] = "血量上限提升%s点",
        ["add_max_health_03"] = "血量上限提升%s点",
        ["add_max_health_04"] = "血量上限提升%s点",
        ["atk_10s_health"] = "攻击时有概率获得10s回血(+1)buff",
        ["add_critical_hit_rate_damage"] = "暴击+%s%%,暴击效果+100%%",
        ["add_poisonProtection"] = "毒素伤害减少%s%%",
        ["add_immune_poison"] = "免疫中毒伤害",
        ["add_immune_freeze"] = "无法被冰冻",
        ["san_replace_damage"] = "%s%%概率消耗san抵挡受到的伤害",
        ["immune_debuff"] = "免疫冷,热,冰冻,毒",
        ["attack_fire_impact"] = "攻击时有概率触发%s条火焰柱攻击",
        ["reduce_bramble_percent"] = "减少受到的反甲伤害%s%%",
        ["immune_bramble"] = "免疫反弹伤害",
        ["follow_damage"] = "随从伤害增加%s点",
        ["follow_reduce_damage"] = "随从减伤%s点",
        ["more_damage_20_200"] = "20%%概率造成%s%%伤害(可暴击)",
        ["more_damage_15_300"] = "15%%概率造成%s%%伤害(可暴击)",
        ["more_damage_8_500"] = "8%%概率造成%s%%伤害(可暴击)",
        ["health_suppress_num"] = "有%s%%概率使目标获得10s制裁效果",
        ["true_damage_small"] = "造成伤害时附带%s点真伤",
        ["target_percent_damage"] = "伤害+目标%s%%当前血量",
        ["shadow_camp"] = "影怪无法对玩家造成仇恨",
        ["moon_camp"] = "月灵无法主动造成仇恨",
        ["immunity_moisture"] = "免疫潮湿",
        ["add_light"] = "增加照明效果",
        ["fast_act"] = "大幅提升采集,建造,烹饪,交易速度",
        ["work_speed"] = "双倍工作速度",
        ["armor_reduce_amount"] = "护甲消耗减少%s%%(受到攻击)",
        ["armor_immune_amount"] = "护甲免疫消耗(受到攻击)",
        ["porter"] = "搬运雕像不会减速",
        ["special_bhtg"] = "回神3%% 吸血3%% 伤害+50 加成10%% 制裁",
        ["special_zqrf"] = "免疫制裁,减速,冷,热,冰冻,毒,潮湿",
        ["special_true_damage"] = "造成伤害附带%s点真实伤害",
        ["special_sgsy"] = "减伤35,免伤45%% 免反伤",
        ["atk_speed"] = "攻速提升%s%%(" .. (TUNING["HH_ATK_SPEED_BOOL"] and "设置可关闭" or "设置已关闭") .. ")",
        ["immune_sleep"] = "免疫催眠效果",
        ["absorb_small"] = "减少%s%%受到的伤害",
        ["autumn_god"] = "秋季造成的伤害增加50点,10%%暴击率",
        ["black_monkey"] = "每拥有一个诅咒饰品(物品栏)提升%s%%伤害",
        ["tga_robot"] = "机器人提升%s点高额伤害",
        ["money_player"] = "消耗金块提升100点伤害(无则-200伤害)",
        ["immunity_stick"] = "免疫粘液",
        ["special_immune_control"] = "免疫击飞,(刚羊/恶液)粘液,催眠,冰冻",
        ------------宝藏组合型？--------------------------
        ["treasure_poison_freeze"] = "免疫中毒,冰冻",
        ["treasure_hot_cold"] = "免疫过冷,过热",
        ------------宝藏组合型？--------------------------
        -- 未公开
        ["z_suit_yhby"] = "圣光庇佑",
        ["z_suit_bhtg"] = "白虎天罡",
        ["z_suit_zqrf"] = "朱雀鸾凤",
        ["z_suit_xwsh"] = "玄武守护",
        ["z_suit_slly"] = "神龙凌云",
        ["z_suit_fyyy"] = "飞云逸影(专属)",
    },
    ["SUIT_CONFIG"] = {
        ["suit_yhby"] = { ["name"] = "圣光庇佑", ["desc"] = "已激活",
                          ["effect_str"] = "免疫制裁\n免疫潮湿\n免疫中毒\n减伤:10\n受到攻击范围10码的玩家\n获得回血buff cd:20s", },
        ["suit_bhtg"] = { ["name"] = "白虎天罡", ["desc"] = "白虎天罡已激活",
                          ["effect_str"] = "攻击附带2%撕裂效果\n回神:3%\n伤害:+50\n伤害加成10%\n受到的伤害+20%\n攻击附带制裁效果", },
        ["suit_zqrf"] = { ["name"] = "朱雀鸾凤", ["desc"] = "朱雀鸾凤已激活",
                          ["effect_str"] = "攻击附带50穿刺伤害\n吸血:3%\n免疫制裁\n免疫减速", },
        ["suit_fyyy"] = { ["name"] = "飞云逸影", ["desc"] = "飞云逸影已激活(专属)",
                          ["effect_str"] = "增强闪避能力(30%概率)\n发光\n提升动作速度\n免疫减速\n移速:30%\n伤害:50\n回神:10%\n吸血:10%", },
    },
    ["GEM_EFFECT"] = {
        ["durableGem"] = "耐久回复宝石2s+1",
        ["damageBoostGem"] = "增加造成的伤害10点",
        ["powerMettleStone"] = "造成的伤害增加3%",
        ["strideBead"] = "移速增加3%",
        ["shadowNightBead"] = "夜晚造成伤害增加20点",
        ["twilightBead"] = "黄昏伤害增加20点",
        ["dayShineBead"] = "白天伤害增加20点",
        ["critStrikeStone"] = "暴击+3%，暴击效果+10%",
        ["resistDamageGem"] = "受到的伤害减少3点",
        ["retaliateGem"] = "受到伤害时，反弹3点伤害给攻击者",
        ["spiderVengeance"] = "对蜘蛛造成的伤害增加20点",
        ["insectStrikeCrystal"] = "对昆虫造成的伤害增加20点",
        ["shadowStrikeLuminary"] = "对暗影生物造成的伤害增加20点",
        ["bossStrikeGem"] = "对boss造成的伤害增加50点",
        ["followCritical"] = "提升随从暴击率3%",
        ["followDamage"] = "提升随从伤害10点",
        ["followArmor"] = "随从受到的伤害减少3点",
        --宝藏尾刀
        ["treasure_armor"] = "宝★回耐:超快恢复耐久",
        ["treasure_atk"] = "宝★攻击:伤害增加50点",
        ["treasure_bj"] = "宝★暴击:暴击+20%",
        -----------------------------分割线-----------------------------
        ["elementBead"] = "特殊:免疫负面效果",
        ["eightPigGem"] = "音音石:免疫反弹+负面(专属-余音音)",
        ["nkGem"] = "圣嘉然的庇佑(专属-那珂)",
        ["baconOmeletteBlessArmor"] = "极致-防:免疫 +1000耐久 极品回复耐久",
        ["baconOmeletteBlessAtk"] = "特殊-攻:伤害提升50 加成15% 移速5%",
        ["baconOmeletteBlessCritical"] = "特殊-暴:暴击率10% 暴击效果:50%",
        ["baconOmeletteTrueDamage"] = "极-真伤:攻击附带100点真伤",
        ["fxGem"] = "特殊:播放文字特效",
        -----------------------------分割线-----------------------------
    },
    ["MONSTER_CONFIG"] = {
        ["addMaxHealthNum"] = "生命值上限提升%s点",
        ["addMaxHealthPercent"] = "生命值上限加成%s%%",
        ["addComDamageNum"] = "造成的伤害提升%s点",
        ["addComDamagePercent"] = "造成的伤害提升%s%%",
        ["atkAddPoison"] = "攻击有%s%%使目标中毒",
        ["hitAddPoison"] = "使攻击者有%s%%中毒",
        ["atkChanceAddFreeze"] = "攻击有%s%%使目标冰冻2s",
        ["hitChanceAddFreeze"] = "使攻击者有%s%%冰冻2s",
        ["atkChanceReduceSpeed"] = "%s%%概率使目标减速",
        ["hitChanceReduceSpeed"] = "%s%%概率使攻击者减速",
        ["addSpeedPercent"] = "增加移速%s%%",
        ["atkBlood"] = "增加吸血%s%%",
        ["addCriticalHitRate"] = "增加暴击率%s%%,暴击效果+50%%",
        ["bossAddCriticalHitRate"] = "增加暴击率%s%%,暴击效果+120%%",
        ["addReduceAttackedDamage"] = "受到的伤害减少%s点",
        ["addReboundDamageNum"] = "反弹伤害%s点",
        ["addDayDamage"] = "白天造成的伤害增加%s点",
        ["addDuskDamage"] = "黄昏造成的伤害增加%s点",
        ["addNightDamage"] = "夜晚造成的伤害增加%s点",
        ["addSuppressAddHealth"] = "攻击有%s%%使目标获得治疗-90%%效果",
        ["hitSuppressAddHealth"] = "使攻击者有%s%%获得治疗-90%%效果",
        ["reboundDamagePercent"] = "反弹伤害%s%%",
        ["deadAddFreeze"] = "死亡时范围4码内附加1层冰冻效果",
        ["deadAddMoisture"] = "死亡时范围4码内附加10点潮湿度",
        ["deadAddExplode"] = "死亡时发生爆炸范围4码内造成伤害30点",
        ["deadAddPoison"] = "死亡时范围4码内造成中毒效果",
        ["deadAddReduceSpeed"] = "死亡时范围4码内造成减速效果",
        ["iceTurret"] = "被动技能:寒冰炮塔",
        ["fireTurret"] = "被动技能:火焰炮塔",
        ["poisonTurret"] = "被动技能:剧毒炮塔",
        ["iceLaser"] = "攻击技能:激光",
        ["addHealth3sNum"] = "每3s回复%s血量",
        ["addHealth5sNum"] = "每5s回复%s血量",
        ["addHealth10sNum"] = "每10s回复%s血量",
        ["addHealth3sPercent"] = "每3s回复%s%%血量",
        ["addTargetDamage"] = "%s%%使目标获得30秒的降低理智效果",
        ["immuneFreeze"] = "免疫冰冻",
        ["noHitDamage"] = "%s%%概率抵挡受到的伤害",
        ["hitAddMoisture"] = "%s%%概率使攻击者增加20点潮湿度",
        ["addHealthPercent03"] = "每3秒回复%s%%血量",
        ["addHealthPercent05"] = "每5秒回复%s%%血量",
        ["addHealthPercent10"] = "每10秒回复%s%%血量",
        ["hitAddCold"] = "%s%%使攻击者获得30秒易冷",
        ["hitAddHot"] = "%s%%使攻击者获得30秒易热",
        ["reduceNightDamage"] = "夜晚受到的伤害减少%s点",
        ["reduceSunlightDamage"] = "白天受到的伤害减少%s点",
        ["reduceAfterglowDamage"] = "黄昏受到的伤害减少%s点",
        ["atkReduceArmor"] = "攻击使目标%s%%概率获得脆甲效果",
        ["reducePercentDamage"] = "减少%s%%受到的伤害",
        ["immuneTearing"] = "免疫撕裂效果",
    },

}
local function getChanceDesc()
    local hh_table = {
        string["format"]("装备-普通生物:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["common_monster"] * 100),
        string["format"]("装备-精英生物:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["elite_monster"] * 100),
        string["format"]("装备-boss生物:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]["boss_monster"] * 100),
        string["format"]("宝石/特殊道具:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_gem_chance"] * 100),
        string["format"]("附魔卷轴/洗蕴石:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_stone_chance"] * 50),
        string["format"]("极品附魔石-精英:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_stone"] * 100),
        string["format"]("极品附魔石-boss:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_stone"] * 100),
        string["format"]("装备包裹-精英:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_gif"] * 100),
        string["format"]("装备包裹-boss:%s%%\n", TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_gif"] * 100),

    }
    local hh_result = ""
    for i, v in ipairs(hh_table) do
        hh_result = hh_result .. v
    end
    return hh_result
end
--面板配置颜色
TUNING["HH_COLOR_CONFIG"] = {
    { ["name"] = "黑色", ["color"] = { 0, 0, 0, }, },
    { ["name"] = "象牙黑", ["color"] = { 41, 36, 33, }, },
    { ["name"] = "灰色", ["color"] = { 192, 192, 192, }, },
    { ["name"] = "冷灰", ["color"] = { 128, 138, 135, }, },
    { ["name"] = "石板灰", ["color"] = { 112, 128, 105, }, },
    { ["name"] = "暖灰色", ["color"] = { 128, 128, 105, }, },
    { ["name"] = "白色", ["color"] = { 255, 255, 255, }, },
    { ["name"] = "古董白", ["color"] = { 250, 235, 0, }, },
    { ["name"] = "天蓝色", ["color"] = { 240, 255, 255, }, },
    { ["name"] = "白烟", ["color"] = { 245, 245, 245, }, },
    { ["name"] = "白杏仁", ["color"] = { 255, 235, 205, }, },
    { ["name"] = "蛋壳色", ["color"] = { 252, 230, 201, }, },
    { ["name"] = "花白", ["color"] = { 255, 250, 240, }, },
    { ["name"] = "蜜露橙", ["color"] = { 240, 255, 240, }, },
    { ["name"] = "象牙白", ["color"] = { 250, 255, 240, }, },
    { ["name"] = "亚麻色", ["color"] = { 250, 240, 230, }, },
    { ["name"] = "海贝壳色", ["color"] = { 255, 245, 238, }, },
    { ["name"] = "雪白", ["color"] = { 255, 250, 250, }, },
    { ["name"] = "红色", ["color"] = { 255, 0, 0, }, },
    { ["name"] = "砖红", ["color"] = { 156, 102, 31, }, },
    { ["name"] = "镉红", ["color"] = { 227, 23, 13, }, },
    { ["name"] = "珊瑚色", ["color"] = { 255, 127, 80, }, },
    { ["name"] = "耐火砖红", ["color"] = { 178, 34, 34, }, },
    { ["name"] = "印度红", ["color"] = { 176, 23, 31, }, },
    { ["name"] = "栗色", ["color"] = { 176, 48, 96, }, },
    { ["name"] = "粉红", ["color"] = { 255, 192, 203, }, },
    { ["name"] = "草莓色", ["color"] = { 135, 38, 87, }, },
    { ["name"] = "橙红色", ["color"] = { 250, 128, 114, }, },
    { ["name"] = "蕃茄红", ["color"] = { 255, 99, 71, }, },
    { ["name"] = "桔红", ["color"] = { 255, 69, 0, }, },
    { ["name"] = "黄色", ["color"] = { 255, 255, 0, }, },
    { ["name"] = "香蕉色", ["color"] = { 227, 207, 87, }, },
    { ["name"] = "镉黄", ["color"] = { 255, 153, 18, }, },
    { ["name"] = "金黄色", ["color"] = { 255, 215, 0, }, },
    { ["name"] = "黄花色", ["color"] = { 218, 165, 105, }, },
    { ["name"] = "橙色", ["color"] = { 255, 97, 0, }, },
    { ["name"] = "胡萝卜色", ["color"] = { 237, 145, 33, }, },
    { ["name"] = "桔黄", ["color"] = { 255, 128, 0, }, },
    { ["name"] = "淡黄色", ["color"] = { 245, 222, 179, }, },
    { ["name"] = "棕色", ["color"] = { 128, 42, 42, }, },
    { ["name"] = "米色", ["color"] = { 163, 148, 128, }, },
    { ["name"] = "锻浓黄土色", ["color"] = { 138, 54, 15, }, },
    { ["name"] = "锻棕土色", ["color"] = { 135, 51, 36, }, },
    { ["name"] = "黄褐色", ["color"] = { 240, 230, 140, }, },
    { ["name"] = "肖贡土色", ["color"] = { 199, 97, 20, }, },
    { ["name"] = "标土棕", ["color"] = { 115, 74, 18, }, },
    { ["name"] = "乌贼墨棕", ["color"] = { 94, 38, 18, }, },
    { ["name"] = "赫色", ["color"] = { 160, 82, 45, }, },
    { ["name"] = "马棕色", ["color"] = { 139, 69, 19, }, },
    { ["name"] = "沙棕色", ["color"] = { 244, 164, 96, }, },
    { ["name"] = "棕褐色", ["color"] = { 210, 180, 140, }, },
    { ["name"] = "蓝色", ["color"] = { 0, 0, 255, }, },
    { ["name"] = "钴色", ["color"] = { 61, 89, 171, }, },
    { ["name"] = "锰蓝", ["color"] = { 3, 168, 158, }, },
    { ["name"] = "深蓝色", ["color"] = { 25, 25, 112, }, },
    { ["name"] = "孔雀蓝", ["color"] = { 51, 161, 201, }, },
    { ["name"] = "土耳其玉色", ["color"] = { 0, 199, 140, }, },
    { ["name"] = "浅灰蓝色", ["color"] = { 176, 224, 230, }, },
    { ["name"] = "品蓝", ["color"] = { 65, 105, 225, }, },
    { ["name"] = "石板蓝", ["color"] = { 106, 90, 205, }, },
    { ["name"] = "天蓝", ["color"] = { 135, 206, 235, }, },
    { ["name"] = "青色", ["color"] = { 0, 255, 255, }, },
    { ["name"] = "绿土", ["color"] = { 56, 94, 15, }, },
    { ["name"] = "靛青", ["color"] = { 8, 46, 84, }, },
    { ["name"] = "碧绿色", ["color"] = { 127, 255, 212, }, },
    { ["name"] = "青绿色", ["color"] = { 64, 224, 208, }, },
    { ["name"] = "绿色", ["color"] = { 0, 255, 0, }, },
    { ["name"] = "黄绿色", ["color"] = { 127, 255, 0, }, },
    { ["name"] = "钴绿色", ["color"] = { 61, 145, 64, }, },
    { ["name"] = "翠绿色", ["color"] = { 0, 201, 87, }, },
    { ["name"] = "森林绿", ["color"] = { 34, 139, 34, }, },
    { ["name"] = "草地绿", ["color"] = { 124, 252, 0, }, },
    { ["name"] = "酸橙绿", ["color"] = { 50, 205, 50, }, },
    { ["name"] = "薄荷色", ["color"] = { 189, 252, 201, }, },
    { ["name"] = "草绿色", ["color"] = { 107, 142, 35, }, },
    { ["name"] = "暗绿色", ["color"] = { 48, 128, 20, }, },
    { ["name"] = "海绿色", ["color"] = { 46, 139, 87, }, },
    { ["name"] = "嫩绿色", ["color"] = { 0, 255, 127, }, },
    { ["name"] = "紫色", ["color"] = { 160, 32, 240, }, },
    { ["name"] = "紫罗蓝色", ["color"] = { 138, 43, 226, }, },
    { ["name"] = "湖紫色", ["color"] = { 153, 51, 250, }, },
    { ["name"] = "淡紫色", ["color"] = { 218, 112, 214, }, },
}
TUNING["HH_ICON_CONFIG"] = {
    { ["name"] = "无", ["xml"] = "images/hh_icon/hh_icon_01.xml", ["tex"] = "hh_icon_01.tex", ["no_icon"] = true, },
    -----------------------------------------------定制-------------------------------------------------------------
    { ["name"] = "粉色兔子", ["xml"] = "images/hh_icon/hh_icon_01.xml", ["tex"] = "hh_icon_01.tex", },
    -----------------------------------------------官方-------------------------------------------------------------
    { ["name"] = "星星", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_favorites.tex", },
    { ["name"] = "太阳", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_summer.tex", },
    { ["name"] = "锅", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_cooking.tex", },
    { ["name"] = "花盆", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_cosmetic.tex", },
    { ["name"] = "爱心", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_health.tex", },
    { ["name"] = "符号", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_none.tex", },
    { ["name"] = "雪花", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_winter.tex", },
    { ["name"] = "攻击", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_weapon.tex", },
    { ["name"] = "箱子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_containers.tex", },
    { ["name"] = "烟花", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_events.tex", },
    { ["name"] = "胡萝卜", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_gardening.tex", },
    { ["name"] = "齿轮", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_modded.tex", },
    { ["name"] = "火焰", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_fire.tex", },
    { ["name"] = "护甲", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_armour.tex", },
    { ["name"] = "钓鱼", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_fishing.tex", },
    { ["name"] = "伞", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_rain.tex", },
    { ["name"] = "砖石", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_refine.tex", },
    { ["name"] = "牛鞍", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_riding.tex", },
    { ["name"] = "船", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_sailing.tex", },
    { ["name"] = "科技", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_science.tex", },
    { ["name"] = "骷髅头", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_skull.tex", },
    { ["name"] = "房子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_structure.tex", },
    { ["name"] = "工具", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_tool.tex", },
    { ["name"] = "衣服", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "filter_warable.tex", },
    { ["name"] = "书", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_books.tex", },
    { ["name"] = "锯子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_carpentry.tex", },
    { ["name"] = "制图", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_cartography.tex", },
    { ["name"] = "天体", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_celestial.tex", },
    { ["name"] = "远古", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_crafting_table.tex", },
    { ["name"] = "冬季盛宴炉子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_feast_oven.tex", },
    { ["name"] = "调味台", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_foodprocessing.tex", },
    { ["name"] = "瓶子", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_hermitcrab_shop.tex", },
    { ["name"] = "乌鸦", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_host.tex", },
    { ["name"] = "月亮科技", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_lunar_forge.tex", },
    { ["name"] = "药剂", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_madscience_lab.tex", },
    { ["name"] = "宠物牌", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_orphanage.tex", },
    { ["name"] = "元宝", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_perd_offering.tex", },
    { ["name"] = "鸦年华", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_prizebooth.tex", },
    { ["name"] = "船方向盘", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_seafaring.tex", },
    { ["name"] = "暗影锅", ["xml"] = "images/crafting_menu_icons.xml", ["tex"] = "station_shadow_forge.tex", },
    { ["name"] = "小男孩", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_walter.tex", },
    { ["name"] = "旺达", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wanda.tex", },
    { ["name"] = "沃利", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_warly.tex", },
    { ["name"] = "女武神", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wathgrithr.tex", },
    { ["name"] = "老麦", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_waxwell.tex", },
    { ["name"] = "蜘蛛人", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_webber.tex", },
    { ["name"] = "温蒂", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wendy.tex", },
    { ["name"] = "维斯", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wes.tex", },
    { ["name"] = "老奶奶", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wickerbottom.tex", },
    { ["name"] = "威诺", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_willow.tex", },
    { ["name"] = "威尔逊", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wilson.tex", },
    { ["name"] = "女工", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_winona.tex", },
    { ["name"] = "大力士", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wolfgang.tex", },
    { ["name"] = "猴子", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wonkey.tex", },
    { ["name"] = "吴迪", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie.tex", },
    { ["name"] = "鼹鼠", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie_1.tex", },
    { ["name"] = "鹿", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie_2.tex", },
    { ["name"] = "大鹅", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_woodie_3.tex", },
    { ["name"] = "植物人", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood.tex", },
    { ["name"] = "植物人-2", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood_1.tex", },
    { ["name"] = "植物人-3", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood_2.tex", },
    { ["name"] = "植物人-4", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wormwood_3.tex", },
    { ["name"] = "小恶魔", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wortox.tex", },
    { ["name"] = "小鱼妹", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wurt.tex", },
    { ["name"] = "机器人", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wx78.tex", },
    { ["name"] = "科学家", ["xml"] = "images/crafting_menu_avatars.xml", ["tex"] = "avatar_wagstaff_npc.tex", },
    -----------------------------------------------官方-------------------------------------------------------------
    { ["name"] = "悠", ["xml"] = "images/hh_icon/hh_icon_you.xml", ["tex"] = "hh_icon_you.tex", },
}
TUNING["HH_UI_TEXT"] = {
    ["UPDATE_VISION"] = {
        {
            ["title"] = "2026-06-16",
            ["desc"] = [[
            1.修复攻速兼容问题
            ]]
        },
        {
            ["title"] = "2026-05-24",
            ["desc"] = [[
            1.设置增加每日掉落上限配置 卷轴/装备/附魔石:当天默认上限40（可配置）
            2.增加世界日志记录(帮助页面)
            3.星空蛋-奖池拓展(普通装备有惊喜哦)
            4.帮助页面介绍页拓展
            5.合成台可鼠标快捷键移入物品
            ]]
        },
        {
            ["title"] = "2026-04-06",
            ["desc"] = [[
            源码去掉混淆，代码水平很烂不接受吐槽 做补丁看着一团乱码的也不容易
            ]]
        },
        {
            ["title"] = "2025-11-10",
            ["desc"] = [[
            修复
            -孵蛋窝敲了返还已有的蛋
            -公屏播报装备异常ui
            ]]
        },
        {
            ["title"] = "2025-11-09",
            ["desc"] = [[
            二周年纪念一下下
            -增加皮肤(附魔石/附魔盒子/附魔台/彩曜星环)
            -彩曜星环-孵蛋掉落
            -孵蛋(16个)
            -附魔石可配置是否显示文字提示(地面)
            ]]
        },
        {
            ["title"] = "2025-05-13",
            ["desc"] = [[
            -修复外部接口部分字段未生效的bug
            -无实质内容更新
            ]]
        },
        {
            ["title"] = "2025-04-18",
            ["desc"] = [[
            --------优化--------
            -加了一些新词条
            -制裁持续时间5s提升为10s
            -增加配置-蠕虫是否掉落额外战利品
            -增加配置-设置信息面版默认位置
            坐标:跟随鼠标/固定左上/固定左下
            左下角设置可定义是否展示信息面版
            -随从击杀生物也会掉落宝石/卷轴
            -阿比盖尔享受温蒂的增伤词条(各类固定增伤)
            （比例加成类不享受此效果）
            -中毒ui移除
            -建筑(structure标签)无视反弹伤害
            -宝藏巨鹿不会因为脱离视野消失
            (服务器重新加载会消失)
            -老麦魔术帽词条不生效bug修复
            -T键可生成宝藏boss对应宝藏点
            -代码优化,移除无用预制物
            --------接口开放--------
            -开放附魔石接口
            (mod路径-addNewEffect.lua文件提供教程案例)
            ]]
        },
        {
            ["title"] = "2024-09-16",
            ["desc"] = [[
            1.装备词条
            --免疫催眠:免疫催眠效果
            --生命类词条移除获取途径
            --伤害减免(小中大):减少一定比例受到的伤害
            伤害流程:固定减伤之后 原版护甲之前
            --稀★神龟守御:减伤35,免伤45% 免反伤/催眠
            --修复锁甲词条崩溃问题
            2.宝藏怪
            --超级鲨鱼移除无视边界
            --宝藏坎普斯增加限伤(每次受到伤害固定扣一千血)
            ]]
        },
        {
            ["title"] = "2024-08-02",
            ["desc"] = [[
            1.装备词条
            --快速交互优化:支持收锅/蘑菇农场/晾肉架
            --免疫潮湿类词条不再对小鱼妹/向晚(枝江往事)生效
            2.信息面板
            --增加配置开关(关闭则只显示词条类信息)
            --增加玩家属性显示(暴击增伤等等)
            3.月光/暗影鱼人加入强化
            4.拆除法杖
            --修复会拆稀有附魔石的bug
            --支持镶嵌宝石/升品-见左下角帮助
            5.宝藏
            --大霜鲨加入宝藏怪-护甲锁定
            6.道具
            --鸭鸭盒子-便捷猪王(设置可关闭配方)
            ]]
        },
        {
            ["title"] = "2024-06-27",
            ["desc"] = [[
            1.装备词条
            --大小攻速:(出现兼容问题可在设置中关闭)
            --撕裂提升为极品词条
            --穿刺词条数值削弱
            2.怪物词条
            --防御词条：百分比免疫伤害
            --免疫撕裂：只会出现在宝藏怪身上
            3.装备栏/附魔石支持宣告
            4.附魔盒子-容器栏制作 可拆解附魔石
            5.大霜鲨，拾荒猪人加入怪物强化
            6.拆除法杖增加批量附魔功能,装备继承支持宝石
            7.增加寻宝卷轴（娱乐向,有概率挖出强力boss）
            ]]
        },
        {
            ["title"] = "2024-06-02",
            ["desc"] = [[
            1.装备词条
            --搬运工:雕像不减速
            --(初/高)护甲减免:减少受到攻击时的护甲消耗(乘法不是加法)
            --稀★锁甲:受到攻击护甲不再消耗耐久(合成台合成)
            --稀★白虎:顶替原白虎套装
            --稀★朱雀:顶替原朱雀套装
            --稀★真伤:攻击附带真伤 不限制位置
            2.拆除法杖只会拆解怪物掉落列表中的装备
            3.套装合成途径移除(原先词条未移除)
            4.星星法杖增加技能:右键召唤多个流星轰炸目标位置
            5.怪物增加攻击脆甲词条
            6.部分贴图优化,合成台只能转换普通附魔石
            ]]
        },
        {
            ["title"] = "2024-05-30",
            ["desc"] = [[
            1.新增星星法杖,冰刃-武器/魔法栏制作
            2.修复免疫潮湿词条导致状态ui箭头不消失
            3.修正部分词条描述
            4.炮塔特效优化
            5.光照,快速交互,双倍工作不限制位置(只生效一次)
            6.耐用-通用词条不再限制绿护符/法杖
            7.暗影护盾词条概率提升(上限80%)
            ]]
        },
        {
            ["title"] = "2024-05-18",
            ["desc"] = [[
            1.怪物词条
            普通新增:易冷 易热 时段减伤
            精英新增:易冷 易热 受击潮湿 百分比回血 时段减伤
            boss新增:受击潮湿 百分比回血 时段减伤
            恐惧效果调整为持续降低理智
            蚁狮不会再拥有免疫冰冻词条
            2.装备词条:
            新增:光照 快速交互 双倍工作
            移除:毒抗 火抗
            修改:
            制裁词条提升了触发概率，白虎套装附带制裁效果
            白天/夜晚/黄昏/潮湿增伤由10-40提升至20-60
            三维对伤害加成由30%提升至50%
            修复五倍伤害丢失bug
            3.信息面板配置-各存档通用(同一个电脑)
            4.增加装备展示功能(shift+alt+鼠标左键装备)
            鼠标移至装备名字显示属性 可在配置栏配置是否启用
            5.文字类特效增加配置选项
            6.修复了部分场景信息面板报错的问题
            ]]
        },
        {
            ["title"] = "2024-03-24",
            ["desc"] = [[
            1.修复穿刺词条击杀影怪无法正常获得san补偿
            2.修复强化页面打开时格子图标变大问题
            3.套装类词条合成途径修改-详情见合成台页面
            4.合成台增加装备继承和附魔石三合一功能
            5.增加了一些套装词条
            6.强化页面一键放入不会再将背包内武器放入容器中
            7.免疫潮湿词条现在可以免疫闪电
            8.勋章，泰拉饰品增加配置-是否可以附魔
            9.护甲词条加强 增加的护甲值提升
            ]]
        },
        {
            ["title"] = "2024-03-06",
            ["desc"] = [[
            1.修复附魔套装词条后无法附魔其他词条
            2.增加拆除法杖-魔法栏制作 右键拆除地上的装备
            3.聊天栏不会触发强化页面的热键
            ]]
        },
        {
            ["title"] = "2024-03-04",
            ["desc"] = [[
            1.修复部分场景炮塔失效问题
            2.增加套装词条（测试）-通过合成附魔石获得
            3.增加定向清除词条功能-消耗净化符（获取路径:同普通宝石）
            4.打开强化页面增加热键配置-mod配置页面
            5.魔法栏增加合成台建筑（测试）-用于合成套装/定向清除
            6.增加武器-戳戳戳(魔法栏)-附魔石随机提升攻速
            ]]
        },
        {
            ["title"] = "2024-02-21",
            ["desc"] = [[
            1.修复同一个装备穿刺和撕裂可以附魔多条
            2.撕裂的百分比属性-上限改为3%
            3.修复人物变成猴子后宝石重置
            ]]
        },
        {
            ["title"] = "2024-02-20",
            ["desc"] = [[
            1.修复部分词条物品栏描述显示错误
            2.怪物的炮塔技能增加范围限制，不再无视距离进行攻击
            3.玩家获得的宝石数据在换人时会自动继承，不再需要
              宝石存储就行继承
            4.信息面板增加可配置边框/背景颜色/图标
            5.普通附魔池增加词条
                1)穿刺:每次造成伤害时会附加一定数值的真实伤害
                2)撕裂:玩家对怪物造成的伤害提升(无法暴击/多倍)
                  提升数值=目标当前血量x比例
                3)伪装:影怪/月灵不会对玩家拥有仇恨
                4)免疫潮湿:潮湿度不会再提升
            ]]
        },
        {
            ["title"] = "2024-01-15",
            ["desc"] = [[
            1.五倍伤害词条改为普通品质
            2.修复虚空套装 亮茄套装耐久为0 回复耐久无法正常使用bug
            3.生物激光技能修改 不再会拆除建筑
            4.附魔石图标增加文字展示属性
            5.配置栏增加是否掉落装备配置
            ]]
        },
        {
            ["title"] = "2024-01-07",
            ["desc"] = [[
            1.修复提示字体崩溃问题
            ]]
        },
        {
            ["title"] = "2024-01-06",
            ["desc"] = [[
            1.修复制裁词条只对玩家生效
            2.获取道具增加播报
            3.增加生物每日血量加成-天数限制 配置
            ]]
        },
        {
            ["title"] = "2023-12-31",
            ["desc"] = [[
            1.修复附魔多次掉落bug
            2.装备词条-制裁,增加随从类宝石(暴击,增伤,减伤)
            ]]
        },
        {
            ["title"] = "2023-12-30",
            ["desc"] = [[
            新内容
            1.新增怪物词条:(寒冰,火焰,剧毒)炮塔,激光,回血
            2.武器新增词条:多倍伤害,随从增伤,随从减伤
            优化
            1.修复人物变成猴子无法生成对应的存储器
            2.中毒页面优化,制裁效果改为-90%
            3.词条属性值到达上限后,再次重置将不会进行随机赋值
            4.打孔石/重置宝石可通过击杀精英/boss较高概率获取
            5.怪物掉落的装备有较低概率随机打1~2个孔
            6.装备耐久用完消失会有概率返还附魔石(已移除)
            ]]
        },
        {
            ["title"] = "2023-12-12",
            ["desc"] = [[
            1.信息面板优化-可配置是否显示官方文本 默认关闭
            2.中毒增加ui显示，免疫中毒在穿戴时可清除中毒buff
            3.增加免疫反弹伤害词条，精英/boss掉落
            4.含有词条的附魔石放在地上时，增加文字显示
            5.信息面板增加装备评级显示-受属性影响
            ]]
        },
        {
            ["title"] = "2023-12-05",
            ["desc"] = [[
            1.怪物强化增加难度配置-默认困难
            ]]
        },
        {
            ["title"] = "2023-12-02",
            ["desc"] = [[
            1.修复亮茄法杖伤害异常
            2.修复附魔石附魔后会刷新到坐标0,0,0的bug
            3.修复增加耐久的词条清除和升品导致崩溃的bug
            ]]
        },
        {
            ["title"] = "2023-12-02",
            ["desc"] = [[
            1.死亡时减速buff不清除bug修复
            2.装备掉落增加可配置化-是否提高装备掉率
            3.增加道具介绍页面
            ]]
        },
        {
            ["title"] = "2023-12-01",
            ["desc"] = [[
            1.增加岛屿冒险部分生物强化,装备词条新增猴子杀手词条
            2.耐久回复词条bug修复
            3.削弱怪物反伤和吸血属性
            ]]
        },
        {
            ["title"] = "2023-11-30",
            ["desc"] = [[
            1.装备掉落略微升高
            2.怪物强化削弱负面buff概率
            3.装备词条新增毒抗，暗影护盾，中毒词条
            ]]
        },
    },
    ["MOD_INFO"] = {
        ["mod_role"] = "",
        ["monster"] = "",
        ["choose_config"] = "",
        ["conflict"] = "",
        ["qq_str"] = "B站Mod介绍链接-By:风萧听雨落"

    },
    ["UI_ITEMS"] = "",
    ["CHANCE_TEXT"] = "",
    ["QQ_HTTP"] = "https://www.bilibili.com/video/BV1ThUKYoEgg/?spm_id_from=333.337.search-card.all.click&vd_source=c49f638584b025dc36167c79ec9eac92",
}
--文字特效配置
TUNING["HH_CAN_SHOW_TEXT_FX"] = GetModConfigData("can_show_text_fx")
TUNING["HH_WORM_CONFIG"] = GetModConfigData("worm_config")
TUNING["HH_HOVERER_POS_CONFIG"] = GetModConfigData("hoverer_pos_config")
TUNING["HH_SHOW_STONE_TEXT"] = GetModConfigData("show_stone_text")
TUNING["LIMIT_DROP_EQUIP"] = tonumber(GetModConfigData("limit_drop_equip")) or 40
TUNING["LIMIT_DROP_TALLY"] = tonumber(GetModConfigData("limit_drop_tally")) or 40
TUNING["LIMIT_DROP_STONE"] = tonumber(GetModConfigData("limit_drop_stone")) or 40
----
---任务描述列表
---
TUNING["HH_JOB_TASK_STR"] = {

}
----
---直接调用原版图鉴贴图
---
local function getScrapbookIcon(item_id)
    return GetScrapbookIconAtlas(tostring(item_id) .. ".tex")
end
local function createScrapTable(item_id)
    return { getScrapbookIcon(tostring(item_id)), tostring(item_id) .. ".tex" }
end
----
---富文本配置
---
TUNING["HH_OVO_CONFIG"] = {
    ["UI_IMAGE"] = {
        ["default"] = { "images/hh_icon/hh_log.xml", "default.tex" },
        ["effect_stone"] = { "images/hh_icon/hh_items.xml", "hh_effect_stone.tex" },
        ["effect_tally"] = { "images/hh_icon/hh_items.xml", "hh_effect_tally.tex" },
        ["remove_stone"] = { "images/hh_icon/hh_items.xml", "hh_remove_stone.tex" },
        ["effect_gem"] = { "images/hh_icon/hh_items.xml", "hh_gem.tex" },
        --魔法二本
        ["magic"] = { "images/crafting_menu_icons.xml", "station_arcane.tex" },
        --箭头
        ["arrow_right"] = { "images/button_icons.xml", "goto_url.tex" },
        --合成台
        ["suit_build"] = { "images/hh_icon/hh_suit_build.xml", "hh_suit_build.tex" },
        --猫猫盒子
        ["cat_box"] = { "images/hh_icon/hh_items.xml", "hh_cat_box.tex" },
        --水晶小人
        ["essence"] = { "images/hh_icon/hh_items.xml", "hh_essence.tex" },
        --寻宝卷轴
        ["treasure_tally"] = { "images/hh_icon/hh_items.xml", "hh_treasure_tally.tex" },
        --宝藏点
        ["treasure_build"] = { "images/hh_icon/hh_items.xml", "hh_treasure_build.tex" },
        --鸭鸭盒子
        ["duck_box"] = { "images/hh_icon/hh_items.xml", "hh_duck_box.tex" },
        --拆除法杖
        ["staff_dis"] = { "images/hh_icon/hh_weapon.xml", "hh_staff_dis.tex" },
        --冰刀
        ["ice_knife"] = { "images/hh_icon/hh_weapon.xml", "hh_ice_knife.tex" },
        --星星法杖
        ["staff_star"] = { "images/hh_icon/hh_weapon.xml", "hh_staff_star.tex" },
        --孵蛋窝
        ["egg_nest"] = { "images/hh_icon/hh_egg_nest.xml", "hh_egg_nest.tex" },
        --蛋
        ["egg_common"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_common.tex" },
        ["egg_gold"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_gold.tex" },
        ["egg_silver"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_silver.tex" },
        ["egg_black"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_black.tex" },
        ["egg_cat_claw_orange"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_cat_claw_orange.tex" },
        ["egg_cat_claw_purple"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_cat_claw_purple.tex" },
        ["egg_cat_claw_green"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_cat_claw_green.tex" },
        ["egg_cat_claw_blue"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_cat_claw_blue.tex" },
        ["egg_figure_blue_star"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_blue_star.tex" },
        ["egg_figure_green_black"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_green_black.tex" },
        ["egg_figure_purple_black"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_purple_black.tex" },
        ["egg_figure_red_black"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_red_black.tex" },
        ["egg_figure_red_blue"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_red_blue.tex" },
        ["egg_figure_yellow_green"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_yellow_green.tex" },
        ["egg_figure_yellow_green_purple"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_figure_yellow_green_purple.tex" },
        ["egg_starry_sky"] = { "images/hh_icon/hh_eggs.xml", "hh_egg_starry_sky.tex" },
        --彩曜星环
        ["hat_star"] = { "images/hh_icon/hh_hat_star.xml", "hh_hat_star.tex" },
        --原版图鉴
        ["krampus"] = createScrapTable("krampus"),
        ["mutateddeerclops"] = createScrapTable("mutateddeerclops"),
        ["mutatedbearger"] = createScrapTable("mutatedbearger"),
        ["sharkboi"] = createScrapTable("sharkboi"),
        ["pigman"] = createScrapTable("pigman"),
        ["mutatedwarg"] = createScrapTable("mutatedwarg"),
        ["catcoon"] = createScrapTable("catcoon"),
    },
    ["UI_COLOR"] = {
        ["green"] = { 0, 1, 0, 1 },
        ["red"] = { 1, 0, 0, 1 },
        ["blue"] = { 0, 0, 1, 1 },
        ["yellow"] = { 1, 1, 0, 1 },
        ["white"] = { 1, 1, 1, 1 },
        ["black"] = { 0, 0, 0, 1 },
        ["orange"] = { 1, 0.5, 0, 1 },
        ["purple"] = { 0.8, 0, 0.8, 1 }
    },
    ["UI_EXTRA_FN"] = {
        --富文本增加额外拓展函数
        ["slot_back_ground"] = function(util, self_ui)
            local ui_size_x = self_ui["size_x"] or 10
            local ui_size_y = self_ui["size_y"] or 10
            self_ui["back_ui"] = util:CreateFrameUi(self_ui, Vector3(0, 0, 1),
                    { ["size_x"] = ui_size_x, ["size_y"] = ui_size_y, ["color"] = { 189 / 255, 175 / 255, 134 / 255, 0.9 }, },
                    { ["size"] = 2, ["color"] = { 0 / 255, 0 / 255, 0 / 255, 1 }, })
            self_ui["back_ui"]:MoveToBack()
        end,
    },
}

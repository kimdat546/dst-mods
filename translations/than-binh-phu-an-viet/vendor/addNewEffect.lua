--提供了一个可以新增词条的接口-仅限于新增词条 未开放人物属性部分 具体逻辑需要自己补充
--案例-自己随便找个mod模板加就行 优先级改为负数或写在GLOBAL["ModManager"]["RegisterPrefabs"]中
if not AddSpecialEquipEffect then
    return
end
--非必填的都可以置空 但需要注意key之间的关联关系
AddSpecialEquipEffect("test_effect", {--id唯一 不要重复
    name = "词条名字", --必填
    client_text = "新\n词条", --这边是物品栏图标上的文字 一般三个字即可  必填
    desc = "词条描述", -- 必填
    check_desc = "无", --扩展描述-可自定义显示(例如描述词条前置条件) 必填
    --ui_from_desc = "附魔石来源", --扩展描述-用于帮助里面展示附魔石来源 非必填
    can_add = true, --是否可以通过附魔卷轴附魔出来(true/false) 非必填
    only_one = true, --单个装备是否允许重复附魔(true/false) 非必填
    --only_compound = false, --填true 该附魔只能合成台合成出来(等同稀有词条的概率)(true/false) 非必填
    --client_color = { 101 / 255, 255 / 255, 0 / 255, 1 }, --附魔石背景颜色 非必填 如果填了 一定要按照格式{r,g,b,a} 非必填
    --is_special = false, --填true+上面can_add填false 该词条则不能通过正常途径获取 可以通过另一个接口进行生成 非必填
    value_range = { min = 3, max = 6 }, --如果词条带有(随机变化的)属性值则必填  非必填
    check_equip_can_add = function(inst)
        -- 非必填
        --词条校验函数 一般用于校验词条是否能被装备附魔
        --ps：必须含有俩个返回值 1：是否符合条件(true/false) 2：如果第一个是false 需要写清楚不满足条件的原因
        return true, "满足条件"
    end,
    --下面俩个分别在装备新增/清除词条时执行 如果是定时任务类词条 记得在end_fn中清除掉对应任务
    -- 非必填
    start_fn = function(inst)
        --inst->装备
    end,
    -- 非必填
    end_fn = function(inst)
    end,
    --下面两个分别会在玩家穿戴/脱下装备时执行
    -- 非必填
    on_equip_fn = function(inst, owner, value)
        --inst->装备 owner->穿戴者 value->词条的属性值 如果属性值(value_range)上面未定义范围 则算作nil
    end,
    -- 非必填
    un_equip_fn = function(inst, owner, value)
    end,
})
--注意点
--如果value_range定义了值 desc->格式需要为 某某某属性%s某某某
--原因 词条描述进行的操作是string.format(desc,属性值) 如果看不懂去学一下lua的基本语法
--上面则算新增了一个词条 不要用标签进行词条的属性值添加 自己写逻辑 崩溃问题概不负责
--特殊接口
--local stone=HHSpawnStoneById("词条id") 返回指定id的附魔石实体 需要自定义坐标
----------------------------------------------------------下面是一些词条的样例-----------------------------------------------------------------------
--[[
{
        ["name"] = "稀★护甲锁定",
        ["client_text"] = "稀\n锁甲",
        ["desc"] = "护甲免疫消耗(受到攻击)",
        ["check_desc"] = "含有护甲值(armor)且免伤比例小于1",
        ["can_add"] = false, ["only_one"] = true,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 },
        ["only_compound"] = true,
        ["value_range"] = { ["min"] = 10, ["max"] = 80 },
        ["check_equip_can_add"] = function(inst)
            if not HH_UTILS:HasComponents(inst, "armor") then
                return false, "需要含有护甲值"
            end
            if not inst["components"]["armor"]["indestructible"] then
                return true, "满足条件"
            end
            local current_armor = inst["components"]["armor"]["absorb_percent"] or 0
            if not HH_UTILS:IsHHType(current_armor, "number") then
                return false, "护甲防御参数错误"
            end
            if current_armor >= 1 then
                return false, "防御过高-禁止附魔"
            end
            return false, "前置条件:含有护甲值"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
        end,
    }
    {
        ["name"] = "稀★白虎天罡",
        ["client_text"] = "稀\n白虎",
        ["desc"] = "回神3%% 吸血3%% 伤害+50 加成10%% 制裁",
        ["check_desc"] = "武器栏",
        ["can_add"] = false, ["only_one"] = true,
        ["client_color"] = { 255 / 255, 0 / 255, 0 / 255, 1 },
        ["only_compound"] = true,
        ["value_range"] = { ["min"] = 1, ["max"] = 1000 },
        ["check_equip_can_add"] = function(inst)
            if isEquipSlot(inst, EQUIPSLOTS["HANDS"]) then
                return true, "满足条件"
            end
            return false, "只允许附魔在手部"
        end,
        ["on_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["restoreSpirit"] = 3,
                ["bloodSuck"] = 3,
                ["addComDamage"] = 50,
                ["addComDamagePercent"] = 10,
                ["addSuppressAddHealth"] = 100,
            }, true)
        end,
        ["un_equip_fn"] = function(inst, owner, value)
            addSuitEffect(owner, {
                ["restoreSpirit"] = 3,
                ["bloodSuck"] = 3,
                ["addComDamage"] = 50,
                ["addComDamagePercent"] = 10,
                ["addSuppressAddHealth"] = 100,
            }, false)
        end,
    }
     {
        ["name"] = "耐久回复3s+1",
        ["desc"] = "每3秒回复1点耐久,
        ["can_add"] = true,
        ["only_one"] = true,
        ["client_text"] = "3\n回耐",
        ["check_desc"] = "护甲,燃料,使用次数,新鲜度",
        ["check_equip_can_add"] = function(inst)
            if HasUseComponent(inst) then
                return true, "满足条件"
            end
            return false, "装备含有护甲/燃料/使用次数/新鲜度才可以使用该词条!!!"
        end,
        ["start_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_3s_1use_task")
            inst["restore_use_3s_1use_task"] = inst:DoPeriodicTask(3, function()
                AddEquipUse(inst, 1)
            end)
        end,
        ["end_fn"] = function(inst)
            HH_UTILS:HHKillTask(inst, "restore_use_3s_1use_task")
        end,
    }
]]
----------------------------------------------------------上面是一些词条的样例-----------------------------------------------------------------------
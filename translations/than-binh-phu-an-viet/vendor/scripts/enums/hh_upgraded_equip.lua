----
---原版装备进化类
---
local HH_UTILS = require("utils/hh_utils")
local function replaceAnim(inst, data)
    if HH_UTILS:IsHHType(inst, "table") and inst["AnimState"] and HH_UTILS:IsHHType(data, "table")
            and HH_UTILS:IsHHType(data["anim"], "string")
            and HH_UTILS:IsHHType(data["build"], "string")
            and HH_UTILS:IsHHType(data["idle"], "string")
    then
        local new_anim = data["anim"]
        local new_build = data["build"]
        local new_idle = data["idle"]
        --是否循环播放
        if data["need_loop"] then
            inst["AnimState"]:SetBank(new_anim)
            inst["AnimState"]:SetBuild(new_build)
            inst["AnimState"]:PlayAnimation(new_idle, true)
        else
            inst["AnimState"]:SetBank(new_anim)
            inst["AnimState"]:SetBuild(new_build)
            inst["AnimState"]:PlayAnimation(new_idle)
        end

    end
end
----
---能力池子
---
local ENTRY_POUND = {
    ["ice_power"] = {
        ["name"] = "寒冰之力",
        ["desc"] = "持续降温获得伤害加成",
        ["color"] = { 1, 0, 1, 1 },
        ["equip_fn"] = function(inst, owner)
            print("穿-寒冰之力")
        end,
        ["un_equip_fn"] = function(inst, owner)
            print("脱-寒冰之力")
        end,
        --HHUpdateValue+preload执行
        ["start_fn"] = function(inst)
            print("生成-寒冰之力")
        end,
    },
    ["hot_power"] = {
        ["name"] = "火焰之力",
        ["color"] = { 1, 0, 1, 1 },
        ["equip_fn"] = function(inst, owner)
            print("穿-火焰之力")
        end,
        ["un_equip_fn"] = function(inst, owner)
            print("脱-火焰之力")
        end,
        --HHUpdateValue+preload执行
        ["start_fn"] = function(inst)
            print("生成-火焰之力")
        end,
    },
    ["moisture_power"] = {
        ["name"] = "海皇之力",
        ["color"] = { 1, 0, 1, 1 },
        ["equip_fn"] = function(inst, owner)
            print("穿-test_1_power")
        end,
        ["un_equip_fn"] = function(inst, owner)
            print("脱-test_1_power")
        end,
        --HHUpdateValue+preload执行
        ["start_fn"] = function(inst)
            print("生成-test_1_power")
        end,
    },
    ["health_god"] = {
        ["name"] = "生命女神祝福",
        ["color"] = { 1, 0, 1, 1 },
        ["equip_fn"] = function(inst, owner)
            print("穿-test_1_power")
        end,
        ["un_equip_fn"] = function(inst, owner)
            print("脱-test_1_power")
        end,
        --HHUpdateValue+preload执行
        ["start_fn"] = function(inst)
            print("生成-test_1_power")
        end,
    },

}
local body_slot = EQUIPSLOTS["BODY"]
local hand_slot = EQUIPSLOTS["HANDS"]
local hat_slot = EQUIPSLOTS["HEAD"]
local function updateEquipImage(inst, xml, tex_id)
    if HH_UTILS:HasComponents(inst, "inventoryitem")
            and HH_UTILS:IsHHType(xml, "string")
            and HH_UTILS:IsHHType(tex_id, "string")
    then
        inst["components"]["inventoryitem"]["atlasname"] = xml
        inst["components"]["inventoryitem"]:ChangeImageName(tex_id)
    end
end
local EQUIP_CONFIG = {
    --模型/动画
    ["white_body"] = {
        ["name"] = "毫无价值的白板",
    },
    ["hambat"] = {
        ["name"] = "★火腿棒",
        ["desc"] = "掺杂了巨量防腐剂,吃了长生不老!",
        --装备栏类型
        --["slot_type"] = body_slot,
        --图层关系
        ["equip_fn"] = function(inst, owner)
        end,
        ["un_equip_fn"] = function(inst, owner)
        end,
        [""] = {},
        --初始化会执行+preload执行
        ["start_fn"] = function(inst)

        end,

    },
    ["armormarble"] = {
        ["name"] = "★强化的大理石甲",
        --图层关系
        ["equip_fn"] = function(inst, owner)
        end,
        ["un_equip_fn"] = function(inst, owner)
        end,
        --词条池子 关联ENTRY_POUND的key
        ["entry_pond"] = {
            "ice_power",
            "hot_power",
            "moisture_power",
            "health_god",
        },
        ["entry_num"] = 2, --新进词条数量
        --初始化会执行HHStartValue+preload执行
        ["start_fn"] = function(inst)
            inst:AddComponent("armor")
            inst["components"]["armor"]:InitCondition(1000, 0.95)

        end,

    },
}
----
---不同的装备栏对应的词条(外观类)-关联EQUIP_CONFIG的key
---
local EQUIP_SLOT_CONFIG = {
    [body_slot] = {
        "armormarble", --大理石甲

    },
    [hand_slot] = {

    },
    [hat_slot] = {

    },
}
return {
    ["EFFECT"] = ENTRY_POUND,
    ["EQUIP"] = EQUIP_CONFIG,
    ["EQUIP_SLOT_EFFECT"] = EQUIP_SLOT_CONFIG,
}
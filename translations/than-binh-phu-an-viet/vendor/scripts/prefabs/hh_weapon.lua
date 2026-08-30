local HH_EQUIP_CONFIG = require("enums/hh_equip")
local HH_UTILS = require("utils/hh_utils")
local assets = {
    --武器
    Asset("ANIM", "anim/hh_weapon.zip"),
    Asset("IMAGE", "images/hh_icon/hh_weapon.tex"),
    Asset("ATLAS", "images/hh_icon/hh_weapon.xml"),
    Asset("ATLAS_BUILD", "images/hh_icon/hh_weapon.xml", 256),
}
local function handleEquipFn(inst, owner, is_equip)
    if HH_EQUIP_CONFIG[inst["prefab"]] then
        if is_equip and HH_EQUIP_CONFIG[inst["prefab"]]["equip_fn"] then
            HH_EQUIP_CONFIG[inst["prefab"]]["equip_fn"](inst, owner)
        elseif not is_equip and HH_EQUIP_CONFIG[inst["prefab"]]["unequip_fn"] then
            HH_EQUIP_CONFIG[inst["prefab"]]["unequip_fn"](inst, owner)
        end
    end
end
local function HandleWeapon(name, damage, weapon_range, need_limit)
    local function onequip(inst, owner)
        if need_limit then
            --权限
            --HH_UTILS:HasLimitItems(inst, owner)
        end
        owner["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", name)
        owner["AnimState"]:Show("ARM_carry")
        owner["AnimState"]:Hide("ARM_normal")
        handleEquipFn(inst, owner, true)
    end
    local function onunequip(inst, owner)
        owner["AnimState"]:Hide("ARM_carry")
        owner["AnimState"]:Show("ARM_normal")
        handleEquipFn(inst, owner, false)
    end
    local function weapon_fn()
        local inst = CreateEntity()
        inst["entity"]:AddTransform()
        inst["entity"]:AddAnimState()
        inst["entity"]:AddSoundEmitter()
        -----音效
        inst["entity"]:AddNetwork()
        inst["entity"]:AddMiniMapEntity()
        inst["MiniMapEntity"]:SetIcon(name .. ".tex")
        inst["AnimState"]:SetBank("hh_weapon")
        inst["AnimState"]:SetBuild("hh_weapon")
        inst["AnimState"]:PlayAnimation(name, true)

        inst:AddTag("weapon")
        inst:AddTag("sharp") --标签决定攻击方式，这里是长矛的

        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, "med", 0.3, 0.8)

        inst["entity"]:SetPristine()

        if HH_EQUIP_CONFIG[name] and HH_EQUIP_CONFIG[name]["client_fn"] then
            HH_EQUIP_CONFIG[name]["client_fn"](inst)
        end

        if not TheWorld["ismastersim"] then
            return inst
        end

        inst:AddComponent("inspectable") --可检查组件

        inst:AddComponent("equippable") --可装备组件
        inst["components"]["equippable"]:SetOnEquip(onequip)
        inst["components"]["equippable"]:SetOnUnequip(onunequip)
        --inst["components"]["equippable"]["walkspeedmult"] = TUNING["CANE_SPEED_MULT"]----加速

        inst:AddComponent("talker")
        inst["components"]["talker"]["fontsize"] = 28
        inst["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)

        inst:AddComponent("weapon")
        if weapon_range then
            inst["components"]["weapon"]:SetRange(weapon_range, weapon_range + 1)
        else
            inst["components"]["weapon"]:SetRange(1, 2)  --攻击距离，不写此行就是默认0.5,测试比长矛多一丢丢
        end
        inst["hh_damage"] = damage or 20
        inst["components"]["weapon"]:SetDamage(inst["hh_damage"])

        inst:AddComponent("inventoryitem")
        inst["components"]["inventoryitem"]["imagename"] = name
        inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_weapon.xml" --物品贴图

        if HH_EQUIP_CONFIG[name] and HH_EQUIP_CONFIG[name]["start_fn"] then
            HH_EQUIP_CONFIG[name]["start_fn"](inst)
        end

        return inst
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_weapon.xml", name .. ".tex")
    return Prefab(name, weapon_fn, assets)
end
return
HandleWeapon("hh_ice_knife", 58),
--拆解
HandleWeapon("hh_staff_dis", 1),
--星星法杖
HandleWeapon("hh_staff_star", 10, 15)
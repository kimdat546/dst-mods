-- scripts/prefabs/pn_truc_phong_van_kiem.lua
-- Trúc Phong Vân Kiếm — a cultivation flying-sword weapon.
-- MVP: equippable melee weapon. Inventory icon is our own art; the held/ground
-- appearance reuses the vanilla "swap_spear" build as a placeholder (real
-- swap-build art comes when we rig a custom anim).
--
-- Damage scales lightly with the wielder's cảnh giới (Luyện Khí tier): each
-- tier adds DAMAGE_PER_TIER, rewarding cultivation.

-- Held/ground visual: a custom swap build (our sword art composited into the
-- spear's atlas frames, build renamed swap_pn_truc_phong_van_kiem). The "spear"
-- BANK provides the animations; our BUILD provides the sword texture. The symbol
-- inside the build is still named "swap_spear" (we only renamed the build).
local assets = {
    Asset("ANIM", "anim/spear.zip"),                          -- bank (animations)
    Asset("ANIM", "anim/swap_pn_truc_phong_van_kiem.zip"),    -- our sword build
    Asset("ATLAS", "images/inventoryimages/pn_truc_phong_van_kiem.xml"),
    Asset("IMAGE", "images/inventoryimages/pn_truc_phong_van_kiem.tex"),
}

local SWAP_BUILD  = "swap_pn_truc_phong_van_kiem"
local SWAP_SYMBOL = "swap_spear"  -- symbol name inside the build (unchanged)

local BASE_DAMAGE     = 40
local DAMAGE_PER_TIER = 4

local function GetWielderTier(owner)
    if owner and owner.components and owner.components.pn_canhgioi then
        return owner.components.pn_canhgioi:GetTier()
    end
    return 0
end

local function CalcDamage(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    return BASE_DAMAGE + DAMAGE_PER_TIER * GetWielderTier(owner)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", SWAP_BUILD, SWAP_SYMBOL)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    -- Refresh damage based on current wielder tier
    if inst.components.weapon then
        inst.components.weapon:SetDamage(CalcDamage(inst))
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, attacker, target)
    -- Recompute each swing so breakthroughs apply live.
    if inst.components.weapon then
        inst.components.weapon:SetDamage(CalcDamage(inst))
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spear")
    inst.AnimState:SetBuild(SWAP_BUILD)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("pn_phapbao")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(BASE_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pn_truc_phong_van_kiem.xml"
    inst.components.inventoryitem.imagename = "pn_truc_phong_van_kiem"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES or 150)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES or 150)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.ATTACK, 1)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("pn_truc_phong_van_kiem", fn, assets)

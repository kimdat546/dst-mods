local HH_UTILS = require("utils/hh_utils")

local hh_sharkboi_brain = require("brains/hh_sharkboi")
local hh_com_brain = require("brains/hh_com_monster")

local function Mutated_CreateEyeFlame(hh_config)
    local fx_config = {}
    if HH_UTILS:IsHHType(hh_config, "table") then
        fx_config = hh_config
    end
    local inst = CreateEntity()
    inst:AddTag("FX")
    inst["persists"] = false
    inst["entity"]:AddTransform()
    inst["entity"]:AddAnimState()
    inst["entity"]:AddFollower()
    inst["Transform"]:SetFourFaced()
    inst["AnimState"]:SetBank("lunar_flame")
    inst["AnimState"]:SetBuild("lunar_flame")
    if HH_UTILS:IsHHType(fx_config["anim"], "string") then
        inst["AnimState"]:PlayAnimation(fx_config["anim"], true)
    else
        inst["AnimState"]:PlayAnimation("flameanim", true)
    end
    if HH_UTILS:IsHHType(fx_config["color"], "table") then
        inst["AnimState"]:SetMultColour(unpack(fx_config["color"]))
    else
        inst["AnimState"]:SetMultColour(1, 1, 1, 1)
    end
    inst["AnimState"]:SetLightOverride(0.1)
    inst["AnimState"]:SetBloomEffectHandle("shaders/anim.ksh")
    return inst
end
local function addComPhysics(inst, mass, rad)
    local phys = inst["entity"]:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0.1)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION["CHARACTERS"])
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION["WORLD"])
    phys:CollidesWith(COLLISION["OBSTACLES"])
    phys:CollidesWith(COLLISION["SMALLOBSTACLES"])
    phys:CollidesWith(COLLISION["CHARACTERS"])
    phys:CollidesWith(COLLISION["GIANTS"])
    phys:SetCapsule(rad, 1)
    return phys
end
--索敌
local function RetargetFn(inst)
    return FindEntity(inst, 14, function(guy)
        return guy and inst["components"]["combat"]:CanTarget(guy)
    end, { "_combat" }, { "prey", "smallcreature", "INLIMBO" })
end
local function KeepTargetFn(inst, target)
    if HH_UTILS:HasComponents(inst, "combat") and HH_UTILS:HasComponents(target, "combat")
            and HH_UTILS:NotIsDead(target)
            and inst["components"]["combat"]:CanTarget(target)
            and HH_UTILS:CanHitTarget(inst, target)
    then
        return true
    end
    return false
end
--重置攻击目标
local function refreshAttackTarget(_inst, data)
    if not data["attacker"] then
        return
    end
    local new_target = data["attacker"]
    if HH_UTILS:NotIsDead(new_target) and HH_UTILS:NotIsDead(_inst)
            and HH_UTILS:HasComponents(new_target, "combat")
            and HH_UTILS:CanHitTarget(_inst, new_target)
    then
        _inst["components"]["combat"]:SetTarget(new_target)
    end
end
local HH_PREFAB = {
    ["hh_sharkboi"] = {
        ["assets"] = {
            Asset("ANIM", "anim/sharkboi_build.zip"),
            Asset("ANIM", "anim/sharkboi_build_brows.zip"),
            Asset("ANIM", "anim/sharkboi_build_manes.zip"),
            Asset("ANIM", "anim/sharkboi_basic.zip"),
            Asset("ANIM", "anim/sharkboi_action.zip"),
            Asset("ANIM", "anim/sharkboi_actions1.zip"),
        },
        ["name"] = "大霜鲨", ["recipe_str"] = "大霜鲨", ["desc"] = "大霜鲨",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["entity"]:AddDynamicShadow()
            inst["DynamicShadow"]:SetSize(3.5, 1.5)
            --碰撞体积
            inst:SetPhysicsRadiusOverride(1)
            addComPhysics(inst, 1, inst["physicsradiusoverride"])

            inst["AnimState"]:SetBank("sharkboi")
            inst["AnimState"]:SetBuild("sharkboi_build")
            inst["AnimState"]:PlayAnimation("idle", true)
            inst["Transform"]:SetScale(1.6, 1.6, 1.6)
            --inst["AnimState"]:PlayAnimation("atk3", true)--三连击
            --inst["AnimState"]:PlayAnimation("torpedo_pre_pre", true)--握拳
            --inst["AnimState"]:PlayAnimation("fin_loop", true)--潜水 漏角
            --眼睛
            inst["AnimState"]:SetSymbolMultColour("sharkboi_eye_white", 1, 0, 0, 1)--红色
            --头上的角
            --inst["AnimState"]:SetSymbolMultColour("sharkboi_fin_middle_ice", 1, 0, 0, 1)
            --手
            --inst["AnimState"]:SetSymbolMultColour("sharkboi_hand", 0 / 255, 0 / 255, 0 / 255, 1)
            --鱼翅
            --inst["AnimState"]:SetSymbolMultColour("sharkboi_forearm_fin", 255 / 255, 255 / 255, 255 / 255, 0.1)
            --脖子的毛
            --inst["AnimState"]:SetSymbolMultColour("sharkboi_cloak", 0 / 255, 0 / 255, 0 / 255, 1)
            --头
            --inst["AnimState"]:SetSymbolMultColour("sharkboi_headBase", 0 / 255, 0 / 255, 0 / 255, 1)
            inst["Transform"]:SetFourFaced()
            --眼睛特效

            inst["hh_eye_fx"] = Mutated_CreateEyeFlame({ ["anim"] = "mouthflameanim", })
            inst["hh_eye_fx"]["entity"]:SetParent(inst["entity"])
            inst["hh_eye_fx"]["Follower"]:FollowSymbol(inst["GUID"], "sharkboi_eye_white", 50, 20, 0, true)
            inst["hh_hand_fx"] = Mutated_CreateEyeFlame({ ["anim"] = "mouthflameanim", })
            inst["hh_hand_fx"]["entity"]:SetParent(inst["entity"])
            inst["hh_hand_fx"]["Follower"]:FollowSymbol(inst["GUID"], "sharkboi_forearm_fin", -30, 40, 0, true)
            --inst["hh_eye_fx"]["Follower"]:FollowSymbol(inst["GUID"], "sharkboi_hand", 0, 0, 0, true)
            --胳膊
            --inst.eyeL.Follower:FollowSymbol(inst.GUID, "sharkboi_forearm", 0, 0, 0, true)
            --inst.eyeL.Follower:FollowSymbol(inst.GUID, "sharkboi_eye_white", 0, 0, 0, true)

            inst:AddTag("monster")
            inst:AddTag("hostile")
            inst:AddTag("epic")
            inst:AddTag("largecreature")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            --移速
            inst:AddComponent("locomotor")
            inst["components"]["locomotor"]["runspeed"] = 9
            inst["components"]["locomotor"]["walkspeed"] = 9

            inst:AddComponent("combat")
            inst["components"]["combat"]:SetDefaultDamage(50)
            inst["components"]["combat"]:SetAttackPeriod(3)
            --inst["components"]["combat"]["playerdamagepercent"] = .5
            inst["components"]["combat"]:SetRange(4.5)
            inst["components"]["combat"]:SetRetargetFunction(3, RetargetFn)
            inst["components"]["combat"]:SetKeepTargetFunction(KeepTargetFn)
            inst["components"]["combat"]["hiteffectsymbol"] = "sharkboi_torso"
            inst["components"]["combat"]["battlecryenabled"] = false
            inst["components"]["combat"]["forcefacing"] = false
            inst:AddComponent("health")
            --inst["components"]["health"]:StartRegen(5, 1)
            inst["components"]["health"]:SetMaxHealth(50000)
            inst["components"]["health"]["fire_damage_scale"] = 0--防火

            inst:AddComponent("timer")
            inst:AddComponent("grouptargeter")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")

            --位面防御
            inst:AddComponent("planarentity")
            --位面伤害
            inst:AddComponent("planardamage")
            inst["components"]["planardamage"]:SetBaseDamage(30)

            inst:SetStateGraph("SGhh_sharkboi")
            inst:SetBrain(hh_sharkboi_brain)
            --重置仇恨
            inst:ListenForEvent("attacked", refreshAttackTarget)
        end,
    },
    --["hh_klaus"] = {
    --    ["assets"] = {
    --        Asset("ANIM", "anim/klaus_basic.zip"),
    --        Asset("ANIM", "anim/klaus_actions.zip"),
    --        Asset("ANIM", "anim/klaus_build.zip"),
    --    },
    --    ["name"] = "超级克劳斯", ["recipe_str"] = "超级克劳斯", ["desc"] = "超级克劳斯",
    --    ["client_fn"] = function(inst, name)
    --        inst["entity"]:AddSoundEmitter()
    --        inst["entity"]:AddDynamicShadow()
    --        inst["DynamicShadow"]:SetSize(3.5, 1.5)
    --        --碰撞体积
    --        inst:SetPhysicsRadiusOverride(1)
    --        addComPhysics(inst, 1, inst["physicsradiusoverride"])
    --
    --        inst["AnimState"]:SetBank("klaus")
    --        inst["AnimState"]:SetBuild("klaus_build")
    --        inst["AnimState"]:PlayAnimation("idle_loop", true)
    --        inst["Transform"]:SetSixFaced()
    --        --角
    --        inst["AnimState"]:SetSymbolMultColour("swap_klaus_antler", 217 / 255, 0 / 255, 255 / 255, 1)--紫色
    --        --链子
    --        inst["AnimState"]:SetSymbolMultColour("swap_chain_link", 255 / 255, 0 / 255, 0 / 255, 1)--红色
    --        --身体
    --        --inst["AnimState"]:SetSymbolMultColour("klaus_body",  0 / 255, 0 / 255, 0 / 255, 1)--紫色
    --        --眼睛特效
    --        inst["hh_eye_fx"] = Mutated_CreateEyeFlame()
    --        inst["hh_eye_fx"]["entity"]:SetParent(inst["entity"])
    --        inst["hh_eye_fx"]["Follower"]:FollowSymbol(inst["GUID"], "klaus_eye", 0, 0, 0, true)
    --
    --    end,
    --    ["server_fn"] = function(inst, name)
    --        inst:AddComponent("inspectable")
    --    end,
    --},
    --["hh_boss_a"] = {
    --    ["assets"] = {
    --        Asset("ANIM", "anim/lavaarena_boarrior_basic.zip"),
    --    },
    --    ["name"] = "双持野猪", ["recipe_str"] = "双持野猪", ["desc"] = "双持野猪",
    --    ["client_fn"] = function(inst, name)
    --        inst["entity"]:AddSoundEmitter()
    --        inst["entity"]:AddDynamicShadow()
    --        inst["DynamicShadow"]:SetSize(3.5, 1.5)
    --        --碰撞体积
    --        inst:SetPhysicsRadiusOverride(1)
    --        addComPhysics(inst, 1, inst["physicsradiusoverride"])
    --
    --        inst["AnimState"]:SetBank("boarrior")
    --        inst["AnimState"]:SetBuild("lavaarena_boarrior_basic")
    --        inst["AnimState"]:PlayAnimation("idle_loop", true)
    --        inst["Transform"]:SetFourFaced()
    --
    --    end,
    --    ["server_fn"] = function(inst, name)
    --        inst:AddComponent("inspectable")
    --    end,
    --},
    ["hh_beetle_pig"] = {
        ["assets"] = {
            Asset("ANIM", "anim/lavaarena_beetletaur.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_basic.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_actions.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_block.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_fx.zip"),
            Asset("ANIM", "anim/lavaarena_beetletaur_break.zip"),
        },
        ["name"] = "甲虫野猪", ["recipe_str"] = "甲虫野猪", ["desc"] = "甲虫野猪",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["entity"]:AddDynamicShadow()
            inst["DynamicShadow"]:SetSize(3.5, 1.5)
            --碰撞体积
            inst:SetPhysicsRadiusOverride(1.5)
            MakeGiantCharacterPhysics(inst, 1000, inst["physicsradiusoverride"])

            inst["AnimState"]:SetBank("beetletaur")
            inst["AnimState"]:SetBuild("lavaarena_beetletaur")
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["Transform"]:SetFourFaced()
            --inst["Transform"]:SetScale(1.6, 1.6, 1.6)

            inst:AddTag("monster")
            inst:AddTag("hostile")
            inst:AddTag("epic")
            inst:AddTag("largecreature")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            --移速
            inst:AddComponent("locomotor")
            inst["components"]["locomotor"]["runspeed"] = 7
            inst["components"]["locomotor"]["walkspeed"] = 7
            inst:AddComponent("combat")
            inst["components"]["combat"]:SetDefaultDamage(50)
            inst["components"]["combat"]:SetAttackPeriod(2)
            inst["components"]["combat"]:SetRange(4.5)
            inst["components"]["combat"]:SetRetargetFunction(3, RetargetFn)
            inst["components"]["combat"]:SetKeepTargetFunction(KeepTargetFn)
            inst["components"]["combat"]["hiteffectsymbol"] = "body"
            inst["components"]["combat"]["battlecryenabled"] = false
            inst["components"]["combat"]["forcefacing"] = false
            inst:AddComponent("health")
            inst["components"]["health"]:SetMaxHealth(50000)
            inst["components"]["health"]["fire_damage_scale"] = 0--防火
            inst:AddComponent("timer")
            inst["components"]["timer"]:StartTimer("pig_jump_cd", 7)
            inst["components"]["timer"]:StartTimer("pig_strong_cd", 27)
            inst["components"]["timer"]:StartTimer("pig_control_cd", 45)
            inst:AddComponent("grouptargeter")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
            --位面防御
            inst:AddComponent("planarentity")
            --位面伤害
            inst:AddComponent("planardamage")
            inst["components"]["planardamage"]:SetBaseDamage(30)
            inst:SetStateGraph("SGhh_beetle_pig")
            inst:SetBrain(hh_com_brain)
            --重置仇恨
            inst:ListenForEvent("attacked", refreshAttackTarget)
        end,
    },
    ["hh_dual_wield_pig"] = {
        ["assets"] = {
            Asset("ANIM", "anim/lavaarena_boarrior_basic.zip"),
        },
        ["name"] = "双持野猪", ["recipe_str"] = "双持野猪", ["desc"] = "双持野猪",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["entity"]:AddDynamicShadow()
            inst["DynamicShadow"]:SetSize(3.5, 1.5)
            --碰撞体积
            inst:SetPhysicsRadiusOverride(1.5)
            MakeGiantCharacterPhysics(inst, 1000, inst["physicsradiusoverride"])

            inst["AnimState"]:SetBank("boarrior")
            inst["AnimState"]:SetBuild("lavaarena_boarrior_basic")
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["Transform"]:SetFourFaced()

            inst:AddTag("monster")
            inst:AddTag("hostile")
            inst:AddTag("epic")
            inst:AddTag("largecreature")
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            --移速
            inst:AddComponent("locomotor")
            inst["components"]["locomotor"]["runspeed"] = 7
            inst["components"]["locomotor"]["walkspeed"] = 7
            inst:AddComponent("combat")
            inst["components"]["combat"]:SetDefaultDamage(50)
            inst["components"]["combat"]:SetAttackPeriod(2)
            inst["components"]["combat"]:SetRange(4.5)
            inst["components"]["combat"]:SetRetargetFunction(3, RetargetFn)
            inst["components"]["combat"]:SetKeepTargetFunction(KeepTargetFn)
            inst["components"]["combat"]["hiteffectsymbol"] = "body"
            inst["components"]["combat"]["battlecryenabled"] = false
            inst["components"]["combat"]["forcefacing"] = false
            inst:AddComponent("health")
            inst["components"]["health"]:SetMaxHealth(50000)
            inst["components"]["health"]["fire_damage_scale"] = 0--防火
            inst:AddComponent("timer")
            --inst["components"]["timer"]:StartTimer("pig_rotate_cd", 15)
            inst["components"]["timer"]:StartTimer("pig_around_cd", 12)
            inst:AddComponent("grouptargeter")
            inst:AddComponent("lootdropper")
            inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
            --位面防御
            inst:AddComponent("planarentity")
            --位面伤害
            inst:AddComponent("planardamage")
            inst["components"]["planardamage"]:SetBaseDamage(30)
            inst:SetStateGraph("SGhh_dual_wield_pig")
            inst:SetBrain(hh_com_brain)
            --重置仇恨
            inst:ListenForEvent("attacked", refreshAttackTarget)
        end,
    },
    --["hh_npc_fire"] = {
    --    ["assets"] = {
    --        Asset("ANIM", "anim/hh_weapon.zip"),
    --    },
    --    ["name"] = "火男", ["recipe_str"] = "火男", ["desc"] = "火男",
    --    ["client_fn"] = function(inst, name)
    --        inst["entity"]:AddSoundEmitter()
    --        inst["entity"]:AddDynamicShadow()
    --        inst["DynamicShadow"]:SetSize(3.5, 1.5)
    --        --碰撞体积
    --        inst:SetPhysicsRadiusOverride(1.5)
    --        MakeGiantCharacterPhysics(inst, 1000, inst["physicsradiusoverride"])
    --
    --        inst["AnimState"]:SetBank("wilson")
    --        inst["AnimState"]:SetBuild("wilson")
    --        inst["AnimState"]:PlayAnimation("idle_loop", true)
    --        inst["Transform"]:SetFourFaced()
    --        inst["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", "hh_ice_knife")
    --        inst["AnimState"]:Show("ARM_carry")
    --        inst["AnimState"]:Hide("ARM_normal")
    --
    --        inst:AddTag("monster")
    --        inst:AddTag("hostile")
    --        inst:AddTag("epic")
    --    end,
    --    ["server_fn"] = function(inst, name)
    --        inst:AddComponent("inspectable")
    --        --移速
    --        inst:AddComponent("locomotor")
    --        inst["components"]["locomotor"]["runspeed"] = 7
    --        inst["components"]["locomotor"]["walkspeed"] = 7
    --        inst:AddComponent("combat")
    --        inst["components"]["combat"]:SetDefaultDamage(50)
    --        inst["components"]["combat"]:SetAttackPeriod(2)
    --        inst["components"]["combat"]:SetRange(4.5)
    --        inst["components"]["combat"]:SetRetargetFunction(3, RetargetFn)
    --        inst["components"]["combat"]:SetKeepTargetFunction(KeepTargetFn)
    --        inst["components"]["combat"]["hiteffectsymbol"] = "body"
    --        inst["components"]["combat"]["battlecryenabled"] = false
    --        inst["components"]["combat"]["forcefacing"] = false
    --        inst:AddComponent("health")
    --        inst["components"]["health"]:SetMaxHealth(50000)
    --        inst["components"]["health"]["fire_damage_scale"] = 0--防火
    --        inst:AddComponent("timer")
    --        --inst["components"]["timer"]:StartTimer("pig_rotate_cd", 15)
    --        --inst["components"]["timer"]:StartTimer("pig_around_cd", 12)
    --        inst:AddComponent("grouptargeter")
    --        inst:AddComponent("lootdropper")
    --        inst["components"]["lootdropper"]:SetChanceLootTable("hh_treasure_monster")
    --        --位面防御
    --        inst:AddComponent("planarentity")
    --        --位面伤害
    --        inst:AddComponent("planardamage")
    --        inst["components"]["planardamage"]:SetBaseDamage(10)
    --        inst:SetStateGraph("SGhh_npc_fire")
    --        inst:SetBrain(hh_com_brain)
    --        --重置仇恨
    --        inst:ListenForEvent("attacked", refreshAttackTarget)
    --    end,
    --},

}

return HH_PREFAB
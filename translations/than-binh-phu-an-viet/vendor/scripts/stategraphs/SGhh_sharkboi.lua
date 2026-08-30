local HH_UTILS = require("utils/hh_utils")
require("stategraphs/commonstates")
--转换攻击sg名称
local function ChooseAttack(inst, target)
    local inst_sg = inst["sg"]
    target = target or inst["components"]["combat"]["target"]
    if target and not target:IsValid() then
        target = nil
    end
    if inst_sg:HasStateTag("fin") then
        if inst_sg:HasStateTag("moving") then
            inst_sg["statemem"]["fin"] = true
            inst_sg:GoToState("fin_stop", { "dive_jump_delay", target })
        elseif inst_sg["currentstate"]["name"] == "fin_stop" then
            if inst_sg["nextstateparams"] then
                inst_sg["nextstateparams"][2] = target
            else
                inst_sg["nextstateparams"] = { "dive_jump_delay", target }
            end
        else
            inst_sg:GoToState("dive_jump_delay", target)
        end
        return true
    elseif not inst["components"]["timer"]:TimerExists("torpedo_cd") then
        inst_sg:GoToState("ice_summon", target)
        return true
    elseif not inst["components"]["timer"]:TimerExists("standing_dive_cd") then
        --跳水
        inst_sg:GoToState("standing_dive_jump_pre", target)
        return true
    elseif target and inst:IsNear(target, 4.5 + target:GetPhysicsRadius(0)) then
        inst_sg:GoToState("attack1", target)
        return true
    end
    return false
end
--摧毁冰块特效
local function RemoveIceFx(inst, radius)
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local all_ent = TheSim:FindEntities(x, y, z, radius + 2.5, { "hh_shark_ice_fx", }, { "FX", "DECOR", "INLIMBO" })
    if not all_ent or #all_ent <= 0 then
        return
    end
    for i, v in ipairs(all_ent) do
        if v and v["prefab"] == "hh_shark_ice_fx" and HH_UTILS:HasComponents(v, "workable") then
            v["components"]["workable"]:Destroy(inst)
        end
    end
end
------------------------钻地生成冰块-----------------------------------------
local function SpawnIcePlowFX(inst, sideoffset)
    local x, y, z = inst["Transform"]:GetWorldPosition()
    if sideoffset and sideoffset ~= 0 then
        local theta = (inst["Transform"]:GetRotation() + 90) * DEGREES
        x = x + math["cos"](theta) * sideoffset
        z = z - math["sin"](theta) * sideoffset
    end
    local fx = SpawnPrefab("sharkboi_iceplow_fx")
    if fx and fx["Transform"] then
        fx["Transform"]:SetPosition(x, 0, z)
    end
end
local function SpawnIceTrailFX(inst)
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local fx = SpawnPrefab("sharkboi_icetrail_fx")
    if fx and fx["Transform"] then
        fx["Transform"]:SetPosition(x, 0, z)
        fx["Transform"]:SetRotation(inst["Transform"]:GetRotation())
    end
end
local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }
local WORK_RADIUS_PADDING = 0.5
local function TossLaunch(inst, launcher, basespeed, startheight, startradius)
    if not launcher or not launcher["Transform"] then
        return
    end
    if not inst or not inst["Physics"] then
        return
    end
    local x0, y0, z0 = launcher["Transform"]:GetWorldPosition()
    local x1, y1, z1 = inst["Transform"]:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math["sqrt"](dsq)
        angle = math["atan2"](dz / dist, dx / dist) + (math["random"]() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math["random"]()
    end
    local sina, cosa = math["sin"](angle), math["cos"](angle)
    local speed = basespeed + math["random"]()
    inst["Physics"]:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst["Physics"]:SetVel(cosa * speed, speed * 5 + math["random"]() * 2, sina * speed)
end
--弹飞道具
local function TossItems(inst, dist, radius)
    local x, y, z = inst["Transform"]:GetWorldPosition()
    if dist ~= 0 then
        local rot = inst["Transform"]:GetRotation() * DEGREES
        x = x + dist * math["cos"](rot)
        z = z - dist * math["sin"](rot)
    end
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, radius + WORK_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)) do
        if v["prefab"] == "ice" then
            v:Remove()
        else
            if HH_UTILS:HasComponents(v, "inventoryitem") and not v["components"]["inventoryitem"]["nobounce"]
                    and v["Physics"] and v["Physics"]:IsActive()
            then
                TossLaunch(v, inst, 0.8 + radius, radius * 0.4, radius + v:GetPhysicsRadius(0))
            end
        end
    end
end
--摧毁建筑+弹飞道具
local function DoFinWork(inst)
    RemoveIceFx(inst, 0.8)
    TossItems(inst, 0.3, 0.8)
end
------------------------钻地生成冰块-----------------------------------------
--事件转sg
local hh_events = {
    --走路
    EventHandler("locomote", function(inst, data)
        if HH_UTILS:HasComponents(inst, "locomotor") and inst["sg"] then
            local inst_sg = inst["sg"]
            if inst["components"]["locomotor"]:WantsToMoveForward() then
                if inst_sg:HasStateTag("idle") then
                    if data and data["dir"] then
                        --转向
                        inst["components"]["locomotor"]:SetMoveDir(data["dir"])
                    end
                    local new_sg = (inst_sg:HasStateTag("fin") and "fin_start") or (inst["components"]["locomotor"]:WantsToRun() and "run_start" or "walk_start")
                    inst_sg:GoToState(new_sg)
                elseif inst_sg:HasStateTag("moving") and not inst_sg:HasStateTag("fin") then
                    local should_run = inst["components"]["locomotor"]:WantsToRun()
                    if should_run ~= inst_sg:HasStateTag("running") then
                        inst_sg:GoToState(should_run and "run_start" or "walk_start")
                    end
                end
            elseif inst_sg:HasStateTag("moving") then
                if inst_sg:HasStateTag("fin") then
                    inst_sg["statemem"]["fin"] = true
                    inst_sg:GoToState("fin_stop")
                else
                    inst_sg:GoToState(inst_sg:HasStateTag("running") and "run_stop" or "walk_stop")
                end
            end
        end
    end),
    --受到攻击
    EventHandler("attacked", function(inst)
        --0.5概率免疫僵直
        local random_num = math["random"]()
        if random_num < 0.5 then
            return
        end
        local inst_sg = inst["sg"]
        --print("受到攻击")
        if not inst_sg:HasStateTag("busy") or
                inst_sg:HasStateTag("caninterrupt") or
                inst_sg:HasStateTag("frozen")
        then
            if inst_sg:HasStateTag("digging") then
                inst_sg:GoToState("dive_dig_hit", inst_sg["statemem"]["hits"])
            elseif inst_sg:HasStateTag("dizzy") then
                local hits = (inst_sg["statemem"]["hits"] or 0) + 1
                inst_sg:GoToState("hit", {
                    hits > 2 and "torpedo_pst" or "torpedo_dizzy",
                    hits
                })
            elseif inst_sg:HasStateTag("torpedoready") then
                inst_sg:GoToState("hit", {
                    "torpedo_pre",
                    inst_sg["statemem"]["target"]
                })
            elseif not CommonHandlers["HitRecoveryDelay"](inst) then
                inst_sg:GoToState("hit")
            end
        end
    end),
    --开始攻击
    EventHandler("doattack", function(inst, data)
        local inst_sg = inst["sg"]
        if not inst_sg:HasStateTag("busy") and HH_UTILS:NotIsDead(inst) then
            ChooseAttack(inst, data and data["target"] or nil)
        end
    end),
}
local SPAWN_CHECK_TAGS = { "locomotor" }
local SPAWN_CHECK_NOTAGS = { "INLIMBO", "invisible", "flight" }
local function IsSpawnPointClear(pt)
    return #TheSim:FindEntities(pt["x"], 0, pt["z"], 2, SPAWN_CHECK_TAGS, SPAWN_CHECK_NOTAGS) == 0
end
------------------------------aoe------------------------------------------------------------------
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }

local function _AOEAttack(inst, dig, dist, radius, arc, heavymult, mult, hh_forcelanded, targets)
    inst["components"]["combat"]["ignorehitrange"] = true
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local arcx, cos_theta, sin_theta
    if dist ~= 0 or arc then
        local theta = inst["Transform"]:GetRotation() * DEGREES
        cos_theta = math["cos"](theta)
        sin_theta = math["sin"](theta)
        if dist ~= 0 then
            x = x + dist * cos_theta
            z = z - dist * sin_theta
        end
        if arc then
            arcx = x + math["cos"](arc / 2 * DEGREES) * radius
        end
    end
    for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
        if v ~= inst and not (targets and targets[v]) and
                v:IsValid() and not v:IsInLimbo()
                and HH_UTILS:NotIsDead(inst)
                and HH_UTILS:CanHitTarget(inst, v)
                and HH_UTILS:NotIsDead(v)
        then
            local range = radius + v:GetPhysicsRadius(0)
            local x1, y1, z1 = v["Transform"]:GetWorldPosition()
            local dx = x1 - x
            local dz = z1 - z
            if dx * dx + dz * dz < range * range
                    and (arcx == nil or x + cos_theta * dx - sin_theta * dz > arcx)
                    and inst["components"]["combat"]:CanTarget(v)
            then
                --秒杀不会动的生物
                if dig and v["components"]["locomotor"] == nil then
                    v["components"]["health"]:Kill()
                else
                    inst["components"]["combat"]:DoAttack(v)
                    if mult then
                        --是否击飞
                        local hh_strengthmult = (v["components"]["inventory"] and v["components"]["inventory"]:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
                        v:PushEvent("knockback", {
                            ["knocker"] = inst,
                            ["radius"] = radius + dist,
                            ["strengthmult"] = hh_strengthmult,
                            ["forcelanded"] = hh_forcelanded,
                        })
                    end
                end
                if targets then
                    targets[v] = true
                end
            end
        end
    end
    inst["components"]["combat"]["ignorehitrange"] = false
end
local function SpawnSwipeFX(inst, offset, reverse)
    inst["sg"]["statemem"]["fx"] = SpawnPrefab("sharkboi_swipe_fx")
    if inst["sg"]["statemem"]["fx"] then
        inst["sg"]["statemem"]["fx"]["entity"]:SetParent(inst["entity"])
        inst["sg"]["statemem"]["fx"]["Transform"]:SetPosition(offset, 0, 0)
        if reverse then
            inst["sg"]["statemem"]["fx"]:Reverse()
        end
    end
end
local SWIPE_ARC = 240
local SWIPE_OFFSET = 2
local SWIPE_RADIUS = 3.5
--aoe伤害
local function DoArcAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets)
    RemoveIceFx(inst, 0.8)
    _AOEAttack(inst, false, dist, radius, arc, heavymult, mult, forcelanded, targets)
end
--跳跃-下坠
local function DoAOEAttackAndWork(inst, dist, radius, heavymult, mult, forcelanded, targets)
    RemoveIceFx(inst, 0.8)
    _AOEAttack(inst, false, dist, radius, nil, heavymult, mult, forcelanded, targets)
end
--遁地冲撞
local function DoAOEAttackAndDig(inst, dist, radius, heavymult, mult, forcelanded, targets)
    RemoveIceFx(inst, 0.8)
    _AOEAttack(inst, true, dist, radius, nil, heavymult, mult, forcelanded, targets)
    TossItems(inst, dist, radius)
end
local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
    RemoveIceFx(inst, 0.8)
    _AOEAttack(inst, false, dist, radius, nil, heavymult, mult, forcelanded, targets)
end
--目标在前方
local function IsTargetInFront(inst, target, arc)
    if not (target and target:IsValid()) then
        return false
    end
    local rot = inst["Transform"]:GetRotation()
    local rot1 = inst:GetAngleToPoint(target["Transform"]:GetWorldPosition())
    return DiffAngle(rot, rot1) < (arc or 180) / 2
end

--清除随身特效
local function KillSwipeFX(inst)
    if inst["sg"]["statemem"]["fx"] ~= nil then
        if inst["sg"]["statemem"]["fx"]:IsValid() then
            inst["sg"]["statemem"]["fx"]:Remove()
        end
        inst["sg"]["statemem"]["fx"] = nil
    end
end
local function getSoundPathFirst(inst)
    if inst and HH_UTILS:IsHHType(inst["voicepath"], "string") then
        return inst["voicepath"]
    end
    return "meta3/sharkboi/sharkboi_a/"
end
local function SpawnIceImpactFX(inst, x, z)
    if x == nil then
        local y = 0
        x, y, z = inst["Transform"]:GetWorldPosition()
    end
    local hh_fx = SpawnPrefab("sharkboi_iceimpact_fx")
    if hh_fx and hh_fx["Transform"] then
        hh_fx["Transform"]:SetPosition(x, 0, z)
    end
end
local function SpawnIceHoleFX(inst, x, z)
    if x == nil then
        local y
        x, y, z = inst["Transform"]:GetWorldPosition()
    end
    local hh_fx = SpawnPrefab("sharkboi_icehole_fx")
    hh_fx["Transform"]:SetPosition(x, 0, z)
    return hh_fx
end
local function emptyFn()

end
--inst["sg"]["statemem"]["target"]
--inst["sg"]["statemem"]["targetpos"]
--getSoundPathFirst(inst)
local hh_states = {
    --出生
    State {
        ["name"] = "spawn",
        ["tags"] = { "busy", "jumping", "nosleep", "noattack", "temp_invincible", "notalksound" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("spawn")
            inst["SoundEmitter"]:PlaySound("turnoftides/common/together/water/emerge/large")
            inst["SoundEmitter"]:PlaySound("meta3/sharkboi/spawn")
            local pos = inst:GetPosition()
            local spawn_fx = SpawnPrefab("splash_green_large")
            if spawn_fx and spawn_fx["Transform"] then
                spawn_fx["Transform"]:SetPosition(pos["x"], 0, pos["z"])
            end
            HH_UTILS:HHSay(inst, "我来也")
            local offset, angle = FindWalkableOffset(pos, math["random"]() * PI2, 3.75, 8, false, nil, IsSpawnPointClear, false, false)
            inst["Transform"]:SetRotation(angle and angle * RADIANS or math.random(360))
            inst["Physics"]:SetMotorVelOverride(7, 0, 0)
        end,

        ["timeline"] = {
            FrameEvent(16, function(inst)
                PlayFootstep(inst)
                inst["Physics"]:SetMotorVelOverride(4, 0, 0)
            end),
            FrameEvent(17, function(inst)
                inst["Physics"]:SetMotorVelOverride(2, 0, 0)
            end),
            FrameEvent(18, function(inst)
                inst["Physics"]:SetMotorVelOverride(1, 0, 0)
            end),
            FrameEvent(19, function(inst)
                inst["Physics"]:SetMotorVelOverride(0.5, 0, 0)
            end),
            FrameEvent(20, function(inst)
                inst["Physics"]:ClearMotorVelOverride()
                inst["Physics"]:Stop()
            end),
            CommonHandlers.OnNoSleepFrameEvent(24, function(inst)
                inst["sg"]:RemoveStateTag("busy")
                inst["sg"]:RemoveStateTag("nosleep")
                inst["sg"]:RemoveStateTag("noattack")
                inst["sg"]:RemoveStateTag("temp_invincible")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    --待机
    State {
        ["name"] = "idle",
        ["tags"] = { "idle", "canrotate" },

        ["onenter"] = function(inst, norotate)
            local inst_sg = inst["sg"]
            if HH_UTILS:NotIsDead(inst) then
                if norotate then
                    --还原旋转状态
                    inst_sg:RemoveStateTag("canrotate")
                    inst_sg:AddStateTag("try_restore_canrotate") --for brain
                    inst["components"]["locomotor"]["pusheventwithdirection"] = true
                end
            else
                --死亡
                inst_sg:GoToState("death")
                return
            end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("idle", true)
        end,
        ["onexit"] = function(inst)
            local inst_sg = inst["sg"]
            if not inst_sg["statemem"]["keepsixfaced"] then
                inst["Transform"]:SetFourFaced()
            end
            inst["components"]["locomotor"]["pusheventwithdirection"] = false
        end,
    },
    --死亡
    State {
        ["name"] = "death",
        ["tags"] = { "dead", "busy", "noattack" },
        ["onenter"] = function(inst)
            HH_UTILS:HHSay(inst, "溜了~~")
            inst["AnimState"]:PlayAnimation("torpedo_pre_pre")
            inst["Physics"]:Stop()
            RemovePhysicsColliders(inst)
            if HH_UTILS:HasComponents(inst, "lootdropper") then
                inst["components"]["lootdropper"]:DropLoot(inst:GetPosition())
            end
        end,
    },

    ---------------------------------------------------------------受击----------------------------------------------------------------
    State {
        ["name"] = "hit",
        ["tags"] = { "hit", "busy" },
        ["onenter"] = function(inst, nextstateparams)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("hit")
            inst["SoundEmitter"]:PlaySound("meta3/sharkboi/hit")
            inst["sg"]["statemem"]["nextstateparams"] = nextstateparams
            if inst["sg"]["lasttags"] and inst["sg"]["lasttags"]["dizzy"] then
                inst["sg"]:AddStateTag("dizzy")
            end
        end,
        ["timeline"] = {
            FrameEvent(11, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    --死亡
                    inst["sg"]:GoToState("death")
                    return
                elseif inst["sg"]["statemem"]["nextstateparams"] then
                    inst["sg"]:GoToState(unpack(inst["sg"]["statemem"]["nextstateparams"]))
                    return
                elseif inst["sg"]["statemem"]["doattack"] then
                    if ChooseAttack(inst, inst["sg"]["statemem"]["doattack"]) then
                        return
                    end
                    --跳水cd
                    local cd = inst["components"]["timer"]:GetTimeLeft("standing_dive_cd")
                    if cd then
                        local delta = 24 / 5
                        if cd > delta then
                            inst["components"]["timer"]:SetTimeLeft("standing_dive_cd", cd - delta)
                        else
                            inst["components"]["timer"]:StopTimer("standing_dive_cd")
                        end
                    end
                end
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("doattack", function(inst, data)
                if inst["sg"]:HasStateTag("busy") and inst["sg"]["statemem"]["nextstateparams"] == nil then
                    inst["sg"]["statemem"]["doattack"] = data and data["target"] or nil
                    return true
                end
            end),
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },

    ---------------------------------------------------------------攻击1----------------------------------------------------------------
    State {
        ["name"] = "attack1",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("atk1")
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["target"] = target
            end
        end,
        ["timeline"] = {
            FrameEvent(12, function(inst)
                inst["components"]["combat"]:StartAttack()
                inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_small")
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/swipe_arm")
                SpawnSwipeFX(inst, 2)
            end),
            FrameEvent(16, function(inst)
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },

        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if IsTargetInFront(inst, inst["sg"]["statemem"]["target"], SWIPE_ARC) then
                        inst["sg"]:GoToState("attack2", inst["sg"]["statemem"]["target"])
                    elseif inst["components"]["combat"]["target"] ~= inst["sg"]["statemem"]["target"]
                            and IsTargetInFront(inst, inst["components"]["combat"]["target"], SWIPE_ARC) then
                        inst["sg"]:GoToState("attack2", inst["components"]["combat"]["target"])
                    else
                        inst["sg"]:GoToState("attack1_pst")
                    end
                end
            end),
        },
        ["onexit"] = KillSwipeFX,
    },
    --一段攻击结束
    State {
        ["name"] = "attack1_pst",
        ["tags"] = { "busy", "caninterrupt" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("atk1_pst")
        end,
        ["timeline"] = {
            FrameEvent(6, function(inst)
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },
    ---------------------------------------------------------------攻击2----------------------------------------------------------------
    State {
        ["name"] = "attack2",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("atk2")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
            inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_small")
            inst["SoundEmitter"]:PlaySound("meta3/sharkboi/swipe_arm")
            SpawnSwipeFX(inst, 2, true)
        end,
        ["timeline"] = {
            FrameEvent(4, function(inst)
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if IsTargetInFront(inst, inst["sg"]["statemem"]["target"], 120) then
                        inst["sg"]:GoToState("attack2_delay", inst["sg"]["statemem"]["target"])
                    elseif inst["components"]["combat"]["target"] ~= inst["sg"]["statemem"]["target"]
                            and IsTargetInFront(inst, inst["components"]["combat"]["target"], 120) then
                        inst["sg"]:GoToState("attack2_delay", inst["components"]["combat"]["target"])
                    else
                        inst["sg"]:GoToState("attack2_pst")
                    end
                end
            end),
        },
        ["onexit"] = KillSwipeFX,
    },
    State {
        ["name"] = "attack2_pst",
        ["tags"] = { "busy", "caninterrupt" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("atk2_pst")
        end,
        ["timeline"] = {
            FrameEvent(5, function(inst)
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },

    ---------------------------------------------------------------蓄力转三连击----------------------------------------------------------------
    State {
        ["name"] = "attack2_delay",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("atk2_delay")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst["sg"]["statemem"]["targetpos"] = target:GetPosition()
                local rot = inst["Transform"]:GetRotation()
                local rot1 = inst:GetAngleToPoint(inst["sg"]["statemem"]["targetpos"])
                local drot = ReduceAngle(rot1 - rot)
                if math["abs"](drot) < 60 then
                    rot1 = rot + drot / 2
                    inst["Transform"]:SetRotation(rot1)
                end
            end
        end,
        --转向索敌
        ["onupdate"] = function(inst)
            if inst["sg"]["statemem"]["targetpos"] then
                if inst["sg"]["statemem"]["target"] then
                    if inst["sg"]["statemem"]["target"]:IsValid() then
                        local p = inst["sg"]["statemem"]["targetpos"]
                        p["x"], p["y"], p["z"] = inst["sg"]["statemem"]["target"]["Transform"]:GetWorldPosition()
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                end
                local rot = inst["Transform"]:GetRotation()
                local rot1 = inst:GetAngleToPoint(inst["sg"]["statemem"]["targetpos"])
                local drot = ReduceAngle(rot1 - rot)
                if math["abs"](drot) < 90 then
                    rot1 = rot + math["clamp"](drot / 2, -1, 1)
                    inst["Transform"]:SetRotation(rot1)
                end
            end
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("attack3", inst["sg"]["statemem"]["target"])
                end
            end),
        },
    },
    --三连踢
    State {
        ["name"] = "attack3",
        ["tags"] = { "attack", "busy", "jumping", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("atk3")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
            --加个小加速
            inst["Physics"]:SetMotorVelOverride(9, 0, 0)
        end,
        ["onupdate"] = function(inst)
            if inst["sg"]["statemem"]["decelspeed"] then
                if inst["sg"]["statemem"]["decelspeed"] > 1 then
                    inst["sg"]["statemem"]["decelspeed"] = inst["sg"]["statemem"]["decelspeed"] - 1
                    inst["Physics"]:SetMotorVelOverride(inst["sg"]["statemem"]["decelspeed"], 0, 0)
                else
                    inst["sg"]["statemem"]["decelspeed"] = nil
                    inst["Physics"]:ClearMotorVelOverride()
                    inst["Physics"]:Stop()
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                inst["sg"]["statemem"]["decelspeed"] = 9
            end),
            FrameEvent(6, function(inst)
                inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_big")
            end),
            FrameEvent(8, function(inst)
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/swipe_tail")
                SpawnSwipeFX(inst, 2)
            end),
            FrameEvent(12, function(inst)
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC, nil, 1)
            end),
            FrameEvent(19, function(inst)
                inst["sg"]:AddStateTag("caninterrupt")
            end),
            FrameEvent(24, function(inst)
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    ---------------------------------------------------------------抬手冰柱----------------------------------------------------------------
    State {
        ["name"] = "ice_summon",
        ["tags"] = { "busy", "candefeat", "torpedoready" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("ice_summon")

            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst["sg"]["statemem"]["targetpos"] = target:GetPosition()
                inst:ForceFacePoint(inst["sg"]["statemem"]["targetpos"])
            end
        end,
        ["onupdate"] = function(inst)
            if inst["sg"]["statemem"]["targetpos"] then
                if inst["sg"]["statemem"]["target"] then
                    if inst["sg"]["statemem"]["target"]:IsValid() then
                        local p = inst["sg"]["statemem"]["targetpos"]
                        p["x"], p["y"], p["z"] = inst["sg"]["statemem"]["target"]["Transform"]:GetWorldPosition()
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                end
                local rot = inst["Transform"]:GetRotation()
                local rot1 = inst:GetAngleToPoint(inst["sg"]["statemem"]["targetpos"])
                local drot = ReduceAngle(rot1 - rot)
                if math["abs"](drot) < 90 then
                    rot1 = rot + math["clamp"](drot / 2, -2, 2)
                    inst["Transform"]:SetRotation(rot1)
                end
            end
        end,

        timeline = {
            FrameEvent(10, function(inst)
                inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_small")
            end),
            FrameEvent(35, function(inst)
                inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_big")
                inst["sg"]["statemem"]["target"] = nil
                inst["sg"]["statemem"]["targetpos"] = nil

                local x, y, z = inst["Transform"]:GetWorldPosition()
                local theta = inst["Transform"]:GetRotation() * DEGREES
                x = x + math["cos"](theta)
                z = z - math["sin"](theta)
                inst["sg"]["statemem"]["fx"] = SpawnPrefab("hh_shark_ice_start_fx")
                inst["sg"]["statemem"]["fx"]["Transform"]:SetPosition(x, 0, z)
                inst["sg"]["statemem"]["fx"]["Transform"]:SetRotation(inst["Transform"]:GetRotation())
            end),
            FrameEvent(58, function(inst)
                inst["sg"]:AddStateTag("caninterrupt")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]["statemem"]["not_interrupted"] = true
                    inst["sg"]:GoToState("torpedo_pre")
                end
            end),
        },
        ["onexit"] = function(inst)
            if not inst["sg"]["statemem"]["not_interrupted"] and inst["sg"]["statemem"]["fx"] and inst["sg"]["statemem"]["fx"]:IsValid() then
                inst["sg"]["statemem"]["fx"]:Remove()
            end
        end,
    },
    ---------------------------------------------------------------起飞----------------------------------------------------------------
    State {
        ["name"] = "torpedo_pre",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("torpedo_pre")
            if inst["sg"]["lasttags"] and inst["sg"]["lasttags"] then
                inst["sg"]["statemem"]["quick"] = true
                inst["AnimState"]:SetFrame(16)
            end
            inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_small")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst["sg"]["statemem"]["targetpos"] = target:GetPosition()
                inst:ForceFacePoint(inst["sg"]["statemem"]["targetpos"])
            end
        end,
        --转向索敌
        ["onupdate"] = function(inst)
            if inst["sg"]["statemem"]["targetpos"] then
                if inst["sg"]["statemem"]["target"] then
                    if inst["sg"]["statemem"]["target"]:IsValid() then
                        local p = inst["sg"]["statemem"]["targetpos"]
                        p["x"], p["y"], p["z"] = inst["sg"]["statemem"]["target"]["Transform"]:GetWorldPosition()
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                end
                local rot = inst["Transform"]:GetRotation()
                local rot1 = inst:GetAngleToPoint(inst["sg"]["statemem"]["targetpos"])
                local drot = ReduceAngle(rot1 - rot)
                if math["abs"](drot) < 90 then
                    rot1 = rot + math["clamp"](drot / 2, -2, 2)
                    inst["Transform"]:SetRotation(rot1)
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(30 - 16, function(inst)
                if inst["sg"]["statemem"]["quick"] then
                    PlayFootstep(inst)
                end
            end),
            FrameEvent(30, function(inst)
                if not inst["sg"]["statemem"]["quick"] then
                    PlayFootstep(inst)
                end
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("torpedo_jump")
                end
            end),
        },
    },
    State {
        ["name"] = "torpedo_jump",
        ["tags"] = { "attack", "busy", "jumping", "nosleep", "cantalk" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("torpedo_jump")
            inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_big")
            inst["components"]["combat"]:StartAttack()
            inst["components"]["timer"]:StopTimer("torpedo_cd")
            inst["components"]["timer"]:StartTimer("torpedo_cd", 20)
            inst["Physics"]:SetMotorVelOverride(16, 0, 0)
            inst["sg"]["statemem"]["targets"] = {}
        end,
        ["onupdate"] = function(inst)
            DoAOEAttackAndWork(inst, 0, 2.5, nil, 1, nil, inst["sg"]["statemem"]["targets"])
        end,
        ["timeline"] = {
            FrameEvent(8, function(inst)
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/torpedo_drill", "drill")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]["statemem"]["torpedo"] = true
                    inst["sg"]:GoToState("torpedo", inst["sg"]["statemem"]["targets"])
                end
            end),
        },
        ["onexit"] = function(inst)
            if not inst["sg"]["statemem"]["torpedo"] then
                inst["SoundEmitter"]:KillSound("drill")
                inst["Physics"]:ClearMotorVelOverride()
                inst["Physics"]:Stop()
            end
        end,
    },
    --鱼雷冲击
    State {
        ["name"] = "torpedo",
        ["tags"] = { "attack", "busy", "jumping", "nosleep" },
        ["onenter"] = function(inst, targets)
            inst["components"]["locomotor"]:Stop()
            inst["Transform"]:SetEightFaced()
            inst["AnimState"]:PlayAnimation("torpedo_loop", true)
            inst["Physics"]:SetMotorVelOverride(16, 0, 0)
            inst["sg"]:SetTimeout(1)
            inst["sg"]["statemem"]["targets"] = targets or {}
            inst["sg"]["statemem"]["icedelay"] = 0
            inst["sg"]["statemem"]["traildelay"] = 0
            inst["sg"]["statemem"]["shakedelay"] = 8
            if not inst["SoundEmitter"]:PlayingSound("drill") then
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/torpedo_drill", "drill")
            end
        end,
        ["onupdate"] = function(inst)
            DoAOEAttackAndDig(inst, -0.4, 3, nil, 1, nil, inst["sg"]["statemem"]["targets"])
            if inst["sg"]["statemem"]["icedelay"] > 0 then
                inst["sg"]["statemem"]["icedelay"] = inst["sg"]["statemem"]["icedelay"] - 1
            else
                inst["sg"]["statemem"]["icedelay"] = 3
                SpawnIcePlowFX(inst, 2)
                SpawnIcePlowFX(inst, -2)
                SpawnIceTrailFX(inst)
            end
            if inst["sg"]["statemem"]["traildelay"] > 0 then
                inst["sg"]["statemem"]["traildelay"] = inst["sg"]["statemem"]["traildelay"] - 1
            else
                inst["sg"]["statemem"]["traildelay"] = 2
                SpawnIceTrailFX(inst)
            end
            if inst["sg"]["statemem"]["shakedelay"] > 0 then
                inst["sg"]["statemem"]["shakedelay"] = inst["sg"]["statemem"]["shakedelay"] - 1
            else
                inst["sg"]["statemem"]["shakedelay"] = 6
            end
        end,
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("torpedo_climb")
        end,
        ["onexit"] = function(inst)
            inst["Transform"]:SetFourFaced()
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
            inst["SoundEmitter"]:KillSound("drill")
        end,
    },
    --冲撞后从地上爬起来
    State {
        ["name"] = "torpedo_climb",
        ["tags"] = { "busy", "dizzy", "nosleep" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("torpedo_climb")
        end,
        ["timeline"] = {
            FrameEvent(32, function(inst)
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/hit")
            end),
            CommonHandlers["OnNoSleepFrameEvent"](36, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    inst["sg"]:GoToState("death")
                    return
                end
                inst["sg"]:RemoveStateTag("nosleep")
                inst["sg"]:AddStateTag("caninterrupt")
            end),
        },

        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("torpedo_dizzy")
                end
            end),
        },
    },
    --晕乎乎
    State {
        ["name"] = "torpedo_dizzy",
        ["tags"] = { "busy", "dizzy", "caninterrupt" },
        ["onenter"] = function(inst, hits)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("torpedo_dizzy")
            if hits then
                inst["AnimState"]:SetFrame(23)
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/hit", nil, 0.6)
                inst["sg"]["statemem"]["hits"] = hits
            end
        end,
        ["timeline"] = {
            FrameEvent(22, function(inst)
                if inst["sg"]["statemem"]["hits"] == nil then
                    inst["SoundEmitter"]:PlaySound("meta3/sharkboi/hit")
                end
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("torpedo_pst")
                end
            end),
        },
    },
    --结束晕乎乎
    State {
        ["name"] = "torpedo_pst",
        ["tags"] = { "busy", "notalksound" },
        ["onenter"] = function(inst, hits)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("torpedo_pst")
            if hits then
                inst["AnimState"]:SetFrame(19)
                inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "talk", nil, 0.4)
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/hit", nil, 0.6)
            else
                inst["sg"]:AddStateTag("dizzy")
                inst["sg"]:AddStateTag("caninterrupt")
            end
            inst["sg"]["statemem"]["hits"] = 3
        end,
        ["timeline"] = {
            FrameEvent(34 - 19, function(inst)
                if not inst["sg"]:HasStateTag("dizzy") then
                    inst["sg"]:AddStateTag("caninterrupt")
                end
            end),
            FrameEvent(16, function(inst)
                if inst["sg"]:HasStateTag("dizzy") then
                    inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "talk", nil, 0.4)
                    inst["SoundEmitter"]:PlaySound("meta3/sharkboi/hit", nil, 0.6)
                end
            end),
            FrameEvent(19, function(inst)
                if inst["sg"]:HasStateTag("dizzy") then
                    inst["sg"]:RemoveStateTag("dizzy")
                    inst["sg"]:RemoveStateTag("caninterrupt")
                end
            end),
            FrameEvent(34, function(inst)
                inst["sg"]:AddStateTag("caninterrupt")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },

    ---------------------------------------------------------------破冰跳出来咬人----------------------------------------------------------------
    State {
        ["name"] = "standing_dive_jump_pre",
        ["tags"] = { "busy", "candefeat", "fastdig" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_standing_jump_pre")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst["sg"]["statemem"]["targetpos"] = target:GetPosition()
                inst:ForceFacePoint(inst["sg"]["statemem"]["targetpos"])
            end
        end,
        ["onupdate"] = function(inst)
            local target = inst["sg"]["statemem"]["target"]
            if target then
                if target:IsValid() then
                    local pos = inst["sg"]["statemem"]["targetpos"]
                    pos["x"], pos["y"], pos["z"] = target["Transform"]:GetWorldPosition()
                    if target["Physics"] then
                        local vx, vy, vz = target["Physics"]:GetVelocity()
                        pos["x"] = pos["x"] + vx * 0.3
                        pos["z"] = pos["z"] + vz * 0.3
                    end
                    local rot = inst["Transform"]:GetRotation()
                    local rot1 = inst:GetAngleToPoint(pos)
                    if DiffAngle(rot, rot1) < 45 then
                        inst["Transform"]:SetRotation(rot1)
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                else
                    inst["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(10, PlayFootstep),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("dive_jump", inst["sg"]["statemem"]["targetpos"])
                end
            end),
        },
    },
    State {
        ['name'] = "dive_jump_delay",
        ['tags'] = { "fin", "busy", "nosleep", "noattack", "invisible", "temp_invincible", "jumping" },
        ['onenter'] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst:Hide()
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst["sg"]["statemem"]["targetpos"] = target:GetPosition()
            end
            if inst["sg"]["lasttags"] and inst["sg"]["lasttags"]["idle"] then
                inst["Physics"]:SetMotorVelOverride(6 / 4, 0, 0)
            else
                inst["Physics"]:SetMotorVelOverride(6 / 2, 0, 0)
            end
            inst["sg"]:SetTimeout(0.5)
        end,
        ["onupdate"] = function(inst)
            local target = inst["sg"]["statemem"]["target"]
            local pos = inst["sg"]["statemem"]["targetpos"]
            if target then
                if target:IsValid() then
                    pos["x"], pos["y"], pos["z"] = target["Transform"]:GetWorldPosition()
                    if target["Physics"] then
                        local vx, vy, vz = target["Physics"]:GetVelocity()
                        pos["x"] = pos["x"] + vx * 0.3
                        pos["z"] = pos["z"] + vz * 0.3
                    end
                    local rot = inst["Transform"]:GetRotation()
                    local rot1 = inst:GetAngleToPoint(pos)
                    if DiffAngle(rot, rot1) < 45 then
                        inst["Transform"]:SetRotation(rot1)
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                else
                    inst["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["ontimeout"] = function(inst)
            inst["sg"]["statemem"]["diving"] = true
            inst["sg"]:GoToState("dive_jump_pre", {
                ["target"] = inst["sg"]["statemem"]["target"],
                ["targetpos"] = inst["sg"]["statemem"]["targetpos"],
            })
        end,
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
            inst:Show()
        end,
    },

    State {
        ["name"] = "dive_jump_pre",
        ["tags"] = { "busy", "nosleep", "noattack", "invisible", "temp_invincible" },
        ["onenter"] = function(inst, data)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_jump_pre")
            inst["DynamicShadow"]:Enable(false)
            if data then
                if EntityScript["is_instance"](data) then
                    if data:IsValid() then
                        inst["sg"]["statemem"]["target"] = data
                        inst["sg"]["statemem"]["targetpos"] = data:GetPosition()
                        inst:ForceFacePoint(inst["sg"]["statemem"]["targetpos"])
                    end
                else
                    inst["sg"]["statemem"]["target"] = data["target"]
                    inst["sg"]["statemem"]["targetpos"] = data["targetpos"]
                end
            end
        end,
        ["onupdate"] = function(inst)
            if inst["sg"]["statemem"]["targets"] then
                local targets = inst["sg"]["statemem"]["targets"]
                DoAOEAttackAndDig(inst, 0, 2, nil, 1, nil, targets)
                if targets ~= inst["sg"]["statemem"]["targets"] then
                    return
                end
            end

            local target = inst["sg"]["statemem"]["target"]
            if target then
                if target:IsValid() then
                    local pos = inst["sg"]["statemem"]["targetpos"]
                    pos["x"], pos["y"], pos["z"] = target["Transform"]:GetWorldPosition()
                    if target["Physics"] then
                        local vx, vy, vz = target["Physics"]:GetVelocity()
                        pos["x"] = pos["x"] + vx * 0.3
                        pos["z"] = pos["z"] + vz * 0.3
                    end
                    local rot = inst["Transform"]:GetRotation()
                    local rot1 = inst:GetAngleToPoint(pos)
                    if DiffAngle(rot, rot1) < 45 then
                        inst["Transform"]:SetRotation(rot1)
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                else
                    inst["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                inst["sg"]:RemoveStateTag("invisible")
                inst["sg"]:RemoveStateTag("temp_invincible")
                inst["DynamicShadow"]:Enable(true)
                inst["components"]["combat"]:StartAttack()
                inst["sg"]["statemem"]["targets"] = {}
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/popup")
                SpawnIceImpactFX(inst)
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]["statemem"]["jumping"] = true
                    inst["sg"]:GoToState("dive_jump", inst["sg"]["statemem"]["targetpos"])
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["DynamicShadow"]:Enable(true)
        end,
    },

    State {
        ["name"] = "dive_jump",
        ["tags"] = { "busy", "jumping", "nosleep" },
        ["onenter"] = function(inst, pos)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_jump")
            inst["SoundEmitter"]:PlaySound(getSoundPathFirst(inst) .. "attack_big")
            inst["components"]["combat"]:StartAttack()

            local x, y, z = inst["Transform"]:GetWorldPosition()
            inst["components"]["timer"]:StopTimer("standing_dive_cd")
            if inst["sg"]["lasttags"] and inst["sg"]["lasttags"]["fastdig"] then
                inst["sg"]:AddStateTag("fastdig")
                inst["components"]["timer"]:StartTimer("standing_dive_cd", 24 / 2)
            else
                inst["components"]["timer"]:StartTimer("standing_dive_cd", 24)
                SpawnIceHoleFX(inst, x, z)
            end

            local theta = inst["Transform"]:GetRotation() * DEGREES
            local costheta = math["cos"](theta)
            local sintheta = math["sin"](theta)
            local dist = 6
            if pos then
                local hh_x, hh_z = x, z
                local dx = pos["x"] - hh_x
                local dz = pos["z"] - hh_z
                if dx == 0 and dz == 0 then
                    dist = 2
                else
                    local theta1 = math["atan2"](-dz, dx)
                    local dtheta = DiffAngleRad(theta, theta1)
                    dist = math["sqrt"](dx * dx + dz * dz) * math["cos"](dtheta)
                    dist = math["clamp"](math["abs"](dist), 2, 8)
                end
            end
            local map = TheWorld["Map"]
            while dist > 1 and not map:IsVisualGroundAtPoint(x + costheta * dist, 0, z - sintheta * dist) do
                dist = math["max"](1, dist - 0.5)
            end
            local speed = dist / inst["AnimState"]:GetCurrentAnimationLength()
            inst["Physics"]:SetMotorVelOverride(speed, 0, 0)
        end,
        ["timeline"] = {
            FrameEvent(20, function(inst)
                inst["sg"]["statemem"]["targets"] = {}
                DoAOEAttack(inst, 0, 2, nil, 1, nil, inst["sg"]["statemem"]["targets"])
            end),
        },

        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("dive_dig_pre", inst["sg"]["statemem"]["targets"])
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    State {
        ["name"] = "dive_dig_pre",
        ["tags"] = { "digging", "busy", "caninterrupt", "nosleep" },
        ["onenter"] = function(inst, targets)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_dig_pre")
            inst["SoundEmitter"]:PlaySound("meta3/sharkboi/divedown")
            if not HH_UTILS:NotIsDead(inst) then
                inst["sg"]:GoToState("death")
                return
            end
            SpawnIceImpactFX(inst)
            DoAOEAttackAndDig(inst, 0, 2, nil, 1, nil, targets)
            if inst["sg"]["mem"]["sleeping"] then
                inst["sg"]:GoToState("dive_dig_hit")
            elseif inst["sg"]["lasttags"] and inst["sg"]["lasttags"]["fastdig"] then
                inst["sg"]:AddStateTag("fastdig")
            end
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("dive_dig_loop")
                end
            end),
        },
    },
    State {
        ["name"] = "dive_dig_loop",
        ["tags"] = { "digging", "busy", "caninterrupt", "nosleep" },
        ["onenter"] = function(inst, hits)
            inst["components"]["locomotor"]:Stop()
            if hits then
                inst["AnimState"]:PlayAnimation("icedive_dig_loop")
                inst["sg"]["statemem"]["hits"] = hits
            elseif inst["sg"]["lasttags"] and inst["sg"]["lasttags"]["fastdig"] then
                inst["AnimState"]:PlayAnimation("icedive_dig_loop")
            else
                inst["AnimState"]:PlayAnimation("icedive_dig_loop", true)
                inst["sg"]:SetTimeout(2 * inst["AnimState"]:GetCurrentAnimationLength())
            end
            inst["SoundEmitter"]:PlaySound("meta3/sharkboi/feetsies_wiggle_LP", "loop")
        end,
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("dive_dig_pst")
        end,
        ["events"] = {
            EventHandler("animqueueover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("dive_dig_pst")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["SoundEmitter"]:KillSound("loop")
        end,
    },
    State {
        ["name"] = "dive_dig_hit",
        ["tags"] = { "digging", "hit", "busy", "nosleep" },
        ["onenter"] = function(inst, hits)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_dig_hit")
            inst["sg"]["statemem"]["hits"] = (hits or 0) + 1
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    inst["sg"]:GoToState("death")
                    return
                end
                local hh_hit_num = inst["sg"]["statemem"]["hits"]
                if (HH_UTILS:IsHHType(hh_hit_num, "number") and (hh_hit_num >= 3)) or inst["sg"]["mem"]["sleeping"] then
                    inst["sg"]:GoToState("dive_dig_stun")
                end
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("dive_dig_loop", inst["sg"]["statemem"]["hits"] or 1)
                end
            end),
        },
    },

    State {
        ["name"] = "dive_dig_pst",
        ["tags"] = { "digging", "busy", "nosleep" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_dig_pst")
            inst["sg"]["statemem"]["fx"] = SpawnIceHoleFX(inst)
            if inst["sg"]["statemem"]["fx"] and inst["sg"]["statemem"]["fx"]["AnimState"] then
                inst["sg"]["statemem"]["fx"]["AnimState"]:Pause()
            end
        end,
        ["timeline"] = {
            FrameEvent(2, function(inst)
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/popup")
            end),
            FrameEvent(4, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    inst["sg"]:GoToState("death")
                    return
                end
                inst["sg"]:AddStateTag("noattack")
                inst["sg"]:AddStateTag("temp_invincible")
                inst["DynamicShadow"]:Enable(false)
                SpawnIcePlowFX(inst)
            end),
            FrameEvent(10, function(inst)
                if inst["sg"]["statemem"]["fx"] and inst["sg"]["statemem"]["fx"]["AnimState"] then
                    inst["sg"]["statemem"]["fx"]["AnimState"]:Resume()
                    inst["sg"]["statemem"]["fx"] = nil
                end
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]["statemem"]["fin"] = true
                    inst["sg"]:GoToState("fin_idle")
                end
            end),
        },
        ["onexit"] = function(inst)
            if not inst["sg"]["statemem"]["fin"] then
                inst["DynamicShadow"]:Enable(true)
            end
            if inst["sg"]["statemem"]["fx"] and inst["sg"]["statemem"]["fx"]["AnimState"] then
                inst["sg"]["statemem"]["fx"]["AnimState"]:Resume()
            end
        end,
    },

    State {
        ["name"] = "dive_dig_stun",
        ["tags"] = { "busy", "dizzy", "jumping", "nosleep" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("icedive_stun")
            inst["SoundEmitter"]:PlaySound("meta3/sharkboi/popup")
            local x, y, z = inst["Transform"]:GetWorldPosition()
            SpawnIceImpactFX(inst, x, z)
            SpawnIceHoleFX(inst, x, z)
            inst["Physics"]:SetMotorVelOverride(4, 0, 0)
        end,
        ["timeline"] = {
            --Bounce
            FrameEvent(9, PlayFootstep),
            FrameEvent(12, function(inst)
                inst["Physics"]:SetMotorVelOverride(2, 0, 0)
            end),
            --Bounce
            FrameEvent(17, PlayFootstep),
            FrameEvent(20, function(inst)
                inst["Physics"]:SetMotorVelOverride(1, 0, 0)
            end),
            FrameEvent(21, function(inst)
                inst["Physics"]:SetMotorVelOverride(0.5, 0, 0)
            end),
            FrameEvent(22, function(inst)
                inst["Physics"]:SetMotorVelOverride(0.25, 0, 0)
            end),
            FrameEvent(23, function(inst)
                inst["Physics"]:ClearMotorVelOverride()
                inst["Physics"]:Stop()
            end),

            FrameEvent(29, function(inst)
                PlayFootstep(inst, 0.5)
            end),
            FrameEvent(36, function(inst)
                PlayFootstep(inst, 0.5)
            end),
            FrameEvent(59, function(inst)
                PlayFootstep(inst, 0.75)
            end),
            CommonHandlers["OnNoSleepFrameEvent"](59, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    inst["sg"]:GoToState("death")
                    return
                end
                inst["sg"]:RemoveStateTag("nosleep")
                inst["sg"]:AddStateTag("caninterrupt")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("torpedo_dizzy")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    ---------------------------------------------------------------遁地----------------------------------------------------------------
    State {
        ["name"] = "fin_idle",
        ["tags"] = { "fin", "idle", "canrotate", "nosleep", "noattack", "invisible" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:StopMoving()
            inst:Hide()
            inst["sg"]:SetTimeout(0.6)
        end,
        ["ontimeout"] = function(inst)
            inst["components"]["combat"]:ResetCooldown()
        end,

        ["onexit"] = function(inst)
            local x, y, z = inst["Transform"]:GetWorldPosition()
            inst:Show()
        end,
    },
    State {
        ["name"] = "fin_start",
        ["tags"] = { "fin", "moving", "running", "canrotate", "nosleep", "noattack" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:RunForward()
            inst["AnimState"]:PlayAnimation("fin_pre")
            if not inst["SoundEmitter"]:PlayingSound("loop") then
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/movement_thru_ice", "loop")
            end
        end,
        ["timeline"] = {
            FrameEvent(2, SpawnIcePlowFX),
            FrameEvent(2, SpawnIceTrailFX),
            FrameEvent(4, DoFinWork),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]["statemem"]["fin"] = true
                    inst["sg"]:GoToState("fin")
                end
            end),
        },
        ["onexit"] = function(inst)
            if not inst["sg"]["statemem"]["fin"] then
                inst["SoundEmitter"]:KillSound("loop")
            end
        end,
    },
    State {
        ["name"] = "fin",
        ["tags"] = { "fin", "moving", "running", "canrotate", "nosleep", "noattack" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:RunForward()
            if not inst["AnimState"]:IsCurrentAnimation("fin_loop") then
                inst["AnimState"]:PlayAnimation("fin_loop", true)
            end
            if not inst["SoundEmitter"]:PlayingSound("loop") then
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/movement_thru_ice", "loop")
            end
            inst["sg"]:SetTimeout(inst["AnimState"]:GetCurrentAnimationLength())
        end,
        ["timeline"] = {
            FrameEvent(3, SpawnIcePlowFX),
            FrameEvent(12, SpawnIcePlowFX),
            FrameEvent(21, SpawnIcePlowFX),

            FrameEvent(0, SpawnIceTrailFX),
            FrameEvent(4, SpawnIceTrailFX),
            FrameEvent(9, SpawnIceTrailFX),
            FrameEvent(13, SpawnIceTrailFX),
            FrameEvent(18, SpawnIceTrailFX),
            FrameEvent(22, SpawnIceTrailFX),
            FrameEvent(0, DoFinWork),
            FrameEvent(3, DoFinWork),
            FrameEvent(6, DoFinWork),
            FrameEvent(9, DoFinWork),
            FrameEvent(12, DoFinWork),
            FrameEvent(15, DoFinWork),
            FrameEvent(18, DoFinWork),
            FrameEvent(21, DoFinWork),
            FrameEvent(24, DoFinWork),
        },
        ["ontimeout"] = function(inst)
            inst["sg"]["statemem"]["fin"] = true
            inst["sg"]:GoToState("fin")
        end,

        ["onexit"] = function(inst)
            if not inst["sg"]["statemem"]["fin"] then
                inst["SoundEmitter"]:KillSound("loop")
            end
        end,
    },
    State {
        ["name"] = "fin_stop",
        ["tags"] = { "fin", "canrotate", "nosleep", "noattack" },
        ["onenter"] = function(inst, nextstateparams)
            inst["components"]["locomotor"]:RunForward()
            inst["AnimState"]:PlayAnimation("fin_pst")
            if not inst["SoundEmitter"]:PlayingSound("loop") then
                inst["SoundEmitter"]:PlaySound("meta3/sharkboi/movement_thru_ice", "loop")
            end
            if nextstateparams then
                inst["sg"]["statemem"]["nextstateparams"] = nextstateparams
                inst["sg"]:AddStateTag("jumping")
            end
            SpawnIceTrailFX(inst)
        end,

        ["timeline"] = {
            FrameEvent(5, function(inst)
                inst["SoundEmitter"]:KillSound("loop")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if inst["sg"]["statemem"]["nextstateparams"] then
                        inst["sg"]:GoToState(unpack(inst["sg"]["statemem"]["nextstateparams"]))
                    else
                        inst["sg"]:GoToState("fin_idle")
                    end
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["components"]["locomotor"]:StopMoving()
            inst["SoundEmitter"]:KillSound("loop")
        end,
    },
    ---------------------------------------------------------------遁地----------------------------------------------------------------
}

local function DoFootstep(inst, volume)
    inst["sg"]["mem"]["lastfootstep"] = GetTime()
    PlayFootstep(inst, volume)
end
CommonStates["AddWalkStates"](hh_states,
        {
            ["walktimeline"] = {
                FrameEvent(2, DoFootstep),
                FrameEvent(20, DoFootstep),
            },
        },
        nil, nil, nil,
        {
            ["endonenter"] = function(inst)
                local t = GetTime()
                if (inst["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < t then
                    inst["sg"]["mem"]["lastfootstep"] = t
                    PlayFootstep(inst, 0.5)
                end
            end,
        })

CommonStates["AddRunStates"](hh_states,
        {
            ["starttimeline"] = {
                FrameEvent(1, emptyFn),
            },
            ["runtimeline"] = {
                FrameEvent(2, DoFootstep),
                FrameEvent(16, DoFootstep),
            },
        },
        nil, nil, nil,
        {
            ["endonenter"] = function(inst)
                local t = GetTime()
                if (inst["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < t then
                    inst["sg"]["mem"]["lastfootstep"] = t
                    PlayFootstep(inst, 0.5)
                end
            end,
        })
return StateGraph("hh_sharkboi", hh_states, hh_events, "idle")
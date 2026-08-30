----
---火神
---
local HH_UTILS = require("utils/hh_utils")
require("stategraphs/commonstates")

----
---走路事件
---
local function eventWalkSg(inst, data)
    if not (HH_UTILS:HasComponents(inst, "locomotor") and inst["sg"]) then
        return
    end
    local inst_sg = inst["sg"]
    if inst["components"]["locomotor"]:WantsToMoveForward() then
        if inst_sg:HasStateTag("idle") then
            if data and data["dir"] then
                --转向
                inst["components"]["locomotor"]:SetMoveDir(data["dir"])
            end
            local new_sg = inst["components"]["locomotor"]:WantsToRun() and "run_start" or "walk_start"
            inst_sg:GoToState(new_sg)
        elseif inst_sg:HasStateTag("moving") then
            local should_run = inst["components"]["locomotor"]:WantsToRun()
            if should_run ~= inst_sg:HasStateTag("running") then
                inst_sg:GoToState(should_run and "run_start" or "walk_start")
            end
        end
    elseif inst_sg:HasStateTag("moving") then
        inst_sg:GoToState(inst_sg:HasStateTag("running") and "run_stop" or "walk_stop")
    end
end
----
---攻击事件
---
local function eventAttackSg(inst, data)
    local inst_sg = inst["sg"]
    local check_state = not inst_sg:HasStateTag("busy") and HH_UTILS:NotIsDead(inst)
    if not check_state then
        return false
    end
    local hh_target = data and data["target"] or inst["components"]["combat"]["target"]
    if hh_target and not hh_target:IsValid() then
        hh_target = nil
    end
    if hh_target and inst:IsNear(hh_target, 4.5 + hh_target:GetPhysicsRadius(0)) then
        inst_sg:GoToState("attack_pre", hh_target)
        return true
    end
    return false
end
----
---受到攻击
---
local function eventAttackedSg(inst, data)
    --0.5概率免疫僵直
    local random_num = math["random"]()
    if random_num < 0.5 then
        return
    end
    local inst_sg = inst["sg"]
    if not inst_sg:HasStateTag("busy") or
            inst_sg:HasStateTag("caninterrupt") or
            inst_sg:HasStateTag("frozen")
    then
        --受击会加间隔
        if not CommonHandlers["HitRecoveryDelay"](inst) then
            inst_sg:GoToState("hit")
        end
    end

end
local hh_events = {
    CommonHandlers["OnDeath"](),
    --走路
    EventHandler("locomote", eventWalkSg),
    EventHandler("attacked", eventAttackedSg),
    --攻击sg
    EventHandler("doattack", eventAttackSg),

}

local hh_states = {
    --待机
    State {
        ["name"] = "idle",
        ["tags"] = { "idle", "canrotate" },

        ["onenter"] = function(inst, norotate)
            local inst_sg = inst["sg"]
            --死亡
            if not HH_UTILS:NotIsDead(inst) then
                inst_sg:GoToState("death")
                return
            end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("idle_loop", true)
        end,
        ["onexit"] = function(inst)
        end,
    },
    --死亡
    State {
        ["name"] = "death",
        ["tags"] = { "dead", "busy", "noattack" },
        ["onenter"] = function(inst)
            inst["AnimState"]:PlayAnimation("death")
            inst["Physics"]:Stop()
            RemovePhysicsColliders(inst)
            if HH_UTILS:HasComponents(inst, "lootdropper") then
                inst["components"]["lootdropper"]:DropLoot(inst:GetPosition())
            end
        end,
    },
    State {
        ["name"] = "hit",
        ["tags"] = { "hit", "busy" },
        ["onenter"] = function(inst, data)
            inst["components"]["locomotor"]:StopMoving()
            inst["AnimState"]:PlayAnimation("hit")
        end,
        ["timeline"] = {
            FrameEvent(11, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    inst["sg"]:GoToState("death")
                    return
                elseif inst["sg"]["statemem"]["doattack"] then
                    if eventAttackSg(inst, { ["target"] = inst["sg"]["statemem"]["doattack"] }) then
                        return
                    end
                end
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("doattack", function(inst, data)
                if inst["sg"]:HasStateTag("busy") then
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
    --------------------------------攻击-----------------------------------
    State {
        ["name"] = "attack_pre",
        ["tags"] = { "attack", "busy", },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["Physics"]:Stop()
            inst["AnimState"]:PlayAnimation("atk_pre")
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                inst["sg"]:GoToState("attack")
            end),
        },
    },
    State {
        ["name"] = "attack",
        ["tags"] = { "attack", "busy", },
        ["onenter"] = function(inst)
            inst["Physics"]:Stop()
            inst["AnimState"]:PlayAnimation("atk")
            inst["components"]["combat"]:StartAttack()
        end,

        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                inst["components"]["combat"]:DoAttack()
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst["sg"]:GoToState("idle")
            end),
        },
    },

}

--------------------------------走路------------------------------------------------
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
        {
            ["startwalk"] = "channelcast_walk_pre",
            ["walk"] = "channelcast_walk",
            ["stopwalk"] = "channelcast_walk_pst",
        }, nil, nil,
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
            },
            ["runtimeline"] = {
                FrameEvent(2, DoFootstep),
                FrameEvent(16, DoFootstep),
            },
        },
        {
            ["startrun"] = "run_pre",
            ["run"] = "run_loop",
            ["stoprun"] = "run_pst",
        }, nil, nil,
        {
            ["endonenter"] = function(inst)
                local t = GetTime()
                if (inst["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < t then
                    inst["sg"]["mem"]["lastfootstep"] = t
                    PlayFootstep(inst, 0.5)
                end
            end,
        })
return StateGraph("hh_npc_fire", hh_states, hh_events, "idle")
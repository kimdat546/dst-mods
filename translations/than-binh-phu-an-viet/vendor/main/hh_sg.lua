local HH_UTILS = require("utils/hh_utils")
AddStategraphState("wilson",
        State {
            ["name"] = "hh_fast_sg",
            ["tags"] = { "doing", "busy", "keepchannelcasting" },
            ["onenter"] = function(inst)
                inst["components"]["locomotor"]:Stop()
                inst["AnimState"]:PlayAnimation("pickup")

                inst["sg"]["statemem"]["action"] = inst["bufferedaction"]
                inst["sg"]:SetTimeout(5 * FRAMES)
            end,
            ["timeline"] = {
                TimeEvent(2 * FRAMES, function(inst)
                    inst["sg"]:RemoveStateTag("busy")
                    inst:PerformBufferedAction()
                end),
            },
            ["ontimeout"] = function(inst)
                inst:PerformBufferedAction()
            end,
            ["events"] = {
                EventHandler("animover", function(inst)
                    inst["sg"]:GoToState("idle")
                end),
            },
            ["onexit"] = function(inst)
                if inst["bufferedaction"] == inst["sg"]["statemem"]["action"] and
                        (inst["components"]["playercontroller"] == nil
                                or inst["components"]["playercontroller"]["lastheldaction"] ~= inst["bufferedaction"]) then
                    inst:ClearBufferedAction()
                end
            end,
        })
AddStategraphState("wilson_client",
        State {
            ["name"] = "hh_fast_sg",
            ["tags"] = { "doing", "busy" },
            ["server_states"] = { "doshortaction" },
            ["onenter"] = function(inst)
                inst["components"]["locomotor"]:Stop()
                inst["AnimState"]:PlayAnimation("pickup")
                inst:PerformPreviewBufferedAction()
                inst["sg"]:SetTimeout(5 * FRAMES)
            end,
            ["onupdate"] = function(inst)
                if inst["sg"]:ServerStateMatches() then
                    if inst["entity"]:FlattenMovementPrediction() then
                        inst["sg"]:GoToState("idle", "noanim")
                    end
                elseif inst["bufferedaction"] == nil then
                    inst["sg"]:GoToState("idle", true)
                end
            end,
            ["ontimeout"] = function(inst)
                inst:ClearBufferedAction()
                inst["sg"]:GoToState("idle", true)
            end,
        })
----------------------------------------技能-----------------------------------------------------------
AddStategraphState("wilson",
        State {
            ["name"] = "hh_epee_aoe_start",
            ["tags"] = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

            ["onenter"] = function(inst)
                inst["components"]["locomotor"]:Stop()
                inst["AnimState"]:PlayAnimation("atk_leap_pre")
            end,

            ["events"] = {
                EventHandler("combat_hh_epee", function(inst, data)
                    inst["sg"]:GoToState("hh_epee_aoe", data)
                end),
                EventHandler("animover", function(inst)
                    if inst["AnimState"]:AnimDone() then
                        if inst["AnimState"]:IsCurrentAnimation("atk_leap_pre") then
                            inst["AnimState"]:PlayAnimation("atk_leap_lag")
                            inst:PerformBufferedAction()
                        else
                            inst["sg"]:GoToState("idle")
                        end
                    end
                end),
            },

            ["onexit"] = function(inst)
                --inst.sg:GoToState("idle")
            end,
        }
)

local function ToggleOffPhysics(inst)
    inst["sg"]["statemem"]["isphysicstoggle"] = true
    inst["Physics"]:ClearCollisionMask()
    inst["Physics"]:CollidesWith(COLLISION["GROUND"])
end

local function ToggleOnPhysics(inst)
    inst["sg"]["statemem"]["isphysicstoggle"] = nil
    inst["Physics"]:ClearCollisionMask()
    inst["Physics"]:CollidesWith(COLLISION["WORLD"])
    inst["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
    inst["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
    inst["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
    inst["Physics"]:CollidesWith(COLLISION["GIANTS"])
end

AddStategraphState("wilson",
        State {
            ["name"] = "hh_epee_aoe",
            ["tags"] = { "aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph" },
            ["onenter"] = function(inst, data)
                if data ~= nil and
                        data["targetpos"] ~= nil and
                        data["weapon"] ~= nil and
                        inst["AnimState"]:IsCurrentAnimation("atk_leap_lag") then
                    ToggleOffPhysics(inst)
                    inst["Transform"]:SetEightFaced()
                    inst["AnimState"]:PlayAnimation("atk_leap")
                    inst["SoundEmitter"]:PlaySound("dontstarve/common/deathpoof")
                    inst["sg"]["statemem"]["startingpos"] = inst:GetPosition()
                    inst["sg"]["statemem"]["weapon"] = data["weapon"]
                    inst["sg"]["statemem"]["targetpos"] = data["targetpos"]
                    inst["sg"]["statemem"]["flash"] = 0
                    if inst["sg"]["statemem"]["startingpos"]["x"] ~= data["targetpos"]["x"]
                            or inst["sg"]["statemem"]["startingpos"]["z"] ~= data["targetpos"]["z"]
                    then
                        inst:ForceFacePoint(data["targetpos"]:Get())
                        inst["Physics"]:SetMotorVel(math["sqrt"](distsq(inst["sg"]["statemem"]["startingpos"]["x"],
                                inst["sg"]["statemem"]["startingpos"]["z"], data["targetpos"]["x"], data["targetpos"]["z"])) / (12 * FRAMES),
                                0, 0)
                    end
                    return
                end
                inst["sg"]:GoToState("idle", true)
            end,

            ["onupdate"] = function(inst)
                if inst["sg"]["statemem"]["flash"] and inst["sg"]["statemem"]["flash"] > 0 then
                    inst["sg"]["statemem"]["flash"] = math.max(0, inst["sg"]["statemem"]["flash"] - 0.1)
                    local c = math.min(1, inst["sg"]["statemem"]["flash"])
                    inst["components"]["colouradder"]:PushColour("leap", c, c, 0, 0)
                end
            end,

            ["timeline"] = {
                TimeEvent(10 * FRAMES, function(inst)
                    if inst["sg"]["statemem"]["flash"] then
                        inst["components"]["colouradder"]:PushColour("leap", 0.1, 0.1, 0, 0)
                    end
                end),
                TimeEvent(11 * FRAMES, function(inst)
                    if inst["sg"]["statemem"]["flash"] then
                        inst["components"]["colouradder"]:PushColour("leap", 0.2, 0.2, 0, 0)
                    end
                end),
                TimeEvent(12 * FRAMES, function(inst)
                    if inst["sg"]["statemem"]["flash"] then
                        inst["components"]["colouradder"]:PushColour("leap", 0.4, 0.4, 0, 0)
                    end
                    ToggleOnPhysics(inst)
                    inst["Physics"]:Stop()
                    inst["Physics"]:SetMotorVel(0, 0, 0)
                    inst["Physics"]:Teleport(inst["sg"]["statemem"]["targetpos"]["x"], 0, inst["sg"]["statemem"]["targetpos"]["z"])
                end),
                TimeEvent(13 * FRAMES, function(inst)
                    ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.7, 0.015, .8, inst, 20)
                    if inst["sg"]["statemem"]["flash"] then
                        inst["components"]["bloomer"]:PushBloom("leap", "shaders/anim.ksh", -2)
                        inst["components"]["colouradder"]:PushColour("leap", 1, 1, 0, 0)
                        inst["sg"]["statemem"]["flash"] = 1.3
                    end
                    inst["sg"]:RemoveStateTag("nointerrupt")
                    if inst["sg"]["statemem"]["weapon"]:IsValid() then
                        --todo 执行武器函数
                        --inst.sg.statemem.weapon["components"].aoeweapon_leap:DoLeap(inst, inst.sg.statemem.startingpos, inst.sg.statemem.targetpos)
                    end
                end),
                TimeEvent(25 * FRAMES, function(inst)
                    if inst["sg"]["statemem"]["flash"] then
                        inst["components"]["bloomer"]:PopBloom("leap")
                    end
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
                if inst["sg"]["statemem"]["isphysicstoggle"] then
                    ToggleOnPhysics(inst)
                    inst["Physics"]:Stop()
                    inst["Physics"]:SetMotorVel(0, 0, 0)
                    local x, y, z = inst["Transform"]:GetWorldPosition()
                    if TheWorld["Map"]:IsPassableAtPoint(x, 0, z) and not TheWorld["Map"]:IsGroundTargetBlocked(Vector3(x, 0, z)) then
                        inst["Physics"]:Teleport(x, 0, z)
                    else
                        inst["Physics"]:Teleport(inst["sg"]["statemem"]["targetpos"]["x"], 0, inst["sg"]["statemem"]["targetpos"]["z"])
                    end
                end
                inst["Transform"]:SetFourFaced()
                if inst["sg"]["statemem"]["flash"] then
                    inst["components"]["bloomer"]:PopBloom("leap")
                    inst["components"]["colouradder"]:PopColour("leap")
                end
            end,
        }
)
AddStategraphState("wilson_client",
        State {
            ["name"] = "hh_epee_aoe_start",
            ["tags"] = { "doing", "busy", "nointerrupt" },

            ["onenter"] = function(inst)
                inst["components"]["locomotor"]:Stop()
                inst["AnimState"]:PlayAnimation("atk_leap_pre")
                inst["AnimState"]:PushAnimation("atk_leap_lag", false)

                inst:PerformPreviewBufferedAction()
                inst["sg"]:SetTimeout(2)
            end,

            ["onupdate"] = function(inst)
                if inst:HasTag("doing") then
                    if inst["entity"]:FlattenMovementPrediction() then
                        inst["sg"]:GoToState("idle", "noanim")
                    end
                elseif inst["bufferedaction"] == nil then
                    inst["sg"]:GoToState("idle")
                end
            end,

            ["ontimeout"] = function(inst)
                inst:ClearBufferedAction()
                inst["sg"]:GoToState("idle")
            end,
        }
)
----------------------------------------技能-----------------------------------------------------------
----------------------------------------快速施法-----------------------------------------------------------
local function OnRemoveCleanupTargetFX(inst)
    if inst["sg"]["statemem"]["targetfx"]["KillFX"] ~= nil then
        inst["sg"]["statemem"]["targetfx"]:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
        inst["sg"]["statemem"]["targetfx"]:KillFX()
    else
        inst["sg"]["statemem"]["targetfx"]:Remove()
    end
end
AddStategraphState("wilson",
        State {
            ["name"] = "hh_staff_star",
            ["tags"] = { "doing", "busy", "canrotate" },
            ["onenter"] = function(inst, data)
                if inst["components"]["playercontroller"] ~= nil then
                    inst["components"]["playercontroller"]:Enable(false)
                end
                inst["AnimState"]:PlayAnimation("staff_pre")
                inst["AnimState"]:PushAnimation("staff", false)
                inst["components"]["locomotor"]:Stop()
                --Spawn an effect on the player's location
                local staff = inst["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
                local colour = staff ~= nil and staff["fxcolour"] or { 1, 1, 1 }

                inst["sg"]["statemem"]["stafffx"] = SpawnPrefab(inst["components"]["rider"]:IsRiding() and "staffcastfx_mount" or "staffcastfx")
                inst["sg"]["statemem"]["stafffx"]["entity"]:SetParent(inst["entity"])
                inst["sg"]["statemem"]["stafffx"]:SetUp(colour)

                inst["sg"]["statemem"]["stafflight"] = SpawnPrefab("staff_castinglight")
                inst["sg"]["statemem"]["stafflight"]["Transform"]:SetPosition(inst["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["stafflight"]:SetUp(colour, 1.9, 0.33)

                if staff ~= nil and staff["components"]["aoetargeting"] ~= nil then
                    local buffaction = inst:GetBufferedAction()
                    if buffaction ~= nil then
                        inst["sg"]["statemem"]["targetfx"] = staff["components"]["aoetargeting"]:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                        if inst["sg"]["statemem"]["targetfx"] ~= nil then
                            inst["sg"]["statemem"]["targetfx"]:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                        end
                    end
                end

                if staff ~= nil then
                    inst["sg"]["statemem"]["castsound"] = staff["skin_castsound"] or staff["castsound"] or "dontstarve/wilson/use_gemstaff"
                else
                    inst["sg"]["statemem"]["castsound"] = "dontstarve/wilson/use_gemstaff"
                end
            end,

            ["timeline"] = {
                TimeEvent(13 * FRAMES, function(inst)
                    inst["SoundEmitter"]:PlaySound(inst["sg"]["statemem"]["castsound"])
                end),
                --提前施法
                TimeEvent(25 * FRAMES, function(inst)
                    --V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
                    inst:PerformBufferedAction()
                end),
                TimeEvent(53 * FRAMES, function(inst)
                    if inst["sg"]["statemem"]["targetfx"] ~= nil then
                        if inst["sg"]["statemem"]["targetfx"]:IsValid() then
                            OnRemoveCleanupTargetFX(inst)
                        end
                        inst["sg"]["statemem"]["targetfx"] = nil
                    end
                    inst["sg"]["statemem"]["stafffx"] = nil --Can't be cancelled anymore
                    inst["sg"]["statemem"]["stafflight"] = nil --Can't be cancelled anymore
                end),
                TimeEvent(69 * FRAMES, function(inst)
                    inst["sg"]:RemoveStateTag("busy")
                    if inst["components"]["playercontroller"] ~= nil then
                        inst["components"]["playercontroller"]:Enable(true)
                    end
                end),
            },

            ["events"] = {
                EventHandler("animqueueover", function(inst)
                    if inst["AnimState"]:AnimDone() then
                        inst["sg"]:GoToState("idle")
                    end
                end),
            },

            ["onexit"] = function(inst)
                if inst["components"]["playercontroller"] ~= nil then
                    inst["components"]["playercontroller"]:Enable(true)
                end
                if inst["sg"]["statemem"]["stafffx"] ~= nil and inst["sg"]["statemem"]["stafffx"]:IsValid() then
                    inst["sg"]["statemem"]["stafffx"]:Remove()
                end
                if inst["sg"]["statemem"]["stafflight"] ~= nil and inst["sg"]["statemem"]["stafflight"]:IsValid() then
                    inst["sg"]["statemem"]["stafflight"]:Remove()
                end
                if inst["sg"]["statemem"]["targetfx"] ~= nil and inst["sg"]["statemem"]["targetfx"]:IsValid() then
                    OnRemoveCleanupTargetFX(inst)
                end
            end,
        }
)
AddStategraphState("wilson_client",
        State {
            ["name"] = "hh_staff_star",
            ["tags"] = { "doing", "busy", "canrotate" },
            ["server_states"] = { "hh_staff_star" },
            ["onenter"] = function(inst)
                inst["components"]["locomotor"]:Stop()
                inst["AnimState"]:PlayAnimation("staff_pre")
                inst["AnimState"]:PushAnimation("staff_lag", false)
                inst:PerformPreviewBufferedAction()
                inst["sg"]:SetTimeout(2)
            end,

            ["onupdate"] = function(inst)
                if inst["sg"]:ServerStateMatches() then
                    if inst["entity"]:FlattenMovementPrediction() then
                        inst["sg"]:GoToState("idle", "noanim")
                    end
                elseif inst["bufferedaction"] == nil then
                    inst["sg"]:GoToState("idle")
                end
            end,

            ["ontimeout"] = function(inst)
                inst:ClearBufferedAction()
                inst["sg"]:GoToState("idle")
            end,
        }
)
----------------------------------------快速施法-----------------------------------------------------------
----
---处理快速动作
---
local function hookFastAction(sg, act_id, is_server)
    local oldPick = sg["actionhandlers"][act_id]["deststate"]
    sg["actionhandlers"][act_id]["deststate"] = function(inst, action)
        ----------------垃圾场不能快采-----------------------
        if act_id == ACTIONS["PICK"] and HH_UTILS:IsHHType(action, "table") then
            local act_target = action["target"]
            if HH_UTILS:IsHHType(act_target, "table") and act_target["prefab"] == "junk_pile_big" then
                return oldPick(inst, action)
            end
            --HH_UTILS:HHPrint(action)
        end
        ----------------垃圾场不能快采-----------------------
        local new_sg = "hh_fast_sg"
        if act_id == ACTIONS["BUILD"] or act_id == ACTIONS["HARVEST"] then
            new_sg = "doshortaction"
        end
        if is_server then
            if HH_UTILS:HasComponents(inst, "hh_player")
                    and inst["components"]["hh_player"]:HasSpecialEffect("fast_act")
            then
                return new_sg
            end
        else
            if HH_UTILS:HasComponents(inst, "hh_client") then
                local hh_fast_client = HH_UTILS:GetClientValue(inst, "hh_fast_act")
                if hh_fast_client then
                    return new_sg
                end
            end
        end
        return oldPick(inst, action)
    end
end
local function hookOldWeaponAct(sg, act_id, act_item_list, is_server)
    if not HH_UTILS:IsHHType(act_item_list, "table") then
        return
    end
    local oldAct = sg["actionhandlers"][act_id]["deststate"]
    sg["actionhandlers"][act_id]["deststate"] = function(inst, action)
        local hh_equip = nil
        local is_riding = false
        if is_server then
            hh_equip = inst["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
            is_riding = inst["components"]["rider"] ~= nil and inst["components"]["rider"]:IsRiding()
        else
            hh_equip = inst["replica"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
            is_riding = inst["replica"]["rider"] ~= nil and inst["replica"]["rider"]:IsRiding()
        end
        if hh_equip and not is_riding and hh_equip["prefab"] and HH_UTILS:IsHHType(act_item_list[hh_equip["prefab"]], "string") then
            return act_item_list[hh_equip["prefab"]]
        end
        return oldAct(inst, action)
    end
end
local weapon_act_sg = {
    ["hh_epee"] = "hh_epee_aoe_start",
    ["hh_staff_star"] = "hh_staff_star",
}
STRINGS["ACTIONS"]["CASTAOE"][string["upper"]("hh_epee")] = "测试技能"
STRINGS["ACTIONS"]["CASTAOE"][string["upper"]("hh_staff_star")] = "召唤流星"
-----------------------------------攻速---------------------------------------------
----
---四舍五入
---
local function handleLittleNum(num)
    return math["floor"](num + 0.5)
end
local function hookComAttackSg(old_sg)
    if not HH_UTILS:IsHHType(old_sg["timeline"], "table") then
        return
    end

    --记录每一段时间函数中的时间
    for k, v in pairs(old_sg["timeline"]) do
        if HH_UTILS:IsHHType(v, "table")
                and HH_UTILS:IsHHType(v["time"], "number")
        then
            v["hh_max_time"] = handleLittleNum(v["time"] / FRAMES)
        end
    end

    local old_onenter = old_sg["onenter"]
    old_sg["onenter"] = function(inst, ...)
        if old_onenter then
            old_onenter(inst, ...)
        end
        local current_speed = HH_UTILS:GetWeaponAtkSpeed(inst)
        --print(inst["sg"]["timeout"])
        local old_time_out = inst["sg"]["timeout"]
        --print("间隔", old_time_out)
        inst["AnimState"]:SetDeltaTimeMultiplier(current_speed)
        --实时更改sg的timeline表对应时间段函数对应时间索引
        for k, v in pairs(old_sg["timeline"]) do
            if HH_UTILS:IsHHType(v, "table") and HH_UTILS:IsHHType(v["hh_max_time"], "number") then
                v["time"] = handleLittleNum(v["hh_max_time"] / current_speed) * FRAMES
            end
        end
        --设置攻击间隔(服务端)
        if HH_UTILS:HasComponents(inst, "combat") then
            local combat_com = inst["components"]["combat"]
            if not inst["hh_new_min_atk_period"] then
                inst["hh_new_min_atk_period"] = combat_com["min_attack_period"] or inst:HasTag("player") and 0.5 or 4
            end
            combat_com["min_attack_period"] = inst["hh_new_min_atk_period"] / current_speed
        end
        if HH_UTILS:IsHHType(old_time_out, "number") and current_speed > 1 then
            --inst["sg"]:SetTimeout(old_time_out / (current_speed * (current_speed + 0.5) / 2))
            inst["sg"]:SetTimeout(old_time_out / (current_speed * 1))
            --print("新间隔", old_time_out / (current_speed * 2) + FRAMES)
        end
    end
    local old_onexit = old_sg["onexit"]
    old_sg["onexit"] = function(inst, ...)
        if old_onexit then
            old_onexit(inst, ...)
        end
        inst["sg"]:RemoveStateTag("abouttoattack")
        inst["sg"]:RemoveStateTag("attack")
        inst["AnimState"]:SetDeltaTimeMultiplier(1)
    end
end
local sg_change_list = {
    ["attack"] = hookComAttackSg,
    ["mcwattack"] = hookComAttackSg,
    --["slingshot_shoot"] = hookComAttackSg,
    --["mcw_blow_shoot"] = hookComAttackSg,
}
-----------------------------------攻速---------------------------------------------
---
---免疫负面sg
---
local function immunitySg(sg, sg_id, ability_id)
    if not sg or not sg["events"] then
        return
    end
    local knockedout_sg = sg["events"][sg_id]
    if knockedout_sg and knockedout_sg["fn"] then
        local oldSleepFn = knockedout_sg["fn"]
        local hh_effect = ability_id
        knockedout_sg["fn"] = function(inst, ...)
            if HH_UTILS:HasComponents(inst, "hh_player") and inst["components"]["hh_player"]:HasSpecialEffect(hh_effect) then
                return
            end
            if oldSleepFn then
                oldSleepFn(inst, ...)
            end
        end
    end
end
AddStategraphPostInit("wilson", function(sg)
    --local oldATTACK = sg["actionhandlers"][ACTIONS["ATTACK"]]["deststate"]
    --sg["actionhandlers"][ACTIONS["ATTACK"]]["deststate"] = function(inst, action)
    --    if inst and inst["components"] and inst["components"]["inventory"]
    --            and not (inst["components"]["rider"] ~= nil and
    --            inst["components"]["rider"]:IsRiding())
    --    then
    --        local equip = inst["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
    --        if equip then
    --            if equip:HasTag("hh_fast_atk") then
    --                return "hh_fast_attack_pre"
    --            end
    --        end
    --    end
    --    return oldATTACK(inst, action)
    --end
    if TUNING["HH_ATK_SPEED_BOOL"] then
        for i, v in pairs(sg_change_list) do
            if HH_UTILS:IsHHType(v, "function") and sg["states"] and sg["states"][i] then
                v(sg["states"][i])
            end
        end
    end
    hookFastAction(sg, ACTIONS["BUILD"], true)
    hookFastAction(sg, ACTIONS["PICK"], true)
    hookFastAction(sg, ACTIONS["COOK"], true)
    hookFastAction(sg, ACTIONS["GIVE"], true)
    hookFastAction(sg, ACTIONS["HARVEST"], true)
    hookOldWeaponAct(sg, ACTIONS["CASTAOE"], weapon_act_sg, true)
    immunitySg(sg, "knockedout", "immunitySleep")--免疫催眠
    immunitySg(sg, "yawn", "immunitySleep")--免疫催眠
    immunitySg(sg, "suspended", "immunityStick")--免疫恶液
    immunitySg(sg, "knockback", "immunityKnockBack")--免疫击飞
    immunitySg(sg, "mindcontrolled", "immunityKnockBack")--免疫击飞(算作免疫控制)
end)
AddStategraphPostInit("wilson_client", function(sg)
    --local oldATTACK = sg["actionhandlers"][ACTIONS["ATTACK"]]["deststate"]
    --sg["actionhandlers"][ACTIONS["ATTACK"]]["deststate"] = function(inst, action)
    --    if inst and inst["replica"] and inst["replica"]["inventory"]
    --            and not (inst["replica"]["rider"] ~= nil and
    --            inst["replica"]["rider"]:IsRiding())
    --    then
    --        local equip = inst["replica"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
    --        if equip then
    --            if equip:HasTag("hh_fast_atk") then
    --                return "hh_fast_attack_pre"
    --            end
    --        end
    --    end
    --    return oldATTACK(inst, action)
    --end
    if TUNING["HH_ATK_SPEED_BOOL"] then
        for i, v in pairs(sg_change_list) do
            if HH_UTILS:IsHHType(v, "function") and sg["states"] and sg["states"][i] then
                v(sg["states"][i])
            end
        end
    end
    hookFastAction(sg, ACTIONS["BUILD"], false)
    hookFastAction(sg, ACTIONS["PICK"], false)
    hookFastAction(sg, ACTIONS["COOK"], false)
    hookFastAction(sg, ACTIONS["GIVE"], false)
    hookFastAction(sg, ACTIONS["HARVEST"], false)
    hookOldWeaponAct(sg, ACTIONS["CASTAOE"], weapon_act_sg, false)
end)
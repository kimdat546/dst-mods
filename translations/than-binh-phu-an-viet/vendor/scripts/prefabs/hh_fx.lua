local HH_UTILS = require("utils/hh_utils")
local function hh_common_fx()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddAnimState()
    inst["entity"]:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    --inst["Transform"]:SetFourFaced()

    inst["AnimState"]:SetBank("bramblefx")
    inst["AnimState"]:SetBuild("bramblefx")
    inst["AnimState"]:PlayAnimation("idle")

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end

    inst["persists"] = false
    inst:ListenForEvent("animover", function(_inst)
        if _inst["not_need_remove"] then
            return
        end
        _inst:Remove()
    end)
    return inst
end
local max_scale = 0.8
local function hh_indicator_fx()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddAnimState()
    inst["entity"]:AddSoundEmitter()
    inst["entity"]:AddNetwork()

    inst["AnimState"]:SetBank("reticuleaoe")
    inst["AnimState"]:SetBuild("reticuleaoe")
    inst["AnimState"]:PlayAnimation("idle_target")
    inst["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    inst["AnimState"]:SetLayer(LAYER_BACKGROUND)
    inst["AnimState"]:SetSortOrder(3)
    inst["AnimState"]:SetScale(max_scale, max_scale)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end
    inst["persists"] = false
    return inst
end

----
---抛射物特效
---水球击中quagmire_portalspawn_fx
---爆炸explode_small_slurtlehole
---
local function hh_project_fx()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddAnimState()
    inst["entity"]:AddNetwork()
    inst["entity"]:AddSoundEmitter()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("projectile")

    inst["AnimState"]:SetBank("hh_project")
    inst["AnimState"]:SetBuild("hh_project")
    inst["AnimState"]:PlayAnimation("idle_loop", true)
    inst["entity"]:Hide()
    --inst["AnimState"]:SetBank("hh_project")
    --inst["AnimState"]:SetBuild("hh_project")
    --inst["AnimState"]:PlayAnimation("idle_loop", true)
    --inst["AnimState"]:SetLightOverride(-1)
    --inst["AnimState"]:OverrideSymbol("moon_glow", "fireball_2_fx", "moon_glow")
    --inst["AnimState"]:OverrideSymbol("glow", "fireball_2_fx", "glow")
    --inst["AnimState"]:OverrideSymbol("moon_glow", "fireball_2_fx", "moon_glow")

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end
    inst["persists"] = false

    inst["hh_child_list"] = {}

    return inst
end

local function light_fx()
    local inst = CreateEntity()

    inst["entity"]:AddTransform()
    inst["entity"]:AddLight()
    inst["entity"]:AddSoundEmitter()
    inst["entity"]:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst["Light"]:SetIntensity(0.6)
    inst["Light"]:SetRadius(5)
    inst["Light"]:SetFalloff(2)
    inst["Light"]:Enable(false)
    inst["Light"]:SetColour(255 / 255, 255 / 255, 255 / 255)

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end
    inst["Light"]:Enable(true)

    inst["persists"] = false

    return inst
end
local function item_light_fx()
    local inst = CreateEntity()

    inst["entity"]:AddTransform()
    inst["entity"]:AddLight()
    inst["entity"]:AddSoundEmitter()
    inst["entity"]:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst["Light"]:SetIntensity(0.6)
    inst["Light"]:SetRadius(1)
    inst["Light"]:SetFalloff(0.5)
    inst["Light"]:Enable(false)
    inst["Light"]:SetColour(255 / 255, 255 / 255, 255 / 255)

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end
    inst["Light"]:Enable(true)

    inst["persists"] = false

    return inst
end

local bow_project_assets = {
    Asset("ANIM", "anim/fireball_2_fx.zip"),
    Asset("ANIM", "anim/deer_fire_charge.zip"),
}

----
---该函数通过计算两个点的中点，并在这个基础上加上一个由距离、角度和系数决定的偏移量，返回一个新的 Vector3 对象
---
local function getNewOffsetPos(start_pos, end_pos, offset_distance, offset_angle)
    offset_distance = offset_distance or 1
    offset_angle = math["rad"](offset_angle or 90)
    --两点之间的距离
    local end_distance = start_pos:Dist(end_pos)
    --计算两点的方位角
    local pos_angle = math["atan2"](end_pos["z"] - start_pos["z"], end_pos["x"] - start_pos["x"])
    local length_y = end_distance / 2 * offset_distance * math["sin"](offset_angle)
    --以角度为x轴的直角坐标系的平移距离
    local length_xz = end_distance / 2 * offset_distance * math["cos"](offset_angle)
    local ox, oy, oz = length_xz * math["cos"](pos_angle + math["pi"] / 2), length_y, length_xz * math["sin"](pos_angle + math["pi"] / 2)
    return Vector3((start_pos["x"] + end_pos["x"]) / 2 + ox, (start_pos["y"] + end_pos["y"]) / 2 + oy, (start_pos["z"] + end_pos["z"]) / 2 + oz)
end
----
---背后为起点的曲线坐标 三次贝塞尔曲线的公式
---@param start_pos:起点坐标
---@param control_pos_a:控制点1
---@param control_pos_b:控制点2
---@param end_pos:终点
---@param special_num:插值因子
---
local function getSpecialNewPos(start_pos, control_pos_a, control_pos_b, end_pos, special_num)
    local hh_num = 1 - special_num
    return start_pos * hh_num * hh_num * hh_num + control_pos_a * 3 * special_num * hh_num * hh_num + control_pos_b * 3 * special_num * special_num * hh_num + end_pos * special_num * special_num * special_num
end
----
---贝塞尔曲线的二次插值公式
---@param start_pos:起点
---@param control_pos:控制点/当前点
---@param end_pos:终点
---@param change_distance:帧改变的距离
---
local function getBSENewPos(start_pos, control_pos, end_pos, change_distance)
    return start_pos * (1 - change_distance) * (1 - change_distance) + control_pos * 2 * change_distance * (1 - change_distance) + end_pos * change_distance * change_distance
end
local function NewHit(self, target, ...)
    self["hh_last_owner"] = self["owner"]
    if self["hh_motion_state"] then
        local hh_owner = self["owner"]
        local hh_inst = self["inst"]
        self:Stop()
        self["inst"]["Physics"]:Stop()
        --传参-决定攻击者
        if not hh_owner["components"]["combat"] and hh_owner["components"]["weapon"] and hh_owner["components"]["inventoryitem"] then
            hh_inst = hh_owner
            hh_owner = hh_inst["components"]["inventoryitem"]["owner"]
        end
        if hh_owner and hh_owner["components"]["combat"] and target and target["IsValid"] then
            hh_owner["components"]["combat"]:DoAttack(target, hh_inst, self["inst"])
        end
        if self["onhit"] then
            self["onhit"](self["inst"], hh_owner, target, hh_inst)
        end
    else
        return self["HHOldHit"](self, target, ...)
    end
end
local function Throw(self, owner, target, attacker, ...)
    --校验状态
    if self["hh_motion_state"] then
        local inst = self["inst"]
        local target_is_valid = target and target["IsValid"] ~= nil
        self["owner"] = owner
        self["target"] = target_is_valid and target
        self["hitPointHeight"] = 0
        self["start"] = Vector3(owner["Transform"]:GetWorldPosition())
        self["dest"] = target_is_valid and Vector3(target["Transform"]:GetWorldPosition()) + Vector3(0, self["hitPointHeight"], 0) or target
        if not target_is_valid then
            self["homing"] = false
        end
        --初始偏移
        local hh_offset_pos = self["launchoffset"]
        if attacker and attacker["Transform"]
                and attacker["Transform"]["GetRotation"] and hh_offset_pos then
            --初始偏移
            local inst_pos = inst:GetPosition()
            local attacker_angle_pow = attacker["Transform"]:GetRotation() * DEGREES
            local attacker_offset_pos = Vector3(hh_offset_pos["x"] * math["cos"](attacker_angle_pow), hh_offset_pos["y"], -hh_offset_pos["x"] * math["sin"](attacker_angle_pow))
            inst_pos = inst_pos + attacker_offset_pos
            inst["Transform"]:SetPosition(inst_pos:Get())
        elseif target_is_valid and target["Transform"]
                and target["Transform"]["GetRotation"]
                and hh_offset_pos then
            --针对目标进行偏移
            local inst_pos = inst:GetPosition()
            --目标方向
            local target_angle_pow = target["Transform"]:GetRotation() * DEGREES
            local target_offset_pos = Vector3(hh_offset_pos["x"] * math["cos"](target_angle_pow), hh_offset_pos["y"], -hh_offset_pos["x"] * math["sin"](target_angle_pow))
            inst_pos = inst_pos + target_offset_pos
            inst["Transform"]:SetPosition(inst_pos:Get())
        end
        inst:StartUpdatingComponent(self)
        inst:PushEvent("onthrown", { ["thrower"] = owner, ["target"] = target_is_valid and target or nil })
        if target_is_valid then
            target:PushEvent("hostileprojectile", { ["thrower"] = owner, ["attacker"] = attacker, ["target"] = target })
        end
        if self["onthrown"] then
            self["onthrown"](self["inst"], owner, target_is_valid and target or nil)
        end
        if self["cancatch"] and target_is_valid and target["components"]["catcher"] then
            target["components"]["catcher"]:StartWatching(self["inst"])
        end
        --初始化移速+记录坐标
        local hh_inst_self = self["inst"]
        hh_inst_self["Physics"]:SetVel(0, 0, 0)
        self["hh_start_pos"] = Vector3(hh_inst_self["Transform"]:GetWorldPosition())
        --记录运行距离
        self["hh_save_dist"] = 0
    else
        return self["HHOldThrow"](self, owner, target, attacker, ...)
    end
end
local function OnUpdate(self, dt, ...)
    if self["hh_motion_state"] then
        local hh_target = self["target"]
        --判断目标是否是有效的 无效则算作miss
        if self["homing"] and (not hh_target or not hh_target:IsValid() or hh_target:IsInLimbo()) then
            self:Miss(hh_target)
            return
        end
        local hh_inst = self["inst"]
        if self["homing"] and hh_target and hh_target:IsValid() and not hh_target:IsInLimbo() then
            --目标高度偏移
            self["dest"] = Vector3(hh_target["Transform"]:GetWorldPosition()) + Vector3(0, self["hitPointHeight"], 0)
        end
        local target_end_pos = self["dest"]
        local attacker_pos = self["hh_start_pos"]
        local current_pos = Vector3(hh_inst["Transform"]:GetWorldPosition())
        --已经运行的距离
        local hh_current_distance = self["hh_save_dist"]
        --贝塞尔计算距离 状态为3时运行的距离
        local dt_bezier_dist = self["hh_bezier_calc_dist"]
        dt_bezier_dist = dt_bezier_dist and dt_bezier_dist > 0 and dt_bezier_dist or math["sqrt"](math["pow"](attacker_pos["x"] - target_end_pos["x"], 2) + math["pow"](attacker_pos["z"] - target_end_pos["z"], 2))
        --运行距离占比时间
        local hh_current_time = hh_current_distance / dt_bezier_dist
        --帧距离
        local dt_speed = self["speed"] * TheSim:GetTickTime() * TheSim:GetTimeScale()
        hh_current_time = math["min"](1, hh_current_time + dt_speed / dt_bezier_dist)
        self["hh_save_dist"] = self["hh_save_dist"] + dt_speed
        local new_pos = nil
        if self["hh_motion_state"] == 3 and self["hh_bezier_pa"] and self["hh_bezier_pb"] then
            new_pos = getSpecialNewPos(attacker_pos, self["hh_bezier_pa"], self["hh_bezier_pb"], target_end_pos, hh_current_time)
        else
            --控制点的坐标
            local control_pos = nil
            if self["homing"] then
                control_pos = getNewOffsetPos(attacker_pos, target_end_pos, self["hh_bezier_h"], self["hh_bezier_angle"])
            else
                --找中点
                if not self["hh_mid_point"] then
                    self["hh_mid_point"] = getNewOffsetPos(attacker_pos, target_end_pos, self["hh_bezier_h"], self["hh_bezier_angle"])
                end
                control_pos = self["hh_mid_point"]
            end
            new_pos = getBSENewPos(attacker_pos, control_pos, target_end_pos, hh_current_time)
        end
        hh_inst["Transform"]:SetPosition(new_pos:Get())
        --判断是否到达命中范围内
        local target_distance = math["sqrt"](math["pow"](new_pos["x"] - target_end_pos["x"], 2) + math["pow"](new_pos["z"] - target_end_pos["z"], 2))
        if target_distance <= self["hitdist"] then
            self:Hit(hh_target)
            return
        end
        --最大距离限制
        local current_distance = new_pos:Dist(attacker_pos)
        if self["range"] and current_distance > self["range"] then
            self:Miss(hh_target)
            return
        end
    else
        return self["HHOldOnUpdate"](self, dt, ...)
    end
end
--设置高度+角度
local function HHSetBezier(self, height, angle)
    --运动状态
    self["hh_motion_state"] = 2
    --曲线高度
    self["hh_bezier_h"] = height or 1
    --起始角度
    self["hh_bezier_angle"] = angle or 90
end
--偏移曲线
local function HHSetBezier3(self, _a2Vc, _Ab5y)
    self["hh_motion_state"] = 3
    self["hh_bezier_pa"] = _a2Vc
    self["hh_bezier_pb"] = _Ab5y
end
local function HHSetBezierCalcDist(self, hh_dist)
    --贝塞尔计算距离
    self["hh_bezier_calc_dist"] = hh_dist
end
local function hookProjectile(self)
    self["HHOldOnUpdate"] = self["OnUpdate"]
    self["OnUpdate"] = OnUpdate
    self["HHOldThrow"] = self["Throw"]
    self["Throw"] = Throw
    self["HHOldHit"] = self["Hit"]
    self["Hit"] = NewHit
    self["SetBezier"] = HHSetBezier
    self["SetBezier3"] = HHSetBezier3
    self["SetBezierCalcDist"] = HHSetBezierCalcDist
end

local function bow_project_fn()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddAnimState()
    inst["entity"]:AddNetwork()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst["AnimState"]:SetBank("fireball_fx")
    inst["AnimState"]:SetBuild("fireball_2_fx")
    inst["AnimState"]:PlayAnimation("idle_loop", true)
    inst["entity"]:Hide()

    inst:AddTag("projectile")

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end

    inst["persists"] = false

    inst:AddComponent("projectile")
    --更改为抛物线
    hookProjectile(inst["components"]["projectile"])
    inst["components"]["projectile"]:SetLaunchOffset(Vector3(0.8, 2.25, 0))--设置发射偏移量
    inst["components"]["projectile"]:SetSpeed(15)
    --inst["components"]["projectile"]:SetHoming(true)
    --inst["components"]["projectile"]:SetHitDist(0.5)
    inst["components"]["projectile"]["onhit"] = function(inst, owner, target)
        local hit_fx = HH_UTILS:SpawnCommonFx(inst)
        if hit_fx then
            hit_fx["AnimState"]:SetBank("fireball_fx")
            hit_fx["AnimState"]:SetBuild("deer_fire_charge")
            hit_fx["AnimState"]:PlayAnimation("blast")
        end
        inst:Remove()
    end
    inst["components"]["projectile"]:SetOnMissFn(inst["Remove"])
    --设置死亡描述
    inst["components"]["projectile"]:SetStimuli("fire")

    --inst["components"]["projectile"]:SetBezier(1.5)
    return inst
end
return
Prefab("hh_common_fx", hh_common_fx),
Prefab("hh_indicator_fx", hh_indicator_fx), --范围指示器
Prefab("hh_project_fx", hh_project_fx), --怪物抛射物特效
Prefab("hh_bow_project", bow_project_fn, bow_project_assets),
Prefab("hh_light_fx", light_fx), --光
Prefab("hh_item_light_fx", item_light_fx) --道具放地上的光
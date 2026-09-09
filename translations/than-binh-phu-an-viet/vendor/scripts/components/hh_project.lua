local HH_UTILS = require("utils/hh_utils")
local max_height_config = 5
----
---抛射物组件
---
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --起点
    self["start_pos"] = Vector3(0, 5, 0)
    --终点
    self["end_pos"] = Vector3(0, 0, 0)
    --抛物线高度
    self["max_height"] = max_height_config
    --角度
    self["angle"] = 0
    --是否是上升过程
    self["up_bool"] = true
    --每帧位移距离
    self["speed"] = 4 / 60
    self["owner"] = nil
    self["hit_fn"] = nil
end)
function HH_COM:SetSpeed(hh_speed)
    if HH_UTILS:IsHHType(hh_speed, "number") and hh_speed > 0 then
        self["speed"] = hh_speed
    end
end
function HH_COM:SetIsUp(hh_bool)
    self["up_bool"] = hh_bool
end

function HH_COM:SetOwner(hh_owner)
    self["owner"] = hh_owner
end
function HH_COM:SetHitFn(hh_fn)
    self["hit_fn"] = hh_fn
end
----
---抛物线
---
function HH_COM:Throw(owner, target_pos, hh_time)
    if not self["inst"]["Transform"] then
        return false
    end
    if not target_pos["x"] or not target_pos["y"] or not target_pos["z"] then
        return false
    end
    if owner then
        self:SetOwner(owner)
    end
    local project_time = 2
    if HH_UTILS:IsHHType(hh_time, "number") and hh_time > 0 then
        project_time = hh_time
    end
    local hh_fx_x, hh_fx_y, hh_fx_z = self["inst"]["Transform"]:GetWorldPosition()
    self["start_pos"] = Vector3(hh_fx_x, hh_fx_y, hh_fx_z)
    --计算速度
    local end_x, end_y, end_z = target_pos["x"], target_pos["y"], target_pos["z"]
    self["end_pos"] = target_pos

    local hh_distance = HH_UTILS:GetDistance(hh_fx_x, hh_fx_z, end_x, end_z)
    --登记距离
    self["distance"] = hh_distance
    --print("总距离", hh_distance)
    self:SetSpeed(hh_distance / (hh_time / FRAMES))

    local hh_angle = self["inst"]:GetAngleToPoint(target_pos)
    if hh_angle < 0 then
        hh_angle = hh_angle + 360
    end
    self["angle"] = -hh_angle

    self:SetIsUp(true)
    self["inst"]:StartUpdatingComponent(self)
    --防止不及时删除
    self["inst"]:DoTaskInTime(project_time * 2, self["inst"]["Remove"])
end
function HH_COM:OnUpdate(dt)
    local hh_fx_x, hh_fx_y, hh_fx_z = self["inst"]["Transform"]:GetWorldPosition()
    if (self["up_bool"] == false and hh_fx_y <= 0) or not self["angle"] or not self["distance"] then
        self["inst"]:StopUpdatingComponent(self)
        --命中
        if self["hit_fn"] then
            self["hit_fn"](self["inst"], self["owner"])
        end
    end
    if hh_fx_y >= self["max_height"] then
        self:SetIsUp(false)
    end
    local new_x, new_y, new_z = hh_fx_x, hh_fx_y, hh_fx_z
    local hh_angle = self["angle"]
    new_x = new_x + self["speed"] * math["cos"](hh_angle * DEGREES)
    new_z = new_z + self["speed"] * math["sin"](hh_angle * DEGREES)
    --计算y轴
    local start_x, start_y, start_z = self["start_pos"]["x"], self["start_pos"]["y"], self["start_pos"]["z"]
    local hh_distance = HH_UTILS:GetDistance(start_x, start_z, new_x, new_z)
    --print("距离", hh_distance)
    --计算抛物线函数
    local parabola_a, parabola_b, parabola_c = HH_UTILS:SolveParabolaEquation({ { 0, 0 }, { self["distance"] / 2, self["max_height"] }, { self["distance"], 0 } })
    if parabola_a and parabola_b and parabola_c then
        new_y = parabola_a * (hh_distance ^ 2) + parabola_b * hh_distance + parabola_c
    end
    --print(new_y)
    if new_y < 0 then
        self["inst"]:StopUpdatingComponent(self)
        --命中
        if self["hit_fn"] then
            self["hit_fn"](self["inst"], self["owner"])
        end
    end
    new_y = math["max"](new_y, 0)
    self["inst"]["Transform"]:SetPosition(new_x, new_y, new_z)
    --local distance_percent = hh_distance / self["distance"]
    --local end_x, ens_y = self["end_pos"]["x"], self["end_pos"]["y"]
    --new_y = 10 - 0.5 * ((hh_distance) ^ 2)
    --print(new_y)
    --new_y = math["max"](new_y, 0)
    ----print(new_x, new_y, new_z)
    --self["inst"]["Transform"]:SetPosition(new_x, new_y, new_z)
end

return HH_COM
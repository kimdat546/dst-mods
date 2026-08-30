local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")
local TrueScrollArea = require("widgets/truescrollarea")
local UIAnim = require("widgets/uianim")
local HH_TEXT = require("enums/hh_text_config")
local HH_LANGUAGE = require("enums/hh_language")
local HH_UTILS = {}

----
---打印对象
---@param data:打印的对象
---
function HH_UTILS:HHPrint(data)
    print("============================煎蛋工具类打印对象开始========================================")
    print("时间:", os.date(), " 打印类型:", type(data), " 打印对象:", data)
    if type(data) == 'table' then
        print(data, "\n{")
        for i, v in pairs(data) do
            print("\t[" .. tostring(i) .. "] ==>", v)
        end
        print("}")
    else
        print("打印==>", data)
    end
    print("时间:", os.date(), " 打印结束")
    print("============================煎蛋工具类打印对象开始========================================")
end
function HH_UTILS:HHCopyTable(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[HH_UTILS:HHCopyTable(orig_key, copies)] = HH_UTILS:HHCopyTable(orig_value, copies)
            end
            setmetatable(copy, HH_UTILS:HHCopyTable(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    return copy
end

function HH_UTILS:HHSay(inst, str)
    if inst and inst["components"] and inst["components"]["talker"] then
        inst["components"]["talker"]:Say(tostring(str))
    end
end

function HH_UTILS:HasComponents(inst, str)
    if inst and inst["components"] and inst["components"][str] then
        return true
    else
        return false
    end
end

function HH_UTILS:HasReplica(inst, str)
    if inst and inst["replica"] and inst["replica"][str] then
        return true
    else
        return false
    end
end

function HH_UTILS:GetClientValue(player, value_key)
    if not HH_UTILS:HasComponents(player, "hh_client") then
        return nil
    end
    return player["components"]["hh_client"]:GetValue(value_key)
end
----
---获取加成攻速
---
function HH_UTILS:GetWeaponAtkSpeed(inst)
    local base_speed = 1
    local add_speed = 0
    if HH_UTILS:HasComponents(inst, "hh_player") then
        --服务端
        add_speed = inst["components"]["hh_player"]:GetEffectValueByKey("atk_speed")
    elseif HH_UTILS:HasComponents(inst, "hh_client") then
        --延迟补偿-客机部分
        add_speed = HH_UTILS:GetClientValue(inst, "hh_atk_speed")
        add_speed = tonumber(add_speed) or 0
    end
    --上限2 下限0.5
    local result_speed = base_speed + add_speed / 100
    result_speed = math["min"](result_speed, 2)
    result_speed = math["max"](result_speed, 0.5)
    return result_speed
end
----
---ui滑轮hook不允许滚轮拖动视野
---
function HH_UTILS:HookFocusCamera(ui)
    local oldOnGainFocus = ui["OnGainFocus"]
    ui["OnGainFocus"] = function(self, ...)
        TheCamera:SetControllable(false)
        if oldOnGainFocus then
            oldOnGainFocus(self, ...)
        end
    end
    local oldOnLoseFocus = ui["OnLoseFocus"]
    ui["OnLoseFocus"] = function(self, ...)
        TheCamera:SetControllable(true)
        if oldOnLoseFocus then
            oldOnLoseFocus(self, ...)
        end
    end

end

----
---客户端部分推送事件
---
function HH_UTILS:SetClientValue(player, value_key, value)
    if not HH_UTILS:HasComponents(player, "hh_client") then
        return nil
    end
    return player["components"]["hh_client"]:SetValue(value_key, value)
end
function HH_UTILS:HHCreateImageUi(father, xml, tex, pos, size_x, size_y, color)
    local hh_ui = father:AddChild(Image(xml, tex))
    hh_ui:SetPosition(pos)
    if size_x and size_y then
        hh_ui:SetSize(size_x, size_y)
    end
    if color and type(color) == 'table' and #color == 4 then
        hh_ui:SetTint(color[1], color[2], color[3], color[4])
    end
    return hh_ui
end
----
---宝藏权重随机表
---格式
---local test={
----   { name = "id",chance = 40,  },
----   { name = "id",chance = 30,  },
----}
---
function HH_UTILS:GetRandomTreasure(hh_table)
    local hh_list = {}
    local max_num = 0
    for i, v in ipairs(hh_table) do
        if v and v["chance"] and type(v["chance"], "number") then
            max_num = max_num + v["chance"]
            table["insert"](hh_list, v)
        end
    end
    local result_num = math["random"](1, max_num)
    local hh_index = #hh_list
    while result_num > 0 do
        result_num = result_num - hh_list[hh_index]["chance"]
        hh_index = hh_index - 1
    end
    return hh_list[hh_index + 1] or nil
end
function HH_UTILS:HHCreateImageButton(father, xml, tex, pos, scale_x, scale_y, color)
    local hh_ui = father:AddChild(ImageButton(xml, tex))
    hh_ui:SetPosition(pos)
    hh_ui["clickoffset"] = Vector3(0, 0, 0)
    local base_scale_x, base_scale_y = tonumber(scale_x) or 1, tonumber(scale_y) or 1
    hh_ui["image"]:SetScale(base_scale_x, base_scale_y, 1)
    if color then
        hh_ui["image"]:SetTint(color[1], color[2], color[3], color[4])
    end
    hh_ui["OnGainFocus"] = function()
        hh_ui["image"]:SetScale(base_scale_x * 1.1, base_scale_y * 1.1, 1)
    end
    hh_ui["OnLoseFocus"] = function()
        hh_ui["image"]:SetScale(base_scale_x, base_scale_y, 1)
    end
    return hh_ui
end

function HH_UTILS:HHCreateBtnUi(father, xml, tex, pos, scale_x, scale_y, color)
    local hh_ui = father:AddChild(ImageButton("images/ui.xml", "button_large.tex", "button_large_over.tex", "button_large_disabled.tex"))
    hh_ui:SetPosition(pos)
    hh_ui["image"]:SetScale(scale_x, scale_y, 1)
    if color then
        hh_ui["image"]:SetTint(color[1], color[2], color[3], color[4])
    end
    return hh_ui
end
function HH_UTILS:HHCreateTextUi(father, pos, str, color, scale, is_left)
    local hh_text = father:AddChild(Text(NUMBERFONT, scale or 30, ""))
    hh_text:SetPosition(pos)
    hh_text:SetString(str)
    hh_text:SetColour(color or { 1, 1, 1, 1 })
    if is_left then
        hh_text:SetHAlign(ANCHOR_LEFT)
        hh_text:SetVAlign(ANCHOR_MIDDLE)
    end
    return hh_text
end

function HH_UTILS:HHKillChild(self, key)
    if self and self[key] then
        self[key]:Kill()
        self[key] = nil
    end
end

function HH_UTILS:HHKillTask(self, key)
    if self and self[key] then
        self[key]:Cancel()
        self[key] = nil
    end
end
function HH_UTILS:HHRemoveFx(self, key)
    if self and self[key] and self[key]["Remove"] then
        self[key]:Remove()
        self[key] = nil
    end
end

function HH_UTILS:TableToStr(hh_table)
    local hh_result = "{}"
    local success, result = pcall(json["encode"], hh_table)
    if success then
        hh_result = result
    end
    return hh_result
end

function HH_UTILS:StrToTable(hh_str)
    local hh_result = {}
    local success, result = pcall(json["decode"], hh_str)
    if success then
        hh_result = result
    end
    return hh_result
end

function HH_UTILS:TableSortKeys(hh_table)
    local result = {}
    if type(hh_table) == 'table' then
        for i, v in pairs(hh_table) do
            if type(i) == 'string' then
                table["insert"](result, i)
            end
        end
    end
    table["sort"](result)
    return result
end
----
---判断字符串是否以xx开始
---@param str:原字符串
---@param data:校验字符串
---
function HH_UTILS:StartWith(str, data)
    if not HH_UTILS:IsHHType(str, "string") or not HH_UTILS:IsHHType(data, "string") then
        return false
    end
    return string["match"](str, "^" .. data) ~= nil
end
----
---判断字符串是否以xx结尾
---@param str:原字符串
---@param data:校验字符串
---
function HH_UTILS:EndWith(str, data)
    if not HH_UTILS:IsHHType(str, "string") or not HH_UTILS:IsHHType(data, "string") then
        return false
    end
    return data == "" or str:sub(-#data) == data
end

----算字符个数
function HH_UTILS:GetStringWordNum(str)
    local fontSize = 20
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string["byte"](str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte >= 128 and curByte < 224 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 240 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + 1
    end
    return count
end

----截取子字符串
--返回当前字符实际占用的字符数
local function SubStringGetByteCount(str, index)
    local curByte = string["byte"](str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte >= 192 and curByte <= 223 then
        byteCount = 2
    elseif curByte >= 224 and curByte <= 239 then
        byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
        byteCount = 4
    end
    return byteCount;
end

--获取中英混合UTF8字符串的真实字符数量
local function SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until (lastCount == 0);
    return curIndex - 1;
end

--获取字符串的真实索引值
local function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until (curIndex >= index);
    return i - lastCount;
end

--截取中英混合的UTF8字符串，endIndex可缺省
function HH_UTILS:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then
        return string["sub"](str, SubStringGetTrueIndex(str, startIndex));
    else
        return string["sub"](str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

function HH_UTILS:HHCompareTable(table1, table2)
    if table1 == table2 then
        return true
    end
    if table1 == nil or table2 == nil or type(table1) ~= "table" or type(table2) ~= "table" then
        return false
    end
    if #table1 ~= #table2 then
        return false
    end
    for key, value in pairs(table1) do
        if not HH_UTILS:HHCompareTable(value, table2[key]) then
            return false
        end
    end
    for key, value in pairs(table2) do
        if not HH_UTILS:HHCompareTable(value, table1[key]) then
            return false
        end
    end
    return true
end
function HH_UTILS:IsHHType(data, hh_type)
    if data and type(data) == hh_type then
        return true
    end
    return false
end
----
--- 替换模板中的变量
---@param template:模板 内容中{{字段}}替换对应表中元素值
---@param data:表
---@return string
function HH_UTILS:Template(template, data)
    if not data or type(data) ~= "table" then
        return "入参错误 需要table格式"
    end
    return template:gsub("{{([^{}]+)}}", function(match)
        local value = data[match]
        if value == nil or not (type(value) == "string" or type(value) == "number") then
            value = ""
        end
        return value
    end)
end
----
---获取角度对应三角函数值
---
function HH_UTILS:GetAngleValue(math_type, angle)
    if math[math_type] then
        return math[math_type](math["rad"](angle))
    end
    return 1
end

----lua计算俩点之间距离
function HH_UTILS:GetDistance(x1, y1, x2, y2)
    return math["sqrt"]((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
----计算俩点之间角度 起点，终点
function HH_UTILS:GetAngleByPoints(x1, y1, x2, y2)
    local deltaX = x2 - x1
    local deltaY = y2 - y1
    local angle = math["atan2"](deltaY, deltaX) * 180 / math["pi"]
    return angle
end

function HH_UTILS:NotIsDead(inst)
    if inst and inst:IsValid() and HH_UTILS:HasComponents(inst, "health")
            and not inst["components"]["health"]:IsDead() then
        return true
    end
    return false
end
----
---根据id就行将key取出来排序 1为第一位 {aa = {id = 1},}
---
function HH_UTILS:GetSortTableKeys(originalTable)

    -- 存储键名的顺序
    local keyOrder = {}

    -- 遍历原始表，将键名存储到 keyOrder 中
    for key, _ in pairs(originalTable) do
        table["insert"](keyOrder, key)
    end

    -- 按照 id 字段排序 keyOrder 中的键名
    table["sort"](keyOrder, function(a, b)
        return originalTable[a]["id"] < originalTable[b]["id"]
    end)

    -- 构建新的排序表 sortedTable，仅保留键名，按照 id 字段排序
    local sortedTable = {}
    for _, key in ipairs(keyOrder) do
        sortedTable[#sortedTable + 1] = key
    end
    return sortedTable
end
----
---同步附魔石头对应配方套装石
---
function HH_UTILS:ForgeStoneClient(inst)
    --if not HH_UTILS:HasComponents(inst, "container")
    --        or not HH_UTILS:HasComponents(inst["hh_ui_owner"], "hh_player")
    --then
    --    return
    --end
    --local hh_table = { 2, 3, 4, 5 }
    --local hh_client = { }
    --for i, v in ipairs(hh_table) do
    --    local hh_item = inst["components"]["container"]:GetItemInSlot(v)
    --    if hh_item and hh_item["prefab"] then
    --        hh_client["hh_" .. i] = hh_item["prefab"]
    --    end
    --end
    ----HH_UTILS:HHPrint(hh_client)
    --HH_UTILS:HHClientRpc(inst["hh_ui_owner"], "hh_forge_stone", HH_UTILS:TableToStr(hh_client))
end
----
---攻击力为0的生物-置为可攻击
---
local damage_is_0 = {
    ["spat"] = true,
    ["monkey"] = true,
}
----
---目标是否是有效的 攻击力大于0
---
function HH_UTILS:IsValidCombat(target)
    if HH_UTILS:HasComponents(target, "combat")
            and HH_UTILS:IsHHType(target["components"]["combat"]["defaultdamage"], "number")
            and (target["components"]["combat"]["defaultdamage"] > 0 or damage_is_0[target["prefab"]])
    then
        return true
    end
    return false
end
local function launchItem(item, angle)
    if not item["Physics"] then
        return
    end
    local speed = math["random"]() * 4 + 2
    angle = (angle + math["random"]() * 60 - 30) * DEGREES
    item["Physics"]:SetVel(speed * math["cos"](angle), 15, speed * math["sin"](angle))
end
local function getWorldPos(inst)
    local pos_x, pos_y, pos_z = 0, 0, 0
    if inst and inst["Transform"] and inst["Transform"]["GetWorldPosition"] then
        pos_x, pos_y, pos_z = inst["Transform"]:GetWorldPosition()
    end
    return pos_x or 0, pos_y or 0, pos_z or 0
end
----
---检查可以读取世界坐标
---
function HH_UTILS:CheckTransform(inst)
    return inst and inst["Transform"] and inst["Transform"]["GetWorldPosition"]
end
----
---获取对应目标角度
---
function HH_UTILS:GetTargetAngle(inst, target)
    local pos_x, pos_y, pos_z = target["Transform"]:GetWorldPosition()
    local hh_angle = inst:GetAngleToPoint(Vector3(pos_x, pos_y, pos_z))
    if hh_angle < 0 then
        hh_angle = hh_angle + 360
    end
    hh_angle = -hh_angle
    return hh_angle
end
----
---文字特效
---
function HH_UTILS:SpawnTextFx(inst, hh_str)
    if not HH_UTILS:IsHHType(hh_str, "string") then
        return
    end
    local fx = SpawnPrefab("hh_tips")
    if fx and fx["Transform"] then
        local inst_x, inst_y, inst_z = getWorldPos(inst)
        fx["Transform"]:SetPosition(inst_x, inst_y + 4, inst_z)
        if fx["hh_tips"] then
            fx["hh_tips"]:set(tostring(hh_str))
        end
        local angle = math["random"](1, 360)
        launchItem(fx, angle)
    end
end
function HH_UTILS:SpawnCommonFx(inst)
    local fx = SpawnPrefab("hh_common_fx")
    if fx and fx["Transform"] then
        fx["Transform"]:SetPosition(getWorldPos(inst))
        return fx
    end
    return nil
end
function HH_UTILS:SpawnCollapseFx(inst)
    local fx = SpawnPrefab("hh_common_fx")
    if fx and fx["Transform"] then
        fx["AnimState"]:SetBank("collapse")
        fx["AnimState"]:SetBuild("structure_collapse_fx")
        fx["AnimState"]:PlayAnimation("collapse_small")
        fx["Transform"]:SetPosition(getWorldPos(inst))
        return fx
    end
    return nil
end

----
---生成巨鹿抛冰柱特效
---
function HH_UTILS:SpawnDeerClopFx(inst, target)
    if not target or not target["Transform"] then
        return
    end
    local fx = SpawnPrefab("hh_common_fx")
    if fx and fx["Transform"] then
        fx["Transform"]:SetEightFaced()
        fx["AnimState"]:SetBank("deerclops")
        fx["AnimState"]:SetBuild("deerclops_mutated")
        fx["AnimState"]:PlayAnimation("throw")
        fx["AnimState"]:SetMultColour(0, 0, 0, 0.6)
        fx["Transform"]:SetScale(1.65, 1.65, 1.65)
        fx["Transform"]:SetPosition(getWorldPos(inst))
        local hh_x, hh_y, hh_z = getWorldPos(target)
        fx:ForceFacePoint(getWorldPos(target))
        fx["hh_target_pos"] = { ["x"] = hh_x, ["y"] = hh_y, ["z"] = hh_z }
        fx:DoTaskInTime(60 * FRAMES, function()
            if HH_UTILS:IsHHType(fx["hh_target_pos"], "table") then
                local lance = SpawnPrefab("deerclops_impact_circle_fx")
                lance["Transform"]:SetPosition(fx["hh_target_pos"]["x"], fx["hh_target_pos"]["y"], fx["hh_target_pos"]["z"])
            end
        end)
        --指示器
        fx["ping_fx"] = SpawnPrefab("deerclops_icelance_ping_fx")
        fx["ping_fx"]["Transform"]:SetPosition(getWorldPos(target))
        fx:ListenForEvent("animover", function()
            if fx["ping_fx"] then
                if fx["ping_fx"]["KillFX"] then
                    fx["ping_fx"]:KillFX()
                else
                    fx["ping_fx"]:Remove()
                end
            end
            fx:Remove()
        end)
    end
end

function HH_UTILS:GetMonsterType(inst)
    if HH_UTILS:HasComponents(inst, "hh_monster") then
        return inst["components"]["hh_monster"]:GetMonsterType()
    end
    return nil
end
function HH_UTILS:SpawnBrambleFx(inst)
    local fx = SpawnPrefab("hh_common_fx")
    if fx and fx["Transform"] then
        --fx["Transform"]:SetFourFaced()
        fx["Transform"]:SetPosition(getWorldPos(inst))
    end
end

function HH_UTILS:NetSay(net_str)
    if TheNet then
        TheNet:Announce(tostring(net_str))
    end
end
function HH_UTILS:UpdateEquipValue(player, effect_name, value, is_add)
    if HH_UTILS:HasComponents(player, "hh_player") then
        if is_add then
            player["components"]["hh_player"]:AddEffectValueByKey(effect_name, value)
        else
            player["components"]["hh_player"]:ReduceEffectValueByKey(effect_name, value)
        end
    end
end
----
---暗影护盾特效
---
function HH_UTILS:SpawnShadowFx(inst)
    local fx = SpawnPrefab("hh_common_fx")
    if fx and fx["Transform"] then
        fx["AnimState"]:SetBank("stalker_shield")
        fx["AnimState"]:SetBuild("stalker_shield")
        fx["AnimState"]:PlayAnimation("idle1")
        fx["Transform"]:SetPosition(getWorldPos(inst))
    end
end
----
---爆炸特效
---
function HH_UTILS:SpawnExplodeFx(inst, hh_color)
    local fx = SpawnPrefab("hh_common_fx")
    if fx and fx["Transform"] then
        fx["AnimState"]:SetBank("explode")
        fx["AnimState"]:SetBuild("explode")
        fx["AnimState"]:PlayAnimation("small")
        fx["Transform"]:SetPosition(getWorldPos(inst))
        if hh_color and type(hh_color) == "table" then
            local r = hh_color[1] or 1
            local g = hh_color[2] or 1
            local b = hh_color[3] or 1
            local a = hh_color[4] or 1
            fx["AnimState"]:SetMultColour(r, g, b, a)
        end
    end
end
----
---指示器特效
---
function HH_UTILS:SpawnIndicatorFx(target_pos, remove_time, hh_color, scale)
    local fx = SpawnPrefab("hh_indicator_fx")
    if fx and fx["Transform"] then
        if hh_color and type(hh_color) == "table" then
            local r = hh_color[1] or 1
            local g = hh_color[2] or 1
            local b = hh_color[3] or 1
            local a = hh_color[4] or 1
            fx["AnimState"]:SetMultColour(r, g, b, a)
        end
        if scale then
            fx["AnimState"]:SetScale(scale, scale)
        end
        fx["Transform"]:SetPosition(target_pos["x"], target_pos["y"], target_pos["z"])
        local remove_task = 3
        if HH_UTILS:IsHHType(remove_time, "number") and remove_time > 0 then
            remove_task = remove_time
        end
        fx:DoTaskInTime(remove_task, fx["Remove"])
    end
end

----
---文字特效
---
function HH_UTILS:SpawnClientStrFx(inst, hh_str)
    if not inst or not inst["Transform"]
            or not HH_UTILS:IsHHType(hh_str, "string") then
        return
    end
    if not TUNING["HH_CAN_SHOW_TEXT_FX"] then
        return
    end
    local fx = SpawnPrefab("hh_fx_text")
    if fx and fx["Transform"] and fx["SetTextStr"] then
        fx:SetTextStr(hh_str)
        fx["Transform"]:SetPosition(getWorldPos(inst))
    end
end
-- 解方程组，找到抛物线系数(三个点 凹槽向下)
function HH_UTILS:SolveParabolaEquation(points)
    local a, b, c

    -- 使用第一个点得到 c 的值
    c = points[1][2]

    -- 使用第二个点和第三个点得到 a 和 b 的值
    local x1, y1 = points[1][1], points[1][2]
    local x2, y2 = points[2][1], points[2][2]
    local x3, y3 = points[3][1], points[3][2]

    local den = (x1 - x2) * (x1 - x3) * (x2 - x3)

    if den == 0 then
        -- 避免除零错误
        return nil, nil, nil
    end

    local A = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / den
    local B = (x3 ^ 2 * (y1 - y2) + x2 ^ 2 * (y3 - y1) + x1 ^ 2 * (y2 - y3)) / den

    a = A
    b = B - 2 * A * x1
    c = y1 - A * x1 ^ 2 - B * x1
    return a, b, c
end
function HH_UTILS:HHClientRpc(player, rpc_name, data)
    if player and player["userid"] and player:HasTag("player") and type(rpc_name) == 'string' then
        SendModRPCToClient(CLIENT_MOD_RPC["hh_rpc"]["hh_client_value"], player["userid"], rpc_name, data)
    end
end

----
---使ui按钮右键可以移动
---
function HH_UTILS:MakeUiCanMove(ui_self)
    local oldControl = ui_self["OnControl"]
    ui_self["OnControl"] = function(self, control, down)
        if self["Passive_OnControl"] then
            self:Passive_OnControl(control, down)
        end
        if oldControl then
            return oldControl(self, control, down)
        end
    end
    ui_self["Passive_OnControl"] = function(self, control, down)
        if self["focus"] and control == CONTROL_SECONDARY then
            if down then
                self:StartDrag()
            else
                self:EndDrag()
            end
        end
    end

    --设置拖拽坐标
    ui_self["SetDragPosition"] = function(self, x, y, z)
        local pos
        if type(x) == "number" then
            pos = Vector3(x, y, z)
        else
            pos = x
        end
        local self_scale = self:GetScale()
        local offset = 1--偏移修正(容器是0.6)
        local newpos = self["p_startpos"] + (pos - self["m_startpos"]) / (self_scale.x / offset)--修正偏移值
        self:SetPosition(newpos)--设定新坐标
    end
    ui_self["StartDrag"] = function(self)
        if not self["hh_follower"] then
            local mousepos = TheInput:GetScreenPosition()
            self["m_startpos"] = mousepos--鼠标初始坐标
            self["p_startpos"] = self:GetPosition()--面板初始坐标
            self["hh_follower"] = TheInput:AddMoveHandler(function(x, y)
                self:SetDragPosition(x, y, 0)
                if not Input:IsMouseDown(MOUSEBUTTON_RIGHT) then
                    self:EndDrag()
                end
            end)
            self:SetDragPosition(mousepos)
        end
    end
    ui_self["EndDrag"] = function(self)
        if self["hh_follower"] then
            self["hh_follower"]:Remove()
        end
        self["hh_follower"] = nil
        self["m_startpos"] = nil
        self["p_startpos"] = nil
    end
end
----
---增加buff
---
function HH_UTILS:HandleSuitBuff(player, buff_name, buff_time, need_add)
    if not HH_UTILS:HasComponents(player, "hh_buff") then
        return
    end
    if need_add then
        player["components"]["hh_buff"]:AddBuff(buff_name, buff_time)
    else
        player["components"]["hh_buff"]:RemoveBuff(buff_name)
    end
end

function HH_UTILS:CheckSuitEffect(player, suit_id)
    if not HH_UTILS:HasComponents(player, "hh_player") then
        return false
    end
    return player["components"]["hh_player"]:HasSuitEffect(suit_id)

end
----
---黑名单-退出游戏
---
function HH_UTILS:ExitGame(s)
    if ThePlayer and HH_UTILS:IsHHType(s, "number") then
        ThePlayer:DoTaskInTime(s, function()
            DoRestart(true)
        end)
    end
end

function HH_UTILS:GetAtkSpeedLevel(player)
    if not HH_UTILS:HasComponents(player, "hh_player")
            or not player["components"]["hh_player"]:HasSpecialEffect("atkSpeed")
    then
        return 1
    end
    local hh_atkSpeed = player["components"]["hh_player"]:GetEffectValueByKey("atkSpeed")
    --去掉小数
    hh_atkSpeed = math["floor"](hh_atkSpeed)
    --上限5
    hh_atkSpeed = math["min"](hh_atkSpeed, 4)
    return hh_atkSpeed + 1

end
----
---同步客机地图传送权限
---
function HH_UTILS:ClientMapBlink(owner)
    if not HH_UTILS:HasComponents(owner, "hh_player") then
        return false
    end
    if owner["components"]["hh_player"]:HasSpecialEffect("z_map_blink") then
        HH_UTILS:SetClientValue(owner, "hh_can_map_blink", "Y")
    else
        HH_UTILS:SetClientValue(owner, "hh_can_map_blink", "N")
    end
end
----
---是否可以攻击对方
---
function HH_UTILS:CanHitTarget(attacker, target)
    if not (HH_UTILS:IsHHType(attacker, "table") and HH_UTILS:IsHHType(target, "table")
            and attacker["IsValid"] and attacker:IsValid()
            and target["IsValid"] and target:IsValid()
            and attacker["Transform"] and not attacker:HasTag("FX")
            and not attacker:HasTag("INLIMBO") and not attacker:HasTag("DECOR")
            and target["Transform"] and not target:HasTag("FX")
            and not target:HasTag("INLIMBO") and not target:HasTag("DECOR")
    ) then
        return false
    end
    if attacker == target then
        return false
    end
    local attacker_follower = attacker["components"]["follower"]
    local target_follower = target["components"]["follower"]
    --攻击者不允许攻击自己的领导者
    if attacker_follower and attacker_follower["leader"] == target then
        return false
    end
    --不会攻击自己的下属
    if target_follower and target_follower["leader"] == attacker then
        return false
    end

    return true
end
----
---单行封装多种颜色文字
---@param father
---@param str_list:{{str="描述",color={颜色},scale=大小}}
---@param direction:文字方向 1-右边 2-左边 3-下面 4-上面
---
function HH_UTILS:CreateMoreTextUi(father, str_list, direction, font)
    local hh_ui = father:AddChild(Widget())
    local start_x, start_y = 0, 0
    if HH_UTILS:IsHHType(str_list, "table") then
        for i, v in ipairs(str_list) do
            if HH_UTILS:IsHHType(v, "table") then
                local hh_scale = v["scale"] or 30
                local hh_text_str = v["str"] or "文字"
                local hh_text_color = v["color"] or { 1, 1, 1, 1 }
                local base_font = NUMBERFONT
                if font then
                    base_font = font
                end
                hh_ui["hh_text_" .. i] = hh_ui:AddChild(Text(base_font, hh_scale or 30, ""))
                hh_ui["hh_text_" .. i]:SetString(hh_text_str)
                hh_ui["hh_text_" .. i]:SetColour(hh_text_color)
                hh_ui["hh_text_" .. i]:SetHAlign(ANCHOR_LEFT)
                hh_ui["hh_text_" .. i]:SetVAlign(ANCHOR_MIDDLE)
                local text_x, text_y = hh_ui["hh_text_" .. i]:GetRegionSize()
                if direction and direction ~= 1 then
                    if direction == 2 then
                        hh_ui["hh_text_" .. i]:SetPosition(start_x - text_x / 2, -text_y / 2, 0)
                        start_x = start_x - text_x
                        start_y = math["max"](start_y, text_y)
                    elseif direction == 3 then
                        hh_ui["hh_text_" .. i]:SetPosition(text_x / 2, start_y - text_y / 2, 0)
                        start_x = math["max"](start_x, text_x)
                        start_y = start_y - text_y
                    elseif direction == 4 then
                        hh_ui["hh_text_" .. i]:SetPosition(text_x / 2, start_y + text_y / 2, 0)
                        start_x = math["max"](start_x, text_x)
                        start_y = start_y + text_y
                    end
                else
                    hh_ui["hh_text_" .. i]:SetPosition(start_x + text_x / 2, -text_y / 2, 0)
                    start_x = start_x + text_x
                    start_y = math["max"](start_y, text_y)
                end
            end
        end
    end
    --登记长宽
    hh_ui["max_x"] = math["abs"](start_x)
    hh_ui["max_y"] = math["abs"](start_y)
    return hh_ui
end

----
---单行封装多种颜色文字+多种图片交接的ui
---@param father
---@param str_list:{
---{type="text",str="描述",color={颜色},scale=大小},
---{type="image",xml="图片",tex="图片",color={颜色},size_x=大小,size_y=大小}
---}
---
function HH_UTILS:CreateImageAndText(father, str_list, ui_type)
    local hh_ui = father:AddChild(Widget(""))
    local start_x, start_y = 0, 0
    --增加格式 用于上下左右拼接ui 1-右边 2-左边 3-下面 4-上面
    local line_type = ui_type or 1
    if HH_UTILS:IsHHType(str_list, "table") then
        for i, v in ipairs(str_list) do
            if HH_UTILS:IsHHType(v, "table") and v["type"] then
                local child_size_x, child_size_y = 0, 0
                local ui_name = "hh_child_" .. i
                if v["type"] == "text" then
                    local hh_scale = v["scale"] or 30
                    local hh_text_str = v["str"] or "文字"
                    local hh_text_color = v["color"] or { 1, 1, 1, 1 }
                    hh_ui[ui_name] = hh_ui:AddChild(Text(NUMBERFONT, hh_scale or 30, ""))
                    hh_ui[ui_name]:SetString(hh_text_str)
                    hh_ui[ui_name]:SetColour(hh_text_color)
                    hh_ui[ui_name]:SetHAlign(ANCHOR_LEFT)
                    hh_ui[ui_name]:SetVAlign(ANCHOR_MIDDLE)
                    local text_x, text_y = hh_ui[ui_name]:GetRegionSize()
                    child_size_x, child_size_y = text_x, text_y
                elseif v["type"] == "image" then
                    local image_xml = v["xml"] or "images/global.xml"
                    local image_tex = v["tex"] or "square.tex"
                    local image_size_x = v["size_x"] or 30
                    local image_size_y = v["size_y"] or 30
                    local image_color = v["color"] or { 1, 1, 1, 1 }
                    hh_ui[ui_name] = hh_ui:AddChild(Image(image_xml, image_tex))
                    hh_ui[ui_name]:SetSize(image_size_x, image_size_y)
                    hh_ui[ui_name]:SetTint(image_color[1], image_color[2], image_color[3], image_color[4])
                    hh_ui[ui_name]:SetClickable(false)
                    child_size_x, child_size_y = image_size_x, image_size_y
                    local current_ui = hh_ui[ui_name]
                    --记录一下大小 作为传参
                    current_ui["size_x"] = image_size_x
                    current_ui["size_y"] = image_size_y
                    if HH_UTILS:IsHHType(v["extra_fn"], "function") then
                        v["extra_fn"](HH_UTILS, current_ui)
                    end
                end
                if hh_ui[ui_name] then
                    if line_type == 1 then
                        --右边
                        hh_ui[ui_name]:SetPosition(start_x + child_size_x / 2, -child_size_y / 2, 0)
                        start_x = start_x + child_size_x
                        start_y = math["max"](start_y, child_size_y)
                    elseif line_type == 2 then
                        --左边
                        hh_ui[ui_name]:SetPosition(start_x - child_size_x / 2, -child_size_y / 2, 0)
                        start_x = start_x - child_size_x
                        start_y = math["max"](start_y, child_size_y)
                    elseif line_type == 3 then
                        --下面
                        hh_ui[ui_name]:SetPosition(child_size_x / 2, start_y - child_size_y / 2, 0)
                        start_x = math["max"](start_x, child_size_x)
                        start_y = start_y - child_size_y
                    elseif line_type == 4 then
                        --上面
                        hh_ui[ui_name]:SetPosition(child_size_x / 2, start_y + child_size_y / 2, 0)
                        start_x = math["max"](start_x, child_size_x)
                        start_y = start_y + child_size_y
                    end
                end
            end
        end
    end
    --登记长宽
    hh_ui["max_x"] = math["abs"](start_x)
    hh_ui["max_y"] = math["abs"](start_y)
    return hh_ui
end

----
---创建带边框的ui
---
function HH_UTILS:CreateFrameUi(father, pos, father_data, frame_data)
    local hh_ui = father:AddChild(Image("images/global.xml", "square.tex"))
    hh_ui:SetPosition(pos)
    local image_size_x, image_size_y = father_data["size_x"] or 100, father_data["size_y"] or 100
    hh_ui:SetSize(image_size_x, image_size_y)
    if HH_UTILS:IsHHType(father_data["color"], "table") and #father_data["color"] == 4 then
        local image_main_color = father_data["color"]
        hh_ui:SetTint(image_main_color[1], image_main_color[2], image_main_color[3], image_main_color[4])
    end
    -------------------创建边框-4边+4角---------------------------------
    if HH_UTILS:IsHHType(frame_data, "table") then
        local frame_size = frame_data["size"] or 5
        local frame_color = frame_data["color"] or { 1, 1, 1, 1 }
        hh_ui["hh_left"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(-image_size_x / 2 - frame_size / 2, 0, 1), frame_size, image_size_y, frame_color)
        hh_ui["hh_right"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(image_size_x / 2 + frame_size / 2, 0, 1), frame_size, image_size_y, frame_color)
        hh_ui["hh_up"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(0, image_size_y / 2 + frame_size / 2, 1), image_size_x, frame_size, frame_color)
        hh_ui["hh_down"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(0, -image_size_y / 2 - frame_size / 2, 1), image_size_x, frame_size, frame_color)
        local base_pos_x, base_pos_y = frame_size / 2 + image_size_x / 2, image_size_y / 2 + frame_size / 2
        hh_ui["hh_icon_01"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(-base_pos_x, base_pos_y, 1), frame_size, frame_size, frame_color)
        hh_ui["hh_icon_02"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(base_pos_x, base_pos_y, 1), frame_size, frame_size, frame_color)
        hh_ui["hh_icon_03"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(-base_pos_x, -base_pos_y, 1), frame_size, frame_size, frame_color)
        hh_ui["hh_icon_04"] = HH_UTILS:HHCreateImageUi(hh_ui, "images/global.xml", "square.tex", Vector3(base_pos_x, -base_pos_y, 1), frame_size, frame_size, frame_color)
    end
    -------------------创建边框-4边+4角---------------------------------
    return hh_ui
end
----
---带四角的边框-官方棕色
---
function HH_UTILS:CreateFrameUiTwo(father, pos, father_data)
    local base_xml, base_tex = father_data["xml"] or "images/global.xml", father_data["tex"] or "square.tex"
    local hh_ui = father:AddChild(Image(base_xml, base_tex))
    hh_ui:SetPosition(pos)
    local image_size_x, image_size_y = father_data["size_x"] or 100, father_data["size_y"] or 100
    hh_ui:SetSize(image_size_x, image_size_y)
    if HH_UTILS:IsHHType(father_data["color"], "table") and #father_data["color"] == 4 then
        local image_main_color = father_data["color"]
        hh_ui:SetTint(image_main_color[1], image_main_color[2], image_main_color[3], image_main_color[4])
    end
    -------------------创建边框-4边+4角---------------------------------
    local frame_size = 10
    local frame_color = { 1, 1, 1, 1 }
    local line_xml, line_tex = "images/hh_icon/hh_ui_line.xml", "hh_ui_line.tex"
    hh_ui["hh_left"] = HH_UTILS:HHCreateImageUi(hh_ui, line_xml, line_tex, Vector3(-image_size_x / 2, 0, 1), frame_size, image_size_y, frame_color)
    hh_ui["hh_right"] = HH_UTILS:HHCreateImageUi(hh_ui, line_xml, line_tex, Vector3(image_size_x / 2, 0, 1), frame_size, image_size_y, frame_color)
    hh_ui["hh_up"] = HH_UTILS:HHCreateImageUi(hh_ui, line_xml, line_tex, Vector3(0, image_size_y / 2, 1), frame_size, image_size_x, frame_color)
    hh_ui["hh_up"]:SetRotation(90)
    hh_ui["hh_down"] = HH_UTILS:HHCreateImageUi(hh_ui, line_xml, line_tex, Vector3(0, -image_size_y / 2, 1), frame_size, image_size_x, frame_color)
    hh_ui["hh_down"]:SetRotation(270)
    local base_pos_x, base_pos_y = image_size_x / 2, image_size_y / 2
    local icon_size = 25
    local child_offset = 5
    local icon_xml, icon_tex = "images/hh_icon/hh_ui_horn.xml", "hh_ui_horn.tex"
    hh_ui["hh_icon_01"] = HH_UTILS:HHCreateImageUi(hh_ui, icon_xml, icon_tex, Vector3(-base_pos_x + child_offset, base_pos_y - child_offset, 1), icon_size, icon_size, frame_color)
    hh_ui["hh_icon_01"]:SetRotation(90)
    hh_ui["hh_icon_02"] = HH_UTILS:HHCreateImageUi(hh_ui, icon_xml, icon_tex, Vector3(base_pos_x - child_offset, base_pos_y - child_offset, 1), icon_size, icon_size, frame_color)
    hh_ui["hh_icon_02"]:SetRotation(180)
    hh_ui["hh_icon_03"] = HH_UTILS:HHCreateImageUi(hh_ui, icon_xml, icon_tex, Vector3(-base_pos_x + child_offset, -base_pos_y + child_offset, 1), icon_size, icon_size, frame_color)
    hh_ui["hh_icon_04"] = HH_UTILS:HHCreateImageUi(hh_ui, icon_xml, icon_tex, Vector3(base_pos_x - child_offset, -base_pos_y + child_offset, 1), icon_size, icon_size, frame_color)
    hh_ui["hh_icon_04"]:SetRotation(270)
    -------------------创建边框-4边+4角---------------------------------
    return hh_ui
end
local info_config_test = {
    {
        ["id"] = "name2",
        ["name"] = " ",
        ["scale"] = 1,
        ["color"] = { 1, 1, 1, 1 },
        ["is_mid"] = true, --词缀居中
        ["child_mid"] = true, --子类居中
    },

}
--参数格式表  k id v {str=描述,child={}}
local info_table_test = {
    ["name"] = {
        ["str"] = "名字",
        ["color"] = { 1, 0, 0, 1 }, --文本颜色
        ["child"] = {
            --{type="text",str="描述",color={颜色},scale=大小},
            --{type="image",xml="图片",tex="图片",color={颜色},size_x=大小,size_y=大小}
            ["ui_type"] = 2, --对齐格式 1:跟在单行描述后面 2 跟在描述下面与前缀齐平 3 跟在描述下面 不与前缀齐平
            ["child_type"] = 1, --下方子类对齐格式
            { ["type"] = "text", ["str"] = "对", ["color"] = { 1, 0, 1, 1 }, scale = 30 },
            { ["type"] = "text", ["str"] = "齐", ["color"] = { 0, 1, 1, 1 }, scale = 30 },
            { ["type"] = "text", ["str"] = "格", ["color"] = { 1, 0, 0, 1 }, scale = 30 },
            { ["type"] = "text", ["str"] = "式", ["color"] = { 0, 0, 1, 1 }, scale = 30 },
        }
    },
}
----
---创建通用的信息类文本
---
function HH_UTILS:CreateInfoUi(father, info_table, info_config)
    local hh_ui = father:AddChild(Widget("hh_info"))
    hh_ui["max_x"], hh_ui["max_y"] = 1, 1
    if not HH_UTILS:IsHHType(info_table, "table")
            or not HH_UTILS:IsHHType(info_config, "table") then
        return hh_ui
    end
    local ui_size_x, ui_size_y = 0, 0
    for i, v in ipairs(info_config) do
        if v and v["id"] and info_table[v["id"]] then
            local child_ui_size_x, child_ui_size_y = 0, 0
            local ui_id = v["id"]
            local ui_title = v["name"] or "前缀"
            local text_scale = v["scale"] or 30
            local text_color = v["color"] or { 1, 1, 1, 1 }
            local title_name = "text_title" .. ui_id
            hh_ui[title_name] = HH_UTILS:HHCreateTextUi(hh_ui, Vector3(0, 0, 1), ui_title, text_color, text_scale)
            local text_x, text_y = hh_ui[title_name]:GetRegionSize()
            hh_ui[title_name]:SetPosition(text_x / 2, -ui_size_y - text_y / 2, 1)
            child_ui_size_x = text_x
            child_ui_size_y = text_y
            local info_v = info_table[ui_id]
            local info_str = info_v["str"] or "描述"
            local info_color = info_v["color"] or { 1, 1, 1, 1 }
            local text_ui = hh_ui[title_name]
            --空字符串 不添加描述ui
            if info_str ~= "" then
                text_ui["hh_str"] = HH_UTILS:HHCreateTextUi(text_ui, Vector3(0, 0, 1), tostring(info_str), info_color, text_scale, true)
                local hh_str_x, hh_str_y = text_ui["hh_str"]:GetRegionSize()
                text_ui["hh_str"]:SetPosition(text_x / 2 + hh_str_x / 2, text_y / 2 - hh_str_y / 2, 1)

                child_ui_size_x = child_ui_size_x + hh_str_x
                child_ui_size_y = math["max"](child_ui_size_y, hh_str_y)
            end
            --居中的文本 不需要添加子类ui
            --if not v["is_mid"] then
            ---子类ui
            if info_v["child"] then
                text_ui["hh_child_ui"] = HH_UTILS:CreateImageAndText(text_ui, info_v["child"], info_v["child"]["child_type"])
                local hh_child_ui_size_x, hh_child_ui_size_y = text_ui["hh_child_ui"]["max_x"], text_ui["hh_child_ui"]["max_y"]
                local hh_line_type = info_v["child"]["ui_type"] or 3
                if hh_line_type == 1 then
                    --跟在描述后面
                    text_ui["hh_child_ui"]:SetPosition(child_ui_size_x - text_x / 2, text_y / 2, 0)
                    child_ui_size_x = child_ui_size_x + hh_child_ui_size_x
                    child_ui_size_y = math["max"](child_ui_size_y, hh_child_ui_size_y)

                elseif hh_line_type == 2 then
                    --与前缀齐平
                    text_ui["hh_child_ui"]:SetPosition(-text_x / 2, -(child_ui_size_y / 2 + text_y / 2), 0)
                    child_ui_size_x = math["max"](child_ui_size_x, hh_child_ui_size_x)
                    child_ui_size_y = child_ui_size_y + hh_child_ui_size_y
                elseif hh_line_type == 3 then
                    --不与前缀齐平
                    text_ui["hh_child_ui"]:SetPosition(text_x / 2, -(child_ui_size_y / 2 + text_y / 2), 0)
                    child_ui_size_x = math["max"](child_ui_size_x, hh_child_ui_size_x + text_x)
                    child_ui_size_y = child_ui_size_y + hh_child_ui_size_y
                end
            end
            --end
            --记录下ui大小
            hh_ui[title_name]["max_x"] = child_ui_size_x
            hh_ui[title_name]["max_y"] = child_ui_size_y
            ui_size_y = ui_size_y + child_ui_size_y
            ui_size_x = math["max"](ui_size_x, child_ui_size_x)
        end
    end

    ----特殊部分 居中的ui
    for i, v in ipairs(info_config) do
        if v and v["id"] and info_table[v["id"]] then
            local ui_id = v["id"]
            local title_name = "text_title" .. ui_id
            if hh_ui[title_name] then
                local text_ui = hh_ui[title_name]
                local pos_text = text_ui:GetPosition()
                if v["is_mid"] then
                    --单前缀居中
                    text_ui:SetPosition(ui_size_x / 2, pos_text["y"], 1)
                end
                --前缀为空格 子类展示图片时使用
                if v["child_mid"] and text_ui["hh_child_ui"] then
                    local hh_child_ui_x = text_ui["hh_child_ui"]["max_x"] or 10
                    local child_pos_text = text_ui["hh_child_ui"]:GetPosition()
                    text_ui["hh_child_ui"]:SetPosition(ui_size_x / 2 - hh_child_ui_x / 2, child_pos_text["y"], 1)
                    --text_ui["hh_child_ui"]:SetPosition(-10, child_pos_text["y"], 1)
                end
            end
        end
    end

    hh_ui["max_x"], hh_ui["max_y"] = math["abs"](ui_size_x), math["abs"](ui_size_y)
    return hh_ui
end
----
---创建滑轮ui
---@param father_ui:父类
---@param ui_child:挂载的ui
---@param ui_weight:裁剪后ui长
---@param ui_height:裁剪后ui宽
---@param ui_child_height:挂载的ui-高度
---@param ui_click_speed:滑动的速度
---@param ui_offset_x:ui-x偏移
---@param ui_offset_y:ui-y偏移
---
function HH_UTILS:CreateTrueScrollArea(father_ui, ui_child, ui_weight, ui_height, ui_child_height, ui_click_speed, ui_offset_x, ui_offset_y)
    local scissor_data = {
        ["x"] = 0,
        ["y"] = 0,
        ["width"] = ui_weight,
        ["height"] = ui_height
    }
    --print(ui_child, ui_weight, ui_child_height, ui_height)
    local offset_x, offset_y = ui_offset_x or 0, ui_offset_y or 0

    local context = {
        --挂载ui
        ["widget"] = ui_child,
        --坐标偏移
        ["offset"] = {
            ["x"] = 0 + offset_x,
            ["y"] = ui_height + offset_y,
        },
        ["size"] = {
            --未找到用处
            ["w"] = 0,
            --总ui大小
            ["height"] = ui_child_height,
        }
    }
    local click_speed = ui_click_speed or 15
    local scrollbar = { ["scroll_per_click"] = click_speed }
    local hh_ui = father_ui:AddChild(TrueScrollArea(context, scissor_data, scrollbar))
    return hh_ui
end

function HH_UTILS:UiAddFocusStr(hh_ui, focus_str, str_scale)
    local base_scale = 30
    if HH_UTILS:IsHHType(str_scale, "number") then
        base_scale = str_scale
    end
    local oldOnGainFocusBack = hh_ui["OnGainFocus"]
    hh_ui["OnGainFocus"] = function()
        if oldOnGainFocusBack then
            oldOnGainFocusBack()
        end
        hh_ui["hh_desc"] = HH_UTILS:HHCreateTextUi(hh_ui, Vector3(0, 0, 1), tostring(focus_str), { 1, 1, 1, 1 }, base_scale)
        hh_ui["hh_desc"]:MoveTo(Vector3(0, 20, 1), Vector3(0, 40, 1), 0.5)
    end
    local oldOnLoseFocus = hh_ui["OnLoseFocus"]
    hh_ui["OnLoseFocus"] = function()
        if oldOnLoseFocus then
            oldOnLoseFocus()
        end
        HH_UTILS:HHKillChild(hh_ui, "hh_desc")
    end
end

function HH_UTILS:CreateAnimUi(father, bank, build, idle, need_true, scale)
    local hh_ui = father:AddChild(UIAnim())
    hh_ui:GetAnimState():SetBank(bank)
    hh_ui:GetAnimState():SetBuild(build)
    if need_true then
        hh_ui:GetAnimState():PlayAnimation(idle, true)
    else
        hh_ui:GetAnimState():PlayAnimation(idle)
    end
    hh_ui:SetClickable(false)
    if scale then
        hh_ui:SetScale(scale, scale, scale)
    end
    return hh_ui
end
local function handleTimeCom(inst, com_name, time_name)
    if inst["components"][com_name] ~= nil and inst["components"][com_name]:TimerExists(time_name) then
        inst["components"][com_name]:StopTimer(time_name)
        inst:PushEvent("timerdone", { name = time_name })
    end
end
----
---催熟作物
---
function HH_UTILS:TryGrowth(inst, player)
    if not inst or inst:IsInLimbo() then
        return
    end
    if HH_UTILS:HasComponents(inst, "pickable") then
        if inst:HasTag("sunflower") and TUNING["SUNFLOWER_REGROW_TIME"] then
            inst["time"] = GetTime() - TUNING["SUNFLOWER_REGROW_TIME"]
        end
        if inst["components"]["pickable"]:CanBePicked() and inst["components"]["pickable"]["caninteractwith"] then
            return
        end
        local hh_nomagic = nil
        if inst["components"]["pickable"]["nomagic"] then
            inst["components"]["pickable"]["nomagic"] = nil
            hh_nomagic = true
        end
        inst["components"]["pickable"]:FinishGrowing()
        inst["components"]["pickable"]["nomagic"] = hh_nomagic
    end
    if inst["components"]["crop"] ~= nil then
        inst["components"]["crop"]:DoGrow(TUNING["TOTAL_DAY_TIME"] * 6, true)
    end
    handleTimeCom(inst, "timer", "grow")
    handleTimeCom(inst, "timer", "growth")
    handleTimeCom(inst, "worldsettingstimer", "grow")
    handleTimeCom(inst, "worldsettingstimer", "growth")
    if HH_UTILS:HasComponents(inst, "crop_legion") and inst["components"]["crop_legion"]["DoGrow"] then
        inst["components"]["crop_legion"]:DoGrow(TUNING["TOTAL_DAY_TIME"] * 6, true) --增加3天生长时间
    end
    if player then
        if inst["components"]["perennialcrop"] ~= nil then
            inst["components"]["perennialcrop"]:DoMagicGrowth(player, TUNING["TOTAL_DAY_TIME"] * 3) -- 增加3天生长时间
        end
        if inst["components"]["perennialcrop2"] ~= nil then
            inst["components"]["perennialcrop2"]:DoMagicGrowth(player, TUNING["TOTAL_DAY_TIME"] * 3) -- 增加3天生长时间
        end
    end
    if HH_UTILS:HasComponents(inst, "growable")
            and (inst:HasTag("tree")
            or inst:HasTag("peachtree")
            or inst:HasTag("plant")
            or inst:HasTag("winter_tree")
            or inst:HasTag("boulder")
            or inst["components"]["growable"]["magicgrowable"]) then
        local stage = inst["components"]["growable"]["stage"]
        local maxstage = #inst["components"]["growable"]["stages"]
        if inst:HasTag("evergreens") then
            maxstage = maxstage - 1
        end
        if inst:HasTag("siving_derivant") then
            inst["components"]["growable"]:DoGrowth()
            inst["components"]["growable"]:DoMagicGrowth()
            inst["components"]["growable"]:DoMagicGrowth()
            inst["components"]["growable"]:DoMagicGrowth()
        else
            if stage == maxstage then
                inst["components"]["growable"]:Pause()
            elseif stage == maxstage - 1 then
                inst["components"]["growable"]:DoGrowth()
                inst["components"]["growable"]:Pause()
            else
                inst["components"]["growable"]:DoGrowth()
            end
        end
    end
    if inst["components"]["harvestable"] ~= nil and inst:HasTag("mushroom_farm") then
        --or inst:HasTag("beebox") 不可以可以催熟蜂箱
        if inst["components"]["harvestable"]["task"] then
            inst["components"]["harvestable"]:Grow()
            inst["components"]["harvestable"]:Grow()
            inst["components"]["harvestable"]:Grow()
            inst["components"]["harvestable"]:Grow()
            inst["components"]["harvestable"]:Grow()
            inst["components"]["harvestable"]:Grow()
        end
    end
end

local STAGE_PETRIFY_PREFABS = {
    "rock_petrified_tree_short",
    "rock_petrified_tree_med",
    "rock_petrified_tree_tall",
    "rock_petrified_tree_old",
}
local STAGE_PETRIFY_FX = {
    "petrified_tree_fx_short",
    "petrified_tree_fx_normal",
    "petrified_tree_fx_tall",
    "petrified_tree_fx_old",
}
local stone_dog = {
    "gargoyle_houndatk",
    "gargoyle_hounddeath",
}
local stone_pig = {
    "gargoyle_werepigatk",
    "gargoyle_werepigdeath",
    "gargoyle_werepighowl",
}

--石化树木
function HH_UTILS:StoneTree(inst, stage, instant)
    local x, y, z = getWorldPos(inst)
    local r, g, b = inst["AnimState"]:GetMultColour()
    inst:Remove()
    if not STAGE_PETRIFY_PREFABS[stage] then
        return
    end
    local rock = SpawnPrefab(STAGE_PETRIFY_PREFABS[stage])
    if rock then
        rock["AnimState"]:SetMultColour(r, g, b, 1)
        rock["Transform"]:SetPosition(x, 0, z)
        if not instant and STAGE_PETRIFY_FX[stage] then
            local fx = SpawnPrefab(STAGE_PETRIFY_FX[stage])
            if fx then
                fx["Transform"]:SetPosition(x, y, z)
                fx:InheritColour(r, g, b)
            end
        end
    end
end

--石化狗狗
function HH_UTILS:StoneDog(inst)
    if not inst["components"]["health"]:IsDead() and (not inst["sg"]:HasStateTag("busy") or inst:IsAsleep()) then
        local x, y, z = getWorldPos(inst)
        local rot = inst["Transform"]:GetRotation()
        inst:Remove()
        local gargoyle = SpawnPrefab(stone_dog[math["random"](#stone_dog)])
        if not gargoyle then
            return
        end
        gargoyle["Transform"]:SetPosition(x, y, z)
        gargoyle["Transform"]:SetRotation(rot)
        gargoyle:Petrify()
    end
end


--石化猪人
function HH_UTILS:StonePig(inst)
    if not inst["components"]["health"]:IsDead() and (not inst["sg"]:HasStateTag("busy") or inst:IsAsleep()) then
        local x, y, z = getWorldPos(inst)
        local rot = inst["Transform"]:GetRotation()
        local name = inst["components"]["named"]["name"]
        inst:Remove()
        local gargoyle = SpawnPrefab(stone_pig[math["random"](#stone_pig)])
        if not gargoyle then
            return
        end
        gargoyle["components"]["named"]:SetName(name)
        gargoyle["Transform"]:SetPosition(x, y, z)
        gargoyle["Transform"]:SetRotation(rot)
        gargoyle:Petrify()
    end
end

function HH_UTILS:GetPrefabName(prefab_id)
    if not HH_UTILS:IsHHType(prefab_id, "string") or prefab_id == "" then
        return "传参错误"
    end
    return tostring(STRINGS["NAMES"][string["upper"](prefab_id)] or "名称未定义")
end
----
---某段函数 内置cd函数
---@param inst-实体
---@param cd_id-boolean值标记是否在cd中
---@param cd_time-冷却
---@param extra_func-拒绝时执行的函数
---@param more_func-不在cd时的执行函数(主要执行的业务函数)
---@param （...）more_func执行函数
---
function HH_UTILS:AddCdTask(inst, cd_id, cd_time, extra_func, more_func, ...)
    if not HH_UTILS:IsHHType(inst, "table")
            or not HH_UTILS:IsHHType(cd_time, "number")
            or cd_time < 0
    then
        return
    end
    local cd_index = cd_id
    if inst[cd_index] then
        if HH_UTILS:IsHHType(extra_func, "function") then
            extra_func(inst, cd_time)
        end
        --print(inst, cd_id, cd_time, "函数cd中")
        return
    end
    if HH_UTILS:IsHHType(more_func, "function") then
        more_func(...)
    end
    inst[cd_index] = true
    inst:DoTaskInTime(cd_time, function(_inst)
        _inst[cd_index] = false
        --print(_inst, cd_index, "函数cd冷却完毕")
    end)
end
----
---判断是否在冷却中
---@param inst:实体
---@param cd_id:标识判断
---
function HH_UTILS:CheckCdTask(inst, cd_id)
    return inst[cd_id]
end

----
---根据长度将字符拆成对应字数的多行文字
function HH_UTILS:SubStrByLength(test_str, num)
    local sub_num = num or 12
    local str_num = HH_UTILS:GetStringWordNum(test_str)
    local extra_num = str_num % sub_num
    local floor_num = math["floor"](str_num / sub_num) + (extra_num == 0 and 0 or 1)
    local new_str = ""
    for i = 1, floor_num do
        local sub_str = HH_UTILS:SubStringUTF8(test_str, (i - 1) * sub_num + 1, i * sub_num)
        new_str = new_str .. sub_str .. "\n"
    end
    return new_str
end
----
---移除文本中的空格
---
function HH_UTILS:RemoveWhiteText(hh_text)
    return hh_text:gsub("\n%s*", "\n"):gsub("^%s*", "")
end
----
---同步主机参数到客机
---
function HH_UTILS:SynchronizeClientValue(player, key)
    if HH_UTILS:HasComponents(player, "hh_player") and (type(key) == "string") then
        local client_value = player["components"]["hh_player"]:GetEffectValueByKey(key)
        HH_UTILS:HHClientRpc(player, key, client_value)
    end
end

----
---读取文本文字
---
function HH_UTILS:GetStrByKey(key, str_index)
    if not HH_TEXT[key] then
        return "未定义文本"
    end
    return tostring(HH_TEXT[key][str_index] or "文本索引失效")
end

function HH_UTILS:SendEggToPlayer(player, egg_id, egg_num)
    if not HH_UTILS:NotIsDead(player) then
        return
    end
    if not HH_UTILS:HasComponents(player, "inventory") then
        return
    end
    local egg_prefab = SpawnPrefab(egg_id)
    if egg_prefab then
        if HH_UTILS:IsHHType(egg_num, "number") and egg_num > 0 and HH_UTILS:HasComponents(egg_prefab, "stackable") then
            egg_prefab["components"]["stackable"]:SetStackSize(egg_num)
        end
        player["components"]["inventory"]:GiveItem(egg_prefab)
    end
end
----
---生成道具 自动设置角度抛物线
---
function HH_UTILS:SpawnLaunchItem(inst, item_id, item_num)
    if inst and inst["Transform"] and HH_UTILS:IsHHType(item_id, "string") then
        local x, y, z = inst["Transform"]:GetWorldPosition()
        local hh_spawn_item = SpawnPrefab(item_id)
        if hh_spawn_item and hh_spawn_item["Transform"] then
            hh_spawn_item["Transform"]:SetPosition(x, 1.5, z)
            if HH_UTILS:HasComponents(hh_spawn_item, "stackable") and HH_UTILS:IsHHType(item_num, "number")
                    and item_num > 0
            then
                hh_spawn_item["components"]["stackable"]:SetStackSize(item_num)
            end
            local angle = math["random"](1, 360)
            if hh_spawn_item["Physics"] then
                local speed = math["random"]() * 4 + 2
                angle = (angle + math["random"]() * 60 - 30) * DEGREES
                hh_spawn_item["Physics"]:SetVel(speed * math["cos"](angle), 5, speed * math["sin"](angle))
            end
        end
    end
end

function HH_UTILS:UpdateSkinItem(player_inst, target)
    if HH_UTILS:HasComponents(player_inst, "hh_skin") and HH_UTILS:IsHHType(target, "table") then
        player_inst["components"]["hh_skin"]:ToolChangeSkin(target)
    end
end
----
---uid加模糊
---
function HH_UTILS:GetSubUID(str)
    -- 检查输入是否为字符串
    if type(str) ~= "string" then
        return str
    end
    local len = HH_UTILS:GetStringWordNum(str)  -- 使用 GetStringWordNum 获取真实字符数
    -- 如果字符串长度小于等于4，直接返回原字符串
    if len <= 4 then
        return str
    end
    -- 获取前两个和后两个字符（兼容中英文）
    local prefix = HH_UTILS:SubStringUTF8(str, 1, 2)
    local suffix = HH_UTILS:SubStringUTF8(str, len - 1, len)
    -- 计算中间需要替换为*的字符数量
    local middleCount = len - 4
    -- 生成相应数量的*
    local middle = string["rep"]("*", middleCount)
    -- 拼接结果
    return prefix .. middle .. suffix
end
----
---世界限制
---
function HH_UTILS:CheckWorldLimit(item_id)
    local world = TheWorld
    local base_result = false
    if HH_UTILS:HasComponents(world, "hh_world_limit") then
        local limitComp = world["components"]["hh_world_limit"]
        base_result = limitComp:CheckItemNum(item_id)
    end
    --print("是否能掉落", item_id, base_result)
    return base_result
end

----
---世界限制DoDelta
---
function HH_UTILS:DoDeltaWorldLimit(item_id, change_num)
    local world = TheWorld
    if HH_UTILS:HasComponents(world, "hh_world_limit") then
        local limitComp = world["components"]["hh_world_limit"]
        limitComp:DoDelta(item_id, change_num)
    end
end
----
---文本类封装到单独的文件中取
---所有format处理的改为模板处理Template
---
function HH_UTILS:GetLanguageByKey(type_index, item_key)
    local base_str = "未定义"
    if not (HH_UTILS:IsHHType(type_index, "string") and HH_UTILS:IsHHType(item_key, "string")) then
        return base_str
    end
    if not HH_UTILS:IsHHType(HH_LANGUAGE[type_index], "table") then
        return base_str
    end
    return tostring(HH_LANGUAGE[type_index][item_key] or base_str)
end

----
---文本类封装到单独的文件中取-table
---所有format处理的改为模板处理Template
---
function HH_UTILS:GetLanguageTableByKey(type_index)
    local base_str = {}
    if not HH_UTILS:IsHHType(type_index, "string") then
        return base_str
    end
    if not HH_UTILS:IsHHType(HH_LANGUAGE[type_index], "table") then
        return base_str
    end
    return HH_LANGUAGE[type_index]
end

----
---获取格式化当前时间：YYYY-MM-DD HH:MM:SS
---自带异常保护，环境出错也返回空字符串，不报错
---
function HH_UTILS:GetCurrentDateTime()
    -- 异常捕获：防止 os.date 不可用/环境报错导致崩溃
    local success, result = pcall(function()
        return os["date"]("%Y年%m月%d日 %H时%M分%S秒")
    end)
    -- 成功返回时间，失败返回空字符串
    return success and result or ""
end
----
---增加日志
---
function HH_UTILS:AddLog(log_type, log_msg)
    local inst = TheWorld
    if not HH_UTILS:HasComponents(inst, "hh_world_log") then
        return
    end
    local logComp = inst["components"]["hh_world_log"]
    logComp:AddLog(log_type, log_msg)
end

function HH_UTILS:HHSayV2(inst, say_str)
    HH_UTILS:HHSayExtraFx(inst, { ["str"] = tostring(say_str) })
end
function HH_UTILS:HHSayExtraFx(inst, data)
    if not (inst and inst["entity"] and HH_UTILS:IsHHType(data, "table")) then
        return
    end
    HH_UTILS:HHRemoveFx(inst, "ovo_talk_fx")
    inst["ovo_talk_fx"] = SpawnPrefab("hh_talk_fx")
    if HH_UTILS:HasComponents(inst["ovo_talk_fx"], "talker") then
        local fx_inst = inst["ovo_talk_fx"]
        fx_inst["entity"]:SetParent(inst["entity"])
        local data_str = HH_UTILS:TableToStr(data)
        if HH_UTILS:IsHHType(fx_inst["UpdateTalkData"], "function") then
            fx_inst:UpdateTalkData(data_str)
        end
        local say_str = data["str"]
        inst:DoTaskInTime(0.1, function(data_inst)
            HH_UTILS:HHSay(fx_inst, tostring(say_str))
        end)
    end
end

--------------------------------------------富文本解析-----------------------------------------------
-- ====================== 配置表 ======================
local IMAGE_CONFIG = TUNING and TUNING["HH_OVO_CONFIG"] and TUNING["HH_OVO_CONFIG"]["UI_IMAGE"] or {}
local COLOR_CONFIG = TUNING and TUNING["HH_OVO_CONFIG"] and TUNING["HH_OVO_CONFIG"]["UI_COLOR"] or {}
local IMAGE_FN_CONFIG = TUNING and TUNING["HH_OVO_CONFIG"] and TUNING["HH_OVO_CONFIG"]["UI_EXTRA_FN"] or {}

-- ====================== 默认值 ======================
local DEFAULTS = {
    ["TEXT"] = {
        ["str"] = "",
        ["color"] = "white",
        ["scale"] = 30
    },
    ["IMAGE"] = {
        ["key"] = "default",
        ["color"] = "white",
        ["size_x"] = 32,
        ["size_y"] = 32
    }
}
-- ====================== 解析器核心 ======================

local function getColor(colorName)
    local name = colorName or DEFAULTS["TEXT"]["color"]
    return COLOR_CONFIG[name] or COLOR_CONFIG[DEFAULTS["TEXT"]["color"]]
end

local function richEmptyFn()
end
local function getExtraFn(fn_id)
    return IMAGE_FN_CONFIG[fn_id] or richEmptyFn
end
local function getImageResource(key)
    local k = key or DEFAULTS["IMAGE"]["key"]
    local res = IMAGE_CONFIG[k] or IMAGE_CONFIG["default"]
    return res[1], res[2]
end
----
---字符串解析为ui用的表 参数可为空 :后面还有参数就不能省略
---这是一段普通文字
---#这是红色大字:red:2
---#普通字@essence:blue:64:64结尾@default:purple::100
---
function HH_UTILS:ParseStrToUi(inputStr)
    local result = {}
    inputStr = inputStr or ""
    local current_pos = 1
    local len = #inputStr
    while current_pos <= len do
        local next_hash, _ = inputStr:find("#", current_pos, true)
        local next_at, _ = inputStr:find("@", current_pos, true)

        local next_pos = math["min"](next_hash or math["huge"], next_at or math["huge"])

        if next_pos == math["huge"] then
            local remaining = inputStr:sub(current_pos)
            if remaining ~= "" then
                table["insert"](result, {
                    ["type"] = "text",
                    ["str"] = remaining,
                    ["color"] = getColor(),
                    ["scale"] = DEFAULTS["TEXT"]["scale"]
                })
            end
            break
        end

        local normal_text = inputStr:sub(current_pos, next_pos - 1)
        if normal_text ~= "" then
            table["insert"](result, {
                ["type"] = "text",
                ["str"] = normal_text,
                ["color"] = getColor(),
                ["scale"] = DEFAULTS["TEXT"]["scale"]
            })
        end

        local symbol = inputStr:sub(next_pos, next_pos)
        current_pos = next_pos + 1

        local data_end = inputStr:find("[#@]", current_pos) or (len + 1)
        local data_str = inputStr:sub(current_pos, data_end - 1)

        if symbol == "#" then
            -- 解析文本: #文字内容:颜色:大小
            -- 将数据按 ':' 分割成最多3个部分
            local parts = {}
            local last_pos = 1
            local count = 0
            for i = 1, 3 do
                -- 最多三个参数
                local pos = data_str:find(":", last_pos)
                if not pos then
                    table["insert"](parts, data_str:sub(last_pos))
                    break
                else
                    table["insert"](parts, data_str:sub(last_pos, pos - 1))
                    last_pos = pos + 1
                end
            end

            -- 确保有3个槽位
            while #parts < 3 do
                table["insert"](parts, "")
            end

            local content = parts[1]
            local color_param = parts[2] == "" and nil or parts[2]
            local scale_param = parts[3] == "" and nil or parts[3]

            table["insert"](result, {
                ["type"] = "text",
                ["str"] = content,
                ["color"] = getColor(color_param),
                ["scale"] = scale_param and tonumber(scale_param) or DEFAULTS["TEXT"]["scale"]
            })
        elseif symbol == "@" then
            -- 解析图片: @图片键值:颜色:宽度:高度
            -- 将数据按 ':' 分割成最多4个部分
            local parts = {}
            local last_pos = 1
            for i = 1, 5 do
                -- 最多5个参数
                local pos = data_str:find(":", last_pos)
                if not pos then
                    table["insert"](parts, data_str:sub(last_pos))
                    break
                else
                    table["insert"](parts, data_str:sub(last_pos, pos - 1))
                    last_pos = pos + 1
                end
            end

            -- 确保有5个槽位
            while #parts < 5 do
                table["insert"](parts, "")
            end

            local key_param = parts[1] == "" and nil or parts[1]
            local color_param = parts[2] == "" and nil or parts[2]
            local size_x_param = parts[3] == "" and nil or parts[3]
            local size_y_param = parts[4] == "" and nil or parts[4]
            local rich_fn_id = parts[5] == "" and nil or parts[5]

            local current_xml, current_tex = getImageResource(key_param)

            table["insert"](result, {
                ["type"] = "image",
                ["xml"] = current_xml,
                ["tex"] = current_tex,
                ["color"] = getColor(color_param),
                ["size_x"] = size_x_param and tonumber(size_x_param) or DEFAULTS["IMAGE"]["size_x"],
                ["size_y"] = size_y_param and tonumber(size_y_param) or DEFAULTS["IMAGE"]["size_y"],
                ["extra_fn"] = getExtraFn(rich_fn_id),
            })
        end
        current_pos = data_end
    end
    if #result == 0 then
        table["insert"](result, {
            ["type"] = "text",
            ["str"] = DEFAULTS["TEXT"]["str"],
            ["color"] = getColor(),
            ["scale"] = DEFAULTS["TEXT"]["scale"]
        })
    end
    return result
end
----
---解析字符+创建ui
---
function HH_UTILS:CreateByCustomText(father, text_str, ui_type)
    local str_list = self:ParseStrToUi(tostring(text_str))
    return self:CreateImageAndText(father, str_list, ui_type)
end
----
---创建多个往下的ui
---
function HH_UTILS:CreateMoreParseUi(father, text_list, child_ui_type)
    local result_ui = father:AddChild(Widget(""))
    local start_x, start_y = 0, 0
    if HH_UTILS:IsHHType(text_list, "table") then
        for i, v in ipairs(text_list) do
            local str_list = self:ParseStrToUi(tostring(v))
            result_ui["ui_" .. i] = self:CreateImageAndText(result_ui, str_list, child_ui_type)
            local child_size_x = tonumber(result_ui["ui_" .. i]["max_x"]) or 0
            local child_size_y = tonumber(result_ui["ui_" .. i]["max_y"]) or 0
            result_ui["ui_" .. i]:SetPosition(0, start_y - child_size_y / 2, 0)
            start_x = math["max"](start_x, child_size_x)
            start_y = start_y - child_size_y
        end
    end
    result_ui["max_x"] = math["abs"](start_x)
    result_ui["max_y"] = math["abs"](start_y)
    return result_ui
end
----
---字符串切割成表
---
function HH_UTILS:StrSplitTable(str, delimiter)
    -- 如果分隔符是特殊字符，需要转义
    delimiter = delimiter or "%s" -- 默认按空白字符分割
    if delimiter == "" then
        -- 如果分隔符为空，则按单个字符分割
        local result = {}
        for i = 1, #str do
            table["insert"](result, str:sub(i, i))
        end
        return result
    end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table["insert"](result, match)
    end
    return result
end
--------------------------------------------富文本解析-----------------------------------------------
function HH_UTILS:GetPlayerDataByKey(player, item_key)
    if not (HH_UTILS:HasComponents(player, "hh_data") and HH_UTILS:IsHHType(item_key, "string")) then
        return 0
    end
    local dataComp = player["components"]["hh_data"]
    return tonumber(dataComp:GetParamsValue(item_key)) or 0
end
return HH_UTILS

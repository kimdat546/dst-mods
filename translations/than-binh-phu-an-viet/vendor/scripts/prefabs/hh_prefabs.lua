local HH_UTILS = require("utils/hh_utils")
local HH_CONFIG = require("enums/hh_enchant")
local HH_EQUIP_BUFF_LIST = HH_CONFIG["HH_EQUIP_BUFF_LIST"]

local function OnItemGet(inst, data)
    if not HH_UTILS:HasComponents(inst["hh_ui_owner"], "hh_player") or not data or not data["item"] or not data["slot"] then
        return
    end
    --登记第一个装备的词条属性
    if data["slot"] == 1 and HH_UTILS:HasComponents(data["item"], "hh_equip") then
        local equip_effects = data["item"]["components"]["hh_equip"]["equip_buff_list"]
        HH_UTILS:HHClientRpc(inst["hh_ui_owner"], "hh_forge_equip", HH_UTILS:TableToStr(equip_effects))
    end
    --同步强化页面服务端信息
    local inst_owner = inst["hh_ui_owner"]
    if HH_UTILS:HasComponents(inst["hh_ui_owner"], "hh_player") then
        inst_owner["components"]["hh_player"]:GetForgeEquipInfo()
    end
    HH_UTILS:ForgeStoneClient(inst)
end

local function OnItemLose(inst, data)
    if not HH_UTILS:HasComponents(inst["hh_ui_owner"], "hh_player") or not data or not data["prev_item"] or not data["slot"] then
        return
    end
    if data["slot"] == 1 and HH_UTILS:HasComponents(data["prev_item"], "hh_equip") then
        HH_UTILS:HHClientRpc(inst["hh_ui_owner"], "hh_forge_equip", HH_UTILS:TableToStr({}))
    end
    --同步强化页面服务端信息
    local inst_owner = inst["hh_ui_owner"]
    if HH_UTILS:HasComponents(inst["hh_ui_owner"], "hh_player") then
        inst_owner["components"]["hh_player"]:GetForgeEquipInfo()
    end
    HH_UTILS:ForgeStoneClient(inst)
end

local function CreateContainer(name, ui, isFridge)
    local function container_fn()
        local inst = CreateEntity()

        inst["entity"]:AddTransform()
        inst["entity"]:AddAnimState()
        inst["entity"]:AddSoundEmitter()
        inst["entity"]:AddNetwork()

        if isFridge then
            inst:AddTag("fridge")
        end
        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("dcs2hm")--fuck为爽 整理按钮

        inst["entity"]:SetPristine()

        if not TheWorld["ismastersim"] then
            inst["OnEntityReplicated"] = function(inst)
                inst["replica"]["container"]:WidgetSetup(ui)
            end
            return inst
        end
        inst:AddComponent("container")
        inst["components"]["container"]:WidgetSetup(ui)
        inst["components"]["container"]["skipclosesnd"] = true
        inst["components"]["container"]["skipopensnd"] = true
        if ui == "hh_forge_container" then
            inst:ListenForEvent("itemget", OnItemGet)
            inst:ListenForEvent("itemlose", OnItemLose)
        end
        return inst
    end
    return Prefab(name, container_fn)
end
local assets = {
    Asset("ANIM", "anim/hh_items.zip"),
    Asset("IMAGE", "images/hh_icon/hh_items.tex"),
    Asset("ATLAS", "images/hh_icon/hh_items.xml"),
    Asset("ATLAS_BUILD", "images/hh_icon/hh_items.xml", 256),
}

local function OnSave(inst, data)
    data["hh_effect"] = inst["hh_effect"]
end

local function OnLoad(inst, data)
    if not data then
        return
    end
    inst["hh_effect"] = data["hh_effect"]
    if inst["HH_Update_Server"] then
        inst:HH_Update_Server()
    end
end
----
---创建实体 挂在附魔石上用于显示
---
local function createChildPrefab()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddLabel()
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst["Label"]:SetFontSize(16)
    inst["Label"]:SetFont(CODEFONT)
    inst["Label"]:SetWorldOffset(0, 2, 0)
    inst["Label"]:SetUIOffset(0, 2, 0)
    inst["Label"]:Enable(false)
    inst["Label"]:SetText("空")
    inst["persists"] = false
    return inst
end
local function updateChildText(inst)
    if inst and inst["hh_child_str"] and inst["hh_child"] and inst["hh_child"]["Label"] then
        local hh_str = inst["hh_child_str"]:value()
        local hh_label = inst["hh_child"]["Label"]
        hh_label:SetText(tostring(hh_str))
        if not TUNING["HH_SHOW_STONE_TEXT"] then
            hh_label:SetText("")
        end
        hh_label:Enable(true)
        --附魔石增加特殊的颜色显示
        local effect_id = inst["hh_client_effect"] and inst["hh_client_effect"]:value() or nil
        if effect_id and HH_EQUIP_BUFF_LIST[effect_id] then
            if HH_EQUIP_BUFF_LIST[effect_id]["client_color"] then
                local color_config = HH_EQUIP_BUFF_LIST[effect_id]["client_color"]
                hh_label:SetColour(color_config[1] or 1, color_config[2] or 1, color_config[3] or 1)
            elseif HH_EQUIP_BUFF_LIST[effect_id]["can_add"] == false then
                hh_label:SetColour(255 / 255, 97 / 255, 0)
            end
        end
    end
end
----
---服务端同步文本
---
local function HH_Update_Server(inst)
    if inst and inst["hh_effect"] and HH_EQUIP_BUFF_LIST[inst["hh_effect"]] and inst["hh_child_str"] then
        if HH_EQUIP_BUFF_LIST[inst["hh_effect"]]["is_suit"] then
            inst:AddTag("hh_suit_stone")--加上炫彩特效
        end
        local hh_gem_str = HH_EQUIP_BUFF_LIST[inst["hh_effect"]]["name"]
        inst["hh_child_str"]:set(tostring(hh_gem_str) .. "\n↓")
        inst["hh_client_effect"]:set(tostring(inst["hh_effect"]))
    end
end
local function makeItems(name, file_name, tag_name)
    local function fn()
        local inst = CreateEntity()
        inst["entity"]:AddTransform()
        inst["entity"]:AddAnimState()
        inst["entity"]:AddSoundEmitter()
        inst["entity"]:AddNetwork()
        --添加图片显示词条
        if name == "hh_effect_stone" then
            inst["hh_child_str"] = net_string(inst["GUID"], "hh_child_str", "hh_child_str")
            inst["hh_client_effect"] = net_string(inst["GUID"], "hh_client_effect", "hh_client_effect")
            inst["hh_child"] = createChildPrefab()
            inst["hh_child"]["entity"]:SetParent(inst["entity"])
            inst:ListenForEvent("hh_child_str", updateChildText)
        end

        inst["AnimState"]:SetBank("hh_items")
        inst["AnimState"]:SetBuild("hh_items")
        inst["AnimState"]:PlayAnimation("idle")
        if file_name then
            inst["AnimState"]:OverrideSymbol("hh_remove_stone", "hh_items", file_name)
        end

        inst:AddTag(tag_name)
        inst:AddTag(name)
        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, "med", 0.3, 0.8)

        inst["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return inst
        end

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst["components"]["inventoryitem"]["imagename"] = name
        inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_items.xml"
        if name == "hh_effect_tally" or name == "hh_remove_stone" then
            inst:AddComponent("stackable")
            inst["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_SMALLITEM"]
        end
        if name == "hh_effect_stone" then
            inst["hh_effect"] = nil
            inst["components"]["tradable"]["goldvalue"] = 5
            inst["HH_Update_Server"] = HH_Update_Server
            inst["OnSave"] = OnSave
            inst["OnLoad"] = OnLoad
        end
        if name == "hh_essence" then
            inst:AddComponent("stackable")
            inst["components"]["stackable"]["maxsize"] = TUNING["STACK_SIZE_PELLET"]
            inst["components"]["tradable"]["goldvalue"] = 5
            inst["GetHHSpDesc03"] = function(inst, player)
                return {
                    ["title"] = "特殊",
                    ["desc"] = "特殊合成材料",
                }
            end
        end

        return inst
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_items.xml", name .. ".tex")
    return Prefab(name, fn, assets)
end
local color_config = {
    { ["name"] = "打孔石", ["color"] = { 255 / 255, 11 / 255, 0 / 255 } },
    { ["name"] = "解石器", ["color"] = { 0 / 255, 101 / 255, 255 / 255 } },
    { ["name"] = "重置宝石", ["color"] = { 255 / 255, 102 / 255, 0 / 255 } },
    --{ ["name"] = "耐用宝珠", ["color"] = { 255 / 255, 242 / 255, 0 / 255 } },
    --{ ["name"] = "增伤宝珠", ["color"] = { 101 / 255, 255 / 255, 0 / 255 } },
}
local function getTextColor(str)
    local base_color = { 255 / 255, 204 / 255, 51 / 255 }
    if HH_UTILS:IsHHType(str, "string") then
        for i, v in ipairs(color_config) do
            if v and v["name"] and v["color"]
                    and string["find"](str, v["name"])
            then
                base_color = v["color"]
                break
            end
        end
    end
    return base_color
end
--飘字
local function UpdatePing(inst, t0, duration)
    local t = GetTime() - t0
    local k = 1 - math["max"](0, t - 0.1) / duration
    k = 1 - k * k
    local s = Lerp(15, 30, k)--字体从15到30
    local y = Lerp(4, 5, k)--高度从4到5
    local label = inst["Label"]
    if label then
        label:SetFontSize(s)
        --label:SetWorldOffset(0, y, 0)
    end
end
local function SetTextValue(inst)
    local str = inst["hh_tips"]:value()
    local label = inst["Label"]
    local text_color = getTextColor(str)
    label:SetText(str)
    label:Enable(true)
    label:SetColour(unpack(text_color))
    inst:DoPeriodicTask(0, UpdatePing, nil, GetTime(), 0.8)
end
--文字提示
local function hh_tips()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddNetwork()
    inst["entity"]:SetCanSleep(false)
    --增加物理
    --local phys = inst["entity"]:AddPhysics()
    --phys:SetMass(0)
    --phys:SetFriction(0.1)
    --phys:SetDamping(0)
    --phys:SetRestitution(.5)
    --phys:SetCollisionGroup(COLLISION.ITEMS)
    --phys:ClearCollisionMask()
    --phys:CollidesWith(COLLISION.GROUND)
    --phys:SetSphere(0.5)

    MakeInventoryPhysics(inst)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    local label = inst["entity"]:AddLabel()
    --字体
    label:SetFont(NUMBERFONT)
    --文字大小
    label:SetFontSize(15)
    --初始偏移
    label:SetWorldOffset(0, 0, 0)
    --颜色
    label:SetColour(255 / 255, 204 / 255, 51 / 255)
    --默认文本
    label:SetText("获得物品")
    label:Enable(false)
    --net-字符串
    inst["hh_tips"] = net_string(inst["GUID"], "hh_tips", "hh_tips")
    --监听net
    inst:ListenForEvent("hh_tips", SetTextValue)

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end

    inst["persists"] = false
    local duration = 2--持续时间
    inst:DoTaskInTime(duration, inst["Remove"])

    return inst
end
local function getFxTextColor(str)
    local base_color = { 255 / 255, 204 / 255, 51 / 255 }
    if HH_UTILS:IsHHType(str, "string") then
        local max_index = #TUNING["HH_COLOR_CONFIG"]
        local random_index = math["random"](1, max_index)
        local random_color = TUNING["HH_COLOR_CONFIG"][random_index]["color"]
        base_color = { random_color[1] / 255, random_color[2] / 255, random_color[3] / 255, 1 }
    end
    return base_color
end

local function UpdateTextFx(inst, t0, duration)
    local t = GetTime() - t0
    local k = 1 - math["max"](0, t - 0.1) / duration
    k = 1 - k * k
    local s = Lerp(20, 40, k)--字体从15到30
    local y = Lerp(4, 5, k)--高度从4到5
    local label = inst["Label"]
    if label then
        label:SetFontSize(s)
        --label:SetWorldOffset(0, y, 0)
    end
end
local function updateClientStr(hh_inst)
    local str = hh_inst["hh_client_str"]:value()
    local hh_label = hh_inst["Label"]
    hh_label:SetText(str)
    hh_label:Enable(true)
    hh_label:SetColour(unpack(getFxTextColor(str)))
    --放大字体
    hh_inst:DoPeriodicTask(0, UpdateTextFx, nil, GetTime(), 0.8)
end
local function hh_fx_text()
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddNetwork()
    inst["entity"]:SetCanSleep(false)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    local label = inst["entity"]:AddLabel()
    --字体
    label:SetFont(NUMBERFONT)
    --文字大小
    label:SetFontSize(20)
    --初始偏移
    label:SetWorldOffset(0, 0.5, 0)
    --颜色
    label:SetColour(255 / 255, 204 / 255, 51 / 255)
    --默认文本
    label:SetText("文字")
    label:Enable(false)

    --net-字符串
    inst["hh_client_str"] = net_string(inst["GUID"], "hh_client_str", "hh_client_str")
    --监听net
    inst:ListenForEvent("hh_client_str", updateClientStr)

    inst["entity"]:SetPristine()

    if not TheWorld["ismastersim"] then
        return inst
    end
    inst["persists"] = false
    inst["SetTextStr"] = function(hh_inst, str)
        if hh_inst and HH_UTILS:IsHHType(str, "string") and hh_inst["hh_client_str"] then
            hh_inst["hh_client_str"]:set(str)
        end
    end
    local hh_time = 0
    local random_angle = math.random() * 360
    local hh_two = (2 / 0.325) ^ 2
    local hh_4 = 4 / 0.325
    inst["hh_task"] = inst:DoPeriodicTask(FRAMES, function()
        hh_time = hh_time + FRAMES
        local hh_pos = inst:GetPosition()
        local random_pos = Vector3(1 / 10 * math["cos"](random_angle), hh_4 * FRAMES, 1 / 10 * math["sin"](random_angle))
        --local random_pos = Vector3(1 / 0.325 * FRAMES * math["cos"](random_angle), hh_4 * FRAMES, 1 / 0.325 * FRAMES * math["sin"](random_angle))
        inst["Transform"]:SetPosition(hh_pos["x"] + random_pos["x"], hh_pos["y"] + random_pos["y"] * 1.5, hh_pos["z"] + random_pos["z"])
        hh_4 = hh_4 - hh_two * FRAMES
        if hh_time > 0.65 then
            HH_UTILS:HHKillTask(inst, "hh_task")
            inst:Remove()
        end
    end)
    inst:DoTaskInTime(5, inst["Remove"])
    return inst
end
return
CreateContainer("hh_ui_container", "hh_ui_container", false), --强化容器
CreateContainer("hh_forge_container", "hh_forge_container", false), --合成套装+指定词条清除页面
makeItems("hh_effect_stone", "hh_effect_stone", "hh_add_stone"),
makeItems("hh_effect_tally", "hh_effect_tally", "hh_add_stone"),
makeItems("hh_remove_stone", "hh_remove_stone", "hh_remove_stone"),
makeItems("hh_essence", "hh_essence", "hh_essence"),
Prefab("hh_tips", hh_tips), --文字显示
--火焰刀特效
--Prefab("hh_fx_hot", function()
--    local inst = CreateEntity()
--    inst["entity"]:AddTransform()
--    inst["entity"]:AddAnimState()
--    inst["entity"]:AddNetwork()
--
--
--    inst["AnimState"]:SetBank("hh_items")
--    inst["AnimState"]:SetBuild("hh_items")
--    inst["AnimState"]:PlayAnimation("idle")
--
--    inst["entity"]:SetPristine()
--    if not TheWorld["ismastersim"] then
--        return inst
--    end
--    return inst
--end),
Prefab("hh_fx_text", hh_fx_text)
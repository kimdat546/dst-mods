local HH_UTILS = require("utils/hh_utils")
local HH_JOB_CONFIG = require("job/hh_job_config")
----
---职业类道具
---
--------------------------------------------------职业卡---------------------------------------------------------------
--客机文字
local function createChildPrefab(data)
    local hh_name = data["name"] or "职业"
    local hh_color = data["color"] or { 1, 1, 1 }
    local hh_scale = data["scale"] or 16
    local inst = CreateEntity()
    inst["entity"]:AddTransform()
    inst["entity"]:AddLabel()
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst["Label"]:SetFontSize(hh_scale)
    inst["Label"]:SetFont(CODEFONT)
    inst["Label"]:SetWorldOffset(0, 1.2, 0)
    inst["Label"]:SetUIOffset(0, 0.8, 0)
    inst["Label"]:Enable(true)
    inst["Label"]:SetText(tostring(hh_name))
    inst["Label"]:SetColour(unpack(hh_color))
    inst["persists"] = false
    return inst
end

----
---服务端同步文本
---
local function HH_Update_Server_Fn(inst)
    if inst and inst["hh_job_id"] and HH_JOB_CONFIG[inst["hh_job_id"]] and inst["hh_client_str"] then
        local job_id = inst["hh_job_id"]
        if job_id and HH_JOB_CONFIG[job_id] then
            local job_config = HH_JOB_CONFIG[job_id]
            inst["hh_client_job"]:set(tostring(job_id))
            inst["hh_client_str"]:set("职业卡-" .. tostring(job_config["name"]))
        end
    end
end

local function updateChildText(inst)
    if inst and inst["hh_client_str"] and inst["hh_child"] and inst["hh_child"]["Label"] then
        local hh_str = inst["hh_client_str"]:value()
        local hh_label = inst["hh_child"]["Label"]
        hh_label:SetText(tostring(hh_str))
        hh_label:Enable(true)
    end
end
--------------------------------------------------职业卡---------------------------------------------------------------
local HH_LIST = {
    ["hh_job_card"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_job_card.zip"),
            Asset("IMAGE", "images/hh_icon/hh_job_item.tex"),
            Asset("ATLAS", "images/hh_icon/hh_job_item.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_job_item.xml", 256),
        },
        ["name"] = "职业卡片", ["recipe_str"] = "转职道具", ["desc"] = "转职道具",
        ["xml"] = "images/hh_icon/hh_items.xml",
        ["client_fn"] = function(inst, name)
            inst["AnimState"]:SetBank("hh_job_card")
            inst["AnimState"]:SetBuild("hh_job_card")
            inst["AnimState"]:PlayAnimation("idle")
            inst:AddTag("hh_job_card")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
            inst["Transform"]:SetScale(0.8, 0.8, 0.8)

            inst["hh_client_str"] = net_string(inst["GUID"], "hh_client_str", "hh_client_str")
            inst["hh_client_job"] = net_string(inst["GUID"], "hh_client_job", "hh_client_job")

            inst["hh_child"] = createChildPrefab({ ["name"] = "职业卡-无效职业", ["color"] = { 1, 1, 0, 1 }, })
            inst["hh_child"]["entity"]:SetParent(inst["entity"])
            inst:ListenForEvent("hh_client_str", updateChildText)
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_job_item.xml"

            inst["hh_job_id"] = nil
            inst["HH_Update_Server"] = HH_Update_Server_Fn
            inst["OnSave"] = function(_inst, data)
                data["hh_job_id"] = _inst["hh_job_id"]
            end
            inst["OnLoad"] = function(_inst, data)
                if not data then
                    return
                end
                _inst["hh_job_id"] = data["hh_job_id"]
                if _inst["HH_Update_Server"] then
                    _inst:HH_Update_Server()
                end
            end
            inst["GetHHSpDesc01"] = function(_inst, player)
                local job_name = "无效职业"
                if _inst["hh_job_id"] and HH_JOB_CONFIG[_inst["hh_job_id"]] then
                    job_name = tostring(HH_JOB_CONFIG[_inst["hh_job_id"]]["name"])
                end
                return {
                    ["title"] = "职业",
                    --["desc"] = "转换职业的道具",
                    ["desc"] = job_name,
                }
            end
        end,
    },
    ["hh_job_container"] = {
        ["assets"] = {},
        ["name"] = "职业空间", ["recipe_str"] = "职业空间", ["desc"] = "职业空间",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst:AddTag("CLASSIFIED")
            inst:AddTag("NOCLICK")
            inst:AddTag("dcs2hm")
            if not TheWorld["ismastersim"] then
                inst["OnEntityReplicated"] = function(_inst)
                    _inst["replica"]["container"]:WidgetSetup("hh_job_container")
                end
                return inst
            end
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("container")
            inst["components"]["container"]:WidgetSetup("hh_job_container")
            inst["components"]["container"]["skipclosesnd"] = true
            inst["components"]["container"]["skipopensnd"] = true
        end,
    },
    ["hh_cat_staff"] = {
        ["assets"] = {
            Asset("ANIM", "anim/hh_cat_staff.zip"),
            Asset("IMAGE", "images/hh_icon/hh_cat_staff.tex"),
            Asset("ATLAS", "images/hh_icon/hh_cat_staff.xml"),
            Asset("ATLAS_BUILD", "images/hh_icon/hh_cat_staff.xml", 256),
        },
        ["name"] = "猫猫法杖", ["recipe_str"] = "猫猫法杖", ["desc"] = "猫猫法杖",
        ["client_fn"] = function(inst, name)
            inst["entity"]:AddSoundEmitter()
            inst["AnimState"]:SetBank("hh_cat_staff")
            inst["AnimState"]:SetBuild("hh_cat_staff")
            inst["AnimState"]:PlayAnimation("idle")
            inst:AddTag("hh_cat_staff")
            inst:AddTag("weapon")
            inst:AddTag("sharp")
            MakeInventoryPhysics(inst)
            MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        end,
        ["server_fn"] = function(inst, name)
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst["components"]["inventoryitem"]["imagename"] = name
            inst["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_cat_staff.xml"

            inst:AddComponent("equippable")
            inst["components"]["equippable"]:SetOnEquip(function(_inst, owner)
                owner["AnimState"]:OverrideSymbol("swap_object", "hh_cat_staff", "hh_cat_staff")
                owner["AnimState"]:Show("ARM_carry")
                owner["AnimState"]:Hide("ARM_normal")
            end)
            inst["components"]["equippable"]:SetOnUnequip(function(_inst, owner)
                owner["AnimState"]:Hide("ARM_carry")
                owner["AnimState"]:Show("ARM_normal")
            end)
            inst:AddComponent("weapon")
            inst["components"]["weapon"]:SetRange(1, 1.5)
            inst["components"]["weapon"]:SetDamage(50)
        end,

    },

}
return HH_LIST
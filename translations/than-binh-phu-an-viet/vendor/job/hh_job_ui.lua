local HH_UTILS = require("utils/hh_utils")
local HH_JOB_CONFIG = require("job/hh_job_config")
--local HH_JOB_UI = require("widgets/hh_ui/hh_job_ui")
--AddClassPostConstruct("widgets/controls", function(self, owner)
--    self["hh_job_ui"] = self:AddChild(HH_JOB_UI(self["owner"]))
--    self["hh_job_ui"]:MoveToBack()
--
--end)

local hh_red = { 255 / 255, 11 / 255, 0 / 255, 1 }
local hh_blue = { 0 / 255, 101 / 255, 255 / 255, 1 }
local hh_orange = { 255 / 255, 102 / 255, 0 / 255, 1 }
local hh_yellow = { 255 / 255, 242 / 255, 0 / 255, 1 }
local hh_green = { 101 / 255, 255 / 255, 0 / 255, 1 }
local hh_purple = { 143 / 255, 0 / 255, 255 / 255, 1 }
----
---职业卡增加物品栏描述
---
local function addSlotText(self)
    local inst = self["item"]
    if inst and inst["prefab"] and inst["prefab"] == "hh_job_card" and inst["hh_client_job"] then
        local client_job_id = inst["hh_client_job"]:value()
        if HH_JOB_CONFIG[tostring(client_job_id)] then
            local job_config = HH_JOB_CONFIG[tostring(client_job_id)]
            if job_config["client_text"] then
                local job_str = tostring(job_config["client_text"])
                self["hh_job_text"] = HH_UTILS:HHCreateTextUi(self, Vector3(0, 0, 1), job_str, { 1, 1, 1, 1 }, 40, true)
                local hh_job_text_size_x, hh_job_text_size_y = self["hh_job_text"]:GetRegionSize()
                self["hh_job_text"]:SetPosition(-32 + hh_job_text_size_x / 2, -32 + hh_job_text_size_y / 2, 0)
                self["hh_job_text"]:SetClickable(false)
                self["hh_fx_anim"] = HH_UTILS:CreateAnimUi(self, "hh_slot_fx", "hh_slot_fx", "idle", true, 0.18)
                local base_color = { 1, 1, 1, 1 }
                if HH_UTILS:IsHHType(job_config["color"], "table") then
                    base_color = job_config["color"]
                end
                self["hh_fx_anim"]:GetAnimState():SetMultColour(unpack(base_color))
                self["hh_fx_anim"]:MoveToBack()
                self["hh_fx_anim"]:SetClickable(false)
                self["hh_image_ui"] = HH_UTILS:HHCreateImageUi(self, "images/hh_icon/hh_status.xml", "hh_status.tex", Vector3(0, 0, 1), 64, 64, base_color)
                self["hh_image_ui"]:SetClickable(false)
                self["hh_image_ui"]:MoveToBack()
            end
            --拿手上不要背景
            local oldStartDrag = self["StartDrag"]
            self["StartDrag"] = function(...)
                if HH_UTILS:HasReplica(self["item"], "inventoryitem") and self["hh_fx_anim"] then
                    HH_UTILS:HHKillChild(self, "hh_fx_anim")
                    HH_UTILS:HHKillChild(self, "hh_image_ui")
                end
                if oldStartDrag then
                    oldStartDrag(...)
                end
            end
        end
    end
end

AddClassPostConstruct("widgets/itemtile", addSlotText)
--
--local HH_SKILL_UI = require("widgets/hh_job/hh_job_skill")
--AddClassPostConstruct("widgets/controls", function(self, owner)
--    self["hh_skill_ui"] = self:AddChild(HH_SKILL_UI(self["owner"]))
--    self["hh_skill_ui"]:MoveToBack()
--end)
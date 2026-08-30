local HH_UTILS = require("utils/hh_utils")

local containers = require("containers")
local params = {}
local offset_y = 0
local offset_x = 0
params["hh_job_container"] = {
    ["widget"] = {
        ["slotpos"] = {
            Vector3(-250 + 30 * 0 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 1 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 2 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 3 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 4 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 5 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 6 + offset_x, -140 + offset_y, 0),
            Vector3(-250 + 30 * 7 + offset_x, -140 + offset_y, 0),
            --Vector3(-550 + 70 * 0 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 1 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 2 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 3 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 4 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 5 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 6 + offset_x, -350 + offset_y, 0),
            --Vector3(-550 + 70 * 7 + offset_x, -350 + offset_y, 0),
        },
        ["slotbg"] = { },
        ["pos"] = Vector3(0, 0, 0),
    },
    --acceptsstacks = false,
    --usespecificslotsforitems = true,
    ["type"] = "chest",
}
for k, v in pairs(params) do
    containers["MAXITEMSLOTS"] = math["max"](containers["MAXITEMSLOTS"], v["widget"]["slotpos"] ~= nil and #v["widget"]["slotpos"] or 0)
end
local containers_widgetsetup = containers["widgetsetup"]
function containers.widgetsetup(container, prefab, data)
    local t = data or params[prefab or container["inst"]["prefab"]]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container["widget"]["slotpos"] ~= nil and #container["widget"]["slotpos"] or 0)
    else
        return containers_widgetsetup(container, prefab, data)
    end
end

-----------------------------------------职业ui--------------------------------------------------------------
local HH_JOB_UI = require("widgets/hh_ui/hh_job_ui")

local slot_config = {
    --["main"] = {
    --    Vector3(-250 + 30 * 7 + offset_x, -140 + offset_y, 0),
    --},
    ["task"] = {
        Vector3(-250 + 30 * 0 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 1 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 2 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 3 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 4 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 5 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 6 + offset_x, -140 + offset_y, 0),
        Vector3(-250 + 30 * 7 + offset_x, -140 + offset_y, 0),
    },
    ["pet"] = {
        Vector3(50 + 30 * 0 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 1 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 2 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 3 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 4 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 5 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 6 + offset_x, -140 + offset_y, 0),
        Vector3(50 + 30 * 7 + offset_x, -140 + offset_y, 0),
    },
}
local function handleContainer(self, owner)
    local oldOpen = self["Open"]
    self["Open"] = function(self, ...)
        oldOpen(self, ...)
        local hh_inst = self["container"]
        if HH_UTILS:HasReplica(self["container"], "container")
                and self["container"]["prefab"] == "hh_job_container"
        then
            local hh_inst_prefab = hh_inst["prefab"]
            self:SetVAnchor(ANCHOR_MIDDLE)
            self:SetHAnchor(ANCHOR_MIDDLE)
            self:SetScaleMode(SCALEMODE_PROPORTIONAL)
            self["hh_job_main"] = self:AddChild(HH_JOB_UI(self["owner"], hh_inst))
            self["hh_job_main"]:CreateJobComUi()
            self["hh_job_main"]:MoveToBack()
            --格子大小改一下
            if self["inv"] and HH_UTILS:IsHHType(self["inv"], "table") then
                for i, v in ipairs(self["inv"]) do
                    if self["inv"][i] and self["inv"][i]["SetScale"] then
                        local base_scale = 0.4
                        --防止快捷键打开初始状态太大 官方默认是有刷新任务的
                        if self["inv"][i]["ScaleTo"] then
                            self["inv"][i]:ScaleTo(base_scale * 0.5, base_scale, 0.125)
                        end
                        self["inv"][i]:SetScale(base_scale)
                        --修复图标变大bug
                        self["inv"][i]["OnGainFocus"] = function(obj)
                            self["inv"][i]:SetScale(base_scale)
                        end
                        self["inv"][i]["OnLoseFocus"] = function(obj)
                            self["inv"][i]:SetScale(base_scale)
                        end
                    end
                end
            end
        end

    end
    local oldClose = self["Close"]
    self["Close"] = function(self, ...)
        HH_UTILS:HHKillChild(self, "hh_job_main")
        oldClose(self, ...)
    end

    --合成台容器增加监听用于格子移动
    self["inst"]:ListenForEvent("hh_job_slot_change", function(inst, data)
        if HH_UTILS:HasReplica(self["container"], "container") then
            local hh_slot_type = HH_UTILS:GetClientValue(self["owner"], "hh_job_slot_change")
            if not HH_UTILS:IsHHType(self["inv"], "table") then
                return
            end
            local all_show = true
            if not slot_config[hh_slot_type] then
                all_show = false
            end
            for i, v in ipairs(self["inv"]) do
                if HH_UTILS:IsHHType(v, "table") then
                    if not slot_config[hh_slot_type] or (not slot_config[hh_slot_type][i]) then
                        v:Hide()
                    else
                        v:Show()
                        v:MoveTo({ ["x"] = -250, ["y"] = -140, ["z"] = 0 }, slot_config[hh_slot_type][i], 0.3)
                    end
                end
            end
        end
    end, self["owner"])

end
AddClassPostConstruct("widgets/containerwidget", handleContainer)
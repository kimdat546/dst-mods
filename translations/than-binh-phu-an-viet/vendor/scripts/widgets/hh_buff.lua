----
---专属buff组件对应ui
---
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local HH_UTILS = require("utils/hh_utils")
local HH_BUFF_CONFIG = require("enums/hh_buff")
----buff图标背景
local buff_back_xml, buff_back_tex = "images/hh_icon/hh_buff_icon.xml", "hh_buff_icon.tex"
----buff背景图片大小
local buff_back_size = 40
----每行最多显示图标个数
local hh_limit = 5
----起点坐标
local hh_start_x, hh_start_y = 0, -70
local hh_text_size = 20
----图片之间间隔 以图片大小为媒介
local hh_interval = 2
local function handleNum(num)
    if num < 0 then
        return "00"
    elseif num < 10 then
        return "0" .. num
    end
    return num
end
----
---秒转分
---
local function secondsToTime(hh_time)
    local minutes = math["floor"](hh_time / 60)
    local seconds = math["floor"](hh_time - (minutes * 60))
    return string["format"]("%s:%s", handleNum(minutes), handleNum(seconds))
end
----
---获取服务端传入的buff
local function GetHasBuff(player)
    local hh_table = {}
    if HH_UTILS:HasComponents(player, "hh_client") then
        local hh_items_client = player["components"]["hh_client"]:GetValue("hh_client_buff")
        if HH_UTILS:IsHHType(hh_items_client, "table") then
            hh_table = hh_items_client
        end
    end
    return hh_table
end
local hh_buffer_ui = Class(Widget, function(self, owner)
    Widget._ctor(self, "hh_buffer_ui")
    self["owner"] = owner
    ---中心点
    self:SetVAnchor(1)
    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self["hh_buff_table"] = {}
    self:HandleBuffUi()
    ----更新ui
    self["inst"]:ListenForEvent("hh_client_buff", function(inst, data)
        self:HandleBuffUi()
    end, self["owner"])
end)

----
---处理buff图标ui
---
function hh_buffer_ui:HandleBuffUi()
    local hh_table = self["hh_buff_table"]
    --所有的buff集合
    local all_buffs = GetHasBuff(self["owner"])
    if all_buffs == nil or not HH_UTILS:IsHHType(all_buffs) == "table" then
        return
    end
    for i, v in ipairs(hh_table) do
        if not HH_BUFF_CONFIG[v] or not all_buffs[v] then
            ----先把消失的buff对应ui剔除掉
            HH_UTILS:HHKillChild(self, v)
        end
    end
    local buff_names = HH_UTILS:TableSortKeys(all_buffs)
    self["hh_buff_table"] = buff_names
    for i, v in ipairs(buff_names) do
        local hh_index = i - 1--坐标排列索引
        if HH_BUFF_CONFIG[v] then
            ----一行最多几个图标
            local hh_x = hh_index % hh_limit
            local hh_y = math["floor"](hh_index / hh_limit)
            local hh_time = tonumber(all_buffs[v]["time"])
            if hh_time then
                hh_time = secondsToTime(math["floor"](hh_time))
            else
                hh_time = " "
            end
            --新建buff图标和移动
            if self[v] then
                ----移动坐标到对应位置
                local pos = self[v]:GetPosition()
                local stop_x, stop_y = hh_start_x + hh_x * hh_interval * buff_back_size, hh_start_y - hh_y * buff_back_size * hh_interval
                if pos.x ~= stop_x or pos.y ~= stop_y then
                    self[v]:MoveTo(pos, Vector3(stop_x, stop_y, 1), 0.5)
                end
                if self[v]["hh_time"] then
                    self[v]["hh_time"]:SetString(tostring(hh_time))
                end
            else
                ----没有当前ui直接生成到对应坐标 不需要移动
                self[v] = HH_UTILS:HHCreateImageUi(self, buff_back_xml, buff_back_tex, Vector3(hh_start_x + hh_x * buff_back_size * hh_interval, hh_start_y - hh_y * buff_back_size * hh_interval, 1), 50, 50)
                ----增加buff对应图标
                if HH_BUFF_CONFIG[v]["xml"] and HH_BUFF_CONFIG[v]["tex"] then
                    local buff_xml, buff_tex = HH_BUFF_CONFIG[v]["xml"], HH_BUFF_CONFIG[v]["tex"]
                    self[v]["buff_icon"] = HH_UTILS:HHCreateImageUi(self[v], buff_xml, buff_tex, Vector3(0, 0, 1), buff_back_size, buff_back_size)
                end
                --没有图的可以增加文字显示buff图标
                if HH_BUFF_CONFIG[v]["icon_text"] then
                    self[v]["icon_text"] = HH_UTILS:HHCreateTextUi(self[v], Vector3(0, 0, 1), tostring(HH_BUFF_CONFIG[v]["icon_text"]), nil, hh_text_size)
                end
                local hh_str = HH_BUFF_CONFIG[v]["str"] or "描述"
                self[v]["OnGainFocus"] = function()
                    self[v]["hh_desc"] = HH_UTILS:HHCreateTextUi(self[v], Vector3(0, 0, 1), tostring(hh_str), { 1, 1, 1, 1 }, hh_text_size)
                    self[v]["hh_desc"]:MoveTo(Vector3(0, buff_back_size / 2, 1), Vector3(0, buff_back_size, 1), 0.5)
                end
                self[v]["OnLoseFocus"] = function()
                    HH_UTILS:HHKillChild(self[v], "hh_desc")
                end
                self[v]["hh_time"] = HH_UTILS:HHCreateTextUi(self[v], Vector3(0, -buff_back_size / 2 - hh_text_size / 2, 1), tostring(hh_time), { 1, 1, 1, 1 }, hh_text_size)
                local hh_name = HH_BUFF_CONFIG[v]["name"] or "未命名"
                self[v]["hh_text"] = HH_UTILS:HHCreateTextUi(self[v], Vector3(0, buff_back_size / 2 + hh_text_size / 2, 1), tostring(hh_name), { 1, 1, 1, 1 }, hh_text_size)

            end
        end
    end
end
return hh_buffer_ui
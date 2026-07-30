-- HUD hiện buff đang có tác dụng + đếm ngược.
--
-- File này chạy trong _G thật (được require, không phải modimport) nên dùng
-- global trực tiếp: Widget, Text, TheInput, GetTime... KHÔNG wrap GLOBAL.
--
-- Phần kéo thả bằng chuột phải + lưu vị trí lấy nguyên từ
-- originals/pham-nhan-tu-tien/scripts/widgets/pn_hud_dantian.lua — cơ chế đó
-- đã chạy thật rồi, không viết lại.

local Widget = require("widgets/widget")
local Text = require("widgets/text")

local SAVE_KEY = "foodbuffhud_position"
local FONT = CHATFONT
local FONT_SIZE = 20
local ROW_H = 24
local MAX_ROWS = 8

-- Mặc định đặt ở mép trái, giữa chiều cao: vùng này thường trống, tránh đè
-- inventory (giữa dưới), status/minimap (phải dưới), đồng hồ (phải trên).
-- Đè thì kéo chuột phải là xong.
local DEFAULT_X, DEFAULT_Y = -520, 60

local COLOR_OK   = { 1, 1, 1, 1 }
local COLOR_WARN = { 1, 0.45, 0.35, 1 }

local function LoadPos(cb)
    TheSim:GetPersistentString(SAVE_KEY, function(ok, data)
        if ok and data and data ~= "" then
            local x, y = string.match(data, "([%-%d%.]+),([%-%d%.]+)")
            if x and y then cb(tonumber(x), tonumber(y)) end
        end
    end)
end

local function SavePos(x, y)
    TheSim:SetPersistentString(SAVE_KEY, string.format("%.1f,%.1f", x, y), false)
end

local function FormatTime(secs)
    if secs < 0 then secs = 0 end
    return string.format("%d:%02d", math.floor(secs / 60), math.floor(secs % 60))
end

local FoodBuffHUD = Class(Widget, function(self, owner)
    Widget._ctor(self, "FoodBuffHUD")
    self.owner = owner

    self.rows = {}
    for i = 1, MAX_ROWS do
        local row = self:AddChild(Widget("row" .. i))
        row.label = row:AddChild(Text(FONT, FONT_SIZE))
        row.label:SetHAlign(ANCHOR_LEFT)
        row.label:SetPosition(0, 0)
        row.timeleft = row:AddChild(Text(FONT, FONT_SIZE))
        row.timeleft:SetHAlign(ANCHOR_LEFT)
        row.timeleft:SetPosition(150, 0)
        row:Hide()
        self.rows[i] = row
    end

    self._dragging = false
    self:SetPosition(DEFAULT_X, DEFAULT_Y)
    LoadPos(function(x, y)
        if self.inst and self.inst:IsValid() then self:SetPosition(x, y) end
    end)

    self:StartUpdating()
    self:Hide()
end)

-- Giữ chuột phải để kéo, thả ra là lưu vị trí
function FoodBuffHUD:OnMouseButton(button, down)
    if button ~= MOUSEBUTTON_RIGHT then return false end
    if down then
        self._dragging = true
        local mx, my = TheInput:GetScreenPosition():Get()
        self._m0 = { x = mx, y = my }
        local p = self:GetPosition()
        self._w0 = { x = p.x, y = p.y }
        return true
    elseif self._dragging then
        self._dragging = false
        local p = self:GetPosition()
        SavePos(p.x, p.y)
        return true
    end
    return false
end

function FoodBuffHUD:OnUpdate()
    if self._dragging then
        if not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
            self._dragging = false
            local p = self:GetPosition()
            SavePos(p.x, p.y)
        else
            local mx, my = TheInput:GetScreenPosition():Get()
            self:SetPosition(self._w0.x + (mx - self._m0.x), self._w0.y + (my - self._m0.y))
        end
    end

    local data = FOODBUFFHUD_DATA
    if data == nil or data.list == nil then return end

    -- Trừ dần theo thời gian đã qua kể từ lần server gửi số. Server gửi lại mỗi
    -- 5 giây nên sai số không tích luỹ.
    local elapsed = GetTime() - (data.at or 0)
    local warn = FOODBUFFHUD_WARN_SECONDS or 30

    local shown = 0
    for i = 1, MAX_ROWS do
        local entry = data.list[i]
        local row = self.rows[i]
        local left = entry and (entry.left - elapsed) or nil

        if entry ~= nil and left > 0 then
            shown = shown + 1
            row.label:SetString(FOODBUFFHUD_PrettyName(entry.key))
            row.timeleft:SetString(FormatTime(left))
            local c = (warn > 0 and left <= warn) and COLOR_WARN or COLOR_OK
            row.label:SetColour(c[1], c[2], c[3], c[4])
            row.timeleft:SetColour(c[1], c[2], c[3], c[4])
            row:SetPosition(0, -(shown - 1) * ROW_H)
            row:Show()
        else
            row:Hide()
        end
    end

    -- Không có buff thì ẩn hẳn, khỏi chiếm chỗ màn hình
    if shown > 0 then self:Show() else self:Hide() end
end

return FoodBuffHUD

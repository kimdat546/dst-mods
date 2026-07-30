-- HUD hiện buff đang có tác dụng + đếm ngược.
--
-- File này chạy trong _G thật (được require) nên dùng global trực tiếp.
--
-- ⚠ BÀI HỌC ĐẮT: widget con của controls.top_root PHẢI neo bằng
-- SetVAnchor/SetHAnchor. Thiếu neo thì nó nằm trong không gian toạ độ không neo
-- và trôi ra ngoài màn hình dù đặt toạ độ nào — mất 3 vòng test mới ra.
--
-- Tham chiếu: mod "Buff Timer (client)" (workshop 2905304624),
-- scripts/BuffTimerClient/widgets/Root.lua — mod ĐANG CHẠY ĐƯỢC.
-- KHÔNG lấy pham-nhan/pn_hud_dantian.lua làm chuẩn: mod đó chưa chạy được,
-- tôi đã sai khi giả định nó đúng chỉ vì có tài liệu nhắc tới.

local Widget = require("widgets/widget")
local Text = require("widgets/text")

local SAVE_KEY = "foodbuffhud_position"
local FONT = NUMBERFONT
local FONT_SIZE = 26
local ROW_H = 30
local MAX_ROWS = 8

-- Offset tính từ GÓC TRÊN-TRÁI màn hình (vì neo TOP/LEFT).
-- y âm là đi xuống. Giá trị nhỏ, không phải ±500 như không gian không neo.
-- Bề rộng vùng chữ: Text mặc định căn GIỮA quanh toạ độ của nó, nên nếu không
-- cho region + căn trái thì nửa chuỗi thò ra ngoài mép màn hình.
local LABEL_W = 260
local TIME_W = 90

local DEFAULT_X, DEFAULT_Y = 60, -120

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

    -- Lớp NEO — đây chính là thứ thiếu khiến HUD không bao giờ hiện
    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_TOP)
    self.root:SetHAnchor(ANCHOR_LEFT)

    -- Lớp di chuyển được, con của lớp neo
    self.panel = self.root:AddChild(Widget("panel"))
    self.panel:SetPosition(DEFAULT_X, DEFAULT_Y)

    self.rows = {}
    for i = 1, MAX_ROWS do
        local row = self.panel:AddChild(Widget("row" .. i))
        row.label = row:AddChild(Text(FONT, FONT_SIZE, ""))
        row.label:SetRegionSize(LABEL_W, ROW_H)
        row.label:SetHAlign(ANCHOR_LEFT)
        row.label:SetPosition(LABEL_W / 2, 0)   -- region căn giữa quanh vị trí → dời nửa bề rộng để chữ bắt đầu từ gốc
        row.timeleft = row:AddChild(Text(FONT, FONT_SIZE, ""))
        row.timeleft:SetRegionSize(TIME_W, ROW_H)
        row.timeleft:SetHAlign(ANCHOR_LEFT)
        row.timeleft:SetPosition(LABEL_W + TIME_W / 2, 0)
        row:Hide()
        self.rows[i] = row
    end

    self._dragging = false
    LoadPos(function(x, y)
        if self.panel ~= nil and self.panel.inst ~= nil and self.panel.inst:IsValid() then
            self.panel:SetPosition(x, y)
        end
    end)

    self:StartUpdating()
end)

-- Giữ chuột phải để kéo, thả ra là lưu vị trí
function FoodBuffHUD:OnMouseButton(button, down)
    if button ~= MOUSEBUTTON_RIGHT then return false end
    if down then
        self._dragging = true
        local mx, my = TheInput:GetScreenPosition():Get()
        self._m0 = { x = mx, y = my }
        local p = self.panel:GetPosition()
        self._w0 = { x = p.x, y = p.y }
        return true
    elseif self._dragging then
        self._dragging = false
        local p = self.panel:GetPosition()
        SavePos(p.x, p.y)
        return true
    end
    return false
end

function FoodBuffHUD:OnUpdate()
    if self._dragging then
        if not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
            self._dragging = false
            local p = self.panel:GetPosition()
            SavePos(p.x, p.y)
        else
            local mx, my = TheInput:GetScreenPosition():Get()
            self.panel:SetPosition(self._w0.x + (mx - self._m0.x), self._w0.y + (my - self._m0.y))
        end
    end

    local data = FOODBUFFHUD_DATA
    if data == nil or data.list == nil then return end

    -- Trừ dần theo thời gian đã qua kể từ lần server gửi. Server gửi lại mỗi 5s
    -- nên sai số không tích luỹ.
    local elapsed = GetTime() - (data.at or 0)
    local warn = FOODBUFFHUD_WARN_SECONDS or 30

    local shown = 0
    for i = 1, MAX_ROWS do
        local entry = data.list[i]
        local row = self.rows[i]
        local left = entry ~= nil and (entry.left - elapsed) or nil

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

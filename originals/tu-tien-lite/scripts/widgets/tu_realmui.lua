-- Widget HUD: khung cảnh giới + thanh linh khí. Dùng texture có sẵn của game.

local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local REALM_NAMES = { "Luyện Khí", "Trúc Cơ", "Kim Đan", "Nguyên Anh", "Hóa Thần" }
-- màu thanh linh khí theo từng cảnh giới (RGB)
local REALM_COLOURS = {
    { 0.55, 0.85, 0.55 }, -- Luyện Khí: lục
    { 0.45, 0.80, 1.00 }, -- Trúc Cơ:   lam
    { 0.80, 0.55, 1.00 }, -- Kim Đan:   tím
    { 1.00, 0.78, 0.35 }, -- Nguyên Anh: kim
    { 1.00, 0.45, 0.40 }, -- Hóa Thần:  xích
}

local PANEL_W, PANEL_H = 236, 74
local BAR_W, BAR_H = 188, 16
local BAR_Y = -17

local TuRealmUI = Class(Widget, function(self, owner)
    Widget._ctor(self, "TuRealmUI")
    self.owner = owner

    -- khung nền
    self.panel = self:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
    self.panel:SetSize(PANEL_W, PANEL_H)
    self.panel:SetTint(0.13, 0.16, 0.22, 0.92)

    -- viền sáng mảnh phía trên (trang trí)
    self.topline = self:AddChild(Image("images/global.xml", "square.tex"))
    self.topline:SetSize(PANEL_W - 24, 2)
    self.topline:SetPosition(0, PANEL_H / 2 - 10, 0)
    self.topline:SetTint(0.5, 0.75, 1, 0.6)

    -- tên cảnh giới
    self.name = self:AddChild(Text(BODYTEXTFONT, 30))
    self.name:SetPosition(0, 13, 0)
    self.name:SetColour(0.95, 0.95, 0.75, 1)

    -- thanh nền (track)
    self.track = self:AddChild(Image("images/global.xml", "square.tex"))
    self.track:SetSize(BAR_W, BAR_H)
    self.track:SetPosition(0, BAR_Y, 0)
    self.track:SetTint(0, 0, 0, 0.55)

    -- thanh linh khí (fill)
    self.fill = self:AddChild(Image("images/global.xml", "square.tex"))
    self.fill:SetSize(BAR_W, BAR_H)
    self.fill:SetPosition(0, BAR_Y, 0)
    self.fill:SetTint(0.45, 0.8, 1, 1)

    -- chữ % trên thanh
    self.pcttext = self:AddChild(Text(BODYTEXTFONT, 19))
    self.pcttext:SetPosition(0, BAR_Y, 0)
    self.pcttext:SetColour(1, 1, 1, 1)

    self._lastlvl, self._lastpct = -1, -1
    self:StartUpdating()
end)

function TuRealmUI:Refresh(lvl, pct)
    local name = REALM_NAMES[lvl] or "?"
    local col = REALM_COLOURS[lvl] or { 0.45, 0.8, 1 }
    local ismax = lvl >= #REALM_NAMES

    self.name:SetString("「" .. name .. "」")

    self.fill:SetTint(col[1], col[2], col[3], 1)

    local shown = ismax and 100 or pct
    local fillw = BAR_W * shown / 100
    if fillw < 1 then
        self.fill:Hide()
    else
        self.fill:Show()
        self.fill:SetSize(fillw, BAR_H)
        -- neo mép trái cố định
        self.fill:SetPosition(-BAR_W / 2 + fillw / 2, BAR_Y, 0)
    end

    self.pcttext:SetString(ismax and "VIÊN MÃN" or (shown .. "%"))
end

function TuRealmUI:OnUpdate()
    local p = self.owner
    if p == nil or p._tu_level == nil or p._tu_pct == nil then
        self:Hide()
        return
    end

    local lvl = p._tu_level:value()
    if lvl < 1 then
        self:Hide()
        return
    end

    self:Show()
    local pct = p._tu_pct:value()
    if lvl ~= self._lastlvl or pct ~= self._lastpct then
        self._lastlvl, self._lastpct = lvl, pct
        self:Refresh(lvl, pct)
    end
end

return TuRealmUI

-- scripts/widgets/pn_hud_main.lua
-- Compact cultivation HUD: a small đan điền medallion with tu vi progress shown
-- INSIDE it (on the plaque), realm name BELOW it, and lifespan as its own
-- icon-prefixed line. Right-click + drag to reposition (saved across sessions).

local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")

local ATLAS = "images/pn_ui.xml"

-- Dantian medallions (level1-6), each a different element flame colour.
local ELEMENT_MEDALLION = {
    THUY = "level1.tex",  -- blue  → Water
    KIM  = "level3.tex",  -- gold  → Metal
    MOC  = "level4.tex",  -- cyan  → Wood
    THO  = "level5.tex",  -- phoenix → Earth
    HOA  = "level6.tex",  -- red   → Fire
}
local DEFAULT_MEDALLION = "level2.tex"  -- purple (mixed / Ngụy)

-- Smaller again per feedback. Tweak these two numbers to resize the medallion.
local MEDALLION_W, MEDALLION_H = 58, 64

local FONT = CHATFONT
local POSITION_SAVE_KEY = "pn_hud_position"

local function LoadSavedPosition(cb)
    TheSim:GetPersistentString(POSITION_SAVE_KEY, function(ok, data)
        if ok and data and data ~= "" then
            local x, y = string.match(data, "([%-%d%.]+),([%-%d%.]+)")
            if x and y then cb(tonumber(x), tonumber(y)) end
        end
    end)
end
local function SavePosition(x, y)
    TheSim:SetPersistentString(POSITION_SAVE_KEY, string.format("%.1f,%.1f", x, y), false)
end

local PnHudMain = Class(Widget, function(self, owner)
    Widget._ctor(self, "PnHudMain")
    self.owner = owner

    -- Đan điền medallion (small centerpiece)
    self.medallion = self:AddChild(Image(ATLAS, DEFAULT_MEDALLION))
    self.medallion:SetSize(MEDALLION_W, MEDALLION_H)
    self.medallion:SetPosition(0, 0)
    self.medallion:SetClickable(true)
    self._cur_medallion = DEFAULT_MEDALLION

    -- Tu vi progress (e.g. "120/282") — INSIDE the medallion, on its plaque area
    self.tuvi_text = self:AddChild(Text(FONT, 11, ""))
    self.tuvi_text:SetPosition(0, -20)

    -- Realm name — BELOW the medallion
    self.canhgioi_text = self:AddChild(Text(FONT, 16, ""))
    self.canhgioi_text:SetPosition(0, -42)

    -- Lifespan — its own icon-prefixed line below
    self.lifespan_text = self:AddChild(Text(FONT, 14, ""))
    self.lifespan_text:SetPosition(0, -60)

    -- Meditating indicator
    self.meditating_text = self:AddChild(Text(FONT, 13, ""))
    self.meditating_text:SetPosition(0, -76)
    self.meditating_text:SetColour(0.6, 0.95, 0.4, 1)

    self._dragging = false

    LoadSavedPosition(function(x, y)
        if self.inst and self.inst:IsValid() then self:SetPosition(x, y) end
    end)

    self:StartUpdating()
end)

function PnHudMain:OnMouseButton(button, down, x, y)
    if button ~= MOUSEBUTTON_RIGHT then return false end
    if down then
        self._dragging = true
        local mx, my = TheInput:GetScreenPosition():Get()
        self._drag_start_mouse = { x = mx, y = my }
        local pos = self:GetPosition()
        self._drag_start_widget = { x = pos.x, y = pos.y }
        return true
    elseif self._dragging then
        self._dragging = false
        local pos = self:GetPosition()
        SavePosition(pos.x, pos.y)
        return true
    end
    return false
end

local function PickMedallion(lc)
    if not (lc and lc:HasData()) then return DEFAULT_MEDALLION end
    local raw = lc:GetElements()
    local first = raw and string.match(raw, "[^,]+")
    return ELEMENT_MEDALLION[first or ""] or DEFAULT_MEDALLION
end

function PnHudMain:OnUpdate(dt)
    if self._dragging then
        if not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
            self._dragging = false
            local pos = self:GetPosition()
            SavePosition(pos.x, pos.y)
        else
            local mx, my = TheInput:GetScreenPosition():Get()
            self:SetPosition(
                self._drag_start_widget.x + (mx - self._drag_start_mouse.x),
                self._drag_start_widget.y + (my - self._drag_start_mouse.y))
        end
    end

    local p = self.owner
    if not p or not p.replica then return end
    local lc = p.replica.pn_linhcan
    local tv = p.replica.pn_tuvi
    local cg = p.replica.pn_canhgioi
    local ls = p.replica.pn_lifespan

    -- Medallion sprite by element
    local want = PickMedallion(lc)
    if want ~= self._cur_medallion then
        self.medallion:SetTexture(ATLAS, want)
        self._cur_medallion = want
    end

    -- Tu vi inside medallion
    if tv and tv:HasData() then
        self.tuvi_text:SetString(string.format("%d/%d",
            math.floor(tv:GetCurrent()), math.floor(tv:GetCap())))
    else
        self.tuvi_text:SetString("")
    end

    -- Realm name below
    if cg then
        local d = cg:GetDisplay()
        if d == nil or d == "" then d = "Phàm Nhân" end
        self.canhgioi_text:SetString(d)
        local col = cg:GetColor()
        if col then self.canhgioi_text:SetColour(col[1], col[2], col[3], col[4]) end
    else
        self.canhgioi_text:SetString("Phàm Nhân")
    end

    -- Lifespan as its own icon line
    if ls and ls:HasData() then
        if ls:IsPermadeath() then
            self.lifespan_text:SetString("⏳ Thọ tận")
        else
            self.lifespan_text:SetString(string.format("⏳ %d/%d",
                math.floor(ls:GetRemaining()), math.floor(ls:GetTotal())))
        end
        local col = ls:GetColor()
        if col then self.lifespan_text:SetColour(col[1], col[2], col[3], col[4]) end
    else
        self.lifespan_text:SetString("")
    end

    -- Meditation
    local med = p.components and p.components.pn_meditation
        and p.components.pn_meditation:IsMeditating()
    self.meditating_text:SetString(med and "✨ Đang thiền" or "")
end

return PnHudMain

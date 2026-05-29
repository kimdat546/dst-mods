-- scripts/widgets/pn_hud_main.lua
-- Compact cultivation HUD using Dengxian's UI atlas (copied as images/pn_ui.*).
-- Layout: a backing panel + realm name on top, a tu vi bar (xuetiao art) below,
-- with small linh căn + lifespan lines. Right-click + drag to reposition.
--
-- All sprite region names are constants below — if a chosen sprite looks wrong
-- in-game, just swap the region name (see images/pn_ui.xml for the full list).

local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")
local Realms = require("pn/realms")

local ATLAS = "images/pn_ui.xml"

-- Sprite regions from the Dengxian atlas (pn_ui.xml). Tweak if they look off.
local SPR_PANEL    = "yqdback.tex"     -- backing panel (引导 back)
local SPR_BAR_BG   = "xuetiao3.tex"    -- thin empty bar frame
local SPR_BAR_FILL = "xuetiao2.tex"    -- filled bar segment

local FONT      = CHATFONT
local FONT_SIZE = 20

local PANEL_W, PANEL_H = 220, 150
local BAR_W = 180

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

    self.root = self:AddChild(Widget("root"))

    -- Backing panel
    self.panel = self.root:AddChild(Image(ATLAS, SPR_PANEL))
    self.panel:SetSize(PANEL_W, PANEL_H)
    self.panel:SetClickable(true)

    -- Realm name (top, bold-ish via larger size + tint)
    self.canhgioi_text = self.root:AddChild(Text(FONT, FONT_SIZE + 4, ""))
    self.canhgioi_text:SetPosition(0, 46)

    -- Linh căn line (small, below realm)
    self.linhcan_text = self.root:AddChild(Text(FONT, FONT_SIZE - 4, ""))
    self.linhcan_text:SetPosition(0, 22)
    self.linhcan_text:SetColour(0.8, 0.85, 0.7, 1)

    -- Tu vi bar — empty frame
    self.bar_bg = self.root:AddChild(Image(ATLAS, SPR_BAR_BG))
    self.bar_bg:SetSize(BAR_W, 18)
    self.bar_bg:SetPosition(0, -4)

    -- Tu vi bar — fill (width scaled by percent in OnUpdate)
    self.bar_fill = self.root:AddChild(Image(ATLAS, SPR_BAR_FILL))
    self.bar_fill:SetSize(BAR_W, 14)
    self.bar_fill:SetPosition(0, -4)

    -- Tu vi numeric overlay
    self.bar_text = self.root:AddChild(Text(FONT, FONT_SIZE - 6, ""))
    self.bar_text:SetPosition(0, -4)

    -- Lifespan line (bottom)
    self.lifespan_text = self.root:AddChild(Text(FONT, FONT_SIZE - 4, ""))
    self.lifespan_text:SetPosition(0, -30)

    -- Meditating indicator (very bottom)
    self.meditating_text = self.root:AddChild(Text(FONT, FONT_SIZE - 6, ""))
    self.meditating_text:SetPosition(0, -52)
    self.meditating_text:SetColour(0.6, 0.95, 0.4, 1)

    -- Drag state
    self._dragging = false
    self._drag_start_mouse = nil
    self._drag_start_widget = nil

    LoadSavedPosition(function(x, y)
        if self.inst and self.inst:IsValid() then self:SetPosition(x, y) end
    end)

    self:StartUpdating()
end)

function PnHudMain:OnMouseButton(button, down, x, y)
    if button == MOUSEBUTTON_RIGHT then
        if down then
            self._dragging = true
            local mx, my = TheInput:GetScreenPosition():Get()
            self._drag_start_mouse = { x = mx, y = my }
            local pos = self:GetPosition()
            self._drag_start_widget = { x = pos.x, y = pos.y }
            return true
        else
            if self._dragging then
                self._dragging = false
                local pos = self:GetPosition()
                SavePosition(pos.x, pos.y)
                return true
            end
        end
    end
    return false
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

    -- Cảnh giới (always show, default Phàm Nhân)
    if cg then
        local display = cg:GetDisplay()
        if display == nil or display == "" then display = "Phàm Nhân" end
        self.canhgioi_text:SetString(display)
        local col = cg:GetColor()
        if col then self.canhgioi_text:SetColour(col[1], col[2], col[3], col[4]) end
    else
        self.canhgioi_text:SetString("Phàm Nhân")
    end

    -- Linh căn
    if lc and lc:HasData() then
        local el = lc:GetElementDisplay()
        self.linhcan_text:SetString(el ~= "" and (lc:GetDisplay() .. " (" .. el .. ")") or lc:GetDisplay())
    else
        self.linhcan_text:SetString("")
    end

    -- Tu vi bar
    if tv and tv:HasData() then
        local pct = tv:GetPercent()
        local fill_w = math.max(2, math.floor(BAR_W * pct))
        self.bar_fill:SetSize(fill_w, 14)
        self.bar_fill:SetPosition(-(BAR_W / 2) + fill_w / 2, -4)
        self.bar_text:SetString(string.format("%d / %d", math.floor(tv:GetCurrent()), math.floor(tv:GetCap())))
    else
        self.bar_fill:SetSize(2, 14)
        self.bar_text:SetString("")
    end

    -- Lifespan
    if ls and ls:HasData() then
        if ls:IsPermadeath() then
            self.lifespan_text:SetString("Thọ: ĐÃ TẬN")
        else
            self.lifespan_text:SetString(string.format("Thọ: %d / %d",
                math.floor(ls:GetRemaining()), math.floor(ls:GetTotal())))
        end
        local col = ls:GetColor()
        if col then self.lifespan_text:SetColour(col[1], col[2], col[3], col[4]) end
    else
        self.lifespan_text:SetString("")
    end

    -- Meditation
    local meditating = p.components and p.components.pn_meditation
        and p.components.pn_meditation:IsMeditating()
    self.meditating_text:SetString(meditating and "✨ Đang thiền" or "")
end

return PnHudMain

-- scripts/widgets/pn_hud_main.lua
-- HUD overlay showing player's linh căn / cảnh giới / tu vi progress.
-- Attaches via AddClassPostConstruct("widgets/controls") in modmain.
--
-- Right-click + drag the HUD background to move it anywhere on screen.
-- Position is saved to TheSim:SetPersistentString and restored next session.

local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")
local Realms = require("pn/realms")

local FONT     = NUMBERFONT
local FONT_SIZE = 22

local POSITION_SAVE_KEY = "pn_hud_position"

local function LoadSavedPosition(callback)
    -- Async load. callback(x, y) when done. If no saved data, callback is not invoked.
    TheSim:GetPersistentString(POSITION_SAVE_KEY, function(success, data)
        if success and data and data ~= "" then
            local x, y = string.match(data, "([%-%d%.]+),([%-%d%.]+)")
            if x and y then
                callback(tonumber(x), tonumber(y))
            end
        end
    end)
end

local function SavePosition(x, y)
    TheSim:SetPersistentString(POSITION_SAVE_KEY, string.format("%.1f,%.1f", x, y), false)
end

local PnHudMain = Class(Widget, function(self, owner)
    Widget._ctor(self, "PnHudMain")
    self.owner = owner

    -- Background frame — dark translucent panel (MVP placeholder for real art)
    self.bg = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bg:SetSize(290, 175)
    self.bg:SetTint(0.05, 0.05, 0.1, 0.7)
    -- Make bg clickable so right-click drag works
    self.bg:SetClickable(true)

    -- Subtle border (second smaller image layered for a frame effect)
    self.bg_border = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bg_border:SetSize(280, 165)
    self.bg_border:SetTint(0.1, 0.15, 0.25, 0.4)

    -- Linh căn label
    self.linhcan_text = self:AddChild(Text(FONT, FONT_SIZE, ""))
    self.linhcan_text:SetPosition(0, 35)
    self.linhcan_text:SetHAlign(ANCHOR_MIDDLE)

    -- Cảnh giới label
    self.canhgioi_text = self:AddChild(Text(FONT, FONT_SIZE + 2, ""))
    self.canhgioi_text:SetPosition(0, 5)
    self.canhgioi_text:SetHAlign(ANCHOR_MIDDLE)

    -- Tu vi progress bar background
    self.bar_bg = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bar_bg:SetSize(240, 14)
    self.bar_bg:SetPosition(0, -25)
    self.bar_bg:SetTint(0.2, 0.2, 0.2, 0.8)

    -- Tu vi progress bar fill
    self.bar_fill = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bar_fill:SetTint(0.4, 0.85, 1, 1)
    self.bar_fill:SetPosition(-120, -25)

    -- Tu vi numeric overlay
    self.bar_text = self:AddChild(Text(FONT, FONT_SIZE - 4, "0 / 0"))
    self.bar_text:SetPosition(0, -25)
    self.bar_text:SetHAlign(ANCHOR_MIDDLE)

    -- Lifespan label (Plan 3)
    self.lifespan_text = self:AddChild(Text(FONT, FONT_SIZE - 2, ""))
    self.lifespan_text:SetPosition(0, -50)
    self.lifespan_text:SetHAlign(ANCHOR_MIDDLE)

    -- Meditating indicator (Plan 4)
    self.meditating_text = self:AddChild(Text(FONT, FONT_SIZE - 4, ""))
    self.meditating_text:SetPosition(0, -75)
    self.meditating_text:SetHAlign(ANCHOR_MIDDLE)
    self.meditating_text:SetColour(0.6, 0.95, 0.4, 1)

    -- Breakthrough flash (Plan 7) — temporary text shown on tier-up
    self.breakthrough_text = self:AddChild(Text(FONT, FONT_SIZE + 6, ""))
    self.breakthrough_text:SetPosition(0, 60)
    self.breakthrough_text:SetHAlign(ANCHOR_MIDDLE)
    self.breakthrough_text:SetColour(1, 0.85, 0.2, 1)  -- gold
    self._breakthrough_until = 0

    -- Drag-to-reposition state
    self._dragging = false
    self._drag_start_mouse = nil  -- screen pos when drag started
    self._drag_start_widget = nil -- widget pos when drag started

    -- Hook breakthrough event for celebration text
    if owner then
        self._breakthrough_listener = function(_, data)
            if data and data.new_tier then
                self.breakthrough_text:SetString("✦ Đột phá: " .. Realms.GetDisplay(data.new_tier) .. " ✦")
                self._breakthrough_until = GetTime() + 5.0
            end
        end
        owner:ListenForEvent("pn_canhgioi_up", self._breakthrough_listener)
    end

    -- Restore saved position (async)
    LoadSavedPosition(function(x, y)
        if self.inst and self.inst:IsValid() then
            self:SetPosition(x, y)
        end
    end)

    self:StartUpdating()
end)

-- Right-click + drag handler. DST routes mouse clicks on a widget through
-- the bg's OnControl (the clickable child); we intercept at the parent level.
function PnHudMain:OnMouseButton(button, down, x, y)
    if button == MOUSEBUTTON_RIGHT then
        if down then
            -- Only start drag if click is over our bg area
            if self.bg and self.bg:IsVisible() then
                self._dragging = true
                local mx, my = TheInput:GetScreenPosition():Get()
                self._drag_start_mouse  = { x = mx, y = my }
                local pos = self:GetPosition()
                self._drag_start_widget = { x = pos.x, y = pos.y }
                return true
            end
        else
            -- Right-click released → end drag, save position
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
    -- Handle drag movement (poll mouse position while dragging)
    if self._dragging then
        if not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
            -- Mouse released outside our area; end drag + save
            self._dragging = false
            local pos = self:GetPosition()
            SavePosition(pos.x, pos.y)
        else
            local mx, my = TheInput:GetScreenPosition():Get()
            local dx = mx - self._drag_start_mouse.x
            local dy = my - self._drag_start_mouse.y
            self:SetPosition(
                self._drag_start_widget.x + dx,
                self._drag_start_widget.y + dy
            )
        end
    end

    local p = self.owner
    if not p or not p.replica then return end

    local lc = p.replica.pn_linhcan
    local tv = p.replica.pn_tuvi
    local cg = p.replica.pn_canhgioi

    -- Linh căn line
    if lc and lc:HasData() then
        local elements = lc:GetElementDisplay()
        local s = elements ~= "" and (lc:GetDisplay() .. " (" .. elements .. ")") or lc:GetDisplay()
        self.linhcan_text:SetString(s)
    else
        self.linhcan_text:SetString("Linh căn: ?")
    end

    -- Cảnh giới line — always show (Phàm Nhân for tier 0)
    if cg then
        local display = cg:GetDisplay()
        -- GetDisplay can return empty if Realms returned nil; guard with default
        if display == nil or display == "" then
            display = "Phàm Nhân"
        end
        self.canhgioi_text:SetString(display)
        local col = cg:GetColor()
        if col then
            self.canhgioi_text:SetColour(col[1], col[2], col[3], col[4])
        end
    else
        self.canhgioi_text:SetString("Phàm Nhân")
    end

    -- Tu vi bar
    if tv and tv:HasData() then
        local pct = tv:GetPercent()
        local fill_w = math.max(2, math.floor(240 * pct))
        self.bar_fill:SetSize(fill_w, 12)
        self.bar_fill:SetPosition(-120 + fill_w / 2, -25)
        self.bar_text:SetString(string.format("%d / %d tu vi",
            math.floor(tv:GetCurrent()), math.floor(tv:GetCap())))
    else
        self.bar_fill:SetSize(2, 12)
        self.bar_text:SetString("- / -")
    end

    -- Lifespan line
    local ls = p.replica.pn_lifespan
    if ls and ls:HasData() then
        local s
        if ls:IsPermadeath() then
            s = "Thọ: ĐÃ TẬN"
        else
            s = string.format("Thọ: %d / %d ngày",
                math.floor(ls:GetRemaining()), math.floor(ls:GetTotal()))
        end
        self.lifespan_text:SetString(s)
        local col = ls:GetColor()
        self.lifespan_text:SetColour(col[1], col[2], col[3], col[4])
    else
        self.lifespan_text:SetString("Thọ: -")
    end

    -- Meditation indicator (server-only state; we sneak-peek via player.components)
    local meditating = false
    if p.components and p.components.pn_meditation then
        meditating = p.components.pn_meditation:IsMeditating()
    end
    self.meditating_text:SetString(meditating and "✨ Đang thiền (×1.5)" or "")

    -- Breakthrough text fade-out
    if self._breakthrough_until > 0 then
        if GetTime() > self._breakthrough_until then
            self.breakthrough_text:SetString("")
            self._breakthrough_until = 0
        end
    end
end

return PnHudMain

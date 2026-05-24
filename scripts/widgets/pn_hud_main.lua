-- scripts/widgets/pn_hud_main.lua
-- HUD overlay showing player's linh căn / cảnh giới / tu vi progress.
-- Attaches via AddClassPostConstruct("widgets/controls") in modmain.

local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")
local Realms = require("pn/realms")

local FONT     = NUMBERFONT
local FONT_SIZE = 22

local PnHudMain = Class(Widget, function(self, owner)
    Widget._ctor(self, "PnHudMain")
    self.owner = owner

    -- Background frame
    self.bg = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))
    self.bg:SetSize(280, 165)
    self.bg:SetTint(0, 0, 0, 0.5)

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

    -- Hook breakthrough event for celebration text
    if owner then
        self._breakthrough_listener = function(_, data)
            if data and data.new_tier then
                local Realms = require("pn/realms")
                self.breakthrough_text:SetString("✦ Đột phá: " .. Realms.GetDisplay(data.new_tier) .. " ✦")
                self._breakthrough_until = GetTime() + 5.0  -- show for 5 seconds
            end
        end
        owner:ListenForEvent("pn_canhgioi_up", self._breakthrough_listener)
    end

    self:StartUpdating()
end)

function PnHudMain:OnUpdate(dt)
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

    -- Cảnh giới line
    if cg then
        self.canhgioi_text:SetString(cg:GetDisplay())
        local col = cg:GetColor()
        self.canhgioi_text:SetColour(col[1], col[2], col[3], col[4])
    else
        self.canhgioi_text:SetString("?")
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

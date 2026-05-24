-- scripts/widgets/pn_canhgioi_indicator.lua
-- Floating text above the player's head showing their cảnh giới.
-- Visible from a distance — useful for future PvP and sect coordination.
-- NOTE: Attach logic deferred to post-MVP plan (Follower pattern is version-dependent).

local Widget = require("widgets/widget")
local Text   = require("widgets/text")

local FONT = NUMBERFONT
local FONT_SIZE = 18

local PnCanhGioiIndicator = Class(Widget, function(self, target)
    Widget._ctor(self, "PnCanhGioiIndicator")
    self.target = target

    self.label = self:AddChild(Text(FONT, FONT_SIZE, ""))
    self.label:SetHAlign(ANCHOR_MIDDLE)
    self.label:SetPosition(0, 80)  -- offset above the player sprite

    self:StartUpdating()
end)

function PnCanhGioiIndicator:OnUpdate(dt)
    local p = self.target
    if not p or not p.replica then
        self.label:SetString("")
        return
    end
    local cg = p.replica.pn_canhgioi
    if not cg then
        self.label:SetString("")
        return
    end
    local tier = cg:GetTier()
    if tier == 0 then
        -- Hide for Phàm Nhân (tier 0) to reduce visual clutter
        self.label:SetString("")
        return
    end
    self.label:SetString(cg:GetDisplay())
    local col = cg:GetColor()
    self.label:SetColour(col[1], col[2], col[3], col[4])
end

return PnCanhGioiIndicator

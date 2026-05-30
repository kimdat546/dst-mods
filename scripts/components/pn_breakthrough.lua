local Events = require("pn/events")
local Realms = require("pn/realms")

local PnBreakthrough = Class(function(self, inst)
    self.inst = inst
    if inst then
        inst:ListenForEvent(Events.TUVI_CHANGED, function(_, d) self:_OnChanged(d) end)
    end
end)

function PnBreakthrough:_OnChanged(data)
    if not data or data.new_value < data.cap then return end
    self:TryBreakthrough()
end

function PnBreakthrough:TryBreakthrough()
    local cg = self.inst.components.pn_canhgioi
    local tv = self.inst.components.pn_tuvi
    if not (cg and tv) then return end
    local cur = cg:GetTier()
    if cur >= Realms.GetMaxTier() then return end
    local next_tier = cur + 1
    local cost = Realms.GetThreshold(next_tier)
    -- M1: auto-pass (Luyện Khí has no tribulation in canon)
    self.inst:PushEvent(Events.CANHGIOI_UP, { new_tier=next_tier, old_tier=cur })
    tv:ConsumeForBreakthrough(cost)
    tv:SetCapForTier(math.min(next_tier + 1, Realms.GetMaxTier()))
end

function PnBreakthrough:OnSave() return {} end
function PnBreakthrough:OnLoad() end

return PnBreakthrough

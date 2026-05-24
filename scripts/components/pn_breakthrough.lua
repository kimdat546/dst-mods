-- scripts/components/pn_breakthrough.lua
-- Listens for tu vi threshold crossings and orchestrates breakthroughs.
-- MVP2: auto-pass. Future plans add risk/fail.

local Events = require("pn/events")
local Realms = require("pn/realms")

local PnBreakthrough = Class(function(self, inst)
    self.inst = inst
    if inst then
        inst:ListenForEvent(Events.TUVI_CHANGED, function(_, data)
            self:_OnTuViChanged(data)
        end)
    end
end)

function PnBreakthrough:_OnTuViChanged(data)
    if not data then return end
    if data.new_value < data.cap then return end  -- not at threshold yet

    self:TryBreakthrough()
end

function PnBreakthrough:TryBreakthrough()
    if not (self.inst and self.inst.components.pn_canhgioi and self.inst.components.pn_tuvi) then
        return
    end

    local cur_tier = self.inst.components.pn_canhgioi:GetTier()
    if cur_tier >= Realms.GetMaxTier() then
        -- Already at cap; can't breakthrough further in MVP2.
        return
    end

    local next_tier = cur_tier + 1
    local cost      = Realms.GetThreshold(next_tier)  -- tu vi consumed for this breakthrough

    -- MVP2: always succeed.
    local success = true

    self.inst:PushEvent(Events.BREAKTHROUGH, { tier = next_tier, success = success })

    if success then
        self.inst:PushEvent(Events.CANHGIOI_UP, {
            new_tier = next_tier,
            old_tier = cur_tier,
        })

        self.inst.components.pn_tuvi:ConsumeForBreakthrough(cost)
        local further_tier = math.min(next_tier + 1, Realms.GetMaxTier())
        self.inst.components.pn_tuvi:SetCapForTier(further_tier)
    end
end

-- No state to save (stateless orchestrator), but include for completeness.
function PnBreakthrough:OnSave()  return {} end
function PnBreakthrough:OnLoad(_) end

return PnBreakthrough

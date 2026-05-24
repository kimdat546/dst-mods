-- scripts/components/pn_tuvi.lua
-- Tu vi accumulator. Listens for TUVI_GAIN events, multiplies by linh căn mult,
-- caps at next-tier threshold so player must breakthrough before accumulating more.

local Events = require("pn/events")
local Realms = require("pn/realms")

local PnTuVi = Class(function(self, inst)
    self.inst    = inst
    self.current = 0
    self.cap     = Realms.GetThreshold(1)  -- start cap = threshold to reach tier 1

    if inst then
        inst:ListenForEvent(Events.TUVI_GAIN, function(_, data)
            self:_OnTuViGain(data)
        end)
    end
end)

function PnTuVi:_OnTuViGain(data)
    if not data or not data.amount then return end
    local amount = data.amount

    -- Apply linh căn multiplier (if linhcan component is on inst)
    if self.inst and self.inst.components.pn_linhcan then
        amount = amount * self.inst.components.pn_linhcan:GetTuViMult()
    end

    local old = self.current
    self.current = math.min(self.current + amount, self.cap)

    if self.current ~= old then
        self:_PushToReplica()
        self.inst:PushEvent(Events.TUVI_CHANGED, {
            new_value = self.current,
            old_value = old,
            cap       = self.cap,
            source    = data.source,
        })
    end
end

-- Called by pn_canhgioi after a breakthrough to advance the cap.
function PnTuVi:SetCapForTier(next_tier)
    self.cap = Realms.GetThreshold(next_tier)
    self:_PushToReplica()
end

-- After a successful breakthrough, the spent tu vi is consumed.
function PnTuVi:ConsumeForBreakthrough(amount)
    self.current = math.max(0, self.current - amount)
    self:_PushToReplica()
end

function PnTuVi:Get()    return self.current end
function PnTuVi:GetCap() return self.cap     end

function PnTuVi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_tuvi) then return end
    self.inst.replica.pn_tuvi:SetCurrent(self.current)
    self.inst.replica.pn_tuvi:SetCap(self.cap)
end

function PnTuVi:OnSave()
    return { current = self.current, cap = self.cap }
end

function PnTuVi:OnLoad(data)
    if data == nil then return end
    self.current = data.current or 0
    self.cap     = data.cap or Realms.GetThreshold(1)
    self:_PushToReplica()
end

return PnTuVi

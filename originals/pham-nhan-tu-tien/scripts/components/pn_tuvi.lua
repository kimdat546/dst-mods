local Events = require("pn/events")
local Realms = require("pn/realms")

local PnTuVi = Class(function(self, inst)
    self.inst = inst
    self.current = 0
    self.cap = Realms.GetThreshold(1)
    if inst then
        inst:ListenForEvent(Events.TUVI_GAIN, function(_, d) self:_OnGain(d) end)
        inst:DoTaskInTime(0, function() self:_PushToReplica() end)
    end
end)

function PnTuVi:_OnGain(data)
    if not data or not data.amount then return end
    local amount = data.amount
    if self.inst.components.pn_linhcan then
        amount = amount * self.inst.components.pn_linhcan:GetTuViMult()
    end
    local old = self.current
    self.current = math.min(self.current + amount, self.cap)
    if self.current ~= old then
        self:_PushToReplica()
        self.inst:PushEvent(Events.TUVI_CHANGED, { new_value=self.current, old_value=old, cap=self.cap })
    end
end

function PnTuVi:SetCapForTier(tier) self.cap = Realms.GetThreshold(tier); self:_PushToReplica() end
function PnTuVi:ConsumeForBreakthrough(amount) self.current = math.max(0, self.current - amount); self:_PushToReplica() end
function PnTuVi:Get() return self.current end
function PnTuVi:GetCap() return self.cap end

function PnTuVi:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_tuvi) then return end
    self.inst.replica.pn_tuvi:SetCurrent(self.current)
    self.inst.replica.pn_tuvi:SetCap(self.cap)
end

function PnTuVi:OnSave() return { current=self.current, cap=self.cap } end
function PnTuVi:OnLoad(data)
    if not data then return end
    self.current = data.current or 0
    self.cap = data.cap or Realms.GetThreshold(1)
    self:_PushToReplica()
end

return PnTuVi

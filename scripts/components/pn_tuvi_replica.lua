local Replica = Class(function(self, inst)
    self.inst = inst
    self.current_net = net_float(inst.GUID, "pn_tuvi.current", "pn_tuvi_dirty")
    self.cap_net     = net_float(inst.GUID, "pn_tuvi.cap", "pn_tuvi_dirty")
end)

function Replica:SetCurrent(v) self.current_net:set(v or 0) end
function Replica:SetCap(v)     self.cap_net:set(v or 1) end
function Replica:GetCurrent()  return self.current_net:value() end
function Replica:GetCap()      return self.cap_net:value() end
function Replica:GetPercent()
    local cap = self:GetCap()
    return cap > 0 and math.min(1, self:GetCurrent()/cap) or 0
end
function Replica:HasData() return self:GetCap() > 0 end

return Replica

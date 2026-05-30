local Realms = require("pn/realms")

local Replica = Class(function(self, inst)
    self.inst = inst
    self.tier_net = net_smallbyte(inst.GUID, "pn_canhgioi.tier", "pn_canhgioi_dirty")  -- 0..63 (tier reaches 13; net_tinybyte caps at 7)
end)

function Replica:SetTier(v) self.tier_net:set(v or 0) end
function Replica:GetTier()  return self.tier_net:value() end
function Replica:GetDisplay() return Realms.GetDisplay(self:GetTier()) end
function Replica:GetColor()   return Realms.GetColor(self:GetTier()) end

return Replica

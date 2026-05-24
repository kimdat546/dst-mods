-- scripts/components/pn_canhgioi_replica.lua

local Realms = require("pn/realms")

local Replica = Class(function(self, inst)
    self.inst = inst
    self.tier_net = net_tinybyte(inst.GUID, "pn_canhgioi.tier", "pn_canhgioi_dirty")
end)

function Replica:SetTier(v) self.tier_net:set(v or 0) end
function Replica:GetTier() return self.tier_net:value() end
function Replica:GetDisplay() return Realms.GetDisplay(self:GetTier()) end
function Replica:GetColor() return Realms.GetTierColor(self:GetTier()) end

function Replica:HasData()
    return self.inst ~= nil
end

return Replica

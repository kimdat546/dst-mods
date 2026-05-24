-- scripts/components/pn_lifespan_replica.lua
-- Networked lifespan state for HUD: total, remaining, permadeath flag.

local Replica = Class(function(self, inst)
    self.inst = inst
    self.total_net      = net_float(inst.GUID, "pn_lifespan.total",     "pn_lifespan_dirty")
    self.remaining_net  = net_float(inst.GUID, "pn_lifespan.remaining", "pn_lifespan_dirty")
    self.permadeath_net = net_bool (inst.GUID, "pn_lifespan.permadeath","pn_lifespan_dirty")
end)

function Replica:SetTotal(v)      self.total_net:set(v or 0)      end
function Replica:SetRemaining(v)  self.remaining_net:set(v or 0)  end
function Replica:SetPermadeath(v) self.permadeath_net:set(v == true) end

function Replica:GetTotal()       return self.total_net:value()      end
function Replica:GetRemaining()   return self.remaining_net:value()  end
function Replica:IsPermadeath()   return self.permadeath_net:value() end

function Replica:GetPercent()
    local t = self:GetTotal()
    if t <= 0 then return 0 end
    return math.max(0, math.min(1, self:GetRemaining() / t))
end

-- Returns {r, g, b, a} colour for HUD based on remaining percentage.
function Replica:GetColor()
    local p = self:GetPercent()
    if p > 0.5 then return {1, 1, 1, 1}        end  -- white
    if p > 0.2 then return {1, 0.85, 0.2, 1}   end  -- yellow
    return            {1, 0.3, 0.3, 1}                -- red
end

function Replica:HasData()
    return self:GetTotal() > 0
end

return Replica

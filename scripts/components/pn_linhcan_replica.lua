-- scripts/components/pn_linhcan_replica.lua
-- Client-side mirror of pn_linhcan. HUD reads via this.

local LinhCanData = require("pn/linhcan_data")

local Replica = Class(function(self, inst)
    self.inst = inst

    -- Networked fields. net_string for compactness; we encode complex state ourselves.
    self.type_net        = net_string(inst.GUID, "pn_linhcan.type", "pn_linhcan_dirty")
    self.elements_net    = net_string(inst.GUID, "pn_linhcan.elements", "pn_linhcan_dirty")
    self.bien_di_tag_net = net_string(inst.GUID, "pn_linhcan.bien_di_tag", "pn_linhcan_dirty")
end)

function Replica:SetType(v)        self.type_net:set(v or "")         end
function Replica:SetElements(v)    self.elements_net:set(v or "")     end
function Replica:SetBienDiTag(v)   self.bien_di_tag_net:set(v or "")  end

function Replica:GetType()       return self.type_net:value()        end
function Replica:GetElements()   return self.elements_net:value()    end
function Replica:GetBienDiTag()  return self.bien_di_tag_net:value() end

-- Convenience: return the display name (e.g. "Băng Linh Căn" or "Ngụy Linh Căn")
function Replica:GetDisplay()
    local t   = self:GetType()
    local tag = self:GetBienDiTag()
    if t == "" then return "?" end
    if tag ~= "" then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if combo.tag == tag then return combo.display end
        end
    end
    return LinhCanData.TYPES[t] and LinhCanData.TYPES[t].display or "?"
end

function Replica:GetElementDisplay()
    local raw = self:GetElements()
    if raw == "" then return "" end
    local out = {}
    for e in string.gmatch(raw, "[^,]+") do
        table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e)
    end
    return table.concat(out, "/")
end

function Replica:HasData()
    return self:GetType() ~= ""
end

return Replica

local LinhCanData = require("pn/linhcan_data")

local Replica = Class(function(self, inst)
    self.inst = inst
    self.type_net     = net_string(inst.GUID, "pn_linhcan.type", "pn_linhcan_dirty")
    self.elements_net = net_string(inst.GUID, "pn_linhcan.elements", "pn_linhcan_dirty")
    self.tag_net      = net_string(inst.GUID, "pn_linhcan.tag", "pn_linhcan_dirty")
end)

function Replica:SetType(v)      self.type_net:set(v or "") end
function Replica:SetElements(v)  self.elements_net:set(v or "") end
function Replica:SetBienDiTag(v) self.tag_net:set(v or "") end
function Replica:GetType()      return self.type_net:value() end
function Replica:GetElements()  return self.elements_net:value() end
function Replica:GetBienDiTag() return self.tag_net:value() end

function Replica:HasData() return self:GetType() ~= "" end

function Replica:GetPrimaryElement()
    local raw = self:GetElements()
    return raw ~= "" and string.match(raw, "[^,]+") or nil
end

function Replica:GetDisplay()
    local t, tag = self:GetType(), self:GetBienDiTag()
    if t == "" then return "?" end
    if tag ~= "" then
        for _, c in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if c.tag == tag then return c.display end
        end
    end
    return LinhCanData.TYPES[t] and LinhCanData.TYPES[t].display or "?"
end

function Replica:GetElementDisplay()
    local raw = self:GetElements()
    if raw == "" then return "" end
    local out = {}
    for e in string.gmatch(raw, "[^,]+") do table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e) end
    return table.concat(out, "/")
end

return Replica

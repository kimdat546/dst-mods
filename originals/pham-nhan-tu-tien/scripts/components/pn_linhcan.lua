local LinhCanData = require("pn/linhcan_data")
local Events = require("pn/events")

local PnLinhCan = Class(function(self, inst)
    self.inst = inst
    self.type = nil
    self.elements = nil
    self.bien_di_tag = nil
    self.rolled = false
    if inst then
        inst:DoTaskInTime(0, function() self:_PushToReplica() end)
    end
end)

function PnLinhCan:RollNew(force)
    if self.rolled and not force then return end
    local roll = math.random() * 100
    local cumulative, picked = 0, "NGUY"
    for _, t in ipairs(LinhCanData.ROLL_ORDER) do
        cumulative = cumulative + LinhCanData.TYPES[t].weight
        if roll <= cumulative then picked = t; break end
    end
    self.type = picked
    local tdef = LinhCanData.TYPES[picked]
    local n = math.random(tdef.element_count[1], tdef.element_count[2])
    local all = {}
    for _, e in ipairs(LinhCanData.ELEMENTS) do table.insert(all, e) end
    for i = #all, 2, -1 do local j = math.random(i); all[i], all[j] = all[j], all[i] end
    self.elements = {}
    for i = 1, n do table.insert(self.elements, all[i]) end
    table.sort(self.elements)
    self.bien_di_tag = nil
    if picked == "BIEN_DI" and n == 2 then
        for _, c in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            local a, b = c.elements[1], c.elements[2]
            if (self.elements[1]==a and self.elements[2]==b) or (self.elements[1]==b and self.elements[2]==a) then
                self.bien_di_tag = c.tag; break
            end
        end
    end
    self.rolled = true
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LINHCAN_ROLLED, { type=self.type, elements=self.elements })
    end
end

function PnLinhCan:GetTuViMult()
    return self.type and LinhCanData.TYPES[self.type].tu_vi_mult or 1.0
end

function PnLinhCan:GetPrimaryElement()
    return self.elements and self.elements[1] or nil
end

function PnLinhCan:GetDisplay()
    if not self.type then return "?" end
    if self.bien_di_tag then
        for _, c in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if c.tag == self.bien_di_tag then return c.display end
        end
    end
    return LinhCanData.TYPES[self.type].display
end

function PnLinhCan:GetElementDisplay()
    if not self.elements then return "" end
    local out = {}
    for _, e in ipairs(self.elements) do table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e) end
    return table.concat(out, "/")
end

function PnLinhCan:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_linhcan) then return end
    self.inst.replica.pn_linhcan:SetType(self.type or "")
    self.inst.replica.pn_linhcan:SetElements(table.concat(self.elements or {}, ","))
    self.inst.replica.pn_linhcan:SetBienDiTag(self.bien_di_tag or "")
end

function PnLinhCan:OnSave()
    return { type=self.type, elements=self.elements, bien_di_tag=self.bien_di_tag, rolled=self.rolled }
end

function PnLinhCan:OnLoad(data)
    if not data then return end
    self.type, self.elements, self.bien_di_tag, self.rolled =
        data.type, data.elements, data.bien_di_tag, data.rolled or false
    self:_PushToReplica()
end

return PnLinhCan

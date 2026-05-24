-- scripts/components/pn_linhcan.lua
-- Linh căn (spiritual root) — rolled once on spawn, immutable after.
-- Provides tu_vi_mult that other components query.

local LinhCanData = require("pn/linhcan_data")
local Events      = require("pn/events")

local PnLinhCan = Class(function(self, inst)
    self.inst = inst

    -- State
    self.type     = nil      -- "NGUY" | "CHAN" | "BIEN_DI" | "THIEN"
    self.elements = nil      -- list of element strings
    self.bien_di_tag = nil   -- e.g. "BANG" if BIEN_DI rolled Băng combo
    self.rolled   = false    -- has roll happened?
end)

-- Roll a new linh căn. Idempotent: if already rolled, does nothing unless force=true.
function PnLinhCan:RollNew(force)
    if self.rolled and not force then return end

    -- 1. Pick type by weighted roll
    local roll = math.random() * 100
    local cumulative = 0
    local picked_type = "NGUY"  -- fallback
    -- Build sorted list by ASCENDING weight (Thien=2, BienDi=3, Chan=30, Nguy=65)
    local sorted = { "THIEN", "BIEN_DI", "CHAN", "NGUY" }
    for _, t in ipairs(sorted) do
        cumulative = cumulative + LinhCanData.TYPES[t].weight
        if roll <= cumulative then
            picked_type = t
            break
        end
    end
    self.type = picked_type

    -- 2. Pick element count for this type
    local type_def = LinhCanData.TYPES[picked_type]
    local element_count = math.random(type_def.element_count[1], type_def.element_count[2])

    -- 3. Pick elements (Fisher-Yates partial shuffle)
    local all_elements = {}
    for _, e in ipairs(LinhCanData.ELEMENTS) do table.insert(all_elements, e) end
    for i = #all_elements, 2, -1 do
        local j = math.random(i)
        all_elements[i], all_elements[j] = all_elements[j], all_elements[i]
    end
    self.elements = {}
    for i = 1, element_count do
        table.insert(self.elements, all_elements[i])
    end
    table.sort(self.elements)  -- canonical order for save consistency

    -- 4. If BIEN_DI, check if element set matches a combo
    self.bien_di_tag = nil
    if picked_type == "BIEN_DI" and element_count == 2 then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            local a, b = combo.elements[1], combo.elements[2]
            if (self.elements[1] == a and self.elements[2] == b)
            or (self.elements[1] == b and self.elements[2] == a) then
                self.bien_di_tag = combo.tag
                break
            end
        end
    end

    self.rolled = true

    -- Notify other components + push to replica
    self:_PushToReplica()
    if self.inst then
        self.inst:PushEvent(Events.LINHCAN_ROLLED, {
            type     = self.type,
            elements = self.elements,
            mult     = self:GetTuViMult(),
        })
    end
end

function PnLinhCan:GetTuViMult()
    if not self.type then return 1.0 end
    return LinhCanData.TYPES[self.type].tu_vi_mult
end

function PnLinhCan:GetDisplay()
    if not self.type then return "?" end
    if self.bien_di_tag then
        for _, combo in ipairs(LinhCanData.BIEN_DI_COMBOS) do
            if combo.tag == self.bien_di_tag then return combo.display end
        end
    end
    return LinhCanData.TYPES[self.type].display
end

function PnLinhCan:GetElementDisplay()
    if not self.elements then return "" end
    local out = {}
    for _, e in ipairs(self.elements) do
        table.insert(out, LinhCanData.ELEMENT_DISPLAY[e] or e)
    end
    return table.concat(out, "/")
end

-- Push state to replica so client can render HUD
function PnLinhCan:_PushToReplica()
    if not (self.inst and self.inst.replica and self.inst.replica.pn_linhcan) then return end
    self.inst.replica.pn_linhcan:SetType(self.type or "")
    self.inst.replica.pn_linhcan:SetElements(table.concat(self.elements or {}, ","))
    self.inst.replica.pn_linhcan:SetBienDiTag(self.bien_di_tag or "")
end

-- Persistence
function PnLinhCan:OnSave()
    return {
        type        = self.type,
        elements    = self.elements,
        bien_di_tag = self.bien_di_tag,
        rolled      = self.rolled,
    }
end

function PnLinhCan:OnLoad(data)
    if data == nil then return end
    self.type        = data.type
    self.elements    = data.elements
    self.bien_di_tag = data.bien_di_tag
    self.rolled      = data.rolled or false
    self:_PushToReplica()
end

return PnLinhCan

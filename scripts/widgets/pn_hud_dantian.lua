local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local Image  = require("widgets/image")
local LinhCanData = require("pn/linhcan_data")

local ATLAS = "images/pn_ui.xml"
local FONT = CHATFONT

-- Medallion native aspect 186:206 ≈ 0.903. Pick a height, derive width to keep ratio.
local MED_H = 64
local MED_W = math.floor(MED_H * 186 / 206)  -- ≈ 57

local SAVE_KEY = "pn_hud_position"

local function LoadPos(cb)
    TheSim:GetPersistentString(SAVE_KEY, function(ok, data)
        if ok and data and data ~= "" then
            local x,y = string.match(data, "([%-%d%.]+),([%-%d%.]+)")
            if x and y then cb(tonumber(x), tonumber(y)) end
        end
    end)
end
local function SavePos(x,y) TheSim:SetPersistentString(SAVE_KEY, string.format("%.1f,%.1f", x, y), false) end

local PnHud = Class(Widget, function(self, owner)
    Widget._ctor(self, "PnHudDantian")
    self.owner = owner

    self.medallion = self:AddChild(Image(ATLAS, LinhCanData.DEFAULT_MEDALLION))
    self.medallion:SetSize(MED_W, MED_H)
    self.medallion:SetClickable(true)
    self._cur = LinhCanData.DEFAULT_MEDALLION

    self.tuvi_text = self:AddChild(Text(FONT, 11, ""))
    self.tuvi_text:SetPosition(0, -(MED_H/2) - 6)
    self.canhgioi_text = self:AddChild(Text(FONT, 15, ""))
    self.canhgioi_text:SetPosition(0, -(MED_H/2) - 22)

    self._dragging = false
    LoadPos(function(x,y) if self.inst and self.inst:IsValid() then self:SetPosition(x,y) end end)
    self:StartUpdating()
end)

function PnHud:OnMouseButton(button, down)
    if button ~= MOUSEBUTTON_RIGHT then return false end
    if down then
        self._dragging = true
        local mx,my = TheInput:GetScreenPosition():Get()
        self._m0 = {x=mx,y=my}; local p=self:GetPosition(); self._w0={x=p.x,y=p.y}
        return true
    elseif self._dragging then
        self._dragging = false; local p=self:GetPosition(); SavePos(p.x,p.y); return true
    end
    return false
end

local function PickMedallion(lc)
    if not (lc and lc:HasData()) then return LinhCanData.DEFAULT_MEDALLION end
    local el = lc:GetPrimaryElement()
    return LinhCanData.ELEMENT_MEDALLION[el or ""] or LinhCanData.DEFAULT_MEDALLION
end

function PnHud:OnUpdate()
    if self._dragging then
        if not TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then
            self._dragging=false; local p=self:GetPosition(); SavePos(p.x,p.y)
        else
            local mx,my = TheInput:GetScreenPosition():Get()
            self:SetPosition(self._w0.x+(mx-self._m0.x), self._w0.y+(my-self._m0.y))
        end
    end
    local p = self.owner
    if not (p and p.replica) then return end
    local lc, tv, cg = p.replica.pn_linhcan, p.replica.pn_tuvi, p.replica.pn_canhgioi

    local want = PickMedallion(lc)
    if want ~= self._cur then self.medallion:SetTexture(ATLAS, want); self._cur = want end

    if cg then
        local d = cg:GetDisplay(); if d=="" then d="Phàm Nhân" end
        self.canhgioi_text:SetString(d)
        local c = cg:GetColor(); if c then self.canhgioi_text:SetColour(c[1],c[2],c[3],c[4]) end
    else
        self.canhgioi_text:SetString("Phàm Nhân")
    end

    if tv and tv:HasData() then
        self.tuvi_text:SetString(string.format("%d/%d", math.floor(tv:GetCurrent()), math.floor(tv:GetCap())))
    else
        self.tuvi_text:SetString("")
    end
end

return PnHud

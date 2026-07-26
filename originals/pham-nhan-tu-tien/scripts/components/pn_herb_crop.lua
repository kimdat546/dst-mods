-- pn_herb_crop: a planted spirit-herb crop with a stage timer. Each stage schedules
-- the next after stage_time / accel. Linh Điền calls SetAccel periodically; accel
-- decays back to 1.0 if not refreshed. Mature → pickable; harvest resets to stage 1.
local config = require("pn/config")
local TOTAL_DAY = TUNING.TOTAL_DAY_TIME or 480

local PnHerbCrop = Class(function(self, inst)
    self.inst = inst
    self.stage = 1
    self.maxstage = config.HERB.CROP_STAGES
    self.accel = 1.0
    self._accel_until = 0
    self.herb_id = nil          -- set by Configure
    self.stage_time = TOTAL_DAY -- set by Configure
    self.anim = { young = "idle", mature = "idle", pick = "idle" }
end)

function PnHerbCrop:Configure(def)
    self.herb_id = def.id
    self.stage_time = (def.crop_grow * TOTAL_DAY) / self.maxstage
    self.seed_chance = def.seed_chance
    self.anim = def.anim or self.anim
end

function PnHerbCrop:OnPlanted()
    self.stage = 1
    self:_Refresh()
    self:_ScheduleNext()
end

function PnHerbCrop:SetAccel(mult, source)
    self.accel = mult
    self._accel_until = GetTime() + (config.LINHDIEN.SCAN_PERIOD * 2.5)
end

function PnHerbCrop:_CurAccel()
    if GetTime() <= self._accel_until then return self.accel end
    return 1.0
end

function PnHerbCrop:_ScheduleNext()
    if self._task then self._task:Cancel() end
    if self.stage >= self.maxstage then return end  -- mature: stop growing
    local dt = self.stage_time / self:_CurAccel()
    self._task = self.inst:DoTaskInTime(dt, function() self:_Advance() end)
end

function PnHerbCrop:_Advance()
    if self.stage < self.maxstage then
        self.stage = self.stage + 1
        self:_Refresh()
        self:_ScheduleNext()
    end
end

function PnHerbCrop:_Refresh()
    local mature = self.stage >= self.maxstage
    if self.inst.AnimState then
        self.inst.AnimState:PlayAnimation(mature and self.anim.mature or self.anim.young, false)
    end
    if self.inst.components.pickable then
        self.inst.components.pickable.canbepicked = mature
    end
end

function PnHerbCrop:OnHarvest(picker)
    if math.random() < (self.seed_chance or 0) and picker and picker.components.inventory then
        local seed = SpawnPrefab(self.herb_id .. "_seed")
        if seed then picker.components.inventory:GiveItem(seed) end
    end
    self.stage = 1
    self:_Refresh()
    self:_ScheduleNext()
end

function PnHerbCrop:OnSave() return { stage = self.stage } end
function PnHerbCrop:OnLoad(data)
    if data and data.stage then self.stage = data.stage end
    self:_Refresh(); self:_ScheduleNext()
end

return PnHerbCrop

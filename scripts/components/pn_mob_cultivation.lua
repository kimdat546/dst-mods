-- scripts/components/pn_mob_cultivation.lua
-- Mob-side cultivation component. Counts time spent in linh mạch aura (measured
-- by how many pn_tuvi_gain ticks the mob has received). At threshold seconds the
-- mob is "upgraded" — its HP / damage / scale go up and a glow tint is applied.
-- On death by player, pushes pn_tuvi_gain on the killer (placeholder for Plan 6
-- nội đan items).

local Events = require("pn/events")
local TUNING = require("pn/tuning")

local PnMobCultivation = Class(function(self, inst)
    self.inst         = inst
    self.time_in_aura = 0   -- seconds accumulated from pn_tuvi_gain ticks
    self.current_tier = 0
    -- Snapshot of base stats so we can apply multipliers cleanly on tier change.
    self._base_hp    = nil
    self._base_dmg   = nil
    self._base_scale = nil

    if inst then
        -- Each pn_tuvi_gain on a mob entity = 1 scan interval of aura time.
        -- The aura_source pushes events every SCAN_INTERVAL seconds; sum them.
        inst:ListenForEvent(Events.TUVI_GAIN, function(_, _)
            self:_OnAuraTick()
        end)

        -- On death, reward the killer if they're a player.
        inst:ListenForEvent("death", function()
            self:_OnDeath()
        end)
    end
end)

function PnMobCultivation:_CaptureBase()
    if self._base_hp == nil and self.inst.components.health then
        self._base_hp = self.inst.components.health.maxhealth
    end
    if self._base_dmg == nil and self.inst.components.combat then
        self._base_dmg = self.inst.components.combat.defaultdamage or 10
    end
    if self._base_scale == nil and self.inst.Transform then
        local s = self.inst.Transform:GetScale()
        self._base_scale = s or 1
    end
end

function PnMobCultivation:_OnAuraTick()
    local interval = TUNING.LINH_MACH.SCAN_INTERVAL or 1.0
    self.time_in_aura = self.time_in_aura + interval

    -- Determine target tier from time_in_aura
    local thresholds = TUNING.MOB_CULTIVATION.TIER_THRESHOLDS
    local target_tier = 0
    for i, t in ipairs(thresholds) do
        if self.time_in_aura >= t then target_tier = i end
    end

    if target_tier > self.current_tier then
        self:_UpgradeTo(target_tier)
    end
end

function PnMobCultivation:_UpgradeTo(new_tier)
    if new_tier < 1 or new_tier > #TUNING.MOB_CULTIVATION.TIER_STATS then return end
    self:_CaptureBase()
    self.current_tier = new_tier

    local stats = TUNING.MOB_CULTIVATION.TIER_STATS[new_tier]

    -- HP
    if self.inst.components.health and self._base_hp then
        local new_max = self._base_hp * stats.hp_mult
        self.inst.components.health:SetMaxHealth(new_max)
        -- Restore proportionally
        self.inst.components.health:SetPercent(1.0)
    end

    -- Damage
    if self.inst.components.combat and self._base_dmg then
        self.inst.components.combat:SetDefaultDamage(self._base_dmg * stats.dmg_mult)
    end

    -- Scale (visual size)
    if self.inst.Transform and self._base_scale then
        local s = self._base_scale * stats.scale
        self.inst.Transform:SetScale(s, s, s)
    end

    -- Tint (glow colour)
    local tint = TUNING.MOB_CULTIVATION.TIER_TINT[new_tier]
    if tint and self.inst.AnimState then
        self.inst.AnimState:SetMultColour(tint[1], tint[2], tint[3], tint[4])
    end

    print(string.format("[PN] %s upgraded to Tier %d (Linh thú/Yêu tu)",
        tostring(self.inst.prefab), new_tier))
end

function PnMobCultivation:_OnDeath()
    local killer = self.inst.components.combat
                   and self.inst.components.combat.lastattacker
    if not killer or not killer:HasTag("player") then return end

    -- Determine which nội đan tier drops based on mob's current tier
    local tier        = self.current_tier
    local drop_chance = TUNING.NOI_DAN.DROP_CHANCE[tier]
    if not drop_chance then return end

    if math.random() > drop_chance then return end

    local prefab_name = (tier == 0) and "pn_noidan_ha"
                     or (tier == 1) and "pn_noidan_trung"
                     or "pn_noidan_thuong"

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local item = SpawnPrefab(prefab_name)
    if item then
        item.Transform:SetPosition(x, y, z)
    end

    -- Tier 2: bonus linh thảo (5% chance to drop a random species)
    if tier == 2 and math.random() < (TUNING.NOI_DAN.TIER2_LINHTHAO_BONUS_CHANCE or 0.05) then
        local species = { "pn_linhthao_tam_tinh_hoa", "pn_linhthao_linh_tien_thao", "pn_linhthao_hong_lien_tu" }
        local bonus = SpawnPrefab(species[math.random(#species)])
        if bonus then
            bonus.Transform:SetPosition(x + 0.5, y, z)
        end
    end
end

function PnMobCultivation:GetTier()       return self.current_tier end
function PnMobCultivation:GetTimeInAura() return self.time_in_aura end

function PnMobCultivation:OnSave()
    return {
        time_in_aura = self.time_in_aura,
        current_tier = self.current_tier,
    }
end

function PnMobCultivation:OnLoad(data)
    if data == nil then return end
    self.time_in_aura = data.time_in_aura or 0
    self.current_tier = 0  -- always re-apply from 0 to capture fresh base stats
    if data.current_tier and data.current_tier > 0 then
        -- Defer one frame so stats are loaded first
        self.inst:DoTaskInTime(0, function()
            self:_UpgradeTo(data.current_tier)
        end)
    end
end

return PnMobCultivation

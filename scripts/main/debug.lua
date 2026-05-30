local Events = GLOBAL.require("pn/events")
local LinhCanData = GLOBAL.require("pn/linhcan_data")
local Realms = GLOBAL.require("pn/realms")

function GLOBAL.c_addtuvi(amount, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    player:PushEvent(Events.TUVI_GAIN, { amount=amount or 100, source="debug" })
    print("[PN] +"..tostring(amount or 100).." tu vi (raw)")
end

function GLOBAL.c_settier(tier, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not (player and player.components.pn_canhgioi) then return end
    local cur = player.components.pn_canhgioi:GetTier()
    for t = cur+1, tier do
        player:PushEvent(Events.CANHGIOI_UP, { new_tier=t, old_tier=t-1 })
    end
    if player.components.pn_tuvi then
        player.components.pn_tuvi:SetCapForTier(math.min(tier+1, Realms.GetMaxTier()))
    end
    print("[PN] set tier → "..tostring(tier))
end

function GLOBAL.c_setlinhcan(t, elements, player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    local lc = player and player.components.pn_linhcan
    if not lc or not LinhCanData.TYPES[t] then print("[PN] valid: NGUY/CHAN/BIEN_DI/THIEN") return end
    lc.type, lc.elements, lc.bien_di_tag, lc.rolled = t, elements or {"KIM"}, nil, true
    lc:_PushToReplica()
    print("[PN] linh căn = "..lc:GetDisplay().." ["..lc:GetElementDisplay().."]")
end

function GLOBAL.c_pnstate(player)
    player = player or GLOBAL.ConsoleCommandPlayer()
    if not player then return end
    local lc, tv, cg = player.components.pn_linhcan, player.components.pn_tuvi, player.components.pn_canhgioi
    print("===== PN state =====")
    if lc then print(string.format("  Linh căn: %s [%s] mult=%.2f", lc:GetDisplay(), lc:GetElementDisplay(), lc:GetTuViMult())) end
    if cg then print(string.format("  Cảnh giới: %s (tier %d)", cg:GetDisplay(), cg:GetTier())) end
    if tv then print(string.format("  Tu vi: %d/%d", tv:Get(), tv:GetCap())) end
end

-- Live-tweak the đan điền HUD with NO file reload / NO rehost.
--   c_pnhud()            -> print current values
--   c_pnhud(120)         -> set medallion height to 120 (width auto from 186:206 ratio)
--   c_pnhud(120, 0.40)   -> also set tu-vi text vertical factor (default 0.33)
-- Converge on the right look in the console, then bake MED_H + factor into
-- scripts/widgets/pn_hud_dantian.lua once and commit.
function GLOBAL.c_pnhud(height, yfactor)
    local player = GLOBAL.ThePlayer
    local hud = player and player.HUD
    local w = hud and hud.controls and hud.controls.pn_hud
    if not w then print("[PN] pn_hud widget not found on HUD") return end

    local H  = height  or w._dbg_H  or 96
    local YF = yfactor or w._dbg_YF or 0.33
    local W  = math.floor(H * 186 / 206)

    -- stored on the instance so the OnUpdate texture-swap re-applies THESE values
    w._dbg_H, w._dbg_YF = H, YF

    w.medallion:SetSize(W, H)
    w.tuvi_text:SetPosition(0, -(H * YF))
    w.canhgioi_text:SetPosition(0, -(H / 2) - 12)
    print(string.format("[PN] c_pnhud  H=%d  W=%d  yfactor=%.2f", H, W, YF))
end

print("[PN] debug loaded: c_addtuvi, c_settier, c_setlinhcan, c_pnstate, c_pnhud")

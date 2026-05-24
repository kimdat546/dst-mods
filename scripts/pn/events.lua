-- scripts/pn/events.lua
-- Centralized event name constants. Use these everywhere instead of string literals.

return {
    -- Tu vi flow
    TUVI_GAIN        = "pn_tuvi_gain",         -- payload: { amount = N, source = "..." }
    TUVI_CHANGED     = "pn_tuvi_changed",      -- payload: { new_value, old_value, cap }

    -- Realm progression
    CANHGIOI_UP      = "pn_canhgioi_up",       -- payload: { new_tier, old_tier }
    BREAKTHROUGH     = "pn_breakthrough",      -- payload: { tier, success } (MVP2: success always true)

    -- Linh căn
    LINHCAN_ROLLED   = "pn_linhcan_rolled",    -- payload: { type, elements, mult }

    -- Lifespan (defined here for Plan 3, unused in Plan 2)
    LIFESPAN_TICK    = "pn_lifespan_tick",
    LIFESPAN_EXPIRED = "pn_lifespan_expired",

    -- Aura (Plan 4, unused now)
    AURA_ENTER       = "pn_aura_enter",
    AURA_EXIT        = "pn_aura_exit",
}

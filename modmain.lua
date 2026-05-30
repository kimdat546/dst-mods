-- Phàm Nhân Tu Tiên (remake) — thin entry. All registration lives in scripts/main/*.
GLOBAL.setmetatable(env, {
    __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end,
})

modimport("scripts/main/import.lua")

print("[PN] Phàm Nhân Tu Tiên (remake M1) loaded")

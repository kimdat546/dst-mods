-- Scan ALL globals for tables containing Chinese text.
-- Goal: find where 登仙 mod stores its private data tables.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local has_chinese = rawget(_G, "dangtien_viet_has_chinese")
if not has_chinese then return end

local seen = {}
local hits = {}  -- {path, sample_text}

local function scan(tbl, path, depth)
    if depth > 6 or type(tbl) ~= "table" or seen[tbl] then return end
    seen[tbl] = true
    local cn_count = 0
    local sample
    for k, v in pairs(tbl) do
        local kp = path .. "." .. tostring(k)
        if type(v) == "string" and #v > 0 and has_chinese(v) then
            cn_count = cn_count + 1
            if not sample then sample = v end
        elseif type(v) == "table" then
            scan(v, kp, depth + 1)
        end
    end
    if cn_count >= 1 then
        hits[#hits+1] = {path=path, count=cn_count, sample=sample}
    end
end

print("[DangTienGlobal] === scanning all globals (lowered threshold) ===")
-- Scan main mod's GLOBAL table specifically
local mm = rawget(_G, "ModManager")
if mm and mm.mods and mm.mods[1] and mm.mods[1].GLOBAL then
    local mg = mm.mods[1].GLOBAL
    if mg.TUNING then scan(mg.TUNING, "MOD.TUNING", 0) end
    if mg.STRINGS then scan(mg.STRINGS, "MOD.STRINGS", 0) end
end
-- Also scan our own TUNING/STRINGS in case mod merged into them
scan(TUNING, "TUNING", 0)
table.sort(hits, function(a,b) return a.count > b.count end)
for i = 1, math.min(500, #hits) do
    local h = hits[i]
    print(string.format("[DangTienGlobal] HIT %d cn=%d %s | sample=%s",
          i, h.count, h.path, h.sample:sub(1, 60)))
end
print("[DangTienGlobal] === done. " .. #hits .. " tables with >=5 CN strings ===")

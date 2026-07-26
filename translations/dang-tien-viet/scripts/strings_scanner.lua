-- Runtime scanner: dump STRINGS entries containing Chinese characters
-- to client_log.txt. Filters to mod-relevant paths (XD_*, etc.).
--
-- Usage: enable DEBUG_SCANNER in mod config, start the game, host a world,
-- then check ~/Documents/Klei/DoNotStarveTogether/client_log.txt:
--   grep "\[DangTienScan\]" client_log.txt > scanner.txt

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local has_chinese = rawget(_G, "dangtien_viet_has_chinese")

-- Path prefixes considered "mod-relevant" — adjust as needed
local TARGET_PREFIXES = {
    "XD_", "DAXSG", "WANGMAZI", "SHIJI", "HANTIANZUN", "YUNXIAO",
    "JINGWEI", "WUKONG", "SUDAJI", "LONGTAIZI", "LUOSHEN",
    "DENGXIAN", "TUTIAN", "TUXIAN",
}

local function path_matches(p)
    for _, pat in ipairs(TARGET_PREFIXES) do
        if p:find(pat, 1, true) then return true end
    end
    return false
end

local seen = {}
local count_cn, count_target_en = 0, 0

local function scan(tbl, path, depth)
    if depth > 10 or type(tbl) ~= "table" then return end
    if seen[tbl] then return end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        local kp = path .. "." .. tostring(k)
        if type(v) == "string" and #v > 0 then
            if has_chinese(v) then
                print("[DangTienScan] CN | " .. kp .. " = " .. v)
                count_cn = count_cn + 1
            elseif path_matches(kp) then
                print("[DangTienScan] EN | " .. kp .. " = " .. v)
                count_target_en = count_target_en + 1
            end
        elseif type(v) == "table" then
            scan(v, kp, depth + 1)
        end
    end
end

print("[DangTienScan] === scan begin ===")
scan(STRINGS, "STRINGS", 0)
print("[DangTienScan] === scan end. CN=" .. count_cn
      .. " mod-EN=" .. count_target_en .. " ===")

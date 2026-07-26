-- Dump all Chinese strings in MOD.STRINGS, MOD.TUNING, and MOD.package.loaded
-- Output: client_log.txt with prefix [DangTienDump]
-- Format: [DangTienDump] PATH = VALUE
-- Process with: grep "^\[\d.*DangTienDump\]" client_log.txt > runtime_strings.txt

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local has_chinese = rawget(_G, "dangtien_viet_has_chinese")
if not has_chinese then return end

local seen = {}
local count = 0
local MAX = 100000

local function escape(s)
    return (s:gsub("\n", "\\n"):gsub("\t", "\\t"))
end

local function dump(tbl, path, depth)
    if depth > 8 or type(tbl) ~= "table" or seen[tbl] or count > MAX then return end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        if type(k) == "string" or type(k) == "number" then
            local kp = path .. "." .. tostring(k)
            if type(v) == "string" and #v > 0 and has_chinese(v) then
                count = count + 1
                print("[DangTienDump] " .. kp .. " = " .. escape(v))
            elseif type(v) == "table" then
                dump(v, kp, depth + 1)
            end
        end
    end
end

print("[DangTienDump] === BEGIN ===")
local mm = rawget(_G, "ModManager")
if mm and mm.mods then
    for i, m in ipairs(mm.mods) do
        if m.GLOBAL then
            local mg = m.GLOBAL
            if mg.STRINGS then dump(mg.STRINGS, "MOD"..i..".STRINGS", 0) end
            if mg.TUNING then dump(mg.TUNING, "MOD"..i..".TUNING", 0) end
            if mg.package and mg.package.loaded then
                dump(mg.package.loaded, "MOD"..i..".pkg", 0)
            end
        end
    end
end
print("[DangTienDump] === END count=" .. count .. " ===")

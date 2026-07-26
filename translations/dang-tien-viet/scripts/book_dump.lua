-- Triggered dump: when user opens Tu Tien Mat Quyen, walk the active screen
-- and dump all visible widget data containing Chinese.
-- Hooks into screen show events.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local has_chinese = rawget(_G, "dangtien_viet_has_chinese")
if not has_chinese then return end

local function escape(s) return (s:gsub("\n", "\\n"):gsub("\t", " ")) end

local seen, count
local function dump_obj(obj, path, depth)
    if depth > 10 or seen[obj] or count > 5000 then return end
    if type(obj) == "string" then
        if has_chinese(obj) then
            count = count + 1
            print("[DangTienBook] " .. path .. " = " .. escape(obj))
        end
        return
    end
    if type(obj) ~= "table" then return end
    seen[obj] = true
    for k, v in pairs(obj) do
        if type(k) == "string" or type(k) == "number" then
            local kp = path .. "." .. tostring(k)
            -- skip metatables, known engine fields
            if k ~= "_listeners" and k ~= "inst" and k ~= "parent"
               and k ~= "components" and k ~= "_parent" then
                dump_obj(v, kp, depth + 1)
            end
        end
    end
end

-- Try hooking the popup screen
local function try_hook_screen(screen_name)
    local ok, screen_class = pcall(require, screen_name)
    if not ok or type(screen_class) ~= "table" then return false end
    local orig_init = screen_class._ctor or screen_class.__init or screen_class.OnBecomeActive
    -- Hook OnBecomeActive (called when screen shown)
    local orig_active = screen_class.OnBecomeActive
    if orig_active then
        screen_class.OnBecomeActive = function(self, ...)
            local r = {orig_active(self, ...)}
            print("[DangTienBook] === " .. screen_name .. " OnBecomeActive ===")
            seen = {}
            count = 0
            dump_obj(self, "screen", 0)
            print("[DangTienBook] === count=" .. count .. " ===")
            return unpack(r)
        end
        return true
    end
    return false
end

-- Try multiple possible screen names
local hooked = {}
for _, name in ipairs({
    "screens/xdbookpopupscreen",
    "screens/redux/xdbookpopupscreen",
}) do
    if try_hook_screen(name) then table.insert(hooked, name) end
end

-- Also hook generic PopupDialogScreen as fallback
local ok, PDS = pcall(require, "screens/redux/popupdialog")
if ok and PDS and PDS.OnBecomeActive then
    local orig = PDS.OnBecomeActive
    PDS.OnBecomeActive = function(self, ...)
        local r = {orig(self, ...)}
        if self.title and type(self.title) == "table" and self.title.GetString then
            local t = pcall(function() return self.title:GetString() end)
            if t and has_chinese(t) then
                print("[DangTienBook] popup title = " .. t)
            end
        end
        return unpack(r)
    end
end

print("[DangTienBook] hook installed for: " .. table.concat(hooked, ","))

-- Universal: console command to dump current TopScreen
rawset(_G, "DangTienDumpTop", function()
    local TheFrontEnd = rawget(_G, "TheFrontEnd")
    if not TheFrontEnd then return end
    local top = TheFrontEnd:GetActiveScreen()
    if not top then print("[DangTienBook] no active screen") return end
    print("[DangTienBook] === manual dump of " .. tostring(top.name or top) .. " ===")
    seen = {}
    count = 0
    dump_obj(top, "top", 0)
    print("[DangTienBook] === count=" .. count .. " ===")
end)
print("[DangTienBook] type DangTienDumpTop() in console while book open")

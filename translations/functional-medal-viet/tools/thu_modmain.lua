-- Chạy thử modmain trong MÔI TRƯỜNG GIẢ LẬP của DST.
--
--   luajit tools/thu_modmain.lua
--
-- ⚠ VÌ SAO CẦN CÁI NÀY, KHI ĐÃ CÓ `luajit -bl`. Kiểm cú pháp KHÔNG BẮT ĐƯỢC
--   việc gọi một global mà DST không cấp cho mod. Đã dính thật: modmain gọi
--   `pcall(...)` — cú pháp hoàn hảo, `luajit -bl` báo sạch, mod lên Workshop
--   ngon lành — rồi ném "attempt to call global 'pcall' (a nil value)" NGAY
--   TRONG AddSimPostInit, tức đúng lúc người chơi vừa vào world.
--
--   Nhìn từ server thì triệu chứng là: client vào được rồi RỚT sau 12-26 giây,
--   kèm "[P2P] Connection failed ... error code 4". Không một dòng nào nói là
--   lỗi mod, nên rất dễ đổ oan cho đường truyền hoặc cho server.
--
-- ⚠ DANH SÁCH DƯỚI ĐÂY CHÉP ĐÚNG scripts/mods.lua:369. Đừng thêm gì vào cho
--   "dễ chạy" — thêm là mất luôn tác dụng của bộ thử. Thứ gì không có trong
--   danh sách thì modmain phải lấy qua GLOBAL.

local MOD = "build/functional-medal-vi"

local STRINGS = {
  NAMES = {}, RECIPE_DESC = {},
  CHARACTERS = { GENERIC = { DESCRIBE = {} } },
}
-- GLOBAL trong DST chính là _G, nên nó có pcall/type/... đầy đủ.
local GLOBAL = setmetatable({ STRINGS = STRINGS }, { __index = _G })

local hook
local env = {
  -- lua  (đúng bằng scripts/mods.lua:369, không hơn)
  pairs = pairs, ipairs = ipairs, print = print, math = math, table = table,
  type = type, string = string, tostring = tostring,
  require = function(m) return dofile(MOD .. "/scripts/" .. m .. ".lua") end,
  -- runtime
  TUNING = {},
  GLOBAL = GLOBAL, modname = "thu", MODROOT = MOD .. "/",
  -- móc mà mod này dùng
  AddSimPostInit = function(fn) hook = fn end,
}

local function chet(msg)
  print("✗ " .. msg)
  os.exit(1)
end

local f = loadfile(MOD .. "/modmain.lua") or chet("không đọc được modmain.lua")
setfenv(f, env)
local ok, err = pcall(f)
if not ok then chet("modmain nổ khi nạp: " .. tostring(err)) end
if hook == nil then chet("modmain không đăng ký AddSimPostInit") end

local ok2, err2 = pcall(hook)
if not ok2 then chet("AddSimPostInit nổ: " .. tostring(err2)) end

local function dem(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
local a, b, c = dem(STRINGS.NAMES), dem(STRINGS.RECIPE_DESC),
                dem(STRINGS.CHARACTERS.GENERIC.DESCRIBE)
if a + b + c == 0 then chet("chạy xong mà KHÔNG áp được chuỗi nào") end

print(string.format("✓ modmain chạy sạch — NAMES=%d RECIPE_DESC=%d DESCRIBE=%d (tổng %d)",
                    a, b, c, a + b + c))
print("  ví dụ: NAMES.COOK_CERTIFICATE = " .. tostring(STRINGS.NAMES.COOK_CERTIFICATE))

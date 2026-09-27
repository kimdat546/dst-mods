-- Chạy thử modmain trong MÔI TRƯỜNG GIẢ LẬP của DST, trên chuỗi THẬT của mod gốc.
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
-- ⚠ DANH SÁCH `env` DƯỚI ĐÂY CHÉP ĐÚNG scripts/mods.lua:369. Đừng thêm gì vào
--   cho "dễ chạy" — thêm là mất luôn tác dụng của bộ thử. Thứ gì không có
--   trong danh sách thì modmain phải lấy qua GLOBAL.
--
-- Ngoài chuyện env, bộ thử còn dựng lại ĐÚNG những chỗ mod gốc COPY chuỗi đi
-- lúc nạp (xem modmain_mau.lua), rồi kiểm bản dịch có tới được chỗ copy không:
--   • STRINGS.ACTIONS[id]  ← MEDAL_NEWACTION[khoá]   (medal_actions.lua)
--   • CHARACTERS.*.ACTIONFAIL ← MEDAL_ACTIONFAIL_SPEECH (medal_wipebutt.lua)
--   • bảng đề thi medal_exam_defs_en qua require dùng chung

local MOD = "build/functional-medal-vi"
local GOC = os.getenv("HOME") ..
  "/Library/Application Support/Steam/steamapps/workshop/content/322330/1909182187"

local function chet(msg) print("✗ " .. msg) os.exit(1) end
local function doc(p) local f = io.open(p, "rb") or chet("không mở được " .. p)
  local s = f:read("*a") f:close() return s end

-- 1) Nạp chuỗi TIẾNG ANH thật của mod gốc vào STRINGS (tự tạo bảng con khi
--    file đọc tới), rồi gỡ metatable cho giống bảng thường của game.
local function tudong()
  return setmetatable({}, { __index = function(t, k)
    local v = tudong(); rawset(t, k, v); return v end })
end
local STRINGS = tudong()
do
  local f = loadfile(GOC .. "/scripts/lang/medal_strings_eng.lua") or chet("không nạp được chuỗi gốc")
  setfenv(f, setmetatable({ STRINGS = STRINGS, TUNING = tudong() }, { __index = function(_, k)
    local g = _G[k]; if g ~= nil then return g end; return tudong() end }))
  f()
  local function go(t, da) if da[t] then return end; da[t] = true; setmetatable(t, nil)
    for _, v in pairs(t) do if type(v) == "table" then go(v, da) end end end
  go(STRINGS, {})
end
STRINGS.ACTIONS = STRINGS.ACTIONS or {}
STRINGS.CHARACTERS = STRINGS.CHARACTERS or {}
STRINGS.CHARACTERS.GENERIC = STRINGS.CHARACTERS.GENERIC or {}

-- 2) Dựng lại các bản copy lúc nạp, y như mod gốc làm (bằng tiếng Anh).
local cap = {}   -- id hành động -> khoá MEDAL_NEWACTION
do
  local function quet(s)
    for b in s:gmatch("%b{}") do
      local trong = b:sub(2, -2)
      local _, n = trong:gsub('id%s*=%s*"', "")
      if n == 1 then
        local id = trong:match('id%s*=%s*"([%w_]+)"')
        local k = trong:match("STRINGS%.MEDAL_NEWACTION%.([%w_]+)")
        if id and k then cap[id] = k end
      elseif n > 1 then quet(trong) end
    end
  end
  quet(doc(GOC .. "/scripts/medal_defs/medal_actions.lua"))
end
local so_cap, so_khac = 0, 0
for id, k in pairs(cap) do
  if type(STRINGS.MEDAL_NEWACTION[k]) == "string" then
    STRINGS.ACTIONS[id] = STRINGS.MEDAL_NEWACTION[k]
    so_cap = so_cap + 1
    if id ~= k then so_khac = so_khac + 1 end
  end
end
if so_cap < 50 then chet("chỉ dò được " .. so_cap .. " hành động trong medal_actions.lua") end
local AF = {}
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL = STRINGS.CHARACTERS.GENERIC.ACTIONFAIL or {}
for hd, bang in pairs(STRINGS.MEDAL_ACTIONFAIL_SPEECH) do
  STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[hd] = STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[hd] or {}
  for ly, en in pairs(bang) do
    STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[hd][ly] = en
    AF[#AF + 1] = { hd, ly, en }
  end
end

-- 3) Môi trường mod đúng mods.lua:369. require dùng chung một package.loaded
--    như game thật: mod gốc nạp đề thi trước, mod dịch require lại ra CÙNG bảng.
local loaded = {}
local function req(m)
  if loaded[m] == nil then
    local p = MOD .. "/scripts/" .. m .. ".lua"
    local f = io.open(p) or io.open(GOC .. "/scripts/" .. m .. ".lua")
    if not f then error("module '" .. m .. "' not found") end
    f:close()
    p = io.open(p) and p or (GOC .. "/scripts/" .. m .. ".lua")
    loaded[m] = dofile(p)
  end
  return loaded[m]
end
local DE = req("medal_defs/medal_exam_defs_en")   -- mod gốc nạp trước
-- Màn đề thi giả: chỉ cần _ctor tạo self.content có SetMultilineTruncatedString,
-- để kiểm bản vá hạ số ký tự/dòng (xem VaManDeThi).
local MAN_THI = { _ctor = function(self)
  self.content = { SetMultilineTruncatedString = function(w, str, dong, rong, ky_tu) w.ky_tu = ky_tu end }
end }
loaded["screens/medalexamscreen"] = MAN_THI
local de_en_1 = DE[1].content

-- GLOBAL trong DST chính là _G, nên nó có pcall/tonumber/... đầy đủ.
local GLOBAL = setmetatable({ STRINGS = STRINGS }, { __index = _G })
local hooks = {}
local env = {
  -- lua  (đúng bằng scripts/mods.lua:369, không hơn)
  pairs = pairs, ipairs = ipairs, print = print, math = math, table = table,
  type = type, string = string, tostring = tostring, require = req,
  -- runtime
  TUNING = {},
  GLOBAL = GLOBAL, modname = "thu", MODROOT = MOD .. "/",
  -- móc mà mod này dùng
  AddSimPostInit  = function(fn) hooks[#hooks + 1] = fn end,
  AddGamePostInit = function(fn) hooks[#hooks + 1] = fn end,
}

local f = loadfile(MOD .. "/modmain.lua") or chet("không đọc được modmain.lua")
setfenv(f, env)
local ok, err = pcall(f)
if not ok then chet("modmain nổ khi nạp: " .. tostring(err)) end
if #hooks == 0 then chet("modmain không đăng ký móc postinit nào") end
for i, fn in ipairs(hooks) do
  local ok2, err2 = pcall(fn)
  if not ok2 then chet("móc postinit #" .. i .. " nổ: " .. tostring(err2)) end
end

-- 4) Kiểm từng chuỗi trong bảng dịch đã nằm đúng chỗ, đúng KIỂU khoá.
local VI = dofile(MOD .. "/scripts/medal_vi_strings.lua")
local function lay(goc, duong)
  local t = goc
  for doan in duong:gmatch("[^/]+") do
    if type(t) ~= "table" then return nil end
    local kieu, k = doan:sub(1, 1), doan:sub(3)
    t = t[kieu == "n" and tonumber(k) or k]
  end
  return t
end
local sai, dung = {}, 0
for i = 1, #VI.strings, 2 do
  local duong, chu = VI.strings[i], VI.strings[i + 1]
  if lay(STRINGS, duong) == chu then dung = dung + 1 else sai[#sai + 1] = duong end
end
local thi_dung, thi_sai = 0, {}
for i = 1, #VI.exam, 2 do
  local duong, chu = VI.exam[i], VI.exam[i + 1]
  if lay(DE, duong) == chu then thi_dung = thi_dung + 1 else thi_sai[#thi_sai + 1] = duong end
end

-- ACTIONS: mọi id phải đổi sang đúng chuỗi dịch của khoá tương ứng.
local hd_sai = {}
for id, k in pairs(cap) do
  local v = STRINGS.ACTIONS[id]
  if type(v) == "string" and v ~= STRINGS.MEDAL_NEWACTION[k] then hd_sai[#hd_sai + 1] = id end
end
-- ACTIONFAIL: bản copy không được còn là tiếng Anh gốc.
local af_sai = {}
for _, x in ipairs(AF) do
  local v = STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[x[1]][x[2]]
  if v == x[3] or v ~= STRINGS.MEDAL_ACTIONFAIL_SPEECH[x[1]][x[2]] then af_sai[#af_sai + 1] = x[1] .. "." .. x[2] end
end
-- Bảng trạng thái không được bị ghi đè thành chuỗi.
local bang_sai = {}
for _, k in ipairs({ "MEDAL_BEEBOX", "MEDAL_SEAPOND", "BEARGER_CHEST", "MEDAL_SHROOM_CHEST" }) do
  if type(STRINGS.CHARACTERS.GENERIC.DESCRIBE[k]) ~= "table" then bang_sai[#bang_sai + 1] = k end
end

local function liet(ds) return table.concat(ds, ", ", 1, math.min(#ds, 8)) end
local loi = false
if #sai > 0 then loi = true print("✗ " .. #sai .. " chuỗi không tới nơi: " .. liet(sai)) end
if #thi_sai > 0 then loi = true print("✗ " .. #thi_sai .. " dòng đề thi không tới nơi: " .. liet(thi_sai)) end
if DE[1].content == de_en_1 then loi = true print("✗ đề thi vẫn là tiếng Anh") end
if #hd_sai > 0 then loi = true print("✗ " .. #hd_sai .. " ACTIONS lệch: " .. liet(hd_sai)) end
if #af_sai > 0 then loi = true print("✗ " .. #af_sai .. " ACTIONFAIL chưa dịch: " .. liet(af_sai)) end
if #bang_sai > 0 then loi = true print("✗ bảng trạng thái bị ghi đè: " .. liet(bang_sai)) end
local man = {}
MAN_THI._ctor(man)
man.content:SetMultilineTruncatedString("x", 6, 250, 40, true, true)
if not (type(man.content.ky_tu) == "number" and man.content.ky_tu < 40) then
  loi = true print("✗ màn đề thi chưa được vá: vẫn " .. tostring(man.content.ky_tu) .. " ký tự/dòng")
end
if loi then os.exit(1) end

print(string.format("✓ modmain chạy sạch — %d/%d chuỗi, %d/%d dòng đề thi, %d ACTIONS (%d khác tên khoá), %d ACTIONFAIL",
  dung, #VI.strings / 2, thi_dung, #VI.exam / 2, so_cap, so_khac, #AF))
print("  ví dụ: ACTIONS.MEDALTOOLSORB = " .. tostring(STRINGS.ACTIONS.MEDALTOOLSORB))
print("  ví dụ: đề 1 = " .. tostring(DE[1].content))
print("  màn đề thi: 40 → " .. tostring(man.content.ky_tu) .. " ký tự/dòng")

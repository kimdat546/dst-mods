-- Chạy một file chuỗi của mod trong hộp cát rồi in ra MỌI chuỗi lá.
--
--   luajit tools/rut_chuoi.lua strings <file.lua>   bảng STRINGS
--   luajit tools/rut_chuoi.lua bang    <file.lua>   file trả về một bảng (đề thi)
--
-- ⚠ VÌ SAO CHẠY FILE CHỨ KHÔNG DÒ BẰNG REGEX. Bản rút chuỗi đầu dò dạng
--   `STRINGS.X.Y = "..."` và báo "856/856 (100%)" — trong khi file thật sinh
--   ra 1.568 chuỗi. Mọi bảng khai kiểu `STRINGS.X = { ... }` đều lọt lưới:
--   tên hành động, giao diện, nhiệm vụ, thoại... Chạy thẳng file thì mod gán
--   gì mình thấy nấy.
--
-- Mỗi dòng ra: <đường dẫn>\t<giá trị>. Đường dẫn nối bằng "/", mỗi đoạn có
-- tiền tố kiểu: s:khoá chữ, n:khoá số. Phải giữ kiểu vì nhiều bảng thoại là
-- MẢNG — ghi nhầm khoá số 1 thành khoá chữ "1" là mod gốc không đọc thấy.
local che_do, tep = arg[1], arg[2]

local function tudong()
  return setmetatable({}, { __index = function(t, k)
    local v = tudong(); rawset(t, k, v); return v end })
end

local STRINGS = tudong()
local env = setmetatable({ STRINGS = STRINGS, TUNING = tudong() }, { __index = function(_, k)
  local g = _G[k]; if g ~= nil then return g end
  return tudong() end })

local f = assert(loadfile(tep))
setfenv(f, env)
local ok, ra = pcall(f)
if not ok then io.stderr:write("LỖI chạy " .. tep .. ": " .. tostring(ra) .. "\n") os.exit(1) end

local function thoat(s) return (s:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "")) end
local function doan(k) return (type(k) == "number" and "n:" or "s:") .. tostring(k) end

local function di(t, duong, da)
  if da[t] then return end; da[t] = true
  local khoa = {}
  for k in pairs(t) do khoa[#khoa + 1] = k end
  table.sort(khoa, function(a, b) return tostring(a) < tostring(b) end)
  for _, k in ipairs(khoa) do
    local v, p = t[k], duong .. "/" .. doan(k)
    if type(v) == "string" then io.write(p:sub(2), "\t", thoat(v), "\n")
    elseif type(v) == "table" then di(v, p, da) end
  end
end

if che_do == "strings" then di(STRINGS, "", {})
else assert(type(ra) == "table", "file không trả về bảng"); di(ra, "", {}) end

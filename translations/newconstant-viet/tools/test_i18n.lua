-- Kiểm apply.lua + i18n.lua ngoài máy, không cần game.
--     lua tools/test_i18n.lua
--
-- Có giả lập strict.lua của DST (đọc biến toàn cục chưa khai báo là ném lỗi),
-- vì đó chính là loại lỗi mà Lua thường không bắt được.

local declared = {}
setmetatable(_G, {
    __newindex = function(t, k, v) declared[k] = true; rawset(t, k, v) end,
    __index = function(_, k)
        if not declared[k] then error("variable '" .. tostring(k) .. "' is not declared", 2) end
        return nil
    end,
})

package.path = "scripts/ncvi/?.lua;" .. package.path
local apply = dofile("scripts/ncvi/apply.lua")
local i18n  = dofile("scripts/ncvi/i18n.lua")

local fail = 0
local function check(cond, msg)
    if cond then print("  ✓ " .. msg) else print("  ✗ " .. msg); fail = fail + 1 end
end

print("── apply.set ──")
local S = {}
check(apply.set(S, "STRINGS.NAMES.FOO", "Ba"), "tạo được nhánh sâu")
check(S.NAMES and S.NAMES.FOO == "Ba", "giá trị nằm đúng chỗ")
check(select(1, apply.set(S, "STRINGS.A.B.C.D", "x")), "tạo nhiều tầng trung gian")
check(S.A.B.C.D == "x", "tầng sâu đúng giá trị")

local ok, why = apply.set(S, "NAMES.FOO", "x")
check(not ok and why:find("STRINGS"), "từ chối đường dẫn không bắt đầu bằng STRINGS")

ok, why = apply.set(S, "STRINGS.NAMES.FOO.BAR", "x")
check(not ok and why:find("đâm vào chuỗi"), "từ chối ghi đè xuyên qua một chuỗi đang có")
check(S.NAMES.FOO == "Ba", "chuỗi cũ KHÔNG bị phá khi bị từ chối")

print("\n── apply.set: chỉ số MẢNG ──")
local A = {}
check(apply.set(A, "STRINGS.BOSSRUSH.1", "một"), "gán được phần tử mảng")
check(apply.set(A, "STRINGS.BOSSRUSH.2", "hai"), "gán phần tử thứ hai")
check(A.BOSSRUSH[1] == "một", "truy cập bằng CHỈ SỐ SỐ được (không phải chuỗi \"1\")")
check(rawget(A.BOSSRUSH, "1") == nil, "không tạo nhầm khoá chuỗi \"1\"")
check(#A.BOSSRUSH == 2, "ipairs/# đếm đúng 2 phần tử — game đọc được")

print("\n── apply.apply ──")
local S2 = {}
local n, errs = apply.apply(S2, {
    ["STRINGS.NAMES.A"] = "a",
    ["STRINGS.NAMES.B"] = "b",
    ["SAI.C"]           = "c",
    ["STRINGS.NAMES.D"] = 123,
})
check(n == 2, "gán đúng 2 mục hợp lệ (được " .. n .. ")")
check(#errs == 2, "báo đúng 2 lỗi (được " .. #errs .. ")")

print("\n── i18n.normalize ──")
check(i18n.normalize("zh") == "zh", "zh")
check(i18n.normalize("zht") == "zh", "zht → zh")
check(i18n.normalize("zhr") == "zh", "zhr → zh")
check(i18n.normalize("vi") == "vi", "vi")
check(i18n.normalize(nil) == "en", "nil → en")
check(i18n.normalize("") == "en", "rỗng → en")
check(i18n.normalize("fr_FR") == "fr", "fr_FR → fr")

print("\n── i18n.resolve: chuỗi dự phòng ──")
local TABLES = {
    ["lang.zh"] = { A = "zhA", B = "zhB", C = "zhC" },
    ["lang.en"] = { A = "enA", B = "enB" },
    ["lang.vi"] = { A = "viA" },
}
local function loader(name)
    local t = TABLES[name]
    if t == nil then error("không có " .. name) end
    return t
end

local m, st = i18n.resolve(loader, "vi")
check(m.A == "viA", "có bản Việt thì dùng bản Việt")
check(m.B == "enB", "thiếu bản Việt thì rơi xuống tiếng Anh")
check(m.C == "zhC", "thiếu cả Anh thì rơi xuống tiếng Trung")
check(st.total == 3, "tổng 3 chuỗi")
check(st.from_fallback == 2, "đếm đúng 2 chuỗi phải dùng dự phòng")

local m2, st2 = i18n.resolve(loader, "zht")
check(m2.A == "zhA", "zht lấy đúng bảng zh, không bị bản en đè")
check(st2.from_fallback == 0, "zh không cần dự phòng")

local m3 = i18n.resolve(loader, "de")
check(m3.A == "enA" and m3.C == "zhC", "ngôn ngữ chưa có vẫn chạy, dùng dự phòng")

print("\n" .. (fail == 0 and "  TẤT CẢ ĐẠT" or ("  HỎNG " .. fail .. " chỗ")))
os.exit(fail == 0 and 0 or 1)

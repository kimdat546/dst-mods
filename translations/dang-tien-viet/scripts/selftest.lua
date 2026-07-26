-- Self-test chạy BÊN TRONG game, in kết quả ra log.
--
-- Mục đích: đo khách quan "còn bao nhiêu chữ Hán trong STRINGS sau khi mod
-- dịch đã chạy", thay vì phải vào game chơi tới đâu phát hiện tới đó.
--
-- Chỉ nạp khi _G.DANGTIEN_SELFTEST = true (bản build test đặt cờ này).
-- Chạy được cả trên dedicated server headless → không cần mở game.
--
-- Đọc kết quả:  docker logs <container> | grep '\[DangTienVN\]\[TEST\]'

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local has_chinese = rawget(_G, "dangtien_viet_has_chinese")
if not has_chinese then
    print("[DangTienVN][TEST] FATAL: thiếu has_chinese — main.lua chưa nạp?")
    return
end

local function log(msg) print("[DangTienVN][TEST] " .. msg) end

-- =========================================================================
-- 1. Quét toàn bộ STRINGS, đếm chuỗi còn chữ Hán
-- =========================================================================
local remaining, total = {}, 0
local seen = {}

local function walk(tbl, path, depth)
    if depth > 8 or seen[tbl] then return end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and k or ("[" .. tostring(k) .. "]")
        local p = path .. "." .. key
        if type(v) == "string" then
            total = total + 1
            if has_chinese(v) then
                remaining[#remaining + 1] = p .. " = " .. v
            end
        elseif type(v) == "table" then
            walk(v, p, depth + 1)
        end
    end
end

local ok, err = pcall(walk, STRINGS, "STRINGS", 0)
if not ok then
    log("LỖI khi quét STRINGS: " .. tostring(err))
else
    log(string.format("QUÉT: %d chuỗi trong STRINGS, còn %d chuỗi có chữ Hán (%.1f%%)",
        total, #remaining, #remaining / math.max(total, 1) * 100))

    -- Gom theo nhóm để biết phần còn lại nằm ở đâu, thay vì in hàng nghìn dòng.
    -- Thoại nhân vật (CHARACTERS.XD_*) gom theo tên nhân vật; còn lại theo 3 cấp.
    local groups, order = {}, {}
    for _, entry in ipairs(remaining) do
        local path = entry:match("^([^ ]+)")
        local g = path:match("^(STRINGS%.CHARACTERS%.XD_[A-Z0-9_]+)%.")
                or path:match("^(STRINGS%.[A-Za-z_0-9]+%.[A-Za-z_0-9]+)%.")
                or path:match("^(STRINGS%.[A-Za-z_0-9]+)")
                or path
        if not groups[g] then groups[g] = 0; order[#order + 1] = g end
        groups[g] = groups[g] + 1
    end
    table.sort(order, function(a, b) return groups[a] > groups[b] end)
    log("PHÂN BỐ phần chưa dịch:")
    for i = 1, math.min(#order, 15) do
        log(string.format("  %6d  %s", groups[order[i]], order[i]))
    end
    if #order > 15 then
        log(string.format("  ... và %d nhóm nhỏ nữa", #order - 15))
    end

    -- Vài ví dụ cụ thể NGOÀI phần thoại nhân vật — đây mới là thứ đáng vá.
    local n = 0
    for _, entry in ipairs(remaining) do
        if not entry:find("^STRINGS%.CHARACTERS%.XD_") and n < 10 then
            n = n + 1
            log("  NGOÀI_THOẠI: " .. entry)
        end
    end
    if n == 0 then
        log("  ✓ Không còn chữ Hán nào ngoài phần thoại nhân vật.")
    end

    -- Ghi danh sách ĐẦY ĐỦ (phần ngoài thoại) ra persistent string để đọc từ
    -- ngoài container: file nằm trong thư mục persistent_storage_root đã mount.
    -- Đây là kênh đưa dữ liệu từ trong game ra ngoài mà không cần console.
    local dump = {}
    for _, entry in ipairs(remaining) do
        if not entry:find("^STRINGS%.CHARACTERS%.XD_") then dump[#dump + 1] = entry end
    end
    if TheSim ~= nil and TheSim.SetPersistentString ~= nil then
        TheSim:SetPersistentString("dangtien_missing.txt", table.concat(dump, "\n"), false)
        log(string.format("ĐÃ GHI %d dòng ngoài-thoại ra dangtien_missing.txt", #dump))
    end
end

-- =========================================================================
-- 2. Kiểm điểm những chuỗi phase6 vừa dịch (mod gốc v19.0)
-- =========================================================================
local CASES = {
    {"STRINGS.NAMES.XD_CHENPINGAN_BD",                         "Bắc Đẩu"},
    {"STRINGS.NAMES.XD_CHENPINGAN_ZLT",                        "Trảm Long Đài"},
    {"STRINGS.NAMES.XD_CHENPINGAN_KCD",                        "Dao chặt củi"},
    {"STRINGS.NAMES.XD_QINGMEIJIU",                            "Rượu thanh mai"},
    {"STRINGS.CHARACTERS.GENERIC.DESCRIBE.XD_CHENPINGAN_ZLT",  "Trên đài chém rồng, dưới đài kinh thần."},
    {"STRINGS.CHARACTERS.GENERIC.DESCRIBE.XD_CHENPINGAN_MUME.CHOPPED", "Gốc cây thanh mai."},
    {"STRINGS.RECIPE_DESC.XD_CHENPINGAN_QP",                   "Kiếm ý trong suốt, thẳng chỉ bản tâm."},
    {"STRINGS.XD_USE_INVENTORY.SUMMON_ST",                     "Thi triển Thần Thông"},
    {"STRINGS.XD_USE_INVENTORY.XD_PETEGG_IN",                  "Thu vào Đan Điền"},
    {"STRINGS.XD_LINGJIACTION.ATTACK",                         "Linh Kỹ"},
    {"STRINGS.XS_PET_LEVELUP.RONGHE",                          "Dung hợp"},
}

local function get_path(path)
    local tbl, parts = _G, {}
    for p in path:gmatch("[^%.]+") do parts[#parts + 1] = p end
    for i = 1, #parts do
        if type(tbl) ~= "table" then return nil, "đứt ở " .. parts[i - 1] end
        tbl = tbl[parts[i]]
        if tbl == nil then return nil, "không tồn tại: " .. parts[i] end
    end
    return tbl
end

local pass, fail = 0, 0
for _, c in ipairs(CASES) do
    local path, want = c[1], c[2]
    local got, why = get_path(path)
    if got == want then
        pass = pass + 1
    else
        fail = fail + 1
        log(string.format("  FAIL %s\n           mong đợi: %s\n           thực tế : %s",
            path, want, tostring(got) .. (why and (" (" .. why .. ")") or "")))
    end
end

log(string.format("KIỂM ĐIỂM: PASS %d / FAIL %d (tổng %d)", pass, fail, #CASES))

-- =========================================================================
-- 3. Mod gốc có thật sự đang chạy không (nếu không thì test vô nghĩa)
-- =========================================================================
local src_loaded = STRINGS.NAMES ~= nil and STRINGS.NAMES.XD_LINGSHI1 ~= nil
log("MOD_GỐC_ĐÃ_NẠP: " .. tostring(src_loaded))
log(src_loaded and (fail == 0 and "KẾT_QUẢ: PASS" or "KẾT_QUẢ: FAIL")
    or "KẾT_QUẢ: KHÔNG_XÁC_ĐỊNH (mod 登仙 chưa nạp)")

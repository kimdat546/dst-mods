-- Việt hoá Functional Medal (能力勋章) — mod CLIENT, không đụng mod gốc.
-- SINH TỰ ĐỘNG từ tools/modmain_mau.lua + strings_source.json. Đừng sửa tay.
--
-- ⚠ VÌ SAO GHI ĐÈ `STRINGS` CHỨ KHÔNG THÊM THƯ MỤC NGÔN NGỮ. Mod gốc hardcode
--   đúng hai nhánh (ch / eng), không có móc mở rộng, nên muốn thêm "vi" thì
--   phải fork cả mod.
--
-- ⚠ VÌ SAO KHÔNG LỖI KHI SERVER KHÔNG BẬT MOD GỐC. `STRINGS` là bảng toàn cục;
--   gán một khoá không ai đọc thì không có gì xảy ra. Còn bảng đề thi thì lấy
--   bằng pcall(require) — mod gốc vắng mặt thì require hỏng, bỏ qua êm.
--
-- ⚠ `pcall` KHÔNG CÓ trong môi trường mod. DST chỉ cấp cho modmain: pairs,
--   ipairs, print, math, table, type, string, tostring, require, Class, TUNING,
--   GLOBAL, modname, MODROOT (scripts/mods.lua:369). Bản 0.1.0 gọi thẳng pcall
--   và làm rớt client ngay khi vào world. Mọi thứ khác lấy qua GLOBAL.
local pcall = GLOBAL.pcall
local tonumber = GLOBAL.tonumber

-- Đường dẫn giữ KIỂU khoá: "s:" khoá chữ, "n:" khoá số. Nhiều bảng thoại là
-- MẢNG — ghi khoá số 1 thành khoá chữ "1" thì mod gốc không đọc thấy.
local BANG = {
@@BANG@@
}

-- 49 câu đề thi khảo hạch (medal_defs/medal_exam_defs_en.lua).
local THI = {
@@THI@@
}

-- Tiếng Anh -> tiếng Việt của những chuỗi bị mod gốc COPY đi chỗ khác lúc nạp:
--   * MEDAL_NEWACTION -> AddAction(id, str) ghi vào STRINGS.ACTIONS[id]
--   * MEDAL_ACTIONFAIL_SPEECH -> chép vào STRINGS.CHARACTERS.*.ACTIONFAIL
-- Sửa bảng nguồn sau khi đã chép là vô ích, phải sửa cả bản chép.
local BAN_COPY = {
@@BAN_COPY@@
}

local function Ghi(goc, duong, chu)
    local bang, khoa = goc, nil
    for doan in string.gmatch(duong, "[^/]+") do
        if khoa ~= nil then
            if type(bang[khoa]) ~= "table" then return false end
            bang = bang[khoa]
        end
        local kieu, k = string.match(doan, "^(%a):(.*)$")
        khoa = kieu == "n" and tonumber(k) or k
    end
    -- Chỉ ghi đè CHUỖI đã có, hoặc ô trống. Gặp bảng thì thôi — ghi chuỗi đè
    -- lên bảng là phá mô tả theo trạng thái (bản đầu đã làm hỏng đúng như vậy
    -- với MEDAL_BEEBOX).
    if type(bang[khoa]) == "table" then return false end
    bang[khoa] = chu
    return true
end

local function ThayBanCopy(bang, sau)
    if sau > 6 or type(bang) ~= "table" then return 0 end
    local n = 0
    for k, v in pairs(bang) do
        if type(v) == "string" then
            local moi = BAN_COPY[v]
            if moi ~= nil then bang[k] = moi; n = n + 1 end
        elseif type(v) == "table" then
            n = n + ThayBanCopy(v, sau + 1)
        end
    end
    return n
end

local function ApDung()
    local S = GLOBAL.STRINGS
    local n = 0
    for i = 1, #BANG, 2 do
        if Ghi(S, BANG[i], BANG[i + 1]) then n = n + 1 end
    end
    local c = ThayBanCopy(S.ACTIONS, 1)
    for _, nv in pairs(S.CHARACTERS or {}) do
        if type(nv) == "table" then c = c + ThayBanCopy(nv.ACTIONFAIL, 1) end
    end
    -- Đề thi: require dùng chung package.loaded với mod gốc, nên sửa bảng này
    -- là mod gốc thấy ngay, kể cả khi nó đã require từ trước.
    local t = 0
    local ok, de = pcall(require, "medal_defs/medal_exam_defs_en")
    if ok and type(de) == "table" then
        for i = 1, #THI, 2 do
            if Ghi(de, THI[i], THI[i + 1]) then t = t + 1 end
        end
    end
    return n, c, t
end

-- ⚠ ÁP Ở CẢ BA MỐC. DST xếp thứ tự nạp mod theo TÊN THƯ MỤC chứ không theo
--   `priority` (skill dst-workspace-tools, đã đo cả -9999 lẫn 9999). Mốc nào
--   chạy sau mod gốc thì mốc đó thắng; áp lặp chỉ là gán lại cùng giá trị.
local function ApMoc(moc)
    local ok, n, c, t = pcall(ApDung)
    if ok then
        print("[medal-vi @@PHIEN_BAN@@] " .. moc .. ": " .. tostring(n) .. " chuỗi, "
              .. tostring(c) .. " bản copy, " .. tostring(t) .. " dòng đề thi")
    else
        print("[medal-vi @@PHIEN_BAN@@] " .. moc .. ": LỖI " .. tostring(n))
    end
end

ApMoc("modmain")
AddSimPostInit(function() ApMoc("AddSimPostInit") end)
AddGamePostInit(function() ApMoc("AddGamePostInit") end)

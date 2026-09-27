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

-- Mod gốc COPY tên hành động lúc nạp: AddAction(id, STRINGS.MEDAL_NEWACTION.X)
-- ghi vào STRINGS.ACTIONS[id]. Sửa MEDAL_NEWACTION sau đó là vô ích.
--
-- ⚠ VÁ THEO MÃ, KHÔNG THEO GIÁ TRỊ TIẾNG ANH. 97 hành động nhưng 27 cái có mã
--   khác tên khoá, và nhiều khoá khác nhau cùng chữ "Repair" (vá giáp / bổ
--   sung sức mạnh không gian / bổ sung lông vũ). Thay theo giá trị thì cả ba ra
--   cùng một bản dịch. Bảng mã -> khoá này rút thẳng từ medal_actions.lua lúc
--   dựng (tools/build.py).
local MA_HANH_DONG = {
@@MA_HANH_DONG@@
}

-- Thoại lỗi hành động: mod gốc CHÉP MEDAL_ACTIONFAIL_SPEECH vào
-- STRINGS.CHARACTERS.*.ACTIONFAIL lúc nạp (medal_wipebutt.lua). Đây là câu
-- dài, không trùng nhau, nên vá theo giá trị là an toàn.
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
    local c = 0
    local tenhd = S.MEDAL_NEWACTION
    if type(S.ACTIONS) == "table" and type(tenhd) == "table" then
        for ma, khoa in pairs(MA_HANH_DONG) do
            -- Chỉ thay khi đang là CHUỖI: hành động có strfn dùng BẢNG biến thể.
            if type(S.ACTIONS[ma]) == "string" and type(tenhd[khoa]) == "string" then
                S.ACTIONS[ma] = tenhd[khoa]
                c = c + 1
            end
        end
    end
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

-- Màn đề thi: mod gốc xuống dòng theo SỐ KÝ TỰ (40/dòng cho tiếng Anh), không
-- theo độ rộng: khung chữ cố định 250px nên TextWidget:GetRegionSize() luôn
-- trả 250 và vòng đo độ rộng trong Text:SetTruncatedString không bao giờ
-- chạy. Chữ Việt có dấu rộng hơn, 40 ký tự tràn quá 250px và bị KHUNG CHE
-- (không mất chữ, chỉ không thấy). ~29 ký tự thường là đầy 250px ở cỡ 24 →
-- hạ còn 26. Câu dài nhất vẫn vừa 6 dòng (build.py kiểm).
--
-- ⚠ KHÔNG dùng AddClassPostConstruct: nó require NGAY lúc modmain chạy, mà bản
--   cài local (tên thư mục "functional-medal-vi…") nạp TRƯỚC mod gốc →
--   "module not found" là sập. Vá _ctor trong postinit, lúc mọi mod đã nạp.
local KY_TU_DONG_DE_THI = @@KY_TU_DONG_DE_THI@@
local function VaManDeThi()
    if GLOBAL.TheNet and GLOBAL.TheNet:IsDedicated() then return "bỏ qua (dedicated)" end
    local ok, lop = pcall(require, "screens/medalexamscreen")
    if not ok or type(lop) ~= "table" or type(lop._ctor) ~= "function" then
        return "không thấy màn đề thi"
    end
    if lop._medal_vi_da_va then return "đã vá" end
    lop._medal_vi_da_va = true
    local ctor = lop._ctor
    lop._ctor = function(self, ...)
        ctor(self, ...)
        local nd = self.content
        if nd and type(nd.SetMultilineTruncatedString) == "function" then
            local goc = nd.SetMultilineTruncatedString
            nd.SetMultilineTruncatedString = function(w, str, dong, rong, ky_tu, ...)
                if type(ky_tu) == "number" and ky_tu > KY_TU_DONG_DE_THI then
                    ky_tu = KY_TU_DONG_DE_THI
                end
                return goc(w, str, dong, rong, ky_tu, ...)
            end
        end
    end
    return "đã vá"
end
local function VaMoc(moc)
    local ok, kq = pcall(VaManDeThi)
    print("[medal-vi @@PHIEN_BAN@@] " .. moc .. ": màn đề thi " .. tostring(ok and kq or ("LỖI " .. tostring(kq))))
end

ApMoc("modmain")
AddSimPostInit(function() ApMoc("AddSimPostInit") end)
AddGamePostInit(function() ApMoc("AddGamePostInit"); VaMoc("AddGamePostInit") end)

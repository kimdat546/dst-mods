-- i18n.lua — chọn và nạp bảng chuỗi theo ngôn ngữ game.
--
-- Khác mod gốc ở ba điểm:
--   1. Thêm ngôn ngữ = thêm một file lang/<mã>.lua, KHÔNG phải sửa modmain.
--   2. Có chuỗi dự phòng nhiều tầng, nên thiếu bản dịch thì hiện tiếng Anh
--      (rồi tiếng Trung), chứ không bao giờ hiện nil/MISSING.
--   3. Báo ra log số chuỗi thiếu của từng ngôn ngữ — đo được tiến độ dịch
--      thay vì đoán.
--
-- Mod gốc dùng `if locale == "zh" ... else <tiếng Anh>`, nên mọi ngôn ngữ không
-- phải tiếng Trung đều rơi vào bản Anh — mà bản Anh còn 59/234 chuỗi chưa dịch,
-- vẫn là chữ Hán.

local M = {}

-- Thứ tự dự phòng: ngôn ngữ yêu cầu → tiếng Anh → tiếng Trung.
-- Tiếng Trung đứng cuối vì đó là bản ĐẦY ĐỦ NHẤT của mod gốc.
local FALLBACK = { "en", "zh" }

-- DST trả về nhiều mã cho tiếng Trung; gom hết về "zh".
local ALIAS = {
    zh = "zh", zht = "zh", zhr = "zh",
    vi = "vi", vn = "vi",
    en = "en",
}

-- Chuẩn hoá mã ngôn ngữ mà game đưa xuống.
function M.normalize(locale)
    if type(locale) ~= "string" or locale == "" then return "en" end
    local base = string.lower(string.match(locale, "^(%a+)") or locale)
    return ALIAS[base] or base
end

-- Nạp một bảng ngôn ngữ. Trả về bảng, hoặc nil nếu không có file.
-- `loader` là hàm nạp do bên gọi cung cấp (require của môi trường mod).
local function load_table(loader, code)
    local ok, tbl = pcall(loader, "lang." .. code)
    if ok and type(tbl) == "table" then return tbl end
    return nil
end

-- Dựng bảng cuối cùng: đắp từ tầng dự phòng thấp nhất lên trên.
-- Trả về bảng đã gộp + thống kê để ghi log.
function M.resolve(loader, locale)
    local want = M.normalize(locale)

    -- Xếp thứ tự đắp: dự phòng trước, ngôn ngữ mong muốn sau cùng (đè lên).
    local order = {}
    for i = #FALLBACK, 1, -1 do
        if FALLBACK[i] ~= want then order[#order + 1] = FALLBACK[i] end
    end
    order[#order + 1] = want

    local merged, stats = {}, { locale = want, layers = {}, total = 0, from_fallback = 0 }
    local own = nil
    for _, code in ipairs(order) do
        local tbl = load_table(loader, code)
        if tbl then
            local n = 0
            for k, v in pairs(tbl) do
                merged[k] = v
                n = n + 1
            end
            stats.layers[#stats.layers + 1] = code .. "=" .. n
            if code == want then own = tbl end
        end
    end

    for _ in pairs(merged) do stats.total = stats.total + 1 end
    if own then
        for k in pairs(merged) do
            if own[k] == nil then stats.from_fallback = stats.from_fallback + 1 end
        end
    else
        stats.from_fallback = stats.total
    end

    return merged, stats
end

function M.describe(stats)
    return string.format(
        "[NewConstant-VI] ngôn ngữ=%s | %d chuỗi (%d phải dùng dự phòng) | tầng: %s",
        stats.locale, stats.total, stats.from_fallback,
        table.concat(stats.layers, ", "))
end

return M

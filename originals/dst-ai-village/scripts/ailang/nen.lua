-- Nền chung: cấu hình + ghi log. Mọi file khác require file này.
--
-- File trong scripts/ được require từ modmain nên chạy trong môi trường
-- GLOBAL của game — dùng thẳng TheWorld, SpawnPrefab... KHÔNG có
-- GetModConfigData, nên modmain phải nhét cấu hình vào AILANG_CAUHINH trước.

local nen = {}

nen.cauhinh = rawget(_G, "AILANG_CAUHINH") or {}

local muc = nen.cauhinh.muc_log or 1

local function ghi(nguong, dinh, ...)
    if muc < nguong then return end
    local phan = {}
    for i = 1, select("#", ...) do
        table.insert(phan, tostring((select(i, ...))))
    end
    print("[ailang]" .. dinh .. " " .. table.concat(phan, " "))
end

function nen.log(...)  ghi(1, "",       ...) end
function nen.chitiet(...) ghi(2, "[ct]", ...) end
function nen.loi(...)  ghi(0, "[LỖI]", ...) end

-- pcall có báo lỗi kèm ngữ cảnh, thay cho pcall trần nuốt lỗi im lặng.
function nen.thu(ngucanh, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then nen.loi(ngucanh .. ":", err) end
    return ok, err
end

-- Tên dân làng. Người chơi phân biệt nhau bằng tên, dân làng cũng vậy.
nen.TEN = {
    "Tí", "Sửu", "Dần", "Mão", "Thìn", "Tỵ",
    "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi",
}

-- Nhân vật dùng làm thân xác. Đều là prefab người chơi vanilla nên dân làng
-- mặc được giáp, cầm được vũ khí, ăn được mọi thứ như người chơi thật.
nen.NHAN_VAT = { "wx78", "wilson", "willow", "wendy", "woodie", "wickerbottom" }

return nen

-- apply.lua — áp một bảng PHẲNG vào cây STRINGS của game.
--
-- Bảng ngôn ngữ dùng khoá phẳng dạng "STRINGS.NAMES.NEWCS_X" thay vì bảng lồng
-- nhau, vì ba lý do:
--   1. so sánh giữa các ngôn ngữ là so hai tập khoá, không phải duyệt cây
--   2. công cụ bên ngoài (python) đọc/ghi được mà không cần hiểu cú pháp Lua
--   3. thiếu khoá thì phát hiện ngay, không lặng lẽ tạo nhánh rỗng
--
-- ⚠ DST nạp strict.lua: ĐỌC biến toàn cục chưa khai báo là ném lỗi chứ không
-- trả nil. Mọi truy cập toàn cục ở đây đều đi qua rawget.

local M = {}

-- Tách "STRINGS.NAMES.X" thành {"STRINGS","NAMES","X"}.
-- Đoạn toàn chữ số được đổi thành SỐ, vì một số chuỗi của mod nằm trong MẢNG
-- (STRINGS.BOSSRUSH = {"…","…"}). Dùng khoá chuỗi "1" thay vì số 1 thì game đọc
-- bằng ipairs sẽ không thấy gì — lỗi im lặng, rất khó truy.
local function split(path)
    local parts = {}
    for seg in string.gmatch(path, "[^%.]+") do
        parts[#parts + 1] = string.match(seg, "^%d+$") and tonumber(seg) or seg
    end
    return parts
end

-- Gán giá trị vào đường dẫn, tạo bảng trung gian nếu thiếu.
-- Trả về true nếu gán được, false + lý do nếu không.
function M.set(root, path, value)
    local parts = split(path)
    if #parts < 2 then
        return false, "đường dẫn quá ngắn: " .. tostring(path)
    end
    if parts[1] ~= "STRINGS" then
        return false, "đường dẫn không bắt đầu bằng STRINGS: " .. tostring(path)
    end

    local node = root
    for i = 2, #parts - 1 do
        local seg = parts[i]
        local nxt = rawget(node, seg)
        if nxt == nil then
            nxt = {}
            rawset(node, seg, nxt)
        elseif type(nxt) ~= "table" then
            -- Đụng phải một chuỗi ở giữa đường: ghi tiếp sẽ phá chuỗi đang có.
            return false, "đường dẫn đâm vào chuỗi tại '" .. seg .. "': " .. path
        end
        node = nxt
    end

    rawset(node, parts[#parts], value)
    return true
end

-- Áp cả bảng. Trả về số mục đã gán và danh sách lỗi.
function M.apply(root, tbl)
    local ok, errors = 0, {}
    for path, value in pairs(tbl) do
        if type(value) == "string" then
            local done, why = M.set(root, path, value)
            if done then
                ok = ok + 1
            else
                errors[#errors + 1] = why
            end
        else
            errors[#errors + 1] = "giá trị không phải chuỗi: " .. tostring(path)
        end
    end
    return ok, errors
end

return M

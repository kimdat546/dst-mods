-- Nhật ký làng — trí nhớ dài hạn cho tầng suy nghĩ.
--
-- ⚠ TRƯỚC BẢN NÀY, MỖI NHỊP HỎI LÀ MỘT LẦN HỎI ĐỘC LẬP. Gói hỏi chỉ chụp
--   HIỆN TẠI: máu bao nhiêu, quanh mình có gì, nút thắt là gì. Tầng suy nghĩ
--   không biết đêm qua có ai chết, không biết nó đã ra lệnh gì mười nhịp
--   trước, không biết cái bản vẽ kia đã đứng đó ba ngày mà không ai góp.
--
--   Hậu quả rất cụ thể: nó ra lại đúng một lệnh đã hỏng, và hỏng lại đúng
--   cách cũ. `muc_tieu_loi` chỉ cứu được một nhịp.
--
-- ⚠ GIỮ NGẮN. Đây là thứ gửi kèm MỖI nhịp 15 giây, nên nhật ký dài là đốt
--   token và làm loãng phần quan trọng. Chỉ giữ việc ĐÁNG NHỚ, và chỉ giữ
--   SO_NHO mục gần nhất.

local nen = require("ailang/nen")

local nhat_ky = {}

local SO_NHO = 12          -- giữ bấy nhiêu mục gần nhất
local KHOA_GHI_NHO = 2000  -- chặn ghi nhớ của AI dài quá

-- Bản thân nhật ký sống trên TheWorld để lưu cùng world.
local function So()
    if TheWorld.ailang_nhat_ky == nil then
        TheWorld.ailang_nhat_ky = { muc = {}, ghi_nho = nil }
    end
    return TheWorld.ailang_nhat_ky
end

-- Ghi một việc đáng nhớ. `viec` là chuỗi ngắn, đã có sẵn ngày tháng.
function nhat_ky.Ghi(viec)
    if type(viec) ~= "string" or viec == "" then return end
    local s = So()
    local ngay = TheWorld.state.cycles or 0
    -- ⚠ Đừng ghi trùng liên tiếp. "lửa tắt" lặp mười lần trong một phút thì
    --   nhật ký chỉ còn mỗi nó, và mọi thứ đáng nhớ khác bị đẩy ra ngoài.
    local cuoi = s.muc[#s.muc]
    if cuoi ~= nil and cuoi.viec == viec and cuoi.ngay == ngay then
        cuoi.lap = (cuoi.lap or 1) + 1
        return
    end
    table.insert(s.muc, { ngay = ngay, viec = viec })
    while #s.muc > SO_NHO do table.remove(s.muc, 1) end
    nen.chitiet("nhật ký:", "ngày", ngay, "—", viec)
end

-- Bản gửi kèm gói hỏi.
function nhat_ky.BanGon()
    local s = So()
    local ra = {}
    for _, m in ipairs(s.muc) do
        table.insert(ra, "ngày " .. m.ngay .. ": " .. m.viec
                         .. (m.lap ~= nil and (" (x" .. m.lap .. ")") or ""))
    end
    return ra
end

-- ── ghi nhớ của chính tầng suy nghĩ ─────────────────────────────────────
--
-- ⚠ Đây mới là phần "dài hạn" thật. Nhật ký là thứ MOD thấy; `ghi_nho` là thứ
--   tầng suy nghĩ tự viết cho chính nó ở nhịp sau — kế hoạch đang theo, điều
--   đã học, thứ đã thử và hỏng. Mod không đọc hiểu nó, chỉ giữ hộ và trả lại.
function nhat_ky.DatGhiNho(chu)
    local s = So()
    if chu == nil or chu == "" then s.ghi_nho = nil return end
    if type(chu) ~= "string" then return end
    s.ghi_nho = #chu > KHOA_GHI_NHO and chu:sub(1, KHOA_GHI_NHO) or chu
end

function nhat_ky.GhiNho()
    return So().ghi_nho
end

-- ── nối vào các việc đáng nhớ ───────────────────────────────────────────

local nut_cu

-- Gọi mỗi nhịp hỏi: ghi lại những đổi thay đáng nhớ mà không ai báo.
function nhat_ky.SoatDoiThay(kho)
    if kho == nil then return end
    if kho.nut_that ~= nut_cu then
        if kho.nut_that == nil then
            nhat_ky.Ghi("làng hết nút thắt")
        else
            nhat_ky.Ghi("nút thắt đổi sang: " .. tostring(kho.nut_that))
        end
        nut_cu = kho.nut_that
    end
end

function nhat_ky.OnSave()
    local s = So()
    return { muc = s.muc, ghi_nho = s.ghi_nho }
end

function nhat_ky.OnLoad(data)
    if type(data) ~= "table" then return end
    local s = So()
    s.muc = data.muc or {}
    s.ghi_nho = data.ghi_nho
end

return nhat_ky

-- Sách hướng dẫn của 【登仙】 là ảnh (images/xd_info_*.tex), chữ Hán nằm trong
-- pixel. Bản tiếng Việt được vẽ lại bằng tools/book/render_page.py vào
-- images/vn_book/. Ở đây chỉ tráo atlas khi widget Image nạp trang sách:
-- không đụng file của mod gốc, trang nào chưa có bản Việt thì giữ nguyên.
--
-- Chạy trong env của mod (modimport từ modmain) để khai báo Assets.

local PAGES = {
    "xd_info_dy_1",    -- trang 1-2: bìa, lời tựa
    "xd_info_dy_2",    -- trang 3-4: Luyện Khí kỳ
    "xd_info_dy_3",    -- trang 5-6: Trúc Cơ kỳ
    "xd_info_dy_4",    -- trang 7-8: Kết Đan kỳ, Nguyên Anh kỳ
    "xd_info_dy_5",    -- trang 9-10: Vạn Vật Thăng Cách, Hóa Thần kỳ
    "xd_info_dy_7",    -- trang 13-14: đan dược theo phẩm
    "xd_info_dy_8",    -- trang 15-16: đan dược theo phẩm, Phản Hư kỳ
    "xd_info_ys_21",   -- trang 41-42: Cổ Nguyệt Phương Nguyên
}

local _G = GLOBAL
local have = {}
Assets = Assets or {}
for _, name in ipairs(PAGES) do
    local xml = "images/vn_book/" .. name .. ".xml"
    table.insert(Assets, Asset("ATLAS", xml))
    table.insert(Assets, Asset("IMAGE", "images/vn_book/" .. name .. ".tex"))
    have[name] = MODROOT .. xml
end

local Image = _G.require("widgets/image")
local old_SetTexture = Image.SetTexture
Image.SetTexture = function(self, atlas, tex, ...)
    local hd = false
    if type(atlas) == "string" then
        local name = atlas:match("images/(xd_info_[%w_]+)%.xml$")
        if name and have[name] and not atlas:find("vn_book", 1, true) then
            atlas = have[name]
            hd = true
        end
    end
    local ret = old_SetTexture(self, atlas, tex, ...)
    if hd then
        -- Ảnh Việt là 2048 (gấp đôi ảnh gốc 1024) cho chữ nét. Widget lấy cỡ
        -- hiển thị từ cỡ texture → thu về một nửa để trang giữ đúng cỡ cũ,
        -- không thì trang phình gấp đôi, tràn màn hình.
        local w, h = self:GetSize()
        if w and h then self:SetSize(w / 2, h / 2) end
    end
    return ret
end

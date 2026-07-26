-- Glossary CN ↔ VN từ wiki tiếng Việt (dang-tien.pdf, 83 trang).
-- Áp dụng vào textfix (exact match) và word_fix (substring) khi mod load.
-- File text đầy đủ wiki: ../wiki_reference.txt
--
-- LƯU Ý: Phần lớn entries dưới đây dựa trên tên nguyên bản tiếng Trung
-- mà ta SUY ĐOÁN từ wiki Việt (mod gốc bị mã hóa nên chưa xác nhận
-- được tên CN gốc). Sau khi chạy scanner, sẽ verify và update lại.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local textfix = rawget(_G, "dangtien_viet_textfix") or {}
local word_fix = rawget(_G, "dangtien_viet_word_fix") or {}

-- =========================================================================
-- 1. NHÂN VẬT (9 characters)
-- =========================================================================
local CHARACTERS = {
    ["王麻子"]   = "Vương Ma Tử",
    ["石矶娘娘"] = "Thạch Cơ Nương Nương",
    ["石矶"]     = "Thạch Cơ",
    ["寒天尊"]   = "Hàn Thiên Tôn",
    ["三霄娘娘"] = "Tam Tiêu Nương Nương",
    ["云霄"]     = "Vân Tiêu",
    ["碧霄"]     = "Bích Tiêu",
    ["琼霄"]     = "Quỳnh Tiêu",
    ["精卫"]     = "Tinh Vệ",
    ["孙悟空"]   = "Tôn Ngộ Không",
    ["大圣"]     = "Đại Thánh",
    ["苏妲己"]   = "Tô Đát Kỷ",
    ["妲己"]     = "Đát Kỷ",
    ["敖丙"]     = "Ngao Bính",
    ["龙太子"]   = "Long Thái Tử",
    ["洛神"]     = "Lạc Thần",
    ["紫云魔君"] = "Tử Vân Ma Quân",
    ["纣王"]     = "Trụ Vương",
}

-- =========================================================================
-- 2. CẢNH GIỚI TU LUYỆN (Cultivation realms)
-- =========================================================================
local REALMS = {
    -- Luyện Thể (7 stages)
    ["练体"]   = "Luyện Thể",
    ["通脉"]   = "Thông Mạch",
    ["锻骨"]   = "Đoán Cốt",
    ["炼腑"]   = "Luyện Phủ",
    ["元武"]   = "Nguyên Võ",
    ["神力"]   = "Thần Lực",
    ["破虚"]   = "Phá Hư",
    ["归元"]   = "Quy Nguyên",
    -- Luyện Khí (8 stages)
    ["练气"]   = "Luyện Khí",
    ["筑基"]   = "Trúc Cơ",
    ["结丹"]   = "Kết Đan",
    ["元婴"]   = "Nguyên Anh",
    ["化神"]   = "Hóa Thần",
    ["反虚"]   = "Phản Hư",
    ["合体"]   = "Hợp Thể",
    -- Modifiers
    ["初期"]   = "sơ kỳ",
    ["中期"]   = "trung kỳ",
    ["后期"]   = "hậu kỳ",
    ["问道丹劫"] = "Vấn Đạo Đan Kiếp",
}

-- =========================================================================
-- 3. PHÁP BẢO CHUYÊN CHỨC (Class-specific treasures cho 20+ nhân vật)
-- =========================================================================
local TREASURES = {
    -- 9 nhân vật của mod
    ["天逆珠"]   = "Thiên Nghịch Châu",
    ["招魂幡"]   = "Tôn Hồn Phiên",
    ["李广弓"]   = "Lý Quảng Cung",
    ["撒豆成兵"] = "Tát Đậu Thành Binh",
    ["射神战车"] = "Xạ Thần Chiến Xa",
    ["仙魔之剑"] = "Tiên Ma Chi Kiếm",
    ["无上魔体"] = "Vô Thượng Ma Thể",
    ["功德金身"] = "Công Đức Kim Thân",
    ["古神之体"] = "Cổ Thần Chi Thể",
    ["木雕师傅"] = "Mộc Điêu Sư Phó",
    ["血煞剑"]   = "Huyết Sát Kiếm",
    ["太阿剑"]   = "Thái A Kiếm",
    ["青竹凤云剑"] = "Thanh Trúc Phong Vân Kiếm",
    ["金蛟剪"]   = "Kim Giao Tiễn",
    ["指尺青箓"] = "Chỉ Thử Thanh Lục",
    ["如意金箍棒"] = "Như Ý Kim Cô Bổng",
    ["梅香如旧"] = "Mai Hương Như Cựu",
    ["养魂灵玉"] = "Dưỡng Hồn Linh Ngọc",
    ["水龙吟"]   = "Thủy Long Ngâm",
    ["龙珠"]     = "Long Châu",
    -- Vanilla characters
    ["混元斧"]   = "Hỗn Nguyên Phủ",
    ["芙蓉玄旗伞"] = "Phù Dung Huyền Kỳ Tản",
    ["焚籍"]     = "Phẫn Tịch",
    ["金鳞"]     = "Kim Lân",
    ["赤龙"]     = "Xích Long",
    ["星罗剑"]   = "Tinh La Kiếm",
    ["天翻万劫刀"] = "Thiên Phiên Vạn Kiếp Đao",
    ["青月"]     = "Thanh Nguyệt",
    ["不尽神剑"] = "Bất Tận Thần Kiếm",
    ["问世"]     = "Vấn Thế",
    ["销金赤骨刀"] = "Tiêu Kim Xích Cốt Đao",
    ["杏花微雨剑"] = "Hạnh Hoa Vi Vũ Kiếm",
    ["忘忧剑"]   = "Vong Ưu Kiếm",
    ["无相剑"]   = "Vô Tướng Kiếm",
    ["墨染"]     = "Mặc Nhiễm",
    ["毅鳞"]     = "Nghị Lân",
    ["龙魂问道珠"] = "Long Hồn Vấn Đạo Chu",
    ["天兽食原枪"] = "Thiên Thú Thực Nguyên Thương",
    ["金箍棒"]   = "Kim Cô Bổng",
    -- Skill names
    ["定身术"]   = "Định Thân Thuật",
    ["定身法"]   = "Định Thân Pháp",
    ["安身法"]   = "An Thân Pháp",
    ["铜头铁臂"] = "Đồng Đầu Thiết Tý",
    ["聚形散气"] = "Tụ Hình Tán Khí",
    ["变化之术"] = "Biến Hóa Chi Thuật",
    ["六根"]     = "Lục Căn",
    ["根气"]     = "Căn Khí",
    ["神识傀儡"] = "Thần Thức Khôi Lỗi",
    ["身外化身"] = "Thân Ngoại Hóa Thân",
    ["虚天鼎"]   = "Hư Thiên Đỉnh",
    ["三焰扇"]   = "Tam Diễm Phiến",
    ["风雷翼"]   = "Phong Lôi Dực",
    ["五子同心魔"] = "Ngũ Tử Đồng Tâm Ma",
    ["破灭法目"] = "Phá Diệt Pháp Mục",
    ["元合五极山"] = "Nguyên Hợp Ngũ Cực Sơn",
    ["玄天斩灵剑"] = "Huyền Thiên Trảm Linh Kiếm",
    ["飞剑符宝"] = "Phi Kiếm Phù Bảo",
    ["天雷子"]   = "Thiên Lôi Tử",
    ["食金虫"]   = "Thực Kim Trùng",
    ["血玉珠"]   = "Huyết Ngọc Chu",
    ["混元金斗"] = "Hỗn Nguyên Kim Đấu",
    ["复郁手杖"] = "Phức Uẩn Thủ Trượng",
    ["云幕霓裳"] = "Vân Mạc Thượng Trang",
    ["缚龙索"]   = "Phược Long Tỏa",
    ["符骨法器"] = "Phù Cốt Pháp Khí",
    ["青出于蓝"] = "Thanh Xuất Ư Lam",
    ["翠羽仙踪"] = "Thúy Vũ Tiên Tung",
    ["玄武吹箭"] = "Huyền Vũ Xuy Tiễn",
    ["井石蝎道杖"] = "Tỉnh Thạch Yết Đạo Trượng",
    ["通灵石哨"] = "Thông Linh Thạch Khiếu",
    ["枯髅山"]   = "Khô Lâu Sơn",
    ["食心坠"]   = "Thực Tâm Trụy",
    ["八卦云光法"] = "Bát Quái Vân Quang Pháp",
    ["八卦龙须法"] = "Bát Quái Long Tu Pháp",
    ["掌天瓶"]   = "Chưởng Thiên Bình",
    ["碧云童子"] = "Bích Vân Đồng Tử",
    ["彩云童子"] = "Thải Vân Đồng Tử",
    ["玄鸟"]     = "Huyền Điểu",
    ["魂狼"]     = "Hồn Lang",
    ["月华十药枝"] = "Nguyệt Hoa Thập Dược Chi",
    ["化劫尖蟒"] = "Hóa Kiếp Tiêm Mãng",
    ["精炼丹炉"] = "Tinh Tế Đan Phủ",
}

-- =========================================================================
-- 4. LINH BẢO & CÔNG TRÌNH (Sacred items, structures)
-- =========================================================================
local STRUCTURES = {
    ["天机屋"]   = "Thiên Cơ Ốc",
    ["天机卷珠"] = "Thiên Cơ Cuộn Châu",
    ["天机令牌"] = "Thiên Cơ Lệnh Bài",
    ["养魂短枪"] = "Dưỡng Hồn Đoản Thương",
    ["辟谷丹"]   = "Bích Cốc Đan",
    ["护心玉佩"] = "Hộ Tâm Ngọc Bội",
    ["灵宝祭炼台"] = "Linh Bảo Tế Luyện Đài",
    ["本源祭板"] = "Bổn Nguyên Tế Bản",
    ["焚天剑"]   = "Phẫn Thiên Kiếm",
    ["珅魂扇"]   = "Tôn Hồn Phiến",
    ["丹炉"]     = "Lò Đan",
    ["玉露玄钢"] = "Ngọc Lộ Huyền Cang",
    ["天宝壶"]   = "Thiên Bảo Hồ",
    ["玉露仙溪"] = "Ngọc Lộ Tiên Khê",
    ["祭坛"]     = "Đàn Tế",
    ["传送阵"]   = "Truyền Trận Cổ",
    ["玲珑宝箱"] = "Bảo Rương Linh Lung",
    ["慈生祠台"] = "Từ Sinh Tự Đài",
    ["昆鹏仙岛"] = "Côn Bằng Tiên Đảo",
    ["心魔"]     = "Tâm Ma",
    ["醉春烟"]   = "Túy Xuân Yên",
    ["醉梅"]     = "Túy Mai",
    ["仙鹤"]     = "Tiên Hạc",
    ["灵狐"]     = "Linh Hồ",
    ["青丘坊"]   = "Thanh Khâu Phường",
    ["妖杂魔蛛"] = "Yêu Tạp Ma Châu",
    ["魔蛛巢"]   = "Hang Ma Châu",
    ["紫云阁"]   = "Tử Vân Các",
    ["紫赤面具"] = "Mặt Nạ Tử Xích",
    ["妖煞护甲"] = "Hộ Giáp Yêu Sát",
    ["紫赤魔羽"] = "Lông Ma Tử Xích",
    -- Linh mộc
    ["沙藤树"]   = "Cây Sa Đằng",
    ["沙藤"]     = "Sa Đằng",
    ["沙藤树根"] = "Sa Đằng Thụ Căn",
    ["沙藤果"]   = "Quả Sa Đằng",
    ["返魂木"]   = "Cây Phản Hồn",
    ["返魂果"]   = "Quả Phản Hồn",
    ["复生香"]   = "Hương Phục Sinh",
    ["返魂果酱"] = "Mứt Quả Phản Hồn",
    -- Trang trí
    ["水芙蓉"]   = "Thủy Phù Dung",
    ["朝阳花"]   = "Triều Dương Hoa",
    ["白虹"]     = "Bạch Hồng",
    ["铃兰"]     = "Linh Lan",
    ["幽兰"]     = "U Lan",
    ["牡丹"]     = "Mẫu Đơn",
    ["百合"]     = "Bách Hợp",
    ["蒲公英"]   = "Bồ Công Anh",
    ["木梨花"]   = "Mộc Lê Hoa",
    ["樱花树"]   = "Cây Anh Đào",
    ["丹枫"]     = "Đan Phong",
    ["银杏"]     = "Ngân Hạnh",
    ["杏花树"]   = "Hạnh Hoa Thụ",
    ["烟柳树"]   = "Yên Liễu Thụ",
    ["蓝杉"]     = "Lam Sam",
}

-- =========================================================================
-- 5. ĐAN DƯỢC & LINH THẢO (Pills & herbs)
-- =========================================================================
local PILLS = {
    -- Đột phá đan
    ["聚气丹"]   = "Tụ Khí Đan",
    ["锻体丹"]   = "Đoán Thể Đan",
    ["筑基丹"]   = "Trúc Cơ Đan",
    ["洗髓丹"]   = "Tẩy Tủy Đan",
    ["化精丹"]   = "Hóa Tinh Đan",
    ["云中丹"]   = "Vân Trung Đan",
    ["疏脉丹"]   = "Sơ Mạch Đan",
    ["熔灵丹"]   = "Dung Linh Đan",
    ["结婴丹"]   = "Kết Anh Đan",
    ["蕴血丹"]   = "Uẩn Huyết Đan",
    ["凝神丹"]   = "Ngưng Thần Đan",
    ["化神丹"]   = "Hóa Thần Đan",
    ["回元丹"]   = "Hồi Nguyên Đan",
    ["合灵丹"]   = "Hợp Linh Đan",
    -- Hiệu ứng đan
    ["赤阳焚血丹"] = "Xích Dương Phần Huyết Đan",
    ["雷鸣杀气丹"] = "Lôi Minh Sát Khí Đan",
    ["地脉回生丹"] = "Địa Mạch Hồi Sinh Đan",
    ["清心洗魂丹"] = "Thanh Tâm Tẩy Hồn Đan",
    ["御风神行丹"] = "Ngự Phong Thần Hành Đan",
    ["磐石护身丹"] = "Bàn Thạch Hộ Thân Đan",
    ["天机巧手丹"] = "Thiên Cơ Xảo Thủ Đan",
    ["玄阳暖玉丹"] = "Huyền Dương Noãn Ngọc Đan",
    ["寒髓避火丹"] = "Hàn Tủy Tỵ Hỏa Đan",
    ["血淡元丹"]   = "Huyết Đạm Nguyên Đan",
    ["逝子返魂丹"] = "Thế Tử Phản Hồn Đan",
    ["废丹"]       = "Phế Đan",
    -- Linh thảo
    ["赤阳花"]   = "Xích Dương Hoa",
    ["霜寒草"]   = "Sương Hàn Thảo",
    ["雷鸣谷"]   = "Lôi Minh Cốc",
    ["清风蕖"]   = "Thanh Phong Tụ",
    ["地脉参"]   = "Địa Mạch Tham",
    ["幽魂花"]   = "U Hồn Hoa",
    ["玄魂花"]   = "Huyền Hồn Hoa",
}

-- =========================================================================
-- 6. VẬT PHẨM & TÀI NGUYÊN (Items, materials)
-- =========================================================================
local ITEMS = {
    -- Linh thạch
    ["下品灵石"]   = "Hạ Phẩm Linh Thạch",
    ["中品灵石"]   = "Trung Phẩm Linh Thạch",
    ["上品灵石"]   = "Thượng Phẩm Linh Thạch",
    ["极品灵石"]   = "Cực Phẩm Linh Thạch",
    ["灵石"]       = "Linh Thạch",
    ["灵草"]       = "Linh Thảo",
    ["丹药"]       = "Đan Dược",
    -- Bảo thạch
    ["红宝石"]     = "Hồng Bảo Thạch",
    ["蓝宝石"]     = "Lam Bảo Thạch",
    ["绿宝石"]     = "Lục Bảo Thạch",
    ["紫宝石"]     = "Tử Bảo Thạch",
    ["橙宝石"]     = "Cam Bảo Thạch",
    ["黄宝石"]     = "Hoàng Bảo Thạch",
    ["彩虹宝石"]   = "Bảo Thạch Cầu Vồng",
    -- Nguyên liệu
    ["紫煞魔羽"]   = "Tử Sát Ma Vũ",
    ["邪煞步族"]   = "Tà Sát Bộ Túc",
    ["魔怪钳骨"]   = "Ma Quái Kiềm Cốt",
    ["灵狐尾"]     = "Đuôi Linh Hồ",
    ["羽毛碎片"]   = "Lông Vũ Mảnh",
    ["凤髓"]       = "Phượng Tủy",
    ["麒麟角"]     = "Sừng Kỳ Lân",
    ["金锦虎皮"]   = "Da Hổ Gấm",
    ["金"]         = "Vàng",
    ["纸"]         = "Giấy",
    ["猴毛"]       = "Râu khỉ",
    -- Yêu thú boss
    ["太古异兽"]   = "Thái Cổ Dị Thú",
    ["金凤神念"]   = "Kim Phượng Thần Niệm",
    ["残魂麒麟"]   = "Tàn Hồn Kỳ Lân",
    ["残神白虎"]   = "Tàn Thần Bạch Hổ",
    ["邪煞纣王"]   = "Tà Sát Chu Vương",
    ["魔将蒲牢"]   = "Ma Tướng Phù Đồ",
    ["麒麟"]       = "Kỳ Lân",
    ["白虎"]       = "Bạch Hổ",
    ["金凤"]       = "Kim Phượng",
    ["朱雀"]       = "Chu Điểu",
    ["火灵"]       = "Hỏa Tinh",
    ["灵矿魔影"]   = "Linh Khoáng Ma Ảo",
}

-- =========================================================================
-- Apply to lookup tables
-- =========================================================================
local function merge(map, label)
    local n = 0
    for cn, vn in pairs(map) do
        textfix[cn] = vn
        word_fix[cn] = vn
        n = n + 1
    end
    return n
end

local n_chars  = merge(CHARACTERS, "characters")
local n_realms = merge(REALMS, "realms")
local n_treas  = merge(TREASURES, "treasures")
local n_struct = merge(STRUCTURES, "structures")
local n_pills  = merge(PILLS, "pills")
local n_items  = merge(ITEMS, "items")

rawset(_G, "dangtien_viet_glossary", {
    characters = CHARACTERS,
    realms     = REALMS,
    treasures  = TREASURES,
    structures = STRUCTURES,
    pills      = PILLS,
    items      = ITEMS,
})

print(string.format(
    "[DangTienVN] Glossary loaded: %d chars / %d realms / %d treasures / %d structs / %d pills / %d items = %d total",
    n_chars, n_realms, n_treas, n_struct, n_pills, n_items,
    n_chars + n_realms + n_treas + n_struct + n_pills + n_items
))

-- Dynamic UI text caught by MISSING logger.
-- Adds: word_fix substring entries + textfix_patterns for format strings.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local textfix = rawget(_G, "dangtien_viet_textfix") or {}
local word_fix = rawget(_G, "dangtien_viet_word_fix") or {}
local textfix_patterns = rawget(_G, "dangtien_viet_textfix_patterns") or {}

-- =========================================================================
-- Format-string patterns (Lua byte-based — Chinese chars are 3-byte UTF-8)
-- =========================================================================
table.insert(textfix_patterns, {"(%d+%.?%d*)秒", "%1 giây"})
table.insert(textfix_patterns, {"(%d+%.?%d*)天", "%1 ngày"})
table.insert(textfix_patterns, {"(%d+%.?%d*)分钟", "%1 phút"})
table.insert(textfix_patterns, {"(%d+%.?%d*)小时", "%1 giờ"})
table.insert(textfix_patterns, {"(%d+%.?%d*)点", "%1 điểm"})
table.insert(textfix_patterns, {"砍%((%d+)%)", "Chặt(%1)"})
table.insert(textfix_patterns, {"挖%((%d+)%)", "Đào(%1)"})
table.insert(textfix_patterns, {"敲%((%d+)%)", "Đập(%1)"})
table.insert(textfix_patterns, {"凿%((%d+)%)", "Đục(%1)"})
table.insert(textfix_patterns, {"装饰度%((%d+)%)", "Trang trí(%1)"})
table.insert(textfix_patterns, {"心魔值[:：]%s*(%d+)", "Giá trị Tâm Ma: %1"})
table.insert(textfix_patterns, {"耐久:%s*", "Độ bền: "})
table.insert(textfix_patterns, {"耐久度:%s*", "Độ bền: "})
table.insert(textfix_patterns, {"第(%d+)层", "Tầng %1"})
table.insert(textfix_patterns, {"一层", "tầng 1"})
table.insert(textfix_patterns, {"二层", "tầng 2"})
table.insert(textfix_patterns, {"三层", "tầng 3"})
table.insert(textfix_patterns, {"四层", "tầng 4"})
table.insert(textfix_patterns, {"五层", "tầng 5"})
table.insert(textfix_patterns, {"六层", "tầng 6"})
table.insert(textfix_patterns, {"七层", "tầng 7"})
table.insert(textfix_patterns, {"八层", "tầng 8"})
table.insert(textfix_patterns, {"九层", "tầng 9"})
table.insert(textfix_patterns, {"十层", "tầng 10"})

-- =========================================================================
-- Substring word_fix — dùng cho compound dynamic strings
-- =========================================================================
local SUBS = {
    -- Common UI fragments
    ["系列隐藏皮肤"] = " (skin ẩn)",
    ["系列皮肤"] = " (skin)",
    ["属于赞助获得皮肤"] = "thuộc loại skin tài trợ",
    ["属于什色录礼包皮肤"] = "thuộc gói quà Thập Sắc Lục",
    ["属于"] = "thuộc loại ",
    ["皮肤"] = "skin",
    ["此物炼制之法，尚未参透。"] = "Phương pháp luyện chế vật này, ta chưa thấu triệt.",
    ["因皮肤同步方式调整"] = "Do cách đồng bộ skin được điều chỉnh",
    ["服务器列表搜索登仙并进入对应服务器"] = "tìm \"登仙\" trong danh sách server và vào đúng server",
    ["即可同步刷新保存您已有的所有皮肤"] = "để đồng bộ và lưu lại toàn bộ skin bạn đang có",
    ["即可同步刷新保存您已有的所有皮肤。"] = "để đồng bộ và lưu lại toàn bộ skin bạn đang có.",
    ["魔杖一挥，樱花纷飞。"] = "Vẫy ma trượng, hoa anh đào tung bay.",

    -- Verbs / common terms
    ["收获"] = "Thu hoạch",
    ["种植"] = "Trồng",
    ["播种"] = "Gieo hạt",
    ["施法"] = "Thi pháp",
    ["切换"] = "Đổi",
    ["关闭"] = "Đóng",
    ["打开"] = "Mở",
    ["进入"] = "Vào",
    ["离开"] = "Rời khỏi",
    ["使用"] = "Sử dụng",
    ["收回"] = "Thu hồi",
    ["召唤"] = "Triệu hồi",
    ["激活"] = "Kích hoạt",
    ["祭炼"] = "Tế luyện",
    ["温养"] = "Ôn dưỡng",
    ["填充"] = "Lấp đầy",
    ["修复"] = "Sửa chữa",
    ["遁走"] = "Độn tẩu",

    -- Stats / status
    ["饱食度"] = "No bụng",
    ["精神"] = "Tinh thần",
    ["生命"] = "Máu",
    ["血量"] = "Máu",
    ["理智"] = "Lý trí",
    ["饱腹"] = "No",
    ["护甲"] = "Giáp",
    ["攻击"] = "Tấn công",
    ["防御"] = "Phòng ngự",
    ["移速"] = "Tốc độ",
    ["伤害"] = "Sát thương",
    ["减伤"] = "Giảm sát thương",
    ["保暖"] = "Giữ ấm",
    ["隔热"] = "Cách nhiệt",
    ["防水"] = "Chống nước",
    ["新鲜"] = "Tươi",
    ["腐烂"] = "Thối",

    -- Realms (mod dùng 前期/中期/后期 chứ không phải 初期)
    ["前期"] = " sơ kỳ",
    ["中期"] = " trung kỳ",
    ["后期"] = " hậu kỳ",
    ["巅峰"] = " đỉnh phong",
    ["大圆满"] = " đại viên mãn",
    ["解锁"] = "mở khoá",
    ["未解锁"] = "chưa mở khoá",
    ["已解锁"] = "đã mở khoá",
    ["炼气"] = "Luyện Khí",
    ["炼体"] = "Luyện Thể",
    ["筑基"] = "Trúc Cơ",
    ["结丹"] = "Kết Đan",
    ["元婴"] = "Nguyên Anh",
    ["化神"] = "Hoá Thần",
    ["反虚"] = "Phản Hư",
    ["合体"] = "Hợp Thể",
    ["通脉"] = "Thông Mạch",
    ["锻骨"] = "Đoán Cốt",
    ["炼腑"] = "Luyện Phủ",
    ["元武"] = "Nguyên Võ",
    ["神力"] = "Thần Lực",
    ["破虚"] = "Phá Hư",
    ["归元"] = "Quy Nguyên",
    ["魂灵"] = "Hồn Linh",
    ["魂魄"] = "Hồn phách",
    ["元神"] = "Nguyên Thần",

    -- Cultivation
    ["灵力"] = "Linh lực",
    ["灵气"] = "Linh khí",
    ["神识"] = "Thần thức",
    ["法力"] = "Pháp lực",
    ["神通"] = "Thần thông",
    ["灵技"] = "Linh kỹ",
    ["奇术"] = "Kỳ thuật",
    ["突破"] = "Đột phá",
    ["渡劫"] = "Độ kiếp",
    ["法宝"] = "Pháp bảo",
    ["灵宝"] = "Linh bảo",
    ["灵石"] = "Linh thạch",
    ["丹药"] = "Đan dược",
    ["灵草"] = "Linh thảo",
    ["仙途"] = "Tiên Đồ",

    -- Materials
    ["羽毛"] = "Lông",
    ["木头"] = "Gỗ",
    ["木材"] = "Gỗ",
    ["石头"] = "Đá",
    ["燧石"] = "Đá lửa",
    ["丝线"] = "Tơ",
    ["蜘蛛丝"] = "Tơ nhện",
    ["蜘蛛腺"] = "Hạch nhện",

    -- Tu tiên mật quyển / item info labels (must come BEFORE single chars below)
    ["放热:"] = "Tỏa nhiệt: ",
    ["放热："] = "Tỏa nhiệt: ",
    ["工具:"] = "Công cụ: ",
    ["工具："] = "Công cụ: ",
    ["攻击距离:"] = "Tầm tấn công: ",
    ["攻击距离："] = "Tầm tấn công: ",
    ["位面伤害:"] = "Sát thương vị diện: ",
    ["位面伤害："] = "Sát thương vị diện: ",
    ["品阶:"] = "Phẩm cấp: ",
    ["品阶："] = "Phẩm cấp: ",
    ["基础神通:"] = "Thần thông cơ bản: ",
    ["基础神通："] = "Thần thông cơ bản: ",
    ["娴熟:"] = "Thuần thục: ",
    ["娴熟："] = "Thuần thục: ",
    ["叠加:"] = "Cộng dồn: ",
    ["叠加："] = "Cộng dồn: ",
    ["新鲜度:"] = "Độ tươi: ",
    ["新鲜度："] = "Độ tươi: ",
    ["剩余天数:"] = "Số ngày còn lại: ",
    ["剩余天数："] = "Số ngày còn lại: ",
    ["心魔值:"] = "Giá trị Tâm Ma: ",
    ["心魔值："] = "Giá trị Tâm Ma: ",
    ["距离:"] = "Khoảng cách: ",
    ["距离："] = "Khoảng cách: ",

    -- Realm levels
    ["凡级"] = "Cấp Phàm",
    ["仙级"] = "Cấp Tiên",
    ["神级"] = "Cấp Thần",
    ["玄级"] = "Cấp Huyền",
    ["地级"] = "Cấp Địa",
    ["天级"] = "Cấp Thiên",
    ["黄级"] = "Cấp Hoàng",

    -- Common phrases in cultivation manual
    ["强大怪物蕴藏的"] = "Của quái vật mạnh ẩn chứa ",
    ["都在里面了"] = " đều ở trong đó",
    ["需要达到"] = "Cần đạt đến ",
    ["期才能驾驭这"] = " kỳ mới có thể điều khiển ",
    ["玄宝"] = "huyền bảo",
    ["猎犬"] = "Liệp khuyển",
    ["帮助修士进行战斗"] = "trợ giúp tu sĩ chiến đấu",
    ["每次撕咬"] = "mỗi lần cắn xé ",
    ["增加"] = "tăng ",
    ["位面"] = "Vị diện",
    ["距离"] = "Khoảng cách",
    ["放热"] = "Tỏa nhiệt",
    ["工具"] = "Công cụ",
    ["品阶"] = "Phẩm cấp",
    ["娴熟"] = "Thuần thục",
    ["叠加"] = "Cộng dồn",
    ["新鲜度"] = "Độ tươi",
    ["剩余天数"] = "Số ngày còn lại",

    -- Cooldown messages
    ["冷却中"] = "Đang hồi chiêu",
    ["冷却时间"] = "Thời gian hồi chiêu",
    ["冷却"] = "Hồi chiêu",
    ["剩余"] = "Còn lại",
    ["还剩"] = "Còn",
    ["持续时间"] = "Thời gian duy trì",
    ["持续"] = "Duy trì",
}

for cn, vn in pairs(SUBS) do
    word_fix[cn] = vn
end

-- =========================================================================
-- Exact-match dynamic strings từ MISSING log
-- =========================================================================
local EXACT = {
    ["此物炼制之法，尚未参透。"] = "Phương pháp luyện chế vật này, ta chưa thấu triệt.",
    ["因皮肤同步方式调整"] = "Do cách đồng bộ skin được điều chỉnh",
    ["服务器列表搜索登仙并进入对应服务器"] = "Tìm \"登仙\" trong danh sách server và vào đúng server",
    ["即可同步刷新保存您已有的所有皮肤。"] = "Để đồng bộ và lưu lại toàn bộ skin bạn đang có.",
    ["耐久:"] = "Độ bền:",
    ["耐久度:"] = "Độ bền:",
    ["巨龙头颅低垂，龙身盘踞成台"] = "Đầu rồng khổng lồ cúi thấp, thân rồng cuộn tròn thành đài",
}
for cn, vn in pairs(EXACT) do
    textfix[cn] = vn
end

print("[DangTienVN] Dynamic textfix loaded: " .. tostring(#textfix_patterns)
      .. " patterns + word_fix subs.")

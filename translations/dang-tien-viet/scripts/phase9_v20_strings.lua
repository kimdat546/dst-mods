-- Phase 9: chuỗi mới của mod gốc 【登仙】 v20.0 (đo 2026-10-15).
--
-- Gồm:
--   1. Nhân vật mới 古月方源 Cổ Nguyệt Phương Nguyên (Cổ sư, từ truyện 蛊真人)
--      — cổ trùng, Vạn Cổ Ốc, Thiên Nguyên Bảo Liên, Định Tiên Du...
--   2. Món ăn hồi phục mới: cỏ Sinh Cơ, canh lá Sinh Cơ, bánh Cửu Diệp Sinh Cơ
--   3. Pháp bảo Vạn Ngã Quy Nhất, nhãn menu mới
--
-- Quy ước như phase6: tên cổ trùng/pháp bảo giữ Hán-Việt (đúng tên trong
-- bản dịch truyện Cổ Chân Nhân); món ăn thường dùng tiếng Việt.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)
local set_str = rawget(_G, "dangtien_viet_set_str")
if not set_str then return end

local s = set_str

-- =========================================================================
-- 1. Cổ Nguyệt Phương Nguyên — tên vật phẩm
-- =========================================================================
local N = "STRINGS.NAMES."
s(N .. "XD_GYFY_WGW",           "Vạn Cổ Ốc")
s(N .. "XD_GYFY_GU_JLDMG",      "Tiêu Lôi Đậu Mẫu Cổ")
s(N .. "XD_GYFY_GU_JLDMG_MINE", "Tiêu Lôi Đậu Mẫu Cổ")
s(N .. "XD_GYFY_WZN",           "Vô Túc Điểu")
s(N .. "XD_GYFY_DXY",           "Định Tiên Du")
s(N .. "XD_GYFY_TYBLXG",        "Thiên Nguyên Bảo Liên Tiên Cổ")
s(N .. "XD_GYFY_BAOLIAN",       "Thiên Nguyên Bảo Liên")
s(N .. "XD_GYFY_YYG",           "Diệu Dực Cổ")
s(N .. "XD_GYFY_QXLJG",         "Thanh Tê Liệt Giáp Cổ")
s(N .. "XD_GYFY_FYJJF",         "Phi Dực Kim Cức Phong")

-- Thiên Nguyên Bảo Liên lên cấp theo bậc. Bảng mảng chỉ số số nguyên, nên
-- không đi qua set_str được (set_str sẽ ghi vào khoá chuỗi "1").
if type(STRINGS.XD_GYFY_BAOLIAN_NAMES) == "table" then
    local names = {
        "Thiên Nguyên Bảo Liên",
        "Thiên Nguyên Bảo Liên",
        "Thiên Nguyên Bảo Quân Liên",
        "Thiên Nguyên Bảo Vương Liên",
        "Thiên Nguyên Bảo Hoàng Liên",
    }
    for i, v in ipairs(names) do STRINGS.XD_GYFY_BAOLIAN_NAMES[i] = v end
end

-- =========================================================================
-- 2. Món ăn / pháp bảo mới
-- =========================================================================
s(N .. "XD_SHENGJICAO",          "Cỏ Sinh Cơ")
s(N .. "XD_SHENGJIYEGENG",       "Canh lá Sinh Cơ")
s(N .. "XD_SHENGJIYEGENG_BUFF",  "Canh lá Sinh Cơ")
s(N .. "XD_JIUYESHENGJIGAO",      "Bánh Cửu Diệp Sinh Cơ")
s(N .. "XD_JIUYESHENGJIGAO_BUFF", "Bánh Cửu Diệp Sinh Cơ")
s(N .. "XD_WWGY",                "Vạn Ngã Quy Nhất")

-- =========================================================================
-- 3. Mô tả khi inspect
-- =========================================================================
local D = "STRINGS.CHARACTERS.GENERIC.DESCRIBE."
s(D .. "XD_GYFY_WGW",           "Huyền ốc thâm u, khoá giữ vạn cổ.")
s(D .. "XD_GYFY_GU_JLDMG",      "Đậu trông tầm thường, nổ ra kinh thiên.")
s(D .. "XD_GYFY_GU_JLDMG_MINE", "Đậu trông tầm thường, nổ ra kinh thiên.")
s(D .. "XD_GYFY_WZN",           "Không chân chẳng đậu, ngừng bay là chết.")
s(D .. "XD_GYFY_DXY",           "Tâm niệm vừa tới, ba hơi đã đến.")
s(D .. "XD_GYFY_TYBLXG",        "Có thể trồng thành Thiên Nguyên Bảo Liên.")
s(D .. "XD_GYFY_BAOLIAN",       "Hội tụ nguyên khí trời đất.")
s(D .. "XD_GYFY_YYG",           "Cổ trùng loại tấn công.")
s(D .. "XD_GYFY_QXLJG",         "Cổ trùng loại tấn công.")
s(D .. "XD_GYFY_FYJJF",         "Cổ trùng loại hồi phục.")
s(D .. "XD_SHENGJICAO",         "Một nhánh cỏ biếc, sinh cơ ngầm chứa. Bẻ lá làm thuốc, cây khô gặp xuân.")
s(D .. "XD_SHENGJIYEGENG",      "Lá biếc chìm nổi như phỉ thuý thả vào canh, Cổ sư trị thương luôn mang theo.")
s(D .. "XD_JIUYESHENGJIGAO",    "Chín lá ngưng biếc, sinh cơ ẩn trong. Một miếng vào bụng, như tắm gió xuân.")
s(D .. "XD_WWGY",               "Khi vạn ngã quy nhất, đại đạo có thể mong.")

-- =========================================================================
-- 4. Mô tả công thức
-- =========================================================================
local R = "STRINGS.RECIPE_DESC."
s(R .. "XD_GYFY_GU_JLDMG", "Đậu trông tầm thường, nổ ra kinh thiên.")
s(R .. "XD_GYFY_WZN",      "Không chân chẳng đậu, ngừng bay là chết.")
s(R .. "XD_GYFY_DXY",      "Tâm niệm vừa tới, ba hơi đã đến.")
s(R .. "XD_GYFY_TYBLXG",   "Có thể trồng thành Thiên Nguyên Bảo Liên.")

-- =========================================================================
-- 5. Hành động và nhãn menu
-- =========================================================================
s("STRINGS.ACTIONS.DEPLOY.XD_GYFY_GU_JLDMG", "Bố trí")
s("STRINGS.ACTIONS.GIVE.XD_GYFY_BAOLIAN",    "Cho ăn")

local U = "STRINGS.XD_USE_INVENTORY."
s(U .. "GYFY_WZN",  "Điều khiển")
s(U .. "GYFY_DXY",  "Ngao du")
s(U .. "CUSTOMIZE", "Tự chọn trang bị")

-- =========================================================================
-- 6. Chuỗi CHỈ lộ ra khi chạy thật (đăng ký từ file mã hoá của mod gốc),
--    tìm bằng selftest.lua trên dedicated server headless, 2026-10-15.
-- =========================================================================
s("STRINGS.ACTIONS.XD_LUOSHEN_YIN_MAP.GYFY_WZN",      "Điều khiển")
s("STRINGS.ACTIONS.XD_LUOSHEN_YIN_MAP.GYFY_DXY",      "Ngao du")
s("STRINGS.ACTIONS.XD_LUOSHEN_YIN_MAP.CUSTOMIZE",     "Tự chọn trang bị")
s("STRINGS.ACTIONS.XD_LUOSHEN_YIN_MAP.GYFY_KONGQIAO", "Cất vào Tiên Khiếu")
s("STRINGS.ACTIONS.XD_GYFY_WZN_MAP",                  "Hạ xuống")

-- Màn chọn nhân vật
s(N .. "XD_GYFY",                                 "Cổ Nguyệt Phương Nguyên")
s("STRINGS.CHARACTER_NAMES.xd_gyfy",              "Cổ Nguyệt Phương Nguyên")
s("STRINGS.CHARACTER_TITLES.xd_gyfy",             "Đại Ái Tiên Tôn")
s("STRINGS.CHARACTER_QUOTES.xd_gyfy",             "\"Chẳng qua chỉ là chút gió sương mà thôi.\"")
s("STRINGS.CHARACTER_SURVIVABILITY.xd_gyfy",      "Cửu tử nhất sinh")
s("STRINGS.CHARACTER_DESCRIPTIONS.xd_gyfy",
  "*Chủ nhân Xuân Thu Thiền\n*Cửu chuyển Cổ Tiên\n*Minh chủ Thiên Địa Nhất Gia Đại Ái Minh")

-- Cổ trùng: tên / công thức / mô tả
local GU = {
    -- key, tên, mô tả công thức, mô tả inspect (nil = trùng công thức)
    { "DSH",   "Đâu Suất Hoa",             "Trong nụ hoa, riêng có động thiên." },
    { "JYSJC", "Cửu Diệp Sinh Cơ Thảo",    "Chín lá biếc, sinh cơ ngầm chứa." },
    { "YMG",   "Nguyệt Mang Cổ",           "Nguyệt hoa như lưỡi đao, hàn quang lộ rõ." },
    { "ZHG",   "Trí Tuệ Cổ",               "Mất máu để mở khoá một phần khoa kỹ.",
               "Lấy thọ làm củi, đốt lửa trí tuệ, soi thấu sơ hở của vạn sự vạn vật." },
    { "HTG",   "Hoả Thán Cổ",              "Thân giấu lửa than, đêm lạnh tự ấm." },
    { "JCG",   "Kiên Trì Cổ",              "Lòng đã hướng về, ngược dòng chẳng lùi." },
    { "TTC",   "Khiêu Khiêu Thảo",         "Một bước giẫm lò xo cỏ, thoắt cái mất dạng." },
    { "TPG",   "Thiên Bồng Cổ",            "Sức nhu của nước, hộ thân vô hình." },
    { "SZG",   "Thuỷ Tráo Cổ",             "Sức nhu của nước, hộ thân vô hình." },
    { "BYG",   "Bạch Ngọc Cổ",             "Nguyệt hoa như lưỡi đao, hàn quang lộ rõ." },
    { "LYG",   "Lôi Dực Cổ",               "Sấm sét hoá cánh, chớp mắt nghìn dặm." },
    { "XYG",   "Huyết Nguyệt Cổ",          "Nguyệt mang cắn địch, huyết khí dưỡng thân." },
    { "XGG",   "Tiểu Quang Cổ",            "Một điểm tinh mang, ánh sáng sinh từ lòng bàn tay." },
    { "XQG",   "Huyết Khí Cổ",             "Máu dâng khí động, cây khô gặp xuân." },
    { "ZZXTG", "Chí Tôn Tiên Thai Cổ",     "Giới hạn no bụng, tinh thần, máu đều tăng 125 điểm." },
    { "CQC",   "Xuân Thu Thiền",           "Khi chịu đòn chí mạng thì sống lại tại chỗ, hồi đầy cả ba chỉ số." },
    { "YGG",   "Nguyệt Quang Cổ",          "Ánh trăng như đao, chém sạch tà ma." },
    { "FDC",   "Phạn Đại Thảo",            "Trong túi cỏ, hương cơm tự đến." },
    { "GSYG",  "Cẩu Thỉ Vận Cổ",           "Vận may vô thường, giẫm trúng chính là phúc." },
    { "DTREC", "Địa Thính Nhục Nhĩ Thảo",  "Nghe khắp bốn phương dưới đất, phải bỏ một tai." },
    { "MDG",   "Mộng Điệp Cổ",             "Trốn vào cõi mộng, để ác mộng hành động thay mình.",
               "Bướm vào mộng sâu, nhìn thấu thiên cơ." },
}
for _, g in ipairs(GU) do
    local key = "XD_GYFY_GU_" .. g[1]
    s(N .. key, g[2])
    s(R .. key, g[3])
    s(D .. key, g[4] or g[3])
    -- mod gốc chép cùng câu vào thoại riêng của Phương Nguyên lúc chạy
    s("STRINGS.CHARACTERS.XD_GYFY.DESCRIBE." .. key, g[4] or g[3])
end

-- Skin mới (Phương Nguyên + đồ của nhân vật cũ)
local K, SD, SQ = "STRINGS.SKIN_NAMES.", "STRINGS.SKIN_DESCRIPTIONS.", "STRINGS.SKIN_QUOTES."
s(K .. "xd_gyfy_none",                 "Cổ Nguyệt Phương Nguyên")
s(K .. "xd_gyfy_zljz",                 "Chướng Lâm Quân Tử")
s(SD .. "xd_gyfy_zljz",                "Lấy rừng chướng khí làm áo, lấy tiếng cổ trùng làm lễ.")
s(SQ .. "xd_gyfy_zljz",                "Chớ vội, đợi ta ngửi mùi cổ trong gió đã, rồi tiễn ngươi lên đường.")
s(K .. "xd_hantianzun_xyhk",           "Nhàn Vân Hải Khách")
s(SD .. "xd_hantianzun_xyhk",          "Khổ tu nghìn năm, khó được một ngày thanh nhàn.")
s(SQ .. "xd_hantianzun_xyhk",          "Gió cả vùng biển này đủ thổi tan nửa đời mỏi mệt.")
s(K .. "xd_qljq_skins_hdcm",           "Hải Đăng Trường Minh")
s(SD .. "xd_qljq_skins_hdcm",          "Một ngọn đèn soi đêm, vạn con sóng về bến.")
s(K .. "xd_skin_ps",                   "Phá Tiêu")
s(SD .. "xd_skin_ps",                  "Phá Tiêu")
s(K .. "xd_skin_tblj",                 "Điềm Băng Lệ Kiếm")
s(SD .. "xd_skin_tblj",                "Điềm Băng Lệ Kiếm")
s(K .. "xd_backpack3_skin7",           "Cửu Vĩ")
s(K .. "xd_tree_ls_skins_yrzd",        "Dừa Nhiên Tự Đắc")
s(SD .. "xd_tree_ls_skins_yrzd",       "Nơi bóng dừa lay động, chính là chốn an lòng.")
s(K .. "xd_liandanlu_skins_qxdt",      "Thấm Tuyết Đan Đài")
s(SD .. "xd_liandanlu_skins_qxdt",     "Sắc sương làm chén, vị ngọt làm đan.")
s(K .. "xd_flower_pgy_skins_flqr",     "Phù Lạp Khinh Nhung")
s(SD .. "xd_flower_pgy_skins_flqr",    "Một nón nổi giữa hè, vạn sợi bông cưỡi gió.")
s(K .. "xd_hyc_skins_xyc",             "Hồ Vui Chơi")
s(SD .. "xd_hyc_skins_xyc",            "Phao bơi bóng màu, che nắng nghịch nước.")
s(K .. "xd_skin_jzlz",                 "Quân Tử Linh Trượng")
s(SD .. "xd_skin_jzlz",                "Quân Tử Linh Trượng")
s(K .. "xd_zzxhcx_skins_hwxq",         "Ổ Lửng Chợp Mắt")
s(SD .. "xd_zzxhcx_skins_hwxq",        "Rêu chưa quét, vừa hay đánh một giấc.")

-- =========================================================================
-- 7. Thoại Vương Ma Tử còn sót: mod gốc chèn lúc chạy, không có trong file
--    speech nên bản dịch phase3 không thấy. Giữ giọng "Vương Mỗ" kiêu ngạo.
-- =========================================================================
local W = "STRINGS.CHARACTERS.XD_WANGMAZI.DESCRIBE."
s(W .. "BERRYBUSH_JUICY.DISEASED",       "Bệnh khí xâm thực, sinh cơ dần mất.")
s(W .. "BERRYBUSH.DISEASED",             "Bụi này đã nhiễm bệnh, e khó kết trái.")
s(W .. "BASALT",                         "Đá này cứng hơn tinh thiết, sức người không phá nổi.")
s(W .. "WAGPUNKBITS_KIT",                "Máy tự sửa, khéo vượt trời đất.")
s(W .. "WAGPUNKHAT",                     "Mũ bánh răng, dẫn động chân nguyên.")
s(W .. "BIGFOOT",                        "Hừ, chẳng qua là yêu quái núi rừng, cũng xứng hiện hình trước mặt Vương Mỗ sao?")
s(W .. "WAGSTAFF_MUTATIONS_NOTE",        "Ghi chép biến dị, huyền diệu phi thường.")
s(W .. "ARMORWAGPUNK",                   "Chiến giáp cơ giới, xem ra chẳng phải vật tầm thường.")
s(W .. "ARCHIVE_ORCHESTRINA_MAIN",       "Âm luật viễn cổ, ẩn chứa huyền cơ.")
s(W .. "RECORD_WORKTOBEDONE",            "Khúc nhạc dở dang, còn chờ hoàn thiện.")
s(W .. "RECORD_MAIN",                    "Giai điệu chủ, khí thế hùng tráng.")
s(W .. "RECORD_EFS",                     "Âm luật huyền diệu, chẳng tầm thường.")
s(W .. "RECORD_DRSTYLE",                 "Âm luật dị vực, riêng một phong vị.")
s(W .. "RECORD_CREEPYFOREST",            "Tiếng âm u rừng sâu, sát khí bức người.")
s(W .. "RECORD",                         "Vật mang âm luật, giữ được diệu âm.")
s(W .. "PHONOGRAPH",                     "Nhạc cụ phàm gian, chẳng có gì lạ.")
s(W .. "DECOR_PORTRAITFRAME",            "Chân dung phàm tục, khó vào nơi thanh nhã.")
s(W .. "DECOR_LAMP",                     "Một ngọn đèn bàn, chiếu sáng mà thôi.")
s(W .. "RECORD_DUSK",                    "Tiếng hoàng hôn, mộ khí nặng nề.")
s(W .. "FENCE_ROTATOR",                  "Xoay hàng rào, chỉnh lại trận thế.")
s(W .. "RECORD_END",                     "Khúc cuối, dư âm kéo dài.")
s(W .. "DECOR_CENTERPIECE",              "Đồ bày trên bàn, để trang trí.")
s(W .. "WAGSTAFF_MACHINERY",             "Cơ quan bỏ phế, có lẽ còn dùng lại được.")
s(W .. "RECORD_DAWN",                    "Tiếng bình minh, sinh cơ dạt dào.")
s(W .. "WOOD_CHAIR.GENERIC",             "Ghế gỗ phàm phẩm, miễn cưỡng ngồi được.")
s(W .. "WOOD_CHAIR.BURNT",               "Ghế cháy sém, đã vô dụng.")
s(W .. "WOOD_CHAIR.OCCUPIED",            "Đã có kẻ khác ngồi rồi.")
s(W .. "DECOR_PICTUREFRAME.GENERIC",     "Khung tranh tinh xảo, có thể lồng đan thanh.")
s(W .. "DECOR_PICTUREFRAME.UNDRAWN",     "Khung trắng trơn, chờ tác phẩm hay.")
s(W .. "DECOR_FLOWERVASE.GENERIC",       "Bình hoa thanh nhã, có thể cắm linh hoa.")
s(W .. "DECOR_FLOWERVASE.EMPTY",         "Bình trống chờ hoa, lặng đợi giai huệ.")
s(W .. "DECOR_FLOWERVASE.OLDLIGHT",      "Quang hoa dần tắt, cần thay nhụy mới.")
s(W .. "DECOR_FLOWERVASE.WILTED",        "Hoa tàn lá úa, cần thay cành mới.")
s(W .. "DECOR_FLOWERVASE.FRESHLIGHT",    "Linh hoa vừa nở, quang hoa lưu chuyển.")
s(W .. "RECORD_DANGER",                  "Tiếng hung hiểm, không nên nghe nhiều.")
s(W .. "BEEMINE_MAXWELL",                "Cơ quan tinh xảo, tổ ong thường sao sánh được.")
s(W .. "WAGPUNK_BITS",                   "Linh kiện cơ giới, còn cần mài giũa.")
-- Bảng DESCRIBE[1] (bàn mộc) dùng khoá số, set_str không với tới được.
do
    local t = STRINGS.CHARACTERS.XD_WANGMAZI
    t = t and t.DESCRIBE and t.DESCRIBE[1]
    if type(t) == "table" then
        t.GENERIC  = "Xưởng mộc phàm gian, làm được đồ gỗ tầm thường."
        t.BURNT    = "Bị lửa thiêu huỷ, đã vô dụng."
        t.HAS_ITEM = "Nguyên liệu đã đủ, có thể thi công."
    end
end

-- =========================================================================
-- 8. Giao diện Tiên Khiếu (lắp cổ trùng) và đếm hồi chiêu — mod gốc ghép
--    chuỗi trực tiếp, không qua STRINGS. Bắt bằng log MISSING_CN khi chơi
--    thật, 2026-10-15.
-- =========================================================================
local textfix  = rawget(_G, "dangtien_viet_textfix")
local word_fix = rawget(_G, "dangtien_viet_word_fix")
local patterns = rawget(_G, "dangtien_viet_textfix_patterns")
if textfix and word_fix and patterns then
    textfix["仙窍"]                     = "Tiên Khiếu"
    textfix["关闭仙窍界面"]             = "Đóng giao diện Tiên Khiếu"
    textfix["选择下方蛊虫后点击仙窍装配"] = "Chọn cổ trùng bên dưới rồi bấm vào Tiên Khiếu để lắp"
    textfix["仙窍已经存在该蛊虫了"]     = "Tiên Khiếu đã có cổ trùng này rồi"
    textfix["月亮石"]                   = "Đá Mặt Trăng"
    textfix["海象营地"]                 = "Trại Hải Tượng"

    -- Tên cổ trùng hiện trần trong ô Tiên Khiếu và trong chuỗi ghép
    -- ("<tên>冷却<n>秒", "已选择：<tên>；..."). Dùng word_fix để thay cả
    -- khi tên nằm giữa câu. Các tên không chồng lên nhau nên thứ tự
    -- duyệt word_fix không ảnh hưởng.
    local GU_CN = {
        ["兜率花"] = "Đâu Suất Hoa",       ["九叶生机草"] = "Cửu Diệp Sinh Cơ Thảo",
        ["月芒蛊"] = "Nguyệt Mang Cổ",     ["智慧蛊"] = "Trí Tuệ Cổ",
        ["火炭蛊"] = "Hoả Thán Cổ",        ["坚持蛊"] = "Kiên Trì Cổ",
        ["跳跳草"] = "Khiêu Khiêu Thảo",   ["天蓬蛊"] = "Thiên Bồng Cổ",
        ["水罩蛊"] = "Thuỷ Tráo Cổ",       ["白玉蛊"] = "Bạch Ngọc Cổ",
        ["雷翼蛊"] = "Lôi Dực Cổ",         ["血月蛊"] = "Huyết Nguyệt Cổ",
        ["小光蛊"] = "Tiểu Quang Cổ",      ["血气蛊"] = "Huyết Khí Cổ",
        ["至尊仙胎蛊"] = "Chí Tôn Tiên Thai Cổ", ["春秋蝉"] = "Xuân Thu Thiền",
        ["月光蛊"] = "Nguyệt Quang Cổ",    ["饭袋草"] = "Phạn Đại Thảo",
        ["狗屎运蛊"] = "Cẩu Thỉ Vận Cổ",   ["地听肉耳草"] = "Địa Thính Nhục Nhĩ Thảo",
        ["梦蝶蛊"] = "Mộng Điệp Cổ",       ["定仙游"] = "Định Tiên Du",
        ["无足鸟"] = "Vô Túc Điểu",        ["曜翼蛊"] = "Diệu Dực Cổ",
        ["青犀裂甲蛊"] = "Thanh Tê Liệt Giáp Cổ", ["绯翼金棘蜂"] = "Phi Dực Kim Cức Phong",
        ["焦雷豆母蛊"] = "Tiêu Lôi Đậu Mẫu Cổ",
    }
    for cn, vn in pairs(GU_CN) do
        textfix[cn]  = vn
        word_fix[cn] = vn
    end

    -- Chèn lên ĐẦU danh sách: pattern "(%d+)秒" chung chạy trước sẽ ăn mất
    -- phần "秒" và để lại "冷却" dính liền tên.
    table.insert(patterns, 1, {"冷却(%d+)秒", ": hồi chiêu %1 giây"})
    table.insert(patterns, 1, {"^已选择：(.-)；点击仙的大仙窍装配$", "Đã chọn: %1 — bấm vào Đại Tiên Khiếu để lắp"})
    table.insert(patterns, 1, {"^已选择：(.-)；点击仙的小仙窍装配$", "Đã chọn: %1 — bấm vào Tiểu Tiên Khiếu để lắp"})
end

-- =========================================================================
-- 9. Tooltip trong giao diện Tiên Khiếu: "<tên>\n<mô tả>[\n左键：卸载]".
--    Mô tả là chuỗi Hán gốc, bị word_fix cắt vụn ("损失Máumở khoá部分科技")
--    nếu không thay nguyên câu TRƯỚC word_fix → dùng pattern (chạy trước).
-- =========================================================================
if textfix and word_fix and patterns then
    local GU_DESC = {
        ["以寿为薪，燃智之火，照见万事万物的破绽"] = "Lấy thọ làm củi, đốt lửa trí tuệ, soi thấu sơ hở của vạn sự vạn vật.",
        ["地听四方，需舍一耳"] = "Nghe khắp bốn phương dưới đất, phải bỏ một tai.",
        ["心之所向，逆流不退"] = "Lòng đã hướng về, ngược dòng chẳng lùi.",
        ["损失血量解锁部分科技"] = "Mất máu để mở khoá một phần khoa kỹ.",
        ["星芒一点，光自掌心生"] = "Một điểm tinh mang, ánh sáng sinh từ lòng bàn tay.",
        ["月华如刃，寒芒毕露"] = "Nguyệt hoa như lưỡi đao, hàn quang lộ rõ.",
        ["月色如刃，斩尽邪祟"] = "Ánh trăng như đao, chém sạch tà ma.",
        ["月芒噬敌，血气养身"] = "Nguyệt mang cắn địch, huyết khí dưỡng thân.",
        ["水柔之力，护体无形"] = "Sức nhu của nước, hộ thân vô hình.",
        ["炭火藏身，寒夜自暖"] = "Thân giấu lửa than, đêm lạnh tự ấm.",
        ["碧叶九片，生机暗藏"] = "Chín lá biếc, sinh cơ ngầm chứa.",
        ["致命伤害时原地复生，恢复全部三维"] = "Khi chịu đòn chí mạng thì sống lại tại chỗ, hồi đầy cả ba chỉ số.",
        ["花苞之内，别有洞天"] = "Trong nụ hoa, riêng có động thiên.",
        ["草簧一踏，瞬息无踪"] = "Một bước giẫm lò xo cỏ, thoắt cái mất dạng.",
        ["草袋之中，饭香自来"] = "Trong túi cỏ, hương cơm tự đến.",
        ["蝶入幽梦，窥尽天机"] = "Bướm vào mộng sâu, nhìn thấu thiên cơ.",
        ["血涌气动，枯木逢春"] = "Máu dâng khí động, cây khô gặp xuân.",
        ["运道无常，踩中便是福"] = "Vận may vô thường, giẫm trúng chính là phúc.",
        ["遁入梦境，以梦魇代替自己行动"] = "Trốn vào cõi mộng, để ác mộng hành động thay mình.",
        ["雷光化翼，一瞬千里"] = "Sấm sét hoá cánh, chớp mắt nghìn dặm.",
        ["饱食度、理智、血量的上限均增加125点"] = "Giới hạn no bụng, tinh thần, máu đều tăng 125 điểm.",
    }
    for cn, vn in pairs(GU_DESC) do
        textfix[cn] = vn
        table.insert(patterns, 1, {cn, vn})
    end
    textfix["请先选择下方仓库中的蛊虫"] = "Hãy chọn cổ trùng trong kho bên dưới trước"
    textfix["左键：卸载"]               = "Chuột trái: tháo ra"
    table.insert(patterns, 1, {"左键：卸载", "Chuột trái: tháo ra"})
    -- tên cổ phía trước còn là chữ Hán lúc này; word_fix chạy sau sẽ dịch
    table.insert(patterns, 1, {"只能装配到大仙窍", " chỉ lắp được vào Đại Tiên Khiếu"})
    table.insert(patterns, 1, {"只能装配到小仙窍", " chỉ lắp được vào Tiểu Tiên Khiếu"})
end

-- =========================================================================
-- 10. Bảng định nghĩa cổ trùng xd_gyfy_gu_defs (file mã hoá của mod gốc).
--     Giao diện Tiên Khiếu đọc tên/hiệu ứng từ đây chứ không từ STRINGS.
--     Nội dung lấy bằng selftest (dangtien_moddata.txt), 2026-10-15.
--     Ghi đè thẳng vào bảng (package.loaded dùng chung giữa các mod), kèm
--     textfix + pattern để đỡ khi UI đã chép sẵn chuỗi cũ.
-- =========================================================================
local GU_EFFECT = {
    BYG   = { "增加部分防御", "Tăng một phần phòng ngự" },
    DSH   = { "具有额外的储存空间", "Có thêm chỗ chứa đồ" },
    DTREC = { "地图上视野范围更大", "Mở rộng tầm nhìn trên bản đồ" },
    FDC   = { "缓慢生成食物", "Từ từ sinh ra thức ăn" },
    GSYG  = { "采集时有概率获取双倍", "Khi thu thập có xác suất nhận gấp đôi" },
    HTG   = { "抵御寒冷", "Chống lạnh" },
    JCG   = { "增加少量位面防御", "Tăng một ít phòng ngự vị diện" },
    JYSJC = { "自动缓慢产出生机草", "Tự động sinh ra cỏ Sinh Cơ theo thời gian" },
    LYG   = { "奔跑一定时间后激活雷翼", "Chạy một lúc sẽ kích hoạt Lôi Dực" },
    SZG   = { "受到伤害概率激活水罩", "Khi bị đánh có xác suất kích hoạt màn nước hộ thân" },
    TPG   = { "增加部分防御，受到伤害概率激活水罩",
              "Tăng một phần phòng ngự, khi bị đánh có xác suất kích hoạt màn nước hộ thân" },
    TTC   = { "略微增加移速", "Tăng nhẹ tốc độ di chuyển" },
    XGG   = { "具有微弱发光效果", "Phát ra ánh sáng yếu" },
    XQG   = { "缓慢回复血量", "Từ từ hồi máu" },
    XYG   = { "攻击时概率附加剑气，具有微弱发光效果，缓慢回复血量",
              "Khi tấn công có xác suất kèm kiếm khí, phát ra ánh sáng yếu, từ từ hồi máu" },
    YGG   = { "攻击时概率附加剑气", "Khi tấn công có xác suất kèm kiếm khí" },
    YMG   = { "攻击时概率附加剑气，具有微弱发光效果",
              "Khi tấn công có xác suất kèm kiếm khí, phát ra ánh sáng yếu" },
    -- 4 con còn lại có hiệu ứng trùng câu mô tả công thức (đã dịch ở mục 6)
}

if textfix and patterns then
    for _, e in pairs(GU_EFFECT) do
        textfix[e[1]] = e[2]
        table.insert(patterns, 1, { e[1], e[2] })
    end
end

do
    local ok, defs = pcall(require, "xd_gyfy_gu_defs")
    if ok and type(defs) == "table" and type(defs.BY_PREFAB) == "table" then
        local by_key = {}
        for _, g in ipairs(GU) do by_key[g[1]] = g end
        local n = 0
        for prefab, def in pairs(defs.BY_PREFAB) do
            local key = type(prefab) == "string" and prefab:match("^xd_gyfy_gu_(%w+)$")
            local g = key and by_key[key:upper()]
            if g and type(def) == "table" then
                local recipe, examine = g[3], g[4] or g[3]
                local eff = GU_EFFECT[key:upper()]
                if def.name then def.name = g[2] end
                if def.recipe_description then def.recipe_description = recipe end
                if def.examine then def.examine = examine end
                if def.description then def.description = eff and eff[2] or recipe end
                n = n + 1
            end
        end
        print("[DangTienVN] xd_gyfy_gu_defs: vá " .. n .. " cổ trùng")
    end
end

-- Tooltip Tiên Khiếu khi hai cổ trùng xung đột: "效果被<tên>抑制"
if patterns then
    table.insert(patterns, 1, {"效果被(.-)抑制", "Hiệu quả bị %1 áp chế"})
end

-- =========================================================================
-- 11. Chuỗi còn sót trong log MISSING_CN khi chơi thật (2026-10-17)
-- =========================================================================
if textfix and word_fix and patterns then
    -- "通脉十二层": pattern chung "二层" chạy trước "十层" nên ra "Thông Mạch十tầng 2".
    -- Chèn bản 11-29 lên ĐẦU danh sách để khớp trước.
    local so = { "一", "二", "三", "四", "五", "六", "七", "八", "九" }
    for i = #so, 1, -1 do
        table.insert(patterns, 1, { "二十" .. so[i] .. "层", " tầng " .. (20 + i) })
        table.insert(patterns, 1, { "十" .. so[i] .. "层", " tầng " .. (10 + i) })
    end
    table.insert(patterns, 1, { "二十层", " tầng 20" })
    -- tooltip thuộc tính bản nguyên của pháp bảo (phần sau dấu ":" đã được dịch sẵn)
    word_fix["本源倾斜"] = "Thiên hướng bản nguyên"
    word_fix["倾斜程度"] = "Mức thiên lệch"
    -- lời NPC lão phu bán đan: chuỗi do server ghép, word_fix "丹药" chạy trước textfix
    textfix["小友老夫这或许有些你需要的丹药"] = "Tiểu hữu, chỗ lão phu có lẽ có vài loại đan dược ngươi cần"
    table.insert(patterns, 1, { "小友老夫这或许有些你需要的丹药", "Tiểu hữu, chỗ lão phu có lẽ có vài loại đan dược ngươi cần" })
    textfix["选择蛊虫后点击仙窍装配；右键库存蛊虫取出"] = "Chọn cổ trùng rồi bấm vào Tiên Khiếu để lắp; chuột phải cổ trùng trong kho để lấy ra"
end

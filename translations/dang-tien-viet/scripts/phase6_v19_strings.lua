-- Phase 6: vá 109 chuỗi còn thiếu, đo với mod gốc 【登仙】 v19.0 (2026-07-26).
--
-- Gồm 3 nhóm:
--   1. Nhân vật mới 陈平安 Trần Bình An (v19.0) — tên + mô tả + recipe desc
--   2. Bảng STRINGS.XD_USE_INVENTORY — trùng key với ACTIONS.XD_LUOSHEN_YIN_MAP
--      mà phase2 đã dịch, nên dùng LẠI ĐÚNG bản dịch đó cho nhất quán
--   3. Vài chuỗi lẻ: XD_JIANGRENACTION, XD_LINGJIACTION, XS_PET_LEVELUP
--
-- Quy ước: tên pháp bảo/phù lục giữ Hán-Việt; vật thường dùng tiếng Việt
-- (dao chặt củi, cây thanh mai). Mô tả là câu đối/thơ → dịch thoát giữ nhịp.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)
local set_str = rawget(_G, "dangtien_viet_set_str")
if not set_str then return end

local s = set_str

-- =========================================================================
-- 1. Trần Bình An — tên vật phẩm
-- =========================================================================
s("STRINGS.NAMES.XD_CHENPINGAN_BD",            "Bắc Đẩu")
s("STRINGS.NAMES.XD_CHENPINGAN_BSF",           "Bái Sơn Phù")
s("STRINGS.NAMES.XD_CHENPINGAN_BYZ",           "Trâm Bích Ngọc")
s("STRINGS.NAMES.XD_CHENPINGAN_CJQ",           "Trường Khí Kiếm")
s("STRINGS.NAMES.XD_CHENPINGAN_CM",            "Trừ Ma")
s("STRINGS.NAMES.XD_CHENPINGAN_JJTQ",          "Kim Tinh Đồng Tiền")
s("STRINGS.NAMES.XD_CHENPINGAN_KCD",           "Dao chặt củi")
s("STRINGS.NAMES.XD_CHENPINGAN_LJT",           "Lão Kiếm Điều")
s("STRINGS.NAMES.XD_CHENPINGAN_LJT_BUILDER",   "Lão Kiếm Điều")
s("STRINGS.NAMES.XD_CHENPINGAN_MUME",          "Cây thanh mai")
s("STRINGS.NAMES.XD_CHENPINGAN_MUMEFRUIT",     "Thanh mai")
s("STRINGS.NAMES.XD_CHENPINGAN_MUME_SAPLING",  "Cây thanh mai con")
s("STRINGS.NAMES.XD_CHENPINGAN_PZF",           "Phá Chướng Phù")
s("STRINGS.NAMES.XD_CHENPINGAN_QP",            "Thanh Bình")
s("STRINGS.NAMES.XD_CHENPINGAN_RYSZSF",        "Nhật Du Thần Chân Thân Phù")
s("STRINGS.NAMES.XD_CHENPINGAN_SHIWU",         "Thập Ngũ")
s("STRINGS.NAMES.XD_CHENPINGAN_XB",            "Tinh Tiêu")
s("STRINGS.NAMES.XD_CHENPINGAN_YGL",           "Nón Ẩn Quan")
s("STRINGS.NAMES.XD_CHENPINGAN_YGP",           "Áo bào Ẩn Quan")
s("STRINGS.NAMES.XD_CHENPINGAN_YJH",           "Hồ lô dưỡng kiếm")
s("STRINGS.NAMES.XD_CHENPINGAN_YQTDF",         "Dương Khí Khiêu Đăng Phù")
s("STRINGS.NAMES.XD_CHENPINGAN_YYSZSF",        "Dạ Du Thần Chân Thân Phù")
s("STRINGS.NAMES.XD_CHENPINGAN_ZLT",           "Trảm Long Đài")
s("STRINGS.NAMES.XD_QINGMEIJIU",               "Rượu thanh mai")
s("STRINGS.NAMES.XD_QINGMEIPAIGU",             "Sườn xào thanh mai")

-- =========================================================================
-- 2. Trần Bình An — mô tả khi inspect (GENERIC.DESCRIBE)
-- =========================================================================
local D = "STRINGS.CHARACTERS.GENERIC.DESCRIBE."
s(D .. "XD_CHENPINGAN_BD",           "Bảy sao chỉ lối, đêm chẳng lạc đường.")
s(D .. "XD_CHENPINGAN_BSF",          "Đi giữa đường, thần quỷ chẳng quấy.")
s(D .. "XD_CHENPINGAN_BYZ",          "Kỳ vọng của bậc thầy với hậu bối: lập thân giữ chính, ung dung đường hoàng.")
s(D .. "XD_CHENPINGAN_CJQ",          "Một hơi còn thở, kiếm ý chẳng tan.")
s(D .. "XD_CHENPINGAN_CM",           "Chẳng thuộc hàng kim thiết, mà chém sạch tà ma thế gian.")
s(D .. "XD_CHENPINGAN_JJTQ",         "Sắc đồng ánh vàng, chạm đất kêu vang như kiếm ngâm.")
s(D .. "XD_CHENPINGAN_KCD",          "Không chém đầu người, chỉ phạt gai góc.")
s(D .. "XD_CHENPINGAN_LJT",          "Từng theo chủ nhân chém rơi thần linh trong trận Đăng Thiên.")
s(D .. "XD_CHENPINGAN_LJT_BUILDER",  "Từng theo chủ nhân chém rơi thần linh trong trận Đăng Thiên.")
s(D .. "XD_CHENPINGAN_MUME.BURNT",   "Cây thanh mai cháy đen.")
s(D .. "XD_CHENPINGAN_MUME.CHOPPED", "Gốc cây thanh mai.")
s(D .. "XD_CHENPINGAN_MUME.GENERIC", "Mai xanh trĩu cành, chua chát ba phần là tương tư.")
s(D .. "XD_CHENPINGAN_MUMEFRUIT",    "Mai xanh trĩu cành, chua chát ba phần là tương tư.")
s(D .. "XD_CHENPINGAN_MUME_SAPLING", "Cây thanh mai con.")
s(D .. "XD_CHENPINGAN_PZF",          "Phá tan mê chướng trong một phạm vi nhất định.")
s(D .. "XD_CHENPINGAN_QP",           "Kiếm ý trong suốt, thẳng chỉ bản tâm.")
s(D .. "XD_CHENPINGAN_RYSZSF",       "Tà mị thấy phải lui, bước đi như gió.")
s(D .. "XD_CHENPINGAN_SHIWU",        "Kiếm này vừa xuất, tiên cơ đã định.")
s(D .. "XD_CHENPINGAN_XB",           "Khi cầm Bắc Đẩu có thể truyền tống tới Tinh Tiêu.")
s(D .. "XD_CHENPINGAN_YGL",          "Dưới vành nón không người, chỉ có kiếm ý.")
s(D .. "XD_CHENPINGAN_YGP",          "Một tấm áo Ẩn Quan, áp trọn kiếm khí Trường Thành.")
s(D .. "XD_CHENPINGAN_YJH",          "Có thể từ từ hồi phục độ bền vũ khí.")
s(D .. "XD_CHENPINGAN_YQTDF",        "Lạnh chẳng xâm, tối chẳng gần.")
s(D .. "XD_CHENPINGAN_YYSZSF",       "Vạn vật dưới trăng đều sáng như đuốc, bước đi không tiếng.")
s(D .. "XD_CHENPINGAN_ZLT",          "Trên đài chém rồng, dưới đài kinh thần.")
s(D .. "XD_QINGMEIJIU",              "Kiếm thành còn vương vị thiếu niên, chẳng thấy người cùng ủ rượu năm xưa.")
s(D .. "XD_QINGMEIPAIGU",            "Chua thơm chống ngán, ăn rất ngon.")
s(D .. "XD_ZUICHUNYAN.BURNT",        "Túy Xuân Yên cháy rụi, chẳng còn chút sinh cơ.")
s(D .. "XD_ZUICHUNYAN.CHOPPED",      "Gốc cây Túy Xuân Yên.")
s(D .. "XD_ZUICHUNYAN.GENERIC",      "Dường như ẩn chứa linh lực thuần hậu, sinh sôi bất tận.")

-- =========================================================================
-- 3. Trần Bình An — mô tả công thức chế tạo
-- =========================================================================
local R = "STRINGS.RECIPE_DESC."
s(R .. "XD_CHENPINGAN_BD",          "Bảy sao chỉ lối, đêm chẳng lạc đường.")
s(R .. "XD_CHENPINGAN_BSF",         "Đi giữa đường, thần quỷ chẳng quấy.")
s(R .. "XD_CHENPINGAN_CJQ",         "Một hơi còn thở, kiếm ý chẳng tan.")
s(R .. "XD_CHENPINGAN_KCD",         "Không chém đầu người, chỉ phạt gai góc.")
s(R .. "XD_CHENPINGAN_LJT_BUILDER", "Từng theo chủ nhân chém rơi thần linh trong trận Đăng Thiên.")
s(R .. "XD_CHENPINGAN_PZF",         "Phá tan mê chướng trong một phạm vi nhất định.")
s(R .. "XD_CHENPINGAN_QP",          "Kiếm ý trong suốt, thẳng chỉ bản tâm.")
s(R .. "XD_CHENPINGAN_RYSZSF",      "Tà mị thấy phải lui, bước đi như gió.")
s(R .. "XD_CHENPINGAN_YGL",         "Dưới vành nón không người, chỉ có kiếm ý.")
s(R .. "XD_CHENPINGAN_YGP",         "Một tấm áo Ẩn Quan, áp trọn kiếm khí Trường Thành.")
s(R .. "XD_CHENPINGAN_YJH",         "Có thể từ từ hồi phục độ bền vũ khí.")
s(R .. "XD_CHENPINGAN_YQTDF",       "Lạnh chẳng xâm, tối chẳng gần.")
s(R .. "XD_CHENPINGAN_YYSZSF",      "Vạn vật dưới trăng đều sáng như đuốc, bước đi không tiếng.")
s(R .. "XD_CHENPINGAN_ZLT",         "Trên đài chém rồng, dưới đài kinh thần.")

-- =========================================================================
-- 4. STRINGS.XD_USE_INVENTORY — nhãn menu dùng vật phẩm
--    Trùng key với ACTIONS.XD_LUOSHEN_YIN_MAP (phase2) → giữ y hệt bản dịch đó.
-- =========================================================================
local U = "STRINGS.XD_USE_INVENTORY."
s(U .. "ADD_MASTER",    "Đặt làm điểm chính")
s(U .. "CHUMO",         "Chạm")
s(U .. "CLOSE",         "Đóng")
s(U .. "DUANZAO",       "Rèn trang bị")
s(U .. "DUNRU",         "Độn nhập")
s(U .. "EAT",           "Ăn")
s(U .. "FISH",          "Câu")
s(U .. "GET_FOOD",      "Nhận triều cống")
s(U .. "GUIRUI",        "Quy nhụy")
s(U .. "JIHUO",         "Kích hoạt")
s(U .. "JINRU",         "Vào")
s(U .. "JIQU",          "Hấp thu linh lực")
s(U .. "KLS",           "Pháp Thể Độn Nhập")
s(U .. "LIANHUA",       "Luyện hoá")
s(U .. "MAP",           "Xem bản đồ")
s(U .. "NAQU",          "Lấy xuống")
s(U .. "NIESUI",        "Bóp vỡ")
s(U .. "OPEN",          "Mở")
s(U .. "REMOVE_MASTER", "Huỷ điểm chính")
s(U .. "SHESHENG",      "Xả sinh")
s(U .. "SHOUHUI",       "Thu hồi")
s(U .. "SJC",           "Triệu Thực Kim Trùng")
s(U .. "SUMMON",        "Triệu hồi")
s(U .. "SUMMON_LB",     "Thi triển Huyền Bảo Thần Thông")
s(U .. "SUMMON_ST",     "Thi triển Thần Thông")          -- mới v19.0
s(U .. "SWHS",          "Ngưng Thần")
s(U .. "TRADE",         "Giao dịch")
s(U .. "TSMD_SWAP",     "Đổi")
s(U .. "TSMD_USE",      "Huyễn hoá")
s(U .. "USE",           "Sử dụng")
s(U .. "USE_GCSZ",      "Truyền tống")
s(U .. "XD_PETEGG_IN",  "Thu vào Đan Điền")              -- mới v19.0
s(U .. "XTLB_CLOSE",    "Thu hồi thần thức")
s(U .. "XTLB_OPEN",     "Thần thức tham xét")
s(U .. "XYZZ",          "Triệu Huyết Ngọc Châu")

-- =========================================================================
-- 5. Chuỗi lẻ
-- =========================================================================
s("STRINGS.ACTIONS.GIVE.XD_CHONGNENG_CJQ", "Bổ sung khí huyết")
s("STRINGS.XD_JIANGRENACTION.SHESHENG",    "Xả sinh")
s("STRINGS.XD_LINGJIACTION.ATTACK",        "Linh Kỹ")
s("STRINGS.XS_PET_LEVELUP.REPAIR",         "Nuốt")
s("STRINGS.XS_PET_LEVELUP.RONGHE",         "Dung hợp")

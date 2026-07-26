-- Phase 7: các chuỗi CHỈ phát hiện được khi chạy thật.
--
-- Nguồn: self-test headless trên dedicated server (scripts/selftest.lua),
-- chạy 2026-07-26 với mod gốc v19.0.
--
-- Vì sao phân tích tĩnh không thấy: những chuỗi này KHÔNG nằm trong
-- scripts/main/strings.lua mà được mod gốc đăng ký từ các file đã mã hóa
-- (AddModCharacter, khai báo skin, AddAction...). Chỉ khi mod chạy thật thì
-- chúng mới xuất hiện trong bảng STRINGS.
--
-- KHÔNG dịch STRINGS.PRETRANSLATED.* — đó là chuỗi chọn ngôn ngữ của chính
-- game gốc (Hàn/Trung), cố tình để nguyên tiếng bản địa.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)
local set_str = rawget(_G, "dangtien_viet_set_str")
if not set_str then return end

local s = set_str

-- =========================================================================
-- 1. Nhân vật Trần Bình An — tên, danh hiệu, mô tả (màn chọn nhân vật)
-- =========================================================================
s("STRINGS.NAMES.XD_CHENPINGAN",                "Trần Bình An")
s("STRINGS.CHARACTER_NAMES.xd_chenpingan",      "Trần Bình An")
s("STRINGS.CHARACTER_TITLES.xd_chenpingan",     "Trần Thập Nhất")
s("STRINGS.CHARACTER_QUOTES.xd_chenpingan",     "\"Thiên đạo sụp đổ, Trần Bình An ta chỉ có một kiếm!\"")
s("STRINGS.CHARACTER_SURVIVABILITY.xd_chenpingan", "Gian khổ tột bậc")
s("STRINGS.CHARACTER_DESCRIPTIONS.xd_chenpingan",
  "*Xích tử chi tâm\n*Kiếm linh hộ thể\n*Bản mệnh từ đã vỡ")

-- =========================================================================
-- 2. Tên skin (SKIN_NAMES)
-- =========================================================================
local K = "STRINGS.SKIN_NAMES."
s(K .. "xd_hyparmor",                        "Hồng Vân Bào")
s(K .. "xd_jdjarmor",                        "Kiếp Địa Giáp")
s(K .. "xd_jtkhat",                          "Kiếp Thiên Khôi")
s(K .. "xd_lhyhat",                          "Băng Trán Nhẫn Giả")
s(K .. "xd_chenpingan_none",                 "Trần Bình An")
s(K .. "xd_chenpingan_hphz",                 "Chuột Da Đỏ")
s(K .. "xd_chenpingan_ygp_skins_wgr",        "Người Chưa Về")
s(K .. "xd_chenpingan_ygl_skins_wm",         "Vô Danh")
s(K .. "xd_chenpingan_cjq_skins_qgch",       "Khí Quán Trường Hồng")
s(K .. "xd_chenpingan_yjh_skins_cf",         "Tàng Phong")
s(K .. "xd_chenpingan_qp_skins_fqqp",        "Phong Khởi Thanh Bình")
s(K .. "xd_chenpingan_ljt_builder_skins_gjtl", "Cổ Kiếm Thông Linh")
s(K .. "xd_chenpingan_bd_skins_xc",          "Tinh Thùy")
s(K .. "xd_chenpingan_zlt_skins_lhd",        "Long Hài Đê")
s(K .. "xd_shatangshu_skins_stm",            "Sa Đường Mặc")
s(K .. "xd_gj_skins_qsj",                    "Giếng Thanh Thạch")
s(K .. "xd_backpack3_skin6",                 "Thải Hà")
s(K .. "xd_skin_ys",                         "Diệu Thăng")
s(K .. "xd_skin_zj",                         "Chước Kinh")
s(K .. "xd_skin_sny",                        "Thiếu Niên Du")
s(K .. "xd_flower_bh_skins_ya",              "Yên Ái")
s(K .. "xd_lgzbh_skins_lz",                  "Liên Tàng")
s(K .. "xd_hjjm_skins_pj",                   "Phá Kiếp")
s(K .. "xd_wsjx_skins_xzyj",                 "Tro Tàn Trong Hộp")
s(K .. "xd_tree_yls_skins_cl",               "Thùy Lộ")

-- =========================================================================
-- 3. Mô tả / lời thoại skin
-- =========================================================================
s("STRINGS.SKIN_DESCRIPTIONS.xd_chenpingan_hphz", "Máu thịt làm áo, xương khô làm rường.")
s("STRINGS.SKIN_DESCRIPTIONS.xd_skin_ys",         "Diệu Thăng")
s("STRINGS.SKIN_DESCRIPTIONS.xd_skin_zj",         "Chước Kinh")
s("STRINGS.SKIN_DESCRIPTIONS.xd_skin_sny",        "Thiếu Niên Du")
s("STRINGS.SKIN_QUOTES.xd_chenpingan_hphz",
  "Tấm áo đỏ này của ta, vốn được khâu nên khi đứng giữa đống đổ nát.")

-- =========================================================================
-- 4. Action đăng ký qua AddAction (không có trong strings.lua)
-- =========================================================================
s("STRINGS.ACTIONS.XD_CHENPINGAN_ZLT_POLISH",         "Mài dao")
s("STRINGS.ACTIONS.XD_CHENPINGAN_PZF_MAP",            "Phá mê chướng")
s("STRINGS.ACTIONS.XD_CHENPINGAN_GUIDE_MAP.GUIDE",    "Dẫn dắt")
-- 2 mục mới của v19.0, bổ sung cho bảng phase2 đã dịch trước đó
s("STRINGS.ACTIONS.XD_LUOSHEN_YIN_MAP.SUMMON_ST",     "Thi triển Thần Thông")
s("STRINGS.ACTIONS.XD_LUOSHEN_YIN_MAP.XD_PETEGG_IN",  "Thu vào Đan Điền")

-- =========================================================================
-- 5. Thông báo hành động thất bại
-- =========================================================================
s("STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.RUMMAGE.NOTMYSWHS",
  "Thân ngoại hoá thân này ngưng luyện thần thức của người khác.")
s("STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.BUILD.ISMAX",
  "Đã đạt giới hạn xây dựng tối đa.")

-- Phase 4: Override mod's PRIVATE STRINGS/TUNING tables (sandboxed in mod env)
-- These are read by the mod itself (e.g. Tu Tiên Mật Quyển) and don't go through
-- the global STRINGS, so phase2 overrides don't reach them.

local _G = GLOBAL
GLOBAL.setfenv(1, GLOBAL)

local mm = rawget(_G, "ModManager")
if not mm or not mm.mods then return end

-- Find dengxian mod (workshop id 3235319974)
local target_mod
for _, m in ipairs(mm.mods) do
    if m.modinfo and (m.modinfo.id == "workshop-3235319974"
       or (m.modinfo.name and m.modinfo.name:find("登仙", 1, true))) then
        target_mod = m
        break
    end
end
if not target_mod then target_mod = mm.mods[1] end  -- fallback to first
if not target_mod or not target_mod.GLOBAL then
    print("[DangTienVN] Phase4: target mod not found")
    return
end

local M = target_mod.GLOBAL

-- =========================================================================
-- Helper: set nested path on table
-- =========================================================================
local function setpath(tbl, path, value)
    local parts = {}
    for p in path:gmatch("[^%.]+") do parts[#parts + 1] = p end
    local cur = tbl
    for i = 1, #parts - 1 do
        local k = tonumber(parts[i]) or parts[i]
        if type(cur[k]) ~= "table" then return false end
        cur = cur[k]
    end
    local final = tonumber(parts[#parts]) or parts[#parts]
    if cur[final] ~= nil then
        cur[final] = value
        return true
    end
    return false
end

local applied, missed = 0, 0
local function set(path, vn)
    -- path looks like "STRINGS.NAMES.XD_ZIYUNNPC_TALKS.1"
    local root = path:match("^([^%.]+)")
    if not root then return end
    local rest = path:sub(#root + 2)
    local target = M[root]
    if not target then missed = missed + 1; return end
    if setpath(target, rest, vn) then applied = applied + 1
    else missed = missed + 1 end
end

-- =========================================================================
-- NPC dialogue
-- =========================================================================
set("STRINGS.NAMES.XD_ZIYUNNPC_TALKS.1", "Đạo hữu phương nào tới, có thể giúp bổn tôn chém đứt tâm chi ma tướng?")
set("STRINGS.NAMES.XD_ZIYUNNPC_TALKS.2", "Tiểu hữu có thể giúp bổn quân đánh bại hoá thân mất kiểm soát, bổn quân tất hậu tạ!")
set("STRINGS.NAMES.XD_ZIYUNNPC_TALKS.3", "Đa tạ tiểu hữu, đây là chút lễ vật mọn của bổn quân.")
set("STRINGS.NAMES.XD_ZIYUNNPC_TALKS.4", "Lúc bổn quân nhàn bộ chớ quấy rầy.")
set("STRINGS.NAMES.XD_ZIYUNNPC_TALKS.5", "Ma niệm trong tâm ngày càng khó áp chế.")
set("STRINGS.NAMES.XD_ZIYUNNPC_TALKS.6", "Với thủ đoạn của bổn quân cũng không trấn áp được Côn Bằng che trời này.")

set("STRINGS.NAMES.XD_QXDX_TALKS.1", "Tiểu hữu lại đem tinh hoa thiên địa, làm chuyện cặn bã!")
set("STRINGS.NAMES.XD_QXDX_TALKS.2", "Tiểu hữu, lão phu đây có lẽ có vài đan dược ngươi cần")
set("STRINGS.NAMES.XD_QXDX_TALKS.3", "Đa tạ tiểu hữu chiếu cố")
set("STRINGS.NAMES.XD_QXDX_TALKS.4", "Tiểu hữu, linh thạch của ngươi dường như chưa đủ")
set("STRINGS.NAMES.XD_QXDX_TALKS.5", "Đại đạo như vực sâu, lối vào chỉ một sợi. Lão phu hôm nay, lấy thân làm thuyền, lại tranh cơ hội mong manh này!")

set("STRINGS.NAMES.XD_ZIYUNBOSS_TALKS.1", "Có chút thực lực, dùng huyền bảo của bổn quân thử ngươi xem nặng nhẹ ra sao.")
set("STRINGS.NAMES.XD_ZIYUNBOSS_TALKS.2", "Có thể bức bổn quân đến bước đường này, quả là kẻ kinh tài tuyệt diễm.")
set("STRINGS.NAMES.XD_ZIYUNBOSS_TALKS.3", "Bổn quân... không ngờ... bại rồi...")
set("STRINGS.NAMES.XD_ZIYUNBOSS_TALKS.4.1", "Phàm phu kiến lại dám quấy rầy thanh tịnh của bổn quân!")
set("STRINGS.NAMES.XD_ZIYUNBOSS_TALKS.4.2", "Đem ngươi nghiền cốt rải tro chỉ là việc tiện tay của bổn quân thôi.")
set("STRINGS.NAMES.XD_ZIYUNBOSS_TALKS.4.3", "Tiểu nhân không biết trời cao đất dày, bổn quân vô cùng không ưa!")

-- =========================================================================
-- Cooking dialogue
-- =========================================================================
set("STRINGS.XD_JINGWEI_FENICE_COOKTALK.1", "Tôn thượng, thử món sắc vị đều tuyệt này.")
set("STRINGS.XD_JINGWEI_FENICE_COOKTALK.2", "Tôn thượng, nếm thử tay nghề của tiểu nữ tử thế nào?")

-- =========================================================================
-- Level skill strings
-- =========================================================================
set("STRINGS.XD_LEVEL_SKILLSTR.6", "Chính đạo ma đạo, đều ở trong một niệm của ta")
set("STRINGS.XD_LEVEL_SKILLSTR.3", "Ta đã có thể thử triệu hoán thân ngoại hoá thân")
set("STRINGS.XD_LEVEL_SKILLSTR.9", "Linh lực của ta đủ để điều khiển Huyền Thiên Linh Bảo")

-- =========================================================================
-- Long Châu spells
-- =========================================================================
set("STRINGS.XD_LONGZHU_SPELLSTR.1", "Giáng vũ")
set("STRINGS.XD_LONGZHU_SPELLSTR.2", "Lạc lôi")
set("STRINGS.XD_LONGZHU_SPELLSTR.3", "Băng lao")
set("STRINGS.XD_LONGZHU_SPELLSTR.4", "Băng pháp trận")
set("STRINGS.XD_LONGZHU_SPELLSTR.5", "Không gian lưu trữ")
set("STRINGS.XD_LONGZHU_SPELLSTR.6", "Cực quang")
set("STRINGS.XD_LONGZHU_SPELLSTR.7", "Băng linh hộ thể")
set("STRINGS.XD_LONGZHU_SPELLSTR.8", "Hàn băng linh nhãn")

-- =========================================================================
-- TUNING.XD_FB_ZHF_STR — Chấn Hồn Phù pháp bảo skills
-- =========================================================================
set("TUNING.XD_FB_ZHF_STR.1.1", "Mỗi lần Liệp Khuyển hồn phách cắn xé tăng 28 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.1.2", "Mỗi lần Liệp Khuyển hồn phách cắn xé tăng 28 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.1.3", "Mỗi lần Liệp Khuyển hồn phách cắn xé tăng 28 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.1.4", "Mỗi lần Liệp Khuyển hồn phách cắn xé tăng 42.5 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.1.5", "Mỗi lần Liệp Khuyển hồn phách cắn xé tăng 56 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.1.6", "Mỗi lần Liệp Khuyển hồn phách cắn xé tăng 67.2 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.1.7", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")
set("TUNING.XD_FB_ZHF_STR.1.8", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")
set("TUNING.XD_FB_ZHF_STR.1.9", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")

set("TUNING.XD_FB_ZHF_STR.2.1", "Liệp Khuyển hồn phách tăng 0.5 điểm khoảng cách tấn công")
set("TUNING.XD_FB_ZHF_STR.2.2", "Liệp Khuyển hồn phách tăng 0.5 điểm khoảng cách tấn công")
set("TUNING.XD_FB_ZHF_STR.2.3", "Liệp Khuyển hồn phách tăng 0.5 điểm khoảng cách tấn công")
set("TUNING.XD_FB_ZHF_STR.2.4", "Liệp Khuyển hồn phách tăng 1 điểm khoảng cách tấn công")
set("TUNING.XD_FB_ZHF_STR.2.5", "Liệp Khuyển hồn phách tăng 1.5 điểm khoảng cách tấn công")
set("TUNING.XD_FB_ZHF_STR.2.6", "Liệp Khuyển hồn phách tăng 2 điểm khoảng cách tấn công")
set("TUNING.XD_FB_ZHF_STR.2.7", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")
set("TUNING.XD_FB_ZHF_STR.2.8", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")
set("TUNING.XD_FB_ZHF_STR.2.9", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")

set("TUNING.XD_FB_ZHF_STR.3.1", "Mỗi lần Liệp Khuyển hồn phách cắn xé sẽ thêm một Hỏa Linh Kỹ, gây 16.8 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.3.2", "Mỗi lần Liệp Khuyển hồn phách cắn xé sẽ thêm một Hỏa Linh Kỹ, gây 16.8 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.3.3", "Mỗi lần Liệp Khuyển hồn phách cắn xé sẽ thêm một Hỏa Linh Kỹ, gây 16.8 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.3.4", "Mỗi lần Liệp Khuyển hồn phách cắn xé sẽ thêm một Hỏa Linh Kỹ, gây 47 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.3.5", "Mỗi lần Liệp Khuyển hồn phách cắn xé sẽ thêm một Hỏa Linh Kỹ, gây 62.4 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.3.6", "Mỗi lần Liệp Khuyển hồn phách cắn xé sẽ thêm một Hỏa Linh Kỹ, gây 106.9 điểm sát thương")
set("TUNING.XD_FB_ZHF_STR.3.7", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")
set("TUNING.XD_FB_ZHF_STR.3.8", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")
set("TUNING.XD_FB_ZHF_STR.3.9", "Liệp Khuyển hồn phách sẽ trở thành tế phẩm cho yêu hồn mạnh hơn")

set("TUNING.XD_FB_ZHF_STR.4.5", "Triệu hồi thêm một Liệp Khuyển hồn phách yếu hơn")
set("TUNING.XD_FB_ZHF_STR.4.6", "Cường hoá Liệp Khuyển hồn phách phụ trợ yếu hơn")
set("TUNING.XD_FB_ZHF_STR.4.7", "Cường hoá lần nữa Liệp Khuyển hồn phách phụ trợ yếu hơn")
set("TUNING.XD_FB_ZHF_STR.4.8", "Cường hoá lần nữa Liệp Khuyển hồn phách phụ trợ yếu hơn")
set("TUNING.XD_FB_ZHF_STR.4.9", "Cường hoá lần nữa Liệp Khuyển hồn phách phụ trợ yếu hơn")

set("TUNING.XD_FB_ZHF_STR.5.7", "Thông qua tế phẩm triệu hoán Toạ Lang phụ thân hồn phách")
set("TUNING.XD_FB_ZHF_STR.5.8", "Cường hoá Toạ Lang phụ thân hồn phách triệu hoán qua tế phẩm")
set("TUNING.XD_FB_ZHF_STR.5.9", "Toạ Lang phụ thân hồn phách sẽ trở thành tế phẩm cho yêu vương chủ hồn")

set("TUNING.XD_FB_ZHF_STR.6.9", "Triệu hoán Tinh Thể Độc Nhãn Cự Lộc cấp yêu vương hồn phách")

-- =========================================================================
-- TUNING.XD_FB_FTJ_STR — Phong Tê Hỏa pháp bảo skills
-- =========================================================================
set("TUNING.XD_FB_FTJ_STR.1.1", "Tấn công sinh Liệt Diễm tăng 50 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.2", "Tấn công sinh Liệt Diễm tăng 50 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.3", "Tấn công sinh Liệt Diễm tăng 50 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.4", "Tấn công sinh Liệt Diễm tăng 76 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.5", "Tấn công sinh Liệt Diễm tăng 100 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.6", "Tấn công sinh Liệt Diễm tăng 120 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.7", "Tấn công sinh Liệt Diễm tăng 152 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.8", "Tấn công sinh Liệt Diễm tăng 125.8 điểm sát thương")
set("TUNING.XD_FB_FTJ_STR.1.9", "Tấn công sinh Liệt Diễm tăng 222.5 điểm sát thương")

set("TUNING.XD_FB_FTJ_STR.2.1", "Phạm vi Liệt Diễm tăng 10%")
set("TUNING.XD_FB_FTJ_STR.2.2", "Phạm vi Liệt Diễm tăng 10%")
set("TUNING.XD_FB_FTJ_STR.2.3", "Phạm vi Liệt Diễm tăng 10%")
set("TUNING.XD_FB_FTJ_STR.2.4", "Phạm vi Liệt Diễm tăng 20%")
set("TUNING.XD_FB_FTJ_STR.2.5", "Phạm vi Liệt Diễm tăng 30%")
set("TUNING.XD_FB_FTJ_STR.2.6", "Phạm vi Liệt Diễm tăng 40%")
set("TUNING.XD_FB_FTJ_STR.2.7", "Phạm vi Liệt Diễm tăng 60%")
set("TUNING.XD_FB_FTJ_STR.2.8", "Phạm vi Liệt Diễm tăng 80%")
set("TUNING.XD_FB_FTJ_STR.2.9", "Phạm vi Liệt Diễm tăng 100%")

set("TUNING.XD_FB_FTJ_STR.3.1", "Triệu hoán hai Nham Thạch Trùng phụ trợ tu sĩ tấn công")
set("TUNING.XD_FB_FTJ_STR.3.2", "Triệu hoán hai Nham Thạch Trùng phụ trợ tu sĩ tấn công")
set("TUNING.XD_FB_FTJ_STR.3.3", "Triệu hoán hai Nham Thạch Trùng phụ trợ tu sĩ tấn công")
set("TUNING.XD_FB_FTJ_STR.3.4", "Sát thương tấn công Nham Thạch Trùng tăng lên 176.4, sát thương cháy lên 81.5")
set("TUNING.XD_FB_FTJ_STR.3.5", "Sát thương tấn công Nham Thạch Trùng tăng lên 233.9, sát thương cháy lên 117")
set("TUNING.XD_FB_FTJ_STR.3.6", "Sát thương tấn công Nham Thạch Trùng tăng lên 267.4, sát thương cháy lên 133.7")
set("TUNING.XD_FB_FTJ_STR.3.7", "Nham Thạch Trùng sẽ trở thành tế phẩm để Kim Phụng thần niệm gọi ra Hoả Tinh")
set("TUNING.XD_FB_FTJ_STR.3.8", "Nham Thạch Trùng sẽ trở thành tế phẩm để Kim Phụng thần niệm gọi ra Hoả Tinh")
set("TUNING.XD_FB_FTJ_STR.3.9", "Nham Thạch Trùng sẽ trở thành tế phẩm để Kim Phụng thần niệm gọi ra Hoả Tinh")

set("TUNING.XD_FB_FTJ_STR.4.5", "Triệu hoán thêm Kim Phụng thần niệm tấn công mục tiêu")
set("TUNING.XD_FB_FTJ_STR.4.6", "Kim Phụng thần niệm phụ trợ sau khi đáp xuống sẽ thực hiện một đòn xung kích")
set("TUNING.XD_FB_FTJ_STR.4.7", "Kim Phụng thần niệm phụ trợ sau khi đáp xuống sẽ xung kích, sát thương tăng")
set("TUNING.XD_FB_FTJ_STR.4.8", "Kim Phụng thần niệm phụ trợ sau khi đáp xuống sẽ xung kích, sát thương tăng lần nữa")
set("TUNING.XD_FB_FTJ_STR.4.9", "Kim Phụng thần niệm phụ trợ sau khi đáp xuống sẽ xung kích, sát thương tăng lần nữa")

set("TUNING.XD_FB_FTJ_STR.5.7", "Khi triệu hoán Kim Phụng thần niệm sẽ có Hoả Tinh xuất hiện hỗ trợ tấn công")
set("TUNING.XD_FB_FTJ_STR.5.8", "Khi triệu hoán Kim Phụng thần niệm có Hoả Tinh hỗ trợ, sát thương cháy tăng lên 406.7")
set("TUNING.XD_FB_FTJ_STR.5.9", "Hiến tế Hoả Tinh khiến Kim Phụng giáng lâm triệt để hơn")

set("TUNING.XD_FB_FTJ_STR.6.9", "Khi xuất hiện Kim Phụng sẽ thêm thân ngoại hoá thân của Kim Phụng tấn công một lần")

-- =========================================================================
-- TUNING.XD_GUAIWU* — Quái vật bản nguyên/thân thể/khuynh hướng
-- =========================================================================
set("TUNING.XD_GUAIWUQINGXIANG.1.1", "Vi nhược")
set("TUNING.XD_GUAIWUQINGXIANG.2.1", "Phổ thông")
set("TUNING.XD_GUAIWUQINGXIANG.3.1", "Cường liệt")
set("TUNING.XD_GUAIWUQINGXIANG.4.1", "Cực trí")

set("TUNING.XD_GUAIWUBENYUAN.1.1", "Thổ")
set("TUNING.XD_GUAIWUBENYUAN.2.1", "Mộc")
set("TUNING.XD_GUAIWUBENYUAN.3.1", "Thuỷ")
set("TUNING.XD_GUAIWUBENYUAN.4.1", "Hoả")
set("TUNING.XD_GUAIWUBENYUAN.5.1", "Kim")
set("TUNING.XD_GUAIWUBENYUAN.6.1", "Hỗn nguyên")
set("TUNING.XD_GUAIWUBENYUAN.7.1", "Vô cực")

set("TUNING.XD_GUAIWUSHENGTI.1.1", "<Yêu Tổ Chuyển Thế Thân>")
set("TUNING.XD_GUAIWUSHENGTI.2.1", "<Tiên Thiên Đạo Thể>")
set("TUNING.XD_GUAIWUSHENGTI.3.1", "<Hoang Cổ Thánh Thể>")
set("TUNING.XD_GUAIWUSHENGTI.4.1", "<Sí Dương Thánh Thể>")
set("TUNING.XD_GUAIWUSHENGTI.5.1", "<Tà Âm Ma Thể>")

print(string.format("[DangTienVN] Phase4 mod-private: applied=%d missed=%d", applied, missed))

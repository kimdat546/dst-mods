-- patch_strings.lua
-- STRINGS.* overrides cho Myth Words Patch (腌笃鲜)
-- Được gọi từ AddSimPostInit trong main.lua nên sẽ chạy SAU khi Patch mod load xong

local STRINGS = GLOBAL.STRINGS
if not STRINGS then return end

-- =================================================================
-- Item names
-- =================================================================
if STRINGS.NAMES then
    STRINGS.NAMES.XYDZTZ_FUTON = "Bồ đoàn"
    STRINGS.NAMES.XYDZTZ_ARMOR_MADAMEWEB = "Thiên La Y Hỷ Châu"
    STRINGS.NAMES.XYDZTZ_CUNXIN_JINGPO = "Tinh Phách Thốn Tâm"
end

-- =================================================================
-- Recipe descriptions
-- =================================================================
if STRINGS.RECIPE_DESC then
    STRINGS.RECIPE_DESC.XYDZTZ_FUTON = "Dùng để ngồi thiền, suy diễn chu thiên."
    STRINGS.RECIPE_DESC.XYDZTZ_ARMOR_MADAMEWEB = "Kết ngàn tơ thành thụy khí, dệt thiên la chống vạn tà."
    STRINGS.RECIPE_DESC.XYDZTZ_CUNXIN_JINGPO = "Kết tinh tạo hóa trời đất và kiếp vận thành hạt nhân linh vận."
end

-- =================================================================
-- Generic character examine text
-- =================================================================
if STRINGS.CHARACTERS and STRINGS.CHARACTERS.GENERIC and STRINGS.CHARACTERS.GENERIC.DESCRIBE then
    local G = STRINGS.CHARACTERS.GENERIC.DESCRIBE
    G.XYDZTZ_FUTON = "Trong núi Phương Thốn ẩn chứa diệu lý, bồ đoàn này có thể dùng để tham thiền."
    G.XYDZTZ_ARMOR_MADAMEWEB = "Ẩn ẩn có lưu quang di chuyển, pháp y này như thể có sinh mệnh đang tự vá."
    G.XYDZTZ_CUNXIN_JINGPO = "Linh vận thuần khiết! Không biết là khổ tu từ đâu mà có được tạo hóa này."
end

-- =================================================================
-- Myth character-specific examine text
-- =================================================================
local function SetCharDescribe(char, item, text)
    if STRINGS.CHARACTERS[char] and STRINGS.CHARACTERS[char].DESCRIBE then
        STRINGS.CHARACTERS[char].DESCRIBE[item] = text
    end
end

SetCharDescribe("MONKEY_KING", "XYDZTZ_FUTON", "Năm xưa lão Tôn ta ở Linh Đài Phương Thốn Sơn, cũng từng ngồi cái này!")
SetCharDescribe("YANGJIAN", "XYDZTZ_FUTON", "Dù nhục thân đã thành thánh, kiếp vận nơi linh đài vẫn cần tĩnh tọa mới khám phá được.")
SetCharDescribe("NEZA", "XYDZTZ_FUTON", "Tiểu gia ta thiên sinh linh đài thanh minh, ngồi không ở đây chẳng bằng đi trừ ma.")
SetCharDescribe("PIGSY", "XYDZTZ_FUTON", "Tu gì linh đài thốn tâm, ngồi trên này chẳng bằng nằm cho thoải mái.")
SetCharDescribe("WHITEBONE", "XYDZTZ_FUTON", "Cởi bỏ lớp da giả, chính hợp để ngưng luyện huyền âm cốt khí của bản tọa.")
SetCharDescribe("MADAMEWEB", "XYDZTZ_FUTON", "Kiếp số trời đất chỉ là con mồi của mạng tơ. Hãy để ta ngưng kết vài sợi thốn tâm tại đây.")
SetCharDescribe("MADAMEWEB", "XYDZTZ_ARMOR_MADAMEWEB", "Thốn tâm tinh phách ngàn tơ kết. Thiên la địa võng của bản tọa đâu thể bị đao binh phàm gian phá?")
SetCharDescribe("MYTH_YUTU", "XYDZTZ_FUTON", "Nguyệt hoa như nước, soi rõ linh đài. Ngồi nơi đây khiến người tâm tĩnh.")
SetCharDescribe("YAMA_COMMISSIONERS", "XYDZTZ_FUTON", "Nơi giao giới âm dương, có thể ngộ lý sinh tử.")

-- =================================================================
-- XYDZTZ custom strings
-- =================================================================
if STRINGS.XYDZTZ then
    STRINGS.XYDZTZ.TUDI_ASK_LINE = "Thượng tiên có phải tìm Linh Đài Phương Thốn Sơn ngoài biển? Lão già tuy chỉ quản mảnh đất nhỏ, nhưng tiên sơn linh khí xông trời, lão biết phương hướng."
end

print("[Myth-Viet] Đã override STRINGS cho Patch mod.")

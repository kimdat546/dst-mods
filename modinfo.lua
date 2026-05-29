name = "Phàm Nhân Tu Tiên [Alpha]"
description = [[
Mod tu tiên lấy cảm hứng từ tiểu thuyết 「凡人修仙传」(Phàm Nhân Tu Tiên Truyện) của 忘语.

Mọi người chơi bắt đầu từ phàm nhân với linh căn ngẫu nhiên (Ngụy/Chân/Biến Dị/Thiên), tìm linh mạch huyệt trên map, hấp thu linh khí để tu cảnh giới Luyện Khí 9 tầng.

Tính năng MVP1:
• Linh căn ngẫu nhiên (4 loại × 5 hệ — Kim/Mộc/Thủy/Hỏa/Thổ + 6 combo Biến Dị)
• Luyện Khí 9 tầng tự đột phá theo threshold tu vi
• Tuổi thọ + permadeath: phàm nhân = 60 ngày, mỗi tầng +5 ngày, hết thọ = chết già
• Linh mạch huyệt (3 phẩm Hạ/Trung/Thượng) trải worldgen
• Tọa thiền (×1.5 bonus) trên linh mạch
• Vanilla mobs cũng tu trong aura → Linh thú (5min) → Yêu tu (15min)
• Nội đan drop khi giết mobs đã tu (3 phẩm)
• Linh thảo forage từ biomes — buff 5 phút (sanity regen/speed/fire resist)
• HUD 4 dòng: linh căn / cảnh giới / tu vi / tuổi thọ + "đột phá" celebration
• 10 debug commands cho dev iteration

ALPHA: chỉ tester nội bộ. Permadeath bật mặc định. Asset placeholder.
]]
author = "kimdat546"
version = "0.1.19-mvp1"

forumthread = ""

api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "phamnhan", "tu tiên", "xianxia" }

priority = -50  -- chạy sau hầu hết mod khác để override character list cuối

configuration_options = {
    -- Plan 1: chưa có config option nào. Plan 2+ sẽ thêm.
}

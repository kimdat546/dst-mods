name = "Phàm Nhân Tu Tiên"
description = [[
Mod tu tiên lấy cảm hứng từ tiểu thuyết 「凡人修仙传」(Phàm Nhân Tu Tiên Truyện) của 忘语.

Tất cả player bắt đầu từ phàm nhân với linh căn ngẫu nhiên, tự tìm linh dược, tu cảnh giới qua tích lũy linh khí.

MVP1 (Plan 1): mod skeleton — character "phàm nhân" tồn tại, chưa có gameplay cultivation.
]]
author = "kimdat546"
version = "0.1.0-p1"

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

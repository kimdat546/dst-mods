name = "Tu Tiên Lite (Đăng Tiên gọn nhẹ)"
description = "Hệ thống tu tiên đơn giản: cảnh giới, linh thạch, thần thông. Viết mới hoàn toàn, lấy cảm hứng từ thể loại tiên hiệp."
author = "kimdat546 + Claude"
version = "1.0.0"
forumthread = ""

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true
client_only_mod = false
api_version = 10

priority = 0

server_filter_tags = {"tu tien"}

-- danh sách phím để chọn cho cấu hình (keycode chuẩn của engine)
local keylist = {
    {description = "Z", data = 122},
    {description = "X", data = 120},
    {description = "C", data = 99},
    {description = "V", data = 118},
    {description = "F", data = 102},
    {description = "G", data = 103},
    {description = "R", data = 114},
    {description = "T", data = 116},
}

configuration_options =
{
    {
        name = "skillkey",
        label = "Phím thần thông",
        options = keylist,
        default = 122, -- Z
    },
    {
        name = "exprate",
        label = "Tốc độ tu luyện",
        options = {
            {description = "x1", data = 1},
            {description = "x2", data = 2},
            {description = "x5", data = 5},
        },
        default = 1,
    },
}

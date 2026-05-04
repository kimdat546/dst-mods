name = "Đăng Tiên - Tiếng Việt"
description = "Bản dịch tiếng Việt cho mod Đăng Tiên (登仙) - Workshop ID: 3235319974\n\nYêu cầu: Phải subscribe và bật mod gốc Đăng Tiên trước.\n\nPhiên bản: 0.1.0 (alpha - đang phát triển)"
author = "kimdat546"
version = "0.1.0"

forumthread = ""
api_version = 10
priority = -10000

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = false
client_only_mod = true

server_filter_tags = {"vn", "vietnamese", "dang-tien", "kimdat546"}

configuration_options = {
    {
        name = "DEBUG_SCANNER",
        label = "Scanner (debug)",
        hover = "Dump STRINGS có Hán tự ra client_log.txt. Tắt khi chơi bình thường.",
        options = {
            {description = "Tắt", data = false},
            {description = "Bật", data = true},
        },
        default = false,
    },
    {
        name = "DEBUG_MISSING",
        label = "Log string thiếu (debug)",
        hover = "Ghi log Hán tự chưa dịch khi gặp ở runtime.",
        options = {
            {description = "Tắt", data = false},
            {description = "Bật", data = true},
        },
        default = false,
    },
}

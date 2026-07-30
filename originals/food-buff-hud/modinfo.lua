name = "Food Buff HUD"
description = [[Hiện các hiệu ứng (buff) từ thức ăn đang có tác dụng, kèm ĐỒNG HỒ ĐẾM NGƯỢC chính xác — để biết đúng lúc nào cần ăn tiếp.

Phủ các buff từ:
- Món đặc biệt của Warly (Bít tết Sốc Điện, Cá Cordon Bleu...)
- Món nêm gia vị: ớt (tăng sát thương), tỏi (giảm sát thương nhận), đường (làm việc nhanh)
- Và mọi buff khác của game dùng chung cơ chế đó — kể cả món Klei thêm về sau

CÁCH DÙNG
- Có buff thì HUD tự hiện, hết buff tự ẩn.
- Sắp hết (dưới 30 giây) thì đổi màu để bạn kịp ăn tiếp.
- GIỮ CHUỘT PHẢI kéo để đổi vị trí HUD, thả ra là tự lưu.

VÌ SAO CẦN CÀI Ở SERVER
Thời gian còn lại của buff chỉ tồn tại phía server (component debuffable/timer
không có bản sao cho client). Nên mod tính ở server rồi gửi số thật xuống.
Các mod tương tự chỉ chạy phía client buộc phải đoán theo thời lượng cố định,
nên sai khi buff được gia hạn hoặc khi bạn vào server giữa lúc buff đang chạy.

Người chơi KHÔNG cần cài trước: DST tự tải mod khi họ vào server.

CHƯA PHỦ
- Muối không tạo buff (nó chỉ +25% hồi máu của chính món ăn) nên không có gì để đếm.
- Vài hiệu ứng dùng cơ chế riêng chứ không phải buff có thời hạn: jellybean, wormlight,
  trà, elixir của Wendy.]]
author = "kimdat546"

version = "1.0.0"
-- Client cũ/mới đều vào được, miễn >= mốc này. Chỉ nâng khi đổi định dạng RPC
-- theo cách không tương thích (lúc đó chặn mới là đúng).
version_compatible = "1.0.0"

forumthread = ""
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

-- Phải chạy ở server để đọc được timer thật. all_clients_require_mod = true nên
-- client tự tải khi join (mod tạm, không thêm vào danh sách sub của họ).
-- Hai cờ client_only_mod và all_clients_require_mod loại trừ nhau.
all_clients_require_mod = true
client_only_mod = false

server_filter_tags = { "buff", "hud", "food" }

configuration_options = {
    {
        name = "SHOW_HUD",
        label = "Hiện HUD",
        hover = "Tắt nếu bạn không muốn thấy HUD. Chỉ ảnh hưởng máy bạn.",
        options = {
            { description = "Bật", data = true },
            { description = "Tắt", data = false },
        },
        default = true,
    },
    {
        name = "WARN_SECONDS",
        label = "Cảnh báo trước",
        hover = "Còn bao nhiêu giây thì đổi màu để nhắc ăn tiếp.",
        options = {
            { description = "10 giây", data = 10 },
            { description = "30 giây", data = 30 },
            { description = "60 giây", data = 60 },
            { description = "Tắt",     data = 0 },
        },
        default = 30,
    },
}

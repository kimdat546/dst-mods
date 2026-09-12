-- ═══════════════════════════════════════════════════════════════════════
--  AI Làng — dân làng NPC có não, chơi cùng người chơi thật
--
--  Viết mới hoàn toàn. Có tham khảo ý tưởng và cách bố trí từ hai mod MIT:
--    - hineios/FAtiMA-DST          (2018)
--    - votus777/DST-AICompanion    (2024)
--  KHÔNG dùng lại mã của hai mod đó: kiến trúc HTTP của chúng đã chết trên
--  DST hiện tại (xem README, mục "Vì sao không dùng lại").
-- ═══════════════════════════════════════════════════════════════════════

name = "AI Làng - Đừng Chết Đói :)"
description = [[Dân làng NPC tự sống, tự làm việc, và biết nói chuyện.

Có gì:
- Dân làng là nhân vật thật (mặc giáp, cầm vũ khí, ăn cơm như người chơi)
- Não phản xạ chạy thẳng trong game: chặt cây, nhặt đồ, đánh trả, chạy trốn,
  ăn khi đói, về nhà khi tối
- Tầng "suy nghĩ" tuỳ chọn: nối ra dịch vụ ngoài (Gemini hoặc model local)
  để dân làng có mục tiêu riêng và biết trò chuyện

Không bật dịch vụ ngoài thì dân làng vẫn sống và làm việc bình thường.]]
author = "kimdat546"
version = "0.1.0"

forumthread = ""
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

-- ⚠ CLIENT BẮT BUỘC PHẢI CÓ MOD. Đừng đổi về false.
--
--   Ban đầu mod cố ý chạy server-only để không ai phải cài gì. Nhưng Đài
--   Triệu Hồi là PREFAB TỰ TẠO, và client không nạp mod thì không dựng nổi
--   nó: người chơi vào game bị ĐƠ, log client đầy
--       RakNet detected a missing replica
--   Dùng hình ảnh vanilla KHÔNG đủ — bản thân prefab phải tồn tại ở client.
--
--   Dân làng thì không sao vì chúng là prefab người chơi vanilla. Nhưng mọi
--   công trình riêng, mọi giao diện (bảng điều khiển, xem hành trang) đều đòi
--   phần chạy ở client.
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "ai", "npc", "village" }

configuration_options =
{
    {
        name = "so_dan_lang",
        label = "Số dân làng",
        hover = "Bao nhiêu dân làng được sinh ra lúc tạo thế giới mới.",
        options =
        {
            { description = "0 (tự gọi bằng lệnh)", data = 0 },
            { description = "1", data = 1 },
            { description = "2", data = 2 },
            { description = "3", data = 3 },
            { description = "5", data = 5 },
        },
        default = 3,
    },
    {
        name = "ban_kinh_lang",
        label = "Bán kính làng",
        hover = "Vùng quanh Đài Triệu Hồi mà dân làng coi là nhà: chúng ưu tiên\nđánh quái, dập lửa và cất đồ trong vùng này.",
        options =
        {
            { description = "Nhỏ (40)", data = 40 },
            { description = "Vừa (60)", data = 60 },
            { description = "Lớn (80)", data = 80 },
        },
        default = 60,
    },
    {
        name = "bat_tam_tri",
        label = "Tầng suy nghĩ",
        hover = "Bật thì dân làng hỏi dịch vụ ngoài để chọn mục tiêu và trò chuyện.\nTắt thì chỉ chạy não phản xạ — vẫn làm việc bình thường.",
        options =
        {
            { description = "Tắt", data = false },
            { description = "Bật", data = true },
        },
        default = false,
    },
    {
        name = "nhip_suy_nghi",
        label = "Nhịp suy nghĩ",
        hover = "Bao lâu dân làng hỏi tầng suy nghĩ một lần. Dài thì rẻ, ngắn thì nhanh nhạy.",
        options =
        {
            { description = "5 giây", data = 5 },
            { description = "15 giây", data = 15 },
            { description = "30 giây", data = 30 },
            { description = "60 giây", data = 60 },
        },
        default = 15,
    },
    {
        name = "muc_log",
        label = "Mức ghi log",
        hover = "Gỡ lỗi thì bật Chi tiết, chơi thật thì để Ít.",
        options =
        {
            { description = "Tắt", data = 0 },
            { description = "Ít", data = 1 },
            { description = "Chi tiết", data = 2 },
        },
        default = 1,
    },
}

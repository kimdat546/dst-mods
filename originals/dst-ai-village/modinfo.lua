-- ═══════════════════════════════════════════════════════════════════════
--  AI Làng — dân làng NPC có não, chơi cùng người chơi thật
--
--  Viết mới hoàn toàn. Có tham khảo ý tưởng và cách bố trí từ hai mod MIT:
--    - hineios/FAtiMA-DST          (2018)
--    - votus777/DST-AICompanion    (2024)
--  KHÔNG dùng lại mã của hai mod đó: kiến trúc HTTP của chúng đã chết trên
--  DST hiện tại (xem README, mục "Vì sao không dùng lại").
-- ═══════════════════════════════════════════════════════════════════════

name = "AI NPC - Đừng Chết Đói :)"
description = [[Dân làng NPC tự sống, tự làm việc cùng bạn.

BẢN THỬ NGHIỆM — mod còn mới, dân làng có lúc làm chuyện ngớ ngẩn hoặc chết
lãng xẹt. Gặp lỗi, thấy chúng kẹt, hay game báo lỗi khi bật mod thì báo giúp ở
phần bình luận bên dưới. Kèm file client_log.txt (Documents/Klei/
DoNotStarveTogether) ngay sau khi lỗi — trước khi mở lại game, vì game xoá
log mỗi lần khởi động.

BẮT ĐẦU
- Thế giới mới sẽ có sẵn 3 dân làng (đổi số lượng trong cấu hình mod)
- Chưa có nhà thì dân làng đi theo bạn
- Dựng ĐÀI TRIỆU HỒI (2 vàng + 8 gỗ + 6 đá, không cần máy) — đó là NHÀ của
  cả làng, và là chỗ gọi thêm dân làng mới

DÂN LÀNG BIẾT LÀM GÌ
- Tự chặt cây, đào đá, hái cỏ, nhặt đồ; cầm đuốc khi tối, dựng và giữ lửa trại
- Tự lo ăn: đặt bẫy thỏ, nướng thịt, cất đồ ăn vào rương
- Góp chung nguyên liệu để dựng Máy Khoa Học, rương, nồi
- Mỗi người một nghề (kiếm ăn / thợ mỏ / giữ nhà) nên không dồn cục
- Đánh trả khi bị tấn công, trốn nắng mùa hè, về bên lửa khi đêm xuống
- Chết thì thành hồn ma, tự tìm Đài để sống lại

TƯƠNG TÁC
- Cho ăn để tăng thân thiết; đủ thân thì chúng chịu đi theo bạn
- Mở túi hàng của dân làng để lấy đồ chúng gom được
- Lệnh console cho chủ server: c_ailang_bang() xem danh sách,
  c_ailang_chienluoc() xem kho và nút thắt của làng

TẦNG SUY NGHĨ (tuỳ chọn, cho người rành kỹ thuật)
Mặc định TẮT. Bật lên thì cần chạy thêm một dịch vụ ngoài (Gemini hoặc model
chạy máy nhà) để dân làng tự lên kế hoạch và trò chuyện. Không bật thì dân
làng vẫn sống và làm việc bình thường.

LƯU Ý
- Mod server: mọi người vào server đều cần bật mod
- Mỗi dân làng tốn CPU gần bằng một người chơi — đừng gọi quá đông]]
author = "kimdat546"
version = "0.2.0"

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

-- ⚠ KHÔNG KHAI BÁO ICON CHỪNG NÀO CHƯA CÓ FILE THẬT. Mod vốn khai
--   icon_atlas/icon trỏ tới modicon.xml + modicon.tex mà hai file đó CHƯA BAO
--   GIỜ tồn tại, nên mỗi lần nạp mod là một dòng cảnh báo. Khai một thứ không
--   có còn tệ hơn là không khai: người đọc log phải đi xác minh xem nó có
--   nghĩa gì không.
--
--   Muốn có icon thì cần `ktech` của Don't Starve Mod Tools chuyển PNG sang
--   .tex — máy này chưa có. Làm xong ảnh thì đặt modicon.png cạnh modinfo.lua,
--   chạy ktech, rồi mở lại hai dòng dưới:
--       icon_atlas = "modicon.xml"
--       icon = "modicon.tex"

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

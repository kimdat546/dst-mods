name = "Đăng Tiên - Đừng Chết Đói :)"
description = [[Bản dịch tiếng Việt cho mod 【登仙】(Đăng Tiên).

Mình làm cái này ban đầu chỉ để chơi với mấy đứa bạn, nhưng nghĩ chắc cũng có nhiều người Việt thích mod tu tiên mà ngại tiếng Trung như mình, nên up luôn lên đây cho ai cần thì dùng.

YÊU CẦU
- Phải sub và bật mod 登仙 gốc trước (Workshop ID: 3235319974).
- Mod này phải load sau mod gốc.

ĐÃ DỊCH
- Tên item, recipe, mô tả khi inspect — khoảng 2000 dòng.
- Toàn bộ thoại của Vương Ma Tử (vai cultivator nói kiểu kiêu ngạo "bổn tôn", "Vương Mỗ"...) — 2951 dòng.
- Mô tả skill, buff của pháp bảo.
- NPC dialogue (Tử Vân chân quân, lão phu Khúc Tiên...).
- Một số UI tooltip hay gặp.
- Đã bắt kịp mod gốc v19.0: toàn bộ vật phẩm và mô tả của nhân vật mới Trần Bình An (Bắc Đẩu, Thanh Bình, Thập Ngũ, Trảm Long Đài, cây thanh mai...) cùng menu dùng vật phẩm.

CHƯA DỊCH
- Thoại 9 nhân vật còn lại: Trần Bình An, Hàn Thiên Tôn, Long Thái Tử, Tinh Vệ, Tô Đát Kỷ, Ngộ Không, Lạc Thần, Vân Tiêu, Thi Cơ. Mỗi nhân vật ~3000 dòng, dịch dần.
- Nội dung Tu Tiên Mật Quyển. Tác giả mod gốc đóng gói thành ảnh nên phải vẽ lại, đang tìm cách xử lý.
- Một số nhãn nướng sẵn trong ảnh giao diện (Ngoại trang, Nhân vật, Đổi...).

LƯU Ý
- Mod chỉ thay text, không động vào logic game, không hỏng save.
- Nếu thấy chữ Trung còn sót, bật option "Log string thiếu" trong settings rồi gửi cho mình client_log.txt + ảnh chụp.
- Khi mod gốc update, mod này sẽ chậm vá hơn vài hôm.

Cảm ơn tác giả 登仙 đã làm ra một mod hay như vậy. Nếu thấy hữu ích thì cho mình 1 like.

Cập nhật: 2026-07-26 — bắt kịp mod gốc v19.0]]
author = "kimdat546"
version = "1.1.0"

forumthread = ""
api_version = 10
priority = -10000

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = false
client_only_mod = true

-- icon_atlas = "modicon.xml"  -- TODO: add modicon for v1.1
-- icon = "modicon.tex"

server_filter_tags = {"vn", "vietnamese", "dang-tien", "dengxian"}

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
        hover = "Ghi log Hán tự chưa dịch khi gặp ở runtime. Bật khi muốn báo lỗi.",
        options = {
            {description = "Tắt", data = false},
            {description = "Bật", data = true},
        },
        default = false,
    },
}

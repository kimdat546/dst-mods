name = "Đăng Tiên - Đừng Chết Đói :)"
description = [[Bản dịch tiếng Việt cho mod 【登仙】(Đăng Tiên).

Mình làm cái này ban đầu chỉ để chơi với mấy đứa bạn, nhưng nghĩ chắc cũng có nhiều người Việt thích mod tu tiên mà ngại tiếng Trung như mình, nên up luôn lên đây cho ai cần thì dùng.

YÊU CẦU
- Phải sub và bật mod 登仙 gốc trước (Workshop ID: 3235319974).
- Mod này phải load sau mod gốc.

MỚI Ở BẢN NÀY (1.3.0)
- Bắt kịp mod gốc v20.0.
- Dịch TRỌN BỘ nhân vật mới Cổ Nguyệt Phương Nguyên (Đại Ái Tiên Tôn): 3964 dòng
  thoại, cùng toàn bộ cổ trùng (Xuân Thu Thiền, Định Tiên Du, Vô Túc Điểu,
  Thiên Nguyên Bảo Liên, Vạn Cổ Ốc...) và skin mới.
- Món ăn mới: cỏ Sinh Cơ, canh lá Sinh Cơ, bánh Cửu Diệp Sinh Cơ.
- Vá thêm thoại Vương Ma Tử, Trần Bình An còn sót.
- Giao diện Tiên Khiếu (lắp cổ trùng): tên, hiệu ứng, hồi chiêu đều tiếng Việt.
- Dịch TRỌN BỘ Tu Tiên Mật Quyển (sách hướng dẫn dạng ảnh): đủ 41 trang —
  cảnh giới & đan dược, Linh Bảo, Nhàn Vân Dã Hạc, Dị Thú và các nhân vật.
- Thống nhất tên theo DST Tiếng Việt (Ngọc Đỏ/Lam/Lục/Tím…), sửa vài tên
  Hán-Việt sai âm (Phần Thiên Kiếm, Tà Trá Ma Chu, Dưỡng Hồn Chuỷ Thủ).

ĐÃ DỊCH
- Tên item, recipe, mô tả khi inspect — khoảng 2000 dòng.
- Toàn bộ thoại Vương Ma Tử (giọng kiêu ngạo "bổn tôn", "Vương Mỗ"...) — 2951 dòng.
- Toàn bộ thoại Trần Bình An (giọng mộc mạc chân chất) — 3447 dòng.
- Toàn bộ thoại Cổ Nguyệt Phương Nguyên (giọng lạnh lùng, thực dụng) — 3964 dòng.
- Mô tả skill, buff của pháp bảo.
- NPC dialogue (Tử Vân chân quân, lão phu Khúc Tiên...).
- Một số UI tooltip hay gặp.

CHƯA DỊCH
- Thoại 8 nhân vật còn lại: Hàn Thiên Tôn, Long Thái Tử, Tinh Vệ, Tô Đát Kỷ,
  Ngộ Không, Lạc Thần, Vân Tiêu, Thi Cơ. Mỗi người ~3000 dòng, dịch dần.
- Một số nhãn nướng sẵn trong ảnh giao diện (Ngoại trang, Nhân vật, Đổi...).

LƯU Ý
- Mod chỉ thay text, không động vào logic game, không hỏng save.
- Nếu thấy chữ Trung còn sót, bật option "Log string thiếu" trong settings rồi gửi cho
  mình client_log.txt + ảnh chụp. Có log là vá được đúng chỗ.
- Khi mod gốc update, mod này sẽ chậm vá hơn vài hôm.

Cảm ơn tác giả 登仙 đã làm ra một mod hay như vậy. Nếu thấy hữu ích thì cho mình 1 like.

Cập nhật: 2026-10-18 — v20.0 + trọn bộ thoại Cổ Nguyệt Phương Nguyên + trọn bộ Tu Tiên Mật Quyển]]
author = "kimdat546"
version = "1.3.0"

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

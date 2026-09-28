# Hướng dẫn dịch / soát — DST Tiếng Việt

Bạn làm MỘT lô trong `viec/`. Mỗi dòng lô: `khoa<TAB>en<TAB>vi_hien_tai<TAB>goi_y`
(dòng đầu là tiêu đề). `\n` trong ô là xuống dòng thật của game — giữ nguyên
dạng `\n` khi ghi ra.

## Kết quả

Ghi file `viec/<tên lô>.ra.tsv` (vd lô `viec/dich_03.tsv` → `viec/dich_03.ra.tsv`),
KHÔNG tiêu đề, mỗi dòng: `khoa<TAB>bản_dịch_tiếng_Việt`. UTF-8. Không sửa file nào khác.

- Lô **dich_*** / **dich_skin_***: ghi MỌI dòng của lô.
- Lô **soat_***: CHỈ ghi dòng bạn SỬA (bản dịch hiện tại sai nghĩa, sai thuật ngữ,
  lỗi chính tả, câu lủng củng khó hiểu, sót tiếng Anh). Dòng ổn thì bỏ qua. Không
  sửa chỉ vì "thích cách khác" — chỉ sửa khi người chơi sẽ hiểu sai hoặc thấy lỗi.
  Cuối việc, báo lại số dòng đã sửa và 10 ví dụ tiêu biểu (cũ → mới, lý do).

## Quy tắc bắt buộc

1. **Placeholder giữ y nguyên**: `%s` `%d` `%.1f` `{name}` `{item}`… Số lượng và tên
   phải khớp bản tiếng Anh. Không dịch chữ trong `{}`.
2. **Không thêm ghi chú** kiểu "(Chơi chữ với …)", "(Lưu ý: …)" — người chơi thấy
   nguyên văn trong game. Chơi chữ thì tìm cách chơi chữ tiếng Việt, hoặc dịch nghĩa.
3. **Không dùng tab** trong bản dịch. Dấu nháy kép `"` dùng bình thường.
4. **Tên vật phẩm / sinh vật**: tra `viec/tu_dien.tsv` (khoa, en, vi) — dùng ĐÚNG tên
   Việt đã có. Cột `goi_y` của câu soi đồ cho sẵn `Tên Anh = Tên Việt` của vật được
   nói tới (`?` = chưa có tên Việt → tự dịch tên đó cho hợp). Tên riêng nhân vật
   (Wilson, Webber, Charlie, Maxwell…) và tên boss quen thuộc (Deerclops, Bearger…
   xem tu_dien) giữ theo tu_dien.
5. **Giọng nhân vật** (khoá `STRINGS.CHARACTERS.<NHÂN_VẬT>.…`): giữ giọng đã có —
   hầu hết xưng "tôi"; **WEBBER** xưng "chúng tôi/chúng mình" (hai đứa trong một);
   **WOLFGANG** tự gọi mình là "Wolfgang", câu ngắn, hơi ngô nghê; **WX78** robot,
   CHỮ HOA như bản Anh nếu bản Anh viết hoa, gọi người là "THỊT"/"SINH VẬT THỊT";
   **WORMWOOD** câu cực ngắn, ngây ngô, gọi đồ vật như bạn bè; **WURT** người cá
   nhỏ, hay "glurph/flort"; **WICKERBOTTOM** thủ thư uyên bác, trang trọng;
   **WAXWELL** kiêu kỳ, mỉa mai; **WORTOX** tinh nghịch, thích vần điệu;
   **WATHGRITHR** chiến binh hào hùng; **WARLY** đầu bếp, hay tiếng Pháp nhẹ;
   **WALTER** hướng đạo sinh hăng hái; **WANDA** vội vã, ám ảnh thời gian;
   **WENDY** u sầu; **WILLOW** mê lửa; **WOODIE** hiền, nói với rìu Lucy;
   **WINONA** thợ máy thẳng tính. GENERIC = Wilson, nhà khoa học.
   Muốn xem giọng cụ thể: `grep 'STRINGS.CHARACTERS.WEBBER.DESCRIBE' -A3 vietnamese.po | head -60`.
6. Tiếng kêu / từ tượng thanh ("Bzzt!", "Glurgh...", "Eep!") giữ hoặc đổi sang
   tượng thanh Việt tương đương; đừng để y tiếng Anh nếu có chữ thường đọc được
   (vd "Shoo!" → "Xùy!").
7. Tên trang phục (SKIN_NAMES): dịch thành tên gọi hay, ngắn, viết hoa chữ đầu mỗi
   từ như tên riêng; phần tên vật dùng đúng tu_dien (vd "Jagged Dragonfly Armor" →
   "Giáp Dragonfly Lởm Chởm" vì tu_dien giữ tên boss Dragonfly). Tên
   riêng/nhãn hiệu (Victorian, Gladiator…) được dịch nghĩa hoặc phiên cho tự nhiên.
8. Chính tả tiếng Việt chuẩn, đủ dấu. Không bỏ sót câu.

Tham khảo thêm bản dịch tiếng Trung chính thức của game: `game_source/chinese_s.po`
(cùng msgctxt) — hữu ích khi tiếng Anh mơ hồ.

## Bảng chữ bộ sưu tập trang phục (BẮT BUỘC cho SKIN_NAMES)

Chữ đã chốt — mọi tên trang phục thuộc bộ nào thì dùng đúng chữ của bộ đó:

| hậu tố khoá / tên Anh | Việt |
|---|---|
| victorian | Victoria |
| formal (đồ) / Guest of Honor (tên bộ nhân vật) | Dạ Hội / Khách Danh Dự |
| survivor / The Survivor | Sinh Tồn / Người Sống Sót |
| shadow / Triumphant | Khải Hoàn ("Shadow X" = "X Bóng Tối") |
| rose / Roseate, Rosy | Hoa Hồng (tên bộ nhân vật: Sắc Hồng) |
| nature / Verdant | Xanh Tươi (Flowery = Hoa Lá) |
| gladiator | Đấu Sĩ |
| magma / Magmatic | Dung Nham |
| ice / Snowfallen | Băng Giá |
| yule / Merrymaker | Hội Hè |
| hallowed / Hallowed Nights | Đêm Hội Ma |
| western / Stampeder | Cao Bồi |
| 20s / Roaring, Roarer | Thập Niên 20 |
| valkyrie / Winged Victory | Nữ Thần Chiến Thắng |
| northern / Nordic | Bắc Âu |
| invisible / Pantomimed | Kịch Câm |
| harlequin / Fool | Chú Hề |
| haunteddoll / Forlorn Doll | Búp Bê Sầu Muộn |
| wrestler / Contender | Đô Vật |
| costume / "X Costume" | Hóa Trang / Trang Phục X |
| deluxe | Cao Cấp |
| lunar / Moonbound | Nhuốm Trăng |
| ancient / Archaic | Cổ Xưa |
| combatant / Challenger | Thách Đấu |
| hazard / Hermetic | Kín Bưng |
| doll / festive / beast (Lucky Beast) / robot (Ironclad) / war | Búp Bê / Lễ Hội / Kỳ Lân / Bọc Thép / Chiến Binh |
| Complete / Essential X / "X Emote" / Ugly … Sweater | Trọn Bộ / X Nguyên Bản / Biểu Cảm X / Áo Len Xấu Xí … |
| Beefalo Caparison/Headgear/Shoes/Horns/Tail | Áo Phủ / Mũ / Giày / Sừng / Đuôi |
| Hound | Chó Săn |
| pirate / The Swashbuckler | Cướp Biển |
| masquerade / The Masquerader | Kẻ Đeo Mặt Nạ |
| cook / The Culinarian | Đầu Bếp |
| retro / The Experiment | Vật Thí Nghiệm |
| "skin" (trong mô tả rương) | trang phục — KHÔNG dịch "da" |

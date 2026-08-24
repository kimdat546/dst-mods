# Đăng Tiên — Dữ liệu Wiki

> Tài liệu tham chiếu được trích xuất từ wiki PDF tiếng Việt (186 trang) của mod 「登仙」(Dengxian) cho Don't Starve Together, đối chiếu với `daxsg_mod_path.txt` để gắn mỗi entity tới prefab cụ thể.
>
> **Nguồn:** `Đăng-Tiên.pdf` (186 trang, fan-translate sang tiếng Việt) + cross-reference `dengxian_architecture.md` (Layer 1) + `dengxian_gameplay_glossary.md` (Layer 2) + `daxsg_mod_path.txt` (index 532 dòng).
>
> **Cách đọc:** mỗi entry pháp bảo/đan dược/boss có dòng `**Prefab:**` hoặc `**Prefab đoán:**` để tra tới Lua file. Khi tài liệu PDF không có thông tin (HP/dame/drop) thì ghi rõ "PDF không nêu" — KHÔNG đoán bừa.

---

## 0. Mục lục & nguồn

Trích từ PDF (trang 2-3):

| # | Section PDF | Trang | Ánh xạ section bên dưới |
|---|---|---|---|
| 1 | Nhân vật | 4 | §1 |
|   | — Vương Ma Tử | 4 | §1.1 |
|   | — Thạch Cơ Nương Nương | 10 | §1.2 |
|   | — Hàn Thiên Tôn | 16 | §1.3 |
|   | — Tam Tiêu Nương Nương | 24 | §1.4 |
|   | — Tinh Vệ | 31 | §1.5 |
|   | — Tôn Ngộ Không | 36 | §1.6 |
|   | — Tô Đát Kỷ | 44 | §1.7 |
|   | — Ngao Bính | 51 | §1.8 |
| 2 | Cảnh giới Luyện Thể | 55 | §3.1 |
| 3 | Hệ thống Thiên Lệch Bản Nguyên & Yêu Linh Thánh Thể | 56 | §3.2 |
| 4 | Thế Giới Thăng Cách | 59 | §3.3 |
| 5 | Vô Thượng Ma Thể & Công Đức Kim Thân | 61 | §3.4 |
| 6 | Tiên Ma Chi Kiếm | 65 | §4 |
| 7 | Luyện Khí Cảnh Giới (đột phá tổng thể) | 66 | §2 |
| 8 | Linh Bảo | 73 | §5 |
| 9 | Chuyên Chức Pháp Bảo | 80 | §6 |
| 10 | Linh Mộc Thần Thụ (Sa Đẳng, Phản Hồn) | 111 | §10 |
| 11 | Trang trí | 116 | §11 |
| 12 | Địa Luyện Thể | 122 | §12 |
| 13 | Côn Bằng Tiên Đảo | 124 | §13 |
|   | — Tử Vân Ma Quân | 132 | §13.x |
| 14 | Vấn Đạo Đan Kiếp | 135 | §7 |
| 15 | LINH THẢO | 140 | §8 |
| 16 | ĐAN DƯỢC | 143 | §9 |
| 17 | KHO CHỨA | 152 | §14 |
| 18 | CÔNG TRÌNH | 156 | §15 |
| 19 | Thái Cổ Dị Thú (6 boss) | 166 | §16 |

**Ghi chú nguồn:**
- PDF 186 trang, đối chiếu `daxsg_mod_path.txt` (274 prefab).
- Mod Workshop ID `3235319974`, prefix prefab thống nhất là `xd_`.
- 8 nhân vật trong PDF + 1 nhân vật (`xd_longtaizi` / Long Thái Tử / Ngao Bính theo PDF) — tổng 9 nhân vật chơi được (xem `dengxian_architecture.md` §3). PDF gọi rồng là "Ngao Bính"; prefab tương ứng là `xd_longtaizi`.
- PDF thiếu (so với prefab list): **Lạc Thần** (`xd_luoshen`) không có trang riêng trong PDF — có thể đã được gộp vào skin hoặc tài liệu chưa cover.

---

## 1. Nhân vật

### 1.1 Vương Ma Tử — `xd_wangmazi` (trang 4-9)

**Chỉ số gốc:** No bụng 200 / Tinh thần 150 / Máu 200
**Món ăn yêu thích:** Canh thịt hầm

**Thiên phú / Đặc tính — Cổ Thần Chi Thể:**
- Tăng 25% giảm sát thương cơ bản
- Tăng thêm 5 điểm giảm sát thương diện rộng
- Tăng thêm 5 điểm công kích diện rộng
- Tốc độ tiêu hao no bụng tăng 100%

**Hiệu quả đặc biệt:**
- Khi ăn thức ăn không bị hiệu ứng giảm máu
- Mang theo quang hoàn giảm tinh thần chậm, đồng thời tác động cả lên bản thân
- Cứ mỗi 120 giây, khi tấn công hoặc bị tấn công sẽ khiến sinh linh xung quanh rơi vào trạng thái sợ hãi

**Pháp bảo riêng:**

| Tên | Prefab đoán | Loại | Tác dụng | Tái luyện khi thất lạc |
|---|---|---|---|---|
| Thiên Nghịch Châu | `xd_wmz_tnz` | Pháp bảo | Sinh ra đã mang theo, có không gian nội giới; nhấp phải vào nội giới (tiêu hao độ bền); trong nội giới hồi chậm máu/tinh thần/no bụng; tự hồi độ bền theo thời gian | Tử Sát Ma Vũ ×2, Vàng ×5, Lục bảo thạch ×10, Thượng phẩm linh thạch ×3 |
| Tôn Hồn Phiên | `xd_wmz_zhf` / `xd_zhf` | Pháp bảo (bố trí xuống đất) | Sinh ra đã sở hữu; khi tiêu diệt sinh linh xung quanh sẽ hấp thu hồn phách; tích lũy đủ linh hồn sẽ triệu hồi Hồn Linh của Tôn Hồn Phiên cùng chiến đấu | Hồng bảo thạch ×5, Giấy ×5, Thượng phẩm linh thạch ×1, Tử Sát Ma Vũ ×1 |

**Thần thông trong kỹ năng:**

| Tên | Hồi chiêu | Tác dụng |
|---|---|---|
| Lý Quảng Cung | 20s | Kéo cung bắn tên, gây sát thương đường thẳng tầm xa |
| Tát Đậu Thành Binh | 45s | Ném đậu binh tới vị trí chỉ định hỗ trợ chiến đấu; tồn tại 30s |
| Xạ Thần Chiến Xa – Hồn Linh | 45s | Triệu hồi 3 Hồn Linh bướm của Xạ Thần Chiến Xa, loại bướm ngẫu nhiên: **Bướm Băng** (sát thương + đóng băng), **Bướm Hỏa** (sát thương lửa AOE tại điểm), **Bướm Ám Ảnh** (sát thương bóng tối duy trì) |

**Mộc Điêu Sư Phó (cơ chế đặc biệt):**
- Vương Ma Tử có thể "nhập" vào các mộc điêu (tượng gỗ): Possessed Varg, Kim Phượng, Deerclops, Dragonfly, Moose/Goose, Kỳ Lân, Bearger, Reanimated Skeleton (Viễn Cổ Chức Ảnh Giả).
- Khi Vương Ma Tử tiêu diệt sinh vật tương ứng → kích hoạt công thức chế tác mộc điêu của sinh vật đó.
- Mộc điêu đặt xuống đất; khi sinh vật tiến gần sẽ kích hoạt một lần kỹ năng của sinh vật mộc điêu.

**Chế tác chuyên biệt:**

| Tên | Loại | Tác dụng | Prefab đoán |
|---|---|---|---|
| Khôn Cực Tiên Tiên | Roi | Sau khi đánh trúng mục tiêu sẽ gây hiệu ứng dễ tổn thương (nhận thêm sát thương) trong 45s; có thể trảm sát sinh vật có máu dưới 7% | `xd_wmz_xsj`(?) |
| Sát Lục Tiên Quyết | Pháp bảo | Khi kích hoạt thân ngoại hóa thân; ban cho hóa thân xác suất kích hoạt Huyết Kiếm (thêm dame) để hiệp đồng công kích | `xd_wmz_slxj` |

(PDF trang 4-9 chỉ liệt kê 2 pháp bảo chế tác chuyên biệt trên; các prefab `xd_wmz_db`, `xd_wmz_kjb`, `xd_wmz_md`, `xd_wmz_butterfly`, `xd_wmz_spell` chưa được PDF mô tả riêng — có thể là phần của summon system hoặc internal logic.)

---

### 1.2 Thạch Cơ Nương Nương — `xd_shiji` (trang 10-15)

**Chỉ số gốc:** No bụng 150 / Tinh thần 150 / Máu 200
**Món ăn ưa thích:** Guacamole (bơ nghiền)

**Đặc tính:**
- Không thuộc phe Bóng Tối cũng không thuộc phe Mặt Trăng → khi đối đầu cả hai phe: +7% sát thương, +7% phòng ngự bổ sung
- Giảm sát thương cơ bản +25%
- Khi bắt đầu mang theo: 20 × Đá, 10 × Đá lửa
- Khi bị tấn công, thạch tôm (Stone Lobster) xung quanh sẽ lập tức thù hận và tấn công kẻ địch
- Mỗi khi 1 thạch tôm xung quanh bị giết → giảm 10 điểm tinh thần
- Tốc độ đào mỏ giảm 30%
- Tốc độ tăng thân nhiệt +25%

**Môn hạ song đồng (cơ chế đặc biệt):**
Có thể triệu hồi **Bích Vân Đồng Tử** và **Thái Vân Đồng Tử** trong mục chế tạo.

**Bích Vân Đồng Tử** — `xd_sj_by` (Prefab; brain `xd_sj_bybrain`, SG `SGxd_sj_by`)
- Sau khi triệu hồi tồn tại 4 ngày.
- Phạm vi hoạt động: bán kính 5 ô địa hình.
- Có ô chứa đồ tự bảo quản (giữ tươi) — container `xd_by_container`.
- Hỗ trợ: thu hoạch nông sản, giao tiếp với cây trồng, tưới nước/bón phân, sắp xếp vật phẩm.
- Mỗi buổi sáng đưa cho Thạch Cơ Nương Nương 1 món ăn: 40% Thịt viên / 20% Bánh thanh long / 20% Canh thịt / 20% Há cảo.

**Thái Vân Đồng Tử** — `xd_sj_cy` (Prefab; brain `xd_sj_cybrain`, SG `SGxd_sj_cy`, petleash `xd_petleash_cy`)
- Luôn theo sau Thạch Cơ Nương Nương.
- Có ô chứa đồ riêng.
- Hỗ trợ: đào mỏ, đốn cây.
- Có thể tự động thu thập tài nguyên trong phạm vi nhất định.

**Chế tạo chuyên biệt:**

| Tên | Loại | Prefab đoán | Tác dụng |
|---|---|---|---|
| Khô Lâu Sơn | Công trình | `xd_sj_kls` | Khi nhấp vào có thể tiêu hao tinh thần để điều khiển bất kỳ bộ xương nào trên bản đồ. Bộ xương: hiệu suất chặt cây cao, +10% tốc độ di chuyển, thu thập nhanh. Nhược điểm: máu thấp, nhận thêm 35% sát thương. Khi bộ xương tử vong, thần thức quay về bản thể. |
| Thực Tâm Trụy | Giáp (thân thể) | `xd_sj_tej`(?) | 85% phòng ngự thường; độ bền 840; có thể dùng Trung Phẩm Linh Thạch để bồi dưỡng. Khi mặc: nhiệt độ cơ thể không vượt quá 30 độ, giảm tinh thần chậm. Có thể dùng Hạ Phẩm Linh Thạch để hồi độ bền. Khi chịu sát thương có xác suất miễn dịch 1 lần sát thương. |
| Bát Quái Vân Quang Pháp | Pháp bảo | `xd_sj_bgygp` | Có thể triệu hồi phân thân ngoài thân cường hóa (lõi Hoàng Cân Lực Sĩ). Phân thân có thêm một số kỹ năng. **Nhân vật khác cũng có thể sử dụng.** |
| Bát Quái Long Tu Pháp | Pháp bảo | `xd_sj_bglxp`(?) | Thu thập tài nguyên trong phạm vi nhỏ tại điểm chỉ định. Có thể bắt giữ sinh vật nhỏ trong khu vực: ong, bướm, đom đóm, thỏ, nhện, chim… Có thể dùng Trung Phẩm Linh Thạch để hồi độ bền. |
| Tinh Thạch Yết Đạo Trượng | Pháp trượng | `xd_sj_sxz`(?) | Khi sử dụng: khiến thạch tôm trong khu vực mục tiêu trung thành trong 7 ngày; ban cho +20 phòng ngự diện rộng, giảm tốc đánh của địch, tăng tốc di chuyển. Có thể biến hóa: khoáng thạch, tổ nhện hệ đá → biến thành thạch tôm. |
| Thông Linh Thạch Khiếu | Vật phẩm tiêu hao | `xd_sj_xsydz`(?) | Sau khi chế tạo và đặt xuống đất: sinh ra 1 thạch tôm trung thành với Thạch Cơ Nương Nương trong 7 ngày. |

(Prefab `xd_sj_tlsq` chưa map được trong PDF — có thể là pet/summon nội bộ.)

---

### 1.3 Hàn Thiên Tôn — `xd_hantianzun` (trang 16-23)

**Chỉ số gốc:** No bụng 150 / Tinh thần 150 / Máu 200
**Món ăn ưa thích:** Thịt viên

**Đặc tính:**
- Không thuộc phe Bóng Tối cũng không thuộc phe Mặt Trăng → +7% sát thương, +7% phòng ngự bổ sung khi đối đầu cả hai phe
- +5% tốc độ di chuyển

**Pháp bảo & vật phẩm chuyên biệt:**

**Chưởng Thiên Bình** — Vật phẩm (Prefab đoán: `xd_htz_ztp` hoặc `xd_ztp`)
- Có hiệu quả thúc đẩy tăng trưởng đối với: bụi quả mọng, cành cây, các loại cây trồng, Cây Sa Đường.
- Độ bền gấp 2 lần Chưởng Thiên Bình thông thường.
- Ban đêm tự hồi phục độ bền.

**Linh lực (cơ chế tài nguyên cốt lõi của Hàn Thiên Tôn)** — Component `xd_htz_lq`
- Hồi 2 điểm mỗi giây.
- Thi triển các loại thần thông đều cần tiêu hao linh lực.
- Hấp thụ Trung Phẩm Linh Thạch: tăng tốc độ hồi linh lực trong 480 giây; có thể cộng dồn thời gian, tối đa 2400 giây.
- Cảnh giới tăng lên sẽ làm tăng giới hạn linh lực và thay đổi giá trị tương ứng.

**Kỹ năng – Thần thông:**

| Tên | Prefab đoán | Tiêu hao linh lực | Mở khóa | Hồi chiêu | Tác dụng |
|---|---|---|---|---|---|
| Hư Thiên Đỉnh | `xd_htz_ztp` (Trảm Thiên Bình)(?) | 60 | Trúc Cơ sơ kỳ | 60s | Gây tấn công Huyền Lam Băng Diễm lên toàn bộ kẻ địch trong phạm vi xung quanh |
| Tam Diễm Phiến | `xd_htz_firefx` | 90 | Kết Đan sơ kỳ | 60s | Phóng ra ba loại hỏa diễm khác nhau theo một hướng chỉ định |
| Phong Lôi Dực | `xd_htz_fjfb`(?) | 3/giây | Kết Đan hậu kỳ | (duy trì) | Sau lưng xuất hiện cánh Phong Lôi: +8% tốc độ di chuyển, có thể đi trên mặt nước, có hiệu ứng thuấn di ngắn |
| Ngũ Tử Đồng Tâm Ma | `xd_htz_spell` | 100 | Nguyên Anh sơ kỳ | 60s | Triệu hồi năm ma đầu tấn công mục tiêu, đồng thời thi triển hiệu ứng khống chế + một phần ma kiếm thần thông |
| Phá Diệt Pháp Mục | `xd_htz_xyzz`(?) | 2/giây | Nguyên Anh sơ kỳ | (duy trì) | Kích hoạt thị giác ban đêm, đồng thời liên tục hồi phục thần thức |
| Nguyên Hợp Ngũ Cực Sơn | `xd_htz_qzj`(?) | 130 | Hóa Thần sơ kỳ | 60s | Tại điểm chỉ định mọc lên Nguyên Hợp Ngũ Cực Sơn, gây chấn động địa hình tấn công kẻ địch xung quanh |
| Huyền Thiên Tràm Linh Kiếm | `xd_htz_xtzlj` | (xem skill) | Nguyên Anh sơ kỳ | — | Khi kích hoạt: thần thông Thanh Trúc Phong Vân Kiếm tăng tiêu hao linh lực lên 40 điểm. Trong thời gian duy trì, có thể tiếp tục kích hoạt thần thông này để: bố trí kiếm trận tại điểm mục tiêu, triệu hồi Huyền Thiên Tràm Linh Kiếm từ trên không giáng xuống gây sát thương lớn |

**Vật phẩm & triệu hồi:**

**Phi Kiếm Phù Bảo** (Vật phẩm tiêu hao; Prefab đoán: `xd_htz_sjcx` / SG `SGxd_htz_sjc`)
- Khi sinh ra đã có 1 cái.
- Vật phẩm tiêu hao, không thể luyện chế.
- Sử dụng sẽ triệu hồi một thanh phi kiếm hỗ trợ chiến đấu.
- Phù hợp cho giai đoạn đầu của Hàn Thiên Tôn.

**Thiên Lôi Tử** (Pháp trượng; Prefab đoán: `xd_htz_tlz`)
- Nguyên liệu cực kỳ quý hiếm, uy lực lớn.
- Có thể cho vũ khí ăn để bổ sung độ bền.

**Linh thú – Triệu hoán:**

**Thực Kim Trùng** (Prefab đoán: pet system của HTZ — có thể link tới `xd_qy` hoặc `xd_minions`)
- Thực Kim Trùng 1 (Bậc 1–4), Thực Kim Trùng 2 (Bậc 5).
- Chế tạo Hòm Thực Kim Trùng để triệu hồi.
- Tiêu hao linh lực: 45-100 điểm (bậc 1–4), 135 điểm (bậc 5).
- Hồi chiêu: 45 giây.
- Có thể thôn phệ vật liệu yêu thú để trưởng thành: sau khi tăng cấp số lượng triệu hồi tăng, tiêu hao linh lực cũng tăng. Khi đạt bậc 5 hình thái thay đổi, tấn công sẽ kích hoạt: sụt lún mặt đất, giảm tốc kẻ địch.

**Huyết Ngọc Chu** (Prefab đoán: pet system)
- Chế tạo **Trứng Huyết Ngọc Chu** (Vật phẩm).
- Cho ăn 10 viên Trung Phẩm Linh Thạch → sinh ra **Kỳ Chu Huyết Ngọc** (Vật phẩm).
- Dùng vật phẩm này để triệu hồi Huyết Ngọc Chu.
- Tiêu hao linh lực: 50; hồi chiêu: 45 giây.
- Đặc điểm: tấn công AOE, khi đánh sẽ tạo tơ nhện tại vị trí mục tiêu (gây giảm tốc); nếu ở xa mục tiêu sẽ thuấn di đến gần để tiếp tục công kích.

---

### 1.4 Tam Tiêu Nương Nương — `xd_yunxiao` (trang 24-30)

> Mod gọi nhân vật này là "Tam Tiêu Nương Nương" — tham chiếu Phong Thần Diễn Nghĩa (Vân Tiêu, Bích Tiêu, Quỳnh Tiêu). Prefab cốt lõi là `xd_yunxiao`.

**Chỉ số gốc:** No bụng 175 / Tinh thần 175 / Máu 175
**Món ăn ưa thích:** Khoai tây nghiền kem

**Đặc tính:**
- Không thuộc phe Bóng Tối cũng không thuộc phe Mặt Trăng → +7% sát thương, +7% phòng ngự bổ sung
- Mức tiêu hao no bụng = 1,25 lần bình thường
- Không bị ảnh hưởng bởi thời tiết gió cát

**Chuyển đổi Tam Tiêu (3 hình thái):**

Gồm ba hình thái: **Vân Tiêu** – **Bích Tiêu** – **Quỳnh Tiêu**. Nhấn chọn để chuyển sang hình thái tương ứng.

**Vân Tiêu** (Hệ số tấn công cơ bản: 0,75)
- Tăng hiệu suất: nấu ăn, chế tạo vật phẩm.
- Có thể chế tạo: gia vị, một số loại sách, sử dụng sách.
- Có thể chế tạo công trình chuyên biệt `<Trạm Gia Vị Vân Yên>` để nêm nếm hàng loạt món ăn.

**Bích Tiêu**
- Hiệu suất đốn cây & đào mỏ cao hơn.
- Khi đốn cây/đào mỏ có xác suất triệu hồi phân thân hỗ trợ.
- Tốc độ thu thập cao hơn.
- Tự động chăm sóc cây trồng.

**Quỳnh Tiêu** (Hệ số tấn công cơ bản: 1,25)
- +6% tốc độ di chuyển; tăng tầm đánh.
- Có thể tích lũy **Giá trị Hiếu Chiến**:
  - 10 điểm: tạo sát thương AOE hình quạt
  - 20 điểm: đòn đánh hút máu
  - 30 điểm: có hiệu ứng gom quái

**Pháp bảo & công trình:**

**Hỗn Nguyên Kim Đẩu** — `xd_yunxiao_hyjd` (Pháp bảo; teleport: component `xd_yunxiao_hytxtele`; widget `xd_hyyqdui`)
- Pháp khí hệ không gian.
- Kéo thả đặt xuống đất sẽ mở ra không gian nội tại bổ sung.
- Khi cầm tay và chuột phải: chọn sinh vật trong phạm vi mục tiêu để dịch chuyển ngẫu nhiên; đồng thời truyền tống vật phẩm trong khu vực vào bên trong Kim Đẩu.

**Đài Dịch Chuyển Hỗn Nguyên Thái Hư** (nằm bên trong Hỗn Nguyên Kim Đẩu)
- Nhấn để dịch chuyển đến gần bất kỳ điểm dịch chuyển Kim Đẩu nào.

**Điểm Dịch Chuyển Hỗn Nguyên Kim Đẩu** (Công trình)
- Mỗi world chỉ có tối đa **9 điểm**.
- Có thể chuột phải đặt một điểm làm điểm chính; khi dịch chuyển sinh vật, tất cả sẽ đến gần điểm chính này.

**Chế tạo chuyên biệt:**

| Tên | Loại | Prefab đoán | Tác dụng |
|---|---|---|---|
| Phức Uẩn Thủ Trượng | Pháp trượng | `xd_yunxiao_fls`(?) | Khi cầm tay: tăng tốc độ di chuyển, có thể dịch chuyển. Mở bản đồ có thể dịch chuyển quãng ngắn. Hồi chiêu 30s. Có thể dùng Đá Sa Mạc để sửa độ bền. |
| Vân Mạc Thượng Trang | Giáp | `xd_yunxiao_fysz`(?) | Giữ ấm 240; phòng ngự thường 85%; độ bền 840. Có thể phục hồi bằng Trung Phẩm Linh Thạch. Mỗi 60s tự động giảm 1,25% độ bền. Có hiệu ứng phát sáng phạm vi nhỏ. Có thể dùng 1 bộ khâu vá để hồi 100% độ bền. |
| Phược Long Tỏa | Roi | `xd_yunxiao_fgfq`(?) | Tầm đánh 8; sát thương 20. Khi tấn công: trói buộc sinh vật xung quanh mục tiêu. Có thể dùng để cho chuyên chức pháp bảo nuốt, hồi phục độ bền. |
| Phù Cốt Pháp Khí | Pháp trượng | `xd_yunxiao_jjj`(?) | Gây địa chấn diện rộng phía trước; phá hủy cây cối và khoáng thạch trong phạm vi ảnh hưởng. |

(Prefab `xd_yunxiao_ymsz`, `xd_yunxiao_portable_spicer`, `xd_yunxiao_tooler` chưa map 1-1 chính xác — Portable Spicer ~ "Trạm Gia Vị Vân Yên"; Tooler có brain `xd_yunxiao_toolerbrain` ~ pet hỗ trợ/phân thân.)

---

### 1.5 Tinh Vệ — `xd_jingwei` (trang 31-35)

**Chỉ số gốc:** No bụng 125 / Tinh thần 150 / Máu 150
**Món ăn ưa thích:** Bánh thanh long
**Hệ số tấn công cơ bản:** 0,75

**Đặc tính:**
- Không thuộc phe Bóng Tối cũng không thuộc phe Mặt Trăng → +7% sát thương, +7% phòng ngự bổ sung
- Không tích lũy độ ẩm ướt
- Không làm kinh động các loài động vật nhỏ và chim chóc
- Khi động vật nhỏ hoặc chim chóc xung quanh bị giết → giảm 5 điểm tinh thần
- Có thể tiêu hao máu để chế tạo **Huyền Vũ Nhỏ** (Prefab đoán: `xd_jingwei_zzql` hoặc `xd_jingwei_blowdart`)
  - Là nguyên liệu chế tạo chuyên dụng
  - Có thể chuyển hóa thành các loại lông vũ nhiều màu
  - Dùng để chế tạo: Bùa Tái Sinh, Trái Tim Cáo Mật, Tượng Thịt

**Lấp biển (cơ chế đặc biệt):**
- Có thể chế tạo địa hình chuyên dụng để lấp biển.
- Khu vực đã lấp có thể dùng thuốc nổ phá hủy.

**Phi dược:**
- Tiêu hao độ no để bay vọt một khoảng cách nhất định.

**Tùy tùng chuyên dụng – Huyền Điểu** — `xd_jingwei_fenice` (sinh vật; brain `xd_jingwei_fenicebrain`, `xd_jingwei_fenice4brain`; SG `SGxd_jingwei_fenice1/3/4`)
- Có thể triệu hồi hoặc giải trừ trong mục chế tạo.
- Tăng cường theo cảnh giới của người chơi, hình thái thay đổi dần, cuối cùng hóa hình nhân dạng.
- Thuộc tính cơ bản: 90% phòng ngự thường, 70% phòng ngự thần thức, 20 phòng ngự diện rộng, hồi máu chậm.

**Các giai đoạn:**

- **Luyện Khí kỳ – Ấu thể:** ăn Quả Huỳnh Quang để phát sáng; +9 ô chứa đồ; bảo quản vĩnh viễn.
- **Trúc Cơ kỳ – Trưởng thành:** có phạm vi hằng nhiệt nhỏ; hồi phục tinh thần.
- **Kết Đan kỳ – Nhân hình:** hỗ trợ đốn cây và đào mỏ; khi Tinh Vệ đói sẽ tự chế tạo thức ăn đưa cho Tinh Vệ; hành vi này có hồi chiêu 180 giây.

**Chế tạo chuyên biệt:**

| Tên | Loại | Prefab đoán | Tác dụng |
|---|---|---|---|
| Thanh Xuất Ư Lam | Pháp khí | `xd_jingwei_fan` | Số lần sử dụng: 20. Khi dùng: quạt ra một luồng cuồng phong tới điểm mục tiêu. Trong phạm vi nhỏ: thu gom toàn bộ vật phẩm rơi rải, dập tắt hỏa diễm, đồng thời ổn định nhiệt độ (không nóng không lạnh), phá hủy cây cối/rễ cây/khoáng thạch cùng băng nguyên, lôi kéo sinh linh xung quanh tụ về một chỗ. |
| Thúy Vũ Tiên Tung | (?) | `xd_jingwei_zzql`(?) | (PDF chỉ liệt kê tên, chưa có mô tả chi tiết — có thể đi cùng Phức Úc Thủ Trượng bên dưới) |
| Phức Úc Thủ Trượng | Nón (mũ) | `xd_jingwei_hat` | Trang bị đầu; giữ ấm 240; chống nước 100%; độ bền 12 ngày; +7% tốc độ di chuyển. Có thể dùng bộ khâu vá để hồi 100% độ bền. |
| Huyền Vũ Xuy Tiễn | Phi tiêu | `xd_jingwei_blowdart` | Khi tấn công mục tiêu: tạo một hư ảnh có hiệu ứng khiêu khích quanh mục tiêu; thời gian duy trì 9s. Có thể dùng để cho chuyên chức pháp bảo hấp thụ, hồi một phần độ bền. |

---

### 1.6 Tôn Ngộ Không — `xd_wukong` (trang 36-43)

**Chỉ số gốc:** No bụng 125 / Tinh thần 125 / Máu 175
**Món ăn ưa thích:** Chuối (chuối: hồi thêm 100% độ no)

**Đặc tính:**
- +7% sát thương, +7% phòng ngự bổ sung (vì không thuộc phe Bóng Tối / Mặt Trăng)
- Không cầm vũ khí, giữ ALT + chuột phải có thể biến hóa thành bất kỳ vật phẩm hoặc sinh vật nào, đồng thời có hiệu ứng ẩn thân (— component `xd_72bian` / prefab `xd_72bian`).
- Khỉ và các sinh vật họ khỉ thân thiện với Tôn Ngộ Không.
- Cầm bất kỳ vũ khí nào cũng không bị rơi.
- Khi chịu sát thương lửa → giảm tinh thần tương ứng với lượng sát thương nhận vào.
- Khi toàn bộ Kỳ Thuật, Linh Kỹ, Căn Khí và kỹ năng Yêu Thú được mở khóa → nhân vật sẽ tự động chuyển sang ngoại hình **Đại Thánh**.

**Lục Căn (Căn Khí) — cơ chế đặc biệt:**

Tôn Ngộ Không có biểu tượng **Lục Căn Khí**. Mỗi khi đánh bại Boss tương ứng sẽ: thắp sáng một Căn Khí + nhận hiệu ứng tăng cường vĩnh viễn. Có thể chuột phải kéo thả giao diện.

| # | Boss | Phần thưởng Căn Khí |
|---|---|---|
| 1 | Deerclops | Mùa hè nhận 120 điểm cách nhiệt |
| 2 | Armored Bearger | Tai Khí có hiệu ứng bảo quản vĩnh viễn |
| 3 | Klaus | Giảm sát thương 25% |
| 4 | Tàn Hồn Kỳ Lân | Tiêu hao Linh Thạch khi dùng phân thân giảm một nửa |
| 5 | Kim Phượng Thần Niệm | Ngoài mùa hè nhận 120 điểm giữ ấm |
| 6 | Reanimated Skeleton | Mỗi phút hồi 6 điểm thần thức |

**Khi kích hoạt toàn bộ Lục Căn Khí:**
- Kim Cô ở trung tâm sẽ từ hoàn chỉnh chuyển sang vỡ vụn.
- Hiệu ứng **Vô Câu Vô Thúc**: +10% tốc độ di chuyển.

**Tai Khí:**
- Có ô Tai Khí riêng, chứa tối đa 3 vật phẩm.
- Có thể chuột phải kéo thả.
- Khi đã kích hoạt Căn Khí Armored Bearger: vật phẩm bên trong được bảo quản vĩnh viễn.

**Kỳ Thuật (skill table):**

**Bảng Kỳ Thuật**
- Nhấn nút Kỳ Thuật góc trái dưới để xem và chọn kỹ năng.
- Có thể chuột phải kéo thả.
- Khi cầm vũ khí chuyên dụng: ALT + chuột phải để thi triển; hồi chiêu 30s.

| Tên Kỳ Thuật | Mở khóa | Cơ chế |
|---|---|---|
| Định Thân Pháp | (mặc định) | Gây định thân lên mục tiêu và sinh vật xung quanh; thời gian định thân 4s; khi hiệu ứng kết thúc gây **280 sát thương**; hồi chiêu hiển thị ở góc phải dưới. |
| An Thân Pháp | Tự động mở khóa khi đạt Kết Đan kỳ | Triệu hồi vòng lửa gây sát thương: 20 lần đánh, mỗi lần 23 sát thương. Nhân vật đứng trong vòng: mỗi 2,5s hồi 10% máu. |

**Linh Kỹ:**

**Bảng Linh Kỹ**
- Nhấn nút Linh Kỹ góc trái dưới để xem và chọn.
- Có thể chuột phải kéo thả.
- Khi cầm vũ khí chuyên dụng: chuột phải để thi triển.

| Tên Linh Kỹ | Mở khóa | Cơ chế |
|---|---|---|
| Tụ Hình Tán Khí | (mặc định) | Sau khi kích hoạt: thuấn hiện tới vị trí chỉ định, để lại ảo ảnh tại chỗ cũ. Ảo ảnh: có hiệu ứng khiêu khích, tồn tại 5s; khi biến mất gây nổ AOE 400 sát thương. Bản thể: ẩn thân 5s, nếu tấn công sẽ hiện hình, đòn đánh đầu tiên gây **367 sát thương**. Hồi chiêu: 20s. |
| Đồng Đầu Thiết Tý | Tự động mở khóa khi đạt Trúc Cơ kỳ | Khi kích hoạt: vào trạng thái phản kích; đòn đánh đầu tiên nhận vào sẽ miễn nhiễm sát thương + đẩy lùi mục tiêu một đoạn ngắn. Sau đó: Tôn Ngộ Không nhảy phản công, gây **600 sát thương**, có hiệu ứng đẩy lùi. Hồi chiêu: 12s. |

**Biến Hóa Chi Thuật (72 biến):**

**Bảng Biến Hóa** (Prefab: `xd_72bian`)
- Nhấn biểu tượng Biến Hóa góc trái dưới để chọn kỹ năng Yêu Thú.
- Cần đánh bại Yêu Thú tương ứng để học được.
- Nhấn phím R để thi triển (có thể tùy chỉnh phím trong phần cấu hình mod — `wukongkey` default R).
- Giao diện có thể chuột phải kéo thả.

(PDF không liệt kê chi tiết từng dạng biến hóa Yêu Thú; danh sách phải đánh bại để học được khả năng — cơ chế tương tự collection.)

---

### 1.7 Tô Đát Kỷ — `xd_sudaji` (trang 44-50)

**Chỉ số gốc:** No bụng 125 / Tinh thần 200 / Máu 150
**Món ăn yêu thích:** Kẹo Toffee (khi ăn: hồi thêm 50% độ no)

**Đặc tính:**
- Không thuộc phe Bóng Tối hay Mặt Trăng → gây thêm 7% sát thương + nhận thêm 7% phòng thủ trước cả hai phe.
- Do sở hữu đuôi hồ ly: ngoài mùa hè nhận 240 điểm giữ ấm.
- Độ ẩm: tốc độ tăng độ ẩm gấp đôi; khi bị ướt, tốc độ tụt tinh thần gấp đôi.
- Khi chịu sát thương hỏa diễm: đồng thời bị trừ tinh thần tương ứng với lượng sát thương nhận vào.

**Mảnh Nguyên Thần Yêu Thú** (Vật phẩm)
- Vật phẩm linh hồn.
- Rơi ra khi tiêu diệt sinh vật.
- Dùng để: hồi độ bền cho vật phẩm do Tô Đát Kỷ chế tạo, hồi độ bền cho Ngọc Dưỡng Hồn.

**Pháp bảo & vật phẩm chuyên biệt:**

**Nhất Vũ Phương Hoa** — Pháp bảo (Ô) (Prefab đoán: `xd_sudaji_xyj` hoặc `xd_sudaji_ywfh`)
- Công thức chế tạo: Giấy ×6, Tơ nhện ×3, Gỗ sống ×2, Trung phẩm linh thạch ×2.
- Có thể dùng Mảnh Nguyên Thần Yêu Thú để sửa độ bền.
- Độ bền tối đa: duy trì liên tục 7 ngày.
- Hiệu ứng khi cầm tay hoặc đặt xuống đất: miễn nhiễm mưa/mưa axit/mưa thiên thạch; sinh ra hiệu ứng cách nhiệt; khi đặt xuống đất tác dụng theo phạm vi.
- Khi cầm ô và dùng lên bản thân hoặc đồng đội: tiêu hao 25% độ bền; xóa toàn bộ độ ẩm hiện tại; trong 240 giây độ ẩm luôn duy trì ở 0.

**Mộc Điêu Thế Thân** — Vật phẩm tiêu hao (Prefab đoán: phần của `xd_sudaji_soul_spawn`)
- Vật phẩm thế thân.
- Công thức: Gỗ sống ×1, Hạ phẩm linh thạch ×10.
- Hiệu ứng: đặt tại vị trí người chơi → tạo một ảo ảnh của chính người chơi, tồn tại vô hạn. Khi sử dụng lại: ảo ảnh biến mất, người chơi mất 25% máu, lập tức quay về vị trí ảo ảnh.

**Đăng Ngư Long** — Đèn lồng (Prefab: `xd_sudaji_redlantern`)
- Công thức: Gỗ ×2, Vàng ×3, Giấy ×3, Trung phẩm linh thạch ×1.
- Dùng Mảnh Nguyên Thần Yêu Thú để hồi độ bền.
- Độ bền tối đa: chiếu sáng liên tục 7 ngày.
- Hiệu ứng khi cầm tay hoặc đặt xuống đất: duy trì nhiệt độ ổn định trong một phạm vi nhất định.

**Bội Nang Bách Vị** — Túi đeo (Prefab đoán: `xd_sudaji_sjpn` / container `xd_sjpn_container`)
- Công thức: Dây thừng ×6, Lục bảo thạch ×1, Trung phẩm linh thạch ×1.
- Có 6 ô chứa.
- Khi đặt thức ăn vào: thức ăn được làm tươi chậm theo thời gian.

**Thực Khám Thiên Vị** — Công trình (Prefab đoán: `xd_sudaji_tsmd` hoặc related)
- Công thức: Vàng ×2, Gỗ ×7, Hồng bảo thạch ×1, Trung phẩm linh thạch ×1.
- Hiệu ứng: mỗi ngày làm mới 1 hoặc 2 món ăn (mỗi loại 50% xác suất). Tự động thêm gia vị: bột tỏi, tinh thể mật ong, bột ớt, muối gia vị (xác suất mỗi loại gia vị: 25%).

(Prefab `xd_sudaji_mxrg`, `xd_sudaji_yhly`, `xd_sudaji_fx`, `xd_sudaji_soul`, `xd_sudaji_controller` chưa map đầy đủ — có thể là summon/soul system internal.)

---

### 1.8 Ngao Bính (Long Thái Tử) — `xd_longtaizi` (trang 51-54)

**Chỉ số gốc:** No bụng 175 / Tinh thần 175 / Máu 150
**Món ăn yêu thích:** Canh Măng Tây Lạnh (khi ăn: hồi 100% cả ba chỉ số)

**Đặc tính:**
- Không thuộc phe Bóng Tối hay Mặt Trăng → gây thêm 7% sát thương, nhận thêm 7% phòng thủ trước cả hai phe.
- **Cơ chế thể chất nhiệt đặc biệt:** Nhiệt độ càng thấp → hồi tinh thần càng nhanh + tăng tốc độ di chuyển.

**Hiệu ứng theo nhiệt độ cơ thể:**

| Nhiệt độ | Tốc độ | Hồi tinh thần | Khác |
|---|---|---|---|
| ≤ 20°C và > 10°C | +5% | +6 /phút | — |
| ≤ 10°C và > 0°C | +10% | +12 /phút | — |
| ≤ 0°C và > -10°C | +15% | +18 /phút | Đi trên mặt nước; hiệu ứng tuyết bay khi di chuyển |
| ≤ -10°C | +20% | +24 /phút | Đi trên mặt nước; hiệu ứng tuyết bay; miễn nhiễm hoàn toàn trạng thái đóng băng |

**Hàn Băng Linh Khí** (chỉ số riêng — Prefab đoán: `xd_longzhu` hoặc `xd_binglingqi` component)
- Long Thái Tử sở hữu chỉ số Băng Linh Khí.
- Giá trị tối đa: 100. Cứ mỗi 25 điểm là 1 tầng, tổng cộng 4 tầng. Giá trị khởi điểm: 50.

**Phân tầng:**
- 0 – 25: Tầng 1
- 26 – 50: Tầng 2
- 51 – 75: Tầng 3
- 76 – 100: Tầng 4

**Cơ chế Hàn Băng Linh Khí:**
- Mỗi tầng sẽ thay đổi hiệu quả linh kỹ và thần thông.
- Có thể tích lũy khi: nhiệt độ cơ thể giảm, bị tấn công có cộng dồn tầng đóng băng.
- Khi đạt tầng 2 trở lên: hình thái Thủy Long Ngâm sẽ biến đổi.

(Bigportrait `xd_longtaizi_hysj` xác nhận có form transformation Thủy Long Ngâm = "hysj".)

---

## 2. Hệ thống Cảnh giới (Cultivation realms)

### 2.1 Cảnh giới Luyện Thể (trang 55)

> Đây là cảnh giới **luyện thể (rèn thân)**, song song / tiền đề cho hệ thống Luyện Khí.

Cảnh giới Luyện Thể được chia thành **bảy giai đoạn**, lần lượt là:

1. **Thông Mạch**
2. **Đoán Cốt**
3. **Luyện Phủ**
4. **Nguyên Võ**
5. **Thần Lực**
6. **Phá Hư**
7. **Quy Nguyên**

Mỗi giai đoạn gồm 15 tầng, tuy nhiên hiện tại **Quy Nguyên kỳ chỉ mở tầng thứ nhất**.

Mỗi tầng cảnh giới sẽ mang lại cho người chơi một mức gia tăng nhất định về:
- Hệ số tấn công
- Giới hạn sinh lực tối đa

**Cơ chế nhận kinh nghiệm:**
- Chỉ cần người chơi ở trong phạm vi bán kính 28 quanh sinh vật khi sinh vật đó tử vong, đều có thể nhận được kinh nghiệm.
- Khi có nhiều người chơi cùng tham gia, lượng kinh nghiệm không bị suy giảm.

**Component liên quan:** `xd_level` (luyện thể level), `xd_savelevel`, `xd_worldlevel`, `xd_dtlevel` (đại đạo level).

---

### 2.2 Hệ thống Thiên Lệch Bản Nguyên & Yêu Linh Thánh Thể (trang 56-58)

Bản Nguyên Thiên Lệch thuộc phần **cường hóa quái vật**, có công tắc riêng trong giao diện thiết lập mod, được đánh dấu là **"Vạn Vật Cảnh Giới"** (`set` flag trong modinfo). Cho phép người chơi tùy chọn bật/tắt hệ thống này.

Mỗi sinh vật đều sở hữu hệ thống **"Bản Nguyên Thiên Lệch"**, tức khuynh hướng bản nguyên linh khí của sinh vật đó. Các loại bản nguyên bao gồm: **Kim, Mộc, Thủy, Hỏa, Thổ, Vô Cực, Hỗn Nguyên** (7 hệ).

Bản nguyên của sinh vật còn có **mức độ thiên lệch**, được chia thành 4 cấp:
- **Vi Nhược**
- **Phổ Thông**
- **Cường Liệt**
- **Cực Hạn**

Sinh vật có mức thiên lệch đạt **"Cực Hạn"** sẽ đồng thời sở hữu **ba loại thần thông** tương ứng với các cấp "Vi Nhược", "Phổ Thông" và "Cường Liệt".

**Thần thông tương ứng theo thuộc tính:**

**Thổ:**
- Thổ · Vi Nhược: Đòn đánh thường khi trúng tu sĩ sẽ tạo địa hãm, kèm hiệu ứng làm chậm.
- Thổ · Phổ Thông: Gây sát thương diện rộng bằng cát đá.
- Thổ · Cường Liệt: Hình thành bức tường phòng ngự; sau vài giây, các khối đá vỡ vụn và phát nổ sát thương phạm vi tại trung tâm.

**Mộc:**
- Mộc · Vi Nhược: Mỗi lần đánh trúng tu sĩ sẽ triệu hồi dây leo tấn công một lần.
- Mộc · Phổ Thông: Trên đầu tu sĩ xuất hiện bào tử, sau đó phát nổ và để lại độc vân, phát tác theo chu kỳ.
- Mộc · Cường Liệt: Sinh ra mũ bào tử, ném bom nấm về phía người chơi; kỹ năng kích hoạt theo chu kỳ.

**Thủy:**
- Thủy · Vi Nhược: Đòn đánh cộng dồn hiệu ứng đóng băng lên tu sĩ.
- Thủy · Phổ Thông: Khi tấn công sẽ tạo mặt đất băng giá tại vị trí của tu sĩ.
- Thủy · Cường Liệt: Phát sinh băng hỏa theo nhiều hướng; kích hoạt theo đếm, cứ mỗi 3 lần tấn công sẽ phát động một lần.

**Hỏa:**
- Hỏa · Vi Nhược: Đòn đánh thường trúng tu sĩ sẽ gây nổ và thiêu đốt mục tiêu.
- Hỏa · Phổ Thông: Khi tấn công tạo ra hỏa phong.
- Hỏa · Cường Liệt: Gây ba lần sát thương phạm vi bằng lửa; kích hoạt theo đếm, mỗi 3 lần tấn công phát động một lần.

**Kim:**
- Kim · Vi Nhược: Khi tấn công bắn một cầu laser về phía tu sĩ.
- Kim · Phổ Thông: Liên tiếp phóng hai loại laser; kích hoạt theo đếm, mỗi 3 lần tấn công phát động một lần.
- Kim · Cường Liệt: Triệu hồi Mắt Laser và Mắt Ma Diễm, liên tục xung phong 3 lần về phía tu sĩ rồi biến mất.

**Hỗn Nguyên:**
- Hỗn Nguyên · Vi Nhược: Khi tấn công, lấy yêu thú làm trung tâm phóng thích kỹ năng cốt thứ.
- Hỗn Nguyên · Phổ Thông: Liên tục phun ra khối lớn hắc huyết, bắn tung tóe và triệu hồi xúc tu bóng tối xung quanh.
- Hỗn Nguyên · Cường Liệt: Theo chu kỳ triệu hồi một chiến xa bóng tối cùng hai Chủ Giáo Bóng Tối tấn công tu sĩ.

**Vô Cực:**
- Vô Cực · Vi Nhược: Đòn đánh cộng dồn giá trị mê hoặc / thôi miên lên tu sĩ.
- Vô Cực · Phổ Thông: Trong phạm vi nhất định triệu hồi hai Nguyệt Linh Hư Ảnh hỗ trợ chiến đấu.
- Vô Cực · Cường Liệt: Sinh ra khu vực hình tròn có hạt xanh lam đánh dấu ranh giới; khi tu sĩ ở trong khu vực, xung quanh sẽ xuất hiện hư ảnh và đại hư ảnh lao vào tấn công; kỹ năng kích hoạt theo chu kỳ.

---

### 2.3 Thế Giới Thăng Cách (trang 59-60)

Khi người chơi đạt tới **Nguyên Anh kỳ**, thế giới sẽ tiến hành **thăng cách**.

Sau khi thăng cách:
- Đòn tấn công của quái vật cùng với Bản Nguyên Thiên Lệch sẽ **gia tăng thêm sát thương Thần Thức**; loại sát thương này có khả năng **xuyên thấu giáp phòng ngự**.
- Một số quái vật thậm chí còn có thể sở hữu **Yêu Linh Thánh Thể**, khiến thực lực của chúng trở nên khó lường hơn bao giờ hết.
- Trong giai đoạn này, người chơi **chưa đạt tới Kết Đan kỳ** khi tấn công sẽ có xác suất kích hoạt **Tiên Quân trợ chiến**.

**Yêu Linh Thánh Thể:**

Khi thế giới thăng cách, quái vật sẽ sở hữu Bản Nguyên Thiên Lệch cường đại hơn, đồng thời một bộ phận sinh vật còn có thể nắm giữ nhiều loại Thánh Thể khác nhau:

| Tên Thánh Thể | Hiệu ứng |
|---|---|
| Yêu Tổ Chuyển Thế Thân | Khi sinh lực giảm xuống dưới **30%**, sẽ triệu hồi **Armored Bearger** hỗ trợ chiến đấu. Khi sinh lực giảm xuống dưới **25%**, sẽ triệu hồi **Crystal Deerclops** hỗ trợ chiến đấu. |
| Tiên Thiên Đạo Thể | Yêu vật này sẽ sở hữu thêm một loại Bản Nguyên Thiên Lệch ẩn giấu. |
| Hoang Cổ Thánh Thể | Mỗi lần tấn công đều kèm theo một thiên thạch giáng xuống. |
| Xích Dương Thánh Thể | Khi sinh lực giảm xuống dưới **30%**, sẽ triệu hồi thân ngoại hóa thân của chính mình để trợ chiến. |
| Tà Âm Ma Thể | Khi sinh lực giảm xuống dưới **50%**, sẽ triệu hồi Kỵ Sĩ Bóng Tối, Chiến Xa Bóng Tối và Chủ Giáo Bóng Tối cùng tham chiến. |

---

### 2.4 Vô Thượng Ma Thể & Công Đức Kim Thân (trang 61-64)

Khi nhân vật đạt tới cảnh giới **Kết Đan**, dựa theo các điều kiện tích lũy trước đó trong quá trình Kết Đan, sẽ hình thành một trong hai thể chất: **Vô Thượng Ma Thể** hoặc **Công Đức Kim Thân**.

**Cơ chế hình thành:**
- Trước khi Kết Đan, trong phạm vi sáu ô đất xung quanh, nếu có tu sĩ khác hoặc chính bản thân nhân vật tử vong → tích lũy 1 điểm **Tâm Ma**.
- Khi Tâm Ma đạt **7 điểm**, lúc đột phá Kết Đan sẽ sinh ra **Vô Thượng Ma Thể**.
- Nếu không đạt điều kiện này → sẽ hình thành **Công Đức Kim Thân**.

**Công Đức Kim Thân:**
- Khi sinh mệnh của bản thân giảm về 0, nhân vật **không tử vong**, mà lập tức hồi phục sinh mệnh lên 100%.
- Đồng thời, trong **5 giây** tiếp theo, nhân vật tiến vào **trạng thái vô địch**.
- Thời gian hồi chiêu: **1 ngày**.
- Khi tấn công, có xác suất triệu hồi **Kim Thân** từ trên không giáng xuống, hỗ trợ tấn công kẻ địch.

**Vô Thượng Ma Thể:**
- Khi sinh mệnh của bản thân giảm về 0, nhân vật **không chết**, mà bị khóa ở mức **1 điểm sinh mệnh**.
- Đồng thời, xung quanh sẽ xuất hiện **Quỷ Thủ**, có lượng máu bằng **10 lần máu của tu sĩ**.
- Chỉ khi toàn bộ Quỷ Thủ bị tiêu diệt hoặc sau **30 giây** Quỷ Thủ tự động biến mất, tu sĩ mới thoát khỏi trạng thái khóa máu.
- Sát thương mà Quỷ Thủ phải chịu sẽ kế thừa trực tiếp lên bản thân tu sĩ.
- Thời gian hồi chiêu: **480 giây (1 ngày)**.
- Khi tấn công, có xác suất kích hoạt **3 Hóa Ma Phân Thân** xuất hiện, hỗ trợ tấn công.

**Thần Thức Khôi Lỗi (Pháp bảo):**

Có thể sử dụng từ **Trúc Cơ kỳ**.

**Công thức luyện chế:**
- Tủy phượng hoàng ×1
- Vàng ×7
- Ngọc đỏ ×1
- Hạ phẩm linh thạch ×30

**Sử dụng:**
- Nhấp chuột phải vào vật phẩm 《Thần Thức Khôi Lỗi》 để triệu hồi **Thân Ngoại Hóa Thân**.
- Sau khi triệu hồi, tiếp tục nhấp chuột phải để thu hồi hóa thân.
- Nhấn phím **X** để gọi về các sinh vật được thần thức phụ thể, bao gồm Thân Ngoại Hóa Thân và toàn bộ sinh vật triệu hồi của bản thân người chơi.

**Thân Ngoại Hóa Thân (chi tiết):**
- Khi tấn công các mục tiêu có cơ chế tương tự **Armored Bearger**, có thể loại bỏ kháng tính thực thể/kháng vị diện của mục tiêu.
- Khi thu hồi hoặc khi hóa thân tử vong, sẽ sinh ra thời gian hồi chiêu **120 giây**.
- Mỗi tu sĩ chỉ có thể triệu hồi **một** Thân Ngoại Hóa Thân tại cùng một thời điểm.

**Trang bị & sinh tồn:**
- Thân Ngoại Hóa Thân có **túi đồ riêng**, chỉ người chơi sở hữu mới có thể xem.
- Tự động lần lượt trang bị giáp và mũ.
- Khi chịu sát thương, độ bền mũ và giáp sẽ bị tiêu hao bình thường.
- Sau khi thoát khỏi chiến đấu **30 giây**, hóa thân sẽ hồi máu chậm theo thời gian.

**Tử vong & thu hồi:**
- Khi Thân Ngoại Hóa Thân tử vong, toàn bộ vật phẩm trong túi đồ và trang bị sẽ rơi ra.
- Khi thu hồi hóa thân, toàn bộ trang bị trong túi và balo sẽ được lưu giữ lại trong hóa thân.
- Có nút **"Tháo Giáp"**: khi kích hoạt, toàn bộ trang bị đang mặc sẽ được tháo ra và rơi xuống mặt đất.

**Hiệu ứng tăng sát thương:** Thân Ngoại Hóa Thân có thể thông qua việc ăn thức ăn (bột ớt, thạch sừng dê) hoặc trang bị (như mũ hơi nước) để nhận hiệu quả tăng hệ số tấn công giống hệt nhân vật chính.

**Tiêu hao linh thạch duy trì (theo cảnh giới):**

| Cảnh giới | Tiêu hao |
|---|---|
| Luyện Khí kỳ | Mỗi 60 giây tiêu hao Hạ phẩm linh thạch ×1 |
| Trúc Cơ kỳ | Mỗi 42 giây tiêu hao Hạ phẩm linh thạch ×1 |
| Kết Đan kỳ | Mỗi 24 giây tiêu hao Hạ phẩm linh thạch ×1 |
| Nguyên Anh kỳ | Mỗi 15 giây tiêu hao Hạ phẩm linh thạch ×1 |
| Hóa Thần kỳ | Mỗi 480 giây tiêu hao Trung phẩm linh thạch ×1 |
| Phản Hư kỳ | Mỗi 360 giây tiêu hao Trung phẩm linh thạch ×1 |
| Hợp Thể kỳ | Mỗi 240 giây tiêu hao Trung phẩm linh thạch ×1 |

**Tu vi của Thân Ngoại Hóa Thân:**
- Mặc định có cảnh giới **Luyện Khí**, tối đa có thể đạt tới **Hợp Thể kỳ**.
- Khi cảnh giới tăng, sát thương gây ra sẽ được nâng cao tương ứng.
- Có thể trực tiếp cho hóa thân ăn vật liệu yêu thú hoặc đan dược để tăng tu vi.

**Vật phẩm có thể dùng để tăng tu vi:**

| Loại | Tên |
|---|---|
| Linh thạch | Thượng phẩm, Cực phẩm |
| Nguyên liệu & vật phẩm đặc biệt | Bông Hồng Bóng Tối, Sừng Hộ Vệ Già, Đá Cát, Da Gấu, Sữa Ong Chúa, Ngọc Trai Nứt, Nhãn Cự Lộc, Vảy, Lông Ngỗng, Nai Sừng Tấm, Mỏ Hải Điểu Tà Dị, Vỏ Nấm, Mảnh Khai Ngộ, Chất Sữa Trắng, Tâm Phòng Bóng Tối, Nỗi Sợ Thuần Khiết |
| Bảo thạch | Lam, Hồng, Tử, Cam, Hoàng, Lục bảo thạch, Hồng ngọc Cầu Vồng |
| Linh vật & dược liệu | Sừng Kỳ Lân, Phượng Tủy |
| Đan dược | Tụ Khí Hoàn, Đoán Thể Hoàn, Trúc Cơ Đan, Tẩy Tủy Hoàn, Hóa Tinh Đan, Vân Trung Đan, Sơ Mạch Hoàn, Dung Linh Hoàn, Kết Anh Đan |

---

## 4. Tiên Ma Chi Kiếm (trang 65)

Khi nhân vật đạt tới **Hóa Thần kỳ**, tùy theo tu sĩ thuộc **Vô Thượng Ma Thể** hay **Công Đức Kim Thân**, có thể trong bảng chế tác Tiên Đạo nhấn vào biểu tượng tương ứng để kích hoạt **Ma Kiếm** hoặc **Tiên Kiếm**.

Nhấn lần nữa sẽ thu hồi kiếm.

**Tiên Ma Kiếm Thần Thông:**
- Khi kích hoạt Tiên Kiếm hoặc Ma Kiếm, kiếm sẽ phối hợp tấn công dựa trên số lần người chơi ra đòn.
- Khi nhấn phím **X**, có thể giải phóng kỹ năng đặc thù của Tiên Kiếm hoặc Ma Kiếm.
- **Tiên Kiếm:** sau khi phóng thích 3 lần, nhấn tiếp sẽ kích hoạt tối hậu thần thông.
- **Ma Kiếm:** sau 2 lần phóng thích, có thể thi triển tối hậu thần thông.

---

## 2.5 Luyện Khí Cảnh Giới — Bảng đột phá đầy đủ (trang 66-72)

Bảng dưới liệt kê các loại đan dược cần thiết để đột phá từng cảnh giới trong hệ thống Luyện Khí.

| Đột phá | Đan dược | Công thức luyện chế |
|---|---|---|
| Luyện Khí sơ kỳ → Luyện Khí trung kỳ | **Tụ Khí Đan** | Nanh ong ×10, Hạch nhện ×5, Trứng chim cao ×1, Hạ phẩm linh thạch ×10 |
| Luyện Khí trung kỳ → Luyện Khí hậu kỳ | **Đoán Thể Đan** | Vòi voi hoặc vòi voi mùa đông ×1, Da heo ×3, Hồng bảo thạch ×3, Hạ phẩm linh thạch ×30 |
| Luyện Khí hậu kỳ → Trúc Cơ sơ kỳ | **Trúc Cơ Đan** | Da chuồn chuồn ×1, Răng chó ×10, Gỗ sống ×3, Trung phẩm linh thạch ×1 |
| Trúc Cơ sơ kỳ → Trúc Cơ trung kỳ | **Tẩy Tủy Đan** | Quả phát quang ×3, Quả đèn lồng ×10, Xương ốc ×3, Hạ phẩm linh thạch ×20 |
| Trúc Cơ trung kỳ → Trúc Cơ hậu kỳ | **Hóa Tinh Đan** | Râu khỉ (Râu của mod rơi ra từ khỉ hang) ×3, Tử bảo thạch ×3, Vàng cổ ×3, Hạ phẩm linh thạch ×50 |
| Trúc Cơ hậu kỳ → Kết Đan sơ kỳ | **Vân Trung Đan** | Sừng Kỳ Lân ×1, Bào tử đỏ hoặc xanh lá hoặc xanh lam ×10, Lông thỏ ×5, Trung phẩm linh thạch ×2 |
| Kết Đan sơ kỳ → Kết Đan trung kỳ | **Sơ Mạch Đan** | Sữa ong chúa ×1, Tinh thể muối ×15, Quả sung ×10, Hạ phẩm linh thạch ×30 |
| Kết Đan trung kỳ → Kết Đan hậu kỳ | **Dung Linh Đan** | Hoa Hồng Bóng Tối ×1, Sừng cá voi ×1, Vỏ ốc ×7, Trung phẩm linh thạch ×1 |
| Kết Đan hậu kỳ → Nguyên Anh sơ kỳ | **Kết Anh Đan** | Tủy Phượng ×1, Vỏ nấm ×1, Bơ ×1, Trung phẩm linh thạch ×3 |
| Nguyên Anh sơ kỳ → Nguyên Anh trung kỳ | **Uẩn Huyết Đan** | Gậy Thỏ Vương ×1 (giết vua thỏ phẫn nộ), Vải vụn Bóng Tối ×8, Trang sức Nguyền Rủa ×5, Thượng phẩm linh thạch ×1 |
| Nguyên Anh trung kỳ → Nguyên Anh hậu kỳ | **Ngưng Thần Đan** | Mảnh Giác Ngộ ×1, Vỏ Gai ×4, Vật chất sữa trắng ×3, Thượng phẩm linh thạch ×1 |
| Nguyên Anh hậu kỳ → Hóa Thần sơ kỳ | **Hóa Thần Đan** | Da Hổ Gấm ×1 (drop từ Tàn Thần Bạch Hổ), Ác Mộng Thuần Túy ×8, Đá mặt trăng thuần túy ×8, Thượng phẩm linh thạch ×1 |
| Hóa Thần sơ kỳ → Hóa Thần trung kỳ | **Hồi Nguyên Đan** | Tà Sát Bộ Túc ×1 (drop Tà Sát Chu Vương), Đuôi Linh Hồ ×3 (drop Linh Hồ), Lông Vũ Mãnh ×2 (drop Tiên Hạc), Thượng phẩm linh thạch ×1 |
| Hóa Thần trung kỳ → Hóa Thần hậu kỳ | **Hợp Linh Đan** | Tử Sát Ma Vũ ×1 (drop hóa thân Tử Vân Ma Quân), Ma Quái Kiềm Cốt ×1 (drop Ma Tướng Phù Đồ), Trái Tim Bóng Tối ×2, Thượng phẩm linh thạch ×1 |

**Component liên quan:** `xd_level` (luyện khí level), `xd_lingji` (linh khí), `xd_jllingshi` (linh thạch manager), `xd_liandanlu` (lò luyện đan).

---

## 5. Linh Bảo (Spirit Treasures) — pháp bảo chung (trang 73-79)

> Linh Bảo là pháp bảo "chung" mà mọi nhân vật đều có thể dùng (khác với Chuyên Chức Pháp Bảo riêng theo nhân vật).

### 5.1 Thiên Cơ Ốc (private storage space)

Thiên Cơ Ốc sở hữu một không gian khổng lồ riêng biệt.
- Tạo Thiên Cơ Ốc: Dùng **Thiên Cơ Cuộn Châu** đặt xuống → sinh ra Thiên Cơ Ốc.
- Khi Thiên Cơ Ốc được đặt, Thiên Cơ Cuộn Châu sẽ tự động chuyển đổi thành **Thiên Cơ Lệnh Bài**, dùng để thu hồi Thiên Cơ Ốc.
- Mỗi người đặt Thiên Cơ Ốc đều có không gian độc lập riêng, không bị chồng lấn với người khác.

**Thiên Cơ Cuộn Châu** (Vật phẩm; Prefab đoán: `xd_interiors`/`xd_playerhouse` related)
- Công thức: Giấy ×7, Gỗ Sống ×6, Đá Cẩm Thạch ×15, Hạ phẩm linh thạch ×45.

**Thiên Cơ Lệnh Bài**
- Dùng để thu hồi Thiên Cơ Ốc.
- Khi Thiên Cơ Cuộn Châu được đặt, sẽ tự động sinh ra Thiên Cơ Lệnh Bài để quản lý / thu hồi không gian.

### 5.2 Chưởng Thiên Bình (Linh Bảo)

**Công thức luyện chế:** Sừng Kỳ Lân ×1, Mảnh đá mặt Trăng ×6, Lam bảo thạch ×3, Hạ phẩm linh thạch ×30.

**Hiệu quả / Công dụng:**
- Ban đêm: có thể phục hồi độ bền.
- Thúc đẩy tăng trưởng cây trồng và cây Sa Đằng:
  - Cây Sa Đằng: mỗi lần sử dụng tiêu hao 100% độ bền.
  - Cây trồng khác: tiêu hao 50% độ bền.
- Có thể dùng để tưới linh thảo.

### 5.3 Dưỡng Hồn Đoản Thương (Linh Bảo)

**Công thức:** Trái Tim Bóng Tối ×1, Nhiên Liệu ác mộng ×10, Gỗ Sống ×5, Hạ phẩm linh thạch ×30.

**Hiệu quả:**
- Nhấn chuột phải để triệu hồi **Hồn Lang**.
- Mỗi lần triệu hồi tiêu hao 5 Hạ phẩm linh thạch.

**Hồn Lang** (Prefab đoán: `xd_soul_wolf` / `xd_soul_common`; brain `soul_wolfbrain`, SG `SGsoul_wolf`)
- Tồn tại trong nửa ngày.
- Hỗ trợ người chơi: bước trên mặt nước; thu ngắn khoảng cách di chuyển (thuộc tính **Thu Địa Thành Thốn**), giúp di chuyển nhanh hơn trong phạm vi nhất định.

### 5.4 Bích Cốc Đan (Linh Bảo)

**Công thức:** Vòi voi hoặc vòi voi mùa đông ×1, Cỏ khô ×3, Mật ong ×3, Hạ phẩm linh thạch ×5.

**Công dụng:** Có thể trì hoãn cơn đói của tu sĩ trong **5 ngày**.

### 5.5 Hộ Tâm Ngọc Bội (Linh Bảo)

**Công thức:** Hạch nhện ×3, Gỗ sống ×15, Vàng ×10, Hạ phẩm linh thạch ×30.

**Công dụng:** Giúp tu sĩ thoát thân khi cận tử, nhưng sẽ tiêu hao Linh Thạch. Cấp độ tu vi càng cao, lượng Linh Thạch tiêu hao càng nhiều:

| Cảnh giới | Tiêu hao |
|---|---|
| Luyện khí kỳ | 30 Hạ phẩm linh thạch |
| Trúc cơ kỳ | 50 Hạ phẩm linh thạch |
| Kết đan kỳ | 1 Trung phẩm linh thạch |
| Nguyên anh kỳ | 2 Trung phẩm linh thạch |
| Hóa thần kỳ | 3 Trung phẩm linh thạch |

**Thời gian hồi chiêu (CD):** 3 ngày.

### 5.6 Linh Bảo Tế Luyện Đài (công cụ tế luyện)

**Công dụng:** Dùng để tế luyện **Huyền Thiên Linh Bảo**, giúp tu sĩ điều khiển thần thông của Huyền Bảo một cách thuần thục hơn.

**Lưu ý khi tế luyện:**
- Cần tiêu hao **Bổn Nguyên Tế Bản**.
- Linh Thạch thượng phẩm và Linh Thạch cực phẩm đều có thể nâng cao tỷ lệ tế luyện thành công của Huyền Thiên Linh Bảo ở mức khác nhau.

### 5.7 Bổn Nguyên Tế Bản

**Công dụng:** Là nguyên liệu cần thiết để tế luyện pháp bảo.

**Cách sở hữu:**
- Có xác suất nhận được khi tiêu diệt bất kỳ yêu thú nào.
- Lần đầu mở **Linh Lung Bảo Tử** sẽ nhận được một lượng nhất định.

### 5.8 Phẩm cấp Linh Thạch

**Trung phẩm linh thạch (Prefab: `xd_lingshi` — phẩm trung)**
- Dùng để bồi dưỡng linh lực cho trang bị phòng ngự, nâng cao độ bền của trang bị lên gấp **5 lần**.
- Sau khi bồi dưỡng, dưới thanh độ bền sẽ hiển thị "(Đã qua linh lực bồi dưỡng)".
- Cách sở hữu: nhận được khi vượt ải hoặc tiêu diệt các yêu thú mạnh.

**Thượng phẩm linh thạch**
- Có thể dùng để tăng tỷ lệ tế luyện pháp bảo, mức cơ bản tăng **4%**, có thể điều chỉnh tỷ lệ trong giao diện cài đặt.
- Sử dụng trong máy rút Linh Thạch, bồi dưỡng trang bị, hoặc Cổ Truyền Tống Trận.
- Cách sở hữu: có xác suất nhận được khi vượt **Lượng Kiếp** trong **Lịch Luyện Chi Địa**.

**Cực phẩm linh thạch**
- So với Linh Thạch Thượng Phẩm, có thể tăng tỷ lệ tế luyện pháp bảo cao hơn, mức cơ bản tăng **7%**.
- Cách sở hữu: có xác suất nhận được khi vượt **Vô Lượng Lượng Kiếp** trong Lịch Luyện Chi Địa.

### 5.9 Huyền Thiên Linh Bảo (chung, không thuộc nhân vật cụ thể)

**Phẫn Thiên Kiếm** — Huyền Thiên Linh Bảo
- Khi thuần thục thần thông, có thể triệu hồi **Ảnh Kim Phượng** vào thế giới để trợ chiến, phá kẻ thù.
- Có thể tiêu thụ Linh Thạch Trung Phẩm để phục hồi độ bền.
- Cách sở hữu: có xác suất nhận được khi tiêu diệt yêu thú mạnh; trên Linh Bảo Tế Luyện Đài tại Lịch Luyện Chi Địa, chắc chắn xuất hiện một món Huyền Thiên Linh Bảo.

**Tôn Hồn Phiến** — Huyền Thiên Linh Bảo
- Khi thuần thục thần thông, có thể triệu hồi **yêu vương** trong thời gian nhất định để trợ chiến.
- Có thể tiêu thụ Linh Thạch Trung Phẩm để phục hồi độ bền.
- Cách sở hữu: giống như Phẫn Thiên Kiếm.

---

## 6. Chuyên Chức Pháp Bảo (trang 80-110)

> Mỗi pháp bảo Chuyên Chức gắn với 1 nhân vật cụ thể. Section này list theo nhân vật, dùng được khi đạt cảnh giới yêu cầu.

### 6.1 Huyết Sát Kiếm — Riêng của Vương Ma Tử
**Prefab đoán:** `xd_wmz_xsj` (Xian Sun Jian? — kiếm)

**Thông số:**
- Công kích: **100**
- Mô tả: "Ngưng tụ vạn phần lệ khí, kiếm minh như tiếng khóc quỷ thần"

**Linh kỹ – Định Thân Thuật:**
- Hồi chiêu: 20 giây
- Định thân mục tiêu và gây sát thương

**Thần thông – Thanh Quang Thuẫn:**
- Hồi chiêu: 60 giây
- Triệu hồi Thanh Quang Thuẫn, tồn tại 60 giây
- Có 40% khí huyết bản thể

### 6.2 Thái A Kiếm — Riêng của Thạch Cơ Nương Nương
**Prefab đoán:** `xd_sj_sxz` hoặc `xd_sj_tej`

**Thông số:**
- Công kích: 100
- Mô tả: *"Chớ nói ngoan thạch vô hận cốt, Thái A gào thét quỷ thần không."*

**Linh kỹ:**
- Hồi chiêu: 12 giây
- Bay vọt lên không trung, sau đó hóa thân thành thiên thạch rơi xuống điểm chỉ định.

**Thần thông:**
- Hồi chiêu: 60 giây
- Triệu hồi **Bàn Nhạc Thạch Khôi** trợ chiến trong 45 giây.
- Thạch Khôi sẽ tiếp tục triệu hồi thạch tôm cường hóa tham chiến.

---

### 6.3 Thanh Trúc Phong Vân Kiếm — Riêng của Hàn Thiên Tôn
**Prefab:** `xd_htz_xtzlj` (xác nhận vì PDF nói đây là pháp bảo bản mệnh của Hàn Thiên Tôn)

**Thông số:**
- Công kích: 100
- Mô tả: Pháp bảo bản mệnh của Hàn Thiên Tôn.

**Linh kỹ:**
- Hồi chiêu: 15 giây
- Nhảy vọt lên không trung, hóa thành thần lôi trừ tà xuất hiện tại điểm chỉ định.
- Đồng thời tại khu vực mục tiêu sẽ có nhiều Thanh Trúc Phong Vân Kiếm từ trên không giáng xuống.

**Thần thông:**
- Tiêu hao linh lực: **30 điểm** (khi mở khóa Huyền Thiên Tràm Linh Kiếm, tiêu hao tăng lên 40 điểm)
- Hồi chiêu: 60 giây
- Triệu hồi nhiều Thanh Trúc Phong Vân Kiếm xoay quanh bản thân và liên tục tấn công kẻ địch.

---

### 6.4 Kim Giao Tiễn — Riêng của Tam Tiêu Nương Nương
**Prefab đoán:** `xd_yunxiao_jjj` (Jin Jiao Jian)

**Thông số:**
- Công kích: 100
- Mô tả: *"Thâm cung cao các nhập Tử Thanh, Kim hóa giao long quẫn trụ thêu."*

**Linh kỹ:**
- Hồi chiêu: 15 giây
- Lao nhanh một đoạn, gây nhiều lần sát thương lên các mục tiêu trên đường lướt.

**Thần thông – Cửu Khúc Hoàng Hà Trận:**
- Hồi chiêu: 60 giây
- Khi thi triển:
  - Biến một khu vực lớn thành địa hình sa mạc tạm thời
  - Đứng trong khu vực sẽ hồi máu chậm
  - Sinh vật trong vùng bị giảm tốc
  - Cát đá rung chuyển gây sát thương liên tục lên sinh vật

---

### 6.5 Chỉ Thử Thanh Lục — Riêng của Tinh Vệ
**Prefab đoán:** `xd_jingwei_zzql` hoặc `xd_jingwei_fenice` link

**Thông số:**
- Công kích: 100
- Mô tả: *"Giang bích điểu du bạch, Sơn thanh hoa dục nhiên."*

**Linh kỹ:**
- Hồi chiêu: 15 giây
- Hóa thân thành cự điểu chân thân, gây sát thương diện rộng.

**Thần thông:**
- Hồi chiêu: 60 giây
- Cường hóa tùy tùng chuyên biệt (Huyền Điểu), khiến nó hóa thành cự đại Huyền Điểu trong một khoảng thời gian: tăng cường mô thức tấn công + mở khóa kỹ năng mới.

---

### 6.6 Như Ý Kim Cô Bổng — Riêng của Tôn Ngộ Không
**Prefab:** `xd_wukong_jgb` / `xd_jgb` (SG `SGxd_jgb_monkey`, `SGxd_jgb_mate`)

**Thông số:**
- Công lực tấn công: 100
- Nguồn gốc: Vật phẩm từ Đông Nam Sơn Hải, dài tám thước, đơn giản nhưng uy lực.

**Linh kỹ:** Chi tiết xem tại mục nhân vật Tôn Ngộ Không (§1.6).

**Thần thông:**
- Thời gian hồi chiêu (CD): 45 giây
- Hiệu quả: Triệu hồi 3 bản thể giống bản thân để tấn công kẻ địch.
  - Bản thể thứ 8 và 24 giây: Một trong ba bản thể tung Định Thân Thuật, nhưng thời gian chỉ bằng nửa bình thường, gây sát thương vỡ vụn **22.5**.
  - Bản thể thứ 16 giây: Một trong ba bản thể tung An Thân Thuật, kéo dài chỉ bằng nửa thời gian chuẩn, sát thương mỗi đoạn **2.3**, đồng thời hồi phục **3%** cho chủ nhân.

---

### 6.7 Mai Hương Như Cựu — Riêng của Tô Đát Kỷ
**Prefab đoán:** `xd_sudaji_xyj` hoặc related

**Thông số:**
- Công lực tấn công: 100
- Nguồn gốc: *"Linh hương còn nguyên khi tất cả tan thành bùn và bụi."*

**Linh kỹ:**
- Thời gian hồi chiêu: 12 giây
- Hiệu quả:
  - Nhấp nháy đến vị trí mục tiêu, đồng thời phát sinh **Quỷ Hỏa**.
  - Khi Quỷ Hỏa kết thúc: gây sát thương + cộng thêm **0.8 tầng** giá trị thôi miên, đồng thời hồi phục **3.3% máu** cho bản thân.

**Dưỡng Hồn Linh Ngọc** (Vật phẩm hỗ trợ — Prefab đoán: `xd_sudaji_yhly`)
- Loại: Vật phẩm trạng thái 2 trong hành trang.
- Bên trong: chứa một phần hồn của **Trụ Vương**.
- Công thức luyện chế: Dây thừng ×1, Vàng ×3, Hồng bảo thạch ×3, Trung phẩm linh thạch ×3.

**Cơ chế trạng thái:**
- Trạng thái 1: độ bền <50%, không cộng tốc độ, không cộng lý trí.
- Trạng thái 2: độ bền ≥50%, tốc độ +10%, lý trí +12 điểm/phút, đồng thời tăng cường hiệu quả thần thông các giai đoạn.

**Cơ chế hồi sinh (Trụ Vương xuất hiện):**

Khi Tô Đát Kỷ sở hữu Dưỡng Hồn Ngọc Bội và nhận sát thương chí mạng:
- **Trụ Vương** hiện thân từ Dưỡng Hồn Ngọc Bội, có thể do người chơi điều khiển.
- Trụ Vương không chết, bất tử, giảm sát thương **95%**, và có thể tung linh kỹ và thần thông.
- Mỗi đòn tấn công của Trụ Vương hút máu **5%** máu tối đa của bản thân, tối đa không vượt quá 100%.
- Thời gian điều khiển Trụ Vương **30 giây**:
  - Nếu máu Trụ Vương đạt 100%, Tô Đát Kỷ hồi phục lại thân xác.
  - Nếu không đạt 100%, Tô Đát Kỷ sẽ tử vong.
- Khi hồi sinh, Dưỡng Hồn Linh Ngọc bị xóa toàn bộ độ bền, và thần thông bắt đầu CD **75 giây**.

**Thần thông (Mai Hương Như Cựu):**
- Thời gian hồi chiêu: 180 giây
- Thời gian tồn tại: 120 giây
- Hiệu ứng khi kích hoạt:
  - Tiêu hao 15% máu.
  - Mỗi giai đoạn của thần thông được tăng cường khi Dưỡng Hồn Linh Ngọc ở trạng thái 2.

**Tùy theo máu của Tô Đát Kỷ:**

| Máu | Hiệu ứng thần thông |
|---|---|
| >70% và ≤100% | Xuất hiện vòng lửa xung quanh tấn công đồng loạt, mỗi đòn cộng thêm **1.3 tầng** thôi miên. |
| >40% và ≤70% | Triệu hồi **Pháp Thân Trụ Vương** trợ chiến (yêu cầu Dưỡng Hồn Linh Ngọc còn ≥10% độ bền). Khi người chơi phát sinh Công Đức Kim Thân hoặc Vô Thượng Ma Thể, pháp thân Trụ Vương cũng tấn công đồng loạt. |
| ≤40% | Triệu hồi **Trụ Vương bản chính** trợ chiến (yêu cầu Dưỡng Hồn Linh Ngọc còn ≥10% độ bền). Khi người chơi phát sinh Công Đức Kim Thân, Vô Thượng Ma Thể, hoặc sử dụng Linh Kỹ, Trụ Vương bản chính sẽ tấn công đồng loạt. |

---

### 6.8 Thủy Long Ngâm — Riêng của Ngao Bính
**Prefab đoán:** `xd_longzhu` (Long Châu link) hoặc kiếm Ngao Bính

**Thông số:**
- Công lực tấn công: 100
- Nguồn gốc: *"Chôn sâu chí cao không đổi, một hội phong vân chính là hoàng."*

**Linh kỹ (theo tầng Băng Linh Khí):**
- Thời gian hồi chiêu: 12 giây

| Tầng | Hiệu quả |
|---|---|
| 1 | Nhấp nháy đến mục tiêu, bắn nước tung tóe, gây sát thương diện rộng. |
| 2 | Nhấp nháy đến mục tiêu, tạo băng tinh mặt đất, gây sát thương và đóng băng mục tiêu. |
| 3 | Nhấp nháy đến mục tiêu, tạo băng tinh diện tích lớn, liên tục sinh ra Băng Linh Khí để đóng băng mục tiêu. |
| 4 | Giữ hiệu quả tầng 3 và đồng thời tạo lá chắn thuộc tính băng cho bản thân, hấp thụ 1 đòn. Nếu lá chắn bị phá, sinh vật bị trúng 2 tầng đóng băng. Lá chắn tồn tại 4 giây hoặc bị đánh 1 lần, có thể cộng dồn với lá chắn từ thần thông. |

**Thần thông (theo tầng Băng Linh Khí):**
- Thời gian hồi chiêu: 30 giây

| Tầng | Hiệu quả |
|---|---|
| 1 | Nhận trạng thái tăng cường; mỗi đòn tấn công bình thường tạo một sóng biển lao về phía trước, gây sát thương. |
| 2 | Tăng khoảng cách tấn công; mỗi đòn gây một quả cầu băng nhỏ bay tới mục tiêu, gây sát thương. |
| 3 | Tăng khoảng cách tấn công, băng cầu được tăng cường, bật giữa các sinh vật; đồng thời tạo lá chắn băng cho bản thân, tấn công bạn sẽ bị phản công gây 2 tầng đóng băng, hấp thụ 2 đòn, tồn tại 15 giây. |
| 4 | Ngoài hiệu quả tầng 3, xung quanh quái vật mưa đá liên tục rơi, mỗi viên trúng sinh vật sẽ cộng thêm giá trị đóng băng. |

---

### 6.9 Long Châu — Riêng của Ngao Bính
**Prefab:** `xd_longzhu`

**Công thức luyện chế:** Lam bảo thạch ×4, Băng ×13, Đá cẩm thạch ×9, Trung phẩm linh thạch ×1.

**Cơ chế:**
- Độ bền khởi điểm: **10%**.
- Có thể dung hợp các loại bảo thạch để hồi độ bền.
- Chuột phải để thi pháp, mở vòng kỹ năng Long Châu.

**Kỹ năng Long Châu:**

| # | Kỹ năng | Hiệu ứng |
|---|---|---|
| 1 | Giáng Vũ | Triệu hồi mưa trong khu vực |
| 2 | Hàn Băng Linh Nhãn | Tồn tại 1 ngày; hiệu ứng tương đương Tinh Thể Băng Nhãn; có thể dùng cuốc để khai thác công trình này |
| 3 | Lạc Lôi | Gọi sét đánh mục tiêu |
| 4 | Băng Lao | Tạo một vòng quặng băng; đào bất kỳ khối nào sẽ rơi ra 3 băng; sau một thời gian sẽ tự vỡ |
| 5 | Hàn Băng Pháp Trận | Giải phóng băng linh khí; đóng băng mục tiêu trong phạm vi nhỏ |
| 6 | Cực Quang | Hiệu ứng cực quang; chỉ tồn tại 1 ngày |
| 7 | Không Gian Trữ Vật | Không tiêu hao độ bền; mở một không gian chứa đồ có hiệu ứng giữ tươi; khi nhân vật di chuyển, không gian sẽ tự động đóng |
| 8 | Băng Linh Hộ Thể | Triệu hồi Băng Điệp làm linh sủng; duy trì nhiệt độ cơ thể, liên tục hạ nhiệt trong một khoảng thời gian |

---

### 6.10 Tổng Quan Pháp Bảo Chuyên Chức (cơ chế chung)

**Đặc điểm:**
- **Sinh ra đã gắn kết:** Đây là bản mệnh pháp bảo của bản thân, không rơi khi chết.
- **Độ bền:** Pháp bảo có 100% độ bền, ban đầu chỉ 30%. Có thể phục hồi độ bền bằng cách tiêu thụ các vũ khí khác.
- Khi hết độ bền, sát thương chỉ còn **10 điểm**.
- Pháp bảo bị mất vẫn có thể tái luyện chế.

**Công thức luyện chế (cơ bản):**
- Mảnh xương ×1
- Gỗ sống ×3
- Hồng bảo thạch ×5
- Hạ Phẩm Linh Thạch ×30

**Lưu ý:** Pháp bảo mới luyện chế sẽ có độ bền 0.

---

### 6.11 Pháp bảo Chuyên Chức cho nhân vật DST vanilla

> Mod cấp pháp bảo chuyên chức cho TẤT CẢ nhân vật DST gốc (không chỉ 8 nhân vật Đăng Tiên).

#### 6.11.1 Hỗn Nguyên Phủ — Riêng của Woodie

**Thông số:** Công lực tấn công 87.5; *"Mở khai Hồng Mông, Hỗn Nguyên sơ hiện."*

**Linh kỹ:** Hồi chiêu 12s; ném cây rìu ánh sáng về hướng mục tiêu, rìu quay vòng trên không; đường đi đi và về đều gây sát thương trên kẻ địch.

**Thần thông:** Hồi chiêu 60s; trong thời gian thần thông, vũ khí chuyển dạng, tăng khoảng cách tấn công; khi tấn công, sát thương có thể nảy lan tối đa **8 quái vật**, đồng thời 25% giảm sát thương nhận vào (áp dụng cả sát thương thực tế từ không gian khác) + tăng 25% tốc độ di chuyển.

#### 6.11.2 Phù Dung Huyền Kỳ Tản — Riêng của Wes

**Thông số:** Công lực 100; *"Dưới Huyền Kỳ Tản tìm thấy an nhàn, lén lút hưởng nửa ngày phàm trần."*

**Linh kỹ:** Hồi chiêu 12s; tạo ra ảo ảnh giống hệt Wes, tiến hành 3 đợt tấn công trước khi biến mất.

**Thần thông:** Hồi chiêu 30s; sau khi sử dụng kỹ năng, ngay lập tức bước vào trạng thái ẩn thân.
- Trong trạng thái ẩn thân: hành động chủ động của kẻ địch không nhận Wes là mục tiêu, nhưng vẫn bị ảnh hưởng bởi sát thương diện rộng. Nếu bị sát thương hoặc người chơi chủ động tấn công, ẩn thân kết thúc (không bao gồm việc tung linh kỹ).
- Trạng thái ẩn thân kéo dài nửa ngày.
- Mỗi lần kích hoạt kỹ năng để ẩn thân, nhận trạng thái tăng cường 10 giây: trong trạng thái này, mỗi 2 đòn tấn công sẽ bắn ra một đợt máu đen lớn, văng xuống mặt đất xung quanh mục tiêu, hóa thành xúc tu bóng tối hỗ trợ tấn công.

#### 6.11.3 Phẫn Tịch — Riêng của Maxwell

**Thông số:** Công lực 100; *"Trường cầm hồn đoạn, máu vẽ trận; đúc thành Phẫn Tịch, diệt vong chúng sinh."*

**Linh kỹ:** Hồi chiêu 15s; triệu hồi 5 bóng tối đan xen; khi bóng tối tiếp cận mục tiêu, nổ tung, gây sát thương. Nếu trong phạm vi nổ có chủ nhân, mỗi bóng tối nổ sẽ hồi một lượng máu nhất định cho chủ nhân.

**Thần thông:** Hồi chiêu 90s; triệu hồi 2 Giám Mục Bóng Tối xung quanh người chơi, hỗ trợ tấn công trong thời gian nhất định.

#### 6.11.4 Kim Lân — Riêng của Wurt

**Thông số:** Công lực 100; *"Vảy vàng há phải vật dưới hồ, một khi gặp phong vân liền hóa long."*

**Linh kỹ:** Hồi chiêu 12s; tạo cột nước bắn lên xung quanh chủ nhân, đồng thời 3 luồng sóng nước đẩy đi, có hiệu ứng hất văng mục tiêu.

**Thần thông:** Hồi chiêu 60s; triệu hồi 2 vệ sĩ nhân cá xung quanh chủ nhân hỗ trợ tấn công. Liên kết với linh kỹ: khi chủ nhân tung linh kỹ, 2 vệ sĩ nhân cá cũng tung linh kỹ một lần. Nếu triệu hồi Vua Nhân Cá, chủ nhân nhận **66% giảm sát thương bổ sung**.

#### 6.11.5 Xích Long — Riêng của Wigfrid

**Thông số:** Công lực 100; *"Xích Long tung hoành chín vạn dặm, Ngọc Kinh và Bồng Lai tự do tự tại."*

**Linh kỹ:** Hồi chiêu 12s; nhảy tới vị trí mục tiêu, gây sát thương và tạo địa hình sụt giảm tốc độ cho kẻ địch.

**Thần thông:** Hồi chiêu 60s; trong thời gian thần thông, vũ khí chuyển dạng, tăng khoảng cách tấn công; khi tấn công tạo ra lốc xoáy, kéo các sinh vật về trung tâm; đòn tấn công trở thành sát thương diện rộng, đồng thời hồi một lượng máu nhất định cho chủ nhân sau mỗi đòn.

#### 6.11.6 Tinh La Kiếm — Riêng của WX-78

**Thông số:** Công lực 100; *"Tinh La lấp lánh, trăng sáng ngời; hỡi chàng có uống một chén không?"*

**Linh kỹ:** Hồi chiêu 12s; triệu hồi robot hẹn giờ tới vị trí mục tiêu; khi sinh vật tiến gần, robot sẽ kích nổ, hoặc tự động nổ sau thời gian nhất định.

**Thần thông:** Hồi chiêu 60s; liên tục triệu hồi 3 luồng sấm sét tấn công chủ nhân và 2 sinh vật khác trong phạm vi.
- Khi sấm sét đánh vào chủ nhân, không gây sát thương mà hồi phục máu.
- Khi đánh vào chủ nhân hoặc 2 sinh vật khác, gây sát thương diện rộng cho tất cả mục tiêu trừ bản thân.
- Mỗi lần sấm sét đánh xuống sẽ kích nổ tất cả robot hẹn giờ trên sân một lần.

#### 6.11.7 Thiên Phiên Vạn Kiếp Đao — Riêng của Wanda

**Thông số:** Công lực 100; *"Thiên không bao la, Vạn Kiếp Thái Cực trường tồn."*

**Linh kỹ:** Tự động kích hoạt — không cần dùng kỹ năng, khi tấn công có xác suất tạo ra một khe nứt thời gian. Trong thời gian khe nứt, vài Wanda sẽ xuất hiện với các tình huống khác nhau:
1. Cầm Trượng Băng Pháp tấn công mục tiêu rồi biến mất.
2. Cầm Trượng Hỏa Ma tấn công mục tiêu rồi biến mất.
3. Cầm Tiêu Thời Tiết Khí tấn công mục tiêu rồi biến mất.
4. Cầm Bài Tiêu và dùng, sau đó biến mất.
5. Dùng Trượng Triệu Tinh Giả, rồi biến mất.
6. Thả một món ăn ngẫu nhiên.
7. Xuất hiện Wanda cầm chuyên vũ và tung thần thông: tạo lá chắn bất tử, nhưng thời gian tồn tại ngắn hơn thần thông của Wanda.

**Thần thông:** Hồi chiêu 45s; trong thời gian duy trì, cấp cho bản thân lá chắn bất tử. Khi lá chắn tồn tại, mỗi đòn tấn công sẽ chuyển thành sát thương diện rộng.

#### 6.11.8 Thanh Nguyệt — Riêng của Winona

**Thông số:** Công lực 100; *"Hồng phi minh minh nhật nguyệt bạch, Thanh phong diệp xích thiên vũ sương."*

**Linh kỹ:** Hồi chiêu 12s; khi có robot thần thông xuất hiện, phóng quả cầu laser về vị trí mục tiêu. Nếu robot không tồn tại, không thể sử dụng kỹ năng.

**Thần thông:** Hồi chiêu 120s; triệu hồi 1 robot xung quanh chủ nhân để hỗ trợ tấn công.
- Có thể gọi robot về bằng cách nhấn lại nút thần thông.
- Khi dùng biểu cảm nhảy múa, robot sẽ sao chép biểu cảm y hệt.
- Thời gian tồn tại: vô hạn; hồi chiêu xảy ra khi robot bị gọi về hoặc chết.
- Khi thoát chiến đấu vài giây, chủ nhân sẽ tự hồi phục máu.
- Nếu robot thần thông tồn tại, **37% sát thương** nhận vào của Winona (bao gồm sát thương từ các không gian khác) sẽ được robot gánh thay.

#### 6.11.9 Bất Tận Thần Kiếm — Riêng của Wormwood

**Thông số:** Công lực 100; *"Tứ Thiên chưa đến, phong không dừng; Cửu Chuyển vô công, hóa bất thiêu."*

**Linh kỹ:** Hồi chiêu 12s; chủ nhân tung gai nhọn về mục tiêu, gây sát thương diện rộng. Linh kỹ này liên kết với thần thông để tạo hiệu quả mạnh hơn.

**Thần thông:** Hồi chiêu 30s; triệu hồi 7 Tinh Linh Quả Phỉ xung quanh chủ nhân để tấn công mục tiêu.
- Khi chủ nhân di chuyển, đường đi sẽ xuất hiện Quả Dạ Quang và cây Dương Xỉ, tồn tại một thời gian rồi mờ dần, trong khoảng thời gian này hồi phục máu liên tục cho chủ nhân.
- Khi sử dụng linh kỹ, tất cả Tinh Linh Quả Phỉ cũng sẽ tung linh kỹ đồng thời.

#### 6.11.10 Vấn Thế — Riêng của Wolfgang

**Thông số:** Công lực **86.5 + 1 điểm sát thương vị diện**; *"Ngày sau sẽ đứng trên đỉnh tuyệt cực, dám hỏi chín tầng trời có sánh cao?"*

**Linh kỹ:** Loại bị động. Mỗi 2 đòn tấn công, đòn thứ 3 sẽ tạo ra bụi bay tung tóe, gây sát thương bắn ra xung quanh.

**Thần thông:** Hồi chiêu 40s; chủ nhân nhận trạng thái tăng cường trong thời gian nhất định. Trong trạng thái này: nhận **60% giảm sát thương bổ sung**, không bị gián đoạn khi tấn công. Mỗi 3 đòn tấn công: đòn đầu tiên tạo ra bụi bay tung tóe; đòn thứ hai và ba tạo ra cát đá văng ra phía trước, gây sát thương diện rộng hơn.

#### 6.11.11 Tiêu Kim Xích Cốt Đao — Riêng của Willow

**Thông số:** Công lực 100; *"Thiên địa hào kiệt khí, ngàn thu vẫn sừng sững."*

**Linh kỹ:** Hồi chiêu 12s; ném 3 quả cầu lửa về vị trí mục tiêu, gây sát thương diện nhỏ xung quanh.

**Thần thông:** Hồi chiêu 30s; tạo ra luồng lửa băng xanh dạng quạt về phía trước, gây sát thương diện rộng. Trong trạng thái này, vẫn có thể sử dụng linh kỹ mà không tốn hành động tấn công. Đồng thời, cấp cho bản thân lá chắn băng: khi bị tấn công, tăng tầng đóng băng cho kẻ tấn công, có thể chặn 3 đòn sát thương.

#### 6.11.12 Hạnh Hoa Vi Vũ Kiếm — Riêng của Wendy

**Thông số:** Công lực 100; *"Hạnh hoa vi vũ say lòng người, hoa triều cố nhân trở về."*

**Linh kỹ:** Hồi chiêu 12s; tỏa cánh hoa, gây sát thương diện rộng. Abigail cũng sẽ sử dụng linh kỹ này đồng thời.

**Thần thông:** Hồi chiêu 42s; trong một phạm vi nhất định, hoa liên tục mọc lên gây sát thương diện rộng. Kích hoạt trạng thái dễ bị tổn thương của mục tiêu do Abigail gây ra.

**Abigail được tăng cường:** Phòng ngự 90%, Phòng ngự vị diện 20 điểm.

#### 6.11.13 Vong Ưu Kiếm — Riêng của Wortox

**Thông số:** Công lực 100; *"Hoa đỏ rực rụng hết mới biết bâng khuâng, đi thẳng con đường quên ưu mà vẫn chưa quên."*

**Linh kỹ:** Loại bị động. Mỗi đòn tấn công có xác suất tạo ra ảo ảnh hỗ trợ tấn công. Khi đánh trúng mục tiêu, cộng thêm 1 tầng đóng băng và hiệu ứng thiêu đốt. Trong trạng thái thiêu đốt, chủ nhân hồi phục máu.

**Thần thông:** Hồi chiêu 30s; xung quanh chủ nhân liên tục mọc hoa đỏ, gây sát thương liên tục, đồng thời kích nổ sớm Hồn Hỏa gây sát thương mạnh hơn. Khi kích hoạt, cũng kích hoạt hiệu quả hồi máu của linh kỹ.

#### 6.11.14 Vô Tướng Kiếm — Riêng của Wilson

**Thông số:** Công lực 100; *"Vô tướng cũng có tướng, chúng sinh đều có thể độ."*

**Linh kỹ:** Hồi chiêu 12s; khi thần thông biến thân thành các cơ giáp khác nhau, linh kỹ sẽ tạo ra hiệu quả riêng biệt tùy cơ giáp.

**Thần thông:** Hồi chiêu 30s; biến thân thành một trong các cơ giáp: **xanh, lục, cam, tím, lam**. Khi biến thân: tiêu thụ 100% độ bền của một trang bị đang mặc, kế thừa giảm sát thương của trang bị đó; nhận thêm 25% giảm sát thương cơ bản và tỏa sáng.

**Hiệu ứng từng cơ giáp:**

| Cơ giáp | Tấn công thường | Linh kỹ |
|---|---|---|
| Xanh lá | Tạo gai diện rộng gây sát thương | Trói kẻ địch xung quanh và triệu thực vật tấn công mục tiêu |
| Lam | Cộng thêm tầng đóng băng cho kẻ địch | Tỏa khí lạnh xung quanh, sát thương diện rộng + cộng tầng đóng băng |
| Tím | Xác suất kích hoạt tia laser | Tung tia laser diện rộng |
| Đỏ | Xác suất gây sát thương lửa diện rộng | Ném quả cầu lửa về mục tiêu, gây sát thương |
| Màu (hiếm) | Tăng mạnh sát thương tấn công thường, vô địch toàn diện; khi bị tấn công: kẻ thù chịu 1 lần hiệu ứng mê, đóng băng, phản sát thương; khi tấn công triệu hồi xúc tu bóng tối | Dịch chuyển tức thời đến mục tiêu, gây sụt đất, sát thương diện rộng lửa và khí băng, sát thương cực lớn |

#### 6.11.15 Mặc Nhiễm — Riêng của Wickerbottom

**Thông số:** Công lực 100; *"Như khách vút qua nhân gian, Mặc Nhiễm in dấu tinh tú giữa mây nước."*

**Linh kỹ:** Hồi chiêu 12s; khi thần thông triệu hồi **Cổ Cấu Chỉ Ảnh**, tại trung tâm xuất hiện cấu trận xương.

**Thần thông:** Hồi chiêu 90s; triệu hồi Cổ Cấu Chỉ Ảnh hỗ trợ chủ nhân trong chiến đấu.

#### 6.11.16 Nghị Lân — Riêng của Webber

**Thông số:** Công lực 100; *"Thiên thần quý tộc, không gì quý hơn Thanh Long, không thể làm kẻ thù."*

**Linh kỹ:** Hồi chiêu 30s; triệu hồi 3 Huyệt Cư Huyền Chu đội mỏ Thiều Khoáng, hỗ trợ chủ nhân tấn công.

**Thần thông:** Hồi chiêu 90s; triệu hồi **Thần Hồn Nữ Vương Nhện** hỗ trợ chủ nhân; nữ vương nhện còn triệu hồi Huyệt Cư Huyền Chu và Nhện Phá Giới cùng hỗ trợ tấn công.

#### 6.11.17 Long Hồn Vấn Đạo Châu — Riêng của Warly

**Thông số:** Công lực 100; *"Từ xưa chinh chiến ngàn năm, Long Hồn vấn đạo chỉ trong một niệm."*

**Linh kỹ:** Hồi chiêu 12s; trong một phạm vi quanh chủ nhân, gây sát thương lửa diện rộng.

**Thần thông:** Hồi chiêu 45s; cấp cho bản thân trạng thái tăng cường; mỗi 2 đòn tấn công sẽ kích hoạt sát thương **Lửa – Phong**; đồng thời, hiệu ứng này cũng áp dụng cho đồng đội.

#### 6.11.18 Thiên Thú Thực Nguyên Thương — Riêng của Walter

**Thông số:** Công lực 100; *"Ngậm linh săn yêu, không thể làm kẻ thù."*

**Linh kỹ:** Hồi chiêu 12s; gắn dấu **Ảnh Bóng** lên mục tiêu, sau đó **Đại Thương Cá Băng Bóng** sẽ nhảy tới tấn công mục tiêu.

**Thần thông:** Hồi chiêu 30s; nhận trạng thái tăng cường liên tục; khi tấn công, sát thương sẽ phản hồi giữa các sinh vật; có xác suất triệu hồi 2 **Hải Tượng Bóng** hoặc **Bóng Phân Thân** tấn công mục tiêu.

#### 6.11.19 Kim Cô Bổng — Riêng của Wilbur (Vô Hầu)

**Thông số:** Công lực 100; *"Đánh tan mọi điều bất bình thế gian, xua đi muộn phiền ngàn thu."*
**Ghi chú:** Trong giao diện cài đặt có thể lựa chọn bật/tắt nhân vật Vô Hầu.

**Linh kỹ:** Hồi chiêu 15s; triệu hồi 3 bản thể **Kim Thân** để tấn công mục tiêu.

**Thần thông:** Hồi chiêu 45s; triệu hồi 2 **Kim Thân Đại Phó** hỗ trợ chủ nhân trong chiến đấu; mỗi lần tấn công hồi phục máu cho chủ nhân; sau một khoảng thời gian, tiếp tục triệu hồi 3 **Hải Tặc Hầu** hỗ trợ tấn công.

**Biến hóa:** Khi tay không, nhấn giữ phím Alt và click vào mục tiêu, Vô Hầu có thể biến hóa, có khả năng ẩn thân nhất định để không bị yêu thú phát hiện.

---

## 10. Linh Mộc Thần Thụ (trang 111-115)

### 10.1 Cây Sa Đằng (trang 111-112)

**Prefab đoán:** `xd_shatangshu`

- Có bóng mát tương đương Đại Thụ thông thường, mang lại hiệu quả hạ nhiệt, che mưa và tránh sấm sét.
- Dưới bóng cây và trong nhà Đại Thụ đều có tác dụng hồi phục thần thức.
- Khi vừa bước vào giai đoạn trở thành Đại Thụ, cây sẽ sinh ra một nhánh **Lý Quả Sa Đằng**; người chơi có thể trực tiếp thu hoạch quả Sa Đằng trên đó. Sau khi thu hoạch, cả nhánh quả Sa Đằng biến mất. Tiếp theo, cứ 2 ngày lại sinh ra một nhánh quả Sa Đằng mới. Số lượng nhánh quả Sa Đằng rủ xuống tối đa là 2; khi đạt tối đa, sẽ không sinh ra nhánh mới nữa.
- Phần gốc cây có một nhà gỗ nhỏ, phát ra ánh sáng trong phạm vi hẹp. Không gian bên trong nhà gỗ giữ nhiệt độ ổn định và sáng rực.

**Sa Đằng Thụ Căn** (gốc cây)
- Khi vớt linh mộc dưới thủy vực, sẽ có nửa phần xác suất thu được Sa Đằng Thụ Căn.
- Tưới Sa Đằng Thụ Căn bằng **Chưởng Thiên Bình** có thể giúp nó phát triển lên giai đoạn 2.

**Sa Đằng Giai Đoạn 2 (Đại Thụ Thứ Nhất)**
- Sa Đằng ở giai đoạn 2 chỉ có một nửa hiệu quả hồi thần thức so với cây Sa Đằng trưởng thành.

**Quả Sa Đằng** (Prefab: `xd_deciduous_root` related)
- Khi ăn, hồi phục ba chỉ số: No bụng 47.5 / Thần thức 7 / Khí huyết 3.
- Mỗi 2 ngày chỉ được ăn 1 quả, giúp người chơi có thể bước qua nước trong một ngày.
- Thời gian thối rữa: 15 ngày.

### 10.2 Cây Phản Hồn (trang 113-115)

**Prefab đoán:** `xd_fanhunshu`

- Có bóng mát tương đương Đại Thụ thông thường, mang lại hiệu quả hạ nhiệt, che mưa và tránh sấm sét.
- Dưới bóng cây và trong nhà Đại Thụ đều có tác dụng hồi phục thần thức.
- Mỗi **3 ngày** sẽ sinh ra một nhánh Quả Phản Hồn, số nhánh rủ tối đa là 2; khi đạt tối đa, sẽ không sinh nhánh mới nữa.
- Phần gốc cây có nhà gỗ nhỏ, phát ra ánh sáng trong phạm vi hẹp. Không gian bên trong giữ nhiệt độ ổn định, sáng rực và có thể hồi phục máu từ từ (**0.5% mỗi giây**) cùng hồi phục **8 điểm tinh thần mỗi phút**.
- Trong nhà gỗ còn lưu giữ di sản của các bậc tiền bối, mang hơi thở cổ xưa và linh thiêng.

**Hiệu quả Phục Sinh:**
- Người chơi có 2 cơ hội "**cương tụ xác thân**". Khi chết, nếu có Cây Phản Hồn đang hiện diện, người chơi sẽ được phục sinh, đồng thời tiêu hao 1 lần phục sinh của cây.
- Mỗi ngày, số lần phục sinh này tái hồi 1 điểm, tối đa 2 điểm.

**Quả Phản Hồn**
- Khi ăn, hồi phục ba chỉ số: No bụng 15 / Thần thức 20 / Khí huyết 5.
- Sau khi ăn, trong 1 ngày, mỗi 2 giây hồi 2 điểm máu (tăng theo cảnh giới) và hồi 6 điểm tinh thần mỗi phút.

**Hương Phục Sinh** (món ăn)
- Nguyên liệu nấu: Quả Phản Hồn + thịt > 0 + trứng > 0 + rau > 0.
- Khi ăn: No bụng 67.5 / Thần thức 25 / Khí huyết 45.
- Hiệu ứng đặc biệt: trong thời gian tác dụng, nếu người chơi chết và để lại xương, có thể phục sinh trực tiếp từ xương.

**Mứt Quả Phản Hồn** (món ăn)
- Nguyên liệu nấu: Quả Phản Hồn + thịt = 0 + các vật liệu bổ sung khác.
- Khi ăn: No bụng 20 / Thần thức 22 / Khí huyết 7.
- Sau khi ăn, trong 1 ngày, mỗi 2 giây hồi 3 điểm máu (tăng theo cảnh giới) và hồi 6 điểm tinh thần mỗi phút.

---

## 11. Trang trí (Decorations) — trang 116-121

> Toàn bộ vật phẩm trang trí mỗi sáng sớm có **40% cơ hội** sinh ra một con bướm, mang lại hiệu quả hồi phục tinh thần trong phạm vi nhỏ.
> **Prefab chung:** `xd_flowers`, `xd_huapen` (chậu hoa), `xd_planted_tree`

| Tên | Công thức |
|---|---|
| Thủy Phù Dung | 2 Bướm, 3 Lam bảo thạch, 1 Hạ phẩm linh thạch |
| Triều Dương Hoa | 2 Bướm, 3 Gỗ sống, 1 Hạ phẩm linh thạch |
| Bạch Hồng | 2 Bướm, 1 Hoàng Bảo Thạch, 1 Hạ phẩm linh thạch |
| Linh Lan | 2 Bướm, 15 Cành cây, 1 Hạ phẩm linh thạch |
| U Lan | 2 Bướm, 3 Đá cẩm thạch, 1 Hạ phẩm linh thạch |
| Mẫu Đơn | 2 Bướm, 3 Hồng Bảo Thạch, 1 Hạ phẩm linh thạch |
| Bách Hợp | 2 Bướm, 2 Tử Bảo Thạch, 1 Hạ phẩm linh thạch |
| Bồ Công Anh | 2 Bướm, 12 Gỗ, 1 Hạ phẩm linh thạch |
| Mộc Lê Hoa | 2 Bướm, 1 Lục Bảo Thạch, 1 Hạ phẩm linh thạch |

**Cây cảnh trang trí (Mỗi 7 ngày sinh ra bảo thạch tương ứng; giữ nhiệt cố định trên diện tích 1.5 ô đất):**

| Tên | Công thức | Bảo thạch sinh ra |
|---|---|---|
| Cây Anh Đào | 4 Gỗ sống, 4 Tử Bảo Thạch, 1 Hạ phẩm linh thạch | 2 viên Tử Bảo Thạch |
| Đan Phong | 4 Gỗ sống, 8 Hồng Bảo Thạch, 1 Hạ phẩm linh thạch | 4 viên Hồng Bảo Thạch |
| Ngân Hạnh | 4 Gỗ sống, 2 Cam Bảo Thạch, 1 Hạ phẩm linh thạch | 1 viên Cam Bảo Thạch |
| Hạnh Hoa Thụ | 4 Gỗ sống, 2 Hoàng Bảo Thạch, 1 Hạ phẩm linh thạch | 1 viên Hoàng Bảo Thạch |
| Yên Liễu Thụ | 4 Gỗ sống, 2 Lục Bảo Thạch, 1 Hạ phẩm linh thạch | 1 viên Lục Bảo Thạch |
| Lam Sam | 4 Gỗ sống, 2 Lam Bảo Thạch, 1 Hạ phẩm linh thạch | 1 viên Lam Bảo Thạch |

---

## 12. Địa Luyện Thể (Lịch Luyện Chi Địa) — trang 122-123

> **Prefab đoán:** `xd_jitan` (Tế Đàn) + `xd_jitan_antlion_sinkhole`

**Đàn Tế:**
- Chỉ **Nguyên Anh kỳ trở lên** mới có thể dùng vật phẩm đặc thù để kích hoạt.
- Phần thưởng sau khi vượt ải sẽ xuất hiện trong **Bảo Rương Linh Lung**.

**Kích hoạt đàn tế:**
- Dùng Trung Phẩm Linh Thạch hoặc Thượng phẩm để kích hoạt, có thể khởi sinh **Lượng Kiếp Tiên Pháp**, **Lượng Kiếp Sinh Tử** và **Lượng Kiếp Vô Lượng**.
- Qua các lượng kiếp này, người chơi nhận phần thưởng, có thể kiểm tra trong Bảo Rương Linh Lung.

**Truyền Trận Cổ:**
- Có thể tìm thấy trong **đầm lầy**.
- Dùng 1 viên Trung Phẩm Linh Thạch để kích hoạt, có thể truyền tới Địa Luyện Thể.

**Bảo Rương Linh Lung:**
- Loại rương này xuất hiện tại Địa Luyện Thể.
- Lần mở đầu tiên nhận được phần thưởng phúc duyên, số lượng mảnh Bản Nguyên có thể cấu hình trong giao diện cài đặt.
- Tất cả phần thưởng trong quá trình luyện tập đều hội tụ tại đây.
- Mỗi người chơi chỉ nhìn thấy phần thưởng của riêng mình trong rương.

**Từ Sinh Tự Đài:**
- Có thể tái tạo xác thân đồng đạo (dùng để hồi sinh).
- Có 3 cơ hội cương tụ xác thân.
- Mỗi 2 ngày phục hồi 1 lần cơ hội.

---

## 13. Côn Bằng Tiên Đảo (Kunpeng Island Dungeon) — trang 124-131

**Prefab:** `xd_kunpeng_shadow`, `xd_kunpengspawner` (component spawner), `xd_kunpengstage` (component stage), `map/static_layouts/xd_kunpeng`, widget `xd_kunpengui`

### 13.1 Cơ chế xuất hiện đảo

- Mỗi **7 ngày** vào buổi sáng, một **Côn Bằng** sẽ bay qua bầu trời (ngày đầu tiên cũng xuất hiện; sau đó vào các ngày 7, 14, 21… tức bội số của 7).
- Khi Côn Bằng bay qua, người chơi sẽ bị giảm **20 điểm Thần thức**.
- Khi tu sĩ đạt **Nguyên Anh kỳ**, lần bay tiếp theo của Côn Bằng sẽ bị tự động hạ gục từ trên cao.
- Sau đó, trên vùng biển rộng nhất có thể, sẽ hình thành **Côn Bằng Tiên Đảo**.

### 13.2 Trạng thái đảo (4 trạng thái)

Đảo tồn tại các trạng thái: **Bình Tĩnh, Phiền Nhiễu, Bạo Nộ, An Ủi**.

**Bình Tĩnh:** trạng thái mặc định.

**Phiền Nhiễu:** Lông mảnh của Hạc Tiên tỏa ra, báo hiệu sắp bước vào Bạo Nộ.

**Bạo Nộ:**
- Chim không đậu trên đảo.
- Lông mảnh vỡ vụn.
- Linh Hồ và Yêu Tạp Ma Châu trên đảo hóa ma hóa và di chuyển khắp đảo.
- Người chơi bị giảm nhanh Tinh Thần, Cooldown Tâm Ma giảm.

**An Ủi:**
- Chim vẫn không đậu trên đảo.
- Côn Bằng sắp trở về trạng thái bình tĩnh, tốc độ giảm Tinh Thần giảm một nửa.
- Lông mảnh tỏa ra bình thường.

### 13.3 Côn Bằng Tiên Đảo bạo động — Tâm Ma

- Nếu tinh thần của người chơi về 0 khi ở đảo, sẽ kích hoạt **Tâm Ma**.
- Sau khi giết Tâm Ma, trong **480 giây** không sinh ra Tâm Ma tiếp theo.
- Nếu Côn Bằng Tiên Đảo đang bạo động, Cooldown Tâm Ma giảm còn 60 giây.

**Thông số Tâm Ma:**
- Máu: **3250**
- Sức mạnh tấn công: **60**
- Rơi ra: 5 Nhiên Liệu Ác Mộng, 20% Tim Bóng Tối (1 chiếc)

**Thụ động:** Sau mỗi 2 đòn tấn công thường, đòn thứ 3 phối hợp Ma Thể Vô Thượng, gây sát thương mạnh.

**Kỹ năng:** Khi người chơi quá xa Tâm Ma, Tâm Ma bật lên không trung rồi rơi xuống vị trí người chơi, gây sát thương.

### 13.4 Túy Xuân Yên (cây trên đảo)

- Là cây xuất hiện trên Côn Bằng Tiên Đảo.
- Khi đứng gần Túy Xuân Yên trưởng thành, người chơi hồi phục máu chậm, **0.5% mỗi 6 giây**.

**Túy Mai** (quả)
- Khi ăn, hồi phục ba chỉ số: No bụng 12 / Thần thức 5 / Khí huyết 2.
- Có thể dùng để trồng Túy Xuân Yên.

### 13.5 Sinh vật trên đảo

**Tiên Hạc** — `xd_xianhe` (SG `SGxd_xianhe`)
- Khu vực sinh trưởng: Côn Bằng Tiên Đảo
- Máu: **200**
- Rơi ra: Lông mảnh thường 25%, Thịt nhỏ 80%.
- Khi bị giết, tăng mức nghịch ngợm nhiều hơn các loài chim khác **gấp 6 lần**.

**Lông Mảnh:** Dùng để kiểm tra trạng thái của Côn Bằng Tiên Đảo.

| Loại lông | Trạng thái đảo |
|---|---|
| Lông mảnh thường | Bình Tĩnh |
| Lông mảnh tỏa ra | Phiền Nhiễu hoặc An Ủi |
| Lông mảnh vỡ vụn | Bạo Nộ |

**Linh Hồ**
- Khu vực sinh trưởng: Vùng đất xanh tốt trên Côn Bằng Tiên Đảo
- Máu: **400** (trước khi mở cảnh giới Vạn Vật)
- Sức mạnh tấn công: **40**
- Khi Côn Bằng Tiên Đảo ở trạng thái Bạo Nộ, Linh Hồ ma hóa, tự động tấn công người chơi.
- Thời gian hồi sinh: Trong Thanh Khâu Phường, sau 2 ngày sẽ hồi sinh.
- Rơi ra: Đuôi Linh Hồ (25%), Thịt ×1.

**Kỹ năng Linh Hồ:**
1. Tạo ngọn lửa rơi xuống vị trí mục tiêu, gây sát thương diện rộng theo lửa.
2. Triệu hồi 3 vòng lửa xung quanh bản thân, tự động tấn công mục tiêu.

**Thanh Khâu Phường** (công trình)
- Nguyên liệu chế tạo: Đuôi Linh Hồ ×3, Ván Gỗ ×4, Gạch Đá ×3.
- Linh Hồ bị giết trong khu vực này sẽ hồi sinh sau 2 ngày.

**Mỏ Linh Thạch** (Prefab: `xd_lingshi` / `xd_rock_basalt`)
- Khu vực sinh trưởng: Xuất hiện tại Linh Mạch Côn Bằng.
- Khi khai thác: ngoài việc nhận đá thường và đá lửa, còn rơi thêm **Hạ Phẩm Linh Thạch**.

**Mỏ Linh Thạch Hiếm**
- Khu vực sinh trưởng: Xuất hiện tại Linh Mạch Côn Bằng, tỷ lệ xuất hiện thấp hơn.
- Khi khai thác: ngoài đá thường và đá lửa, còn rơi thêm **Trung Phẩm Linh Thạch**.

**Mỏ Linh Thạch Tuyệt Phẩm**
- Khu vực sinh trưởng: Xuất hiện tại Linh Mạch Côn Bằng, tỷ lệ xuất hiện cực thấp.
- Khi khai thác: ngoài đá thường và đá lửa, còn rơi thêm Trung Phẩm Linh Thạch và 1 vật phẩm cơ duyên quý hiếm.

**Yêu Tạp Ma Châu**
- Khu vực sinh trưởng: Côn Bằng Tiên Đảo
- Máu: 400 (trước khi mở cảnh giới Vạn Vật)
- Sức mạnh tấn công: 40
- Khi Côn Bằng Tiên Đảo ở trạng thái Bạo Nộ, Yêu Tạp Ma Châu ma hóa, tấn công người chơi kèm hiệu ứng độc khi trúng.
- Thời gian hồi sinh: Sinh ra tại **Hang Ma Châu**.
- Rơi ra: Thịt quái (25%), Tơ nhện (25%), Hạch nhện (25%).

**Kỹ năng Yêu Tạp Ma Châu:**
1. Khi người chơi ở khoảng cách xa, phun mạng nhện về hướng người chơi, gây **30 sát thương** và giảm tốc 12 giây.
2. Khi người chơi ở gần, dịch chuyển tức thời ra sau lưng người chơi và tấn công, gây **52.5 sát thương**.

**Hang Ma Châu** (công trình)
- Nguyên liệu: Tà Sát Bộ Túc ×1, Tơ nhện ×12, Đá ×6.
- Khi Côn Bằng Tiên Đảo bạo động, các Yêu Tạp Ma Châu trong hang sẽ tự ra ngoài đi lang thang, tấn công người chơi.

### 13.6 Tử Vân Ma Quân (trang 132-134)

> **Prefab:** `xd_ziyunboss`, brain `xd_ziyunbossbrain`, SG `SGxd_ziyunboss`. Bộ tổ chức: `xd_ziyunge` (Tử Vân Các), `xd_ziyunjfsn`, `xd_ziyunminions`, `xd_ziyunswordfx`, `xd_ziyunwarg`, `xd_deerclops_ziyun`, `xd_stalke_ziyun`.

- Chỗ ở: Sinh sống tại nhà riêng trên Côn Bằng Tiên Đảo (Tử Vân Các).
- Khi người chơi đưa vật phẩm **Lông Ma Tử Xích** cho Tử Vân Ma Quân:
  - Sẽ nhận được **Bản vẽ Mặt Nạ Tử Xích** và **Giáp Yêu Sát Hộ Giáp**.
- Lông Ma Tử Xích có được khi đánh bại Hóa Thân Tử Vân Ma Quân.

**Tử Vân Các** (công trình — `xd_ziyunge`)
- Chức năng: Chỗ ở của Tử Vân Ma Quân, có khả năng chống mưa và sét.
- Điều kiện môi trường: Nhiệt độ trong phòng rất cao, tạo cảm giác ấm áp nhưng giảm dần lý trí của người chơi nếu ở lâu.

**Mặt Nạ Tử Xích** (Trang bị đầu)
- Công thức chế tạo: Tử Sát Ma Vũ ×1, Da Hồ Gấm ×1, Sợi Lông Mảnh ×3, Thượng Phẩm Linh Thạch ×1.
- Hiệu quả: Phòng ngự 90%, Phòng ngự địa phương 10 điểm, Tăng thêm hệ số tấn công +0.2.
- Cơ chế đặc biệt:
  - Dùng Trung Phẩm Linh Thạch dưỡng: 1 Trung Phẩm Linh Thạch hồi 20% độ bền, tự hồi 1% độ bền mỗi 10 giây.
  - Khi đeo cùng bộ giáp, có xác suất miễn sát thương trong 2 giây, hồi chiêu 10 giây.

**Hộ Giáp Yêu Sát** (Trang bị thân)
- Công thức: Ma Quái Kiềm Cốt ×1, Tà Sát Bộ Túc ×1, Đuôi Linh Hồ ×6, Thượng Phẩm Linh Thạch ×1.
- Hiệu quả: Phòng ngự 90%, Phòng ngự địa phương 10 điểm, Tăng tốc độ di chuyển +10%.
- Cơ chế đặc biệt:
  - Dùng Trung Phẩm Linh Thạch dưỡng: 1 Trung Phẩm Linh Thạch hồi 20% độ bền, tự hồi 1% độ bền mỗi 10 giây.
  - Khi đeo cùng bộ giáp, có xác suất miễn sát thương trong 2 giây, hồi chiêu 10 giây.

(Chi tiết HP/skill của Hóa Thân Tử Vân Ma Quân khi làm boss xem §16.)

---

## 7. Vấn Đạo Đan Kiếp (trang 135-139)

### 7.1 Lò Đan
**Prefab:** `xd_liandanlu`

**Công thức chế tạo:** Vàng ×5, Đá Gạch ×3, Đá Lửa ×3, Hạ Phẩm Linh Thạch ×5.

- Nếu công thức sai, Đan Lò sẽ nhả ra vật phẩm và không thể luyện đan.
- Đây là nền tảng luyện hầu hết các đạo cụ thăng tiên.

### 7.2 Phiên bản Vấn Đạo Đan Kiếp

- Khi luyện đan dược **cấp 5 trở lên**, Đan Lò phải chịu trận **Lôi Kiếp**.
  - Mỗi lần Lôi Kiếp đánh trúng giảm **5%** tỷ lệ thành công của đan dược.
- Nếu có đạo sĩ trong phạm vi, đạo sĩ sẽ thay Đan Lò chịu Lôi Kiếp.
- Nếu xung quanh có **Hóa Kiếp Tiêm Mãng**, mỗi trận Lôi Kiếp sẽ đánh sang Hóa Kiếp Tiêm Mãng.
- Nếu luyện thất bại, sẽ sinh ra **Đan Phế**.

### 7.3 Công trình hỗ trợ luyện đan

**Ngọc Lộ Huyền Cang** (`xd_cangku` / `xd_he_container`?)
- Công thức: Lam Bảo Thạch ×10, Đá Gạch ×10, Ván Gỗ ×5, Trung Phẩm Linh Thạch ×3.
- Hiệu quả: Dùng để lưu trữ linh thảo và hạt linh thảo; có tác dụng tái tươi chậm cho linh thảo; có thể xếp chồng, không giới hạn số lượng.

**Thiên Bảo Hồ**
- Công thức: Cam Bảo Thạch ×1, Khối Vàng ×5, Dây Thừng ×1, Trung Phẩm Linh Thạch ×2.
- Hiệu quả: Dùng để lưu trữ đan dược một cách tiện lợi, dễ mang theo.

**Ngọc Lộ Tiên Khê** (chậu trồng linh thảo — Prefab: `xd_huapen` / `xd_ylxq`)
- Công thức: Gỗ Sống ×8, Đá Gạch ×5, Lục Bảo Thạch ×1, Trung Phẩm Linh Thạch ×3.
- Hiệu quả: Dùng để trồng linh thảo; có thể dùng Chưởng Thiên Bình để tăng nồng độ linh dịch; mỗi ngày tiêu hao 1 điểm nồng độ linh dịch. Khi nồng độ > 0, linh thảo tiếp tục sinh trưởng.

**Tinh Tế Đan Phủ** (lò luyện cao cấp)
- Công thức: Cam Bảo Thạch ×10, Bảo Thạch Cầu Vồng ×2, Đá Gạch ×5, Thượng Phẩm Linh Thạch ×10.
- Cơ chế thăng phẩm đan dược:
  - Cấp 5 → Cấp 4: 1 ngày, cần 10 Hạ Phẩm Linh Thạch
  - Cấp 4 → Cấp 3: 5 ngày, cần 3 Trung Phẩm Linh Thạch
  - Cấp 3 → Cấp 2: 20 ngày, cần 1 Thượng Phẩm Linh Thạch

**Hóa Kiếp Tiêm Mãng** (cột chống sét)
- Công thức: Đá Gạch ×4, Sừng Dê ×1, Vàng ×10, Thượng Phẩm Linh Thạch ×1.
- Hiệu quả: Có xác suất thay thế Đan Lò và đạo sĩ trong phạm vi chịu Lôi Kiếp; mỗi lần chịu Lôi Kiếp sẽ mất độ bền; có thể dùng linh thạch để bổ sung độ bền.

**Nguyệt Hoa Thập Dược Chi** (lưỡi hái thu hoạch)
- Công thức: Cành Cây ×12, Cánh Hoa ×6, Cam Bảo Thạch ×2, Trung Phẩm Linh Thạch ×10.
- Hiệu quả: Dùng để thu hoạch linh thảo cự ly ngắn mà không gây tác dụng phụ; tăng nhẹ xác suất nhận được hạt giống khi thu hoạch linh thảo.

---

## 8. LINH THẢO (trang 140-142)

> **Cơ chế chung:** Cây khổng lồ khi phá ra sẽ có **40% xác suất** ngẫu nhiên sinh ra 1 hạt giống linh thảo.
> **Prefab đoán:** `xd_plant`, `xd_flowers`, `xd_yhsyz`, `xd_ylxc`, `xd_ylxq`

| Tên | Mọc ở mùa | Cơ chế thu hoạch / Tính chất |
|---|---|---|
| **Xích Dương Hoa** | Chỉ mọc vào mùa **Hạ** | Khi cây lớn bị phá, có xác suất nhận 1 hạt giống. Khi thu hoạch có thể bị lửa thiêu đốt. Khi ăn quả: tăng thân nhiệt. |
| **Sương Hàn Thảo** | Chỉ mọc vào mùa **Đông** | Khi cây lớn bị phá, có xác suất nhận 1 hạt giống. Khi thu hoạch, người chơi sẽ bị đóng băng nhẹ. Khi ăn quả: làm giảm thân nhiệt. |
| **Lôi Minh Cốc** | Chỉ mọc vào mùa **Xuân** | Khi cây lớn bị phá, có xác suất nhận 1 hạt giống. Khi thu hoạch, có thể bị sét đánh. Khi ăn quả: cũng sẽ bị sét đánh nhưng không gây sát thương. |
| **Thanh Phong Tụ** | Chỉ mọc vào mùa **Thu** | Khi cây lớn bị phá, có xác suất nhận 1 hạt giống. Khi thu hoạch, không gây tác dụng phụ. Tuy nhiên, thời gian bảo quản ngắn. |
| **Địa Mạch Tham** | Chỉ mọc vào **ban ngày**, ngưng sinh trưởng khi trời mưa hoặc có tuyết | Khi cây lớn bị phá, có xác suất nhận 1 hạt giống. Khi thu hoạch, người chơi sẽ rơi vào trạng thái mệt mỏi. Khi ăn quả: hồi phục máu một lượng nhỏ liên tục. |
| **U Hồn Hoa** | Chỉ mọc vào **ban đêm** | Khi cây lớn bị phá, có xác suất nhận 1 hạt giống. Khi thu hoạch, sẽ giảm lý trí. Khi mang quả hoặc hạt giống trên người, sẽ liên tục giảm lý trí. |

---

## 9. ĐAN DƯỢC (trang 143-151)

> Mỗi đan dược có **5 cấp** (5 yếu nhất → 1 mạnh nhất). Cấp 1 hiện chưa thể chế tạo. Công thức thấp hơn (cấp 5/4) yêu cầu ít nguyên liệu, cấp cao hơn (cấp 3/2) yêu cầu nguyên liệu hiếm hơn.
> **Prefab:** `xd_danyao`, `xd_danyao_new`, `xd_danyao_items`, `xd_dy_buffs`. **Component:** `xd_lingji` (link luyện đan).

### 9.1 Xích Dương Phần Huyết Đan (tăng sát thương)

| Cấp | Công thức |
|---|---|
| 5 | Xích Dương Hoa ×1, Quả Phát Quang ×1, Ớt ×2, Thịt Nhỏ ×2 |
| 4 | Xích Dương Hoa ×2, Quả Phát Quang ×2, Ớt ×4, Thịt ×4 |
| 3 | Xích Dương Hoa ×4, Quả Phát Quang ×3, Ớt ×6, Vảy ×1 |
| 2 | Xích Dương Hoa ×8, Quả Phát Quang ×4, Ớt ×8, Vảy ×2 |
| 1 | Hiện chưa thể chế tạo |

### 9.2 Lôi Minh Sát Khí Đan (tấn công trở thành tấn công điện + cộng sát thương thuộc tính tầng)

| Cấp | Công thức |
|---|---|
| 5 | Lôi Minh Cốc ×1, Sừng Dê ×1, Măng Tây ×2, Vàng ×2 |
| 4 | Lôi Minh Cốc ×2, Sừng Dê ×1, Măng Tây ×4, Lông Cừu ×1 |
| 3 | Lôi Minh Cốc ×4, Sừng Dê ×2, Măng Tây ×6, Sừng Kỳ Lân ×1 |
| 2 | Lôi Minh Cốc ×8, Sừng Dê ×2, Măng Tây ×8, Sừng Kỳ Lân ×2 |

### 9.3 Địa Mạch Hồi Sinh Đan (hồi phục máu trong thời gian)

| Cấp | Công thức |
|---|---|
| 5 | Địa Mạch Tham ×1, Hạch Nhện ×2, Lý Địa Thảo (Tillweeds) ×2, Trứng Chim ×2 |
| 4 | Địa Mạch Tham ×2, Hạch Nhện ×4, Lý Địa Thảo ×4, Thịt Lá ×7 |
| 3 | Địa Mạch Tham ×4, Hạch Nhện ×6, Lý Địa Thảo ×6, Sữa Ong Chúa ×3 |
| 2 | Địa Mạch Tham ×8, Hạch Nhện ×8, Nhân Sâm ×1, Sữa Ong Chúa ×6 |

### 9.4 Thanh Tâm Tẩy Hồn Đan (hồi phục thần trí)

| Cấp | Công thức |
|---|---|
| 5 | U Hồn Hoa ×1, Nhiên Liệu Ác Mộng ×5, Nấm Xanh ×2, Nấm Lam ×2 |
| 4 | U Hồn Hoa ×2, Nhiên Liệu Ác Mộng ×10, Nấm Xanh ×4, Bánh Nấm ×2 |
| 3 | U Hồn Hoa ×4, Nhiên Liệu Ác Mộng ×20, Nấm Xanh ×6, Đá mặt trăng thuần túy ×1 |
| 2 | U Hồn Hoa ×8, Nhiên Liệu Ác Mộng ×40, Nấm Xanh ×8, Đá mặt trăng thuần túy ×3 |

### 9.5 Ngự Phong Thần Hành Đan (tăng tốc độ di chuyển)

| Cấp | Công thức |
|---|---|
| 5 | Thanh Phong Tụ ×1, Cà Rốt ×2, Lông Thỏ ×2, Lông Đen ×1 |
| 4 | Thanh Phong Tụ ×2, Cà Rốt ×4, Lông Thỏ ×4, Lông Vàng ×2 |
| 3 | Thanh Phong Tụ ×4, Cà Rốt ×6, Lông Thỏ ×6, Lông Ma Thiên Ưng (Malbatross) ×8 |
| 2 | Thanh Phong Tụ ×8, Cà Rốt ×8, Lông Thỏ ×8, Lông Ma Thiên Ưng ×16 |

### 9.6 Bàn Thạch Hộ Thân Đan (tăng phòng thủ)

| Cấp | Công thức |
|---|---|
| 5 | Địa Mạch Tham ×1, Khoai Tây ×2, Thù Khoáng ×1, Đá ×2 |
| 4 | Địa Mạch Tham ×2, Khoai Tây ×4, Thù Khoáng ×2, Đá Cẩm Thạch ×4 |
| 3 | Địa Mạch Tham ×4, Khoai Tây ×6, Thù Khoáng ×3, Ma Quái Kiềm Cốt ×1 |
| 2 | Địa Mạch Tham ×8, Khoai Tây ×8, Thù Khoáng ×4, Ma Quái Kiềm Cốt ×2 |

### 9.7 Thiên Cơ Xảo Thủ Đan (giảm hao mòn công cụ + tăng hiệu suất làm việc)

| Cấp | Công thức |
|---|---|
| 5 | Thanh Phong Tụ ×1, Bánh Răng ×1, Ngô ×2, Đá Lửa ×1 |
| 4 | Thanh Phong Tụ ×2, Bánh Răng ×2, Ngô ×4, Mảnh Trăng ×2 |
| 3 | Thanh Phong Tụ ×4, Bánh Răng ×3, Ngô ×6, Vỏ Nấm ×1 |
| 2 | Thanh Phong Tụ ×8, Bánh Răng ×4, Ngô ×8, Vỏ Nấm ×2 |

### 9.8 Huyền Dương Noãn Ngọc Đan (giữ ấm cơ thể)

| Cấp | Công thức |
|---|---|
| 5 | Xích Dương Hoa ×1, Thanh Long ×2, Thịt Quái ×2, Quả Mọng ×3 |
| 4 | Xích Dương Hoa ×2, Thanh Long ×4, Thịt Quái ×4, Hồng Bảo Thạch ×1 |
| 3 | Xích Dương Hoa ×4, Thanh Long ×6, Thịt Quái ×6, Phượng Tủy ×1 |
| 2 | Xích Dương Hoa ×8, Thần Long Quả ×8, Thịt Quái ×8, Phượng Tủy ×2 |

### 9.9 Hàn Tủy Tỵ Hỏa Đan (ngăn chặn tình trạng quá nhiệt)

| Cấp | Công thức |
|---|---|
| 5 | Sương Hàn Thảo ×1, Dưa Hấu ×2, Băng ×2, Băng ×2 |
| 4 | Sương Hàn Thảo ×2, Dưa Hấu ×4, Băng ×4, Lam Bảo Thạch ×1 |
| 3 | Sương Hàn Thảo ×4, Dưa Hấu ×6, Băng ×6, Mắt Kỳ Lộc ×1 |
| 2 | Sương Hàn Thảo ×8, Dưa Hấu ×8, Băng ×8, Mắt Kỳ Lộc ×2 |

### 9.10 Huyết Đạm Nguyên Đan (tấn công có khả năng hút máu)

| Cấp | Công thức |
|---|---|
| 5 | Huyền Hồn Hoa ×1, Cà Chua ×2, Cánh Dơi ×1, Túi Máu Muỗi ×1 |
| 4 | Huyền Hồn Hoa ×2, Cà Chua ×4, Cánh Dơi ×2, Tử Bảo Thạch ×1 |
| 3 | Huyền Hồn Hoa ×4, Cà Chua ×6, Cánh Dơi ×3, Tử Sát Ma Vũ ×1 |
| 2 | Huyền Hồn Hoa ×8, Cà Chua ×8, Cánh Dơi ×4, Tử Sát Ma Vũ ×2 |

### 9.11 Thế Tử Phản Hồn Đan (đan dược phục sinh)

**Hiệu quả:** Khi sử dụng, cho phép tái sinh nhân vật và giữ nguyên cảnh giới hiện tại.
**Công thức chế tạo:** Sừng Kỳ Lân ×3, Phượng Tủy ×3, Vảy ×5, Thượng phẩm Linh Thạch ×3.

### 9.12 Phế Đan (đan dược thất bại)

**Hiệu quả:** Là sản phẩm khi chế đan thất bại.
**Cơ chế khi sử dụng:** Bổ sung 10 điểm no, giảm 50 điểm lý trí, mất 100 điểm sinh lực.

---

## 14. Kho Chứa (Storage Containers) — trang 152-155

> **Prefab:** `xd_cangku`, `xd_he_container`, `xd_cwkj_container`, `xd_llbx`, `xd_lbx`, `xd_bjms`, etc.

| # | Tên | Nguyên liệu | Chức năng |
|---|---|---|---|
| 1 | Kho Thịt | Gạch ×10, Ván gỗ ×5, Hạ Phẩm Linh thạch ×10 | Chứa thịt, làm chậm hỏng; có thể tăng số lượng chứa bằng "Máy Tăng Không Gian". |
| 2 | Kho Rau Quả | Cỏ hái được ×40, Dây ×10, Hạ Phẩm Linh thạch ×10 | Chứa đồ ăn thuần chay, làm chậm hỏng; tăng giới hạn bằng Máy Tăng Không Gian. |
| 3 | Tủ Đa Năng | Ván gỗ ×6, Vàng ×2, Đá cẩm thạch ×2, Hạ Phẩm Linh thạch ×1 | 6×6 ô chứa; 8 ô đầu hiển thị trên kệ; vật phẩm có thể chồng xếp; tăng giới hạn bằng Máy Tăng Không Gian. |
| 4 | Bàn Gỗ Hoàng Hoa Lý | Gỗ sống ×3, Ván gỗ ×5, Hạ Phẩm Linh thạch ×10 | Đặt được 8 món ăn, có thể chồng xếp; làm chậm hỏng; tăng giới hạn bằng Máy Tăng Không Gian. |
| 5 | Hộp Kiếm Vô Song | Vàng ×6, Ván gỗ ×2, Bánh răng ×1, Hạ Phẩm Linh thạch ×1 | Chứa vũ khí; tự hút vật phẩm trong 2 ô quanh; tăng giới hạn bằng Máy Tăng Không Gian. |
| 6 | Hộp Dụng Cụ | Ván gỗ ×2, Vàng ×3, Hạ Phẩm Linh thạch ×7 | Chứa dù và các công cụ đập, chặt, xẻ, đào, búa, cuốc; tự hút vật phẩm trong 2 ô quanh; tăng giới hạn bằng Máy Tăng Không Gian. |
| 7 | Hòm Linh Bảo | Gạch ×10, Ván gỗ ×5, Hạ Phẩm Linh thạch ×20 | Chứa nguyên liệu quái vật; khi >12 ô, 15 ngày sao chép 1 nhóm vật phẩm ngẫu nhiên (tối đa 20); tự hút vật phẩm trong 2 ô quanh; **tối đa 3 cái mỗi thế giới**. |
| 8 | Hộp Trang Sức Lưu Quang | Đá cẩm thạch ×4, Vàng ×10, Hạ Phẩm Linh thạch ×4 | Chứa đá quý và linh thạch; tự hút vật phẩm trong 2 ô quanh; tăng giới hạn bằng Máy Tăng Không Gian. |
| 9 | Bình Mật Ong | Bướm ×10, Đá ×5, Dây ×2, Hạ Phẩm Linh thạch ×10 | Chứa mật ong và sản phẩm liên quan (mật, sáp, thuốc mật, sữa ong, đường); làm chậm hỏng; tăng giới hạn bằng Máy Tăng Không Gian. |
| 10 | Giỏ Nấm | Gỗ ×8, Gỗ sống ×3, Dây ×3, Hạ Phẩm Linh thạch ×10 | Chứa nấm thu hái (xanh, đỏ, lam, mặt trăng); làm chậm hỏng; tự hút vật phẩm trong 2 ô quanh; tăng giới hạn bằng Máy Tăng Không Gian. |

---

## 15. CÔNG TRÌNH (Constructions) — trang 156-165

### 15.1 Máy Quay Thưởng Linh Thạch
**Prefab:** `xd_choujiangji` (SG `SGxd_choujiangji`; spawner `xd_cjjspwner`; map `xd_choujiangjimap`)

- Sinh ra tự nhiên trong khu đầm lầy.
- Mỗi lần sử dụng tiêu hao: 1 Linh thạch trung phẩm hoặc 60 Linh thạch hạ phẩm để quay một lần.
- Hiệu quả: Sau khi quay, người chơi có thể nhận được cơ duyên / cơ hội may mắn, hoặc gặp kiếp nạn / vận rủi.

### 15.2 Đèn Lồng Trang Trí

**Công thức:** Cành cây ×10, Dây thừng ×3, Vàng ×3, Hạ Phẩm Linh thạch ×1.
**Công dụng:** Có 1 ô đặt linh thạch để chiếu sáng. Có thể xếp chồng tối đa 60 linh thạch, chỉ chấp nhận linh thạch. 1 linh thạch chiếu sáng trong 3 ngày. Phạm vi chiếu sáng nhỏ.

### 15.3 Đèn Kim Ô Tung Thái

**Công thức:** Vàng cổ ×3, Lông vũ vàng ×3, Vàng ×3, Hạ Phẩm Linh thạch ×1.
**Công dụng:** Cơ chế tiêu thụ linh thạch giống Đèn Lồng Trang Trí. Phạm vi chiếu sáng trung bình.

### 15.4 Quỳnh Lâu Kim Khuyết

**Công thức:** Đá cẩm thạch ×5, Hoàng bảo thạch ×5, Gỗ ×3, Hạ Phẩm Linh thạch ×1.
**Công dụng:** Dùng linh thạch để chiếu sáng (1 viên = 3 ngày). Phạm vi chiếu sáng lớn.

### 15.5 Liên Diệp Đông

**Công thức:** Đá ×20, Bào tử nấm xanh ×12, Cỏ ×2, Hạ Phẩm Linh thạch ×1.
**Công dụng:** Cơ chế dùng linh thạch giống các đèn khác. Phạm vi chiếu sáng rất lớn.

### 15.6 Hồ Tẩy Nguyệt

**Công thức:** Đá Mặt Trăng ×10, Hoàng bảo thạch ×3, Đá cẩm thạch ×15, Hạ Phẩm Linh thạch ×1.
**Công dụng đặc biệt:** Không tiêu hao tài nguyên vẫn có thể chiếu sáng. Phạm vi chiếu sáng cực lớn. Có thể thả cá giống (tối đa 3 con). Sau 7 ngày, mỗi cá giống cho 4 cá, tổng cộng 12 cá.

### 15.7 Giá Trân Bảo (Đa Bảo Các)

**Công thức:** Ván gỗ ×6, Vàng ×2, Đá cẩm thạch ×2, Hạ Phẩm Linh thạch ×1.
**Công dụng:** Kho chứa dạng lưới 6×6. 8 ô phía trước sẽ hiển thị vật phẩm lên kệ. Vật phẩm có thể xếp chồng bình thường. Có thể dùng Máy Mở Rộng Không Gian để tăng giới hạn xếp chồng.

### 15.8 Giếng Ngọt

**Công thức:** Đá ×12, Dây thừng ×1, Gỗ ×11, Hạ Phẩm Linh thạch ×1.
**Công dụng:** Dùng để đổ đầy bình nước.

### 15.9 Tổ Chuồn Chuồn (spawner Dragonfly)
**Prefab đoán:** `xd_dragonfly` + tổ

**Công thức:** Trứng sâu dung nham ×1, Cam bảo thạch ×3, Hoàng bảo thạch ×5, Trung Phẩm Linh thạch ×1.

**Hiệu quả:** Sau khi xây dựng, khu vực xung quanh sẽ sinh ra 1 Chuồn Chuồn (Dragonfly). Nếu Chuồn Chuồn chết, sau 5 ngày sẽ hồi sinh lại 1 con mới. Có thể dùng để bảo vệ căn cứ.

**Thu hoạch (mỗi 10 ngày):** Vảy ×1, Hoàng bảo thạch ×1, Lục bảo thạch ×1, Cam bảo thạch ×1, Hồng bảo thạch ×2, Lam bảo thạch ×2, Tử bảo thạch ×2.

**Thuê:** Đưa cho Chuồn Chuồn Rồng 1 Vảy Rồng (Dragon Scales); thuê trong 2 ngày để hỗ trợ người chơi chiến đấu.

### 15.10 Tổ Gấu Lưng Giáp (spawner Bearger)
**Prefab đoán:** `xd_bearger`

**Công thức:** Đá mặt trăng thuần túy ×4, Lam bảo thạch ×10, Gạch đá ×10, Trung Phẩm Linh thạch ×1.

**Hiệu quả:** Sau khi xây dựng sẽ sinh ra 1 Gấu Lưng Giáp (Bearger). Nếu chết, 5 ngày sau sẽ hồi sinh. Giúp giữ nhà, bảo vệ căn cứ.

**Thu hoạch:** Mỗi 10 ngày thu được 2 Đá mặt trăng thuần túy.
**Thuê:** Đưa 1 Đá mặt trăng thuần túy → thuê 3 ngày hỗ trợ chiến đấu.

### 15.11 Nhà Bò Lông Dài (Beefalo House)
**Prefab đoán:** `xd_beefalo`

**Công thức:** Vàng ×3, Sừng bò ×2, Gạch đá ×5, Hạ Phẩm Linh thạch ×10.

**Hiệu quả:** Sau khi xây dựng sẽ sinh ra 2 Bò (Beefalo). Nếu 1 con chết, 1 ngày sau sẽ sinh lại.
**Thu hoạch:** Mỗi 3 ngày: Lông bò ×8, 50% nhận thêm 1 sừng bò.

### 15.12 Nhà Cây Mèo Gấu Trúc (Catcoon House)

**Công thức:** Gạch đá ×3, Gỗ ×10, Đuôi mèo ×3, Hạ Phẩm Linh thạch ×10.

**Hiệu quả:** Mèo Gấu Trúc sau khi bị giết sẽ hồi sinh vô hạn tại đây. Thời gian hồi sinh: 1 ngày.
**Thu hoạch:** Khi thu hoạch sẽ nhận toàn bộ vật phẩm mà mèo đã nhặt. Mỗi ngày có thể nhận thêm vật phẩm ngẫu nhiên trong danh sách "bãi nôn".

### 15.13 Chuồng Dê

**Công thức:** Sừng Dê ×2, Đá ×10, Dây thừng ×10, Hạ Phẩm Linh thạch ×10.

**Hiệu quả:** Sau khi xây dựng sinh ra 2 Dê. Nếu 1 con chết, 1 ngày sau sinh lại.
**Thu hoạch:** Mỗi ngày: 1 chai Sữa Dê, 25% nhận thêm 1 sừng Dê.

### 15.14 Nhà Voi (Koalefant House)
**Prefab đoán:** `xd_koalefant`

**Công thức:** Vòi voi ×1, Vòi voi mùa đông ×1, Gạch đá ×5, Hạ Phẩm Linh thạch ×10.

**Hiệu quả:** Sau khi xây dựng sinh ra 2 Koalefant. Nếu 1 con chết, 1 ngày sau sinh lại.
**Thu hoạch:** Mỗi 3 ngày thu được 1 vòi voi.

---

## 16. Thái Cổ Dị Thú (Ancient Beasts / Boss) — trang 166-185

> Bộ 6 boss endgame. Cho mỗi boss: HP trước khi mở cảnh giới Vạn Vật (thế giới thăng cách), drop, phase, skills.

### 16.1 Kim Phượng Thần Niệm (trang 166-169)
**Prefab đoán:** Liên quan tới `xd_jcbird` (Kim Sí Điểu) hoặc một boss riêng. Brain `xd_jcbirdbrain`, SG `SGxd_jcbird`.

**Khu vực sinh ra:** Khu mỏ (khi không tồn tại khu mỏ thì sẽ sinh ra ở địa hình hỗn hợp).
**Máu:** **30.000** (khi chưa mở cảnh giới Vạn Vật).
**Cơ chế tấn công:** Sau mỗi 2 lần tấn công thường, lần tấn công thường tiếp theo sẽ gây hiệu ứng **Hỏa Phong**.
**Thời gian hồi sinh:** 7 ngày.

**Vật phẩm rơi ra:** Tủy Phượng ×2, Lục bảo thạch ×2, Cam bảo thạch ×2, Hoàng bảo thạch ×2, Tử bảo thạch ×2, Vàng ×9.

**Danh sách kỹ năng:**

| # | Kỹ năng | Mô tả |
|---|---|---|
| 1 | Xung phong | Để lại một con đường lửa phạm vi lớn gây sát thương cho kẻ địch. |
| 2 | Hóa thân thiên thạch | Bay lên không trung, hóa thân thành thiên thạch lao xuống vị trí mục tiêu, khi rơi xuống gây sát thương lửa trên diện rộng. |
| 3 | Gầm thét | Chỉ định tối đa 2 tu sĩ xung quanh và gây hiệu ứng thiêu đốt. Khi ngọn lửa biến mất, tại vị trí người chơi sẽ xuất hiện **Chu Điểu** và **Hỏa Tinh**. |
| 4 | Cường hóa Chu Điểu và Hỏa Tinh | Tăng tốc độ di chuyển, tăng sát thương và tăng máu cho Chu Điểu và Hỏa Tinh được triệu hồi. Ngoài ra, khi Hỏa Tinh bị tiêu diệt, sau một khoảng thời gian nhất định sẽ tái sinh trong lửa. |

**Hỏa Tinh** (minion)
- Máu: 1.000 (khi chưa mở cảnh giới Vạn Vật)
- Liên tục phun lửa tấn công người chơi.

**Chu Điểu** (minion)
- Máu: 3.300 (khi chưa mở cảnh giới Vạn Vật)
- Sinh vật này sẽ liên tục bay về phía Kim Phượng.
- Khi bị người chơi tiêu diệt hoặc bị Kim Phượng giết ngay lập tức: kích hoạt một lần sát thương lửa phạm vi cho Kim Phượng Thần Niệm, đồng thời tăng **8%** sát thương của Kim Phượng (có thể cộng dồn).
- Tối đa kích hoạt 6 lần, tương đương tăng tối đa **48%** sát thương cho Kim Phượng.
- Khi tiến vào phạm vi nhất định gần Kim Phượng, Chu Điểu sẽ lập tức chết.
- Chu Điểu sẽ bị tất cả kỹ năng của Kim Phượng lan trúng và bị giết ngay lập tức.

**Chuyển giai đoạn theo lượng máu của Kim Phượng:**

| Lượng máu | Hành vi |
|---|---|
| > 80% | Chỉ sử dụng kỹ năng Xung phong. |
| 80% → 35% | Ngoài Xung phong, sử dụng thêm Hóa thân thiên thạch, đồng thời triệu hồi Hỏa Tinh và Chu Điểu. |
| < 35% | Kích hoạt thêm Kỹ năng 4, cường hóa Chu Điểu và Hỏa Tinh. |

---

### 16.2 Tàn Hồn Kỳ Lân (trang 170-172)
**Prefab:** `xd_qlch` (SG `SGxd_qlch`; brains `xd_qlchbrain`, `xd_qlchfsbrain`, `xd_qlchtxbrain`; spawner `xd_qlchspwner`)

**Khu vực sinh ra:** Rừng bạch dương.
**Máu:** **28.000** (khi chưa mở cảnh giới Vạn Vật).
**Hành vi:** Không chủ động tấn công người chơi.
**Thời gian hồi sinh:** 7 ngày.
**Vật phẩm rơi ra:** Sừng Kỳ Lân ×2, Lục bảo thạch ×2, Cam bảo thạch ×2, Hoàng bảo thạch ×2, Vàng ×5.

**Danh sách kỹ năng:**

| # | Kỹ năng | Mô tả |
|---|---|---|
| 1 | Trụ cát quạt | Phóng ra phía trước theo hình quạt một lượng lớn trụ cát vàng, gây sát thương trên diện rộng. Sau một khoảng thời gian, các trụ cát sẽ phát nổ trực tiếp. |
| 2 | Tháp Trì Linh | Sinh ra một Tháp Trì Linh dưới chân tu sĩ, tồn tại trong một khoảng thời gian nhất định, có khả năng chống lại thiên thạch. |
| 3 | Thiên thạch | Triệu hồi một thiên thạch rơi xuống vị trí tu sĩ. Khi thiên thạch chạm đất, lấy vị trí của mỗi tu sĩ làm tâm sẽ tạo ra hiệu ứng địa chấn phạm vi, gây sát thương lớn. Nếu hai tu sĩ đứng quá gần nhau, sẽ chịu hai lần sát thương do ảnh hưởng lẫn nhau. Nếu trong phạm vi vụ nổ có Tháp Trì Linh, tháp bị phá hủy và tu sĩ không kích hoạt sát thương địa chấn. |
| 4 | Phân thân hỗ trợ tấn công | Triệu hồi hai phân thân: **Phân thân 1** lần lượt tạo 3 đợt trụ cát vàng cỡ nhỏ tại vị trí của tất cả tu sĩ và cho nổ tung. **Phân thân 2** sinh ra mây ngủ dưới chân tất cả người chơi, tu sĩ chạm vào sẽ bị trạng thái ngủ một lần. |

**Chuyển giai đoạn theo lượng máu của Kỳ Lân:**

| Lượng máu | Hành vi |
|---|---|
| > 85% | Chỉ sử dụng Kỹ năng 1. |
| 85% → 50% | Sau khi thi triển một vòng Kỹ năng 1 + Kỹ năng 2, sẽ tiếp tục thi triển một vòng Kỹ năng 1 + Kỹ năng 3. |
| < 50% | Triệu hồi phân thân để hỗ trợ tấn công. |

**Khi một phân thân bị tiêu diệt:** Phân thân còn lại sẽ thay thế và tăng tần suất thi triển kỹ năng.
**Khi cả hai phân thân đều bị tiêu diệt:** Kỳ Lân Tàn Hồn bước vào trạng thái cuồng bạo, vừa tăng tốc độ tấn công, vừa cường hóa toàn bộ kỹ năng.

---

### 16.3 Tàn Thần Bạch Hổ (trang 173-176)
**Prefab:** `xd_baihu` + brain `xd_baihubrain`, `xd_baihu_noattackbrain`, SG `SGxd_baihu`, spawner `xd_baihuspwner`. Buff `xd_baihu_buff`, fx `xd_baihu_shadow_fx`, `xd_baihufx`.

**Khu vực sinh ra:** Thảo nguyên, Đồng cỏ.
**Máu:** **26.000** (khi chưa mở cảnh giới Vạn Vật).
**Công kích:** **87,5**.
**Cơ chế tấn công thường:** Mỗi lần tấn công thường trúng người chơi sẽ gây hiệu ứng **Phá Giáp – Toái Giáp**. Trong vòng 18 giây tiếp theo, đòn tấn công đầu tiên trúng người chơi sẽ gây **170%** sát thương; nếu tiếp tục kích hoạt lần nữa, sát thương sẽ tăng lên **300%** và hiệu ứng lập tức kết thúc.
**Thời gian hồi sinh:** 7 ngày.

**Vật phẩm rơi ra:** Da Hổ Gấm ×2, Lục bảo thạch ×3, Cam bảo thạch ×4, Hoàng bảo thạch ×4, Hồng bảo thạch ×3, Vàng ×15.

**Công dụng vật phẩm:** Da Hổ Cẩm Mao có thể cho thân ngoại hóa thân ăn để tăng kinh nghiệm Luyện Khí.

**Danh sách kỹ năng:**

**Kỹ năng 1 — Xung phong:**
- Xung phong vào tối đa 4 người chơi, bắt buộc trúng đích, gây một lượng sát thương nhỏ (Hổ Trảo – Vàng), đồng thời khiến người chơi trong thời gian ngắn phải chịu sát thương từ xung phong tăng **300%** (Hổ Trảo – Đỏ).
- Người chơi đứng trên đường xung phong cũng sẽ chịu sát thương.
- Khi có nhiều người chơi, cần chú ý vị trí đứng để tránh bị trúng nhiều lần xung phong liên tiếp.
- Mỗi lần xung phong trúng người chơi sẽ để lại tại vị trí người chơi một hư ảnh, gây sát thương nhỏ theo thời gian, có thể cộng dồn.

**Kỹ năng 2 — Đập đất:**
- Trước tiên Bạch Hổ gầm thét và đánh dấu người chơi, sau đó đập đất.
- Sau một khoảng thời gian, Bạch Hổ sẽ dịch chuyển tức thời đến vị trí người chơi và tung đòn nện, gây một lượng sát thương nhỏ, đồng thời phá hủy các hư ảnh do Kỹ năng 1 tạo ra trong phạm vi nhỏ.
- Mỗi hư ảnh bị phá hủy sẽ gây một lần sát thương nổ.
- Sau vụ nổ sẽ để lại một vùng gây sát thương duy trì.

**Kỹ năng 3 — Mệt mỏi + nén:**
- Bạch Hổ bước vào trạng thái mệt mỏi trong 6 giây, sau đó hất tung toàn bộ người chơi trong phạm vi nhỏ, gây sát thương cực lớn.
- Tiếp theo, Bạch Hổ dựng lên tường đá để giam người chơi, rồi thực hiện nhiều lần xung phong gây sát thương cao, các đòn này có thể né tránh.
- Cuối cùng, Bạch Hổ sẽ phá hủy toàn bộ hư ảnh, gây sát thương nổ cực lớn có thể cộng dồn.
- Mỗi hư ảnh bị Bạch Hổ chủ động kích nổ đều gây ra lượng sát thương rất lớn.

(Mod prefab `xd_baihu_shadow_fx` xác nhận giai đoạn shadow.)

---

### 16.4 Tà Sát Chu Vương (trang 177-179)
**Prefab:** `xd_zhouwang` + `xd_zhouwang_shadow`, brain `xd_zhouwangshadowbrain`.

**Khu vực sinh trưởng:** Phần cuối cùng của Côn Bằng Tiên Đảo.
**Máu:** **29.500** (trước khi mở cảnh giới Vạn Vật).
**Sức mạnh tấn công:** **75**.
**Cơ chế đặc biệt:** Trong 30 giây tấn công cùng một mục tiêu hoặc đòn thứ 3 trúng người chơi, sẽ sinh ra mạng nhện dưới chân, khiến người chơi giảm tốc **50%** và chịu sát thương liên tục khi đứng trên mạng.
**Thời gian hồi sinh:** 7 ngày.

**Rơi ra:** Tà Sát Bộ Túc ×2, Lục Bảo Thạch ×3, Cam Bảo Thạch ×3, Hoàng Bảo Thạch ×3, Tử Bảo Thạch ×5, Thịt quái ×8, Tơ nhện ×6.
**Lưu ý:** Bước chân Yêu Sát có thể cho thân ngoại hóa thân ăn để tăng kinh nghiệm luyện khí.

**Danh sách kỹ năng:**

| # | Kỹ năng | Mô tả |
|---|---|---|
| 1 | Dấu ấn Mạng Nhện | Đánh dấu tối đa 4 người chơi. Sau một thời gian, mạng nhện xuất hiện tại vị trí người chơi, sát thương cao hơn mạng nhện từ tấn công thường, kèm hiệu ứng giảm tốc. Mạng tồn tại 240 giây. |
| 2 | Sóng Độc | Nhắm tối đa 2 người chơi, xuất hiện mũi tên hướng dưới chân. Sau một khoảng thời gian, phát ra sóng độc theo hướng mũi tên, gây sát thương cho người chơi trúng. Sóng độc dọn sạch mạng nhện từ tấn công thường và Kỹ năng 1, và tạo bụi độc tồn tại 10 giây, gây sát thương liên tục. |
| 3 | Nhảy và Khống Chế | Nhảy gần người chơi, tạo 2 tảng đá đặc biệt để che tầm nhìn của Châu Vương. Đánh dấu tất cả người chơi để kéo về phía Châu Vương. Sau thời gian, Châu Vương phun mạng nhện vào tất cả người chơi, nếu trúng sẽ kéo về gần và tấn công gây sát thương lớn. Khi kỹ năng kết thúc, tảng đá vỡ, gây sát thương diện rộng nhỏ. |
| 4 | Triệu hồi Yêu Tạp Ma Châu | Mỗi 16 giây, triệu hồi 1 Yêu Tạp Ma Châu để tấn công người chơi. |

---

### 16.5 Ma Tướng Phù Đồ (trang 180-182)
**Prefab đoán:** `xd_swhs` (SG `SGxd_swhs`, brain `xd_swhsbrain`) hoặc boss-related stone form.

**Nơi sống:** Côn Bằng Tiên Đảo (cấp cơ bản).
**Khu vực sinh trưởng:** Vùng mỏ khoáng Côn Bằng Tiên Đảo.
**Máu:** **42.500** (trước khi mở cảnh giới Vạn Vật).
**Sức mạnh tấn công:** **58.5**.
**Cơ chế tấn công thường:** Kèm sát thương hình quạt diện rộng nhỏ.
**Thời gian hồi sinh:** 7 ngày.

**Rơi ra:** Ma Quái Kiềm Cốt ×2, Lục Bảo Thạch ×5, Cam Bảo Thạch ×2, Hoàng Bảo Thạch ×2, Tử Bảo Thạch ×3, Đá ×25.
**Lưu ý:** Xương Quái Ma có thể cho thân ngoại hóa thân ăn để tăng kinh nghiệm luyện khí.

**Danh sách kỹ năng:**

**Kỹ năng 1 — Mưa Sao Băng:**
- Trong một phạm vi nhất định, liên tục triệu hồi mưa sao băng trực tiếp, gây sát thương diện rộng.

**Kỹ năng 2 — Cọc Đá Cộng Hưởng:**
- Đánh dấu tối đa 4 người chơi, tạo đá chóp tại vị trí.
- Sát thương ban đầu xảy ra ngay.
- Sau đó, cột đá cộng hưởng với người chơi, gây sát thương nhỏ liên tục.
- Cột đá chỉ bị phá bởi Kỹ năng 3 của boss; khi bị phá cũng gây sát thương nhỏ.
- Sát thương từ nhiều cột đá có thể cộng dồn.

**Kỹ năng 3 — Quạt Phóng Diện Rộng:**
- Phát ra sát thương hình quạt diện rộng về phía trước, sau đó quay về hướng người chơi và phát lần 2.
- Kỹ năng này có thể phá vỡ các cột đá do boss triệu hồi và **Linh Khoáng Ma Ảo**.

**Cơ chế đặc biệt — Linh Khoáng Ma Ảo:**
- Boss theo thời gian triệu hồi 1 Linh Khoáng Ma Ảo tấn công người chơi.
- Ma ảo không thể bị tấn công; chỉ có thể bị phá bởi kỹ năng 3 của boss.

**Linh Khoáng Ma Ảo** (minion)
- Sức mạnh tấn công: **65**.
- Cơ chế tấn công thường: Kèm hiệu ứng đẩy lùi mục tiêu.
- Kỹ năng: Mỗi 10 giây, phát ra đá chóp nhỏ từ xa, gây sát thương cho người chơi.

---

### 16.6 Tử Vân Ma Quân · Hóa Thân (trang 183-185) — FINAL BOSS
**Prefab:** `xd_ziyunboss` (boss form), brain `xd_ziyunbossbrain`, SG `SGxd_ziyunboss` + `SGxd_ziyunshadow` + `SGxd_ziyunjfsn` + `SGxd_ziyunsword` + `SGxd_ziyunwarg`. Bigportrait `xd_ziyunboss` (?). Liên quan minion: `xd_ziyunge`, `xd_ziyunjfsn`, `xd_ziyunminions`, `xd_ziyunswordfx`, `xd_ziyunwarg`, `xd_deerclops_ziyun`, `xd_stalke_ziyun` (3 raid biến dị).

**Khu vực sinh trưởng:** **Thiên Cơ Lâu Dị Hóa** (bản đồ) trên Côn Bằng Tiên Đảo. Có thể triệu hồi khi phá hủy Thiên Cơ Lâu Dị Hóa.

**Máu (3 dạng):**
- **Hóa Thân chính:** 9.750
- **Dạng 2 — Tinh thể Lộc Dương một mắt:** 13.000
- **Dạng 3 — Trái tim:** 9.750 (trước khi mở cảnh giới Vạn Vật)

**Sức mạnh tấn công:** **30** (trước khi mở cảnh giới Vạn Vật).

**Bị động (toàn trận):**
- Luôn có Ma Kiếm đi theo bên cạnh Hóa Thân Tử Vân.
- Khi máu người chơi <5%, sẽ rơi vào tình trạng mê hoặc, Ma Kiếm tự động chém sát.

**Thời gian hồi sinh:** 7 ngày.

**Rơi ra:** Tử Sát Ma Vũ ×2, Lục Bảo Thạch ×3, Cam Bảo Thạch ×4, Hoàng Bảo Thạch ×4, Tử Bảo Thạch ×3, Tâm Phòng Bóng Tối ×1.
**Lưu ý:** Tử Sát Ma Vũ có thể cho thân ngoại hóa thân ăn để tăng kinh nghiệm luyện khí.

**Dạng 1:**
- Sau 5 giây đầu trận, triệu hồi **Cổ Thần Chế Ảnh Giả** hợp lực tấn công.
- **Kỹ năng:**
  1. Mỗi 3 đòn tấn công thường, kích hoạt hợp lực Ma Thể tối thượng, gây sát thương.
  2. Cổ Thần Chế Ảnh Giả dùng Cốt Lao lên người chơi, gây sát thương nhỏ và trói người chơi.
  3. Triệu hồi Bóng Tối Dệt Lên bò về người chơi, mỗi vụ nổ gây sát thương.

**Dạng 2:**
- Khi máu Hóa Thân = 1, bay lên không trung, dùng **Tôn Hồn Phan** triệu hồi **Tinh Thể Lộc Dương Một Mắt Hồn Phách** tấn công người chơi.
- Hóa Thân trên không liên tục dùng Tôn Hồn Phan và Phong Thiêu Kiếm để gây rối người chơi.
- Đánh bại Hồn Phách Tinh Thể Lộc Dương để tiến sang Pha 3.
- **Kỹ năng:**
  1. Hồn Phách Lộc Dương: Dùng Thương Băng gây sát thương và hiệu ứng đóng băng.
  2. Ma Quân: Dùng Tôn Hồn Phan triệu hồi Ngự Tọa Lang Hồn Phách, tấn công kết hợp băng – hỏa, gây rối người chơi.
  3. Ma Quân: Dùng Phong Thiêu Kiếm, triệu hồi Phượng Hoàng tấn công người chơi.

**Dạng 3:**
- Hóa Thân Tử Vân hạ xuống đất, tạo ra **Ma Tâm Tử Vân**.
- Chỉ khi tiêu diệt Ma Tâm hoàn toàn, mới đánh bại Hóa Thân.
- Dạng này, Hóa Thân dùng bí pháp, mạnh mẽ hơn.
- **Kỹ năng:**
  1. Vòng 1 – đòn thứ 3: Kích hoạt hợp lực Ma Thể tối thượng, gây sát thương.
  2. Vòng 2 – đòn thứ 3: Kích hoạt Ma Kiếm tấn công tầm xa.
  3. Vòng 3 – đòn thứ 3: Ma Kiếm phía sau Ma Quân dùng đòn đại chiêu, gây sát thương kéo dài 6 giây.
  4. Mỗi 20 giây, triệu hồi số lượng lớn Ma Thể tối thượng tiến về người chơi; nếu khoảng cách ngắn, gây sát thương cực lớn.

---

## 17. Bảng tra prefab → wiki section

Bảng dưới liệt kê các prefab đã được PDF wiki nhắc tới (qua mô tả hoặc inference từ tên Hán-Việt) và section nào trong document này tham chiếu chúng.

### 17.1 Prefab nhân vật

| Prefab | Section |
|---|---|
| `xd_wangmazi`, `xd_wangmazi_none` | §1.1 |
| `xd_shiji`, `xd_shiji_none` | §1.2 |
| `xd_hantianzun`, `xd_hantianzun_none` | §1.3 |
| `xd_yunxiao`, `xd_yunxiao_none` | §1.4 (Tam Tiêu Nương Nương) |
| `xd_jingwei`, `xd_jingwei_none` | §1.5 |
| `xd_wukong`, `xd_wukong_none` | §1.6 |
| `xd_sudaji`, `xd_sudaji_none` | §1.7 |
| `xd_longtaizi`, `xd_longtaizi_none` | §1.8 (Ngao Bính) |
| `xd_luoshen`, `xd_luoshen_none` | **không nêu rõ trong PDF** (xem §18 Gap) |

### 17.2 Prefab pháp bảo theo nhân vật

| Prefab | Wiki entry | Section |
|---|---|---|
| `xd_wmz_tnz` | Thiên Nghịch Châu | §1.1 |
| `xd_wmz_zhf` / `xd_zhf` | Tôn Hồn Phiên | §1.1, §5.9 |
| `xd_wmz_xsj` / Khôn Cực Tiên Tiên | §1.1 | |
| `xd_wmz_slxj` | Sát Lục Tiên Quyết | §1.1 |
| `xd_wmz_md` / `xd_wmz_db` / `xd_wmz_kjb` | Mộc Điêu Sư Phó | §1.1 |
| `xd_wmz_butterfly` | Bướm/scout | §1.1 |
| `xd_wmz_xsj` | Huyết Sát Kiếm (Chuyên Chức) | §6.1 |
| `xd_sj_by` | Bích Vân Đồng Tử | §1.2 |
| `xd_sj_cy` | Thái Vân Đồng Tử | §1.2 |
| `xd_sj_kls` | Khô Lâu Sơn | §1.2 |
| `xd_sj_tej` | Thực Tâm Trụy / Thái A Kiếm | §1.2, §6.2 |
| `xd_sj_bgygp` | Bát Quái Vân Quang Pháp | §1.2 |
| `xd_sj_bglxp` | Bát Quái Long Tu Pháp | §1.2 |
| `xd_sj_sxz` | Tinh Thạch Yết Đạo Trượng | §1.2 |
| `xd_sj_xsydz` | Thông Linh Thạch Khiếu | §1.2 |
| `xd_sj_tlsq` | (Không nêu rõ — xem §18) | |
| `xd_htz_lq` (component) | Linh lực HTZ | §1.3 |
| `xd_htz_ztp` / `xd_ztp` | Chưởng Thiên Bình / Hư Thiên Đỉnh | §1.3 |
| `xd_htz_firefx` | Tam Diễm Phiến | §1.3 |
| `xd_htz_fjfb` | Phong Lôi Dực | §1.3 |
| `xd_htz_spell` | Ngũ Tử Đồng Tâm Ma | §1.3 |
| `xd_htz_xyzz` | Phá Diệt Pháp Mục | §1.3 |
| `xd_htz_qzj` | Nguyên Hợp Ngũ Cực Sơn | §1.3 |
| `xd_htz_xtzlj` | Huyền Thiên Tràm Linh Kiếm / Thanh Trúc Phong Vân Kiếm | §1.3, §6.3 |
| `xd_htz_sjcx` | Phi Kiếm Phù Bảo | §1.3 |
| `xd_htz_tlz` | Thiên Lôi Tử | §1.3 |
| `xd_yunxiao_hyjd` | Hỗn Nguyên Kim Đẩu | §1.4 |
| `xd_yunxiao_hytxtele` (component) | Đài Dịch Chuyển Thái Hư | §1.4 |
| `xd_yunxiao_fls` | Phức Uẩn Thủ Trượng | §1.4 |
| `xd_yunxiao_fysz` | Vân Mạc Thượng Trang | §1.4 |
| `xd_yunxiao_fgfq` | Phược Long Tỏa | §1.4 |
| `xd_yunxiao_jjj` | Phù Cốt Pháp Khí / Kim Giao Tiễn | §1.4, §6.4 |
| `xd_yunxiao_portable_spicer` | Trạm Gia Vị Vân Yên | §1.4 |
| `xd_yunxiao_tooler` | Pet/tool Vân Tiêu | §1.4 |
| `xd_yunxiao_battleborn` (comp) | Quỳnh Tiêu buff | §1.4 |
| `xd_jingwei_fan` | Thanh Xuất Ư Lam | §1.5 |
| `xd_jingwei_blowdart` | Huyền Vũ Xuy Tiễn | §1.5 |
| `xd_jingwei_hat` | Phức Úc Thủ Trượng (nón) | §1.5 |
| `xd_jingwei_fenice` | Huyền Điểu pet | §1.5, §6.5 |
| `xd_jingwei_zzql` | Thúy Vũ Tiên Tung / Chỉ Thử Thanh Lục | §1.5, §6.5 |
| `xd_wukong_jgb` / `xd_jgb` | Như Ý Kim Cô Bổng | §1.6, §6.6 |
| `xd_72bian` | Biến Hóa Chi Thuật | §1.6 |
| `xd_wukong_dsmo` | (chưa map cụ thể) | §18 |
| `xd_sudaji_xyj` / `xd_sudaji_ywfh` | Nhất Vũ Phương Hoa / Mai Hương Như Cựu | §1.7, §6.7 |
| `xd_sudaji_yhly` | Dưỡng Hồn Linh Ngọc | §6.7 |
| `xd_sudaji_redlantern` | Đăng Ngư Long | §1.7 |
| `xd_sudaji_sjpn` / `xd_sjpn_container` | Bội Nang Bách Vị | §1.7 |
| `xd_sudaji_tsmd` | Thực Khám Thiên Vị | §1.7 |
| `xd_sudaji_mxrg` | Mộc Điêu Thế Thân / pet mxrg | §1.7 |
| `xd_sudaji_soul` / `xd_sudaji_soul_spawn` | Trụ Vương hồn | §6.7 |
| `xd_longzhu` | Long Châu | §6.9 |
| `xd_binglingqi` (comp) | Hàn Băng Linh Khí | §1.8 |

### 17.3 Boss & quái

| Prefab | Boss/Quái | Section |
|---|---|---|
| `xd_kunpeng_shadow` + spawner `xd_kunpengspawner` + stage `xd_kunpengstage` | Côn Bằng | §13 |
| `xd_xianhe` | Tiên Hạc | §13.5 |
| `xd_jcbird` / Kim Sí Điểu | Kim Phượng Thần Niệm (?) | §16.1 |
| `xd_qlch` (+ `_cloud`, `_fx`) | Tàn Hồn Kỳ Lân | §16.2 |
| `xd_baihu` (+ buff, shadow_fx, fx) | Tàn Thần Bạch Hổ | §16.3 |
| `xd_zhouwang` + `xd_zhouwang_shadow` | Tà Sát Chu Vương | §16.4 |
| `xd_swhs` | Ma Tướng Phù Đồ (?) | §16.5 |
| `xd_ziyunboss` + ge/jfsn/minions/swordfx/warg | Tử Vân Ma Quân Hóa Thân | §16.6, §13.6 |
| `xd_deerclops_ziyun` | Crystal/Tử Vân Deerclops | §16.6 (raid minion) |
| `xd_stalke_ziyun` | Tử Vân Stalker | §16.6 |
| `xd_ziyunwarg` | Tử Vân Warg | §16.6 |
| `xd_qy` (?) | Linh Hồ ↔ Yêu Tạp Ma Châu (Côn Bằng) | §13.5 (mapping uncertain) |

### 17.4 Đan dược / linh thạch / luyện đan

| Prefab | Section |
|---|---|
| `xd_lingshi` | §5.8 (Linh thạch phẩm cấp), §13.5 (Mỏ Linh Thạch) |
| `xd_liandanlu` | §7.1 (Lò Đan) |
| `xd_jitan` + `xd_jitan_antlion_sinkhole` | §12 (Địa Luyện Thể) |
| `xd_danyao`, `xd_danyao_items`, `xd_danyao_new`, `xd_dy_buffs` | §9 (Đan Dược) |
| `xd_lingbao` / `xd_lingbaojilian` / `xd_lingbaojilian10` (components) | §5 (Linh Bảo, tế luyện 10 cấp) |

### 17.5 Container & công trình

| Prefab | Section |
|---|---|
| `xd_cangku` | §14 Kho Chứa |
| `xd_he_container` | §14 |
| `xd_cwkj_container` | §14 |
| `xd_llbx` / `xd_lbx` / `xd_lbjlt` | §12 (Bảo Rương Linh Lung), §14 |
| `xd_choujiangji` / `xd_cjjspwner` | §15.1 Máy Quay Thưởng |
| `xd_lights` | §15.2-15.6 (đèn) |
| `xd_chairs` / `xd_walls` / `xd_floor` / `xd_fence` | §15 (nhà cửa nói chung) |
| `xd_planted_tree` / `xd_flowers` / `xd_huapen` | §11 Trang trí |
| `xd_dragonfly` | §15.9 Tổ Chuồn Chuồn |
| `xd_bearger` | §15.10 |
| `xd_beefalo` | §15.11 |
| `xd_koalefant` | §15.14 |
| `xd_huapen` + `xd_huapen_plant` + `xd_ylxq` | §7.3 Ngọc Lộ Tiên Khê |
| `xd_qxdx` + brain + spawner + shopui | NPC shop (Hermit-like) — không có trang riêng trong PDF, xem §18 |

### 17.6 Linh mộc / cây

| Prefab | Section |
|---|---|
| `xd_shatangshu` (đoán) | §10.1 Cây Sa Đằng |
| `xd_fanhunshu` | §10.2 Cây Phản Hồn |
| `xd_deciduous_root` | §10.1 (Quả Sa Đằng) |
| `xd_trees` / `xd_planted_tree` | §11 Cây cảnh |

### 17.7 Component cốt lõi (cross-cut)

| Component | Function | Section |
|---|---|---|
| `xd_level`, `xd_savelevel` | Cảnh giới Luyện Thể & save | §2.1 |
| `xd_dtlevel` | Đại đạo level | §2.1 (suy diễn) |
| `xd_worldlevel`, `xd_worldlevel_old` | Thế Giới Thăng Cách | §2.3 |
| `xd_lingji` | Linh khí pool | §1.3 (HTZ), §9 (chung) |
| `xd_lingbao` | Linh Bảo core | §5 |
| `xd_lingbaojilian` / `xd_lingbaojilian10` | Tế luyện 10 cấp | §5.6 |
| `xd_jilianmanager` | Manager tế luyện | §5.6 |
| `xd_jllingshi` | Linh thạch currency | §5.8 |
| `xd_lingliitem` | Item chứa linh lực | §1.3 |
| `xd_skillcd` (+replica) | Cooldown skill | §1.6 (Wukong) |
| `xd_xuetiao` (+replica) | Healthbar | §16 (boss HP) |
| `xd_damagenumber` (+replica) | Số sát thương | §16 |
| `xd_consciousnessdamage` / `xd_consciousnessdefense` | Sát thương Thần Thức | §2.3 (sau thăng cách) |
| `xd_petleash` + variants (`_bjms`, `_cy`, `_fly`, `_mxrg`, `_qy`, `_xinmo`) | Leash pet riêng | §1.2 (Shiji), §1.5 (Jingwei), §1.7 (Sudaji), pet system |
| `xd_armor_levelup` / `xd_armor_levelupitem` / `xd_levelupitem` | Nâng cấp giáp | §5.8 (bồi dưỡng linh thạch) |
| `xd_playerhouse` / `xd_playerhousepos` / `xdhouse` | Nhà chơi | §5.1 Thiên Cơ Ốc |
| `xd_interiors` | Interior tiles | §5.1 |
| `xd_teleporter` | Teleporter | §1.4 (Hỗn Nguyên Kim Đẩu) |
| `xd_kunpengspawner` / `xd_kunpengstage` | Côn Bằng dungeon | §13 |
| `xd_baihuspwner` / `xd_jfsnspwner` / `xd_qlchspwner` | Boss spawner | §16.1, §16.2, §16.3 |
| `xd_buffs` / `xd_dy_buffs` / `xd_weaponbuffs` / `xd_baihu_buff` / `xd_dms_healthregenbuff` | Status effects | §16 (boss debuff), §9 (đan dược buff) |
| `xd_72bian` | 72 biến (Wukong) | §1.6 |
| `xd_jingwei_pet` | Jingwei fenice mechanism | §1.5 |
| `xd_wukong_skill` | Wukong skill component | §1.6 |
| `xd_sudaji_controller` | Sudaji controller | §1.7 |
| `xd_htz_sword_controller` / `xd_sword_controller` | Kiếm controller | §1.3 |

---

## 18. Gap Analysis — Prefab có trong daxsg_mod_path.txt nhưng KHÔNG xuất hiện trong PDF

### 18.1 Nhân vật chưa cover bởi wiki PDF

- **`xd_luoshen` / `xd_luoshen_none` / `xd_luoshen_flower` / `xd_luoshen_items` / `xd_luoshen_jihuaze_debuff` / `xd_luoshen_krss` / `xd_luoshen_shentong_fx`** — Lạc Thần (洛神). Mặc dù prefab và speech file đầy đủ (xem `dengxian_gameplay_glossary.md` §2.4, §5.4), PDF Vietnamese wiki **hoàn toàn không có trang riêng** cho nhân vật này. Có thể:
  - (a) Nhân vật đã bị xóa khỏi mod ở phiên bản gần đây (workshop v18.1), hoặc
  - (b) Fan-translation chưa cover, hoặc
  - (c) Lạc Thần được gộp dưới một section khác mà tôi đã đọc sót — khả năng thấp.
- Stategraph `SGxd_luoshenzhu_vine` xác nhận skill dây leo tồn tại runtime.

### 18.2 Pháp bảo / minion prefab không mô tả riêng trong PDF

| Prefab | Suy đoán | Lý do gap |
|---|---|---|
| `xd_sj_tlsq` | Pháp bảo Thạch Cơ | PDF không liệt kê riêng — có thể là internal logic của Tinh Thạch Yết Đạo Trượng. |
| `xd_wukong_dsmo` | "Đại Thánh Ma" / form chuyển hóa Wukong | Liên kết với form Đại Thánh ở §1.6 nhưng PDF không có entry riêng. |
| `xd_wukong_shadow` | Phân thân Wukong | Internal mechanic của Linh Kỹ "Tụ Hình Tán Khí"; không entry riêng. |
| `xd_wukong_breath_fx` / `xd_wukong_moose_fx` | FX biến hóa 72 phép | FX prefab, không có entry riêng. |
| `xd_xinmo` + `xd_petleash_xinmo` + brain + SG | Tâm Ma (Côn Bằng) | §13.3 nhắc Tâm Ma boss nhưng `xinmo` cũng có thể là 1 pet hệ thống khác. |
| `xd_xjs` + `xd_xjspuppet` + `xd_xjs_curve_fx` | Boss tentacle / puppet | PDF không có entry riêng. |
| `xd_tssyq` + `SGxd_tssyq_puppet` + `SGxd_tssyq_shark` | Quái multi-form | Không có. |
| `xd_jfsn` + `xd_jfsn_fire` + `xd_jfsnmeteor` + spawner | Boss có meteor lửa | PDF không có section riêng — có thể là Kim Phượng Thần Niệm pre-boss spawn? |
| `xd_jcbird` + `xd_fb_jcbird` | Kim Sí Điểu (vanilla + fuben) | PDF Kim Phượng dùng meteor + birds — có thể link gián tiếp tới §16.1. |
| `xd_pog` + brain + SG | Pet POG vanilla-clone | Không nêu. |
| `xd_icebutterfly` + brain + SG | Bướm băng (link Ngao Bính Long Châu kỹ năng 8?) | §6.9 nhắc "Băng Điệp" → có thể chính là `xd_icebutterfly`. |
| `xd_icedragon` | Rồng băng | Không có entry boss. |
| `xd_klxw` | Klaus-clone (?) | Không có trang riêng, chỉ nhắc trong Lục Căn Khí của Wukong §1.6 boss list. |
| `xd_swhs` + brain + SG | Quái độc lập | §16.5 đoán là Ma Tướng Phù Đồ. |
| `xd_lhwdc`, `xd_ftys`, `xd_ylxc`, `xd_mr`, `xd_nl`, `xd_sly`, `xd_pflnw`, `xd_hjjm`, `xd_xtbh`, `xd_dbg`, `xd_mglz`, `xd_mg` | Mob/sinh vật nhỏ | Không có entry — có thể là sinh vật ambient trong biome. |
| `xd_ws` + `xd_ws_wizard_fx` | Phù thuỷ shadow | Không nêu. |
| `xd_aoeent` | AOE entity | FX/internal. |
| `xd_gongdeshadow` + SG | Bóng Công Đức | Link với Công Đức Kim Thân §2.4 — có thể là hiệu ứng triệu hồi Kim Thân. |
| `xd_ds_entity` + widget `xd_ds_ui` | "Đại Thánh" form UI? | Liên kết với form Đại Thánh §1.6 nhưng không có entry. |
| `xd_gestalt` + brain + SG | Gestalt (lunar) | Không nêu. |
| `xd_shadowmonster`, `xd_shadowmeteor`, `xd_shadow_bishop` | Shadow creatures (port) | Internal. |
| `xd_lightninggoat` + SG | Dê sấm port | Internal. |
| `xd_merm` + SG / `xd_mermguardbrain` | Nhân ngư port | Liên kết với pháp bảo Kim Lân của Wurt §6.11.4. |
| `xd_spider` + `xd_spiderden` + `xd_spiderqueen` + `xd_spiderqueen_cloud` + `xd_shadowspiderqueen` | Nhện vanilla + biến thể | Liên kết với Nghị Lân của Webber §6.11.16. |
| `xd_bearger`, `xd_eyeofterror`, `xd_dragonfly`, `xd_stalke` (+ `_fuben`, `_ziyun`) | Boss vanilla + biến thể | §15.9-10, §16.6. |

### 18.3 Phó bản (`fb`) chưa cover

Toàn bộ hệ thống `xd_fb_*` (`xd_fb_hound`, `xd_fb_jcbird`, `xd_fb_jfsn`, `xd_fb_lavae`, `xd_fb_mutateddeerclops`, `xd_fb_mutatedwarg`, `xd_fb_warg_mutated_fx`, `xd_fubenminions`) — **không có section riêng nào trong PDF**. Đây có thể là một dungeon system riêng hoặc bộ raid mutated chưa được tài liệu hóa.

### 18.4 Hệ thống NPC shop chưa cover

- `xd_qxdx` (NPC), brain `xd_qxdxbrain`, spawner `xd_qxdxspwner`, widget `xd_qxdx_shopui`, SG `SGxd_qxdx` — confirm có **shop NPC kiểu Hermit/Pearl** nhưng PDF không có section riêng.

### 18.5 Vũ khí phụ chưa cover

- `xd_qfwjd` (Khởi Phong Vạn Kiếp Đao) + SG `SGqfwjdtornado` — không có entry riêng.
- `xd_ftj` (Phi Thiên Kiếm) — không có.
- `xd_wxj` (Vạn Hiệp Kiếm?) — không có.
- `xd_xhwyj`, `xd_hyf`, `xd_wyj`, `xd_sword`, `xd_swordfx`, `xd_ziyunswordfx` — kiếm chung, không có entry riêng.

### 18.6 Hệ thống monster enhancement chưa cover

Module `main/xd_moster_*` (`healthbar`, `qianghua`, `shengti_set`, `skill`, `skill_set1`, `skill_set2`) — confirm có hệ thống cường hóa quái vanilla theo cấp, nhưng PDF chỉ ám chỉ qua §2.2 (Bản Nguyên Thiên Lệch) + §2.3 (Yêu Linh Thánh Thể), không có section technical riêng.

### 18.7 Mention trong PDF không map được tới prefab cụ thể

| Mention trong PDF | Mong đợi prefab | Tình trạng |
|---|---|---|
| "Thực Kim Trùng" (Hàn Thiên Tôn pet, §1.3) | ? | Không có prefab `xd_htz_*_chong` rõ; có thể dùng `xd_minions` hoặc `xd_qy`. |
| "Huyết Ngọc Chu" (HTZ pet, §1.3) | ? | Tương tự, có thể là `xd_minions` variant. |
| "Bàn Nhạc Thạch Khôi" (Thái A Kiếm minion, §6.2) | ? | Không có prefab rõ. |
| "Cổ Thần Chế Ảnh Giả" (Tử Vân Pha 1, §16.6) | `xd_gestalt`? | Có thể link `xd_gongdeshadow` / `xd_gestalt`. |
| "Ma Tâm Tử Vân" (Tử Vân Pha 3, §16.6) | `xd_xinmo`? | Liên kết với Tâm Ma ở §13.3, có thể chia sẻ component. |
| "Hồn Phách Tinh Thể Lộc Dương" (Tử Vân Pha 2, §16.6) | ? | Không có prefab rõ — internal stage minion. |
| "Pháp Thân Trụ Vương" (Sudaji ultimate, §6.7) | `xd_sudaji_soul_spawn` / `xd_zhouwang` | Có thể link tới `xd_zhouwang` raid boss prefab. |
| "Hỏa Tinh", "Chu Điểu" (Kim Phượng minions, §16.1) | ? | Không có prefab rõ — internal minion spawn. |
| "Tinh Thể Băng Nhãn" (Long Châu skill 2, §6.9) | `xd_icedragon`? | Có thể link. |
| "Băng Điệp" (Long Châu skill 8, §6.9) | `xd_icebutterfly` | ✓ Confirmed mapping. |
| "Hắc Hổ Cẩm Mao" (food vật phẩm tu vi, §2.4) | drop từ `xd_baihu` | Confirmed §16.3. |
| "Lông Vũ Mãnh" (Tiên Hạc drop, §2.5 Hồi Nguyên Đan) | drop từ `xd_xianhe` | Confirmed §13.5. |
| "Tà Sát Bộ Túc" (Chu Vương drop, §2.5 Hồi Nguyên Đan) | drop từ `xd_zhouwang` | Confirmed §16.4. |
| "Ma Quái Kiềm Cốt" (Ma Tướng Phù Đồ drop, §2.5 Hợp Linh Đan) | drop từ `xd_swhs`(?) | Confirmed §16.5. |
| "Tử Sát Ma Vũ" (Tử Vân drop, §2.5 Hợp Linh Đan) | drop từ `xd_ziyunboss` | Confirmed §16.6. |
| "Trụ Vương" (Sudaji ultimate) | `xd_zhouwang` | Confirmed link, dùng để hồi sinh Tô Đát Kỷ. |

### 18.8 Gợi ý cho dev mod mới

Khi bạn implement mod tương tự:
1. **Lạc Thần** là khoảng trống lớn nhất — wiki tiếng Việt chưa cover, nên bạn có thể tự thiết kế lại theme thuỷ + hoa + thần thông (gợi ý từ `dengxian_gameplay_glossary.md` §2.4).
2. **Phó bản system** (`xd_fb_*`) — bạn có thể tự thiết kế bộ "dungeon" với mutated boss tương tự.
3. **NPC shop** (`xd_qxdx`) — implement hệ thống Hermit-like riêng.
4. **`xd_qfwjd`, `xd_ftj`, `xd_wxj`** — bộ vũ khí phụ "shared" giữa các nhân vật mà bạn có thể tự design.
5. **Hệ thống monster enhancement** (`xd_moster_*`) — implement Bản Nguyên Thiên Lệch (7 hệ × 4 cấp = 28 biến thể) theo §2.2 chính là khung sườn nguy hiểm và "thấm" nhất của mod gốc.

---

**Hết tài liệu.** Tổng số section: 18 (1 nhân vật → 16 boss → 17 prefab lookup → 18 gap). Mọi số liệu trong document này được copy verbatim từ wiki PDF 186 trang.


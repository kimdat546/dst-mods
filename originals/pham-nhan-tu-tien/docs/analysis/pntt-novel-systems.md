# Phàm Nhân Tu Tiên — Hệ thống nguyên tác (design foundation)

Tổng hợp từ deep-research đa nguồn (có adversarial verify) + đối chiếu Dengxian wiki.
Nguồn gốc: tiểu thuyết 凡人修仙传 (A Record of a Mortal's Journey to Immortality) — 忘语.

**Mức tin cậy:**
- ✅ **VERIFIED** — đã fact-check 3-vote (2-3/3 đồng thuận), dùng làm xương sống thiết kế.
- 🔶 **SUPPLEMENTARY** — thu thập được nhưng chưa adversarial-verify; dùng tham khảo, cần kiểm lại trước khi đưa vào cơ chế cứng.

---

## 1. Thang cảnh giới (Cultivation Realm Ladder) ✅ VERIFIED

Chia 3 đại tầng: **Hạ Cảnh Giới (Nhân Giới)** → **Trung Cảnh Giới (Linh Giới)** → **Thượng Cảnh Giới / Tiên Giới**.

### Nhân giới — 8 đại cảnh giới (thứ tự cố định) ✅
| # | Cảnh giới | 中文 | Đặc điểm chuyển hoá | Tuổi thọ (≈) |
|---|---|---|---|---|
| 1 | Luyện Khí | 练气 | Nhập môn, hấp thu linh khí. **13 tầng** (không chia sơ/trung/hậu) | 100–180 năm |
| 2 | Trúc Cơ | 筑基 | Linh khí **hoá lỏng**, xây nền tảng | ~200–250 năm |
| 3 | Kết Đan | 结丹 | Ngưng tụ **Kim Đan** — "tu tiên chân chính" | ~500–600 năm |
| 4 | Nguyên Anh | 元婴 | Hình thành **Nguyên Anh** (linh hồn thu nhỏ), có thể đoạt xá | ~1000–1500 năm |
| 5 | Hoá Thần | 化神 | Siêu phàm, điều khiển một phần quy luật thiên địa | ~2000 năm |
| 6 | Luyện Hư | 炼虚 | (Spatial Tempering / Void Refinement) | — |
| 7 | Hợp Thể | 合体 | Hợp nhất nguyên anh + thần thức + công lực → **pháp tướng** | — |
| 8 | Đại Thừa | 大乘 | (Mahayana / Grand Ascension) — cuối nhân giới, trước phi thăng | — |

**Đột phá:** từ Đại Thừa phải vượt **Độ Kiếp (渡劫)** — lôi kiếp / thiên kiếp — để phi thăng Tiên giới.

### Sub-stage ✅
Mọi cảnh giới **TRỪ Luyện Khí** chia 4 giai đoạn: **Sơ kỳ → Trung kỳ → Hậu kỳ → Đại viên mãn**.
Luyện Khí thay bằng **13 tầng**.

### Tiên giới ✅ (#9 trở lên)
| Cảnh giới | 中文 | Ghi chú |
|---|---|---|
| (Ngụy Tiên) | 伪仙 | Vừa phi thăng — chưa chuyển hết pháp lực thành tiên nguyên |
| **Chân Tiên** | 真仙 | Realm #9, tồn tại thần thánh đầu tiên. ~12,000 năm thọ |
| Kim Tiên | 金仙 | Thông 36 tiên khiếu mới lên được |
| Thái Ất (Ngọc Tiên) | 太乙 | |
| Đại La (Kim Tiên) | 大罗 | Cần **trảm Tam Thi**; thông 360 tiên khiếu |
| Đạo Tổ | 道祖 | Đỉnh cao |

**Cơ chế tiên khiếu (aperture) ✅:** Chân Tiên 3 sub-stage mở dần tiên khiếu — 12 khiếu → trung kỳ, 24 → hậu kỳ, **36 khiếu → đủ lên Kim Tiên**. → Cơ chế "mở 36 node" rất hợp làm progress bar rời rạc.

**Tam Suy của Chân Tiên ✅:** Chân Tiên KHÔNG bất tử thụ động — phải vượt **Tam Suy** (躯衰 Khu Suy / 仙衰 Tiên Suy / 窍衰 Khiếu Suy) định kỳ. → Cơ chế "maintenance tribulation" / decay cuối game.

---

## 2. Linh căn (Spiritual Root) ✅ VERIFIED (cốt lõi) + 🔶 chi tiết

- **Hàn Lập (nhân vật chính)** có **4 ngụy linh căn**, thiếu hệ **Kim (金)** — hệ Thủy/Mộc/Hỏa/Thổ. Là kẻ **tư chất thấp**, tốc độ tu luyện cực chậm. Sau bổ sung hệ Kim qua nội đan Giao Long. ✅
- Linh căn là **modifier tốc độ tu luyện**, tách rời khỏi thang cảnh giới. ✅
- 🔶 Phân loại (theo fan-wiki, chưa verify cứng — khớp với MVP1 ta đã dùng):
  - Ngụy linh căn (4-5 hệ) — chậm nhất
  - Chân linh căn (2-3 hệ) — khá
  - Thiên linh căn (1 hệ) — thiên tài
  - Biến dị linh căn (combo hệ đặc biệt: Lôi/Băng/Phong...) — hiếm, nhanh + thần thông riêng
- 🔶 **Bổ Thiên Đan (补天丹)** có thể bù linh căn tạp, tinh luyện linh căn → nối hệ thống đan dược với linh căn.

---

## 3. Pháp bảo (Magic Treasures) 🔶 SUPPLEMENTARY

(Chưa adversarial-verify nhưng nhất quán giữa các nguồn Qidian)
- **Pháp khí (法器)** — kích hoạt bằng linh lực, chia **thượng/trung/hạ tam phẩm** (上中下三品).
- **Pháp bảo (法宝)** — luyện được khi đạt **Kết Đan**, dùng đan hoả / địa hoả.
- **Bản mệnh pháp bảo (本命法宝)** — gắn với linh hồn tu sĩ, **mạnh lên theo tu vi** + theo thời gian.
- Thang cao hơn (tham khảo tiên hiệp chung): Pháp khí → Pháp bảo → Linh bảo → Tiên khí.
- → Cơ chế game: vũ khí "tế luyện" nhiều cấp, mạnh dần theo cảnh giới (đã làm thử với Trúc Phong Vân Kiếm: damage scale theo tier).

---

## 4. Đan dược & Luyện đan 🔶 SUPPLEMENTARY
- Đan dược chia phẩm cấp; tu sĩ luyện bằng đan hoả/địa hoả + linh thảo.
- **Bổ Thiên Đan** (sửa linh căn) là đan nổi bật.
- **Tiểu bình xanh thần bí (mysterious green vial)** của Hàn Lập — bảo bối định mệnh: **tăng tốc sinh trưởng linh thảo** đặt trong đó. → Cơ chế game: "linh điền gia tốc" / trồng linh thảo nhanh.
- (Dengxian wiki có chi tiết 16 loại đan + công thức — xem `dengxian_wiki_data.md` §9, nhưng đó là diễn giải của MOD, không phải canon novel.)

---

## 5. Linh thạch (Spirit Stone economy) 🔶 SUPPLEMENTARY
- Tiền tệ tu tiên, chia **hạ/trung/thượng/cực phẩm** (low/mid/high/top). Cấp cao = linh khí đậm đặc hơn.
- → Cơ chế game: tài nguyên tu luyện + tiền tệ chế tạo.

---

## 6. Môn phái / thế lực 🔶 SUPPLEMENTARY (yếu — cần research thêm nếu cần)
- **Thất Huyền Môn** (七玄门) — môn phái khởi đầu của Hàn Lập (phàm nhân, thấp cấp).
- **Hoàng Phong Cốc** (黄枫谷) — môn phái tu tiên Hàn Lập gia nhập sau.
- Liên minh các tông (Seven Sect Alliance) — fan-wiki, chưa verify.
- → Với mod no-character / co-op, "môn phái" có thể là **sĩ môn do người chơi lập** (đã ghi trong feedback long-term).

---

## 7. Cơ chế đặc trưng (Signature mechanics) ✅/🔶
- **Đoạt xá (夺舍)** — Nguyên Anh chiếm thân xác khác để tái sinh. ✅ (gắn realm Nguyên Anh)
- **Tam Suy** ở Chân Tiên — decay định kỳ. ✅
- 🔶 **괴 lỗi / Puppet (傀儡)** — Hàn Lập dùng괴 lỗi (sentient puppet) làm chiến lực phụ.
- 🔶 **Luyện thể (体修)** — tu thân thể song song luyện khí (Dengxian tách Luyện Khí | Luyện Thể).
- 🔶 **Brahma Saint / Thôn phệ** — công pháp hấp thu/nuốt linh lực.
- 🔶 **Song tu** — tu luyện đôi.
- **Thiên kiếp/Độ kiếp** — lôi kiếp khi đột phá cảnh giới lớn. ✅ (gắn Đại Thừa→phi thăng)

---

## 8. Gợi ý ánh xạ sang cơ chế game (cho bước brainstorm)

| Hệ thống novel | Cơ chế game tiềm năng |
|---|---|
| 8 đại cảnh giới × 4 sub-stage | Thang tiến triển rời rạc (progress tiers) |
| 3 đại tầng (Nhân/Linh/Tiên) | 3 macro-tier → **world scaling** khi player đầu tiên lên Linh/Tiên |
| Luyện Khí 13 tầng | Giai đoạn đầu game nhiều bước nhỏ |
| Linh căn (4 loại) | Modifier tốc độ tu vi, random khi tạo nhân vật |
| Tiên khíếu 36 node | Progress bar rời rạc cuối game |
| Tam Suy / Độ Kiếp | Tribulation event — risk khi đột phá / maintenance |
| Tuổi thọ tăng theo cảnh giới | Lifespan + permadeath (đã làm MVP1) |
| Bản mệnh pháp bảo mạnh theo tu vi | Vũ khí scale theo cảnh giới (đã thử) |
| Tiểu bình xanh | Linh điền tăng tốc trồng linh thảo |
| Linh thạch hạ→cực phẩm | Tài nguyên + tiền tệ |
| Đoạt xá | (advanced) hồi sinh đặc biệt? |

---

## Caveat
- Thang cảnh giới + linh căn + tiên khíếu + tuổi thọ: **đáng tin** (verified).
- Pháp bảo / đan dược / linh thạch / môn phái: **mới gather, chưa verify cứng** — đa số khớp tiên hiệp chung + Dengxian, nhưng nếu muốn chính xác canon cần đọc nguyên tác sâu hơn (hoặc chấp nhận diễn giải game-hoá như Dengxian đã làm).
- Nguồn chính: en.wikipedia A Record of Mortal's Journey, mortalsjourney.com, fandom wiki, Qidian/Zhihu (tiếng Trung).

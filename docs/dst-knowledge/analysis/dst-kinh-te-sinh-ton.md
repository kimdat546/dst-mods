# Kinh tế sinh tồn DST — số liệu rút từ mã nguồn game

Viết sau khi mod AI Làng để dân làng chết đều từ ngày 9 mà vá mãi không xong.
Nguyên nhân hoá ra không nằm ở cây hành vi mà ở **kinh tế**: bảng nhu cầu của
mod đặt mục tiêu mà thế giới không đủ tài nguyên để đáp ứng.

Mọi con số dưới đây **đọc thẳng từ mã game** (`scripts/tuning.lua`,
`recipes.lua`, `preparedfoods.lua`, `veggies.lua`, `meats.lua`,
`components/hunger.lua`), không phải trí nhớ hay wiki.

## 1. Đói: bài toán số học khắc nghiệt

| đại lượng | giá trị | nguồn |
|---|---|---|
| Dạ dày | 150 | `wilson_hunger` |
| Đốt mỗi ngày | **75** | `calories_per_day` |
| → dạ dày đầy sống được | **2 ngày** | |
| Chết đói mất máu | **1 máu/giây** | `Hunger.hurtrate`, `hunger.lua:160` |
| → 150 máu bay trong | **2,5 phút** | |

Ba dân làng cần **225 calo/ngày**.

## 2. Giá trị đồ ăn

| món | sống | chín | giữ được |
|---|---|---|---|
| quả mọng | **9,375** | 12,5 | 6 ngày / 3 ngày |
| cà rốt | 12,5 | 12,5 | 10 ngày |
| thịt nhỏ | 12,5 | ~25 | 6 ngày |
| **thịt viên** (nồi hầm) | — | **62,5** | **10 ngày** |

Nấu chín quả mọng được **+33%** và thêm chút máu. Nồi hầm mới là đòn bẩy thật.

## 3. Vì sao quả mọng KHÔNG nuôi nổi một làng

| | |
|---|---|
| `BERRY_REGROW_TIME` | **3 ngày** (mỗi lần hái lại +0,5 ngày) |
| `BERRYBUSH_CYCLES` | **3** — hái 3 lần là bụi chết nếu không bón phân |
| → một bụi cho | **~0,33 quả/ngày** |

Ba dân làng cần 24 quả/ngày → **cần khoảng 70 bụi quả**. Làng thử nghiệm có vài
bụi. Chúng chắc chắn phải chết đói; chỉ là mất tới ngày 9 mới tiêu hết đồ ăn
khởi đầu và mấy bụi quanh nhà.

⚠ Đây là lý do thật của cái chết từ ngày 9, không phải lỗi cây hành vi.

## 4. Đồ ăn hỏng theo chỗ để

| chỗ để | hệ số |
|---|---|
| dưới đất | **×1,5** (hỏng nhanh hơn) |
| trong rương | ×1 |
| tủ lạnh | ×0,5 |
| mùa đông | ×0,75 |

## 5. Cây công nghệ — thứ gì mở ra thứ gì

**TECH 0 — không cần máy móc:**

| món | nguyên liệu |
|---|---|
| đuốc | cỏ 2, cành 2 |
| lửa trại | cỏ 3, gỗ 2 |
| rìu | cành 1, đá lửa 1 |
| cuốc | cành 2, đá lửa 2 |
| **bẫy thỏ** | **cành 2, cỏ 6** — 8 lần dùng |
| **bếp lửa đá** | gỗ 2, **đá 12** |
| **Máy Khoa Học** | **vàng 1**, gỗ 4, **đá 4** |
| mũ cỏ | cỏ 12 |
| **mũ tai thỏ** (chống lạnh) | **thỏ 2, cành 1** |

**TECH 1 — cần Máy Khoa Học:**
dây thừng (cỏ 3) · ván (gỗ 4) · đá cắt (đá 3) · giáo · giáp gỗ · ba lô ·
**nồi hầm** (đá cắt 3, than 6, cành 6) · giàn phơi · **rương** (ván 3)

**TECH 2 — cần Máy Giả Kim:**
đèn lồng · đá giữ nhiệt · mũ mùa đông · **tủ lạnh**

⚠ **Tủ lạnh cần BÁNH RĂNG**, chỉ rơi từ robot cơ khí. Không thực tế cho NPC
giai đoạn đầu — đừng đặt nó làm mục tiêu.

## 6. Đường sinh tồn đúng của một người chơi thật

```
ngày 1-2   cỏ, cành, đá lửa -> rìu, cuốc, đuốc, lửa trại
ngày 2-4   ĐÀO ĐÁ: đá + vàng -> MÁY KHOA HỌC (vàng 1, gỗ 4, đá 4)
           đặt BẪY THỎ (tech 0) -> nguồn thịt tái tạo
ngày 4-6   dây thừng -> giáo, giáp gỗ, ba lô
           đá cắt + than -> NỒI HẦM: 1 thịt + 3 độn = 62,5 calo, giữ 10 ngày
           ván -> RƯƠNG (đồ ăn khỏi hỏng nhanh 1,5 lần)
           bếp lửa đá (đá 12) thay lửa trại — không tắt ngóm giữa đêm
ngày 6-20  tích trữ, trồng trọt
ngày 21    MÙA ĐÔNG: mũ tai thỏ (tech 0!), bếp lửa, đồ ăn dự trữ
```

**Nút thắt là ĐÀO ĐÁ.** Không có đá thì không có Máy Khoa Học, không Máy Khoa
Học thì không dây thừng/nồi hầm/rương/giáo — tức là không có kinh tế đồ ăn,
không phòng thủ, không bảo quản. Mọi thứ khác đều nằm sau cái cuốc và mỏ đá.

## 7. Những thứ giết người chơi, theo thứ tự thời gian

| | |
|---|---|
| Charlie (bóng tối) | `GRUEDAMAGE = 150 × 0,667 = **100,05**` — hai đòn là chết |
| Chó săn | 20 sát thương/con, sóng đầu quanh ngày 3-7, lặp lại và tăng dần |
| Đói | 1 máu/giây khi dạ dày cạn |
| Quá nhiệt mùa hè | `OVERHEAT_TEMP = 70`, nhiệt môi trường có thể tới 85+ |
| Lạnh mùa đông | từ ngày 21 |

## 8. Bảng nhu cầu của mod thiếu gì (tính tới 15/09/2026)

| thiếu | hậu quả |
|---|---|
| Không có động lực **đào đá** | không bao giờ có Máy Khoa Học -> kẹt tech 0 vĩnh viễn |
| `do_an` chỉ hái quả mọng và cà rốt | cần ~70 bụi quả mới đủ nuôi 3 người |
| Không có **bẫy thỏ** | bỏ mất nguồn thịt tái tạo rẻ nhất, lại là tech 0 |
| Không biết **nấu chín** | mất 33% giá trị quả mọng, 100% giá trị thịt |
| Không có **nồi hầm** | bỏ mất món 62,5 calo giữ được 10 ngày |
| Không có **rương** | đồ ăn để đất hỏng nhanh 1,5 lần |
| Không có **bếp lửa đá** | lửa trại cứ tắt rồi phải dựng lại, tốn 2 gỗ mỗi vòng |
| Không chuẩn bị **mùa đông** | mũ tai thỏ là tech 0 mà không ai làm |

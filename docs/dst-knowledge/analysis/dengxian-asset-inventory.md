# Kho tài nguyên hình ảnh đã giải mã của mod 「登仙」(Dengxian)

> Mục tiêu: catalog trực quan toàn bộ asset PNG đã decode từ `.tex`, để developer dự án **Phàm Nhân Tu Tiên** quyết định asset nào dùng tạm làm placeholder, asset nào phải vẽ lại, asset nào bỏ.
>
> Nguồn: `~/Desktop/dengxian-assets-review/decoded_png/` — 567 ảnh PNG, giữ nguyên cấu trúc thư mục của mod gốc.
> Tham chiếu kiến trúc/đặt tên: `docs/analysis/dengxian_architecture.md`.
> Lưu ý quan trọng: dự án của chúng ta **không có nhân vật cố định** — nên mọi asset đặc thù nhân vật (portrait, skill medallion theo nhân vật, pháp bảo cá nhân) có giá trị tái sử dụng thấp; các asset tu tiên generic (đan dược, linh thạch, linh thảo, lò luyện đan, medallion cảnh giới, thanh máu/HUD) là phần đáng giá nhất.

---

## 1. Tổng quan

### 1.1 Số lượng & cấu trúc thư mục

| Thư mục | Số file | Nội dung |
|---|---:|---|
| `images/inventoryimages/` | 379 | Icon vật phẩm trong túi đồ (đan dược, linh thạch, linh thảo, pháp bảo, vũ khí, skin, cây trồng…) |
| `images/map_icons/` | 78 | Icon minimap (cây, đá, công trình, boss, NPC) |
| `images/avatars/` | 27 | 9 nhân vật × 3 biến thể (avatar thường / avatar ghost / self_inspect) |
| `images/skills/` | 8 | Atlas icon kỹ năng + 3 tile noise minimap |
| `images/saveslot_portraits/` | 9 | Ảnh nhân vật cho ô save (1/nhân vật) |
| `images/` (gốc) | 56 | UI/HUD atlas, splash art boss, trang sách bestiary, tên nhân vật |
| `bigportraits/` | 22 | Chân dung lớn màn chọn nhân vật (9 nhân vật + biến thể skin + `_none`) |
| **Tổng** | **579** | (con số catalog hơi lệch 567 do đếm cả 3 thư mục phụ avatars/saveslot) |

### 1.2 Phong cách mỹ thuật

- **Đồng nhất 100% với phong cách gốc Don't Starve Together**: nét viền đen dày, tô màu phẳng có vân giấy/than chì (charcoal), bóng đổ mềm. Đây là điểm cực kỳ giá trị — asset trông "đúng chất DST" chứ không phải art ngoài game dán vào.
- **Chất lượng cao và nhất quán**: icon túi đồ ~64×64, vẽ tay tỉ mỉ, mỗi đan dược có hình thù + tông màu riêng biệt (xem mục 2).
- **Hai lớp art tách biệt rõ**:
  1. *Art kiểu DST* (icon, chibi portrait, medallion) — dùng trực tiếp trong game.
  2. *Splash art kiểu tranh thủy mặc / Trung Hoa* (ví dụ `xd_kunpeng_ui1`, trang bestiary `xd_info_ys_*`) — minh họa boss, vẽ theo phong cách tranh mực màu, đẹp nhưng KHÔNG phải kiểu DST.
- **Tiền tố `xd_`** xuyên suốt (namespace tác gi) — tham chiếu mục 2 của tài liệu kiến trúc.

---

## 2. Inventory icons (`images/inventoryimages/`, 379 file)

Nhóm theo tiền tố/chủ đề. Số đếm lấy từ `ls` thực tế.

### 2.1 Đan dược — `xd_danyao_*` (16 file) ⭐ ƯU TIÊN TÁI SỬ DỤNG

Pill viên đan thành phẩm, mỗi loại một màu/hình riêng. Đặc biệt phù hợp mod tu tiên generic.

| File mẫu đã xem | Mô tả |
|---|---|
| `xd_danyao_hj.png` | Viên đan cầu tròn xanh dương, quanh có các tinh thể tím-xanh đâm tua tủa như pha lê băng. Rất "linh đan cao cấp". |
| `xd_danyao_jq.png` | Viên đan lửa: vỏ nâu sẫm, lõi xoáy lửa cam-vàng rực. Tông "hỏa thuộc tính". |
| `xd_danyao_bg.png` | Viên đan trắng/vàng nhạt nằm trên đế lá xanh có trứng-ngọc nhỏ + bướm vàng. Kiểu "đan bổ / dưỡng sinh". |
| `xd_danyao_rl.png` | Viên đan dạng giọt nước xanh ngọc bóng loáng, có tua khói/dây leo. |
| `xd_danyao_kx.png` | Viên đan tím-xanh có ngọn lửa âm xoáy quanh đáy vàng — kiểu "đan ma/độc". |

Các hậu tố còn lại: `_dt _hl _hs _hy _ns _sm _xs _yx _yz _zj`. Mỗi cái gần như chắc chắn là một loại đan khác màu. **Đây là bộ icon đan dược generic tốt nhất trong cả mod.**

### 2.2 Đan dược theo bậc/công thức — `xd_dy_*` (57 file) ⭐ TÁI SỬ DỤNG CHỌN LỌC

Đặt tên dạng `xd_dy_<tên4chữ>_1..5.png` — tức **11 loại đan, mỗi loại 5 bậc phẩm chất** (cyfxd, dmhsd, hsphd, lmsqd, pshsd, qjqsd, qxdhd, tsfhd, xttyd, xynyd, yfsxd) + vài file lẻ (`xd_dy_fd`, `xd_dy_tsfhd`).

| File mẫu đã xem | Mô tả |
|---|---|
| `xd_dy_cyfxd_1.png` … `_5.png` | Cùng một viên đan lửa cam-vàng xoáy, **5 file gần như giống hệt nhau** — khác biệt phẩm chất chỉ ở chi tiết hào quang rất nhỏ. |

Nhận xét: vì mỗi loại lặp 5 bậc gần giống nhau, **dùng được nhưng dư thừa** cho mod không có 5-bậc-phẩm-chất. Lấy bậc 1 hoặc 5 làm icon đại diện là đủ.

### 2.3 Linh thạch — `xd_lingshi1..4` (4 file) ⭐ ƯU TIÊN TÁI SỬ DỤNG

| File | Mô tả |
|---|---|
| `xd_lingshi1.png` | Viên đá quý lục giác **xanh dương** cắt mặt, có vạch sáng dọc. Đẹp, như tiền tệ tu tiên. |
| `xd_lingshi3.png` | Cùng dáng nhưng **cam/đỏ** (viền nâu). |
| `xd_lingshi2/4` | Biến thể màu khác (chưa xem, suy ra theo cặp). |

Đây chính là "linh thạch" (tiền tệ tu luyện). 4 màu = 4 phẩm cấp. **Dùng được ngay làm tiền tệ/tài nguyên trong mod ta.**

### 2.4 Linh thảo / cây trồng — `xd_flower_*` (13) + `xd_lc_*` (12) ⭐ TÁI SỬ DỤNG

- `xd_flower_*` = linh hoa/dược thảo. `xd_flower_md.png`: chậu bonsai hoa mẫu đơn hồng — rất "linh dược". `xd_flower_sfr.png`: cây nắp ấm/hoa ăn thịt xanh-trắng, kiểu thực vật yêu dị.
- `xd_lc_*` = cây trồng (linh điền) + hạt giống: mỗi loại có cặp `x_lc_<x>.png` (cây trưởng thành) và `xd_lc_<x>_seed.png` (hạt). `xd_lc_cyh.png`: bụi lửa cam mọc lên; `xd_lc_cyh_seed.png`: cụm hạt-tinh thể cam.

Sáu loại cây: cyh, dms, hsc, lmg, qfx, yhh (mỗi loại 1 cây + 1 hạt). **Tốt cho hệ thống trồng linh thảo.**

### 2.5 Lò luyện đan & công cụ chế tác

| File | Mô tả |
|---|---|
| `xd_liandanlu.png` | **Lò luyện đan**: đỉnh/vạc đồng xanh cổ, hai đầu rồng hai bên, lõi phát sáng. Rất biểu tượng. ⭐ |
| `xd_infobook.png` | Sách bìa xanh đóng gáy đồng — "công pháp / sổ tay". |
| `xd_huapen.png`, `xd_stool.png` | Chậu hoa, ghế đẩu (đồ nội thất). |

### 2.6 Pháp bảo & vũ khí theo nhân vật (đặc thù — giá trị thấp với mod ta)

| Cụm | Số | Ví dụ đã xem |
|---|---:|---|
| `xd_htz_*` (Hàn Thiên Tôn) | 7 | `xd_htz_tlz.png`: vòng/khiên xoáy vàng-đen hình tròn (pháp bảo). |
| `xd_wmz_*` (Vương Ma Tử) | 13 | md1..md8 (8 biến thể "ma đao"), tnz, slxj, xsj, zhf… |
| `xd_sudaji_*` (Tô Đát Kỷ) | 15 | `xd_sudaji_redlantern.png`: đèn lồng đỏ-vàng; soul, yhly, sjpn… |
| `xd_yunxiao_*` (Vân Tiêu) | 9 | hyjd (Hỗn Nguyên Kim Đẩu), fls, fysz… |
| `xd_sj_*` (Thạch Cơ) | 13 | bglxp, bgygp (bàn bát quái), kls, tej, by/cy (pet)… |
| `xd_luoshen_*` (Lạc Thần) | 12 | dinghunxianglu, huaxia, krss… |
| `xd_jingwei_*` (Tinh Vệ) | 5 | fan, blowdart, hat… |
| `xd_wukong_*` (Ngộ Không) | 2 | jgb (gậy), dsmo. |

Vũ khí dùng chung đáng chú ý:
- `xd_jgb.png`: **Gậy Như Ý** — gậy dài đỏ-vàng có đai kim loại hai đầu. Đẹp, generic-ish.
- `xd_wxj.png`: **kiếm cánh lông vũ** trắng-bạc lưỡi đôi rất hoành tráng. Có thể tái dùng làm pháp kiếm.
- `xd_tianji_lingpai.png`: lệnh bài/bùa hình khiên xanh ngọc + tua rua. Generic "tín vật". ⭐

### 2.7 Skin nhân vật — `xd_skin_*` (44 file)

Icon skin (cho hệ thống đổi trang phục nhân vật của mod gốc). Đặc thù nhân vật, **bỏ qua** với mod ta.

### 2.8 Các cụm khác trong inventory

- `xd_tree_*` (10): icon gỗ/lá/quả của cây tu tiên (df, ls, xhs, yhs, yls, yxs) — một số có skin.
- Đồ nội thất/turf: `turf_xdtile1..3`, `turf_jingweitile`, `fence_luoshen_*`, `wall_luoshen_*`, `xd_stool`, `xd_huapen`.
- Nguyên liệu lặt vặt: `xd_longzhu` (long châu), `xd_xuanyu`, `xd_qianyu`, `xd_spider_leg`, `xd_shatangshunut`…

---

## 3. Skill icons (`images/skills/`, 8 file)

Đây phần lớn là **atlas** (nhiều icon ghép trong 1 ảnh), không phải 1 icon/file.

| File | Mô tả |
|---|---|
| `xd_spell_icons.png` | **8 icon phép thuật** tròn nền xanh, mỗi cái lồng trong **bông tuyết băng** lớn (kết tinh, túi đồ, sao, sét, bướm, rồng nước, khói, ốc/mưa). Đây là skill hệ băng — đẹp, kiểu DST. |
| `xd_wukong_bsicons.png` | Atlas ~30+ medallion tròn viền vàng/bạc: hình thú, mặt khỉ, các pháp bảo. Skill tree Ngộ Không. |
| `xd_htz_skillicon.png` | ~15 medallion tròn viền (xám = chưa mở, màu = đã mở), hoa văn lá/sét. Skill tree Hàn Thiên Tôn. |
| `xd_wmz_skillicon.png` | 8 medallion khung "ma" gai đỏ-đen dữ tợn, bên trong là quái/sét/nhân vật tóc bạc. Skill tree Vương Ma Tử. |
| `xd_luoshen_shentong_life_hit.png` / `_death_hit.png` | Dải **cánh hoa rơi** cam-đỏ (sprite-sheet hiệu ứng đòn đánh), không phải icon. |
| `mini_noise_xdtile1..3.png` | Texture noise cho minimap tile (3 file) — không phải skill. |

Nhận xét: skill icon đều **đặc thù nhân vật** + dạng atlas → khó tách dùng. Riêng `xd_spell_icons.png` (8 phép băng generic-ish) có thể tách icon lẻ làm placeholder kỹ năng.

---

## 4. Map / minimap icons (`images/map_icons/`, 78 file)

Icon nhỏ hiển thị trên bản đồ. Cùng phong cách icon túi đồ nhưng đơn giản hơn.

| Nhóm | Ví dụ | Mô tả |
|---|---|---|
| Cây/thực vật | `xd_tree_df.png` (cây phong lá đỏ rực), `xd_flower_*`, `xd_shatangshu*`, `xd_zuichunyan_*` (4 trạng thái: green/purple/burnt/stump) | Generic, dùng được. |
| Đá/khoáng | `xd_rock1..3`, `xd_lingshi`?, | Đá tài nguyên. |
| Công trình | `xd_liandanlu.png` (lò luyện đan thu nhỏ, vạc đồng xanh), `xd_jitan` (tế đàn), `xd_ziyunge`, `xd_pog_house`, `xd_ziyun_house` | ⭐ Generic công trình tu tiên. |
| Boss/NPC | `xd_sudaji`, `xd_wukong`, `xd_luoshen`, `xd_longtaizi`, `xd_hantianzun`, `xd_jingwei`, `xd_qwsk`, `xd_klxw` | Đặc thù — marker nhân vật/boss. |
| Pháp bảo/vật đặt | `xd_yunxiao_hyjd`, `xd_qljq`, `xd_choujiangji` (máy quay thưởng), `xd_shiji` | Đặc thù. |

Nhận xét: phần cây/đá/công trình generic dùng tốt làm marker; phần boss/NPC đặc thù bỏ qua.

---

## 5. Big portraits (`bigportraits/`, 22 file) + avatars + saveslot

### 5.1 Phát hiện quan trọng: `xd_<name>.png` là KHUNG RỖNG

- `xd_luoshen.png`, `xd_sudaji.png`, `xd_jingwei.png`, `xd_wukong.png` … (bản không hậu tố) đều chỉ là **khung chân dung DST màu xám rỗng** (núi + cây vẽ chì), KHÔNG có art nhân vật. Đây là portrait "trống" mặc định.
- Art nhân vật thật nằm ở biến thể **`xd_<name>_none.png`** (build cơ bản, xem mục 2.3 tài liệu kiến trúc).

| File mẫu đã xem | Mô tả |
|---|---|
| `xd_sudaji_none.png` | Chibi **Tô Đát Kỷ**: nữ ma tóc đen, tai cáo trắng, váy hồng-đen, cầm hoa hồng đỏ phát sáng. Khung gai đen. Rất đẹp. |
| `xd_wukong_none.png` | Chibi **Tôn Ngộ Không**: khỉ mặc giáp đỏ-vàng, vác gậy Như Ý, đứng trên mây vàng. |
| `xd_yunxiao_none.png` | Chibi **Vân Tiêu**: tiên nữ tóc xanh đậm, mũ phượng bạc-xanh, áo choàng xanh ngọc, cầm pháp bảo vàng. |

Biến thể skin: `xd_sudaji_qrsy`, `xd_sudaji_wcgz`, `xd_longtaizi_hysj`, `xd_wukong_ds`. Tổng 9 nhân vật + skin + khung rỗng = 22 file.

### 5.2 Avatars (`images/avatars/`, 27 file)

9 nhân vật × 3: `avatar_xd_<name>` (mặt tròn trong game), `avatar_ghost_xd_<name>` (bản ma xám), `self_inspect_xd_<name>`. Ví dụ `avatar_xd_sudaji.png`: icon mặt tròn nữ ma tóc đen tai cáo — sạch, dùng tốt làm HUD avatar **nếu** mod ta có nhân vật tương ứng.

### 5.3 Saveslot (`images/saveslot_portraits/`, 9 file)

1 ảnh/nhân vật cho ô lưu game.

Nhận xét chung: toàn bộ portrait/avatar đều **đặc thù nhân vật** → với mod **không nhân vật cố định** của ta, chỉ hữu ích nếu ta tái dùng đúng nhân vật đó, ngược lại bỏ qua. Tuy nhiên các khung rỗng `xd_<name>.png` và phong cách chibi có thể tham khảo để vẽ nhân vật mới.

---

## 6. UI / misc (`images/` gốc, 56 file) ⭐ PHẦN GIÁ TRỊ NHẤT CHO HUD

### 6.1 `xd_ui.png` — ATLAS HUD TU TIÊN TỔNG (load-bearing)

Một atlas lớn ~600×600 chứa gần như toàn bộ widget HUD tu luyện:
- **Cuộn giấy/scroll panel** (parchment) — nền sách công pháp.
- **Medallion cảnh giới**: huy hiệu tròn viền vàng treo dây, bên trong có biểu tượng giọt linh lực phát sáng (vàng/tím/xanh) — chính là medallion cấp `xd_level`/`xd_dtlevel` (xem kiến trúc). Có cả phiên bản treo lồng đèn.
- **Thanh tu vi / xuetiao bar**: thanh ngang dài nền nâu-đỏ (thanh tiến độ cảnh giới), + thanh có **rồng đen uốn lượn** trang trí hai bên.
- **Khung tab dọc** màu nâu-vàng có chữ Hán (熊麟子 / 天骄 …) — nhãn cảnh giới.
- Các nút bấm, khung ô item, biểu tượng hoa sen.

→ **Đây là nguồn vàng** cho HUD tu tiên generic: medallion cảnh giới + thanh tu vi + panel cuộn giấy. Tách sprite từ atlas này dùng làm placeholder HUD rất hợp lý.

### 6.2 Splash art boss (tranh thủy mặc)

| File | Mô tả |
|---|---|
| `xd_kunpeng_ui1.png` / `ui2` | Tranh **Côn Bằng**: thủy mặc màu xanh ngọc-vàng, sóng nước cuộn xoáy, mây núi. Phong cách tranh Trung Hoa, KHÔNG phải kiểu DST. Đẹp nhưng lệch phong cách icon. |
| `xd_luoshen_huaxia_ui.png` | Splash Lạc Thần. |
| `xd_qxdx_ui.png` | **Cửa hàng NPC** "phi dược thương mãi": khung tre xanh + lồng đèn, panel mua bán. ⭐ Generic shop UI. |

### 6.3 Trang sách bestiary — `xd_info_*` (40+ file)

- `xd_info_0.png`: trang sách giấy cũ mở đôi, viền chim hạc + mây — **template trang bestiary trống**. ⭐ Dùng tốt.
- `xd_info_ys_1..18`, `xd_info_dy_1..8`, `xd_info_lb_1..7`, `xd_info_xy_1..5`: các trang nội dung có **tranh minh họa quái/đan + chữ Hán mô tả**. Ví dụ `xd_info_ys_1.png`: 2 con thú thần (kỳ lân nai, phượng lửa) vẽ đẹp + text. Đặc thù nội dung mod gốc → tham khảo bố cục, không dùng trực tiếp.

### 6.4 Khác

- `xd_tab.png`: chữ Hán **「仙」(Tiên)** kiểu thư pháp DST — icon tab crafting. ⭐ Generic.
- `xd_spell_icons.png` (đã nói ở mục 3).
- `names_xd_<name>.png` (9 file): ảnh tên nhân vật thư pháp — đặc thù.
- `xd_back_xh_ui.png`, `xd_kunpeng_ui2.png`…

---

## 7. Khuyến nghị cho remake (Phàm Nhân Tu Tiên)

Bối cảnh quyết định: mod ta **KHÔNG có nhân vật cố định** → mọi thứ đặc thù nhân vật (portrait, avatar, skill medallion, pháp bảo cá nhân, tên nhân vật) giá trị thấp. Cần generic: đan dược, linh thạch, linh thảo, lò luyện đan, medallion cảnh giới, thanh tu vi/HUD.

### 7.1 Bảng quyết định theo nhóm asset

| Nhóm asset | File tiêu biểu | Placeholder? | Vẽ lại? | Bỏ? | Lý do (1 dòng) |
|---|---|:---:|:---:|:---:|---|
| Đan dược `xd_danyao_*` | `xd_danyao_hj/jq/bg` | ✅ Có | sau | | 16 viên đan đẹp, đa màu, generic — dùng ngay làm icon đan. |
| Đan theo bậc `xd_dy_*` | `xd_dy_cyfxd_1..5` | ✅ chọn lọc | | một phần | Mỗi loại lặp 5 bậc gần giống — chỉ lấy 1 đại diện, bỏ phần dư. |
| Linh thạch `xd_lingshi1..4` | `xd_lingshi1/3` | ✅ Có | | | 4 màu đá quý — tiền tệ tu tiên hoàn hảo, dùng ngay. |
| Linh thảo `xd_flower_*` | `xd_flower_md/sfr` | ✅ Có | | | Dược thảo/hoa generic, hợp hệ hái thuốc. |
| Cây trồng + hạt `xd_lc_*` | `xd_lc_cyh(+seed)` | ✅ Có | | | Cặp cây+hạt cho linh điền, generic. |
| Lò luyện đan `xd_liandanlu` | `xd_liandanlu` | ✅ Có | | | Vạc đồng rồng — biểu tượng luyện đan, dùng ngay. |
| HUD atlas `xd_ui.png` | `xd_ui` | ✅ Có ⭐ | sau | | Chứa medallion cảnh giới + thanh tu vi + panel — tách sprite làm placeholder HUD. |
| Tab thư pháp `xd_tab` | `xd_tab` (「仙」) | ✅ Có | | | Icon tab crafting kiểu DST, generic. |
| Lệnh bài/tín vật | `xd_tianji_lingpai` | ✅ Có | | | Bùa/lệnh bài generic. |
| Vũ khí pháp khí chung | `xd_jgb`, `xd_wxj` | ✅ tạm | nên | | Gậy/kiếm đẹp nhưng gắn IP (Gậy Như Ý) — dùng tạm rồi vẽ lại. |
| Trang bestiary trống | `xd_info_0` | ✅ Có | | | Template sách trống, viền hạc/mây — dùng làm popup mô tả. |
| Shop UI `xd_qxdx_ui` | `xd_qxdx_ui` | ✅ Có | | | Khung cửa hàng tre/lồng đèn generic. |
| Icon phép `xd_spell_icons` | `xd_spell_icons` | ⚠️ tách lẻ | | | 8 phép băng generic-ish; tách icon đơn làm placeholder skill. |
| Map icon cây/đá/công trình | `xd_tree_df`, `xd_rock*`, `xd_jitan` | ✅ Có | | | Marker minimap generic. |
| Skill medallion theo NV | `xd_htz/wmz/wukong_skillicon` | | | ✅ Bỏ | Atlas đặc thù nhân vật, khó tách, không hợp mod no-character. |
| Pháp bảo cá nhân | `xd_htz_*`, `xd_sudaji_*`, `xd_wmz_*`… | | nếu cần | ✅ phần lớn | Gắn chặt nhân vật/IP cụ thể; chỉ mượn vài cái dáng generic. |
| Big portraits `_none` | `xd_sudaji_none` | | tham khảo | ✅ Bỏ | Chibi đẹp nhưng là nhân vật cụ thể; tham khảo phong cách để tự vẽ. |
| Big portraits khung rỗng | `xd_luoshen.png` (rỗng) | ✅ Có | | | Khung chân dung DST trống — tái dùng làm khung cho nhân vật mới. |
| Avatars / saveslot | `avatar_xd_*` | | | ✅ Bỏ | Mặt nhân vật cụ thể, vô dụng nếu không tái dùng đúng NV. |
| Skin icons `xd_skin_*` | `xd_skin_jj` | | | ✅ Bỏ | Skin trang phục đặc thù nhân vật. |
| Splash art boss | `xd_kunpeng_ui1` | | tham khảo | ✅ Bỏ | Tranh thủy mặc lệch phong cách DST + gắn boss cụ thể. |
| Tên nhân vật `names_xd_*` | `names_xd_sudaji` | | | ✅ Bỏ | Thư pháp tên riêng, vô dụng. |
| Turf/fence/wall | `turf_xdtile*` | ✅ tạm | | | Texture nền/hàng rào generic, dùng tạm. |

### 7.2 Ghi chú pháp lý / lưu ý

- Toàn bộ là tài sản của tác giả mod gốc (薪人小黄、路障僵尸、吃不吃大肉丸子). **Chỉ dùng làm placeholder nội bộ trong lúc phát triển**, phải thay bằng art tự vẽ trước khi phát hành công khai.
- Asset gắn IP rõ (Gậy Như Ý / Ngộ Không / Tô Đát Kỷ / Côn Bằng…) tuyệt đối không giữ trong bản release.
- Phong cách DST (viền đen, tô phẳng, vân giấy) chính là cái nên **bắt chước về mặt phong cách** khi tự vẽ — đó là phần đáng học nhất.

---

*Đã xem trực tiếp ~28 file mẫu đại diện trải đều các nhóm; phần còn lại suy luận theo tiền tố + tài liệu kiến trúc.*

# Hướng phát triển server Thần Binh — ghi lại 09/09/2026

Ba ý tưởng đã bàn, **chưa bắt tay làm**. Ghi lại để không mất, kèm những
thứ đã tra được để lần sau khỏi tra lại.

Bối cảnh: world `than-binh-phu-an` chơi tới ngày ~700, người chơi đạt
~73.400 DPS, quái và boss không còn theo kịp.

---

## Sự thật đã tra được (đừng tra lại)

### Vanilla DST chỉ có ba điểm chuyển thế giới

Soi 4.030 file trong `scripts.zip`:

```
cave_entrance / cave_exit     mặt đất ↔ hang
oceanwhirlbigportal           xoáy nước, Master ↔ Caves (bản Waterlogged)
migration_portal              sang server khác
```

`SetCanUseMap(false)` chỉ xuất hiện 3 lần, **đều trong `prefabs/woodie.lua`**
(lúc hoá thú). Không mod nào trong 20 mod của server tắt bản đồ.

### Server chỉ có HAI shard

`_infra/dst-server-docker` nhánh `than-binh-phu-an`:
`server/config/` chỉ có `Master/` và `Caves/`.

→ "Thế giới riêng" mà user gặp khi nhảy vào vết nứt dưới hang **không phải
shard thứ ba**. Đó là **một vùng xa trên chính bản đồ hang**, chưa khám phá
nên minimap đen — cảm giác như bản đồ không mở được.

**Kết luận cho đấu trường:** dùng **vùng ẩn trên bản đồ hang**
(`Transform:SetPosition()`), KHÔNG dựng shard thứ ba. Shard thứ ba đòi sửa
`cluster.ini` + thêm container + thêm tiến trình — quá nặng cho ThinkPad.

### Cơ chế trần-mỗi-đòn của tác giả (quan trọng nhất)

```lua
hh_treasure_monster.lua:283
val = math.max(old_health - 1000, 0)   -- mỗi đòn trừ TỐI ĐA 1000 máu
```

Chỉ áp cho 2 con: `treasure_kps` (Krampus Siêu Cấp, 1 triệu máu) và Miêu Du
Siêu Cấp → đúng **1000 nhát** bất kể sát thương. Sát thương thật cũng bị chặn:
`DoHHDelta` (`hh_api.lua:199`) vẫn gọi `SetVal` nên đi qua hook.

Đây là lời giải đúng cho ARPG lệch thang: biến trận đấu từ **đua DPS** sang
**trụ được bao lâu**. Đáng mở rộng.

### Vì sao quái tụt lại (đo cụ thể)

```lua
hh_monster.lua:117   end_limit_num = math.min(add_limit, base_num + floor(ngày/12) + 1)
```
`add_limit` boss = 4 (thường) / 7 (khó) → **ngừng nhận dòng cường hoá từ ngày ~36–84**.

```lua
hh_config.lua:22-26  boss +50..100 máu/ngày (tuyến tính)
```
Ngày 700 → boss chỉ +35k–70k máu. Muốn trận 60 giây ở 73.400 DPS cần
**≈4.400.000 máu** → thiếu **63 lần**.

### Mảnh ghép vanilla dùng lại được

```
components/hounded.lua             hệ đợt tấn công, độ khó theo tuổi nhân vật
components/acidbatwavemanager.lua  quản lý wave theo đợt
prefabs/pighouse.lua               "dân làng" đã có sẵn
winona_catapult                    tháp phòng thủ + pin + dây điện
beefalo thuần hoá                  chăn nuôi đã có
```

---

## Ý 1 — Đấu trường vô tận  ⭐ làm trước

Thay hẳn bù nhìn đo Chiến lực. Đo cùng thứ nhưng chân thực hơn: sát thương,
chịu đòn, và cả kỹ năng né.

**Thiết kế:**

```
Đợt n:  máu quái      = base × 1.35^n         (cấp số nhân)
        trần mỗi đòn  = f(Chiến lực) ÷ n      ← chìa khoá, mở rộng cơ chế của tác giả
        số dòng cường hoá = n, KHÔNG chặn trần
```

Đợt sau không thể one-shot dù mạnh cỡ nào → **đến một mức phải bỏ cuộc**,
đúng ý user. Kỷ lục ghi "tới đợt bao nhiêu" thay cho con số Chiến lực.

**Vào/ra:** vùng ẩn trên bản đồ hang, `Transform:SetPosition()`. Phải tự chặn
người chơi đi bộ ra khỏi vùng.

**Vì sao làm trước:** một công ba việc — sửa được vấn đề cấp bách, dựng nên
cỗ máy sinh-quái-theo-đợt mà ý 2 cần, và thay được bù nhìn.

## Ý 2 — Thủ thành

Cùng một cỗ máy với ý 1: sinh quái theo đợt, khó dần, có mục tiêu phải bảo vệ.
Đấu trường bảo vệ **bản thân**, thủ thành bảo vệ **cái làng**. Làm xong ý 1 thì
ý 2 rẻ đi rất nhiều.

Nội dung: chăn nuôi sinh vật thân thiện, NPC dân làng, xây làng, chống các đợt
tấn công.

**Rủi ro thiết kế đã nhận ra:** DST là game sinh tồn phi tuyến, người chơi đi
lang thang. Thủ thành đòi ở yên đúng lúc. Wave tới mà cả đội đang ở hang thì
làng tan — loại thất bại gây ức chế chứ không vui.
→ **Để người chơi tự bấm bắt đầu đợt**, đừng ép theo lịch.

## Ý 3 — Nhân vật Thợ Rèn (mod RIÊNG)

Trong 20+ nhân vật vanilla **không ai có vai trò chế tác**. Gần nhất là Winona
(chế nhanh) và Warly (nấu ăn) — không ai *biến đồ người khác thành đồ tốt hơn*.
Trong server ARPG chạy đồ thì đây là vai hợp thể loại nhất còn trống.

**Làm nhân vật riêng, KHÔNG làm class trong Thần Binh.** Nhân vật là thứ cách
ly tốt nhất trong DST: không đụng bảng dữ liệu mod nào, không sợ tác giả Thần
Binh cập nhật đè, đăng Workshop riêng được. Làm class bên trong Thần Binh là
cắm vào hệ thống nghề dang dở của người khác.

**Trục thiết kế (chất liệu manga thợ rèn, hợp DST):**
- **Lò và lửa** — sức mạnh phụ thuộc nguồn nhiệt. DST đã có lò, hố lửa, dung
  nham dưới hang → tự nhiên sinh ra vòng lặp xây dựng.
- **Búa vừa là công cụ vừa là vũ khí** — đánh quái yếu, đập vào *trang bị* mạnh.
- **Đồ ký tên** — Thần Binh đã cắm sẵn móc `components/hh_smith_equip.lua`:
  nó hook đè `SetName` của component `named` (*"干掉命名组件 防止其他mod改名字"*)
  nhưng `GetName()` chỉ `return "名字"`. Móc có sẵn, thiếu nội dung.
- **Đánh đổi** — rèn tốn máu/tinh thần, rèn hỏng thì mất đồ.

**Nên viết design doc trước khi viết code** — đúng như tác giả Thần Binh đã làm
trong `vendor/job/hh_job_text.lua`.

### Phụ lục: ý đồ gốc của tác giả Thần Binh về nghề rèn

`vendor/job/hh_job_text.lua` là **bản thiết kế viết trong chuỗi Lua**, không nơi
nào đọc. Tóm tắt phần Thợ Rèn:

- 6 bậc phẩm chất trang bị: 凡铁 Phàm Thiết → 精钢 Tinh Cương → 秘银 Bí Ngân →
  陨星 Vẫn Tinh → 龙魂 Long Hồn → 天铸 Thiên Chú
- 5 cấp bậc, mỗi cấp có câu tả nghề
- 7 loại nhiệm vụ (thu thập / nộp trang bị / rèn đồ đặc biệt / dây chuyền /
  ẩn — mở khi thiện cảm NPC đạt 1000 / thăng cấp / ăn cơm)
- 5 NPC, mỗi người một vai (mã chỉ có 2)
- Trang bị mang kỹ năng bị động + chủ động qua vòng chuột phải
- Bản vẽ đặc biệt dùng một lần, rơi từ tinh anh/boss
- Năng lực định danh: **ghi lại tên người rèn + cho tự đặt tên món đồ**

Còn có 光明牧师 (Mục Sư Ánh Sáng) thiết kế đủ 16 bị động + 20 chủ động, và hai
nghề bị chú thích trong `hh_job_ui.lua`: 光环骑士 (tank hào quang) và 猪猪骑士
(nghề ẩn, 眷顾人: 知非).

Tác giả **tắt hẳn** hệ thống nghề trong `modmain.lua:15-19` — chỉ còn
`hh_job_rpc.lua` chạy. 19/95 hàm rỗng, và 100% hàm quyết định lối chơi đều rỗng.
Lý do có lẽ là **phạm vi quá lớn**, không phải vì lỗi.

---

## Thứ tự đề nghị

1. Đấu trường vô tận
2. Thủ thành (tái dùng cỗ máy của 1)
3. Nhân vật Thợ Rèn (mod riêng, làm song song lúc nào cũng được)

**Không thêm mod nội dung thứ 10.** Server đã có 9 mod nội dung nặng + 9 mod
tiện ích, và nhánh `fix/mod-conflicts-workshop-patches` sinh ra chính vì hai mod
Workshop làm sập server. Vấn đề không phải thiếu đồ để cày, mà thiếu thứ đủ sức
đánh lại.

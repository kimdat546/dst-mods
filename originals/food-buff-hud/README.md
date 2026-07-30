# Food Buff HUD

Hiện buff từ thức ăn đang có tác dụng + đếm ngược **chính xác**, để biết đúng lúc cần ăn tiếp.

## Vì sao phải chạy ở server

Thời gian còn lại của buff **chỉ tồn tại phía server**. Đã kiểm trong source game:

- `components/debuffable.lua`, `components/debuff.lua`, `components/timer.lua` — **không có replica, không netvar**
- Client không có đường nào đọc được

Nên mọi mod buff-timer *chỉ chạy phía client* buộc phải hardcode thời lượng từ `TUNING`
rồi tự đếm nhẩm. Cách đó sai trong ba tình huống: buff được **gia hạn** (ăn thêm món),
**vào server giữa lúc buff đang chạy**, và **server lag**.

Mod này đọc số thật ở server rồi gửi xuống, nên không có tình huống nào sai.

## Cơ chế buff của game (đã tra source)

Mỗi buff là một entity gắn vào người chơi, đếm bằng component `timer`, timer tên `"buffover"`:

```lua
-- prefabs/foodbuffs.lua
MakeBuff("attack", ..., TUNING.BUFF_ATTACK_DURATION, 1)
  OnAttached:  inst.entity:SetParent(target.entity)
  OnExtended:  timer:StopTimer("buffover"); timer:StartTimer("buffover", duration)
```

Thời gian còn lại thật:
```lua
player.components.debuffable.debuffs[key].inst.components.timer:GetTimeLeft("buffover")
```

## Điểm chống mục ruỗng

Mod **không hardcode danh sách buff**. Nó duyệt `debuffable.debuffs` và đọc timer
`"buffover"` → tự động phủ **mọi** buff dùng cơ chế `MakeBuff`, kể cả món Klei thêm
về sau. Buff lạ chưa có tên tiếng Việt vẫn hiện, chỉ là tên thô hoá
(`buff_foo_bar` → "Foo bar") chứ không bị ẩn.

So sánh: hai mod "Buff Timer" trên Workshop (`2630628898`, `2905304624`) hardcode
58–80 entry, còn nguyên dòng `-- TODO: acid healing salve`. Tác giả cập nhật lần cuối
**2024-03**, và đó là lý do chúng không còn dùng được.

### Đã phủ

Mọi buff dựng bằng `MakeBuff`: `attack`, `playerabsorption`, `workeffectiveness`,
`moistureimmunity`, `electricattack`, `sleepresistance`, `sleepimmunity`,
`firefrenzy` (than Willow) — tức toàn bộ món Warly và món nêm gia vị
(ớt→attack, tỏi→playerabsorption, đường→workeffectiveness).

### CHƯA phủ

Hiệu ứng **không** dùng `MakeBuff` nên phải xử lý riêng từng cái:
jellybean (hồi máu), wormlight (phát sáng), trà, elixir của Wendy.
Muối cũng không tạo buff — nó chỉ `+25% HEALTH` của chính món ăn
(`TUNING.SPICE_MULTIPLIERS.SPICE_SALT`), thuộc phần "hiện hiệu ứng TRƯỚC khi ăn"
(chưa làm).

## Kiến trúc

```
SERVER  quét debuffable mỗi 1s → đọc timer "buffover" → gửi RPC xuống client đó
        gửi khi tập buff ĐỔI, khi buff được GIA HẠN (ăn thêm), + heartbeat 5s
CLIENT  nhận RPC → tự trừ dần tại chỗ (không tốn băng thông) → vẽ HUD
```

Dùng **RPC** chứ không netvar: netvar cần khai báo khớp hai phía, RPC thì không.
Nhờ vậy sau này muốn tách bản client riêng cũng không phải sửa gì ở tầng dữ liệu.

## Đóng gói

`all_clients_require_mod = true` — client **tự tải** khi vào server (mod tạm, không
thêm vào danh sách sub của họ). Người chơi không cần cài trước, không bị chặn.

`version_compatible = "1.0.0"` — client cũ/mới đều vào được miễn `>=` mốc này.
Chỉ nâng khi đổi định dạng RPC theo cách không tương thích, lúc đó chặn mới là đúng.
Không khai trường này thì game so khớp **tuyệt đối**, lệch một chữ số là client bị đá
(`modindex.lua:1255`).

## HUD

- Có buff tự hiện, hết buff tự ẩn
- Sắp xếp theo thời gian còn lại **tăng dần** — cái sắp hết nằm trên
- Dưới ngưỡng cảnh báo (mặc định 30s) thì đổi màu đỏ nhạt
- **Giữ chuột phải kéo** để đổi vị trí, thả ra tự lưu qua `TheSim:SetPersistentString`

Neo `ANCHOR_TOP` + `ANCHOR_LEFT`, mặc định lệch `(60, -120)` từ góc trên-trái — vùng
thường trống, tránh inventory (giữa dưới), status/minimap (phải dưới), đồng hồ (phải trên).
Đè mod khác thì giữ chuột phải kéo là xong.

⚠ **KHÔNG** lấy `pham-nhan/scripts/widgets/pn_hud_dantian.lua` làm mẫu — mod đó chưa chạy
được và thiếu `SetVAnchor`/`SetHAnchor`. Mẫu đúng: `workshop-2905304624` Buff Timer (client).

## Trạng thái

**v1.0.0 — đã test chạy được trên game thật** (2026-07-30): HUD hiện, đếm ngược đúng,
ăn thêm món cùng loại thì số reset ngay, kéo thả bằng chuột phải lưu được vị trí.
Selftest headless PASS 14/0.

### Ba lỗi đã sửa trong quá trình test

1. `modmain` chạy trong env sandbox, không có `rawget`/`tonumber` → phải gọi qua `_G.`
2. Server không người chơi thì `Sim paused`, `DoTaskInTime` không nổ → dùng `DoStaticTaskInTime`
3. **Widget HUD phải neo** bằng `SetVAnchor`/`SetHAnchor`, nếu không thì trôi ra ngoài
   màn hình dù đặt toạ độ nào. Xem `pham-nhan-tu-tien/docs/analysis/dst-hud-widgets.md`.

## Chưa làm

- Phần B: hiện hiệu ứng **trước khi ăn**, ngay trên món ăn (gồm cả muối +25% HEALTH)
- Icon cho từng buff (hiện chỉ có chữ)
- Các hiệu ứng không dùng `MakeBuff` (xem trên)

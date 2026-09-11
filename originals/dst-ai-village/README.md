# AI Làng

Dân làng NPC có não, sống và làm việc cùng người chơi thật trong Don't Starve
Together.

Viết mới hoàn toàn. Có tham khảo ý tưởng từ hai mod MIT là
[hineios/FAtiMA-DST](https://github.com/hineios/FAtiMA-DST) (2018) và
[votus777/DST-AICompanion](https://github.com/votus777/DST-AICompanion) (2024),
nhưng **không dùng lại mã của chúng** — lý do ở ngay dưới.

## Vì sao không dùng lại hai mod cũ

Cả hai đều tách đôi: thân xác là mod Lua trong game, bộ não là một app C# chạy
ngoài, nói chuyện với nhau qua **HTTP tới `localhost:8080`** bằng
`TheSim:QueryServer`.

Đo trên DST bản **11/09/2026**, kiến trúc đó không còn chạy được:

| Thứ đã đo | Kết quả |
|---|---|
| `TheSim:QueryServer` tới `http://<ip>:8080` | callback **không bao giờ nổ** |
| `TheSim:QueryServer` tới `https://api.github.com` | callback **không bao giờ nổ** |
| Thử trên server offline | không nổ |
| Thử trên server online đang có người chơi | không nổ |
| Đối chứng: `DoTaskInTime(2)` | nổ đúng 2,00 giây — sim vẫn chạy bình thường |

Klei đã khoá `QueryServer` lại cho endpoint của họ. Đây không phải lỗi cấu hình
mạng — cùng lúc đó `curl` từ trong container gọi tới dịch vụ vẫn thông.

Ngoài ra:

- `FAtiMA-Server.exe` là **.NET Framework 4.6.1**, và `WebServer.cs` mở đầu
  bằng `if (!HttpListener.IsSupported) throw new NotSupportedException("Needs
  Windows XP SP2...")`. Server là Linux trong Docker.
- votus777 chỉ ship DLL/EXE đã biên dịch. hineios có mã nguồn C# nhưng chỉ
  **915 dòng** — thuần một lớp vỏ HTTP, trí tuệ nằm trong FAtiMA-Toolkit.
- `modmain.lua` của DST-AICompanion bật `CHEATS_ENABLED = true` và
  `require 'debugkeys'`. Mã nghiên cứu, không đưa lên server công khai được.

Thứ đáng giá còn lại là **ý tưởng**: spawn prefab người chơi làm NPC, và tách
"phản xạ" khỏi "suy nghĩ". Cả hai đều giữ ở đây, phần còn lại viết lại.

## Kiến trúc

```
        DST server (Lua, trong tiến trình)          Dịch vụ suy nghĩ (Python)
  ┌──────────────────────────────────────┐      ┌─────────────────────────────┐
  │ danlangbrain.lua                     │      │ tam_tri.py                  │
  │   behaviour tree — PHẢN XẠ           │      │   quét thư mục save         │
  │   chặt / hái / nhặt / đánh / chạy    │      │                             │
  │   ăn / theo người / lang thang       │      │ backends/                   │
  │   ↑ luôn chạy, không cần mạng        │      │   luat    (mặc định)        │
  │                                      │      │   gemini                    │
  │ cau_noi.lua                          │◄────►│   cuc_bo  (Ollama)          │
  │   SetPersistentString  (hỏi)         │ FILE │                             │
  │   GetPersistentString  (nghe)        │      └─────────────────────────────┘
  └──────────────────────────────────────┘
```

Hai tầng tách hẳn nhau, và đó là điểm chính:

- **Tầng phản xạ** chạy thẳng trong game. Tắt dịch vụ, mất mạng, hết quota
  Gemini — dân làng vẫn sống và làm việc.
- **Tầng suy nghĩ** chỉ **đặt mục tiêu** (`inst.ailang.muc_tieu`) và **câu
  thoại**. Nó không điều khiển từng bước đi, nên độ trễ vài giây không sao.

Đi bằng **file** chứ không phải HTTP, vì `QueryServer` đã chết (xem bảng trên).
`TheSim:SetPersistentString` / `GetPersistentString` thì chạy tốt, đã kiểm cả
hai chiều kể cả tiếng Việt có dấu. `io.open` **không dùng được** — DST chặn,
trả `invalid filepath`.

## Ba điều đã đo về prefab người chơi làm NPC

Dân làng là prefab người chơi thật (`wx78`, `wilson`, ...) spawn ra mà không có
ai điều khiển. Nhờ vậy nó mặc được giáp, cầm được vũ khí, ăn được mọi thứ —
quan trọng với server mà đồ đạc là cốt lõi. Nhưng có ba cái bẫy:

1. **Nó tự đăng ký vào `AllPlayers`** (0 → 1). Không gỡ ra thì mọi thứ đếm
   người chơi đều sai. `TheNet:GetPlayerCount()` vẫn = 0 nên server vẫn tự
   pause đúng — gỡ khỏi `AllPlayers` là đủ.
2. **`persists = false`** — prefab người chơi KHÔNG được lưu cùng world,
   restart là mất sạch. Nên thứ được lưu là **hồ sơ** trong component
   `ailangquanly` gắn trên `TheWorld`, và dân làng được dựng lại từ đó.
3. **Entity ngủ thì não không chạy.** `AddServerNonSleepable()` để cái làng
   sống tiếp lúc cả đội đang ở hang.

## Chạy

### Mod

Bỏ vào thư mục mod của server. Cấu hình trong `modoverrides.lua`:

```lua
["dst-ai-village"] = {
  enabled = true,
  configuration_options = {
    so_dan_lang = 2,
    bat_tam_tri = true,    -- false thì chỉ chạy não phản xạ
    nhip_suy_nghi = 15,
    muc_log = 1,
  },
},
```

Lệnh trong game:

```
c_ailang_soi()                -- ĐANG NGHĨ GÌ: lo nhu cầu nào, làm hành động
                              --   gì với mục tiêu nào, mang gì, túi có gì
c_ailang_kiem()               -- chạy cả 20 phép tự kiểm NGAY TRONG GAME
c_ailang_dem()                -- liệt kê gọn
c_ailang_them("Tí", "wx78")   -- thêm một dân làng ở chỗ mình đứng
c_ailang_datnha()             -- đặt nhà tại chỗ mình đứng
c_ailang_tiepte()             -- phát 2 cỏ + 2 cành cho cả làng
c_ailang_bang()               -- BẢNG: ai chế độ nào, thân bao nhiêu
c_ailang_theo("Tí")           -- đi theo mình (cần thiện cảm ≥ 70)
c_ailang_onha("Tí")           -- ở nhà
c_ailang_tudo("Tí")           -- làm việc quanh nhà (mặc định)
c_ailang_goi()                -- gọi cả làng tới chỗ mình và đặt nhà ở đây
c_ailang_cuu()                -- hồi sinh mọi hồn ma dân làng
c_ailang_giet("Tí")           -- giết một dân làng để xem cơ chế hồn ma
c_ailang_naplai()             -- nạp mã mới, không phải khởi động lại game
c_ailang_xoahet()
```

`c_ailang_soi()` là lệnh đáng dùng nhất khi muốn biết "nó có làm đúng không":
cây hành vi chạy trong im lặng nên nhìn bằng mắt thường rất khó đoán.

⚠ `c_ailang_kiem()` xoá sạch dân làng để dựng bản thử rồi **dựng lại làng của
bạn** ở cuối, và có đổi giờ trong ngày. Chạy lúc rảnh, đừng chạy giữa lúc đánh
boss. Nếu không có bước dựng lại đó thì cả làng biến mất vĩnh viễn —
`ChupTatCa` dựng bảng hồ sơ TỪ dân làng đang sống, mà lúc đó không còn ai.

### Dịch vụ suy nghĩ (tuỳ chọn)

```bash
cd tam-tri
cp .env.example .env      # chọn AILANG_NAO, điền AILANG_SAVE
docker compose up -d
```

`AILANG_SAVE` phải trỏ vào thư mục save của world — chỗ mod ghi
`ailang_hoi.json`. Với server trong Docker thì đó là
`<volume>/server/general/Master/save`.

Không có phụ thuộc nào: ảnh là `python:3.12-alpine` trần, toàn bộ mã chỉ dùng
thư viện chuẩn. Cố ý như vậy — hai mod cũ chết vì phụ thuộc.

## Chọn bộ não nào

| Bộ | Cần gì | Hợp với |
|---|---|---|
| `luat` | không gì cả | mặc định, và là lưới an toàn khi bộ khác hỏng |
| `gemini` | `GEMINI_API_KEY` | dân làng có mục tiêu riêng và biết trò chuyện |
| `cuc_bo` | một máy khác chạy Ollama | muốn chạy kín, không gọi ra ngoài |

**Đừng chạy model local trên chính con ThinkPad đang gánh server.** Đo ngày
11/09/2026: i5-8250U (4 nhân ULV 1,6 GHz), RAM 7,7 GB mà DST đã ăn 5 GB — chỉ
còn **2,7 GB trống**, GPU là UHD 620 không tính toán được. Nhét model vào đó là
tranh CPU với vòng lặp sim của DST. Muốn chạy local thì để ở máy khác rồi trỏ
`AILANG_URL` qua Tailscale.

## Vòng lặp sửa–thử

Trước đây mỗi lần sửa là: sửa mã → cài lại → **thoát hẳn DST** → mở lại → host
world → chơi. Hai bước giữa mất vài phút, mà một buổi có hàng chục vòng. Hai
công cụ dưới đây cắt gần hết chỗ đó.

### Nạp nóng — không phải khởi động lại game

```bash
./tools/sync_local.sh          # ghi mã mới vào thư mục mod của game
```
rồi trong game gõ:
```
c_ailang_naplai()
```

Nó xoá `package.loaded` của mọi mô đun rồi require lại từ đĩa, và gắn lại não
mới cho từng dân làng đang sống.

**Nạp nóng được:** `scripts/ailang/*`, `scripts/brains/*` — tức là cây hành vi,
cách chọn mục tiêu, hồn ma, ánh sáng, và cả các lệnh `c_ailang_*`. Đây là gần
như toàn bộ phần hay phải sửa.

**KHÔNG nạp nóng được:** `modmain.lua`, `modinfo.lua`, và component
`ailangquanly` trên `TheWorld`. modmain chạy một lần lúc world khởi động và
những gì nó đăng ký (`AddPrefabPostInit`, `AddSimPostInit`) không gỡ ra đăng ký
lại được. Sửa mấy file đó thì vẫn phải thoát game.

⚠ Thêm/xoá FILE thì luôn phải khởi động lại game — DST chỉ quét danh sách file
mod một lần lúc mở game.

### Server test cho NGƯỜI CHƠI vào được

```bash
./tools/test/keo_game.sh        # một lần, ~15 phút
cd tools/test && docker compose up -d
```
rồi trong DST: `c_connect("127.0.0.1", 11000)`

⚠ **Ảnh Docker không nhúng sẵn file game** — nó tải lúc chạy bằng steamcmd, mà
steamcmd là **ELF 32-bit** (EM_386) và Rosetta trên Apple Silicon **không chạy
32-bit**, nó segfault. Nên bản game trong ảnh đứng yên ở 726875 trong khi client
đã 747465, và người chơi nhận *"máy chủ ở phiên bản cũ hơn bạn"*.
`keo_game.sh` chép thư mục game từ server thật trên ThinkPad (x86_64 thật, tự
cập nhật được) về đây. 4,3 GB, ~5 MB/s qua Tailscale.

⚠ **Cổng phải trong [10998, 11018]** vì đây là cụm offline. Ngoài khoảng đó DST
không báo lỗi mà lặng lẽ tụt về 10999.

⚠ Mount thư mục game phải **đọc-ghi**. Mount `:ro` thì Docker không tạo nổi điểm
mount LỒNG cho mấy file mod bên dưới, container chết ngay lúc khởi tạo.

Vào được server này thì thế giới THỨC (có client thật), nên xem được đầy đủ
chuyển động và hành vi — thứ mà bộ tự kiểm không kiểm được.

### Tự kiểm — không cần người chơi

```bash
./tools/test/chay_tu_kiem.sh
```

Dựng server test SẠCH, xác nhận mod nạp được, rồi chạy `scripts/ailang/tu_kiem.lua`.
Hiện **20 phép kiểm**: nấm chưa mọc, ánh sáng ban đêm và hoàng hôn, mũ thợ mỏ,
hồn ma và hồi sinh, đánh trả, nấm độc, đi kiếm nguyên liệu, thứ tự ưu tiên.

⚠ Bộ kiểm để trong `scripts/` chứ KHÔNG mount riêng, vì hai lý do đã vấp phải:
  console DST có **giới hạn độ dài** (gộp một dòng chạm 10.402 ký tự là im
  lặng không chạy gì), và mount lồng vào trong `scripts` đang read-only thì
  container chết ngay lúc khởi tạo với "create mountpoint: read-only file
  system".

**Kiểm được:** logic chọn hành động — đúng chỗ hay sai nhất.
**KHÔNG kiểm được:** chuyển động, tìm đường, hoạt ảnh, cảm giác chơi. Mấy thứ
đó vẫn phải vào game thật.

⚠ Bộ này chạy tay `bt:Update()` chứ không để BrainManager chạy, vì khi không có
client nào nối vào thì DST **ngủ cả thế giới**. Đã đo ba lần:
`AddServerNonSleepable()` không cứu, nhét dân làng vào `AllPlayers` cũng không —
engine dùng client MẠNG thật. Đối chứng bằng heo vanilla: nó cũng ngủ, cũng
đứng im y hệt.

## Kiểm thử

`tools/test/` chạy server headless offline chỉ bật đúng mod này.

```bash
cd tools/test && cp test.env.example test.env && docker compose up -d
docker logs -f dst-ailang-test | grep ailang
```

**Kiểm được:** mod nạp sạch, dân làng sinh ra, gỡ khỏi `AllPlayers`, hồ sơ bền
qua restart, vòng file hai chiều với dịch vụ suy nghĩ, và cây hành vi chạy
không lỗi (chạy tay `bt:Update()`).

**KHÔNG kiểm được: hành vi thật.** Khi không có client nào nối vào, DST **ngủ
cả thế giới** — entity ngủ thì không chạy não. Đã đối chứng bằng heo vanilla:
nó cũng ngủ, cũng đứng im y hệt. Phần đi lại, chặt cây, đánh nhau phải vào game
thật mới xem được.

## Bảng nhu cầu sinh tồn

Dân làng quyết định làm gì bằng `scripts/ailang/nhu_cau.lua` — một bảng KHAI
BÁO, không phải nhánh `if` lồng nhau. Thêm nhu cầu mới chỉ là thêm một mục.

Thứ tự ưu tiên:

```
ánh sáng > đồ ăn > hồi máu > hồi não > vũ khí > giáp > nhà
```

Với nhu cầu cấp thiết nhất chưa thoả, `sinh_ton.lua` đi ba nước:

1. Có sẵn món ở bậc nào thì mặc/cầm món đó
2. Không có nhưng chế được thì chế
3. Không bậc nào làm ngay được thì **đi kiếm nguyên liệu còn thiếu** cho bậc
   rẻ nhất — đây là chỗ dân làng trông "biết tính" thay vì đi lang thang

Ví dụ ánh sáng có ba bậc `minerhat` → `lantern` → `torch`. Đầu game
`builder:CanBuild` trả false cho hai bậc trên vì thiếu Máy Giả Kim, nên tự tụt
xuống đuốc; thiếu cỏ thì đi tìm bụi cỏ, thiếu cành thì tìm bụi cây con.

### Cây công nghệ tự lo liệu

| bậc | cần gì | ví dụ |
|---|---|---|
| tech 0 | không cần gì | torch, campfire, armorgrass, researchlab |
| tech 1 | đứng gần Máy Khoa Học | rope, spear, armorwood, boards |
| tech 2 | đứng gần Máy Giả Kim | lantern, minerhat, footballhat |

`builder:CanBuild` tự xét cấp công nghệ nên **bậc cao tự rụng khi chưa đủ đồ
nghề**. Không phải viết điều kiện tay.

### Nguyên liệu lấy từ đâu

Đo từ `pickable.product` và bảng loot, không phải trí nhớ: `grass`→cutgrass,
`sapling`→twigs, `flower`→petals, `berrybush`→berries,
**`flower_cave`→lightbulb** (trái đèn để làm đèn lồng), cây→log,
đá→rocks/flint/goldnugget/nitre.

### Ăn uống

⚠ **ĐỪNG ăn bừa mọi thứ `eater:CanEat()`.** Giá trị thật đã đo:

| | máu | não |
|---|---|---|
| red_cap | **−20** | 0 |
| green_cap | 0 | **−50** |
| blue_cap | +20 | −15 |
| thịt sống | +1 | −10 |

Bản đầu ăn bất cứ thứ gì nên dân làng tự đầu độc mình bằng đúng con nấm vừa
hái. Giờ chấm điểm `no + máu×3 + não×2`, chỉ đụng món hại khi đói dưới 15%.

## Thiện cảm và chế độ — mượn mô hình Wurt ↔ merm

Wurt cho merm ăn thì merm kết thân và đi theo. Dân làng ở đây cũng vậy.

**Thiện cảm 0–100**, bắt đầu ở 50:

| | thay đổi |
|---|---|
| Cho ăn (thả đồ ăn lên dân làng) | **+10** |
| Cứu sống khi đang là hồn ma | **+20** |
| Tặng dụng cụ / vũ khí / giáp | +3 |
| Sống yên qua một ngày | +2 |
| Bị bỏ đói (dưới 25%) qua một ngày | −5 |
| **Bị chính người chơi đánh** | **−25** |

- Từ **70** trở lên mới chịu đi theo
- Dưới **15** thì nó nói *"Đủ rồi! Tôi không ở đây nữa."*

Cách cho ăn là thao tác vanilla: kéo món đồ thả lên dân làng. Chạy được mà
**không cần mod ở client** — dân làng có component `trader`, đúng cơ chế merm.
Nó chỉ nhận món có lợi: đưa nấm não −50 thì nó từ chối.

### Ba chế độ

```
c_ailang_bang()           -- bảng: ai đang chế độ nào, thân bao nhiêu
c_ailang_theo("Tí")       -- đi theo mình (cần thiện cảm ≥ 70)
c_ailang_onha("Tí")       -- ở nhà, không rời đi
c_ailang_tudo("Tí")       -- làm việc quanh nhà (mặc định)
```

Bỏ tên thì áp cho cả làng. Chưa đủ thân mà đòi theo thì nó báo còn thiếu bao
nhiêu.

⚠ Đây là "bảng setting" dạng **lệnh**, không phải giao diện. Giao diện thật đòi
phần chạy ở client, mà mod cố ý giữ server-only để không ai phải cài gì mới vào
được server — xem mục quyết định bên dưới.

### Vì sao KHÔNG đổi dân làng sang prefab kiểu merm/pigman

Đã đo, hai phép liền nhau cùng một nền:

| | CPU hơn nền |
|---|---|
| 20 heo vanilla thức | +11,8% |
| 20 dân làng (đã tắt não) thức | +13,9% |

Prefab người chơi chỉ đắt hơn heo khoảng **18%**. Đổi lấy chừng đó mà mất
`builder` (heo và merm **không chế tạo được**), mất mặc giáp, mất cầm vũ khí
bất kỳ thì không đáng. Thứ đáng mượn từ merm là **quan hệ**, không phải prefab.

Chi phí thật: **≈0,9% CPU mỗi dân làng thức**, RAM không tăng. Đòn bẩy nằm ở
số dân làng thức cùng lúc, không ở loại prefab.

## Dân làng KHÔNG ngủ — và bài học về việc dùng sai hàm

Entity DST "ngủ" khi không có người chơi ở gần, và entity ngủ thì **không chạy
não** — não dừng là mất luôn việc đang làm dở.

Dân làng ở đây dùng `inst.entity:SetCanSleep(false)` nên **vẫn sống và vẫn làm
việc kể cả khi không có ai trong world**.

⚠ **Đã từng kết luận nhầm là "engine không cho ép thức".** Sai ở chỗ dùng **sai
hàm**: `AddServerNonSleepable()` không có tác dụng gì. Đo lại, không có người
chơi nào trong world:

| | ngủ? | não |
|---|---|---|
| heo vanilla, không làm gì | ngủ | không |
| heo + `SetCanSleep(false)` | **thức** | **chạy** |
| dân làng, chỉ có `AddServerNonSleepable()` | ngủ | không |
| dân làng + `SetCanSleep(false)` | **thức** | **chạy** |

Hai điều kiện phải nhớ:

- Gọi lúc entity **còn thức** (ngay sau khi spawn). Gọi lên entity đã ngủ rồi
  thì vô hiệu — đó là lý do lần thử đầu thất bại.
- **Cái giá: ≈0,9% CPU mỗi dân làng, liên tục**, kể cả lúc không ai xem. Đo
  được 20 dân làng thức tốn thêm ~18% CPU. Cân nhắc trước khi tăng số dân.

## Sống, chết, và hồn ma

Dân làng **chết thật**. Không có hồi sinh tự động.

**Ban ngày** chúng làm việc bình thường. **Chập tối và ban đêm**, nhánh ánh sáng
được ưu tiên trước mọi việc khác, vì không có sáng là chết:

1. Đang cầm đuốc còn nhiên liệu → xong
2. Có đuốc trong túi → cầm lên
3. Chế được đuốc (2 cỏ + 2 cành) → chế rồi cầm
4. Dựng được lửa trại (3 cỏ + 2 gỗ) và quanh đó chưa có lửa → dựng
5. Hết cách → bám lấy đống lửa gần nhất trong bán kính 60

⚠ **Không dùng `LightWatcher` để biết tối hay sáng.** Đã đo trên dedicated
server: `IsInLight()` trả `true` cả khi đứng giữa đêm không cầm gì, và
`GetTimeInDark()` đứng yên ở 0. Ánh sáng là thứ client vẽ — `inst.Light` phía
server cũng `nil` cho cả đuốc lẫn lửa trại. Nên điều kiện ở đây là
`TheWorld.state.isnight or isdusk`, vừa đáng tin vừa khiến dân làng chuẩn bị
TRƯỚC khi trời tối hẳn.

**Khi chết** dân làng thành hồn ma:

- Ngừng mọi việc thu thập — đã chết thì không đi hái quả nữa
- Đồ rơi lại tại chỗ, **vị trí chết được ghi vào hồ sơ**
- Mang tag `notarget` nên quái thôi nhắm tới, và bất tử nên không chết lần nữa
- Đi tìm chỗ hồi sinh trong bán kính 60: bia đá, tượng thịt, hoặc dây chuyền
  hồi sinh nằm dưới đất — cả ba đều mang chung tag `resurrector`
- Không tìm thấy gì thì **đứng yên chỗ chết** chờ người chơi tới cứu, thay vì
  lang thang khắp bản đồ
- **Kêu lên** lúc chết và cứ 20 giây một lần, để người chơi biết nó là gì và
  cần gì. ⚠ Không có phần này thì người chơi chỉ thấy "một Wendy mờ đứng im,
  giống hồn ma nhưng không hiện giống hồn ma" — đã xảy ra thật. Hồn ma tự dựng
  không có hình dạng hồn ma của engine nên PHẢI tự nói ra mình là gì
- Hồi sinh xong: 50% máu, rồi tự quay lại chỗ chết nhặt lại đồ của mình

⚠ **Không dùng được hồn ma thật của engine.** `inst:SetGhostMode(true)` có tồn
tại nhưng nổ ngay: `player_common.lua:957 attempt to index field 'HUD'` — nó đòi
HUD của client, mà dân làng không có ai điều khiển nên không có HUD. Trạng thái
hồn ma ở đây là tự dựng: vẫn cùng một entity, chỉ đổi màu, gỡ khả năng đánh
nhau, và cắm cờ cho cây hành vi rẽ nhánh. Hệ quả: người chơi **không** dùng dây
chuyền lên hồn ma dân làng được như với người chơi thật — nhưng hồn ma tự đi
tới chỗ dây chuyền rơi và dùng nó.

## Quyết định: dân làng KHÔNG hiện trong tab người chơi

Đã chốt 11/09/2026, **giữ mod chỉ chạy phía server**. Ghi lại để khỏi bàn lại.

Tab người chơi dựng từ `TheNet:GetClientTable()`. Đã đo: bảng đó **dựng lại mới
mỗi lần gọi**, nên thêm mục từ phía server là vô ích — sửa xong gọi lại là mất.
Đường duy nhất là móc widget `PlayerStatusScreen` ở **phía client**, mà làm vậy
thì `all_clients_require_mod` phải bật và ai vào server cũng phải tải mod.

Đổi lại được gì nếu giữ server-only:

- Người chơi không phải cài gì
- Dân làng vẫn là nhân vật thật: mặc giáp, cầm vũ khí, ăn cơm
- Vẫn nói chuyện được — `talker:Say()` chạy qua mạng, không cần mod ở client
- Vẫn xem được bằng `c_ailang_dem()`

Mất: không có tên nổi trên đầu, không hiện trong tab.

**Và dù có làm phần client thì cũng KHÔNG đưa dân làng trở lại `AllPlayers`.**
Đã đo: có mặt trong `AllPlayers` làm sai mọi thứ đếm người chơi, và mọi mod
chia máu boss theo đầu người — như Thần Binh Phù Ấn trên server — sẽ tính sai
theo. Nếu sau này muốn hiện trong tab thì đó phải là thay đổi **chỉ ở phần
hiển thị**.

## Còn phải làm

- ~~Vào game thật xem dân làng có thật sự đi lại và làm việc không.~~ Đã xác
  nhận 11/09/2026: đi lại, nhặt đồ, thu thập tài nguyên đều chạy.
- Tự chữa thương. Hiện dân làng không có cách nào hồi máu ngoài ăn.
- Chủ động gom cỏ và cành BAN NGÀY để chắc chắn có nguyên liệu làm đuốc. Giờ
  chúng chỉ nhặt được gì thì nhặt, gặp đêm mà tay trắng thì vẫn kẹt.
- `modicon.tex/.xml` (đang cảnh báo lúc nạp, vô hại).
- Nghề nghiệp: hiện mọi dân làng dùng chung một cây hành vi.
- Trí nhớ dài hạn cho tầng suy nghĩ (giờ mỗi nhịp là một lần hỏi độc lập).
- Nối với ý "thủ thành" trong `docs/plans/2026-09-09-huong-phat-trien-server.md`.

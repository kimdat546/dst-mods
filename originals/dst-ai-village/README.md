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

> ⚠ Tới 15/09/2026, `muc_tieu` vẫn là **một ống dẫn ra hư không**: `cau_noi`
> gán nó, `dan_lang` xoá nó lúc chết, và **không một dòng nào đọc**. Giờ nó đã
> cắm vào thế giới — xem mục *Tầng động từ* bên dưới.

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
c_ailang_kiem()               -- chạy CẢ BỘ tự kiểm NGAY TRONG GAME
c_ailang_dem()                -- liệt kê gọn
c_ailang_them("Tí", "wx78")   -- thêm một dân làng ở chỗ mình đứng
c_ailang_datnha()             -- đặt nhà tại chỗ mình đứng
c_ailang_tiepte()             -- phát 2 cỏ + 2 cành cho cả làng
c_ailang_bang()               -- BẢNG: ai chế độ nào, thân bao nhiêu
c_ailang_kho()                -- KHO CỦA LÀNG: gom túi đồ + đồ đang cầm + túi
                              --   hàng của mọi dân làng, cộng rương trong làng
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

## Bẫy lớn nhất của behaviour tree: DoAction giữ RUNNING

⚠ **Logic "chen ngang" KHÔNG được nằm bên trong hàm sinh hành động.**

`DoAction` giữ trạng thái `RUNNING` suốt lúc dân làng đi tới mục tiêu, và
trong khoảng đó **hàm sinh hành động không được gọi lại**. Nên nhu cầu gấp
kiểm tra bên trong hàm đó sẽ không bao giờ chạy: đêm xuống mà dân làng đang
trên đường đi kiếm đồ làm giáo thì chẳng ai bảo nó cầm đuốc — đuốc nằm sẵn
trong túi cho tới sáng.

Cách đúng: nhu cầu gấp là **node riêng, ưu tiên cao hơn**. `PriorityNode` xét
lại từ đầu mỗi 0,5 giây nên nó cắt ngang được việc đang dở, và khi xong việc
tức thì thì tự nhường lại.

Mất khá nhiều vòng mới tìm ra, vì gọi thẳng `sinh_ton.Giai` thì **luôn đúng** —
lỗi chỉ hiện khi đi qua cây hành vi.

## Một việc, một chủ sở hữu

Mọi lao động đi qua **một node duy nhất** trong cây hành vi
(`scripts/ailang/viec.lua`), không phải năm nhánh riêng.

⚠ **Vì sao phải đổi:** `PriorityNode` của DST **quyết lại từ đầu mỗi nhịp**.
Với năm nhánh làm việc riêng (mục tiêu / nhặt / hái / chặt / đào), chúng giẫm
chân nhau và người chơi thấy ngay:

- nhánh chặt cầm rìu lên → nhánh ánh sáng thấy mất sáng → cầm đuốc lại →
  **lặp vô tận**
- **chặt vài nhát rồi bỏ sang cây khác** vì nhánh khác giành lượt

Cách chữa mượn từ [GrimWorld](https://steamcommunity.com/sharedfiles/filedetails/?id=3748676443):
bộ chạy việc **giữ lấy một việc xuyên nhiều nhịp** — nhận việc, đi tới, làm,
xong hoặc bỏ. Ở đây làm gọn hơn: vẫn dùng `DoAction` của DST, nhưng hàm sinh
hành động **nhớ** việc đang làm và trả lại đúng việc đó cho tới khi xong.

Việc bị bỏ khi: mục tiêu biến mất, không làm được nữa, hoặc **đeo quá 45 giây
mà không bào mòn được gì** (đếm ngược đặt lại mỗi khi `workleft` giảm, nên
việc dài bao lâu cũng làm xong).

Kết quả: cây hành vi từ **437 xuống 281 dòng**, và thứ tự còn lại rõ ràng:

```
hồn ma > cháy > máu thấp > đánh trả > đói
       > nhu cầu tức thì > LÀM VIỆC > đêm chưa có sáng
       > theo chân chủ > về nhà > về nhặt đồ > lang thang
```

## Tầng động từ — cách AI ra lệnh cho dân làng

`scripts/ailang/hanh_dong.lua` phơi **thẳng bảng `ACTIONS` của DST** (~200
động từ) và `AllRecipes` ra dưới dạng dữ liệu. Một mệnh lệnh là một bảng:

```lua
{ hanh_dong = "SHAVE", nham = "beefalo", dung = "razor" }
{ hanh_dong = "MINE",  nham = "rock2",   dung = "pickaxe", lan = 4, tam = 60 }
{ che = "researchlab", dat_xuong = true }
{ buoc = { { che = "trap" },
           { hanh_dong = "DROP", nham = "rabbithole", dung = "trap" } } }
```

| trường | nghĩa |
|---|---|
| `hanh_dong` | tên trong `ACTIONS`, không phân biệt hoa thường |
| `nham` | tên prefab (`"beefalo"`) **hoặc** tag (`"CHOP_workable"`) |
| `dung` | prefab món cần cầm — tự tìm trong túi và trang bị |
| `lan` | làm bấy nhiêu **mục tiêu**, không phải bấy nhiêu nhát |
| `tam` | bán kính tìm, mặc định 30 |
| `che` | tên công thức, thay cho `hanh_dong` |
| `dat_xuong` | công thức này là công trình, đặt xuống đất |
| `buoc` | danh sách mệnh lệnh làm lần lượt |

Hai điều đã phải trả giá để biết:

- **`lan` đếm MỤC TIÊU LÀM XONG, không đếm nhát chém.** `ACTIONS.CHOP` trả
  `true` cho *mỗi nhát*, mà hạ một cây thông cần khoảng mười nhát. Bản đầu
  chạy `CHOP ×8` đủ tám lượt mà **không cây nào đổ**, gỗ = 0.
- **Đào và chặt làm rơi đồ xuống đất, không bỏ vào túi.** Chuỗi
  `MINE rock2 ×6 → CHOP ×8 → chế researchlab` chạy đúng hai bước đầu rồi báo
  "chưa đủ nguyên liệu" với vàng = 0 — tất cả nằm ngay dưới chân. Tầng mục
  tiêu giờ **tự nhặt** trước khi làm tiếp, và lần nhặt đó không tính vào `lan`.

**Vì sao không viết tay từng động từ.** Chép lại một thứ đã có, và chép mãi
cũng không đủ — người chơi sẽ luôn nghĩ ra tình huống chưa lường. "Cạo lông
bò" không cần một dòng mã riêng nào.

**Vị trí trong cây hành vi** là cả thiết kế:

```
giữ mạng (hồn ma, cháy, máu thấp, giữ làng, đói, quá nóng, đêm về lửa)
   > MỤC TIÊU TỪ TẦNG SUY NGHĨ
      > chính sách mặc định (bảng nhu cầu + việc thường)
```

Đặt cao hơn thì Gemini bảo đi đào đá giữa đêm và dân làng đi thật, bỏ đuốc
lại — kênh trễ vài giây, nó không thấy con ếch đang cắn. Đặt thấp hơn node
làm việc thì không bao giờ tới lượt, vì `DoAction` giữ `RUNNING` suốt quãng
đường đi (xem mục *Bẫy lớn nhất của behaviour tree*).

Có **hai loại hỏng** và chúng được đếm khác nhau: hỏng lúc *tính* (không thấy
mục tiêu, thiếu món, động từ không có) là lệnh sai — sáu lần là bỏ; hỏng lúc
*làm* (engine từ chối vì cây vừa đổ, hoặc một phản xạ cắt ngang) chỉ ghi lý do,
vì gộp lại thì sáu lần cắt ngang lúc chập tối là một mục tiêu đúng bị vứt oan.
Van chặn ôm mãi là **đồng hồ 180 giây**, và nó được soát ở nhịp định kỳ của
`dan_lang` chứ **không** trong cây hành vi — `DoAction` giữ `RUNNING` suốt
quãng đường đi, nên đặt trong đó là đúng lúc dân làng kẹt cứng thì không ai
xem đồng hồ. Đã đo: kẹt vật cản, cách mục tiêu 3 đơn vị, 8 giây đi được 0,0.

Lệnh sai bị **soát ngay lúc nhận** và lý do được gửi ngược trong
`muc_tieu_loi` của nhịp sau. Nuốt lỗi thì tầng suy nghĩ ra lệnh sai mãi mà
không biết vì sao — nó không nhìn thấy log server.

Thử tay:

```lua
c_ailang_muctieu("An", { hanh_dong = "CHOP", nham = "evergreen", dung = "axe", lan = 3 })
c_ailang_muctieu("An", { che = "researchlab", dat_xuong = true })
c_ailang_muctieu("An")     -- xoá mục tiêu
```

Mod ghi toàn bộ từ vựng ra `<save>/ailang_tudien.json` lúc khởi động, để dịch
vụ ngoài biết nó ra lệnh được những gì.

**Một khác biệt đáng để ý:** chính sách mặc định chỉ tìm đồ **trong bán kính
làng** (`sinh_ton.DiKiem` lọc qua `lang.TrongLang`), còn mục tiêu từ tầng suy
nghĩ thì **không bị bó** — `tam` muốn bao nhiêu cũng được. Nên khi làng cạn
thứ gì đó tại chỗ, đó đúng là việc của tầng suy nghĩ: nó thấy `nut_that` là
"thiếu vàng cho máy khoa học", biết quanh làng không có mỏ vàng nào, và gửi
lệnh đi xa lấy về. Bảng nhu cầu một mình thì chỉ biết ghi nhận "bó tay" rồi
nghỉ.

## Bản vẽ công trình — cả làng góp liệu

`builder:DoBuild` của DST đòi **một** người cầm **đủ cả** bộ nguyên liệu. Máy
Khoa Học cần vàng 1 + gỗ 4 + đá 4, nên ba dân làng mỗi đứa ôm một phần thì
**không bao giờ** dựng nổi dù cộng lại thừa. Đo trên server: vàng 3, đá 6 nằm
rải trong túi nhiều người, máy vẫn không lên. Đó không phải lỗi hành vi — là
trần của mô hình "mỗi người tự lo".

Lời giải mượn từ GrimWorld: đặt một **bản vẽ** (`ailang_banve`) kèm bảng giá,
ai rảnh thì mang liệu tới, đủ thì nó thành công trình thật.

```
nhu cầu   quyết ĐỊNH DỰNG GÌ, đặt bản vẽ khi tự mình không đủ
việc      lo MANG LIỆU TỚI — việc của cả làng, xếp cùng bậc giữ làng
```

| quyết định | vì sao |
|---|---|
| giao liệu bằng `trader` + `ACTIONS.GIVE` | DST có sẵn `constructionsite` nhưng nó dính chặt vào UI người chơi (cần `constructionbuilderuidata` trên người làm); dân làng không có UI |
| bản vẽ **không** mang tag của thứ nó sắp thành | bản vẽ Máy Khoa Học mà mang `prototyper` thì `xuong.du` báo làng đã có xưởng, và không ai mang liệu tới nữa |
| **một** bản vẽ một lúc | cho đặt nhiều thì làng chia liệu ra khắp nơi và không cái nào xong — đúng bệnh nó sinh ra để chữa, chỉ đổi chỗ chia |
| chỉ công trình **đáng chờ** mới dùng bản vẽ | đống lửa khẩn cấp thì không: cần nó là cần **ngay**, chờ người khác mang gỗ tới là chết đêm |

Hai cái bẫy đã trả giá:

- **Tên file hoạt ảnh phải đúng từng chữ.** Viết `pigman_house` (tên prefab con
  heo) thay vì `pig_house` (tên file anim) làm **cả server không khởi động
  nổi** — không `MOD ERROR`, không dòng lỗi nào, world chỉ đơn giản không bao
  giờ nạp xong và bộ kiểm treo tới hết giờ.
- **`trader:AcceptGift` mặc định chỉ lấy MỘT món** (`count = count or 1`),
  không nuốt cả chồng. Mà `ACTIONS.GIVE` không truyền `count` được, nên bản vẽ
  tự moi thêm trong túi người đưa cho đủ phần còn thiếu — một lượt đưa là xong,
  và không vét sạch túi người ta.

## Kiểm kê làng — để AI ra chiến lược

`scripts/ailang/kho_lang.lua` gom **cả làng** (túi + đồ mặc + túi hàng +
rương) và quy về thứ quyết định được, rồi gửi kèm trong mỗi gói hỏi:

| trường | nghĩa |
|---|---|
| `ngay_an` | dự trữ ăn được mấy ngày cho cả làng |
| `mau_hoi` | tổng máu hồi được đang cầm |
| `cap_may` | cấp công nghệ cao nhất làng có |
| `sap_hong` | số món dưới 25% độ tươi |
| `du_an` / `du_thuoc` / `du_vu_khi` / `du_giap` | đủ hay chưa |
| `du_suc_danh` | đủ ăn + đủ thuốc + đủ vũ khí + máu ≥ 70% |
| `nut_that` | thứ **đầu tiên** đang chặn làng |

Kho tính **cả đồ rơi trên đất trong bán kính làng**, không chỉ túi và rương —
nền đất của làng cũng là một cái kho, và người chơi thật cũng dùng nó như vậy.
Bỏ sót chỗ này thì bảng nói dối đúng lúc quan trọng nhất: đào vỡ ba tảng đá
vàng xong, vàng nằm ngay dưới chân mà bảng vẫn báo `vang = 0`.

Đi kèm là **trần thu gom** (`kho_lang.TRAN`): đủ rồi thì thôi gom, và **đếm cả
làng** chứ không đếm riêng từng túi — ba dân làng mỗi đứa ôm 19 quả berry thì
không ai thấy làng đang có 57 quả. Trần chỉ chặn việc **tự phát**; nhu cầu đi
qua `sinh_ton.DiKiem` nên vẫn kiếm được gỗ để dựng Máy Khoa Học dù kho đầy gỗ.

**Đếm số món thì không trả lời được "đủ ăn chưa".** "Có 12 berry" nghe như no;
quy ra thì là 112 calo, chưa nổi một ngày cho một người. Và nhìn riêng túi
từng người thì ba người mỗi người hai quả trông như sắp chết đói trong khi
rương đầy thịt viên.

Xem bằng `c_ailang_chienluoc`.

## Bảng nhu cầu sinh tồn

Dân làng quyết định làm gì bằng `scripts/ailang/nhu_cau.lua` — một bảng KHAI
BÁO, không phải nhánh `if` lồng nhau. Thêm nhu cầu mới chỉ là thêm một mục.

Thứ tự ưu tiên:

```
ánh sáng > đồ ăn > hồi máu > mát > dụng cụ > cuốc > nhà > dự trữ > xưởng > kho
         > hồi não > vũ khí > giáp
```

Thứ tự này là thứ đã trả giá đắt nhất để tìm ra, nên chép lại lý do:

- **dụng cụ (rìu) đứng trên nhà.** Rìu là ĐIỀU KIỆN của đống lửa, không phải
  thứ cạnh tranh với nó. Bản trước không có nhu cầu này, nên dân làng chết một
  lần là rơi mất rìu và **không bao giờ chặt được gỗ nữa** — dù đứng giữa
  rừng. Đo tại chỗ: `DiKiem("log")` trả nil ở cả hai bán kính trong khi có 12
  cây chặt được trong vòng 30. Không gỗ → không lửa → chết đêm → lại rơi rìu.
- **cuốc đứng cạnh rìu, không đứng cuối bảng.** Lý do cũ là "không có cuốc
  thì chỉ chậm, không chết" — đúng vào lúc chưa có gì trong bảng cần đá. Giờ
  đào là **nút thắt của cả nền kinh tế**: cuốc → đá + vàng → Máy Khoa Học →
  rương, nồi, giáo, giáp gỗ, lửa lạnh. Để cuối bảng thì `xưởng` cứ thử dựng
  máy, không kiếm nổi vàng vì tay không cuốc, bị ghi **bó tay** rồi cho nghỉ —
  mà nhu cầu gỡ được nút đó lại nằm sau bốn nhu cầu khác.
- **nhà đứng trên vũ khí và giáp.** Không có lửa thì chết đêm; không có giáp
  thì chỉ đau hơn. Để "nhà" ở cuối bảng là giáp/vũ khí luôn chen trước và dân
  làng không dựng nổi đống lửa nào.
- **cuốc ở cuối.** Không có cuốc thì chỉ chậm, không chết.
- **mát đứng gần đầu.** Mùa hè giết dân làng giữa ban ngày, không cần Charlie —
  xem mục dưới.
- **xưởng đứng dưới nhà.** Có chỗ trú đã rồi mới tính chuyện máy móc. Nhưng nó
  trên vũ khí/giáp, vì một cái máy mở khoá cả một tầng.

Với nhu cầu cấp thiết nhất chưa thoả, `sinh_ton.lua` đi ba nước:

1. Có sẵn món ở bậc nào thì mặc/cầm món đó
2. Không có nhưng chế được thì chế
3. Không bậc nào làm ngay được thì **đi kiếm nguyên liệu còn thiếu** cho bậc
   rẻ nhất — đây là chỗ dân làng trông "biết tính" thay vì đi lang thang

Ví dụ ánh sáng có bốn bậc `minerhat` → `lantern` → `torch` → `campfire`. Đầu game
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

### Mùa hè giết dân làng giữa ban ngày

Không cần Charlie. Đo trên server ngày 57:

```
nhiệt độ MÔI TRƯỜNG = 71.6 … 78      TUNING.OVERHEAT_TEMP = 70
```

Chỉ đứng ngoài trời là đủ chết. Máu tụt đều suốt ngày mà **không một sự kiện
`attacked` nào**, nên ban đầu nhìn như lỗi ma. Tương quan thì thẳng tưng:

| dân làng | nhiệt độ | máu |
|---|---|---|
| An | 67.6 | 56% |
| Cuong | 71.3 | 1% |
| Binh | 72.4 | **chết** |

Đồ chống nóng đã đo:

| món | cách nhiệt | ô | công thức | tech |
|---|---|---|---|---|
| `coldfire` (lửa lạnh) | — | công trình | cutgrass×3 nitre×2 | **1** |
| `grass_umbrella` | 120 | tay | twigs×4 cutgrass×3 petals×6 | 0 |
| `strawhat` | 60 | đầu | cutgrass×12 | 0 |

⚠ Mũ và ô chỉ **làm chậm** tốc độ nóng lên, không chặn đứng — ở mức 78 độ thì
cách nhiệt 60 không cứu nổi. Lời giải thật là **lửa lạnh**, và nó tech 1.

⚠ Bắt đầu lo từ **62 độ**, đừng đợi chạm 70. Đội mũ lúc đã 70 là muộn.

⚠ **Đang quá nhiệt thì ĐỪNG về bên lửa.** Đống lửa toả nhiệt cộng thêm vào cái
nóng vốn đã quá ngưỡng.

### Một cái máy mở khoá cả một tầng

`researchlab` là **tech 0** (`goldnugget×1 log×4 rocks×4`) nên dân làng tự dựng
được — cần cuốc để có đá và vàng, mà nhu cầu *cuốc* đã lo phần đó. Từ lúc có
máy, mọi nhu cầu khác **tự lên bậc mà không phải sửa gì thêm**, vì
`builder:CanBuild` xét cấp công nghệ hộ:

```
mát     → coldfire    (lời giải thật của mùa hè)
nhà     → firepit     (bếp lửa không biến mất khi hết củi)
vũ khí  → spear
giáp    → armorwood
```

⚠ `du` của nhu cầu *xưởng* phải đòi tag **`structure`**, không chỉ `prototyper`:
`carnival_host` — con quạ của sự kiện lễ hội — cũng mang tag `prototyper` và nó
**biết đi**. Bộ tự kiểm bắt được đúng cảnh đó: một con lảng vảng gần điểm sinh
làm dân làng tưởng làng đã có xưởng.

### Túi hàng — chỗ người chơi lấy đồ ra

Túi **đồ** của một prefab người chơi thì người chơi khác không mở được. Nên mỗi
dân làng được gắn thêm hẳn một `container` lên chính entity — đúng cách Chester
và Glommer làm. Trỏ chuột vào dân làng là có nút mở.

Đây là **hộp một chiều, cố ý**: `inventory:GetOverflowContainer` chỉ nhìn món
đang mặc ở ô BODY, nên đồ trong túi hàng KHÔNG dùng để chế đồ được. Vì vậy dân
làng chỉ dồn vào đây thứ nó không cần để sống, và chỉ khi túi chính **đã đầy** —
lúc đó nó vốn đứng ngây không nhặt thêm được gì.

⚠ Bốn món **không bao giờ** bị dồn đi: `cutgrass`, `twigs`, `log`, `flint`. Đó
là nguyên liệu của đuốc, lửa trại và rìu — cất đi là tự chặt đường sống.

⚠ Túi hàng phải gắn **trước** khi dựng lại đồ trong `dan_lang.Sinh`, và phải
vào **hồ sơ**: dân làng có `persists = false` nên thứ được lưu cùng world là hồ
sơ chứ không phải entity. Quên một trong hai là đồ người chơi gửi vào bốc hơi
sau mỗi restart.

### Bóng cây và cái mũ — hai vai khác nhau

Đừng gộp **biện pháp cấp cứu** với **giải pháp lâu dài**:

```
cấp cứu tức thời  →  cây hành vi : chạy vào bóng cây (nhánh trên node làm việc)
giải pháp bền     →  bảng nhu cầu : cái mũ cỏ, cái lửa lạnh
```

Bản đầu cho bóng râm thoả luôn nhu cầu *mát*, tức lấy cấp cứu làm giải pháp bền.
Dân làng sống, nhưng **rỉ máu vĩnh viễn** và không bao giờ chế mũ: mỗi vòng
ra-vào gốc cây lại nhích qua mốc 70 một nhịp. Nhiệt độ nhìn thì ổn định
(64-76°), chỉ có máu là nói thật — 99% → 59%.

⚠ Nhánh trú nóng phải có **trễ ngưỡng**: bật ở 66, chỉ nhả ở 65, cộng
`StandStill` giữ chân dưới gốc cây. Không có nó thì nhánh nhả lượt ngay khi vừa
chạm bóng râm và dân làng bị lôi đi khi còn 69°.

⚠ Mức nhả **không được đặt dưới 63**: bóng cây chỉ hạ nhiệt khi đang *trên*
`TREE_SHADE_COOLING_THRESHOLD`, nên đòi xuống 58 là đứng dưới gốc cây tới sáng
mà không bao giờ đạt.

⚠ Đã **bỏ hẳn `grass_umbrella`** dù nó cách nhiệt gấp đôi mũ cỏ (120 so với 60).
Nó chiếm **ô tay** — đúng ô mà đuốc cần. Hai nhu cầu giành nhau một ô là quay
lại đúng bệnh rìu↔đuốc đã tốn mấy vòng để chữa.

### Lo thân trước khi giữ làng

Nhánh *Giữ làng* nằm rất cao trong cây, nên hễ nó giành được lượt là mọi nhánh
tự-lo bên dưới **không bao giờ chạy**. Đã gây hoạ **ba lần**:

1. một con hound cách 30 làm hỏng cả năm phép kiểm về đuốc và nhặt đồ
2. dân làng đứng đánh nhau giữa đêm khi chưa có nguồn sáng
3. cả ba khoá cứng ở đó để đuổi **một con ếch** giữa mùa hè — nhiệt 77° → 87°,
   máu 94% → 28% → chết, trong khi có 21 gốc cây rợp bóng trong bán kính 40

Hai lần đầu đều vá bằng cách thêm *đúng một* cửa thoát cho đúng triệu chứng vừa
gặp. Giờ mọi lý do "chết tại chỗ đang đứng" gom trong `lang.LoThanTruoc()` —
kiểm được bằng phép kiểm tự động, và lần sau thêm điều kiện chỉ phải sửa một chỗ.

### Nuôi lửa

Lửa trại **không cháy mãi**: hết nhiên liệu là nó nhả tro rồi biến mất hẳn
(`campfire.lua` đặt `accepting = false`, thêm tag `NOCLICK`, rồi `ErodeAway`).
Tệ nhất là nó tắt giữa đêm — đúng lúc dân làng bị cấm cầm rìu nên không đi
chặt gỗ mới được.

Nên "tiếp lửa" là một VIỆC THƯỜNG trong `viec.lua`, xếp ngay sau dập lửa: dưới
nửa bình thì ném củi vào, ưu tiên gỗ, chừa lại 4 cỏ/cành để còn làm đuốc. Để
là việc thường (chứ không phải nhu cầu) vì nhu cầu gấp vẫn phải chen ngang
được — lo thân trước, nuôi lửa sau.

### Ưu tiên phải thắng khoảng cách

`sinh_ton.Giai` từng lặp **bán kính ở vòng ngoài, ưu tiên ở vòng trong** — quét
hết mọi nhu cầu ở gần rồi mới nới rộng. Nghe thì hợp lý ("đi xa là biện pháp
cuối"), nhưng nó **lặng lẽ đảo ngược cả bảng ưu tiên**: một nhu cầu quan trọng ở
xa luôn thua một nhu cầu vặt ở gần.

Đo trên server giữa mùa hè:

```
DiKiem("cutgrass")  r=30  -> nil        (1 bụi cỏ trong vòng 30)
DiKiem("cutgrass")  r=130 -> PICK       (39 bụi trong vòng 130)
```

*Mát* hạng 4 cần đi xa, *nhà* hạng 6 xong ngay tại chỗ. Thế là dân làng đi dựng
lửa trại **trong khi đang mất máu vì nóng**, máu 99% → 46%, mà nhật ký chỉ ghi
`đi kiếm log cho campfire`.

Giờ **ưu tiên ở vòng ngoài**: thử từng nhu cầu ở cả hai bán kính rồi mới xuống
nhu cầu tiếp theo.

### Nhu cầu bó tay thì đừng cho cướp lượt

Một nhu cầu `gap` giải không ra — thử cả hai bán kính đều tay trắng — mà vẫn giữ
quyền chen ngang thì nó cướp lượt **mỗi nhịp**: dân làng bỏ việc liên tục, chẳng
làm xong gì, mà nhu cầu kia vẫn không nhúc nhích.

`Giai` giờ ghi lại những nhu cầu bó tay vào `inst.ailang.bo_tay`, và
`viec.CanChenNgang` bỏ qua chúng.

⚠ Nhờ chốt này mà *mát* giữ lại được `gap`. Cờ đó **không phải để chen ngang cho
vui** — nó là thứ nới dây trói về nhà từ 50 lên 140 (xem bảng dưới). Bỏ `gap`
thì dân làng bị trói trong 50 đơn vị và không bao giờ với tới chỗ có cỏ.

### Bán kính đi kiếm phải KHỚP với dây trói về nhà

Hai con số này từng đá nhau và nó giết cả làng:

| | cũ | mới |
|---|---|---|
| `TAM_KIEM_GAP` (sinh_ton) — tầm tìm khi nhu cầu cấp thiết | 80 | **130** |
| `VE_NHA_XA` (danlangbrain) — xa nhà bấy nhiêu thì bỏ việc về | 50 | 50 |
| `VE_NHA_XA_GAP` — nhưng khi còn nhu cầu GẤP chưa giải được | *(không có)* | **140** |

Vòng tìm khẩn cấp bán kính 80 là **mã chết** khi node "đi quá xa nhà" kéo chúng
về ngay lúc vượt 50. Dân làng bị trói trong đúng 50 đơn vị quanh Đài.

Đo trên server, làng dựng giữa rừng rậm:

| bán kính | bụi cỏ | bụi cây con | cây gỗ |
|---|---|---|---|
| 30 | 1 | 0 | 55 |
| 80 | 3 | 0 | 250 |
| 150 | **86** | 0 | 514 |

Đuốc cần 2 cỏ + 2 cành, lửa trại cần 3 cỏ. Cả ba chết đêm với 2 khúc gỗ trong
túi — ngồi trên một mỏ gỗ mà không đổi ra nổi ánh sáng, trong khi 86 bụi cỏ nằm
ngay ngoài sợi dây trói.

Vẫn giữ trần cứng 140 để không quay lại bệnh trôi vô hạn (đã đo lần trước: trôi
tới 158, chết ở 235).

### Đống lửa của làng đặt ở LÀNG

Bậc `campfire`/`firepit` của nhu cầu **nhà** mang cờ `o_nha`, nên dựng cạnh
Đài Triệu Hồi chứ không dựng dưới chân. Bản trước dựng tại chỗ đứng, thường
cách nhà hơn 40, nên `nha.du` quét quanh nhà không thấy gì và dân làng **dựng
lại, dựng mãi**, đốt sạch gỗ vừa chặt mà làng vẫn tối. Nhật ký bắt tại trận:
`lua=1` mà cả ba vẫn báo `dang_lam="nhà"`.

Ngược lại, bậc `campfire` của nhu cầu **ánh sáng** KHÔNG mang cờ đó — đó là
lửa khẩn cấp, phải nhóm ngay dưới chân, ở đâu cũng được.

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

## Kinh tế đồ ăn — vì sao cả làng từng chết sạch

Chạy server chỉ có NPC ở tốc độ tối đa, đo được:

| | kết quả |
|---|---|
| không có Đài triệu hồi | chết ngày 2, và ở lại chết |
| có Đài triệu hồi | khoẻ tới ngày 8; từ ngày 9 chết mỗi đêm; ngày 16 là 95 lượt chết, còn 10% máu |

Truy ra thì **không phải lỗi hành vi nào cả** — là bài toán lương thực không
có lời giải:

- Ba dân làng đốt **225 calo/ngày** (bụng 150, đốt 75/ngày mỗi người).
- Một quả berry cho **9,375 calo**. Một bụi ra 3 quả rồi **chết**, mọc lại mất
  3 ngày → **0,33 quả/ngày/bụi**.
- Muốn nuôi ba người chỉ bằng berry thì cần **khoảng 70 bụi** trong bán kính
  làng. Không bản đồ nào có.

Cộng thêm một dòng bảng tra: `goldnugget` nhắm mọi thứ mang tag
`MINE_workable`, nên dân làng **đập tảng đá thường mãi mà không bao giờ ra
vàng** — trong khi Máy Khoa Học cần đúng một cục. Bảng rơi trong
`scripts/prefabs/rocks.lua` nói thẳng: `rock1` → đá + diêm tiêu + đá lửa,
**không có vàng**; chỉ `rock2` mới cho. Không có máy thì không có rương,
không nồi, không giáo, không lửa lạnh — cả nền kinh tế tech 1 chết ở một dòng.

Lời giải là ba thứ người chơi thật vẫn làm, nay nằm trong `viec.lua`:

1. **Nấu chín** — thịt nhỏ 12,5 → 25 calo, đồng hồ hỏng được đặt lại. Không
   tốn nguyên liệu nào, chỉ cần đứng cạnh lửa của làng.
2. **Bẫy thỏ** — nguồn thịt **tái tạo**, tech 0 (`twigs`×2 `cutgrass`×6, 8
   lượt dùng). Đặt **đúng lên miệng hang**, và chỉ vào hang chưa có bẫy.
3. **Cất rương** — đồ ăn để đất hỏng **nhanh gấp rưỡi** (ngoài trời ×1,5,
   rương ×1,0, tủ lạnh ×0,5). Cất từ khi túi chưa đầy, chứ đợi đầy là đã phí.

Bốn việc này nằm **cùng bậc với giữ làng**, tức là trên các nhu cầu không
gấp. Để xuống dưới cùng thì không bao giờ tới lượt: `vũ khí` và `giáp` có
`can` luôn trả true, nên hễ quanh đó còn một bụi cỏ là bộ giải luôn có việc
trả về — đúng cái bệnh đã làm lửa của làng tụt còn 17% trong khi cả ba đứng
hái cỏ làm áo giáp.

Chi tiết số liệu: `docs/dst-knowledge/analysis/dst-kinh-te-sinh-ton.md`.

**Tủ lạnh thì cố ý KHÔNG đưa vào.** `icebox` cần `gears`, mà gears chỉ rơi từ
người máy ở Ruộng Bàn Cờ — dân làng đánh không lại. Bắt chúng đi săn gears là
bắt đi chết. Người chơi có sẵn thì cứ đưa tay.

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

**Chưa kiểm được, cần người:**

- **Chạy thử tầng suy nghĩ với khoá Gemini thật.** Cả kênh AI đã kiểm kỹ ở
  phía mod (đặt mục tiêu, soát lệnh sai, báo ngược lý do, từ điển ghi ra đĩa),
  nhưng **chưa một lần nào có LLM thật ở đầu kia**. Ba bộ não Python nạp được
  và bộ luật chạy đúng; phần Gemini mới chỉ kiểm bằng dữ liệu giả.
- **Nút mở túi hàng của dân làng** — UI phía client, server headless không
  kiểm được. Cần vào game bấm thử.
- **Dân làng tự dựng Máy Khoa Học trong một lượt tự phát.** Bốn thứ chặn cứng
  đã sửa và có phép kiểm canh, nhưng world ở `tools/test/data` đã bị hàng chục
  lượt thử vét sạch cỏ và cành quanh làng, nên `ánh sáng` chiếm lượt vĩnh viễn.
  Phải dựng world mới hoặc vào game thật.
- **Sống qua nhiều chu kỳ ngày–đêm liên tiếp** (mới xác nhận một chu kỳ).

**Còn thiếu trong mod:**

- **Nồi (`cookpot`)** — bước nhân giá trị đồ ăn lớn nhất còn lại (thịt viên
  62,5 calo, giữ 10 ngày). Kẹt ở `charcoal`×6: than chỉ ra từ cây bị **đốt**,
  nên cần động từ "châm lửa đốt cây" — và phải tính chuyện cháy lan trước.
- **Nghề nghiệp.** Mọi dân làng dùng chung một bảng nhu cầu nên cả ba luôn lo
  cùng một thứ cùng lúc (đã thấy: cả ba cùng "gom củi" 11 lượt liền). GrimWorld
  giải bằng bảng ưu tiên theo nghề, cố ý không để phẳng.
- **Chủ động gom cỏ và cành ban ngày** để chắc chắn có liệu làm đuốc. Giờ chỉ
  nhặt được gì thì nhặt, gặp đêm tay trắng là kẹt — và đó chính là thứ đã làm
  ba lượt thử Máy Khoa Học tắc.
- **Trí nhớ dài hạn cho tầng suy nghĩ** (giờ mỗi nhịp là một lần hỏi độc lập).
- `modicon.tex/.xml` (đang cảnh báo lúc nạp, vô hại).
- Nối với ý "thủ thành" trong `docs/plans/2026-09-09-huong-phat-trien-server.md`.

**Còn đáng học từ GrimWorld** (xem
`docs/dst-knowledge/analysis/refmods/3748676443-grimworld.md`): chọn kho bằng
điểm, sự kiện thương nhân đổi hàng (lối thoát cho vàng và `gears`),
`Immune`/`Prefers` trong mô hình giá trị đồ ăn, `FindFire` trả về cả lửa tắt
đáng nhóm lại.

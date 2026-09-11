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
c_ailang_them("Tí", "wx78")   -- thêm một dân làng ở chỗ mình đứng
c_ailang_dem()                -- liệt kê dân làng và trạng thái
c_ailang_datnha()             -- đặt nhà tại chỗ mình đứng
c_ailang_xoahet()
```

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

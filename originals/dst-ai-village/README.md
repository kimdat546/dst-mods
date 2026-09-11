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

## Còn phải làm

- Vào game thật xem dân làng có thật sự đi lại và làm việc không.
- `modicon.tex/.xml` (đang cảnh báo lúc nạp, vô hại).
- Nghề nghiệp: hiện mọi dân làng dùng chung một cây hành vi.
- Trí nhớ dài hạn cho tầng suy nghĩ (giờ mỗi nhịp là một lần hỏi độc lập).
- Nối với ý "thủ thành" trong `docs/plans/2026-09-09-huong-phat-trien-server.md`.

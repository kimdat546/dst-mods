# Test harness headless — Food Buff HUD

Chạy mod trên dedicated server không giao diện, `scripts/selftest.lua` in PASS/FAIL ra log.

## Kiểm được gì / KHÔNG kiểm được gì

**Kiểm được (không cần mở game):**
- Mod nạp không lỗi Lua
- Giả định cốt lõi: buff gắn vào người chơi có timer `"buffover"` đọc được số giây thật
- `Collect()` thấy đủ buff và sắp xếp tăng dần
- `Encode`→`Decode` không mất mát
- Buff lạ được thô hoá tên thay vì bị bỏ (điểm chống mục ruỗng)

**KHÔNG kiểm được ở đây** — cần client thật có màn hình:
- HUD hiện ra đúng chỗ
- RPC có tới được client
- Kéo thả bằng chuột phải

Nếu selftest FAIL thì khỏi cần mở game: kiến trúc sai từ gốc.
Nếu PASS thì phần còn lại chỉ là chuyện hiển thị.

## Chuẩn bị (một lần)

```bash
cp test.env.example test.env      # dán DST_CLUSTER_TOKEN thật vào
docker build --platform linux/amd64 -f Dockerfile.x64 -t dst-server-x64-test:local .
```

`Dockerfile.x64` + `container-x64` cần thiết vì binary server DST mặc định là 32-bit,
mà Rosetta trên Apple Silicon không chạy được 32-bit (exit 139). Chúng chuyển sang
`bin64/..._x64` và thêm `libcurl3-gnutls` 64-bit.

## Chạy

```bash
./build.sh                      # dựng bản test (bật cờ FOODBUFFHUD_SELFTEST)
docker compose up -d master     # lần đầu ~60s gồm worldgen
docker compose logs master | grep '\[FoodBuffHUD\]\[TEST\]'
```

⚠ `docker compose logs` in cả lịch sử các lần chạy trước. Muốn chắc đang xem lần
mới thì `docker compose down` trước, hoặc so mốc thời gian.

## Dọn

```bash
docker compose down       # giữ world
docker compose down -v    # xoá sạch
```

## Hai cái bẫy đã vấp (ghi lại kẻo lặp)

**1. `modmain` chạy trong env sandbox, thiếu nhiều hàm base Lua.**
`mods.lua CreateEnvironment()` chỉ cấp:
`pairs ipairs print math table type string tostring require Class TUNING GLOBAL modname MODROOT`.
KHÔNG có `rawget`, `tonumber`, `pcall`, `assert`, `next`… → phải gọi qua `_G.`.
Các file trong `scripts/` thì khác: chúng `setfenv(1, GLOBAL)` nên dùng trực tiếp được.
Lỗi biểu hiện là `attempt to call global 'rawget' (a nil value)`, và trên dedicated
server nó còn bị che bởi `variable 'SetGlobalErrorWidget' is not declared` (server
headless không có widget báo lỗi) — phải kéo log lên xem dòng `MOD ERROR` phía trên.

**2. Server không có người chơi thì DST `Sim paused` → `DoTaskInTime` không bao giờ nổ.**
Dùng `DoStaticTaskInTime` cho những gì phải chạy bất chấp pause. Ngoài ra harness đặt
`DST_GAMEPLAY_PAUSE_WHEN_EMPTY=false` để sim chạy thật — nếu sim đứng thì timer buff
cũng đứng, test đếm ngược thành vô nghĩa.

**3. `modimport` phải được gọi trong lúc `modmain` chạy**, không gọi được trong callback
trễ. Nạp file ở modmain để định nghĩa hàm, rồi chỉ hoãn phần *gọi*.

## Kết quả mốc (2026-07-30)

```
PASS 14 / FAIL 0
buff_attack 240.0s · buff_playerabsorption 240.0s · buff_workeffectiveness 240.0s
buff_moistureimmunity 300.0s · buff_electricattack 300.0s · buff_sleepresistance 480.0s
buff_some_future_thing → "Some future thing"
```

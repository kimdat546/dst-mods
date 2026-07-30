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

# Test harness headless cho mod dịch Đăng Tiên

Chạy mod dịch cùng mod gốc 【登仙】 trên **dedicated server không giao diện**, rồi đọc
kết quả từ log. Không cần mở game, không cần ngồi canh — dùng để đo *"còn bao nhiêu
chữ Hán chưa dịch, nằm ở đâu"* sau mỗi lần mod gốc update.

Hoàn toàn tách biệt với server thật ở `_infra/dst-server-docker` (khác container,
khác cổng 11997, khác thư mục dữ liệu).

## Vì sao cần

Phân tích tĩnh (đọc `scripts/main/strings.lua` của mod gốc) **không thấy hết**: 97%
file của mod gốc bị mã hóa, nhiều chuỗi được đăng ký lúc chạy qua `AddModCharacter`,
khai báo skin, `AddAction`… Lần chạy đầu tiên harness này đã tìm ra **55 chuỗi**
mà phân tích tĩnh bỏ sót — trong đó có cả tên nhân vật trên màn hình chọn.

## Chuẩn bị (một lần)

```bash
cp test.env.example test.env      # rồi dán DST_CLUSTER_TOKEN thật vào
export STEAM_DIR="$HOME/Library/Application Support/Steam"
docker build --platform linux/amd64 -f Dockerfile.x64 -t dst-server-x64-test:local .
```

`Dockerfile.x64` cần thiết vì image server gốc chỉ cài thư viện 32-bit, mà Rosetta
trên Apple Silicon **không chạy được binary 32-bit**. Image dẫn xuất thêm
`libcurl3-gnutls` 64-bit, và `container-x64` đổi entrypoint sang
`bin64/dontstarve_dedicated_server_nullrenderer_x64`.

## Chạy

```bash
./build.sh ../.. ./build/dang-tien-viet-test   # dựng bản build test từ source mod
docker compose up -d master                     # lần đầu ~60s (gồm world gen)
```

Bản build test khác bản phát hành đúng 2 điểm, do `build.sh` tự vá:
1. `client_only_mod = false` — dedicated server **loại bỏ** mod client-only, không sửa thì server không nạp.
2. Bật cờ `DANGTIEN_SELFTEST` — để `scripts/selftest.lua` chạy.

## Đọc kết quả

```bash
docker compose logs master | grep '\[DangTienVN\]\[TEST\]'
```

Và danh sách đầy đủ phần chưa dịch (ngoài thoại nhân vật) được self-test ghi từ
**trong game** ra file, đọc được từ ngoài:

```
data/Master/server/general/Master/save/dangtien_missing.txt
```

⚠ `docker compose logs` in cả lịch sử các lần chạy trước. Muốn chắc chắn đang xem
lần chạy mới thì xóa file dump rồi chờ nó xuất hiện lại, đừng chờ theo dòng log.

## Kết quả mốc (2026-07-26, mod gốc v19.0)

```
QUÉT: 119652 chuỗi trong STRINGS, còn 27381 có chữ Hán (22.9%)
KIỂM ĐIỂM: PASS 11 / FAIL 0
Ngoài thoại nhân vật: 0 chuỗi cần dịch
  (12 chuỗi STRINGS.PRETRANSLATED.* là của game gốc — cố tình để tiếng Hàn/Trung)
```

27381 chuỗi còn lại **toàn bộ là thoại 9 nhân vật chưa dịch**, ~3000 dòng mỗi người.

## Dọn

```bash
docker compose down          # giữ world
docker compose down -v       # xóa sạch
```

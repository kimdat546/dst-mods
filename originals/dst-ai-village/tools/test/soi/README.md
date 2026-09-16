# Soi thế giới đang chạy

Dùng khi bộ tự kiểm không đủ — nó chạy bằng **não dựng tay**, nên kiểm được
LOGIC CHỌN HÀNH ĐỘNG nhưng không kiểm được chuyện dân làng có thật sự đi tới
nơi và làm xong việc không. Mấy lỗi nặng nhất của mod đều chỉ lộ ra ở đây:

- đào/chặt làm rơi đồ **xuống đất**, mục tiêu AI không nhặt
- `lan` đếm **nhát chém** chứ không đếm cây đổ
- dân làng **kẹt cứng** vào vật cản mà vẫn ôm mục tiêu 264 giây

## Chạy

```bash
cd tools/test && docker compose up -d      # bật server
cd soi
./goi_lenh.sh dung_canh.lua X5             # dựng cảnh + theo dõi tới khi có Máy Khoa Học
./goi_lenh.sh soi_ket.lua   SOI            # soi khi nghi dân làng kẹt
docker stop dst-ailang-test                # XONG THÌ DỪNG
```

| tệp | việc |
|---|---|
| `goi_lenh.sh` | nhét một tệp Lua qua console rồi chờ đúng kết quả của lượt này |
| `dung_canh.lua` | rải cỏ/cành/cây/đá vàng quanh làng rồi theo dõi 26 lượt xem có lên tech 1 không |
| `soi_ket.lua` | in vị trí, trạng thái, hành động đang đệm, và **đo xem 8 giây đi được bao xa** |

## Hai cái bẫy đã dẫm

**Chú thích `--` trong kịch bản.** Lệnh bị ép về một dòng trước khi nhét qua
console, nên `--` nuốt sạch phần sau nó. Kịch bản gửi đi phải **không có chú
thích**.

**`docker logs` giữ log cũ qua các lần restart**, nên vòng chờ khớp ngay vào
dòng của lượt trước và in kết quả cũ ra như kết quả mới — đã mất hai lượt vì
chuyện này. `goi_lenh.sh` đếm số lần xuất hiện **trước khi gửi** rồi chờ số đó
tăng.

## Lưu ý về world

`tools/test/data` đã bị hàng chục lượt thử **vét sạch cỏ và cành** quanh làng.
Mà `ánh sáng` là nhu cầu ưu tiên số một và đuốc thì cháy hết liên tục — nên ở
world đó nó chiếm lượt vĩnh viễn và làng không bao giờ lên tech, **dù mã hoàn
toàn đúng**. Muốn kiểm thật thì xoá `tools/test/data/Master/save` cho nó sinh
world mới, hoặc vào game thật có client nối vào.

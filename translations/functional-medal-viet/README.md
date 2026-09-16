# Functional Medal Việt hoá — 能力勋章

Bản dịch tiếng Việt cho mod [**Functional Medal / 能力勋章**](https://steamcommunity.com/sharedfiles/filedetails/?id=1909182187)
của tác giả **恒子** — mod chủ đề "trưởng thành": huân chương trao năng lực,
kèm hệ nhiệm vụ/khảo thí, gia vị, cây trồng, tượng, đạn ná.

Trang chủ mod: <https://www.guanziheng.com/>

## Vì sao là mod CLIENT RIÊNG, không fork, không thêm thư mục ngôn ngữ

Mod gốc **hardcode đúng hai nhánh ngôn ngữ** (`modmain.lua:213`):

```lua
if TUNING.MEDAL_LANGUAGE == "ch" then require "lang/medal_strings_ch"
else                                 require "lang/medal_strings_eng" end
```

Không có móc mở rộng — khác Montfluv (mod đó nạp theo **tên thư mục** nên chỉ
cần thêm `translation_vi/`). Ở đây muốn thêm "vi" thì phải fork cả mod.

Nên cách sạch nhất là **ghi đè `STRINGS` sau khi mod gốc nạp xong**:

| | |
|---|---|
| Không đụng file mod gốc | Steam cập nhật mod gốc cũng không mất bản dịch |
| Mod client | Server không cần bật theo |
| Không cần fork | Không bắt người chơi tải lại cả mod |

## Server không chơi Functional Medal thì có lỗi không?

**Không, và không nhờ chốt chặn nào cả.** `STRINGS` là bảng toàn cục của game;
gán `STRINGS.NAMES.COOK_CERTIFICATE` khi mod gốc vắng mặt chỉ tạo ra một khoá
**không ai đọc tới**. An toàn tự nhiên — không cần `if mod tồn tại then`.

## Thứ tự nạp — chỗ dễ sai nhất

`scripts/mods.lua:557` sắp mod bằng `apriority > bpriority` cho `table.sort`,
tức **giảm dần: số LỚN nạp TRƯỚC, số NHỎ nạp SAU**.

- Functional Medal: `priority = -10001`
- Mod này: `priority = -10002` → nạp **sau** → ghi đè được

Nhưng chuỗi vẫn áp trong `AddSimPostInit` (chạy sau **mọi** modmain), nên đúng
kể cả khi tác giả mod gốc đổi `priority` ở bản sau.

## Quy trình

```bash
./tools/extract_strings.py     # rút chuỗi từ mod gốc + cơ chế từ wiki
# dịch trong strings_source.json (trường "vi")
./tools/make_anh.py            # assets/*_source.png -> modicon.tex/.xml + preview.png
./tools/build.py               # dựng build/functional-medal-vi/
./tools/sync_local.sh          # cài vào game để thử
./tools/sync_local.sh --clean  # gỡ
./tools/make_upload.sh         # đóng gói sạch sang upload/ để đẩy Workshop
```

### Ảnh

| file | cỡ | việc |
|---|---|---|
| `assets/icon_source.png` | 2048² | ảnh nguồn vuông (gitignore, 8 MB) |
| `assets/preview_source.png` | 2816×1536 | ảnh nguồn ngang (gitignore, 8 MB) |
| `assets/modicon.tex` + `.xml` | 256² | icon trong menu Mods |
| `assets/preview.png` | 1024×559 | ảnh trang Workshop |

`make_anh.py` tự hạ chất lượng preview tới khi **lọt dưới 1 MB** — Steam từ
chối ảnh preview lớn hơn thế. `make_upload.sh` kiểm lại lần nữa trước khi đóng
gói.

⚠ `modicon.tex/.xml` phải nằm **cạnh `modinfo.lua`**, không nằm trong thư mục
con — `modinfo` trỏ tới chúng bằng tên trần.

⚠ Dùng `tools/ktex.py` dùng chung ở gốc kho để ghi `.tex`. Chú thích trong đó
ghi lại một lỗi đắt: `platform` trong header KTEX **phải là 0**, đặt khác thì
game macOS sập ngay khi mở menu Mods, và không báo là lỗi mod.

`extract_strings.py` **giữ lại bản dịch cũ** khi chạy lại — mod gốc cập nhật
thì không mất công dịch.

## Nguồn đối chiếu

`wiki/medal_item_data.js` tải từ guanziheng.com — dữ liệu có cấu trúc: tên gốc
tiếng Trung, **mã prefab** (`item_code`, khớp thẳng với khoá `STRINGS`), cơ chế,
nguyên liệu, bàn chế, độ bền. 218 vật phẩm, khớp 213 khoá của mod.

Dùng để **hiểu cơ chế mà dịch cho đúng**, không phải để chép lại nội dung wiki.

## Gộp vào "DST Tiếng Việt" sau này

`scripts/medal_vi_strings.lua` cố ý là **file dữ liệu thuần** — không logic,
không phụ thuộc. Muốn gộp thì chỉ cần `require` nó trong `AddSimPostInit` của
mod kia, không phải làm lại gì.

(Bản thân mod này **không** `require` nó — xem bẫy manifest ở trên. File chỉ
tồn tại cho mục đích dùng lại.)

Hiện để riêng vì: mod gốc vá thường xuyên (1.6.8.1) nên gộp vào là mỗi lần nó
đổi chuỗi lại phải phát hành lại DST Tiếng Việt cho **toàn bộ** người dùng mod
đó; và DST Tiếng Việt dịch **game gốc** bằng `.po` + `LoadPOFile` — cơ chế khác
hẳn.

## Đăng Workshop

```bash
./tools/make_upload.sh
```

Rồi mở **Don't Starve Mod Tools → Mod Uploader**, chọn
`upload/functional-medal-vi`. Mod mới thì để trống ô Workshop ID.

`modinfo` ghi rõ mod gốc (tên, tác giả 恒子, Workshop ID 1909182187, trang chủ
guanziheng.com) và ghi rõ mọi công trạng nội dung thuộc về tác giả gốc — cùng
lối với các mod dịch khác trong kho.

Upload xong nhớ điền Workshop ID vào bảng mod trong `README.md` ở gốc kho.

## Tiến độ — 856/856 (100%)

| | |
|---|---|
| 386 | tên vật phẩm |
| 166 | mô tả công thức |
| 304 | lời nhân vật khi soi đồ |

Bảng thuật ngữ bám theo bản dịch game gốc trong
`translations/dst-tieng-viet/vietnamese.po`: Đá cẩm thạch, Nhân Sâm, Củ Thịt,
Ong Chúa, Ngọc Lam/Lục, Pha Lê Trăng, Vợt côn trùng, Xẻng, Ba Lô, Rương, và
tên rau quả.

Thuật ngữ riêng của mod, giữ nhất quán xuyên suốt:

| gốc | Việt |
|---|---|
| 勋章 | Huân chương |
| 时空 | Thời Không |
| 本源 | Bản Nguyên |
| 蓝晶 / 红晶 | Lam Tinh / Hồng Tinh |
| 凋零 | Điêu Linh |

Thành ngữ Trung dịch theo **nghĩa** sang thành ngữ Việt tương đương chứ không
dịch chữ: 熟能生巧 → *Trăm hay không bằng tay quen*, 只要功夫深铁杵磨成针 →
*Có công mài sắt có ngày nên kim*, 沉默是金 → *Im lặng là vàng*.

⚠ Một chỗ **cố ý lệch** với `.po` cũ: ở đó `Hammer` dịch là "Đập" (động từ),
danh từ phải là **"Búa"**. Mod này dùng "Búa Pha Lê Trăng". Đáng xem lại bên
`dst-tieng-viet`.

## ⚠ Bẫy đã mất một lần upload: môi trường mod KHÔNG có `pcall`

DST chỉ cấp cho `modmain` đúng mấy thứ này (`scripts/mods.lua:369`):

```
pairs  ipairs  print  math  table  type  string  tostring  require  Class
TUNING  GLOBAL  modname  MODROOT
```

**Không có `pcall`**, không có `os`, không có `io`. Mọi thứ khác phải lấy qua
`GLOBAL`.

Bản 0.1.0 gọi thẳng `pcall(...)`. Cú pháp hoàn hảo, `luajit -bl` báo sạch, mod
lên Workshop trót lọt — rồi ném `attempt to call global 'pcall' (a nil value)`
**ngay trong `AddSimPostInit`**, tức đúng lúc người chơi vừa vào world.

Nhìn từ log server thì triệu chứng là:

```
[Join Announcement] <tên>
... 12-26 giây sau ...
Connection lost to <ip>
[P2P] Connection failed ... error code 4 (target user didn't respond)
```

Không một dòng nào nói là lỗi mod — rất dễ đổ oan cho đường truyền hoặc server.

**Cách chặn:** `tools/thu_modmain.lua` chạy `modmain` trong môi trường giả lập
dựng đúng theo `mods.lua:369`, và `make_upload.sh` gọi nó trước khi đóng gói.
Kiểm cú pháp không bắt được loại lỗi này.

## ⚠ Bẫy thứ hai: mod Workshop MẶC ĐỊNH BẬT MANIFEST

`scripts/mods.lua:566`:

```lua
if((mod.modinfo.forcemanifest == nil and IsWorkshopMod(mod.modname)) or ...)
    ManifestManager:LoadModManifest(mod.modname, mod.modinfo.version)
```

Khi manifest bật, **DST chỉ thấy file nằm trong manifest** — file nào không có
là `module not found`. Đây đúng là cái bẫy `montfluv-viet/README.md` đã ghi lại.

Bản 0.1.0/0.1.1 để bảng chuỗi ở `scripts/medal_vi_strings.lua` rồi
`require` nó. **Cài local thì chạy, tải từ Workshop thì hỏng.**

Chữa ở hai tầng:

1. `forcemanifest = false` trong `modinfo`
2. **Nhúng thẳng bảng chuỗi vào `modmain.lua`**, bỏ hẳn `require` — không còn
   file thứ hai để tìm thì không còn cả lớp rủi ro

`scripts/medal_vi_strings.lua` vẫn được sinh ra để dùng lại ở chỗ khác (xem
mục gộp vào DST Tiếng Việt), nhưng `modmain` **không phụ thuộc vào nó nữa**.

## Kiểm tự động khi dựng

`tools/build.py` từ chối dựng nếu **placeholder lệch**. Chuỗi gốc có
`{medal}` `{level}` `{food}` `{product}` `{item}` `{chest}` `{backpack}`
`{trap}`; dịch đánh rơi hoặc viết sai thì người chơi thấy nguyên chữ `{food}`
giữa câu. Hiện **0 lỗi trên 856 chuỗi**, 0 chuỗi còn sót chữ Hán, 0 chuỗi rỗng.

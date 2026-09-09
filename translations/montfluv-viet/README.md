# Montfluv Việt hoá — 山河表里

Bản dịch tiếng Việt cho mod [**[DST] Montfluv**](https://steamcommunity.com/sharedfiles/filedetails/?id=3401927745)
(山河表里) của tác giả 威吊 — mod chủ đề **Sơn Hải Kinh**: Động Thiên Tháp, Côn
Lôn long mạch, Chúc Long, Câu Mang, Chu Yếm, Khâm Nguyên…

## Vì sao KHÔNG fork như các mod khác

Mod này **đã có sẵn hệ đa ngôn ngữ**:

```lua
local translation = GetModConfigData("language")
require("shanhai_strings/translation_"..translation.."/strings")
```

```
scripts/shanhai_strings/
    strings.lua + 19 file nhân vật     ← tiếng Anh
    translation_ch/                    ← tiếng Trung
    translation_es/                    ← tiếng Tây Ban Nha (do cộng đồng đóng góp)
    translation_vi/                    ← BẢN NÀY
```

Nên chỉ cần **thêm một thư mục** và một dòng trong `modinfo`, thay vì fork cả
mod **193 MB** rồi bắt mọi người tải lại. Việc `translation_es` tồn tại cũng cho
thấy tác giả nhận đóng góp từ cộng đồng.

## Dùng thử

```bash
./tools/sync_local.sh          # dựng mod client + cài vào game
./tools/sync_local.sh --clean  # gỡ khỏi game
```

Trong game: **Mods → Client Mods → bật "Montfluv - Đừng Chết Đói :)"**.
Mod gốc (`workshop-3401927745`) để `language = "en"` — xem phần sách bên dưới.

Bản dịch là **mod client riêng**, không đụng vào file của mod gốc, nên Steam
cập nhật mod gốc cũng không mất.

⚠ Script phải cài qua **Finder** (`osascript`). macOS App Management chặn GHI
vào `dontstarve_steam.app/Contents/` từ dòng lệnh — kể cả `sudo` — nhưng
KHÔNG chặn XOÁ. `rsync --delete` vì thế xoá sạch mod rồi không chép lại được:
đã mất trắng một mod đã cài vì lỗi này.

## Cấu trúc

| | |
|---|---|
| `vendor/` | nguồn gốc, **chỉ chép file Lua** (1,2 MB thay vì 193 MB) |
| `strings_source.json` | 1.495 chuỗi, khoá là chuỗi Hán, kèm tham chiếu bản tiếng Anh |
| `build/shanhai_strings/translation_vi/` | 20 file sinh ra, sẵn sàng nộp cho tác giả |
| `tools/extract_strings.py` | trích chuỗi Hán từ `translation_ch/` |
| `tools/apply_vi.py` | ghi bản dịch vào `strings_source.json` |
| `tools/next.py` | in lô chưa dịch tiếp theo |
| `tools/build.py` | sinh `translation_vi/`, kiểm lỗi định dạng trước khi ghi |
| `tools/sync_local.sh` | dựng mod client + cài vào game (qua Finder) |
| `tools/extract_desc.py` | trích 104 trang sách + 15 nhãn ra `desc_source.json` |
| `tools/next_desc.py` | in lô trang sách chưa dịch |
| `tools/apply_desc.py` | ghi bản dịch sách vào `desc_source.json` |
| `tools/build_desc_lua.py` | sinh `scripts/shanhai_desc_vi.lua` cho mod client |
| `tools/build_client_mod.py` | đóng gói mod client (tự gọi `build_desc_lua.py`) |
| `tools/make_upload.sh` | dựng `upload/montfluv-vi` đông cứng để đẩy Workshop |

## Quy ước dịch

- **Tên riêng thần thoại dùng âm Hán-Việt**: Chúc Long, Câu Mang, Chu Yếm, Khâm
  Nguyên, Côn Bằng, Tức Nhưỡng, Động Thiên Tháp, Huyền Hà. Người Việt đọc ra
  ngay điển tích; dịch qua tiếng Anh (Zhulong, Goumang…) là mất sạch.
- **Vật thường dùng tiếng Việt thuần**: linh chi, bạch quả, sâm núi, vẹm.
- **Ngũ âm** 宫商角徵羽 → Cung Thương Giốc Chuỷ Vũ (thuật ngữ nhạc lý có sẵn).
- **NPC heo** giữ giọng nho sĩ rởm mà tham ăn; **NPC quạ** tự xưng "Quạ".
- Dịch từ **bản tiếng Trung**, đối chiếu bản tiếng Anh của tác giả khi mơ hồ.
- Comment trong file giữ nguyên tiếng Trung để nộp ngược lên cho tác giả.

## Sách "Cuộn Tranh Sơn Hà" — hệ thống văn bản THỨ HAI

Sách hướng dẫn trong mod (prefab `sh_desc`, lấy bằng `c_give("sh_desc")`)
**không đi qua `STRINGS`**. Nó có đường dữ liệu riêng:

```
sh_desc_contents.lua:2     local sh_lan = TUNING.SHANHE_LAN or "ch"
                           local desc_contents = require("shanhai_defs/sh_desc_"..sh_lan)
sh_desc_contents.lua:1757  v.description = desc_contents[u]   -- COPY lúc nạp
sh_desc_animpage.lua:506   body:SetMultilineTruncatedString(data.desc_def.description, ...)
```

Vì text được **copy lúc nạp**, sửa bảng ngôn ngữ sau đó là vô ích — phải vá
thẳng bảng def đã dựng. Làm được vì `mods.lua:567` prepend `package.path` của
từng mod vào một `package.path` **dùng chung**, nên `require("shanhai_defs/…")`
từ mod client vẫn trỏ đúng file của Montfluv, và `package.loaded` là chung.

Bảng nạp **lười** (chỉ khi mở sách), nên mod client `require` hộ ở postinit —
lúc đó `TUNING.SHANHE_LAN` đã được `init_tuning.lua` của mod gốc đặt.

Còn **31 nhãn UI** thì hardcode trong widget dạng `SH_IS_CH and "中文" or
"English"`, bản dịch không với tới.

Móc `_ctor` là **hụt**: phần lớn nhãn (`desc`, `type`, `recipe`, `location`,
`attitude`) do `ShDescAnimPage:PopulateRecipeDetailPanel` dựng — chạy lại mỗi
lần bấm một mục, không phải lúc khởi tạo. Nên chặn ở tầng dưới cùng:
`Text:SetString` **và** `Text:SetMultilineTruncatedString` (hàm sau gọi thẳng
`inst.TextWidget:SetString`, không đi qua hàm trước). Chỉ dịch khi chắc chắn ở
trong sách — đang chạy trong một phương thức của 5 lớp widget sách, hoặc widget
có tổ tiên mang dấu `__montfluv_vi_sach` — nên `OK`, `type`, `desc` không đụng
phần còn lại của game.

## Trạng thái

**1.495/1.495 chuỗi (100%)** · 20 file · kiểm cú pháp bằng LuaJIT (Lua 5.1,
đúng bản DST dùng) · không còn chuỗi Hán nào trong phần mã.

**Sách: 104/104 trang · 15/15 nhãn địa điểm/loại · 31/31 nhãn UI.** Đã mô phỏng
ngoài game bằng LuaJIT: vá trúng 101 mục (3 mục còn lại — `dsc_light`,
`sh_seanest`, `sh_fsm_monkey_zhuyan` — chỉ hiện khi bật đúng cấu hình hoặc mod
`山海秘藏`), không mục nào thiếu bản dịch.

## Phát hành lên Workshop

```bash
./tools/make_upload.sh          # dựng + kiểm + đông cứng vào upload/montfluv-vi
```

Ảnh do kimdat546 vẽ, đặt ở `assets/`. Dựng lại bộ ảnh bằng tool dùng chung:

```bash
python3 ../../tools/make_modicon.py <ảnh_gốc> assets
```

| File | Kích thước | Dùng cho |
|---|---|---|
| `assets/modicon.png` | 256×256 | bản xem lại, để dựng lại `.tex` |
| `assets/modicon.tex` | 256×256 DXT5 | icon trong danh sách mod của DST |
| `assets/modicon.xml` | — | atlas 1 phần tử, `modinfo.lua` trỏ vào |
| `assets/preview.png` | 1024×1024, 430 KB | ảnh trang Workshop (Steam chặn > 1 MB) |

Preview lưu dạng PNG bảng 256 màu chứ không phải JPEG: tranh là line-art nền
phẳng, JPEG gây quầng ở nét viền, còn 256 màu thì gần như không phân biệt được
với bản gốc mà chỉ nặng 430 KB thay vì 1,7 MB.

`make_upload.sh` chặn phát hành nếu thiếu `modicon.*`, `preview.png`, nếu
`modinfo` quên `icon_atlas`, nếu mod không còn `client_only_mod`, hoặc nếu
preview vượt 1 MB. Kiểm cú pháp bằng **LuaJIT** chứ không phải `luac` — `luac`
trên máy là 5.5, không bắt được cú pháp Lua 5.1 không hợp lệ.

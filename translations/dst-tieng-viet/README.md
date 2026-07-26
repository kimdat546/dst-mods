# DST Tiếng Việt - Đừng Chết Đói :)

Workshop ID: **3683660917**
Tác giả: Datgavl

---

## Cấu trúc project

```
update-mods/          ← thư mục làm việc (repo này)
├── scripts/
│   ├── main.lua                     ← logic load PO + hook STRINGS
│   └── textfix/
│       ├── init.lua                 ← hook TextWidget.SetString
│       ├── ui_gamesetup.lua         ← dịch UI tĩnh (game modes, worldgen)
│       └── character_speech.lua    ← dịch skill tree, character speech
├── vietnamese.po                    ← file dịch chính (84,968 entries)
├── modinfo.lua                      ← thông tin mod (tên, version, author)
├── modmain.lua                      ← entry point của mod
├── DST_Vietnamese.tex / .xml        ← icon mod
├── preview.png                      ← ảnh preview Workshop
├── mod.manifest                     ← manifest cho Mod Tools
│
├── game_source/                     ← nguồn game để tham khảo (KHÔNG upload)
│   └── strings.pot                  ← template dịch của game
├── tools/                           ← công cụ kiểm tra (KHÔNG upload)
│   ├── sync_check.py                ← phát hiện string mới khi game update
│   └── quality_check.py             ← kiểm tra lỗi format string
└── sync_reports/                    ← báo cáo sync (KHÔNG upload)
```

---

## Files cần upload lên Workshop

Chỉ upload đúng các file sau (không thêm thứ khác):

```
modinfo.lua
modmain.lua
vietnamese.po
DST_Vietnamese.tex
DST_Vietnamese.xml
mod.manifest
preview.png
scripts/
  main.lua
  textfix/
    init.lua
    ui_gamesetup.lua
    character_speech.lua
```

Thư mục `dst-viet-mod/` tại `/Users/kimdat546/Desktop/dst-viet-mod/` là bản sạch chứa đúng các file trên, dùng để upload.

---

## Cách upload / update mod lên Steam Workshop

### Bước 1 — Sửa nội dung
Chỉnh sửa trong thư mục `update-mods/` (repo này).

### Bước 2 — Sync sang thư mục upload sạch

Chạy lệnh sau để copy file cần thiết vào `dst-viet-mod/`:

```bash
rsync -av \
  modinfo.lua modmain.lua vietnamese.po \
  DST_Vietnamese.tex DST_Vietnamese.xml \
  mod.manifest preview.png \
  /Users/kimdat546/Desktop/dst-viet-mod/

rsync -av --delete scripts/ /Users/kimdat546/Desktop/dst-viet-mod/scripts/
```

### Bước 3 — Cập nhật version trong modinfo.lua

Mở `/Users/kimdat546/Desktop/dst-viet-mod/modinfo.lua` và cập nhật:
- `version` → tăng số (ví dụ `"2026.2"` → `"2026.3"`)
- `description` → cập nhật ngày trong dòng "Cập nhật lần cuối ngày..."

### Bước 4 — Upload bằng Don't Starve Mod Tools

1. Mở **Steam** → **Library** → tìm **Don't Starve Mod Tools** → **Play**
2. Chọn **Upload Existing Mod**
3. Chọn thư mục: `/Users/kimdat546/Desktop/dst-viet-mod/`
4. Nhập Workshop ID: `3683660917`
5. Nhấn **Upload**

---

## Khi game có update mới (phát hiện string chưa dịch)

```bash
# Bước 1: Lấy strings.pot mới từ game (giải nén từ scripts.zip)
# File ở: ~/Library/Application Support/Steam/steamapps/common/
#          Don't Starve Together/dontstarve_steam.app/Contents/data/databundles/scripts.zip

# Bước 2: Chạy sync check
python3 tools/sync_check.py game_source/strings.pot vietnamese.po --output-dir sync_reports/

# Bước 3: Xem báo cáo
open sync_reports/
```

---

## Kiểm tra chất lượng bản dịch

```bash
python3 tools/quality_check.py vietnamese.po --format-only
```

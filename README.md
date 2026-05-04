# Đăng Tiên - Tiếng Việt

Bản dịch tiếng Việt cho mod Don't Starve Together **【登仙】 (Đăng Tiên)** — Workshop ID: `3235319974`.

## Trạng thái

🚧 **Alpha (v0.1.0)** — đang phát triển.

## Kiến trúc

Mod nguồn bị mã hóa ~95% (modmain + 273/274 prefab là bytecode binary). Pattern dịch dùng 2 lớp:

1. **TextWidget hook** (render-time) — bắt mọi text khi UI hiển thị
2. **STRINGS overrides** (load-time, sau `AddSimPostInit`) — gán `STRINGS.NAMES.*`, `RECIPE_DESC.*`, v.v.

Mod dịch có `priority = -10000`, load **sau** mod gốc (priority `-10`), nên override luôn thắng.

## Cấu trúc

```
dang-tien-vietnamese/
├── modinfo.lua              # priority=-10000, options DEBUG_*
├── modmain.lua              # entry, đọc config, gọi scripts/main.lua
└── scripts/
    ├── main.lua             # TextWidget hook + helpers (set_str, has_chinese)
    ├── strings_scanner.lua  # debug: dump STRINGS có Hán tự
    ├── wiki_glossary.lua    # tên chuẩn từ dang-tien.pdf (CN ↔ VN)
    ├── textfix_*.lua        # (sẽ tạo) các bảng dịch theo phase
    └── phase*_strings.lua   # (sẽ tạo) STRINGS.* override
```

## Workflow

### Lần đầu — chạy scanner để gom string

1. Cài mod nguồn 【登仙】 + mod này (link symlink dev folder vào `mods/`)
2. Bật game → Mods → cấu hình mod này → **Bật scanner** (DEBUG_SCANNER = true)
3. Tạo world bất kỳ, chờ load xong, vào game
4. Thoát game
5. Lấy log:
   ```bash
   grep "\[DangTienScan\]" \
     ~/Documents/Klei/DoNotStarveTogether/client_log.txt > scanner.txt
   ```
6. File `scanner.txt` sẽ chứa các dòng:
   ```
   [DangTienScan] CN | STRINGS.NAMES.XD_BAIHU = 残神白虎
   [DangTienScan] EN | STRINGS.NAMES.XD_FOO   = ...
   ```

### Sau khi có scanner.txt

Chia thành các phase và dịch dần (xem TaskList).

## Quick install (dev)

```bash
ln -s /Users/kimdat546/Desktop/dang-tien-vietnamese \
      "$HOME/Documents/Klei/DoNotStarveTogether/mods/dang-tien-vietnamese"
```

## TODO ngay

- [ ] Tạo `modicon.tex` / `modicon.xml` (preview 64x64)
- [ ] Tạo `preview.png` 512x512 cho Workshop
- [ ] Đọc đầy đủ PDF 83 trang, mở rộng `wiki_glossary.lua`
- [ ] User chạy game lần 1 với scanner → `scanner.txt`
- [ ] Phase 1: dịch `STRINGS.NAMES.XD_*`
- [ ] Phase 2: dịch cảnh giới, pháp bảo, đan dược
- [ ] Phase 3: dịch 9 file speech (~56k strings)
- [ ] Phase 4: `fallback_textfix.lua` auto-gen + MISSING logger
- [ ] Phase 5: upload Workshop

## Source mod info

- Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3235319974
- Tên: 【登仙】
- Tác giả: 薪人小黄、路障僵尸、吃不吃大肉丸子
- Phiên bản: 18.0
- Local path: `~/Library/Application Support/Steam/steamapps/workshop/content/322330/3235319974/`

---
name: dst-workspace-tools
description: Use BEFORE writing any script, installing a mod build into the game, uploading to Workshop, extracting/replacing strings, converting .tex art, or touching the DST server — this workspace already has tools for all of it. Also covers the macOS App Management trap that silently destroys a local mod install.
---

# Công cụ có sẵn trong workspace dst-mods

**Quy tắc số một: trước khi viết bất kỳ script nào, hoặc trước khi tự tay
copy/rsync/xoá file, hãy `ls tools/` ở gốc workspace VÀ `ls <mod>/tools/`.**
Gần như mọi việc lặp lại đều đã có công cụ, và chúng đã xử lý sẵn những cái bẫy
mà làm tay sẽ vấp.

## Bẫy chết người: KHÔNG bao giờ tự ghi vào thư mục mod của game

Thư mục mod của DST nằm **bên trong** `dontstarve_steam.app`:

```
~/Library/Application Support/Steam/steamapps/common/Don't Starve Together/
    dontstarve_steam.app/Contents/mods/<tên-mod>/
```

macOS (App Management) **chặn mọi tiến trình dòng lệnh ghi vào đó** — kể cả
`sudo`, kể cả khi đã tắt sandbox. `rsync`, `cp`, `cat >` đều trả
`Operation not permitted`. Nhưng **thao tác XOÁ lại thành công**.

Hậu quả nếu làm tay: `rsync --delete` xoá sạch thư mục rồi không ghi lại được →
hỏng bản mod đang chơi. Đã xảy ra thật (7/9/2026, mất 128/181 file).

**Luôn dùng `<mod>/tools/sync_local.sh`.** Nó đi vòng qua Finder bằng `osascript`
— Finder có entitlement mà dòng lệnh không có. Mọi mod trong workspace đều có
script này và cách dùng giống hệt nhau:

```bash
./tools/sync_local.sh            # dựng + cài vào game
./tools/sync_local.sh --clean    # gỡ ra
```

Nó tự chạy build, tự `luac -p` toàn bộ file Lua, rồi mới cài. Cài xong **phải
khởi động lại DST** — engine chỉ quét thư mục mod một lần lúc mở game.

## Công cụ dùng chung — `tools/` ở gốc workspace

Xem `tools/README.md` để biết chi tiết API.

| Công cụ | Việc |
|---|---|
| `ktex.py` | `.tex` của Klei ↔ PNG (đọc/ghi) |
| `make_atlas.py` | gộp nhiều PNG thành một atlas `.tex` + `.xml` |
| `dstmod.py` | điều khiển DST Mod Tool qua IPC (đọc/sửa/render hoạt ảnh) |
| `patch_workshop_mods.py` | vá mod Workshop lỗi làm sập server (Steam hay ghi đè lại) |
| `giu_log_dst.sh` | giữ `client_log.txt` của phiên crash — DST **cắt trắng log mỗi lần mở game**, không chạy cái này thì phân tích nhầm log của phiên sau |

## Công cụ theo từng mod — `<mod>/tools/`

Mọi mod đều có cùng bộ khung. Tên khác nhau chút giữa các mod, `ls` để chắc:

| Việc | Script |
|---|---|
| Cài vào game để thử | `sync_local.sh` |
| Dựng thư mục sạch để lên Workshop | `make_upload.sh` hoặc `prepare_upload.sh` |
| Dựng bản mod từ nguồn + bản dịch | `build.py` |
| Cập nhật `vendor/` từ bản Workshop trên máy | `fetch_vendor.sh` |
| Trích chuỗi cần dịch | `extract_strings.py` |
| Ghi bản dịch vào `strings_source.json` | `apply_vi.py` |
| Dò chữ tiếng Việt tràn khung UI | `check_layout.py` |
| Sinh wiki tra cứu offline | `build_wiki_data.py` → `build_wiki_html.py` |
| Cắt sprite khỏi `anim/*.zip` | `anim_sprite.py` (newconstant-viet) |
| Cắt ảnh vật phẩm khỏi atlas | `extract_images.py` (newconstant-viet) |
| Sinh `preview.png` 512×512 cho Workshop | `make_preview.py` (newconstant-viet) |

## Kiến trúc bản dịch: vendor/ bất khả xâm phạm

Quy ước đã ghi trong `build.py`:

> `vendor/` phải giữ đúng bản gốc để còn diff khi tác giả cập nhật.

- `vendor/` — mã nguồn gốc, **không sửa trực tiếp bao giờ**
- `strings_source.json` — bảng dịch, `build.py` thay chuỗi khi dựng
- `patches.json` — vá mã nguồn có chủ đích, mỗi mục kèm trường `vi_sao`
- `addons/` — mã mở rộng do mình viết, `build.py` chép đè lên build
- `assets/` — preview.png và tài nguyên riêng
- `build/` — kết quả, sinh ra được, đừng sửa tay

Thêm tính năng mới thì viết file trong `addons/`, **không** vá vào `vendor/`.

## Server DST — `_infra/dst-server-docker/cli/dst`

Repo **riêng**, không nằm trong monorepo (nó dùng branch làm cấu hình từng world).

```bash
./cli/dst switch <branch>    # đổi world (mỗi world = một git branch)
./cli/dst restart --fresh    # dựng lại container, kéo mod mới
./cli/dst rollback <ngày>
./cli/dst console '<lệnh lua>'
```

Bot Discord dùng chung cho mọi world, webhook ở `bot/.bot.env` (không phải
`.env`). Xem `docs/chay-song-song-hai-world.md` để chạy hai world cùng lúc.

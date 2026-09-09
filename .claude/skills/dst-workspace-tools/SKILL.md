---
name: dst-workspace-tools
description: Use BEFORE writing any script, installing a mod build into the game, uploading to Workshop, extracting/replacing strings, converting .tex art, making a modicon, running a local headless test server, or touching the DST server — this workspace already has tools for all of it. Also covers choosing between the three mod-translation approaches (fork / runtime hook / client mod), the mod.manifest trap, DST mod load order, and the macOS App Management trap that silently destroys a local mod install.
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

Nó tự chạy build, tự kiểm cú pháp toàn bộ file Lua, rồi mới cài. Cài xong
**phải khởi động lại DST** — engine chỉ quét thư mục mod một lần lúc mở game.

⚠ **Kiểm cú pháp phải dùng `luajit -bl`, KHÔNG dùng `luac -p`.** `luac` trên máy
này là **Lua 5.5**; nó nhận cú pháp mà DST (Lua 5.1) từ chối, nên "hợp lệ" theo
`luac` vẫn có thể làm sập mod. LuaJIT đúng là 5.1. Script nào còn dùng `luac -p`
thì nên đổi.

## Công cụ dùng chung — `tools/` ở gốc workspace

Xem `tools/README.md` để biết chi tiết API.

| Công cụ | Việc |
|---|---|
| `ktex.py` | `.tex` của Klei ↔ PNG (đọc/ghi) |
| `make_atlas.py` | gộp nhiều PNG thành một atlas `.tex` + `.xml` |
| `dstmod.py` | điều khiển DST Mod Tool qua IPC (đọc/sửa/render hoạt ảnh) |
| `patch_workshop_mods.py` | vá mod Workshop lỗi làm sập server (Steam hay ghi đè lại) |
| `giu_log_dst.sh` | giữ `client_log.txt` của phiên crash — DST **cắt trắng log mỗi lần mở game**, không chạy cái này thì phân tích nhầm log của phiên sau |
| `make_modicon.py` | ảnh bất kỳ → `modicon.tex/.xml/.png` + `preview.png` ép dưới 1 MB cho Workshop |
| `doc_web.py` | đọc wiki dựng bằng JS (Playwright). `curl` chỉ trả khung rỗng ~418 byte; browser MCP trả `{"error":"browser_disabled"}` |

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

**Git:** `vendor/` CÓ trong git (cần bản gốc để đối chiếu và diff khi tác giả
cập nhật). `build/` và `upload/` thì KHÔNG — sinh lại được. Mỗi mod tự khai
trong `<mod>/.gitignore` hoặc trong `.gitignore` gốc.

## Ba kiểu dịch mod — chọn đúng kiểu trước khi bắt đầu

| Mã nguồn mod | Cách làm |
|---|---|
| **Đọc được, mình dựng lại** | Fork: `vendor/` + `strings_source.json` + `build.py`. Ví dụ: than-binh-phu-an, newconstant. |
| **Bytecode / mã hoá** | Móc lúc chạy: `priority = -10000`, ghi đè `STRINGS.*` trong `AddSimPostInit`, móc `TextWidget.SetString`. Ví dụ: 登仙. |
| **Đọc được nhưng KHÔNG nên fork** | **Mod client riêng.** Ví dụ: montfluv (mod gốc 193 MB, có sẵn hệ đa ngôn ngữ). |

### Vì sao có kiểu thứ ba: `mod.manifest`

Mod tải từ Workshop mang theo `mod.manifest` — danh mục file nhị phân. **DST chỉ
thấy file có tên trong đó.**

- Thêm thư mục mới vào mod đã tải → `module '...' not found`
- Xoá `mod.manifest` cho xong → hỏng luôn asset (`Could not find levels/tiles/jungle.tex`)

Manifest quản cả Lua lẫn tài nguyên nên không gỡ được. Mod client tự có manifest
riêng nên không vướng.

### Mod client vá được cả bảng nội bộ của mod khác

`mods.lua:567` prepend `package.path` của **từng** mod vào một `package.path`
**dùng chung**, và `package.loaded` cũng dùng chung. Nên từ mod client:

```lua
local bang = require("shanhai_defs/sh_desc_contents")  -- file của MOD KHÁC
```

vẫn trỏ đúng, và sửa bảng đó thì mod gốc nhận được. Hai điều kiện:

- **Phải chạy ở postinit**, không phải lúc nạp modmain: path của mod kia chỉ
  được thêm vào ngay trước khi modmain của NÓ chạy.
- Nếu mod kia **copy** giá trị lúc nạp (không đọc lười) thì phải vá bảng ĐÍCH,
  vá bảng nguồn là vô ích.

### Thứ tự nạp mod: `priority` KHÔNG quyết định

Đã đo với cả `-9999` lẫn `9999`: DST xếp theo **tên thư mục**. Đừng dựa vào thứ
tự — áp bản dịch ở **cả ba mốc** (nạp modmain, `AddSimPostInit`,
`AddGamePostInit`), xoá `package.loaded[...]` trước mỗi lần để gọi lại vẫn ăn.
Trên dedicated server `AddGamePostInit` chạy **sau** `AddSimPostInit`.

### Chuỗi hardcode trong widget thì móc `Text`

Nhiều mod viết `local ten = LA_TIENG_TRUNG and "中文" or "English"` ngay trong
widget — bản dịch không với tới. Móc `_ctor` (`AddClassPostConstruct`) là **hụt**
nếu nhãn do một phương thức dựng lại mỗi lần bấm. Móc `Text:SetString` **và**
`Text:SetMultilineTruncatedString` (hàm sau gọi thẳng `inst.TextWidget:SetString`,
không đi qua hàm trước), rồi giới hạn phạm vi bằng cờ "đang trong widget của mod
đó" để không đụng phần còn lại của game.

## Server test cục bộ — thử mod trước khi đưa người chơi

`<mod>/tools/test/` chạy một server headless **offline, chỉ bật đúng mod đang
làm**, nên lỗi hiện sạch không lẫn mod khác. Ảnh Docker và script container dùng
chung, nằm ở `translations/dang-tien-viet/tools/test-harness/` (có README riêng).

```
<mod>/tools/test/
    compose.yml                    # mount build/<mod> vào /usr/share/game/mods
    test.env                       # GITIGNORE — có DST_CLUSTER_TOKEN
    test.env.example               # bản mẫu, có trong git
    config/Master/modoverrides.lua # chỉ bật đúng mod này
    data/                          # GITIGNORE — runtime container ghi vào
```

Ảnh phải là **linux/amd64** (`platform: linux/amd64`) — DST server không có bản
arm64, trên máy Apple Silicon chạy qua Rosetta/QEMU.

Dùng để làm gì: bắt `MOD ERROR` / `LUA ERROR` lúc nạp, kiểm chuỗi đã thay đúng
chưa (`grep` log), thử RPC và prefab phía server. **Không** thử được UI/widget —
headless không vẽ, phần đó phải vào game thật.

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

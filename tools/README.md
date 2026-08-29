# tools/ — công cụ dùng chung cho mọi mod

Gom về đây 2026-08-26. Trước đó rải trong `tools/` của từng mod, mỗi nơi một
bản, sửa một chỗ không lan sang chỗ khác.

| Công cụ | Việc |
|---|---|
| `ktex.py` | `.tex` của Klei ↔ PNG |
| `make_atlas.py` | gộp nhiều PNG thành một atlas `.tex` + `.xml` |
| `dstmod.py` | điều khiển DST Mod Tool qua IPC (đọc/sửa/render hoạt ảnh) |
| `patch_workshop_mods.py` | vá lại mod Workshop lỗi làm sập server (Steam hay ghi đè) |

---

## `ktex.py` — đọc/ghi ảnh .tex

```python
import sys; sys.path.insert(0, 'tools')
import ktex
img, info = ktex.read('a.tex')     # → (PIL.Image, "DXT5 2048x1024")
ktex.write(img, 'b.tex', 'DXT5')   # PIL.Image → .tex
```

Không cần cài `ktech` của Klei. Cách làm: đọc header KTEX, lấy mipmap lớn
nhất, bọc lại thành header DDS rồi để Pillow giải nén DXT.

Kích thước phải là **bội của 4** (yêu cầu của DXT).

> `translations/newconstant-viet/tools/ktex.py` giờ chỉ là **cầu nối** trỏ về
> file này, vì `build.py`, `make_preview.py`, `extract_images.py`,
> `anim_sprite.py` đều `from ktex import ...` theo đường dẫn cùng thư mục.

## `make_atlas.py` — làm atlas icon

```bash
python3 tools/make_atlas.py <thư_mục_png> <tên_atlas> <thư_mục_ra>
```

Gom mọi PNG trong thư mục, xếp lưới, làm tròn lên luỹ thừa của 2, xuất
`.tex` + `.xml`, rồi in danh sách tên để dán vào code.

**Hai điều dễ sai, đã xử sẵn trong tool:**

1. `image = "x.tex"` trong code là **tên `<Element>` trong xml**, KHÔNG phải
   file trên đĩa. Một `.tex` chứa 264 icon thì có 264 Element.
2. Trục **`v` tính từ ĐÁY lên** (quy ước OpenGL). Kiểm chứng bằng atlas của
   mod 景熹家居: icon `jx_potted` có `v1=0.8716 v2=0.9331`; cắt theo chiều từ
   đỉnh ra ô rỗng, cắt từ đáy mới ra đúng icon.

## `dstmod.py` — điều khiển DST Mod Tool

```bash
python3 tools/dstmod.py info                                  # đọc document đang mở
python3 tools/dstmod.py render <bank> <anim> <frame> <ra.png> # render 1 frame
python3 tools/dstmod.py lua script.lua                        # chạy Lua tuỳ ý
python3 tools/dstmod.py lua -                                 # Lua từ stdin
python3 tools/dstmod.py doc                                   # in tài liệu API (1092 dòng)
```

Dùng trong Python:
```python
import sys; sys.path.insert(0, 'tools')
import dstmod
dstmod.run('print(#doc.builds)')
dstmod.render('jx_potted', 'idle', 1, '/tmp/xem.png')
```

**Điều kiện:** app phải đang chạy và có document mở sẵn. Script chạy trên
workspace hiện tại, không tự mở file.

**Không phải MCP** — chỉ là gọi binary rồi đọc JSON trả về. Nhưng bản thân
tool có hẳn chương *"Guide for AI Agents"* mô tả đúng cách dùng này, kể cả
`export_png` để agent render ra ảnh rồi tự nhìn.

---

## `patch_workshop_mods.py` — vá mod Workshop lỗi

```bash
python3 tools/patch_workshop_mods.py --check   # kiểm tra
python3 tools/patch_workshop_mods.py           # áp vá
```

Steam ghi đè thư mục Workshop mỗi lần mod cập nhật, cuốn theo bản vá tay →
chạy lại script sau mỗi lần Steam tải mod về. Idempotent, giữ `.bak` cạnh
file gốc.

**Vá hiện có — Raiden Shogun (2845021470)** *(2026-08-29)*

`raiden_descriptions.lua:25` làm `STRINGS.CHARACTERS.RAIDEN_SHOGUN =
require "speech_wilson"` **không deepcopy**. Vanilla `strings.lua:15581` cũng
là `STRINGS.CHARACTERS.GENERIC = require "speech_wilson"` → hai bảng là MỘT.
Gán tiếp `.ACTIONFAIL.COOK = "chuỗi"` (vanilla là table `{GENERIC, INUSE,
TOOFAR}`) làm hỏng `speech_wilson` cho toàn bộ game. Mod nhân vật nạp sau —
`3625940357` 腌笃鲜•神话书说 — index `.COOK.xxx` rồi sập cả server:

```
speech_xydztz_yutu.lua:34: attempt to index field 'COOK' (a string value)
→ Error loading main.lua → Failed mSimulation->Reset()
```

Vá bằng cách giữ `COOK` ở dạng table. **Không** sửa dòng 25 thành deepcopy:
Raiden sẽ mất mô tả mọi item của các mod nạp sau nó.

> Cùng lỗi tiềm ẩn: `2992200942` 枝江往事 gán `DIANA`/`BELLA =
> require "speech_winona"`, `AVAVA = require "speech_wurt"`. Chưa sửa field
> lồng nhau nào nên chưa nổ.

**Vá hiện có — Xuaner (3014076942)** *(2026-08-29)*

Xuaner (`priority=-9999999999`) nạp **trước** Don't Starve: Dehydrated
(`priority=-10000010001`). Cặp này làm server treo cứng — 100% CPU, log đứng
mãi ở `modimport: ../mods/workshop-3004639365/scripts/set_env`, không bao giờ
tới worldgen. Chạy riêng từng mod đều bình thường; chỉ khi đứng chung mới treo.
`modinfo.lua` của Xuaner bị obfuscate nên không truy được cơ chế, nhưng **đảo
thứ tự nạp là đủ**: hạ `priority` của Xuaner xuống `-10000010002` để nó nạp sau
Dehydrated.

Cách cô lập (dùng lại được cho lần sau): dựng cluster offline trong `/tmp`, chạy
thẳng `Contents/MacOS/dontstarve_dedicated_server_nullrenderer` với
`-persistent_storage_root /tmp/dst_test -cluster Cluster_TEST -shard Master`, rồi
bisect danh sách mod trong `modoverrides.lua`. Mốc phân biệt: log có
`Sim paused` là chạy được, dừng ở `set_env` là treo. Một lượt mất ~2 phút; tìm ra
cặp xung đột trong 5 lượt.

---

## Chưa gom (còn nằm trong từng mod, vì gắn chặt với mod đó)

```
translations/newconstant-viet/tools/   build.py, gen_lang.py, extract_strings.py,
                                       extract_images.py, anim_sprite.py,
                                       build_wiki_*.py, make_preview.py
*/tools/sync_local.sh                  cài mod vào game — mỗi bản hardcode MODNAME
*/tools/prepare_upload.sh              dựng thư mục build sạch để lên Workshop
*/tools/test-harness/                  server headless kiểm thử
```

`sync_local.sh` đáng gom nhất — bốn bản gần như giống hệt, chỉ khác `MODNAME`.
Nó đi vòng qua **Finder** bằng AppleScript vì macOS App Management chặn dòng
lệnh ghi vào trong `dontstarve_steam.app`.

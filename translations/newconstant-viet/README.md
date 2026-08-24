# NewConstant Việt — bản dựng lại

Bản dựng lại của **NewConstant** (永恒新界) cho Don't Starve Together, với hệ đa
ngôn ngữ đúng chuẩn và bản dịch tiếng Việt đầy đủ.

> **Nguồn gốc:** mod gốc do **莫非则** viết —
> [Core `3645179905`](https://steamcommunity.com/sharedfiles/filedetails/?id=3645179905) ·
> [Base `3191348907`](https://steamcommunity.com/sharedfiles/filedetails/?id=3191348907).
> Toàn bộ gameplay, assets, âm thanh là của tác giả gốc. Bản này **chỉ dùng
> local**. Muốn đưa lên Workshop thì phải xin phép 莫非则 trước.

## Vì sao dựng lại

Mod gốc mở nguồn hoàn toàn (157/157 file Lua đọc được) nhưng hệ ngôn ngữ có ba
vấn đề, đo được bằng công cụ trong `tools/`:

| Vấn đề | Số đo |
|---|---|
| Chỉ hỗ trợ 2 ngôn ngữ, nhánh cứng `if locale == "zh" … else` | không thêm ngôn ngữ mới được nếu không sửa `modmain` |
| Bản "tiếng Anh" chưa dịch xong — vẫn còn chữ Hán | **59 / 234 chuỗi** |
| Chuỗi có ở bản Trung nhưng thiếu hẳn ở bản Anh | **11 chuỗi** |

Tức người chơi không biết tiếng Trung đang thấy chữ Hán ở **70 chỗ**.

## Phạm vi — cái gì được dựng lại, cái gì giữ nguyên

**Dựng lại:**
- Hệ i18n: tách chuỗi khỏi code, một bảng phẳng cho mỗi ngôn ngữ, tự chọn theo
  locale, có chuỗi dự phòng (vi → en → zh) nên không bao giờ hiện `MISSING`
- Bản dịch tiếng Việt đầy đủ
- Công cụ trích chuỗi, sinh file ngôn ngữ, dựng bản chơi được, kiểm thử headless

**Giữ nguyên (vendor):** 157 file logic gameplay và toàn bộ assets.

Đây là quyết định có cân nhắc: viết lại logic gameplay đang chạy tốt thì **rủi ro
cao, lợi ích thấp, và không kiểm chứng hết được** ở quy mô 85 MB. Chỗ thật sự
hỏng là hệ ngôn ngữ, nên chỉ dựng lại đúng chỗ đó.

## Assets không nằm trong git

85 MB assets (73 MB riêng âm thanh) là của tác giả gốc và không delta-nén được —
đưa vào sẽ làm `.git` phình từ 34 MB lên gấp mấy lần. `tools/build.sh` lấy chúng
từ thư mục Workshop lúc dựng. Repo chỉ giữ phần việc của mình.

## Cấu trúc

```
scripts/ncvi/i18n.lua      bộ nạp ngôn ngữ + chuỗi dự phòng
scripts/ncvi/apply.lua     áp bảng phẳng vào cây STRINGS
lang/vi.lua  en.lua  zh.lua   bảng chuỗi, sinh tự động từ tools/
strings_source.json        chuỗi trích từ mod gốc (zh + en) — nguồn để dịch
translations/vi.json       bản dịch tiếng Việt do người sửa
tools/extract_strings.py   trích chuỗi từ mod gốc
tools/gen_lang.py          sinh lang/*.lua
tools/build.sh             ghép mod chơi được (vendor code + assets)
tools/test/                server headless kiểm thử
```

## Thêm một ngôn ngữ mới

Chép `translations/vi.json` thành `translations/<mã>.json`, dịch, chạy
`tools/gen_lang.py`. Không phải đụng vào `modmain.lua` — khác hẳn mod gốc.

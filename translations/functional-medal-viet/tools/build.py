#!/usr/bin/env python3
"""Dựng mod client Việt hoá từ strings_source.json + tools/modmain_mau.lua.

Sinh ra một thư mục mod hoàn chỉnh trong build/ để cài vào game hoặc upload.
"""

import json
import pathlib
import re
import shutil
import sys

GOC = pathlib.Path(__file__).resolve().parent.parent
RA = GOC / "build" / "functional-medal-vi"

UU_TIEN = -10002
PHIEN_BAN = "0.2.0"

# Nhóm chuỗi bị mod gốc COPY đi chỗ khác lúc nạp — xem modmain_mau.lua.
NHOM_BI_COPY = ("s:MEDAL_NEWACTION/", "s:MEDAL_ACTIONFAIL_SPEECH/")


def thoat_lua(s):
    return (s.replace("\\", "\\\\").replace('"', '\\"')
             .replace("\n", "\\n").replace("\r", ""))


def soat_placeholder(nguon):
    """Placeholder lệch là LỖI HIỂN THỊ THẬT: người chơi thấy nguyên chữ
    "{food}" giữa câu, hoặc string.format nổ vì thiếu %s."""
    loi = []
    for khoa, v in nguon.items():
        if not v.get("vi"):
            continue
        for mau in (r"\{(\w+)\}", r"%[-+ #0]*\d*(?:\.\d+)?[sdifgxc]"):
            a = sorted(re.findall(mau, v["en"]))
            b = sorted(re.findall(mau, v["vi"]))
            if a != b:
                loi.append(f"  {khoa}: gốc {a} -> dịch {b}")
    return loi


def main():
    nguon = json.loads((GOC / "strings_source.json").read_text(encoding="utf-8"))
    loi = soat_placeholder(nguon)
    if loi:
        print("✗ placeholder lệch — KHÔNG dựng:", file=sys.stderr)
        print("\n".join(loi), file=sys.stderr)
        return 1

    xong = {k: v for k, v in nguon.items() if v.get("vi")}
    if not xong:
        print("chưa có chuỗi nào được dịch — không dựng", file=sys.stderr)
        return 1

    def cap(loai):
        return "\n".join(
            f'  "{v["p"]}", "{thoat_lua(v["vi"])}",'
            for k, v in sorted(xong.items()) if v["loai"] == loai)

    ban_copy, da = [], set()
    for k, v in sorted(xong.items()):
        if v["p"].startswith(NHOM_BI_COPY) and v["en"] not in da:
            da.add(v["en"])
            ban_copy.append(f'  ["{thoat_lua(v["en"])}"] = "{thoat_lua(v["vi"])}",')

    RA.mkdir(parents=True, exist_ok=True)
    (RA / "scripts").mkdir(exist_ok=True)

    mau = (GOC / "tools" / "modmain_mau.lua").read_text(encoding="utf-8")
    modmain = (mau.replace("@@BANG@@", cap("strings"))
                  .replace("@@THI@@", cap("exam"))
                  .replace("@@BAN_COPY@@", "\n".join(ban_copy))
                  .replace("@@PHIEN_BAN@@", PHIEN_BAN))
    assert "@@" not in modmain, "còn chỗ trống chưa điền trong mẫu modmain"
    (RA / "modmain.lua").write_text(modmain, encoding="utf-8")

    # File dữ liệu thuần để GỘP vào mod khác sau này (vd. DST Tiếng Việt).
    # Bản thân modmain KHÔNG require nó.
    (RA / "scripts" / "medal_vi_strings.lua").write_text(
        "-- Bảng dịch Functional Medal — SINH TỰ ĐỘNG. Đường dẫn giữ kiểu khoá\n"
        "-- (s: chữ / n: số). Cách áp: xem Ghi() trong modmain.lua.\n"
        "return {\n strings = {\n" + cap("strings") + "\n },\n exam = {\n"
        + cap("exam") + "\n },\n}\n", encoding="utf-8")

    # ── modinfo ────────────────────────────────────────────────────────
    (RA / "modinfo.lua").write_text(
        f'''name = "Functional Medal - Đừng Chết Đói :)"
description = [[Bản dịch tiếng Việt cho mod Functional Medal (能力勋章).

Mod gốc của tác giả 恒子 — chủ đề "trưởng thành": huân chương trao năng lực,
kèm hệ nhiệm vụ, gia vị nấu ăn, cây ghép, tượng và đạn ná.

YÊU CẦU
- Phải sub và bật mod gốc trước: Functional Medal, Workshop ID 1909182187
- Trong cấu hình mod gốc để ngôn ngữ = English (language_switch)
- Mod này là MOD CLIENT, chỉ đổi chữ hiện trên máy bạn

BẢN THỬ NGHIỆM
Đã dịch toàn bộ: tên, công thức, lời soi đồ, tên hành động, giao diện,
nhiệm vụ, thoại, tên trang phục và 49 câu đề thi khảo hạch. Gặp chữ dịch sai,
chỗ còn tiếng Anh/tiếng Trung, hoặc game bị lỗi khi bật mod thì báo giúp ở
phần bình luận bên dưới — kèm tên vật phẩm hoặc ảnh chụp càng tốt.

GHI CHÚ
- Không đụng vào file mod gốc, nên Steam cập nhật mod gốc cũng không mất bản dịch
- Server không chơi Functional Medal thì mod này cũng không gây lỗi gì
- Trang chủ mod gốc: guanziheng.com

Tác giả bản dịch: kimdat546
Mọi công trạng về nội dung mod thuộc về tác giả gốc 恒子.]]
author = "kimdat546"
version = "{PHIEN_BAN}"
api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

-- Chữ hiện ở máy người chơi, nên đây là mod client. Server không cần bật.
all_clients_require_mod = false
client_only_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- Mod Workshop mặc định bật manifest (mods.lua:566). Mod này không đọc file
-- nào ngoài modmain nên không cần manifest; tắt cho khỏi phải nghĩ tới nó.
forcemanifest = false

-- Đặt nhỏ hơn -10001 (priority của mod gốc) cho đúng ý, nhưng ĐỪNG dựa vào nó:
-- đã đo được DST xếp thứ tự nạp theo TÊN THƯ MỤC. modmain tự áp chuỗi ở cả ba
-- mốc nên đúng bất kể thứ tự.
priority = {UU_TIEN}

server_filter_tags = {{"vn", "vietnam", "vietnamese", "medal", "kimdat546"}}

configuration_options = {{}}
'''
        , encoding="utf-8",
    )

    # ── ảnh ────────────────────────────────────────────────────────────
    #
    # ⚠ modicon.tex/.xml PHẢI nằm cạnh modinfo.lua, không nằm trong thư mục con
    #   — modinfo trỏ tới chúng bằng tên trần. preview.png thì Workshop đọc,
    #   game không dùng.
    thieu = []
    for ten in ("modicon.tex", "modicon.xml", "preview.png"):
        nguon_anh = GOC / "assets" / ten
        if nguon_anh.exists():
            shutil.copy2(nguon_anh, RA / ten)
        else:
            thieu.append(ten)
    if thieu:
        print("  ⚠ thiếu ảnh: " + ", ".join(thieu) + " — chạy tools/make_anh.py")

    tong = len(nguon)
    theo = {}
    for v in nguon.values():
        a = theo.setdefault(v["loai"], [0, 0]); a[0] += 1; a[1] += bool(v.get("vi"))
    print(f"đã dựng {RA}")
    print(f"  {len(xong)}/{tong} chuỗi ({len(xong) * 100 // tong}%)  "
          + "  ".join(f"{l}: {x}/{n}" for l, (n, x) in sorted(theo.items())))
    print(f"  {len(ban_copy)} chuỗi vá bản copy (hành động, thoại lỗi)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

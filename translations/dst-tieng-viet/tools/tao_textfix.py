#!/usr/bin/env python3
"""Dựng lại scripts/textfix/character_speech.lua TỪ vietnamese.po.

    python3 tools/tao_textfix.py

textfix là lớp dịch thứ hai: móc TextWidget.SetString, gặp chuỗi TIẾNG ANH nào
có trong bảng thì thay bằng tiếng Việt. Nó bắt được chữ không đi qua STRINGS
của máy mình — quan trọng nhất là THOẠI DO SERVER GỬI VỀ (world có hang / server
riêng không nạp mod client, câu nhân vật tới máy người chơi là tiếng Anh).

⚠ Trước đây bảng này là một bản dịch MÁY riêng, lệch hẳn .po (vd "BURN ITTTT!"
  → "ĐỐT CHÁY ITTTT!", còn giữ "Sữa dê diện"…). Giờ sinh từ .po nên hai lớp luôn
  khớp. Câu KHÔNG có trong strings.pot (câu ghép động, ~800 câu) nằm ở
  scripts/textfix/ngoai_po.lua, sửa tay ở đó.

Trùng tiếng Anh ở nhiều khoá (vd "Fish" vừa tên vừa hành động) → ưu tiên thoại
nhân vật, rồi NAMES, rồi theo thứ tự khoá.
"""

import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import po  # noqa: E402

GOC = pathlib.Path(__file__).resolve().parent.parent
RA = GOC / "scripts/textfix/character_speech.lua"


def lua(s):
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "")


def uu_tien(k):
    if ".CHARACTERS.GENERIC." in k:
        return (0, k)
    if ".CHARACTERS." in k:
        return (1, k)
    if k.startswith("STRINGS.NAMES."):
        return (2, k)
    return (3, k)


def main():
    _, mp = po.doc(GOC / "game_source/strings.pot")
    _, mv = po.doc(GOC / "vietnamese.po")
    V = {m.ctx: m.str for m in mv}

    bang = {}
    for m in sorted(mp, key=lambda m: uu_tien(m.ctx)):
        vi = V.get(m.ctx, "")
        en = m.id
        if not vi or vi == en or not re.search(r"[A-Za-z]", en) or len(en) < 2:
            continue
        if po.placeholder(en):       # chuỗi có %s/{x} được format trước khi hiện → không khớp nguyên văn
            continue
        bang.setdefault(en, vi)

    # Câu không có trong strings.pot (ghép động…) nằm TAY ở scripts/textfix/ngoai_po.lua.
    giu = 0
    dong = [
        "-- textfix/character_speech.lua — SINH TỰ ĐỘNG bởi tools/tao_textfix.py từ vietnamese.po.",
        "-- ĐỪNG SỬA TAY: sửa vietnamese.po rồi chạy lại tool. Xem docstring của tool.",
        "",
    ]
    # ⚠ Mỗi hàm Lua giới hạn số hằng số (LuaJIT 65536, Lua 5.1 262143). 67k dòng
    #   × 2 chuỗi vượt mức của LuaJIT → chia thành từng hàm con, mỗi hàm 15k dòng.
    muc = [f'    textfix["{lua(en)}"] = "{lua(vi)}"' for en, vi in sorted(bang.items())]
    for i in range(0, len(muc), 15000):
        dong.append("(function()")
        dong += muc[i:i + 15000]
        dong.append("end)();")  # `;` bắt buộc: không có thì "(function" kế tiếp bị hiểu là gọi tiếp
    RA.write_text("\n".join(dong) + "\n", encoding="utf-8")
    print(f"{RA.relative_to(GOC)}: {len(bang)} câu từ .po")


if __name__ == "__main__":
    main()

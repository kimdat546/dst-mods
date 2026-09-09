#!/usr/bin/env python3
"""Dựng bản Việt hoá: vendor/ + strings_source.json → build/than-binh-phu-an-vi

    python3 tools/build.py            # dựng
    python3 tools/build.py --check    # chỉ báo tiến độ, không ghi

Cách làm: copy nguyên vendor/ sang build/, rồi thay từng chuỗi tiếng Trung
trong file .lua bằng bản dịch. Chỉ đụng chuỗi nằm trong nháy kép — comment và
mã nguồn giữ nguyên, nên logic mod không đổi.

Chuỗi chưa dịch (`vi` rỗng) được giữ nguyên tiếng Trung, nhờ vậy dựng lúc nào
cũng ra bản chạy được, dịch tới đâu hiện tiếng Việt tới đó.
"""

import argparse
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VENDOR = ROOT / "vendor"
BUILD = ROOT / "build" / "than-binh-phu-an-vi"
SRC = ROOT / "strings_source.json"
PATCHES = ROOT / "patches.json"

HAN = re.compile(r"[一-鿿]")
LUA_STR = re.compile(r'"((?:[^"\\\n]|\\.)*)"')


# `description` của modinfo nằm trong block [[...]], không phải nháy kép, nên
# bộ thay chuỗi không đụng tới — vá riêng ở đây. Giữ nguyên `author` gốc và ghi
# rõ nguồn: đây là bản dịch, không phải mod của mình.
MODINFO_DESC = (
    """description = [[
装备附魔/生物强化
| 煎蛋牛牛牛牛牛牛牛牛牛牛牛牛牛牛牛牛煎蛋 |
]]""",
    """description = [[
Phù ấn trang bị / Cường hoá sinh vật

Thêm hệ phù ấn cho trang bị: gắn dòng thuộc tính, kế thừa, nâng sao,
cường hoá sinh vật, quái kho báu, ấp trứng và nghề nghiệp.

MỚI Ở 0.0.3 — ĐUA TOP CHIẾN LỰC
Chế Bù Nhìn Đo Chiến Lực (4 ván gỗ + 10 Tinh Thể, tab Tinh Chế), bấm
vào nó rồi đánh trong 60 giây. Mod đo sát thương thật của bạn, tính
kèm khả năng chống chịu rồi cho ra một điểm Chiến lực duy nhất.
Xem bảng xếp hạng ở Trợ giúp -> Nhật ký thế giới -> Chiến lực.
Kỷ lục lưu theo tài khoản nên không mất khi chết hay đổi nhân vật.

Phát triển từ mod mã nguồn mở 传奇武器-附魔强化 (Workshop 3096210166)
của tác giả 宇宙超级霹雳闪电大煎蛋. Xin cảm ơn tác giả gốc.

Việt hoá và phát triển thêm: kimdat546
Cập nhật lần cuối: 07/09/2026

LƯU Ý: hãy TẮT mod gốc 3096210166 nếu đang bật — hai bản trùng prefab
và công thức chế tạo.
]]""",
)


def apply_code_patches():
    """Áp các bản vá MÃ NGUỒN (khác với dịch chuỗi) từ patches.json.

    Tác giả gốc nói rõ: có bug thì tự làm bản vá mà sửa. vendor/ luôn giữ
    nguyên bản gốc để còn diff được, mọi sửa đổi nằm ở đây.

    Mỗi mục: {"file": đường dẫn trong mod, "old": ..., "new": ..., "vi_sao": ...}
    Thêm "tat_ca": true nếu cần thay MỌI chỗ khớp thay vì chỗ đầu tiên.
    """
    if not PATCHES.exists():
        return
    items = json.loads(PATCHES.read_text(encoding="utf-8"))
    if not items:
        return
    for i, it in enumerate(items, 1):
        f = BUILD / it["file"]
        if not f.exists():
            print(f"  ⚠ vá #{i}: không có file {it['file']}")
            continue
        s = f.read_text(encoding="utf-8")
        if it["new"] in s:
            print(f"  vá #{i} đã có sẵn: {it.get('vi_sao', it['file'])}")
            continue
        if it["old"] not in s:
            print(f"  ⚠ vá #{i}: không khớp đoạn cần vá trong {it['file']} — mod đã đổi")
            continue
        n = -1 if it.get("tat_ca") else 1
        f.write_text(s.replace(it["old"], it["new"], n), encoding="utf-8")
        so = s.count(it["old"]) if it.get("tat_ca") else 1
        print(f"  ✓ vá #{i}{f' (x{so})' if so > 1 else ''}: {it.get('vi_sao', it['file'])}")


def patch_modinfo():
    f = BUILD / "modinfo.lua"
    s = f.read_text(encoding="utf-8")
    old, new = MODINFO_DESC
    if old in s:
        f.write_text(s.replace(old, new, 1), encoding="utf-8")
        print("vá modinfo: description + ghi công tác giả gốc")
    elif new not in s:
        print("⚠ không khớp description trong modinfo — mod đã đổi, xem lại tay")


# KHÔNG cho khoảng trắng trong phần cờ: "10% cơ hội" là dấu phần trăm bình thường,
# không phải ô thay thế. Chỉ "%s", "%d", "%%"... mới tính.
FMT = re.compile(r"%[-+#0-9.]*[a-zA-Z%]")


def kiem_ban_dich(table):
    """Bắt các lỗi làm hỏng mod mà mắt thường khó thấy khi sửa tay.

    Lua không có tham số theo vị trí, nên %s trong bản dịch phải ĐÚNG SỐ LƯỢNG
    và ĐÚNG THỨ TỰ như bản gốc; sai là string.format nổ lúc chạy chứ không phải
    lúc build. Dấu " chưa thoát thì làm hỏng cú pháp Lua. Số dòng \n phải giữ
    vì nhiều nhãn hai dòng được canh theo từng dòng.
    """
    loi = 0
    for zh, rec in table.items():
        vi = rec.get("vi")
        if not vi:
            continue
        a, b = FMT.findall(zh), FMT.findall(vi)
        if a != b:
            # Chuỗi os.date: mỗi %X độc lập, đảo thứ tự là ĐÚNG (ngày Việt là
            # d/m/Y). Chỉ báo lỗi khi tập ô thay thế thật sự khác nhau.
            if rec.get("doi_thu_tu") and sorted(a) == sorted(b):
                pass
            else:
                print(f"  ⚠ ô thay thế lệch: gốc {a} ≠ dịch {b}  |  {vi[:44]}")
                loi += 1
        if '"' in vi:
            print(f"  ⚠ có dấu nháy kép chưa thoát: {vi[:44]}")
            loi += 1
        if zh.count("\\n") > vi.count("\\n"):
            print(f"  · mất dấu xuống dòng: gốc {zh.count(chr(92)+chr(110))} "
                  f"≠ dịch {vi.count(chr(92)+chr(110))}  |  {vi[:40]}")
            loi += 1
    print(f"  {loi} cảnh báo" if loi else "  bản dịch không có lỗi định dạng")
    return loi


def build(check_only=False):
    table = json.loads(SRC.read_text(encoding="utf-8"))
    done = {zh: rec["vi"] for zh, rec in table.items() if rec.get("vi")}

    total = len(table)
    print(f"đã dịch {len(done)}/{total} chuỗi ({len(done) * 100 // max(total, 1)}%)")
    kiem_ban_dich(table)
    if check_only:
        return

    if BUILD.exists():
        shutil.rmtree(BUILD)
    BUILD.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(VENDOR, BUILD)

    replaced = files_touched = 0
    for f in sorted(BUILD.rglob("*.lua")):
        text = f.read_text(encoding="utf-8", errors="replace")
        if not HAN.search(text):
            continue
        hits = 0

        def sub_line(line: str) -> str:
            nonlocal hits
            if line.lstrip().startswith("--"):
                return line
            # chỉ thay trong phần mã, giữ nguyên comment đuôi dòng
            head, sep, tail = line.partition("--")
            if not HAN.search(head):
                return line

            def one(m):
                nonlocal hits
                zh = m.group(1)
                vi = done.get(zh)
                if vi:
                    hits += 1
                    return '"' + vi + '"'
                return m.group(0)

            return LUA_STR.sub(one, head) + sep + tail

        new = "\n".join(sub_line(l) for l in text.split("\n"))
        if hits:
            f.write_text(new, encoding="utf-8")
            replaced += hits
            files_touched += 1

    # addons/ = mã DO MÌNH VIẾT (tính năng mở rộng), giữ ngoài vendor/ theo đúng
    # nguyên tắc bên dưới: vendor/ phải là bản gốc nguyên vẹn để còn diff khi
    # tác giả cập nhật. Chép đè lên build sau khi đã copy vendor.
    addons = ROOT / "addons"
    if addons.exists():
        n = 0
        for f in addons.rglob("*"):
            if f.is_file():
                dest = BUILD / f.relative_to(addons)
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(f, dest)
                n += 1
        print(f"  chép {n} file mở rộng từ addons/")

    # preview.png cho Workshop: để ở assets/ chứ KHÔNG nhét vào vendor/,
    # vì vendor/ phải giữ đúng bản gốc 3.21 để còn diff khi tác giả cập nhật.
    pv = ROOT / "assets" / "preview.png"
    if pv.exists():
        shutil.copy2(pv, BUILD / "preview.png")
        print("  chép preview.png cho Workshop")

    patch_modinfo()
    apply_code_patches()

    print(f"thay {replaced} lượt chuỗi trong {files_touched} file")
    print(f"→ {BUILD.relative_to(ROOT)}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true")
    build(ap.parse_args().check)

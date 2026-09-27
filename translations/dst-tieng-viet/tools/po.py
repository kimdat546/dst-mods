"""Đọc / ghi file .po của DST (khoá = msgctxt, kiểu "STRINGS.NAMES.AXE").

File .po của Klei: mỗi mục có `#. <khoá>`, `msgctxt`, `msgid`, `msgstr`; chuỗi
có thể trải nhiều dòng "..." nối nhau. Thứ tự mục được giữ nguyên khi ghi lại.
"""

import re

_THOAT = {"n": "\n", "t": "\t", '"': '"', "\\": "\\", "r": "\r"}


def _giai(s):
    return re.sub(r'\\(.)', lambda m: _THOAT.get(m.group(1), "\\" + m.group(1)), s)


def _ma_hoa(s):
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\t", "\\t")


class Muc:
    __slots__ = ("ctx", "id", "str", "chu_thich")

    def __init__(self, ctx="", id_="", str_="", chu_thich=None):
        self.ctx, self.id, self.str = ctx, id_, str_
        self.chu_thich = chu_thich or []


def doc(duong):
    """Trả về (đầu file thô, [Muc...]). Mục đầu (msgid "") giữ nguyên trong phần đầu."""
    van = open(duong, encoding="utf-8-sig").read().split("\n")
    muc, dau, hien, truong = [], [], None, None
    trong_dau = True

    def xong():
        nonlocal hien
        if hien is not None and (hien.ctx or hien.id):
            muc.append(hien)
        hien = None

    for dong in van:
        if trong_dau:
            if dong.startswith("#.") or dong.startswith("msgctxt"):
                trong_dau = False
            else:
                dau.append(dong)
                continue
        if not dong.strip():
            xong(); truong = None
            continue
        if dong.startswith("#"):
            if hien is None or truong is not None:
                xong(); hien = Muc(); truong = None
            hien.chu_thich.append(dong)
            continue
        m = re.match(r'(msgctxt|msgid|msgstr)\s+"(.*)"\s*$', dong)
        if m:
            if hien is None:
                hien = Muc()
            truong = {"msgctxt": "ctx", "msgid": "id", "msgstr": "str"}[m.group(1)]
            setattr(hien, truong, _giai(m.group(2)))
            continue
        m = re.match(r'"(.*)"\s*$', dong)
        if m and hien is not None and truong:
            setattr(hien, truong, getattr(hien, truong) + _giai(m.group(1)))
    xong()
    return "\n".join(dau), muc


def ghi(duong, dau, muc):
    ra = [dau.rstrip("\n"), ""]
    for m in muc:
        ra.extend(m.chu_thich or [f"#. {m.ctx}"])
        ra.append(f'msgctxt "{_ma_hoa(m.ctx)}"')
        ra.append(f'msgid "{_ma_hoa(m.id)}"')
        ra.append(f'msgstr "{_ma_hoa(m.str)}"')
        ra.append("")
    open(duong, "w", encoding="utf-8").write("\n".join(ra))


# Placeholder DST dùng: %s %d %.1f …, {name}, và mã emoji :redgem: (người chơi gõ
# y nguyên vào chat — bản cũ từng gõ sai thành :reddem:).
# ⚠ KHÔNG cho cờ dấu cách (`% s`): "25% sát thương" sẽ bị nhận nhầm là %s.
_PH = re.compile(r"%[-+#0]*\d*(?:\.\d+)?[sdifgxc]|\{[A-Za-z_][A-Za-z0-9_]*\}|(?<![\w:]):[a-z0-9_]+:(?![\w:])")


def placeholder(s):
    return sorted(_PH.findall(s))

#!/usr/bin/env python3
"""Trích chuỗi hiển thị từ mod NewConstant (Core + Base) ra JSON.

File ngôn ngữ của mod gốc dùng bí danh cục bộ (local NAMES = STRINGS.NAMES) rồi
gán NAMES.KEY = "...", nên không thể grep thẳng — phải lần theo bí danh mới dựng
lại được đường dẫn STRINGS đầy đủ.
"""
import json, os, re, sys

ALIAS = re.compile(r'^\s*local\s+([A-Za-z_]\w*)\s*=\s*(STRINGS(?:[.\[][^\s=]*)?)\s*$', re.M)
# X.KEY = "..."  |  X["KEY"] = "..."  |  X.A.B = "..."
ASSIGN = re.compile(
    r'^\s*([A-Za-z_]\w*(?:(?:\.\w+)|(?:\[\s*"[^"]+"\s*\]))*)\s*=\s*'
    r'("(?:[^"\\]|\\.)*")\s*(?:--.*)?$', re.M)

def norm(path, aliases):
    """Đổi bí danh ở đầu đường dẫn thành STRINGS.… và chuẩn hoá ["X"] -> .X"""
    head = re.split(r'[.\[]', path, 1)[0]
    if head in aliases:
        path = aliases[head] + path[len(head):]
    elif head != 'STRINGS':
        return None
    path = re.sub(r'\[\s*"([^"]+)"\s*\]', r'.\1', path)
    return path

# <đường dẫn> = {   → mở đầu một bảng literal (mảng hoặc khoá-giá trị)
TABLE_OPEN = re.compile(r'([A-Za-z_]\w*(?:(?:\.\w+)|(?:\[\s*"[^"]+"\s*\]))*)\s*=\s*\{', re.M)
# phần tử bên trong bảng
TBL_KV = re.compile(r'(?:\["([^"]+)"\]|(\w+))\s*=\s*"((?:[^"\\]|\\.)*)"')
TBL_POS = re.compile(r'"((?:[^"\\]|\\.)*)"')


def _balanced(txt, start):
    """start trỏ vào '{'. Trả về vị trí ngay sau '}' cân bằng, bỏ qua chuỗi."""
    depth, i, n = 0, start, len(txt)
    while i < n:
        c = txt[i]
        if c == '"':
            i += 1
            while i < n and txt[i] != '"':
                i += 2 if txt[i] == '\\' else 1
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return n


def _unesc(s):
    try:
        return json.loads('"' + s + '"')
    except Exception:
        return s


def parse(fp):
    txt = open(fp, encoding='utf-8').read()
    aliases = {m.group(1): m.group(2) for m in ALIAS.finditer(txt)}
    out = {}

    # 1. Gán chuỗi đơn trên một dòng — dạng phổ biến nhất.
    for m in ASSIGN.finditer(txt):
        p = norm(m.group(1), aliases)
        if p:
            out[p] = _unesc(m.group(2)[1:-1])

    # 2. Gán BẢNG. Mod gốc dùng cả mảng (STRINGS.BOSSRUSH = {"a","b"}) lẫn
    #    bảng khoá-giá trị (ACTIONFAIL.AURUMITE_REPAIR = {["X"]="y"}). Regex
    #    theo dòng ở bước 1 không thấy chúng — đã từng bỏ sót 9 chuỗi vì vậy.
    for m in TABLE_OPEN.finditer(txt):
        p = norm(m.group(1), aliases)
        if not p:
            continue
        body = txt[m.end() - 1:_balanced(txt, m.end() - 1)]
        inner = body[1:-1]
        kv = list(TBL_KV.finditer(inner))
        if kv:
            for e in kv:
                out[p + '.' + (e.group(1) or e.group(2))] = _unesc(e.group(3))
        else:
            # mảng thuần: đánh chỉ số từ 1, khớp quy ước Lua
            for i, e in enumerate(TBL_POS.finditer(inner), 1):
                out[f'{p}.{i}'] = _unesc(e.group(1))
    return out

root = sys.argv[1]
core = os.path.join(root, '3645179905', 'scripts', 'languages')
zh, en = {}, {}
for sub, acc in (('newstring', zh), ('newstring_en', en)):
    d = os.path.join(core, sub)
    for fn in sorted(os.listdir(d)):
        if fn.endswith('.lua'):
            for k, v in parse(os.path.join(d, fn)).items():
                acc[k] = {'value': v, 'file': fn}

keys = sorted(set(zh) | set(en))
entries = {k: {'zh': zh.get(k, {}).get('value'),
               'en': en.get(k, {}).get('value'),
               'file': (zh.get(k) or en.get(k))['file']} for k in keys}

print(f"  Core — chuỗi trích được: {len(entries)}")
print(f"    có cả zh và en : {sum(1 for e in entries.values() if e['zh'] and e['en'])}")
print(f"    chỉ có zh      : {sum(1 for e in entries.values() if e['zh'] and not e['en'])}")
print(f"    chỉ có en      : {sum(1 for e in entries.values() if e['en'] and not e['zh'])}")
CJK = re.compile(r'[一-鿿]')
left = {k: e for k, e in entries.items() if e['en'] and CJK.search(e['en'])}
print(f"    ⚠ bản 'en' vẫn còn chữ Hán: {len(left)}")
for k in list(left)[:5]:
    print(f"        {k} = {left[k]['en'][:40]}")
per = {}
for e in entries.values():
    per[e['file']] = per.get(e['file'], 0) + 1
print("    theo file:", ", ".join(f"{f}={n}" for f, n in sorted(per.items())))

out = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'strings_source.json')
json.dump(entries, open(out, 'w', encoding='utf-8'), ensure_ascii=False, indent=1, sort_keys=True)
print(f"\n  → đã ghi {out}")

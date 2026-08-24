#!/usr/bin/env python3
"""Sinh scripts/lang/<mã>.lua từ strings_source.json + translations/<mã>.json.

  python3 tools/gen_lang.py            sinh tất cả ngôn ngữ
  python3 tools/gen_lang.py --check    chỉ báo cáo tiến độ, không ghi file

Bảng ngôn ngữ là bảng PHẲNG khoá "STRINGS.X.Y" (xem scripts/ncvi/apply.lua).
zh và en lấy thẳng từ mod gốc; các ngôn ngữ khác lấy từ translations/*.json.
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CJK = re.compile(r'[一-鿿]')


def lua_str(s: str) -> str:
    """Escape một chuỗi Python thành literal Lua an toàn."""
    out = s.replace('\\', '\\\\').replace('"', '\\"')
    out = out.replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
    return '"' + out + '"'


def write_lang(code: str, table: dict, note: str) -> str:
    path = os.path.join(ROOT, 'scripts', 'lang', f'{code}.lua')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    lines = [
        f'-- lang/{code}.lua — SINH TỰ ĐỘNG bởi tools/gen_lang.py. ĐỪNG SỬA TAY.',
        f'-- {note}',
        '-- Sửa bản dịch ở translations/<mã>.json rồi chạy lại tools/gen_lang.py.',
        '',
        'return {',
    ]
    for k in sorted(table):
        lines.append(f'  [{lua_str(k)}] = {lua_str(table[k])},')
    lines.append('}')
    open(path, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    return path


def main():
    check_only = '--check' in sys.argv
    src = json.load(open(os.path.join(ROOT, 'strings_source.json'), encoding='utf-8'))

    # Bỏ hiện vật của bộ trích: mod gốc gán trong vòng
    # `for i, name in ipairs(CHARACTERLIST) do ... STRINGS.CHARACTERS[name] ...`
    # nên `[name]` là BIẾN, không phải đường dẫn thật. Năm chuỗi đó đã có bản ở
    # GENERIC; modmain sẽ toả chúng ra mọi nhân vật lúc chạy (xem ncvi/fanout).
    artifacts = [k for k in src if '[name]' in k]
    for k in artifacts:
        del src[k]
    if artifacts:
        print(f"  bỏ {len(artifacts)} khoá hiện-vật CHARACTERS[name] (đã có bản GENERIC)")

    zh = {k: v['zh'] for k, v in src.items() if v.get('zh')}
    en = {k: v['en'] for k, v in src.items() if v.get('en')}

    print(f"  nguồn: {len(src)} khoá  (zh={len(zh)}, en={len(en)})")
    en_dirty = {k for k, v in en.items() if CJK.search(v)}
    print(f"  ⚠ bản en của mod gốc còn chữ Hán ở {len(en_dirty)} chuỗi")

    langs = {'zh': (zh, 'lấy nguyên từ mod gốc (scripts/languages/newstring/)'),
             'en': (en, 'lấy nguyên từ mod gốc (scripts/languages/newstring_en/)')}

    tdir = os.path.join(ROOT, 'translations')
    if os.path.isdir(tdir):
        for fn in sorted(os.listdir(tdir)):
            # modinfo_*.json không phải bảng ngôn ngữ — đó là chuỗi thay thẳng
            # vào modinfo.lua lúc build (xem tools/build.py), không đi qua STRINGS.
            if not fn.endswith('.json') or fn.startswith('modinfo'):
                continue
            code = fn[:-5]
            data = json.load(open(os.path.join(tdir, fn), encoding='utf-8'))
            tbl = {k: v for k, v in data.items() if isinstance(v, str) and v.strip()}
            done = len(tbl)
            missing = sorted(set(src) - set(tbl))
            dirty = sorted(k for k, v in tbl.items() if CJK.search(v))
            pct = done / max(len(src), 1) * 100
            print(f"\n  {code}: {done}/{len(src)} chuỗi ({pct:.0f}%)")
            if missing:
                print(f"    còn thiếu {len(missing)}: {', '.join(m.split('.')[-1] for m in missing[:6])}"
                      + (' …' if len(missing) > 6 else ''))
            if dirty:
                print(f"    ⚠ CÒN CHỮ HÁN ở {len(dirty)}: {', '.join(d.split('.')[-1] for d in dirty[:6])}")
            extra = sorted(set(tbl) - set(src))
            if extra:
                print(f"    ⚠ khoá lạ không có trong nguồn ({len(extra)}): {extra[:4]}")
            langs[code] = (tbl, f'bản dịch tay, {done}/{len(src)} chuỗi')

    if check_only:
        print("\n  (--check: không ghi file nào)")
        return 0

    print()
    for code, (tbl, note) in sorted(langs.items()):
        p = write_lang(code, tbl, note)
        print(f"  ✓ ghi {os.path.relpath(p, ROOT)}  ({len(tbl)} chuỗi)")
    return 0


if __name__ == '__main__':
    sys.exit(main())

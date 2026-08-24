#!/usr/bin/env python3
"""Sinh wiki/wiki.html từ wiki/data.json — nguồn để in ra PDF.

Ảnh nhúng thẳng dạng base64 để file HTML tự chứa, in ra PDF không mất ảnh.
"""
import base64
import html
import json
import os
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WIKI = os.path.join(ROOT, 'wiki')

ORDER = ['Chế tạo được', 'Vật phẩm & Khác', 'Sinh vật & Boss',
         'Hiệu ứng', 'Chất độc', 'Linh hồn']

INTRO = {
    'Chế tạo được': 'Những thứ bạn tự làm ra được, kèm nguyên liệu và bậc công nghệ cần thiết.',
    'Vật phẩm & Khác': 'Vật phẩm rơi ra, nguyên liệu thô, công trình và các mục còn lại.',
    'Sinh vật & Boss': 'Quái vật và trùm của mod. Phần lớn nằm ở Vực Sâu và tầng Viễn Cổ.',
    'Hiệu ứng': 'Trạng thái tăng/giảm sức mạnh hiện trên thanh hiệu ứng.',
    'Chất độc': 'Các loại độc do quái gây ra. Dùng Thuốc Giải Vạn Năng để hoá giải.',
    'Linh hồn': 'Nguyên liệu hiếm rơi từ trùm, dùng cho chế tạo cấp cao.',
}


PLACEHOLDER = {
    'Hiệu ứng': '✦', 'Chất độc': '☠', 'Sinh vật & Boss': '☾',
    'Linh hồn': '❂', 'Chế tạo được': '⚒', 'Vật phẩm & Khác': '◈',
}


def b64(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode()


def esc(s):
    return html.escape(s) if s else ''


def cjk(name, h_pt):
    """Chèn chữ Hán dưới dạng ẢNH.

    Chrome --print-to-pdf NUỐT ký tự CJK dù --screenshot vẫn vẽ được, và kê tên
    font trong CSS không cứu được. Chỉ có vài chỗ cần chữ Hán (tên mod, tên tác
    giả) nên vẽ sẵn ra PNG bằng Pillow rồi nhúng — chắc chắn hiện trong PDF.
    """
    p = os.path.join(WIKI, 'img', f'_cjk_{name}.png')
    if not os.path.exists(p):
        return ''
    return (f'<img src="data:image/png;base64,{b64(p)}" '
            f'style="height:{h_pt}pt;vertical-align:-2px">')


def main():
    data = json.load(open(os.path.join(WIKI, 'data.json'), encoding='utf-8'))
    entries, tech_vi, stats = data['entries'], data['tech_vi'], data['stats']

    groups = defaultdict(list)
    for e in entries.values():
        groups[e['category']].append(e)
    for g in groups.values():
        g.sort(key=lambda e: e['name'].lower())

    P = []
    A = P.append

    A('<!doctype html><html lang="vi"><head><meta charset="utf-8">')
    A('<title>NewConstant — Cẩm nang tiếng Việt</title><style>')
    A('''
@page { size: A4; margin: 16mm 14mm; }
* { box-sizing: border-box; }
/* Phải kê tên font CJK: Chrome headless KHÔNG tự dự phòng cho chữ Hán. */
body { font-family: "Charter", "Iowan Old Style", Georgia, "Times New Roman", serif;
       color: #1c1c1e; margin: 0; font-size: 12pt; line-height: 1.62;
       -webkit-font-smoothing: antialiased; }
.sans { font-family: -apple-system, "Helvetica Neue", Arial, sans-serif; }

.cover { height: 262mm; display: flex; flex-direction: column;
         justify-content: center; align-items: center; text-align: center;
         page-break-after: always; }
.cover h1 { font-size: 40pt; margin: 0 0 10px; letter-spacing: -1px; font-weight: 700; }
.cover .sub { font-size: 16pt; color: #55595e; margin-bottom: 38px; }
.cover .meta { font-size: 12pt; color: #55595e; line-height: 2.05;
               border-top: 1px solid #d8dade; padding-top: 22px; max-width: 430px; }
.cover .warn { margin-top: 32px; font-size: 10.5pt; line-height: 1.55; color: #7a5000;
               background: #fffaed; border-left: 3px solid #e0b04a;
               padding: 14px 18px; max-width: 460px; text-align: left; }

h2 { font-size: 21pt; margin: 0 0 6px; padding-bottom: 8px;
     border-bottom: 2.5px solid #1c1c1e; page-break-after: avoid; letter-spacing: -.3px; }
h2 .n { font-size: 11.5pt; color: #85898f; font-weight: normal; letter-spacing: 0; }
.lead { color: #55595e; margin: 0 0 18px; font-size: 11.5pt; page-break-after: avoid; }
section { page-break-before: always; }

.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.card { border: 1px solid #dcdfe3; border-radius: 8px; padding: 13px 15px;
        page-break-inside: avoid; background: #fff; display: flex; gap: 13px; }
.card .ic { width: 58px; height: 58px; flex: 0 0 58px; display: flex;
            align-items: center; justify-content: center;
            background: #f2f4f7; border-radius: 7px; }
.card .ic img { max-width: 54px; max-height: 54px; image-rendering: -webkit-optimize-contrast; }
.card .ic .ph { font-size: 20pt; opacity: .55; }
.card .body { min-width: 0; flex: 1; }
.card h3 { font-size: 13pt; margin: 0 0 3px; line-height: 1.3; letter-spacing: -.2px; }
.card .pf { font-family: ui-monospace, Menlo, monospace; font-size: 8.5pt;
            color: #9aa0a8; margin-bottom: 7px; letter-spacing: -.2px; }
.card .q { color: #34383d; font-size: 11pt; margin: 5px 0; font-style: italic; }
.card .rd { color: #1f6146; font-size: 10.5pt; margin: 5px 0; }
.rec { margin-top: 9px; border-top: 1px solid #e8eaee; padding-top: 8px; font-size: 10.5pt;
       line-height: 1.5; }
.rec .t { color: #6a6f76; }
.rec b { color: #1c1c1e; }
.tag { display: inline-block; background: #eef1f5; color: #4d535a;
       border-radius: 4px; padding: 1px 7px; font-size: 9.5pt; margin-left: 5px;
       font-family: -apple-system, sans-serif; }

table.sum { width: 100%; border-collapse: collapse; font-size: 11.5pt; margin: 10px 0 20px; }
table.sum th, table.sum td { border: 1px solid #dcdfe3; padding: 9px 12px; text-align: left;
                             vertical-align: top; }
table.sum th { background: #f2f4f7; font-family: -apple-system, sans-serif; font-size: 10.5pt; }
''')
    A('</style></head><body>')

    # ── Bìa ────────────────────────────────────────────────────────────────
    A('<div class="cover">')
    A('<h1>NewConstant</h1>')
    A(f'<div class="sub">{cjk("title", 15)} — Cẩm nang tiếng Việt</div>')
    A('<div class="meta">')
    A(f"<b>{stats['tong_muc']}</b> mục &nbsp;·&nbsp; "
      f"<b>{stats['co_cong_thuc']}</b> công thức &nbsp;·&nbsp; "
      f"<b>{stats['co_anh']}</b> hình ảnh<br>")
    A('Gồm ba mod: Core · Nightmare · Base<br>')
    A(f'Mod gốc do {cjk("author", 11)} viết<br>')
    A('Bản dịch và cẩm nang này dựng từ chính mã nguồn mod')
    A('</div>')
    A('<div class="warn"><b>Lưu ý về bản quyền.</b> Toàn bộ nội dung, hình ảnh và '
      f'gameplay thuộc về tác giả gốc {cjk("author_warn", 9)}. Tác giả ghi rõ trong mod: '
      '<i>cấm sao chép, phát tán lại và sửa đổi khi chưa được phép</i>. '
      'Tài liệu này chỉ để dùng riêng.</div>')
    A('</div>')

    # ── Mục lục ────────────────────────────────────────────────────────────
    A('<section><h2>Mục lục</h2>')
    A('<table class="sum"><tr><th>Phần</th><th>Số mục</th><th>Nội dung</th></tr>')
    for c in ORDER:
        if c in groups:
            A(f'<tr><td><b>{esc(c)}</b></td><td>{len(groups[c])}</td>'
              f'<td>{esc(INTRO.get(c,""))}</td></tr>')
    A('</table>')
    A('<p class="lead">Cẩm nang được sinh tự động từ mã nguồn mod: tên và mô tả lấy từ '
      'bản dịch tiếng Việt, công thức lấy từ khai báo <code>AddRecipe2</code>, '
      'hình ảnh giải mã từ atlas <code>.tex</code> của Klei. '
      'Mục nào thiếu mô tả là do mod gốc không viết mô tả cho nó.</p>')
    A('</section>')

    # ── Từng nhóm ──────────────────────────────────────────────────────────
    for cat in ORDER:
        if cat not in groups:
            continue
        items = groups[cat]
        A(f'<section><h2>{esc(cat)} <span class="n">— {len(items)} mục</span></h2>')
        A(f'<p class="lead">{esc(INTRO.get(cat,""))}</p><div class="grid">')
        for e in items:
            A('<div class="card">')
            if e['image'] and os.path.exists(os.path.join(WIKI, e['image'])):
                A(f'<div class="ic"><img src="data:image/png;base64,'
                  f'{b64(os.path.join(WIKI, e["image"]))}"></div>')
            else:
                A(f'<div class="ic"><span class="ph">{PLACEHOLDER.get(e["category"], "•")}</span></div>')
            A('<div class="body">')
            A(f'<h3>{esc(e["name"])}</h3>')
            A(f'<div class="pf">{esc(e["prefab"])}</div>')
            if e['describe']:
                A(f'<div class="q">“{esc(e["describe"])}”</div>')
            if e['recipe_desc']:
                A(f'<div class="rd">▸ {esc(e["recipe_desc"])}</div>')
            r = e['recipe']
            if r:
                ing = ' · '.join(f'{esc(i["name"])} <b>×{i["count"]}</b>'
                                 for i in r['ingredients'])
                A('<div class="rec">')
                A(f'<span class="t">Nguyên liệu:</span> {ing}<br>')
                A(f'<span class="t">Công nghệ:</span> '
                  f'{esc(tech_vi.get(r["tech"], r["tech"]))}')
                if r['station']:
                    A('<span class="tag">cần trạm chế tạo</span>')
                A('</div>')
            A('</div></div>')
        A('</div></section>')

    A('</body></html>')

    out = os.path.join(WIKI, 'wiki.html')
    open(out, 'w', encoding='utf-8').write('\n'.join(P))
    print(f"  ✓ {os.path.relpath(out, ROOT)}  ({os.path.getsize(out)//1024} KB)")
    return 0


if __name__ == '__main__':
    sys.exit(main())

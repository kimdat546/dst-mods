#!/usr/bin/env python3
"""Sinh wiki/wiki.html từ wiki/data.json — tự chứa, mở offline, in PDF được."""
import html, json, os, datetime

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W = os.path.join(ROOT, 'wiki')
d = json.load(open(os.path.join(W, 'data.json'), encoding='utf-8'))

# (khoá dữ liệu, tiêu đề, mô tả dẫn nhập)
SECTIONS = [
    ('phu_an', 'Phù ấn trang bị',
     'Các dòng thuộc tính gắn được lên vũ khí và giáp qua Bàn Phù Ấn. '
     'Trang bị càng cấp cao càng chứa được nhiều dòng — quái thường tối đa 5, tinh anh 7, boss 10.'),
    ('thuoc_tinh', 'Thuộc tính nhân vật',
     'Toàn bộ chỉ số mà phù ấn và ngọc có thể tác động tới.'),
    ('buff', 'Hiệu ứng tạm thời',
     'Trạng thái có thời hạn, hiện trên thanh hiệu ứng.'),
    ('vat_pham', 'Vật phẩm của mod',
     'Đá phù ấn, ngọc, vật phẩm chức năng và nguyên liệu do mod thêm vào.'),
    ('prefab_mod', 'Công trình & thực thể',
     'Bàn phù ấn, tổ ấp trứng, điểm kho báu và các thực thể khác.'),
    ('boss', 'Boss riêng của mod', 'Trùm do mod thêm vào, khác với boss gốc của game.'),
    ('quai_kho_bau', 'Quái sự kiện kho báu',
     'Sinh vật xuất hiện khi đào điểm kho báu. Nhiều con được cường hoá rất mạnh.'),
    ('nghe', 'Hệ nghề', 'Các bậc nghề nghiệp, hiện mới có nhánh thợ rèn.'),
    ('trang_bi_phu_an', 'Trang bị phù ấn được',
     'Trang bị sẵn có của game mà mod cho phép gắn dòng phù ấn.'),
    ('trang_bi_roi', 'Trang bị rơi ra',
     'Trang bị mà quái có thể rơi kèm dòng phù ấn sẵn.'),
    ('sinh_vat', 'Sinh vật được cường hoá',
     'Những loài mod áp cường hoá lên — máu và dòng tăng theo ngày.'),
    ('tuy_chon', 'Tuỳ chọn cấu hình',
     'Thiết lập người chơi chỉnh được khi tạo thế giới.'),
]

def esc(x): return html.escape(str(x or ''))

rows_html = []
nav = []
for key, title, intro in SECTIONS:
    items = d.get(key) or []
    if not items: continue
    nav.append(f'<a href="#{key}">{esc(title)} <b>{len(items)}</b></a>')
    body = []
    for it in items:
        ten = it.get('ten') or it.get('nhan') or ''
        mo = it.get('mo_ta', '')
        k = it.get('key', '')
        zh = ' zh' if any('一' <= c <= '鿿' for c in str(ten) + str(mo)) else ''
        body.append(
            f'<tr class="r{zh}"><td class="n">{esc(ten)}</td>'
            f'<td class="d">{esc(mo)}</td><td class="k">{esc(k)}</td></tr>')
    tbl = (f'<table><thead><tr><th>Tên</th><th>Mô tả</th><th>Khoá</th></tr></thead>'
           f'<tbody>{"".join(body)}</tbody></table>')
    # bảng dài thì gập lại cho wiki đỡ lê thê
    if len(items) > 60:
        tbl = (f'<details><summary>Mở danh sách {len(items)} mục</summary>{tbl}</details>')
    rows_html.append(
        f'<section id="{key}"><h2>{esc(title)} '
        f'<span class="ct">{len(items)}</span></h2>'
        f'<p class="intro">{esc(intro)}</p>{tbl}</section>')

# ── hai mục đặc biệt: bậc quái và phân loại loài, hiện dạng chip ─────────
NHAN = {
 'common_monster':'Quái thường','elite_monster':'Quái tinh anh','boss_monster':'Quái boss',
 'pig':'Loài lợn','rabbit':'Loài thỏ','fish':'Loài cá','gear':'Sinh vật bánh răng',
 'spider':'Loài nhện','dog':'Loài chó','frog':'Loài ếch','insect':'Côn trùng',
 'monkey':'Loài khỉ','shadow':'Sinh vật bóng tối','plant':'Thực vật'}

def chips(key, title, intro):
    g = d.get(key) or {}
    if not g: return '', 0
    n = sum(len(v) for v in g.values())
    body = []
    for gk, items in g.items():
        body.append('<div class="grp"><h3>%s <span class="ct">%d</span></h3><div class="chips">%s</div></div>'
            % (esc(NHAN.get(gk, gk)), len(items),
               ''.join('<span class="chip">%s</span>' % esc(i['ten']) for i in items)))
    nav.append(f'<a href="#{key}">{esc(title)} <b>{n}</b></a>')
    return (f'<section id="{key}"><h2>{esc(title)} <span class="ct">{n}</span></h2>'
            f'<p class="intro">{esc(intro)}</p>{"".join(body)}</section>'), n

extra = []
for k, ti, intro in [
    ('bac_quai', 'Bậc quái',
     'Quái nào tính là thường / tinh anh / boss. Bậc quyết định tỉ lệ rơi đồ và '
     'số dòng phù ấn tối đa trên trang bị nó rơi ra.'),
    ('phan_loai', 'Phân loại loài',
     'Loài nào tính vào từng nhóm. Dùng cho các phù ấn dạng "tăng sát thương lên lợn/nhện/côn trùng…".')]:
    h, n = chips(k, ti, intro)
    if h: extra.append(h)
rows_html.extend(extra)

total = sum(len(d.get(k) or []) for k, _, _ in SECTIONS) \
        + sum(len(v) for v in (d.get('bac_quai') or {}).values()) \
        + sum(len(v) for v in (d.get('phan_loai') or {}).values())
today = datetime.date.today().isoformat()

doc = f'''<!doctype html><html lang="vi"><meta charset="utf-8">
<title>Thần Binh Phù Ấn — Wiki</title>
<style>
:root{{--bg:#faf8f5;--fg:#241f1b;--mut:#7a6f64;--line:#e2dad0;--acc:#8a5a2b;--zh:#b45309}}
@media(prefers-color-scheme:dark){{:root{{--bg:#17140f;--fg:#ece5db;--mut:#9d9083;--line:#332c24;--acc:#d9a05b;--zh:#f0b45f}}}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--bg);color:var(--fg);
 font:15px/1.6 -apple-system,"Segoe UI",system-ui,sans-serif}}
.wrap{{max-width:1000px;margin:0 auto;padding:32px 22px 80px}}
h1{{font-size:30px;margin:0 0 4px;letter-spacing:-.02em}}
.sub{{color:var(--mut);margin:0 0 22px;font-size:14px}}
nav{{display:flex;flex-wrap:wrap;gap:7px;margin:0 0 26px;
 padding:14px;border:1px solid var(--line);border-radius:10px}}
nav a{{color:var(--fg);text-decoration:none;font-size:13px;padding:4px 10px;
 border:1px solid var(--line);border-radius:99px}}
nav a b{{color:var(--acc)}}
nav a:hover{{border-color:var(--acc)}}
#q{{width:100%;padding:11px 14px;margin:0 0 26px;font-size:15px;
 border:1px solid var(--line);border-radius:9px;background:transparent;color:var(--fg)}}
section{{margin:0 0 40px;scroll-margin-top:16px}}
h2{{font-size:19px;margin:0 0 4px;padding-bottom:7px;border-bottom:2px solid var(--acc)}}
.ct{{font-size:12px;color:var(--mut);font-weight:400}}
.intro{{color:var(--mut);margin:0 0 12px;font-size:14px}}
table{{width:100%;border-collapse:collapse;font-size:14px}}
th{{text-align:left;font-size:11px;letter-spacing:.08em;text-transform:uppercase;
 color:var(--mut);padding:6px 9px;border-bottom:1px solid var(--line);font-weight:600}}
td{{padding:7px 9px;border-bottom:1px solid var(--line);vertical-align:top}}
.n{{font-weight:600;width:24%}}
.d{{color:var(--mut)}}
.k{{font-family:ui-monospace,Menlo,monospace;font-size:11px;color:var(--mut);
 width:20%;word-break:break-all}}
tr.zh .n,tr.zh .d{{color:var(--zh)}}
tr.hide{{display:none}}
details{{border:1px solid var(--line);border-radius:8px;padding:0 12px}}
details[open]{{padding-bottom:8px}}
summary{{cursor:pointer;padding:10px 0;color:var(--acc);font-size:14px;font-weight:600}}
.grp{{margin:0 0 16px}}
.grp h3{{font-size:14px;margin:0 0 7px;font-weight:600}}
.chips{{display:flex;flex-wrap:wrap;gap:5px}}
.chip{{font-size:12px;padding:3px 9px;border:1px solid var(--line);
 border-radius:99px;color:var(--mut)}}
footer{{margin-top:50px;padding-top:16px;border-top:1px solid var(--line);
 color:var(--mut);font-size:13px}}
@media print{{nav,#q{{display:none}} body{{background:#fff;color:#000}}
 section{{break-inside:avoid}} a{{color:#000}}}}
</style>
<div class="wrap">
<h1>Thần Binh Phù Ấn</h1>
<p class="sub">Wiki nội dung mod · {total} mục · dựng ngày {today}<br>
Mod gốc <b>传奇武器-附魔强化</b> v3.21 của <b>宇宙超级霹雳闪电大煎蛋</b> — Workshop 3096210166.
Mục còn <span style="color:var(--zh)">màu cam</span> là chưa dịch xong.</p>
<input id="q" placeholder="Gõ để lọc — tên, mô tả hoặc khoá…">
<nav>{''.join(nav)}</nav>
{''.join(rows_html)}
<footer>Dựng tự động từ mã nguồn mod bằng <code>tools/build_wiki_data.py</code> +
<code>tools/build_wiki_html.py</code>. Chạy lại sau mỗi đợt dịch để cập nhật.</footer>
</div>
<script>
const q=document.getElementById('q');
q.addEventListener('input',()=>{{
  const s=q.value.trim().toLowerCase();
  document.querySelectorAll('section').forEach(sec=>{{
    let n=0;
    sec.querySelectorAll('tr.r').forEach(tr=>{{
      const hit=!s||tr.textContent.toLowerCase().includes(s);
      tr.classList.toggle('hide',!hit); if(hit)n++;
    }});
    sec.style.display=n?'':'none';
  }});
}});
</script>
</html>'''

open(os.path.join(W, 'wiki.html'), 'w', encoding='utf-8').write(doc)
print("  → wiki/wiki.html  (%d mục, %.0f KB)" % (total, len(doc)/1024))

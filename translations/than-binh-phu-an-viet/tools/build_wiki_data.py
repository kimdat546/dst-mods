#!/usr/bin/env python3
"""Rút dữ liệu từ vendor/ thành wiki/data.json.

Không chạy Lua — chỉ đọc tĩnh bằng regex. Mod dùng bảng lồng nhau khá đều tay
nên cách này đủ, và không phải dựng môi trường game.

Tên/mô tả phù ấn KHÔNG nằm trong hh_enchant.lua mà ở
main/hh_tunning.lua["HH_FORMAT_CONFIG"]["EQUIP_EFFECT"], tra theo khoá.
Bản dịch lấy từ strings_source.json, chưa dịch thì giữ nguyên tiếng Trung.
"""
import json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V = os.path.join(ROOT, 'vendor')

def read(p):
    """Đọc file, BỎ phần bị comment — nếu không sẽ rút nhầm cả code đã tắt.
    extract_strings.py cũng bỏ comment, hai bên phải khớp nhau."""
    try:
        raw = open(os.path.join(V, p), encoding='utf-8', errors='replace').read()
    except FileNotFoundError:
        return ''
    out = []
    for line in raw.splitlines():
        i = line.find('--')
        # chỉ cắt khi '--' nằm ngoài chuỗi (đếm số nháy kép phía trước)
        while i != -1 and line[:i].count('"') % 2 == 1:
            i = line.find('--', i + 2)
        out.append(line[:i] if i != -1 else line)
    return '\n'.join(out)

# ── bản dịch ──────────────────────────────────────────────────────────────
VI = {}
try:
    for zh, rec in json.load(open(os.path.join(ROOT, 'strings_source.json'),
                                  encoding='utf-8')).items():
        if rec.get('vi'): VI[zh] = rec['vi']
except FileNotFoundError:
    pass

def t(s):
    """Dịch nếu có, không thì trả nguyên bản."""
    return VI.get(s, s) if isinstance(s, str) else s

# ── bảng tên/mô tả phù ấn từ hh_tunning ───────────────────────────────────
def tunning_block(name):
    s = read('main/hh_tunning.lua')
    m = re.search(r'\["%s"\]\s*=\s*\{' % re.escape(name), s)
    if not m: return {}
    i = m.end(); depth = 1
    while i < len(s) and depth:
        if s[i] == '{': depth += 1
        elif s[i] == '}': depth -= 1
        i += 1
    body = s[m.end():i]
    return {k: v for k, v in re.findall(r'\["([^"]+)"\]\s*=\s*"((?:[^"\\]|\\.)*)"', body)}

EFFECT = tunning_block('EQUIP_EFFECT')

# ── phù ấn ────────────────────────────────────────────────────────────────
def enchants():
    s = read('scripts/enums/hh_enchant.lua')
    out = []
    for m in re.finditer(r'\["([a-z_0-9]+)"\]\s*=\s*\{\s*\n\s*\["id"\]\s*=\s*(\d+)', s):
        key, eid = m.group(1), int(m.group(2))
        blk = s[m.start(): m.start() + 900]
        def g(p):
            mm = re.search(p, blk)
            return mm.group(1) if mm else None
        name_key = g(r'\["name"\]\s*=\s*TUNING_EQUIP_EFFECT\["([^"]+)"\]')
        desc_key = g(r'\["desc"\]\s*=\s*TUNING_EQUIP_EFFECT\["([^"]+)"\]')
        star = g(r'\["star_rating"\]\s*=\s*(\d+)')
        out.append({
            'key': key, 'id': eid,
            'ten': t(EFFECT.get(name_key, '')) if name_key else '',
            'mo_ta': t(EFFECT.get(desc_key, '')) if desc_key else '',
            'sao': int(star) if star else None,
            'chi_mot': '["only_one"] = true' in blk,
            'tex': g(r'\["tex"\]\s*=\s*"([^"]+)"'),
        })
    return out

# ── bảng có ["key"] = { ... ["name"] = "..." } ở bất kỳ độ sâu nào ─────────
def named(path, want_desc=True):
    """Quét theo khối cân ngoặc, lấy khoá cấp 1 kèm name/desc bên trong."""
    s = read(path)
    out = []
    for m in re.finditer(r'^\s{4}\["([a-zA-Z_0-9]+)"\]\s*=\s*\{', s, re.M):
        i = m.end(); depth = 1
        while i < len(s) and depth:
            if s[i] == '{': depth += 1
            elif s[i] == '}': depth -= 1
            i += 1
        blk = s[m.end():i]
        nm = re.search(r'\["name"\]\s*=\s*"((?:[^"\\]|\\.)*)"', blk)
        if not nm: continue
        # dịch TRƯỚC rồi mới nối xuống dòng — làm ngược lại là tra trượt khoá
        r = {'key': m.group(1), 'ten': t(nm.group(1)).replace('\\n', ' · ')}
        if want_desc:
            ds = re.search(r'\["desc"\]\s*=\s*"((?:[^"\\]|\\.)*)"', blk)
            if ds: r['mo_ta'] = t(ds.group(1)).replace('\\n', ' · ')
        out.append(r)
    return out

# ── nhóm phân loại: ["nhom"] = { ["prefab"] = true, --tên }  ─────────────
def groups(path, want):
    """Rút các nhóm phân loại sinh vật/quái. Tên hiển thị lấy từ comment
    cuối dòng nếu có, không thì dùng luôn prefab id."""
    raw = open(os.path.join(V, path), encoding='utf-8', errors='replace').read()
    out = {}
    for g in want:
        m = re.search(r'\["%s"\]\s*=\s*\{' % re.escape(g), raw)
        if not m: continue
        i = m.end(); depth = 1
        while i < len(raw) and depth:
            if raw[i] == '{': depth += 1
            elif raw[i] == '}': depth -= 1
            i += 1
        blk = raw[m.end():i]
        items = []
        for mm in re.finditer(r'\["([a-zA-Z_0-9]+)"\]\s*=\s*true\s*,?\s*(?:--\s*(.*))?', blk):
            nm = (mm.group(2) or '').strip()
            items.append({'key': mm.group(1), 'ten': t(nm) if nm else mm.group(1)})
        if items: out[g] = items
    return out

# ── danh sách phẳng: { ["id"]="x", ["name"]="y" } ────────────────────────
def flat_list(path, group=None):
    s = read(path)
    if group:
        m = re.search(r'\["%s"\]\s*=\s*\{' % re.escape(group), s)
        if not m: return []
        i = m.end(); depth = 1
        while i < len(s) and depth:
            if s[i] == '{': depth += 1
            elif s[i] == '}': depth -= 1
            i += 1
        s = s[m.end():i]
    out = []
    for m in re.finditer(r'\{\s*\["id"\]\s*=\s*"([^"]+)"\s*,\s*\["name"\]\s*=\s*"([^"]*)"', s):
        out.append({'key': m.group(1), 'ten': t(m.group(2))})
    return out

# ── thuộc tính người chơi ────────────────────────────────────────────────
def effects():
    s = read('scripts/enums/hh_effects.lua'); out = []
    for m in re.finditer(r'\["([a-zA-Z_0-9]+)"\]\s*=\s*\{\s*\["name"\]\s*=\s*"([^"]*)"'
                         r'(?:\s*,\s*\["desc"\]\s*=\s*"([^"]*)")?', s):
        out.append({'key': m.group(1), 'ten': t(m.group(2)),
                    'mo_ta': t(m.group(3)) if m.group(3) else ''})
    return out

# ── nghề ──────────────────────────────────────────────────────────────────
def jobs():
    s = read('scripts/job/hh_job_config.lua')
    return [{'ten': t(x)} for x in re.findall(r'\["name"\]\s*=\s*"([^"]+)"', s)]

# ── tuỳ chọn mod ─────────────────────────────────────────────────────────
def options():
    s = read('modinfo.lua'); out = []
    for m in re.finditer(r'name\s*=\s*"([^"]+)"\s*,\s*label\s*=\s*"([^"]+)"', s):
        out.append({'key': m.group(1), 'nhan': t(m.group(2))})
    return out

# Phù ấn đầy đủ: ghép khoá "X_name" với khoá "X" trong EQUIP_EFFECT.
def enchants_full():
    out = []
    for k, v in sorted(EFFECT.items()):
        if not k.endswith('_name'):
            continue
        base = k[:-5]
        out.append({'key': base, 'ten': t(v), 'mo_ta': t(EFFECT.get(base, ''))})
    # các mục chỉ có mô tả, không có *_name riêng
    named_bases = {k[:-5] for k in EFFECT if k.endswith('_name')}
    for k, v in sorted(EFFECT.items()):
        if k.endswith('_name') or k in named_bases:
            continue
        out.append({'key': k, 'ten': '', 'mo_ta': t(v)})
    return out

data = {
    'phu_an':     enchants_full(),
    'phu_an_chi_tiet': enchants(),
    'thuoc_tinh': effects(),
    'boss':       named('scripts/enums/hh_boss.lua'),
    'quai':       named('scripts/enums/hh_monster.lua'),
    'quai_kho_bau': named('scripts/enums/hh_treasure_monster.lua'),
    'buff':       named('scripts/enums/hh_buff.lua'),
    'vat_pham':   named('scripts/enums/hh_items.lua'),
    'trung':      named('scripts/enums/hh_egg.lua'),
    'prefab_mod': named('scripts/enums/hh_prefabs.lua'),
    'trang_bi_phu_an': flat_list('scripts/enums/hh_prefab_list.lua', 'equip'),
    'trang_bi_roi':    flat_list('scripts/enums/hh_prefab_list.lua', 'drop_equip'),
    'sinh_vat':        flat_list('scripts/enums/hh_prefab_list.lua', 'organism'),
    'nghe':       jobs(),
    'tuy_chon':   options(),
}

# phân loại sinh vật (cho phù ấn +sát thương theo loài) và bậc quái
data['phan_loai'] = groups('scripts/enums/hh_prefab_list.lua',
    ['pig','rabbit','fish','gear','spider','dog','frog','insect','monkey','shadow','plant'])
data['bac_quai'] = groups('scripts/enums/hh_prefab_list.lua',
    ['common_monster','elite_monster','boss_monster'])

os.makedirs(os.path.join(ROOT, 'wiki'), exist_ok=True)
with open(os.path.join(ROOT, 'wiki', 'data.json'), 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=1)

for k, v in data.items():
    print("  %-16s %4d mục" % (k, len(v)))

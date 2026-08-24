#!/usr/bin/env python3
"""Gom mọi dữ liệu cần cho wiki thành wiki/data.json.

Nguồn:
  translations/vi.json   tên + mô tả tiếng Việt (đã dịch)
  vendor/*/main/recipes  công thức + nguyên liệu + bậc công nghệ
  wiki/img/*.png         ảnh đã cắt từ atlas
  vendor/*/scripts/prefabs  danh sách prefab để phân loại
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Nguyên liệu của game gốc — dịch để công thức đọc được trọn vẹn tiếng Việt.
VANILLA = {
    'goldenaxe': 'Rìu vàng', 'spear': 'Giáo', 'log': 'Gỗ', 'gears': 'Bánh răng',
    'orangegem': 'Ngọc cam', 'hammer': 'Búa', 'bearger_fur': 'Lông Gấu Voi',
    'spore_small': 'Bào tử nhỏ', 'messagebottleempty': 'Chai rỗng', 'kelp': 'Rong biển',
    'opalpreciousgem': 'Ngọc Opal', 'moonrocknugget': 'Đá mặt trăng',
    'purebrilliance': 'Ánh Sáng Thuần Khiết', 'armorskeleton': 'Giáp xương',
    'horrorfuel': 'Nhiên liệu kinh hoàng', 'voidcloth': 'Vải hư không',
    'dreadstone': 'Đá khiếp sợ', 'shadowheart': 'Tim bóng tối',
    'alterguardianhatshard': 'Mảnh mũ Vệ Thần', 'wagpunk_bits': 'Mảnh Wagpunk',
    'sword_lunarplant': 'Kiếm cây mặt trăng', 'dragon_scales': 'Vảy Rồng',
    'footballhat': 'Mũ bóng bầu dục', 'firestaff': 'Gậy lửa',
    'thulecite': 'Thulecite', 'nightmarefuel': 'Nhiên liệu ác mộng',
    'moonrockidol': 'Tượng đá mặt trăng', 'gestalt_staff': 'Trượng Nguyệt Linh',
    'transistor': 'Bóng bán dẫn', 'redgem': 'Ngọc đỏ', 'bluegem': 'Ngọc lam',
    'greengem': 'Ngọc lục', 'purplegem': 'Ngọc tím', 'yellowgem': 'Ngọc vàng',
    'livinglog': 'Gỗ sống', 'boneshard': 'Mảnh xương', 'rocks': 'Đá',
    'flint': 'Đá lửa', 'twigs': 'Cành cây', 'cutgrass': 'Cỏ khô',
    'goldnugget': 'Vàng', 'marble': 'Cẩm thạch', 'silk': 'Tơ nhện',
    'armorruins': 'Giáp Thulecite', 'amulet': 'Bùa hộ mệnh', 'trident': 'Đinh ba',
    'townportaltalisman': 'Bùa dịch chuyển', 'thulecite_pieces': 'Mảnh Thulecite',
    'ruinshat': 'Vương miện Thulecite', 'staff_lunarplant': 'Trượng cây mặt trăng',
    'voidcloth_scythe': 'Lưỡi hái vải hư không', 'shadowheart_infused': 'Tim bóng tối cường hoá',
}

TECH_VI = {
    'SHADOWFORGING_TWO': 'Rèn Bóng Tối II', 'SHADOWFORGING_ONE': 'Rèn Bóng Tối I',
    'OBSIDIAN_TWO': 'Hắc Diệu Thạch II', 'OBSIDIAN_ONE': 'Hắc Diệu Thạch I',
    'LUNARFORGING_TWO': 'Rèn Nguyệt II', 'LUNARFORGING_ONE': 'Rèn Nguyệt I',
    'NONE': 'Không cần', 'SCIENCE_ONE': 'Khoa học I', 'SCIENCE_TWO': 'Khoa học II',
    'MAGIC_TWO': 'Ma thuật II', 'MAGIC_THREE': 'Ma thuật III',
    'ANCIENT_TWO': 'Viễn Cổ II', 'ANCIENT_FOUR': 'Viễn Cổ IV',
    'CELESTIAL_THREE': 'Thiên Thể III',
}

RECIPE = re.compile(
    r'AddRecipe2\(\s*"([a-z_0-9]+)"\s*,\s*\{(.*?)\}\s*,\s*TECH\.([A-Z_0-9]+)(.*?)\)\s*\n',
    re.S)
INGR = re.compile(r'Ingredient\(\s*"([a-z_0-9]+)"\s*,\s*(\d+)')


def main():
    vi = json.load(open(os.path.join(ROOT, 'translations', 'vi.json'), encoding='utf-8'))

    def name_of(p):
        return vi.get(f'STRINGS.NAMES.{p.upper()}') or VANILLA.get(p) or p
    def desc_of(p):
        return vi.get(f'STRINGS.CHARACTERS.GENERIC.DESCRIBE.{p.upper()}')
    def recipe_desc_of(p):
        return vi.get(f'STRINGS.RECIPE_DESC.{p.upper()}')

    imgs = set()
    idir = os.path.join(ROOT, 'wiki', 'img')
    if os.path.isdir(idir):
        imgs = {f[:-4] for f in os.listdir(idir) if f.endswith('.png')}

    recipes = {}
    for mod in ('core', 'base', 'nightmare'):
        d = os.path.join(ROOT, 'vendor', mod)
        for dp, _, fns in os.walk(d):
            for fn in fns:
                if not fn.endswith('.lua'):
                    continue
                try:
                    txt = open(os.path.join(dp, fn), encoding='utf-8').read()
                except Exception:
                    continue
                for m in RECIPE.finditer(txt):
                    prefab, ing_blob, tech, rest = m.groups()
                    ings = [(a, int(b)) for a, b in INGR.findall(ing_blob)]
                    station = 'CRAFTING_STATION' in rest
                    st = re.search(r'station_tag\s*=\s*"([^"]+)"', rest)
                    recipes[prefab] = {
                        'mod': mod, 'tech': tech, 'station': station,
                        'station_tag': st.group(1) if st else None,
                        'ingredients': [{'prefab': a, 'name': name_of(a), 'count': b}
                                        for a, b in ings],
                    }

    # Mọi thứ có tên tiếng Việt = mục của wiki
    entries = {}
    for key, val in vi.items():
        m = re.match(r'STRINGS\.NAMES\.([A-Z_0-9]+)$', key)
        if not m:
            continue
        p = m.group(1).lower()
        entries[p] = {
            'prefab': p,
            'name': val,
            'describe': desc_of(p),
            'recipe_desc': recipe_desc_of(p),
            'recipe': recipes.get(p),
            'image': f'img/{p}.png' if p in imgs else None,
        }

    # Phân loại theo tiền tố khoá và tên prefab
    def category(p, e):
        if p.startswith('buff_') or p.endswith('_buff') or p in (
                'nightvision_buff', 'healthregenbuff', 'healingsalve_acidbuff'):
            return 'Hiệu ứng'
        if p.endswith('_poison') or p in ('acid_poison',):
            return 'Chất độc'
        if p.endswith('_soul'):
            return 'Linh hồn'
        if e['recipe']:
            return 'Chế tạo được'
        if p.startswith('abyss_') or p in ('ancient_hulk', 'dreaddragon', 'shadowdragon',
                                           'leechterror', 'small_leechterror', 'calamityeye',
                                           'corrupt_heart', 'ironlord', 'spider_robot',
                                           'lunarthrall_plant_queen', 'void_peghook',
                                           'newcs_dragoon', 'ancient_scanner', 'hellblasts'):
            return 'Sinh vật & Boss'
        return 'Vật phẩm & Khác'

    for p, e in entries.items():
        e['category'] = category(p, e)

    stats = {
        'tong_muc': len(entries),
        'co_anh': sum(1 for e in entries.values() if e['image']),
        'co_mo_ta': sum(1 for e in entries.values() if e['describe']),
        'co_cong_thuc': sum(1 for e in entries.values() if e['recipe']),
        'cong_thuc_tim_duoc': len(recipes),
    }
    out = {'entries': entries, 'tech_vi': TECH_VI, 'stats': stats}
    os.makedirs(os.path.join(ROOT, 'wiki'), exist_ok=True)
    json.dump(out, open(os.path.join(ROOT, 'wiki', 'data.json'), 'w', encoding='utf-8'),
              ensure_ascii=False, indent=1, sort_keys=True)

    for k, v in stats.items():
        print(f"  {k}: {v}")
    from collections import Counter
    print("  theo nhóm:", dict(Counter(e['category'] for e in entries.values())))
    orphan = sorted(p for p in recipes if p not in entries)
    if orphan:
        print(f"  ⚠ công thức có nhưng KHÔNG có tên tiếng Việt ({len(orphan)}): {orphan[:8]}")
    return 0


if __name__ == '__main__':
    sys.exit(main())

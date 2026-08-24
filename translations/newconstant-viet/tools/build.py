#!/usr/bin/env python3
"""Ghép bản mod chơi được từ vendor/ + phần i18n của mình.

    python3 tools/build.py           dựng vào build/
    python3 tools/build.py --check   dựng rồi kiểm, không cài đi đâu

Ra hai thư mục mod, giữ nguyên quan hệ phụ thuộc của bản gốc:
    build/newconstant-core-vi/   (priority 0,    Core)
    build/newconstant-base-vi/   (priority -512, Base — cần Core)

Gộp hai mod làm một là phải gỡ rối hệ namespace và thứ tự nạp mà chúng phụ
thuộc vào (Base gọi GLOBAL.newcs_InitNamespace do Core cài). Rủi ro cao, không
lợi ích — nên giữ tách.
"""
import json, os, re, shutil, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, 'build')

# Khối chọn ngôn ngữ của mod gốc, sẽ bị thay bằng hệ i18n của mình.
LANG_BLOCK = re.compile(
    r'local\s+locale\s*=\s*modinfo\.locale\s*\n'
    r'if\s+locale\s*==\s*"zh".*?\nend\s*', re.S)

REPLACEMENT = '''-- ── Hệ ngôn ngữ thay thế (NewConstant Việt) ──────────────────────────────
-- Bản gốc dùng if/else hai nhánh zh/en, và bản "en" còn 65 chuỗi chưa dịch.
-- Bản này nạp bảng phẳng theo locale, có dự phòng vi → en → zh.
modimport("scripts/ncvi/bootstrap.lua")
'''


# Môi trường sandbox mà modimport chạy file trong đó CHỈ có sẵn ngần này.
# Gọi hàm ngoài danh sách sẽ chết lúc chạy với "attempt to call global 'X'
# (a nil value)" — luac không bắt được vì cú pháp vẫn hợp lệ. Đã dính rawget rồi
# lại dính pcall, nên chốt bằng kiểm tự động.
SANDBOX_WHITELIST = {
    'pairs', 'ipairs', 'print', 'math', 'table', 'type', 'string', 'tostring',
    'require', 'Class', 'TUNING', 'GLOBAL', 'modname', 'MODROOT',
    'modinfo', 'modimport', 'modrequire', 'env', 'GetModConfigData',
    'AddReplicableComponent', 'AddPrefabPostInit', 'AddComponentPostInit',
    'AddSimPostInit', 'AddPlayerPostInit', 'AddClassPostConstruct',
}


def check_sandbox(path):
    """Bắt hàm toàn cục không có trong sandbox, ở file nạp bằng modimport."""
    src = open(path, encoding='utf-8').read()
    code = re.sub(r'--.*', '', src)
    code = re.sub(r'"[^"]*"', '""', code)
    # Từ khoá Lua trông giống lời gọi hàm: function(, if(, while(, return(…
    KEYWORDS = {'function', 'if', 'while', 'for', 'return', 'and', 'or', 'not',
                'then', 'do', 'end', 'local', 'elseif', 'until', 'in'}
    calls = set(re.findall(r'(?<![\w.:])([a-zA-Z_]\w*)\s*\(', code)) - KEYWORDS
    declared = set()
    for grp in re.findall(r'local\s+(?:function\s+)?([\w, ]+)', code):
        declared |= {x.strip() for x in grp.split(',') if x.strip()}
    for grp in re.findall(r'function\s+(\w+)', code):
        declared.add(grp)
    return sorted(c for c in calls
                  if c not in SANDBOX_WHITELIST and c not in declared)


def luac_ok(path):
    r = subprocess.run(['luac', '-p', path], capture_output=True, text=True)
    return r.returncode == 0, r.stderr.strip()


# Trường bắt buộc phải còn sau khi vá. Thiếu api_version thì DST báo
# "Old API! (mod: nil)" rồi bỏ qua thứ tự nạp, và mod phụ thuộc sẽ chạy trước
# mod nó cần — đã dính đúng lỗi này một lần.
REQUIRED_MODINFO = ('name', 'version', 'version_compatible', 'api_version', 'priority')

# Phiên bản của BẢN VIỆT HOÁ, độc lập với version của tác giả gốc.
# Tăng số này mỗi lần upload lại lên Workshop, nếu không người dùng không biết
# có bản mới. Giữ nguyên version gốc thì Workshop coi như không đổi.
VI_VERSION = '1.0.1'
# version_compatible: BẮT BUỘC phải có. Thiếu nó thì DST khớp version tuyệt đối
# giữa client và server — lệch một chữ số là người chơi bị từ chối vào phòng.
VI_VERSION_COMPATIBLE = '1.0.0'

UPSTREAM = {
    'core':      ('0.9.25', '3645179905', 'Core'),
    'base':      ('0.9.35', '3191348907', 'Base'),
    'nightmare': ('0.9.30', '3645181516', 'Nightmare'),
}

DESC = {
 'core': 'Mô-đun nền của Vĩnh Hằng Tân Giới (永恒新界). Bắt buộc phải có.',
 'base': 'Nội dung nền của Vĩnh Hằng Tân Giới: sửa đổi các trùm, địa hình hang '
         'động, mưa lửa, kịch độc. KHÔNG bao gồm Vực Sâu.',
 'nightmare': 'Nội dung Viễn Cổ và Vực Sâu của Vĩnh Hằng Tân Giới.',
}


def make_description(mod):
    up_ver, up_id, label = UPSTREAM[mod]
    return (
        f"{DESC[mod]}\n\n"
        f"BẢN VIỆT HOÁ — {VI_VERSION}\n"
        f"Dịch đầy đủ 239 chuỗi sang tiếng Việt: tên vật phẩm, mô tả khi xem, "
        f"công thức chế tạo, tên hành động.\n"
        f"Chọn ngôn ngữ trong phần cấu hình của mod Core (Việt / English / 中文).\n\n"
        f"CẦN BẬT ĐỦ CẢ BA MOD: Core, Base, Nightmare.\n\n"
        f"NGUỒN GỐC\n"
        f"Mod gốc do 莫非则 viết — NewConstant {label}, phiên bản {up_ver}\n"
        f"https://steamcommunity.com/sharedfiles/filedetails/?id={up_id}\n"
        f"Toàn bộ gameplay, hình ảnh và âm thanh thuộc về tác giả gốc. "
        f"Bản này chỉ thay hệ thống ngôn ngữ và bổ sung bản dịch tiếng Việt."
    )


# Tuỳ chọn ngôn ngữ, chèn vào đầu configuration_options của Core.
# CẦN THIẾT vì DST không có locale tiếng Việt — `modinfo.locale` không bao giờ
# trả về "vi", nên chọn theo locale sẽ luôn ra tiếng Anh. Phát hiện khi chạy thử
# trên server thật: log báo `ngôn ngữ=en` dù đã dịch đủ 238 chuỗi.
LANG_OPTION = '''    {
        name = "ncvi_language",
        label = "Ngôn ngữ / Language",
        hover = "Ngôn ngữ hiển thị của mod. DST không có sẵn tiếng Việt nên phải chọn ở đây.",
        options = {
            { description = "Tiếng Việt", data = "vi" },
            { description = "English",    data = "en" },
            { description = "中文",        data = "zh" },
            { description = "Auto (theo game)", data = "auto" },
        },
        default = "vi",
    },
'''


def translate_modinfo_text(txt, mapping):
    """Thay chuỗi Hán trong modinfo bằng bản Việt.

    modinfo.lua được game đọc TRƯỚC khi nạp Lua của mod, nên các nhãn cấu hình
    không đi qua bảng STRINGS được — phải thay thẳng vào văn bản lúc build.
    Thay từ chuỗi DÀI xuống ngắn để chuỗi ngắn không cắt vào giữa chuỗi dài.
    """
    n = 0
    for cn in sorted(mapping, key=len, reverse=True):
        if cn.startswith('_'):
            continue
        if cn in txt:
            txt = txt.replace(cn, mapping[cn])
            n += 1
    return txt, n


def patch_modinfo(path, name_vi, note, inject_lang=False, mod_key=None):
    """Đọc XONG rồi mới ghi.

    ⚠ Không được viết open(p,'w').write(patch(p)): Python dựng open(p,'w') TRƯỚC,
    thao tác đó cắt file về rỗng, rồi patch(p) mới đọc — và đọc phải file rỗng.
    luac không bắt được vì file rỗng vẫn là Lua hợp lệ.
    """
    txt = open(path, encoding='utf-8').read()
    if not txt.strip():
        raise SystemExit(f'✗ modinfo rỗng trước khi vá: {path}')
    txt = re.sub(r'^name\s*=.*$', f'name = "{name_vi}"', txt, count=1, flags=re.M)

    # version của BẢN VIỆT, và version_compatible (thiếu là client không vào được)
    txt = re.sub(r'^\s*version\s*=.*$', f'version = "{VI_VERSION}"', txt, count=1, flags=re.M)
    if not re.search(r'^\s*version_compatible\s*=', txt, re.M):
        txt = re.sub(r'^(version\s*=.*)$',
                     r'\1\nversion_compatible = "' + VI_VERSION_COMPATIBLE + '"',
                     txt, count=1, flags=re.M)

    # Thay HẲN description thay vì dịch chuỗi con — dịch chuỗi con làm vỡ câu
    # (đã ra "永恒新界的底层模块，Xem thêm ở trang Workshop...").
    if mod_key:
        new_desc = 'description = [[' + make_description(mod_key) + ']]'
        txt, nd = re.subn(r'description\s*=\s*(\[\[.*?\]\]|"[^"]*")',
                          lambda m: new_desc, txt, count=1, flags=re.S)
        if nd == 0:
            txt = txt.replace('api_version', new_desc + '\napi_version', 1)

    mapping = json.load(open(os.path.join(ROOT, 'translations', 'modinfo_vi.json'),
                             encoding='utf-8'))
    txt, n_tr = translate_modinfo_text(txt, mapping)

    if inject_lang:
        txt, n_inj = re.subn(r'(configuration_options\s*=\s*\{\s*\n)',
                             r'\1' + LANG_OPTION, txt, count=1)
        if n_inj != 1:
            raise SystemExit(f'✗ không chèn được tuỳ chọn ngôn ngữ vào {path}')
    print(f"    dịch {n_tr} chuỗi trong modinfo"
          + (", đã chèn tuỳ chọn ngôn ngữ" if inject_lang else ""))
    header = (f'-- {note}\n'
              f'-- Mod gốc: 莫非则. Bản dựng lại chỉ thay hệ ngôn ngữ + dịch tiếng Việt.\n'
              f'-- Gameplay và assets giữ nguyên của tác giả gốc.\n\n')
    out = header + txt
    open(path, 'w', encoding='utf-8').write(out)
    return out


def check_modinfo(path, label):
    """Xác nhận bản dựng còn đủ trường sống còn."""
    txt = open(path, encoding='utf-8').read()
    missing = [f for f in REQUIRED_MODINFO
               if not re.search(rf'^\s*{f}\s*=', txt, re.M)]
    n = len(txt.splitlines())
    if missing:
        print(f"    ✗ {label}: THIẾU {', '.join(missing)}  ({n} dòng)")
        return False
    print(f"    ✓ {label}: đủ {len(REQUIRED_MODINFO)} trường bắt buộc ({n} dòng)")
    return True


def build_core():
    dst = os.path.join(BUILD, 'newconstant-core-vi')
    shutil.copytree(os.path.join(ROOT, 'vendor', 'core'), dst)

    # Bỏ hệ ngôn ngữ cũ — đã thay hoàn toàn.
    old = os.path.join(dst, 'scripts', 'languages')
    n_old = sum(len(f) for _, _, f in os.walk(old)) if os.path.isdir(old) else 0
    shutil.rmtree(old, ignore_errors=True)

    # Đưa phần của mình vào.
    for sub in ('ncvi', 'lang'):
        shutil.copytree(os.path.join(ROOT, 'scripts', sub),
                        os.path.join(dst, 'scripts', sub))

    mm = os.path.join(dst, 'modmain.lua')
    txt = open(mm, encoding='utf-8').read()
    patched, n = LANG_BLOCK.subn(REPLACEMENT, txt, count=1)
    if n != 1:
        raise SystemExit('✗ không tìm thấy khối chọn ngôn ngữ trong core/modmain.lua')
    open(mm, 'w', encoding='utf-8').write(patched)

    patch_modinfo(os.path.join(dst, 'modinfo.lua'),
                  'NewConstant Core - Việt hoá', 'NewConstant Core — bản Việt',
                  mod_key='core',
                  inject_lang=True)
    return dst, n_old


# mod_dependencies của bản gốc trỏ vào workshop ID gốc. Bật bản dựng lại và TẮT
# bản Workshop thì kiểm tra phụ thuộc trượt ngay, DST từ chối nạp. DST chấp nhận
# khớp theo TÊN THƯ MỤC (khoá thứ hai, giá trị false), nên viết lại theo tên
# thư mục của bản dựng.
DEP_MAP = {
    'workshop-3645179905': 'newconstant-core-vi',
    'workshop-3645181516': 'newconstant-nightmare-vi',
}


def patch_dependencies(path):
    """GỠ BỎ mod_dependencies khỏi bản dựng.

    Vì sao gỡ chứ không viết lại: bản gốc trỏ vào workshop ID, mà bản Workshop
    sẽ bị tắt khi dùng bản này -> không giải được. Viết lại theo tên thư mục
    thì logic của game (BuildModPriorityList) chấp nhận — đã kiểm bằng cách chạy
    chính code đó ngoài máy — NHƯNG thực tế trong game vẫn sập:

        scripts/modindex.lua:1153: table index is nil
        GetModDependencies -> mods_dep[1] = nil  (danh sách phụ thuộc rỗng)

    Sập ở phụ thuộc thứ HAI (nightmare) trong khi thứ nhất (core) giải được.
    Tôi không truy ra được nguyên nhân chính xác của khác biệt đó.

    Gỡ hẳn khai báo thì game không chạy vào nhánh giải phụ thuộc nữa — hết sập.
    Đánh đổi: game không tự bật mod phụ thuộc giúp, người chơi phải bật đủ ba
    mod bằng tay. Điều này đã ghi rõ trong description và trong sync_local.sh.
    """
    txt = open(path, encoding='utf-8').read()
    m = re.search(r'mod_dependencies\s*=\s*\{', txt)
    if not m:
        return 0
    # tìm khối cân bằng
    i, depth = m.end() - 1, 0
    while i < len(txt):
        if txt[i] == '{':
            depth += 1
        elif txt[i] == '}':
            depth -= 1
            if depth == 0:
                break
        i += 1
    block = txt[m.start():i + 1]
    n = len(re.findall(r'\{[^{}]*\}', block))
    note = ('-- mod_dependencies ĐÃ GỠ trong bản dựng lại. Xem tools/build.py để\n'
            '-- biết lý do (game sập ở GetModDependencies). Phải bật ĐỦ BA mod\n'
            '-- bằng tay: Core, Nightmare, Base.\n')
    open(path, 'w', encoding='utf-8').write(txt[:m.start()] + note + txt[i + 1:].lstrip('\n'))
    return n


def build_nightmare():
    dst = os.path.join(BUILD, 'newconstant-nightmare-vi')
    shutil.copytree(os.path.join(ROOT, 'vendor', 'nightmare'), dst)

    # Mod gốc không có modicon (hai dòng icon_atlas/icon bị chú thích sẵn) nên
    # trên Workshop sẽ hiện ô trống. Icon tự làm nằm ở assets/, tạo bằng
    # tools/ktex.py (PNG -> DXT5 -> KTEX).
    for src, dstname in (('nightmare_modicon.tex', 'modicon.tex'),
                         ('nightmare_modicon.xml', 'modicon.xml')):
        p = os.path.join(ROOT, 'assets', src)
        if os.path.exists(p):
            shutil.copy(p, os.path.join(dst, dstname))
    # scripts/languages/ của mod này là FILE CHẾT — không modmain nào nạp chúng
    # (đã kiểm: không file nào require/modimport tới). Bỏ đi cho khỏi hiểu nhầm.
    dead = os.path.join(dst, 'scripts', 'languages')
    n_dead = sum(len(f) for _, _, f in os.walk(dead)) if os.path.isdir(dead) else 0
    shutil.rmtree(dead, ignore_errors=True)
    mi = os.path.join(dst, 'modinfo.lua')
    txt = open(mi, encoding='utf-8').read()
    open(mi, 'w', encoding='utf-8').write(
        txt.replace('--icon_atlas = "modicon.xml"', 'icon_atlas = "modicon.xml"')
           .replace('--icon = "modicon.tex"', 'icon = "modicon.tex"'))
    patch_modinfo(mi, 'NewConstant Nightmare - Việt hoá', 'NewConstant Nightmare — bản Việt',
                  mod_key='nightmare')
    n_dep = patch_dependencies(os.path.join(dst, 'modinfo.lua'))
    return dst, n_dead, n_dep


def build_base():
    dst = os.path.join(BUILD, 'newconstant-base-vi')
    shutil.copytree(os.path.join(ROOT, 'vendor', 'base'), dst)
    patch_modinfo(os.path.join(dst, 'modinfo.lua'),
                  'NewConstant Base - Việt hoá', 'NewConstant Base — bản Việt',
                  mod_key='base')
    n_dep = patch_dependencies(os.path.join(dst, 'modinfo.lua'))
    return dst, n_dep


def main():
    if not os.path.isdir(os.path.join(ROOT, 'scripts', 'lang')):
        raise SystemExit('✗ chưa có scripts/lang — chạy tools/gen_lang.py trước')

    shutil.rmtree(BUILD, ignore_errors=True)
    os.makedirs(BUILD)

    core, n_old = build_core()
    print(f"  ✓ core → {os.path.relpath(core, ROOT)}  (bỏ {n_old} file ngôn ngữ cũ)")
    base, nb_dep = build_base()
    print(f"  ✓ base → {os.path.relpath(base, ROOT)}  (gỡ {nb_dep} khai báo phụ thuộc)")
    night, n_dead, nn_dep = build_nightmare()
    print(f"  ✓ nightmare → {os.path.relpath(night, ROOT)}  "
          f"(bỏ {n_dead} file ngôn ngữ chết, gỡ {nn_dep} khai báo phụ thuộc)")

    # Kiểm cú pháp MỌI file lua trong bản dựng — bản gốc có thể có file hỏng sẵn,
    # nên so cả với vendor để biết lỗi là của ai.
    # preview.png phải sinh SAU khi copytree, nếu không sẽ bị chép đè mất.
    try:
        import subprocess as _sp
        _sp.run([sys.executable, os.path.join(ROOT, 'tools', 'make_preview.py')],
                check=True, capture_output=True)
        print("  ✓ sinh preview.png cho cả 3 mod")
    except Exception as e:
        print(f"  ⚠ không sinh được preview: {e}")

    print("\n  === kiểm cú pháp Lua toàn bộ bản dựng ===")
    bad = []
    total = 0
    for d in (core, base, night):
        for dp, _, fns in os.walk(d):
            for fn in fns:
                if fn.endswith('.lua'):
                    total += 1
                    p = os.path.join(dp, fn)
                    ok, err = luac_ok(p)
                    if not ok:
                        bad.append((os.path.relpath(p, BUILD), err.splitlines()[0] if err else ''))
    print(f"    {total} file lua, {len(bad)} lỗi")
    for p, e in bad[:10]:
        print(f"      ✗ {p}: {e}")

    print("\n  === hàm toàn cục ngoài sandbox (file chạy qua modimport) ===")
    bs = os.path.join(core, 'scripts', 'ncvi', 'bootstrap.lua')
    off = check_sandbox(bs)
    if off:
        print(f"    ✗ bootstrap.lua gọi {len(off)} hàm KHÔNG có trong sandbox: {', '.join(off)}")
        print(f"      → lấy qua _G, ví dụ: local pcall = _G.pcall")
        bad.append(('bootstrap.lua', 'gọi hàm ngoài sandbox'))
    else:
        print("    ✓ bootstrap.lua không gọi hàm nào ngoài sandbox")

    # Mọi .tex phải có platform=0, nếu không game macOS sập khi vẽ texture
    # (assert Platform() == PLATFORM_OPENGL). Đã dính một lần với modicon tự tạo.
    print("\n  === header .tex hợp lệ ===")
    import struct as _st
    bad_tex = []
    for d in (core, base, night):
        for dp, _, fns in os.walk(d):
            for fn in fns:
                if not fn.endswith('.tex'):
                    continue
                fp = os.path.join(dp, fn)
                with open(fp, 'rb') as fh:
                    head = fh.read(8)
                if head[:4] != b'KTEX':
                    continue
                plat = _st.unpack('<I', head[4:8])[0] & 0xF
                if plat != 0:
                    bad_tex.append((os.path.relpath(fp, BUILD), plat))
    if bad_tex:
        for fp, pl in bad_tex[:6]:
            print(f"    ✗ {fp}: platform={pl} (phải là 0) → game sẽ SẬP")
        bad.append(('tex', 'platform sai'))
    else:
        print("    ✓ mọi .tex đều platform=0")

    print("\n  === file bắt buộc để upload Workshop ===")
    for d in (core, base, night):
        miss = [f for f in ('modinfo.lua', 'modmain.lua', 'modicon.tex',
                            'modicon.xml', 'preview.png')
                if not os.path.exists(os.path.join(d, f))]
        if miss:
            print(f"    ✗ {os.path.basename(d)}: thiếu {', '.join(miss)}")
            bad.append((os.path.basename(d), 'thiếu file upload'))
        else:
            print(f"    ✓ {os.path.basename(d)}: đủ 5 file")

    print("\n  === modinfo còn đủ trường bắt buộc ===")
    mi_ok = all([check_modinfo(os.path.join(core, 'modinfo.lua'), 'core'),
                 check_modinfo(os.path.join(base, 'modinfo.lua'), 'base'),
                 check_modinfo(os.path.join(night, 'modinfo.lua'), 'nightmare')])
    if not mi_ok:
        bad.append(('modinfo', 'thiếu trường bắt buộc'))

    print("\n  === xác nhận đã thay hệ ngôn ngữ ===")
    mm = open(os.path.join(core, 'modmain.lua'), encoding='utf-8').read()
    print(f"    còn require languages.newstring : {'CÓ ✗' if 'languages.newstring' in mm else 'không ✓'}")
    print(f"    có gọi bootstrap                : {'có ✓' if 'ncvi/bootstrap' in mm else 'KHÔNG ✗'}")
    print(f"    thư mục languages cũ còn không  : "
          f"{'CÒN ✗' if os.path.isdir(os.path.join(core,'scripts','languages')) else 'đã xoá ✓'}")

    for d in (core, base, night):
        sz = subprocess.run(['du', '-sh', d], capture_output=True, text=True).stdout.split()[0]
        print(f"    {os.path.basename(d)}: {sz}")

    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())

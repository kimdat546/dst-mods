#!/usr/bin/env python3
"""Moi sprite của quái/công trình ra khỏi file anim/*.zip của Klei.

Mỗi zip chứa build.bin (bảng ký hiệu + toạ độ trên atlas) và atlas-0.tex (ảnh).
Ảnh túi đồ chỉ có cho vật phẩm cầm được; quái, boss, công trình thì sprite nằm
trong đây.

Cấu trúc build.bin (BILD, version 6):
    "BILD"                4 byte
    version               u32
    numsymbols            u32
    numframes             u32
    len + tên build
    numatlases u32, rồi mỗi atlas: len + tên
    với mỗi symbol:
        hash u32, numframes u32   (KHÔNG có colourflags — đã kiểm bằng cách
                                   dump byte thật, tài liệu ngoài mạng ghi sai)
        mỗi frame: framenum u32, duration u32, x f32, y f32, w f32, h f32,
                   vertidx u32, numverts u32
    numverts u32, rồi mảng vertex: x y z u v w (6 float32)

Toạ độ trên atlas nằm ở u,v của vertex — lấy min/max của các vertex thuộc frame
là ra hình chữ nhật cần cắt.
"""
import os
import struct
import sys
import zipfile
from io import BytesIO

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
from ktex import read as ktex_read


def _str(buf, off):
    (n,) = struct.unpack_from('<I', buf, off)
    return buf[off + 4:off + 4 + n].decode('utf-8', 'replace'), off + 4 + n


def parse_build(buf):
    """Trả về danh sách frame: (tên_symbol_hash, u1, v1, u2, v2)."""
    if buf[:4] != b'BILD':
        return []
    ver, numsym, numframes = struct.unpack_from('<3I', buf, 4)
    off = 16
    _name, off = _str(buf, off)
    (natlas,) = struct.unpack_from('<I', buf, off); off += 4
    for _ in range(natlas):
        _a, off = _str(buf, off)

    frames = []
    for _ in range(numsym):
        (h,) = struct.unpack_from('<I', buf, off); off += 4
        (nf,) = struct.unpack_from('<I', buf, off); off += 4
        for _ in range(nf):
            _fn, _dur, _x, _y, _w, _hh, vidx, nv = struct.unpack_from('<2I4f2I', buf, off)
            off += 32
            frames.append((h, vidx, nv))

    (nverts,) = struct.unpack_from('<I', buf, off); off += 4
    verts = struct.unpack_from(f'<{nverts * 6}f', buf, off)

    out = []
    for h, vidx, nv in frames:
        us, vs = [], []
        for i in range(vidx, vidx + nv):
            us.append(verts[i * 6 + 3])
            vs.append(verts[i * 6 + 4])
        if us and vs:
            out.append((h, min(us), min(vs), max(us), max(vs)))
    return out


def biggest_sprite(zip_path):
    """Trả về (PIL.Image, ghi_chú) — khung hình LỚN NHẤT trong file anim."""
    try:
        z = zipfile.ZipFile(zip_path)
    except zipfile.BadZipFile:
        return None, 'zip hỏng'
    names = z.namelist()
    if 'build.bin' not in names:
        return None, 'không có build.bin'
    atlas_name = next((n for n in names if n.startswith('atlas') and n.endswith('.tex')), None)
    if atlas_name is None:
        return None, 'không có atlas'

    frames = parse_build(z.read('build.bin'))
    if not frames:
        return None, 'không đọc được build.bin'

    tmp = BytesIO(z.read(atlas_name))
    tmp_path = zip_path + '.tmp.tex'
    open(tmp_path, 'wb').write(tmp.getvalue())
    try:
        sheet, info = ktex_read(tmp_path)
    finally:
        os.remove(tmp_path)
    if sheet is None:
        return None, f'atlas: {info}'

    W, H = sheet.size
    best, area = None, 0
    for _h, u1, v1, u2, v2 in frames:
        L, T = round(u1 * W), round((1 - v2) * H)
        R, B = round(u2 * W), round((1 - v1) * H)
        if R - L < 8 or B - T < 8:
            continue
        a = (R - L) * (B - T)
        if a > area:
            area, best = a, (L, T, R, B)
    if best is None:
        return None, 'không có khung nào đủ lớn'

    img = sheet.crop(best)
    # bỏ viền trong suốt để icon cân đối
    bbox = img.getchannel('A').getbbox()
    if bbox:
        img = img.crop(bbox)
    if img.width < 8 or img.height < 8:
        return None, 'khung quá nhỏ sau khi cắt viền'
    return img, f'{img.width}x{img.height} (từ {len(frames)} khung)'


if __name__ == '__main__':
    for p in sys.argv[1:]:
        img, info = biggest_sprite(p)
        print(f'{os.path.basename(p)}: {info}')
        if img:
            img.save(p.replace('.zip', '.png'))

#!/usr/bin/env python3
"""Giải mã ảnh .tex của Klei (magic KTEX) ra PNG.

Không dùng ktech/krane (không có trên máy). Cách làm: đọc header KTEX, lấy mipmap
lớn nhất, bọc lại thành header DDS rồi để Pillow giải nén DXT — Pillow có sẵn
DXT1/DXT3/DXT5.

Cấu trúc KTEX:
    "KTEX"            4 byte
    header            4 byte, bitfield little-endian:
                        bit  0-3   platform
                        bit  4-8   pixel format
                        bit  9-12  texture type
                        bit 13-17  số mipmap
                        bit 18-19  flags
    với mỗi mipmap:   width u16, height u16, pitch u16, datasize u32
    rồi lần lượt là dữ liệu từng mipmap
"""
import struct
import sys
from io import BytesIO

PIXELFORMAT = {0: 'DXT1', 1: 'DXT3', 2: 'DXT5', 4: 'ARGB', 5: 'RGB'}


def _dds_header(w, h, fourcc, datasize):
    """Dựng header DDS 128 byte cho dữ liệu DXT nén."""
    flags = 0x1 | 0x2 | 0x4 | 0x1000 | 0x80000          # CAPS HEIGHT WIDTH PIXELFORMAT LINEARSIZE
    hdr = b'DDS ' + struct.pack('<7I', 124, flags, h, w, datasize, 0, 0)
    hdr += b'\x00' * 44                                  # reserved
    hdr += struct.pack('<2I', 32, 0x4)                    # pixelformat size, FOURCC
    hdr += fourcc.encode()
    hdr += struct.pack('<5I', 0, 0, 0, 0, 0)
    hdr += struct.pack('<5I', 0x1000, 0, 0, 0, 0)         # caps = TEXTURE
    return hdr


def read(path):
    """Trả về (PIL.Image, thông tin) hoặc (None, lý do)."""
    data = open(path, 'rb').read()
    if data[:4] != b'KTEX':
        return None, 'không phải KTEX'

    (raw,) = struct.unpack('<I', data[4:8])
    fmt_id = (raw >> 4) & 0x1F
    nummips = (raw >> 13) & 0x1F
    fmt = PIXELFORMAT.get(fmt_id)
    if fmt is None:
        return None, f'định dạng pixel lạ: {fmt_id}'
    if nummips == 0:
        return None, 'không có mipmap'

    # Bảng mipmap: mip lớn nhất đứng đầu.
    off = 8
    mips = []
    for _ in range(nummips):
        w, h, pitch = struct.unpack('<3H', data[off:off + 6])
        (size,) = struct.unpack('<I', data[off + 6:off + 10])
        mips.append((w, h, pitch, size))
        off += 10

    w, h, _pitch, size = mips[0]
    blob = data[off:off + size]

    if fmt in ('DXT1', 'DXT3', 'DXT5'):
        from PIL import Image
        dds = _dds_header(w, h, fmt, size) + blob
        img = Image.open(BytesIO(dds))
        img.load()
        # Klei lưu texture theo chiều TỪ DƯỚI LÊN → phải lật mới ra đúng chiều.
        # Lỗi này im lặng với sprite đối xứng; chỉ lộ ra khi ảnh có CHỮ
        # (modicon đọc thành "ИEM COИƧTAИT"). Đã kiểm bằng mắt trên modicon,
        # chai thuốc, giáp và giáo — cả bốn đều phải lật.
        img = img.transpose(Image.FLIP_TOP_BOTTOM)
        return img.convert('RGBA'), f'{fmt} {w}x{h}'

    if fmt == 'ARGB':
        from PIL import Image
        img = Image.frombytes('RGBA', (w, h), blob[:w * h * 4], 'raw', 'BGRA')
        img = img.transpose(Image.FLIP_TOP_BOTTOM)
        return img, f'ARGB {w}x{h}'

    return None, f'chưa hỗ trợ {fmt}'


if __name__ == '__main__':
    for p in sys.argv[1:]:
        img, info = read(p)
        print(f'{p}: {info}' if img else f'{p}: LỖI — {info}')
        if img:
            out = p.rsplit('.', 1)[0] + '.png'
            img.save(out)
            print(f'   → {out}')


# ── Ghi ngược: PNG → .tex ───────────────────────────────────────────────────
def write(img, path, fmt='DXT5'):
    """Ghi PIL.Image ra file .tex của Klei.

    Cách làm ngược với read(): để Pillow nén DXT ra DDS, cắt bỏ 128 byte header
    DDS rồi bọc lại bằng header KTEX. Cần cho việc tự làm modicon/asset.
    Kích thước phải là bội của 4 (yêu cầu của DXT).
    """
    import struct as _s
    from io import BytesIO as _B
    from PIL import Image

    w, h = img.size
    w, h = w - w % 4, h - h % 4
    if w < 4 or h < 4:
        raise ValueError('ảnh quá nhỏ cho DXT (cần ≥4x4)')
    img = img.convert('RGBA').resize((w, h))
    # ghi ngược lại theo chiều của Klei (từ dưới lên) — xem chú thích ở read()
    img = img.transpose(Image.FLIP_TOP_BOTTOM)

    buf = _B()
    img.save(buf, format='DDS', pixel_format=fmt)
    blob = buf.getvalue()[128:]                     # bỏ header DDS

    fmt_id = {'DXT1': 0, 'DXT3': 1, 'DXT5': 2}[fmt]
    # ⚠ platform PHẢI = 0. Mọi file .tex gốc của Klei và của tác giả mod đều
    # dùng 0; đặt giá trị khác thì game macOS ném assert ngay khi vẽ texture:
    #   Assert failure 'Platform() == PLATFORM_OPENGL' (renderlib/OpenGL/HWTexture.cpp)
    # và SẬP GAME — không phải báo lỗi mod, nên rất khó đoán ra nguồn.
    # Đã dính đúng lỗi này: modicon tự tạo làm game sập khi mở menu Mods.
    raw = (0 & 0xF) | ((fmt_id & 0x1F) << 4) | ((1 & 0xF) << 9) | ((1 & 0x1F) << 13)
    out = b'KTEX' + _s.pack('<I', raw)
    out += _s.pack('<3H', w, h, 0) + _s.pack('<I', len(blob))
    out += blob
    open(path, 'wb').write(out)
    return len(out)

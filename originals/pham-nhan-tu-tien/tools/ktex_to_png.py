#!/usr/bin/env python3
"""Minimal KTEX (Klei .tex) -> PNG decoder. Handles DXT1/DXT3/DXT5.
Decodes the largest mipmap. Requires Pillow (pip install pillow).

Usage: ktex_to_png.py input.tex output.png
"""
import struct, sys
from PIL import Image


def unpack565(c):
    r = (c >> 11) & 0x1F
    g = (c >> 5) & 0x3F
    b = c & 0x1F
    return (r << 3) | (r >> 2), (g << 2) | (g >> 4), (b << 3) | (b >> 2)


def decode_dxt_block_colors(block, off):
    c0, c1 = struct.unpack_from("<HH", block, off)
    bits = struct.unpack_from("<I", block, off + 4)[0]
    r0, g0, b0 = unpack565(c0)
    r1, g1, b1 = unpack565(c1)
    colors = [(r0, g0, b0), (r1, g1, b1)]
    if c0 > c1:
        colors.append(((2*r0+r1)//3, (2*g0+g1)//3, (2*b0+b1)//3))
        colors.append(((r0+2*r1)//3, (g0+2*g1)//3, (b0+2*b1)//3))
    else:
        colors.append(((r0+r1)//2, (g0+g1)//2, (b0+b1)//2))
        colors.append((0, 0, 0))
    idx = [(bits >> (2*i)) & 0x3 for i in range(16)]
    return colors, idx


def decode(data, fmt, w, h, pixoff):
    img = Image.new("RGBA", (w, h))
    px = img.load()
    bw, bh = (w + 3) // 4, (h + 3) // 4
    block_size = 8 if fmt == "DXT1" else 16
    p = pixoff
    for by in range(bh):
        for bx in range(bw):
            block = data[p:p + block_size]
            if fmt == "DXT1":
                colors, idx = decode_dxt_block_colors(block, 0)
                alphas = [255] * 16
                # punch-through alpha for DXT1 handled loosely
            elif fmt == "DXT3":
                a_raw = struct.unpack_from("<Q", block, 0)[0]
                alphas = [((a_raw >> (4*i)) & 0xF) * 17 for i in range(16)]
                colors, idx = decode_dxt_block_colors(block, 8)
            else:  # DXT5
                a0, a1 = block[0], block[1]
                abits = int.from_bytes(block[2:8], "little")
                acodes = [(abits >> (3*i)) & 0x7 for i in range(16)]
                alut = [a0, a1]
                if a0 > a1:
                    for k in range(1, 7):
                        alut.append(((7-k)*a0 + k*a1)//7)
                else:
                    for k in range(1, 5):
                        alut.append(((5-k)*a0 + k*a1)//5)
                    alut += [0, 255]
                alphas = [alut[c] for c in acodes]
                colors, idx = decode_dxt_block_colors(block, 8)
            for i in range(16):
                x = bx*4 + (i % 4)
                y = by*4 + (i // 4)
                if x < w and y < h:
                    r, g, b = colors[idx[i]]
                    px[x, y] = (r, g, b, alphas[i])
            p += block_size
    return img


def main():
    src, dst = sys.argv[1], sys.argv[2]
    data = open(src, "rb").read()
    assert data[:4] == b"KTEX", "not a KTEX file"
    spec = struct.unpack_from("<I", data, 4)[0]
    pixel_format = (spec >> 4) & 0x1F
    mipcount = (spec >> 13) & 0x1F
    fmt_map = {0: "DXT1", 1: "DXT3", 2: "DXT5", 4: "RGBA", 5: "RGB"}
    fmt = fmt_map.get(pixel_format, "DXT5")
    print(f"format={fmt} mips={mipcount}")

    off = 8
    # Read mipmap headers: each = width(u16) height(u16) pitch(u16) datasize(u32)
    mips = []
    for _ in range(mipcount):
        w, h, pitch, size = struct.unpack_from("<HHHI", data, off)
        off += 10
        mips.append((w, h, size))
    # Largest mip is first
    w, h, size = mips[0]
    pixoff = off
    print(f"largest mip: {w}x{h} size={size}")
    img = decode(data, fmt, w, h, pixoff)
    # KTEX stores upside-down
    img = img.transpose(Image.FLIP_TOP_BOTTOM)
    img.save(dst)
    print(f"saved {dst}")


if __name__ == "__main__":
    main()

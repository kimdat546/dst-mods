#!/usr/bin/env python3
"""PNG -> KTEX (.tex) encoder, uncompressed RGBA. DST reads this fine.
Usage: png_to_ktex.py input.png output.tex [size]
  size: optional square resize (e.g. 64). Default keep, but pad to pow2.
"""
import struct, sys
from PIL import Image

def to_pow2(n):
    p = 1
    while p < n: p *= 2
    return p

def main():
    src, dst = sys.argv[1], sys.argv[2]
    size = int(sys.argv[3]) if len(sys.argv) > 3 else None
    img = Image.open(src).convert("RGBA")
    if size:
        img = img.resize((size, size), Image.LANCZOS)
    w, h = img.size
    # pad to power-of-two if needed
    pw, ph = to_pow2(w), to_pow2(h)
    if (pw, ph) != (w, h):
        canvas = Image.new("RGBA", (pw, ph), (0,0,0,0))
        canvas.paste(img, ((pw-w)//2, (ph-h)//2))
        img = canvas; w, h = pw, ph

    # KTEX spec: platform=0, pixel_format=4(RGBA), texture_type=1, mips=1, fill=0xFFF
    spec = 0
    spec |= (4 & 0x1F) << 4
    spec |= (1 & 0xF) << 9
    spec |= (1 & 0x1F) << 13
    spec |= (0xFFF) << 20

    out = bytearray()
    out += b"KTEX"
    out += struct.pack("<I", spec)
    # mipmap header
    out += struct.pack("<HHHI", w, h, w*4, w*h*4)
    # pixel data: flipped vertically, BGRA byte order (Klei convention)
    px = img.load()
    for y in range(h-1, -1, -1):
        for x in range(w):
            r,g,b,a = px[x,y]
            out += bytes((b,g,r,a))
    open(dst,"wb").write(out)
    print(f"wrote {dst}: {w}x{h} RGBA")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Sinh preview.png 512x512 cho Workshop, dùng art của chính từng mod."""
import os, sys
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0,os.path.join(ROOT,'tools'))
from ktex import read
from PIL import Image, ImageDraw, ImageFont

FONT="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
if not os.path.exists(FONT): FONT="/System/Library/Fonts/Helvetica.ttc"

SPEC=[("core","CORE",(26,32,54),(92,124,196)),
      ("nightmare","NIGHTMARE",(30,16,44),(150,96,206)),
      ("base","BASE",(44,22,16),(214,116,56))]

def main():
    for mod,label,bg,accent in SPEC:
        im=Image.new('RGBA',(512,512),bg+(255,)); d=ImageDraw.Draw(im)
        for r in range(300,0,-2):
            t=1-r/300
            d.ellipse([256-r,180-r,256+r,180+r],
                      fill=tuple(int(bg[i]+(accent[i]-bg[i])*t*0.5) for i in range(3))+(255,))
        icon,_=read(os.path.join(ROOT,'build',f'newconstant-{mod}-vi','modicon.tex'))
        if icon:
            b=icon.getchannel('A').getbbox()
            if b: icon=icon.crop(b)
            icon.thumbnail((248,248))
            im.alpha_composite(icon,((512-icon.width)//2,168-icon.height//2))
        f1=ImageFont.truetype(FONT,40); f2=ImageFont.truetype(FONT,58)
        f3=ImageFont.truetype(FONT,34)
        def ctr(t,y,f,fill):
            w=d.textbbox((0,0),t,font=f)[2]; d.text(((512-w)//2,y),t,font=f,fill=fill)
        ctr("NewConstant",312,f1,(238,242,250,255))
        ctr(label,358,f2,accent+(255,))
        # dải nền đặc thay vì ô bo mờ — chữ tiếng Việt nổi rõ trên nền tối
        d.rectangle([0,438,512,500],fill=(0,0,0,150))
        ctr("BẢN VIỆT HOÁ",452,f3,(255,232,150,255))
        im.save(os.path.join(ROOT,'build',f'newconstant-{mod}-vi','preview.png'))
        im.save(os.path.join(ROOT,'assets',f'preview_{mod}.png'))
        print(f"  ✓ preview {mod}")
    return 0

if __name__=='__main__': sys.exit(main())

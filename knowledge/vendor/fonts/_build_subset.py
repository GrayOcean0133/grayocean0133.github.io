# -*- coding: utf-8 -*-
"""把 Noto Sans SC 子集化为第六章用到的字，并把 family 名改成 SimHei。
源字体 SIL OFL 开源、可再分发；OFL 无保留字名，允许重命名。一次性脚本。"""
import os
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.subset import Subsetter, Options

SRC = r"C:\Windows\Fonts\NotoSansSC-VF.ttf"
MD = r"E:\grayocean0133.github.io\knowledge\chapters\chapter6\chapter6.md"
OUT_DIR = r"E:\grayocean0133.github.io\knowledge\vendor\fonts"
OUT = os.path.join(OUT_DIR, "cjk-subset.ttf")
os.makedirs(OUT_DIR, exist_ok=True)

text = open(MD, encoding="utf-8").read()
chars = set()
for ch in text:
    o = ord(ch)
    if 0x4E00 <= o <= 0x9FFF or 0x3000 <= o <= 0x303F or 0xFF00 <= o <= 0xFFEF:
        chars.add(ch)
ascii_set = "".join(chr(c) for c in range(0x20, 0x7F))
keep_text = ascii_set + "".join(sorted(chars))
print("CJK chars:", len(chars), " total subset chars:", len(keep_text))

f = TTFont(SRC)
if "fvar" in f:
    instantiateVariableFont(f, {"wght": 400}, inplace=True)

NEW_FAMILY = "SimHei"
for rec in f["name"].names:
    if rec.nameID in (1, 16):
        rec.string = NEW_FAMILY
    elif rec.nameID in (2, 17):
        rec.string = "Regular"
    elif rec.nameID == 4:
        rec.string = NEW_FAMILY
    elif rec.nameID == 6:
        rec.string = "SimHei-Regular"

opts = Options()
opts.name_IDs = ['*']
opts.name_legacy = True
opts.glyph_names = False
opts.recalc_bounds = True
ss = Subsetter(options=opts)
ss.populate(text=keep_text)
ss.subset(f)
f.save(OUT)
print("wrote:", OUT, " size: %.1f KB" % (os.path.getsize(OUT) / 1024))

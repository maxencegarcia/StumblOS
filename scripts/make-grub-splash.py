#!/usr/bin/env python3
"""Génère le fond du menu GRUB (800x600) à partir de l'image source.

Usage : make-grub-splash.py <image_source> <sortie.png>

- recadre l'image en 4:3 (côté gauche conservé : visage, lune, cristal)
- redimensionne en 800x600 (taille imposée par live-build et gfxmode)
- dessine un panneau sombre translucide + un cadre derrière la zone du menu
  (zone définie par live-theme/theme.txt : left 10 %, width 80 %, top 52 %)
"""
import sys
from PIL import Image, ImageDraw

W, H = 800, 600
PANEL = (72, 300, 728, 404)      # x0, y0, x1, y1 : englobe le menu (x 80-720, y >= 312)
PANEL_RGBA = (15, 16, 36, 184)   # #0f1024, opacité ~72 %
FRAME_RGB = (122, 106, 216)      # #7a6ad8 (accent DistroNight)

def main(src, dst):
    im = Image.open(src).convert("RGB")
    w, h = im.size
    cw = round(h * 4 / 3)
    if cw > w:                   # image plus étroite que 4:3 : on recadre en hauteur
        ch = round(w * 3 / 4)
        im = im.crop((0, (h - ch) // 2, w, (h - ch) // 2 + ch))
    else:
        im = im.crop((0, 0, cw, h))
    im = im.resize((W, H), Image.LANCZOS).convert("RGBA")

    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    d.rectangle(PANEL, fill=PANEL_RGBA)
    d.rectangle(PANEL, outline=FRAME_RGB + (255,), width=2)
    out = Image.alpha_composite(im, overlay).convert("RGB")
    out.save(dst, format="PNG", optimize=True)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])

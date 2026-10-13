#!/usr/bin/env python3
"""Auto normal maps for already-painted sprites (C35): Dave's Rook frames.

For art that was not painted as parts with height (here: Dave's Rook
placeholder frames), build a height field from the sprite's own silhouette
(rounded edges plus a gentle overall bulge) and a little of its painted
detail, then write a normal map in Godot's 2D convention (R = +x, G = +y up,
B = z) for every frame:
  assets/characters/rook/normals/<frame>_n.png
plus dave_spec.png, a flat low-gloss spec for his cloth and skin. Hand-fix
the result for final art; this is only good enough to light the placeholder
hero like the enemies. Run from the project root:
  python3 tools/art/make_normal_maps.py
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lit_rig_common import PROJECT, edt_inside, gblur, normal_to_rgb  # noqa: E402

SRC = os.path.join(PROJECT, "assets", "characters", "rook")
OUT = os.path.join(SRC, "normals")

EDGE_PX = 9.0        # rounded-edge radius in texture pixels (2x art)
DETAIL = 0.9         # how much painted detail (luma) shapes the surface


def normal_map(rgba):
    a = rgba[..., 3] / 255.0
    mask = a > 0.5
    d = edt_inside(mask)
    t = np.clip(d / EDGE_PX, 0, 1)
    h = EDGE_PX * np.sqrt(1.0 - (1.0 - t) ** 2)
    dmax = max(float(d.max()), 1.0)
    h += 0.35 * EDGE_PX * np.sqrt(np.clip(d / dmax, 0, 1))
    luma = (rgba[..., 0] * 0.3 + rgba[..., 1] * 0.59 + rgba[..., 2] * 0.11) / 255.0
    detail = luma - gblur(luma, 3.0)
    h += DETAIL * EDGE_PX * 0.25 * detail * mask
    h = gblur(h * mask, 0.8)
    gy, gx = np.gradient(h)
    n = np.stack([-gx, -gy, np.ones_like(h)], -1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    rgb = normal_to_rgb(n)
    rgb[~mask] = [0.5, 0.5, 1.0]
    return np.concatenate([rgb, a[..., None]], axis=-1)


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in sorted(os.listdir(SRC)):
        if not f.endswith(".png"):
            continue
        rgba = np.asarray(Image.open(os.path.join(SRC, f)).convert("RGBA"), np.float32)
        out = normal_map(rgba)
        Image.fromarray((np.clip(out, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(OUT, f.replace(".png", "_n.png")))
        print("normals", f)
    # a flat, low-gloss spec for Dave's cloth-and-skin frames
    spec = np.zeros((4, 4, 4), np.float32)
    spec[...] = [0.12, 0.3, 0.0, 1.0]
    Image.fromarray((spec * 255).astype(np.uint8)).save(os.path.join(OUT, "dave_spec.png"))
    print("normals ->", OUT)


if __name__ == "__main__":
    main()

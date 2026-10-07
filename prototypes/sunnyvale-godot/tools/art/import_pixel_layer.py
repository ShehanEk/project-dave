#!/usr/bin/env python3
"""Import a generated pixel-art background layer (C39) onto a true pixel grid.

Image generators draw "pixel art" as blocks of roughly N x N screen pixels
that drift off a clean grid. This tool reduces each layer to one texel per
art pixel (the most common colour in each block), limits the palette, makes
the strip repeat seamlessly (the last columns blend into the first), and
writes a PNG the game draws with nearest filtering at ART_PX world px per
texel (area_backdrop.gd). Layers with a transparent background (the campus)
keep a hard 1-bit alpha. Run from the project root:
  python3 tools/art/import_pixel_layer.py far
  python3 tools/art/import_pixel_layer.py campus
  python3 tools/art/import_pixel_layer.py depot
"""
import os
import sys
import warnings

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.normpath(os.path.join(HERE, "..", ".."))
REPO = os.path.normpath(os.path.join(PROJECT, "..", ".."))
OUT_DIR = os.path.join(PROJECT, "assets", "environment", "sunnyvale")

# One entry per layer: the source image, its block size and grid offset
# (measured from the image's edge pattern; a block may be fractional), how
# many colours to keep, how many art-pixel columns to blend across the seam
# (0 when the painting already repeats) and the rows to keep (top, bottom).
# Both layers come out at about two art pixels per generated "pixel", so
# their pixels match in size on screen.
LAYERS = {
    "far": {"sheet": "concept-art/env-sunnyvale/sunnyvale-far-v1.webp", "block": 2, "offset": (0, 0),
            "colors": 128, "seam": 48},
    "campus": {"sheet": "concept-art/env-sunnyvale/sunnyvale-campus-v1.webp", "block": 2.75, "offset": (0, 0),
               "colors": 96, "seam": 0, "rows": (100, 705)},
    # The depot wall (opaque): generated pixels of about 6.5 px, so block 3.25
    # is two art pixels each like the campus. It already repeats (the first
    # and last columns differ by under 1 level), so no seam blend.
    "depot": {"sheet": "concept-art/env-sunnyvale/sunnyvale-depot-v1.webp", "block": 3.25, "offset": (0, 0),
              "colors": 64, "seam": 0},
}


def reduce_blocks(rgba, block, offset):
    """One colour per block (see below) and a hard alpha: a block is opaque
    when most of it is. A fractional block is handled by first enlarging the
    image (nearest) until the block is a whole number of pixels."""
    k = next(k for k in range(1, 9) if abs(block * k - round(block * k)) < 1e-6)
    if k > 1:
        rgba = rgba.repeat(k, axis=0).repeat(k, axis=1)
    b = int(round(block * k))
    ox, oy = offset[0] * k, offset[1] * k
    h = (rgba.shape[0] - oy) // b
    w = (rgba.shape[1] - ox) // b
    cut = rgba[oy:oy + h * b, ox:ox + w * b].reshape(h, b, w, b, 4).transpose(0, 2, 1, 3, 4)
    flat = cut.reshape(h, w, b * b, 4).astype(np.float32)
    alpha = np.median(flat[..., 3], axis=2) >= 128.0
    rgb = flat[..., :3]
    seen = flat[..., 3] >= 128.0
    if not seen.all():
        # Transparent pixels (black) must not darken a building's edge.
        rgb = np.where(seen[..., None], rgb, np.nan)
    # The median is the block's colour and ignores the soft edges the
    # generator leaves between blocks; but a light smaller than a block (a
    # lit window, a neon line) would vanish under it, so a block holding
    # clearly brighter pixels takes their average instead.
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", RuntimeWarning)   # fully transparent blocks
        med = np.nan_to_num(np.nanmedian(rgb, axis=2)) if not seen.all() else np.median(rgb, axis=2)
    lum = np.nan_to_num(rgb, nan=-1e4) @ np.array([0.3, 0.59, 0.11], np.float32)
    mlum = med @ np.array([0.3, 0.59, 0.11], np.float32)
    bright = lum > (mlum[..., None] + 40.0)
    n = bright.sum(-1)
    lit = (np.nan_to_num(rgb) * bright[..., None]).sum(2) / np.maximum(n, 1)[..., None]
    out = np.where((n >= 2)[..., None], lit, med)
    a = np.where(alpha, 255, 0)[..., None]
    return np.concatenate([out.round(), a], axis=-1).astype(np.uint8)


def make_seamless(img, cols):
    """Blends the last `cols` columns into the first ones, then drops them."""
    if cols <= 0:
        return img
    a = img.astype(np.float32)
    w = a.shape[1] - cols
    out = a[:, :w].copy()
    for i in range(cols):
        t = (i + 0.5) / cols
        out[:, i] = a[:, w + i] * (1.0 - t) + a[:, i] * t
    return out.round().astype(np.uint8)


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in LAYERS:
        raise SystemExit("usage: import_pixel_layer.py %s" % "|".join(LAYERS))
    name = sys.argv[1]
    cfg = LAYERS[name]
    src = np.asarray(Image.open(os.path.join(REPO, cfg["sheet"])).convert("RGBA"))
    if "rows" in cfg:
        src = src[cfg["rows"][0]:cfg["rows"][1]]
    art = reduce_blocks(src, cfg["block"], cfg["offset"])
    art = make_seamless(art, cfg["seam"])
    small = Image.fromarray(art[..., :3]).quantize(colors=cfg["colors"], method=Image.Quantize.FASTOCTREE,
                                                   dither=Image.Dither.NONE).convert("RGB")
    opaque = art[..., 3].min() == 255
    if not opaque:
        small.putalpha(Image.fromarray(art[..., 3]))
    os.makedirs(OUT_DIR, exist_ok=True)
    out = os.path.join(OUT_DIR, name + ".png")
    small.save(out)
    top = small.getpixel((0, 0))[:3]
    print("wrote %s (%d x %d art px), top-left %s" % (out, small.width, small.height, "#%02X%02X%02X" % top))


if __name__ == "__main__":
    main()

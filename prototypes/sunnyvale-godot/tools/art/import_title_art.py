#!/usr/bin/env python3
"""Import the title screen art (concept-art/ui-sunnyvale) into the game.

The logo (title-logo-v1.webp) is drawn on a clean grid of 8 x 8 image pixel
blocks (a 4 px grid fits it too, so the importer takes the largest grid that
leaves every block one flat colour). It reduces the logo to one texel per
block, trims the transparent border (150 x 33 texels) and writes the
native-size PNG the game draws with nearest filtering at a whole-number
scale (title_screen.gd).

The backdrop (title-backdrop-v1.webp, a 1672 x 941 night campus plaza) is an
illustration with fine pixels. It is resampled to exactly 1280 x 720 (the
project's canvas size) with a Lanczos filter and the palette is left alone;
the game draws it covering the window with linear filtering.

Run from the project root:
  python3 tools/art/import_title_art.py
then re-import:
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
"""
import os

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.normpath(os.path.join(HERE, "..", ".."))
REPO = os.path.normpath(os.path.join(PROJECT, "..", ".."))
SRC_DIR = os.path.join(REPO, "concept-art", "ui-sunnyvale")
OUT_DIR = os.path.join(PROJECT, "assets", "ui", "pixel")

LOGO_SRC = os.path.join(SRC_DIR, "title-logo-v1.webp")
BACKDROP_SRC = os.path.join(SRC_DIR, "title-backdrop-v1.webp")
LOGO_OUT = os.path.join(OUT_DIR, "title_logo.png")
BACKDROP_OUT = os.path.join(OUT_DIR, "title_backdrop.png")

BACKDROP_SIZE = (1280, 720)


def block_fit(rgba, block, offset):
    """Fraction of whole blocks that are one flat colour, for a grid of
    `block` px starting at `offset` (x, y)."""
    ox, oy = offset
    sub = rgba[oy:, ox:]
    h = sub.shape[0] // block * block
    w = sub.shape[1] // block * block
    cells = sub[:h, :w].reshape(h // block, block, w // block, block, 4)
    flat = (cells == cells[:, :1, :, :1]).all(axis=(1, 3, 4))
    return float(flat.mean())


def detect_grid(rgba, max_block=16):
    """The largest block size (and its offset) that fits the whole image
    exactly, so a drawing made of 4 px blocks is not mistaken for 2 or 1."""
    for block in range(max_block, 1, -1):
        for oy in range(block):
            for ox in range(block):
                if block_fit(rgba, block, (ox, oy)) >= 0.9999:
                    return block, (ox, oy)
    raise SystemExit("no clean pixel grid found in the logo")


def import_logo():
    rgba = np.array(Image.open(LOGO_SRC).convert("RGBA"))
    block, (ox, oy) = detect_grid(rgba)
    h = (rgba.shape[0] - oy) // block
    w = (rgba.shape[1] - ox) // block
    texels = rgba[oy:oy + h * block:block, ox:ox + w * block:block].copy()
    texels[texels[..., 3] == 0] = 0  # transparent texels carry no stray colour
    ys, xs = np.nonzero(texels[..., 3])
    texels = texels[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    Image.fromarray(texels).save(LOGO_OUT, optimize=True)
    print("logo: %dpx blocks at offset %s -> %dx%d texels (%d colours) -> %s"
          % (block, (ox, oy), texels.shape[1], texels.shape[0],
             len(np.unique(texels.reshape(-1, 4), axis=0)), os.path.relpath(LOGO_OUT, PROJECT)))


def import_backdrop():
    img = Image.open(BACKDROP_SRC).convert("RGB")
    out = img.resize(BACKDROP_SIZE, Image.LANCZOS)
    out.save(BACKDROP_OUT, optimize=True)
    print("backdrop: %dx%d -> %dx%d (Lanczos) -> %s"
          % (img.width, img.height, out.width, out.height, os.path.relpath(BACKDROP_OUT, PROJECT)))


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    import_logo()
    import_backdrop()

#!/usr/bin/env python3
"""Import the pixel-art bitmap font sheet (Sheet 10, sign lettering).

The sheet (concept-art/env-sunnyvale/sunnyvale-font-v1.webp) is a native bitmap
font: 117 x 52 px, pure white glyphs on a transparent background in a strict
grid of 9 x 13 px cells, 13 columns by 4 rows:

  row 1  A B C D E F G H I J K L M
  row 2  N O P Q R S T U V W X Y Z
  row 3  0 1 2 3 4 5 6 7 8 9 (two empty cells)
  row 4  . , ! ? - ' : / + & ( ) (one empty cell)

Each glyph is about 5 x 7 pixels inside its cell. This tool crops every glyph
to its own pixels, packs them in one row (one transparent pixel between them)
and writes

  assets/environment/sunnyvale/font/font.png    the atlas, white on transparent
  assets/environment/sunnyvale/font/font.json   the glyph table

so scripts/world/pixel_font.gd can draw a string by blitting rects. The glyphs
stay pure white: the game tints them. Nothing is scaled: one atlas pixel is one
font pixel, which the game draws as a whole number of art pixels (1.5 world px
each).

The JSON holds, in font pixels:
  cap_height  height of a capital letter (7)
  descent     how far Q and the comma hang below the baseline (2)
  gap         blank pixels between two glyphs (1)
  space       advance of a space (3)
  glyphs      per character: x, y, w, h = its rect in the atlas; adv = how far
              the pen moves (w + gap); oy = the glyph's top, in rows below the
              top of the capitals (0 for a capital, 6 for the full stop, 6 for
              the comma, which hangs below the baseline)

Run from the project root (prototypes/sunnyvale-godot), then re-import:
  python3 tools/art/import_pixel_font.py
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
"""
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_pixel_layer import REPO, OUT_DIR  # noqa: E402

SHEET = os.path.join(REPO, "concept-art", "env-sunnyvale", "sunnyvale-font-v1.webp")
OUT = os.path.join(OUT_DIR, "font")
CELL_W, CELL_H = 9, 13
ROWS = [
    "ABCDEFGHIJKLM",
    "NOPQRSTUVWXYZ",
    "0123456789",
    ".,!?-':/+&()",
]
GAP = 1
SPACE = 3


def main() -> None:
    sheet = Image.open(SHEET).convert("RGBA")
    px = np.array(sheet)
    cols = max(len(r) for r in ROWS)
    if sheet.width % CELL_W or sheet.height % CELL_H or sheet.width // CELL_W != cols or sheet.height // CELL_H != len(ROWS):
        sys.exit("unexpected sheet size %s for a %d x %d grid of %d x %d cells" % (sheet.size, cols, len(ROWS), CELL_W, CELL_H))
    # The sheet is pure white and fully opaque or fully clear: any other pixel
    # means the file is not the font the importer was written for.
    a = px[..., 3]
    if not np.all((a == 0) | (a == 255)):
        sys.exit("the sheet has partly transparent pixels")
    solid = a == 255
    if not np.all(px[..., :3][solid] == 255):
        sys.exit("the sheet's glyphs are not pure white")

    glyphs = {}
    for r, row in enumerate(ROWS):
        for c, ch in enumerate(row):
            cell = solid[r * CELL_H:(r + 1) * CELL_H, c * CELL_W:(c + 1) * CELL_W]
            ys, xs = np.nonzero(cell)
            if len(xs) == 0:
                sys.exit("glyph %r is empty" % ch)
            x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
            glyphs[ch] = (int(r * CELL_H + y0), int(c * CELL_W + x0), int(y1 - y0), int(x1 - x0))  # sheet y, x, h, w

    # The capitals and digits share one top row and one baseline inside their
    # cells; measure them off the A. in_cell maps a glyph to (top row in its
    # cell, height).
    cap_h = glyphs["A"][2]
    in_cell = {ch: ((g[0] % CELL_H), g[2]) for ch, g in glyphs.items()}
    cap_line = in_cell["A"][0]
    for ch in "ABCDEFGHIJKLMNOPRSTUVWXYZ0123456789":
        if in_cell[ch] != (cap_line, cap_h):
            sys.exit("capital %r does not sit on the cap line (%s)" % (ch, in_cell[ch]))
    baseline = cap_line + cap_h
    descent = max(in_cell[ch][0] + in_cell[ch][1] for ch in glyphs) - baseline

    # One row, one transparent pixel between glyphs.
    order = [ch for row in ROWS for ch in row]
    atlas_h = max(g[2] for g in glyphs.values())
    atlas_w = sum(glyphs[ch][3] + 1 for ch in order) - 1
    atlas = np.zeros((atlas_h, atlas_w, 4), dtype=np.uint8)
    table = {}
    x = 0
    for ch in order:
        sy, sx, h, w = glyphs[ch]
        atlas[0:h, x:x + w] = px[sy:sy + h, sx:sx + w]
        table[ch] = {"x": x, "y": 0, "w": w, "h": h, "adv": w + GAP, "oy": in_cell[ch][0] - cap_line}
        x += w + 1

    os.makedirs(OUT, exist_ok=True)
    Image.fromarray(atlas).save(os.path.join(OUT, "font.png"), optimize=True)
    data = {
        "source": os.path.relpath(SHEET, REPO),
        "cap_height": cap_h,
        "descent": descent,
        "gap": GAP,
        "space": SPACE,
        "glyphs": table,
    }
    with open(os.path.join(OUT, "font.json"), "w") as f:
        json.dump(data, f, indent=1, sort_keys=False)
        f.write("\n")
    print("font: %d glyphs, atlas %d x %d, cap height %d, descent %d -> %s" % (len(table), atlas_w, atlas_h, cap_h, descent, OUT))


if __name__ == "__main__":
    main()

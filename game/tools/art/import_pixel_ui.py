#!/usr/bin/env python3
"""Import the two pixel-art UI sheets (Sheets 11 and 12) as separate pieces.

  Sheet 11  concept-art/ui-sunnyvale/ui-frames-v2.webp  frames: panels, buttons,
            health segments, weapon slot, lights, slider, checkbox, focus, divider
  Sheet 12  concept-art/ui-sunnyvale/ui-icons-v1.webp   icons: chip, keycard,
            folder, swap, save, tick, warning, locks, gear, speaker, subtitle,
            prompt tag, key caps, arrows, mice

Both sheets are drawn on a transparent background with exact 4 x 4 image-pixel
blocks on a grid that starts at the image's corner (checked here: every block
is one colour, or the tool stops). So no grid is detected: the sheet is reduced
4:1 by taking one pixel per block, and the pieces are the opaque islands of the
reduced image, read row by row (rows are split at fully clear rows) and left to
right, then named from the layout below. A piece made of loose parts (the swap
arrows, the four focus brackets) joins that many islands; the muddy pistol icon
on Sheet 12 is skipped (the HUD's weapon icon is built from the pixel Scrapjack
instead, below).

Writes, under assets/ui/pixel/ (shared with the title screen's own
title_logo.png and title_backdrop.png, which this tool never touches):

  <name>.png      every piece at native size (1 texel = 1 UI pixel), drawn by
                  the game with nearest filtering at 3 canvas px per UI pixel
  x3/<name>.png   the theme's nine-slice frames (panels, buttons, slider,
                  checkbox, focus brackets, divider, prompt tag, the down arrow)
                  scaled up 3x by repeating pixels: a StyleBoxTexture draws its
                  corners 1 texel : 1 canvas px, so the theme needs them at UI
                  scale already
  weapon_scrapjack.png  the HUD weapon icon: the pixel Scrapjack rig
                  (assets/characters/lit/scrapjack: albedo.png + rig.json) put
                  together in its rest pose and reduced to 1 texel per art pixel
                  (the atlas is 3x: 1 art pixel = 3 atlas px)
  mouse_aim.png   "aim with the mouse": the mouse with neither button lit
                  between the pale left and right arrow glyphs
  prompt_box.png, prompt_tail.png
                  the interact prompt tag split in two: the box (its bottom
                  outline closed) nine-slices to any text, the pointer is drawn
                  centred under it

Run from the project root (prototypes/sunnyvale-godot), then re-import:
  python3 tools/art/import_pixel_ui.py
  /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
"""
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_pixel_layer import PROJECT, REPO  # noqa: E402

OUT = os.path.join(PROJECT, "assets", "ui", "pixel")
OUT_X3 = os.path.join(OUT, "x3")
BLOCK = 4
UI_SCALE = 3

# Pieces in reading order, one list per row of the sheet. A tuple joins that
# many islands into one piece; a None name skips the islands.
SHEETS = {
    "frames": {
        "sheet": "concept-art/ui-sunnyvale/ui-frames-v2.webp",
        "rows": [
            ["panel", "tag", "banner"],
            ["button_normal", "button_hover", "button_pressed", "button_disabled"],
            ["health_full", "health_empty", "health_flash", "weapon_slot",
             "ready_lit", "ready_dark", "pip_lit", "pip_dark"],
            ["slider_track", "slider_fill", "slider_knob", "check_off", "check_on",
             ("focus", 4), "divider"],
        ],
    },
    "icons": {
        "sheet": "concept-art/ui-sunnyvale/ui-icons-v1.webp",
        "rows": [
            ["chip", "keycard", "evidence", (None, 1), ("swap", 2), "save", "tick", "warning"],
            ["lock_closed", "lock_open", "gear", ("speaker", 3), "subtitle", "prompt_tag"],
            ["key_cap", "key_cap_pressed", "key_wide", "arrow_up", "arrow_down",
             "arrow_left", "arrow_right", "mouse_left", "mouse_right"],
        ],
    },
}

# The theme's nine-slice frames (and the two theme icons), also written at UI
# scale under x3/.
X3 = ["panel", "tag", "banner", "button_normal", "button_hover", "button_pressed",
      "button_disabled", "slider_track", "slider_fill", "slider_knob", "check_off",
      "check_on", "focus", "divider", "prompt_tag", "arrow_down"]

SCRAPJACK = os.path.join(PROJECT, "assets", "characters", "lit", "scrapjack")
ATLAS_PER_ART = 3

TEAL = (0x3F, 0xE0, 0xD0)
SLATE = (0x2E, 0x3B, 0x4E)


def reduce_exact(src):
    """The sheet at one texel per 4 x 4 block; stops if any block is not one
    colour (the sheet would then need a detected grid instead)."""
    h, w = src.shape[0] // BLOCK * BLOCK, src.shape[1] // BLOCK * BLOCK
    b = src[:h, :w].astype(np.int16).reshape(h // BLOCK, BLOCK, w // BLOCK, BLOCK, 4)
    spread = (b.max(axis=(1, 3)) - b.min(axis=(1, 3))).max(axis=-1)
    if (spread > 8).any():
        raise SystemExit("%d blocks are not one colour: not an exact 4 px grid" % int((spread > 8).sum()))
    out = src[:h:BLOCK, :w:BLOCK].copy()
    out[..., 3] = np.where(out[..., 3] >= 128, 255, 0)
    out[out[..., 3] == 0] = 0
    return out


def islands(mask):
    """Bounding boxes (x0, y0, x1, y1) of the 8-connected opaque islands."""
    h, w = mask.shape
    seen = np.zeros_like(mask)
    boxes = []
    for sy, sx in zip(*np.nonzero(mask)):
        if seen[sy, sx]:
            continue
        q = deque([(sy, sx)])
        seen[sy, sx] = True
        x0 = x1 = sx
        y0 = y1 = sy
        while q:
            cy, cx = q.popleft()
            x0, x1, y0, y1 = min(x0, cx), max(x1, cx), min(y0, cy), max(y1, cy)
            for ny in range(max(cy - 1, 0), min(cy + 2, h)):
                for nx in range(max(cx - 1, 0), min(cx + 2, w)):
                    if mask[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        q.append((ny, nx))
        boxes.append((int(x0), int(y0), int(x1) + 1, int(y1) + 1))
    return boxes


def row_bands(mask):
    """(y0, y1) of each band of rows that has opaque pixels."""
    used = mask.any(axis=1)
    bands, start = [], None
    for y, u in enumerate(used):
        if u and start is None:
            start = y
        if not u and start is not None:
            bands.append((start, y))
            start = None
    if start is not None:
        bands.append((start, len(used)))
    return bands


def cut_sheet(cfg):
    img = reduce_exact(np.asarray(Image.open(os.path.join(REPO, cfg["sheet"])).convert("RGBA")))
    mask = img[..., 3] > 0
    bands = row_bands(mask)
    if len(bands) != len(cfg["rows"]):
        raise SystemExit("%s: %d rows of pieces, expected %d" % (cfg["sheet"], len(bands), len(cfg["rows"])))
    boxes = islands(mask)
    pieces = {}
    for (y0, y1), names in zip(bands, cfg["rows"]):
        row = sorted([b for b in boxes if y0 <= b[1] < y1], key=lambda b: (b[0], b[1]))
        need = sum(n[1] if isinstance(n, tuple) else 1 for n in names)
        if len(row) != need:
            raise SystemExit("%s: row at y %d has %d islands, expected %d" % (cfg["sheet"], y0, len(row), need))
        i = 0
        for n in names:
            name, k = n if isinstance(n, tuple) else (n, 1)
            part = row[i:i + k]
            i += k
            if name is None:
                continue
            bx0, by0 = min(b[0] for b in part), min(b[1] for b in part)
            bx1, by1 = max(b[2] for b in part), max(b[3] for b in part)
            pieces[name] = img[by0:by1, bx0:bx1].copy()
    return pieces


def build_scrapjack():
    """The Scrapjack in its rest pose (every joint at rest_dir 0), one texel per
    art pixel. Parts are placed as cutout_rig.gd places them: a part's sprite
    sits at its joint with offset -pivot (atlas px) and scale 1/texture_scale,
    so in atlas px its top-left is joint_world * texture_scale - pivot."""
    rig = json.load(open(os.path.join(SCRAPJACK, "rig.json")))
    atlas = np.asarray(Image.open(os.path.join(SCRAPJACK, rig["albedo"])).convert("RGBA"))
    ts = float(rig["texture_scale"])
    world = {}
    placed = []
    for j in rig["joints"]:
        parent = world.get(j["parent"], (0.0, 0.0))
        pos = (parent[0] + j["pos"][0], parent[1] + j["pos"][1])
        world[j["name"]] = pos
        part = rig["parts"][j["part"]]
        x, y, w, h = part["rect"]
        tl = (round(pos[0] * ts - part["pivot"][0]), round(pos[1] * ts - part["pivot"][1]))
        placed.append((j["z"], tl, atlas[y:y + h, x:x + w]))
    x0 = min(p[1][0] for p in placed)
    y0 = min(p[1][1] for p in placed)
    x1 = max(p[1][0] + p[2].shape[1] for p in placed)
    y1 = max(p[1][1] + p[2].shape[0] for p in placed)
    # keep the art-pixel grid: every part's top-left is a whole art pixel from (0, 0)
    x0 -= x0 % ATLAS_PER_ART
    y0 -= y0 % ATLAS_PER_ART
    canvas = np.zeros((y1 - y0 + ATLAS_PER_ART, x1 - x0 + ATLAS_PER_ART, 4), np.uint8)
    for _z, (tx, ty), px in sorted(placed, key=lambda p: p[0]):
        dst = canvas[ty - y0:ty - y0 + px.shape[0], tx - x0:tx - x0 + px.shape[1]]
        solid = px[..., 3] >= 128
        dst[solid] = px[solid]
    out = canvas[::ATLAS_PER_ART, ::ATLAS_PER_ART].copy()
    out[..., 3] = np.where(out[..., 3] >= 128, 255, 0)
    ys, xs = np.nonzero(out[..., 3])
    return out[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def build_mouse_aim(pieces):
    """The mouse with neither button lit, between the pale left/right arrows."""
    mouse = pieces["mouse_left"].copy()
    lit = (mouse[..., 0] == TEAL[0]) & (mouse[..., 1] == TEAL[1]) & (mouse[..., 2] == TEAL[2])
    mouse[lit, :3] = SLATE
    left, right = pieces["arrow_left"], pieces["arrow_right"]
    h = mouse.shape[0]
    w = left.shape[1] + 1 + mouse.shape[1] + 1 + right.shape[1]
    out = np.zeros((h, w, 4), np.uint8)
    ay = (h - left.shape[0]) // 2
    out[ay:ay + left.shape[0], :left.shape[1]] = left
    mx = left.shape[1] + 1
    out[:, mx:mx + mouse.shape[1]] = mouse
    rx = mx + mouse.shape[1] + 1
    out[ay:ay + right.shape[0], rx:rx + right.shape[1]] = right
    return out


def split_prompt_tag(tag):
    """The prompt tag as a box that nine-slices (its bottom outline closed where
    the pointer leaves it) and the pointer on its own (from the box's bottom
    row down), so a prompt of any width keeps a pointer of one size, centred."""
    solid = tag[..., 3] > 0
    full = [x for x in range(tag.shape[1]) if solid[:, x].any()]
    body_rows = [y for y in range(tag.shape[0]) if solid[y, full[0] + 1:full[-1]].all()]
    bottom = body_rows[-1]                # the box's bottom outline row
    below = np.nonzero(solid[bottom + 1:].any(axis=0))[0]
    t0, t1 = int(below.min()) - 1, int(below.max()) + 2
    box = tag[:bottom + 1].copy()
    outline = tag[0, tag.shape[1] // 2].copy()
    box[bottom, t0 + 1:t1 - 1] = outline
    tail = tag[bottom:, t0:t1].copy()
    return box, tail


def save(arr, path):
    Image.fromarray(np.ascontiguousarray(arr)).save(path)


def main():
    pieces = {}
    for cfg in SHEETS.values():
        for name, px in cut_sheet(cfg).items():
            if name in pieces:
                raise SystemExit("piece named twice: " + name)
            pieces[name] = px
    pieces["weapon_scrapjack"] = build_scrapjack()
    pieces["mouse_aim"] = build_mouse_aim(pieces)
    pieces["prompt_box"], pieces["prompt_tail"] = split_prompt_tag(pieces["prompt_tag"])
    os.makedirs(OUT_X3, exist_ok=True)
    for name in sorted(pieces):
        px = pieces[name]
        save(px, os.path.join(OUT, name + ".png"))
        line = "%-18s %3d x %3d UI px" % (name, px.shape[1], px.shape[0])
        if name in X3:
            save(px.repeat(UI_SCALE, axis=0).repeat(UI_SCALE, axis=1), os.path.join(OUT_X3, name + ".png"))
            line += "   (+ x3)"
        print(line)


if __name__ == "__main__":
    main()

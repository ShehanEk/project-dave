#!/usr/bin/env python3
"""Import the generated pixel-art effect frames (Sheet 9) as animation strips.

The sheet (concept-art/env-sunnyvale/sunnyvale-effects-v1.webp, 1254 x 1254,
RGB on plain black) is a strict 6 x 6 grid of equal cells. Each row is one
effect, read left to right, with the unused cells left black:

  1. muzzle_flash        4 frames, ivory and orange, pointing right
  2. bullet_impact       5 frames, ivory-white sparks
  3. landing_dust        5 frames, pale blue-grey, flat bottom
  4. machine_break       6 frames, orange sparks and dark smoke
  5. checkpoint_sparkle  6 frames, teal stars
  6. chip_glint          4 frames, gold four-point star

The generator draws its pixels about 6.5 px wide and lets each frame's grid
drift a little, and the black is not pure (WebP noise, and dark smoke and dim
dust only slightly brighter than it). For each frame this tool:

  1. keys the black out by colour: a pixel is clear when its brightest
     channel is at most KEY, and keeps its own colour otherwise (no
     luminance alpha, so a dark smoke puff stays dark and opaque instead of
     turning into a see-through grey);
  2. measures the generated pixel size by comb/FFT of the colour edges
     (printed per frame, pooled over the sheet), then reduces the frame to
     one art pixel per generated pixel with the grid detector of
     import_pixel_sheet.py (`grid_lines`, `reduce_grid`), so a frame keeps its
     own drifting grid;
  3. anchors every frame of an effect on one point (the muzzle's left edge, the
     floor under the dust, the centre of a burst) and pads them to a common
     frame size;
  4. limits every effect to one shared palette and writes
     assets/effects/pixel/<effect>.png (a horizontal strip, hard 1-bit alpha)
     plus assets/effects/pixel/effects.json (frame counts, sizes, anchors).

The game draws a strip with nearest filtering at ART world px per art pixel
(scripts/effects/pixel_fx.gd). Run from the project root:
  python3 tools/art/import_pixel_effects.py
  python3 tools/art/import_pixel_effects.py --measure   (only print the pixel size)
"""
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_pixel_layer import REPO, PROJECT  # noqa: E402
from import_pixel_sheet import grid_lines, reduce_grid  # noqa: E402

SHEET = "concept-art/env-sunnyvale/sunnyvale-effects-v1.webp"
OUT_DIR = os.path.join(PROJECT, "assets", "effects", "pixel")
GRID = 6
# A pixel is black (clear) when its brightest channel is at most this. The
# sheet's background is 0 or 1 with a rare 2 to 12 around bright edges, and the
# dimmest thing worth keeping is the dark smoke at about 45 / 54 / 70.
KEY = 14
COLORS = 48

# Row order is the effect order. `anchor` says what every frame of the effect is
# pinned on (see anchor_of): `centre` the bounding box's centre, `left` the
# bounding box's left edge at its centre height (the muzzle: the flash grows
# forward from it), `floor` the floor line under the bounding box's centre
# (dust).
EFFECTS = [
    {"name": "muzzle_flash", "anchor": "left"},
    {"name": "bullet_impact", "anchor": "centre"},
    {"name": "landing_dust", "anchor": "floor"},
    {"name": "machine_break", "anchor": "centre"},
    {"name": "checkpoint_sparkle", "anchor": "centre"},
    {"name": "chip_glint", "anchor": "centre"},
]


def edge_energy(crop):
    """Colour-edge energy per column and per row of an RGB crop."""
    rgb = crop.astype(np.float32)
    dx = np.abs(np.diff(rgb, axis=1)).sum(-1).sum(0)
    dy = np.abs(np.diff(rgb, axis=0)).sum(-1).sum(1)
    return dx, dy


def spectrum(energy, periods):
    """Magnitude of the energy signal at each candidate period (the FFT's
    fundamental of a comb of edges every `period` px)."""
    n = len(energy)
    e = energy - energy.mean()
    t = np.arange(n)
    out = []
    for p in periods:
        ph = np.exp(-2j * np.pi * t / p)
        out.append(abs((e * ph).sum()))
    return np.array(out)


def measure_pixel(frames):
    """The generated pixel size: the period whose comb the frames' colour edges
    follow best. Each frame (and each axis) is measured on its own, since
    their grids drift apart; the spectra are normalised and summed. Returns
    (pooled period, [(name, period) per frame])."""
    periods = np.arange(4.0, 9.0001, 0.02)
    pooled = np.zeros(len(periods))
    per_frame = []
    for name, crop in frames:
        dx, dy = edge_energy(crop)
        s = np.zeros(len(periods))
        for e in (dx, dy):
            sp = spectrum(e, periods)
            sp = sp / (sp.max() + 1e-6)
            s += sp
        per_frame.append((name, float(periods[int(np.argmax(s))])))
        pooled += s
    return float(periods[int(np.argmax(pooled))]), per_frame


def cells(rgb):
    """(row, col) -> the cell's RGB, for every cell that is not black."""
    h, w = rgb.shape[:2]
    out = {}
    for r in range(GRID):
        for c in range(GRID):
            cell = rgb[r * h // GRID:(r + 1) * h // GRID, c * w // GRID:(c + 1) * w // GRID]
            if (cell.max(-1) > KEY).sum() >= 12:
                out[(r, c)] = cell
    return out


def keyed(cell):
    """The cell as RGBA: black keyed out by colour, every other pixel kept."""
    rgba = np.zeros(cell.shape[:2] + (4,), np.uint8)
    rgba[..., :3] = cell
    rgba[..., 3] = np.where(cell.max(-1) > KEY, 255, 0)
    rgba[rgba[..., 3] == 0, :3] = 0
    return rgba


def reduce_frame(cell, pixel):
    """One art pixel per generated pixel, trimmed to the opaque bounds."""
    rgba = keyed(cell)
    rgb = rgba[..., :3].astype(np.float32)
    solid = (rgba[..., 3] > 128).astype(np.float32)
    dx = (np.abs(np.diff(rgb, axis=1)).sum(-1) + 255.0 * np.abs(np.diff(solid, axis=1))).sum(0)
    dy = (np.abs(np.diff(rgb, axis=0)).sum(-1) + 255.0 * np.abs(np.diff(solid, axis=0))).sum(1)
    art = reduce_grid(rgba, grid_lines(dx, pixel), grid_lines(dy, pixel))
    ys, xs = np.nonzero(art[..., 3])
    return art[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def main_bottom(frame):
    """The floor line of a dust frame: the bottom of its main mass (a row
    counts when it holds at least a third of the widest row's pixels), so a few
    crumbs that fall below it do not move the line."""
    count = (frame[..., 3] > 0).sum(1)
    return int(np.nonzero(count * 3 >= count.max())[0].max()) + 1


def anchor_of(kind, frame):
    """The point of the frame (x, y in art px from its top left) that every
    frame of the effect is pinned on."""
    h, w = frame.shape[:2]
    if kind == "left":
        return 0, h // 2
    if kind == "floor":
        return w // 2, main_bottom(frame)
    return w // 2, h // 2


def build_strip(frames, kind):
    """Pads the frames to one size around their common anchor. Returns the
    strip (h, n * w, 4), the frame size and the anchor in the frame."""
    anchors = [anchor_of(kind, f) for f in frames]
    left = max(a[0] for a in anchors)
    up = max(a[1] for a in anchors)
    right = max(f.shape[1] - a[0] for f, a in zip(frames, anchors))
    down = max(f.shape[0] - a[1] for f, a in zip(frames, anchors))
    fw, fh = left + right, up + down
    strip = np.zeros((fh, fw * len(frames), 4), np.uint8)
    for i, (f, a) in enumerate(zip(frames, anchors)):
        ox, oy = i * fw + left - a[0], up - a[1]
        strip[oy:oy + f.shape[0], ox:ox + f.shape[1]] = f
    return strip, (fw, fh), (left, up)


def main():
    measure_only = "--measure" in sys.argv
    src = np.asarray(Image.open(os.path.join(REPO, SHEET)).convert("RGB"))
    grid = cells(src)
    frames_in = []
    for r, fx in enumerate(EFFECTS):
        cols = [c for c in range(GRID) if (r, c) in grid]
        assert cols == list(range(len(cols))), "%s: frames must be contiguous from the left" % fx["name"]
        fx["cols"] = cols
        for c in cols:
            frames_in.append(("%s %d" % (fx["name"], c + 1), grid[(r, c)]))
    pooled, per_frame = measure_pixel(frames_in)
    print("generated pixel size, pooled over %d frames: %.2f px" % (len(frames_in), pooled))
    print("per frame: " + ", ".join("%s %.2f" % (n.split()[0][:4] + n.split()[1], p) for n, p in per_frame))
    if measure_only:
        return
    pixel = round(pooled, 1)
    reduced = {}
    for r, fx in enumerate(EFFECTS):
        reduced[fx["name"]] = [reduce_frame(grid[(r, c)], pixel) for c in fx["cols"]]
    strips = {}
    for fx in EFFECTS:
        strips[fx["name"]] = build_strip(reduced[fx["name"]], fx["anchor"])
    # One shared palette over every effect's opaque pixels.
    pixels = np.concatenate([s[0][s[0][..., 3] > 0][:, :3] for s in strips.values()])
    pal = Image.fromarray(pixels.reshape(-1, 1, 3)).quantize(
        colors=COLORS, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE)
    os.makedirs(OUT_DIR, exist_ok=True)
    meta = {}
    for fx in EFFECTS:
        strip, size, anchor = strips[fx["name"]]
        rgb = Image.fromarray(np.ascontiguousarray(strip[..., :3])).quantize(palette=pal, dither=Image.Dither.NONE)
        img = rgb.convert("RGB")
        img.putalpha(Image.fromarray(np.ascontiguousarray(strip[..., 3])))
        # clear pixels keep no colour, so a filter or a blend never fringes them
        arr = np.asarray(img).copy()
        arr[arr[..., 3] == 0, :3] = 0
        Image.fromarray(arr).save(os.path.join(OUT_DIR, fx["name"] + ".png"))
        n = len(fx["cols"])
        meta[fx["name"]] = {"frames": n, "frame_size": list(size), "anchor": list(anchor), "anchor_kind": fx["anchor"]}
        print("%-18s %d frames of %2d x %2d art px, anchor %s (%s)" % (fx["name"], n, size[0], size[1], anchor, fx["anchor"]))
    meta["_source"] = {"sheet": SHEET, "pixel_px": pixel, "colors": COLORS, "key": KEY}
    with open(os.path.join(OUT_DIR, "effects.json"), "w") as f:
        json.dump(meta, f, indent=1, sort_keys=True)
        f.write("\n")


if __name__ == "__main__":
    main()

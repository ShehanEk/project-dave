#!/usr/bin/env python3
"""Import a generated pixel-art asset sheet (C39) as separate pieces.

The sheet holds separate objects on a transparent background, laid out in
the prompt's reading order (art-design/environment/sunnyvale-play-plane.md).
This tool finds each object by its transparent gaps, names it by its place
in the layout grid, reduces it to the same pixel grid as the background
layers (import_pixel_layer.py: about two art pixels per generated pixel,
drawn at 1.5 world px per art pixel), aligning each piece to its own grid
because generated grids drift across a sheet, limits the whole sheet to one
shared palette, and writes assets/environment/sunnyvale/<sheet>/<piece>.png.

A sheet with a `pixel` size instead of a `block` is one whose generated
pixels came out half the requested size (the objects are the right size but
drawn with twice the pixels), and whose pixels alternate between two widths
(4 and 5 image px). Each piece then finds its own grid lines on the strongest
colour edges and keeps one art pixel per generated pixel, so the object
keeps its size and its pixels stay even (C42). A sheet drawn at the background's
pixel size (the buildings sheet, about 5.7 px) sets `upscale` 2, so each
generated pixel becomes 2 x 2 art pixels and draws as big as the campus's.
Run from the project root:
  python3 tools/art/import_pixel_sheet.py terrain
  python3 tools/art/import_pixel_sheet.py props
  python3 tools/art/import_pixel_sheet.py buildings
  python3 tools/art/import_pixel_sheet.py objects2
  python3 tools/art/import_pixel_sheet.py paving
  python3 tools/art/import_pixel_sheet.py details
  python3 tools/art/import_pixel_sheet.py foreground
"""
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_pixel_layer import REPO, OUT_DIR, reduce_blocks, make_seamless  # noqa: E402

# One entry per sheet: the source, its block (generated pixel size / 2) or
# its `pixel` (the generated pixel size, for a detected grid at one art pixel
# per generated pixel), the colours to keep, and the pieces' names by layout
# cell (rows x cols, in reading order). A piece lands in the cell its centre
# falls in. A cell may name several pieces (a list), taken top to bottom.
SHEETS = {
    "terrain": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-terrain-v1.webp", "block": 2, "colors": 96,
        "grid": (3, 3),
        "names": ["walkway", "retaining_wall", "planter_ledge",
                  "green_roof", "support_column", "stone_planter",
                  "ac_unit", "pillar", "porch_steps"],
    },
    "props": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-props-v1.webp", "pixel": 4.8, "colors": 64,
        "grid": (2, 5),
        "names": ["lamp_post", "bollard", "planter", "hedge", "glow_plant",
                  "railing", "guide_rail", "intercom", "bench", "beacon"],
    },
    "buildings": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-buildings-v1.webp", "pixel": 5.7, "upscale": 2, "colors": 64,
        "grid": (3, 3),
        "names": ["booth", "gate", "landmark",
                  "pool", "depot_door", "annex_door",
                  "projector", "terminal", ["sign_s", "sign_m", "sign_l"]],
    },
    # Pixels about 5.3 px (the campus's size), so 2 x 2 art pixels each. The
    # sheet's rows are uneven, so its four columns are the cells, each listing
    # the pieces below one another (states side by side: station, core, hatch,
    # gate; the levers share column 2).
    "objects": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-objects-v1.webp", "pixel": 5.3, "upscale": 2, "colors": 64,
        "grid": (1, 4),
        "names": [["recovery_station_off", "core_calm", "gate_locked"],
                  ["recovery_station_on", "core_alarm", "gate_open", "lever_up", "lever_down"],
                  ["workbench", "hatch_closed", "gate_shut"],
                  ["weapon_pad", "hatch_open"]],
    },
    # The walkway, platform and pit cover plus the pickups and the practice
    # target. Pixels about 7 px (coarser than the campus's), so 2 x 2 art
    # pixels each: the walkway is as thick as its collision (20 px) and a chip
    # is as big as the code-drawn one. The sheet's rows are uneven, so its six
    # columns are the cells, each listing the pieces below one another.
    "objects2": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-objects2-v1.webp", "pixel": 7.0, "upscale": 2, "colors": 48,
        "grid": (1, 6),
        "names": ["chip",
                  ["service_walkway", "chip_cluster"],
                  "keycard",
                  ["moving_platform", "med_patch", "practice_target"],
                  ["pit_cover", "evidence_folder"],
                  "chip_cache"],
    },
    # Two long seamless strips (the wet paving and the retaining wall under it),
    # generated 4 px per pixel (a 320-pixel ask came out 343 wide). Kept at one
    # art pixel per generated pixel, so the paving is as thick as the old
    # walkway (20 art rows = 30 world px). Two pieces in a 2 x 1 grid, top to
    # bottom.
    "paving": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-paving-v1.webp", "pixel": 4.0, "colors": 64,
        "grid": (2, 1),
        "names": ["paving", "wall"],
        # Each strip's first and last column are the generator's own outline
        # (see make_strip). The paving keeps its slab joint at the repeat; the
        # wall's bricks run on across it, its last 6 columns cross-faded in.
        "strips": {"paving": {"joint": True}, "wall": {"blend": 6}},
    },
    # Small ground details (decals, Sheet 8): three puddles, two cracks, a drain
    # grate, fallen leaves, a cable, a floor vent, a hose and a box. Pixels about
    # 5.5 px (the campus's size), kept at one art pixel per generated pixel (no
    # `upscale`): a puddle is then about 73 world px wide and the box 37 tall.
    # The rows are uneven, so its eight columns are the cells, each listing the
    # pieces below one another. `join` grows the opaque mask this many px for
    # finding pieces, so the leaves (loose, 10 px apart) and each crack's stray
    # specks stay one piece; the box then trims back to the real pixels.
    "details": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-details-v1.webp", "pixel": 5.5, "colors": 48,
        "join": 14,
        "grid": (1, 8),
        "names": ["puddle_a",
                  "leaves",
                  ["puddle_b", "hose"],
                  ["puddle_c", "cable"],
                  [],
                  ["crack_a", "box"],
                  ["crack_b", "vent"],
                  "grate"],
    },
    # The foreground sheet (Sheet 7, v2): near-black silhouettes (hedges with
    # their grass tufts, railings, bollards, benches and loose grass) laid in
    # 3 rows with irregular spacing, so the pieces are named in reading order
    # (`rows` bands top to bottom, left to right inside a band) instead of by a
    # grid cell. Generated pixels about 5 px, kept at one art pixel per
    # generated pixel; `join` keeps each hedge with its grass tuft (they touch
    # or nearly touch) while a bench next to a hedge stays two pieces.
    "foreground": {
        "sheet": "concept-art/env-sunnyvale/sunnyvale-foreground-v2.webp", "pixel": 5.0, "colors": 8,
        "join": 4, "rows": 3, "rim": (34, 52, 78),
        "names": ["hedge_a", "railing", "hedge_b", "bollard_a",
                  "grass_a", "bench_a", "hedge_c", "railing_short", "grass_b", "grass_c",
                  "hedge_long", "bollard_b", "hedge_d", "bench_b"],
    },
}


def join_mask(mask, r):
    """The opaque mask grown `r` px every way, so loose parts of one piece (a
    cluster of leaves, a crack's specks) are found as one island."""
    out = mask.copy()
    for d in range(1, r + 1):
        out[d:] |= mask[:-d]
        out[:-d] |= mask[d:]
    grown = out.copy()
    for d in range(1, r + 1):
        grown[:, d:] |= out[:, :-d]
        grown[:, :-d] |= out[:, d:]
    return grown


def trim_boxes(boxes, mask):
    """Each box cut back to the real opaque pixels inside it."""
    out = []
    for x0, y0, x1, y1 in boxes:
        ys, xs = np.nonzero(mask[y0:y1, x0:x1])
        out.append((x0 + int(xs.min()), y0 + int(ys.min()), x0 + int(xs.max()) + 1, y0 + int(ys.max()) + 1))
    return out


def find_pieces(alpha, min_px=400, gap=3):
    """Bounding boxes (x0, y0, x1, y1) of the opaque islands, joining parts
    closer than `gap` px (a hedge's loose leaves stay with their planter)."""
    h, w = alpha.shape
    seen = np.zeros_like(alpha, dtype=bool)
    boxes = []
    ys, xs = np.nonzero(alpha)
    for sy, sx in zip(ys[::7], xs[::7]):
        if seen[sy, sx]:
            continue
        q = deque([(sy, sx)])
        seen[sy, sx] = True
        y0 = y1 = sy
        x0 = x1 = sx
        n = 0
        while q:
            cy, cx = q.popleft()
            n += 1
            y0, y1, x0, x1 = min(y0, cy), max(y1, cy), min(x0, cx), max(x1, cx)
            for ny in range(max(cy - gap, 0), min(cy + gap + 1, h)):
                for nx in range(max(cx - gap, 0), min(cx + gap + 1, w)):
                    if alpha[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        q.append((ny, nx))
        if n >= min_px:
            boxes.append((x0, y0, x1 + 1, y1 + 1))
    return boxes


def best_offset(rgba, block):
    """The grid phase whose block borders line up with the most colour edges."""
    rgb = rgba[..., :3].astype(np.float32)
    solid = rgba[..., 3] > 200
    dx = np.abs(np.diff(rgb, axis=1)).sum(-1) * (solid[:, 1:] & solid[:, :-1])
    dy = np.abs(np.diff(rgb, axis=0)).sum(-1) * (solid[1:] & solid[:-1])
    cx, cy = dx.sum(0), dy.sum(1)
    # an edge between columns i and i+1 is a block border when (i + 1 - o) % block == 0
    ox = max(range(block), key=lambda o: cx[(o - 1) % block::block].sum())
    oy = max(range(block), key=lambda o: cy[(o - 1) % block::block].sum())
    return ox, oy


def grid_lines(energy, pixel, slack=1.5, bend=0.15):
    """Cell borders along one axis (0 = before the first image pixel,
    len(energy) + 1 = after the last), spaced near `pixel` and chosen by
    dynamic programming to sit on the strongest colour edges. `energy[i]` is
    the edge between image pixels i and i + 1."""
    n = len(energy) + 1
    e = np.concatenate([[0.0], energy, [0.0]])
    e = e / (e.max() + 1e-6)
    lo, hi = max(2, int(np.floor(pixel - slack))), int(np.ceil(pixel + slack))
    best = np.full(n + 1, -np.inf)
    prev = np.zeros(n + 1, int)
    best[0] = 0.0
    for i in range(1, n + 1):
        if i < lo:
            best[i] = e[i]   # a short first cell in the margin
            continue
        for g in range(lo, min(hi, i) + 1):
            v = best[i - g] + e[i] - bend * (g - pixel) ** 2
            if v > best[i]:
                best[i] = v
                prev[i] = i - g
    out = [max(range(max(n - hi, 1), n + 1), key=lambda i: best[i])]
    while out[-1] > 0:
        out.append(prev[out[-1]])
    return out[::-1]


def reduce_grid(rgba, xs, ys):
    """One art pixel per grid cell, coloured like reduce_blocks(): the
    cell's median, or the average of its clearly brighter pixels (a lamp
    lens); transparent unless most of the cell is opaque."""
    out = np.zeros((len(ys) - 1, len(xs) - 1, 4), np.uint8)
    w = np.array([0.3, 0.59, 0.11], np.float32)
    for r in range(len(ys) - 1):
        for c in range(len(xs) - 1):
            cell = rgba[ys[r]:ys[r + 1], xs[c]:xs[c + 1]].reshape(-1, 4).astype(np.float32)
            seen = cell[:, 3] >= 128
            if seen.sum() * 2 < len(cell):
                continue
            rgb = cell[seen, :3]
            med = np.median(rgb, 0)
            bright = rgb @ w > med @ w + 40.0
            out[r, c, :3] = np.round(rgb[bright].mean(0) if bright.sum() >= 2 else med)
            out[r, c, 3] = 255
    return out


def reduce_detected(crop, pixel):
    rgb = crop[..., :3].astype(np.float32)
    solid = (crop[..., 3] > 128).astype(np.float32)
    dx = (np.abs(np.diff(rgb, axis=1)).sum(-1) + 255.0 * np.abs(np.diff(solid, axis=1))).sum(0)
    dy = (np.abs(np.diff(rgb, axis=0)).sum(-1) + 255.0 * np.abs(np.diff(solid, axis=0))).sum(1)
    return reduce_grid(crop, grid_lines(dx, pixel), grid_lines(dy, pixel))


def make_strip(p, joint=False, blend=0):
    """A long strip that repeats sideways, as the generator drew it: its first
    and last column are its own dark outline, which would show as a seam where
    the strip repeats. Returns [left cap][period][right cap]: the caps are the
    outline columns (1 art pixel on a lone block's ends, drawn only there), the
    period is what repeats between them. `joint` keeps the right outline in the
    period, as the joint between the last slab and the first (slab seams stay
    evenly spaced); otherwise the outline goes and the last `blend` columns
    are cross-faded into the first (make_seamless), so bricks run on across the
    repeat. The strip is a solid rectangle: the corners the generator left
    clear are filled from their neighbours."""
    ys, xs = np.nonzero(p[..., 3])
    p = p[ys.min():ys.max() + 1, xs.min():xs.max() + 1].copy()   # off the margin cells
    clear = p[..., 3] == 0
    clear[:, 1:-1] = False
    p[:, 0][clear[:, 0]] = p[:, 1][clear[:, 0]]
    p[:, -1][clear[:, -1]] = p[:, -2][clear[:, -1]]
    p[..., 3] = 255
    inner = p[:, 1:] if joint else make_seamless(p[:, 1:-1], blend)
    return np.concatenate([p[:, :1], inner, p[:, -1:]], axis=1)


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in SHEETS:
        raise SystemExit("usage: import_pixel_sheet.py %s" % "|".join(SHEETS))
    name = sys.argv[1]
    cfg = SHEETS[name]
    src = np.asarray(Image.open(os.path.join(REPO, cfg["sheet"])).convert("RGBA"))
    solid = src[..., 3] > 128
    if "join" in cfg:
        boxes = trim_boxes(find_pieces(join_mask(solid, cfg["join"])), solid)
    else:
        boxes = find_pieces(solid)
    rows, cols = cfg.get("grid", (cfg.get("rows", 1), 1))
    h, w = src.shape[:2]
    pieces = {}
    boxes = sorted(boxes, key=lambda b: (b[1], b[0]))   # top to bottom, so a list cell fills in order
    if "rows" in cfg:   # uneven rows: the names are in reading order, not by grid cell
        if len(boxes) != len(cfg["names"]):
            raise SystemExit("found %d pieces, expected %d" % (len(boxes), len(cfg["names"])))
        reading = sorted(boxes, key=lambda b: (int((b[1] + b[3]) / 2 / h * rows), b[0]))
        by_box = {b: cfg["names"][i] for i, b in enumerate(reading)}
    for (x0, y0, x1, y1) in boxes:
        cell = int((y0 + y1) / 2 / h * rows) * cols + int((x0 + x1) / 2 / w * cols)
        piece_name = by_box[(x0, y0, x1, y1)] if "rows" in cfg else cfg["names"][cell]
        if isinstance(piece_name, list):
            taken = [n for n in piece_name if n in pieces]
            if len(taken) == len(piece_name):
                raise SystemExit("too many pieces in cell %d" % cell)
            piece_name = piece_name[len(taken)]   # boxes arrive in any order: fixed below by y
        if piece_name in pieces:
            raise SystemExit("two pieces landed in cell %d (%s)" % (cell, piece_name))
        m = int(2 * cfg.get("block", cfg.get("pixel", 0)))
        crop = src[max(y0 - m, 0):y1 + m, max(x0 - m, 0):x1 + m]
        if "pixel" in cfg:
            piece = reduce_detected(crop, cfg["pixel"])
            k = cfg.get("upscale", 1)
            pieces[piece_name] = piece.repeat(k, axis=0).repeat(k, axis=1) if k > 1 else piece
        else:
            pieces[piece_name] = reduce_blocks(crop, cfg["block"], best_offset(crop, cfg["block"]))
    missing = [n for cell in cfg["names"] for n in (cell if isinstance(cell, list) else [cell]) if n not in pieces]
    if missing:
        raise SystemExit("pieces not found: %s" % ", ".join(missing))
    for n, strip_cfg in cfg.get("strips", {}).items():
        pieces[n] = make_strip(pieces[n], **strip_cfg)
    if "rim" in cfg:   # a faint light along every upward-facing edge (the foreground brief asks for one)
        for p in pieces.values():
            solid_px = p[..., 3] > 0
            solid_above = np.zeros_like(solid_px)
            solid_above[1:] = solid_px[:-1]
            p[solid_px & ~solid_above, :3] = cfg["rim"]
    # One shared palette: quantize every piece's opaque pixels together.
    order = [n for cell in cfg["names"] for n in (cell if isinstance(cell, list) else [cell])]
    strip_h = max(p.shape[0] for p in pieces.values())
    strip = np.zeros((strip_h, sum(p.shape[1] for p in pieces.values()), 3), np.uint8)
    x = 0
    for n in order:
        p = pieces[n]
        strip[:p.shape[0], x:x + p.shape[1]] = p[..., :3]
        x += p.shape[1]
    pal = Image.fromarray(strip).quantize(colors=cfg["colors"], method=Image.Quantize.FASTOCTREE,
                                          dither=Image.Dither.NONE)
    out_dir = os.path.join(OUT_DIR, name)
    os.makedirs(out_dir, exist_ok=True)
    for n in order:
        p = pieces[n]
        rgb = Image.fromarray(np.ascontiguousarray(p[..., :3])).quantize(palette=pal, dither=Image.Dither.NONE)
        img = rgb.convert("RGB")
        img.putalpha(Image.fromarray(np.ascontiguousarray(p[..., 3])))
        # trim to the opaque bounds
        img = img.crop(img.getbbox())
        img.save(os.path.join(out_dir, n + ".png"))
        print("%-16s %3d x %3d art px" % (n, img.width, img.height))


if __name__ == "__main__":
    main()

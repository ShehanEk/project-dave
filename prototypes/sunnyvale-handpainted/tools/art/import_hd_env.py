#!/usr/bin/env python3
"""Import the hand-painted HD environment sheets (C56, art-design/handpainted-style.md; the
corporate cyberpunk sheets of C58) into assets/environment/hd/. Run from the project root:
    python3 tools/art/import_hd_env.py                    batch 1: terrain, backgrounds, props
    python3 tools/art/import_hd_env.py --batch2           batch 2 (below)
    python3 tools/art/import_hd_env.py --batch2 details2  only the named steps of a batch

Two kinds of output:
1. Swap textures (the two background layers): each is rebuilt at its pixel piece's exact layout
   (the pixel PNG's size times a scale k), so the backdrop keeps slicing it in the pixel piece's
   art px and scripts/world/hd_skins.gd draws it in place of the pixel PNG at the same path under
   assets/environment/hd/. The walkway deck and the wall under it get new layouts like batch 2's
   pieces (a layout PNG at the pixel path, the painting at the HD path; TerrainSkins slices by the
   layout). Every strip is blended across its seam so it tiles.
2. Props (cut from the props sheets) with their own sizes and slices in props.json: a world scale
   per prop (each keeps the world size the batch 1 prop had), the anchor column (the lamp's pole,
   not the middle of its arm), the lamp's head, pole and base rows and lens, the landmark's head
   and repeating shaft, the railing's bay. The lamp's warm lens is repainted cold white (the
   game's lamps are cold white light).
Every textured piece but the backgrounds gets a normal map (<name>_n.png) from its silhouette and
painted detail, so the game's lamps light it.
"""
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_parts_sheet import REPO, normal_map  # noqa: E402

PROJECT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUT = os.path.join(PROJECT, "assets", "environment", "hd")
PIX = os.path.join(PROJECT, "assets", "environment", "sunnyvale")
ART = "concept-art/style-handpainted/"


def load(name):
    return np.asarray(Image.open(os.path.join(REPO, ART, name)).convert("RGBA"), np.float32)


def save(arr, rel):
    path = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)).save(path)
    return path


def resize(arr, w, h):
    pm = arr.copy()
    pm[..., :3] *= pm[..., 3:4] / 255.0
    out = np.asarray(Image.fromarray(np.clip(pm, 0, 255).astype(np.uint8)).resize((w, h), Image.LANCZOS), np.float32)
    a = out[..., 3:4]
    out[..., :3] = np.where(a > 0.5, out[..., :3] * 255.0 / np.maximum(a, 1e-3), 0.0)
    return out


def seam(arr, n):
    """Cross-fades the last `n` columns into the first, then drops them: the strip tiles."""
    w = arr.shape[1] - n
    out = arr[:, :w].copy()
    t = np.linspace(0.0, 1.0, n)[None, :, None]
    out[:, :n] = arr[:, w:] * (1.0 - t) + arr[:, :n] * t
    return out


def warp_rows(arr, x0, pairs):
    """Moves rows of the columns from `x0` to the right end: sheet row src lands on dst for each
    (src, dst) of `pairs` (top to bottom), easing in from nothing at x0 to all of it at the last
    column; rows above the first pair shift with it, rows below the last stay. Lines up a strip
    whose two ends were painted a few rows apart."""
    out = arr.copy()
    h = arr.shape[0]
    ys = np.arange(h, dtype=np.float64)
    last = arr.shape[1] - 1
    for x in range(x0, arr.shape[1]):
        t = (x - x0) / float(max(1, last - x0))
        dst = [s + (d - s) * t for s, d in pairs]
        src = [s for s, _ in pairs]
        # output row -> sheet row: shifted above the first pair, piecewise linear between, kept below
        m = np.interp(ys, dst, src)
        m = np.where(ys < dst[0], ys + (src[0] - dst[0]), m)
        m = np.where(ys > dst[-1], ys + (src[-1] - dst[-1]), m)
        for c in range(arr.shape[2]):
            out[:, x, c] = np.interp(m, ys, arr[:, x, c].astype(np.float64))
    return out


def cut(arr, box, w, h):
    """The sheet region `box` (float (x0, y0, x1, y1), sheet px) resampled to w x h texels, alpha
    premultiplied: fractional edges keep a lit lip on an exact art row."""
    pm = arr.copy()
    pm[..., :3] *= pm[..., 3:4] / 255.0
    im = Image.fromarray(np.clip(pm, 0, 255).astype(np.uint8))
    out = np.asarray(im.resize((int(w), int(h)), Image.LANCZOS, box=tuple(float(v) for v in box)), np.float32)
    a = out[..., 3:4]
    out[..., :3] = np.where(a > 0.5, out[..., :3] * 255.0 / np.maximum(a, 1e-3), 0.0)
    return out


def silhouette(arr):
    """The near-camera foreground's look: the painting pressed to a near-black navy that keeps a
    trace of its shading, so its lit rims stay a faint cool line (brightest channel about 0.22)."""
    out = arr.copy()
    lum = arr[..., :3].mean(-1, keepdims=True)
    out[..., :3] = np.array([4.0, 9.0, 16.0]) + lum * np.array([0.06, 0.10, 0.16])
    return out


def normals(arr, edge):
    n = normal_map(arr, edge)
    rgba = np.concatenate([n * 255.0, np.full(arr.shape[:2] + (1,), 255.0)], -1)
    return rgba


def pixel_size(rel):
    return Image.open(os.path.join(PIX, rel)).size


def swap(arr, rel, edge=None):
    """`arr` resized to the pixel piece's layout at the scale its width gives; returns k."""
    pw, ph = pixel_size(rel)
    k = arr.shape[1] / pw
    out = resize(arr, int(round(pw * k)), int(round(ph * k)))
    save(out, rel)
    if edge:
        save(normals(out, edge), rel.replace(".png", "_n.png"))
    print("%-22s %4d x %3d  (k %.2f per art px)" % (rel, out.shape[1], out.shape[0], k))
    return k


def components(alpha):
    fg = alpha > 128
    h, w = fg.shape
    lab = np.zeros((h, w), np.int32)
    n = 0
    for y0 in range(0, h, 2):
        for x0 in np.nonzero(fg[y0] & (lab[y0] == 0))[0]:
            if lab[y0, x0]:
                continue
            n += 1
            lab[y0, x0] = n
            q = deque([(y0, x0)])
            while q:
                y, x = q.popleft()
                for ny, nx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                    if 0 <= ny < h and 0 <= nx < w and fg[ny, nx] and not lab[ny, nx]:
                        lab[ny, nx] = n
                        q.append((ny, nx))
    return lab


# The C57 size audit (Dave, 96 px, is 1.75 m: 55 px a metre): the pixel props these were matched to
# were short for real ones. A railing about 1.05 m, a bollard about 0.95 m, an intercom post 1.4 m.
SIZE_FIX = {"railing": 1.45, "bollard": 1.35, "intercom": 1.4}


## The walkway sheet (C58): the deck's front face (sheet rows 168-247; its cold-white lit top edge
## rows 173-177, brightest 174-176) over the graphite wall (rows 342-603). Both are cut unscaled (4
## sheet px an art px, so the deck stays 20 art rows, 30 world px, like the paving it replaces) from
## the same columns: they share one period and the deck's cyan seams stay over the wall's conduit
## stubs (TerrainSkins tiles both from art column 1, in phase with the block's x).
WALKWAY = "walkway-hd-v2.webp"
WALK_K = 4
WALK_PERIOD = (99, 2087)     # sheet columns: 497 art px (the panel across the repeat as wide as the rest)
WALK_SEAM = 48               # the columns after the period blended into its start
WALK_LIP = 174               # the lit edge's first bright row: the floor line ...
WALK_EDGE = 2                # ... on this art row (TerrainSkins "walkway" edge); rows above stand behind the feet
WALL_ROWS = (343, 559)       # the wall's lit top lip down to the dark line under its panels: 54 art rows


def _strip(a, rows, period, n, k):
    """Sheet rows [rows) as [left cap, the period seamed with the n columns after it, right cap], the
    caps one art px of the columns either side of the period's end, darkened to read as the end of a
    lone block (TerrainSkins draws them only there)."""
    (y0, y1), (x0, x1) = rows, period
    left = a[y0:y1, x1 - k:x1].copy()
    right = a[y0:y1, x1:x1 + k].copy()
    for c in (left, right):
        c[..., :3] *= 0.5
    return np.concatenate([left, seam(a[y0:y1, x0:x1 + n], n), right], 1)


def terrain():
    a = load(WALKWAY)
    top = WALK_LIP - WALK_EDGE * WALK_K
    deck = _strip(a, (top, top + 20 * WALK_K), WALK_PERIOD, WALK_SEAM, WALK_K)
    deck[3:, :, 3] = 255                              # the face is solid from the deck's top bevel down
    layout_piece(deck, 20, "paving/paving.png", normals_edge=8.0)
    # The wall face: 54 art rows (TerrainSkins draws its rows 1-55 once under the deck, FACE_DEPTH),
    # over a row 0 that is never drawn (a copy of the first, so no filtering reaches transparency).
    face = _strip(a, WALL_ROWS, WALK_PERIOD, WALK_SEAM, WALK_K)
    wall = np.concatenate([face[:WALK_K], face], 0)
    wall[..., 3] = 255
    layout_piece(wall, 55, "paving/wall.png", normals_edge=10.0)


## The far layer (C58): sky and megatowers with a maglev line that falls 0.0193 px a px to the
## right; the columns are sheared by it (each column moves down by the slope times its distance from
## the right edge, the sky's top colour filling in above), so the line is level and meets itself
## across the repeat. The period keeps the pixel layer's proportions at the sheet's full height.
FAR = "far-hd-v3.webp"
FAR_SLOPE = 0.0193
FAR_X0 = 20          # the period's first column (its seam window clear of the drones and their beams)
FAR_SEAM = 60
## The campus (C58): office pavilions cut under their ground line (the dark rows 645-646). Its ends
## were painted to meet but the right end's roof band sits up to 6 rows low; warp_rows lifts it over
## its last CAMPUS_WARP columns (the windows below already line up).
CAMPUS = "campus-hd-v2.webp"
CAMPUS_GROUND = 647
CAMPUS_WARP = 48
CAMPUS_ROOF = [(330, 324), (339, 336), (348, 346), (380, 380)]   # (right end row, left end row)


def backgrounds():
    src = Image.open(os.path.join(REPO, ART, FAR)).convert("RGB")
    w, h = src.size
    sky = tuple(int(v) for v in np.asarray(src, np.float32)[0].mean(0))
    far = np.asarray(src.transform((w, h), Image.AFFINE, (1, 0, 0, FAR_SLOPE, 1, -FAR_SLOPE * w),
                                   resample=Image.BICUBIC, fillcolor=sky), np.float32)
    pw, ph = pixel_size("far.png")
    period = int(round(h * pw / float(ph)))
    far = seam(far[:, FAR_X0:FAR_X0 + period + FAR_SEAM], FAR_SEAM)
    # The backdrop fills the sky above the painting with the pixel layer's top colour: fade into it.
    flat = np.asarray(Image.open(os.path.join(PIX, "far.png")).convert("RGB"), np.float32)[0, 0]
    t = np.clip(1.0 - np.arange(far.shape[0]) / 48.0, 0.0, 1.0)[:, None, None]
    far = np.concatenate([far * (1.0 - t) + flat * t, np.full(far.shape[:2] + (1,), 255.0)], -1)
    swap(far, "far.png")
    campus = load(CAMPUS)[:CAMPUS_GROUND]
    campus = warp_rows(campus, campus.shape[1] - CAMPUS_WARP, CAMPUS_ROOF)
    swap(campus, "campus.png")


## key: (sheet, a sheet point in the prop, the dimension kept, its world px before SIZE_FIX). The
## sizes are the batch 1 props' (matched to the pixel pieces, C56), so every placed prop keeps its
## size: its height for the lamp, posts and buildings, its width (its footprint) for the rest. The
## landmark pylon is not on the v3 sheet: it stays the v1 one, at its scale.
PROPS3 = "props-hd-v3.webp"
PROPS = {
    "lamp_post": (PROPS3, (122, 200), "h", 122.72),     # lamp
    "bench": (PROPS3, (436, 355), "w", 108.31),          # bench
    "planter": (PROPS3, (809, 400), "w", 75.28),         # low barrier block
    "hedge": (PROPS3, (1107, 400), "w", 72.25),          # utility cabinet
    "railing": (PROPS3, (1305, 400), "h", 39.31),        # glass balustrade
    "bollard": (PROPS3, (138, 800), "h", 37.84),         # LED bollard
    "intercom": (PROPS3, (330, 800), "h", 54.26),        # intercom post
    "booth": (PROPS3, (730, 780), "h", 165.41),          # guard booth
    "gate": (PROPS3, (1060, 750), "w", 267.53),          # broken barrier gate
    "landmark": ("props-hd-v1.webp", (294, 636), "scale", 0.49),
}


def props():
    path = os.path.join(OUT, "props", "props.json")
    manifest = json.load(open(path)) if os.path.exists(path) else {}   # keeps batch 2's props
    sheets = {}
    for key, (sheet_name, at, dim, size) in PROPS.items():
        if sheet_name not in sheets:
            s = load(sheet_name)
            sheets[sheet_name] = (s, components(s[..., 3]))
        sheet, lab = sheets[sheet_name]
        cid = lab[at[1], at[0]]
        assert cid, key
        ys, xs = np.nonzero(lab == cid)
        y0, y1, x0, x1 = int(ys.min()), int(ys.max()) + 1, int(xs.min()), int(xs.max()) + 1
        crop = sheet[y0:y1, x0:x1].copy()
        crop[..., 3] *= (lab[y0:y1, x0:x1] == cid)
        if dim == "scale":
            scale = size
        else:
            scale = size / float(crop.shape[0] if dim == "h" else crop.shape[1]) * SIZE_FIX.get(key, 1.0)
        entry = {"scale": round(scale, 5), "anchor_x": round(crop.shape[1] / 2.0, 1)}
        if key == "lamp_post":
            # The pole is sheet columns 111-135; the head with its arm and the lens's faint halo rows
            # 24-63, the pole 64-284 (repeats under the head), the base below. The painted light
            # falling down the pole is evened out so the repeat shows no step; the lens turns cold.
            entry["anchor_x"] = round(123.0 - x0, 1)
            entry["head"] = int(64 - y0)
            entry["pole"] = [int(64 - y0), int(285 - y0)]
            p0, p1 = entry["pole"]
            pole = crop[p0:p1]
            pole[:, :int(110 - x0), 3] = 0
            pole[:, int(137 - x0):, 3] = 0
            lum = np.array([r[..., :3][r[..., 3] > 128].mean() for r in pole])
            rows = np.arange(len(lum))
            trend = np.polyval(np.polyfit(rows, lum, 2), rows)
            pole[..., :3] *= (lum.mean() / trend)[:, None, None]
            lens = (int(152 - x0), int(39 - y0), int(240 - x0), int(48 - y0))
            entry["lens"] = list(lens)
            sub = crop[lens[1]:lens[3], lens[0]:lens[2]]
            warm = (sub[..., 0] > 170) & (sub[..., 3] > 128)
            lum = sub[..., :3].mean(-1, keepdims=True)
            cold = np.concatenate([lum * 0.92, lum * 0.96, lum * 1.0], -1)
            sub[..., :3] = np.where(warm[..., None], np.maximum(cold, [205, 222, 245]), sub[..., :3])
        if key == "landmark":
            entry["head"] = int(620 - y0)                     # head rows [0, head) above the origin
            entry["shaft"] = [int(620 - y0), int(780 - y0)]   # repeats down to the ground
            entry["emblem"] = [round(294 - x0, 1), int(490 - y0)]
        if key == "railing":
            entry["units"] = [int(1307 - x0), int(1498 - x0)]  # left post .. middle post (centres): one bay
        manifest[key] = entry
        save(crop, "props/%s.png" % key)
        save(normals(crop, max(4.0, 0.035 * min(crop.shape[:2]))), "props/%s_n.png" % key)
        print("%-10s %3d x %3d texels, %.1f x %.1f world px" % (key, crop.shape[1], crop.shape[0],
              crop.shape[1] * scale, crop.shape[0] * scale))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)


# --- batch 2 (2026-10-11): pieces re-laid out at the painted art's own proportions ------------------
#
# The batch 2 sheets don't share the pixel pieces' proportions (the terrain strips are about twice
# as long, the recovery station squat where the pixel one is tall), so instead of squeezing them
# into the pixel layouts, each piece gets a new layout PNG at the pixel path (the painting reduced
# to 1 texel per art px, 1.5 world px: what the skins slice and size by) and the full-resolution
# painting at the HD path (k texels per art px, drawn in its place by hd_skins.gd). The code that
# slices or anchors into a piece (TerrainSkins' SKINS rows and columns, the objects' lamp and lens
# points) is updated to the new layouts; the numbers printed here are those layouts.

PIX_ROOT = PIX


def crop_box(sheet, box):
    x0, y0, x1, y1 = box
    return sheet[y0:y1, x0:x1].copy()


def layout_piece(crop, art_h, rel, edge_px=None, normals_edge=6.0, art_w=None):
    """`crop` (float RGBA) as a piece `art_h` art px tall: writes the layout PNG (at the pixel path)
    and the HD PNG with its normal map (at the HD path). Returns (k, art_w, art_h)."""
    k = crop.shape[0] / float(art_h)
    w = art_w or max(1, int(round(crop.shape[1] / k)))
    hd = resize(crop, int(round(w * k)), int(round(art_h * k)))
    small = resize(crop, w, art_h)
    path = os.path.join(PIX_ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(np.clip(small, 0, 255).astype(np.uint8)).save(path)
    save(hd, rel)
    if normals_edge:
        save(normals(hd, normals_edge), rel.replace(".png", "_n.png"))
    print("%-28s %4d x %3d art px, k %.2f" % (rel, w, art_h, k))
    return k, w, art_h


def write_piece(hd, w, h, rel, normals_edge=6.0):
    """An HD painting already at w x h art px (whole texels per art px): its layout PNG (at the
    pixel path), the painting and its normal map (at the HD path)."""
    path = os.path.join(PIX_ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(np.clip(resize(hd, w, h), 0, 255).astype(np.uint8)).save(path)
    save(hd, rel)
    if normals_edge:
        save(normals(hd, normals_edge), rel.replace(".png", "_n.png"))
    print("%-28s %4d x %3d art px, %d texels an art px" % (rel, w, h, hd.shape[1] // w))


def terrain_strip(sheet, rel, lip, edge, k, bottom, left, right, period=None, n=0):
    """A terrain strip at k sheet px an art px, its walkable lip (sheet row `lip`, the lit edge's
    first bright row) on art row `edge`, down to sheet row `bottom`. `left` (sheet x, art px) is the
    painted left end from that column, `right` (sheet x, art px) the right end up to it: TerrainSkins'
    end caps, drawn only at a lone block's ends. Between them repeats `period` (sheet columns
    [p0, p1), the n after p1 blended into p0) or, with none, the sheet between the caps as painted
    (its ends meet). Returns the layout: {w, h, edge, cols}."""
    kk = max(1, int(round(k)))                           # HD texels an art px
    top = lip - edge * k
    h = int(round((bottom - top) / k))
    y1 = top + h * k
    (lx, lw), (rx, rw) = left, right
    parts = [cut(sheet, (lx, top, lx + lw * k, y1), lw * kk, h * kk)]
    if period:
        p0, p1 = period
        mid = seam(sheet[:, p0:p1 + n], n)
        mid = np.concatenate([mid[:, -16:], mid, mid[:, :16]], 1)   # filter across the wrap
        mw = int(round((p1 - p0) / k))
        parts.append(cut(mid, (16, top, 16 + p1 - p0, y1), mw * kk, h * kk))
    else:
        mx0, mx1 = lx + lw * k, rx - rw * k
        mw = int(round((mx1 - mx0) / k))
        parts.append(cut(sheet, (mx0, top, mx1, y1), mw * kk, h * kk))
    parts.append(cut(sheet, (rx - rw * k, top, rx, y1), rw * kk, h * kk))
    hd = np.concatenate(parts, 1)
    hd[int((edge + 1) * kk):, :, 3] = np.where(hd[int((edge + 1) * kk):, :, 3] > 8, 255.0, 0.0)
    w = lw + mw + rw
    write_piece(hd, w, h, rel)
    return {"w": w, "h": h, "edge": edge, "cols": [lw, lw + mw]}


def terrain2():
    """The corporate cyberpunk terrain sheet (C58). The strips keep the rows the old pieces had
    under their walkable edge (the face a block shows: the platform, roof and wall faces stay as
    thick), and take the painting's own proportions above it (the ledge's glass parapet, the roof's
    rooftop kit); the backstop block and the AC unit keep their heights (the AC is drawn whole on a
    block sized to it), the column its width. Each lit lip lands exactly on its edge row."""
    sheet = load("terrain-hd-v3.webp")
    out = {}
    # PLATFORM: the ledge with its glass parapet; the period is three parapet bays, its seam between
    # posts and between the face's cyan seams. 23 art rows under the lip, as before.
    out["planter_ledge"] = terrain_strip(sheet, "terrain/planter_ledge.png", 243, 34, 67.0 / 23, 310,
                                         (24, 28), (1512, 28), (293, 1343), 48)
    # ROOF: the roof edge with its vents, rooftop units and amber markers (14 art rows under the lip);
    # the seam falls on the two end markers, painted 1388 px apart.
    out["green_roof"] = terrain_strip(sheet, "terrain/green_roof.png", 521, 36, 75.0 / 14, 596,
                                      (28, 4), (1508, 4), (69, 1457), 40)
    # WALL: the raised platform wall (62 art rows under its lit lid, as before); its painted middle
    # (vent, panel, cyan-lit panel) repeats from divider to divider, the pipes are its right end.
    out["retaining_wall"] = terrain_strip(sheet, "terrain/retaining_wall.png", 741, 2, 200.0 / 62, 941,
                                          (44, 6), (521, 21))
    # BACKSTOP: the composite block, 82 rows like the stone planter: its middle (one bolted panel)
    # repeats, the cyan light and pipes are its right end.
    out["stone_planter"] = terrain_strip(sheet, "terrain/stone_planter.png", 691, 3, 250.0 / 79, 941,
                                         (590, 5), (879, 24))
    out["stone_planter"]["body"] = [14, 46]               # one stacked panel, divider to divider
    # The rooftop AC unit with its electrical box (its pipe left out), 59 rows, lid lip on row 2.
    k = (942 - 753) / 57.0
    top = 753 - 2 * k
    hd = cut(sheet, (965, top, 965 + 78 * k, 942), 78 * 3, 59 * 3)
    hd[..., 3] *= hd[..., 3] > 8
    write_piece(hd, 78, 59, "terrain/ac_unit.png")
    out["ac_unit"] = {"w": 78, "h": 59, "edge": 2}
    # The column, unscaled at 4 px an art px (34 wide like the old one): cap and bracket rows 0-13,
    # the lattice repeating every 64 sheet px (16 art rows) from row 14, the foot from row 62 (the
    # lattice's same phase) with its base.
    hd = cut(sheet, (1352, 614, 1488, 950), 34 * 4, 84 * 4)
    write_piece(hd, 34, 84, "terrain/support_column.png")
    out["support_column"] = {"w": 34, "h": 84, "body": [14, 30], "foot": 62}
    print(json.dumps(out))
    return out


def props2():
    """Batch 2 props drawn at their own size (props.json, like batch 1's): the world scale makes
    each about the pixel piece's size; the guide rail repeats its chevron bar between its posts."""
    path = os.path.join(OUT, "props", "props.json")
    manifest = json.load(open(path)) if os.path.exists(path) else {}
    jobs = [
        ("props2-hd-v1.webp", "pool", (253, 250, 1105, 391), 240.0 / 852, {}),
        ("props2-hd-v1.webp", "depot_door", (1130, 38, 1742, 389), 108.0 / 351, {}),
        ("props2-hd-v1.webp", "annex_door", (31, 432, 235, 735), 126.0 / 303, {}),
        ("props2-hd-v1.webp", "glow_plant", (50, 278, 208, 391), 36.0 / 113, {}),
        ("props2-hd-v1.webp", "guide_rail", (502, 605, 957, 714), 27.0 / 109, {"units": [56, 400]}),
        # C57 size audit (55 px a metre): the side table with its cup about 0.85 m, the desk with
        # its lamp about 1.2 m (they were 1.36 m and 1.64 m).
        ("story-hd-v1.webp", "breakfast", (112, 253, 569, 705), 47.0 / 452, {}),
        ("story-hd-v1.webp", "portrait_desk", (701, 59, 1349, 702), 66.0 / 643, {"lamp_head": [1100, 130]}),
    ]
    sheets = {}
    for sheet_name, key, box, scale, extra in jobs:
        if sheet_name not in sheets:
            sheets[sheet_name] = load(sheet_name)
        sheet = sheets[sheet_name]
        lab = components(sheet[..., 3])
        crop = crop_box(sheet, box)
        # Only the components that start inside the box (a neighbour's edge is left out).
        sub = lab[box[1]:box[3], box[0]:box[2]]
        ids = [i for i in np.unique(sub) if i and (sub == i).sum() > 200]
        keep = np.isin(sub, ids)
        crop[..., 3] *= keep
        entry = {"scale": round(scale, 5), "anchor_x": round(crop.shape[1] / 2.0, 1)}
        if "units" in extra:
            entry["units"] = extra["units"]
        if "lamp_head" in extra:
            lx, ly = extra["lamp_head"]
            entry["lamp_head"] = [round((lx - box[0] - crop.shape[1] / 2.0) * scale, 1), round(-(box[3] - ly) * scale, 1)]
        manifest[key] = entry
        save(crop, "props/%s.png" % key)
        save(normals(crop, max(4.0, 0.035 * min(crop.shape[:2]))), "props/%s_n.png" % key)
        print("%-14s %4d x %3d texels, %.1f x %.1f world px" % (key, crop.shape[1], crop.shape[0],
              crop.shape[1] * scale, crop.shape[0] * scale))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)


def objects2():
    """Interactive objects and pickups: each state of an object cropped with one shared box, so
    the states line up; the overlay points (lamps, lenses, the core's bar and port, the lever's
    ground point, the target's board) are printed in the new layouts' art px."""
    obj = load("objects-hd-v1.webp")
    pk = load("pickups-hd-v1.webp")
    pts = {}

    def piece(sheet, box, art_h, rel, points=None):
        crop = crop_box(sheet, box)
        k, w, h = layout_piece(crop, art_h, rel)
        for name, (x, y) in (points or {}).items():
            pts[name] = [round((x - box[0]) / k, 1), round((y - box[1]) / k, 1)]
        return k

    piece(obj, (166, 86, 384, 353), 67, "objects/recovery_station_off.png", {"station_lamp_off": (352, 106)})
    piece(obj, (468, 86, 686, 353), 67, "objects/recovery_station_on.png", {"station_lamp_on": (653, 106)})
    piece(obj, (890, 18, 1088, 352), 87, "objects/core_calm.png", {"core_port_calm": (1050, 205), "core_bar_calm": (918, 286)})
    piece(obj, (1192, 18, 1390, 352), 87, "objects/core_alarm.png", {"core_port_alarm": (1352, 205), "core_bar_alarm": (1220, 286)})
    k = piece(obj, (20, 390, 318, 661), 92, "objects/hatch_closed.png")
    pts["hatch_band"] = [int(round((470 - 390) / k)), int(round((530 - 390) / k))]
    piece(obj, (354, 390, 652, 661), 92, "objects/hatch_open.png")
    piece(obj, (690, 409, 948, 661), 80, "objects/gate_locked.png", {"lens_locked": (913, 495)})
    piece(obj, (968, 409, 1226, 661), 80, "objects/gate_open.png", {"lens_open": (1187, 487)})
    piece(obj, (1254, 409, 1512, 661), 80, "objects/gate_shut.png", {"lens_shut": (1490, 495)})
    k = piece(obj, (171, 768, 292, 947), 36, "objects/lever_up.png")
    pts["lever_up_ground"] = [round((231 - 171) / k, 1), round((945 - 768) / k + 4, 1)]
    k = piece(obj, (385, 826, 534, 972), 29, "objects/lever_down.png")
    pts["lever_down_ground"] = [round((446 - 385) / k, 1), round((945 - 826) / k + 4, 1)]
    piece(obj, (632, 690, 1436, 1000), 57, "objects/workbench.png", {"workbench_lamp": (1390, 712)})
    piece(pk, (51, 266, 153, 367), 20, "objects2/chip.png")
    piece(pk, (224, 153, 464, 364), 46, "objects2/chip_cluster.png")
    piece(pk, (548, 223, 738, 346), 18, "objects2/keycard.png")
    piece(pk, (815, 239, 940, 362), 24, "objects2/med_patch.png")
    piece(pk, (1005, 140, 1251, 374), 55, "objects2/chip_cache.png", {"cache_lock": (1125, 312)})
    piece(pk, (1286, 140, 1532, 374), 55, "objects2/chip_cache_open.png")
    piece(pk, (1572, 30, 1813, 527), 82, "objects2/practice_target.png",
          {"target_centre": (1692, 150), "target_pole_from": (1692, 285), "target_base_from": (1692, 455)})
    piece(pk, (94, 562, 1755, 625), 12, "objects2/service_walkway.png")
    # 15 art rows: the game's platforms are about 98 art px wide, and the painted plate's lights
    # and end caps must fit that (at 20 rows its fixed parts alone were 112 wide).
    piece(pk, (236, 417, 947, 525), 15, "objects2/moving_platform.png",
          {"platform_light1": (412, 495), "platform_light2": (593, 495), "platform_light3": (772, 495)})
    piece(pk, (325, 663, 1521, 818), 36, "objects2/pit_cover.png")
    st = load("story-hd-v1.webp")
    piece(st, (1608, 346, 1881, 701), 36, "story/evidence_folder_v2.png")
    print(json.dumps(pts))


## The details sheet (C58): each piece's sheet box (the red crushed can is left out: red is
## reserved for danger). hedge_c has no piece of its own on the sheet (it gives three utility boxes
## and the long barrier): it is the long barrier's left end and first panel joined to its right end
## (both cut on a panel divider), a short barrier block.
DETAILS = {
    "details/puddle_a": (38, 92, 420, 190), "details/puddle_b": (421, 95, 698, 186),
    "details/puddle_c": (700, 98, 935, 180), "details/crack_a": (950, 94, 1200, 186),
    "details/crack_b": (1234, 94, 1448, 186), "details/grate": (1480, 94, 1737, 186),
    "details/leaves": (268, 228, 456, 344), "details/cable": (496, 266, 917, 322),
    "details/vent": (956, 255, 1226, 341), "details/hose": (1264, 234, 1495, 347),
    "details/box": (1538, 228, 1678, 345),
    "foreground/hedge_a": (276, 383, 625, 517), "foreground/hedge_b": (674, 381, 1034, 518),
    "foreground/hedge_c": [(1084, 380, 1299, 518), (1656, 380, 1699, 518)],
    "foreground/hedge_d": (75, 385, 245, 518), "foreground/hedge_long": (1084, 380, 1699, 518),
    "foreground/railing_short": (79, 549, 477, 679), "foreground/railing": (536, 548, 1692, 677),
    "foreground/bench_a": (73, 718, 364, 832), "foreground/bench_b": (401, 715, 792, 833),
    "foreground/bollard_a": (842, 681, 922, 833), "foreground/bollard_b": (987, 690, 1064, 833),
    "foreground/grass_a": (1109, 743, 1393, 825), "foreground/grass_b": (1430, 686, 1563, 831),
    "foreground/grass_c": (1602, 691, 1682, 831),
}


## The pixel details' sizes (art px): the painted marks fit inside them.
DETAIL_BOX = {"details/puddle_a": (49, 6), "details/puddle_b": (51, 6), "details/puddle_c": (52, 6),
              "details/crack_a": (29, 19), "details/crack_b": (29, 22), "details/grate": (35, 7),
              "details/leaves": (39, 7), "details/cable": (112, 9), "details/vent": (40, 7),
              "details/hose": (39, 13), "details/box": (30, 26)}
## The puddles lie flat on the floor, seen almost edge on: they fill their box's width (squashed
## from the painting's steeper view) instead of fitting into it.
FLAT = ("details/puddle_a", "details/puddle_b", "details/puddle_c")
## The foreground pieces' sizes before C58 (art px, 2.5 world px each): a new piece covers the same
## area at its own proportions, so the row keeps its weight and the tests' size bands hold.
FOREGROUND_BOX = {"foreground/hedge_a": (42, 22), "foreground/hedge_b": (41, 22), "foreground/hedge_c": (35, 20),
                  "foreground/hedge_d": (30, 17), "foreground/hedge_long": (66, 11), "foreground/railing": (164, 15),
                  "foreground/railing_short": (47, 12), "foreground/bench_a": (37, 16), "foreground/bench_b": (36, 14),
                  "foreground/bollard_a": (8, 18), "foreground/bollard_b": (8, 18), "foreground/grass_a": (11, 9),
                  "foreground/grass_b": (9, 6), "foreground/grass_c": (10, 7)}


def details2():
    """Ground details and foreground silhouettes. A ground detail fits inside its pixel piece's box
    (centred on its bottom row); a foreground piece covers its old piece's area at its own
    proportions and is pressed to a near-black silhouette (silhouette())."""
    sheet = load("details-hd-v2.webp")
    for rel, box in DETAILS.items():
        crops = []
        for b in (box if isinstance(box, list) else [box]):
            c = crop_box(sheet, b)
            ys, xs = np.nonzero(c[..., 3] > 8)
            crops.append(c[:, xs.min():xs.max() + 1])
        crop = np.concatenate(crops, 1)
        ys, xs = np.nonzero(crop[..., 3] > 8)
        crop = crop[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
        if rel.startswith("details/"):
            # Ground marks stay inside the pixel piece's box (centred, on its bottom row): a taller
            # painted leaf pile or hose would reach onto the blocks the scenes placed them under.
            pw, ph = DETAIL_BOX[rel]
            k = 8.0
            if rel in FLAT:
                fw, fh = int(round(pw * 0.92 * k)), int(round(ph * k))
            else:
                kfit = min(pw / crop.shape[1], ph / crop.shape[0])
                fw, fh = int(round(crop.shape[1] * kfit * k)), int(round(crop.shape[0] * kfit * k))
            canvas = np.zeros((int(round(ph * k)), int(round(pw * k)), 4), np.float32)
            art = resize(crop, max(1, fw), max(1, fh))
            x0 = (canvas.shape[1] - art.shape[1]) // 2
            canvas[canvas.shape[0] - art.shape[0]:, x0:x0 + art.shape[1]] = art
            layout_piece(canvas, ph, rel + ".png", art_w=pw, normals_edge=3.0)
            continue
        ow, oh = FOREGROUND_BOX[rel]
        r = crop.shape[1] / float(crop.shape[0])
        art_h = max(2, int(round((ow * oh / r) ** 0.5)))
        art_w = max(2, int(round(art_h * r)))
        layout_piece(silhouette(crop), art_h, rel + ".png", art_w=art_w, normals_edge=3.0)


def depot2():
    """The depot's back wall (opaque, seamless, 205 art rows like the pixel wall) and its floor
    grating (a new terrain piece, 20 art rows like the paving)."""
    sheet = load("depot-hd-v1.webp")
    wall = seam(sheet[0:434].copy(), 60)
    wall[..., 3] = 255
    layout_piece(wall, 205, "depot.png", normals_edge=0)
    floor = seam(sheet[601:696].copy(), 60)
    k, w, h = layout_piece(floor, 20, "terrain/depot_floor.png", normals_edge=6.0)
    print("depot_floor", w, h)


def signs2():
    """The blank sign panels (nine-sliced by sign_skins.gd: 2-px repeat columns and rows in the
    plain middle) and the projector housing, stored upside down like the pixel one (the game
    draws it flipped, lens down)."""
    sheet = load("props2-hd-v1.webp")
    out = {}
    for name, box, art_h in (("sign_s", (171, 763, 457, 849), 18), ("sign_m", (552, 763, 951, 850), 22),
                             ("sign_l", (1051, 760, 1625, 850), 24)):
        crop = crop_box(sheet, box)
        ys, xs = np.nonzero(crop[..., 3] > 8)
        crop = crop[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
        k, w, h = layout_piece(crop, art_h, "buildings/%s.png" % name, normals_edge=3.0)
        out[name] = {"size": [w, h], "cols": [w // 2, w // 2 + 2], "rows": [h // 2, h // 2 + 2]}
    crop = crop_box(sheet, (984, 483, 1500, 644))
    lens_from_top = 625 - 483
    crop = crop[::-1].copy()
    k, w, h = layout_piece(crop, 36, "buildings/projector.png", normals_edge=4.0)
    out["projector"] = {"size": [w, h], "lens_y": round(lens_from_top / k, 1)}
    print(json.dumps(out))


if __name__ == "__main__":
    steps = [a for a in sys.argv[1:] if not a.startswith("--")]
    batch = ["terrain2", "props2", "objects2", "details2", "depot2", "signs2"] if "--batch2" in sys.argv \
        else ["terrain", "backgrounds", "props"]
    for step in batch:
        if not steps or step in steps:
            globals()[step]()

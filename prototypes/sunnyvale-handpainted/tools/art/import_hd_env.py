#!/usr/bin/env python3
"""Import the hand-painted HD environment sheets (C56, art-design/handpainted-style.md) into
assets/environment/hd/. Run from the project root:  python3 tools/art/import_hd_env.py

Two kinds of output:
1. Swap textures (the terrain strips and the two background layers): each is rebuilt at its
   pixel piece's exact layout (the pixel PNG's size times a scale k), so the skins keep slicing
   it in the pixel piece's art px (TerrainSkins' caps and seamless period, the backdrop's strip)
   and scripts/world/hd_skins.gd draws it in place of the pixel PNG at the same path under
   assets/environment/hd/. The walkway's top band, the wall's courses (its own lit coping row
   left out, four courses stretched to the pixel wall's repeat) and the skyline are blended
   across their seams so they tile.
2. Props (cut from the props sheet) with their own sizes and slices in props.json: a world scale
   per prop (matched to the pixel piece it replaces), the anchor column (the lamp's pole, not
   the middle of its arm), the lamp's head, pole and base rows and lens, the landmark's head and
   repeating shaft, the railing's bay. The lamp's warm lens is repainted cold white (the game's
   lamps are cold white light).
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


def terrain():
    a = load("walkway-hd-v1.webp")
    walk = seam(a[148:270], 40)
    swap(walk, "paving/paving.png", edge=8)
    # The wall: its coping row (rows 411-480, a lit top of its own) is left out; two courses
    # (480-604) tile vertically, four of them fill the pixel wall's repeat (rows 1..55).
    wall = seam(a[480:604], 40)
    pw, ph = pixel_size("paving/wall.png")
    k = wall.shape[1] / pw
    face = np.concatenate([wall, wall], 0)
    face = resize(face, int(round(pw * k)), int(round((ph - 1) * k)))
    top = face[:int(round(k))]                       # row 0 (the pixel piece's outline row)
    full = np.concatenate([top, face], 0)
    save(full, "paving/wall.png")
    save(normals(full, 10), "paving/wall_n.png")
    print("%-22s %4d x %3d  (k %.2f per art px)" % ("paving/wall.png", full.shape[1], full.shape[0], k))


def backgrounds():
    far = load("far-hd-v2.webp")
    far = seam(far, 60)
    far[..., 3] = 255
    swap(far, "far.png")
    campus = load("campus-hd-v1.webp")[:621]           # cut at the shared ground line (row 620)
    swap(campus, "campus.png")


PROPS = {
    # key: (prop_skins piece tex, the sheet point in it, world px per texel)
    "lamp_post": ((80, 600), 0.26),
    "bench": ((450, 268), 108.0 / 355),
    "planter": ((789, 281), 75.0 / 271),
    "hedge": ((1108, 277), 72.0 / 285),
    "railing": ((1502, 330), 0.273),
    "bollard": ((869, 784), 0.329),
    "intercom": ((979, 750), 0.323),
    "booth": ((600, 647), 0.433),
    "gate": ((1397, 730), 0.394),
    "landmark": ((294, 636), 0.49),
}


def props():
    sheet = load("props-hd-v1.webp")
    lab = components(sheet[..., 3])
    manifest = {}
    for key, (at, scale) in PROPS.items():
        cid = lab[at[1], at[0]]
        assert cid, key
        ys, xs = np.nonzero(lab == cid)
        y0, y1, x0, x1 = int(ys.min()), int(ys.max()) + 1, int(xs.min()), int(xs.max()) + 1
        crop = sheet[y0:y1, x0:x1].copy()
        crop[..., 3] *= (lab[y0:y1, x0:x1] == cid)
        entry = {"scale": round(scale, 5), "anchor_x": round(crop.shape[1] / 2.0, 1)}
        if key == "lamp_post":
            # The pole is columns 63-94 of the sheet; the head with its arm rows 367-409, the pole
            # 410-804 (repeats), the base below. The warm lens under the head turns cold white.
            entry["anchor_x"] = round(78.5 - x0, 1)
            entry["head"] = int(410 - y0)
            entry["pole"] = [int(410 - y0), int(805 - y0)]
            lens = (int(118 - x0), int(396 - y0), int(214 - x0), int(408 - y0))
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
            entry["units"] = [int(1292 - x0), int(1490 - x0)]  # left post .. middle post: one bay
        manifest[key] = entry
        save(crop, "props/%s.png" % key)
        save(normals(crop, max(4.0, 0.035 * min(crop.shape[:2]))), "props/%s_n.png" % key)
        print("%-10s %3d x %3d texels, %.1f x %.1f world px" % (key, crop.shape[1], crop.shape[0],
              crop.shape[1] * scale, crop.shape[0] * scale))
    with open(os.path.join(OUT, "props", "props.json"), "w") as f:
        json.dump(manifest, f, indent=1)


if __name__ == "__main__":
    terrain()
    backgrounds()
    props()

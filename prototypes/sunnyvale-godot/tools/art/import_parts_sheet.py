#!/usr/bin/env python3
"""Import a generated parts sheet (C35/C36) as a lit cutout rig.

A parts sheet is one image with every rig part painted flat and separate on a
transparent background (see the character's art brief, "Image prompt 4").
This tool finds each part, scales the whole sheet by one factor so the
character stands at its gameplay height, builds the skeleton from joint
anchors marked on the sheet (SHEETS below, in sheet pixels), and writes the
same files the painters do:
  assets/characters/lit/<name>/albedo.png, normal.png, spec.png, rig.json
Normal maps are made from each part's silhouette and painted detail. The
enemy's neon trim (its exact neon color on the sheet) becomes the emissive
mask, so the engine makes it glow.

A character ("human") stands on its feet and its scale comes from its height.
A machine is assembled instead: every part's pivot is placed on the chassis
(sheet pixels of the chassis), parts may be rotated or scaled to fit the
assembly, and the scale comes from its overall length. A sheet on a flat grey
background has the background flood-filled away from the corners. Run from
the project root:
  python3 tools/art/import_parts_sheet.py night_guard|patrol_rover [--preview DIR]
"""
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lit_rig_common import LIT_DIR, PROJECT, edt_inside, gblur, normal_to_rgb  # noqa: E402

REPO = os.path.normpath(os.path.join(PROJECT, "..", ".."))

# One entry per imported character. Anchors are sheet pixels. Each part is
# found by the component under `at`; `pivot` is its joint, and the named
# anchors place its children (the skeleton is read straight off the art).
SHEETS = {
    "night_guard": {
        "sheet": "concept-art/se01-night-guard/se01-night-guard-parts-v1.webp",
        "rig_name": "SE01 Night Guard",
        "height": 102.0,          # crown above the soles, world px
        "texture_scale": 4,
        "neon": (0xC6, 0xFF, 0x3D),
        "parts": {
            "head": {"at": (180, 250), "pivot": (165, 370)},
            "torso": {"at": (515, 320), "pivot": (520, 545), "neck": (540, 95), "shoulder": (410, 190)},
            "pelvis": {"at": (838, 430), "pivot": (838, 520), "waist": (842, 322)},
            "upper_arm": {"at": (1068, 270), "pivot": (1068, 140), "elbow": (1072, 410)},
            "forearm": {"at": (1255, 380), "pivot": (1250, 250), "wrist": (1266, 532)},
            "hand_grip": {"at": (143, 800), "pivot": (143, 705), "grip": (143, 820)},
            "hand_open": {"at": (392, 830), "pivot": (390, 705)},
            "thigh": {"at": (655, 820), "pivot": (655, 675), "knee": (650, 985)},
            "shin": {"at": (920, 820), "pivot": (920, 670), "ankle": (925, 990)},
            "foot": {"at": (1245, 900), "pivot": (1150, 830),
                     "soles": [(1088, 1012), (1250, 1016), (1398, 1004)]},
            "baton": {"at": (1380, 340), "pivot": (1380, 148), "tip": (1380, 598)},
        },
    },
    # A machine: `place` is where the part's pivot sits on the assembled
    # rover, in the chassis's sheet pixels; `rotate` (degrees, clockwise) and
    # `scale` fit a part to the chassis it was painted beside. The hatch lid
    # covers the side panel, which is repainted as the open battery bay.
    "patrol_rover": {
        "sheet": "concept-art/m01-patrol-rover/m01-patrol-rover-parts-v1.webp",
        "rig_name": "M01 Patrol Rover",
        "kind": "machine",
        "length": 92.0,           # rear of the chassis to the front of the bumper, world px
        "texture_scale": 4,
        "atlas_width": 512,
        "background": (127, 127, 127),
        "glow": [((250, 30, 208), 1.0),      # the magenta flank strip (C36 neon)
                 ((213, 141, 49), 1.0),      # the lightbar lenses and the sensor lens
                 ((54, 210, 196), 1.0)],     # the battery gauge
        "fill": [{"poly": [(166, 124), (463, 161), (434, 226), (139, 186)], "color": (20, 24, 30)}],
        "parts": {
            "chassis": {"at": (700, 250), "pivot": (676.5, 540), "place": (676.5, 540), "bottom": 600},
            "wheel": {"at": (1321, 700), "pivot": (1321.5, 811.5),
                      "places": [(318, 540), (1035, 540)]},
            "bumper": {"at": (1450, 450), "pivot": (1310, 434), "place": (1272, 484), "front": (1505, 434)},
            "sensor": {"at": (120, 760), "pivot": (165, 805), "place": (960, 277), "rotate": 14.5,
                       "lens": (290, 752), "glow_scale": 0.35},
            "lightbar": {"at": (380, 760), "pivot": (503, 790), "place": (360, 125), "lens": (542, 746)},
            "hatch": {"at": (900, 780), "pivot": (1048, 725), "place": (468, 158), "rotate": 7.6,
                      "scale": (1.0, 0.86)},
            "battery": {"at": (450, 850), "pivot": (547, 900), "place": (300, 176), "scale": (0.5, 0.5)},
        },
    },
}


def components(alpha):
    """Label 4-connected opaque regions; returns (labels, count)."""
    fg = alpha > 128
    h, w = fg.shape
    lab = np.zeros((h, w), np.int32)
    n = 0
    for y0 in range(h):
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
    return lab, n


def normal_map(rgba, edge_px):
    """Silhouette-rounded normals plus a little painted detail (as make_normal_maps.py)."""
    a = rgba[..., 3] / 255.0
    mask = a > 0.5
    d = edt_inside(mask)
    t = np.clip(d / edge_px, 0, 1)
    h = edge_px * np.sqrt(1.0 - (1.0 - t) ** 2)
    dmax = max(float(d.max()), 1.0)
    h += 0.35 * edge_px * np.sqrt(np.clip(d / dmax, 0, 1))
    luma = (rgba[..., 0] * 0.3 + rgba[..., 1] * 0.59 + rgba[..., 2] * 0.11) / 255.0
    h += 0.9 * edge_px * 0.25 * (luma - gblur(luma, 3.0)) * mask
    h = gblur(h * mask, 0.8)
    gy, gx = np.gradient(h)
    n = np.stack([-gx, -gy, np.ones_like(h)], -1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    rgb = normal_to_rgb(n)
    rgb[~mask] = [0.5, 0.5, 1.0]
    return rgb


def spec_map(rgba, glows):
    """R = specular strength, G = gloss, B = emissive (the neon trim and any
    lamps): `glows` is a list of ((r, g, b), strength)."""
    rgb = rgba[..., :3] / 255.0
    val = rgb.max(-1)
    sat = (rgb.max(-1) - rgb.min(-1)) / np.maximum(rgb.max(-1), 1e-4)
    out = np.zeros(rgba.shape[:2] + (3,), np.float32)
    out[...] = [0.08, 0.22, 0.0]                        # cloth
    dark = val < 0.22                                   # boots, belt, baton: leather and rubber
    out[dark] = [0.32, 0.55, 0.0]
    skin = (rgb[..., 0] > rgb[..., 2] + 0.12) & (sat > 0.2) & (val > 0.35)
    out[skin] = [0.14, 0.35, 0.0]
    steel = (sat < 0.12) & (val > 0.6)                  # studs, buckles, the pale grip
    out[steel] = [0.45, 0.7, 0.0]
    for color, strength in glows:
        nr, ng, nb = (c / 255.0 for c in color)
        dist = np.abs(rgb[..., 0] - nr) + np.abs(rgb[..., 1] - ng) + np.abs(rgb[..., 2] - nb)
        out[dist < 0.35] = [0.1, 0.3, strength]
    return out


def resize(arr, size):
    img = Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8))
    return np.asarray(img.resize(size, Image.LANCZOS), np.float32) / 255.0


def load_sheet(cfg):
    """The sheet as float RGBA (0-255), with a flat grey background (if any)
    flood-filled away from the corners and the `fill` repaints applied, and
    its opaque parts labelled."""
    img = Image.open(os.path.join(REPO, cfg["sheet"])).convert("RGBA")
    if "background" in cfg:
        from PIL import ImageDraw
        rgb = img.convert("RGB")
        key = (255, 0, 254)
        for xy in ((0, 0), (img.width - 1, 0), (0, img.height - 1), (img.width - 1, img.height - 1)):
            ImageDraw.floodfill(rgb, xy, key, thresh=22)
        flooded = np.all(np.asarray(rgb) == key, -1)
        # Enclosed background (inside a tow ring) is the exact grey too.
        grey = np.abs(np.asarray(img.convert("RGB"), np.int32) - np.array(cfg["background"])).sum(-1) < 12
        a = np.asarray(img).copy()
        a[flooded | grey, 3] = 0
        img = Image.fromarray(a)
    for f in cfg.get("fill", []):
        from PIL import ImageDraw
        d = ImageDraw.Draw(img)
        d.polygon(f["poly"], fill=tuple(f["color"]) + (255,))
        d.line(list(f["poly"]) + [f["poly"][0]], fill=(11, 13, 16, 255), width=4, joint="curve")
    sheet = np.asarray(img, np.float32)
    lab, _ = components(sheet[..., 3])
    return sheet, lab


def part_crop(sheet, lab, at):
    """The opaque component under `at`, cropped: (crop, x0, y0)."""
    cid = lab[at[1], at[0]]
    assert cid, "no part under %s" % (at,)
    ys, xs = np.nonzero(lab == cid)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    crop = sheet[y0:y1, x0:x1].copy()
    crop[..., 3] *= (lab[y0:y1, x0:x1] == cid)
    return crop, x0, y0


def fit_part(crop, pivot, rotate=0.0, scale=(1.0, 1.0)):
    """Rotates (degrees, clockwise on screen) and scales a crop about its pivot
    (crop pixels). Returns (crop, pivot, fwd), where fwd maps a crop point to
    the new crop."""
    th = np.radians(rotate)
    c, sn = np.cos(th), np.sin(th)
    sx, sy = scale
    A = np.array([[c * sx, -sn * sy], [sn * sx, c * sy]])           # forward: R @ S
    h, w = crop.shape[:2]
    corners = (np.array([[0, 0], [w, 0], [0, h], [w, h]], float) - pivot) @ A.T
    lo = np.floor(corners.min(0)) - 4
    hi = np.ceil(corners.max(0)) + 4
    size = (int(hi[0] - lo[0]), int(hi[1] - lo[1]))
    new_pivot = -lo
    M = np.linalg.inv(A)
    off = np.array(pivot) - M @ new_pivot
    coeffs = (M[0, 0], M[0, 1], off[0], M[1, 0], M[1, 1], off[1])
    pm = crop.copy()
    pm[..., :3] *= pm[..., 3:4] / 255.0
    chans = [np.asarray(Image.fromarray(pm[..., i]).transform(size, Image.AFFINE, coeffs, Image.BICUBIC))
             for i in range(4)]
    out = np.clip(np.stack(chans, -1), 0.0, 255.0)
    a = out[..., 3:4]
    out[..., :3] = np.where(a > 1e-3, out[..., :3] * 255.0 / np.maximum(a, 1e-3), 0.0)

    def fwd(pt):
        return (A @ (np.array(pt, float) - pivot)) + new_pivot
    return out.astype(np.float32), new_pivot, fwd


def cut(crop, pivot, k, glows):
    """A cropped part (float RGBA, straight alpha) at atlas resolution, with
    its normal and spec maps; `pivot` is in crop pixels."""
    size = (max(1, int(round(crop.shape[1] * k))), max(1, int(round(crop.shape[0] * k))))
    # Premultiplied downscale keeps the dark outline from bleeding into halos.
    pm = crop.copy()
    pm[..., :3] *= pm[..., 3:4] / 255.0
    small = resize(pm / 255.0, size)
    alpha = small[..., 3]
    rgb = np.where(alpha[..., None] > 1e-3, small[..., :3] / np.maximum(alpha[..., None], 1e-3), 0.0)
    # Normals and spec at twice the atlas size, then down.
    big = (size[0] * 2, size[1] * 2)
    pm2 = resize(pm / 255.0, big)
    a2 = pm2[..., 3]
    rgb2 = np.where(a2[..., None] > 1e-3, pm2[..., :3] / np.maximum(a2[..., None], 1e-3), 0.0)
    rgba2 = np.concatenate([rgb2, a2[..., None]], -1) * 255.0
    nrm = resize(normal_map(rgba2, edge_px=max(3.0, 0.09 * min(big))), size)
    v = nrm * 2.0 - 1.0
    v /= np.maximum(np.linalg.norm(v, axis=-1, keepdims=True), 1e-4)
    nrm = v * 0.5 + 0.5
    nrm[alpha < 0.5] = [0.5, 0.5, 1.0]
    spc = resize(spec_map(rgba2, glows), size)
    piv = [round(pivot[0] * k, 1), round(pivot[1] * k, 1)]
    return {"rgb": rgb, "alpha": alpha, "normal": nrm, "spec": spc, "pivot": piv}


def write_atlas(results, name, width):
    """Packs the parts into albedo/normal/spec atlases; returns the rects."""
    pad = 4
    order = sorted(results, key=lambda n: -results[n]["alpha"].shape[0])
    x = y = row_h = 0
    rects = {}
    for n in order:
        h, wd = results[n]["alpha"].shape
        if x + wd + pad > width:
            x, y, row_h = 0, y + row_h + pad, 0
        rects[n] = [x + pad, y + pad, wd, h]
        x += wd + pad
        row_h = max(row_h, h)
    height = y + row_h + 2 * pad
    height = 1 << (height - 1).bit_length()
    alb = np.zeros((height, width, 4), np.float32)
    nor = np.zeros((height, width, 4), np.float32)
    nor[...] = [0.5, 0.5, 1.0, 0.0]
    spe = np.zeros((height, width, 4), np.float32)
    for n, (rx, ry, wd, h) in rects.items():
        r = results[n]
        alb[ry:ry + h, rx:rx + wd, :3] = r["rgb"]
        alb[ry:ry + h, rx:rx + wd, 3] = r["alpha"]
        nor[ry:ry + h, rx:rx + wd, :3] = r["normal"]
        nor[ry:ry + h, rx:rx + wd, 3] = r["alpha"]
        spe[ry:ry + h, rx:rx + wd, :3] = r["spec"]
        spe[ry:ry + h, rx:rx + wd, 3] = r["alpha"]
    out_dir = os.path.join(LIT_DIR, name)
    os.makedirs(out_dir, exist_ok=True)
    for fname, arr in (("albedo.png", alb), ("normal.png", nor), ("spec.png", spe)):
        Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(out_dir, fname))
    print("wrote", out_dir, "atlas %dx%d" % (width, height))
    return rects, out_dir


def main():
    args = sys.argv[1:]
    if not args or args[0] not in SHEETS:
        raise SystemExit("usage: import_parts_sheet.py %s [--preview DIR]" % "|".join(SHEETS))
    name = args[0]
    cfg = SHEETS[name]
    preview = args[args.index("--preview") + 1] if "--preview" in args else None
    if cfg.get("kind") == "machine":
        data, out_dir = build_machine(name, cfg)
    else:
        data, out_dir = build_human(name, cfg)
    with open(os.path.join(out_dir, "rig.json"), "w") as f:
        json.dump(data, f, indent=1)
    if preview:
        write_preview(data, out_dir, preview, name)


def build_human(name, cfg):
    sheet, lab = load_sheet(cfg)
    P = cfg["parts"]

    # One scale for the whole sheet: soles to crown equals the gameplay height.
    def dy(a, b):
        return b[1] - a[1]
    head_top = min(y for y, _x in zip(*np.nonzero(lab == lab[P["head"]["at"][1], P["head"]["at"][0]])))
    sole_y = max(p[1] for p in P["foot"]["soles"])
    px_height = ((sole_y - P["foot"]["pivot"][1]) + dy(P["shin"]["pivot"], P["shin"]["ankle"])
                 + dy(P["thigh"]["pivot"], P["thigh"]["knee"]) + dy(P["pelvis"]["waist"], P["pelvis"]["pivot"])
                 + dy(P["torso"]["neck"], P["torso"]["pivot"]) + (P["head"]["pivot"][1] - head_top))
    s = cfg["height"] / px_height                       # world px per sheet px
    T = cfg["texture_scale"]
    k = s * T                                           # atlas texels per sheet px
    print("scale %.4f world px per sheet px (%.1f px sheet height)" % (s, px_height))

    def w(a, b):
        """World vector from sheet point a to sheet point b."""
        return [round((b[0] - a[0]) * s, 2), round((b[1] - a[1]) * s, 2)]

    # --- cut, scale and map every part ---
    results = {}
    for pname, pc in P.items():
        crop, x0, y0 = part_crop(sheet, lab, pc["at"])
        results[pname] = cut(crop, (pc["pivot"][0] - x0, pc["pivot"][1] - y0), k, [(cfg["neon"], 1.0)])
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 256))
    # --- skeleton, read off the anchors ---
    t, pe, ua, fa = P["torso"], P["pelvis"], P["upper_arm"], P["forearm"]
    hip_h = ((sole_y - P["foot"]["pivot"][1]) + dy(P["shin"]["pivot"], P["shin"]["ankle"])
             + dy(P["thigh"]["pivot"], P["thigh"]["knee"])) * s
    torso_pos = w(pe["pivot"], pe["waist"])
    neck = w(t["pivot"], t["neck"])
    shoulder = w(t["pivot"], t["shoulder"])
    elbow = w(ua["pivot"], ua["elbow"])
    wrist = w(fa["pivot"], fa["wrist"])
    grip = w(P["hand_grip"]["pivot"], P["hand_grip"]["grip"])
    knee = w(P["thigh"]["pivot"], P["thigh"]["knee"])
    ankle = w(P["shin"]["pivot"], P["shin"]["ankle"])
    tip = w(P["baton"]["pivot"], P["baton"]["tip"])
    soles = [w(P["foot"]["pivot"], p) for p in P["foot"]["soles"]]
    world_w = {n: results[n]["alpha"].shape[1] / T for n in results}

    def cap(b, r, a=(0.0, 0.0)):
        return {"type": "capsule", "a": list(a), "b": list(b), "r": round(r, 2)}

    head_c = w(P["head"]["pivot"], P["head"]["at"])
    joints = [
        ("pelvis", "pelvis", "", [0.0, -round(hip_h, 2)], 3, False, cap([4.0, -4.0], 6.0, (-4.0, -4.0)), 12.0, None, -90),
        ("torso", "torso", "pelvis", torso_pos, 5, False, cap([neck[0] * 0.5, neck[1] + 5.0], 0.34 * world_w["torso"], (0.0, -2.0)), 25.0, [-35, 75], -90),
        ("head", "head", "torso", neck, 6, False, {"type": "circle", "c": head_c, "r": round(0.4 * world_w["head"], 2)}, 5.0, [-40, 45], -90),
        ("far_upper_arm", "upper_arm", "torso", shoulder, 1, True, cap(elbow, 0.32 * world_w["upper_arm"]), 2.5, [-175, 70], 90),
        ("far_forearm", "forearm", "far_upper_arm", elbow, 1, True, cap(wrist, 0.3 * world_w["forearm"]), 1.8, [-145, 0], 90),
        ("far_hand", "hand_open", "far_forearm", wrist, 1, True, {"type": "circle", "c": [0.0, round(grip[1], 2)], "r": 2.8}, 0.7, [-60, 60], 90),
        ("far_thigh", "thigh", "pelvis", [0.0, 0.0], 2, True, cap(knee, 0.4 * world_w["thigh"]), 8.0, [-110, 40], 90),
        ("far_shin", "shin", "far_thigh", knee, 2, True, cap(ankle, 0.36 * world_w["shin"]), 4.0, [0, 150], 90),
        ("far_foot", "foot", "far_shin", ankle, 2, True, cap([soles[2][0] - 2.0, soles[1][1] - 2.4], 2.3, (soles[0][0] + 2.0, soles[1][1] - 2.4)), 1.5, [-40, 35], 0),
        ("near_thigh", "thigh", "pelvis", [0.0, 0.0], 4, False, cap(knee, 0.4 * world_w["thigh"]), 8.0, [-110, 40], 90),
        ("near_shin", "shin", "near_thigh", knee, 4, False, cap(ankle, 0.36 * world_w["shin"]), 4.0, [0, 150], 90),
        ("near_foot", "foot", "near_shin", ankle, 4, False, cap([soles[2][0] - 2.0, soles[1][1] - 2.4], 2.3, (soles[0][0] + 2.0, soles[1][1] - 2.4)), 1.5, [-40, 35], 0),
        ("near_upper_arm", "upper_arm", "torso", shoulder, 7, False, cap(elbow, 0.32 * world_w["upper_arm"]), 2.5, [-175, 70], 90),
        ("near_forearm", "forearm", "near_upper_arm", elbow, 8, False, cap(wrist, 0.3 * world_w["forearm"]), 1.8, [-145, 0], 90),
        ("near_hand", "hand_grip", "near_forearm", wrist, 10, False, {"type": "circle", "c": [0.0, round(grip[1], 2)], "r": 2.8}, 0.7, [-60, 60], 90),
        ("baton", "baton", "near_hand", grip, 9, False, cap(tip, 1.9, (0.0, -3.0)), 0.6, None, 90),
    ]
    data = {
        "name": cfg["rig_name"], "kind": "human", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": True, "sole_points": soles,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": j[0], "part": j[1], "parent": j[2], "pos": j[3], "z": j[4], "far": j[5],
                    "collider": j[6], "mass": j[7], "limit": j[8], "rest_dir": j[9]} for j in joints],
        "sockets": {"tell": {"joint": "baton", "pos": tip}},
        "source": cfg["sheet"],
    }
    return data, out_dir


def build_machine(name, cfg):
    """A rigid machine: every part hangs off the chassis at its `place`."""
    sheet, lab = load_sheet(cfg)
    P = cfg["parts"]
    T = cfg["texture_scale"]
    fitted = {}
    for pname, pc in P.items():
        crop, x0, y0 = part_crop(sheet, lab, pc["at"])
        pivot = np.array([pc["pivot"][0] - x0, pc["pivot"][1] - y0], float)
        crop, pivot, fwd = fit_part(crop, pivot, pc.get("rotate", 0.0), pc.get("scale", (1.0, 1.0)))
        fitted[pname] = (crop, pivot, (lambda f, ox, oy: lambda pt: f((pt[0] - ox, pt[1] - oy)))(fwd, x0, y0))

    # The scale: from the rear of the chassis to the front of the placed bumper.
    ch, bu = P["chassis"], P["bumper"]
    ch_crop, ch_piv, _ = fitted["chassis"]
    rear = ch["place"][0] - ch_piv[0]
    bu_crop, bu_piv, _ = fitted["bumper"]
    front = bu["place"][0] + (bu_crop.shape[1] - bu_piv[0])
    s = cfg["length"] / (front - rear)
    k = s * T
    print("scale %.4f world px per sheet px (%.0f px sheet length)" % (s, front - rear))

    results = {}
    for pname, (crop, pivot, _f) in fitted.items():
        glows = [(c, b * P[pname].get("glow_scale", 1.0)) for c, b in cfg["glow"]]
        results[pname] = cut(crop, pivot, k, glows)
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 256))

    # The chassis pivot sits at axle height, centred so the machine's length
    # is centred on its origin (the collision box mirrors around it).
    wheel = P["wheel"]
    radius = fitted["wheel"][0].shape[0] * 0.5 - 4.0
    centre = 0.5 * (rear + front)
    chassis_pos = [round((ch["place"][0] - centre) * s, 2), round(-radius * s, 2)]

    def on_chassis(pt):
        return [round((pt[0] - ch["place"][0]) * s, 2), round((pt[1] - ch["place"][1]) * s, 2)]

    def local(pname, pt):
        """World offset of a sheet point of a part from that part's pivot."""
        crop, pivot, f = fitted[pname]
        q = f(pt)
        return [round((q[0] - pivot[0]) * s, 2), round((q[1] - pivot[1]) * s, 2)]

    def collider(pname):
        a = results[pname]["alpha"] > 0.5
        ys, xs = np.nonzero(a)
        px, py = results[pname]["pivot"]
        x0, x1 = (xs.min() - px) / T, (xs.max() + 1 - px) / T
        y0, y1 = (ys.min() - py) / T, (ys.max() + 1 - py) / T
        cx, cy, hw, hh = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
        if pname == "wheel":
            return {"type": "circle", "c": [round(cx, 2), round(cy, 2)], "r": round(0.95 * min(hw, hh), 2)}
        if hw >= hh:
            r = 0.85 * hh
            return {"type": "capsule", "a": [round(cx - hw + r, 2), round(cy, 2)],
                    "b": [round(cx + hw - r, 2), round(cy, 2)], "r": round(r, 2)}
        r = 0.85 * hw
        return {"type": "capsule", "a": [round(cx, 2), round(cy - hh + r, 2)],
                "b": [round(cx, 2), round(cy + hh - r, 2)], "r": round(r, 2)}

    rear_w, front_w = wheel["places"]
    # (name, part, parent, pos, z, far, mass, role). The wheels sit behind
    # the chassis, whose arches overlap them; the battery sits in its bay
    # under the hatch lid, so it shows only when the lid swings open.
    joints = [
        ("chassis", "chassis", "", chassis_pos, 3, False, 45.0, "chassis"),
        ("wheel_far_rear", "wheel", "chassis", on_chassis(rear_w), 1, True, 5.0, "wheel_far_rear"),
        ("wheel_far_front", "wheel", "chassis", on_chassis(front_w), 1, True, 5.0, "wheel_far_front"),
        ("wheel_near_rear", "wheel", "chassis", on_chassis(rear_w), 2, False, 5.0, "wheel_near_rear"),
        ("wheel_near_front", "wheel", "chassis", on_chassis(front_w), 2, False, 5.0, "wheel_near_front"),
        ("lightbar", "lightbar", "chassis", on_chassis(P["lightbar"]["place"]), 2, False, 2.5, "lightbar"),
        ("battery", "battery", "chassis", on_chassis(P["battery"]["place"]), 4, False, 9.0, "battery"),
        ("hatch", "hatch", "chassis", on_chassis(P["hatch"]["place"]), 5, False, 3.0, "hatch"),
        ("sensor", "sensor", "chassis", on_chassis(P["sensor"]["place"]), 6, False, 4.0, "dome"),
        ("bumper", "bumper", "chassis", on_chassis(P["bumper"]["place"]), 7, False, 7.0, "bumper"),
    ]
    bat = fitted["battery"]
    data = {
        "name": cfg["rig_name"], "kind": "machine", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": False,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": j[0], "part": j[1], "parent": j[2], "pos": j[3], "z": j[4], "far": j[5],
                    "collider": collider(j[1]), "mass": j[6], "limit": None, "rest_dir": 0, "role": j[7]}
                   for j in joints],
        "sockets": {
            "lens_light": {"joint": "sensor", "pos": local("sensor", P["sensor"]["lens"])},
            "tell": {"joint": "lightbar", "pos": local("lightbar", P["lightbar"]["lens"])},
            "core": {"joint": "battery", "pos": local("battery", P["battery"]["pivot"])},
            "spark_bumper": {"joint": "bumper", "pos": local("bumper", P["bumper"]["front"])},
            "spark_hatch": {"joint": "hatch", "pos": [round(-0.5 * fitted["hatch"][0].shape[1] * s, 2), 0.0]},
            "spark_dome": {"joint": "sensor", "pos": [0.0, round(-0.5 * fitted["sensor"][0].shape[0] * s, 2)]},
            "oil_drip": {"joint": "chassis", "pos": [0.0, round((ch["bottom"] - ch["place"][1]) * s, 2)]},
        },
        "source": cfg["sheet"],
    }
    print("battery %dx%d px world" % (bat[0].shape[1] * s, bat[0].shape[0] * s))
    return data, out_dir


def write_preview(data, out_dir, preview_dir, name):
    """The assembled rest pose at atlas resolution, light and dark, for a look."""
    T = data["texture_scale"]
    alb = Image.open(os.path.join(out_dir, "albedo.png")).convert("RGBA")
    J = {j["name"]: j for j in data["joints"]}

    def world(j):
        p = np.array(j["pos"], float)
        while j["parent"]:
            j = J[j["parent"]]
            p += np.array(j["pos"], float)
        return p
    W, H = 160 * T, 140 * T
    origin = np.array([W / 2, H - 20 * T])
    canvas = Image.new("RGBA", (W, H), (40, 46, 56, 255))
    for j in sorted(data["joints"], key=lambda j: j["z"]):
        rx, ry, rw, rh = data["parts"][j["part"]]["rect"]
        px, py = data["parts"][j["part"]]["pivot"]
        img = alb.crop((rx, ry, rx + rw, ry + rh))
        if j["far"]:
            img = Image.fromarray((np.asarray(img, np.float32) * [0.7, 0.7, 0.7, 1]).astype(np.uint8))
        at = origin + world(j) * T - [px, py]
        canvas.alpha_composite(img, (int(round(at[0])), int(round(at[1]))))
    from PIL import ImageDraw
    d = ImageDraw.Draw(canvas)
    d.line([(0, origin[1]), (W, origin[1])], fill=(255, 255, 0, 255))
    for j in data["joints"]:                            # joint pivots
        x, y = origin + world(j) * T
        d.ellipse([x - 3, y - 3, x + 3, y + 3], outline=(255, 60, 60, 255))
    os.makedirs(preview_dir, exist_ok=True)
    out = os.path.join(preview_dir, name + "_assembled.png")
    canvas.save(out)
    print("preview", out)


if __name__ == "__main__":
    main()

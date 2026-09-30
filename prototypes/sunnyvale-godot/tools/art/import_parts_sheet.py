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
mask, so the engine makes it glow. Run from the project root:
  python3 tools/art/import_parts_sheet.py night_guard [--preview DIR]
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


def spec_map(rgba, neon):
    """R = specular strength, G = gloss, B = emissive (the neon trim)."""
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
    nr, ng, nb = (c / 255.0 for c in neon)
    dist = np.abs(rgb[..., 0] - nr) + np.abs(rgb[..., 1] - ng) + np.abs(rgb[..., 2] - nb)
    out[dist < 0.35] = [0.1, 0.3, 1.0]
    return out


def resize(arr, size):
    img = Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8))
    return np.asarray(img.resize(size, Image.LANCZOS), np.float32) / 255.0


def main():
    args = sys.argv[1:]
    if not args or args[0] not in SHEETS:
        raise SystemExit("usage: import_parts_sheet.py %s [--preview DIR]" % "|".join(SHEETS))
    name = args[0]
    cfg = SHEETS[name]
    sheet = np.asarray(Image.open(os.path.join(REPO, cfg["sheet"])).convert("RGBA"), np.float32)
    lab, _ = components(sheet[..., 3])
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
        cid = lab[pc["at"][1], pc["at"][0]]
        assert cid, "no part under %s for %s" % (pc["at"], pname)
        ys, xs = np.nonzero(lab == cid)
        y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
        crop = sheet[y0:y1, x0:x1].copy()
        crop[..., 3] *= (lab[y0:y1, x0:x1] == cid)
        size = (max(1, int(round((x1 - x0) * k))), max(1, int(round((y1 - y0) * k))))
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
        spc = resize(spec_map(rgba2, cfg["neon"]), size)
        pivot = [round((pc["pivot"][0] - x0) * k, 1), round((pc["pivot"][1] - y0) * k, 1)]
        results[pname] = {"rgb": rgb, "alpha": alpha, "normal": nrm, "spec": spc, "pivot": pivot}

    # --- atlas ---
    pad = 4
    width = 256
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
    with open(os.path.join(out_dir, "rig.json"), "w") as f:
        json.dump(data, f, indent=1)
    print("wrote", out_dir, "atlas %dx%d" % (width, height), "tell tip", tip)


if __name__ == "__main__":
    main()

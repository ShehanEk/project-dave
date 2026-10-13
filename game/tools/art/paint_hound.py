#!/usr/bin/env python3
"""Paint the K01 Hound lit-cutout rig (placeholder, M4): a four-legged rig, procedurally.

Arcadia Security's cyborg guard dog (art-design/hounds/k01-hound.md): a lean,
deep-chested shepherd-type dog held low and forward, black saddle over a tan coat, a
slim smoked visor band over the eyes with a small round sensor (the dim amber point
while it hunts: emissive), a brushed-steel jaw guard with a thin slot light along the
teeth line (the tell: emissive, tinted amber then red by the engine), a gunmetal
collar with the K9 control module and a status light (teal while it waits, amber
while it hunts: emissive), a navy harness with a pale band and a rigid grab handle,
a white composite shoulder plate and five linked spine plates with a thin neon strip
(emissive; the Hound script tints it lime with a handler, magenta when Adam drives
it, C60), upright ears and a natural tail carried low. No tongue, no leash.

The rig (17 joints) uses the part list the K01 parts sheets will use (M4
coordination), so the painted sheet drops in through import_parts_sheet.py without
renaming code: `torso` (the root: the whole body with harness, plates and the spine
strip), `neck` (collar and module), `head` (skull, upper muzzle, ears, visor band),
`jaw` (the lower jaw, its guard and hinge capsule; the tell is on it), `tail`, and four
legs of three parts each, near and far sharing one painted part (the far drawn darker
by the rig): <near|far>_front_upper_leg (shoulder to elbow), _front_lower_leg (to the
wrist), _front_paw, <near|far>_hind_upper_leg (hip to hock), _hind_lower_leg, _hind_paw.
In a ragdoll the jaw and the paws ride on their parents ("lock"), like a human's
hands and feet. The ground lock keeps the lowest of the four paws on the floor
(rig.json "feet"). Legs at rotation 0 stand naturally; a positive rotation swings a
lower end backward (Godot 2D, clockwise).

Rig space: world px, origin at the bottom centre on the floor, facing right. About
0.70 m at the shoulder (38 px) and 1.30 m nose to rump (72 px), plus the tail.

Outputs (assets/characters/lit/hound/): albedo.png, normal.png, spec.png and
rig.json. Placeholder until the K01 parts sheet exists; replace the folder (same joint
names, the `tell` socket on the jaw, the same emissive parts) to swap the art in.

Run from the project root:  python3 tools/art/paint_hound.py [--preview DIR]
"""
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, ellipse_pts, hexc, rect_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "hound")
SEED = 20261015

BLACK = hexc("#24211F")
TAN = hexc("#A9784A")
TAN_DARK = hexc("#8A5F38")
GUNMETAL = hexc("#5A6B80")
VISOR = hexc("#14181E")
PLATE = hexc("#E2E7EC")
HARNESS = hexc("#2A3B5C")
BAND = hexc("#D3DAE0")
EMBLEM = hexc("#E9EDF0")
LIME = hexc("#C6FF3D")
NOSE = hexc("#161312")
PAD = hexc("#1C1918")
TEAL = hexc("#3FE0D0")
SLOT = hexc("#30363D")
STEEL = hexc("#8A95A3")
LENS = hexc("#3A2A16")

LOWER_LEN = 11.2     # elbow or hock to the wrist (the paw's pivot)
PAW_Y = 3.0          # every paw's sole line, in its own frame
SOLE_POINTS = [(-1.0, PAW_Y), (4.4, PAW_Y)]


def paint_torso():
    """Torso-local: the pivot is at rig (0, -29), the hip line."""
    p = Part("torso", -31.0, -17.4, 26.4, 8.0)
    torso = [(-27.0, -8.2), (-12.0, -10.6), (4.0, -11.6), (13.0, -12.0), (21.0, -7.6), (25.0, -1.4), (22.6, 5.8),
             (12.0, 6.6), (2.0, 4.6), (-8.0, 2.6), (-18.0, 3.6), (-26.4, 3.2), (-30.2, -2.0)]
    m = p.body(torso, TAN, "cloth", radius=6.0, dome=0.3)
    # the black saddle over the back
    saddle = [(-31.0, -0.6), (-18.0, -1.8), (-6.0, -3.4), (8.0, -5.2), (16.0, -6.6), (22.0, -8.6), (22.0, -14.0), (-31.0, -14.0)]
    p.fill(p.mask(lr.catmull(saddle, True, 6)) & m, BLACK, "cloth")
    p.tint([(14.0, 0.0), (24.0, -2.0), (23.0, 5.0), (13.0, 6.0)], TAN_DARK, 0.25, 1.0)
    # fur flow: a few soft ridges along the flank
    for y in (-4.0, -1.0, 2.0):
        p.ridge([(-26.0, y - 1.0), (-10.0, y), (6.0, y + 0.6)], 0.12, 0.6)
    # the navy harness band round the chest, a pale reflective band, the emblem patch
    harness = [(5.0, -12.6), (13.0, -12.8), (15.2, 6.4), (7.0, 5.6)]
    p.patch(harness, HARNESS, "nylon", 0.35, 0.2, smooth=False)
    p.patch([(8.0, -12.4), (10.2, -12.5), (12.2, 6.2), (10.0, 6.0)], BAND, "stripe", 0.12, 0.1, smooth=False)
    # the white composite shoulder plate, bolted, with the small emblem patch
    plate = [(12.6, -11.0), (21.0, -7.4), (22.6, -1.6), (17.6, 1.6), (13.4, -1.0)]
    p.patch(plate, PLATE, "shell", 0.9, 0.3)
    p.seam(plate, 0.0, 0.14, 0.4, closed=True)
    p.patch(rect_pts(16.4, -5.6, 18.6, -3.6, 0.4), EMBLEM, "card", 0.12, 0.08, smooth=False)
    for bx, by in ((14.6, -8.6), (20.4, -2.2)):
        p.dot(bx, by, 0.45, STEEL, "steel", 0.2)
    # the grab handle across the shoulders (a rigid loop) and its cut-off leash ring
    handle = p.stroke([(6.4, -11.8), (7.4, -16.0), (12.4, -16.0), (13.4, -12.0)], 0.9)
    p.fill(handle, HARNESS, "nylon")
    p.sil |= handle
    p.lift(handle, 0.8, 0.2)
    ring = p.stroke(ellipse_pts(10.0, -16.6, 0.9, 0.9, 0, 12) + [ellipse_pts(10.0, -16.6, 0.9, 0.9, 0, 12)[0]], 0.35)
    p.fill(ring, STEEL, "steel")
    p.sil |= ring
    # five linked spine plates along the back, each with the thin neon strip on top
    for k in range(5):
        x0 = -22.0 + k * 6.0
        top = -11.2 + 0.0 * k
        if k >= 3:
            top -= 0.6
        pl = [(x0, top + 2.4), (x0 + 0.6, top - 1.2), (x0 + 5.4, top - 1.6), (x0 + 6.0, top + 2.0)]
        p.shell(pl, PLATE, "shell", bevel=0.7, crown=0.2, smooth=False)
        p.seam(pl, 0.0, 0.12, 0.35, closed=True, smooth=False)
        strip = [(x0 + 0.8, top - 1.0), (x0 + 5.2, top - 1.4), (x0 + 5.2, top - 0.6), (x0 + 0.8, top - 0.2)]
        p.patch(strip, LIME, "stripe", 0.1, 0.06, smooth=False, emissive=1.0)
    return p


def paint_neck():
    """Neck-local: the pivot is at the base of the neck on the chest."""
    p = Part("neck", -7.0, -12.4, 11.6, 9.4)
    neck = [(-6.0, 4.6), (2.0, 8.0), (8.6, 5.2), (10.4, -1.0), (9.0, -9.0), (2.4, -11.4), (-3.8, -7.6), (-6.4, -1.4)]
    m = p.body(neck, TAN, "cloth", radius=4.0, dome=0.3)
    p.fill(p.mask(lr.catmull([(-7.0, 5.0), (-1.0, 0.0), (3.0, -6.0), (4.0, -12.4), (-7.0, -12.4)], True, 6)) & m, BLACK, "cloth")
    # the gunmetal collar band with the K9 module at the throat and its status light
    band = [(-6.4, 0.4), (8.0, 3.0), (8.8, 6.0), (-5.6, 3.8)]
    p.patch(band, GUNMETAL, "metal", 0.5, 0.15, smooth=False)
    p.seam([(-6.0, 0.6), (8.2, 3.2)], 0.1, 0.12, 0.4, smooth=False)
    mod = p.patch(rect_pts(6.6, 2.2, 10.6, 6.6, 0.8), GUNMETAL, "metal", 0.7, 0.15, smooth=False, clip=False)
    p.sil |= mod
    p.dot(8.6, 4.4, 0.75, TEAL, "glass", 0.15, emissive=1.0)
    return p


def paint_head():
    """Head-local: the pivot is at the top of the neck (the head's base)."""
    p = Part("head", -6.4, -15.0, 20.4, 5.2)
    # the far ear (a flat darker colour), behind the head
    far_ear = [(-0.6, -5.4), (1.4, -14.0), (3.6, -6.0)]
    p.shell(far_ear, BLACK * 0.8, "cloth", bevel=0.8, crown=0.2, smooth=False)
    head = [(-5.6, 1.6), (-5.4, -2.6), (-2.6, -6.4), (3.0, -7.0), (6.4, -4.8), (12.0, -3.4), (17.0, -2.6),
            (19.6, -0.6), (18.4, 1.8), (9.0, 2.8), (-0.8, 4.2)]
    m = p.body(head, TAN, "cloth", radius=3.6, dome=0.35)
    # the black muzzle top and crown (a shepherd's mask)
    p.fill(p.mask(lr.catmull([(-6.0, -1.4), (2.0, -4.0), (8.0, -3.6), (19.6, -2.6), (19.6, -8.0), (-6.0, -8.0)], True, 6)) & m,
           BLACK, "cloth")
    near_ear = [(-3.6, -5.0), (-2.6, -14.4), (1.4, -6.2)]
    p.shell(near_ear, BLACK, "cloth", bevel=0.8, crown=0.25, smooth=False)
    p.tint([(-2.8, -6.0), (-2.4, -12.0), (0.2, -6.6)], TAN_DARK, 0.5, 0.4)
    # the dark nose
    p.patch(ellipse_pts(18.6, -0.9, 1.3, 1.1, 0, 16), NOSE, "eye", 0.3, 0.1, smooth=False)
    # the smoked visor band over the eye with its strap and the round sensor (emissive)
    visor = [(1.6, -5.6), (9.6, -4.8), (9.8, -2.0), (1.8, -2.6)]
    p.patch(visor, VISOR, "smoked", 0.5, 0.15, smooth=False)
    p.seam([(-4.6, -3.6), (1.6, -4.0)], 0.1, 0.5, 0.6, smooth=False)
    p.dot(5.6, -3.7, 0.8, LENS, "glass", 0.15, emissive=1.0)
    return p


def paint_jaw():
    """Jaw-local: the pivot is the hinge (the servo capsule)."""
    p = Part("jaw", -2.4, -2.0, 15.6, 4.6)
    jaw = [(-1.6, -0.8), (13.8, -0.4), (14.6, 0.8), (13.0, 2.8), (2.4, 3.8), (-1.6, 2.4)]
    p.shell(jaw, GUNMETAL, "metal", bevel=0.8, crown=0.2, smooth=True)
    # the slot light along the teeth line (dark paint: the engine lights the tell here)
    p.patch(rect_pts(2.6, -0.5, 13.4, 0.5, 0.3), SLOT, "glass", -0.1, 0.08, smooth=False, emissive=1.0)
    for x in (5.0, 8.4, 11.6):
        p.seam([(x, 1.2), (x - 0.4, 3.2)], 0.1, 0.12, 0.35, smooth=False)
    p.dot(0.0, 0.8, 1.5, STEEL, "steel", 0.4)
    return p


def _leg_lower(name, lean):
    p = Part(name, -2.4, -1.6, 3.6, LOWER_LEN + 0.8)
    leg = [(-1.8, -1.2), (1.8, -1.2), (1.4 + lean, LOWER_LEN - 2.0), (1.6 + lean, LOWER_LEN + 0.6),
           (-1.4 + lean, LOWER_LEN + 0.6), (-1.6 + lean * 0.5, LOWER_LEN - 3.0)]
    p.body(leg, TAN, "cloth", radius=1.6, dome=0.25)
    return p


def paint_paw(name="paw"):
    """Paw-local: the pivot is the wrist (or the hock's foot joint); the sole at PAW_Y."""
    p = Part(name, -2.2, -1.2, 5.8, PAW_Y + 0.4)
    paw = [(-1.6, -0.8), (1.6, -0.8), (2.4, 0.6), (4.6, 1.2), (5.2, 2.2), (4.4, PAW_Y), (-1.4, PAW_Y), (-1.9, 1.4)]
    p.body(paw, TAN, "cloth", radius=1.2, dome=0.25)
    p.patch([(-1.4, PAW_Y - 0.8), (4.6, PAW_Y - 0.8), (4.4, PAW_Y), (-1.4, PAW_Y)], PAD, "rubber", -0.05, 0.1, smooth=False)
    for x in (3.0, 4.0, 4.9):
        p.seam([(x, 1.4), (x + 0.3, 2.4)], 0.08, 0.14, 0.6, smooth=False)
    return p


def paint_front_upper_leg():
    p = Part("front_upper_leg", -4.6, -2.6, 4.6, 14.4)
    leg = [(-4.0, -2.0), (4.0, -2.2), (3.6, 5.0), (2.6, 13.6), (-1.8, 13.6), (-3.0, 5.0)]
    p.body(leg, TAN, "cloth", radius=2.6, dome=0.3)
    p.tint([(-4.0, -2.0), (4.0, -2.2), (3.0, 3.0), (-3.0, 3.0)], BLACK, 0.55, 0.8)
    return p


def paint_front_lower_leg():
    return _leg_lower("front_lower_leg", 0.4)


def paint_hind_upper_leg():
    p = Part("hind_upper_leg", -9.0, -3.8, 6.0, 16.2)
    leg = [(-6.6, -3.2), (5.2, -3.0), (4.2, 5.4), (-0.6, 11.6), (-3.0, 15.6), (-5.6, 15.2), (-6.4, 12.0), (-8.4, 4.0)]
    m = p.body(leg, TAN, "cloth", radius=3.4, dome=0.3)
    p.fill(p.mask(lr.catmull([(-9.0, -4.0), (6.0, -4.0), (3.0, 2.0), (-8.0, 5.0)], True, 6)) & m, BLACK, "cloth")
    p.ridge([(-6.0, 2.0), (-3.0, 8.0), (-3.6, 13.0)], 0.12, 0.6)
    return p


def paint_hind_lower_leg():
    return _leg_lower("hind_lower_leg", 0.8)


def paint_tail():
    p = Part("tail", -22.4, -3.4, 1.2, 11.6)
    tail = [(0.6, -2.4), (-6.0, 0.2), (-14.0, 4.6), (-20.6, 9.0), (-21.8, 10.4), (-19.6, 10.8), (-12.0, 8.6), (-5.0, 5.2), (0.6, 2.6)]
    m = p.body(tail, BLACK, "cloth", radius=2.0, dome=0.3)
    p.fill(p.mask(lr.catmull([(-2.0, 3.0), (-12.0, 8.6), (-20.0, 11.2), (-21.0, 12.0), (-2.0, 12.0)], True, 6)) & m,
           TAN_DARK, "cloth")
    p.ridge([(-1.0, 0.0), (-10.0, 4.0), (-19.0, 9.2)], 0.15, 0.5)
    return p


def cap(ax, ay, bx, by, r):
    return {"type": "capsule", "a": [ax, ay], "b": [bx, by], "r": r}


def circ(cx, cy, r):
    return {"type": "circle", "c": [cx, cy], "r": r}


BODY_Y = -29.0
PAW_COL = cap(-0.6, 1.6, 3.6, 1.6, 1.4)


def _leg(side, far, z):
    """One leg's three joints: [(front|hind) upper, lower, paw] on the given side."""
    out = []
    zs = z
    for limb, hip, upper_len, upper_col, ulim, llim in (
            ("front", (15.4 if not far else 12.6, 2.0), (0.4, 12.8), cap(0.0, 0.0, 0.4, 11.6, 2.6), [-80, 60], [-15, 120]),
            ("hind", (-17.6 if not far else -21.0, 0.0), (-4.2, 15.0), cap(-1.0, 1.0, -4.0, 13.0, 3.0), [-70, 70], [-110, 20])):
        u = "%s_%s_upper_leg" % (side, limb)
        l = "%s_%s_lower_leg" % (side, limb)
        w = "%s_%s_paw" % (side, limb)
        lean = 0.4 if limb == "front" else 0.8
        out.append((u, limb + "_upper_leg", "torso", hip, zs, far, upper_col, 2.2, ulim, u, 90))
        out.append((l, limb + "_lower_leg", u, upper_len, zs, far, cap(0.0, 0.0, lean, LOWER_LEN, 1.8), 1.0, llim, l, 90))
        out.append((w, limb + "_paw", l, (lean, LOWER_LEN), zs, far, PAW_COL, 0.4, [-40, 40], w, 0))
    return out


RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit(deg), role, rest_dir
    ("torso", "torso", "", (0.0, BODY_Y), 4, False, cap(-22.0, -3.0, 18.0, -3.0, 8.0), 20.0, None, "torso", 0),
] + _leg("far", True, 1) + [
    ("tail", "tail", "torso", (-29.0, -5.0), 2, False, cap(-2.0, 1.0, -18.0, 9.0, 1.8), 0.8, [-60, 60], "tail", 150),
    ("neck", "neck", "torso", (19.0, -7.0), 5, False, cap(0.0, 2.0, 4.0, -7.0, 4.4), 3.0, [-50, 40], "neck", -70),
    ("head", "head", "neck", (4.6, -9.4), 7, False, cap(-2.0, -1.0, 15.0, -1.0, 3.6), 3.0, [-40, 40], "head", 0),
    ("jaw", "jaw", "head", (2.6, 2.6), 6, False, cap(1.0, 1.2, 12.0, 1.2, 1.6), 0.6, [0, 30], "jaw", 0),
] + _leg("near", False, 8)
# The near front leg in front of the near hind leg.
RIG = [(r[:4] + (9,) + r[5:]) if r[0].startswith("near_front") else r for r in RIG]
FEET = ["near_front_paw", "far_front_paw", "near_hind_paw", "far_hind_paw"]
LOCKED = ["jaw", "near_front_paw", "far_front_paw", "near_hind_paw", "far_hind_paw"]
SOCKETS = {
    "tell": ("jaw", (8.0, 0.0)),            # the jaw guard's slot light: the tell glow
    "visor_light": ("head", (5.6, -3.7)),  # the small amber point while it hunts
    "collar_light": ("neck", (8.6, 4.4)),   # teal while it waits, amber while it hunts
    "spark_shoulder": ("torso", (17.0, -4.0)),
    "spark_spine": ("torso", (-6.0, -12.0)),
}
PAINTERS = {
    "torso": paint_torso, "neck": paint_neck, "head": paint_head, "jaw": paint_jaw,
    "front_upper_leg": paint_front_upper_leg, "front_lower_leg": paint_front_lower_leg,
    "hind_upper_leg": paint_hind_upper_leg, "hind_lower_leg": paint_hind_lower_leg, "front_paw": lambda: paint_paw("front_paw"), "hind_paw": lambda: paint_paw("hind_paw"),
    "tail": paint_tail,
}


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rd, "role": role}
            for (n, pt, par, pos, z, far, col, mass, lim, role, rd) in RIG]


# Preview poses (degrees), the same shapes clips_hound.gd keys.
CROUCH = {"torso": 7, "neck": 26, "head": -14, "near_front_upper_leg": -34, "near_front_lower_leg": 58,
          "near_front_paw": -24, "far_front_upper_leg": -30, "far_front_lower_leg": 54, "far_front_paw": -24,
          "near_hind_upper_leg": -8, "near_hind_lower_leg": 6, "far_hind_upper_leg": -6, "far_hind_lower_leg": 4, "tail": 10}
LUNGE = {"torso": -6, "neck": -8, "head": 4, "jaw": 24, "near_front_upper_leg": -64, "near_front_lower_leg": -8,
         "far_front_upper_leg": -56, "far_front_lower_leg": -2, "near_hind_upper_leg": 48, "near_hind_lower_leg": 26,
         "far_hind_upper_leg": 42, "far_hind_lower_leg": 22, "near_hind_paw": 30, "far_hind_paw": 30, "tail": -22}


def main():
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results)
    path = lr.write_rig_json(OUT_DIR, "K01 Hound (placeholder)", "quadruped", parts_json, joints(), ground_lock=True,
                             sole_points=SOLE_POINTS, sockets=SOCKETS)
    # The four paws for the ground lock, and the jaw riding on the skull in a ragdoll.
    with open(path) as f:
        rig = json.load(f)
    rig["feet"] = FEET
    for j in rig["joints"]:
        if j["name"] in LOCKED:
            j["lock"] = True
    with open(path, "w") as f:
        json.dump(rig, f, indent=1)
        f.write("\n")
    out = lr.preview_arg()
    if out:
        preview(parts, results, out)
    print("atlas", size[0], size[1], "->", OUT_DIR)


def preview(parts, results, out_dir):
    js = joints()
    emis = {"jaw": (hexc("#FFB02E"), 0.0), "torso": (LIME, 1.2), "neck": (TEAL, 1.0), "head": (hexc("#FFB02E"), 0.0)}
    tell = dict(emis)
    tell["jaw"] = (hexc("#FF3B4E"), 2.2)
    tell["head"] = (hexc("#FFB02E"), 0.8)
    lr.preview_rig(os.path.join(out_dir, "hound_preview.png"), js, parts, results,
                   [("stand", {}, emis), ("crouch tell", CROUCH, tell), ("lunge", LUNGE, emis)],
                   (-56, -64, 104, 70), root_fn=lambda pose: lr.ground_offset(js, pose, SOLE_POINTS, FEET),
                   lights=lr.lamp_lights(x=-10, y=-110, height=60))


if __name__ == "__main__":
    sys.exit(main())

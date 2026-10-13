#!/usr/bin/env python3
"""Paint the M02 Security Drone lit-cutout rig (placeholder, M4), procedurally.

Arcadia's ducted-fan security drone (art-design/machines/m02-security-drone.md): a
sleek pill hull with a flat back, pearl-white composite over an Arcadia-grey belly
with a pale reflective band, a blank shield ID plate, a thin magenta underglow strip
along the belly (Adam's colour, C60: emissive), a dark smoked canopy on the nose with
one round lens (the small amber point while it hunts: emissive), two chunky
ducted-fan nacelles on short pylons above the hull, a slim lightbar between them with
five lens segments (the tell: emissive, tinted amber then red by the engine), a tail
boom with one fin, two short skids and a two-pronged shock fork folded under the nose.

The parts follow the list the M02 parts sheets will use (M4 coordination: hull with the
canopy, lens, skids, boom and fin and the magenta strip painted on; nacelle, used twice;
fan; lightbar; fork), so the painted sheet drops in without renaming code. The canopy
lens is painted dark: drone.gd lights the small amber point at the `lens_light` socket.
Rigid parts, so on death they fly apart as debris (`kind: machine`). The drone node's
origin is the hull's centre (it flies; nothing stands on a floor), and so is the
hull joint's pivot: the Drone script pitches the hull about it for the nose-up tell
and the dive. The fork hinges under the nose: 0 is folded back along the belly, about
-150 degrees swings it down and forward for the dive. The fan discs spin by
flipping their x scale (drone.gd).

Outputs (assets/characters/lit/security_drone/): albedo.png, normal.png, spec.png and
rig.json. Placeholder until the M02 parts sheet exists; replace the folder (same
joint names, roles and sockets) to swap the painted art in.

Run from the project root:  python3 tools/art/paint_security_drone.py [--preview DIR]
"""
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, R, arc_pts, ellipse_pts, hexc, rect_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "security_drone")
SEED = 20261014

PEARL = hexc("#DAD8CB")
GREY = hexc("#4B5663")
GREY_DARK = hexc("#3A4450")
BAND = hexc("#D3DAE0")
GRAPHITE = hexc("#2E363E")
GRILLE = hexc("#6B7785")
CANOPY = hexc("#1B2431")
FORK = hexc("#8A95A3")
CAPS = hexc("#D8DEE3")
LENS_AMBER = hexc("#C98A2B")
MAGENTA = hexc("#FF3DD5")
PLATE = hexc("#C4C6BC")
WELL = hexc("#101419")
LENS = hexc("#3A2A16")


def paint_hull():
    """Hull-local = drone-local: the origin is the hull's centre."""
    p = Part("hull", -30.0, -14.0, 22.8, 11.6)
    # the pill: flat back, rounded nose and belly, a short tail boom with one fin
    body = [(-21.0, -5.6), (14.0, -5.6), (18.6, -4.2), (21.4, -0.8), (21.6, 2.2), (19.6, 5.0), (15.0, 6.8),
            (-14.0, 6.8), (-19.6, 5.4), (-22.4, 2.2), (-22.6, -1.6)]
    m_body = p.shell(body, PEARL, "shell", bevel=2.0, crown=0.18, smooth=True, samples=8)
    boom = [(-21.0, -3.6), (-28.6, -2.2), (-29.4, -0.4), (-28.4, 1.0), (-21.0, 1.6)]
    p.shell(boom, GREY_DARK, "paint", bevel=0.8, crown=0.15, smooth=True)
    fin = [(-23.6, -3.0), (-26.6, -12.6), (-28.2, -13.0), (-28.8, -11.8), (-28.0, -2.2)]
    p.shell(fin, PEARL, "shell", bevel=0.7, crown=0.1, smooth=False)
    p.seam([(-25.2, -4.0), (-27.4, -11.4)], 0.1, 0.14, 0.35)
    # the grey belly under a groove, the pale reflective band between them
    belly = p.patch([(-23.0, 1.6), (22.0, 1.6), (22.0, 7.4), (-23.0, 7.4)], GREY, "paint", 0.0, 0.2, smooth=False)
    p.patch(rect_pts(-20.4, 0.2, 19.6, 1.6), BAND, "stripe", 0.15, 0.1, smooth=False)
    p.seam([(-21.6, 1.7), (20.8, 1.7)], 0.3, 0.2, 0.5, smooth=False)
    # the magenta underglow strip along the belly's lower edge (Adam's colour, emissive)
    p.patch(rect_pts(-15.0, 5.2, 13.4, 6.3, 0.4), MAGENTA, "stripe", 0.12, 0.08, smooth=False, emissive=1.0)
    # the blank shield ID plate and panel seams on the white upper hull
    shield = [(-9.6, -3.6), (-5.2, -3.6), (-5.2, -1.4), (-5.8, -0.4), (-7.4, 0.2), (-9.0, -0.4), (-9.6, -1.4)]
    p.patch(shield, PLATE, "steel", 0.25, 0.1, smooth=False)
    p.seam(shield, 0.0, 0.12, 0.4, closed=True, smooth=False)
    p.seam([(4.0, -5.2), (4.6, 0.0)], 0.2, 0.16, 0.45)
    p.seam([(-14.0, -5.2), (-14.4, 0.0)], 0.2, 0.16, 0.45)
    # two short skids under the belly
    for x0 in (-12.0, 5.0):
        sk = p.shell([(x0, 6.4), (x0 + 1.2, 6.4), (x0 + 1.0, 9.6), (x0 + 6.0, 9.6), (x0 + 6.4, 10.6), (x0 - 0.6, 10.6), (x0 - 0.4, 6.4)],
                     GRAPHITE, "paint", bevel=0.4, crown=0.05, smooth=False)
        del sk
    # the fork's insulated collar mount under the nose
    p.patch(ellipse_pts(14.0, 6.2, 1.8, 1.4, 0, 16), GREY_DARK, "steel", 0.3, 0.1, smooth=False, clip=False)
    # the smoked half-dome canopy on the nose with one round lens (dark; the engine lights it)
    cx, cy = 14.6, -0.4
    dome = [(cx, cy - 5.8)] + arc_pts(cx, cy, 7.6, -90, 90, 30, ry=5.9)[1:-1] + [(cx, cy + 5.9)]
    dm = p.mask(dome)
    p.fill(dm, CANOPY, "smoked")
    p.sil |= dm
    yy, xx = np.mgrid[0:p.H, 0:p.W].astype(np.float32)
    wx = xx / R + p.x0 - cx
    wy = yy / R + p.y0 - cy
    e = np.clip(1.0 - (wx / 7.6) ** 2 - (wy / 5.9) ** 2, 0, 1)
    p.height = np.where(dm, np.maximum(p.height, 3.6 * R * np.sqrt(e) + 1.6 * R), p.height)
    lens = p.mask(ellipse_pts(cx + 4.6, cy + 0.6, 1.4, 1.4, 0, 20)) & dm
    p.albedo = np.where(lens[..., None], 0.7 * LENS + 0.3 * CANOPY, p.albedo)
    ring = p.mask(ellipse_pts(cx + 4.6, cy + 0.6, 1.9, 1.9, 0, 20)) & dm & ~lens
    p.albedo = np.where(ring[..., None], 0.5 * GRILLE + 0.5 * p.albedo, p.albedo)
    p.seam([(cx + 0.2, cy - 5.6), (cx + 0.2, cy + 5.6)], 0.15, 0.2, 0.5, smooth=False)
    del m_body, belly
    return p


def paint_nacelle():
    """A ducted-fan pod on a short pylon. Pivot at the pylon's foot on the hull."""
    p = Part("nacelle", -6.4, -10.6, 6.4, 0.6)
    p.shell(rect_pts(-1.3, -4.2, 1.3, 0.4, 0.4), GREY_DARK, "paint", bevel=0.5, crown=0.1, smooth=False)
    pod = rect_pts(-6.0, -10.0, 6.0, -3.4, 1.8)
    p.shell(pod, GRAPHITE, "plastic", bevel=1.2, crown=0.25, smooth=False)
    # the shroud ring (a raised band) and the steel intake grille on top
    p.ridge([(-6.0, -8.4), (6.0, -8.4)], 0.3, 0.5, smooth=False)
    p.ridge([(-6.0, -4.6), (6.0, -4.6)], 0.3, 0.5, smooth=False)
    g = p.patch(rect_pts(-4.8, -10.3, 4.8, -9.2, 0.3), GRILLE, "steel", 0.2, 0.08, smooth=False, clip=False)
    p.sil |= g
    for k in range(7):
        x = -4.2 + k * 1.4
        p.seam([(x, -10.2), (x, -9.3)], 0.12, 0.14, 0.5, smooth=False)
    return p


def paint_fan():
    """The spinning fan disc over an intake (a thin pale ellipse; drone.gd flips it)."""
    p = Part("fan", -6.6, -1.2, 6.6, 1.2)
    m = p.mask(ellipse_pts(0.0, 0.0, 6.3, 0.9, 0, 32))
    p.fill(m, GRILLE, "steel")
    p.sil |= m
    p.height = np.where(m, 0.5 * R, p.height)
    p.seam([(-5.6, 0.0), (5.6, 0.0)], 0.1, 0.2, 0.35, smooth=False)
    p.dot(0.0, 0.0, 0.7, GREY_DARK, "steel", 0.2)
    return p


def paint_lightbar():
    """A slim bar with five flat lens segments (emissive). Pivot at its base centre."""
    p = Part("lightbar", -7.4, -3.6, 7.4, 0.5)
    p.shell(rect_pts(-7.2, -3.4, 7.2, 0.2, 1.2), GREY_DARK, "plastic", bevel=0.8, crown=0.25, smooth=False)
    w = 2.5
    x = -2.5 * w - 0.1
    for k in range(5):
        r = rect_pts(x + 0.2, -2.8, x + w - 0.2, -0.6, 0.3)
        p.patch(r, LENS_AMBER, "glass", 0.2, 0.1, smooth=False, emissive=1.0)
        p.seam(r, 0.0, 0.1, 0.35, closed=True, smooth=False)
        x += w + 0.05
    return p


def paint_fork():
    """The shock fork, folded back along the belly at rest: an insulated white collar
    at the hinge and two blunt steel prongs pointing back (-x) with pale caps.
    Pivot at the hinge."""
    p = Part("fork", -15.6, -2.0, 2.2, 2.6)
    p.shell(ellipse_pts(0.0, 0.2, 1.9, 1.8, 0, 20), CAPS, "plastic", bevel=0.6, crown=0.3, smooth=False)
    for y in (-0.6, 1.0):
        p.shell(rect_pts(-13.2, y - 0.55, -0.6, y + 0.55, 0.5), FORK, "steel", bevel=0.4, crown=0.2, smooth=False)
        p.shell(ellipse_pts(-13.6, y, 1.4, 0.95, 0, 16), CAPS, "plastic", bevel=0.5, crown=0.3, smooth=False)
    return p


def cap(ax, ay, bx, by, r):
    return {"type": "capsule", "a": [ax, ay], "b": [bx, by], "r": r}


def circ(cx, cy, r):
    return {"type": "circle", "c": [cx, cy], "r": r}


NACELLE_Y = -5.6
RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit, role, rest_dir
    ("hull", "hull", "", (0.0, 0.0), 3, False, cap(-18.0, 0.6, 17.0, 0.6, 6.0), 9.0, None, "hull", 0),
    ("fork", "fork", "hull", (14.0, 6.2), 2, False, cap(-12.0, 0.2, -1.0, 0.2, 1.6), 1.0, None, "fork", 0),
    ("nacelle_aft", "nacelle", "hull", (-9.6, NACELLE_Y), 4, False, cap(-4.4, -6.6, 4.4, -6.6, 3.4), 2.5, None, "nacelle_aft", -90),
    ("nacelle_fore", "nacelle", "hull", (8.6, NACELLE_Y), 4, False, cap(-4.4, -6.6, 4.4, -6.6, 3.4), 2.5, None, "nacelle_fore", -90),
    ("fan_aft", "fan", "nacelle_aft", (0.0, -10.4), 5, False, cap(-5.0, 0.0, 5.0, 0.0, 0.9), 0.3, None, "fan_aft", 0),
    ("fan_fore", "fan", "nacelle_fore", (0.0, -10.4), 5, False, cap(-5.0, 0.0, 5.0, 0.0, 0.9), 0.3, None, "fan_fore", 0),
    ("lightbar", "lightbar", "hull", (-0.6, -5.4), 5, False, cap(-6.0, -1.6, 6.0, -1.6, 1.8), 0.8, None, "lightbar", 0),
]
SOCKETS = {
    "tell": ("lightbar", (0.0, -1.7)),        # the big tell glow (amber, then red)
    "lens_light": ("hull", (19.2, 0.2)),      # the small steady amber point while it hunts
    "fork_tip": ("fork", (-13.6, 0.2)),       # the arc and the spent smoke
    "spark_fore": ("nacelle_fore", (0.0, -6.6)),
    "spark_aft": ("nacelle_aft", (0.0, -6.6)),
    "oil_drip": ("hull", (0.0, 7.0)),
    "underglow": ("hull", (0.0, 6.0)),
}
PAINTERS = {
    "hull": paint_hull, "nacelle": paint_nacelle, "fan": paint_fan,
    "lightbar": paint_lightbar, "fork": paint_fork,
}


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rd, "role": role}
            for (n, pt, par, pos, z, far, col, mass, lim, role, rd) in RIG]


PREVIEW_EMISSIVE = {"lightbar": (hexc("#FFB02E"), 0.25)}


def main():
    lr.refuse_to_overwrite_art(OUT_DIR)
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results)
    lr.write_rig_json(OUT_DIR, "M02 Security Drone (placeholder)", "machine", parts_json, joints(),
                      ground_lock=False, sockets=SOCKETS)
    out = lr.preview_arg()
    if out:
        tell = dict(PREVIEW_EMISSIVE)
        tell["lightbar"] = (hexc("#FF3B4E"), 1.8)
        lr.preview_rig(os.path.join(out, "security_drone_preview.png"), joints(), parts, results,
                       [("hover", {}, PREVIEW_EMISSIVE), ("nose-up tell", {"hull": -14}, tell),
                        ("dive", {"hull": 28, "fork": -150}, PREVIEW_EMISSIVE)],
                       (-36, -30, 64, 46), root_fn=lambda pose: (0.0, -10.0),
                       lights=lr.lamp_lights(x=-6, y=-90, height=60))
    print("atlas", size[0], size[1], "->", OUT_DIR)


if __name__ == "__main__":
    sys.exit(main())

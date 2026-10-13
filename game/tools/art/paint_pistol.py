#!/usr/bin/env python3
"""Paint the EG01 AS-9 "Civic" smart pistol as a lit-cutout prop rig (placeholder, M4).

The Sidearm Guard's gun (art-design/enemy-guns/eg01-pistol.md): a sleek matte
white-and-graphite polymer slab with no hammer, a thin teal status strip along the
frame and a flush lamp at the muzzle (the tell: dark until the engine tints it amber,
then red). About 0.21 m long and 0.14 m tall, the length of the carrier's head: here
16 x 10 world px. It is a separate sprite (the brief), so it is a prop rig of two
parts the Gunner hangs on the carrier's near hand:

  frame   the grip, trigger guard and lower frame with the teal status strip
          (emissive, spec B); the root, its origin at the grip's centre a third up
          from the heel, where the palm holds it
  slide   the upper slide with the muzzle lamp at its front face (emissive, spec B);
          the Gunner slides it back on the reload (the rack)

Sockets: `muzzle` (the round and the flash leave here) and `support` (where the far
hand meets the grip in the two-hand stance). Placeholder until the EG01 parts sheet
exists; replace this folder (same joint names and sockets) to swap the art in.

Outputs (assets/characters/lit/pistol_eg01/): albedo.png, normal.png, spec.png and
rig.json. Run from the project root:  python3 tools/art/paint_pistol.py [--preview DIR]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, ellipse_pts, hexc, rect_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "pistol_eg01")
SEED = 20261013

WHITE = hexc("#DCE0E3")
GRAPHITE = hexc("#2A3341")
LAMP_HOUSING = hexc("#1C2A3A")
LAMP_GLASS = hexc("#5B4A2E")     # unlit lamp glass (a dark warm tint; the engine lights it)
TEAL = hexc("#3FE0D0")
STEEL = hexc("#6B7785")

SLIDE_Y = -2.6                    # the slide's pivot in frame space (its lower rear corner line)


def paint_frame():
    p = Part("frame", -4.2, -3.2, 11.4, 6.8)
    # the grip, raked back, graphite with a white back strap
    grip = [(-2.9, -1.6), (2.4, -1.6), (2.0, 1.2), (1.4, 5.6), (0.6, 6.4), (-2.6, 6.4), (-3.4, 5.6), (-3.6, 2.0)]
    p.shell(grip, GRAPHITE, "plastic", bevel=0.9, crown=0.2, smooth=True)
    for y in (1.4, 2.8, 4.2):
        p.seam([(-3.0, y), (1.2, y + 0.4)], 0.12, 0.14, 0.45)
    # the lower frame (dust cover) ahead of the grip, white
    lower = rect_pts(-3.9, -2.9, 11.1, 0.1, 0.8)
    p.shell(lower, WHITE, "shell", bevel=0.8, crown=0.15, smooth=False, replace=True)
    # trigger guard: a loop under the frame, with the trigger inside
    guard_out = [(2.4, -0.2), (6.6, -0.2), (6.6, 1.6), (5.6, 2.8), (2.6, 2.8), (2.2, 1.4)]
    m_out = p.shell(guard_out, GRAPHITE, "plastic", bevel=0.5, crown=0.1, smooth=True)
    hole = p.mask(lr.catmull([(3.2, 0.4), (5.8, 0.4), (5.6, 1.6), (4.8, 2.1), (3.3, 2.0)], True, 8))
    p.albedo[hole] = 0.0
    p.cover[hole] = 0.0
    p.sil &= ~hole
    p.height[hole] = 0.0
    trig = p.patch([(3.6, 0.2), (4.3, 0.2), (4.1, 1.6), (3.7, 1.8)], STEEL, "steel", 0.3, 0.08, smooth=False, clip=False)
    p.sil |= trig
    # the thin teal status strip along the frame (a small steady light, never a tell)
    strip = p.patch(rect_pts(-1.6, -1.8, 9.6, -1.1, 0.3), TEAL, "glass", 0.1, 0.06, smooth=False, emissive=1.0)
    p.seam(rect_pts(-1.8, -2.0, 9.8, -0.9, 0.35), 0.05, 0.1, 0.4, closed=True, smooth=False)
    del strip, m_out
    return p


def paint_slide():
    """Slide-local: the pivot is at its lower rear corner line (frame (0, SLIDE_Y))."""
    p = Part("slide", -4.6, -3.9, 12.6, 0.4)
    body = [(-4.3, 0.1), (-4.3, -2.6), (-3.6, -3.6), (11.2, -3.6), (12.2, -2.9), (12.2, 0.1)]
    p.shell(body, WHITE, "shell", bevel=0.9, crown=0.2, smooth=False)
    # graphite rear serrations and a top rail line
    for k in range(4):
        x = -3.5 + k * 0.7
        p.seam([(x, -3.3), (x, -0.4)], 0.18, 0.16, 0.5, smooth=False)
    p.seam([(-3.4, -3.3), (10.8, -3.3)], 0.1, 0.12, 0.3, smooth=False)
    # the small wordless arch mark on the flank
    arch = lr.arc_pts(4.2, -1.0, 1.1, 180, 360, 10)
    p.seam(arch, 0.05, 0.16, 0.55)
    # the flush muzzle lamp on the front face: a dark housing round a lamp glass (emissive)
    p.patch(rect_pts(10.3, -3.1, 12.1, -0.4, 0.4), LAMP_HOUSING, "plastic", 0.05, 0.08, smooth=False)
    lamp = p.patch(ellipse_pts(11.35, -1.75, 0.75, 1.0, 0, 18), LAMP_GLASS, "glass", 0.15, 0.06, smooth=False, emissive=1.0)
    del lamp
    return p


def cap(ax, ay, bx, by, r):
    return {"type": "capsule", "a": [ax, ay], "b": [bx, by], "r": r}


RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit, role, rest_dir
    ("frame", "frame", "", (0.0, 0.0), 0, False, cap(-1.0, 2.6, 8.0, -1.4, 2.4), 0.8, None, "frame", 0),
    ("slide", "slide", "frame", (0.0, SLIDE_Y), 1, False, cap(-3.4, -1.8, 10.8, -1.8, 1.8), 0.4, None, "slide", 0),
]
SOCKETS = {
    "muzzle": ("slide", (12.4, -1.75)),     # the lamp's centre, just off the front face
    "lamp": ("slide", (11.35, -1.75)),
    "support": ("frame", (0.2, 1.8)),       # where the support hand cups the grip
}
PAINTERS = {"frame": paint_frame, "slide": paint_slide}


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rd, "role": role}
            for (n, pt, par, pos, z, far, col, mass, lim, role, rd) in RIG]


def main():
    lr.refuse_to_overwrite_art(OUT_DIR)
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results, width=128)
    lr.write_rig_json(OUT_DIR, "EG01 AS-9 Civic pistol (placeholder)", "prop", parts_json, joints(),
                      ground_lock=False, sockets=SOCKETS)
    out = lr.preview_arg()
    if out:
        tell = {"slide": (hexc("#FF3B4E"), 2.0), "frame": (hexc("#3FE0D0"), 1.0)}
        idle = {"slide": (hexc("#FFB02E"), 0.0), "frame": (hexc("#3FE0D0"), 1.0)}
        lr.preview_rig(os.path.join(out, "pistol_preview.png"), joints(), parts, results,
                       [("idle", {}, idle), ("tell red", {}, tell)], (-8, -12, 24, 22),
                       lights=lr.lamp_lights(x=0, y=-40, height=40))
    print("atlas", size[0], size[1], "->", OUT_DIR)


if __name__ == "__main__":
    sys.exit(main())

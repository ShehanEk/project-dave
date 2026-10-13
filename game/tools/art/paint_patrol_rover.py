#!/usr/bin/env python3
"""Paint the M01 Patrol Rover lit-cutout rig (C35), procedurally.

Arcadia's squat wheeled campus security robot (art-design/machines/m01-patrol-rover.md):
a wedge chassis that rises toward the rear, with a pearl-white upper shell over an
Arcadia-grey skirt (#4B5663), a pale reflective stripe, a blank shield ID plate, hex
bolts, hazard stripes and a rear tow ring; deep wheel arches over four fat rubber
wheels with flat hubs; a thick padded push-bumper over a skid plate; a smoked sensor
dome with a camera ring and one graphite puck with one round lens; a slim lightbar in
a dark housing with six lens segments; and a hinged battery hatch on the rear deck
over a graphite battery block with a teal gauge. No eye stalks, no shears, no arms.

Every part is rigid and complete, so on death the joints can fly apart as debris
(`kind: machine`, a `role` per joint, colliders and masses for physics bodies).
Emissive masks (spec B): the dome lens (the small steady amber point), the lightbar
lenses (the tell: the engine tints them amber, then red), and the battery's gauge
and cells (teal, visible when the hatch is open).

Rig space: world px, origin at the bottom centre on the floor, facing right; the art
is about 70 x 48 px. The chassis pivot sits at mid-wheelbase, axle height.

Outputs (assets/characters/lit/patrol_rover/): albedo.png, normal.png, spec.png and
rig.json (see lit_rig_common.py for the channel conventions).

Run from the project root:  python3 tools/art/paint_patrol_rover.py [--preview DIR]
"""
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, R, arc_pts, ellipse_pts, hexc, rect_pts, rot_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "patrol_rover")
SEED = 20261001

# --- palette (sRGB; the brief's targets) ------------------------------------------------
PEARL = hexc("#DAD8CB")
GREY = hexc("#4B5663")          # Arcadia grey livery (the guards' colour)
GREY_DARK = hexc("#3A4450")
STRIPE = hexc("#D3DAE0")
RUBBER = hexc("#1C232B")        # bumper and tyres
HUB = hexc("#4A5561")
DOME = hexc("#1B2431")
PUCK = hexc("#3A4552")
LENS_AMBER = hexc("#C98A2B")    # unlit amber-tinted lenses
HOUSING = hexc("#1C232B")
BATTERY = hexc("#2E363E")
TEAL = hexc("#3FE0D0")
TEAL_DARK = hexc("#1F6F6A")
WELL = hexc("#101419")
STEEL = hexc("#8E99A6")
BOLT = hexc("#6E7985")
PLATE = hexc("#C4C6BC")
HAZARD = hexc("#B8902F")        # a muted hazard ochre, never the amber of a light
HAZARD_DARK = hexc("#1E2329")
CAMERA = hexc("#0C1016")

WHEEL_R = 9.0
AXLE_X = 20.0
CHASSIS_Y = -9.0                # the chassis pivot: mid-wheelbase, axle height (rig space)
ARCH_R = 10.5


# --- helpers -------------------------------------------------------------------------------
def radial(p, cx=0.0, cy=0.0):
    """Distance (world px) of every internal pixel of part `p` from (cx, cy)."""
    yy, xx = np.mgrid[0:p.H, 0:p.W].astype(np.float32)
    wx = xx / R + p.x0
    wy = yy / R + p.y0
    return np.sqrt((wx - cx) ** 2 + (wy - cy) ** 2), wx, wy


def hex_bolt(p, cx, cy, r=0.75, color=BOLT):
    """A hex bolt head: a raised hexagon with a darker rim groove."""
    hexa = [(cx + r * math.cos(math.radians(30 + 60 * k)), cy + r * math.sin(math.radians(30 + 60 * k))) for k in range(6)]
    p.patch(hexa, color, "steel", 0.28, 0.08, smooth=False)
    p.seam(hexa, 0.0, 0.14, 0.35, closed=True, smooth=False)


def hazard_stripes(p, x0, y0, x1, y1, step=1.6, clip=None):
    """Diagonal ochre-and-black hazard stripes in a box (flat colour, a slight groove)."""
    box = p.mask(rect_pts(x0, y0, x1, y1))
    if clip is not None:
        box &= clip
    p.fill(box & p.sil, HAZARD, "paint")
    yy, xx = np.mgrid[0:p.H, 0:p.W].astype(np.float32)
    u = (xx / R + p.x0) + (yy / R + p.y0)
    dark = (np.floor(u / step) % 2 == 0) & box & p.sil
    p.fill(dark, HAZARD_DARK, "paint")
    p.seam([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], 0.08, 0.14, 0.4, closed=True, smooth=False)


def vent_slots(p, x0, y0, length, n=3, gap=1.25, angle=0.0):
    for k in range(n):
        y = y0 + k * gap
        pts = rot_pts(rect_pts(x0, y - 0.3, x0 + length, y + 0.3, 0.28), angle, x0, y0)
        m = p.mask(pts) & p.sil
        p.fill(m, WELL, "rubber")
        p.lift(m, -0.45, 0.12)


# --- the parts ---------------------------------------------------------------------------
# Chassis-local coordinates: rig space minus the chassis pivot (0, CHASSIS_Y).
def paint_chassis():
    p = Part("chassis", -36.2, -30.8, 31.8, 3.2)
    body = [(-33.0, 2.6), (-34.3, 0.8), (-34.8, -8.0), (-34.8, -21.0), (-34.3, -26.6), (-32.8, -29.2),
            (-30.2, -30.2), (-12.0, -30.2), (2.0, -30.0), (4.6, -28.8), (7.4, -26.4), (9.4, -25.6),
            (23.6, -25.6), (25.8, -24.2), (28.8, -19.2), (30.6, -14.6), (31.4, -8.0), (31.0, -1.0), (29.4, 2.4)]
    m_body = p.shell(body, PEARL, "shell", bevel=2.2, crown=0.1, smooth=False)
    # the Arcadia-grey skirt below the waist line, with a groove between the two
    skirt = [(-35.4, -12.0), (31.8, -12.0), (31.8, 3.4), (-35.4, 3.4)]
    ms = p.patch(skirt, GREY, "paint", 0.0, 0.2, smooth=False)
    p.seam([(-34.8, -12.0), (31.4, -12.0)], 0.35, 0.3, 0.55, smooth=False)
    p.ridge([(-34.6, -12.9), (31.2, -12.9)], 0.25, 0.7, smooth=False)
    # deep wheel arches: a raised flare around a dark, recessed wheel well
    dist_r, wx, wy = radial(p, -AXLE_X, 0.0)
    dist_f, _, _ = radial(p, AXLE_X, 0.0)
    for dist in (dist_r, dist_f):
        lip = (dist < ARCH_R + 1.4) & (dist >= ARCH_R) & m_body & (wy < 2.0)
        p.fill(lip, GREY_DARK, "paint")
        p.lift(lip, 0.9, 0.25)
        well = (dist < ARCH_R) & m_body
        p.fill(well, WELL, "rubber")
        p.height = np.where(well, p.height * 0.25, p.height)
        p.lift(well, -0.6, 0.3)
    for cx in (-AXLE_X, AXLE_X):
        p.seam(arc_pts(cx, 0.0, ARCH_R + 1.4, 180, 360, 24), 0.2, 0.18, 0.5)
        p.seam(arc_pts(cx, 0.0, ARCH_R, 180, 360, 24), 0.25, 0.16, 0.6)
    # the pale reflective stripe along the flank, between and beyond the arches
    for x0, x1 in ((-8.6, 8.6), (-34.4, -32.2)):
        p.patch(rect_pts(x0, -9.2, x1, -7.6), STRIPE, "stripe", 0.12, 0.1, smooth=False)
    # hex bolts on the skirt, the rear tow ring, hazard stripes on the rear skirt corner
    for bx, by in ((-7.2, -3.4), (0.0, -3.4), (7.2, -3.4), (-32.6, -3.0), (-32.6, -10.0)):
        hex_bolt(p, bx, by)
    hazard_stripes(p, -34.6, -6.4, -30.8, -1.2, 1.2, clip=ms)
    rm = p.patch(ellipse_pts(-35.2, -0.6, 1.3, 1.3, 0, 20), STEEL, "steel", 0.0, 0.1, smooth=False, clip=False)
    p.sil |= rm
    rd, _, _ = radial(p, -35.2, -0.6)
    p.height = np.where(rm, 0.9 * R * np.clip(1.0 - np.abs(rd - 0.85) / 0.5, 0, 1) + 0.4 * R, p.height)
    p.fill(rm & (rd < 0.5), WELL, "rubber")
    p.patch(rect_pts(-35.0, -1.8, -33.6, 0.6, 0.3), GREY_DARK, "steel", 0.3, 0.1, smooth=False)
    # the white shell: door panel with the blank shield ID plate, hood and roof seams
    door = rect_pts(-12.6, -24.6, 7.6, -13.6, 1.2)
    p.seam(door, 0.3, 0.2, 0.5, closed=True, smooth=False)
    shield = [(-3.9, -22.4), (0.9, -22.4), (0.9, -19.4), (0.4, -17.6), (-1.5, -16.2), (-3.4, -17.6), (-3.9, -19.4)]
    p.patch(shield, PLATE, "steel", 0.3, 0.12, smooth=False)
    p.seam(shield, 0.0, 0.14, 0.4, closed=True, smooth=False)
    p.seam([(9.6, -25.0), (13.4, -14.4)], 0.2, 0.18, 0.45)                 # hood panel line
    p.seam([(24.4, -24.6), (27.6, -14.6)], 0.2, 0.18, 0.4)                 # nose panel line
    p.seam([(-12.0, -29.6), (2.0, -29.4)], 0.12, 0.14, 0.3)                 # roof edge
    for x in (-10.0, 5.2):
        hex_bolt(p, x, -15.4, 0.55, STEEL)
    # the battery bay under the hatch (visible only when the lid is open)
    bay = [(-33.6, -28.6), (-15.2, -28.6), (-15.0, -17.6), (-33.8, -17.6)]
    mb = p.mask(lr.catmull(bay, True, 6)) & m_body
    p.fill(mb, WELL, "rubber")
    p.height = np.where(mb, p.height * 0.2, p.height)
    p.lift(mb, -0.8, 0.35)
    p.seam(bay, 0.1, 0.2, 0.3, closed=True)
    # the hatch hinge bracket at the bay's lower rear corner
    hk = p.patch(rect_pts(-35.4, -18.8, -33.0, -16.2, 0.7), GREY_DARK, "steel", 0.0, 0.1, smooth=False, clip=False)
    p.sil |= hk
    p.lift(hk, 0.8, 0.2)
    # soft grime at the bottom of the skirt (flat colour)
    p.tint([(-34.4, -1.4), (31.0, -1.4), (31.0, 2.8), (-34.4, 2.8)], GREY_DARK, 0.35, 0.8, smooth=False)
    return p


def paint_wheel():
    p = Part("wheel", -WHEEL_R, -WHEEL_R, WHEEL_R, WHEEL_R)
    d = radial(p)[0]
    m = d < WHEEL_R
    p.fill(m, RUBBER, "tire")
    p.sil |= m
    # the sidewall bulges like a torus; the tread sits on the outer rim
    rim_in, rim_out = 4.4, WHEEL_R
    mid, half = (rim_in + rim_out) / 2, (rim_out - rim_in) / 2
    t = np.clip(1.0 - ((d - mid) / half) ** 2, 0, 1)
    h = 2.2 * R * np.sqrt(t)
    # the hub: a flat steel disc, set in, with a lip, five lug bolts and a cap
    hub = d < rim_in
    p.fill(hub, HUB, "steel")
    h = np.where(hub, 0.8 * R + 0.5 * R * np.clip((rim_in - d) / 0.6, 0, 1), h)
    p.height = np.where(m, h, 0.0)
    p.seam(ellipse_pts(0, 0, rim_in, rim_in, 0, 40), 0.3, 0.18, 0.6, closed=True, smooth=False)
    p.seam(ellipse_pts(0, 0, rim_in - 1.1, rim_in - 1.1, 0, 40), 0.15, 0.14, 0.35, closed=True, smooth=False)
    for k in range(5):
        a = math.radians(-90 + 72 * k)
        hex_bolt(p, 2.1 * math.cos(a), 2.1 * math.sin(a), 0.5, STEEL)
    p.dot(0, 0, 0.9, GREY_DARK, "steel", 0.35)
    # tread: short grooves around the rim, and the outer shoulder
    for k in range(18):
        a = math.radians(k * 20.0)
        p.seam([(7.7 * math.cos(a), 7.7 * math.sin(a)), (9.2 * math.cos(a), 9.2 * math.sin(a))], 0.35, 0.28, 0.4, smooth=False)
    p.seam(ellipse_pts(0, 0, 7.6, 7.6, 0, 48), 0.18, 0.16, 0.3, closed=True, smooth=False)
    return p


def paint_dome():
    """The smoked sensor dome on its collar (the camera ring), the puck and its lens.
    Pivot at the base centre."""
    p = Part("dome", -9.2, -12.8, 9.2, 0.4)
    # collar: a short graphite band with three small camera windows
    p.shell(rect_pts(-8.2, -2.8, 8.2, 0.3, 0.6), GREY_DARK, "paint", bevel=0.8, crown=0.2, smooth=False)
    for cx in (-5.0, 0.0, 5.0):
        p.patch(ellipse_pts(cx, -1.25, 0.72, 0.62, 0, 16), STEEL, "steel", 0.1, 0.06, smooth=False)
        p.patch(ellipse_pts(cx, -1.25, 0.46, 0.4, 0, 16), CAMERA, "glass", -0.05, 0.05, smooth=False)
    # the half-dome of smoked glass
    dome = [(-8.9, -2.6)] + arc_pts(0.0, -2.6, 8.9, 180, 360, 40, ry=10.0)[1:-1] + [(8.9, -2.6)]
    dm = p.mask(dome)
    p.fill(dm, DOME, "smoked")
    p.sil |= dm
    yy, xx = np.mgrid[0:p.H, 0:p.W].astype(np.float32)
    wx = xx / R + p.x0
    wy = yy / R + p.y0
    e = np.clip(1.0 - (wx / 8.9) ** 2 - ((wy + 2.6) / 10.0) ** 2, 0, 1)
    p.height = np.where(dm, 6.0 * R * np.sqrt(e) + 0.4 * R, p.height)
    # the puck inside, seen through the smoke (flat colour only: the glass keeps its shape)
    puck = rect_pts(-4.4, -9.0, 4.8, -3.4, 1.6)
    pm = p.mask(puck) & dm
    p.albedo = np.where(pm[..., None], 0.55 * PUCK + 0.45 * DOME, p.albedo)
    p.seam([(-3.6, -3.4), (4.2, -3.4)], 0.0, 0.18, 0.35)
    # one round lens on the front of the puck (the small steady amber point)
    lm = p.mask(ellipse_pts(4.1, -6.2, 1.25, 1.25, 0, 20)) & dm
    p.albedo = np.where(lm[..., None], 0.8 * LENS_AMBER + 0.2 * DOME, p.albedo)
    p.emit(lm, 1.0)
    ring = p.mask(ellipse_pts(4.1, -6.2, 1.7, 1.7, 0, 20)) & dm & ~lm
    p.albedo = np.where(ring[..., None], 0.35 * CAMERA + 0.65 * p.albedo, p.albedo)
    # a thin seal ring where the glass meets the collar
    p.seam([(-8.6, -2.7), (8.6, -2.7)], 0.2, 0.2, 0.55, smooth=False)
    return p


def paint_lightbar():
    """A slim lightbar: dark housing, six flat lens segments (emissive), end caps and a
    low mount. Pivot at the base centre, on the deck."""
    p = Part("lightbar", -8.6, -5.0, 8.6, 0.6)
    p.shell(rect_pts(-6.4, -1.4, 6.4, 0.4, 0.3), GREY_DARK, "paint", bevel=0.5, crown=0.1, smooth=False)
    p.shell(rect_pts(-8.4, -4.9, 8.4, -0.9, 1.6), HOUSING, "plastic", bevel=1.0, crown=0.3, smooth=False)
    seg_w = 2.3
    x = -3 * seg_w - 0.35
    for k in range(6):
        p.patch(rect_pts(x + 0.15, -4.2, x + seg_w - 0.15, -1.6, 0.35), LENS_AMBER, "glass", 0.22, 0.12,
                smooth=False, emissive=1.0)
        p.seam(rect_pts(x + 0.15, -4.2, x + seg_w - 0.15, -1.6, 0.35), 0.0, 0.1, 0.35, closed=True, smooth=False)
        x += seg_w + 0.1
    for cx in (-7.6, 7.6):
        p.seam([(cx, -4.6), (cx, -1.2)], 0.12, 0.16, 0.45, smooth=False)
    return p


def paint_bumper():
    """The thick padded push-bumper over a low skid plate with hazard stripes.
    Pivot at its mount on the nose."""
    p = Part("bumper", -3.4, -9.2, 9.0, 10.0)
    # mount bracket (behind the pad)
    p.shell(rect_pts(-3.2, -3.8, 0.8, 3.8, 0.6), GREY_DARK, "steel", bevel=0.6, crown=0.1, smooth=False)
    pad = [(-0.6, -8.6), (5.2, -8.8), (7.8, -7.2), (8.8, -3.6), (8.9, 2.6), (8.2, 6.4), (5.6, 7.9),
           (-0.6, 7.9), (-1.2, 2.0), (-1.2, -3.0)]
    p.shell(pad, RUBBER, "rubber", bevel=2.2, crown=0.35, smooth=True, replace=True)
    # three padded segments: grooves between them, each one puffed up a little
    for y in (-3.3, 2.2):
        p.seam([(-1.0, y), (4.0, y - 0.1), (8.8, y)], 0.5, 0.34, 0.55)
    for y0, y1 in ((-8.4, -3.3), (-3.3, 2.2), (2.2, 7.7)):
        p.bump(rect_pts(0.0, y0 + 0.6, 8.2, y1 - 0.6, 1.2), 0.45, 0.6)
    p.seam([(1.2, -8.2), (1.0, 7.4)], 0.18, 0.2, 0.35)                     # the pad's back edge
    # the skid plate, low under the nose, with hazard stripes
    skid = [(-3.0, 7.6), (7.4, 7.6), (8.6, 8.6), (7.8, 9.8), (-3.0, 9.8)]
    sm = p.shell(skid, STEEL, "steel", bevel=0.4, crown=0.05, smooth=False)
    hazard_stripes(p, -2.4, 7.9, 7.4, 9.5, 1.3, clip=sm)
    for bx in (-1.6, 6.4):
        hex_bolt(p, bx, 8.7, 0.42, STEEL)
    return p


def paint_hatch():
    """The rear battery hatch: a clamshell lid over the rear deck, its top, side and rear
    face in one piece, hinged at its lower rear edge (the pivot). A negative
    (counterclockwise) rotation of about 70 degrees flips it up and back, clear of the
    battery bay; zero is closed."""
    p = Part("hatch", -1.4, -12.4, 20.6, 1.4)
    lid = [(-0.8, 0.4), (-0.8, -7.4), (-0.3, -9.0), (1.2, -11.6), (3.8, -12.6), (20.0, -12.6),
           (20.2, -11.6), (19.9, -6.4), (19.2, -1.0), (17.2, 0.4)]
    m = p.shell(lid, PEARL, "shell", bevel=1.6, crown=0.12, smooth=False)
    # three vent slots, a recessed grab pull at the front edge, the hinge knuckle
    vent_slots(p, 5.6, -8.0, 9.6, 3, 1.35)
    grab = rect_pts(16.8, -3.2, 18.8, -1.4, 0.6)
    gm = p.mask(grab) & m
    p.fill(gm, GREY_DARK, "paint")
    p.lift(gm, -0.5, 0.15)
    hk = p.patch(ellipse_pts(0.0, 0.0, 1.2, 1.2, 0, 16), GREY_DARK, "steel", 0.0, 0.1, smooth=False, clip=False)
    p.sil |= hk
    p.lift(hk, 0.9, 0.2)
    # an inner panel seam and a small hazard mark on the rear face
    p.seam(rect_pts(1.2, -11.0, 18.6, -1.0, 1.0), 0.18, 0.16, 0.35, closed=True, smooth=False)
    hazard_stripes(p, -0.6, -6.8, 0.2, -1.4, 1.0, clip=m)
    return p


def paint_battery():
    """The graphite battery block with teal cell windows and a teal gauge strip (emissive).
    Pivot at its centre."""
    p = Part("battery", -8.4, -4.8, 8.4, 4.6)
    body = rect_pts(-8.0, -3.8, 8.0, 4.3, 1.0)
    p.shell(body, BATTERY, "plastic", bevel=0.9, crown=0.12, smooth=False)
    # terminals on top
    for tx in (-5.2, 4.6):
        t = p.patch(rect_pts(tx - 0.9, -4.6, tx + 0.9, -3.4, 0.3), STEEL, "steel", 0.0, 0.1, smooth=False, clip=False)
        p.sil |= t
        p.lift(t, 0.6, 0.15)
    # cells: ribs with teal windows (a faint glow) and the bright gauge strip
    for k in range(5):
        cx = -6.0 + k * 3.0
        w = p.patch(rect_pts(cx - 0.95, -2.6, cx + 0.95, 0.1, 0.35), TEAL_DARK, "glass", -0.15, 0.1, smooth=False)
        p.emit(w, 0.45)
        if k < 4:
            p.seam([(cx + 1.5, -3.2), (cx + 1.5, 3.6)], 0.15, 0.16, 0.4, smooth=False)
    p.patch(rect_pts(-6.8, 1.2, 4.2, 2.5, 0.4), TEAL, "glass", 0.12, 0.1, smooth=False, emissive=1.0)
    p.seam(rect_pts(-7.1, 0.9, 6.9, 2.8, 0.5), 0.1, 0.12, 0.45, closed=True, smooth=False)
    p.patch(rect_pts(4.6, 1.2, 6.6, 2.5, 0.3), HOUSING, "plastic", -0.05, 0.1, smooth=False)
    return p


# --- rig definition (world px, local to the parent part; y down) -----------------------------
# z: far wheels < chassis < battery < hatch < lightbar, dome < bumper < near wheels
def cap(ax, ay, bx, by, r):
    return {"type": "capsule", "a": [ax, ay], "b": [bx, by], "r": r}


def circ(cx, cy, r):
    return {"type": "circle", "c": [cx, cy], "r": r}


RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit(deg), role, rest_dir
    ("chassis", "chassis", "", (0.0, CHASSIS_Y), 3, False, cap(-18.5, -13.8, 15.0, -13.8, 16.0), 45.0, None, "chassis", 0),
    ("wheel_far_rear", "wheel", "chassis", (-AXLE_X, 0.0), 1, True, circ(0.0, 0.0, WHEEL_R), 5.0, None, "wheel_far_rear", 0),
    ("wheel_far_front", "wheel", "chassis", (AXLE_X, 0.0), 1, True, circ(0.0, 0.0, WHEEL_R), 5.0, None, "wheel_far_front", 0),
    ("battery", "battery", "chassis", (-23.4, -22.8), 4, False, cap(-4.2, 0.2, 4.2, 0.2, 4.2), 9.0, None, "battery", 0),
    ("hatch", "hatch", "chassis", (-34.0, -17.6), 5, False, cap(3.4, -6.0, 16.6, -6.0, 5.4), 3.0, [-110, 0], "hatch", -90),
    ("lightbar", "lightbar", "chassis", (-4.8, -30.0), 6, False, cap(-6.6, -2.8, 6.6, -2.8, 2.2), 2.5, None, "lightbar", 0),
    ("dome", "dome", "chassis", (16.4, -25.6), 6, False, cap(-3.2, -5.6, 3.2, -5.6, 5.8), 4.0, None, "dome", -90),
    ("bumper", "bumper", "chassis", (27.4, -6.0), 7, False, cap(4.2, -5.0, 4.2, 4.0, 4.6), 7.0, None, "bumper", 0),
    ("wheel_near_rear", "wheel", "chassis", (-AXLE_X, 0.0), 8, False, circ(0.0, 0.0, WHEEL_R), 5.0, None, "wheel_near_rear", 0),
    ("wheel_near_front", "wheel", "chassis", (AXLE_X, 0.0), 8, False, circ(0.0, 0.0, WHEEL_R), 5.0, None, "wheel_near_front", 0),
]
# Light, spark and fluid sockets, joint-local world px.
SOCKETS = {
    "lens_light": ("dome", (4.1, -6.2)),      # the small steady amber point while it patrols
    "tell": ("lightbar", (0.0, -2.9)),        # the lightbar tell glow (amber, then red)
    "core": ("battery", (0.0, 0.0)),          # the teal battery glow when the hatch is open
    "spark_bumper": ("bumper", (8.6, 0.0)),
    "spark_hatch": ("hatch", (10.0, -6.0)),
    "spark_dome": ("dome", (0.0, -8.0)),
    "oil_drip": ("chassis", (0.0, 2.4)),
}
PAINTERS = {
    "chassis": paint_chassis, "wheel": paint_wheel, "dome": paint_dome, "lightbar": paint_lightbar,
    "bumper": paint_bumper, "hatch": paint_hatch, "battery": paint_battery,
}


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rd, "role": role}
            for (n, pt, par, pos, z, far, col, mass, lim, role, rd) in RIG]


# Preview poses (degrees): patrol, the rock-back tell, the stall with the hatch open.
ROCK_BACK = {"chassis": -12}
STALL = {"chassis": 4, "hatch": -72}
PREVIEW_EMISSIVE = {"dome": (hexc("#FFB02E"), 1.2), "lightbar": (hexc("#FFB02E"), 0.0),
                    "battery": (hexc("#3FE0D0"), 1.6)}


def main():
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results)
    lr.write_rig_json(OUT_DIR, "M01 Patrol Rover", "machine", parts_json, joints(), ground_lock=False,
                      sockets=SOCKETS)
    out = lr.preview_arg()
    if out:
        preview(parts, results, out)
    print("atlas", size[0], size[1], "->", OUT_DIR)


def preview(parts, results, out_dir):
    js = joints()

    def on_floor(pose):
        # keep the lowest near wheel on the floor when the chassis pitches
        glob = lr.joint_transforms(js, pose)
        low = max((glob[w] @ np.array([0, 0, 1.0]))[1] + WHEEL_R for w in ("wheel_near_rear", "wheel_near_front"))
        return (0.0, -low)

    tell = dict(PREVIEW_EMISSIVE)
    tell["lightbar"] = (hexc("#FF3B4E"), 1.6)
    lr.preview_rig(os.path.join(out_dir, "patrol_rover_preview.png"), js, parts, results,
                   [("patrol", {}, PREVIEW_EMISSIVE), ("rock-back tell", ROCK_BACK, tell),
                    ("stall, hatch open", STALL, PREVIEW_EMISSIVE)],
                   (-48, -64, 96, 70), root_fn=on_floor, lights=lr.lamp_lights(x=-10, y=-120))


if __name__ == "__main__":
    sys.exit(main())

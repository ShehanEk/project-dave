#!/usr/bin/env python3
"""Paint the LK01 Staffer lit-cutout rig (C35), procedurally.

A Linked night-shift Arcadia employee (art-design/linked/lk01-staffer.md): the
navy staff jacket zipped halfway over a pale shirt with a loosened collar, the
near sleeve pushed up above the elbow, charcoal trousers, scuffed slate shoes
with pale soles, a lanyard with a blank ID card, padded restraint grips strapped
over both palms, a close-shaved scalp, heavy half-open eyelids and a slack lower
lip. Behind the near ear sits the Link port: a dark disc with a pale steel rim, a
ring of tiny staples and a faint bruise, a thin seam down the nape and faint
dark lines under the skin of the neck. The port's centre is the only emissive
spot (the small, dim, steady amber point while Adam drives the body; the engine
sets its colour and turns it off on death). No weapon, no blood, no gore.

Same joint names and hierarchy as the Night Guard minus `baton`, so the same
human clips drive it. Realistic proportions (about 7.3 heads, 97 px tall, a
little slimmer than the guard); faces right; texture_scale 3.

Outputs (assets/characters/lit/staffer/): albedo.png, normal.png, spec.png and
rig.json (see lit_rig_common.py for the channel conventions).

Run from the project root:  python3 tools/art/paint_staffer.py [--preview DIR]
"""
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, ellipse_pts, hexc, rect_pts, rot_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "staffer")
SEED = 20260930

# --- palette (sRGB; the brief's targets) ------------------------------------------------
SKIN = hexc("#B38D74")        # a little under the brief's #BC957B, so a lamp overhead never blows it out
SKIN_SHADE = hexc("#957061")
LID = hexc("#A47E69")
STUBBLE = hexc("#2E2724")
BROW = hexc("#4A3C36")
LIP = hexc("#9A6B5E")
MOUTH = hexc("#4A2A28")
EYE_WHITE = hexc("#CFC8BE")
IRIS = hexc("#3A3430")
UNDER_EYE = hexc("#8C6A60")
JACKET = hexc("#2C3D5A")
JACKET_DARK = hexc("#24334C")
SHIRT = hexc("#D3DAE0")
TROUSER = hexc("#333E4F")     # a touch over the brief's #2F3948, so the legs still read at night
BELT = hexc("#1E232B")
SHOE = hexc("#46546A")
SOLE = hexc("#B9C4CF")
GRIP = hexc("#46546A")
STRAP = hexc("#2A3341")
CARD = hexc("#D8DEE4")
LANYARD = hexc("#2A3341")
STEEL = hexc("#9AA5B1")
PORT = hexc("#2E3B4E")
PORT_LENS = hexc("#C98A2B")   # a dull amber lens; the emissive mask makes it the glowing point
STAPLE = hexc("#C8D0D8")
BRUISE = hexc("#7A4A45")
VEIN = hexc("#4A4F63")
ZIP = hexc("#8C96A3")

PORT_AT = (-2.8, -4.4)     # the Link port, head-local world px


# --- the parts ---------------------------------------------------------------------------
def paint_pelvis():
    p = Part("pelvis", -7.0, -7.9, 6.4, 6.6)
    p.body([(-5.6, -7.7), (-6.2, -4.2), (-6.6, -0.4), (-6.4, 3.1), (-5.3, 5.8), (-2.0, 6.4),
            (1.6, 6.1), (4.3, 4.2), (5.5, 0.6), (5.8, -3.4), (5.5, -7.7)], TROUSER, "cloth", radius=4.0, dome=0.3)
    # belt and a plain steel buckle (mostly under the jacket hem)
    p.patch([(-7.6, -7.9), (6.4, -7.9), (6.4, -6.2), (-7.6, -6.2)], BELT, "leather", 0.3, 0.15, smooth=False)
    p.seam([(-7.2, -6.3), (6.1, -6.3)], 0.08, 0.14, 0.3)
    p.patch(rect_pts(4.3, -7.8, 5.9, -6.3, 0.25), STEEL, "metal", 0.2, 0.1, smooth=False)
    for x in (-4.6, 2.2):
        p.patch(rect_pts(x, -8.0, x + 0.7, -5.8, 0.2), TROUSER, "cloth", 0.18, 0.1, smooth=False)
    # fly, side seam, back pocket, seat and crotch folds
    p.seam([(4.9, -6.0), (5.2, -2.0), (4.6, 1.8), (3.2, 4.4)], 0.12, 0.2, 0.35)
    p.seam([(-0.4, -6.0), (-0.3, 0.5), (-0.6, 6.2)], 0.12, 0.18, 0.3)
    p.seam([(-6.1, -4.4), (-3.6, -4.6), (-3.4, -0.8), (-5.9, -0.4)], 0.1, 0.16, 0.3)
    for a, b in (((2.4, 2.0), (4.4, 3.6)), ((1.6, 3.8), (3.6, 5.4)), ((-5.4, 3.4), (-3.2, 5.6))):
        p.seam([a, b], 0.1, 0.26, 0.16)
    return p


def paint_torso():
    p = Part("torso", -7.8, -31.4, 7.0, 5.4)
    # neck (skin) first, so the collars paint over it; it leans forward and matches the
    # head's neck stub at rest, and fills the gap when the head turns
    p.body([(-2.7, -24.0), (-1.7, -27.8), (-1.1, -30.8), (4.0, -30.8), (3.6, -27.6), (3.0, -24.0)],
           SKIN, "skin_matte", radius=2.2, dome=0.2)
    # faint dark lines under the skin of the neck, from the port down into the collar
    p.tint_stroke([(-0.9, -30.6), (-1.1, -28.2), (-0.8, -25.4)], 0.28, VEIN, 0.35, 0.1)
    p.tint_stroke([(0.1, -30.6), (0.1, -28.0), (0.7, -25.4)], 0.24, VEIN, 0.25, 0.1)
    p.seam([(-1.4, -30.6), (-1.8, -27.8), (-2.4, -24.8)], 0.08, 0.14, 0.2)
    # the jacket: a soft, hunched body (rounded upper back, sunken chest, soft belly)
    jacket = [(-6.5, 5.0), (-6.2, 1.0), (-6.0, -4.0), (-6.5, -10.0), (-7.3, -16.0), (-7.4, -20.0),
              (-6.3, -23.6), (-4.4, -25.8), (-2.0, -26.9), (1.0, -27.1), (3.2, -26.2), (4.6, -24.6),
              (5.3, -22.0), (5.6, -18.5), (5.7, -14.0), (5.9, -9.0), (6.5, -4.0), (6.7, 0.8), (6.2, 5.0)]
    p.body(jacket, JACKET, "nylon", radius=5.0, dome=0.42)
    # the half-zipped opening: pale shirt in a narrow wedge down the front
    opening = [(1.6, -27.2), (3.5, -25.9), (4.8, -22.8), (5.55, -18.6), (5.75, -15.6), (4.9, -17.6),
               (3.9, -20.8), (2.6, -24.0), (1.0, -25.8)]
    p.patch(opening, SHIRT, "cloth", 0.1, 0.25)
    p.seam([(2.4, -25.2), (3.9, -21.8), (5.2, -17.4)], 0.1, 0.16, 0.25)               # shirt placket
    # the jacket's open edge (a thick lapel) and its stand collar, fallen open
    lapel = [(1.0, -25.8), (2.6, -24.0), (3.9, -20.8), (4.9, -17.6), (5.6, -15.4)]
    p.ridge(lapel, 0.35, 0.6)
    p.seam([(x - 0.2, y + 0.2) for x, y in lapel], 0.12, 0.2, 0.55)
    collar = [(-4.3, -25.2), (-3.4, -28.4), (-1.4, -29.5), (1.2, -29.2), (2.8, -28.0), (3.6, -26.4),
              (2.4, -25.8), (0.4, -26.6), (-2.0, -26.4)]
    p.patch(collar, JACKET, "nylon", 0.45, 0.25, clip=False)
    p.sil |= p.mask(lr.catmull(collar, True, 8))
    p.seam([(-4.0, -26.0), (-1.6, -27.4), (0.8, -27.6), (3.0, -26.8)], 0.1, 0.16, 0.45)
    # the loosened shirt collar over the jacket collar, a collar point at the front
    scol = [(-2.4, -28.4), (-0.8, -29.8), (1.8, -29.6), (3.4, -28.2), (4.3, -25.9), (3.4, -26.3),
            (2.2, -27.9), (0.0, -28.7), (-1.8, -27.9)]
    p.patch(scol, SHIRT, "cloth", 0.25, 0.2, clip=False)
    p.sil |= p.mask(lr.catmull(scol, True, 8))
    # zipper from the end of the opening down the front to the hem, with its pull
    p.seam([(5.6, -15.2), (5.6, -9.0), (6.3, -3.6), (6.1, 4.6)], 0.14, 0.2, 0.5)
    p.patch(rect_pts(5.0, -15.9, 5.95, -14.0, 0.25), ZIP, "metal", 0.25, 0.1, smooth=False)
    # hem band, side seam, back yoke, soft folds where the jacket bunches at the waist
    p.patch([(-6.8, 2.9), (6.9, 2.9), (6.9, 5.3), (-6.8, 5.3)], JACKET_DARK, "nylon", 0.25, 0.25, smooth=False)
    p.seam([(-6.4, 3.0), (6.5, 3.0)], 0.14, 0.2, 0.5)
    p.seam([(-0.6, -19.6), (-0.4, -9.0), (-0.8, 2.8)], 0.12, 0.18, 0.35)
    p.seam([(-7.2, -18.8), (-4.8, -21.6), (-2.2, -22.6)], 0.1, 0.16, 0.3)
    for a, b in (((-5.8, -2.2), (-3.2, -0.4)), ((-5.6, 0.2), (-2.8, 1.8)), ((2.6, -1.2), (5.0, 0.6))):
        p.seam([a, b], 0.14, 0.3, 0.16)
    p.seam([(1.4, -19.6), (4.0, -18.4)], 0.1, 0.16, 0.4)                               # chest pocket zip
    # lanyard from behind the neck, over the collar and down the chest to a blank ID card
    lan = [(-1.8, -27.6), (0.6, -27.9), (2.7, -26.2), (3.9, -22.4), (4.6, -17.0), (4.8, -12.6)]
    p.ridge(lan, 0.22, 0.42)
    p.tint_stroke(lan, 0.44, LANYARD, 0.95, 0.05)
    p.seam(lan, 0.0, 0.48, 0.25)
    card = rot_pts(rect_pts(3.4, -12.6, 6.0, -8.8, 0.3), 7.0, 4.8, -12.6)
    cm = p.patch(card, CARD, "card", 0.3, 0.1, smooth=False, clip=False)
    p.sil |= cm
    p.patch(rot_pts(rect_pts(4.3, -13.1, 5.1, -11.8, 0.15), 7.0, 4.8, -12.6), ZIP, "metal", 0.15, 0.08, smooth=False)
    return p


def paint_head():
    p = Part("head", -6.0, -13.5, 8.0, 3.6)
    face = [(-3.6, 3.5), (-2.9, 0.8), (-3.8, -1.8), (-5.3, -4.6), (-5.8, -7.8), (-5.0, -10.6),
            (-3.0, -12.5), (0.2, -13.3), (3.4, -12.9), (5.5, -11.4), (6.4, -9.8), (6.85, -8.5),
            (6.6, -7.7), (7.0, -7.0), (7.85, -5.5), (7.0, -5.0), (6.45, -4.8), (6.55, -4.3),
            (6.2, -3.95), (6.42, -3.5), (5.95, -2.95), (6.0, -2.2), (5.5, -1.3), (4.4, -0.5),
            (3.0, -0.1), (2.3, 0.3), (2.0, 1.6), (1.4, 3.5)]
    p.body(face, SKIN, "skin_matte", radius=4.1, dome=0.45, samples=8)
    # close-shaved scalp: dark stubble over the cranium, around the ear to the nape
    scalp = [(6.1, -10.7), (5.3, -12.3), (2.0, -13.5), (-2.8, -12.9), (-5.3, -10.8), (-6.0, -7.4),
             (-5.4, -4.2), (-4.3, -1.6), (-3.3, -0.4), (-2.6, -1.8), (-2.1, -3.6), (-1.6, -5.6),
             (-1.4, -7.8), (0.6, -8.8), (2.4, -9.4), (2.6, -7.4), (3.1, -7.5), (3.3, -9.8), (5.2, -10.3)]
    p.tint(scalp, STUBBLE, 0.72, 0.28)
    p.bump(scalp, 0.05, 0.4)
    p.restyle(p.mask(lr.catmull(scalp, True, 8)), "hair", 0.9, 0.3)
    # soft jaw, a little weight under the chin; brow ridge, nose, cheek
    p.tint([(2.0, -1.6), (3.6, -3.2), (5.6, -3.0), (5.9, -1.6), (5.2, -0.6), (3.8, -0.1), (2.2, 0.2)],
           SKIN_SHADE, 0.22, 0.5)
    p.bump([(2.4, -1.4), (5.0, -1.0), (4.6, -0.2), (2.6, 0.0)], 0.3, 0.4)
    p.bump([(3.9, -8.9), (6.9, -9.0), (6.8, -8.0), (4.0, -7.9)], 0.5, 0.4)
    p.bump([(6.4, -7.5), (7.8, -5.4), (6.4, -4.9)], 0.9, 0.35)
    p.bump([(0.8, -5.8), (4.6, -6.2), (5.4, -4.4), (1.4, -3.8)], 0.5, 0.6)
    p.seam([(5.6, -4.9), (6.1, -4.5)], 0.12, 0.2, 0.2)                                # nostril
    p.seam([(1.0, -0.6), (2.8, -0.6), (4.4, -0.9)], 0.1, 0.3, 0.1)                    # jaw line
    # mouth: slack, lips a little apart, the lower lip hanging
    p.patch([(6.0, -4.45), (6.6, -4.35), (6.25, -4.0), (5.9, -4.05)], LIP, "skin_matte", 0.08, 0.1, smooth=False)
    p.patch([(5.7, -4.0), (6.3, -3.98), (6.28, -3.72), (5.7, -3.75)], MOUTH, "skin_matte", -0.12, 0.1, smooth=False)
    p.patch([(5.75, -3.75), (6.45, -3.6), (6.3, -3.1), (5.75, -3.25)], LIP, "skin_matte", 0.14, 0.12, smooth=False)
    # ear
    p.patch(ellipse_pts(-0.2, -6.1, 1.4, 2.2, 0.1, 28), SKIN, "skin_matte", 0.45, 0.25, smooth=False)
    p.seam([(0.3, -7.8), (-0.8, -7.2), (-0.9, -5.4), (-0.1, -4.4)], 0.25, 0.28, 0.3)
    p.patch(ellipse_pts(0.0, -6.0, 0.45, 0.7, 0.1, 16), SKIN_SHADE, "skin_matte", -0.2, 0.2, smooth=False)
    # eye: heavy lids half closed over an unfocused, lowered gaze; tired shadows under it
    p.tint([(4.4, -6.8), (6.1, -6.8), (5.9, -5.9), (4.6, -5.9)], UNDER_EYE, 0.5, 0.25)
    p.patch(ellipse_pts(5.45, -7.0, 0.62, 0.32, 0.06, 18), EYE_WHITE, "eye", -0.05, 0.1, smooth=False)
    p.patch(ellipse_pts(5.72, -6.9, 0.28, 0.28, 0.0, 14), IRIS, "eye", 0.0, 0.1, smooth=False)
    p.patch([(4.75, -7.5), (6.15, -7.55), (6.2, -7.0), (4.8, -6.98)], LID, "skin_matte", 0.14, 0.1, smooth=False)
    p.seam([(4.8, -7.0), (5.5, -7.02), (6.15, -6.98)], 0.06, 0.16, 0.75)               # lid edge
    p.seam([(4.8, -7.62), (5.5, -7.74), (6.1, -7.64)], 0.1, 0.16, 0.25)                # lid crease
    p.seam([(4.8, -6.4), (5.6, -6.3), (6.1, -6.45)], 0.06, 0.14, 0.2)                  # lower lid
    p.patch([(4.3, -8.45), (6.7, -8.75), (6.75, -8.3), (4.4, -8.0)], BROW, "hair", 0.06, 0.1, smooth=False)
    # the Link port behind the near ear: bruise ring, staples, steel rim, dark disc, lens
    px, py = PORT_AT
    p.tint(ellipse_pts(px, py, 1.9, 1.9, 0, 24), BRUISE, 0.42, 0.35, smooth=False)
    for k in range(6):
        a = 2 * math.pi * (k + 0.25) / 6
        sx, sy = px + 1.42 * math.cos(a), py + 1.42 * math.sin(a)
        p.patch(rot_pts(rect_pts(sx - 0.16, sy - 0.08, sx + 0.16, sy + 0.08), math.degrees(a), sx, sy),
                STAPLE * 0.9, "metal", 0.03, 0.05, smooth=False)
    p.patch(ellipse_pts(px, py, 1.12, 1.12, 0, 24), STEEL, "metal", 0.3, 0.1, smooth=False)
    p.patch(ellipse_pts(px, py, 0.88, 0.88, 0, 20), PORT, "plastic", -0.12, 0.08, smooth=False)
    # the lens is at least ~1.1 px across, so the 1/3-scale sprite never samples past it
    p.patch(ellipse_pts(px, py, 0.62, 0.62, 0, 16), PORT_LENS, "eye", -0.05, 0.06, smooth=False, emissive=1.0)
    # the seam from the port down the nape into the collar, faint lines under the skin
    p.seam([(px - 0.2, py + 1.3), (-3.1, -1.2), (-3.0, 1.0), (-3.4, 3.4)], 0.1, 0.16, 0.3)
    p.tint_stroke([(px + 0.5, py + 0.9), (-1.8, -1.6), (-2.2, 1.2), (-2.4, 3.4)], 0.28, VEIN, 0.35, 0.1)
    p.tint_stroke([(px + 0.9, py + 0.4), (-0.8, -2.4), (-1.3, 0.6), (-1.4, 3.4)], 0.24, VEIN, 0.25, 0.1)
    return p


def paint_upper_arm():
    p = Part("upper_arm", -3.5, -3.6, 3.6, 21.2)
    p.body([(-2.9, -1.4), (-1.1, -3.4), (1.5, -3.4), (3.2, -1.2), (3.3, 2.5), (3.0, 8.0), (2.6, 13.0),
            (2.3, 18.0), (1.7, 20.8), (-1.5, 21.0), (-2.4, 19.0), (-2.8, 13.0), (-3.1, 6.0), (-3.2, 1.0)],
           JACKET, "nylon", radius=3.0, dome=0.2)
    p.seam([(-2.8, -0.2), (-0.2, -1.6), (3.0, -0.6)], 0.15, 0.2, 0.4)                  # shoulder seam
    p.seam([(-2.2, 1.0), (-2.0, 12.0), (-1.8, 19.4)], 0.1, 0.16, 0.3)
    for a, b in (((-2.2, 14.6), (1.2, 16.4)), ((-2.0, 16.8), (0.8, 18.4)), ((-1.2, 19.0), (1.4, 19.9))):
        p.seam([a, b], 0.2, 0.32, 0.2)
    p.ridge([(-2.4, 15.8), (1.6, 17.6)], 0.14, 0.4)
    return p


def paint_forearm():
    """The far forearm: sleeve down to an elastic cuff."""
    p = Part("forearm", -2.9, -3.0, 3.1, 15.0)
    p.body([(-2.3, -1.4), (-0.4, -2.8), (1.7, -2.6), (2.6, -1.0), (2.7, 3.5), (2.4, 8.5), (2.0, 11.8),
            (2.1, 12.6), (2.0, 14.6), (-1.7, 14.8), (-1.9, 12.5), (-1.7, 11.8), (-2.4, 5.0), (-2.5, 0.5)],
           JACKET, "nylon", radius=2.4, dome=0.2)
    p.patch([(-2.2, 12.1), (2.3, 12.1), (2.3, 14.9), (-2.2, 14.9)], JACKET_DARK, "nylon", 0.3, 0.15, smooth=False)
    p.seam([(-1.9, 12.1), (2.0, 12.1)], 0.14, 0.2, 0.45)
    for x in (-0.8, 0.5, 1.5):
        p.seam([(x, 12.4), (x + 0.1, 14.6)], 0.06, 0.18, 0.2)
    for a, b in (((-2.1, 2.0), (1.4, 0.6)), ((-1.9, 4.2), (0.8, 3.0)), ((-1.7, 9.4), (1.2, 10.4))):
        p.seam([a, b], 0.14, 0.3, 0.15)
    return p


def paint_forearm_bare():
    """The near forearm: the sleeve pushed up above the elbow, bare skin below."""
    p = Part("forearm_bare", -3.3, -3.6, 3.4, 14.6)
    # skin first (hidden above the bunch), then the bunched sleeve over the elbow
    p.body([(-2.0, -1.0), (-0.2, -2.0), (1.8, -1.8), (2.5, 1.0), (2.6, 4.2), (2.2, 8.4), (1.7, 11.8),
            (1.8, 13.0), (1.5, 14.2), (-1.4, 14.4), (-1.7, 13.0), (-1.6, 11.8), (-2.3, 6.0), (-2.4, 1.4)],
           SKIN, "skin_matte", radius=2.2, dome=0.25)
    p.bump([(-2.2, 2.0), (1.6, 1.4), (2.3, 5.0), (-1.8, 6.4)], 0.35, 0.8)              # forearm muscle
    p.bump([(-1.4, 12.2), (-0.4, 12.0), (-0.3, 13.0), (-1.4, 13.2)], 0.2, 0.25)       # wrist bone
    p.tint([(-2.2, 4.0), (-0.6, 3.6), (-0.8, 10.0), (-1.8, 11.4)], SKIN_SHADE, 0.12, 0.8)
    bunch = [(-3.2, -2.6), (-1.2, -3.6), (1.6, -3.5), (3.3, -2.2), (3.4, 0.4), (3.0, 2.6), (1.2, 3.2),
             (-1.0, 3.0), (-2.9, 2.2), (-3.3, 0.0)]
    m = p.patch(bunch, JACKET, "nylon", 0.0, 0.3, clip=False)
    p.sil |= m
    d = lr.edt_inside(m)
    r = 2.0 * lr.R
    p.height = np.where(m, r * np.sqrt(1.0 - (1.0 - np.clip(d / r, 0, 1)) ** 2) + 0.35 * r, p.height)
    for a, b in (((-3.0, -1.2), (2.9, -1.8)), ((-2.9, 0.6), (3.2, 0.2)), ((-2.2, 2.0), (2.4, 1.8))):
        p.seam([a, (0.0, (a[1] + b[1]) / 2 + 0.5), b], 0.22, 0.3, 0.4)
    return p


def paint_hand():
    """A grip hand, open and clawed: the fingers hooked forward, the thumb reaching, a
    slate rubber pad strapped over the palm (its rim shows along the palm side),
    graphite wrist and hand straps. Seen from the back, as it hangs."""
    p = Part("hand", -2.4, -1.6, 4.0, 7.8)
    # back of the hand and the finger mass, hooked forward
    p.body([(-1.8, -1.3), (1.6, -1.3), (2.0, 0.6), (2.0, 2.2), (2.5, 3.6), (3.0, 5.0), (3.1, 6.3),
            (2.6, 7.4), (1.8, 7.6), (1.7, 6.8), (1.4, 5.9), (0.4, 5.6), (-0.8, 5.2), (-1.8, 4.2),
            (-2.1, 2.4), (-2.0, 0.6)], SKIN, "skin_matte", radius=1.8, dome=0.3)
    # the thumb, reaching forward, with a gap under it
    tm = p.patch([(1.2, 0.6), (2.6, 1.0), (3.6, 2.2), (3.9, 3.2), (3.4, 3.5), (2.5, 2.7), (1.4, 2.4)],
                 SKIN, "skin_matte", 0.0, 0.2, clip=False)
    p.sil |= tm
    p.lift(tm, 0.9, 0.3)
    p.seam([(1.5, 2.3), (2.6, 2.6), (3.4, 3.4)], 0.12, 0.18, 0.4)
    # fingers: grooves between them, knuckle bumps, the curled tips
    for x0, y0 in ((-1.2, 4.6), (-0.2, 5.0), (0.8, 5.4)):
        p.seam([(x0 - 0.2, y0 - 2.0), (x0 + 0.6, y0 - 0.4), (x0 + 1.4, y0 + 0.6)], 0.16, 0.18, 0.45)
    p.bump([(-1.7, 2.6), (1.9, 2.2), (2.1, 3.3), (-1.6, 3.8)], 0.3, 0.3)
    p.seam([(1.5, 6.0), (2.5, 6.6)], 0.1, 0.16, 0.35)
    # the padded grip: a slate rim along the palm side, under the curled fingers
    p.patch([(-2.3, 0.8), (-1.5, 1.0), (-1.2, 2.8), (-0.5, 4.4), (-1.0, 4.8), (-1.9, 4.0), (-2.2, 2.4)],
            GRIP, "rubber", 0.3, 0.2)
    # wrist strap and the strap across the back of the hand, a steel snap
    p.patch([(-2.3, -0.5), (2.1, -0.5), (2.2, 0.9), (-2.3, 0.9)], STRAP, "rubber", 0.3, 0.15, smooth=False)
    p.seam([(-2.0, 0.2), (1.9, 0.2)], 0.06, 0.12, 0.35)
    p.patch([(-2.2, 1.8), (1.4, 1.1), (1.8, 2.0), (-1.9, 2.8)], STRAP, "rubber", 0.22, 0.15, smooth=False)
    p.dot(1.3, 0.2, 0.28, STEEL, "metal", 0.1)
    return p


def paint_thigh():
    p = Part("thigh", -5.0, -4.6, 4.8, 25.6)
    p.body([(-4.5, -2.4), (-2.0, -4.4), (2.4, -4.4), (4.3, -2.0), (4.5, 3.0), (4.1, 10.0), (3.5, 17.0),
            (3.1, 21.5), (3.3, 23.4), (2.6, 25.4), (-2.3, 25.4), (-2.9, 23.0), (-3.4, 17.5), (-4.2, 10.0),
            (-4.7, 3.0), (-4.8, -1.0)], TROUSER, "cloth", radius=4.2, dome=0.3)
    p.ridge([(2.6, -3.0), (2.4, 8.0), (2.0, 20.0)], 0.12, 0.35)                        # pressed crease
    p.seam([(-0.4, -4.0), (-0.3, 10.0), (0.0, 25.2)], 0.12, 0.18, 0.3)                 # side seam
    for a, b in (((-2.8, 20.8), (0.6, 22.2)), ((-2.9, 22.6), (0.2, 24.0)), ((1.0, 23.4), (3.0, 22.4))):
        p.seam([a, b], 0.16, 0.32, 0.16)
    p.seam([(1.6, -3.6), (3.8, -1.4)], 0.1, 0.24, 0.16)
    return p


def paint_shin():
    """Trouser leg with the hem breaking over the shoe; the shoe collar below the hem."""
    p = Part("shin", -3.9, -3.0, 3.9, 23.8)
    p.body([(-2.8, -1.5), (-1.0, -2.8), (2.2, -2.8), (3.2, -1.0), (3.1, 5.0), (2.8, 12.0), (2.8, 17.0),
            (3.2, 19.4), (3.4, 21.0), (2.9, 21.4), (2.8, 23.6), (-3.1, 23.6), (-3.2, 22.3), (-3.6, 21.9),
            (-3.3, 17.0), (-3.6, 6.0), (-3.4, 1.5)], TROUSER, "cloth", radius=3.1, dome=0.25)
    # shoe collar and heel below the hem
    p.patch([(-3.4, 21.6), (2.9, 21.0), (2.9, 23.9), (-3.4, 23.9)], SHOE, "leather", -0.05, 0.2, smooth=False)
    # the hem: a soft break, longer at the back
    p.patch([(-3.7, 19.4), (3.3, 18.9), (3.5, 21.1), (-3.7, 22.1)], TROUSER, "cloth", 0.3, 0.25)
    p.seam([(-3.4, 22.0), (0.0, 21.5), (3.2, 21.0)], 0.2, 0.22, 0.55)
    for a, b in (((-2.4, 19.6), (-1.2, 21.4)), ((0.6, 19.2), (1.6, 21.0)), ((2.4, 17.6), (3.0, 19.2))):
        p.seam([a, b], 0.12, 0.28, 0.18)
    p.ridge([(2.3, -2.0), (2.2, 10.0), (2.4, 18.4)], 0.1, 0.35)                        # crease
    p.seam([(-0.3, -2.6), (-0.4, 10.0), (-0.3, 19.0)], 0.1, 0.16, 0.25)
    return p


def paint_foot():
    """A scuffed slate work shoe with a pale rubber cup sole."""
    p = Part("foot", -4.2, -1.3, 11.3, 4.6)
    p.body([(-3.4, -0.7), (-0.4, -1.0), (1.6, -0.6), (4.0, 0.1), (6.4, 0.6), (8.4, 0.8), (10.0, 1.3),
            (10.9, 2.3), (11.1, 3.4), (10.6, 4.45), (-3.7, 4.45), (-4.1, 3.4), (-4.0, 1.2)],
           SHOE, "leather", radius=2.2, dome=0.25)
    # pale cup sole with a seam and tread ticks
    p.patch([(-4.3, 2.85), (10.4, 2.85), (11.2, 3.3), (10.8, 4.6), (-4.3, 4.6)], SOLE, "rubber", 0.15, 0.1, smooth=False)
    p.seam([(-4.0, 2.9), (10.3, 2.9), (10.9, 3.3)], 0.1, 0.16, 0.45)
    for x in np.arange(-3.4, 10.2, 1.25):
        p.seam([(float(x), 4.2), (float(x) + 0.5, 4.2)], 0.06, 0.22, 0.25)
    # laces over the instep, the toe cap, the heel counter
    for k in range(4):
        x = 0.4 + k * 1.1
        p.seam([(x, -0.6 + k * 0.3), (x + 0.9, 0.1 + k * 0.3)], 0.08, 0.2, 0.45)
    p.seam([(0.0, -0.8), (4.6, 0.6)], 0.1, 0.16, 0.35)
    p.seam([(7.4, 0.8), (8.2, 1.9), (8.4, 2.8)], 0.12, 0.2, 0.3)
    p.patch(rect_pts(-4.2, -0.2, -2.4, 2.85, 0.4), SHOE, "leather", 0.15, 0.15, smooth=False)
    # scuffs on the toe and heel (lighter, worn leather)
    p.tint([(8.8, 1.1), (10.6, 1.8), (10.9, 2.7), (9.0, 2.4)], hexc("#6B7A8F"), 0.4, 0.3)
    p.tint([(-4.0, 1.2), (-3.2, 0.8), (-3.1, 2.7), (-4.0, 2.8)], hexc("#6B7A8F"), 0.3, 0.25)
    return p


# --- rig definition (world px, local to the parent part; y down) -----------------------------
# z: far arm < far leg < pelvis < near leg < torso < head < near arm (as the Night Guard)
RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit(deg)
    ("pelvis", "pelvis", "", (0.0, -49.5), 3, False, {"type": "capsule", "a": [-3.2, -1.0], "b": [3.0, -1.0], "r": 5.2}, 11.0, None),
    ("torso", "torso", "pelvis", (0.3, -5.5), 5, False, {"type": "capsule", "a": [0.0, -2.0], "b": [0.0, -21.5], "r": 6.0}, 22.0, [-35, 75]),
    ("head", "head", "torso", (1.4, -28.6), 6, False, {"type": "circle", "c": [0.9, -6.4], "r": 6.3}, 5.0, [-40, 45]),
    ("far_upper_arm", "upper_arm", "torso", (0.6, -21.6), 1, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 18.5], "r": 2.6}, 2.3, [-175, 70]),
    ("far_forearm", "forearm", "far_upper_arm", (0.0, 18.5), 1, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 14.0], "r": 2.1}, 1.6, [-145, 0]),
    ("far_hand", "hand", "far_forearm", (0.0, 14.0), 1, True, {"type": "circle", "c": [0.6, 3.0], "r": 2.6}, 0.6, [-60, 60]),
    ("far_thigh", "thigh", "pelvis", (0.4, 0.0), 2, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 23.5], "r": 4.0}, 7.5, [-110, 40]),
    ("far_shin", "shin", "far_thigh", (0.0, 23.5), 2, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 21.5], "r": 2.9}, 3.6, [0, 150]),
    ("far_foot", "foot", "far_shin", (0.0, 21.5), 2, True, {"type": "capsule", "a": [-2.2, 2.6], "b": [9.0, 2.6], "r": 1.9}, 1.2, [-40, 35]),
    ("near_thigh", "thigh", "pelvis", (0.4, 0.0), 4, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 23.5], "r": 4.0}, 7.5, [-110, 40]),
    ("near_shin", "shin", "near_thigh", (0.0, 23.5), 4, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 21.5], "r": 2.9}, 3.6, [0, 150]),
    ("near_foot", "foot", "near_shin", (0.0, 21.5), 4, False, {"type": "capsule", "a": [-2.2, 2.6], "b": [9.0, 2.6], "r": 1.9}, 1.2, [-40, 35]),
    ("near_upper_arm", "upper_arm", "torso", (0.6, -21.6), 7, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 18.5], "r": 2.6}, 2.3, [-175, 70]),
    ("near_forearm", "forearm_bare", "near_upper_arm", (0.0, 18.5), 8, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 14.0], "r": 2.1}, 1.6, [-145, 0]),
    ("near_hand", "hand", "near_forearm", (0.0, 14.0), 10, False, {"type": "circle", "c": [0.6, 3.0], "r": 2.6}, 0.6, [-60, 60]),
]
# Rest directions: what a joint's bone points along at zero rotation (canvas angle).
REST_DIR = {"pelvis": -90, "torso": -90, "head": -90, "foot": 0}
# Sole points of the shoe in foot-local world px (heel, ball, toe).
SOLE_POINTS = [(-3.9, 4.5), (4.0, 4.5), (10.6, 4.5)]
# Light and effect sockets, joint-local world px.
SOCKETS = {
    "port_light": ("head", PORT_AT),    # the small steady amber point; implant sparks
    "grip_near": ("near_hand", (0.4, 3.4)),  # the tell glows on the palms
    "grip_far": ("far_hand", (0.4, 3.4)),
}
PAINTERS = {
    "pelvis": paint_pelvis, "torso": paint_torso, "head": paint_head, "upper_arm": paint_upper_arm,
    "forearm": paint_forearm, "forearm_bare": paint_forearm_bare, "hand": paint_hand,
    "thigh": paint_thigh, "shin": paint_shin, "foot": paint_foot,
}


def rest_dir(name):
    for k, v in REST_DIR.items():
        if name.endswith(k):
            return v
    return 90


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rest_dir(n)}
            for (n, pt, par, pos, z, far, col, mass, lim) in RIG]


# Preview poses (degrees; the lead's hand-keyed clips live in scripts/actors/lit/clips_staffer.gd).
STAND = {"torso": 1, "head": 6, "near_upper_arm": 2, "near_forearm": -4, "near_hand": 4, "far_upper_arm": -2,
         "far_forearm": -6, "far_hand": 4, "near_thigh": -1, "near_shin": 2, "far_thigh": 2, "far_shin": 2}
WALK = {"pelvis": 1, "head": 2, "near_thigh": -18, "near_shin": 3, "far_thigh": 16, "far_shin": 8,
        "near_upper_arm": 3, "near_forearm": -3, "far_upper_arm": -2, "far_forearm": -4, "near_foot": 8, "far_foot": -9}
CROUCH = {"pelvis": 8, "torso": 26, "head": -18, "near_upper_arm": -66, "near_forearm": -16, "near_hand": 14,
          "far_upper_arm": -72, "far_forearm": -12, "far_hand": 14, "near_thigh": -40, "near_shin": 62,
          "far_thigh": -14, "far_shin": 48}


def main():
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results)
    lr.write_rig_json(OUT_DIR, "LK01 Staffer", "human", parts_json, joints(), ground_lock=True,
                      sole_points=SOLE_POINTS, sockets=SOCKETS)
    out = lr.preview_arg()
    if out:
        preview(parts, results, out)
    print("atlas", size[0], size[1], "->", OUT_DIR)


def preview(parts, results, out_dir):
    js = joints()
    port = {"head": (lr.hexc("#FFB02E"), 1.4)}
    lr.preview_rig(os.path.join(out_dir, "staffer_preview.png"), js, parts, results,
                   [("stand", STAND, port), ("rest", {}, port), ("walk", WALK, port), ("crouch (tell)", CROUCH, port)],
                   (-40, -110, 80, 116), root_fn=lambda pose: lr.ground_offset(js, pose, SOLE_POINTS))


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Paint the SE01 Night Guard lit-cutout rig (C35), procedurally.

The approved lit-cutout test's guard, unchanged: every part is drawn once, flat
(no baked light), in its own local frame with the joint pivot at (0, 0), +x = the
direction the guard faces, +y = down the bone (arms and legs hang down in the rest
pose; the torso, pelvis and head point up). lit_rig_common.py turns the parts into
the atlas, the normal map and the rig JSON.

Outputs (assets/characters/lit/night_guard/):
  albedo.png  flat base colours, dark outlines, mild cavity shade
  normal.png  normals (R = +x, G = +y up, B = z; flat = (128, 128, 255))
  spec.png    R = specular strength, G = gloss, B = emissive mask (baton tip,
              chest lamp lens, radio LED), A = alpha
  rig.json    atlas rects, pivots, hierarchy, z order, ragdoll colliders, masses,
              joint limits, sole points and light sockets

`--preview DIR` also writes preview images (rest pose and a walk pose under a lamp,
at gameplay size) into DIR.

Run from the project root:  python3 tools/art/paint_night_guard.py [--preview DIR]
"""
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, R, edt_inside, ellipse_pts, gblur, hexc, rect_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "night_guard")
SEED = 20260929

# --- palette (sRGB) ------------------------------------------------------------------
SKIN = hexc("#AC7658")
SKIN_SHADE = hexc("#8D5E46")
HAIR = hexc("#2A2220")
SHIRT = hexc("#6A737E")
VEST = hexc("#2B3037")
VEST_WEB = hexc("#23272D")
TROUSER = hexc("#3D444E")
BELT = hexc("#1B1D21")
METAL = hexc("#A8B0B8")
GLOVE = hexc("#1A1C20")
BOOT = hexc("#16181B")
SOLE = hexc("#0E0F11")
CAP = hexc("#2E343C")
BRIM = hexc("#121418")
STRIPE = hexc("#C4CBD2")
EMBLEM = hexc("#E6ECF0")
PATCH = hexc("#3A424C")
RADIO = hexc("#151719")
LAMP_BODY = hexc("#2B2E33")
LAMP_LENS = hexc("#FFE7BF")
LED = hexc("#4DE38A")
BATON_GRIP = hexc("#1D1F23")
BATON_SHAFT = hexc("#3A3F46")
BATON_TIP = hexc("#A7AFB8")
EYE_WHITE = hexc("#D9D4CC")
IRIS = hexc("#2B211C")
LIP = hexc("#8E5A48")


# --- the parts ------------------------------------------------------------------------------
def paint_pelvis():
    p = Part("pelvis", -7.2, -8.0, 6.4, 6.8)
    p.body([(-5.6, -7.8), (-6.3, -4.0), (-6.9, 0.0), (-6.6, 3.6), (-5.2, 6.1), (-1.5, 6.5),
            (2.0, 6.1), (4.6, 4.0), (5.7, 0.4), (5.9, -3.6), (5.7, -7.8)], TROUSER, "cloth", radius=4.0, dome=0.3)
    # belt, buckle, loops, pouch
    p.patch([(-7.5, -7.9), (6.5, -7.9), (6.5, -4.7), (-7.5, -4.7)], BELT, "leather", 0.35, 0.2, smooth=False)
    p.seam([(-7, -7.5), (6.2, -7.5)], 0.08, 0.14, 0.3)
    p.seam([(-7, -5.1), (6.2, -5.1)], 0.08, 0.14, 0.3)
    p.patch(rect_pts(4.1, -7.5, 6.1, -5.0, 0.3), METAL, "metal", 0.25, 0.12, smooth=False)
    p.patch(rect_pts(4.55, -7.0, 5.65, -5.5, 0.2), BELT, "leather", -0.08, 0.1, smooth=False)
    for x in (-4.8, 2.4):
        p.patch(rect_pts(x, -8.0, x + 0.8, -4.5, 0.2), BELT, "leather", 0.2, 0.1, smooth=False)
    p.patch(rect_pts(-4.4, -5.6, -0.7, 0.9, 0.7), BELT, "nylon", 0.55, 0.35, smooth=False)   # duty pouch
    p.patch(rect_pts(-4.4, -5.6, -0.7, -3.6, 0.5), VEST_WEB, "nylon", 0.2, 0.2, smooth=False)  # pouch flap
    p.dot(-2.55, -4.2, 0.35, METAL, "metal")
    # trouser seams and back pocket
    p.seam([(2.6, -4.6), (2.9, -1), (2.6, 2.4), (1.4, 6.2)], 0.14, 0.2, 0.35)
    p.seam([(0.2, -4.6), (0.3, 1.0), (0.2, 6.3)], 0.12, 0.18, 0.3)
    p.seam([(-6.3, -3.6), (-3.8, -3.8), (-3.9, 0.6), (-6.4, 0.9)], 0.1, 0.16, 0.3)
    for a, b in (((3.8, 1.5), (5.2, 3.2)), ((3.2, 3.2), (4.6, 5.0))):
        p.seam([a, b], 0.1, 0.25, 0.18)
    return p


def paint_torso():
    p = Part("torso", -7.4, -30.0, 8.2, 3.0)
    # neck (skin) first, so the collar and vest paint over it
    p.body([(-3.0, -26.5), (-2.8, -30.0), (2.1, -30.0), (2.6, -26.8)], SKIN, "skin", radius=2.2, dome=0.2)
    p.body([(-5.4, 2.8), (-5.2, -3.0), (-6.3, -12.0), (-7.0, -19.0), (-6.6, -23.6), (-5.0, -25.9),
            (-3.2, -27.0), (0.0, -27.4), (2.8, -27.0), (4.1, -25.4), (6.5, -22.6), (7.7, -17.5),
            (7.4, -12.0), (6.7, -6.0), (6.4, -1.0), (6.1, 2.8)], VEST, "nylon", radius=5.2, dome=0.45)
    sil = p.sil.copy()
    # shirt shows below the vest (tucked) and as a collar
    p.patch([(-6.0, -1.2), (7.0, -1.2), (7.0, 3.2), (-6.0, 3.2)], SHIRT, "cloth", 0.0, 0.2, smooth=False)
    p.seam([(-5.4, -1.1), (6.6, -1.2)], 0.25, 0.3, 0.55)
    for x in (-3.0, 0.5, 3.5):
        p.seam([(x, -0.6), (x + 0.4, 2.8)], 0.08, 0.3, 0.15)
    p.patch([(-4.2, -27.4), (-3.4, -24.6), (0.5, -24.2), (3.9, -24.9), (4.3, -26.0), (2.9, -27.6), (0.0, -27.8)],
            SHIRT, "cloth", 0.45, 0.3)
    p.seam([(-3.6, -24.8), (0.5, -24.4), (3.8, -25.0)], 0.1, 0.18, 0.4)
    # vest structure: shoulder strap edge, side panel seam, MOLLE rows, front closure
    p.seam([(-5.2, -25.6), (-1.0, -24.3), (4.2, -24.6)], 0.2, 0.22, 0.5)
    p.seam([(-1.2, -24.0), (-0.8, -14.0), (-0.9, -1.4)], 0.16, 0.2, 0.45)
    for y in (-13.6, -10.6, -7.6, -4.6):
        p.patch([(1.2, y), (6.9, y - 0.1), (6.9, y + 1.25), (1.2, y + 1.25)], VEST_WEB, "nylon", 0.22, 0.12, smooth=False)
        for x in (2.6, 4.2, 5.8):
            p.seam([(x, y + 0.1), (x, y + 1.15)], 0.1, 0.16, 0.5)
    p.seam([(6.4, -21.6), (7.2, -12.0), (6.3, -1.4)], 0.12, 0.2, 0.35)
    # radio speaker-mic on the front strap, curly cord over the shoulder
    p.patch(rect_pts(3.3, -24.4, 6.0, -20.4, 0.7), RADIO, "plastic", 0.6, 0.25, smooth=False)
    p.patch(rect_pts(3.7, -23.9, 5.6, -22.1, 0.35), hexc("#202328"), "plastic", -0.15, 0.1, smooth=False)
    for y in (-23.5, -23.0, -22.5):
        p.seam([(3.9, y), (5.4, y)], 0.05, 0.12, 0.4)
    p.dot(5.15, -21.0, 0.28, LED, "plastic", 0.05, emissive=1.0)
    cord = [(3.4, -22.0), (1.5, -23.5), (-1.5, -24.6), (-3.8, -24.3)]
    p.ridge(cord, 0.25, 0.45)
    p.seam(cord, 0.0, 0.4, 0.5)
    # chest-clip lamp (neutral warm lens, drawn as an emissive glow in-engine)
    p.patch(rect_pts(5.9, -17.4, 7.9, -15.3, 0.5), LAMP_BODY, "metal", 0.55, 0.2, smooth=False)
    p.patch(ellipse_pts(7.75, -16.35, 0.45, 0.85, 0, 20), LAMP_LENS, "eye", 0.1, 0.1, smooth=False, clip=False, emissive=1.0)
    # Arcadia emblem (an arch with a leaf) — white, small, not a badge
    arch = []
    for k in range(13):
        a = math.pi + math.pi * k / 12
        arch.append((3.4 + 1.25 * math.cos(a), -17.8 + 1.25 * math.sin(a)))
    p.patch(arch + [(4.65, -17.4), (4.2, -17.4), (4.2, -17.8)] + [(3.4 + 0.8 * math.cos(math.pi + math.pi * k / 12), -17.8 + 0.8 * math.sin(math.pi + math.pi * k / 12)) for k in range(12, -1, -1)] + [(2.6, -17.8), (2.6, -17.4), (2.15, -17.4)],
            EMBLEM, "plastic", 0.12, 0.1, smooth=False)
    p.patch(ellipse_pts(3.4, -17.9, 0.32, 0.55, 0.3, 16), EMBLEM, "plastic", 0.1, 0.1, smooth=False)
    # back: a strap pull loop and a seam
    p.patch(rect_pts(-6.9, -22.5, -5.8, -19.6, 0.3), VEST_WEB, "nylon", 0.25, 0.12, smooth=False)
    p.seam([(-5.6, -20.5), (-5.0, -8.0), (-4.8, -1.4)], 0.1, 0.18, 0.3)
    p.sil = sil
    return p


def paint_head():
    p = Part("head", -6.4, -16.8, 10.6, 3.0)
    face = [(-2.6, 2.8), (-3.3, 0.2), (-4.9, -3.0), (-5.6, -6.4), (-5.5, -9.4), (-3.4, -11.4),
            (1.0, -12.0), (4.6, -11.2), (5.9, -10.0), (6.35, -8.45), (6.0, -7.8), (6.05, -7.0),
            (7.15, -5.35), (5.65, -4.6), (5.95, -3.9), (5.45, -3.35), (5.75, -2.8), (5.6, -1.8),
            (5.3, -0.8), (3.9, 0.2), (2.8, 0.6), (2.3, 2.8)]
    p.body(face, SKIN, "skin", radius=4.0, dome=0.45, samples=8)
    # stubble / jaw shade, lips
    p.tint([(1.2, -1.6), (2.8, -3.2), (5.2, -3.0), (5.6, -1.6), (5.1, -0.7), (3.8, 0.2), (1.4, 0.4)],
           SKIN_SHADE, 0.38, 0.5)
    p.patch([(5.25, -3.55), (5.95, -3.85), (5.8, -3.3), (5.2, -3.2)], LIP, "skin", 0.08, 0.1, smooth=False)
    p.patch([(5.2, -3.0), (5.8, -2.8), (5.55, -2.35), (5.1, -2.5)], LIP, "skin", 0.1, 0.1, smooth=False)
    # hair under the cap, sideburn
    p.patch([(-5.7, -9.2), (-1.8, -9.4), (-1.2, -7.6), (-2.6, -6.2), (-4.4, -3.4), (-5.2, -4.5), (-5.7, -7.0)],
            HAIR, "hair", 0.15, 0.2)
    p.patch([(1.0, -8.9), (2.05, -8.9), (1.95, -5.6), (1.1, -5.9)], HAIR, "hair", 0.08, 0.12, smooth=False)
    # facial form: brow ridge, nose, cheekbone, lips, chin, jaw edge, eye socket
    p.bump([(3.4, -8.6), (6.3, -8.7), (6.2, -7.7), (3.5, -7.6)], 0.55, 0.4)
    p.bump([(5.7, -7.3), (7.1, -5.3), (5.8, -4.8)], 0.9, 0.35)
    p.bump([(0.2, -5.8), (3.8, -6.0), (4.5, -4.3), (0.8, -3.6)], 0.45, 0.6)
    p.bump([(3.6, -1.6), (5.4, -1.8), (5.3, -0.6), (3.6, -0.3)], 0.35, 0.45)
    p.seam([(0.4, 0.2), (2.4, -0.2), (4.2, -0.5)], 0.12, 0.3, 0.12)
    p.seam([(3.5, -7.1), (4.6, -7.35), (5.3, -6.9)], 0.3, 0.45, 0.0)
    p.seam([(4.7, -4.4), (5.2, -3.9)], 0.12, 0.2, 0.2)
    p.seam([(5.25, -3.25), (5.8, -3.3)], 0.1, 0.18, 0.5)
    # ear
    p.patch(ellipse_pts(-0.7, -5.9, 1.45, 2.25, 0.12, 28), SKIN, "skin", 0.45, 0.25, smooth=False)
    p.seam([(-0.2, -7.6), (-1.3, -7.0), (-1.4, -5.2), (-0.6, -4.2)], 0.25, 0.28, 0.3)
    p.patch(ellipse_pts(-0.5, -5.8, 0.45, 0.7, 0.1, 16), SKIN_SHADE, "skin", -0.2, 0.2, smooth=False)
    # eye, eyelid, brow hair
    p.patch(ellipse_pts(4.55, -6.55, 0.62, 0.34, 0.08, 18), EYE_WHITE, "eye", -0.05, 0.1, smooth=False)
    p.patch(ellipse_pts(4.85, -6.55, 0.32, 0.32, 0.0, 14), IRIS, "eye", 0.0, 0.1, smooth=False)
    p.seam([(3.95, -6.85), (4.6, -7.0), (5.2, -6.75)], 0.08, 0.2, 0.75, smooth=True)
    p.patch([(3.3, -7.9), (5.7, -8.3), (5.75, -7.85), (3.4, -7.45)], HAIR, "hair", 0.08, 0.1, smooth=False)
    # cap: crown, band, brim, emblem
    crown = [(-5.9, -8.6), (-5.4, -12.6), (-3.2, -15.3), (0.0, -16.3), (3.6, -15.7), (5.5, -13.4),
             (6.0, -10.0), (5.6, -9.2), (0.0, -9.0)]
    cm = p.patch(crown, CAP, "nylon", 0.0, 0.3, clip=False)
    p.sil |= cm
    d = edt_inside(cm)
    r = 3.6 * R
    p.height = np.where(cm, r * np.sqrt(1.0 - (1.0 - np.clip(d / r, 0, 1)) ** 2) + 0.3 * r, p.height)
    p.patch([(-5.95, -10.9), (6.1, -11.2), (6.05, -9.1), (-5.9, -8.7)], BRIM, "nylon", 0.25, 0.2)
    p.seam([(-5.4, -12.8), (0.0, -13.4), (5.5, -13.3)], 0.12, 0.2, 0.3)
    p.seam([(0.0, -16.1), (0.4, -11.3)], 0.12, 0.2, 0.3)
    brim = [(5.0, -9.95), (8.6, -9.55), (10.35, -8.95), (10.2, -8.45), (8.4, -8.75), (5.0, -8.8)]
    bm = p.patch(brim, BRIM, "leather", 0.0, 0.2, clip=False)
    p.sil |= bm
    p.height = np.where(bm, 0.9 * R * gblur(bm.astype(np.float32), 0.25 * R), p.height)
    p.patch(rect_pts(3.9, -12.9, 5.4, -11.35, 0.25), EMBLEM, "plastic", 0.15, 0.1, smooth=False)
    p.patch(rect_pts(4.25, -12.55, 5.05, -11.7, 0.2), CAP, "nylon", -0.05, 0.1, smooth=False)
    return p


def paint_upper_arm():
    p = Part("upper_arm", -3.8, -3.8, 3.9, 21.8)
    p.body([(-3.0, -1.5), (-1.2, -3.5), (1.6, -3.5), (3.4, -1.2), (3.6, 2.5), (3.4, 8.0), (2.9, 13.0),
            (2.5, 18.5), (1.8, 21.4), (-1.6, 21.6), (-2.6, 19.5), (-3.1, 13.0), (-3.4, 6.0), (-3.4, 1.0)],
           SHIRT, "cloth", radius=3.2, dome=0.2)
    p.patch([(-4.0, 6.4), (4.0, 6.4), (4.0, 7.9), (-4.0, 7.9)], STRIPE, "stripe", 0.2, 0.12, smooth=False)
    p.patch(rect_pts(-1.6, 1.0, 1.9, 4.9, 0.5), PATCH, "cloth", 0.18, 0.15, smooth=False)
    arch = [(0.15 + 1.0 * math.cos(math.pi + math.pi * k / 10), 3.6 + 1.0 * math.sin(math.pi + math.pi * k / 10)) for k in range(11)]
    inner = [(0.15 + 0.6 * math.cos(math.pi + math.pi * k / 10), 3.6 + 0.6 * math.sin(math.pi + math.pi * k / 10)) for k in range(10, -1, -1)]
    p.patch(arch + inner, EMBLEM, "plastic", 0.08, 0.08, smooth=False)
    p.seam([(-3.0, -0.2), (-0.2, -1.6), (3.2, -0.6)], 0.15, 0.2, 0.4)
    for a, b in (((-2.4, 15.5), (1.2, 17.2)), ((-2.2, 17.4), (0.6, 18.9)), ((-1.2, 19.6), (1.6, 20.4))):
        p.seam([a, b], 0.2, 0.34, 0.2)
    p.ridge([(-2.8, 16.6), (1.8, 18.4)], 0.14, 0.4)
    return p


def paint_forearm():
    p = Part("forearm", -3.1, -3.0, 3.3, 15.8)
    p.body([(-2.4, -1.5), (-0.5, -2.9), (1.8, -2.7), (2.7, -1.0), (2.9, 3.5), (2.5, 9.0), (2.0, 12.7),
            (2.2, 13.4), (2.1, 15.4), (-1.8, 15.6), (-2.0, 13.3), (-1.7, 12.7), (-2.6, 5.0), (-2.6, 0.5)],
           SHIRT, "cloth", radius=2.6, dome=0.2)
    p.patch([(-2.3, 12.9), (2.4, 12.9), (2.4, 15.7), (-2.3, 15.7)], SHIRT, "cloth", 0.3, 0.15, smooth=False)
    p.seam([(-2.0, 12.9), (2.1, 12.9)], 0.14, 0.2, 0.45)
    p.dot(1.5, 14.2, 0.28, hexc("#23262B"), "plastic", 0.1)
    for a, b in (((-2.2, 2.0), (1.4, 0.6)), ((-2.0, 4.0), (0.8, 3.0)), ((-1.8, 9.5), (1.2, 10.5))):
        p.seam([a, b], 0.14, 0.3, 0.15)
    return p


def paint_hand():
    p = Part("hand", -2.5, -1.8, 3.3, 7.3)
    p.body([(-1.9, -1.4), (1.9, -1.4), (2.6, 0.6), (3.0, 2.6), (2.9, 4.8), (2.2, 6.6), (0.3, 7.0),
            (-1.4, 6.3), (-2.1, 4.0), (-2.2, 1.0)], GLOVE, "leather", radius=2.2, dome=0.35)
    p.patch([(-2.4, -1.8), (2.3, -1.8), (2.4, 0.4), (-2.4, 0.4)], GLOVE, "leather", 0.25, 0.15, smooth=False)
    p.seam([(-2.1, 0.35), (2.2, 0.35)], 0.15, 0.2, 0.5)
    for y in (2.35, 3.75, 5.1):
        p.seam([(1.0, y), (2.95, y + 0.1)], 0.2, 0.24, 0.55)
    p.bump([(1.2, 0.6), (3.1, 0.9), (2.9, 2.2), (1.3, 2.0)], 0.35, 0.3)       # thumb over the grip
    p.seam([(1.2, 2.05), (2.9, 2.25)], 0.15, 0.2, 0.5)
    p.bump([(-1.6, 1.2), (0.8, 1.0), (0.9, 4.6), (-1.5, 4.8)], 0.25, 0.8)     # back of the hand
    return p


def paint_thigh():
    p = Part("thigh", -5.2, -4.8, 5.0, 26.3)
    p.body([(-4.6, -2.5), (-2.0, -4.6), (2.5, -4.6), (4.4, -2.2), (4.7, 3.0), (4.4, 10.0), (3.8, 17.0),
            (3.4, 22.0), (3.6, 24.2), (2.8, 26.1), (-2.4, 26.1), (-3.0, 23.5), (-3.6, 18.0), (-4.4, 10.0),
            (-4.9, 3.0), (-4.9, -1.0)], TROUSER, "cloth", radius=4.4, dome=0.3)
    p.patch(rect_pts(-2.6, 8.4, 2.8, 15.8, 0.5), TROUSER, "cloth", 0.4, 0.25, smooth=False)       # cargo pocket
    p.patch(rect_pts(-2.8, 8.2, 3.0, 10.3, 0.4), TROUSER, "cloth", 0.25, 0.15, smooth=False)      # its flap
    p.seam([(-2.7, 10.3), (2.9, 10.3)], 0.12, 0.18, 0.45)
    p.dot(0.1, 9.4, 0.3, BELT, "plastic", 0.08)
    p.seam([(-0.3, -4.0), (-0.1, 8.2)], 0.12, 0.18, 0.35)
    p.seam([(-0.1, 15.9), (0.2, 25.8)], 0.12, 0.18, 0.35)
    for a, b in (((-2.8, 21.5), (0.6, 22.8)), ((-2.9, 23.2), (0.2, 24.6)), ((1.0, 23.8), (3.0, 22.9))):
        p.seam([a, b], 0.18, 0.32, 0.18)
    p.ridge([(-2.6, 22.4), (0.8, 23.8)], 0.12, 0.35)
    return p


def paint_shin():
    p = Part("shin", -4.3, -3.0, 3.9, 24.2)
    p.body([(-2.9, -1.5), (-1.0, -2.9), (2.3, -2.9), (3.4, -1.0), (3.3, 5.0), (3.0, 12.0), (2.9, 15.4),
            (3.25, 15.9), (3.1, 21.0), (2.9, 24.1), (-2.8, 24.1), (-3.0, 21.0), (-3.35, 15.9), (-3.9, 6.0),
            (-3.6, 1.5)], TROUSER, "cloth", radius=3.3, dome=0.25)
    # trouser bloused over the boot, then the boot shaft
    p.patch([(-3.7, 13.4), (3.4, 13.1), (3.5, 16.1), (-3.8, 16.2)], TROUSER, "cloth", 0.35, 0.3)
    for x in (-2.0, 0.2, 2.1):
        p.seam([(x, 13.6), (x + 0.3, 15.9)], 0.14, 0.3, 0.2)
    p.patch([(-3.6, 16.0), (3.5, 15.9), (3.4, 24.3), (-3.3, 24.3)], BOOT, "boot", 0.25, 0.2, smooth=False)
    p.seam([(-3.3, 16.0), (3.3, 15.9)], 0.15, 0.2, 0.5)
    for y in (17.0, 18.6, 20.2, 21.8):
        p.dot(2.55, y, 0.3, METAL, "metal", 0.12)
    p.seam([(2.2, 16.3), (2.1, 23.8)], 0.12, 0.16, 0.4)
    p.seam([(-3.0, 20.6), (0.0, 19.9)], 0.12, 0.24, 0.25)
    return p


def paint_foot():
    p = Part("foot", -4.5, -2.8, 13.4, 5.4)
    p.body([(-2.9, -2.7), (2.8, -2.7), (4.5, -0.6), (9.5, 1.2), (12.5, 2.8), (13.1, 4.0), (12.6, 5.25),
            (-3.9, 5.25), (-4.4, 3.8), (-4.1, 0.5), (-3.3, -1.5)], BOOT, "boot", radius=2.6, dome=0.25)
    p.patch([(-4.6, 3.95), (13.3, 3.95), (13.3, 5.3), (-4.6, 5.3)], SOLE, "rubber", 0.15, 0.1, smooth=False)
    for x in range(-3, 13, 2):
        p.seam([(x + 0.3, 4.5), (x + 0.9, 4.5)], 0.08, 0.3, 0.4)
    p.seam([(-4.2, 3.9), (13.0, 3.9)], 0.1, 0.16, 0.5)
    p.seam([(7.8, 1.1), (8.9, 2.5), (9.3, 3.8)], 0.12, 0.2, 0.35)                   # toe cap
    for k in range(4):
        x = 2.9 + k * 0.95
        p.seam([(x, -1.9 + k * 0.62), (x + 0.9, -1.2 + k * 0.62)], 0.08, 0.22, 0.45)
    p.seam([(2.6, -2.4), (6.6, 0.3)], 0.12, 0.18, 0.4)
    p.patch(rect_pts(-4.3, 0.2, -2.6, 3.8, 0.4), BOOT, "boot", 0.15, 0.15, smooth=False)       # heel counter
    return p


def paint_baton():
    p = Part("baton", -1.3, -6.4, 1.3, 27.2)
    p.body([(-0.95, -6.2), (0.95, -6.2), (1.0, 5.4), (0.78, 5.6), (0.78, 15.0), (0.62, 15.2), (0.62, 24.0),
            (0.98, 24.3), (0.95, 27.0), (-0.95, 27.0), (-0.98, 24.3), (-0.62, 24.0), (-0.62, 15.2),
            (-0.78, 15.0), (-0.78, 5.6), (-1.0, 5.4)], BATON_SHAFT, "metal", radius=0.9, dome=0.0, smooth=False)
    p.patch([(-1.1, -6.3), (1.1, -6.3), (1.1, 5.5), (-1.1, 5.5)], BATON_GRIP, "rubber", 0.05, 0.1, smooth=False)
    for y in np.arange(-5.0, 5.0, 0.9):
        p.seam([(-1.0, float(y)), (1.0, float(y) + 0.3)], 0.06, 0.18, 0.35)
    p.patch([(-1.1, 24.1), (1.1, 24.1), (1.1, 27.2), (-1.1, 27.2)], BATON_TIP, "metal", 0.05, 0.1, smooth=False, emissive=1.0)
    p.seam([(-1.0, 25.4), (1.0, 25.4)], 0.1, 0.18, 0.5)
    p.seam([(-0.8, 15.1), (0.8, 15.1)], 0.08, 0.14, 0.5)
    p.seam([(-0.95, 5.5), (0.95, 5.5)], 0.08, 0.14, 0.5)
    return p

# --- rig definition (world px, local to the parent part; y down) -----------------------------
# z: far arm < far leg < pelvis < near leg < torso < head < near arm (baton under the fist)
RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit(deg)
    ("pelvis", "pelvis", "", (0.0, -51.0), 3, False, {"type": "capsule", "a": [-3.2, -1.0], "b": [3.2, -1.0], "r": 5.4}, 12.0, None),
    ("torso", "torso", "pelvis", (0.3, -6.0), 5, False, {"type": "capsule", "a": [0.3, -2.0], "b": [0.3, -22.0], "r": 6.4}, 25.0, [-35, 75]),
    ("head", "head", "torso", (1.6, -28.5), 6, False, {"type": "circle", "c": [1.0, -6.4], "r": 6.2}, 5.0, [-40, 45]),
    ("far_upper_arm", "upper_arm", "torso", (0.2, -23.5), 1, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 19.5], "r": 2.8}, 2.5, [-175, 70]),
    ("far_forearm", "forearm", "far_upper_arm", (0.0, 19.5), 1, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 14.5], "r": 2.3}, 1.8, [-145, 0]),
    ("far_hand", "hand", "far_forearm", (0.0, 14.5), 1, True, {"type": "circle", "c": [0.4, 2.8], "r": 2.6}, 0.7, [-60, 60]),
    ("far_thigh", "thigh", "pelvis", (0.4, 0.0), 2, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 24.0], "r": 4.2}, 8.0, [-110, 40]),
    ("far_shin", "shin", "far_thigh", (0.0, 24.0), 2, True, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 22.0], "r": 3.1}, 4.0, [0, 150]),
    ("far_foot", "foot", "far_shin", (0.0, 22.0), 2, True, {"type": "capsule", "a": [-2.5, 2.8], "b": [10.5, 2.8], "r": 2.1}, 1.5, [-40, 35]),
    ("near_thigh", "thigh", "pelvis", (0.4, 0.0), 4, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 24.0], "r": 4.2}, 8.0, [-110, 40]),
    ("near_shin", "shin", "near_thigh", (0.0, 24.0), 4, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 22.0], "r": 3.1}, 4.0, [0, 150]),
    ("near_foot", "foot", "near_shin", (0.0, 22.0), 4, False, {"type": "capsule", "a": [-2.5, 2.8], "b": [10.5, 2.8], "r": 2.1}, 1.5, [-40, 35]),
    ("near_upper_arm", "upper_arm", "torso", (0.2, -23.5), 7, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 19.5], "r": 2.8}, 2.5, [-175, 70]),
    ("near_forearm", "forearm", "near_upper_arm", (0.0, 19.5), 8, False, {"type": "capsule", "a": [0.0, 0.0], "b": [0.0, 14.5], "r": 2.3}, 1.8, [-145, 0]),
    ("near_hand", "hand", "near_forearm", (0.0, 14.5), 10, False, {"type": "circle", "c": [0.4, 2.8], "r": 2.6}, 0.7, [-60, 60]),
    ("baton", "baton", "near_hand", (0.7, 3.4), 9, False, {"type": "capsule", "a": [0.0, -4.5], "b": [0.0, 25.0], "r": 1.9}, 0.6, None),
]
# Rest directions: what a joint's bone points along at zero rotation (canvas angle).
REST_DIR = {"pelvis": -90, "torso": -90, "head": -90, "foot": 0}


def rest_dir(name):
    for k, v in REST_DIR.items():
        if name.endswith(k):
            return v
    return 90



# Sole points of the boot in foot-local world px (heel, ball, toe): the ground lock keeps
# the lowest of them on y = 0.
SOLE_POINTS = [(-3.9, 5.2), (4.0, 5.2), (12.6, 5.2)]
# Light and effect sockets, joint-local world px.
SOCKETS = {
    "tell": ("baton", (0.0, 25.5)),          # the baton tip: the amber-then-red tell glow
    "chest_lamp": ("torso", (7.75, -16.35)),
    "radio_led": ("torso", (5.15, -21.0)),
}
PAINTERS = {
    "pelvis": paint_pelvis, "torso": paint_torso, "head": paint_head, "upper_arm": paint_upper_arm,
    "forearm": paint_forearm, "hand": paint_hand, "thigh": paint_thigh, "shin": paint_shin,
    "foot": paint_foot, "baton": paint_baton,
}


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rest_dir(n)}
            for (n, pt, par, pos, z, far, col, mass, lim) in RIG]


# A walk pose (degrees, see scripts/actors/lit/rig_animator.gd) for the preview.
WALK = {"torso": 4, "head": -3, "near_thigh": -24, "near_shin": 8, "near_foot": 10, "far_thigh": 16, "far_shin": 24,
        "far_foot": -6, "near_upper_arm": 14, "near_forearm": -20, "far_upper_arm": -16, "far_forearm": -12,
        "baton": -30}


def main():
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results)
    lr.write_rig_json(OUT_DIR, "SE01 Night Guard", "human", parts_json, joints(), ground_lock=True,
                      sole_points=SOLE_POINTS, sockets=SOCKETS)
    out = lr.preview_arg()
    if out:
        preview(parts, results, out)
    print("atlas", size[0], size[1], "->", OUT_DIR)


def preview(parts, results, out_dir):
    js = joints()
    lr.preview_rig(os.path.join(out_dir, "night_guard_preview.png"), js, parts, results,
                   [("rest", {}, None), ("walk", WALK, None)], (-40, -112, 80, 116),
                   root_fn=lambda pose: lr.ground_offset(js, pose, SOLE_POINTS))


if __name__ == "__main__":
    sys.exit(main())

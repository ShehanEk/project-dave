#!/usr/bin/env python3
"""Paint the SE01 Night Guard for the lit-cutout test (C35), procedurally.

Placeholder art for the lighting/rig/ragdoll test only: final enemy art is
painted by hand (or generated) and run through the same split -> normal map
-> atlas steps. Every part is drawn once, flat (no baked light), in its own
local frame with the joint pivot at (0, 0), +x = the direction the guard
faces, +y = down the bone (arms and legs hang down in the rest pose; the
torso, pelvis and head point up).

Outputs (spike/lit_cutout/art/):
  night_guard_albedo.png  flat base colours, dark outlines, mild cavity shade
  night_guard_normal.png  normals in Godot's 2D convention: R = +x (right),
                          G = +y UP, B = z stored directly (Godot's decode
                          reads z = b), so flat = (128, 128, 255)
  night_guard_spec.png    R = specular strength, G = gloss, B = emissive
                          mask (baton tip, lamp lens, radio LED), A = alpha
  night_guard_rig.json    atlas rects, pivots, hierarchy, z order, ragdoll
                          colliders, masses and joint limits
  blood_*.png, light_*.png  blood decals and smooth light textures

`--preview DIR` also writes preview_*.png (the rest pose under a few fake
lights) into DIR, to check the normal maps without opening Godot.

Run from the project root:  python3 tools/spike/paint_night_guard.py [--preview DIR]
Only numpy and Pillow are needed.
"""
import json
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

OUT = 3                 # atlas pixels per world pixel (the sprite is drawn at 1/3 scale)
SS = 4                  # supersampling factor
R = OUT * SS            # internal pixels per world pixel

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.normpath(os.path.join(HERE, "..", ".."))
ART = os.path.join(PROJECT, "spike", "lit_cutout", "art")

RNG = np.random.default_rng(20260929)

# --- palette (sRGB) ------------------------------------------------------------------
def hexc(s):
    s = s.lstrip("#")
    return np.array([int(s[i:i + 2], 16) / 255.0 for i in (0, 2, 4)], np.float32)

OUTLINE = hexc("#0A0C10")
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

# material presets: (spec strength, gloss, noise amplitude, noise scale in world px)
MAT = {
    "skin": (0.20, 0.38, 0.025, 1.2),
    "hair": (0.12, 0.30, 0.06, 0.5),
    "cloth": (0.05, 0.14, 0.035, 0.9),
    "nylon": (0.12, 0.30, 0.03, 0.7),
    "leather": (0.38, 0.52, 0.04, 1.5),
    "boot": (0.55, 0.66, 0.04, 1.5),
    "rubber": (0.10, 0.20, 0.03, 0.6),
    "metal": (0.90, 0.86, 0.02, 2.0),
    "stripe": (0.80, 0.48, 0.02, 1.0),
    "eye": (0.60, 0.90, 0.0, 1.0),
    "plastic": (0.30, 0.55, 0.02, 1.0),
}


# --- geometry helpers ------------------------------------------------------------------
def catmull(points, closed=True, samples=10):
    """Smooth a control polygon (list of (x, y)) with a Catmull-Rom spline."""
    pts = [np.array(p, np.float64) for p in points]
    n = len(pts)
    out = []
    rng = range(n) if closed else range(n - 1)
    for i in rng:
        p0 = pts[(i - 1) % n] if closed else pts[max(i - 1, 0)]
        p1 = pts[i]
        p2 = pts[(i + 1) % n] if closed else pts[min(i + 1, n - 1)]
        p3 = pts[(i + 2) % n] if closed else pts[min(i + 2, n - 1)]
        for s in range(samples):
            t = s / samples
            t2, t3 = t * t, t * t * t
            q = 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
                       + (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
            out.append((float(q[0]), float(q[1])))
    if not closed:
        out.append(tuple(pts[-1]))
    return out


def ellipse_pts(cx, cy, rx, ry, angle=0.0, n=48):
    ca, sa = math.cos(angle), math.sin(angle)
    pts = []
    for i in range(n):
        a = 2 * math.pi * i / n
        x, y = rx * math.cos(a), ry * math.sin(a)
        pts.append((cx + x * ca - y * sa, cy + x * sa + y * ca))
    return pts


def rect_pts(x0, y0, x1, y1, r=0.0):
    if r <= 0:
        return [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
    pts = []
    for cx, cy, a0 in ((x1 - r, y0 + r, -90), (x1 - r, y1 - r, 0), (x0 + r, y1 - r, 90), (x0 + r, y0 + r, 180)):
        for k in range(7):
            a = math.radians(a0 + 15 * k)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def box_blur(a, r):
    if r < 1:
        return a
    k = 2 * r + 1
    p = np.pad(a, ((r + 1, r), (0, 0)))
    c = np.cumsum(p, axis=0)
    a = (c[k:] - c[:-k]) / k
    p = np.pad(a, ((0, 0), (r + 1, r)))
    c = np.cumsum(p, axis=1)
    return (c[:, k:] - c[:, :-k]) / k


def gblur(a, sigma):
    """Approximate Gaussian blur (three box passes), sigma in internal px."""
    if sigma < 0.6:
        return a
    w = math.sqrt(12.0 * sigma * sigma / 3.0 + 1.0)
    r = max(1, int(round((w - 1.0) / 2.0)))
    out = a.astype(np.float32)
    for _ in range(3):
        out = box_blur(out, r)
    return out


def edt_inside(mask):
    """Distance (internal px) from each inside pixel to the nearest outside pixel."""
    m = np.pad(mask, 1, constant_values=False)
    inner = m[1:-1, 1:-1] & m[:-2, 1:-1] & m[2:, 1:-1] & m[1:-1, :-2] & m[1:-1, 2:]
    boundary = mask & ~inner
    by, bx = np.nonzero(boundary)
    out = np.zeros(mask.shape, np.float32)
    if len(by) == 0:
        return out
    step = max(1, len(by) // 1600)
    by = by[::step].astype(np.float32)
    bx = bx[::step].astype(np.float32)
    ys, xs = np.nonzero(mask)
    d = np.empty(len(ys), np.float32)
    chunk = 3000
    for i in range(0, len(ys), chunk):
        yy = ys[i:i + chunk, None].astype(np.float32)
        xx = xs[i:i + chunk, None].astype(np.float32)
        dd = (yy - by[None, :]) ** 2 + (xx - bx[None, :]) ** 2
        d[i:i + chunk] = np.sqrt(dd.min(axis=1))
    out[ys, xs] = d + 0.5
    return out


def smooth_noise(shape, cell_px, seed_offset=0):
    """Smooth value noise in [-1, 1], cells of `cell_px` internal pixels."""
    h, w = shape
    gh = max(2, int(h / max(cell_px, 1.0)) + 2)
    gw = max(2, int(w / max(cell_px, 1.0)) + 2)
    g = RNG.random((gh, gw)).astype(np.float32)
    img = Image.fromarray((g * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
    return (np.asarray(img, np.float32) / 127.5) - 1.0


# --- a paintable part ------------------------------------------------------------------
class Part:
    def __init__(self, name, x0, y0, x1, y1):
        self.name = name
        pad = 1.2
        self.x0, self.y0 = x0 - pad, y0 - pad
        w_world, h_world = (x1 - x0) + 2 * pad, (y1 - y0) + 2 * pad
        self.W = int(math.ceil(w_world * OUT)) * SS
        self.H = int(math.ceil(h_world * OUT)) * SS
        shape = (self.H, self.W)
        self.albedo = np.zeros(shape + (3,), np.float32)
        self.cover = np.zeros(shape, np.float32)          # painted coverage (0..1)
        self.spec = np.zeros(shape, np.float32)
        self.gloss = np.zeros(shape, np.float32)
        self.emis = np.zeros(shape, np.float32)
        self.height = np.zeros(shape, np.float32)
        self.lines = np.zeros(shape, np.float32)           # interior line darkening (0..1)
        self.sil = np.zeros(shape, bool)

    # world (local) -> internal pixel coords
    def px(self, pts):
        return [((x - self.x0) * R, (y - self.y0) * R) for x, y in pts]

    def mask(self, pts):
        img = Image.new("L", (self.W, self.H), 0)
        ImageDraw.Draw(img).polygon(self.px(pts), fill=255)
        return np.asarray(img, np.uint8) > 127

    def stroke(self, pts, width_world, closed=False):
        img = Image.new("L", (self.W, self.H), 0)
        d = ImageDraw.Draw(img)
        p = self.px(pts)
        if closed:
            p = p + [p[0]]
        wpx = max(1, int(round(width_world * R)))
        d.line(p, fill=255, width=wpx, joint="curve")
        r = wpx / 2.0
        for x, y in (p[0], p[-1]):
            d.ellipse((x - r, y - r, x + r, y + r), fill=255)
        return np.asarray(img, np.uint8) > 127

    # painting -------------------------------------------------------------------------
    def fill(self, m, color, mat="cloth", emissive=0.0, clip=None):
        if clip is not None:
            m = m & clip
        spec, gloss, namp, nscale = MAT[mat]
        col = np.broadcast_to(color, self.albedo.shape).copy()
        if namp > 0:
            n = 0.65 * smooth_noise(m.shape, nscale * R) + 0.35 * smooth_noise(m.shape, nscale * R * 0.33)
            col *= (1.0 + namp * n)[..., None]
        self.albedo[m] = col[m]
        self.cover[m] = 1.0
        self.spec[m] = spec
        self.gloss[m] = gloss
        self.emis[m] = emissive
        return m

    def body(self, pts, color, mat="cloth", radius=None, dome=0.35, smooth=True, samples=10):
        """The part's main volume: fills, and adds a rounded height profile."""
        poly = catmull(pts, True, samples) if smooth else pts
        m = self.mask(poly)
        self.fill(m, color, mat)
        self.sil |= m
        d = edt_inside(m)
        if radius is None:
            radius = max(float(d.max()) / R, 0.5)
        r = radius * R
        t = np.clip(d / r, 0.0, 1.0)
        h = r * np.sqrt(1.0 - (1.0 - t) ** 2)
        if dome > 0:
            dm = max(float(d.max()), 1.0)
            h += dome * r * np.sqrt(np.clip(d / dm, 0.0, 1.0))
        self.height = np.where(m, np.maximum(self.height, h), self.height)
        return m

    def patch(self, pts, color, mat="cloth", raise_world=0.35, soft_world=0.35, smooth=True, clip=True, emissive=0.0, samples=8):
        """A raised (or sunken, raise < 0) region painted on top of the body."""
        poly = catmull(pts, True, samples) if smooth else pts
        m = self.mask(poly)
        if clip:
            m &= self.sil
        self.fill(m, color, mat, emissive=emissive)
        if raise_world != 0.0:
            self.height += raise_world * R * gblur(m.astype(np.float32), soft_world * R)
        return m

    def tint(self, pts, color, amount, soft_world=0.6, smooth=True):
        """Blend a colour softly over what is already painted (stubble, grime)."""
        poly = catmull(pts, True, 8) if smooth else pts
        m = self.mask(poly) & self.sil
        w = gblur(m.astype(np.float32), soft_world * R) * amount
        w = np.clip(w, 0, 1)[..., None]
        self.albedo = self.albedo * (1 - w) + color * w

    def bump(self, pts, amount_world, soft_world=0.5, smooth=True, clip=True):
        poly = catmull(pts, True, 8) if smooth else pts
        m = self.mask(poly)
        if clip:
            m &= self.sil
        self.height += amount_world * R * gblur(m.astype(np.float32), soft_world * R)
        return m

    def seam(self, pts, depth_world=0.18, width_world=0.22, dark=0.45, closed=False, smooth=True):
        """A groove line: lowers the height and darkens the albedo a little."""
        p = catmull(pts, closed, 6) if (smooth and len(pts) > 2) else pts
        m = self.stroke(p, width_world, closed) & self.sil
        mf = gblur(m.astype(np.float32), 0.12 * R)
        self.height -= depth_world * R * mf
        self.lines = np.maximum(self.lines, dark * mf)
        return m

    def ridge(self, pts, amount_world=0.2, width_world=0.5, smooth=True):
        p = catmull(pts, False, 6) if (smooth and len(pts) > 2) else pts
        m = self.stroke(p, width_world) & self.sil
        self.height += amount_world * R * gblur(m.astype(np.float32), 0.35 * R)

    def dot(self, cx, cy, r, color, mat="metal", raise_world=0.15, emissive=0.0):
        return self.patch(ellipse_pts(cx, cy, r, r, 0, 20), color, mat, raise_world, 0.12, smooth=False, emissive=emissive)

    # finishing ------------------------------------------------------------------------
    def finish(self, outline_world=0.55, normal_strength=1.0):
        h = gblur(self.height, 0.18 * R)
        # cavity shade (non-directional): darken creases a little
        cav = gblur(h, 1.2 * R) - h
        ao = np.clip(1.0 - 0.9 * np.maximum(cav, 0.0) / (0.9 * R), 0.55, 1.0)
        alb = self.albedo * ao[..., None]
        alb *= (1.0 - self.lines)[..., None]
        # outer outline
        d = edt_inside(self.sil)
        ring = self.sil & (d < outline_world * R)
        soft = np.clip((outline_world * R - d) / (0.35 * R), 0.0, 1.0) * self.sil
        alb = alb * (1.0 - soft[..., None]) + OUTLINE * soft[..., None]
        self.spec = np.where(ring, self.spec * 0.4, self.spec)
        # normals from the height field (Godot 2D: R=+x, G=+y up, B=z)
        gy, gx = np.gradient(h)
        nx = -gx * normal_strength
        ny = -gy * normal_strength      # canvas y (down)
        nz = np.ones_like(h)
        inv = 1.0 / np.sqrt(nx * nx + ny * ny + nz * nz)
        n = np.stack([nx * inv, ny * inv, nz * inv], axis=-1)
        alpha = self.sil.astype(np.float32)
        return downsample(alb, n, self.spec, self.gloss, self.emis, alpha)


def downsample(alb, n, spec, gloss, emis, alpha):
    H, W = alpha.shape
    h, w = H // SS, W // SS

    def red(a):
        return a.reshape(h, SS, w, SS, *a.shape[2:]).mean(axis=(1, 3))

    a = red(alpha)
    wa = np.maximum(a, 1e-6)
    alb_o = red(alb * alpha[..., None]) / wa[..., None]
    n_o = red(n * alpha[..., None])
    ln = np.linalg.norm(n_o, axis=-1, keepdims=True)
    n_o = np.where(ln > 1e-6, n_o / np.maximum(ln, 1e-6), np.array([0, 0, 1.0], np.float32))
    spec_o = red(spec * alpha) / wa
    gloss_o = red(gloss * alpha) / wa
    emis_o = red(emis * alpha) / wa
    return {"albedo": alb_o, "normal": n_o, "spec": spec_o, "gloss": gloss_o, "emis": emis_o, "alpha": a}


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


# --- blood and light textures ----------------------------------------------------------------
def blob_mask(size, seed, lobes=7, drip=False):
    rs = np.random.default_rng(seed)
    n = size * SS
    img = Image.new("L", (n, n), 0)
    d = ImageDraw.Draw(img)
    c = n / 2.0
    pts = []
    for k in range(40):
        a = 2 * math.pi * k / 40
        r = 0.30 + 0.07 * math.sin(a * lobes + rs.random() * 6) + 0.04 * rs.random()
        pts.append((c + r * n * math.cos(a), c + r * n * math.sin(a) * 0.9))
    d.polygon(pts, fill=255)
    for _ in range(5):
        a = rs.random() * 2 * math.pi
        rr = n * (0.34 + 0.1 * rs.random())
        s = n * (0.03 + 0.04 * rs.random())
        x, y = c + rr * math.cos(a), c + rr * math.sin(a)
        d.ellipse((x - s, y - s, x + s, y + s), fill=255)
    if drip:
        x = c + n * 0.05
        d.rectangle((x - n * 0.04, c, x + n * 0.04, c + n * 0.42), fill=255)
        d.ellipse((x - n * 0.065, c + n * 0.38, x + n * 0.065, c + n * 0.5), fill=255)
    return np.asarray(img, np.float32) / 255.0


def save_rgba(path, rgb, a):
    arr = np.concatenate([np.clip(rgb, 0, 1), np.clip(a, 0, 1)[..., None]], axis=-1)
    Image.fromarray((arr * 255 + 0.5).astype(np.uint8)).save(path)


def normal_to_rgb(n):
    rgb = np.empty(n.shape, np.float32)
    rgb[..., 0] = n[..., 0] * 0.5 + 0.5
    rgb[..., 1] = -n[..., 1] * 0.5 + 0.5        # G = up
    rgb[..., 2] = np.clip(n[..., 2], 0, 1)      # Godot decodes z = b
    return rgb


def blood_textures():
    wet = hexc("#B3212F")
    dark = hexc("#5E0D16")
    out = []
    for i, (size, drip) in enumerate(((7, False), (8, True), (6, False))):
        m = blob_mask(size * OUT, 90 + i, 6 + i, drip)
        m = gblur(m, 1.5 * SS)
        a = np.clip((m - 0.35) * 3.0, 0, 1)
        core = np.clip((gblur(m, 3 * SS) - 0.5) * 2.5, 0, 1)
        rgb = wet[None, None, :] * (1 - 0.55 * core[..., None]) + dark[None, None, :] * 0.0
        h = gblur(a, 2.0 * SS) * 2.0 * SS
        gy, gx = np.gradient(h)
        n = np.stack([-gx, -gy, np.ones_like(h)], -1)
        n /= np.linalg.norm(n, axis=-1, keepdims=True)
        res = downsample(rgb, n, np.full(a.shape, 0.75), np.full(a.shape, 0.82), np.zeros(a.shape), a)
        save_rgba(os.path.join(ART, "blood_wound_%d.png" % i), res["albedo"], res["alpha"])
        save_rgba(os.path.join(ART, "blood_wound_%d_n.png" % i), normal_to_rgb(res["normal"]), res["alpha"])
        out.append("blood_wound_%d.png" % i)
    # pool: a thin wet sheet on the floor line, seen almost edge-on
    w, h = 120 * OUT * SS, 8 * OUT * SS
    img = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(img)
    pts = []
    rs = np.random.default_rng(7)
    for k in range(60):
        t = k / 59
        x = t * w
        top = h * (0.62 - 0.30 * math.sin(math.pi * t) ** 0.6 + 0.05 * rs.random())
        pts.append((x, top))
    pts += [(w, h), (0, h)]
    d.polygon(pts, fill=255)
    m = gblur(np.asarray(img, np.float32) / 255.0, 1.2 * SS)
    a = np.clip((m - 0.3) * 3.0, 0, 1)
    rgb = np.broadcast_to(wet, a.shape + (3,)).copy()
    rgb *= (0.85 + 0.15 * smooth_noise(a.shape, 30))[..., None]
    hgt = gblur(a, 1.5 * SS) * 1.2 * SS
    gy, gx = np.gradient(hgt)
    n = np.stack([-gx, -gy, np.ones_like(hgt)], -1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    res = downsample(rgb, n, np.full(a.shape, 0.9), np.full(a.shape, 0.9), np.zeros(a.shape), a)
    save_rgba(os.path.join(ART, "blood_pool.png"), res["albedo"], res["alpha"])
    save_rgba(os.path.join(ART, "blood_pool_n.png"), normal_to_rgb(res["normal"]), res["alpha"])
    # droplet for particles (white, tinted in engine)
    n = 16
    yy, xx = np.mgrid[0:n, 0:n] + 0.5
    r = np.sqrt((xx - n / 2) ** 2 + (yy - n / 2) ** 2) / (n / 2)
    a = np.clip((1.0 - r) * 2.2, 0, 1)
    save_rgba(os.path.join(ART, "blood_drop.png"), np.ones((n, n, 3), np.float32), a)
    # flat helpers: a 4x4 flat normal and a wet spec for decals
    save_rgba(os.path.join(ART, "flat_normal.png"), np.broadcast_to(np.array([0.5, 0.5, 1.0], np.float32), (4, 4, 3)).copy(), np.ones((4, 4), np.float32))
    save_rgba(os.path.join(ART, "wet_spec.png"), np.broadcast_to(np.array([0.85, 0.85, 0.0], np.float32), (4, 4, 3)).copy(), np.ones((4, 4), np.float32))


def light_textures():
    # smooth disc: soft inverse-square-ish falloff
    n = 256
    yy, xx = np.mgrid[0:n, 0:n] + 0.5
    r = np.sqrt((xx - n / 2) ** 2 + (yy - n / 2) ** 2) / (n / 2)
    t = np.clip(1.0 - r, 0, 1)
    i = t ** 2.2 * (0.35 + 0.65 * (1.0 / (1.0 + 9.0 * r * r)))
    i /= i.max()
    save_rgba(os.path.join(ART, "light_disc_smooth.png"), np.ones((n, n, 3), np.float32), i)
    # smooth cone pointing DOWN with its apex at the texture centre, so the light node sits at
    # the lamp head (normal-mapped light direction is taken from the light's position)
    n = 512
    yy, xx = np.mgrid[0:n, 0:n] + 0.5
    dx = (xx - n / 2) / (n / 2)
    dy = (yy - n / 2) / (n / 2)
    ang = np.degrees(np.arctan2(np.abs(dx), np.maximum(dy, 1e-6)))
    dist = np.sqrt(dx * dx + dy * dy)
    half = 40.0
    cone = np.clip((half - ang) / 18.0, 0, 1)
    cone = cone * cone * (3 - 2 * cone)
    fall = np.clip(1.0 - dist, 0, 1) ** 0.9
    beam = np.where(dy > 0, cone * fall, 0.0)
    spill = np.clip(1.0 - dist * 3.0, 0, 1) ** 1.5 * 0.7
    i = np.clip(np.maximum(beam, spill) + 0.25 * np.clip(1.0 - dist * 1.6, 0, 1) ** 2, 0, 1)
    save_rgba(os.path.join(ART, "light_cone_smooth.png"), np.ones((n, n, 3), np.float32), i)
    # soft wide window/sign light
    n = 256
    yy, xx = np.mgrid[0:n, 0:n] + 0.5
    ex = np.abs(xx - n / 2) / (n / 2)
    ey = np.abs(yy - n / 2) / (n / 2)
    i = np.clip(1 - ex, 0, 1) ** 1.3 * np.clip(1 - ey, 0, 1) ** 1.8
    save_rgba(os.path.join(ART, "light_soft_rect.png"), np.ones((n, n, 3), np.float32), i / i.max())


# --- atlas packing and output ----------------------------------------------------------------
def pack(results, pad=4, width=256):
    order = sorted(results.keys(), key=lambda k: -results[k]["alpha"].shape[0])
    x = y = row_h = 0
    rects = {}
    for k in order:
        h, w = results[k]["alpha"].shape
        if x + w + pad > width:
            x = 0
            y += row_h + pad
            row_h = 0
        rects[k] = (x + pad, y + pad, w, h)
        x += w + pad
        row_h = max(row_h, h)
    height = y + row_h + 2 * pad
    height = int(2 ** math.ceil(math.log2(max(height, 16))))
    return rects, width, height


def main():
    os.makedirs(ART, exist_ok=True)
    painters = {
        "pelvis": paint_pelvis, "torso": paint_torso, "head": paint_head, "upper_arm": paint_upper_arm,
        "forearm": paint_forearm, "hand": paint_hand, "thigh": paint_thigh, "shin": paint_shin,
        "foot": paint_foot, "baton": paint_baton,
    }
    parts = {}
    results = {}
    for name, fn in painters.items():
        part = fn()
        parts[name] = part
        results[name] = part.finish()
        print("painted", name, results[name]["alpha"].shape)
    rects, aw, ah = pack(results)
    albedo = np.zeros((ah, aw, 4), np.float32)
    normal = np.zeros((ah, aw, 4), np.float32)
    normal[..., 0:3] = [0.5, 0.5, 1.0]
    spec = np.zeros((ah, aw, 4), np.float32)
    parts_json = {}
    for name, res in results.items():
        x, y, w, h = rects[name]
        a = res["alpha"]
        albedo[y:y + h, x:x + w, 0:3] = res["albedo"]
        albedo[y:y + h, x:x + w, 3] = a
        normal[y:y + h, x:x + w, 0:3] = normal_to_rgb(res["normal"])
        normal[y:y + h, x:x + w, 3] = a
        spec[y:y + h, x:x + w, 0] = res["spec"]
        spec[y:y + h, x:x + w, 1] = res["gloss"]
        spec[y:y + h, x:x + w, 2] = res["emis"]
        spec[y:y + h, x:x + w, 3] = a
        part = parts[name]
        pivot = [(-part.x0) * OUT, (-part.y0) * OUT]
        parts_json[name] = {"rect": [x, y, w, h], "pivot": [round(pivot[0], 3), round(pivot[1], 3)]}
    # bleed colours into transparent pixels so filtering never pulls in black/zero normals
    for arr, fill in ((albedo, None), (normal, [0.5, 0.5, 1.0]), (spec, None)):
        mask = arr[..., 3] > 0.01
        if fill is not None:
            arr[~mask, 0:3] = fill
    Image.fromarray((np.clip(albedo, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(ART, "night_guard_albedo.png"))
    Image.fromarray((np.clip(normal, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(ART, "night_guard_normal.png"))
    Image.fromarray((np.clip(spec, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(ART, "night_guard_spec.png"))
    rig = {
        "name": "SE01 Night Guard (lit-cutout test)",
        "texture_scale": OUT,
        "albedo": "night_guard_albedo.png",
        "normal": "night_guard_normal.png",
        "spec": "night_guard_spec.png",
        "parts": parts_json,
        "joints": [
            {"name": n, "part": pt, "parent": par, "pos": list(pos), "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rest_dir(n)}
            for (n, pt, par, pos, z, far, col, mass, lim) in RIG
        ],
    }
    with open(os.path.join(ART, "night_guard_rig.json"), "w") as f:
        json.dump(rig, f, indent=1)
    blood_textures()
    light_textures()
    if "--preview" in sys.argv:
        i = sys.argv.index("--preview")
        out = sys.argv[i + 1] if i + 1 < len(sys.argv) else "."
        os.makedirs(out, exist_ok=True)
        preview(results, parts, out)
    print("atlas", aw, ah, "->", ART)


# --- a quick software preview (rest pose, a few lights) ---------------------------------------
def preview(results, parts, out_dir):
    scale = OUT
    W, H = 70 * scale, 110 * scale
    base_x, base_y = 30 * scale, 104 * scale
    glob = {}
    for (n, pt, par, pos, z, far, col, mass, lim) in RIG:
        px, py = pos
        if par:
            gx, gy = glob[par]
            glob[n] = (gx + px, gy + py)
        else:
            glob[n] = (px, py)
    lights = [((-30, -120, 60), np.array([0.85, 0.9, 1.0]) * 1.4), ((40, -40, 25), np.array([1.0, 0.85, 0.6]) * 0.9)]
    for tag, ls in (("lamp_and_flash", lights), ("rim_left", [((-60, -60, 10), np.array([0.25, 0.9, 0.85]) * 1.3)]),
                    ("flat_front", [((0, -60, 400), np.array([1.0, 1.0, 1.0]) * 1.0)])):
        img = np.zeros((H, W, 3), np.float32)
        img[:] = hexc("#0E1726")
        for (n, pt, par, pos, z, far, col, mass, lim) in sorted(RIG, key=lambda r: r[4]):
            res = results[pt]
            part = parts[pt]
            gx, gy = glob[n]
            ox = int(round(base_x + (gx + part.x0) * scale))
            oy = int(round(base_y + (gy + part.y0) * scale))
            h, w = res["alpha"].shape
            a = res["alpha"]
            alb = res["albedo"] * (0.72 if far else 1.0)
            nrm = res["normal"]
            yy, xx = np.mgrid[0:h, 0:w]
            wx = (ox + xx - base_x) / scale
            wy = (oy + yy - base_y) / scale
            col_acc = alb * np.array([0.16, 0.18, 0.24])
            for (lx, ly, lz), lc in ls:
                L = np.stack([lx - wx, ly - wy, np.full_like(wx, lz, dtype=np.float64)], -1)
                dist = np.linalg.norm(L, axis=-1, keepdims=True)
                L = L / dist
                att = np.clip(1.0 - dist / 160.0, 0, 1) ** 1.5
                ndl = np.clip((np.sum(nrm * L, -1, keepdims=True) + 0.15) / 1.15, 0, 1)
                hv = L + np.array([0, 0, 1.0])
                hv /= np.linalg.norm(hv, axis=-1, keepdims=True)
                shin = np.exp2(res["gloss"] * 10 + 1)[..., None]
                sp = np.power(np.clip(np.sum(nrm * hv, -1, keepdims=True), 0, 1), shin) * res["spec"][..., None] * (shin + 8) / 25.0
                col_acc = col_acc + (alb * ndl + sp) * lc * att
            col_acc += res["emis"][..., None] * np.array([1.0, 0.9, 0.7]) * 0.6
            y0, x0 = max(oy, 0), max(ox, 0)
            y1, x1 = min(oy + h, H), min(ox + w, W)
            sub_a = a[y0 - oy:y1 - oy, x0 - ox:x1 - ox][..., None]
            img[y0:y1, x0:x1] = img[y0:y1, x0:x1] * (1 - sub_a) + col_acc[y0 - oy:y1 - oy, x0 - ox:x1 - ox] * sub_a
        big = Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8)).resize((W * 2, H * 2), Image.LANCZOS)
        big.save(os.path.join(out_dir, "preview_%s.png" % tag))


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Shared core of the lit-cutout rig painters (C35).

Every enemy is painted once as flat parts (no baked light), each with a
matching normal map and a spec/emissive map, packed into one atlas and
described by a rig JSON that scripts/actors/lit/cutout_rig.gd reads. The
per-asset painters (paint_night_guard.py, paint_staffer.py,
paint_patrol_rover.py) only draw their parts and list their joints; this
module does the rest:

  Part            one paintable part in its own local frame (world px, the
                  joint pivot at (0, 0), +x = the way the rig faces, y down),
                  supersampled; paints flat colour, material, emissive mask
                  and a height field, and finishes to albedo + normals
  geometry        Catmull-Rom outlines, ellipses, rounded rects, arcs
  blur / EDT      box-Gaussian blur, exact Euclidean distance transform
  atlas           shelf packing, colour bleed, PNG writing
  rig JSON        texture_scale, albedo/normal/spec, parts, joints (+ kind,
                  ground_lock, sole_points, per-joint role, sockets)
  preview         a software render of the rig under a few fake lights
                  (--preview DIR), to judge the normal maps without Godot

Conventions:
  normal.png  Godot's 2D convention: R = +x (right), G = +y UP, B = z stored
              directly (Godot decodes z = b), so flat = (128, 128, 255)
  spec.png    R = specular strength, G = gloss, B = emissive mask, A = alpha

Only numpy and Pillow are needed. Output is deterministic: every painter
seeds the noise generator with a fixed number before painting.
"""
import json
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

OUT = 3                 # atlas pixels per world pixel (the sprite is drawn at 1/3 scale)
SS = 4                  # supersampling factor
R = OUT * SS            # internal pixels per world pixel

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.normpath(os.path.join(HERE, "..", ".."))
LIT_DIR = os.path.join(PROJECT, "assets", "characters", "lit")

RNG = np.random.default_rng(0)


def seed(n):
    """Restart the noise generator (call once per painter, before painting)."""
    global RNG
    RNG = np.random.default_rng(n)


# --- colour and materials ------------------------------------------------------------
def hexc(s):
    s = s.lstrip("#")
    return np.array([int(s[i:i + 2], 16) / 255.0 for i in (0, 2, 4)], np.float32)


OUTLINE = hexc("#0A0C10")

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
    # hard-surface machine materials
    "shell": (0.42, 0.62, 0.012, 3.0),      # painted polymer shell, a soft sheen
    "paint": (0.30, 0.50, 0.018, 2.5),      # painted steel skirt
    "glass": (0.95, 0.94, 0.0, 1.0),        # lenses, small glass windows
    "smoked": (0.75, 0.62, 0.0, 1.0),       # a smoked glass dome: a broad, soft glint
    "tire": (0.12, 0.22, 0.05, 0.5),
    "steel": (0.70, 0.70, 0.03, 1.2),       # bare, worn steel (bolts, hinges)
    "card": (0.25, 0.45, 0.01, 1.0),        # laminated ID card
    "skin_matte": (0.14, 0.32, 0.025, 1.2), # tired, unwashed skin (the Linked)
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


def arc_pts(cx, cy, r, a0_deg, a1_deg, n=16, ry=None):
    """Points along an arc (canvas angles: 0 = +x, 90 = down), both ends included."""
    ry = r if ry is None else ry
    out = []
    for k in range(n + 1):
        a = math.radians(a0_deg + (a1_deg - a0_deg) * k / n)
        out.append((cx + r * math.cos(a), cy + ry * math.sin(a)))
    return out


def rot_pts(pts, angle_deg, cx=0.0, cy=0.0):
    """Rotate points about (cx, cy) (canvas angle, clockwise-positive on screen)."""
    a = math.radians(angle_deg)
    ca, sa = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * ca - (y - cy) * sa, cy + (x - cx) * sa + (y - cy) * ca) for x, y in pts]


# --- blur and distance ---------------------------------------------------------------
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


def dist_to(feature):
    """Exact Euclidean distance (px) from every pixel to the nearest True pixel of `feature`.

    Separable: the distance along one axis first (a running last/next index), then
    the exact minimum over the other, shorter axis (brute force in blocks)."""
    H, W = feature.shape
    flip = W > H                        # brute-force along the shorter axis
    f = feature.T if flip else feature
    h, w = f.shape
    big = 2 * (h + w) + 8
    idx = np.arange(h, dtype=np.int32)[:, None]
    up = np.maximum.accumulate(np.where(f, idx, -big), axis=0)
    dn = np.minimum.accumulate(np.where(f, idx, 2 * big)[::-1], axis=0)[::-1]
    g = np.minimum(idx - up, dn - idx).astype(np.int32)
    g2 = g * g
    xs = np.arange(w, dtype=np.int32)
    dx2 = (xs[:, None] - xs[None, :]) ** 2
    out = np.empty((h, w), np.int32)
    block = max(1, 3_000_000 // max(w * w, 1))
    for y0 in range(0, h, block):
        gb = g2[y0:y0 + block]
        out[y0:y0 + block] = (gb[:, None, :] + dx2[None, :, :]).min(axis=2)
    d = np.sqrt(out.astype(np.float32))
    return d.T if flip else d


def edt_inside(mask):
    """Distance (internal px) from each inside pixel to the nearest outside pixel."""
    m = np.pad(mask, 1, constant_values=False)
    inner = m[1:-1, 1:-1] & m[:-2, 1:-1] & m[2:, 1:-1] & m[1:-1, :-2] & m[1:-1, 2:]
    boundary = mask & ~inner
    out = np.zeros(mask.shape, np.float32)
    if not boundary.any():
        return out
    d = dist_to(boundary)
    out[mask] = d[mask] + 0.5
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

    # extra tools for new parts (hard surfaces, overlapping volumes) ------------------------
    def shell(self, pts, color, mat="shell", bevel=1.2, crown=0.25, smooth=True, samples=10, replace=False):
        """A rigid panel or volume: a rounded bevel of `bevel` world px around a gently
        crowned face (`crown` x the part's half-thickness). With `replace`, the new shape
        sits on top of whatever was painted there (its height replaces the old)."""
        poly = catmull(pts, True, samples) if smooth else pts
        m = self.mask(poly)
        self.fill(m, color, mat)
        self.sil |= m
        d = edt_inside(m)
        r = max(bevel, 0.2) * R
        t = np.clip(d / r, 0.0, 1.0)
        h = r * np.sqrt(1.0 - (1.0 - t) ** 2)
        if crown > 0:
            dm = max(float(d.max()), 1.0)
            h += crown * dm * np.sqrt(np.clip(d / dm, 0.0, 1.0))
        if replace:
            self.height = np.where(m, h, self.height)
        else:
            self.height = np.where(m, np.maximum(self.height, h), self.height)
        return m

    def lift(self, m, amount_world, soft_world=0.3):
        """Raise (or lower) an existing region's height softly."""
        self.height += amount_world * R * gblur(m.astype(np.float32), soft_world * R)

    def shade(self, m, factor, soft_world=0.4):
        """Scale the painted colour inside a region (a flat colour change, e.g. a recess
        painted a darker value; never a light direction)."""
        w = gblur(m.astype(np.float32), soft_world * R)[..., None]
        self.albedo = self.albedo * (1.0 - w + w * factor)

    def emit(self, m, amount=1.0, soft_world=0.0):
        """Mark a region as emissive (spec B) without repainting it."""
        w = gblur(m.astype(np.float32), soft_world * R) if soft_world > 0 else m.astype(np.float32)
        self.emis = np.maximum(self.emis, np.clip(w * amount, 0.0, 1.0) * self.sil)

    def tint_mask(self, m, color, amount, soft_world=0.3):
        """Blend a colour softly over a region (bruising, stubble, under-skin lines)."""
        w = np.clip(gblur((m & self.sil).astype(np.float32), soft_world * R) * amount, 0, 1)[..., None]
        self.albedo = self.albedo * (1 - w) + color * w

    def restyle(self, m, mat, amount=1.0, soft_world=0.2):
        """Blend a region's specular and gloss toward another material (a buzz cut on skin)."""
        spec, gloss, _, _ = MAT[mat]
        w = np.clip(gblur((m & self.sil).astype(np.float32), soft_world * R) * amount, 0, 1)
        self.spec = self.spec * (1 - w) + spec * w
        self.gloss = self.gloss * (1 - w) + gloss * w

    def tint_stroke(self, pts, width_world, color, amount, soft_world=0.15, smooth=True):
        p = catmull(pts, False, 6) if (smooth and len(pts) > 2) else pts
        self.tint_mask(self.stroke(p, width_world), color, amount, soft_world)

    # finishing ------------------------------------------------------------------------
    def finish(self, outline_world=0.55, normal_strength=1.0, outline=None):
        outline = OUTLINE if outline is None else outline
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
        alb = alb * (1.0 - soft[..., None]) + outline * soft[..., None]
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


# --- image output --------------------------------------------------------------------
def save_rgba(path, rgb, a):
    arr = np.concatenate([np.clip(rgb, 0, 1), np.clip(a, 0, 1)[..., None]], axis=-1)
    Image.fromarray((arr * 255 + 0.5).astype(np.uint8)).save(path)


def normal_to_rgb(n):
    rgb = np.empty(n.shape, np.float32)
    rgb[..., 0] = n[..., 0] * 0.5 + 0.5
    rgb[..., 1] = -n[..., 1] * 0.5 + 0.5        # G = up
    rgb[..., 2] = np.clip(n[..., 2], 0, 1)      # Godot decodes z = b
    return rgb


def height_to_normal(h):
    """Unit normals (canvas y down) from a height field in px."""
    gy, gx = np.gradient(h)
    n = np.stack([-gx, -gy, np.ones_like(h)], -1)
    return n / np.linalg.norm(n, axis=-1, keepdims=True)


# --- atlas packing and the rig JSON ----------------------------------------------------
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


def paint_parts(painters):
    """Run each part painter (name -> function returning a Part); returns (parts, results)."""
    parts = {}
    results = {}
    for name, fn in painters.items():
        part = fn()
        parts[name] = part
        results[name] = part.finish()
        print("painted", name, results[name]["alpha"].shape)
    return parts, results


def write_atlas(out_dir, parts, results, width=256):
    """Pack the finished parts; write albedo.png, normal.png and spec.png; returns the
    `parts` table of the rig JSON (atlas rect and pivot, in texels) and the atlas size."""
    rects, aw, ah = pack(results, width=width)
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
    # transparent texels carry a flat normal so filtering never pulls in a zero normal
    mask = normal[..., 3] > 0.01
    normal[~mask, 0:3] = [0.5, 0.5, 1.0]
    os.makedirs(out_dir, exist_ok=True)
    for fname, arr in (("albedo.png", albedo), ("normal.png", normal), ("spec.png", spec)):
        Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(out_dir, fname))
    return parts_json, (aw, ah)


def write_rig_json(out_dir, name, kind, parts_json, joints, ground_lock, sole_points=None, sockets=None):
    """The rig JSON read by cutout_rig.gd. `joints` are dicts with name, part, parent,
    pos, z, far, collider, mass, limit, rest_dir and (optional) role; texture files are
    relative to the JSON's folder."""
    rig = {
        "name": name,
        "kind": kind,
        "texture_scale": OUT,
        "albedo": "albedo.png",
        "normal": "normal.png",
        "spec": "spec.png",
        "ground_lock": bool(ground_lock),
    }
    if sole_points is not None:
        rig["sole_points"] = [[float(x), float(y)] for x, y in sole_points]
    rig["parts"] = parts_json
    rig["joints"] = []
    for j in joints:
        e = {"name": j["name"], "part": j["part"], "parent": j["parent"], "pos": [float(v) for v in j["pos"]],
             "z": int(j["z"]), "far": bool(j["far"]), "collider": j["collider"], "mass": float(j["mass"]),
             "limit": j["limit"], "rest_dir": j["rest_dir"]}
        if j.get("role"):
            e["role"] = j["role"]
        rig["joints"].append(e)
    if sockets:
        rig["sockets"] = {k: {"joint": v[0], "pos": [float(v[1][0]), float(v[1][1])]} for k, v in sockets.items()}
    path = os.path.join(out_dir, "rig.json")
    with open(path, "w") as f:
        json.dump(rig, f, indent=1)
        f.write("\n")
    return path


def preview_arg(argv=None):
    """The DIR of `--preview DIR`, or None."""
    argv = sys.argv if argv is None else argv
    if "--preview" not in argv:
        return None
    i = argv.index("--preview")
    return argv[i + 1] if i + 1 < len(argv) else "."


# --- software preview ------------------------------------------------------------------
# A small re-implementation of lit_part.gdshader (ambient + emissive + wrapped
# Lambert + normalised Blinn-Phong per light), so a painter can show its rig under
# a lamp, a muzzle flash and the moon rim without opening Godot.
NIGHT_BG = hexc("#0E1726")
FAR_TINT = np.array([0.74, 0.75, 0.8], np.float32)


class Light:
    """A point light at (x, y) in rig space (world px, y down, origin on the floor),
    `height` px above the play plane, with a smooth disc falloff of `radius` px; or a
    directional light (`direction` = where the light comes FROM, as a canvas vector)."""

    def __init__(self, color, energy, pos=None, height=40.0, radius=160.0, direction=None):
        self.color = np.asarray(color, np.float32)
        self.energy = energy
        self.pos = pos
        self.height = height
        self.radius = radius
        self.direction = direction


def disc_falloff(r):
    """The smooth disc light texture's profile (r = distance / radius)."""
    t = np.clip(1.0 - r, 0, 1)
    return t ** 2.2 * (0.35 + 0.65 * (1.0 / (1.0 + 9.0 * r * r))) / 1.0


def _affine(pos, rot):
    c, s = math.cos(rot), math.sin(rot)
    return np.array([[c, -s, pos[0]], [s, c, pos[1]], [0, 0, 1]], np.float64)


def joint_transforms(joints, pose=None, root_offset=(0.0, 0.0), facing=1):
    """Global 3x3 transforms (rig space, world px) of every joint for a pose of local
    rotations in degrees (missing joints stay at 0)."""
    pose = pose or {}
    glob = {}
    for j in joints:
        rot = math.radians(pose.get(j["name"], 0.0))
        pos = j["pos"]
        if j["parent"]:
            glob[j["name"]] = glob[j["parent"]] @ _affine(pos, rot)
        else:
            glob[j["name"]] = _affine((pos[0] + root_offset[0], pos[1] + root_offset[1]), rot)
    if facing < 0:
        mirror = np.diag([-1.0, 1.0, 1.0])
        glob = {k: mirror @ v for k, v in glob.items()}
    return glob


def _bilinear(img, u, v):
    """Sample img (h, w, c) at continuous texel coords (texel centres at i + 0.5)."""
    h, w = img.shape[:2]
    x = u - 0.5
    y = v - 0.5
    x0 = np.floor(x).astype(np.int64)
    y0 = np.floor(y).astype(np.int64)
    fx = (x - x0)[..., None]
    fy = (y - y0)[..., None]

    def at(yy, xx):
        inside = (xx >= 0) & (xx < w) & (yy >= 0) & (yy < h)
        v_ = img[np.clip(yy, 0, h - 1), np.clip(xx, 0, w - 1)]
        return np.where(inside[..., None], v_, 0.0)

    return (at(y0, x0) * (1 - fx) * (1 - fy) + at(y0, x0 + 1) * fx * (1 - fy)
            + at(y0 + 1, x0) * (1 - fx) * fy + at(y0 + 1, x0 + 1) * fx * fy)


def render(joints, parts, results, pose=None, lights=(), scale=1.0, view=(-40, -110, 80, 120), ambient=(0.2, 0.22, 0.28),
           facing=1, root_offset=(0.0, 0.0), bg=NIGHT_BG, emissive_energy=1.3, emissive_override=None, wrap=0.2,
           normals_on=True, hide=()):
    """Render a posed rig in software. `view` = (x0, y0, width, height) in world px;
    `scale` = output px per world px. `emissive_override` maps a joint name to an
    (rgb, energy) pair (a tinted tell or power glow, like a separate material)."""
    vx, vy, vw, vh = view
    W, H = int(round(vw * scale)), int(round(vh * scale))
    img = np.zeros((H, W, 3), np.float32)
    img[:] = bg
    glob = joint_transforms(joints, pose, root_offset, facing)
    amb = np.asarray(ambient, np.float32)
    order = sorted(range(len(joints)), key=lambda i: (joints[i]["z"], i))
    for i in order:
        j = joints[i]
        if j["name"] in hide:
            continue
        res = results[j["part"]]
        part = parts[j["part"]]
        piv = (-part.x0 * OUT, -part.y0 * OUT)
        h, w = res["alpha"].shape
        A = glob[j["name"]]
        # output-pixel bounding box of the part
        corners = []
        for tu, tv in ((0, 0), (w, 0), (0, h), (w, h)):
            lx, ly = (tu - piv[0]) / OUT, (tv - piv[1]) / OUT
            gx, gy, _ = A @ np.array([lx, ly, 1.0])
            corners.append(((gx - vx) * scale, (gy - vy) * scale))
        cx = [c[0] for c in corners]
        cy = [c[1] for c in corners]
        x0, x1 = max(int(math.floor(min(cx))) - 1, 0), min(int(math.ceil(max(cx))) + 1, W)
        y0, y1 = max(int(math.floor(min(cy))) - 1, 0), min(int(math.ceil(max(cy))) + 1, H)
        if x0 >= x1 or y0 >= y1:
            continue
        yy, xx = np.mgrid[y0:y1, x0:x1].astype(np.float64)
        wx = (xx + 0.5) / scale + vx
        wy = (yy + 0.5) / scale + vy
        Ai = np.linalg.inv(A)
        lx = Ai[0, 0] * wx + Ai[0, 1] * wy + Ai[0, 2]
        ly = Ai[1, 0] * wx + Ai[1, 1] * wy + Ai[1, 2]
        u = lx * OUT + piv[0]
        v = ly * OUT + piv[1]
        pa = res["alpha"][..., None]
        stack = np.concatenate([res["albedo"] * pa, res["normal"] * pa, res["spec"][..., None] * pa,
                                res["gloss"][..., None] * pa, res["emis"][..., None] * pa, pa], axis=-1)
        s = _bilinear(stack, u, v)       # premultiplied, like fix_alpha_border's bleed
        a = s[..., 9]
        if not np.any(a > 0.002):
            continue
        wa = np.maximum(a, 1e-6)[..., None]
        alb = s[..., 0:3] / wa
        if j["far"]:
            alb = alb * FAR_TINT
        nl = s[..., 3:6]
        nl = nl / np.maximum(np.linalg.norm(nl, axis=-1, keepdims=True), 1e-6)
        if not normals_on:
            nl = np.zeros_like(nl)
            nl[..., 2] = 1.0
        lin = A[:2, :2]
        n = np.stack([lin[0, 0] * nl[..., 0] + lin[0, 1] * nl[..., 1],
                      lin[1, 0] * nl[..., 0] + lin[1, 1] * nl[..., 1], nl[..., 2]], -1)
        sp = s[..., 6] / wa[..., 0]
        gl = s[..., 7] / wa[..., 0]
        em = s[..., 8] / wa[..., 0]
        col = alb * amb
        ecol, eeng = alb, emissive_energy
        if emissive_override and j["name"] in emissive_override:
            rgb, eeng = emissive_override[j["name"]]
            ecol = np.broadcast_to(np.asarray(rgb, np.float32), alb.shape)
        col = col + ecol * eeng * em[..., None]
        for L in lights:
            if L.direction is not None:
                d = np.array([L.direction[0], L.direction[1], L.height], np.float64)
                d = d / np.linalg.norm(d)
                Lv = np.broadcast_to(d, n.shape)
                att = 1.0
            else:
                dx = L.pos[0] - wx
                dy = L.pos[1] - wy
                Lv = np.stack([dx, dy, np.full_like(dx, L.height)], -1)
                Lv = Lv / np.linalg.norm(Lv, axis=-1, keepdims=True)
                att = disc_falloff(np.sqrt(dx * dx + dy * dy) / L.radius)[..., None]
            ndl = np.sum(n * Lv, -1, keepdims=True)
            diff = np.clip((ndl + wrap) / (1.0 + wrap), 0, 1)
            hv = Lv + np.array([0, 0, 1.0])
            hv = hv / np.linalg.norm(hv, axis=-1, keepdims=True)
            shin = np.exp2(gl * 10 + 1)[..., None]
            spec = np.power(np.clip(np.sum(n * hv, -1, keepdims=True), 0, 1), shin) * sp[..., None] * (shin + 8) / 25.0
            spec = spec * (ndl > 0)
            col = col + (alb * diff + spec) * L.color * L.energy * att
        sub = img[y0:y1, x0:x1]
        img[y0:y1, x0:x1] = sub * (1 - a[..., None]) + col * a[..., None]
    return np.clip(img, 0, 1)


def to_image(img, zoom=1, nearest=True):
    im = Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8))
    if zoom != 1:
        im = im.resize((im.size[0] * zoom, im.size[1] * zoom), Image.NEAREST if nearest else Image.LANCZOS)
    return im


def silhouette(joints, parts, results, pose=None, scale=1.0, view=(-40, -110, 80, 120), facing=1, root_offset=(0.0, 0.0)):
    """A flat black silhouette on a light grey card (the grayscale readability check)."""
    img = render(joints, parts, results, pose, (), scale, view, (0, 0, 0), facing, root_offset=root_offset,
                 bg=np.array([0.78, 0.78, 0.78], np.float32), emissive_energy=0.0)
    return img


def sheet(cells, cols, pad=8, bg=(12, 16, 24), label_h=14):
    """Lay out (label, PIL image) cells in a grid with small labels."""
    font = ImageFont.load_default()
    rows = (len(cells) + cols - 1) // cols
    cw = max(im.size[0] for _, im in cells)
    ch = max(im.size[1] for _, im in cells)
    W = cols * (cw + pad) + pad
    H = rows * (ch + label_h + pad) + pad
    out = Image.new("RGB", (W, H), bg)
    d = ImageDraw.Draw(out)
    for k, (label, im) in enumerate(cells):
        r, c = divmod(k, cols)
        x = pad + c * (cw + pad)
        y = pad + r * (ch + label_h + pad)
        d.text((x, y), label, fill=(200, 208, 220), font=font)
        out.paste(im.convert("RGB"), (x, y + label_h))
    return out


def lamp_lights(x=-18.0, y=-128.0, height=70.0, energy=1.6, flash=True, moon=True):
    """The preview's standard night: a cold path lamp overhead, Dave's ivory muzzle
    flash from the left and the cool moon rim from the upper left."""
    ls = [Light(hexc("#DCE6FF"), energy, (x, y), height, 190.0)]
    if flash:
        ls.append(Light(hexc("#FFE4BD"), 1.2, (-40.0, -52.0), 26.0, 110.0))
    if moon:
        ls.append(Light(hexc("#7E93C9"), 0.38, direction=(-1.0, -0.8), height=0.4))
    return ls


def ground_offset(joints, pose, sole_points, feet=("near_foot", "far_foot")):
    """The root y offset that puts the lowest sole point on y = 0 (the rig's ground lock)."""
    glob = joint_transforms(joints, pose)
    lowest = -1e9
    for f in feet:
        if f not in glob:
            continue
        for x, y in sole_points:
            lowest = max(lowest, (glob[f] @ np.array([x, y, 1.0]))[1])
    return (0.0, -lowest) if lowest > -1e9 else (0.0, 0.0)


def backdrop(view, scale, color=NIGHT_BG, floor=(0.13, 0.16, 0.22)):
    """A night background with the floor (y >= 0) as a flat slab with a lit top edge,
    so feet and wheels can be judged against it (pass as render(bg=...))."""
    vx, vy, vw, vh = view
    W, H = int(round(vw * scale)), int(round(vh * scale))
    img = np.zeros((H, W, 3), np.float32)
    img[:] = color
    y0 = int(round((0.0 - vy) * scale))
    if floor is not None and 0 <= y0 < H:
        img[y0:] = np.asarray(floor, np.float32)
        img[y0:y0 + max(1, int(round(scale)))] = np.asarray(floor, np.float32) * 1.9
    return img



def preview_rig(path, joints, parts, results, poses, view, root_fn=None, lights=None):
    """Write one preview sheet for a rig: every pose at 3x (detail), then the first pose
    at gameplay size (1x, shown x3 with nearest-neighbour pixels), at 2x, mirrored, and as
    a flat silhouette. `poses` is a list of (label, pose, emissive_override); `root_fn(pose)`
    returns the root offset that keeps the rig on the floor (the ground lock)."""
    lights = lamp_lights() if lights is None else lights
    root_fn = root_fn or (lambda pose: (0.0, 0.0))
    cells = []
    for label, pose, emissive in poses:
        img = render(joints, parts, results, pose, lights, 3.0, view, root_offset=root_fn(pose),
                     emissive_override=emissive, bg=backdrop(view, 3.0))
        cells.append((label + " (3x)", to_image(img)))
    label, pose, emissive = poses[0]
    root = root_fn(pose)
    for zoom, show, facing, tag in ((1, 3, 1, "1x, shown x3"), (2, 2, 1, "2x, shown x2"), (2, 2, -1, "2x mirrored")):
        img = render(joints, parts, results, pose, lights, float(zoom), view, root_offset=root, facing=facing,
                     emissive_override=emissive, bg=backdrop(view, float(zoom)))
        cells.append(("%s %s" % (label, tag), to_image(img, show)))
    sil = silhouette(joints, parts, results, pose, 1.0, view, root_offset=root)
    cells.append(("silhouette 1x, shown x3", to_image(sil, 3)))
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    sheet(cells, 4).save(path)
    return path

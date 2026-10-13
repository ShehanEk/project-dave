#!/usr/bin/env python3
"""Paint the blood decals for lit characters (C29, C35), procedurally.

Blood is never painted into a character's parts: scripts/effects/blood.gd sprays
drops, sticks wound marks to the part that was hit and spreads pools under a
settled body, all drawn with the lit part shader so they glint under lamps and
stay dark red in the dark. Blood is #B3212F drying to #8A1A26: never a tell
colour, never glowing.

Outputs (assets/effects/blood/):
  drop.png                 16 px white droplet (tinted in the engine) for particles
  wound_0..2.png           wound marks (albedo), drawn at 3x like the rigs
  wound_0..2_n.png         their normal maps (R = +x, G = +y up, B = z)
  pool.png, pool_n.png     a thin wet sheet on the floor line, seen almost edge-on
  wet_spec.png             4x4 wet specular (R = strength, G = gloss, B = no emission)
  flat_normal.png          4x4 flat normal (128, 128, 255)

Run from the project root:  python3 tools/art/paint_blood.py
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import OUT, SS, downsample, gblur, hexc, normal_to_rgb, save_rgba, smooth_noise  # noqa: E402

OUT_DIR = os.path.join(lr.PROJECT, "assets", "effects", "blood")
SEED = 20260929
WET = hexc("#B3212F")


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


def wounds():
    """Three wound marks (world size 7, 8 with a drip, 6 px), wet, with a darker core."""
    for i, (size, drip) in enumerate(((7, False), (8, True), (6, False))):
        m = blob_mask(size * OUT, 90 + i, 6 + i, drip)
        m = gblur(m, 1.5 * SS)
        a = np.clip((m - 0.35) * 3.0, 0, 1)
        core = np.clip((gblur(m, 3 * SS) - 0.5) * 2.5, 0, 1)
        rgb = WET[None, None, :] * (1 - 0.55 * core[..., None])
        h = gblur(a, 2.0 * SS) * 2.0 * SS
        n = lr.height_to_normal(h)
        res = downsample(rgb, n, np.full(a.shape, 0.75), np.full(a.shape, 0.82), np.zeros(a.shape), a)
        save_rgba(os.path.join(OUT_DIR, "wound_%d.png" % i), res["albedo"], res["alpha"])
        save_rgba(os.path.join(OUT_DIR, "wound_%d_n.png" % i), normal_to_rgb(res["normal"]), res["alpha"])


def pool():
    """A thin wet sheet on the floor line (120 x 8 world px), seen almost edge-on."""
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
    rgb = np.broadcast_to(WET, a.shape + (3,)).copy()
    rgb *= (0.85 + 0.15 * smooth_noise(a.shape, 30))[..., None]
    hgt = gblur(a, 1.5 * SS) * 1.2 * SS
    n = lr.height_to_normal(hgt)
    res = downsample(rgb, n, np.full(a.shape, 0.9), np.full(a.shape, 0.9), np.zeros(a.shape), a)
    save_rgba(os.path.join(OUT_DIR, "pool.png"), res["albedo"], res["alpha"])
    save_rgba(os.path.join(OUT_DIR, "pool_n.png"), normal_to_rgb(res["normal"]), res["alpha"])


def helpers():
    # droplet for particles (white, tinted in engine)
    n = 16
    yy, xx = np.mgrid[0:n, 0:n] + 0.5
    r = np.sqrt((xx - n / 2) ** 2 + (yy - n / 2) ** 2) / (n / 2)
    a = np.clip((1.0 - r) * 2.2, 0, 1)
    save_rgba(os.path.join(OUT_DIR, "drop.png"), np.ones((n, n, 3), np.float32), a)
    # flat helpers: a 4x4 flat normal and a wet spec for decals
    save_rgba(os.path.join(OUT_DIR, "flat_normal.png"),
              np.broadcast_to(np.array([0.5, 0.5, 1.0], np.float32), (4, 4, 3)).copy(), np.ones((4, 4), np.float32))
    save_rgba(os.path.join(OUT_DIR, "wet_spec.png"),
              np.broadcast_to(np.array([0.85, 0.85, 0.0], np.float32), (4, 4, 3)).copy(), np.ones((4, 4), np.float32))


def main():
    lr.seed(SEED)
    os.makedirs(OUT_DIR, exist_ok=True)
    wounds()
    pool()
    helpers()
    print("blood decals ->", OUT_DIR)


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Paint the W02 Boom Broom as a lit-cutout prop rig (placeholder, M3), and its HUD icon.

Dave's pump-action industrial shotgun (art-design/weapons/w02-boom-broom.md): a thick
galvanized pipe barrel with a dark muzzle collar above a parallel magazine tube, an
oversized ribbed coolant-green pump on that tube, a compact maintenance-orange receiver
with a big side ejection port, a charcoal pistol grip and a short padded shoulder stock.
About 0.92 m long: 55 world px here, drawn at 0.9 (boom_broom.gd ART_SCALE), so about
50 px in game, the muzzle 33 px from the grip. Palette: maintenance orange #E0702A,
galvanized pipe grey #AEB9BF, coolant green #3E9E7E, dark steel #444F58, shell red
#C8503C, brass #C9A24D; upgrade accents ember #FF9436, ceramic #D6DCDF, bronze #8C4F2E,
chip gold #FFD166.

Parts (the painted sheet `boom-broom-parts-v1` replaces this folder through an
import_parts_sheet.py entry with the same joint names and sockets; see the commented
"boom_broom_hd" template there):

  body         the root: receiver, barrel, magazine tube, grip, guard and stock in one
               piece; its origin is the grip, where Dave's fist holds it
  pump         the coolant-green slide on the tube; boom_broom.gd slides it back and
               forward on every pump
  shell        one squat red shell with a brass rim, hidden on the gun: each ejected
               casing is a copy of it
  ext_tube     stage 1 Extended Tube: a longer pale tube and an orange end cap with a chip
  heat_collar  stage 2 Incendiary Shells: a ceramic collar behind the muzzle, three ember
               vents (emissive)
  twin_pod     stage 3 Twin Shell: a pressure pod on the receiver, two ember windows
               (emissive) and a selector paddle

Sockets: `grip` (the origin), `muzzle` (the pellets and the flash leave here), `eject`
(the ejection port: casings fly from here), `support` (on the pump, where the support
hand would hold it).

Outputs: assets/characters/lit/boom_broom/{albedo,normal,spec}.png and rig.json, and the
HUD icon assets/ui/pixel/weapon_boom_broom.png (24 x 14 UI px, like weapon_scrapjack)
with its painted twin assets/ui/hd/weapon_boom_broom.png (x6). Run from the project
root:  python3 tools/art/paint_boom_broom.py [--preview DIR]
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lit_rig_common as lr  # noqa: E402
from lit_rig_common import Part, ellipse_pts, hexc, rect_pts  # noqa: E402

OUT_DIR = os.path.join(lr.LIT_DIR, "boom_broom")
UI_PIXEL = os.path.join(lr.PROJECT, "assets", "ui", "pixel", "weapon_boom_broom.png")
UI_HD = os.path.join(lr.PROJECT, "assets", "ui", "hd", "weapon_boom_broom.png")
SEED = 20261013

ORANGE = hexc("#E0702A")
PIPE = hexc("#AEB9BF")
GREEN = hexc("#3E9E7E")
STEEL = hexc("#444F58")
CHARCOAL = hexc("#2F3438")
RUBBER = hexc("#22262A")
SHELL_RED = hexc("#C8503C")
BRASS = hexc("#C9A24D")
EMBER = hexc("#FF9436")
CERAMIC = hexc("#D6DCDF")
BRONZE = hexc("#8C4F2E")
GOLD = hexc("#FFD166")
TAG = hexc("#9AA3A8")

PUMP_POS = (13.0, -1.0)      # the pump's joint on the body (its rear lower edge line)
SHELL_POS = (3.8, -5.6)      # the shell's joint: the ejection port's centre
EXT_POS = (30.5, -1.0)
COLLAR_POS = (26.0, -5.3)
POD_POS = (-2.5, -8.6)


def paint_body():
    p = Part("body", -19.6, -9.6, 37.0, 7.6)
    # the short padded stock, charcoal, with a rubber shoulder pad at its end
    stock = [(-5.5, -7.6), (-15.6, -6.6), (-17.2, -6.9), (-17.2, 3.4), (-15.4, 3.0), (-5.5, -1.6)]
    p.shell(stock, CHARCOAL, "plastic", bevel=0.9, crown=0.2, smooth=False)
    pad = rect_pts(-19.2, -7.6, -16.6, 4.0, 0.8)
    p.shell(pad, RUBBER, "rubber", bevel=0.8, crown=0.25, smooth=False, replace=True)
    for y in (-5.0, -2.6, -0.2, 2.2):
        p.seam([(-19.0, y), (-16.8, y)], 0.12, 0.16, 0.5, smooth=False)
    # the magazine tube under the barrel (dark steel), its front cap
    tube = rect_pts(7.5, -2.8, 30.6, 0.8, 1.2)
    p.shell(tube, STEEL, "steel", bevel=0.9, crown=0.35, smooth=False)
    p.seam([(29.6, -2.6), (29.6, 0.6)], 0.12, 0.18, 0.5, smooth=False)
    # the barrel: galvanized coolant pipe with a dark muzzle collar
    barrel = rect_pts(9.0, -7.6, 33.0, -3.0, 0.6)
    p.shell(barrel, PIPE, "metal", bevel=1.0, crown=0.45, smooth=False)
    for x in (15.0, 21.5, 28.0):
        p.seam([(x, -7.4), (x, -3.2)], 0.1, 0.16, 0.35, smooth=False)
    collar = rect_pts(32.0, -8.4, 36.6, -2.2, 0.8)
    p.shell(collar, STEEL, "steel", bevel=0.8, crown=0.3, smooth=False, replace=True)
    p.patch(ellipse_pts(36.2, -5.3, 0.55, 1.9, 0, 16), RUBBER, "rubber", -0.3, 0.1, smooth=False)
    # the pistol grip (charcoal, raked back) and the trigger guard
    grip = [(-3.2, -2.6), (2.4, -2.6), (1.6, 3.2), (0.4, 6.6), (-2.8, 6.8), (-4.0, 5.6), (-3.6, 1.0)]
    p.shell(grip, CHARCOAL, "rubber", bevel=0.9, crown=0.25, smooth=True)
    for y in (0.0, 1.8, 3.6, 5.2):
        p.seam([(-3.4, y), (1.2, y - 0.3)], 0.1, 0.14, 0.45)
    guard_out = [(2.0, -1.8), (7.4, -1.8), (7.4, 0.6), (6.2, 2.6), (2.6, 2.6), (1.8, 1.0)]
    p.shell(guard_out, STEEL, "steel", bevel=0.5, crown=0.1, smooth=True)
    hole = p.mask(lr.catmull([(2.9, -1.0), (6.6, -1.0), (6.4, 0.6), (5.6, 1.8), (3.0, 1.7)], True, 8))
    p.albedo[hole] = 0.0
    p.cover[hole] = 0.0
    p.sil &= ~hole
    p.height[hole] = 0.0
    trig = p.patch([(3.8, -1.2), (4.6, -1.2), (4.4, 0.9), (3.9, 1.2)], STEEL, "steel", 0.3, 0.08, smooth=False, clip=False)
    p.sil |= trig
    # the receiver: maintenance orange, a heavy dark outline (it sits on Dave's orange jacket)
    recv = rect_pts(-6.2, -8.8, 10.2, -1.6, 0.9)
    p.shell(recv, ORANGE, "paint", bevel=1.0, crown=0.25, smooth=False, replace=True)
    p.seam(rect_pts(-6.0, -8.6, 10.0, -1.8, 0.9), 0.2, 0.4, 0.75, closed=True, smooth=False)
    # the big side ejection port (a dark opening) and the shell's brass edge inside it
    port = rect_pts(1.0, -7.4, 6.8, -3.8, 0.6)
    p.patch(port, RUBBER, "rubber", -0.45, 0.12, smooth=False)
    p.patch(rect_pts(1.6, -6.4, 2.4, -4.8, 0.2), BRASS, "metal", 0.1, 0.05, smooth=False)
    # the pipe-cleaning pictogram (a brush in a pipe, no lettering) and the blank asset tag
    p.seam(ellipse_pts(-3.0, -5.6, 1.4, 1.4, 0, 18), 0.08, 0.16, 0.55, closed=True)
    p.seam([(-3.9, -5.6), (-2.1, -5.6)], 0.06, 0.14, 0.55, smooth=False)
    p.patch(rect_pts(-5.6, -3.4, -1.6, -2.1, 0.2), TAG, "metal", 0.12, 0.05, smooth=False)
    for x in (-4.8, -3.8, -2.8):
        p.seam([(x, -3.2), (x, -2.3)], 0.04, 0.1, 0.35, smooth=False)
    # four embossed capacity marks on the receiver (Extended Tube shows six on its own part)
    for k in range(4):
        p.dot(7.0 + k * 0.8, -7.3, 0.28, STEEL, "steel", -0.08)
    # wear on the collar and the pad (painted value, never light)
    p.tint(rect_pts(32.2, -8.2, 36.4, -6.8, 0.3), hexc("#6E7880"), 0.35)
    return p


def paint_pump():
    """Pump-local: its joint is the rear lower edge line on the tube (body PUMP_POS)."""
    p = Part("pump", -0.4, -3.6, 11.4, 2.8)
    pump = rect_pts(0.0, -3.2, 11.0, 2.4, 1.3)
    p.shell(pump, GREEN, "plastic", bevel=1.1, crown=0.35, smooth=False)
    for k in range(6):
        x = 1.5 + k * 1.6
        p.seam([(x, -2.9), (x, 2.1)], 0.22, 0.32, 0.55, smooth=False)
    p.tint(rect_pts(0.2, 1.4, 10.8, 2.3, 0.4), hexc("#2C6E58"), 0.4)
    return p


def paint_shell():
    """A squat red shell capsule with a brass rim, centred on its joint."""
    p = Part("shell", -2.6, -1.9, 2.8, 1.9)
    body = rect_pts(-1.4, -1.7, 2.6, 1.7, 0.9)
    p.shell(body, SHELL_RED, "plastic", bevel=0.8, crown=0.35, smooth=False)
    rim = rect_pts(-2.4, -1.9, -0.9, 1.9, 0.4)
    p.shell(rim, BRASS, "metal", bevel=0.5, crown=0.2, smooth=False, replace=True)
    p.seam([(-1.0, -1.6), (-1.0, 1.6)], 0.08, 0.12, 0.4, smooth=False)
    return p


def paint_ext_tube():
    """Stage 1 Extended Tube: a longer pale pipe segment and a rounded orange end cap with a
    small chip module, in front of the stock tube (the pump's travel stays clear)."""
    p = Part("ext_tube", -0.4, -2.2, 9.6, 2.2)
    seg = rect_pts(0.0, -1.7, 6.2, 1.7, 0.6)
    p.shell(seg, CERAMIC, "metal", bevel=0.8, crown=0.35, smooth=False)
    for k in range(6):
        p.dot(0.8 + k * 0.9, -1.0, 0.22, STEEL, "steel", -0.06)
    cap = [(6.0, -2.0), (8.0, -2.0), (9.2, -1.0), (9.2, 1.0), (8.0, 2.0), (6.0, 2.0)]
    p.shell(cap, ORANGE, "paint", bevel=0.7, crown=0.3, smooth=True)
    p.patch(rect_pts(6.8, -0.8, 8.2, 0.6, 0.1), BRONZE, "plastic", 0.1, 0.05, smooth=False)
    p.seam(rect_pts(6.7, -0.9, 8.3, 0.7, 0.1), 0.04, 0.08, 0.2, closed=True, smooth=False)
    p.patch(rect_pts(6.75, -0.85, 8.25, -0.6, 0.0), GOLD, "metal", 0.02, 0.03, smooth=False)
    return p


def paint_heat_collar():
    """Stage 2 Incendiary Shells: a thick ceramic heat collar behind the muzzle collar, three
    protected ember vent windows (emissive) and a chip module on its flank."""
    p = Part("heat_collar", -0.4, -3.9, 6.4, 3.9)
    collar = rect_pts(0.0, -3.5, 6.0, 3.5, 1.0)
    p.shell(collar, CERAMIC, "shell", bevel=1.0, crown=0.3, smooth=False)
    for k in range(3):
        x = 1.0 + k * 1.6
        p.patch(rect_pts(x, -2.4, x + 0.9, 0.2, 0.3), EMBER, "glass", -0.1, 0.05, smooth=False, emissive=1.0)
    p.patch(rect_pts(1.6, 1.2, 3.2, 2.6, 0.1), BRONZE, "plastic", 0.1, 0.05, smooth=False)
    p.patch(rect_pts(1.65, 1.25, 3.15, 1.5, 0.0), GOLD, "metal", 0.02, 0.03, smooth=False)
    return p


def paint_twin_pod():
    """Stage 3 Twin Shell: a pressure-indicator pod on the receiver with two round ember
    windows (emissive), a broad selector paddle on its left and a chip at its rear."""
    p = Part("twin_pod", -0.4, -4.4, 10.4, 0.4)
    pod = rect_pts(0.6, -3.6, 9.4, 0.2, 1.0)
    p.shell(pod, BRONZE, "paint", bevel=0.8, crown=0.3, smooth=False)
    for cx in (3.8, 6.6):
        p.patch(ellipse_pts(cx, -1.7, 1.0, 1.0, 0, 16), EMBER, "glass", -0.1, 0.05, smooth=False, emissive=1.0)
    paddle = [(0.0, -1.2), (1.4, -4.2), (2.4, -4.2), (1.4, -1.0)]
    p.shell(paddle, STEEL, "steel", bevel=0.4, crown=0.1, smooth=False)
    p.patch(rect_pts(7.8, -3.0, 9.0, -1.6, 0.1), GOLD, "metal", 0.02, 0.03, smooth=False)
    return p


def cap(ax, ay, bx, by, r):
    return {"type": "capsule", "a": [ax, ay], "b": [bx, by], "r": r}


RIG = [
    # name, part, parent, pos, z, far, collider, mass, limit, role, rest_dir
    ("body", "body", "", (0.0, 0.0), 1, False, cap(-17.0, -3.0, 34.0, -4.5, 4.0), 3.0, None, "frame", 0),
    ("shell", "shell", "body", SHELL_POS, 0, False, cap(-1.5, 0.0, 1.5, 0.0, 1.6), 0.05, None, "shell", 0),
    ("ext_tube", "ext_tube", "body", EXT_POS, 2, False, cap(0.5, 0.0, 8.5, 0.0, 1.8), 0.2, None, "upgrade", 0),
    ("pump", "pump", "body", PUMP_POS, 3, False, cap(1.0, -0.4, 10.0, -0.4, 2.6), 0.4, None, "pump", 0),
    ("heat_collar", "heat_collar", "body", COLLAR_POS, 3, False, cap(1.0, 0.0, 5.0, 0.0, 3.2), 0.3, None, "upgrade", 0),
    ("twin_pod", "twin_pod", "body", POD_POS, 3, False, cap(1.0, -1.7, 9.0, -1.7, 1.8), 0.3, None, "upgrade", 0),
]
SOCKETS = {
    "grip": ("body", (0.0, 0.0)),
    "muzzle": ("body", (36.8, -5.3)),
    "eject": ("body", (3.8, -5.6)),
    "support": ("pump", (5.5, -0.4)),
}
PAINTERS = {"body": paint_body, "pump": paint_pump, "shell": paint_shell, "ext_tube": paint_ext_tube,
            "heat_collar": paint_heat_collar, "twin_pod": paint_twin_pod}
# The HUD icon is the base gun (stage 0): no upgrade parts, no loose shell.
ICON_PARTS = ["body", "pump"]


def joints():
    return [{"name": n, "part": pt, "parent": par, "pos": pos, "z": z, "far": far, "collider": col,
             "mass": mass, "limit": lim, "rest_dir": rd, "role": role}
            for (n, pt, par, pos, z, far, col, mass, lim, role, rd) in RIG]


def _flat_composite(parts, results, names):
    """The rest pose's albedo, flat (no light), at lr.OUT texels per world px, cropped."""
    pos = {"body": (0.0, 0.0)}
    for (n, _pt, par, p, *_rest) in RIG:
        if par:
            pos[n] = (pos[par][0] + p[0], pos[par][1] + p[1])
    order = sorted(names, key=lambda n: [r[4] for r in RIG if r[0] == n][0])
    x0 = min(pos[n][0] + parts[n].x0 for n in names)
    y0 = min(pos[n][1] + parts[n].y0 for n in names)
    x1 = max(pos[n][0] + parts[n].x0 + results[n]["alpha"].shape[1] / lr.OUT for n in names)
    y1 = max(pos[n][1] + parts[n].y0 + results[n]["alpha"].shape[0] / lr.OUT for n in names)
    w, h = int(np.ceil((x1 - x0) * lr.OUT)) + 2, int(np.ceil((y1 - y0) * lr.OUT)) + 2
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for n in order:
        res = results[n]
        rgba = np.concatenate([np.clip(res["albedo"], 0, 1), res["alpha"][..., None]], -1)
        img = Image.fromarray((rgba * 255 + 0.5).astype(np.uint8))
        ox = int(round((pos[n][0] + parts[n].x0 - x0) * lr.OUT))
        oy = int(round((pos[n][1] + parts[n].y0 - y0) * lr.OUT))
        canvas.alpha_composite(img, (ox, oy))
    return canvas.crop(canvas.getbbox())


def _outlined(img, width):
    """`img` with a near-black outline `width` texels thick round its silhouette (the HUD's)."""
    a = img.getchannel("A").point(lambda v: 255 if v > 90 else 0)
    grown = a
    for _ in range(width):
        grown = grown.filter(ImageFilter.MaxFilter(3))
    out = Image.new("RGBA", img.size, (7, 9, 15, 0))
    out.putalpha(grown)
    out.alpha_composite(img)
    return out


def _fit(img, size, pad):
    """`img` scaled to fit inside `size` less `pad` on every side, centred."""
    w, h = size
    k = min((w - 2 * pad) / img.width, (h - 2 * pad) / img.height)
    scaled = img.resize((max(1, int(round(img.width * k))), max(1, int(round(img.height * k)))), Image.LANCZOS)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    out.alpha_composite(scaled, ((w - scaled.width) // 2, (h - scaled.height) // 2))
    return out


def write_icons(parts, results):
    flat = _flat_composite(parts, results, ICON_PARTS)
    # Painted twin (assets/ui/hd, x6 the pixel piece): the gun with a 3-texel outline.
    big = _outlined(_fit(flat, (144, 84), 6), 3)
    os.makedirs(os.path.dirname(UI_HD), exist_ok=True)
    big.save(UI_HD)
    # The pixel piece: one texel per UI pixel, hard alpha, a one-pixel outline.
    small = _fit(flat, (24, 14), 1)
    arr = np.array(small)
    arr[..., 3] = np.where(arr[..., 3] > 110, 255, 0)
    small = _outlined(Image.fromarray(arr), 1)
    arr = np.array(small)
    arr[..., 3] = np.where(arr[..., 3] > 110, 255, 0)
    Image.fromarray(arr).save(UI_PIXEL)
    print("icons ->", UI_PIXEL, UI_HD)


def main():
    lr.refuse_to_overwrite_art(OUT_DIR)
    lr.seed(SEED)
    parts, results = lr.paint_parts(PAINTERS)
    parts_json, size = lr.write_atlas(OUT_DIR, parts, results, width=256)
    lr.write_rig_json(OUT_DIR, "W02 Boom Broom (placeholder)", "prop", parts_json, joints(),
                      ground_lock=False, sockets=SOCKETS)
    write_icons(parts, results)
    out = lr.preview_arg()
    if out:
        base = {"heat_collar": (EMBER, 0.0), "twin_pod": (EMBER, 0.0)}
        lr.preview_rig(os.path.join(out, "boom_broom_preview.png"), joints(), parts, results,
                       [("rest", {}, base)], (-24, -16, 44, 12),
                       lights=lr.lamp_lights(x=0, y=-40, height=40))
    print("atlas", size[0], size[1], "->", OUT_DIR)


if __name__ == "__main__":
    sys.exit(main())

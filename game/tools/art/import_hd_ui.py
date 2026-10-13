#!/usr/bin/env python3
"""Import the hand-painted effects, HUD and menu sheet (batch 3, art-design/handpainted-style.md,
concept-art/style-handpainted/ui-fx-hd-v1.webp). Run from the project root:
    python3 tools/art/import_hd_ui.py

Outputs (the pixel pieces stay as they are; they still give every piece its layout size):
- assets/effects/hd/<effect>.png and effects.json: one strip per effect, frame cells K texels per
  art px around the pixel effect's own anchor (K per effect, the largest painted frame fitting the
  pixel frame), the painted frames at the sheet's own resolution. scripts/effects/pixel_fx.gd plays
  them in place of the pixel strips.
- assets/ui/hd/<piece>.png: every HUD and menu piece at UI_K texels per UI pixel of the pixel
  piece's size. Icons are fitted inside it (aspect kept, centred); frames are nine-sliced so the
  painted border keeps its thickness and the plain face stretches. scripts/ui/pixel_ui.gd draws
  them at the pixel piece's size (an ImageTexture size override).
- assets/ui/hd/x3/<piece>.png: the theme's frames at 3 canvas px per UI pixel (1 texel per px).
- assets/ui/hd/title_logo.png: the logo.
"""
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_hd_env import resize  # noqa: E402
from import_parts_sheet import REPO  # noqa: E402

PROJECT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
SHEET = os.path.join(REPO, "concept-art/style-handpainted/ui-fx-hd-v1.webp")
FX_PIX = os.path.join(PROJECT, "assets/effects/pixel")
FX_OUT = os.path.join(PROJECT, "assets/effects/hd")
UI_PIX = os.path.join(PROJECT, "assets/ui/pixel")
UI_OUT = os.path.join(PROJECT, "assets/ui/hd")
UI_K = 6

# --- effects ------------------------------------------------------------------------------------

# Per effect: the sheet rows (y from, to), each frame's columns (x from, to), and how the anchor's
# y is found: "union" (the middle of all frames' rows), "frame" (each frame's own middle),
# "bottom" (the floor under all frames).
FX = {
    "bullet_impact": {"y": (20, 176), "ymode": "union", "grey": True,
                      "cols": [(55, 130), (130, 240), (240, 385), (385, 545), (548, 700)]},
    "muzzle_flash": {"y": (20, 176), "ymode": "union", "stub": True,
                     "cols": [(805, 990), (990, 1200), (1200, 1368), (1368, 1515)]},
    "checkpoint_sparkle": {"y": (176, 345), "ymode": "union",
                           "cols": [(45, 135), (135, 250), (255, 375), (385, 515), (530, 650), (665, 760)]},
    "chip_glint": {"y": (176, 345), "ymode": "frame",
                   "cols": [(890, 995), (1005, 1145), (1145, 1332), (1335, 1440)]},
    # The sheet has six dust frames; the game plays five (the last, nearly gone, is left out).
    "landing_dust": {"y": (340, 472), "ymode": "bottom",
                     "cols": [(30, 135), (135, 258), (258, 430), (430, 558), (558, 660)]},
    "machine_break": {"y": (340, 472), "ymode": "union",
                      "cols": [(750, 870), (870, 1005), (1005, 1143), (1143, 1297), (1297, 1416), (1416, 1525)]},
}


def sheet():
    return np.asarray(Image.open(SHEET).convert("RGBA"), np.float32)


def bbox(a, thr=40):
    ys, xs = np.nonzero(a > thr)
    return xs.min(), ys.min(), xs.max() + 1, ys.max() + 1


def effects(sh):
    meta = json.load(open(os.path.join(FX_PIX, "effects.json")))
    out = {}
    os.makedirs(FX_OUT, exist_ok=True)
    for name, cfg in FX.items():
        fs = meta[name]["frame_size"]
        an = meta[name]["anchor"]
        y0, y1 = cfg["y"]
        frames = []
        for x0, x1 in cfg["cols"]:
            crop = sh[y0:y1, x0:x1].copy()
            if cfg.get("stub"):
                # The barrel stub left of the flame: cut at the first column with white-hot flame.
                lum = crop[..., :3].mean(-1) * (crop[..., 3] > 128)
                hot = np.nonzero((lum > 215).any(0))[0]
                crop[:, :max(0, hot.min() - 2)] = 0.0
            frames.append((x0, crop))
        boxes = [bbox(c[..., 3]) for _, c in frames]
        uy0 = min(b[1] for b in boxes)
        uy1 = max(b[3] for b in boxes)
        anchors = []
        for (x0, crop), b in zip(frames, boxes):
            ax = b[0] if cfg.get("stub") else (b[0] + b[2]) * 0.5
            if cfg["ymode"] == "union":
                ay = (uy0 + uy1) * 0.5
            elif cfg["ymode"] == "bottom":
                ay = uy1
            else:
                ay = (b[1] + b[3]) * 0.5
            anchors.append((ax, ay))
        # K texels per art px: every frame fits the pixel frame around the pixel anchor.
        k = 0.0
        for b, (ax, ay) in zip(boxes, anchors):
            for need, room in ((ax - b[0], an[0]), (b[2] - ax, fs[0] - an[0]),
                               (ay - b[1], an[1]), (b[3] - ay, fs[1] - an[1])):
                if room > 0:
                    k = max(k, need / room)
        cw, ch = int(np.ceil(fs[0] * k)), int(np.ceil(fs[1] * k))
        strip = np.zeros((ch, cw * len(frames), 4), np.float32)
        for i, ((x0, crop), (ax, ay)) in enumerate(zip(frames, anchors)):
            ox = int(round(an[0] * k - ax))
            oy = int(round(an[1] * k - ay))
            h, w = crop.shape[:2]
            sx0, sy0 = max(0, -ox), max(0, -oy)
            dx0, dy0 = max(0, ox), max(0, oy)
            ww = min(w - sx0, cw - dx0)
            hh = min(h - sy0, ch - dy0)
            if ww > 0 and hh > 0:
                cell = strip[:, i * cw:(i + 1) * cw]
                src = crop[sy0:sy0 + hh, sx0:sx0 + ww]
                dst = cell[dy0:dy0 + hh, dx0:dx0 + ww]
                np.copyto(dst, np.where(src[..., 3:4] > dst[..., 3:4], src, dst))
        if cfg.get("grey"):
            # The game tints the impact with the hit's colour: make it white-hot rather than orange.
            g = (strip[..., 0] * 0.3 + strip[..., 1] * 0.59 + strip[..., 2] * 0.11) * 1.3
            strip[..., :3] = np.clip(g, 0, 255)[..., None]
        Image.fromarray(np.clip(strip, 0, 255).astype(np.uint8)).save(os.path.join(FX_OUT, name + ".png"))
        out[name] = {"k": round(k, 4), "cell": [cw, ch], "frames": len(frames)}
        print("fx %-20s %d frames, cell %d x %d, k %.2f" % (name, len(frames), cw, ch, k))
    with open(os.path.join(FX_OUT, "effects.json"), "w") as f:
        json.dump(out, f, indent=1, sort_keys=True)


# --- UI -----------------------------------------------------------------------------------------

ICONS = {
    "health_full": (43, 485, 97, 577), "health_empty": (119, 485, 174, 577),
    "health_flash": (197, 484, 253, 577), "chip": (274, 490, 355, 573),
    "keycard": (365, 492, 458, 571), "evidence": (473, 500, 563, 573),
    "lock_closed": (587, 489, 649, 573), "lock_open": (664, 486, 743, 575),
    "warning": (763, 495, 848, 575), "gear": (867, 493, 953, 579), "save": (972, 496, 1049, 572),
    "speaker": (1071, 497, 1163, 573), "subtitle": (1184, 498, 1275, 577), "swap": (1309, 490, 1388, 577),
    "tick": (1419, 494, 1501, 577),
    "weapon_scrapjack": (25, 587, 298, 724),
    "pip_dark": (321, 634, 363, 675), "pip_lit": (378, 632, 424, 678),
    "ready_dark": (440, 633, 483, 676), "ready_lit": (495, 633, 540, 677),
    "arrow_up": (556, 616, 622, 691), "arrow_down": (635, 617, 697, 691),
    "arrow_left": (712, 622, 784, 687), "arrow_right": (803, 622, 875, 687),
    "mouse_left": (981, 608, 1052, 706), "mouse_right": (1070, 608, 1142, 706),
    "key_cap": (1169, 621, 1247, 699), "key_cap_pressed": (1261, 621, 1339, 699),
    "slider_knob": (1183, 771, 1211, 800), "check_off": (1216, 766, 1254, 806),
    "check_on": (1260, 765, 1302, 807),
}
MOUSE_PLAIN = (891, 608, 962, 706)
# Frames, nine-sliced to the pixel piece's size.
FRAMES = {
    "panel": (23, 735, 151, 836), "banner": (153, 760, 336, 811), "tag": (338, 757, 424, 814),
    "prompt_box": (802, 766, 904, 807), "slider_track": (1011, 773, 1090, 799),
    "slider_fill": (1092, 768, 1150, 803), "weapon_slot": (1337, 743, 1512, 829),
    "focus": (728, 749, 800, 820), "key_wide": (1353, 621, 1506, 699),
}
BUTTON_ROW = (428, 762, 727, 810)
BUTTONS = ["button_normal", "button_hover", "button_pressed", "button_disabled"]
DIVIDER = (1311, 758, 1329, 819)
PROMPT_TAG = (904, 763, 1010, 820)
LOGO = (437, 840, 1099, 1006)
THEME_X3 = ["panel", "button_normal", "button_hover", "button_pressed", "button_disabled", "focus",
            "slider_track", "slider_fill", "slider_knob", "check_off", "check_on", "divider",
            "arrow_down", "banner", "prompt_tag", "tag"]


def crop(sh, box):
    x0, y0, x1, y1 = box
    c = sh[y0:y1, x0:x1].copy()
    b = bbox(c[..., 3], 24)
    return c[b[1]:b[3], b[0]:b[2]]


def pix_size(piece):
    return Image.open(os.path.join(UI_PIX, piece + ".png")).size


def save_ui(arr, rel):
    path = os.path.join(UI_OUT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)).save(path)


def fit(c, w, h):
    """`c` scaled to fit a w x h canvas (aspect kept), centred."""
    s = min(w / c.shape[1], h / c.shape[0])
    cw, ch = max(1, int(round(c.shape[1] * s))), max(1, int(round(c.shape[0] * s)))
    r = resize(c, cw, ch)
    out = np.zeros((h, w, 4), np.float32)
    ox, oy = (w - cw) // 2, (h - ch) // 2
    out[oy:oy + ch, ox:ox + cw] = r
    return out


def border(c):
    """The painted border's thickness, sheet px: from each side along the middle row and column
    to where the face colour starts."""
    h, w = c.shape[:2]
    face = c[h // 2, w // 2, :3]
    best = 0
    for line in (c[h // 2, :, :], c[h // 2, ::-1, :], c[:, w // 2, :], c[::-1, w // 2, :]):
        d = np.abs(line[:, :3] - face).sum(-1)
        i = 0
        while i < len(line) // 2 and (d[i] > 40 or line[i, 3] < 200):
            i += 1
        best = max(best, i)
    return best


def nine(c, w, h, corner=None):
    """`c` nine-sliced to w x h: the corners at one uniform scale, edges and face stretched."""
    s = min(w / c.shape[1], h / c.shape[0])
    cs = corner if corner is not None else min(border(c) + 3, min(c.shape[:2]) // 2 - 1)
    d = max(1, min(int(round(cs * s)), w // 2 - 1, h // 2 - 1))
    sx = [0, cs, c.shape[1] - cs, c.shape[1]]
    sy = [0, cs, c.shape[0] - cs, c.shape[0]]
    dx = [0, d, w - d, w]
    dy = [0, d, h - d, h]
    out = np.zeros((h, w, 4), np.float32)
    for j in range(3):
        for i in range(3):
            src = c[sy[j]:sy[j + 1], sx[i]:sx[i + 1]]
            dw, dh = dx[i + 1] - dx[i], dy[j + 1] - dy[j]
            if src.size and dw > 0 and dh > 0:
                out[dy[j]:dy[j + 1], dx[i]:dx[i + 1]] = resize(src, dw, dh)
    return out, d


def ui(sh):
    pieces = {}
    for name, box in ICONS.items():
        pw, ph = pix_size(name)
        pieces[name] = fit(crop(sh, box), pw * UI_K, ph * UI_K)
    # The mouse with an arrow either side: the aim hint.
    pw, ph = pix_size("mouse_aim")
    aim = np.zeros((ph * UI_K, pw * UI_K, 4), np.float32)
    m = fit(crop(sh, MOUSE_PLAIN), 12 * UI_K, ph * UI_K)
    x = (pw * UI_K - m.shape[1]) // 2
    aim[:, x:x + m.shape[1]] = m
    for box, ax in ((ICONS["arrow_left"], 0), (ICONS["arrow_right"], pw * UI_K - 7 * UI_K)):
        a = fit(crop(sh, box), 7 * UI_K, 7 * UI_K)
        y = (ph * UI_K - a.shape[0]) // 2
        aim[y:y + a.shape[0], ax:ax + a.shape[1]] = a
    pieces["mouse_aim"] = aim
    corners = {}
    for name, box in FRAMES.items():
        pw, ph = pix_size(name)
        c = crop(sh, box)
        corner = c.shape[0] // 2 - 1 if name == "focus" else None
        pieces[name], corners[name] = nine(c, pw * UI_K, ph * UI_K, corner)
    # The four buttons, side by side in one run of the sheet: split at the clear columns.
    row = sh[BUTTON_ROW[1]:BUTTON_ROW[3], BUTTON_ROW[0]:BUTTON_ROW[2]]
    clear = row[..., 3].max(0) < 24
    runs, start = [], None
    for i, cl in enumerate(list(clear) + [True]):
        if not cl and start is None:
            start = i
        if cl and start is not None:
            if i - start > 20:
                runs.append((start, i))
            start = None
    # Two buttons may touch: split the longest run at its faintest column in its middle third.
    col = row[..., 3].sum(0)
    while len(runs) < 4:
        a, b = max(runs, key=lambda r: r[1] - r[0])
        t = (b - a) // 3
        cut = a + t + int(np.argmin(col[a + t:b - t]))
        runs.remove((a, b))
        runs += [(a, cut), (cut + 1, b)]
        runs.sort()
    for name, (a, b) in zip(BUTTONS, runs):
        pw, ph = pix_size(name)
        c = crop(sh, (BUTTON_ROW[0] + a, BUTTON_ROW[1], BUTTON_ROW[0] + b, BUTTON_ROW[3]))
        pieces[name], corners[name] = nine(c, pw * UI_K, ph * UI_K)
    # The divider is painted upright: turn it to lie along the row.
    pw, ph = pix_size("divider")
    pieces["divider"], _ = nine(np.rot90(crop(sh, DIVIDER)).copy(), pw * UI_K, ph * UI_K,
                                corner=4)
    # The prompt tag with its pointer, and the pointer alone (under the box's middle).
    tag = crop(sh, PROMPT_TAG)
    pw, ph = pix_size("prompt_tag")
    pieces["prompt_tag"] = fit(tag, pw * UI_K, ph * UI_K)
    # The pointer: the rows at the bottom much narrower than the box (plus the box's bottom edge).
    cover = (tag[..., 3] > 60).sum(1)
    r = tag.shape[0]
    while r > 0 and cover[r - 1] < 0.4 * tag.shape[1]:
        r -= 1
    xs = np.nonzero((tag[r:, :, 3] > 60).any(0))[0]
    tail = tag[max(0, r - 4):, xs.min():xs.max() + 1]
    tb = bbox(tail[..., 3], 24)
    tail = tail[tb[1]:tb[3], tb[0]:tb[2]]
    pw, ph = pix_size("prompt_tail")
    pieces["prompt_tail"] = fit(tail, pw * UI_K, ph * UI_K)
    for name, arr in pieces.items():
        save_ui(arr, name + ".png")
        pw, ph = pix_size(name)
        if name in THEME_X3:
            save_ui(resize(arr, pw * 3, ph * 3), "x3/%s.png" % name)
    for name, d in sorted(corners.items()):
        print("frame %-16s painted corner %5.1f UI px" % (name, d / float(UI_K)))
    logo = crop(sh, LOGO)
    save_ui(logo, "title_logo.png")
    print("ui: %d pieces at %d texels per UI px, logo %d x %d" % (len(pieces), UI_K, logo.shape[1], logo.shape[0]))


if __name__ == "__main__":
    s = sheet()
    effects(s)
    ui(s)

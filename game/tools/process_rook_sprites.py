#!/usr/bin/env python3
"""Turn the generated Rook sprite pack into game-ready textures.

Source: concept-art/h01-rook/sprites-v1/ (user-generated with ChatGPT from
concept-art/h01-rook/rook-sprite-brief-for-chatgpt.md, 2026-09-28; 1254x1254
transparent PNGs). Output: assets/characters/rook/*.png at 2x game scale plus
scripts/actors/visuals/rook_frames.gd (per-frame shoulder pivots).

What it fixes, per the pack's own README ("consistent scale/baseline
alignment ... pending"):
  * faint stray alpha (< 40) across each canvas is cleared;
  * scale drift: the action frames were drawn 3-16% larger than the
    standing frames, by a different amount each (see SCALE below);
    everything is normalised to the standing frames;
  * alignment: every frame goes on one 256x256 canvas with the hero origin
    (feet, centre) at (128, 248). Grounded frames sit on that baseline;
    airborne frames keep the standing head height instead, so tucked legs
    rise instead of the whole body sinking;
  * the near (gun) arm is cut from the parts sheet with its shoulder pivot
    and fist recorded, so the game can rotate it with the aim.

Run from the Godot project root:  python3 tools/process_rook_sprites.py
Requires Pillow.
"""
import os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(PROJECT))
SRC = os.path.join(REPO, "concept-art", "h01-rook", "sprites-v1")
OUT = os.path.join(PROJECT, "assets", "characters", "rook")
FRAMES_GD = os.path.join(PROJECT, "scripts", "actors", "visuals", "rook_frames.gd")

ALPHA_FLOOR = 40            # alpha below this is generator noise
CANVAS = 256                # 2x game scale
ORIGIN = (128, 248)         # hero origin (feet, centre) on the canvas
TARGET_STAND_2X = 196       # standing height at 2x -> ~98 px in game (H = 96)
REF_FILE = "rook-idle-1.png"

# name -> (file, size relative to the standing frames, vertical anchor)
# Each generated frame drifted in scale by a different amount (3-16%), so
# every frame gets its own factor. Measures, all relative to rook-idle-1:
# sqrt of jacket (orange) area, boot-leather diameter, sqrt of total painted
# area, plus head/face size compared by eye. The run frames use the jacket
# measure (the most stable across those poses; it splits cleanly into run
# 1-3 at ~1.12 and run 4-6 at ~1.06, matching the two generation sessions).
# The rest use the median, nudged where one measure is known to misread that
# pose (an outstretched arm adds jacket area; a tuck or crouch hides area; a
# toe-down boot looks shorter).
SCALE = {
    "idle_1": ("rook-idle-1.png", 1.000, "feet"),
    "idle_2": ("rook-idle-2.png", 1.009, "feet"),
    "run_1": ("rook-run-1.png", 1.125, "feet"),
    "run_2": ("rook-run-2.png", 1.125, "feet"),
    "run_3": ("rook-run-3.png", 1.117, "feet"),
    "run_4": ("rook-run-4.png", 1.067, "feet"),
    "run_5": ("rook-run-5.png", 1.053, "feet"),
    "run_6": ("rook-run-6.png", 1.061, "feet"),
    "jump_rise": ("rook-jump-rise.png", 1.080, "head"),
    "jump_fall": ("rook-jump-fall.png", 1.063, "head"),
    "land": ("rook-land.png", 1.030, "feet"),
    "hurt": ("rook-hurt.png", 1.100, "feet"),
    "defeated": ("rook-defeated.png", 1.140, "feet"),
    "interact": ("rook-interact.png", 1.030, "feet"),
}

# Near shoulder measured on the standing frame, relative to the hair
# (top row, horizontal centre) in source pixels at standing scale.
SHOULDER_FROM_HAIR = (548 - 640, 335 - 84)

# Parts sheet: drawn ~5% larger than the standing frames. Arm piece bounds,
# rounded shoulder-cap centre and fist centre, in parts-sheet pixels.
PARTS_FILE = "h01-rook-sprite-parts.png"
PARTS_SCALE = 1.05
ARM_BOX = (596, 318, 1160, 492)
ARM_SHOULDER = (660, 405)
ARM_FIST = (1070, 430)


def load_clean(name):
    im = Image.open(os.path.join(SRC, name)).convert("RGBA")
    alpha = im.getchannel("A").point(lambda v: 0 if v < ALPHA_FLOOR else v)
    im.putalpha(alpha)
    return im


def is_hair(p):
    r, g, b, a = p
    return a >= 200 and (0.3 * r + 0.59 * g + 0.11 * b) < 60


def measure(im):
    """bbox of solid pixels, top row of hair, horizontal centre of the hair band."""
    bbox = im.getchannel("A").point(lambda v: 255 if v >= 128 else 0).getbbox()
    x0, y0, x1, y1 = bbox
    px = im.load()
    top = y0
    for y in range(y0, y1):
        if sum(1 for x in range(x0, x1, 2) if is_hair(px[x, y])) >= 4:
            top = y
            break
    xs = [x for y in range(top, min(top + 90, y1)) for x in range(x0, x1) if is_hair(px[x, y])]
    return bbox, top, (min(xs) + max(xs)) / 2.0


def torso_center(im, bbox):
    x0, y0, x1, y1 = bbox
    h = y1 - y0
    px = im.load()
    xs = [x for y in range(int(y0 + 0.30 * h), int(y0 + 0.45 * h))
          for x in range(x0, x1) if px[x, y][3] >= 128]
    xs.sort()
    return xs[len(xs) // 2]


def main():
    os.makedirs(OUT, exist_ok=True)
    ref = load_clean(REF_FILE)
    ref_bbox, ref_hair_top, ref_hair_cx = measure(ref)
    k0 = TARGET_STAND_2X / float(ref_bbox[3] - ref_bbox[1])
    # Put the standing torso on the hero's centre line.
    head_x = (ref_hair_cx - torso_center(ref, ref_bbox)) * k0
    head_top_y = (ref_hair_top - ref_bbox[3]) * k0  # negative: above the feet

    shoulders = {}
    for name, (fname, rel, anchor) in SCALE.items():
        im = load_clean(fname)
        bbox, hair_top, hair_cx = measure(im)
        k = k0 / rel
        crop = im.crop(bbox)
        crop = crop.resize((max(1, round(crop.width * k)), max(1, round(crop.height * k))), Image.LANCZOS)
        # where the crop's top-left lands on the canvas
        cx = ORIGIN[0] + head_x - (hair_cx - bbox[0]) * k
        if anchor == "feet":
            cy = ORIGIN[1] - crop.height
        else:
            cy = ORIGIN[1] + head_top_y - (hair_top - bbox[1]) * k
        canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
        canvas.alpha_composite(crop, (int(round(cx)), int(round(cy))))
        if (cx < 0 or cy < 0 or cx + crop.width > CANVAS or cy + crop.height > CANVAS):
            print("WARNING: %s is clipped by the canvas" % name)
        canvas.save(os.path.join(OUT, "rook_%s.png" % name))
        # shoulder in 1x game units relative to the hero origin
        hx = cx + (hair_cx - bbox[0]) * k + SHOULDER_FROM_HAIR[0] * k0
        hy = cy + (hair_top - bbox[1]) * k + SHOULDER_FROM_HAIR[1] * k0
        shoulders[name] = ((hx - ORIGIN[0]) / 2.0, (hy - ORIGIN[1]) / 2.0)
        print("%-10s scale 1/%.2f  anchor %-4s  shoulder (%.1f, %.1f)" % (name, rel, anchor, *shoulders[name]))

    # Near (gun) arm from the parts sheet.
    parts = load_clean(PARTS_FILE)
    ka = k0 / PARTS_SCALE
    arm = parts.crop(ARM_BOX)
    arm = arm.resize((round(arm.width * ka), round(arm.height * ka)), Image.LANCZOS)
    arm.save(os.path.join(OUT, "rook_arm.png"))
    arm_shoulder = ((ARM_SHOULDER[0] - ARM_BOX[0]) * ka, (ARM_SHOULDER[1] - ARM_BOX[1]) * ka)
    arm_fist = ((ARM_FIST[0] - ARM_SHOULDER[0]) * ka / 2.0, (ARM_FIST[1] - ARM_SHOULDER[1]) * ka / 2.0)
    print("arm %dx%d  shoulder px (%.1f, %.1f)  fist from shoulder (1x) (%.1f, %.1f)"
          % (arm.width, arm.height, arm_shoulder[0], arm_shoulder[1], arm_fist[0], arm_fist[1]))

    with open(FRAMES_GD, "w") as f:
        f.write("extends RefCounted\n")
        f.write("## GENERATED by tools/process_rook_sprites.py — do not edit by hand.\n")
        f.write("## Rook sprite frames (assets/characters/rook/, 2x scale, 256x256, hero\n")
        f.write("## origin at (128, 248)) and each frame's near-shoulder pivot in 1x game\n")
        f.write("## units relative to the hero origin (facing right).\n\n")
        f.write("const TEXTURE_SCALE := 0.5\n")
        f.write("const CANVAS_OFFSET := Vector2(0, -120)  # canvas centre relative to the feet, 2x px\n\n")
        f.write("const SHOULDER := {\n")
        for name, (sx, sy) in shoulders.items():
            f.write('\t&"%s": Vector2(%.1f, %.1f),\n' % (name, sx, sy))
        f.write("}\n\n")
        f.write("## Arm texture: shoulder-cap centre in texture px (2x), and the fist\n")
        f.write("## relative to the shoulder in 1x game units (arm pointing right).\n")
        f.write("const ARM_SHOULDER_PX := Vector2(%.1f, %.1f)\n" % arm_shoulder)
        f.write("const ARM_FIST := Vector2(%.1f, %.1f)\n" % arm_fist)
    print("wrote", FRAMES_GD)


if __name__ == "__main__":
    main()

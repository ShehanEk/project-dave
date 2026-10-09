#!/usr/bin/env python3
"""Import a generated parts sheet (C35/C36) as a lit cutout rig.

A parts sheet is one image with every rig part painted flat and separate on a
transparent background (see the character's art brief, "Image prompt 4").
This tool finds each part, scales the whole sheet by one factor so the
character stands at its gameplay height, builds the skeleton from joint
anchors marked on the sheet (SHEETS below, in sheet pixels), and writes the
same files the painters do:
  assets/characters/lit/<name>/albedo.png, normal.png, spec.png, rig.json
Normal maps are made from each part's silhouette and painted detail. The
enemy's neon trim (its exact neon color on the sheet) becomes the emissive
mask, so the engine makes it glow.

A character ("human") stands on its feet and its scale comes from its height.
A machine is assembled instead: every part's pivot is placed on the chassis
(sheet pixels of the chassis), parts may be rotated or scaled to fit the
assembly, and the scale comes from its overall length. A prop (a gun) is
assembled the same way around the point where the hand holds it, which
becomes the rig's origin. A sheet on a flat grey background has the
background flood-filled away from the corners.

A PIXEL sheet (a character painted as pixel art, `"pixel": {...}` in its
entry; the Night Guard's since 2026-10-06) is cut differently, because pixel
art must stay on a pixel grid:
  1. each part finds its own generated-pixel grid (grid_lines) and is reduced
     to one pixel per generated pixel (the "gen" image), colours snapped to
     one palette for the whole sheet, the neon trim to the exact neon;
  2. the gen image is binned down by `reduce` generated pixels per ART pixel
     (a sheet drawn with finer pixels than the game's art pixel of `world`
     world px; the Night Guard's came out ~2.7 times finer than the 66-pixel
     character the prompt asked for), on a grid anchored to the part's
     pivot, so the pivot is a whole art pixel and the part rotates about a
     pixel corner. A cell takes the share-weighted colour of its pixels with
     priority to the neon trim and bright accents; the one-pixel near-black
     outline is redrawn on the silhouette (the generator's outline is thinner
     than one art pixel);
  3. the art pixels are enlarged by the integer `upscale` (nearest) into the
     atlas, so one art pixel is `upscale` atlas texels, `world` world px and
     `texture_scale` = upscale / world atlas texels per world px;
  4. joint offsets are measured on each parent part's own art grid and
     rounded to whole art pixels; normal maps are made from the art
     silhouette and smoothed across the pixel steps; the neon trim is exactly
     the emissive mask; rig.json gets `"pixel_art": true` (cutout_rig.gd draws
     such a rig with nearest filtering).
A human sheet may list `joint_parts` (which part draws a joint: the Staffer's
bare near forearm, "baton": None for no baton) and `sockets` (name ->
{"joint", "part", "at": sheet point} or {"joint", "pos": joint-local world px}),
`extra_joints` (small parts hung on a joint: the Staffer's Link port on the head
and lanyard on the torso), `joint_z` / `joint_mass` / `colliders` (per-joint
overrides) and `skin_scale`; a part may list `lens` (an amber lamp pixel at its
pivot corner), `clip_top`, and its own `gen` / `reduce` (a part drawn on a finer
grid: the Staffer's port). Dave's (2026-10-07) added `"neon": []` (no glow),
`skin_tint` (skin entries scaled per channel), `pixel.extra_colors` (fixed palette
entries), a human part's own `pixel` dict, and per part `patch` (paint a box of the
sheet out with its column's colours below it: his chest badge) and `paint`
(hand-placed art pixels: his brow); a machine sheet with `pixel`
builds through build_machine_pixel (no rotate or scale: the parts must already
fit; the Patrol Rover's since 2026-10-06: a part's own `pixel` dict overrides the
sheet's, `symmetry` 4 / 8 makes a wheel's art round, `neon_first` lets a thin trim
beat its outline, `drop_purple` keeps the glow's antialiasing out of the palette).
`neon` / `glow` may list several exact glow colours. A prop sheet with `pixel` builds through
build_prop_pixel (the Scrapjack's since 2026-10-07: the first part is the root and its pivot the
rig's origin, the grip; every other part's `place` is a sheet point on the root, rounded to whole
art pixels; a part's own `reduce` fits one that is drawn too big; `inside_share` keeps thin parts,
a part's `snap` makes the warm pixels of a box exactly one glow colour and its `glow_in` limits where
a glow colour counts). tools/art/README.md, "Pixel rigs", is the recipe. `--out-dir DIR` writes the rig somewhere else (to
try an import without touching the game's assets). Run from the project root:
  python3 tools/art/import_parts_sheet.py night_guard|night_guard_smooth|staffer|dave|patrol_rover|patrol_rover_smooth|scrapjack|scrapjack_smooth [--preview DIR] [--out-dir DIR] [--measure]
"""
import json
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lit_rig_common import LIT_DIR, PROJECT, edt_inside, gblur, normal_to_rgb  # noqa: E402

REPO = os.path.normpath(os.path.join(PROJECT, "..", ".."))

# One entry per imported character. Anchors are sheet pixels. Each part is
# found by the component under `at`; `pivot` is its joint, and the named
# anchors place its children (the skeleton is read straight off the art).
SHEETS = {
    # The Night Guard as pixel art (2026-10-06): anchors in the pixel sheet's
    # pixels (1448 x 1086; its generated pixels are ~7.6 wide and ~7.1 tall).
    # Every part of the sheet is drawn ~2.7 times finer than the 66-pixel
    # character the prompt asked for, so `reduce` bins 2.7 generated pixels
    # into one art pixel (1.5 world px) and the character stands ~102 world
    # px (68 art px). `pixel` is the generic switch: any human sheet with it
    # is imported this way.
    "night_guard": {
        "sheet": "concept-art/se01-night-guard/se01-night-guard-parts-pixel-v1.webp",
        "rig_name": "SE01 Night Guard",
        "height": 102.0,          # crown above the soles, world px (sets `reduce` when it is not given)
        "texture_scale": 2,       # = pixel.upscale / pixel.world atlas texels per world px
        "neon": (0xC6, 0xFF, 0x3D),
        "pixel": {"gen": (7.6, 7.1), "reduce": 2.7, "world": 1.5, "upscale": 3, "colors": 24, "outline_share": 0.26, "neon_share": 0.14},
        "parts": {
            "head": {"at": (210, 230), "pivot": (172, 318)},
            "torso": {"at": (588, 300), "pivot": (588, 405), "neck": (595, 85), "shoulder": (520, 135)},
            "pelvis": {"at": (960, 300), "pivot": (968, 385), "waist": (968, 212)},
            "upper_arm": {"at": (1290, 250), "pivot": (1288, 110), "elbow": (1306, 350)},
            "forearm": {"at": (195, 580), "pivot": (195, 478), "wrist": (211, 695)},
            "hand_grip": {"at": (580, 640), "pivot": (585, 575), "grip": (600, 655)},
            "hand_open": {"at": (940, 640), "pivot": (940, 580)},
            "thigh": {"at": (1290, 600), "pivot": (1285, 480), "knee": (1290, 705)},
            "shin": {"at": (190, 900), "pivot": (190, 790), "ankle": (190, 1000)},
            "foot": {"at": (560, 1000), "pivot": (545, 928),
                     "soles": [(505, 1040), (600, 1042), (680, 1030)]},
            # `emit`: the baton's tip cap and studs glow in the tell's colour (the old
            # baton had a lime tip; the pixel baton has none).
            "baton": {"at": (934, 900), "pivot": (934, 810), "tip": (934, 1048),
                      "emit": [(900, 1010, 970, 1055), (920, 860, 950, 892), (920, 940, 950, 972)]},
        },
    },
    # The first (smooth, painted) Night Guard parts sheet. Rebuilds the old
    # smooth art into the same assets/characters/lit/night_guard folder.
    "night_guard_smooth": {
        "out": "night_guard",
        "sheet": "concept-art/se01-night-guard/se01-night-guard-parts-v1.webp",
        "rig_name": "SE01 Night Guard",
        "height": 102.0,          # crown above the soles, world px
        "texture_scale": 4,
        "neon": (0xC6, 0xFF, 0x3D),
        "parts": {
            "head": {"at": (180, 250), "pivot": (165, 370)},
            "torso": {"at": (515, 320), "pivot": (520, 545), "neck": (540, 95), "shoulder": (410, 190)},
            "pelvis": {"at": (838, 430), "pivot": (838, 520), "waist": (842, 322)},
            "upper_arm": {"at": (1068, 270), "pivot": (1068, 140), "elbow": (1072, 410)},
            "forearm": {"at": (1255, 380), "pivot": (1250, 250), "wrist": (1266, 532)},
            "hand_grip": {"at": (143, 800), "pivot": (143, 705), "grip": (143, 820)},
            "hand_open": {"at": (392, 830), "pivot": (390, 705)},
            "thigh": {"at": (655, 820), "pivot": (655, 675), "knee": (650, 985)},
            "shin": {"at": (920, 820), "pivot": (920, 670), "ankle": (925, 990)},
            "foot": {"at": (1245, 900), "pivot": (1150, 830),
                     "soles": [(1088, 1012), (1250, 1016), (1398, 1004)]},
            "baton": {"at": (1380, 340), "pivot": (1380, 148), "tip": (1380, 598)},
        },
    },
    # The Staffer as pixel art (2026-10-06): anchors in the pixel sheet's pixels (1620 x 971; its
    # generated pixels are ~9.1 wide and ~9.0 tall, the port's ~5.7 and ~5.5). The sheet draws the
    # character ~1.6 times finer than the 64-pixel person the prompt asked for, so `reduce` bins
    # ~1.6 generated pixels into one art pixel (1.5 world px) and he stands ~97 world px (65 art px).
    # The port is drawn on its own finer grid and bigger than it should be (a third of the
    # head), so it is binned by its own `reduce` and its centre pixel is the amber lens. The
    # lanyard and the port are extra joints (`extra_joints`) on the torso and head; his near
    # forearm is the bare one; the sleeve roll that covers its top is the upper arm's lower end.
    "staffer": {
        "sheet": "concept-art/lk01-staffer/lk01-staffer-parts-pixel-v1.webp",
        "rig_name": "LK01 Staffer",
        "height": 97.0,
        "texture_scale": 2,
        "neon": (0x4D, 0x8D, 0xFF),
        "skin_scale": 0.84,       # skin #DFB798 -> ~#BB997E: a lamp overhead no longer blows a face out to white
        "pixel": {"gen": (9.1, 9.0), "world": 1.5, "upscale": 3, "colors": 24, "outline_share": 0.26, "neon_share": 0.14,
                  "edge_art": 4.0},
        "joint_parts": {"near_forearm": "forearm_bare", "baton": None},
        "parts": {
            "head": {"at": (180, 220), "pivot": (140, 290)},
            "port": {"at": (470, 230), "pivot": (470, 230), "gen": (5.7, 5.5), "reduce": 3.2, "lens": (0xC9, 0x8A, 0x2B)},
            "torso": {"at": (790, 200), "pivot": (780, 335), "neck": (820, 90), "shoulder": (760, 135)},
            "pelvis": {"at": (1180, 270), "pivot": (1175, 290), "waist": (1170, 215)},
            "upper_arm": {"at": (1485, 200), "pivot": (1490, 120), "elbow": (1490, 285)},
            "forearm": {"at": (165, 520), "pivot": (165, 440), "wrist": (168, 600)},
            "forearm_bare": {"at": (480, 530), "pivot": (478, 450), "wrist": (478, 610)},
            "hand_grip": {"at": (808, 570), "pivot": (805, 495), "grip": (808, 575)},
            "hand_open": {"at": (1135, 580), "pivot": (1130, 495)},
            "thigh": {"at": (1455, 540), "pivot": (1455, 440), "knee": (1455, 640)},
            "shin": {"at": (170, 820), "pivot": (165, 745), "ankle": (165, 880)},
            "foot": {"at": (500, 860), "pivot": (465, 840),
                     "soles": [(428, 912), (520, 912), (572, 908)]},
            "lanyard": {"at": (810, 890), "pivot": (810, 775), "clip_top": 770},
        },
        # The draw order: the sleeve roll on the upper arm's lower end covers the forearm's top.
        "joint_z": {"near_forearm": 6, "far_upper_arm": 2},
        # The old Staffer's masses (so the ragdoll falls as before); colliders refitted to the new,
        # wider pelvis and hands.
        "joint_mass": {"pelvis": 11.0, "torso": 22.0, "head": 5.0, "far_upper_arm": 2.3, "near_upper_arm": 2.3,
                       "far_forearm": 1.6, "near_forearm": 1.6, "far_hand": 0.6, "near_hand": 0.6,
                       "far_thigh": 7.5, "near_thigh": 7.5, "far_shin": 3.6, "near_shin": 3.6,
                       "far_foot": 1.2, "near_foot": 1.2},
        "colliders": {"pelvis": {"type": "capsule", "a": [-3.5, -3.0], "b": [4.5, -3.0], "r": 8.5},
                      "near_hand": {"type": "circle", "c": [0.0, 7.5], "r": 4.5},
                      "far_hand": {"type": "circle", "c": [0.0, 7.5], "r": 4.5}},
        "extra_joints": [
            {"name": "lanyard", "part": "lanyard", "parent": "torso", "on": "torso", "at": (868, 150),
             "z": 6, "mass": 0.4, "limit": [-130, 130], "before": "head"},
            {"name": "port", "part": "port", "parent": "head", "on": "head", "at": (112, 218),
             "z": 7, "mass": 0.3, "limit": [-10, 10]},
        ],
        "sockets": {
            "port_light": {"joint": "port", "pos": (0.75, 0.75)},       # the amber lens pixel's centre
            "spark_port": {"joint": "port", "pos": (0.75, 0.75)},
            "grip_near": {"joint": "near_hand", "part": "hand_grip", "at": (808, 575)},
            "grip_far": {"joint": "far_hand", "part": "hand_open", "at": (1128, 575)},
        },
    },
    # Dave Harlan, the hero, as pixel art (2026-10-07): anchors in the pixel sheet's pixels (1448 x
    # 1086; its generated pixels are ~7.9 x 8.0). The sheet draws him ~130 generated pixels tall (the
    # prompt asked for 62), so `reduce` bins 2.04 generated pixels into one art pixel and he stands 64
    # art px = 96 world px (`height` 94 gave 2.065 and 93.3: the rounded joints make the height jump a
    # pixel or two between neighbouring values, so `reduce` is fixed). No neon: nothing glows (the
    # badge's red band and the wrist light are paint). The skin is painted ~#D8A078 and retinted to the
    # brief's fair #E1B596 (`skin_tint`). The torso has the revoked badge painted on its chest as well
    # as the separate `lanyard` part, so its `patch` paints it out with the hoodie below it; the lanyard
    # (cut below its neck loop) hangs from the end of the cord painted round his neck, and the hood
    # hangs behind the neck: both are extra joints on the torso. The median cut gives its 24 colours to
    # near-identical charcoals, so `extra_colors` adds the card's pale grey, its red band, the eye's
    # white and the wrist light's blue-grey. The head's own `outline_share` keeps the brow and the eye
    # from binning into one black block and `paint` puts the two brow pixels back. `joint_z` lifts the
    # near forearm and fist to 10 so hero_rig_visual.gd can draw the Scrapjack between them and the
    # upper arm (7). Sockets: the fist's `grip` (the gun's grip goes there), the cuff's wrist light and
    # five places a hit bleeds from.
    "dave": {
        "sheet": "concept-art/h01-dave/h01-dave-parts-pixel-v1.webp",
        "rig_name": "H01 Dave Harlan",
        "height": 96.0,
        "texture_scale": 2,
        "neon": [],
        "skin_tint": {"from": (0xD8, 0xA0, 0x78), "to": (0xE1, 0xB5, 0x96)},
        "pixel": {"gen": (7.9, 8.0), "reduce": 2.04, "world": 1.5, "upscale": 3, "colors": 24, "outline_share": 0.26, "neon_share": 0.14,
                  "edge_art": 4.0,
                  "extra_colors": [(0xC0, 0xC8, 0xD0), (0x99, 0x27, 0x2F), (0xE7, 0xE1, 0xE5), (0x3C, 0x48, 0x58)]},
        "joint_parts": {"baton": None},
        "parts": {
            "head": {"at": (192, 203), "pivot": (158, 318), "pixel": {"outline_share": 0.38, "accent_contrast": 40.0},
                     "paint": [((4, -7), (0x2E, 0x21, 0x1B)), ((5, -7), (0x2E, 0x21, 0x1B))]},
            "hood": {"at": (533, 250), "pivot": (560, 300)},
            "torso": {"at": (850, 231), "pivot": (905, 355), "neck": (930, 118), "shoulder": (875, 150),
                      "patch": [{"box": (928, 190, 976, 268), "from": (928, 272, 976, 340)}]},
            "pelvis": {"at": (1259, 300), "pivot": (1262, 318), "waist": (1262, 215)},
            "upper_arm": {"at": (177, 554), "pivot": (177, 465), "elbow": (174, 632)},
            "forearm": {"at": (535, 557), "pivot": (527, 452), "wrist": (550, 658)},
            "hand_grip": {"at": (892, 591), "pivot": (888, 535), "grip": (918, 605)},
            "hand_open": {"at": (1258, 598), "pivot": (1262, 535)},
            "thigh": {"at": (173, 874), "pivot": (178, 768), "knee": (172, 950)},
            "shin": {"at": (541, 892), "pivot": (545, 830), "ankle": (540, 985)},
            "foot": {"at": (895, 959), "pivot": (870, 895),
                     "soles": [(838, 1016), (940, 1021), (995, 1016)]},
            "lanyard": {"at": (1256, 960), "pivot": (1256, 895), "clip_top": 888},
        },
        "joint_z": {"near_forearm": 10, "near_hand": 10},
        "extra_joints": [
            {"name": "lanyard", "part": "lanyard", "parent": "torso", "on": "torso", "at": (945, 182),
             "z": 6, "mass": 0.4, "limit": [-130, 130], "before": "head"},
            {"name": "hood", "part": "hood", "parent": "torso", "on": "torso", "at": (905, 120),
             "z": 5, "mass": 0.6, "limit": [-20, 20], "before": "head"},
        ],
        "sockets": {
            "grip": {"joint": "near_hand", "part": "hand_grip", "at": (918, 605)},
            "grip_far": {"joint": "far_hand", "part": "hand_open", "at": (1262, 610)},
            "wrist_light": {"joint": "near_forearm", "part": "forearm", "at": (556, 632)},
            "blood_head": {"joint": "head", "part": "head", "at": (205, 235)},
            "blood_chest": {"joint": "torso", "part": "torso", "at": (915, 185)},
            "blood_belly": {"joint": "torso", "part": "torso", "at": (915, 300)},
            "blood_arm": {"joint": "near_upper_arm", "part": "upper_arm", "at": (177, 545)},
            "blood_thigh": {"joint": "near_thigh", "part": "thigh", "at": (178, 850)},
        },
    },
    # The Patrol Rover as pixel art (2026-10-06): anchors in the pixel sheet's pixels (1536 x 1024;
    # its generated pixel is ~8 sheet px). A machine: `place` is where the part's pivot sits on
    # the assembled rover, in the chassis's sheet pixels (no `rotate` or `scale`: the sheet's
    # parts fit as drawn). `reduce` 2.86 generated pixels per art pixel makes the rover 62 art
    # px (93 world px) long, the old rover's 92, and the wheel exactly 14 x 14 art px. The
    # chassis pivots at mid-wheelbase (the arches' centres, x 419 and 1112) and axle height;
    # the lid (354 x 151) covers the rear deck panel and the dark bay; the battery (341 x 167)
    # is larger than the bay, so it sits over the deck under the lid; the pod and the lightbar
    # stand on the roof; the bumper overlaps the nose by one generated pixel. `neon_first`:
    # the flank strip is thinner than an art pixel and its outlines would eat it.
    "patrol_rover": {
        "sheet": "concept-art/m01-patrol-rover/m01-patrol-rover-parts-pixel-v1.webp",
        "rig_name": "M01 Patrol Rover",
        "kind": "machine",
        "length": 92.0,           # rear of the chassis to the front of the bumper, world px (sets `reduce` when it is not given)
        "texture_scale": 2,       # = pixel.upscale / pixel.world atlas texels per world px
        "atlas_width": 256,
        "glow": [((255, 61, 213), 1.0),      # the magenta flank strip, exactly #FF3DD5
                 ((201, 138, 43), 1.0),      # the lightbar lenses and the sensor lens, #C98A2B
                 ((63, 224, 208), 1.0)],     # the battery gauge, #3FE0D0
        "pixel": {"gen": (8.0, 7.9), "reduce": 2.86, "world": 1.5, "upscale": 3, "colors": 24,
                  "neon_first": [0], "drop_purple": True},
        "parts": {
            "chassis": {"at": (700, 250), "pivot": (765, 410), "place": (765, 410), "bottom": 465},
            # the wheel turns about its hub: `phase` 0 keeps the grid on the hub and `symmetry` 8 makes
            # the art round (the generator's tyre teeth leave lumps that would wobble as it spins)
            "wheel": {"at": (1220, 850), "pivot": (1220, 847), "places": [(419, 410), (1112, 410)],
                      "pixel": {"phase": 0}, "symmetry": 8},
            "bumper": {"at": (270, 620), "pivot": (200, 625), "place": (1338, 353), "front": (360, 625)},
            "sensor": {"at": (700, 600), "pivot": (712, 676), "place": (1010, 178), "lens": (811, 622),
                       "spark": (690, 556), "glow_scale": 0.35},
            "lightbar": {"at": (1190, 600), "pivot": (1192, 643), "place": (340, 58), "lens": (1192, 592)},
            "hatch": {"at": (280, 880), "pivot": (440, 925), "place": (474, 153)},
            "battery": {"at": (750, 880), "pivot": (750, 862), "place": (330, 90)},
        },
    },
    # The first (smooth, painted) Patrol Rover parts sheet. Rebuilds the old
    # smooth art into the same assets/characters/lit/patrol_rover folder.
    # A machine: `place` is where the part's pivot sits on the assembled
    # rover, in the chassis's sheet pixels; `rotate` (degrees, clockwise) and
    # `scale` fit a part to the chassis it was painted beside. The hatch lid
    # covers the side panel, which is repainted as the open battery bay.
    "patrol_rover_smooth": {
        "out": "patrol_rover",
        "sheet": "concept-art/m01-patrol-rover/m01-patrol-rover-parts-v1.webp",
        "rig_name": "M01 Patrol Rover",
        "kind": "machine",
        "length": 92.0,           # rear of the chassis to the front of the bumper, world px
        "texture_scale": 4,
        "atlas_width": 512,
        "background": (127, 127, 127),
        "glow": [((250, 30, 208), 1.0),      # the magenta flank strip (C36 neon)
                 ((213, 141, 49), 1.0),      # the lightbar lenses and the sensor lens
                 ((54, 210, 196), 1.0)],     # the battery gauge
        "fill": [{"poly": [(166, 124), (463, 161), (434, 226), (139, 186)], "color": (20, 24, 30)}],
        "parts": {
            "chassis": {"at": (700, 250), "pivot": (676.5, 540), "place": (676.5, 540), "bottom": 600},
            "wheel": {"at": (1321, 700), "pivot": (1321.5, 811.5),
                      "places": [(318, 540), (1035, 540)]},
            "bumper": {"at": (1450, 450), "pivot": (1310, 434), "place": (1272, 484), "front": (1505, 434)},
            "sensor": {"at": (120, 760), "pivot": (165, 805), "place": (960, 277), "rotate": 14.5,
                       "lens": (290, 752), "glow_scale": 0.35},
            "lightbar": {"at": (380, 760), "pivot": (503, 790), "place": (360, 125), "lens": (542, 746)},
            "hatch": {"at": (900, 780), "pivot": (1048, 725), "place": (468, 158), "rotate": 7.6,
                      "scale": (1.0, 0.86)},
            "battery": {"at": (450, 850), "pivot": (547, 900), "place": (300, 176), "scale": (0.5, 0.5)},
        },
    },
    # The Scrapjack as pixel art (2026-10-07): anchors in the pixel sheet's pixels (1536 x 1024; its
    # generated pixels are ~9.4 x 9.2). A prop: the frame is the root and `origin` is the grip, where
    # Dave's fist wraps the tape (the top of the taped grip, under the rail: it is the root's pivot and
    # place too); every other part's `place` is the frame-sheet point where its pivot sits. The sheet
    # draws the pistol ~123 generated pixels long (the prompt asked for 26): at `reduce` 6.5 (the old
    # gun's 26 world px, 17 art px) it is a black blob, so `reduce` 5.0 bins 5 generated pixels into one
    # art pixel and the gun is 24 art px = 36 world px long (the barrel and the rail drawn under the
    # housing as in the look concept). The housing's bottom outline row is the frame's rail top row (one
    # black row, not two), the barrel hangs two art rows lower than the housing (its bore is 3.75 world
    # px above the grip, near the aim line), the battery cell is hung under the housing with its top
    # outline hidden behind it, and being drawn 1.35 times bigger than the look wants it takes its own
    # coarser `reduce` 5.75. `inside_share` 0.35 keeps the thin trigger guard, `outline_share` 0.8 keeps
    # the housing's scrap window from turning into a black slab, `phase` 2.0 lets the grid find clean
    # cells. Glow: the copper coils (the generator paints a dozen oranges: `snap` makes every warm pixel
    # inside the two coil boxes exactly #D9884A) and the teal charge light #3FE0D0 are the masks;
    # `glow_in` keeps the copper off the rust flecks and the scrap window's orange bits.
    "scrapjack": {
        "sheet": "concept-art/w01-scrapjack/w01-scrapjack-parts-pixel-v1.webp",
        "rig_name": "W01 Scrapjack",
        "kind": "prop",
        "length": 26.0,           # the smooth gun's, back of the grip to the muzzle, world px (sets `reduce` when it is not given)
        "texture_scale": 2,       # = pixel.upscale / pixel.world atlas texels per world px
        "atlas_width": 128,
        "origin": (235, 346),
        "glow": [((217, 136, 74), 1.0),      # the copper coils, #D9884A
                 ((63, 224, 208), 1.0)],     # the teal charge light, #3FE0D0
        "pixel": {"gen": (9.4, 9.2), "reduce": 5.0, "world": 1.5, "upscale": 3, "colors": 24,
                  "neon_first": [0, 1], "neon_share": 0.14, "outline_share": 0.8, "inside_share": 0.35, "phase": 2.0},
        "parts": {
            "frame": {"at": (400, 270), "pivot": (235, 346), "place": (235, 346), "z": 1, "mass": 1.0,
                      "glow_in": {0: [], 1: []}},
            "barrel": {"at": (440, 790), "pivot": (300, 787), "place": (800, 253), "z": 3, "mass": 1.0, "muzzle": (660, 787),
                       "snap": [{"box": (345, 690, 435, 885), "to": (217, 136, 74)},
                                {"box": (460, 690, 548, 885), "to": (217, 136, 74)}],
                       "glow_in": {0: [(345, 690, 435, 885), (460, 690, 548, 885)], 1: []}},
            "upper": {"at": (1000, 300), "pivot": (900, 440), "place": (240, 254), "z": 4, "mass": 1.0,
                      "glow_in": {0: [], 1: []}},
            "battery": {"at": (1200, 800), "pivot": (1040, 700), "place": (630, 208), "z": 2, "mass": 1.0, "light": (1040, 807),
                        "reduce": 5.75, "glow_in": {0: []}},
        },
    },
    # The first (smooth, painted) Scrapjack parts sheet. Rebuilds the old
    # smooth art into the same assets/characters/lit/scrapjack folder.
    # A prop: parts placed on the frame (the frame's sheet pixels); `origin`
    # is where Dave's hand holds the grip. The copper glow counts only inside
    # `glow_boxes` (the coils), so the painted rust spots never glow.
    "scrapjack_smooth": {
        "out": "scrapjack",
        "sheet": "concept-art/w01-scrapjack/w01-scrapjack-parts-v1.webp",
        "rig_name": "W01 Scrapjack",
        "kind": "prop",
        "length": 26.0,           # back of the grip to the muzzle, world px
        "texture_scale": 8,
        "atlas_width": 512,
        "origin": (230, 330),
        "glow": [((3, 204, 200), 1.0)],                 # the teal charge light
        "parts": {
            "frame": {"at": (600, 200), "pivot": (230, 330), "place": (230, 330), "z": 1, "mass": 1.0},
            "barrel": {"at": (220, 790), "pivot": (176, 793), "place": (975, 162), "z": 2, "mass": 1.0,
                       "muzzle": (705, 793),
                       "glow": [((201, 122, 65), 1.0)], "glow_boxes": [(255, 670, 400, 915), (430, 670, 560, 915)]},
            "upper": {"at": (800, 300), "pivot": (725, 375), "place": (185, 178), "z": 3, "mass": 1.0},
            "battery": {"at": (1200, 800), "pivot": (845, 700), "place": (668, 280), "z": 4, "mass": 1.0,
                        "scale": (0.68, 0.68), "light": (1000, 828)},
        },
    },
}


def components(alpha):
    """Label 4-connected opaque regions; returns (labels, count)."""
    fg = alpha > 128
    h, w = fg.shape
    lab = np.zeros((h, w), np.int32)
    n = 0
    for y0 in range(h):
        for x0 in np.nonzero(fg[y0] & (lab[y0] == 0))[0]:
            if lab[y0, x0]:
                continue
            n += 1
            lab[y0, x0] = n
            q = deque([(y0, x0)])
            while q:
                y, x = q.popleft()
                for ny, nx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                    if 0 <= ny < h and 0 <= nx < w and fg[ny, nx] and not lab[ny, nx]:
                        lab[ny, nx] = n
                        q.append((ny, nx))
    return lab, n


def normal_map(rgba, edge_px):
    """Silhouette-rounded normals plus a little painted detail (as make_normal_maps.py)."""
    a = rgba[..., 3] / 255.0
    mask = a > 0.5
    d = edt_inside(mask)
    t = np.clip(d / edge_px, 0, 1)
    h = edge_px * np.sqrt(1.0 - (1.0 - t) ** 2)
    dmax = max(float(d.max()), 1.0)
    h += 0.35 * edge_px * np.sqrt(np.clip(d / dmax, 0, 1))
    luma = (rgba[..., 0] * 0.3 + rgba[..., 1] * 0.59 + rgba[..., 2] * 0.11) / 255.0
    h += 0.9 * edge_px * 0.25 * (luma - gblur(luma, 3.0)) * mask
    h = gblur(h * mask, 0.8)
    gy, gx = np.gradient(h)
    n = np.stack([-gx, -gy, np.ones_like(h)], -1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    rgb = normal_to_rgb(n)
    rgb[~mask] = [0.5, 0.5, 1.0]
    return rgb


def spec_map(rgba, glows):
    """R = specular strength, G = gloss, B = emissive (the neon trim and any
    lamps): `glows` is a list of ((r, g, b), strength)."""
    rgb = rgba[..., :3] / 255.0
    val = rgb.max(-1)
    sat = (rgb.max(-1) - rgb.min(-1)) / np.maximum(rgb.max(-1), 1e-4)
    out = np.zeros(rgba.shape[:2] + (3,), np.float32)
    out[...] = [0.08, 0.22, 0.0]                        # cloth
    dark = val < 0.22                                   # boots, belt, baton: leather and rubber
    out[dark] = [0.32, 0.55, 0.0]
    skin = (rgb[..., 0] > rgb[..., 2] + 0.12) & (sat > 0.2) & (val > 0.35)
    out[skin] = [0.14, 0.35, 0.0]
    steel = (sat < 0.12) & (val > 0.6)                  # studs, buckles, the pale grip
    out[steel] = [0.45, 0.7, 0.0]
    for color, strength in glows:
        nr, ng, nb = (c / 255.0 for c in color)
        dist = np.abs(rgb[..., 0] - nr) + np.abs(rgb[..., 1] - ng) + np.abs(rgb[..., 2] - nb)
        out[dist < 0.35] = [0.1, 0.3, strength]
    return out


def resize(arr, size):
    img = Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8))
    return np.asarray(img.resize(size, Image.LANCZOS), np.float32) / 255.0


def load_sheet(cfg):
    """The sheet as float RGBA (0-255), with a flat grey background (if any)
    flood-filled away from the corners and the `fill` repaints applied, and
    its opaque parts labelled."""
    img = Image.open(os.path.join(REPO, cfg["sheet"])).convert("RGBA")
    if "background" in cfg:
        from PIL import ImageDraw
        rgb = img.convert("RGB")
        key = (255, 0, 254)
        for xy in ((0, 0), (img.width - 1, 0), (0, img.height - 1), (img.width - 1, img.height - 1)):
            ImageDraw.floodfill(rgb, xy, key, thresh=22)
        flooded = np.all(np.asarray(rgb) == key, -1)
        # Enclosed background (inside a tow ring) is the exact grey too.
        grey = np.abs(np.asarray(img.convert("RGB"), np.int32) - np.array(cfg["background"])).sum(-1) < 12
        a = np.asarray(img).copy()
        a[flooded | grey, 3] = 0
        img = Image.fromarray(a)
    for f in cfg.get("fill", []):
        from PIL import ImageDraw
        d = ImageDraw.Draw(img)
        d.polygon(f["poly"], fill=tuple(f["color"]) + (255,))
        d.line(list(f["poly"]) + [f["poly"][0]], fill=(11, 13, 16, 255), width=4, joint="curve")
    sheet = np.asarray(img, np.float32)
    lab, _ = components(sheet[..., 3])
    return sheet, lab


def part_crop(sheet, lab, at):
    """The opaque component under `at`, cropped: (crop, x0, y0)."""
    cid = lab[at[1], at[0]]
    assert cid, "no part under %s" % (at,)
    ys, xs = np.nonzero(lab == cid)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    crop = sheet[y0:y1, x0:x1].copy()
    crop[..., 3] *= (lab[y0:y1, x0:x1] == cid)
    return crop, x0, y0


def fit_part(crop, pivot, rotate=0.0, scale=(1.0, 1.0)):
    """Rotates (degrees, clockwise on screen) and scales a crop about its pivot
    (crop pixels). Returns (crop, pivot, fwd), where fwd maps a crop point to
    the new crop."""
    th = np.radians(rotate)
    c, sn = np.cos(th), np.sin(th)
    sx, sy = scale
    A = np.array([[c * sx, -sn * sy], [sn * sx, c * sy]])           # forward: R @ S
    h, w = crop.shape[:2]
    corners = (np.array([[0, 0], [w, 0], [0, h], [w, h]], float) - pivot) @ A.T
    lo = np.floor(corners.min(0)) - 4
    hi = np.ceil(corners.max(0)) + 4
    size = (int(hi[0] - lo[0]), int(hi[1] - lo[1]))
    new_pivot = -lo
    M = np.linalg.inv(A)
    off = np.array(pivot) - M @ new_pivot
    coeffs = (M[0, 0], M[0, 1], off[0], M[1, 0], M[1, 1], off[1])
    pm = crop.copy()
    pm[..., :3] *= pm[..., 3:4] / 255.0
    chans = [np.asarray(Image.fromarray(pm[..., i]).transform(size, Image.AFFINE, coeffs, Image.BICUBIC))
             for i in range(4)]
    out = np.clip(np.stack(chans, -1), 0.0, 255.0)
    a = out[..., 3:4]
    out[..., :3] = np.where(a > 1e-3, out[..., :3] * 255.0 / np.maximum(a, 1e-3), 0.0)

    def fwd(pt):
        return (A @ (np.array(pt, float) - pivot)) + new_pivot
    return out.astype(np.float32), new_pivot, fwd


def cut(crop, pivot, k, glows):
    """A cropped part (float RGBA, straight alpha) at atlas resolution, with
    its normal and spec maps; `pivot` is in crop pixels."""
    size = (max(1, int(round(crop.shape[1] * k))), max(1, int(round(crop.shape[0] * k))))
    # Premultiplied downscale keeps the dark outline from bleeding into halos.
    pm = crop.copy()
    pm[..., :3] *= pm[..., 3:4] / 255.0
    small = resize(pm / 255.0, size)
    alpha = small[..., 3]
    rgb = np.where(alpha[..., None] > 1e-3, small[..., :3] / np.maximum(alpha[..., None], 1e-3), 0.0)
    # Normals and spec at twice the atlas size, then down.
    big = (size[0] * 2, size[1] * 2)
    pm2 = resize(pm / 255.0, big)
    a2 = pm2[..., 3]
    rgb2 = np.where(a2[..., None] > 1e-3, pm2[..., :3] / np.maximum(a2[..., None], 1e-3), 0.0)
    rgba2 = np.concatenate([rgb2, a2[..., None]], -1) * 255.0
    nrm = resize(normal_map(rgba2, edge_px=max(3.0, 0.09 * min(big))), size)
    v = nrm * 2.0 - 1.0
    v /= np.maximum(np.linalg.norm(v, axis=-1, keepdims=True), 1e-4)
    nrm = v * 0.5 + 0.5
    nrm[alpha < 0.5] = [0.5, 0.5, 1.0]
    spc = resize(spec_map(rgba2, glows), size)
    piv = [round(pivot[0] * k, 1), round(pivot[1] * k, 1)]
    return {"rgb": rgb, "alpha": alpha, "normal": nrm, "spec": spc, "pivot": piv}


OUT_DIR = None      # --out-dir: write the rigs here instead of assets/characters/lit


def write_atlas(results, name, width):
    """Packs the parts into albedo/normal/spec atlases; returns the rects."""
    pad = 4
    order = sorted(results, key=lambda n: -results[n]["alpha"].shape[0])
    x = y = row_h = 0
    rects = {}
    for n in order:
        h, wd = results[n]["alpha"].shape
        if x + wd + pad > width:
            x, y, row_h = 0, y + row_h + pad, 0
        rects[n] = [x + pad, y + pad, wd, h]
        x += wd + pad
        row_h = max(row_h, h)
    height = y + row_h + 2 * pad
    height = 1 << (height - 1).bit_length()
    alb = np.zeros((height, width, 4), np.float32)
    nor = np.zeros((height, width, 4), np.float32)
    nor[...] = [0.5, 0.5, 1.0, 0.0]
    spe = np.zeros((height, width, 4), np.float32)
    for n, (rx, ry, wd, h) in rects.items():
        r = results[n]
        alb[ry:ry + h, rx:rx + wd, :3] = r["rgb"]
        alb[ry:ry + h, rx:rx + wd, 3] = r["alpha"]
        nor[ry:ry + h, rx:rx + wd, :3] = r["normal"]
        nor[ry:ry + h, rx:rx + wd, 3] = r["alpha"]
        spe[ry:ry + h, rx:rx + wd, :3] = r["spec"]
        spe[ry:ry + h, rx:rx + wd, 3] = r["alpha"]
    out_dir = os.path.join(OUT_DIR or LIT_DIR, name)
    os.makedirs(out_dir, exist_ok=True)
    for fname, arr in (("albedo.png", alb), ("normal.png", nor), ("spec.png", spe)):
        Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(out_dir, fname))
    print("wrote", out_dir, "atlas %dx%d" % (width, height))
    return rects, out_dir


# --- pixel sheets ---------------------------------------------------------------------
OUTLINE = (11, 13, 16)          # #0B0D10, the characters' one-pixel outline
GLOW_TOL = 95                   # a generated pixel this near (L1, 0-765) a glow colour is that glow


def glow_colors(neon):
    """`neon` is one colour or a list of them: the exact glow colours (an empty
    list: none, Dave)."""
    if not neon:
        return []
    return [tuple(neon)] if isinstance(neon[0], int) else [tuple(c) for c in neon]


def glow_class(rgb, glows, tol=GLOW_TOL):
    """Index (0..) of the glow colour a generated pixel belongs to, or -1: the
    generator's trim is not exactly its neon (webp, shading), but near it."""
    if not glows:
        return -1
    d = [sum(abs(float(a) - float(b)) for a, b in zip(rgb, g)) for g in glows]
    i = int(np.argmin(d))
    return i if d[i] < tol else -1


def measure_gen(crop):
    """The generated pixel (width, height) in sheet px of one part, from the
    thickness of its one-pixel near-black outline: the mean length of the dark
    runs (4 to 14 px) along rows and along columns, within 2.5 px of their
    median. Rough (the generator's pixels drift by a pixel): `gen` in a
    sheet's entry is the average over its parts."""
    lum = crop[..., :3] @ np.array([0.3, 0.59, 0.11])
    dark = (lum < 45) & (crop[..., 3] > 200)
    out = []
    for m in (dark, dark.T):
        runs = []
        for row in m:
            d = np.diff(np.concatenate([[0], row.astype(int), [0]]))
            runs += list(np.nonzero(d == -1)[0] - np.nonzero(d == 1)[0])
        runs = np.array(runs)
        runs = runs[(runs >= 4) & (runs <= 14)]
        if len(runs) < 20:
            out.append(float("nan"))
            continue
        near = runs[np.abs(runs - np.median(runs)) <= 2.5]
        out.append(float(near.mean()))
    return out


def gen_reduce(crop, gen):
    """One pixel per GENERATED pixel on this part's own grid: returns
    (G uint8 RGBA, xs, ys) where xs/ys are the grid lines in crop pixels."""
    from import_pixel_sheet import grid_lines
    rgb = crop[..., :3]
    solid = (crop[..., 3] > 128).astype(np.float32)
    dx = (np.abs(np.diff(rgb, axis=1)).sum(-1) + 255.0 * np.abs(np.diff(solid, axis=1))).sum(0)
    dy = (np.abs(np.diff(rgb, axis=0)).sum(-1) + 255.0 * np.abs(np.diff(solid, axis=0))).sum(1)
    xs = grid_lines(dx, gen[0])
    ys = grid_lines(dy, gen[1])
    out = np.zeros((len(ys) - 1, len(xs) - 1, 4), np.uint8)
    for r in range(len(ys) - 1):
        for c in range(len(xs) - 1):
            cell = crop[ys[r]:ys[r + 1], xs[c]:xs[c + 1]].reshape(-1, 4)
            seen = cell[:, 3] >= 128
            if seen.sum() * 2 < len(cell):
                continue
            out[r, c, :3] = np.round(np.median(cell[seen, :3], 0))
            out[r, c, 3] = 255
    return out, np.array(xs, float), np.array(ys, float)


def overlap_matrix(n_src, p0, step, count, k0):
    """W[k, g] = length of source cell g (unit cells) inside art cell k, whose
    edges are p0 + (k0 + k) * step."""
    edges = p0 + (k0 + np.arange(count + 1)) * step
    g0 = np.arange(n_src)
    lo = np.maximum(edges[:-1, None], g0[None, :])
    hi = np.minimum(edges[1:, None], g0[None, :] + 1.0)
    return np.clip(hi - lo, 0.0, None)


class PixelPart:
    """One part on its own pixel grids: the generated-pixel grid (G) and the
    art-pixel grid anchored at the part's pivot."""

    def __init__(self, name, sheet, lab, pc, px):
        self.name = name
        crop, x0, y0 = part_crop(sheet, lab, pc["at"])
        if pc.get("clip_top") is not None:
            # Drop everything above this sheet row (the lanyard's long loop round the neck).
            crop[:max(0, int(pc["clip_top"]) - y0), :, 3] = 0
        self.bbox = (x0, y0, x0 + crop.shape[1], y0 + crop.shape[0])     # the part's bounds, sheet px
        m = 16
        self.crop = np.pad(crop, ((m, m), (m, m), (0, 0)))
        self.x0, self.y0 = x0 - m, y0 - m
        self.gen = tuple(pc.get("gen", px["gen"]))
        self.G, self.xs, self.ys = gen_reduce(self.crop, self.gen)
        # The centres of the generated cells, in sheet px (for the part's `snap` and `glow_in` boxes).
        self.cell_x = self.x0 + 0.5 * (self.xs[:-1] + self.xs[1:])
        self.cell_y = self.y0 + 0.5 * (self.ys[:-1] + self.ys[1:])
        for rule in pc.get("patch", []):
            self.patch_cells(rule)
        for rule in pc.get("snap", []):
            self.snap_colour(rule)
        # `glow_in`: {glow index: [sheet-px boxes]}: that glow colour counts only inside its boxes
        # ([] = nowhere on this part), so the Scrapjack's rust flecks and its window's orange scrap
        # never glow like its copper coils.
        self.glow_ok = {int(i): self.in_boxes(boxes) for i, boxes in pc.get("glow_in", {}).items()} or None
        self.pivot_sheet = pc["pivot"]
        self.pg = None          # the effective pivot (G coordinates), set by art_reduce
        self.emit_boxes = pc.get("emit", [])   # sheet-px boxes whose pixels glow (a baton tip's tell)
        self.own_reduce = pc.get("reduce")     # a part drawn on a finer grid than the rest (the Staffer's port)

    def in_boxes(self, boxes):
        """A mask over the generated cells: True where the cell's centre is in one of the
        sheet-px boxes (x0, y0, x1, y1)."""
        m = np.zeros(self.G.shape[:2], bool)
        for bx0, by0, bx1, by1 in boxes:
            m |= ((self.cell_y >= by0) & (self.cell_y <= by1))[:, None] & ((self.cell_x >= bx0) & (self.cell_x <= bx1))[None, :]
        return m

    def patch_cells(self, rule):
        """`patch`: {"box": (x0, y0, x1, y1), "from": (x0, y0, x1, y1)} (sheet px). Every opaque
        generated cell whose centre is in `box` takes the median colour of the opaque cells of its
        own column whose centres are in `from`: Dave's revoked ID badge, painted on the torso's
        chest, is painted out with the hoodie and the jacket edge below it (the badge is its own
        swinging `lanyard` part)."""
        opaque = self.G[..., 3] > 0
        dst = self.in_boxes([rule["box"]]) & opaque
        src = self.in_boxes([rule["from"]]) & opaque
        for c in np.nonzero(dst.any(0))[0]:
            rows = np.nonzero(src[:, c])[0]
            if len(rows):
                self.G[dst[:, c], c, :3] = np.round(np.median(self.G[rows, c, :3].astype(float), 0)).astype(np.uint8)

    def snap_colour(self, rule):
        """`snap`: {"box": (x0, y0, x1, y1), "to": (r, g, b), "warm": 50}. Warm generated pixels
        (red above blue by `warm`, at least as red as green; not the outline) inside the box
        become exactly `to`: the Scrapjack's copper coils are painted in a dozen shades of
        orange, and only the exact colour is the glow mask."""
        rgb = self.G[..., :3].astype(int)
        lum = rgb @ np.array([0.3, 0.59, 0.11])
        warm = (rgb[..., 0] > rgb[..., 2] + int(rule.get("warm", 50))) & (rgb[..., 0] >= rgb[..., 1])
        hit = self.in_boxes([rule["box"]]) & (self.G[..., 3] > 0) & (lum >= 24) & warm
        self.G[hit, :3] = np.array(rule["to"], np.uint8)

    def reduce_of(self, px):
        """Generated pixels (of this part's own grid) per art pixel."""
        return float(self.own_reduce if self.own_reduce is not None else px["reduce"])

    def to_g(self, pt):
        """A sheet point in generated-pixel coordinates (fractional). A point beyond the part's
        grid (the Scrapjack's barrel is placed on the frame past its front tip) continues the
        grid at its mean cell size."""
        def one(v, grid):
            n = len(grid)
            if v < grid[0] or v > grid[-1]:
                step = (grid[-1] - grid[0]) / (n - 1)
                return (v - grid[0]) / step if v < grid[0] else (n - 1) + (v - grid[-1]) / step
            return float(np.interp(v, grid, np.arange(n)))
        return np.array([one(pt[0] - self.x0, self.xs), one(pt[1] - self.y0, self.ys)])


def palette_classes(parts, neon, n_colors, tol=GLOW_TOL, drop_purple=False, extra=None):
    """Snaps every part's gen pixels to one palette: class 0 = outline, classes
    1..k = the exact glow colours (`neon`), then the rest (median cut).
    `drop_purple` keeps purple pixels (the antialiasing between a magenta glow
    and its outline) out of the palette, so no body colour is a muddy purple.
    `extra` (the sheet's `pixel.extra_colors`) adds fixed colours after the
    median cut's: small details the cut, led by the big dark areas, leaves out
    (Dave's pale ID card and its red band, the eye's white, the wrist light).
    Returns (classes per part, colour table)."""
    glows = glow_colors(neon)

    def part_glow(p, y, x, c):
        """The glow class of one generated pixel of a part: a part's `glow_in` limits where a
        glow colour counts (the pixel is then a body colour)."""
        i = glow_class(c, glows, tol)
        if i >= 0 and p.glow_ok is not None and i in p.glow_ok and not p.glow_ok[i][y, x]:
            return -1
        return i

    flat = []
    neonmask = []
    for p in parts.values():
        solid = p.G[..., 3] > 0
        flat.append(p.G[solid][:, :3])
        if p.glow_ok is None:
            neonmask += [glow_class(c, glows, tol) >= 0 for c in p.G[solid][:, :3]]
        else:
            neonmask += [part_glow(p, y, x, p.G[y, x, :3].astype(float)) >= 0 for y, x in zip(*np.nonzero(solid))]
    flat = np.concatenate(flat)
    lum = flat @ np.array([0.3, 0.59, 0.11])
    neonmask = np.array(neonmask)
    keep = (lum >= 24) & ~neonmask
    if drop_purple:
        keep &= ~((flat[:, 0].astype(int) - flat[:, 1] > 25) & (flat[:, 2].astype(int) - flat[:, 1] > 25))
    rest = flat[keep]
    strip = Image.fromarray(rest.reshape(1, -1, 3).astype(np.uint8))
    pal_img = strip.quantize(colors=n_colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    pal = np.array(pal_img.getpalette()[:n_colors * 3], np.uint8).reshape(-1, 3)
    if extra:
        pal = np.concatenate([pal, np.array(extra, np.uint8).reshape(-1, 3)])
    table = np.concatenate([np.array([OUTLINE] + glows, np.uint8), pal])
    classes = {}
    for n, p in parts.items():
        G = p.G
        cls = np.zeros(G.shape[:2], np.int32) - 1
        h, w = G.shape[:2]
        for y in range(h):
            for x in range(w):
                if G[y, x, 3] == 0:
                    continue
                c = G[y, x, :3].astype(float)
                if c @ np.array([0.3, 0.59, 0.11]) < 24:
                    cls[y, x] = 0
                elif part_glow(p, y, x, c) >= 0:
                    cls[y, x] = 1 + part_glow(p, y, x, c)
                else:
                    cls[y, x] = 1 + len(glows) + int(np.argmin(np.abs(pal.astype(float) - c).sum(1)))
        classes[n] = cls
    return classes, table


def art_grid_stats(cls, pg, r, shift):
    """Overlap matrices and per-cell coverage for the art grid whose cell
    edges sit at pg + shift + k * r (generated-pixel units)."""
    ny, nx = cls.shape
    org = np.array(pg, float) + shift
    k0x, k0y = int(np.floor(-org[0] / r)) - 1, int(np.floor(-org[1] / r)) - 1
    cx = int(np.ceil((nx - org[0]) / r)) + 1 - k0x
    cy = int(np.ceil((ny - org[1]) / r)) + 1 - k0y
    Wx = overlap_matrix(nx, org[0], r, cx, k0x)
    Wy = overlap_matrix(ny, org[1], r, cy, k0y)
    return Wx, Wy, (k0x, k0y), (cx, cy)


def best_phase(cls, pg, r, span, step=0.25, thr=0.5):
    """The grid shift (generated pixels, within +-span of the pivot) whose
    cells are the cleanest: silhouette cells mostly in or out, and every
    cell mostly one colour. Moves the pivot by less than half an art pixel."""
    solid = (cls >= 0).astype(float)
    onehot = [(cls == c).astype(float) for c in range(int(cls.max()) + 1)]
    best, best_s = (0.0, 0.0), -1e9
    for sy in np.arange(-span, span + 1e-6, step):
        for sx in np.arange(-span, span + 1e-6, step):
            Wx, Wy, _k, _c = art_grid_stats(cls, pg, r, (sx, sy))
            cover = (Wy @ solid @ Wx.T) / (r * r)
            purity = np.zeros_like(cover)
            for oh in onehot:
                purity = np.maximum(purity, (Wy @ oh @ Wx.T) / (r * r))
            score = np.abs(cover - thr).sum() + 2.0 * purity.sum() - 0.05 * np.hypot(sx, sy)
            if score > best_s:
                best, best_s = (sx, sy), score
    return np.array(best)


def art_reduce(part, cls, table, px, n_glow=1):
    """Bins the gen image into art pixels on a grid anchored at the pivot.
    Returns (art RGBA uint8, pivot in art px (integers)); the part's
    effective pivot (`part.pg`, generated-pixel coordinates) is the grid
    corner."""
    r = part.reduce_of(px)
    pg0 = part.to_g(part.pivot_sheet)
    # `inside_share`: how much of a cell the silhouette must cover for the cell to be part of the art
    # (0.5: the half-covered cells decide; a tiny prop, the Scrapjack, takes less so that its thin
    # trigger guard is not lost between the cells)
    thr = float(px.get("inside_share", 0.5))
    shift = best_phase(cls, pg0, r, float(px.get("phase", 1.2)), thr=thr) if px.get("phase", 1.2) > 0 else np.zeros(2)
    part.pg = pg0 + shift
    Wx, Wy, (k0x, k0y), (cx, cy) = art_grid_stats(cls, pg0, r, shift)
    solid = (cls >= 0).astype(float)
    cover = (Wy @ solid @ Wx.T) / (r * r)
    inside = cover >= thr
    ncls = len(table)
    share = np.zeros((cy, cx, ncls))
    for c in range(ncls):
        share[..., c] = Wy @ (cls == c).astype(float) @ Wx.T
    total = np.maximum(share.sum(-1, keepdims=True), 1e-6)
    share = share / total
    lum_t = table.astype(float) @ np.array([0.3, 0.59, 0.11])
    art = np.zeros((cy, cx, 4), np.uint8)
    # cells forced emissive: those whose centre lies in one of the part's `emit` boxes (sheet px)
    emit = np.zeros((cy, cx), bool)
    for bx0, by0, bx1, by1 in part.emit_boxes:
        g0, g1 = part.to_g((bx0, by0)), part.to_g((bx1, by1))
        cxs = part.pg[0] + (k0x + np.arange(cx) + 0.5) * r
        cys = part.pg[1] + (k0y + np.arange(cy) + 0.5) * r
        emit |= ((cys >= g0[1]) & (cys <= g1[1]))[:, None] & ((cxs >= g0[0]) & (cxs <= g1[0]))[None, :]
    # outline cells: the silhouette's 4-neighbour boundary
    pad = np.pad(inside, 1, constant_values=False)
    edge = inside & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
    cell_lum = (share * lum_t[None, None, :]).sum(-1)
    body = np.arange(ncls) > n_glow
    for y in range(cy):
        for x in range(cx):
            if not inside[y, x]:
                continue
            sh = share[y, x]
            # `neon_first`: indices of glow colours that beat the outline (a trim thinner than
            # an art pixel, like the Rover's flank strip, is otherwise eaten by its own outlines)
            first = list(px.get("neon_first", []))
            if edge[y, x]:
                cidx = 0
            elif first and sh[1:1 + n_glow][first].max() >= px.get("neon_share", 0.2):
                cidx = 1 + first[int(np.argmax(sh[1:1 + n_glow][first]))]
            elif sh[0] >= px.get("outline_share", 0.34):
                cidx = 0
            elif n_glow and sh[1:1 + n_glow].max() >= px.get("neon_share", 0.2):
                cidx = 1 + int(np.argmax(sh[1:1 + n_glow]))      # the neon trim wins at a small share
            else:
                score = sh * body
                if score.sum() <= 1e-6:
                    cidx = 0
                else:
                    # a small bright accent (a badge, a tag, an eye highlight) beats its surroundings
                    bright = (lum_t > cell_lum[y, x] + px.get("accent_contrast", 70.0)) & body & (sh > px.get("accent_share", 0.25))
                    score[bright] *= 2.0
                    cidx = int(np.argmax(score))
            art[y, x, :3] = table[cidx]
            art[y, x, 3] = 255
    return art, (-k0x, -k0y), emit & inside


def symmetrize(art, pivot, order=8):
    """The art made symmetric about its pivot (a pixel corner): under the four
    quarter turns (`order` 4) and also the mirror (8). Every cell takes the
    most common colour of its orbit (a tie goes to the darker one) and is
    opaque when at least half of its orbit is. A wheel turns about its hub: the
    lumps the generator's tyre teeth and the pixel grid leave in its outline
    would wobble as it spins; symmetric, it stays round at every angle."""
    from collections import Counter
    h, w = art.shape[:2]
    px_, py_ = int(pivot[0]), int(pivot[1])
    orbit_of = {}
    for r in range(h):
        for c in range(w):
            orbit = {(c - px_, r - py_)}
            todo = list(orbit)
            while todo:
                i, j = todo.pop()
                nxt = [(-j - 1, i)] + ([(-i - 1, j)] if order == 8 else [])   # quarter turn, mirror
                for n in nxt:
                    if n not in orbit:
                        orbit.add(n)
                        todo.append(n)
            orbit_of[(r, c)] = orbit
    out = np.zeros_like(art)
    for (r, c), orbit in orbit_of.items():
        seen, solid = [], 0
        for i, j in orbit:
            rr, cc = j + py_, i + px_
            if 0 <= rr < h and 0 <= cc < w and art[rr, cc, 3] > 127:
                seen.append(tuple(int(v) for v in art[rr, cc, :3]))
                solid += 1
        if solid * 2 < len(orbit):
            continue
        n = Counter(seen)
        best = max(n.values())
        col = min((k for k, v in n.items() if v == best), key=lambda k: 0.3 * k[0] + 0.59 * k[1] + 0.11 * k[2])
        out[r, c, :3] = col
        out[r, c, 3] = 255
    return out


def trim_art(art, pivot, emit):
    """Crops to the opaque bounds; returns (art, pivot, emit)."""
    ys, xs = np.nonzero(art[..., 3])
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    return art[y0:y1, x0:x1], (pivot[0] - x0, pivot[1] - y0), emit[y0:y1, x0:x1]


def pixel_normal_map(art, up, edge_art=2.0, detail=0.5):
    """Normals for pixel art, soft across the pixel steps: the silhouette is
    enlarged, smoothed and rounded like normal_map(), and the painted detail
    (luma without the outline) is blurred over about one art pixel."""
    mask = np.kron((art[..., 3] > 127).astype(np.float32), np.ones((up, up), np.float32))
    sm = gblur(np.pad(mask, up), 0.8 * up)[up:-up, up:-up]
    inside = sm > 0.5
    d = edt_inside(inside)
    edge = edge_art * up
    t = np.clip(d / edge, 0, 1)
    h = edge * np.sqrt(1.0 - (1.0 - t) ** 2)
    dmax = max(float(d.max()), 1.0)
    h += 0.35 * edge * np.sqrt(np.clip(d / dmax, 0, 1))
    rgb = art[..., :3].astype(np.float32) / 255.0
    luma = rgb @ np.array([0.3, 0.59, 0.11], np.float32)
    keep = ((art[..., 3] > 127) & (np.abs(art[..., :3].astype(int) - np.array(OUTLINE)).sum(-1) > 6)).astype(np.float32)
    lum_fill = gblur(luma * keep, 1.0) / np.maximum(gblur(keep, 1.0), 1e-3)
    luma = np.where(keep > 0, luma, lum_fill)
    big = np.kron(luma, np.ones((up, up), np.float32))
    big = gblur(big, 0.9 * up)
    h += detail * edge * 0.25 * (big - gblur(big, 2.2 * up)) * inside
    h = gblur(h * inside, 0.9 * up)
    gy, gx = np.gradient(h)
    n = np.stack([-gx, -gy, np.ones_like(h)], -1)
    n /= np.linalg.norm(n, axis=-1, keepdims=True)
    out = normal_to_rgb(n)
    out[~inside] = [0.5, 0.5, 1.0]
    return out


def pixel_spec_map(art, neon, emit, strengths=None):
    """spec_map() on the art pixels; the exact glow colours (and the part's
    `emit` cells) are the emissive mask, `strengths` (one per glow colour,
    default 1) how strongly each glows."""
    spec = spec_map(art.astype(np.float32), [])
    opaque = art[..., 3] > 127
    for i, g in enumerate(glow_colors(neon)):
        hit = np.all(art[..., :3] == np.array(g, np.uint8), -1) & opaque
        spec[hit] = [0.1, 0.3, 1.0 if strengths is None else strengths[i]]
    spec[emit & opaque] = [0.1, 0.3, 1.0]
    return spec


def cut_pixel(art, pivot, px, neon, emit, strengths=None):
    """The atlas entry of an art-pixel part: nearest-enlarged albedo, smooth
    normals, spec (the same shape cut() returns; the pivot is in texels)."""
    up = int(px["upscale"])
    k = np.ones((up, up), np.uint8)
    alb = np.kron(art, k[..., None]).astype(np.float32) / 255.0
    # `edge_art` (how many art pixels the rim rounds over) and `normal_detail` may be set per sheet:
    # a rounder rim keeps a big flat part (the Staffer's face) from catching a lamp head-on.
    nrm = pixel_normal_map(art, up, float(px.get("edge_art", 2.0)), float(px.get("normal_detail", 0.5)))
    spc = np.kron(pixel_spec_map(art, neon, emit, strengths), k[..., None].astype(np.float32))
    alpha = alb[..., 3]
    nrm[alpha < 0.5] = [0.5, 0.5, 1.0]
    return {"rgb": alb[..., :3], "alpha": alpha, "normal": nrm, "spec": spc,
            "pivot": [float(pivot[0] * up), float(pivot[1] * up)]}


def main():
    global OUT_DIR
    args = sys.argv[1:]
    if not args or args[0] not in SHEETS:
        raise SystemExit("usage: import_parts_sheet.py %s [--preview DIR] [--out-dir DIR] [--measure]" % "|".join(SHEETS))
    name = args[0]
    cfg = SHEETS[name]
    preview = args[args.index("--preview") + 1] if "--preview" in args else None
    if "--measure" in args:
        # Prints each part's generated-pixel size (for `gen` in the sheet's entry).
        sheet, lab = load_sheet(cfg)
        allx, ally = [], []
        for pname, pc in cfg["parts"].items():
            crop, _x0, _y0 = part_crop(sheet, lab, pc["at"])
            gx, gy = measure_gen(crop)
            print("%-12s generated pixel %.2f x %.2f sheet px" % (pname, gx, gy))
            allx.append(gx)
            ally.append(gy)
        print("average      %.1f x %.1f  ->  \"gen\": (%.1f, %.1f)" % (np.nanmean(allx), np.nanmean(ally), np.nanmean(allx), np.nanmean(ally)))
        return
    if "--out-dir" in args:
        OUT_DIR = os.path.abspath(args[args.index("--out-dir") + 1])
    out_name = cfg.get("out", name)
    if cfg.get("kind") == "machine":
        data, out_dir = build_machine(out_name, cfg)
    elif cfg.get("kind") == "prop":
        data, out_dir = build_prop(out_name, cfg)
    else:
        data, out_dir = build_human(out_name, cfg)
    with open(os.path.join(out_dir, "rig.json"), "w") as f:
        json.dump(data, f, indent=1)
    if preview:
        write_preview(data, out_dir, preview, name)


# Which sheet part draws each joint of a human rig. A character whose sheet
# differs (the Staffer: one hand part, a bare near forearm, no baton) lists
# only the joints that differ in its `joint_parts`; "baton": None drops the
# baton joint and its `tell` socket.
HUMAN_JOINT_PARTS = {"head": "head", "torso": "torso", "pelvis": "pelvis", "upper_arm": "upper_arm",
                     "far_forearm": "forearm", "near_forearm": "forearm", "far_hand": "hand_open",
                     "near_hand": "hand_grip", "thigh": "thigh", "shin": "shin", "foot": "foot", "baton": "baton"}


def build_human(name, cfg):
    sheet, lab = load_sheet(cfg)
    P = cfg["parts"]
    px = cfg.get("pixel")
    T = cfg["texture_scale"]
    JP = dict(HUMAN_JOINT_PARTS)
    JP.update(cfg.get("joint_parts", {}))
    hand_n, hand_f = JP["near_hand"], JP["far_hand"]
    forearm_n, forearm_f = JP["near_forearm"], JP["far_forearm"]

    # --- the unit each part is measured in -----------------------------------
    # A smooth sheet has one scale for the whole sheet: soles to crown equals
    # the gameplay height. A pixel sheet is measured on every part's own art
    # grid (world = art pixels * px["world"]), so the grids' drift between
    # parts never shows. rel(part, sheet point) is the world offset of a
    # sheet point from the part's pivot.
    head_top = min(y for y, _x in zip(*np.nonzero(lab == lab[P["head"]["at"][1], P["head"]["at"][0]])))
    sole_y = max(p[1] for p in P["foot"]["soles"])
    if px:
        pparts = {pname: PixelPart(pname, sheet, lab, pc, px) for pname, pc in P.items()}
        world = float(px["world"])

        def rel(pname, pt, nd=4):
            part = pparts[pname]
            pg = part.pg if part.pg is not None else part.to_g(part.pivot_sheet)
            d = (part.to_g(pt) - pg) / part.reduce_of(px) * world
            return [round(float(d[0]), nd), round(float(d[1]), nd)]

        def snap(v):
            """A joint offset in whole art pixels."""
            return [round(round(v[0] / world) * world, 2), round(round(v[1] / world) * world, 2)]
    else:
        px_height = ((sole_y - P["foot"]["pivot"][1]) + (P["shin"]["ankle"][1] - P["shin"]["pivot"][1])
                     + (P["thigh"]["knee"][1] - P["thigh"]["pivot"][1]) + (P["pelvis"]["pivot"][1] - P["pelvis"]["waist"][1])
                     + (P["torso"]["pivot"][1] - P["torso"]["neck"][1]) + (P["head"]["pivot"][1] - head_top))
        s = cfg["height"] / px_height                   # world px per sheet px
        k = s * T                                       # atlas texels per sheet px
        print("scale %.4f world px per sheet px (%.1f px sheet height)" % (s, px_height))

        def rel(pname, pt, nd=2):
            pv = P[pname]["pivot"]
            return [round((pt[0] - pv[0]) * s, nd), round((pt[1] - pv[1]) * s, nd)]

        def snap(v):
            return v

    if px and "reduce" not in px:
        # The reduction that stands the character at its gameplay height.
        px["reduce"] = 1.0
        h_gen = (rel("foot", (P["foot"]["pivot"][0], sole_y))[1] + rel("shin", P["shin"]["ankle"])[1]
                 + rel("thigh", P["thigh"]["knee"])[1] - rel("pelvis", P["pelvis"]["waist"])[1]
                 - rel("torso", P["torso"]["neck"])[1] - rel("head", (P["head"]["pivot"][0], head_top))[1])
        px["reduce"] = round(h_gen / cfg["height"], 3)
        print("reduce %.3f generated pixels per art pixel" % px["reduce"])

    # --- cut, scale and map every part ---
    results = {}
    if px:
        classes, table = palette_classes(pparts, cfg["neon"], int(px["colors"]), extra=px.get("extra_colors"))
        if cfg.get("skin_scale"):
            # Skin tones a little darker, so a lamp overhead never blows a face out to white
            # (the old Staffer's skin was painted the same way; see paint_staffer.py).
            table = table.copy()
            for i in range(1 + len(glow_colors(cfg["neon"])), len(table)):
                r, g, b = (table[i] / 255.0).tolist()
                top = max(r, g, b)
                if r > b + 0.12 and (top - min(r, g, b)) / max(top, 1e-4) > 0.2 and top > 0.35:
                    table[i] = np.clip(table[i].astype(float) * float(cfg["skin_scale"]), 0, 255).astype(np.uint8)
        if cfg.get("skin_tint"):
            # Skin retinted per channel by `to` / `from` (Dave's sheet paints his skin about
            # #D8A078, tanner than his brief's fair #E1B596). Only skin entries change: warm, light
            # and moderately saturated, with green between 0.58 and 0.86 of red (the burnt-orange
            # jacket is more saturated and redder, the boots and the hair are darker).
            tint = cfg["skin_tint"]
            gain = np.array(tint["to"], float) / np.array(tint["from"], float)
            table = table.copy()
            for i in range(1 + len(glow_colors(cfg["neon"])), len(table)):
                r, g, b = (table[i] / 255.0).tolist()
                top = max(r, g, b)
                sat = (top - min(r, g, b)) / max(top, 1e-4)
                if r > b + 0.12 and 0.2 < sat < 0.62 and top > 0.5 and 0.58 < g / max(r, 1e-4) < 0.86:
                    table[i] = np.clip(np.round(table[i].astype(float) * gain), 0, 255).astype(np.uint8)
        for pname, part in pparts.items():
            # a part's own `pixel` dict overrides the sheet's (Dave's head: a higher `outline_share`, so
            # the brow and the eye are not one black block)
            ppx = dict(px, **P[pname].get("pixel", {}))
            art, pivot_art, emit = art_reduce(part, classes[pname], table, ppx, len(glow_colors(cfg["neon"])))
            art, pivot_art, emit = trim_art(art, pivot_art, emit)
            if "lens" in P[pname]:
                # A small lamp painted on the part: the art pixel just right of and below
                # the pivot corner takes the lens colour and glows (the Staffer's dull amber
                # Link port light).
                ly, lx = int(pivot_art[1]), int(pivot_art[0])
                art[ly, lx, :3] = P[pname]["lens"]
                emit[ly, lx] = True
            for (dx, dy), colour in P[pname].get("paint", []):
                # Hand-placed art pixels, (dx, dy) art px from the one right of and below the
                # pivot corner: a feature too small to survive the binning (Dave's eye and brow).
                # The colour snaps to the palette's nearest entry (after any skin retint).
                ly, lx = int(pivot_art[1]) + int(dy), int(pivot_art[0]) + int(dx)
                assert art[ly, lx, 3] > 0, "%s: paint (%d, %d) is outside the art" % (pname, dx, dy)
                art[ly, lx, :3] = table[int(np.argmin(np.abs(table.astype(int) - np.array(colour)).sum(1)))]
            results[pname] = cut_pixel(art, pivot_art, ppx, cfg["neon"], emit)
            shift = (part.pg - part.to_g(part.pivot_sheet)) * np.array([part.gen[0], part.gen[1]])
            print("%-10s gen %dx%d  art %dx%d px  pivot (%d, %d)  grid moved the pivot %.1f, %.1f sheet px" % (
                pname, part.G.shape[1], part.G.shape[0], art.shape[1], art.shape[0], pivot_art[0], pivot_art[1],
                shift[0], shift[1]))
    else:
        for pname, pc in P.items():
            crop, x0, y0 = part_crop(sheet, lab, pc["at"])
            results[pname] = cut(crop, (pc["pivot"][0] - x0, pc["pivot"][1] - y0), k, [(cfg["neon"], 1.0)])
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 256))
    # --- skeleton, read off the anchors ---
    t, pe, ua, fa = P["torso"], P["pelvis"], P["upper_arm"], P[forearm_n]
    hip_h = (rel("foot", (P["foot"]["pivot"][0], sole_y), 6)[1] + rel("shin", P["shin"]["ankle"], 6)[1]
             + rel("thigh", P["thigh"]["knee"], 6)[1])
    torso_pos = rel("pelvis", pe["waist"])
    neck = rel("torso", t["neck"])
    shoulder = rel("torso", t["shoulder"])
    elbow = rel("upper_arm", ua["elbow"])
    wrist = rel(forearm_n, fa["wrist"])
    wrist_f = rel(forearm_f, P[forearm_f]["wrist"])
    grip = rel(hand_n, P[hand_n]["grip"]) if "grip" in P[hand_n] else [0.0, 3.0]
    knee = rel("thigh", P["thigh"]["knee"])
    ankle = rel("shin", P["shin"]["ankle"])
    has_baton = JP.get("baton") is not None
    tip = rel(JP["baton"], P[JP["baton"]]["tip"]) if has_baton else None
    soles = [rel("foot", p) for p in P["foot"]["soles"]]
    world_w = {n: results[n]["alpha"].shape[1] / T for n in results}
    head_c = rel("head", P["head"]["at"])
    if px:
        # Hip height, joint offsets and the baton's grip in whole art pixels
        # (the colliders, sole points and sockets stay as measured).
        head_up = -rel("head", (P["head"]["pivot"][0], head_top))[1]
        hip_h = snap([0.0, hip_h])[1]
        torso_pos, neck, shoulder = snap(torso_pos), snap(neck), snap(shoulder)
        elbow_j, wrist_j, knee_j, ankle_j, grip_j = snap(elbow), snap(wrist), snap(knee), snap(ankle), snap(grip)
        wrist_fj = snap(wrist_f)
        standing = hip_h - torso_pos[1] - neck[1] + head_up
        print("hip height %.1f world px; standing height %.1f world px = %.1f art px (target %.0f)" % (
            hip_h, standing, standing / world, cfg["height"]))
    else:
        elbow_j, wrist_j, knee_j, ankle_j, grip_j = elbow, wrist, knee, ankle, grip
        wrist_fj = wrist_f

    def cap(b, r, a=(0.0, 0.0)):
        return {"type": "capsule", "a": list(a), "b": list(b), "r": round(r, 2)}

    joints = [
        ("pelvis", JP["pelvis"], "", [0.0, -round(hip_h, 2)], 3, False, cap([4.0, -4.0], 6.0, (-4.0, -4.0)), 12.0, None, -90),
        ("torso", JP["torso"], "pelvis", torso_pos, 5, False, cap([neck[0] * 0.5, neck[1] + 5.0], 0.34 * world_w[JP["torso"]], (0.0, -2.0)), 25.0, [-35, 75], -90),
        ("head", JP["head"], "torso", neck, 6, False, {"type": "circle", "c": head_c, "r": round(0.4 * world_w[JP["head"]], 2)}, 5.0, [-40, 45], -90),
        ("far_upper_arm", JP["upper_arm"], "torso", shoulder, 1, True, cap(elbow, 0.32 * world_w[JP["upper_arm"]]), 2.5, [-175, 70], 90),
        ("far_forearm", forearm_f, "far_upper_arm", elbow_j, 1, True, cap(wrist_f, 0.3 * world_w[forearm_f]), 1.8, [-145, 0], 90),
        ("far_hand", hand_f, "far_forearm", wrist_fj, 1, True, {"type": "circle", "c": [0.0, round(grip[1], 2)], "r": 2.8}, 0.7, [-60, 60], 90),
        ("far_thigh", JP["thigh"], "pelvis", [0.0, 0.0], 2, True, cap(knee, 0.4 * world_w[JP["thigh"]]), 8.0, [-110, 40], 90),
        ("far_shin", JP["shin"], "far_thigh", knee_j, 2, True, cap(ankle, 0.36 * world_w[JP["shin"]]), 4.0, [0, 150], 90),
        ("far_foot", JP["foot"], "far_shin", ankle_j, 2, True, cap([soles[2][0] - 2.0, soles[1][1] - 2.4], 2.3, (soles[0][0] + 2.0, soles[1][1] - 2.4)), 1.5, [-40, 35], 0),
        ("near_thigh", JP["thigh"], "pelvis", [0.0, 0.0], 4, False, cap(knee, 0.4 * world_w[JP["thigh"]]), 8.0, [-110, 40], 90),
        ("near_shin", JP["shin"], "near_thigh", knee_j, 4, False, cap(ankle, 0.36 * world_w[JP["shin"]]), 4.0, [0, 150], 90),
        ("near_foot", JP["foot"], "near_shin", ankle_j, 4, False, cap([soles[2][0] - 2.0, soles[1][1] - 2.4], 2.3, (soles[0][0] + 2.0, soles[1][1] - 2.4)), 1.5, [-40, 35], 0),
        ("near_upper_arm", JP["upper_arm"], "torso", shoulder, 7, False, cap(elbow, 0.32 * world_w[JP["upper_arm"]]), 2.5, [-175, 70], 90),
        ("near_forearm", forearm_n, "near_upper_arm", elbow_j, 8, False, cap(wrist, 0.3 * world_w[forearm_n]), 1.8, [-145, 0], 90),
        ("near_hand", hand_n, "near_forearm", wrist_j, 10, False, {"type": "circle", "c": [0.0, round(grip[1], 2)], "r": 2.8}, 0.7, [-60, 60], 90),
    ]
    if has_baton:
        joints.append(("baton", JP["baton"], "near_hand", grip_j, 9, False, cap(tip, 1.9, (0.0, -3.0)), 0.6, None, 90))

    def bounds_collider(pname):
        """A collider fitted to a part's art: a circle, or a capsule along its long axis."""
        ys, xs = np.nonzero(results[pname]["alpha"] > 0.5)
        pvx, pvy = results[pname]["pivot"]
        x0, x1 = (xs.min() - pvx) / T, (xs.max() + 1 - pvx) / T
        y0, y1 = (ys.min() - pvy) / T, (ys.max() + 1 - pvy) / T
        cx, cy, hw, hh = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
        if abs(hw - hh) < 0.25 * max(hw, hh):
            return {"type": "circle", "c": [round(cx, 2), round(cy, 2)], "r": round(0.9 * min(hw, hh), 2)}
        r = 0.85 * min(hw, hh)
        if hw >= hh:
            return {"type": "capsule", "a": [round(cx - hw + r, 2), round(cy, 2)], "b": [round(cx + hw - r, 2), round(cy, 2)], "r": round(r, 2)}
        return {"type": "capsule", "a": [round(cx, 2), round(cy - hh + r, 2)], "b": [round(cx, 2), round(cy + hh - r, 2)], "r": round(r, 2)}

    # Extra joints (`extra_joints`): small parts hung on a joint above, for a sheet with more
    # parts than the guard's rig (the Staffer's Link port on the head, its lanyard on the
    # torso). Each: name, part, parent, `on` (the sheet part the parent joint draws) and `at`
    # (a sheet point on it: the new joint's pivot), z, mass, limit, rest_dir, `before` (a joint
    # it is listed in front of: of equal z, a later joint draws on top) and optionally far and
    # collider (else fitted to the part's art).
    for ex in cfg.get("extra_joints", []):
        pos = snap(rel(ex["on"], ex["at"]))
        row = (ex["name"], ex["part"], ex["parent"], pos, ex["z"], ex.get("far", False),
               ex.get("collider") or bounds_collider(ex["part"]), ex["mass"], ex.get("limit"), ex.get("rest_dir", 90))
        joints.insert(next((i for i, j in enumerate(joints) if j[0] == ex.get("before")), len(joints)), row)
    # Per-sheet overrides: `joint_z` (draw order), `colliders` (a joint's collider, joint-local
    # world px) and `joint_mass` (the ragdoll's masses, to keep a character's own).
    joints = [(j[0], j[1], j[2], j[3], cfg.get("joint_z", {}).get(j[0], j[4]), j[5],
               cfg.get("colliders", {}).get(j[0], j[6]), cfg.get("joint_mass", {}).get(j[0], j[7]), j[8], j[9]) for j in joints]
    # Sockets: the baton's tell, plus any the sheet lists as `sockets`:
    # name -> {"joint", "part", "at": sheet point on that part} or {"joint", "pos": (x, y) joint-local world px}.
    sockets = {"tell": {"joint": "baton", "pos": tip}} if has_baton else {}
    for sname, sc in cfg.get("sockets", {}).items():
        sockets[sname] = {"joint": sc["joint"], "pos": list(sc["pos"]) if "pos" in sc else rel(sc["part"], sc["at"], 2)}
    data = {
        "name": cfg["rig_name"], "kind": "human", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": True, "sole_points": soles,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": j[0], "part": j[1], "parent": j[2], "pos": j[3], "z": j[4], "far": j[5],
                    "collider": j[6], "mass": j[7], "limit": j[8], "rest_dir": j[9]} for j in joints],
        "sockets": sockets,
        "source": cfg["sheet"],
    }
    if px:
        data["pixel_art"] = True
        data["pixel_world"] = float(px["world"])
    return data, out_dir


def build_machine_pixel(name, cfg, sheet, lab):
    """build_machine() for a pixel sheet: the same parts, `place` points and
    sockets, but every part is cut on its own art-pixel grid (see the module
    docstring) and nothing is rotated or scaled (`rotate` / `scale` are not
    used: pixel art does not survive resampling, so the sheet's parts must
    already fit together). The scale comes from `length` as for a smooth
    machine: `reduce` generated pixels per art pixel unless it is given."""
    P = cfg["parts"]
    px = cfg["pixel"]
    T = cfg["texture_scale"]
    world = float(px["world"])
    pparts = {pname: PixelPart(pname, sheet, lab, pc, px) for pname, pc in P.items()}
    for pname, pc in P.items():
        assert not pc.get("rotate") and pc.get("scale", (1.0, 1.0)) == (1.0, 1.0), \
            "%s: a pixel part is not rotated or scaled" % pname

    def rel(pname, pt, nd=4):
        part = pparts[pname]
        pg = part.pg if part.pg is not None else part.to_g(part.pivot_sheet)
        d = (part.to_g(pt) - pg) / float(px["reduce"]) * world
        return [round(float(d[0]), nd), round(float(d[1]), nd)]

    def snap(v):
        return [round(round(v[0] / world) * world, 2), round(round(v[1] / world) * world, 2)]

    ch, bu = P["chassis"], P["bumper"]

    def on_chassis(pt):
        a, b = rel("chassis", pt), rel("chassis", ch["place"])
        return [round(a[0] - b[0], 4), round(a[1] - b[1], 4)]

    def extents():
        """(rear, front) of the assembled machine, world px, from the chassis's pivot."""
        cb, bb = pparts["chassis"].bbox, pparts["bumper"].bbox
        rear = on_chassis((cb[0], ch["pivot"][1]))[0]
        front = on_chassis(bu["place"])[0] + rel("bumper", (bb[2], bu["pivot"][1]))[0]
        return rear, front

    if "reduce" not in px:
        px["reduce"] = 1.0
        rear, front = extents()
        px["reduce"] = round((front - rear) / cfg["length"], 3)
        print("reduce %.3f generated pixels per art pixel" % px["reduce"])
    glow_list = cfg.get("glow", [])
    glows = [g[0] for g in glow_list]
    classes, table = (palette_classes(pparts, glows, int(px["colors"]), drop_purple=bool(px.get("drop_purple")))
                      if glows else (None, None))
    results = {}
    for pname, part in pparts.items():
        # a part may override the sheet's `pixel` settings (the wheel's `phase`: 0 keeps its
        # grid exactly on the hub) and list a `symmetry` (4 or 8, see symmetrize)
        ppx = dict(px, **P[pname].get("pixel", {}))
        art, pivot_art, emit = art_reduce(part, classes[pname], table, ppx, len(glows))
        if P[pname].get("symmetry"):
            art = symmetrize(art, pivot_art, int(P[pname]["symmetry"]))
            emit = np.zeros(art.shape[:2], bool)
        art, pivot_art, emit = trim_art(art, pivot_art, emit)
        strengths = [g[1] * P[pname].get("glow_scale", 1.0) for g in glow_list]
        results[pname] = cut_pixel(art, pivot_art, px, glows, emit, strengths)
        print("%-10s gen %dx%d  art %dx%d px" % (pname, part.G.shape[1], part.G.shape[0], art.shape[1], art.shape[0]))
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 256))

    # The chassis pivot sits at axle height, centred so the machine's length
    # is centred on its origin (the collision box mirrors around it). The
    # wheels' lowest point (below their pivot, and below the chassis pivot by
    # the wheels' offset) stands on the floor.
    rear, front = extents()
    radius = (results["wheel"]["alpha"].shape[0] - results["wheel"]["pivot"][1]) / T
    wheel_dy = snap(on_chassis(P["wheel"]["places"][0]))[1]
    centre = 0.5 * (rear + front)
    chassis_pos = snap([-centre, -(radius + wheel_dy)])

    def collider(pname):
        a = results[pname]["alpha"] > 0.5
        ys, xs = np.nonzero(a)
        px_, py_ = results[pname]["pivot"]
        x0, x1 = (xs.min() - px_) / T, (xs.max() + 1 - px_) / T
        y0, y1 = (ys.min() - py_) / T, (ys.max() + 1 - py_) / T
        cx, cy, hw, hh = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
        if pname == "wheel":
            return {"type": "circle", "c": [round(cx, 2), round(cy, 2)], "r": round(0.95 * min(hw, hh), 2)}
        if hw >= hh:
            r = 0.85 * hh
            return {"type": "capsule", "a": [round(cx - hw + r, 2), round(cy, 2)],
                    "b": [round(cx + hw - r, 2), round(cy, 2)], "r": round(r, 2)}
        r = 0.85 * hw
        return {"type": "capsule", "a": [round(cx, 2), round(cy - hh + r, 2)],
                "b": [round(cx, 2), round(cy + hh - r, 2)], "r": round(r, 2)}

    wheel = P["wheel"]
    rear_w, front_w = wheel["places"]
    joints = [
        ("chassis", "chassis", "", chassis_pos, 3, False, 45.0, "chassis"),
        ("wheel_far_rear", "wheel", "chassis", snap(on_chassis(rear_w)), 1, True, 5.0, "wheel_far_rear"),
        ("wheel_far_front", "wheel", "chassis", snap(on_chassis(front_w)), 1, True, 5.0, "wheel_far_front"),
        ("wheel_near_rear", "wheel", "chassis", snap(on_chassis(rear_w)), 2, False, 5.0, "wheel_near_rear"),
        ("wheel_near_front", "wheel", "chassis", snap(on_chassis(front_w)), 2, False, 5.0, "wheel_near_front"),
        ("lightbar", "lightbar", "chassis", snap(on_chassis(P["lightbar"]["place"])), 2, False, 2.5, "lightbar"),
        ("battery", "battery", "chassis", snap(on_chassis(P["battery"]["place"])), 4, False, 9.0, "battery"),
        ("hatch", "hatch", "chassis", snap(on_chassis(P["hatch"]["place"])), 5, False, 3.0, "hatch"),
        ("sensor", "sensor", "chassis", snap(on_chassis(P["sensor"]["place"])), 6, False, 4.0, "dome"),
        ("bumper", "bumper", "chassis", snap(on_chassis(bu["place"])), 7, False, 7.0, "bumper"),
    ]
    data = {
        "name": cfg["rig_name"], "kind": "machine", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": False,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": j[0], "part": j[1], "parent": j[2], "pos": j[3], "z": j[4], "far": j[5],
                    "collider": collider(j[1]), "mass": j[6], "limit": None, "rest_dir": 0, "role": j[7]}
                   for j in joints],
        "sockets": {
            "lens_light": {"joint": "sensor", "pos": rel("sensor", P["sensor"]["lens"], 2)},
            "tell": {"joint": "lightbar", "pos": rel("lightbar", P["lightbar"]["lens"], 2)},
            "core": {"joint": "battery", "pos": rel("battery", P["battery"]["pivot"], 2)},
            "spark_bumper": {"joint": "bumper", "pos": rel("bumper", P["bumper"]["front"], 2)},
            # `spark` (a sheet point on the part) places the hatch's and pod's spark points; without it
            # the hatch's is the middle of the lid and the pod's half its height above its pivot
            "spark_hatch": {"joint": "hatch", "pos": rel("hatch", P["hatch"]["spark"], 2) if "spark" in P["hatch"]
                            else [round(-0.5 * results["hatch"]["alpha"].shape[1] / T, 2), 0.0]},
            "spark_dome": {"joint": "sensor", "pos": rel("sensor", P["sensor"]["spark"], 2) if "spark" in P["sensor"]
                           else [0.0, round(-0.5 * results["sensor"]["alpha"].shape[0] / T, 2)]},
            "oil_drip": {"joint": "chassis", "pos": [0.0, round(on_chassis((ch["pivot"][0], ch["bottom"]))[1], 2)]},
        },
        "source": cfg["sheet"],
        "pixel_art": True, "pixel_world": world,
    }
    return data, out_dir


def build_machine(name, cfg):
    """A rigid machine: every part hangs off the chassis at its `place`."""
    sheet, lab = load_sheet(cfg)
    if cfg.get("pixel"):
        return build_machine_pixel(name, cfg, sheet, lab)
    P = cfg["parts"]
    T = cfg["texture_scale"]
    fitted = {}
    for pname, pc in P.items():
        crop, x0, y0 = part_crop(sheet, lab, pc["at"])
        pivot = np.array([pc["pivot"][0] - x0, pc["pivot"][1] - y0], float)
        crop, pivot, fwd = fit_part(crop, pivot, pc.get("rotate", 0.0), pc.get("scale", (1.0, 1.0)))
        fitted[pname] = (crop, pivot, (lambda f, ox, oy: lambda pt: f((pt[0] - ox, pt[1] - oy)))(fwd, x0, y0))

    # The scale: from the rear of the chassis to the front of the placed bumper.
    ch, bu = P["chassis"], P["bumper"]
    ch_crop, ch_piv, _ = fitted["chassis"]
    rear = ch["place"][0] - ch_piv[0]
    bu_crop, bu_piv, _ = fitted["bumper"]
    front = bu["place"][0] + (bu_crop.shape[1] - bu_piv[0])
    s = cfg["length"] / (front - rear)
    k = s * T
    print("scale %.4f world px per sheet px (%.0f px sheet length)" % (s, front - rear))

    results = {}
    for pname, (crop, pivot, _f) in fitted.items():
        glows = [(c, b * P[pname].get("glow_scale", 1.0)) for c, b in cfg["glow"]]
        results[pname] = cut(crop, pivot, k, glows)
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 256))

    # The chassis pivot sits at axle height, centred so the machine's length
    # is centred on its origin (the collision box mirrors around it).
    wheel = P["wheel"]
    radius = fitted["wheel"][0].shape[0] * 0.5 - 4.0
    centre = 0.5 * (rear + front)
    chassis_pos = [round((ch["place"][0] - centre) * s, 2), round(-radius * s, 2)]

    def on_chassis(pt):
        return [round((pt[0] - ch["place"][0]) * s, 2), round((pt[1] - ch["place"][1]) * s, 2)]

    def local(pname, pt):
        """World offset of a sheet point of a part from that part's pivot."""
        crop, pivot, f = fitted[pname]
        q = f(pt)
        return [round((q[0] - pivot[0]) * s, 2), round((q[1] - pivot[1]) * s, 2)]

    def collider(pname):
        a = results[pname]["alpha"] > 0.5
        ys, xs = np.nonzero(a)
        px, py = results[pname]["pivot"]
        x0, x1 = (xs.min() - px) / T, (xs.max() + 1 - px) / T
        y0, y1 = (ys.min() - py) / T, (ys.max() + 1 - py) / T
        cx, cy, hw, hh = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
        if pname == "wheel":
            return {"type": "circle", "c": [round(cx, 2), round(cy, 2)], "r": round(0.95 * min(hw, hh), 2)}
        if hw >= hh:
            r = 0.85 * hh
            return {"type": "capsule", "a": [round(cx - hw + r, 2), round(cy, 2)],
                    "b": [round(cx + hw - r, 2), round(cy, 2)], "r": round(r, 2)}
        r = 0.85 * hw
        return {"type": "capsule", "a": [round(cx, 2), round(cy - hh + r, 2)],
                "b": [round(cx, 2), round(cy + hh - r, 2)], "r": round(r, 2)}

    rear_w, front_w = wheel["places"]
    # (name, part, parent, pos, z, far, mass, role). The wheels sit behind
    # the chassis, whose arches overlap them; the battery sits in its bay
    # under the hatch lid, so it shows only when the lid swings open.
    joints = [
        ("chassis", "chassis", "", chassis_pos, 3, False, 45.0, "chassis"),
        ("wheel_far_rear", "wheel", "chassis", on_chassis(rear_w), 1, True, 5.0, "wheel_far_rear"),
        ("wheel_far_front", "wheel", "chassis", on_chassis(front_w), 1, True, 5.0, "wheel_far_front"),
        ("wheel_near_rear", "wheel", "chassis", on_chassis(rear_w), 2, False, 5.0, "wheel_near_rear"),
        ("wheel_near_front", "wheel", "chassis", on_chassis(front_w), 2, False, 5.0, "wheel_near_front"),
        ("lightbar", "lightbar", "chassis", on_chassis(P["lightbar"]["place"]), 2, False, 2.5, "lightbar"),
        ("battery", "battery", "chassis", on_chassis(P["battery"]["place"]), 4, False, 9.0, "battery"),
        ("hatch", "hatch", "chassis", on_chassis(P["hatch"]["place"]), 5, False, 3.0, "hatch"),
        ("sensor", "sensor", "chassis", on_chassis(P["sensor"]["place"]), 6, False, 4.0, "dome"),
        ("bumper", "bumper", "chassis", on_chassis(P["bumper"]["place"]), 7, False, 7.0, "bumper"),
    ]
    bat = fitted["battery"]
    data = {
        "name": cfg["rig_name"], "kind": "machine", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": False,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": j[0], "part": j[1], "parent": j[2], "pos": j[3], "z": j[4], "far": j[5],
                    "collider": collider(j[1]), "mass": j[6], "limit": None, "rest_dir": 0, "role": j[7]}
                   for j in joints],
        "sockets": {
            "lens_light": {"joint": "sensor", "pos": local("sensor", P["sensor"]["lens"])},
            "tell": {"joint": "lightbar", "pos": local("lightbar", P["lightbar"]["lens"])},
            "core": {"joint": "battery", "pos": local("battery", P["battery"]["pivot"])},
            "spark_bumper": {"joint": "bumper", "pos": local("bumper", P["bumper"]["front"])},
            "spark_hatch": {"joint": "hatch", "pos": [round(-0.5 * fitted["hatch"][0].shape[1] * s, 2), 0.0]},
            "spark_dome": {"joint": "sensor", "pos": [0.0, round(-0.5 * fitted["sensor"][0].shape[0] * s, 2)]},
            "oil_drip": {"joint": "chassis", "pos": [0.0, round((ch["bottom"] - ch["place"][1]) * s, 2)]},
        },
        "source": cfg["sheet"],
    }
    print("battery %dx%d px world" % (bat[0].shape[1] * s, bat[0].shape[0] * s))
    return data, out_dir


def build_prop_pixel(name, cfg, sheet, lab):
    """build_prop() for a pixel sheet (the Scrapjack's since 2026-10-07): the same parts,
    `place` points and sockets, but every part is cut on its own art-pixel grid (see the
    module docstring) and nothing is rotated or scaled (a part that is too big for the
    assembly takes a coarser `reduce` of its own instead). The first part is the root: its
    pivot is the rig's origin (where the hand holds the grip, the root joint's (0, 0)) and
    every other part's `place` is a sheet point on the root where that part's pivot sits,
    measured on the root's art grid and rounded to whole art pixels. The scale comes from
    `length` (the back of the root to the muzzle) as for a machine, unless `reduce` is
    given. Sockets: `muzzle` (the barrel's front edge, on the barrel's `muzzle` row) and
    `charge_light` (a sheet point on the battery, `light`)."""
    P = cfg["parts"]
    px = cfg["pixel"]
    T = cfg["texture_scale"]
    world = float(px["world"])
    names = list(P)
    root = names[0]
    assert tuple(P[root]["pivot"]) == tuple(cfg["origin"]) == tuple(P[root]["place"]), \
        "the root's pivot, place and the rig's origin are the grip point"
    pparts = {pname: PixelPart(pname, sheet, lab, pc, px) for pname, pc in P.items()}
    for pname, pc in P.items():
        assert not pc.get("rotate") and pc.get("scale", (1.0, 1.0)) == (1.0, 1.0), \
            "%s: a pixel part is not rotated or scaled" % pname

    def rel(pname, pt, nd=4):
        part = pparts[pname]
        pg = part.pg if part.pg is not None else part.to_g(part.pivot_sheet)
        d = (part.to_g(pt) - pg) / part.reduce_of(px) * world
        return [round(float(d[0]), nd), round(float(d[1]), nd)]

    def snap(v):
        return [round(round(v[0] / world) * world, 2), round(round(v[1] / world) * world, 2)]

    def extents(rounded):
        """(back, front) of the assembled prop, world px, from the grip: the back of the root
        to the barrel's muzzle."""
        rb = pparts[root].bbox
        back = rel(root, (rb[0], P[root]["pivot"][1]))[0]
        j = rel(root, P["barrel"]["place"])
        j = snap(j) if rounded else j
        return back, j[0] + rel("barrel", P["barrel"]["muzzle"])[0]

    if "reduce" not in px:
        px["reduce"] = 1.0
        back, front = extents(False)
        px["reduce"] = round((front - back) / cfg["length"], 3)
        print("reduce %.3f generated pixels per art pixel" % px["reduce"])
    glow_list = cfg.get("glow", [])
    glows = [g[0] for g in glow_list]
    classes, table = palette_classes(pparts, glows, int(px["colors"]), drop_purple=bool(px.get("drop_purple")))
    results = {}
    arts = {}
    for pname, part in pparts.items():
        ppx = dict(px, **P[pname].get("pixel", {}))
        art, pivot_art, emit = art_reduce(part, classes[pname], table, ppx, len(glows))
        art, pivot_art, emit = trim_art(art, pivot_art, emit)
        strengths = [g[1] * P[pname].get("glow_scale", 1.0) for g in glow_list]
        results[pname] = cut_pixel(art, pivot_art, px, glows, emit, strengths)
        arts[pname] = (art, pivot_art)
        print("%-10s gen %dx%d  art %dx%d px  pivot (%d, %d)  reduce %.2f" % (
            pname, part.G.shape[1], part.G.shape[0], art.shape[1], art.shape[0], pivot_art[0], pivot_art[1],
            part.reduce_of(px)))
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 128))

    def collider(pname):
        a = results[pname]["alpha"] > 0.5
        ys, xs = np.nonzero(a)
        px_, py_ = results[pname]["pivot"]
        x0, x1 = (xs.min() - px_) / T, (xs.max() + 1 - px_) / T
        y0, y1 = (ys.min() - py_) / T, (ys.max() + 1 - py_) / T
        cx, cy, hw, hh = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
        r = 0.85 * min(hw, hh)
        if hw >= hh:
            return {"type": "capsule", "a": [round(cx - hw + r, 2), round(cy, 2)],
                    "b": [round(cx + hw - r, 2), round(cy, 2)], "r": round(r, 2)}
        return {"type": "capsule", "a": [round(cx, 2), round(cy - hh + r, 2)],
                "b": [round(cx, 2), round(cy + hh - r, 2)], "r": round(r, 2)}

    # The muzzle: the front edge of the barrel's art (a pixel boundary), halfway up it.
    b_art, b_piv = arts["barrel"]
    muzzle = [round((b_art.shape[1] - b_piv[0]) * world, 2), round((0.5 * b_art.shape[0] - b_piv[1]) * world, 2)]
    # The charge light: the middle of the battery's cells in the `light` glow colour (the second one),
    # else the sheet point `light`.
    l_art, l_piv = arts["battery"]
    lit = np.nonzero(np.all(l_art[..., :3] == np.array(glows[int(P["battery"].get("light_glow", 1))], np.uint8), -1)
                     & (l_art[..., 3] > 127))
    light = ([round((float(lit[1].mean()) + 0.5 - l_piv[0]) * world, 2), round((float(lit[0].mean()) + 0.5 - l_piv[1]) * world, 2)]
             if len(lit[0]) else rel("battery", P["battery"]["light"], 2))
    back, front = extents(True)
    root_art, root_piv = arts[root]
    print("assembled: %.1f world px from the back of the grip (%.1f) to the muzzle (%.1f from the grip point); "
          "the barrel's front edge is %.1f; length %.1f world px = %.1f art px" % (
              front - back, back, front, muzzle[0] + snap(rel(root, P["barrel"]["place"]))[0],
              front - back, (front - back) / world))
    data = {
        "name": cfg["rig_name"], "kind": "prop", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": False,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": n, "part": n, "parent": "" if n == root else root,
                    "pos": [0.0, 0.0] if n == root else snap(rel(root, P[n]["place"])),
                    "z": P[n]["z"], "far": False, "collider": collider(n), "mass": P[n]["mass"],
                    "limit": None, "rest_dir": 0, "role": n} for n in names],
        "sockets": {
            "muzzle": {"joint": "barrel", "pos": muzzle},
            "charge_light": {"joint": "battery", "pos": light},
        },
        "source": cfg["sheet"],
        "pixel_art": True, "pixel_world": world,
    }
    return data, out_dir


def build_prop(name, cfg):
    """A small rigid prop (a gun): every part hangs off the first one at its
    `place`, and the rig's origin is `origin` (where the hand holds it)."""
    sheet, lab = load_sheet(cfg)
    if cfg.get("pixel"):
        return build_prop_pixel(name, cfg, sheet, lab)
    P = cfg["parts"]
    T = cfg["texture_scale"]
    names = list(P)
    fitted = {}
    for pname in names:
        pc = P[pname]
        crop, x0, y0 = part_crop(sheet, lab, pc["at"])
        pivot = np.array([pc["pivot"][0] - x0, pc["pivot"][1] - y0], float)
        crop, pivot, fwd = fit_part(crop, pivot, pc.get("rotate", 0.0), pc.get("scale", (1.0, 1.0)))
        fitted[pname] = (crop, pivot, (lambda f, ox, oy: lambda pt: f((pt[0] - ox, pt[1] - oy)))(fwd, x0, y0))

    # The scale: from the back of the grip to the muzzle.
    root = names[0]
    _rc, rp, _rf = fitted[root]
    back = P[root]["place"][0] - rp[0]
    _bc, bp, bf = fitted["barrel"]
    front = P["barrel"]["place"][0] + (bf(P["barrel"]["muzzle"])[0] - bp[0])
    s = cfg["length"] / (front - back)
    k = s * T
    print("scale %.4f world px per sheet px (%.0f px sheet length)" % (s, front - back))

    results = {}
    for pname in names:
        crop, pivot, f = fitted[pname]
        pc = P[pname]
        base = cfg.get("glow", [])
        if pc.get("glow_boxes"):
            # The part's own glow colours count only inside its boxes.
            res = cut(crop, pivot, k, base)
            lit = cut(crop, pivot, k, pc.get("glow", []) + base)
            mask = np.zeros(res["alpha"].shape, bool)
            for bx0, by0, bx1, by1 in pc["glow_boxes"]:
                a = f((bx0, by0)) * k
                b = f((bx1, by1)) * k
                xa, xb = sorted((int(a[0]), int(b[0])))
                ya, yb = sorted((int(a[1]), int(b[1])))
                mask[max(0, ya):yb, max(0, xa):xb] = True
            res["spec"][mask] = lit["spec"][mask]
            results[pname] = res
        else:
            results[pname] = cut(crop, pivot, k, pc.get("glow", []) + base)
    rects, out_dir = write_atlas(results, name, cfg.get("atlas_width", 256))

    origin = cfg["origin"]
    root_place = P[root]["place"]

    def placed(pname):
        ref = origin if pname == root else root_place
        pl = P[pname]["place"]
        return [round((pl[0] - ref[0]) * s, 2), round((pl[1] - ref[1]) * s, 2)]

    def local(pname, pt):
        _c, pivot, f = fitted[pname]
        q = f(pt)
        return [round((q[0] - pivot[0]) * s, 2), round((q[1] - pivot[1]) * s, 2)]

    def collider(pname):
        a = results[pname]["alpha"] > 0.5
        ys, xs = np.nonzero(a)
        px, py = results[pname]["pivot"]
        x0, x1 = (xs.min() - px) / T, (xs.max() + 1 - px) / T
        y0, y1 = (ys.min() - py) / T, (ys.max() + 1 - py) / T
        cx, cy, hw, hh = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
        r = 0.85 * min(hw, hh)
        if hw >= hh:
            return {"type": "capsule", "a": [round(cx - hw + r, 2), round(cy, 2)],
                    "b": [round(cx + hw - r, 2), round(cy, 2)], "r": round(r, 2)}
        return {"type": "capsule", "a": [round(cx, 2), round(cy - hh + r, 2)],
                "b": [round(cx, 2), round(cy + hh - r, 2)], "r": round(r, 2)}

    data = {
        "name": cfg["rig_name"], "kind": "prop", "texture_scale": T,
        "albedo": "albedo.png", "normal": "normal.png", "spec": "spec.png",
        "ground_lock": False,
        "parts": {n: {"rect": rects[n], "pivot": results[n]["pivot"]} for n in results},
        "joints": [{"name": n, "part": n, "parent": "" if n == root else root, "pos": placed(n),
                    "z": P[n]["z"], "far": False, "collider": collider(n), "mass": P[n]["mass"],
                    "limit": None, "rest_dir": 0, "role": n} for n in names],
        "sockets": {
            "muzzle": {"joint": "barrel", "pos": local("barrel", P["barrel"]["muzzle"])},
            "charge_light": {"joint": "battery", "pos": local("battery", P["battery"]["light"])},
        },
        "source": cfg["sheet"],
    }
    return data, out_dir


def write_preview(data, out_dir, preview_dir, name):
    """The assembled rest pose at atlas resolution, light and dark, for a look."""
    T = data["texture_scale"]
    alb = Image.open(os.path.join(out_dir, "albedo.png")).convert("RGBA")
    J = {j["name"]: j for j in data["joints"]}

    def world(j):
        p = np.array(j["pos"], float)
        while j["parent"]:
            j = J[j["parent"]]
            p += np.array(j["pos"], float)
        return p
    W, H = 160 * T, 140 * T
    origin = np.array([W / 2, H - 20 * T])
    zoom = 1
    if data.get("pixel_art") and data.get("kind") == "prop":
        # a small pixel prop (the Scrapjack): a window around its grip, enlarged with nearest filtering
        W, H = 48 * T, 32 * T
        origin = np.array([12.0 * T, 18.0 * T])
        zoom = 8
    canvas = Image.new("RGBA", (W, H), (40, 46, 56, 255))
    for j in sorted(data["joints"], key=lambda j: j["z"]):
        rx, ry, rw, rh = data["parts"][j["part"]]["rect"]
        px, py = data["parts"][j["part"]]["pivot"]
        img = alb.crop((rx, ry, rx + rw, ry + rh))
        if j["far"]:
            img = Image.fromarray((np.asarray(img, np.float32) * [0.7, 0.7, 0.7, 1]).astype(np.uint8))
        at = origin + world(j) * T - [px, py]
        canvas.alpha_composite(img, (int(round(at[0])), int(round(at[1]))))
    from PIL import ImageDraw
    if zoom > 1:
        canvas = canvas.resize((W * zoom, H * zoom), Image.NEAREST)
    d = ImageDraw.Draw(canvas)
    d.line([(0, origin[1] * zoom), (W * zoom, origin[1] * zoom)], fill=(255, 255, 0, 255))
    for j in data["joints"]:                            # joint pivots
        x, y = (origin + world(j) * T) * zoom
        d.ellipse([x - 3, y - 3, x + 3, y + 3], outline=(255, 60, 60, 255))
    os.makedirs(preview_dir, exist_ok=True)
    out = os.path.join(preview_dir, name + "_assembled.png")
    canvas.save(out)
    print("preview", out)


if __name__ == "__main__":
    main()

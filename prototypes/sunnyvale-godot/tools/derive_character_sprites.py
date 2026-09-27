#!/usr/bin/env python3
"""Derive prototype-scale character cutouts from the approved concept-art
PNGs for M6 (presentation pass).

Reads (read-only, never modified — concept-art/ is off-limits per project
rules):
  ../../concept-art/z01-resident/z01-resident-2d-v1.png
  ../../concept-art/r01-clipper/r01-clipper-2d-v1.png

Writes into assets/characters/ (this project):
  resident_full_1x.png / resident_full_2x.png
      Whole-body Resident cutout, background removed, cropped to the
      silhouette. Used as-is for idle/approach/recovery poses; windup/lunge
      swap to the procedural vector rig in scripts/actors/visuals/
      resident_visual.gd (see that file's header for why: the concept art
      only shows one relaxed-arm pose, and the brief calls for windup's
      raised hands to be "separate pieces or procedural overlays").
  clipper_body_1x.png / clipper_body_2x.png
      Clipper shell/wheels/handle/motor housing cutout, background removed,
      cropped, with the eye-stalk assembly and the shear/hinge assembly
      erased (feathered) so scripts/actors/visuals/clipper_visual.gd can
      draw those two parts as separately animated vector pieces on top (see
      that file's header — style-guide.md is explicit that a concept PNG is
      "not ... a layered source document", so true pixel-accurate part
      extraction from this single flat illustration is not attempted; the
      eye/shear geometry genuinely changes shape across states — retracted
      vs extended stalks, closed vs open shears — which a static cutout
      cannot do on its own).
  clipper_full_1x.png / clipper_full_2x.png
      Reference-only whole-body Clipper cutout (nothing erased) — not wired
      into any scene; kept for comparison/future use.

Background removal: iterative flood fill from the four image borders,
matching the sampled corner color within TOLERANCE (Euclidean RGB
distance), so interior same-colored regions (e.g. the Clipper's ivory
panels) that are NOT reached from the border stay fully opaque. An
additional feather band anti-aliases the cut edge instead of leaving a hard
binary edge.

Deterministic, stdlib + Pillow only (no numpy/scipy available in this
environment). Re-run after editing this file to regenerate byte-identical
output: `python3 tools/derive_character_sprites.py`.
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageFilter

TOOLS_DIR = Path(__file__).resolve().parent
PROJECT_DIR = TOOLS_DIR.parent  # prototypes/sunnyvale-godot
REPO_ROOT = PROJECT_DIR.parent.parent  # project-dave
CONCEPT_DIR = REPO_ROOT / "concept-art"
OUT_DIR = PROJECT_DIR / "assets" / "characters"

RESIDENT_SRC = CONCEPT_DIR / "z01-resident" / "z01-resident-2d-v1.png"
CLIPPER_SRC = CONCEPT_DIR / "r01-clipper" / "r01-clipper-2d-v1.png"

TOLERANCE = 34.0        # background match radius (RGB Euclidean distance)
EDGE_BAND = 46.0        # extra distance band feathered from opaque to transparent
CROP_PAD = 6            # px padding kept around the opaque bbox after crop
ALPHA_BBOX_THRESHOLD = 160  # only reasonably-opaque pixels count for the crop bbox

# AD-02 fix: a pure per-pixel color-distance flood from the border leaks
# through thin near-background-colored seams (a highlight streak on the
# Resident's jacket bridges straight into the near-background-toned shirt)
# and, for the Clipper, several ivory/cream design panels sit close enough
# to the cream backdrop color that they are only saved from the same leak by
# being explicitly protected below. OPEN_RADIUS runs a morphological "open"
# (erode then dilate by the same radius) on the background candidate mask
# BEFORE flood-filling from the border, which snaps shut any seam thinner
# than 2*OPEN_RADIUS+1 px while leaving genuinely wide background regions
# (the door-handle loop, the gaps between limbs) untouched — verified by eye
# against a blue test backdrop at prototypes/sunnyvale-godot/tools (see the
# M6 art session notes) before landing this value.
OPEN_RADIUS = 2

# Clipper source-image regions (same coordinate space as CLIPPER_EYE_BOX/
# CLIPPER_SHEAR_BOX below) that are cream/ivory-painted body panels close
# enough in color to the cream backdrop that OPEN_RADIUS alone still isn't
# enough to stop the border flood from reaching them through the wide-open
# shear-arm linkage gap: forced to stay opaque regardless of color distance.
# Picked by eye against a printed coordinate grid overlay, same method as
# the eye/shear boxes.
CLIPPER_PROTECT_BOXES = [
    (685, 515, 925, 615),    # front ivory accent band
    (650, 615, 900, 845),    # front wheel's ivory hub disc
    (690, 320, 990, 435),    # eye-stalk mount's ivory panel
    (1145, 365, 1295, 620),  # rear motor housing's ivory guard
]

# Both source images bake in a soft cast shadow under the feet/wheels that
# survives color-distance background removal (it's a shaded, not flat-color,
# blend). Cropped out (feathered) the same way erase_region cuts the
# Clipper's eye/shear regions, in source-image pixel space.
RESIDENT_SHADOW_BOX = (350, 925, 1090, 1030)
CLIPPER_SHADOW_BOX = (130, 830, 1410, 915)

# Resident.HEIGHT (resident.gd) is the 48x84 collision box; the previous
# blockout's own drawn silhouette (legs+torso+head) came out to ~86px tall
# at that scale. Target within CONVENTIONS' "~10% of current hit zones".
RESIDENT_TARGET_H = 92
# Clipper shell/wheels/handle: the previous blockout's drawn silhouette
# (body + extended eye stalks) came out to ~74px tall against the 64x48
# collision box. Target close to that, allowing a little extra for the
# now-visible integrated handle the blockout never drew.
CLIPPER_TARGET_H = 80

# --- Clipper part regions, in ORIGINAL z01/r01 source-image pixel space ----
# Picked by eye against a printed coordinate grid overlay (see the M6 art
# session notes) against r01-clipper-2d-v1.png (1448x1086). Erased from the
# body cutout and re-drawn as animated vector overlays in clipper_visual.gd.
CLIPPER_EYE_BOX = (598, 203, 802, 352)   # both eye stalks + lenses only
# Just the blade paddle, stopping short of the fixed hinge bracket/drive
# rods (those stay baked into the body — mechanically the hinge is fixed
# and only the blades themselves pivot, which also avoids a seam against a
# baked hinge that would otherwise never move with the vector overlay).
CLIPPER_SHEAR_BOX = (5, 632, 478, 720)


def _dist2(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    return (a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2


def remove_background(im: Image.Image, tolerance: float = TOLERANCE,
                       edge_band: float = EDGE_BAND, open_radius: int = OPEN_RADIUS,
                       protect_boxes: tuple[tuple[int, int, int, int], ...] = ()) -> Image.Image:
    """Flood fill from the border to cut the flat background, with a
    feathered edge. Interior same-colored regions never reached from the
    border (e.g. the Clipper's ivory panels) are meant to be left fully
    opaque, but a raw per-pixel color-distance test alone can still leak
    through a thin near-background-colored seam (AD-02: this let the flood
    walk straight through a highlight streak into the Resident's shirt).
    Two independent guards close that gap without touching any pixel that
    isn't background:
      - `open_radius` runs a morphological open (erode then dilate by the
        same radius) on the raw color-distance mask before flooding, which
        snaps shut any seam thinner than 2*open_radius+1 px while leaving
        wide legitimate background regions (the Clipper's door-handle loop,
        gaps between limbs) untouched.
      - `protect_boxes` (source-image pixel space) are forced opaque
        regardless of color distance, for panels close enough to the
        backdrop color that a WIDE opening (not just a thin seam) connects
        them to the border (the Clipper's ivory accents, via the open
        shear-arm linkage) — the same hand-picked-box technique already
        used below for the eye/shear erasure regions.
    """
    im = im.convert("RGB")
    w, h = im.size
    px = im.load()
    bg = px[0, 0]
    tol2 = tolerance * tolerance
    edge2 = (tolerance + edge_band) * (tolerance + edge_band)

    candidate = Image.new("L", (w, h), 0)
    cpx = candidate.load()
    for y in range(h):
        for x in range(w):
            if _dist2(px[x, y], bg) <= tol2:
                cpx[x, y] = 255
    for (bx0, by0, bx1, by1) in protect_boxes:
        for y in range(max(0, by0), min(h, by1)):
            for x in range(max(0, bx0), min(w, bx1)):
                cpx[x, y] = 0

    if open_radius > 0:
        k = open_radius * 2 + 1
        candidate = candidate.filter(ImageFilter.MinFilter(k)).filter(ImageFilter.MaxFilter(k))
    opened = candidate.load()

    is_bg = bytearray(w * h)
    visited = bytearray(w * h)
    stack: list[tuple[int, int]] = []
    for x in range(w):
        stack.append((x, 0))
        stack.append((x, h - 1))
    for y in range(h):
        stack.append((0, y))
        stack.append((w - 1, y))

    while stack:
        x, y = stack.pop()
        idx = y * w + x
        if visited[idx]:
            continue
        visited[idx] = 1
        if opened[x, y] == 0:
            continue
        is_bg[idx] = 1
        if x > 0:
            stack.append((x - 1, y))
        if x < w - 1:
            stack.append((x + 1, y))
        if y > 0:
            stack.append((x, y - 1))
        if y < h - 1:
            stack.append((x, y + 1))

    out = Image.new("RGBA", (w, h))
    opx = out.load()
    for y in range(h):
        row_base = y * w
        for x in range(w):
            idx = row_base + x
            r, g, b = px[x, y]
            if is_bg[idx]:
                opx[x, y] = (r, g, b, 0)
                continue
            d2 = _dist2((r, g, b), bg)
            if d2 < edge2:
                t = (d2 - tol2) / (edge2 - tol2)
                a = max(0, min(255, int(round(255 * t))))
            else:
                a = 255
            opx[x, y] = (r, g, b, a)
    return out


def erase_region(im: Image.Image, box: tuple[int, int, int, int],
                  feather: int = 10) -> Image.Image:
    """Zero the alpha inside `box` (image-space, matching remove_background's
    coordinate space), feathered inward from the box edge so the cut doesn't
    leave a hard rectangular seam against the surrounding body art."""
    im = im.copy()
    px = im.load()
    x0, y0, x1, y1 = box
    for y in range(max(0, y0 - feather), min(im.height, y1 + feather)):
        for x in range(max(0, x0 - feather), min(im.width, x1 + feather)):
            r, g, b, a = px[x, y]
            if x0 <= x < x1 and y0 <= y < y1:
                # Fully inside: distance to nearest edge drives a short feather
                # so pixels deep inside the box are fully erased while the
                # rim blends.
                dx = min(x - x0, x1 - x) if feather else feather
                dy = min(y - y0, y1 - y) if feather else feather
                d = min(dx, dy)
                if d >= feather:
                    na = 0
                else:
                    na = int(a * (d / float(feather)))
            else:
                # Just outside: fade the erasure out over `feather` px.
                dx = max(x0 - x, x - x1, 0)
                dy = max(y0 - y, y - y1, 0)
                d = max(dx, dy)
                if d >= feather:
                    continue
                na = int(a * (d / float(feather)))
            px[x, y] = (r, g, b, min(a, na))
    return im


def alpha_bbox(im: Image.Image, threshold: int = ALPHA_BBOX_THRESHOLD) -> tuple[int, int, int, int]:
    alpha = im.split()[-1]
    mask = alpha.point(lambda a: 255 if a >= threshold else 0)
    bbox = mask.getbbox()
    if bbox is None:
        raise SystemExit("alpha_bbox: image is fully transparent — tolerance too aggressive?")
    return bbox


def crop_with_pad(im: Image.Image, bbox: tuple[int, int, int, int], pad: int = CROP_PAD) -> Image.Image:
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - pad)
    y0 = max(0, y0 - pad)
    x1 = min(im.width, x1 + pad)
    y1 = min(im.height, y1 + pad)
    return im.crop((x0, y0, x1, y1))


def save_scaled(im: Image.Image, out_path: Path, target_h: int, label: str) -> None:
    scale = target_h / im.height
    size_1x = (max(1, round(im.width * scale)), target_h)
    im_1x = im.resize(size_1x, Image.LANCZOS)
    im_2x = im.resize((size_1x[0] * 2, size_1x[1] * 2), Image.LANCZOS)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    p1 = out_path.with_name(out_path.name.replace("__SCALE__", "1x"))
    p2 = out_path.with_name(out_path.name.replace("__SCALE__", "2x"))
    im_1x.save(p1)
    im_2x.save(p2)
    print(f"{label}: source {im.size} -> {p1.name} {size_1x}, {p2.name} {(size_1x[0]*2, size_1x[1]*2)}")


def process_resident() -> None:
    src = Image.open(RESIDENT_SRC)
    cut = remove_background(src)
    # AD-02: the concept art bakes in a soft cast shadow under the feet that
    # survives color-distance background removal (it's a shaded blend, not a
    # flat color) — crop it out the same way the Clipper's eye/shear regions
    # are erased below, before the bbox/crop so the shadow doesn't widen it.
    cut = erase_region(cut, RESIDENT_SHADOW_BOX, feather=14)
    bbox = alpha_bbox(cut)
    cropped = crop_with_pad(cut, bbox)
    print(f"resident bbox in source px: {bbox}, cropped size {cropped.size}")
    save_scaled(cropped, OUT_DIR / "resident_full___SCALE__.png", RESIDENT_TARGET_H, "resident_full")


def process_clipper() -> None:
    src = Image.open(CLIPPER_SRC)
    cut = remove_background(src, protect_boxes=tuple(CLIPPER_PROTECT_BOXES))
    cut = erase_region(cut, CLIPPER_SHADOW_BOX, feather=14)
    bbox = alpha_bbox(cut)
    cropped_full = crop_with_pad(cut, bbox)
    print(f"clipper bbox in source px: {bbox}, cropped size {cropped_full.size}")
    save_scaled(cropped_full, OUT_DIR / "clipper_full___SCALE__.png", CLIPPER_TARGET_H, "clipper_full (reference only)")

    body = erase_region(cut, CLIPPER_EYE_BOX)
    body = erase_region(body, CLIPPER_SHEAR_BOX)
    # Crop the body variant to the SAME bbox as the full cutout (not
    # recomputed) so its canvas stays pixel-aligned with clipper_full and
    # with the source-space anchor points clipper_visual.gd uses to place
    # the eye/shear overlays.
    cropped_body = crop_with_pad(body, bbox)
    save_scaled(cropped_body, OUT_DIR / "clipper_body___SCALE__.png", CLIPPER_TARGET_H, "clipper_body")

    scale = CLIPPER_TARGET_H / cropped_body.height
    ox0, oy0 = bbox[0] - CROP_PAD, bbox[1] - CROP_PAD
    def to_local_1x(pt: tuple[float, float]) -> tuple[float, float]:
        return ((pt[0] - ox0) * scale, (pt[1] - oy0) * scale)

    eye_base_src = ((CLIPPER_EYE_BOX[0] + CLIPPER_EYE_BOX[2]) / 2.0, CLIPPER_EYE_BOX[3])
    # The real pivot bolt sits just outside (to the right of) the erased
    # blade box, at approximately this source-space point.
    shear_hinge_src = (478.0, 675.0)
    print("clipper_body 1x canvas size:", (round(cropped_body.width * scale), round(cropped_body.height * scale)))
    print("eye_base anchor (1x local px, origin = body sprite top-left):", to_local_1x(eye_base_src))
    print("shear_hinge anchor (1x local px, origin = body sprite top-left):", to_local_1x(shear_hinge_src))


def main() -> int:
    if not RESIDENT_SRC.exists() or not CLIPPER_SRC.exists():
        print("Missing concept-art source PNG(s); nothing derived.", file=sys.stderr)
        return 1
    process_resident()
    process_clipper()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

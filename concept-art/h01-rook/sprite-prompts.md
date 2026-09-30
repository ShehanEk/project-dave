# Rook (H01) — 2D gameplay sprite prompts

> **Record (C35):** this is the generation record of the placeholder Rook sprite pack in [sprites-v1](sprites-v1/), which now stands in for Dave Harlan. It describes the old hero Rook and the pre-revamp look (cel shadows, stylized proportions) and is kept for history. New character art follows the lit cutout pipeline in the [style guide](../../art-design/style-guide.md) (C35): flat, evenly lit paintings with a normal map for each part or frame.

**Visual direction when the pack was made (C11):** [Hand-drawn 2D](../../art-design/style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../README.md).

**Status:** Generation record. These produced the in-game hero art in [sprites-v1](sprites-v1/) that replaced the prototype's code-drawn figure. Dave's current look is the proposed [H01 hero brief](../../design/02-characters/hero.md).

## How the game uses the sprite

The prototype's hero is a small rig (`prototypes/sunnyvale-godot/scripts/actors/visuals/hero_visual.gd`): a **body** (head, torso, legs, back arm) plus a separate **gun arm** that rotates 360° with mouse aim and holds the separately drawn Scrapjack Pistol. So the body sprites leave out the near (gun) arm, and that arm is its own piece. The pistol is never part of the character art.

Output rules for every prompt below: side view facing **right**; one character; **transparent background** (if your tool can't do transparency, use a flat pure-white background with no shadow); square canvas; character about 85% of the canvas height; feet on the same baseline near the bottom edge in every image. Generate **one pose per request** and attach the approved base sprite each time — multi-pose sheets drift in anatomy and scale (style guide, "Sprite and animation references").

## 1. Base sprite (do this first)

If you have already approved a Rook identity image from [generation-prompt.md](generation-prompt.md), attach it as the identity reference.

```text
If a Rook image is attached, use it as the IDENTITY reference. Style: confident dark olive or warm charcoal outlines, heavier outer contour, restrained interior lines, broad flat local colors, one or two crisp cel-shadow shapes, sparse graphic highlights.
Draw a finished hand-drawn 2D game sprite of the hero Dave Harlan for a side-scrolling platformer shooter: adult practical scavenger, compact build, about five-and-a-half heads tall, strong hands, broad practical boots. Warm brown skin, cropped dark hair with one uneven forelock, expressive brows, small healed mark through one eyebrow, quietly resourceful expression. Rust-orange short work jacket over a dark teal shirt, short cream neck cloth, cream reinforced trousers with charcoal knee patches, broad scuffed brown boots, one small belt pouch.
Strict side view facing right, neutral standing pose, weight even, feet flat on one baseline, relaxed back arm hanging, near arm hanging straight down at the side with the hand empty and slightly open. Full body, fully visible, nothing cropped.
Transparent background, no ground, no contact shadow, no weapon, no holster, no text, UI, effects or watermark. No realistic surface shading, gradients, glow or photographic blur. Square canvas, character about 85% of the canvas height, centered.
```

Save the chosen result as `h01-rook-sprite-base.png` in this folder.

## 2. Rig parts: body without the gun arm + separate gun arm

Attach `h01-rook-sprite-base.png`.

```text
Use the attached sprite as the exact identity and style reference for DEAD EDEN's hero Rook: same face, proportions, palette, outfit, line weight and cel shadows. Draw a cutout-animation parts sheet on a transparent background, all parts at exactly the same scale as the reference, clearly separated with empty space between them, no overlaps:
1) the full body in the same strict right-facing side pose WITHOUT the near (viewer-side) arm — show only a clean rounded jacket shoulder where that arm attaches; keep the back arm hanging relaxed.
2) the near arm as ONE separate piece: jacket sleeve upper arm and forearm extended straight forward, horizontal, with the hand closed in a one-handed pistol grip (index finger along the side, empty — no gun), shoulder end rounded so it can rotate at the shoulder.
No weapon, no text, labels, UI or shadow.
```

Save as `h01-rook-sprite-parts.png`.

## 3. Animation poses (one request each)

Attach `h01-rook-sprite-parts.png` (or the base sprite). Paste this template and replace `{POSE}` with one line from the list.

```text
Use the attached sprite as the exact identity and style reference for DEAD EDEN's hero Rook: same face, proportions, palette, outfit, line weight and cel shadows. Draw ONE full-body pose, strict side view facing right, WITHOUT the near (viewer-side) arm (only the rounded jacket shoulder where it attaches), back arm moving naturally with the pose. Pose: {POSE}. Same scale as the reference, feet (or the lowest point of the body) placed consistently for a side-scrolling game sprite, transparent background, no ground, no shadow, no weapon, no motion lines, text or effects.
```

| Save as | `{POSE}` |
| --- | --- |
| `rook-idle-1.png` | relaxed ready stance, weight even, slight knee bend |
| `rook-idle-2.png` | same stance mid-breath: chest a touch higher, shoulders slightly lifted |
| `rook-run-1.png` … `rook-run-6.png` | running cycle frame N of 6: (1) contact, front heel down; (2) down, weight over bent front leg; (3) passing, back leg swinging through; (4) up, pushing off the front toe; (5) flight, both feet off the ground; (6) reach, front leg extending for the next contact |
| `rook-jump-rise.png` | rising jump, knees tucked up, body leaning slightly forward |
| `rook-jump-fall.png` | falling, legs extending down toward the ground, back arm raised for balance |
| `rook-land.png` | landing squash: knees deeply bent, body low, feet flat |
| `rook-hurt.png` | hit recoil: torso bent back away from the facing direction, grimace, one foot lifting |
| `rook-defeated.png` | collapsed kneeling on one knee, head down, exhausted (no injury detail) |
| `rook-interact.png` | leaning slightly forward, back hand reaching out at chest height to press a panel |

## After generation

Drop the files in this folder and tell Claude Code. The next step cuts them out, scales them to the game's 96 px hero height, aligns feet and shoulder pivots, and swaps them in for the code-drawn hero without changing collision or movement.

The game mirrors right-facing art for left-facing movement. That mirrors Rook's forelock and eyebrow mark too; the style guide prefers separate left-facing drawings for asymmetric details, so treat mirroring as a prototype shortcut.

[Identity prompt](generation-prompt.md) · [Hero brief](../../design/02-characters/hero.md) · [Scrapjack Pistol brief](../../art-design/weapons/w01-scrapjack-pistol.md) · [Shared 2D guide](../../art-design/style-guide.md)

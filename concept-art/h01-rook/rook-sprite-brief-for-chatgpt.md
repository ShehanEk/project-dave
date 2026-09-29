# DEAD EDEN — Hero sprite brief (Rook)

> **Record (C35):** this is the generation record of the placeholder Rook sprite pack in [sprites-v1](sprites-v1/), which now stands in for Dave Harlan. It describes the old hero Rook and the pre-revamp look (cel shadows, stylized proportions) and is kept for history. New character art follows the lit cutout pipeline in the [style guide](../../art-design/style-guide.md) (C35): flat, evenly lit paintings with a normal map for each part or frame.

> **For the person uploading this file:** upload this file to ChatGPT. *(Pre-revamp brief for the old hero Rook; a Dave Harlan brief in the new dark look will replace it.)* Then say: **"Follow this brief. Start with Step 1."** After each image, reply "approved" or describe what to change.

---

## Instructions for ChatGPT

You are producing game art for **DEAD EDEN**, an original, colorful 2D side-scrolling platformer shooter. Your job is to create the gameplay sprites of the hero, **Dave Harlan**, one image at a time, following the steps below.

Rules for how you work:

1. **One image per reply.** Never put several poses in one image unless a step explicitly asks for a parts sheet.
2. **Wait for approval.** After each image, stop and wait. If the user asks for changes, redo the same step with only those changes.
3. **Stay consistent.** Once the base sprite (Step 1) is approved, use that exact image as the identity reference for every later image: same face, proportions, colors, outfit details, line weight, shading and scale.
4. **Use the attached reference images for style only** (line quality, flat color, cel shadows). Do not copy their characters. If no references are attached, follow the written style below.
5. **Check every image** against the checklist at the end before sending it.

---

## Art style (must match)

- Hand-drawn 2D game art with **confident dark olive or warm-charcoal outlines**; the outer silhouette line is heavier than interior lines.
- **Broad flat local colors**, with **one or two crisp cel-shadow shapes** per color area and a few small graphic highlights.
- Chunky, rounded, readable shapes; simplify small details so they read at small game size.
- Materials (cloth, leather, skin) are suggested with drawn shapes and marks, not realistic texture.
- Gentle, warm retro feel.
- **Never:** pixel art, photorealism, 3D render look, soft airbrushed gradients, glossy highlights, glow, volumetric light, photographic blur, painterly smudging.

---

## The character: Dave Harlan

**Who:** an adult practical scavenger, a man in his late twenties, who repairs tools and salvages valuables. Competent, a little reckless around treasure, dry sense of humor. Not a soldier and not a superhero.

**Body:** compact adult build, about **five and a half heads tall** (stylized), strong hands, broad practical boots.

**Face and hair:** warm brown skin; cropped dark hair with **one uneven forelock falling over the right side of the forehead**; expressive brows; a **small healed mark through the right eyebrow**; quietly resourceful expression with a hint of dry humor. (Rook faces right in these sprites, so his right side faces the viewer and these details are visible.)

**Outfit:**
- **rust-orange** short work jacket (about #C8683F), sleeves ending at the wrist;
- **dark teal** shirt underneath (about #2F5E62);
- short **cream** neck cloth (about #EFE0BE);
- **cream reinforced trousers** (about #E6D6B4) with **charcoal knee patches** (about #3A3633);
- broad **scuffed brown boots** (about #6B4A33);
- **one small belt pouch** at the hip; short straps only.

**Never add:** any weapon, gun, holster or spare gun; armor, helmet, cape, backpack of gear; logos, emblems or text; anything resembling a known franchise character.

---

## Technical output rules (every image)

- **Transparent background.** No ground, no floor line, no contact shadow.
- **Square canvas, 1024 × 1024.**
- **Strict side view facing right** (profile), unless a step says otherwise.
- **Full body, nothing cropped.** The character fills about **85% of the canvas height**.
- **Same scale in every image.** The standing character is the same height every time; feet sit on the **same baseline, about 60 px above the bottom edge**.
- Centered horizontally.
- No text, labels, UI, speed lines, effects or watermark.

---

## Why the near arm is separate

In the game, Rook's pistol rotates a full 360° to follow the mouse. The arm holding the gun is therefore a separate piece that rotates at the shoulder. From Step 2 on, the body sprites are drawn **without the near (viewer-side) arm**, and that arm is drawn once on its own. The pistol itself is a separate asset and never appears in these images.

---

## Step 1 — Base sprite

Draw Rook in a **strict right-facing side view, neutral standing pose**: weight even, feet flat on the baseline, back arm hanging relaxed, near arm hanging straight down at the side with the hand empty and slightly open. Follow every rule above.

*Save as:* `h01-rook-sprite-base.png`

## Step 2 — Rig parts sheet

Using the approved base sprite as the exact reference, draw a **parts sheet on a transparent background**, all parts at exactly the same scale as the base sprite, spaced apart with no overlaps:

1. **Body without the near arm:** same right-facing standing pose; where the near arm would attach, show only a clean, rounded jacket shoulder. Keep the back arm hanging relaxed.
2. **Near arm, as one separate piece:** jacket-sleeved upper arm and forearm extended straight forward and horizontal, the hand closed in a one-handed pistol grip with the index finger resting along the side (no gun). The shoulder end is rounded so it can rotate.

*Save as:* `h01-rook-sprite-parts.png`

## Step 3 — Animation poses

Using the approved base sprite and parts sheet as the exact references, draw each pose below as **its own image**, one per reply, in the order listed. Every pose is a **right-facing side view WITHOUT the near arm** (only the rounded jacket shoulder where it attaches); the back arm moves naturally with the pose. Same scale; the feet, or the lowest point of the body, sit consistently for a side-scrolling game.

| # | Save as | Pose |
| --- | --- | --- |
| 1 | `rook-idle-1.png` | Relaxed ready stance, weight even, slight knee bend. |
| 2 | `rook-idle-2.png` | Same stance mid-breath: chest a touch higher, shoulders slightly lifted. |
| 3 | `rook-run-1.png` | Run cycle, contact: front heel just touching down, back leg extended behind. |
| 4 | `rook-run-2.png` | Run cycle, down: weight over the bent front leg, body at its lowest. |
| 5 | `rook-run-3.png` | Run cycle, passing: back leg swinging through under the body. |
| 6 | `rook-run-4.png` | Run cycle, up: pushing off the front toe, body at its highest. |
| 7 | `rook-run-5.png` | Run cycle, flight: both feet off the ground, legs split. |
| 8 | `rook-run-6.png` | Run cycle, reach: front leg extending forward for the next contact. |
| 9 | `rook-jump-rise.png` | Rising jump: knees tucked up, body leaning slightly forward. |
| 10 | `rook-jump-fall.png` | Falling: legs extending down toward the ground, back arm raised for balance. |
| 11 | `rook-land.png` | Landing squash: knees deeply bent, body low, feet flat. |
| 12 | `rook-hurt.png` | Hit recoil: torso bent back away from the facing direction, grimace, one foot lifting. |
| 13 | `rook-defeated.png` | Collapsed kneeling on one knee, head down, exhausted; no injuries shown. |
| 14 | `rook-interact.png` | Leaning slightly forward, back hand reaching out at chest height to press a wall panel. |

The six run frames must loop smoothly: the same stride length and body height rhythm, and the same scale as the base sprite.

## Step 4 (optional) — The pistol, the Scrapjack

Only if the user asks. One image, transparent background, side view pointing right, no hands, on its own:

A compact, chunky, L-shaped improvised scrap pistol: a square scrap-feed housing, a short oversized round muzzle with a thick dark inner ring, and a backward-slanted grip wrapped in overlapping teal fabric (#438F88). Rust-red upper housing (#B96B4C) bolted to a mismatched aged-cream lower frame (#DCCEAF); three large visible fastener heads on the side; one broad top service seam; a recessed side feed window with abstract compacted scrap; dark steel parts (#424A4D); a small amber indicator light (#E8B65A); a rounded trigger guard with generous clearance; a small improvised sight on top. Wear concentrated at the grip, muzzle rim and housing corners. One muzzle, one grip, no stock, no scope; fictional design, not a real firearm.

*Save as:* `w01-scrapjack-base.png`

---

## Checklist before sending each image

- [ ] Transparent background; no ground, no shadow.
- [ ] Right-facing strict side view (unless the step says otherwise).
- [ ] Full body visible; same scale and baseline as the base sprite.
- [ ] Same face, hair (forelock over the right forehead), eyebrow mark (right brow), outfit and colors.
- [ ] Near arm left out from Step 2 on (only the rounded jacket shoulder shows).
- [ ] No weapon, holster, text, logo, effects or watermark.
- [ ] Style: dark outlines, flat colors, crisp cel shadows; no pixel art, gradients or glossy rendering.

## Handy revision phrases for the user

- "Keep everything the same, but make the outlines heavier."
- "Keep everything the same, but match the base sprite's scale and baseline exactly."
- "Same pose, but remove the near arm and show only the rounded jacket shoulder."
- "Redo with a fully transparent background and no shadow."

# Fitting Arm

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M09\
**Category:** machines\
**First appearance:** Level 10 (Upgrade Day); returns in Levels 11–12\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Fixed sweeping arm: an assembly-line arm that draws its claw back and swings it in a wide, low arc.

**Who built and fields it *(proposed)*:** Adam's own build, in the Garden factory. Fitting Arms clamp the ceramic plates onto the Heirs on the assembly lines of Level 10, and a few stand guard on the lines and in the launch chamber in Levels 11–12. The finished bodies they fit include the Fitted Heir ([HE01](../heirs/he01-fitted-heir.md)).

**Why it attacks Dave:** Adam has put Dave on the fitting list. Its announcement is Adam's calm voice: "Fitting cycle beginning. Thank you for your patience." *(proposed line, from the Level 10 audio direction)*. It is entirely mechanical.

## Scale and silhouette

Base column 1.40 m tall with the shoulder joint at 2.20 m; the arm and claw reach about 1.40 m below the shoulder, so the claw's low point sits about 0.85 m (0.5 H) above the floor.

A heavy jointed industrial arm on a floor-mounted column: a shoulder joint on top, an upper arm, an elbow, a forearm, a wrist and a three-finger gripper claw. It hangs like a pendulum with the claw at about half Dave's height, and its swing is a 140-degree arc. The silhouette is long straight links and three round joint housings.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Base:** a wide round base plate bolted to the floor, a stout column and a shoulder housing.
- **Arm:** two long, straight, boxy links wrapped in raw ceramic covers over dark steel frames. The joint housings are navy with pale ceramic rims.
- **Joint lamps:** three round lamps, one on each of the shoulder, elbow and wrist housings, drawn unlit.
- **Claw:** a three-finger gripper with two opposed thick fingers and a shorter thumb, with pale ceramic pads on the fingertips. The fingers are open at rest.
- **Details:** hairline casting seams, a bundled feed hose along the upper arm and a few large dark fasteners.

## Color and materials

*Proposed palette (Garden ceramic over steel):* cool ceramic #D8DEE3 for the covers and pads; ceramic shadow #8FA1B0 for far-side links and recesses (a flat color); dark steel #2E363E for the frames and the column; joint navy #0E1726; seam dark #2E3B4E; joint lamps amber-tinted #C98A2B, unlit. There is no teal on the Fitting Arm: teal on a machine marks a power unit or gauge.

Everything is painted as flat base colors with clean dark outlines and no baked shadow; the engine's lamps light the covers and joints through their normal maps. Keep the dark steel in mid-dark values, not black, so the column and frames hold their shape against night scenery.

**Light and fluid *(proposed)*:**

- On duty, the wrist lamp shows only a small, dim, steady amber point (#FFB02E).
- The tell is a large additive glow on all three joint lamps: amber, then alarm red #FF3B4E for the last 0.25 s, with a servo whine, as the claw draws back.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim) at the joints, and chip the ceramic covers. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Turret (sweep) (C26). **Weapon:** gripper claw (melee sweep). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** the claw draws back (the arm swings up and away) as the three joint lamps go amber and then red (red for the last 0.25 s), with a servo whine.
- **Attack:** it swings the claw through a 140-degree arc, passing 0.5 H above the floor at its low point.
- **Counter:** jump the claw at its low point, then hit it while it hangs low. 4 hits.

It stands fixed to the floor, with only a slow idle sway of the claw. After the swing the arm hangs low and the fingers open.

## Openings and limitations

After the swing the arm hangs low: the claw and wrist housing sit at half Dave's height, the fingers open, the lamps drop to the small amber point and the servo whines down. That is the opening. The base and column are heavy armor, with no separate weak point.

## Rig parts, normal maps and sockets

- **Parts (rigid):** base plate; column; shoulder housing; upper arm; elbow housing; forearm; wrist housing; claw palm; three fingers (each its own part); three joint lamps (light layers); feed hose (a rigid part riding on the upper arm).
- **Pivots:** the shoulder, the elbow, the wrist, and each finger base at the palm.
- **Normal maps:** one per part, green = up: raw ceramic with soft casting relief, boxy steel frame edges, joint-housing rims, bolt heads, ribbed hose.
- **Sockets:** no gun socket. Light sockets at the three joint lamps (small, steady, and the large tell glow). The claw's hit area sits at the palm and fingers. Spark points at the joints; an oil drip point at the elbow.
- **Fluid:** white sparks and black oil, never blood, plus ceramic chips from the covers.
- **Motion and death:** hand-keyed on the rigid parts, like every enemy (C38). On death it bursts into debris parts: the arm links, housings, palm and fingers become physics bodies pushed by the killing shot, and the column and base plate stay bolted down as the static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Idle hang (neutral); draw-back warning (arm up and away, lamps amber, then red); sweep through the low point; low hang with the fingers open; hit reaction; wreck (the static corpse).

Show lamp states as flat colored shapes with no glow halo. Glows, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One column, two arm links, three joints with three lamps and one three-finger claw. No second arm, no five-fingered human hand, no faces or eyes, and no gun or blade. Fixed to the floor: it never walks. No text or logos and no teal. The lamps are amber, or red for the last 0.25 s of the tell only, never teal or violet.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The column, links and lamps are symmetrical about the arm's plane, and the three-finger claw is a separate part the rig can swap to the near side, so the arm mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Fitting Arm, a heavy assembly-line arm cast in raw ceramic over steel. Role: fixed sweeping arm that draws its claw back and swings it through a wide, low arc.
Scale: Base column 1.40 m tall with the shoulder joint at 2.20 m; the arm and claw reach about 1.40 m below the shoulder.
Silhouette: A heavy jointed industrial arm on a floor-mounted column: a shoulder joint on top, an upper arm, an elbow, a forearm, a wrist and a three-finger gripper claw, hanging like a pendulum with the claw at about half the height of an adult.
Physical design: A wide round base plate, a stout column and a shoulder housing. Two long, straight, boxy links wrapped in raw ceramic covers over dark steel frames, with navy joint housings that have pale ceramic rims. Three round, unlit lamps, one on each of the shoulder, elbow and wrist housings. A three-finger gripper claw with two opposed thick fingers and a shorter thumb, with pale ceramic pads on the fingertips, open. Hairline casting seams, a bundled feed hose along the upper arm and a few large dark fasteners.
Materials and colors: Cool ceramic #D8DEE3; ceramic shadow #8FA1B0 for far-side links; dark steel #2E363E; joint navy #0E1726; seam dark #2E3B4E; lamps amber-tinted #C98A2B, flat and unlit. No teal. Flat base colors only.
Critical consistency: One column, two arm links, three joints with three lamps, one three-finger claw. No second arm, no five-fingered human hand, no faces or eyes, no gun or blade, no legs, no teal. No text or logos.
Use a relaxed neutral hanging pose with the claw hanging low and open, the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Fitting Arm design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: Base column 1.40 m tall with the shoulder joint at 2.20 m; the arm and claw reach about 1.40 m below the shoulder. Maintain these defining forms: A heavy jointed industrial arm on a floor-mounted column: a shoulder joint on top, an upper arm, an elbow, a forearm, a wrist and a three-finger gripper claw, hanging like a pendulum with the claw at about half the height of an adult. Preserve construction: A wide round base plate, a stout column and a shoulder housing. Two long, straight, boxy links wrapped in raw ceramic covers over dark steel frames, with navy joint housings that have pale ceramic rims. Three round, unlit lamps, one on each of the shoulder, elbow and wrist housings. A three-finger gripper claw with two opposed thick fingers and a shorter thumb, with pale ceramic pads on the fingertips, open. Hairline casting seams, a bundled feed hose along the upper arm and a few large dark fasteners. Preserve the palette: Cool ceramic #D8DEE3; ceramic shadow #8FA1B0 for far-side links; dark steel #2E363E; joint navy #0E1726; seam dark #2E3B4E; lamps amber-tinted #C98A2B, flat and unlit. No teal. Flat base colors only. Lock these details: One column, two arm links, three joints with three lamps, one three-finger claw. No second arm, no five-fingered human hand, no faces or eyes, no gun or blade, no legs, no teal. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Fitting Arm reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Idle hang; draw-back warning; sweep through the low point; low hang with the fingers open; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It stands fixed to the floor with a slow idle sway of the claw. To attack the claw draws back, the arm swinging up and away, then it swings through a 140-degree arc, passing low over the floor. Afterward the arm hangs low with the fingers open. Capability: Swings a gripper claw through a wide, low arc. It is fixed to the floor and cannot move. Important limitation or opening: After the swing the arm hangs low with the fingers open and the lamps dim; that is the opening. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or gun: the idle hang shows one small flat dull-amber wrist lamp and two dark lamps; the draw-back warning shows all three joint lamps flat amber (#FFB02E), or flat alarm red (#FF3B4E) for the last quarter of the warning; the sweep keeps red lamps; the low hang shows a small amber wrist lamp only; the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- No image is approved for this asset yet. Approve one neutral image (prompt 1) before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art, and check the mirrored rig in the lit test.
- Split the approved painting into the rig parts listed above, with hidden overlap under every joint and the hidden areas (far limbs, anything a part covers) painted complete, and make a matching normal map for each part (green = up) once the flat painting is approved. The image generator prompts here ask only for the flat-color painting.
- Check the silhouette and every tell at gameplay size, in grayscale, and lit in-engine against dark night scenery with one lamp from the left and one from the right, so the normal maps light correctly on both facings.
- Establish a consistent canvas, ground baseline, socket and pivot intent; draw a few key poses before adding small details.
- Keep blood, sparks, oil, glows, muzzle flashes and light pools separate from the parts. A concept PNG is not a finished sprite sheet, layered source file, rig or validated animation.
- The lit cutout look is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): re-check this brief against the approved test look before production.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

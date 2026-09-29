# Pruner

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M08\
**Category:** machines\
**First appearance:** Level 10 (Upgrade Day); returns in Levels 11–12\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

High-mounted beam turret: a ceramic bud that opens its petals, tracks Dave with a thin sight line, freezes, then drags a white-hot beam after him.

**Who built and fields it *(proposed)*:** Adam's own build, cast in the Garden. Where the Sentry Turret ([M03](m03-sentry-turret.md)) is an Arcadia product, the Pruner has no Arcadia design: Adam grows it into its own gantries and "prunes" with it. It hangs from the high gantries and ceilings of the assembly halls and the launch chamber in Levels 10–12, and is mounted high only. The name is Adam's. Its lens unit is the Cutter Beam ([EG09](../enemy-guns/eg09-cutter-beam.md)).

**Why it attacks Dave:** Adam sorts what belongs in the Garden from what must be cut back, and it has filed Dave under "cut back". It speaks no line: the petals opening and a sizzling hum are the warning.

## Scale and silhouette

The cowl is 0.30 m across when closed and 0.50 m across when open; the head is about 0.45 m tall, hanging on a 1.30 m arm from a ceiling plate.

A ceramic bud hanging from a jointed arm: a cowl of six petals (closed like a tulip bud, or open in a ring) around a single lens, on two ceramic arm segments and a ceiling plate. It hangs high, aimed down at Dave.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Mount:** a round ceiling plate with a short collar, then two ceramic arm segments joined by a navy joint housing, and a yoke that lets the head pitch.
- **Head:** a bulb-shaped ceramic head. Around it six slim, overlapping petals fold forward into a smooth pointed bud when closed and splay outward when open (a two-frame swap, closed and open). Each petal is raw cast ceramic with a dark seam along its spine. A small round status lens sits on the head shell just below the cowl.
- **Lens:** a single recessed lens in a dark ring at the center of the cowl, hidden when closed and visible when open. The lens unit is the Cutter Beam ([EG09](../enemy-guns/eg09-cutter-beam.md)); the beam and the sight line leave from the lens center.
- **Details:** hairline casting seams and a few dark fasteners at the joints. No faces or eyes.

## Color and materials

*Proposed palette (Garden ceramic):* pearl-white ceramic #E6ECEF for the petals, with dark #2E3B4E seams; inner petal faces and far-side petals #C9D3DA (a flat color, not a painted shadow); arm and head cool ceramic #D8DEE3; joint navy #0E1726; lens dark glass #14181E, with a small white-blue core that stays a flat unlit dot in the base art.

Everything is painted as flat base colors with clean dark outlines and no baked shadow; the engine's lamps and the lens glow light the ceramic through its normal maps. Keep the ceramic a little darker than pure white so the lens glow and the beam edge stay the brightest shapes on the machine. There is no teal on the Pruner: teal on a machine marks a power unit or gauge.

**Light and fluid *(proposed)*:**

- While it hunts, the status lens on the head shell shows only a small, dim, steady amber point (#FFB02E), whether the petals are folded or open.
- The tell is the thin sight line plus a large additive glow around the lens ring: amber (the line holds amber for 0.3 s at the freeze), then alarm red #FF3B4E for the last 0.25 s.
- The beam is a separate effect: a white-hot core with a blue-white edge (#5AA9FF), never amber, red or teal.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim) where the ceramic shell cracks, and chip pale ceramic. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Turret (beam) (C26). **Weapon:** Cutter Beam, the Garden "pruning" laser ([EG09](../enemy-guns/eg09-cutter-beam.md)). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (LINE):** the petals open (a two-frame swap), then a thin sight line tracks Dave at 3 H/s for 0.8 s, freezes and holds amber for 0.3 s, then turns red for 0.25 s.
- **Attack:** a white-hot beam up to 6.5 H long drags after Dave at 2 H/s for 1.2 s, stopping at the first solid thing, and hits at most once per firing. Then a 1.6 s cooldown with the lens open.
- **Counter:** keep moving (Dave is faster than the drag), get behind a pillar or under a catwalk, then shoot the open lens. 3 hits.

It hangs still between attacks with the petals folded. It has no duck dodge, because Dave cannot crouch.

## Openings and limitations

The open lens during the cooldown: the petals stay splayed, the lens ring goes dark and small sparks stutter at its edge. Closed, the head is a plain armored bud with no visible target.

## Rig parts, normal maps and sockets

- **Parts (rigid):** ceiling plate (fixed); collar; arm segment 1; joint housing; arm segment 2; yoke; head shell; six petals (each its own part, hinged at its base, or a closed and an open two-frame set); lens unit with its ring (a light layer); status lens on the head shell (a light layer).
- **Pivots:** the arm joints, the yoke for head pitch, and each petal base.
- **Normal maps:** one per part, green = up: raw ceramic with soft casting relief, petal ribs and spine seams, a domed lens.
- **Sockets:** the head socket takes the [EG09](../enemy-guns/eg09-cutter-beam.md) lens unit, whose muzzle marker sits at the lens center; the sight line and the beam start there. Light sockets at the status lens (small, steady) and the lens ring (tell glow). Spark points at the joints and the lens; an oil drip point at the joint housing.
- **Fluid:** white sparks and black oil where the machine parts show, plus ceramic chips. Never blood.
- **Motion and death:** hand-keyed on the rigid parts (Mixamo clips are humanoid) *(proposed)*. On death it bursts into debris parts: the petals, head shell, lens unit and arm segments become physics bodies pushed by the killing shot, and the arm swings loose from the ceiling plate, which stays. The wreck hangs as a static corpse with a dark oil stain below.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Open cowl (neutral for the identity image and the rig split); closed bud; petals opening; sight line locked (lens ring amber); beam firing (lens ring red); cooldown with the lens open; hit reaction; wreck (the static corpse).

Show lamp states as flat colored shapes with no glow halo. The sight line, the beam, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One head with one lens, one small status lens and six petals, two arm segments and one ceiling plate. No eyelids, pupils or faces. No plants, roots or living stems: the flower shape is cast ceramic. No violet (the Bloom's color) and no teal. Mounted high only. The sight line and beam are effects, never painted in; the lens ring is amber, or red for the last 0.25 s of the tell only, and the beam is never amber or red.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The head, petals and arm are symmetrical about the arm's axis, so the Pruner mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Pruner, a ceiling-mounted ceramic beam turret cast in an underground factory garden. Role: high-mounted beam turret with a petal cowl that opens to a single lens.
Scale: The cowl is 0.30 m across when closed and 0.50 m across when open; the head is about 0.45 m tall, hanging on a 1.30 m arm from a ceiling plate.
Silhouette: A ceramic bud hanging from a jointed arm: a cowl of six petals around a single lens, on two ceramic arm segments and a ceiling plate.
Physical design: A round ceiling plate with a short collar, then two ceramic arm segments joined by a navy joint housing and a yoke. A bulb-shaped cool ceramic head with a cowl of six slim, overlapping pearl-white petals splayed open in a ring around a single recessed dark lens in a dark ring (drawn open so that the lens and the separate petals are visible; the closed bud is a state study). Each petal is raw cast ceramic with a dark seam along its spine. A small round unlit status lens sits on the head shell just below the cowl. Hairline casting seams and a few dark fasteners at the joints. No faces or eyes.
Materials and colors: Pearl-white ceramic #E6ECEF petals with dark #2E3B4E seams; inner petal faces #C9D3DA; arm and head cool ceramic #D8DEE3; joint navy #0E1726; lens dark glass #14181E; the status lens a small, flat, dull amber disc. No teal. Flat base colors only; the lens is a flat, unlit disc.
Critical consistency: One head, one lens, one small status lens, six petals, two arm segments, one ceiling plate. No eyelids, pupils or faces, no plants, roots or living stems, no violet, no teal, no gun. No text or logos.
Use a relaxed neutral pose hanging from the ceiling plate with the petals open and the lens visible, the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). The petal cowl and its lens are part of the Pruner and are painted. Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Pruner design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: The cowl is 0.30 m across when closed and 0.50 m across when open; the head is about 0.45 m tall, hanging on a 1.30 m arm from a ceiling plate. Maintain these defining forms: A ceramic bud hanging from a jointed arm: a cowl of six petals around a single lens, on two ceramic arm segments and a ceiling plate. Preserve construction: A round ceiling plate with a short collar, then two ceramic arm segments joined by a navy joint housing and a yoke. A bulb-shaped cool ceramic head with a cowl of six slim, overlapping pearl-white petals splayed open in a ring around a single recessed dark lens in a dark ring (drawn open so that the lens and the separate petals are visible; the closed bud is a state study). Each petal is raw cast ceramic with a dark seam along its spine. A small round unlit status lens sits on the head shell just below the cowl. Hairline casting seams and a few dark fasteners at the joints. No faces or eyes. Preserve the palette: Pearl-white ceramic #E6ECEF petals with dark #2E3B4E seams; inner petal faces #C9D3DA; arm and head cool ceramic #D8DEE3; joint navy #0E1726; lens dark glass #14181E; the status lens a small, flat, dull amber disc. No teal. Flat base colors only; the lens is a flat, unlit disc. Lock these details: One head, one lens, one small status lens, six petals, two arm segments, one ceiling plate. No eyelids, pupils or faces, no plants, roots or living stems, no violet, no teal, no gun. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Pruner reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Closed bud; petals opening; sight line locked; beam firing; cooldown with the lens open; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It hangs still with the petals folded. To attack the petals open, the head pitches to follow its target, and a thin sight line tracks, freezes and fires a beam that drags after the target. Afterward the lens stays open through a cooldown. Capability: Fires a white-hot beam that drags after a moving target, from high on a ceiling mount. It cannot move. Important limitation or opening: During the cooldown the petals stay splayed and the lens is open; the open lens is the target. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil, sight line or beam: the closed bud shows only the small flat dull-amber status lens; the petals-opening pose shows the lens ring flat dull amber; the sight-line-locked pose shows the lens ring flat amber (#FFB02E); the beam-firing pose shows the lens ring flat alarm red (#FF3B4E); the cooldown shows a dark lens ring; the wreck shows everything unlit. Draw no sight line and no beam. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

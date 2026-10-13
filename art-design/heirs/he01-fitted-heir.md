# Fitted Heir

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** HE01\
**Category:** heirs\
**First appearance:** Level 10 (Upgrade Day); returns in Levels 11–12\
**Design status:** Roster entry confirmed (C31). Look follows C60 (approved 2026-10-12): painted HD parts on the lit cutout rig (C56), corporate cyberpunk (C58), Adam's magenta seam lights (C60). Concept images are still to be generated. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

*Proposed:* an Heir that leaps past Dave and strikes on landing, wearing the face of someone Dave used to know.

Heirs are Adam's synthetic people: sleek white-and-graphite shells with magenta seam lights and a face display that shows a borrowed face. They are trained on minds Adam copied in the Memory Orchard and built to inherit the world after the Bloom. The Fitted Heir is the first Heir Dave meets: it steps off the Level 10 assembly line, where the Fitting Arms ([M09](../machines/m09-fitting-arm.md)) have just clamped its plates on. It appears in Levels 10–12.

**Why it attacks Dave:** Adam sends it to greet him. Its face display flickers to a dead colleague's face that says "Dave? It's me" *(proposed; the writers own the exact lines)*, to make him hesitate, and then it leaps. The unsettling part is the mismatch: a familiar face and voice on a body that has never been alive.

## Scale and silhouette

1.90 m tall; about 0.60 m across the shoulders; realistic adult proportions, about 7.5 heads tall.

A tall, slender figure that stands slightly too straight, with a smooth oval head, long arms and hands a little too large for the body. Fitted white composite plates cover the torso, arms and legs, and a dark glass face display covers the face. In the leap the body folds long and low, with the arms swept wide.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Shell:** sleek, matte white composite plates, each with a hairline magenta seam light (#FF3DD5, Adam's color, painted as a flat bright line with no glow), fitted over a graphite undersuit at the joints. It is freshly built: the plates sit flush with crisp, even seams, and nothing is cracked, scuffed or damaged.
- **Fiducial marks:** small black-and-white quartered alignment marks on the shoulders, chest and hips, left from the assembly line, like crash-test-dummy targets. There are no letters or numbers. They are a separate paint layer.
- **Head and face display:** a smooth composite oval with a rigid cap-like crest. A dark glass face display across the face shows a borrowed face in teal-white light, drawn as simple flat line shapes in profile (an eye, a brow, a mouth), so it reads as human at a glance and wrong on a second look. The display sits in a clean bezel. At rest and when destroyed, the display is blank.
- **Hands:** long, slim, five-fingered composite hands with plate knuckles. The fingers are a little too long and perfectly still.
- **Damage:** it is a machine. Hits chip the shell's edges, throw white sparks and leak black oil at the seams, and the face display glitches. Nothing organic ever shows. Chips are separate overlay layers per part.
- **Two looks on one rig** (C56, C60): **A, Pearl** (white composite shell over a graphite undersuit) and **B, Onyx** (a graphite shell with white trim over a white undersuit). Same magenta seams, same display, same proportions.
- **Borrowed faces:** three face sets, each a flat line drawing in profile: blank, calm, and "colleague" (a specific person from the staff Dave knew). There is no photoreal likeness of any real person.

## Color and materials

*Proposed palette:* white composite #D8DEE3 for the plates (look B graphite #2E3B4E with white trim); composite shadow #8FA1B0 for the far-side limbs and inner plates (a flat color, not a painted shadow); graphite undersuit and display bezel #2E3B4E; joint navy #0E1726; seam light magenta #FF3DD5; fiducial marks black #14181E on white #E9E6DA; display glass #14181E.

Everything is painted as evenly lit HD parts (C56): soft painted shading for form, clean dark outlines, no cast shadow, rim light or glow. The engine's lamps, screens and muzzle flashes light the composite smoothly through its normal maps. White composite must never blow out to pure white: keep the base value below it so lamplight still reads as light. Keep the display bezel lighter than the night scenery so the borrowed-face light always has a shape to sit on.

**Light and fluid *(proposed)*:**

- **Neon (C60):** the seam lights glow a steady, dim magenta (#FF3DD5, Adam's color) while it stands or walks, thinner and dimmer than any tell, and dark on death. While it hunts, a small, dim, steady amber point (#FFB02E) shows at the display's eye, as on every driven or hunting body, and the seams stay magenta.
- The tell (GLOW) is a large additive glow along the seams and hands: amber, then alarm red #FF3B4E for the last 0.25 s, as the display flickers to the colleague's face; the magenta gives way to the tell glow while it is up. The face light is teal-white and never red.
- In the blank landing pose the seams dim and the display goes blank. Destroyed, everything goes dark.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim) from the seams, drawn as separate effects. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Brawler + hop (C26). **Weapon:** composite hands (melee). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** its seams go amber and then red (red for the last 0.25 s) and its face display flickers to a dead colleague's face ("Dave? It's me").
- **Attack:** it leaps to land 1.75 H past Dave, striking on both sides of its landing spot.
- **Counter:** hold still or step back, then punish its blank landing pose. 4 hits.

It walks upright with an even, slightly too smooth stride and its hands held low and open. Before the hop it crouches with the arms drawn back and the face flickering. The leap is one long fold through the air, and it lands with the arms swept out to both sides. After the landing it stands blank for a beat: display empty, seams dim, arms hanging. Its motion is hand-keyed for the side view (C38), and its death is a ragdoll.

## Openings and limitations

The blank landing pose: display empty, seams dim, arms hanging. Chips and oil show where it has been hit. There is no armored weak point: the composite plates are the body, and a hit anywhere counts.

## Introduction scene (proposed, L10)

On an assembly line in Upgrade Day, a finished Heir stands in its fitting cradle with its face display blank and its seams dark. The display wakes with two teal points, and a borrowed face resolves: a colleague Dave used to know. The Heir looks at Dave and says hello in that colleague's voice, politely, and knows Dave's name. The scene is scripted and non-interactive, not a fight, and the assembly line then carries the body on. The writers decide which colleague and the exact lines, and level design owns the staging.

The Fitted Heir is the suggested body for the scene because it is the first Heir met in the level, but any Heir body may substitute. Art needs four frames: standby (arms folded, display blank, seams dark), display waking, greeting (face fully projected) and the projection fading to blank. Keep the face to flat line shapes, with no photoreal likeness of any real person. The unsettling beat is the mismatch: a familiar voice and a warm face on a body that has never been alive. In combat the same borrowed-face flicker becomes the tell.

## Rig parts, normal maps and sockets

- **Parts (humanoid rig):** head with crest; face display (its own part); face-projection layers (blank, calm, colleague); torso; pelvis; upper and lower arms; two hands; upper and lower legs; two feet. The composite hands are the weapon, so both are ordinary hand parts.
- **Overlays:** fiducial marks; chip overlays per part (two damage stages); seam glow masks (emissive, one per part).
- **Pivots:** the pelvis as the root; the neck base; shoulders, elbows and wrists; hips, knees and ankles.
- **Normal maps:** one per part, green = up: matte composite plates with crisp seam grooves, a nearly flat glass display panel, and shallow chip relief on the overlays.
- **Sockets:** no gun socket. Light sockets along the seams, on the hands and at the face display (the face projection, and the small amber point while hunting). The melee hit areas sit on the hands.
- **Fluid:** white sparks and black oil: a drip from the hit part under gravity only, spark points at the seams and a floor stain, separate from the painted art. Never blood.
- **Motion and death:** hand-keyed on the rig for the side view (C38): the walk, crouch, jump and landing. Death is a ragdoll: the parts become physics bodies pushed by the killing shot and stay joined at their pivots (no dismemberment, C29), the seams and the face projection go dark, and the body settles as a static corpse with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Neutral standing (arms low, display blank); walk; crouch (arms drawn back, seams amber, display flickering to the colleague's face); leap; landing strike (arms out to both sides); blank landing pose; hit reaction with chips and sparks; death (ragdoll corpse). For the introduction scene also: standby with a blank display, display waking, borrowed-face greeting, and the projection fading.

Show seams and the display light as flat colored shapes with no glow halo: magenta seams at rest and while walking (with a small amber dot at the display's eye once it hunts), amber then red in the crouch. The face is a flat teal-white line drawing. Chips, sparks, oil and glows are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Exactly two arms, two legs and one head. One face display on one head: the face is light on a display, never a second head. Five long composite fingers per hand. No gun, no weapon and no armor beyond the fitted shell. No cracked shell, grown tissue, lymph, wounds, exposed organs or bone, and no dismemberment. The face light is teal-white, never red; oil is black, never red, teal, amber or white; the only neon is the magenta seam light.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The alignment marks are symmetric quartered targets and the face display is a profile drawing on its own part, so the Fitted Heir mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish.

Design the Fitted Heir, one of Adam's synthetic people: a tall, sleek white-and-graphite synthetic body with magenta seam lights and a face display that shows a borrowed face. Role: Heir brawler that leaps past its target and strikes on landing.
Scale: 1.90 m tall; about 0.60 m across the shoulders; realistic adult proportions, about 7.5 heads tall.
Silhouette: A tall, slender figure that stands slightly too straight, with a smooth oval head, long arms and hands a little too large for the body, in fitted white composite plates and a dark glass face display.
Physical design: Sleek matte white composite plates, each with a hairline flat magenta (#FF3DD5) seam, fitted over a graphite undersuit at the joints, flush with crisp even seams. Small black-and-white quartered alignment marks on the shoulders, chest and hips, with no letters. A smooth composite oval head with a rigid cap-like crest and a dark glass face display in a clean bezel across the face, blank. Long, slim, five-fingered composite hands with plate knuckles. Intact, undamaged shell everywhere.
Materials and colors: White composite #D8DEE3; composite shadow #8FA1B0 on the far-side limbs; graphite undersuit and display bezel #2E3B4E; joint navy #0E1726; seam magenta #FF3DD5 as flat lines, no glow; display glass #14181E; alignment marks black #14181E on white #E9E6DA.
Critical consistency: Exactly two arms, two legs and one head; one face display, blank, never a second head; five long composite fingers per hand. No gun, no weapon, no armor beyond the fitted shell, no cracks, no tissue, no blood, oil or lymph. No text or logos.
Use a relaxed neutral A-pose with the arms slightly away from the torso and the legs slightly apart so the limb parts separate, display blank; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit hand-painted art: soft painted shading for form, clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Fitted Heir design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 1.90 m tall; about 0.60 m across the shoulders; realistic adult proportions, about 7.5 heads tall. Maintain these defining forms: A tall, slender figure that stands slightly too straight, with a smooth oval head, long arms and hands a little too large for the body, in fitted white composite plates and a dark glass face display. Preserve construction: Sleek matte white composite plates, each with a hairline flat magenta (#FF3DD5) seam, fitted over a graphite undersuit at the joints, flush with crisp even seams. Small black-and-white quartered alignment marks on the shoulders, chest and hips, with no letters. A smooth composite oval head with a rigid cap-like crest and a dark glass face display in a clean bezel across the face, blank. Long, slim, five-fingered composite hands with plate knuckles. Intact, undamaged shell everywhere. Preserve the palette: White composite #D8DEE3; composite shadow #8FA1B0 on the far-side limbs; graphite undersuit and display bezel #2E3B4E; joint navy #0E1726; seam magenta #FF3DD5 as flat lines, no glow; display glass #14181E; alignment marks black #14181E on white #E9E6DA. Lock these details: Exactly two arms, two legs and one head; one face display, blank, never a second head; five long composite fingers per hand. No gun, no weapon, no armor beyond the fitted shell, no cracks, no tissue, no blood, oil or lymph. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit hand-painted colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Fitted Heir reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Neutral standing; walk; crouch; leap; landing strike; blank landing pose; hit reaction; death; standby with a blank display; display waking; borrowed-face greeting. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It walks upright with an even, slightly too smooth stride and its hands low and open. Before the hop it crouches with the arms drawn back while the face display flickers to a familiar face. The leap is one long fold through the air. It lands with the arms swept out to both sides, then stands blank for a beat with the arms hanging. Capability: Leaps to land past its target and strikes on both sides of its landing spot with its composite hands. Important limitation or opening: The blank landing pose, with the display empty, the seams dim and the arms hanging, is the opening. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, oil, sparks or gun: the neutral standing pose shows the seam lines flat magenta (#FF3DD5) and a blank display; the walk adds one small flat amber (#FFB02E) dot at the display's eye; the crouch shows the seam lines flat amber, or flat alarm red (#FF3B4E) for the last quarter of the crouch, and a flat teal-white line-drawn face on the display; the leap and landing strike keep red seams; the blank landing pose shows dim seams and a blank display; the death shows dark seams and a blank display; in the greeting study the display holds a flat teal-white line-drawn face in profile (an eye, a brow, a mouth). For hit reactions, draw small edge chips only, with no fluid. Evenly lit hand-painted color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Generate each look as a painted HD parts sheet (C56) with style-frame-v2 attached. Approve one neutral image (prompt 1) before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art, and check the mirrored rig in the lit test.
- Split the approved painting into the rig parts listed above, with hidden overlap under every joint and the hidden areas (far limbs, anything a part covers) painted complete, and make a matching normal map for each part (green = up) once the painting is approved. The image generator prompts here ask only for the evenly lit painting.
- Check the silhouette and every tell at gameplay size, in grayscale, and lit in-engine against dark night scenery with one lamp from the left and one from the right, so the normal maps light correctly on both facings.
- Establish a consistent canvas, ground baseline, socket and pivot intent; draw a few key poses before adding small details.
- Keep blood, sparks, oil, glows, muzzle flashes and light pools separate from the parts. A concept PNG is not a finished sprite sheet, layered source file, rig or validated animation.
- The lit cutout look is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): re-check this brief against the approved test look before production.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

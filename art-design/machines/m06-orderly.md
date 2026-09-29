# Orderly

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M06\
**Category:** machines\
**First appearance:** Level 7 (Please Remain Still); returns in Level 9\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Staff-collection charger that pushes a scoop stretcher, stalls, then beeps and reverses.

**Who built and fields it *(proposed)*:** one of the Arcadia Wellness Center's transport machines, built by Arcadia's medical facilities division to wheel staff between the waiting rooms, the recovery ward and the implant theater. It works the clinic in Level 7 and returns in Level 9. Its stretcher deck carries a sealed body bag.

**Why it attacks Dave:** Adam dispatches it when it files Dave as due for collection, and its intake script becomes the warning: "Please remain still for collection." It is entirely mechanical and carries no implant hardware of its own.

## Scale and silhouette

Robot 1.65 m tall; robot plus stretcher approximately 2.45 m long.

A stocky humanoid robot leaning behind a long low wheeled stretcher. Broad shoulders and two planted legs contrast with the stretcher's shallow front scoop.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

The robot has two arms permanently gripping a rear pushbar, a rounded rectangular head, two sleepy capsule eyes, and a rear-mounted drive motor. The stretcher has four wheels, two raised padded rails, and a hinged front lip that can drop close to the floor. A sealed charcoal body bag lies flat along the deck under two thick restraint straps: a plain, closed bag with no visible face, hands or limbs and no shape beyond a soft rounded outline. It is cargo, not a target and not a person.

**Details *(proposed)*:** the capsule eyes are half-lidded lenses; a small, low-profile collection beacon sits on the crown of the head as part of the head layer; the motor's back vents can show light while it stalls; a pale reverse lamp sits at the rear of the stretcher; clinic-aqua livery runs along the shoulders and rails. None of this adds a moving part.

## Color and materials

*Proposed palette (keeps the Orderly's identifying colors):* worn clinic ivory #BDB9A4 shell; clinic aqua #3E9A94 livery trim; dusky mattress clay #A8695C; body bag charcoal #2A2F36 with a pale zipper line #B9C4CF; graphite wheels #2A353D; collection beacon and reverse lamp amber-tinted #C98A2B, unlit; motor vents graphite #2E363E with a teal strip #3FE0D0.

Everything is painted as flat base colors with clean dark outlines and no baked shadow. The engine's lamps, including the clinic's green exit signs and surgical lamps, light the shell and the bag through their normal maps. Keep the shell pale enough to read at night without going white, and keep the charcoal bag lighter than the night scenery so the deck still reads as a shape.

**Light and fluid *(proposed)*:**

- The sleepy capsule lenses show only a small, dim, steady amber point (#FFB02E).
- The tell is a large additive glow on the collection beacon and the eye lenses: amber, then alarm red #FF3B4E for the last 0.25 s, in step with the announcement, as the scoop lip drops. The red light falls on the floor ahead of the lowered lip, showing the charge lane.
- During the stall the rear motor's vents show Adam teal #3FE0D0, so the opening reads in the dark.
- The reverse lamp blinks amber with each beep and turns red for the last 0.25 s before the stretcher rolls back.
- A destroyed Orderly goes dark.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects, never on the bag. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- In the Wellness Center the red "PLEASE REMAIN STILL" signage shares the alarm red used for tells, so the lowered lip and the forward lean must carry the warning; the red flash only reinforces it.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Charger + reverse (C26). **Weapon:** ram (the scoop lip and stretcher). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** its lamps go amber and then red (red for the last 0.25 s) with the announcement "Please remain still for collection," the scoop lip dropping and the robot leaning forward.
- **Attack:** it charges down its floor. After the stall it beeps and reverses.
- **Counter:** bait it into a wall and hit the rear motor during the stall, then jump it when it beeps. 3 hits.

It shuffles slowly while searching, then lowers the front lip, leans forward and accelerates. Braking makes the bag bounce on the deck and the robot lean backward. The spoken line is the audible warning that a charge is coming, so it must cut through other sounds; its polite, unhurried voice is the unsettling part.

## Openings and limitations

The vented motor on the robot's back, reached when the Orderly stalls against a wall or after Dave passes over the stretcher; its vents show teal light while it stalls. The stretcher, the bag and the mattress are props, not a target: no person is ever drawn on the stretcher, and staff held for implanting are protected characters, not targets.

## Rig parts, normal maps and sockets

- **Parts (rigid):** robot head (with the lenses and the beacon as light layers), torso, two arms (upper and lower each), two legs; rear motor with its vents (a light layer); stretcher chassis; four wheels; two rails; hinged scoop lip; mattress; body bag (its own part, so it can slide free); two restraint straps; reverse lamp (a light layer).
- **Pivots:** the shoulders (the hands stay fixed to the pushbar); the torso lean pivot at the hips; the scoop lip hinge at its rear edge; each wheel hub.
- **Normal maps:** one per part, green = up: padded rails and mattress, the soft folds of the bag, strap webbing, wheel tread, shallow panel seams and vent slats on the shell.
- **Sockets:** no gun socket. Light sockets at the eye lenses (small, steady), the beacon (large tell glow), the motor vents (teal) and the reverse lamp. Spark points at the motor and joints; an oil drip point under the robot.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts (Mixamo clips are humanoid) *(proposed)*. On death it bursts into debris parts: the robot's head, torso and limbs, the motor, the scoop lip and the wheels become physics bodies pushed by the killing shot, and the sealed bag slides off the deck and stays closed. The stretcher and robot settle as a static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Patrol; lip-lowered warning; charge; stall with the motor vents showing; beep and reverse; braking; hit reaction; wreck (the static corpse, the bag slid clear and still closed).

Show lamp states as flat colored shapes with no glow halo. Glows, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One robot and one attached stretcher, always connected by the pushbar during ordinary motion. One sealed body bag, always closed and opaque, with no visible person, face, hands or limbs. No extra attendants and no hidden additional arms. Fully mechanical: no implant hardware, exposed cabling or organic parts. No text or logos.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The robot, the stretcher and the bag mirror together as one assembly, and nothing on them carries text, so the Orderly is mirror-safe.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Orderly, a clinic patient-transport robot. Role: staff-collection charger that pushes a scoop stretcher, stalls, then beeps and reverses.
Scale: Robot 1.65 m tall; robot plus stretcher approximately 2.45 m long.
Silhouette: A stocky humanoid robot leaning behind a long low wheeled stretcher. Broad shoulders and two planted legs contrast with the stretcher's shallow front scoop.
Physical design: The robot has two arms permanently gripping a rear pushbar, a rounded rectangular head with two sleepy half-lidded capsule eyes, and a rear-mounted drive motor with vent slats. A small, low-profile collection beacon sits on the crown of the head. The stretcher has four wheels, two raised padded rails, a hinged front lip that can drop close to the floor, and a pale reverse lamp at the rear. A sealed charcoal body bag lies flat along the deck under two thick restraint straps: a plain, closed bag with no visible face, hands or limbs. Clinic-aqua livery runs along the shoulders and rails.
Materials and colors: Worn clinic ivory #BDB9A4 shell; clinic aqua #3E9A94 livery trim; dusky mattress clay #A8695C; body bag charcoal #2A2F36 with a pale zipper line #B9C4CF; graphite wheels #2A353D; collection beacon and reverse lamp amber-tinted #C98A2B, unlit; the eye lenses small, flat, dull amber discs. Flat base colors only.
Critical consistency: One robot and one attached stretcher, always connected by the pushbar. One sealed, opaque body bag: no visible person, face, hands or limbs. No extra attendants and no hidden additional arms. Fully mechanical: no implant hardware, exposed cabling or organic parts. No text or logos.
Use a relaxed neutral pose that reveals the silhouette and joint structure, with the scoop lip up and the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Orderly design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: Robot 1.65 m tall; robot plus stretcher approximately 2.45 m long. Maintain these defining forms: A stocky humanoid robot leaning behind a long low wheeled stretcher. Broad shoulders and two planted legs contrast with the stretcher's shallow front scoop. Preserve construction: The robot has two arms permanently gripping a rear pushbar, a rounded rectangular head with two sleepy half-lidded capsule eyes, and a rear-mounted drive motor with vent slats. A small, low-profile collection beacon sits on the crown of the head. The stretcher has four wheels, two raised padded rails, a hinged front lip that can drop close to the floor, and a pale reverse lamp at the rear. A sealed charcoal body bag lies flat along the deck under two thick restraint straps: a plain, closed bag with no visible face, hands or limbs. Clinic-aqua livery runs along the shoulders and rails. Preserve the palette: Worn clinic ivory #BDB9A4 shell; clinic aqua #3E9A94 livery trim; dusky mattress clay #A8695C; body bag charcoal #2A2F36 with a pale zipper line #B9C4CF; graphite wheels #2A353D; collection beacon and reverse lamp amber-tinted #C98A2B, unlit; the eye lenses small, flat, dull amber discs. Flat base colors only. Lock these details: One robot and one attached stretcher, always connected by the pushbar. One sealed, opaque body bag: no visible person, face, hands or limbs. No extra attendants and no hidden additional arms. Fully mechanical: no implant hardware, exposed cabling or organic parts. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Orderly reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Patrol; lip-lowered warning; charge; stall with the motor vents showing; beep and reverse; braking; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It shuffles slowly while searching. It then lowers the front lip, leans forward and accelerates. Braking makes the bag bounce on the deck and the robot lean backward. After the stall it backs the stretcher up with the reverse lamp blinking. Capability: Charges down its floor with a lowered scoop lip, stalls, then beeps and reverses. Important limitation or opening: The vented motor on the robot's back shows teal light during the stall and is the target. The stretcher and the sealed bag are props, not targets, and no person is ever drawn on the stretcher. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or gun: the patrol shows the eye lenses flat dull amber and an unlit beacon; the lip-lowered warning shows the beacon and eye lenses flat amber (#FFB02E), or flat alarm red (#FF3B4E) for the last quarter of the warning; the charge keeps red lenses; the stall shows dark lenses and the motor vent strip flat teal (#3FE0D0); the beep and reverse shows the reverse lamp flat amber; the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

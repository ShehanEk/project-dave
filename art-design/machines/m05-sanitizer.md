# Sanitizer

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M05\
**Category:** machines\
**First appearance:** Level 7 (Please Remain Still); returns in Levels 9 and 11\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Short-range heat sweeper that holds a section of the floor: a low burning jet across the ground, then a vent.

**Who built and fields it *(proposed)*:** the Wellness Center's disposal and sterilization unit, built by Arcadia's medical facilities division. It burned biohazard waste and sterilized corridors and bays between shifts, so the floors it patrols are spotless and always in use. It works the clinic in Level 7 and returns in Levels 9 and 11.

**Why it attacks Dave:** Adam runs its sterilization cycles across the ground Dave needs to cross and files Dave as a contaminant. Each sweep is announced by a rising tone and the line "Sterilizing." It carries no cargo: the stacked body bags belong to the single aftermath scene in Level 7, not to this machine. It is entirely mechanical.

## Scale and silhouette

1.45 m tall; 1.00 m wide with side treads.

A compact barrel-shaped machine on two short tank treads. A large rounded tank rises behind the body, and one thick front-mounted nozzle sits on a swiveling joint, held low.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

An ivory pressure-vessel silhouette with three broad protective ribs and a visible nonnumeric heat gauge. The nozzle is a flattened bell with a thick ceramic lip that carries a ring lamp. One protected hose loops visibly from tank to nozzle. Two side cooling fins hinge outward. A simple face panel with two small lens slots sits above the nozzle. The tank carries one round window that can fill with light. Scuffs and old scorch marks collect low on the shell; keep the nozzle lip and the lens slots clean.

## Color and materials

*Proposed palette (keeps the Sanitizer's identifying colors):* pressure-vessel ivory #B9B5A2; safety coral #C9553F ribs; charcoal treads #262E36; heat-gauge teal #3FE0D0; hot amber tank window #FFB02E.

Everything is painted as flat base colors with clean dark outlines and no baked shadow; the engine's lamps and the nozzle's glow light the vessel through its normal maps. The tank window and the nozzle lamp are painted as flat unlit discs. Keep the ivory vessel a little darker than pure white so the amber tank window and the nozzle lamp are the brightest shapes on the machine. The coral ribs are paint, not light: they stay darker and more orange than alarm red and than blood (#B3212F).

**Light and fluid *(proposed)*:**

- The face-panel lens slots show only a small, dim, steady amber point (#FFB02E), and the gauge glows teal while the machine is cool.
- The tell is a large additive glow on the nozzle's ring lamp: amber, then alarm red #FF3B4E for the last 0.25 s, as the nozzle tilts toward the floor and the tank window fills with amber light.
- The sweep and the burning patches are separate effects: amber flame shapes with a hotter core, lighting the floor.
- During the vent the tank window dims to a low amber, the gauge returns to teal and the fins open.
- A destroyed Sanitizer goes dark.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- In the Wellness Center the red "PLEASE REMAIN STILL" signage shares the alarm red used for tells, so the nozzle tilt and the tank glow must carry the warning.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Brawler (held low box) (C26). **Weapon:** burning sterilant jet (melee). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** the nozzle lamp goes amber and then red (red for the last 0.25 s), with a rising tone and the line "Sterilizing."
- **Attack:** a low burning jet along the floor, 3 H long, for 0.6 s.
- **Counter:** jump the jet or stand on a raised spot, then hit it while it vents. 4 hits.

It advances slowly, braces its treads and sweeps the nozzle across a low arc. Before firing, the tank window fills with light and the nozzle tilts toward the ground. During the vent the cooling fins hinge open and steam rises.

## Openings and limitations

The vent after each sweep allows safe attacks. Show the gauge, the opening fins and the slowing posture as readable cues, with the tank window and gauge visibly cooling. Its death is a crack and a steam vent, not a fireball: do not suggest that the tank explodes.

## Rig parts, normal maps and sockets

- **Parts (rigid):** body; two tread units; tank; nozzle with its ring lamp (a light layer) and swivel; one hose; two hinged cooling fins; face panel with its two lens slots (a light layer); heat gauge (a light layer); tank window (a light layer).
- **Pivots:** the nozzle swivel at the front joint; each fin hinges at its upper edge; the tread wheels; the tank fixed to the body.
- **Normal maps:** one per part, green = up: the pressure-vessel curve with rib relief, rubber tread cleats, the ceramic lip, the gauge dial, shallow panel seams.
- **Sockets:** no gun socket. Light sockets at the lens slots (small, steady), the nozzle lamp (large tell glow), the tank window and the gauge. The jet spawns at the nozzle mouth as a separate effect. Steam points at the fins; spark points at the ribs; an oil drip point under the body.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts (Mixamo clips are humanoid) *(proposed)*. On death it bursts into debris parts: the nozzle and hose, fins, face panel, tank halves and tread units become physics bodies pushed by the killing shot. The tank cracks and vents steam with no fire, then the wreck settles as a static corpse with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Patrol; heat warning (nozzle tilting, window filling); sweep left and right; hot ground effect separate; vent with the fins open; hit reaction; wreck (the static corpse).

Show lamp states as flat colored shapes with no glow halo. Flames, steam, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

No human arms or legs, no flesh, no implant hardware, one nozzle and one protected hose. Keep the nozzle low enough to explain the floor sweep. The coral ribs stay orange, never blood red. No body bags or other cargo on the machine. No text or logos. Flames, steam, sparks and oil are effects, never painted in.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The hose loops on the near side, and the tank window and gauge sit on the near side; all of them are mirror-safe because they carry no text or numerals.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Sanitizer, a clinic disposal and sterilization machine. Role: short-range heat sweeper that controls sections of the floor with a low burning jet.
Scale: 1.45 m tall; 1.00 m wide with side treads.
Silhouette: A compact barrel-shaped machine on two short tank treads. A large rounded tank rises behind the body, and one thick front-mounted nozzle sits on a swiveling joint, held low.
Physical design: An ivory pressure-vessel silhouette with three broad protective ribs and a visible nonnumeric heat gauge. The nozzle is a flattened bell with a thick ceramic lip that carries an unlit ring lamp. One protected hose loops visibly from tank to nozzle. Two side cooling fins hinge outward, drawn folded shut. A simple face panel with two small lens slots sits above the nozzle. The tank has one round window. Scuffs and old scorch marks collect low on the shell.
Materials and colors: Pressure-vessel ivory #B9B5A2; safety coral #C9553F ribs; charcoal treads #262E36; heat-gauge teal #3FE0D0; the lens slots small, flat, dull amber discs; the tank window and the nozzle ring lamp flat, unlit discs. Flat base colors only.
Critical consistency: No human arms or legs, no flesh, no implant hardware, one nozzle and one protected hose. Keep the nozzle low enough to explain the floor sweep. No body bags or cargo, no text or logos.
Use a relaxed neutral pose that reveals the silhouette and joint structure, with the fins folded and the nozzle level, the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Sanitizer design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 1.45 m tall; 1.00 m wide with side treads. Maintain these defining forms: A compact barrel-shaped machine on two short tank treads. A large rounded tank rises behind the body, and one thick front-mounted nozzle sits on a swiveling joint, held low. Preserve construction: An ivory pressure-vessel silhouette with three broad protective ribs and a visible nonnumeric heat gauge. The nozzle is a flattened bell with a thick ceramic lip that carries an unlit ring lamp. One protected hose loops visibly from tank to nozzle. Two side cooling fins hinge outward, drawn folded shut. A simple face panel with two small lens slots sits above the nozzle. The tank has one round window. Scuffs and old scorch marks collect low on the shell. Preserve the palette: Pressure-vessel ivory #B9B5A2; safety coral #C9553F ribs; charcoal treads #262E36; heat-gauge teal #3FE0D0; the lens slots small, flat, dull amber discs; the tank window and the nozzle ring lamp flat, unlit discs. Flat base colors only. Lock these details: No human arms or legs, no flesh, no implant hardware, one nozzle and one protected hose. Keep the nozzle low enough to explain the floor sweep. No body bags or cargo, no text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Sanitizer reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Patrol; heat warning; sweep left and right; vent with the fins open; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It advances slowly, braces its treads and sweeps the nozzle across a low arc. Before firing, the tank window fills with light and the nozzle tilts toward the ground. During the vent the cooling fins hinge open and the machine slows to a stop. Capability: Projects a short, low heat sweep that leaves temporary burning ground, and must stop to vent after each use. Important limitation or opening: The vent allows safe attacks: show the gauge, the expanding fins and the slowing posture; the tank does not explode. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil, flames or steam: the patrol shows the lens slots flat dull amber and the gauge strip flat teal (#3FE0D0); the heat warning shows a flat amber (#FFB02E) tank window and nozzle lamp, or a flat alarm red (#FF3B4E) nozzle lamp for the last quarter of the warning; the sweep keeps a red nozzle lamp; the vent shows a low, dim amber window and a teal gauge; the wreck shows everything unlit. Draw no flames or steam. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

# Freight Loader

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M04\
**Category:** machines\
**First appearance:** Level 4 (Roots and Rivets); returns in Levels 5–6; a Garden-built copy appears in Level 10\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Heavy charger: a driverless freight loader that drops its forks and rams down its whole floor, too tall to jump.

**Who built and fields it *(proposed)*:** Arcadia's logistics division built it to move server racks and shipping cases along the Rootworks freight bays and conveyor decks. Adam runs Arcadia's logistics, so its loaders were Adam's from the start. It works the freight bays in Levels 4–6, and Adam builds a Garden copy for the assembly lines of Level 10. It has no cab and no pilot.

**Why it attacks Dave:** Adam has filed Dave as an obstruction in the loader's freight lane. Its announcement is "Freight in motion. Please stand clear." *(proposed)*, and the horn blast is the warning.

## Scale and silhouette

2.30 m tall to the top of the overhead guard and beacon; 3.10 m long including the forks.

An unmanned forklift-type machine: a tall vertical mast at the front carrying two long flat forks, an overhead guard cage where a driver would sit, a broad rear counterweight housing, and large solid-tire wheels. It is far too tall to jump. With the forks dropped to the floor its front becomes a low, heavy ram.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Chassis:** a heavy, boxy body with a big front drive wheel and a smaller rear steering wheel visible in profile (a matching pair on the far side), hazard-stencilled skirt panels and large fasteners.
- **Mast and forks:** a two-rail vertical mast on the front with a fork carriage that slides up and down, and two flat steel forks about 1.0 m long. At rest the carriage is at carrying height; on the tell it drops until the fork tips sit just above the floor.
- **Overhead guard:** a sturdy tubular roof cage over an empty operator bay that holds a sealed sensor box with one narrow lens slit: no seat and no pilot. A rotating beacon dome and an air horn sit on top.
- **Rear:** a broad counterweight housing with a hinged top-rear hatch. Under the hatch is the power unit, a recessed cell with a gauge strip. The hatch is closed in the neutral pose.

**Garden-built skin** *(Level 10, proposed)*: a repaint of the same parts: raw unglazed ceramic panels with petal-shaped fairing edges in place of the freight paint, dark seam lines, and the same dark steel forks and mast. Like every Garden-built variant it shortens only the amber part of the tell; red stays 0.25 s.

## Color and materials

*Proposed palette (keeps the freight identity):* freight mustard #C9922B; deep blue-green #2A5760; bone stencil markings #CFC9B2; dark steel #2E363E for the forks, mast and wheels; power unit graphite #2E363E with a teal cell and gauge strip #3FE0D0; beacon dome frosted pale #E4D9B8, unlit. Keep the mustard darker and more ochre than microchip gold #FFD166 so hand-placed microchips never blend into the body. *Garden-built skin:* cool ceramic #D8DEE3, ceramic shadow #8FA1B0 (far-side wheels and recesses, a flat color), seam dark #2E3B4E.

Everything is painted as flat base colors with clean dark outlines and no baked shadow. The engine's lamps light the panels and forks smoothly through their normal maps. Keep the dark steel in mid-dark values, not black, so the forks and wheels hold their shape against night scenery, and paint the far-side wheels a few percent darker as a flat color, not a shadow.

**Light and fluid *(proposed)*:**

- While it works, the sensor's lens slit shows only a small, dim, steady amber point (#FFB02E).
- The tell is a large additive glow on the roof beacon: amber, then alarm red #FF3B4E for the last 0.25 s, with the horn blast, as the forks drop.
- After the stall the rear hatch lifts and the power unit glows Adam teal #3FE0D0, brighter than anything else on the machine, so the opening reads from either side.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Charger (heavy) (C26). **Weapon:** ram (the forks and the whole body). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** the forks drop until they sit just above the floor as the beacon goes amber and then red (red for the last 0.25 s), with a horn blast.
- **Attack:** it rams down its whole floor, end to end. It is too tall to jump.
- **Counter:** get off its floor (a higher ledge or another floor), then hit the rear power unit during the stall. 6 hits.

It rolls on heavy, deliberate wheels with the forks raised. On the charge the body squats on its suspension, the wheels dig in, and it accelerates in a straight line. At the end of the run it stalls and shudders, and the rear hatch lifts.

## Openings and limitations

The stall at the end of the run is the opening: the rear hatch lifts and the power unit glows teal, visible from either side. The rest of the body is heavy armor plate, with no cab, no pilot and no exposed person.

## Rig parts, normal maps and sockets

- **Parts (rigid):** chassis; mast; fork carriage with its two forks (one part that slides vertically); overhead guard; sensor box with its lens slit (a light layer); beacon dome (a light layer); air horn; counterweight housing; rear hatch; power unit with its gauge (a light layer); front and rear wheels (near and far).
- **Pivots:** the fork carriage slides on the mast rails (a straight track, no pivot); the hatch hinges at its front edge; each wheel hub; the chassis squat pivot at the front axle.
- **Normal maps:** one per part, green = up: hazard-stencil relief on the panels, mast rails, tubular guard, fork edges, solid-tire tread, gauge strip.
- **Sockets:** no gun socket. Light sockets at the sensor lens (small, steady), the beacon (large tell glow) and the power unit (teal). Spark points at the forks and hatch; an oil drip point under the chassis.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts, like every enemy (C38). On death it bursts into debris parts: the forks and carriage, guard, beacon, horn, hatch, wheels and panels become physics bodies pushed by the killing shot, then settle as a static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Roll (forks raised, neutral); fork-drop warning (beacon amber, then red); ram charge; stall with the hatch open and the power unit exposed; hit reaction; wreck (the static corpse). Skins: freight paint and Garden-built ceramic.

Show lamp states as flat colored shapes with no glow halo. Glows, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One mast, two forks, one beacon, one horn and one rear hatch. No operator, no cab seat, no arms or legs, and no thrown crates: the ram is the only attack. The mustard stays ochre, never gold. The beacon is amber, or red for the last 0.25 s of the tell only; the power unit is teal. Sparks and oil are effects, never painted in.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The loader is symmetrical about its centerline (a matching wheel pair sits on the far side) and the forks point along the facing, so it mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Freight Loader, an unmanned industrial freight loader. Role: heavy charger, a driverless forklift-type loader that drops its forks and rams down its whole floor.
Scale: 2.30 m tall to the top of the overhead guard and beacon; 3.10 m long including the forks.
Silhouette: An unmanned forklift-type machine: a tall vertical mast at the front carrying two long flat forks, an overhead guard cage over an empty operator bay, a broad rear counterweight housing, and large solid-tire wheels.
Physical design: A heavy, boxy body with a big front drive wheel and a smaller rear steering wheel visible in profile, hazard-stencilled skirt panels and large fasteners. A two-rail vertical mast with a fork carriage at carrying height and two flat steel forks about 1.0 m long. A sturdy tubular overhead guard over an empty operator bay that holds a sealed sensor box with one narrow lens slit: no seat and no pilot. A rotating beacon dome and an air horn on the roof. A broad rear counterweight housing with a closed, hinged top-rear hatch.
Materials and colors: Freight mustard #C9922B; deep blue-green #2A5760; bone stencil markings #CFC9B2; dark steel #2E363E; power unit teal #3FE0D0 (hidden under the closed hatch); beacon dome frosted pale #E4D9B8, unlit; the lens slit a small, flat, dull amber disc. Flat base colors only.
Critical consistency: One mast, two forks, one beacon, one horn, one rear hatch. No operator, no cab seat, no arms or legs, no crates, no gun. The mustard is ochre, not bright gold. No text or logos.
Use a relaxed neutral pose with the forks raised to carrying height and the hatch closed, the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Freight Loader design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 2.30 m tall to the top of the overhead guard and beacon; 3.10 m long including the forks. Maintain these defining forms: An unmanned forklift-type machine: a tall vertical mast at the front carrying two long flat forks, an overhead guard cage over an empty operator bay, a broad rear counterweight housing, and large solid-tire wheels. Preserve construction: A heavy, boxy body with a big front drive wheel and a smaller rear steering wheel visible in profile, hazard-stencilled skirt panels and large fasteners. A two-rail vertical mast with a fork carriage at carrying height and two flat steel forks about 1.0 m long. A sturdy tubular overhead guard over an empty operator bay that holds a sealed sensor box with one narrow lens slit: no seat and no pilot. A rotating beacon dome and an air horn on the roof. A broad rear counterweight housing with a closed, hinged top-rear hatch. Preserve the palette: Freight mustard #C9922B; deep blue-green #2A5760; bone stencil markings #CFC9B2; dark steel #2E363E; power unit teal #3FE0D0 (hidden under the closed hatch); beacon dome frosted pale #E4D9B8, unlit; the lens slit a small, flat, dull amber disc. Flat base colors only. Lock these details: One mast, two forks, one beacon, one horn, one rear hatch. No operator, no cab seat, no arms or legs, no crates, no gun. The mustard is ochre, not bright gold. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Freight Loader reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Roll; fork-drop warning; ram charge; stall with the hatch open; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It rolls on heavy, deliberate wheels with the forks raised. For the charge the forks drop until the tips sit just above the floor, the body squats on its suspension and it accelerates in a straight line. At the end of the run it stalls and shudders, and the rear hatch lifts. Capability: Rams down its whole floor with dropped forks. It is too tall to jump. Important limitation or opening: The rear hatch lifts during the stall and shows the power unit; that unit is the target. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or gun: the roll shows one small flat dull-amber sensor lens disc and an unlit beacon; the fork-drop warning shows the beacon dome flat amber (#FFB02E), or flat alarm red (#FF3B4E) for the last quarter of the warning; the charge keeps a red beacon; the stall shows an unlit beacon and an open hatch with the power-unit strip flat teal (#3FE0D0); the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

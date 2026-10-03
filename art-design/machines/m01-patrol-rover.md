# Patrol Rover

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M01\
**Category:** machines\
**First appearance:** Level 1 (Welcome to Sunnyvale); returns in Levels 2–4 and 6; a Garden-built copy appears in Level 10\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Visual reference status

**Look chosen (2026-09-30):** [m01-patrol-rover-look-v1.webp](../../concept-art/m01-patrol-rover/m01-patrol-rover-look-v1.webp), a lit concept of the light cyberpunk look with its magenta flank strip and underglow (C36). It is a look reference, not the source painting. It changes two things in this brief, and the parts sheet follows the concept: the body is longer and lower, like a small car, and the sensor is a hooded pod on the hood (a dark visor with one amber lens) in place of the smoked roof dome. **Parts sheet in the game (2026-10-03):** [m01-patrol-rover-parts-v1.webp](../../concept-art/m01-patrol-rover/m01-patrol-rover-parts-v1.webp), imported with `tools/art/import_parts_sheet.py`. The sheet's seven parts (chassis, bumper, sensor pod, lightbar, hatch lid, battery, one wheel used four times) are assembled on the chassis; the side panel under the lid is repainted as the open battery bay, and the lid hinges at its front edge. In the game the rover is 92 px long and about 43 px tall, and its body box grew from 64 to 92 px to match. The Patrol Rover is a fresh design (C32): the earlier ground robot was removed entirely, and nothing of its look carries over.

The route follows the Night Guard's ([SE01](../security/se01-night-guard.md)): generate a lit concept of the look from the look prompt below and approve one; then paint the flat rig parts from it with prompt 4 and import the sheet with `tools/art/import_parts_sheet.py`. Prompts 1–3 remain for neutral design and pose studies.

## Identity and role

Ground charger: a low security patrol robot that rocks back, then rams along its floor.

**Who built and fields it *(proposed)*:** Arcadia's security division built the Patrol Rover to roll the campus paths, plazas and car parks after hours. It was an unarmed unit whose job was to be seen and to nudge trespassers along, and a speed governor kept it slow. It patrols Sunnyvale in Level 1, returns through Levels 2–4 and 6, and Adam builds a Garden copy for Level 10.

**Why it attacks Dave:** Adam has flagged Dave as a hazard on the rover's route and overridden its speed governor. Its announcement is the tell: "Speed limit override accepted." It is entirely mechanical, with no implant hardware and no cab.

## Scale and silhouette

0.85 m tall to the top of the dome; 1.35 m long including the bumper; about half Dave's height.

A squat wedge on four fat wheels: a low, wide chassis that rises toward the rear, a padded rounded bumper across the nose, a smoked sensor dome on the front third of the roof, a long flat lightbar on the rear roof, and a hinged battery hatch on the rear deck. It reads as a small security vehicle, not as an animal or a garden tool.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Chassis:** a rounded-rectangular body with deep wheel arches, a low nose and a higher rear deck. Four chunky rubber wheels with plain flat hubs (two visible in side view, two hidden; occlusion does not remove them). A few large hex bolts on the skirt and a rear tow ring.
- **Bumper:** a thick, dark, padded push-bumper wraps the nose over a low skid plate. It is the ram.
- **Sensor dome:** a smoked half-dome about 0.35 m across on a short collar. Inside sits one graphite sensor puck with a single round lens. Exactly one lens: no stalks and no second eye.
- **Lightbar:** a slim horizontal lightbar in a dark housing on the rear roof, with six flat lens segments, drawn unlit.
- **Livery:** a pearl-white upper shell, an Arcadia-grey skirt (the guards' livery, [SE01](../security/se01-night-guard.md)) and a thin magenta neon strip (#FF3DD5) along the flank, with a blank shield-shaped ID plate on the door panel (no text, no logo). The strip is painted as a flat bright color with no glow.
- **Battery hatch:** a hinged lid on the rear deck with three vent slots. Under it sits a graphite battery block with a teal gauge strip. The lid is closed in the neutral pose.

**Garden-built skin** *(Level 10, proposed)*: a repaint of the same parts: raw unglazed ceramic panels with petal-shaped fairing edges in place of the white and grey shell, dark seam lines and a pale ceramic dome, with the same lightbar, bumper and hatch. Like every Garden-built variant it shortens only the amber part of the tell; red stays 0.25 s.

## Color and materials

*Proposed palette:* pearl white #DAD8CB; Arcadia grey #4B5663; neon magenta flank strip #FF3DD5; bumper and tire black #1C232B; hub grey #4A5561; smoked dome #1B2431 over a graphite puck #3A4552; lightbar lenses amber-tinted #C98A2B, unlit; battery block graphite #2E363E with a teal gauge strip #3FE0D0. *Garden-built skin:* cool ceramic #D8DEE3, ceramic shadow #8FA1B0 (far-side wheels and recesses, a flat color), seam dark #2E3B4E.

Everything is painted as flat base colors with clean dark outlines and no baked shadow. The engine's lamps light the shell and the dome smoothly through their normal maps. Keep the white shell a little darker than pure white so the lightbar glow stays the brightest shape on the machine, and paint the far-side wheels a few percent darker as a flat color, not a shadow. Teal appears on the machine only as the battery gauge, since teal on a machine marks a power unit.

**Light and fluid *(proposed)*:**

- While it patrols, the dome lens shows only a small, dim, steady amber point (#FFB02E).
- **Neon (C36):** the magenta flank strip is its type's neon. The engine makes it glow steadily (painted flat #FF3DD5, marked in the emissive mask) and adds a soft magenta underglow on the floor beneath the chassis. Both stay thinner and dimmer than the tell, never touch the bumper (the attacking part) or the battery (the weak point), and go dark when it is destroyed.
- The tell is a large additive glow on the lightbar: amber, then alarm red #FF3B4E for the last 0.25 s, as the body rocks back.
- After the stall the battery hatch pops open and the battery glows Adam teal #3FE0D0, the brightest shape on the machine, so the opening reads from either side.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Charger (C26). **Weapon:** ram (the padded bumper). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** it rocks back onto its rear wheels, nose up, as the lightbar goes amber and then red (red for the last 0.25 s), and it announces "Speed limit override accepted."
- **Attack:** it charges 4 H along its floor, nose down, bumper first.
- **Counter:** jump it, or bait it into a wall, then shoot the battery during the stall. 3 hits.

It patrols at a steady roll with a small suspension bounce and cannot follow Dave into the air. A charge that hits a wall ends in a stall: the wheels spin, the body slews, and the rear hatch pops open.

## Openings and limitations

The stall after a wall hit is the opening. The rear battery hatch pops open on its hinge and shows the battery block glowing teal, visible in profile from either side; the flung lid and the glow carry the cue if a background glow competes. The exposed battery is the target. The dome, bumper and wheels are plain armor.

## Rig parts, normal maps and sockets

- **Parts (rigid):** chassis with wheel arches; front bumper and skid plate; sensor dome; sensor puck with its lens (its own light layer); lightbar housing with a separate lens layer; rear battery hatch lid; battery block with its gauge (a light layer); four wheels (two near, two far); tow ring.
- **Pivots:** the hatch hinge at the lid's front edge; each wheel hub; the chassis pitch pivot at mid-wheelbase for the rock-back.
- **Normal maps:** one per part, green = up: a smooth dome curve, a padded bulge on the bumper, shallow panel grooves and bolt heads on the shell, tread relief on the tires.
- **Sockets:** no gun socket. Light sockets at the dome lens (small, steady), the lightbar (large tell glow) and the battery (teal). Spark points at the bumper, hatch and dome; an oil drip point under the chassis.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts (Mixamo clips are humanoid) *(proposed)*. On death the machine bursts into debris parts: the dome, lightbar, hatch lid, bumper, four wheels, battery block and the two shell halves become physics bodies pushed by the killing shot, then settle as a static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Patrol roll (neutral side view, hatch closed); rock-back wind-up (nose up, lightbar amber, then red); charge (nose down, bumper first); wall stall with the hatch open and the battery exposed; hit reaction; wreck (the static corpse). Skins: standard shell and Garden-built ceramic.

Show lamp states as flat colored shapes with no glow halo. Glows, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Exactly four wheels (two visible), one dome with one lens, one lightbar, one padded bumper and one rear battery hatch. No eye stalks, no shears or blades, no arms or legs, no animal face, no pear-shaped watering-can shell and no rear roller: nothing from the removed design. No text, logos or license plates. The lightbar is the tell lamp: amber, or red for the last 0.25 s of the tell only, never teal or violet. Sparks and oil are effects, never painted in.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The rover is symmetrical apart from the blank ID plate, a plain shield shape that is mirror-safe (no text). The lightbar, dome and hatch sit on the centerline, so it mirrors safely.

## Look prompt — lit concept (C36)

A look test, not the source painting: it asks for lit concept art (night, neon, lamps) so it shows how the rover should feel in the game. Approve one, then paint the parts flat from it with prompt 4.

```text
Original 2D concept art for DEAD EDEN, a mature dark sci-fi side-view platformer shooter. Look: light cyberpunk at night. Deep navy-black darks lit by neon trim, screens and practical lamps; strong, saturated colors against the dark; high contrast, never washed out, never pastel. Clean painted shapes with crisp near-black outlines, smooth realistic lighting with soft glows around light sources and a faint cool moonlight rim. Not photorealistic, not anime, not pixel art. No text, logos, watermark or UI.

Subject: the Patrol Rover, Arcadia's squat wheeled campus-security robot with its speed governor removed, in strict side view facing right. About half a person's height (0.85 m tall, 1.35 m long): a rounded wedge body with deep wheel arches that rises toward the rear, four chunky rubber wheels, a thick padded black push-bumper on the nose, a small smoked sensor dome with one round lens showing a tiny dim amber point, a slim unlit lightbar on the rear roof, and a closed battery hatch on the rear deck. Pearl-white upper shell (#DAD8CB) over an Arcadia-grey skirt (#4B5663).
Neon: a thin glowing magenta (#FF3DD5) light strip along the flank and a magenta underglow washing the wet paving beneath it. This is its only neon; the bumper and the battery hatch have none.
Setting: wet dark paving on a night campus, a cold white path lamp to one side, the magenta underglow reflected in puddles, dark glass office wings behind. No eye stalks, blades or arms. No text or logos.
```

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Patrol Rover, an unmanned campus security robot. Role: ground charger, a low security patrol robot that rocks back, then rams along the floor.
Scale: 0.85 m tall to the top of the dome; 1.35 m long including the bumper; about half the height of an adult.
Silhouette: A squat wedge on four fat wheels: a low, wide chassis that rises toward the rear, a padded rounded bumper across the nose, a smoked sensor dome on the front third of the roof, a long flat lightbar on the rear roof and a hinged battery hatch on the rear deck. It reads as a small security vehicle.
Physical design: A rounded-rectangular body with deep wheel arches, a low nose and a higher rear deck; four chunky rubber wheels with plain flat hubs (two visible in side view); a few large hex bolts on the skirt and a rear tow ring. A thick, dark, padded push-bumper wraps the nose over a low skid plate. A smoked half-dome about 0.35 m across on a short collar holds one graphite sensor puck with a single round lens: exactly one lens, no stalks. A slim horizontal lightbar in a dark housing on the rear roof with six flat, unlit lens segments. A pearl-white upper shell, an Arcadia-grey skirt, a thin flat magenta (#FF3DD5) strip along the flank and a blank shield-shaped ID plate with no text. A closed, hinged battery hatch lid with three vent slots on the rear deck.
Materials and colors: Pearl white #DAD8CB; Arcadia grey #4B5663; flat magenta flank strip #FF3DD5, no glow; bumper and tire black #1C232B; hub grey #4A5561; smoked dome #1B2431 over a graphite puck #3A4552; lightbar lenses amber-tinted #C98A2B, unlit; the lens a small, flat, dull amber disc. No teal paint. Flat base colors only.
Critical consistency: Exactly four wheels (two visible), one dome with one lens, one lightbar, one padded bumper, one rear battery hatch. No eye stalks, no shears or blades, no arms or legs, no animal face, no pear-shaped watering-can shell, no rear roller. No text, logos or license plates.
Use a relaxed neutral rolling pose with the hatch closed and the body level, the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Patrol Rover design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 0.85 m tall to the top of the dome; 1.35 m long including the bumper; about half the height of an adult. Maintain these defining forms: A squat wedge on four fat wheels: a low, wide chassis that rises toward the rear, a padded rounded bumper across the nose, a smoked sensor dome on the front third of the roof, a long flat lightbar on the rear roof and a hinged battery hatch on the rear deck. It reads as a small security vehicle. Preserve construction: A rounded-rectangular body with deep wheel arches, a low nose and a higher rear deck; four chunky rubber wheels with plain flat hubs (two visible in side view); a few large hex bolts on the skirt and a rear tow ring. A thick, dark, padded push-bumper wraps the nose over a low skid plate. A smoked half-dome about 0.35 m across on a short collar holds one graphite sensor puck with a single round lens: exactly one lens, no stalks. A slim horizontal lightbar in a dark housing on the rear roof with six flat, unlit lens segments. A pearl-white upper shell, an Arcadia-grey skirt, a thin flat magenta (#FF3DD5) strip along the flank and a blank shield-shaped ID plate with no text. A closed, hinged battery hatch lid with three vent slots on the rear deck. Preserve the palette: Pearl white #DAD8CB; Arcadia grey #4B5663; flat magenta flank strip #FF3DD5, no glow; bumper and tire black #1C232B; hub grey #4A5561; smoked dome #1B2431 over a graphite puck #3A4552; lightbar lenses amber-tinted #C98A2B, unlit; the lens a small, flat, dull amber disc. No teal paint. Flat base colors only. Lock these details: Exactly four wheels (two visible), one dome with one lens, one lightbar, one padded bumper, one rear battery hatch. No eye stalks, no shears or blades, no arms or legs, no animal face, no pear-shaped watering-can shell, no rear roller. No text, logos or license plates. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Patrol Rover reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Patrol roll; rock-back wind-up; charge; wall stall with the hatch open; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It patrols at a steady roll with a small suspension bounce. Before charging it rocks back onto its rear wheels, nose up, with the lightbar amber and then red. It charges nose down, bumper first, and a wall hit ends in a stall with the wheels spinning and the rear hatch popping open. Capability: Charges 4 H along a floor and rams with its padded bumper. It cannot follow a target into the air. A wall collision creates a stall. Important limitation or opening: The rear battery hatch pops open during the stall and shows the battery block; the battery is the target. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or gun: the patrol roll shows one small flat dull-amber lens disc and unlit lightbar segments; the rock-back wind-up shows the lightbar segments flat amber (#FFB02E), or flat alarm red (#FF3B4E) for the last quarter of the wind-up; the charge keeps red segments; the wall stall shows unlit segments and an open hatch with the battery strip flat teal (#3FE0D0); the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Image prompt 4 — rig parts sheet

Attach the approved look reference. This turns the lit concept into the flat source painting, already split into the rig's parts. Save the result as a PNG for import: the importer snaps colors to this palette, darkens the outlines, and turns the exact magenta into the glow mask. One wheel is painted; the rig uses it for all four and darkens the far pair.

```text
Using the attached approved Patrol Rover concept as the exact design reference, paint a 2D cutout-rig parts sheet of the same machine for a side-view game. Same machine, same shapes, same proportions and same details (the long low body with its angular grey wheel arches, the stepped magenta flank strip, the black push-bumper, the hooded sensor pod with its one amber lens, the lightbar on its raised mount, the rear hatch panel with its two latches, the bolts and the small skirt panel): not a redesign. The reference is lit at night; this sheet is not. Convert it to flat, evenly lit base colors and remove the lamp light, underglow, reflections, rain and shadows.

Style: flat base colors, evenly lit. No shadows, no highlights, no rim light, no gradients, no glow, no sparks, no oil. Paint the sensor lens and the lightbar segments dull and unlit.

Color: keep every color at its exact hex value at full strength. Do not lighten, fade, desaturate or grey out the image. Darks stay dark: the bumper and tires are near-black, the skirt and wheel arches are a mid-dark blue-grey, the sensor visor is dark smoked glass, and the pearl-white shell is the only large light area. Paint the flank strip as flat, bright magenta #FF3DD5 with no glow or halo; the game makes it glow.

Outlines: crisp near-black (#0B0D10), about 3-4 px on the outer contour and 1-2 px inside.

Background: transparent. If transparency is not possible, a flat solid mid-grey (#808080) with no texture, noise or vignette.

Layout: a landscape canvas. Draw each part below as a separate, complete piece, as seen in the right-facing side view, all at the same scale (the assembled machine would be about 1200 px long). Leave at least 40 px of empty space between parts; no part may touch or overlap another. No labels, text, numbers, grid lines, frames or drop shadows.

Parts, exactly these, once each:
1. Chassis: the whole body with its wheel arches cut out empty, the pearl-white upper shell, the grey skirt and arches, the stepped magenta flank strip, the bolts and the small skirt panel. No wheels, no bumper, no sensor pod, no lightbar and no hatch panel attached. Where the rear hatch panel sits, paint the open battery bay as a dark recess. Paint the body complete behind where the other parts will cover it.
2. Bumper: the thick black blocky push-bumper, as it wraps the nose, with a flat back edge that tucks under the chassis nose.
3. Sensor pod: the white hood on the front deck with its dark smoked visor and the single round lens inside, the lens a small flat dull-amber disc.
4. Lightbar: the slim dark housing on its raised mount, with six flat unlit amber-tinted lens segments along its side, the mount's base tucking into the roof.
5. Rear hatch panel: closed, the same white panel with its two latches along the bottom edge, and a hinge along its top edge.
6. Battery block: graphite with a thin teal gauge strip along its side.
7. One wheel: the chunky treaded rubber tire with its flat hub and four bolts, seen square-on, perfectly round.

Joints: give the bumper, sensor pod, lightbar and hatch panel an edge that extends about 20 px past where they meet the chassis, painted in the same material, so the pieces overlap when assembled and no gap shows when they move.

Palette: pearl white #DAD8CB; Arcadia grey #4B5663; neon magenta flank strip #FF3DD5; bumper and tire black #1C232B; hub grey #4A5561; smoked visor #1B2431; lens dull amber #C98A2B; lightbar lenses amber-tinted #C98A2B; battery graphite #2E363E with teal gauge strip #3FE0D0; bay recess #14181E. No text or logos, no eye stalks, no blades, no arms, no gun, no underglow.
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

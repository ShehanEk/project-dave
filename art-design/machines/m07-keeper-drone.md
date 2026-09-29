# Keeper Drone

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M07\
**Category:** machines\
**First appearance:** Level 8 (The Memory Orchard); returns in Levels 9 and 11\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Hovering archivist: a slow drone that walks its path with a lantern, and once per lap swells the lantern and releases one homing seeker.

**Who built and fields it *(proposed)*:** the Memory Orchard's keepers were built by Arcadia's archive team to patrol the server trees, carry a lantern along the rows and log every copied mind. The Orchard is where Adam copied the staff, so the keepers are Adam's own. It works the Memory Orchard in Level 8 and returns in Levels 9 and 11. The seeker it releases is Adam's own hunting ammunition ([EG08](../enemy-guns/eg08-seeker.md)).

**Why it attacks Dave:** Adam files Dave as a trespasser among the memories. On each lap the drone murmurs a fragment of a dead employee's voice, a processed recording with a subtitle, before it lets the seeker go. It is entirely mechanical.

## Scale and silhouette

1.00 m tall including the lantern; 0.70 m across the brim and crook.

An upright, spindle-shaped pod hovering under a wide, flat brim ring, with a slim curved crook arm that carries a frosted glass lantern out in front. Three small fins sit at the base. The lantern hangs at about belly height, well clear of the body, so it reads as the machine's one bright, hanging object.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Pod:** a narrow spindle of pale parchment enamel with a slim vertical speaker grille (the murmur; there is no mouth or face) and a small round status lens under the brim.
- **Brim ring:** a wide, flat, dark ring-shaped fan duct around the top of the pod, like a hat brim. The spinning fan is a separate blur layer (a two-frame swap), not painted in.
- **Crook and lantern:** a thin pewter crook arm curves out from the front of the pod and carries a hanging frosted glass lantern in a slim steel cage. A round launch port ring, about 0.14 m across, sits at the lantern's base. The lantern is drawn empty and unlit; the seeker ([EG08](../enemy-guns/eg08-seeker.md)) is a separate projectile sprite that leaves the port along its axis.
- **Fins:** three small stabilizer fins around the base (two visible in profile).
- **Wear:** faint dust on the pod, and a thin gauge strip low on the pod with three unlit segments.

## Color and materials

*Proposed palette:* pod parchment enamel #D8D2BC; pewter fittings and crook #8C949A; brim ring and fins charcoal #2E363E; lantern frosted glass #E8EEF0 in a dark steel cage #46566A; launch port ring pewter #8C949A with a dark inner rim #14181E; speaker grille #1B2431; gauge strip teal #3FE0D0. The warm parchment and pewter keep it readable against the Memory Orchard's cold teal shimmer.

Everything is painted as flat base colors with clean dark outlines and no baked shadow; the engine's lamps and the lantern's own light light the pod and cage through their normal maps. Keep the frosted glass a little darker than pure white so the swelling lantern glow stays the brightest shape on the machine.

**Light and fluid *(proposed)*:**

- The status lens and the lantern's core show only a small, dim, steady amber point (#FFB02E).
- The tell is a large additive glow that swells in the lantern and around its launch port: amber, then alarm red #FF3B4E for the last 0.25 s, with a sonar ping and the murmur (with its subtitle). The tell is on the port, never on the seeker.
- The seeker is a separate projectile: a small pale finned teardrop with a white-core lens and a short wisp, never amber, red or teal.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects; the lantern glass cracks and drops shards on death. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Drone (path mode) (C26). **Weapon:** Seeker ([EG08](../enemy-guns/eg08-seeker.md)). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (CHARGE):** once per lap its lantern swells amber and then red (red for the last 0.25 s), with a sonar ping and a dead employee's murmur.
- **Attack:** it releases one seeker: 3 H/s, turning at most 90 degrees per second, a 2.5 s life, then it fizzles. One damage. At most 2 alive.
- **Counter:** jump the seeker late so it overshoots, lead it into a wall or shoot it down (one bolt kills it), and hit the drone on its low pass. 3 hits.

It drifts along its path at a walking pace with a slow bob, rising on the high pass and dipping to head height on the low pass, the lantern swinging below it. It never stops to aim: the lap is the whole pattern.

## Openings and limitations

The low pass: the drone dips to head height with the lantern swinging below it. There is no armor and no shell to open, so a hit anywhere counts. The seeker is itself a target: a shootable finned round with its own hit zone.

## Rig parts, normal maps and sockets

- **Parts (rigid):** pod; brim ring with its fan-blur layer; three fins; crook arm; lantern cage; lantern glass with its inner glow (a light layer); launch port ring (its own part, with a glow layer); speaker grille; status lens (a light layer); gauge strip (a light layer).
- **Pivots:** the crook arm at the front of the pod (a slight sway); the pod tilts a little with its path speed.
- **Normal maps:** one per part, green = up: the spindle curve, the brim ring, pewter fittings, cage bars, the soft bump of the frosted glass, the port ring's rim.
- **Sockets:** no gun socket. The seeker ([EG08](../enemy-guns/eg08-seeker.md)) launches from the lantern port: its muzzle marker sits at the port's center, and the round leaves along the port's axis before turning toward its heading. Light sockets at the status lens (small, steady) and the lantern and port (large tell glow). Spark points at the pod and brim; an oil drip point under the pod.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts (Mixamo clips are humanoid) *(proposed)*. On death it bursts into debris parts: the lantern cage and glass (glass shards), crook, brim ring, fins and pod halves become physics bodies pushed by the killing shot, then settle as a static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Path drift (neutral, lantern dim); lantern swell warning (lantern amber, then red); seeker release (the port ring lit, the seeker shown only as a plain pale teardrop leaving it); low pass (dipped to head height); hit reaction; wreck (the static corpse).

Show lamp states as flat colored shapes with no glow halo. Glows, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One pod, one brim ring, one crook, one lantern with one launch port, and three fins. No face, eyes, mouth or hands: the speaker grille is the only voice. The seeker is never painted into the lantern in the base art. No text or logos. The lantern is amber, or red for the last 0.25 s of the tell only, never violet, and teal appears only on the gauge strip.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The crook and lantern point along the facing and mirror with it, and the pod is symmetrical, so the drone mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Keeper Drone, an unmanned archive-keeper drone that carries a lantern. Role: hovering archivist drone that swells a hanging lantern and releases one homing seeker per lap.
Scale: 1.00 m tall including the lantern; 0.70 m across the brim and crook.
Silhouette: An upright, spindle-shaped pod hovering under a wide, flat brim ring, with a slim curved crook arm that carries a frosted glass lantern out in front at about belly height, and three small fins at the base.
Physical design: A narrow spindle of pale parchment enamel with a slim vertical speaker grille (no mouth, no face) and a small round status lens under the brim. A wide, flat, dark ring-shaped fan duct around the top of the pod like a hat brim, with no painted-in fan blur. A thin pewter crook arm curving out from the front of the pod carries a hanging frosted glass lantern in a slim steel cage, with an empty round launch port ring about 0.14 m across at its base; the lantern is unlit. Three small stabilizer fins around the base, two visible in profile. Faint dust on the pod and a thin gauge strip with three unlit segments.
Materials and colors: Pod parchment enamel #D8D2BC; pewter fittings and crook #8C949A; brim ring and fins charcoal #2E363E; lantern frosted glass #E8EEF0 in a dark steel cage #46566A; launch port ring pewter with a dark inner rim #14181E; speaker grille #1B2431; gauge strip teal #3FE0D0; the status lens a small, flat, dull amber disc. Flat base colors only.
Critical consistency: One pod, one brim ring, one crook, one lantern with one launch port, three fins. No face, eyes, mouth or hands. No seeker or projectile painted into the lantern, no gun. No text or logos.
Use a relaxed neutral hovering pose with the crook and lantern hanging still and the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). The lantern and its launch port are part of the drone and are painted, empty and unlit. Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Keeper Drone design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 1.00 m tall including the lantern; 0.70 m across the brim and crook. Maintain these defining forms: An upright, spindle-shaped pod hovering under a wide, flat brim ring, with a slim curved crook arm that carries a frosted glass lantern out in front at about belly height, and three small fins at the base. Preserve construction: A narrow spindle of pale parchment enamel with a slim vertical speaker grille (no mouth, no face) and a small round status lens under the brim. A wide, flat, dark ring-shaped fan duct around the top of the pod like a hat brim, with no painted-in fan blur. A thin pewter crook arm curving out from the front of the pod carries a hanging frosted glass lantern in a slim steel cage, with an empty round launch port ring about 0.14 m across at its base; the lantern is unlit. Three small stabilizer fins around the base, two visible in profile. Faint dust on the pod and a thin gauge strip with three unlit segments. Preserve the palette: Pod parchment enamel #D8D2BC; pewter fittings and crook #8C949A; brim ring and fins charcoal #2E363E; lantern frosted glass #E8EEF0 in a dark steel cage #46566A; launch port ring pewter with a dark inner rim #14181E; speaker grille #1B2431; gauge strip teal #3FE0D0; the status lens a small, flat, dull amber disc. Flat base colors only. Lock these details: One pod, one brim ring, one crook, one lantern with one launch port, three fins. No face, eyes, mouth or hands. No seeker or projectile painted into the lantern, no gun. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Keeper Drone reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Path drift; lantern swell warning; seeker release; low pass; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It drifts along its path at a walking pace with a slow bob, the lantern swinging below the crook. Once per lap the lantern swells as it drifts, then the seeker leaves the launch port at the lantern's base. On the low pass it dips to head height. Capability: Releases one shootable homing seeker per lap from its lantern's launch port. Important limitation or opening: On the low pass the drone dips to head height and is exposed; there is no armor, and the seeker is itself a target. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks or oil, and draw the seeker only as a plain pale finned teardrop shape where the state needs it: the path drift shows one small flat dull-amber status lens disc and a pale unlit lantern; the lantern swell warning shows the lantern glass and port ring flat amber (#FFB02E), or flat alarm red (#FF3B4E) for the last quarter of the warning; the seeker release shows the port ring dim and the lantern dim; the low pass shows the small amber lens disc; the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

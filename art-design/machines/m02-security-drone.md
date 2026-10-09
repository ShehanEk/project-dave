# Security Drone

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M02\
**Category:** machines\
**First appearance:** Level 2 (Curfew); returns in Levels 3–6; Garden-built copies appear in Levels 10–12\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Flying diver: a hovering security drone that noses up, then dives at the spot where Dave stood.

**Who built and fields it *(proposed)*:** Arcadia's security division built it to hover over the campus paths, terraces and car parks at night, with a lightbar and a crowd-control shock fork. Adam runs the fleet. It patrols the campus in Levels 2–3, returns through Levels 4–6, and Adam builds Garden copies for Levels 10–12.

**Why it attacks Dave:** the campus is under curfew, and Adam has logged Dave as the violation. Its announcement is "Curfew is in effect." *(proposed line)*. It is entirely mechanical, with no implant hardware.

## Scale and silhouette

0.80 m long hull; 1.05 m long with the shock fork extended; 0.55 m tall including the fan nacelles.

A slim pill-shaped hull with a flat back, a dark canopy on the nose, two chunky ducted-fan nacelles standing on short pylons above the hull (one forward, one aft), a lightbar wrapped around the upper hull between them, a small tail fin, and a two-pronged shock fork folded under the nose. It hovers level, noses up for the tell and noses down for the dive.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Hull:** a pearl-white upper hull over an Arcadia-grey belly (the guards' livery, [SE01](../security/se01-night-guard.md)) with a pale reflective band between them, a blank shield-shaped ID plate on the flank (no text) and two short landing skids.
- **Canopy:** a dark smoked half-dome on the nose with one round lens.
- **Nacelles:** two thick ducted-fan pods on short pylons, each a graphite cylinder with a steel intake grille on top and a plain shroud ring. The spinning fans are a separate blur layer (a two-frame swap), not painted into the pod.
- **Lightbar:** a slim bar wrapping the upper hull between the nacelles, with five flat lens segments, drawn unlit.
- **Shock fork:** two blunt steel prongs on an insulated ceramic collar under the nose, folded back against the belly at rest. They swing forward and down for the dive. Their tips carry pale ceramic insulator caps.
- **Tail:** a short tail boom with one small stabilizer fin, so the pitch reads clearly in profile.

**Garden-built skin** *(Levels 10–12, proposed)*: a repaint of the same parts: raw unglazed ceramic hull and nacelle shrouds with petal-shaped fairing edges and dark seam lines, and the same steel fork. Like every Garden-built variant it shortens only the amber part of the tell; red stays 0.25 s.

## Color and materials

*Proposed palette:* pearl white #DAD8CB; Arcadia grey #4B5663; pale reflective band #D3DAE0; nacelle graphite #2E363E with steel grilles #6B7785; smoked canopy #1B2431; fork steel #8A95A3 with ceramic caps #D8DEE3; lightbar lenses amber-tinted #C98A2B, unlit. *Garden-built skin:* cool ceramic #D8DEE3, ceramic shadow #8FA1B0 (a flat color), seam dark #2E3B4E.

Everything is painted as flat base colors with clean dark outlines and no baked shadow; the engine's lamps light the hull and canopy through their normal maps. Keep the pale hull a little darker than pure white so the lightbar glow stays the brightest shape on the machine, and keep the grey belly lighter than the night scenery so the underside still reads.

**Light and fluid *(proposed)*:**

- While it hunts, the canopy lens shows only a small, dim, steady amber point (#FFB02E).
- The tell is a large additive glow on the lightbar: amber, then alarm red #FF3B4E for the last 0.25 s, as the nose comes up. After the dive the lightbar drops back to the small point.
- The fork's discharge is a separate pale blue-white arc effect, never painted in.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Drone (dive) (C26). **Weapon:** shock prongs (melee dive). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** it noses up and stops almost still as the lightbar goes amber and then red (red for the last 0.25 s), announcing "Curfew is in effect." *(proposed)*.
- **Attack:** it dives in a straight, committed line at Dave's locked spot. It cannot redirect once the dive begins.
- **Counter:** sidestep the dive, then hit it while it hangs at head height. 2 hits.

It drifts along its patrol path at chest height with a slight bob. In the dive the fork swings forward and the fans scream up. After the strike it hangs at head height, fans spooling down and the fork smoking, before it climbs away.

## Openings and limitations

After the dive it hangs at head height with the fork spent: that is the opening. The whole hull is exposed, with no shell to open and no invulnerable state. The fans winding down and the lightbar's small amber point mark it as safe to hit.

## Rig parts, normal maps and sockets

- **Parts (rigid):** hull (upper hull and belly as one part); canopy with its lens (a light layer); two nacelles with pylons, each with its own fan-blur layer; tail boom with fin; lightbar (a light layer); shock fork (two prongs on a collar); two skids.
- **Pivots:** the fork collar hinge under the nose; the hull's pitch pivot at its center for the nose-up and dive poses.
- **Normal maps:** one per part, green = up: a smooth domed canopy, ribbed nacelle shrouds and grilles, shallow panel seams on the hull.
- **Sockets:** no gun socket. Light sockets at the canopy lens (small, steady), the lightbar (large tell glow) and the fork tips (arc effect). Spark points at the nacelles and fork; an oil drip point under the belly.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts, like every enemy (C38). On death it bursts into debris parts: the nacelles, canopy, fork, tail fin and the two hull halves become physics bodies pushed by the killing shot, fall, and settle as a static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Hover (neutral, level); nose-up warning (lightbar amber, then red); dive (fork out, nose down); strike and hang at head height (fork smoking, fans slowing); hit reaction; wreck (the static corpse). Skins: standard shell and Garden-built ceramic.

Show lamp states as flat colored shapes with no glow halo. Glows, arcs, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One hull, one canopy lens, exactly two nacelles, one lightbar, one tail fin and one two-pronged fork. No wings or vanes, no antennae, no insect legs or stripes, no gun, no rockets and no humanoid parts. No text or logos, and no teal on the paint. The lightbar is amber, or red for the last 0.25 s of the tell only, never teal or violet. The fork's arc is a separate effect.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The drone is symmetrical apart from the blank ID plate, a plain shield shape that is mirror-safe (no text). The nacelles, lightbar and fork sit on the centerline, so it mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Security Drone, an unmanned hovering campus security drone. Role: flying diver that noses up, then dives at a locked spot with a shock fork.
Scale: 0.80 m long hull; 1.05 m long with the shock fork extended; 0.55 m tall including the fan nacelles.
Silhouette: A slim pill-shaped hull with a flat back, a dark canopy on the nose, two chunky ducted-fan nacelles on short pylons above the hull (one forward, one aft), a lightbar wrapped around the upper hull between them, a small tail fin, and a two-pronged shock fork folded under the nose.
Physical design: A pearl-white upper hull over an Arcadia-grey belly with a pale reflective band between them, a blank shield-shaped ID plate on the flank with no text, and two short landing skids. A dark smoked half-dome canopy on the nose with one round lens. Two thick ducted-fan pods on short pylons, each a graphite cylinder with a steel intake grille on top and a plain shroud ring, with no painted-in fan blur. A slim lightbar with five flat, unlit lens segments wrapping the upper hull between the nacelles. Two blunt steel prongs with pale ceramic insulator caps on an insulated ceramic collar under the nose, folded back against the belly. A short tail boom with one small stabilizer fin.
Materials and colors: Pearl white #DAD8CB; Arcadia grey #4B5663; pale reflective band #D3DAE0; nacelle graphite #2E363E with steel grilles #6B7785; smoked canopy #1B2431; fork steel #8A95A3 with ceramic caps #D8DEE3; lightbar lenses amber-tinted #C98A2B, unlit; the canopy lens a small, flat, dull amber disc. No teal paint. Flat base colors only.
Critical consistency: One hull, one canopy lens, exactly two nacelles, one lightbar, one tail fin, one two-pronged fork. No wings or vanes, no antennae, no insect legs or stripes, no gun, no rockets, no humanoid parts, no text or logos.
Use a relaxed neutral hover pose, level, with the fork folded under the nose and the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Security Drone design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 0.80 m long hull; 1.05 m long with the shock fork extended; 0.55 m tall including the fan nacelles. Maintain these defining forms: A slim pill-shaped hull with a flat back, a dark canopy on the nose, two chunky ducted-fan nacelles on short pylons above the hull (one forward, one aft), a lightbar wrapped around the upper hull between them, a small tail fin, and a two-pronged shock fork folded under the nose. Preserve construction: A pearl-white upper hull over an Arcadia-grey belly with a pale reflective band between them, a blank shield-shaped ID plate on the flank with no text, and two short landing skids. A dark smoked half-dome canopy on the nose with one round lens. Two thick ducted-fan pods on short pylons, each a graphite cylinder with a steel intake grille on top and a plain shroud ring, with no painted-in fan blur. A slim lightbar with five flat, unlit lens segments wrapping the upper hull between the nacelles. Two blunt steel prongs with pale ceramic insulator caps on an insulated ceramic collar under the nose, folded back against the belly. A short tail boom with one small stabilizer fin. Preserve the palette: Pearl white #DAD8CB; Arcadia grey #4B5663; pale reflective band #D3DAE0; nacelle graphite #2E363E with steel grilles #6B7785; smoked canopy #1B2431; fork steel #8A95A3 with ceramic caps #D8DEE3; lightbar lenses amber-tinted #C98A2B, unlit; the canopy lens a small, flat, dull amber disc. No teal paint. Flat base colors only. Lock these details: One hull, one canopy lens, exactly two nacelles, one lightbar, one tail fin, one two-pronged fork. No wings or vanes, no antennae, no insect legs or stripes, no gun, no rockets, no humanoid parts, no text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Security Drone reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Hover; nose-up warning; dive; strike and hang at head height; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It drifts level at chest height with a slight bob. To attack it noses up and stops almost still, then noses down and dives in one straight committed line with the fork swung forward and down. After the strike it hangs at head height with the fork smoking and the fans slowing. Capability: Dives at a locked spot with a shock fork. It cannot redirect once the dive begins. Important limitation or opening: After the dive it hangs at head height with the fork spent; the whole hull is exposed with no separate shell. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or gun: the hover shows one small flat dull-amber canopy lens disc and unlit lightbar segments; the nose-up warning shows the lightbar segments flat amber (#FFB02E), or flat alarm red (#FF3B4E) for the last quarter of the warning; the dive keeps red segments; the strike-and-hang shows unlit segments and the small amber lens disc; the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

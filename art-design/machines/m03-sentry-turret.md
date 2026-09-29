# Sentry Turret

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** M03\
**Category:** machines\
**First appearance:** Level 4 (Roots and Rivets); returns in Levels 5–6, 8 and 11–12\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Fixed gun emplacement: an armored turret that opens a shutter, spins up a rotary gun and rakes its floor with a stream of fire.

**Who built and fields it *(proposed)*:** Arcadia's defense division sells it as "perimeter denial": a fixed emplacement for servers and vaults, armed with the HG-40 "Thresher" rotary ([EG03](../enemy-guns/eg03-machine-gun.md)). Arcadia and Thornwall bolted them across the Rootworks server halls, and Adam runs them, so they also guard the Memory Orchard and Adam's factory (Levels 8 and 11–12).

**Why it attacks Dave:** Adam has drawn a perimeter around the places Dave must cross, and Dave is inside it. It is entirely mechanical, with no implant hardware.

## Scale and silhouette

1.10 m tall on its pedestal; 0.90 m wide across the housing; about 1.60 m long with the rotary's barrels protruding 0.9 m from the shutter.

A squat armored housing on a swivel yoke atop a short bolted pedestal. A broad front shutter with a horizontal slot slides up to open a gun port, and the three-barrel rotary in its white shroud sits in that opening. A belt chute curves into the rear of the housing, and two vent flaps sit on top. It is a low, wide, defensive silhouette, bolted down.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Base:** a round steel base plate bolted to the floor with four large bolts, a short pedestal column and a swivel yoke.
- **Housing:** a broad, low armored shell of overlapping plates in graphite and pale ivory, with bone-white hazard stencil bars (no lettering) and a few visible fasteners. A small lens sits on the brow of the housing.
- **Shutter:** a heavy front shutter with a narrow horizontal slot. Closed at rest, it slides up when the gun is used.
- **Gun cradle:** an open cradle behind the shutter carries the gun on a mount point. The rotary itself ([EG03](../enemy-guns/eg03-machine-gun.md): three barrels in a white shroud with a heat collar) is a separate sprite: paint the cradle empty.
- **Belt feed:** a curved armored chute with a visible belt of ammunition links (dark round tips, no brass) enters the rear of the housing and meets the belt stub on the gun sprite.
- **Vents and core:** two hinged heat flaps on the top-rear of the housing hide a recessed core cell, a graphite cell in a dark recess ringed with vent slots. The flaps are closed in the neutral pose.

It is bolted to a floor, platform or catwalk and never hangs from a ceiling; the Pruner ([M08](m08-pruner.md)) is the high-mounted machine. It has no laser sight and no scanner.

## Color and materials

*Proposed palette:* housing graphite #2A3441 with pale ivory plates #CFCBB9; bone hazard bars #CFC9B2; base plate and pedestal slate #2E3B4E; shutter dark steel #46566A; yoke and joints navy #0E1726; core cell graphite #2E363E with a teal gauge strip #3FE0D0; brow lens glass #14181E.

Everything is painted as flat base colors with clean dark outlines and no baked shadow; the engine's lamps and the gun's muzzle flash light the plates, shutter and yoke through their normal maps. Keep the ivory plates a little darker than pure white so a muzzle flash reads as light on them, and keep the graphite housing lighter than the night scenery so the silhouette holds when the room is dim.

**Light and fluid *(proposed)*:**

- While it is on duty, the brow lens shows only a small, dim, steady amber point (#FFB02E).
- The tell is a large additive glow on the rotary's heat collar (part of the [EG03](../enemy-guns/eg03-machine-gun.md) sprite): it grows amber while the barrels spin up and the whine rises, then turns alarm red #FF3B4E for the last 0.25 s. Firing is one held muzzle glow, never a strobe.
- During the overheat the core cell glows Adam teal #3FE0D0 in its dark recess and vents steam, the brightest shape on the machine, so the opening reads from either side.
- Everything goes dark when it is destroyed.
- Hits throw white sparks and leak black oil (#14181E with a #46566A sheen rim), drawn as separate effects. Oil never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Turret (track) (C26). **Weapon:** Machine Gun, the HG-40 "Thresher" rotary ([EG03](../enemy-guns/eg03-machine-gun.md)). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (CHARGE):** the shutter slides up and the barrels spin up for about 1.0 s: the collar glow grows amber, the whine rises in pitch, then it turns red for the last 0.25 s.
- **Attack:** a 1.2 s stream of 12 rounds whose aim point creeps after Dave at 2.5 H/s with no lead. Then a 2.0 s overheat, rooted, venting steam.
- **Counter:** keep running (the aim cannot keep up) or get behind high cover, then hit the open core during the overheat. 3 hits.

The housing does not move except to track: the cradle pitches on the yoke to follow its aim point. Between attacks the shutter closes and the barrels stop.

## Openings and limitations

The overheat: the shutter stays up, the barrels wind down and the two top vent flaps lift, exposing the teal core in its dark recess with steam venting. The open core is the target. At rest the flaps are closed, plain armor.

## Rig parts, normal maps and sockets

- **Parts (rigid):** base plate; pedestal; yoke; housing; shutter (slides vertically); gun cradle; feed chute with its belt (one rigid part); two vent flaps; core cell (a light layer); brow lens (a light layer).
- **Pivots:** the gun cradle pivots on the yoke for tracking; each flap hinges at its rear edge; the shutter slides on two rails and has no pivot.
- **Normal maps:** one per part, green = up: plate edges and bolt heads, hazard bars as shallow stencil relief, vent slots, belt links.
- **Sockets:** the gun socket is a mount point on the cradle, where the [EG03](../enemy-guns/eg03-machine-gun.md) rotary sits by its center of balance with its own muzzle-flash light and a fixed muzzle marker at the barrel cluster. Light sockets at the brow lens (small), the rotary's collar (tell glow, on the gun sprite) and the core (teal). Steam vent points at the flaps; spark points at the plates and yoke; an oil drip point at the yoke.
- **Fluid:** white sparks and black oil, never blood.
- **Motion and death:** hand-keyed on the rigid parts (Mixamo clips are humanoid) *(proposed)*. On death it bursts into debris parts: the shutter, flaps, cradle, feed chute and housing halves fly off as physics bodies, and the rotary falls as a static prop. The base plate and pedestal stay bolted down, blackened, as the static wreck with a dark oil stain.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Neutral for the identity image (shutter raised, cradle empty, flaps closed); closed rest (shutter down); shutter rising with the gun tracking; spin-up (collar glow amber, then red for the last 0.25 s); firing stream (held muzzle glow); overheat vent with the core exposed and steam; hit reaction; wreck (the static corpse).

Show lamp states as flat colored shapes with no glow halo. The rotary is drawn in state studies only as a plain placeholder three-barrel gun in a white shroud, since it is the separate [EG03](../enemy-guns/eg03-machine-gun.md) sprite. Glows, steam, sparks and oil are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One three-barrel rotary (a separate sprite), one shutter, two top vent flaps, one core cell and one belt feed. No laser sight, scanning beam or sight line: the laser is gone and the spin-up is the tell. No petals, flower shapes, stalk or legs, and no ceiling mount. No text or logos and no human parts. The tell glow is amber, or red for the last 0.25 s only; the core glow is teal. Sparks, steam and oil are effects, never painted in.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The housing is symmetrical, the rotary points along the facing, and the belt chute enters the rear, so the turret mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Sentry Turret, a fixed armored gun emplacement for server halls. Role: fixed gun emplacement that opens a shutter, spins up a rotary gun and fires a stream that tracks its target.
Scale: 1.10 m tall on its pedestal; 0.90 m wide across the housing; the housing is about 0.7 m long without the gun.
Silhouette: A squat armored housing on a swivel yoke atop a short bolted pedestal, with a broad front shutter raised to show an empty open gun cradle, a belt chute curving into the rear of the housing and two hinged vent flaps on top. Low, wide and bolted down.
Physical design: A round steel base plate with four large bolts, a short pedestal column and a swivel yoke. A broad, low armored housing of overlapping graphite and pale ivory plates with bone-white hazard stencil bars (no lettering), a few visible fasteners and a small dark lens on the brow. A heavy front shutter with a narrow horizontal slot, drawn raised so that the open, empty gun cradle behind it is visible, and an armored ammunition belt chute with dark-tipped links entering the rear of the housing. Two closed hinged heat flaps on the top-rear hiding a recessed core cell.
Materials and colors: Housing graphite #2A3441 with pale ivory plates #CFCBB9; bone hazard bars #CFC9B2; base plate and pedestal slate #2E3B4E; shutter dark steel #46566A; yoke and joints navy #0E1726; core cell graphite #2E363E with a teal gauge strip #3FE0D0; brow lens glass #14181E. Lamps and the lens are flat, unlit discs.
Critical consistency: One shutter, two top vent flaps, one core cell, one belt feed, and an EMPTY gun cradle: no rotary gun, no barrels painted in. No laser sight, scanner or sight line. No petals, flower shapes, stalk or legs, no ceiling mount, no text or logos, no human parts.
Use a neutral pose with the shutter raised, the cradle empty and the vent flaps closed, the parts slightly separated for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Leave the gun cradle empty; the rotary is a separate sprite. Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Sentry Turret design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 1.10 m tall on its pedestal; 0.90 m wide across the housing; the housing is about 0.7 m long without the gun. Maintain these defining forms: A squat armored housing on a swivel yoke atop a short bolted pedestal, with a broad front shutter raised to show an empty open gun cradle, a belt chute curving into the rear of the housing and two hinged vent flaps on top. Low, wide and bolted down. Preserve construction: A round steel base plate with four large bolts, a short pedestal column and a swivel yoke. A broad, low armored housing of overlapping graphite and pale ivory plates with bone-white hazard stencil bars (no lettering), a few visible fasteners and a small dark lens on the brow. A heavy front shutter with a narrow horizontal slot, drawn raised so that the open, empty gun cradle behind it is visible, and an armored ammunition belt chute with dark-tipped links entering the rear of the housing. Two closed hinged heat flaps on the top-rear hiding a recessed core cell. Preserve the palette: Housing graphite #2A3441 with pale ivory plates #CFCBB9; bone hazard bars #CFC9B2; base plate and pedestal slate #2E3B4E; shutter dark steel #46566A; yoke and joints navy #0E1726; core cell graphite #2E363E with a teal gauge strip #3FE0D0; brow lens glass #14181E. Lamps and the lens are flat, unlit discs. Lock these details: One shutter, two top vent flaps, one core cell, one belt feed, and an EMPTY gun cradle: no rotary gun, no barrels painted in. No laser sight, scanner or sight line. No petals, flower shapes, stalk or legs, no ceiling mount, no text or logos, no human parts. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Sentry Turret reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Closed rest; shutter rising with the gun tracking; spin-up; firing stream; overheat vent with the core exposed; hit reaction; wreck. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: At rest the shutter is down and the barrels are still. To attack the shutter slides up, the cradle pitches to follow its aim point and the barrels spin up. It fires a stream, then the barrels wind down, the top vent flaps lift and steam vents from the exposed core. Capability: Fires a 1.2 s stream from a rotary gun whose aim point creeps after its target, then overheats and cannot move. It is bolted down. Important limitation or opening: During the overheat the vent flaps lift and expose the teal core in its dark recess; the open core is the target. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or steam, and draw the rotary only as a plain, flat placeholder three-barrel gun in a white shroud (the real gun is a separate sprite): the closed rest shows one small flat dull-amber brow lens disc and a dark core; the shutter-rising and spin-up poses show the rotary's collar flat amber (#FFB02E), and flat alarm red (#FF3B4E) for the last quarter of the spin-up; the firing stream keeps a red collar; the overheat vent shows the collar dark and the exposed core cell strip flat teal (#3FE0D0); the wreck shows everything unlit. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

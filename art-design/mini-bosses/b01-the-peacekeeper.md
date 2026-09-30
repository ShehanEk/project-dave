# The Peacekeeper — Arcadia's Crowd-Control Truck

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** B01\
**Category:** mini-bosses\
**First appearance:** Level 3\
**Design status:** Enemy art direction (C35): a lit cutout rig with smooth, realistic engine lighting; confirmed direction, validated by the approved lit-cutout test (2026-09-30). The Peacekeeper's identity, name, appearance and palette are *proposed* (C31, P23), and no image is approved yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

First mini-boss; *proposed:* Arcadia's driverless crowd-control truck. Arcadia's defense division builds the Peacekeeper and sells it abroad as "riot management", and its export sales reel still loops on the side screen while Adam sends it after Dave. It has no driver, no face and no hesitation. It carries a ram and a roof rotary machine gun (the Thresher, [EG03](../enemy-guns/eg03-machine-gun.md)).

Its lesson is to read the tell, dodge and punish the stall: leave the lane or take cover, then hit the open hatch. It is also the first boss to teach that a tracking gun is slower than Dave (keep running) and that only high cover stops an elevated gun. Its export contract is an evidence file ([evidence files](../../design/03-progression/evidence-files.md)). The truck never speaks: its loudspeaker carries only Arcadia's calm dispersal notice, and its siren is a tell.

## Scale and silhouette

2.85 m tall to the top of the roof gun (2.30 m to the cab roof) and 5.00 m long; about 1.7 hero heights (H, Dave's 1.70 m) tall and 3 H long. The roof gun's muzzle line sits 1.5 H (2.55 m) above the floor.

A long, low armored truck on six heavy wheels (three visible from each side): a wedge ram plow across the nose, a short blunt hood, a windowless armored cab and a tall boxy rear body carrying a large flat side screen. A turret ring on the roof holds the rotary gun, and a two-leaf hatch on the rear roof covers the drive core. It reads as a riot-control vehicle: blunt, heavy and built to run people down, with no face.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

The cab has no windows: one dark sensor slit crosses the front and a small sensor pod sits on the roof edge. The roof carries a full-width lightbar (every segment dark in the neutral pose), two loudspeaker horns and a siren dome. The ram plow is a thick angled steel wedge with white-and-charcoal chevrons and two heavy push-bar struts. Steel mesh guards cover the side panels and the wheel arches. A large flat screen sits in a raised frame on the rear body; its export sales reel (a cheerful loop of truck silhouettes and a turning globe, never legible text) is a separate layer.

The truck still looks like showroom stock: clean matte white armor, a small original teal Arcadia arch emblem on the cab door, a bolted demo-placard bracket with no text, and scuffs from the Parade route. The two roof hatch leaves lie flush and seamless when closed; opened, they lift to about 60 degrees and show a squat finned drive core with a steam vent. The turret ring is a broad flat ring with a plain mounting socket; the roof gun is drawn separately (EG03).

## Color and materials

Base colors are flat and unlit (C35): matte Arcadia white #D5DDE3 (*proposed*) for the upper body and cab; graphite armor #2E3B4E and steel #1C2A3A for the lower body, plow struts, mesh and wheel arches; near-black rubber #07090F for the tires; small Arcadia teal #3FE0D0 for the door emblem and the screen frame. The lightbar segments and the gun's collar are drawn dark, and the engine adds their glow: amber #FFB02E, then alarm red #FF3B4E, as tells only. The open drive core glows hot white, never amber or red, so an opening is never mistaken for a tell. Fluid is black oil #14181E with a #46566A sheen rim, plus white sparks. There is no blood.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Two attacks, one at a time, and no summoned enemies. Dave runs 4 H/s.

- **Ram:** for 1 s the siren wails, the wheels spin in place and the lightbar glows amber, then red for the last 0.25 s. The truck then rams straight down its lane into the bollards (2 damage) and stalls for 3 s with the roof hatch open.
- **Roof gun:** it reverses to the center of the lane. The rotary's collar glows amber as its barrels spin up with a rising whine, then red for 0.25 s. A 1.5 s stream follows from 1.5 H up, and its aim point creeps after Dave at 2.5 H/s with no lead. Dave keeps running the side walkway or stands behind a concrete planter pillar. The overheat opens the hatch for 1.8 s.
- **Phase 2 (below 50%):** the gun stream runs straight into a ram. The amber part of each tell shortens (x0.7); the red part stays 0.25 s.

The truck idles parked with a low engine rumble and the sales reel looping. Before a ram the nose dips on its suspension as the wheels spin; after the bollard impact the body rocks back and the hatch leaves rise. For the gun it reverses and stops, the turret ring swings the gun to face Dave (the gun flips at the ring while the body keeps its facing) and the rotary spins up. Sounds are *proposed*: a two-tone crowd-control siren, a calm loudspeaker notice (wording owned by the level brief), the rotary's spin-up whine and chatter loop (EG03), a hatch clang and a steam hiss.

## Openings and limitations

The drive core under the roof hatch: open for 3 s after a bollard impact and for 1.8 s after the gun's overheat. The armor everywhere else deflects shots with sparks and a ping. Both side views must show the raised hatch leaves and the core, so a player on either walkway can see and hit them. The core's hot-white glow and the steam make the target read in the dark.

**Death:** the truck bursts into parts (see the rig list). The side screen keeps looping its reel for a moment after the engine dies, then goes dark last.

## Rig parts, normal maps and sockets

All parts are rigid. Every part gets a matching normal map (green = up), so the plaza's lamps, the side screen and the gun's muzzle flash light the truck smoothly. Keep wheel discs radially symmetric, or spin only the tread ring, so turning a wheel never turns its lit side.

- **Hull** (root part, pivot at the rear axle): rear body with the screen frame and mesh guards; cab; sensor pod, horns and siren dome; lightbar (each segment its own layer for the amber and red glow).
- **Ram plow:** pivot at its lower hinge, for a small pitch on the ram windup and impact.
- **Wheels:** three near-side wheels with hub pivots and three darker far-side wheels; tread ring and hub disc separate.
- **Roof hatch:** two leaves with hinge pivots at their rear edges. The drive core, its glow and the steam vent are separate layers under them.
- **Turret ring, the gun socket:** the EG03 rotary sprite mounts here. Its origin is the gun's mount point, its muzzle marker sits 1.5 H above the floor, and its muzzle-flash light follows EG03. The gun is drawn without the truck and flips left or right at the ring. It drops as a static prop on death.
- **Side screen:** a looping reel layer with no text.
- **Fluid:** black oil #14181E with a #46566A sheen rim, plus white sparks. Oil leaks, spark bursts and dents are separate overlay layers attached to the hit part.
- **Debris on death:** the wheels, plow, both hatch leaves, cab, screen frame, lightbar and gun become physics bodies in a burst, and an oil pool spreads under the wreck.

## Required pose and state references

Neutral parked idle; ram windup (siren, wheels spinning, lightbar amber then red); ram; bollard impact and stall with the hatch open; reversing to center; gun spin-up (collar amber then red); gun stream; overheat with the hatch open and steam venting; phase-two damage state (dented plow, cracked screen, same chassis); hit reaction; wreck.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment. Draw lamps as flat bright shapes with no glow halo, since the engine adds the glow.

## Consistency rules

Six wheels (three visible per side), one ram plow, one roof turret ring with one gun, one two-leaf roof hatch, one lightbar and one side screen. No driver, no face, no interior visible: the cab stays windowless and blank. It is a crowd-control truck: no cutting deck, drums, clippings, mascot, bunting or festive decoration, and no water cannon. Amber and red appear only as tell glows, and the open core is hot white. No blood: machine fluid only. No lettering or logos; the teal arch emblem carries no text. Keep the gun socket empty in the base art.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view. The Peacekeeper's painted parts are safe to mirror: the arch emblem carries no text and the screen frame mirrors cleanly, so the rig mirrors the right-facing painting for left-facing play.

## Single-weapon encounter constraint

The hero carries only one weapon. This fight must support every weapon type that can legitimately reach this level. A clear Scrapjack shot is only one case: provide safe close-range access for the Boom Broom or Arc Welder, workable arcs and fuse windows for the Seedlobber, and replenishable throwable props when the Graviton Tether can be carried. The boss cannot be grabbed. No required route assumes a separate tether, backup pistol, or two-weapon combo.

## Arena relationship and phase changes

A broad indoor plaza in the showcase hall: one ground lane between two lines of steel bollards (the ram stops), raised side walkways along both edges for running and jumping clear, and concrete planter pillars at least 1.2 H tall standing on the walkways as high cover against the roof gun. Show the arena only on a separate context sheet; one bollard impact is enough to explain the fight. A checkpoint sits immediately before the arena gate. Light comes from amber security lamps and dim exhibit spotlights: put a light near each landing and keep the bollard faces and the pillars lit. Every ram can be cleared by leaving the lane or by a held jump onto a walkway, and a gun stream never overlaps a ram in phase one. *Proposed:* the level's keycard comes from the arena console after the fight, and level design owns its placement.

Phase one keeps one attack active at a time. Phase two chains the gun stream into a ram with shorter amber tells and the same red tell, not a new body form. Damage may dent the plow and crack the side screen but must preserve the same chassis. The truck starts no new windup while its shots are alive.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Peacekeeper, Arcadia's driverless crowd-control truck. Role: first mini-boss; a heavy armored truck with a ram plow and a roof gun mount that teaches reading the tell, dodging and punishing the stall. It has no driver and no face.
Scale: 2.85 m tall to the top of the roof gun mount and 5.00 m long; about 1.7 hero heights tall and 3 hero heights long.
Silhouette: A long, low armored truck on six heavy wheels (three visible from the side), with a wedge ram plow across the nose, a short blunt hood, a windowless armored cab and a tall boxy rear body carrying a large flat side screen. A broad turret ring on the roof and a two-leaf hatch on the rear roof.
Physical design: The cab has no windows: one dark sensor slit crosses the front and a small sensor pod sits on the roof edge. A full-width lightbar (all segments dark), two loudspeaker horns and a siren dome sit on the roof. The ram plow is a thick angled steel wedge with white-and-charcoal chevrons and two heavy push-bar struts. Steel mesh guards cover the side panels and wheel arches. A large flat screen sits in a raised frame on the rear body, showing a cheerful loop of truck silhouettes and a turning globe with no text. The roof hatch is two flush leaves at the rear of the roof, closed. The turret ring has a plain empty mounting socket. Showroom-clean matte white armor, a small unlettered teal arch emblem on the cab door, a blank bolted bracket, and light scuffs.
Materials and colors: Matte white #D5DDE3 upper body and cab; graphite armor #2E3B4E and steel #1C2A3A lower body, plow struts, mesh and wheel arches; near-black rubber #07090F tires; small teal #3FE0D0 emblem and screen frame. Flat base colors only, with the lamps drawn as dark unlit shapes.
Critical consistency: Six wheels (three visible), one ram plow, one turret ring, one two-leaf roof hatch, one lightbar, one side screen. No driver, no face, no visible interior, no cutting deck, no mascot or festive decoration, no water cannon, no gun on the turret ring.
Use a relaxed neutral pose that reveals the silhouette and joint structure: parked, hatch closed, no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right (the production facing; the rig mirrors it for left-facing play), centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored, painted so it can be split into rig parts (hull, cab, ram plow, wheels, hatch leaves, turret ring, lightbar) with clean overlap under each hinge and the hidden areas (the far wheels) painted complete. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in and no gun painted in. No airbrushed gradients, glossy chrome, photoreal volumetrics, pixel art, environment, action effects, UI, watermark, text, logos, labels, measurement arrows, franchise vehicles or unrelated props. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Peacekeeper design for DEAD EDEN. This is the same exact asset, not a redesign. Show a right-facing painting (the production facing) and a left-facing check drawing as separate drawings; the rig mirrors the right-facing parts for left-facing play, so the check only confirms that mirrored parts still read. Preserve anatomical left/right equipment; do not mirror asymmetry blindly. Use the same canvas scale and ground line in both drawings, flat base colors and a plain flat mid-grey (#808080) background. Maintain these proportions: 2.85 m tall to the top of the roof gun mount and 5.00 m long; about 1.7 hero heights tall and 3 hero heights long. Maintain these defining forms: A long, low armored truck on six heavy wheels (three visible from the side), with a wedge ram plow across the nose, a short blunt hood, a windowless armored cab and a tall boxy rear body carrying a large flat side screen. A broad turret ring on the roof and a two-leaf hatch on the rear roof. Preserve construction: The cab has no windows: one dark sensor slit crosses the front and a small sensor pod sits on the roof edge. A full-width lightbar (all segments dark), two loudspeaker horns and a siren dome sit on the roof. The ram plow is a thick angled steel wedge with white-and-charcoal chevrons and two heavy push-bar struts. Steel mesh guards cover the side panels and wheel arches. A large flat screen sits in a raised frame on the rear body, showing a cheerful loop of truck silhouettes and a turning globe with no text. The roof hatch is two flush leaves at the rear of the roof, closed. The turret ring has a plain empty mounting socket. Showroom-clean matte white armor, a small unlettered teal arch emblem on the cab door, a blank bolted bracket, and light scuffs. Preserve the palette: Matte white #D5DDE3; graphite armor #2E3B4E; steel #1C2A3A; near-black rubber #07090F; small teal #3FE0D0. Lock these details: Six wheels (three visible), one ram plow, one turret ring, one two-leaf roof hatch, one lightbar, one side screen. No driver, no face, no visible interior, no cutting deck, no mascot or festive decoration, no water cannon, no gun on the turret ring. Keep all parts fully in frame and clearly separated; show all required views without overlap, including a side view that shows the rear roof hatch clearly. Use a neutral repeatable pose, no action effects, no scenery. No baked shadows, no cast or contact shadow, no highlights, no rim light, no glow halos, no blood painted in. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Peacekeeper reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Neutral parked idle; ram windup; ram; bollard impact and stall with the hatch open; reversing to center; gun spin-up; gun stream; overheat with the hatch open and steam venting; phase-two damage state; hit reaction; wreck. If no state is specified, show the ram windup. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: The truck idles parked with a low engine rumble and a looping side screen. Before a ram the nose dips on its suspension as the wheels spin in place; after the bollard impact the body rocks back and the two roof hatch leaves rise. For the gun it reverses and stops, and the turret ring swings the gun to face the hero. Capability: A ram down a marked lane into bollards, and a roof rotary gun stream that creeps after the hero. In phase two the gun stream runs straight into a ram. No summoned enemies. Important limitation or opening: The finned drive core under the two open roof hatch leaves, glowing hot white with steam, and visible from both side views; the rest of the armor is closed. Boss phases: Phase one keeps one attack active at a time. Phase two chains the gun stream into a ram with shorter amber tells, not a new body form; damage may dent the plow and crack the side screen but must preserve the same chassis. Draw lamps and the lightbar as flat bright shapes with no glow halos. Keep effects small and separate enough that the body silhouette is visible. Plain flat mid-grey (#808080) background, evenly lit, no baked shadows and no blood painted in; leave the turret ring's gun socket empty; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Before sprite production

- No image is approved for this asset yet. Approve one neutral image (prompt 1) before producing animation poses.
- The lit cutout look is a confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): paint parts flat and unlit, with no shadows or highlights, and add a normal map per part after the parts are cut.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and tell readability at intended gameplay size, lit by the engine's lamps against the dark plaza, and in grayscale. The lightbar and collar tells and the open hatch must read from shape and motion as well as glow.
- Establish a consistent canvas, ground line and pivot intent; draw a few key poses before adding small details.
- Neutral and study sheets use a flat mid-grey background so dark and light parts both read. Final parts are cut out to transparent.
- Keep effects and moving pieces separate. A concept PNG is not a finished rig, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

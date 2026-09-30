# Seedlobber

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** W04\
**Category:** weapons\
**First appearance:** Level 5\
**Design status:** Confirmed 2D rendering style (C11) and dark sci-fi mood (C15); C35 amends the rendering to flat paint lit in the engine (confirmed direction, validated by the approved lit-cutout test (2026-09-30)). The palette tokens (P21) and this asset's appearance and lore details are proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Botanical launcher for bouncing explosive pods and control of ground space. It is the launcher from Arcadia's reforestation program, which replanted burned land with pressure-burst seed pods; Dave repurposes it to lob those pods at enemies. Dave collects it from a reforestation supply depot on Level 5.

*Proposed lore:* the seeds are ordinary short-lived plants, and the foam that Snare Foam leaves behind is ordinary seed-bed foam. Neither carries nanites, the Bloom or Adam-made growth, and the foam dries and crumbles within seconds.

## Scale and silhouette

Approximately 0.72 m long and 0.43 m tall including the top seed hopper.

A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble industrial reforestation equipment: chunky and municipal, with the flower-shaped cup as its one softer shape.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design ([hero brief](../../design/02-characters/hero.md)) is not fixed by this measurement.

## Appearance and construction

The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a forest-green shell with pale gray trim and a clay-brown lower bowl. The rear grip tilts backward; a short forward handle sits below the cup.

## Color and materials

Reforestation green #4F8A3E; clay brown #9A5A3A; pale trim gray #C7CEC9; pale green-tinted hopper glass #B4D8AE; dark brown handles #4A4239; pod seed-brown #7A5236 with amber fuse-pulse seams #FFB02E (shown only while a pod is armed). Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on the cup ribs, handle edges and hopper collar.

Dark-scene readability: the pale trim and the pale green hopper glass carry the silhouette against near-black scenery, and the forest-green shell takes the engine's lamp light along its top edge (no rim light is painted). Pods must stay visible in flight, so give them a pale seam band; the amber fuse pulse appears only while a pod is armed, which keeps amber meaning a warning. Nothing on this weapon or its effects uses violet, which is reserved for the Bloom.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Launches pods that bounce before a delayed explosion. Later upgrades add slowing foam, increased blast radius, and secondary explosive seeds. Nearby explosions can hurt Dave.

The hopper jiggles before launch, one pod drops into the cup, and a brief compressed puff sends it in an arc. The cup recoils a little and the next pod settles. No constant organic tentacle motion.

## Openings and limitations

Projectile arcs and delayed fuses demand careful positioning. A larger blast remains dangerous nearby. This weapon does not assume access to a simultaneously carried tether.

## Rig parts, normal maps and sockets

Body; four-rib launch cup; clear hopper; sample seed props; internal visible feed gate; two grips; separate fired pod (fuse glow on its own layer), explosion, foam, and cluster-charge assets; three upgrade mounts.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. Under the lit cutout pipeline (C35, validated 2026-09-30) each listed part is painted flat with its own matching normal map, the grip is the socket where Dave's hand holds the weapon, and the muzzle marks where its flash light sits. Frame counts and timing remain later production choices.

## Required pose and state references

Base off; pod loading; launch; bounced pod reference; fuse warning; Snare Foam aftermath; cluster release; four cumulative appearance stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, no slime or goo (Snare Foam is dry, matte seed-bed foam that crumbles away, never glossy, wet or dripping), no free-floating leaves, no glowing bioluminescent growth, no violet or nanite-swarm imagery, and no implication that the seeds or the foam are alive, hostile or linked to Adam's Bloom. The plants are ordinary and short-lived. The upgrade name Cluster Charges describes small secondary seed pods only. No logos or legible text.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand on the angled grip, support hand beneath the launch cup. The hopper remains above and forward of Dave's face in the holding study.

A large rounded seed pod with three broad shell seams and a small amber seam pulse for the fuse. The Snare Foam aftermath shows ordinary matte pale-green foam clumps that dry and crumble away; they never glow and never carry violet. Upgraded foam and cluster contents appear in separate cutaway-style art studies of fictional pods, not practical explosive schematics.

## Single-weapon gameplay rule

This weapon occupies Dave's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; Dave does not retain it as a backup or a separate utility tool. Images of Dave must not show additional carried guns.

Microchips (C19) are the primary collectible and the upgrade currency; evidence files (proposed) are optional journal finds with no stat effect. Re-flashing microchips into the carried weapon at a workbench (proposed name) to buy its upgrades is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

*Proposed:* each attachment seats a small re-flashed microchip module (a thumbnail-sized square chip with thin gold contact edges), showing the upgrade Dave bought at a workbench. Keep the modules small graphic shapes with no gold glow, so they never read as microchip pickups or change the silhouette.

### Stage 1: Snare Foam

**Capability:** Explosions leave short-lived foam that slows grounded enemies.

**Visible change:** A small green foam cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple bubble-cluster embossed motif and a pale foam-colored seam. No loose vines obstruct the weapon. A small square microchip module with thin gold contact edges is seated in a slot on the cartridge's cap.

**Attachment location:** Left side of the hopper base.

### Stage 2: Burst Pods

**Capability:** Increases the explosion radius, including danger to Dave.

**Visible change:** A thick clay-brown pressure collar encircles the launch cup's base, with four broad recessed panels. Pods gain a wider middle band while retaining the same overall size envelope. A small square microchip module with thin gold contact edges is seated in a slot in one of the recessed panels. Snare Foam stays fitted.

**Attachment location:** Launch-cup base behind the fixed petal ribs.

### Stage 3: Cluster Charges

**Capability:** Releases a small set of secondary explosive seeds after the main detonation.

**Visible change:** The hopper lid is replaced by a three-lobed cap and a small side sorting chamber. Pod surfaces gain three distinct bud-like nodes; the original hopper body and previous attachments remain. A small square microchip module with thin gold contact edges is seated in a slot in the sorting chamber's bracket.

**Attachment location:** Hopper lid and right-side sorting bracket.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Chunky rounded silhouette with a few readable functional details; suggest metal, plastic, ceramic, tape, rubber and glass through flat color areas and clean marks rather than painted reflections, with only subtle texture inside large color areas (the engine adds light and fine surface detail through a normal map). No painted light: no highlights, rim light, glow shapes, airbrushed gradients, photoreal volumetrics, glossy chrome or pixel art. Keep the weapon's own local colors. No franchise assets.

Design Seedlobber. Role: Botanical launcher for bouncing explosive pods and control of ground space, built for aerial reforestation seeding.
Scale: Approximately 0.72 m long and 0.43 m tall including the top seed hopper.
Silhouette: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble industrial reforestation equipment: chunky and municipal, with the flower-shaped cup as its one softer shape.
Physical design: The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a forest-green shell with pale gray trim and a clay-brown lower bowl. The rear grip tilts backward; a short forward handle sits below the cup.
Materials and colors: Reforestation green #4F8A3E; clay brown #9A5A3A; pale trim gray #C7CEC9; pale green-tinted hopper glass #B4D8AE; dark brown handles #4A4239; pod seed-brown #7A5236 with amber fuse-pulse seams #FFB02E (shown only while a pod is armed). Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on the cup ribs, handle edges and hopper collar.
Critical consistency: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, no slime or goo, no free-floating leaves, no glowing bioluminescent growth and no violet or nanite-swarm imagery; the plants are ordinary and short-lived. No logos or legible text.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no blood. Use a readable gameplay side pose with generous margins and the stated proportions. Use clean dark outlines and flat local colors. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Seedlobber design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors, evenly lit with no baked shadows, on a flat mid-grey (#808080) background. Maintain these proportions: Approximately 0.72 m long and 0.43 m tall including the top seed hopper. Maintain these defining forms: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble industrial reforestation equipment: chunky and municipal, with the flower-shaped cup as its one softer shape. Preserve construction: The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a forest-green shell with pale gray trim and a clay-brown lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Preserve the palette: Reforestation green #4F8A3E; clay brown #9A5A3A; pale trim gray #C7CEC9; pale green-tinted hopper glass #B4D8AE; dark brown handles #4A4239; pod seed-brown #7A5236 with amber fuse-pulse seams #FFB02E (shown only while a pod is armed). Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on the cup ribs, handle edges and hopper collar. Lock these details: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, no slime or goo, no free-floating leaves, no glowing bioluminescent growth and no violet or nanite-swarm imagery; the plants are ordinary and short-lived. No logos or legible text. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Seedlobber reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Base off; pod loading; launch; bounced pod reference; fuse warning; Snare Foam aftermath; cluster release; four cumulative appearance stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: The hopper jiggles before launch, one pod drops into the cup, and a brief compressed puff sends it in an arc. The cup recoils a little and the next pod settles. No constant organic tentacle motion. Capability: Launches pods that bounce before a delayed explosion. Later upgrades add slowing foam, increased blast radius, and secondary explosive seeds. Nearby explosions can hurt the wielder. Important limitation or opening: Projectile arcs and delayed fuses demand careful positioning. A larger blast remains dangerous nearby. This weapon does not assume access to a simultaneously carried tether. Handling: Rear hand on the angled grip, support hand beneath the launch cup. The hopper remains above and forward of the wielder's face in the holding study. Keep effects small and separate enough that the body or weapon silhouette is visible. Use a flat mid-grey (#808080) background, evenly lit and flat-colored with no baked shadows, no rim light and no blood; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette and line weight unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Snare Foam

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 1 of the approved DEAD EDEN Seedlobber weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble industrial reforestation equipment: chunky and municipal, with the flower-shaped cup as its one softer shape. The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a forest-green shell with pale gray trim and a clay-brown lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Show all cumulative attachments through this stage: 1. Snare Foam: A small green foam cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple bubble-cluster embossed motif and a pale foam-colored seam. No loose vines obstruct the weapon. A small square microchip module with thin gold contact edges is seated in a slot on the cartridge's cap. Mount: Left side of the hopper base. Do not include any later-stage attachment. Preserve rules: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, no slime or goo, no free-floating leaves, no glowing bioluminescent growth and no violet or nanite-swarm imagery; the plants are ordinary and short-lived. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Burst Pods

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 2 of the approved DEAD EDEN Seedlobber weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble industrial reforestation equipment: chunky and municipal, with the flower-shaped cup as its one softer shape. The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a forest-green shell with pale gray trim and a clay-brown lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Show all cumulative attachments through this stage: 1. Snare Foam: A small green foam cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple bubble-cluster embossed motif and a pale foam-colored seam. No loose vines obstruct the weapon. A small square microchip module with thin gold contact edges is seated in a slot on the cartridge's cap. Mount: Left side of the hopper base. 2. Burst Pods: A thick clay-brown pressure collar encircles the launch cup's base, with four broad recessed panels. Pods gain a wider middle band while retaining the same overall size envelope. A small square microchip module with thin gold contact edges is seated in a slot in one of the recessed panels. Snare Foam stays fitted. Mount: Launch-cup base behind the fixed petal ribs. Do not include any later-stage attachment. Preserve rules: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, no slime or goo, no free-floating leaves, no glowing bioluminescent growth and no violet or nanite-swarm imagery; the plants are ordinary and short-lived. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Cluster Charges

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 3 of the approved DEAD EDEN Seedlobber weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble industrial reforestation equipment: chunky and municipal, with the flower-shaped cup as its one softer shape. The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a forest-green shell with pale gray trim and a clay-brown lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Show all cumulative attachments through this stage: 1. Snare Foam: A small green foam cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple bubble-cluster embossed motif and a pale foam-colored seam. No loose vines obstruct the weapon. A small square microchip module with thin gold contact edges is seated in a slot on the cartridge's cap. Mount: Left side of the hopper base. 2. Burst Pods: A thick clay-brown pressure collar encircles the launch cup's base, with four broad recessed panels. Pods gain a wider middle band while retaining the same overall size envelope. A small square microchip module with thin gold contact edges is seated in a slot in one of the recessed panels. Snare Foam stays fitted. Mount: Launch-cup base behind the fixed petal ribs. 3. Cluster Charges: The hopper lid is replaced by a three-lobed cap and a small side sorting chamber. Pod surfaces gain three distinct bud-like nodes; the original hopper body and previous attachments remain. A small square microchip module with thin gold contact edges is seated in a slot in the sorting chamber's bracket. Mount: Hopper lid and right-side sorting bracket. Do not include any later-stage attachment. Preserve rules: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, no slime or goo, no free-floating leaves, no glowing bioluminescent growth and no violet or nanite-swarm imagery; the plants are ordinary and short-lived. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the approved neutral image, or approve one for this unpictured asset, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size, in grayscale, as a solid silhouette and against a dark background.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects, glow shapes and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

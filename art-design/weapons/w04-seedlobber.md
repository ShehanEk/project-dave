# Seedlobber

**Approved visual direction (C11):** [Hand-drawn 2D](../style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Asset ID:** W04\
**Category:** weapons\
**First appearance:** Level 5\
**Design status:** Confirmed hand-drawn 2D rendering style (C11); this asset's unselected appearance details remain proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Botanical launcher for bouncing explosive pods and control of ground space.

## Scale and silhouette

Approximately 0.72 m long and 0.43 m tall including the top seed hopper.

A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble cheerful greenhouse equipment.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a moss-green shell with cream trim and a terracotta lower bowl. The rear grip tilts backward; a short forward handle sits below the cup.

## Color and materials

Moss green #74934F; terracotta #C4825C; warm cream #E9DAB9; pale honey glass #E0CC8F; dark brown #555148; coral pod seams #D88973.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Launches pods that bounce before a delayed explosion. Later upgrades add slowing roots, increased blast radius, and secondary explosive seeds. Nearby explosions can hurt the hero.

The hopper jiggles before launch, one pod drops into the cup, and a brief compressed puff sends it in an arc. The cup recoils a little and the next pod settles. No constant organic tentacle motion.

## Openings and limitations

Projectile arcs and delayed fuses demand careful positioning. A larger blast remains dangerous nearby. This weapon does not assume access to a simultaneously carried tether.

## Parts to keep separate for animation

Body; four-rib launch cup; clear hopper; sample seed props; internal visible feed gate; two grips; separate fired pod, explosion, roots, and cluster-seed assets; three upgrade mounts.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. These are illustrated components, not a mandated rig: frame-by-frame, cutout or hybrid animation remains a later production choice.

## Required pose and state references

Base off; pod loading; launch; bounced pod reference; fuse warning; Deep Roots aftermath; cluster release; four cumulative appearance stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, infection slime, free-floating leaves, or implication that these plants infect robots.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand on the angled grip, support hand beneath the launch cup. The hopper remains above and forward of the hero's face in the holding study.

A large rounded seed pod with three broad shell seams and a small glowing seam pulse for the fuse. Upgraded root and cluster contents appear in separate cutaway-style art studies of fictional pods, not practical explosive schematics.

## Single-weapon gameplay rule

This weapon occupies the hero's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; the hero does not retain it as a backup or a separate utility tool. Images of the hero must not show additional carried guns.

Gems are the primary treasure, and artifacts are another treasure type. Spending gems at checkpoint facilities to upgrade the carried weapon is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

### Stage 1: Deep Roots

**Capability:** Explosions leave short-lived roots that slow grounded enemies.

**Visible change:** A small green culture cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple root-shaped embossed motif and a slightly woody seam. No loose vines obstruct the weapon.

**Attachment location:** Left side of the hopper base.

### Stage 2: Burst Pods

**Capability:** Increases the explosion radius, including danger to the hero.

**Visible change:** A thick terracotta pressure collar encircles the launch cup's base, with four broad recessed panels. Pods gain a wider middle band while retaining the same overall size envelope. Deep Roots stays fitted.

**Attachment location:** Launch-cup base behind the fixed petal ribs.

### Stage 3: Cluster Bloom

**Capability:** Releases a small set of secondary explosive seeds after the main detonation.

**Visible change:** The hopper lid is replaced by a three-lobed cap and a small side sorting chamber. Pod surfaces gain three distinct bud-like nodes; the original hopper body and previous attachments remain.

**Attachment location:** Hopper lid and right-side sorting bracket.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original hand-drawn 2D game concept art for DEAD EDEN, a colorful side-scrolling platformer shooter. Match the selected 2D Clipper, Resident and Sunnyvale references: confident dark olive or warm charcoal outlines, heavier outer contours, restrained interior lines, broad flat local colors, one or two crisp cel-shaded shadow shapes, and sparse graphic highlights. Use chunky rounded silhouettes and a few readable functional details. Describe enamel, ceramic, rubber, steel, skin and cloth through drawn shapes and marks rather than realistic reflections or surface rendering. Use only subtle painted texture inside large color areas. Preserve each asset's own palette; Sunnyvale colors do not replace other regions' palettes. Organic forms remain intact, with gentle eerie humor and no exposed viscera. No photorealism, volumetric lighting, ambient occlusion or franchise assets.

Design Seedlobber. Role: Botanical launcher for bouncing explosive pods and control of ground space.
Scale: Approximately 0.72 m long and 0.43 m tall including the top seed hopper.
Silhouette: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble cheerful greenhouse equipment.
Physical design: The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a moss-green shell with cream trim and a terracotta lower bowl. The rear grip tilts backward; a short forward handle sits below the cup.
Materials and colors: Moss green #74934F; terracotta #C4825C; warm cream #E9DAB9; pale honey glass #E0CC8F; dark brown #555148; coral pod seams #D88973.
Critical consistency: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, infection slime, free-floating leaves, or implication that these plants infect robots.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete hand-drawn 2D subject only, centered and fully visible on flat warm off-white with a simple flat contact shadow. Use a readable gameplay side pose with generous margins; preserve the selected reference's identity and proportions. Use clean outlines, flat local colors and crisp cel shadows. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create a clean hand-drawn 2D directional sprite study of the attached approved Seedlobber design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors and cel shadows and a plain light-gray background. Maintain these proportions: Approximately 0.72 m long and 0.43 m tall including the top seed hopper. Maintain these defining forms: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble cheerful greenhouse equipment. Preserve construction: The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a moss-green shell with cream trim and a terracotta lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Preserve the palette: Moss green #74934F; terracotta #C4825C; warm cream #E9DAB9; pale honey glass #E0CC8F; dark brown #555148; coral pod seams #D88973. Lock these details: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, infection slime, free-floating leaves, or implication that these plants infect robots. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Using the attached approved Seedlobber reference, draw one clear full-subject hand-drawn 2D animation key pose in strict gameplay side view, showing one state selected from this list: Base off; pod loading; launch; bounced pod reference; fuse warning; Deep Roots aftermath; cluster release; four cumulative appearance stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: The hopper jiggles before launch, one pod drops into the cup, and a brief compressed puff sends it in an arc. The cup recoils a little and the next pod settles. No constant organic tentacle motion. Capability: Launches pods that bounce before a delayed explosion. Later upgrades add slowing roots, increased blast radius, and secondary explosive seeds. Nearby explosions can hurt the hero. Important limitation or opening: Projectile arcs and delayed fuses demand careful positioning. A larger blast remains dangerous nearby. This weapon does not assume access to a simultaneously carried tether. Handling: Rear hand on the angled grip, support hand beneath the launch cup. The hopper remains above and forward of the hero's face in the holding study.  Keep effects small and separate enough that the body or weapon silhouette is visible. Plain light-gray background; no cinematic framing, text, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette, line weight and cel shadows unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Deep Roots

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 1 of the approved DEAD EDEN Seedlobber weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble cheerful greenhouse equipment. The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a moss-green shell with cream trim and a terracotta lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Show all cumulative attachments through this stage: 1. Deep Roots: A small green culture cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple root-shaped embossed motif and a slightly woody seam. No loose vines obstruct the weapon. Mount: Left side of the hopper base. Do not include any later-stage attachment. Preserve rules: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, infection slime, free-floating leaves, or implication that these plants infect robots. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Burst Pods

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 2 of the approved DEAD EDEN Seedlobber weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble cheerful greenhouse equipment. The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a moss-green shell with cream trim and a terracotta lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Show all cumulative attachments through this stage: 1. Deep Roots: A small green culture cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple root-shaped embossed motif and a slightly woody seam. No loose vines obstruct the weapon. Mount: Left side of the hopper base. 2. Burst Pods: A thick terracotta pressure collar encircles the launch cup's base, with four broad recessed panels. Pods gain a wider middle band while retaining the same overall size envelope. Deep Roots stays fitted. Mount: Launch-cup base behind the fixed petal ribs. Do not include any later-stage attachment. Preserve rules: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, infection slime, free-floating leaves, or implication that these plants infect robots. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Cluster Bloom

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 3 of the approved DEAD EDEN Seedlobber weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A broad trumpet-shaped launch cup, a rounded body, a bulbous transparent hopper above, and two sturdy handles underneath. It should resemble cheerful greenhouse equipment. The launch cup resembles a thick open flower with exactly four fixed petal-shaped ribs, not moving living petals. A single clear hopper shows three large seed pods as a readable sample load rather than a fixed ammo count. The main case has a moss-green shell with cream trim and a terracotta lower bowl. The rear grip tilts backward; a short forward handle sits below the cup. Show all cumulative attachments through this stage: 1. Deep Roots: A small green culture cartridge fits along the anatomical left side of the hopper base. Loaded pods gain a simple root-shaped embossed motif and a slightly woody seam. No loose vines obstruct the weapon. Mount: Left side of the hopper base. 2. Burst Pods: A thick terracotta pressure collar encircles the launch cup's base, with four broad recessed panels. Pods gain a wider middle band while retaining the same overall size envelope. Deep Roots stays fitted. Mount: Launch-cup base behind the fixed petal ribs. 3. Cluster Bloom: The hopper lid is replaced by a three-lobed cap and a small side sorting chamber. Pod surfaces gain three distinct bud-like nodes; the original hopper body and previous attachments remain. Mount: Hopper lid and right-side sorting bracket. Do not include any later-stage attachment. Preserve rules: One launch cup, four fixed ribs, one hopper, two grips. No ordinary rifle barrel, infection slime, free-floating leaves, or implication that these plants infect robots. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the selected 2D reference, or select a neutral image for an asset that has no approved image yet, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size and in grayscale.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

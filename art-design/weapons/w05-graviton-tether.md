# Graviton Tether

**Approved visual direction (C11):** [Hand-drawn 2D](../style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Asset ID:** W05\
**Category:** weapons\
**First appearance:** Level 6\
**Design status:** Confirmed hand-drawn 2D rendering style (C11); this asset's unselected appearance details remain proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Cargo-handling device for grabbing, throwing, and pulling the hero to marked anchors.

## Scale and silhouette

Approximately 0.68 m long and 0.38 m tall; front ring 0.32 m across.

A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a yellow cargo casing, a white top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring.

## Color and materials

Cargo yellow #D8B250; off-white #E6DFCC; navy-gray #3D5261; dark rubber #384247; violet field light #B8A0F0. Wear is concentrated on handle edges and ring bumpers.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Captures loose objects and small enemies after a brief lock, throws them, and pulls the hero to designated anchors. Later can capture medium enemies while staggered. Heavy enemies and bosses remain immune.

The three fingers spread slightly when acquiring a target. The ring carriage slides back under a heavy load, the field line tightens, and a release pulse propels the object. Pulling to an anchor tilts the whole weapon forward rather than extending a physical hook.

## Openings and limitations

The tether is the sole carried weapon when equipped. Mandatory fights must supply reachable replenishable throwable props and valid damage lines. Medium-target capture can use an environmental stagger; it never assumes a carried shotgun. Anchor movement is unavailable while another weapon is carried.

Capture takes time, and target size matters. It cannot create arbitrary grapple points or lift an entire mini-boss.

## Parts to keep separate for animation

Power body; rear grip; top support handle; ring; three brackets; three focusing fingers; recoil carriage; cable; load indicator; three upgrade mounts. Tether lines, held-object effects, and impact pulse remain separate.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. These are illustrated components, not a mandated rig: frame-by-frame, cutout or hybrid animation remains a later production choice.

## Required pose and state references

Neutral ring; target acquisition; light load; heavy load; throw release; anchor pull; impact-pulse effect; four cumulative appearance stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand on the grip and support hand on the upper handle. Leave enough separation for the hero's wrists while aiming the open ring forward.

No conventional ammunition projectile. Use a thin violet connection with a bright ring around the held target; show the target separately. Impact Pulse is a brief expanding ground-level ring after collision.

## Single-weapon gameplay rule

This weapon occupies the hero's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; the hero does not retain it as a backup or a separate utility tool. Images of the hero must not show additional carried guns.

Gems are the primary treasure, and artifacts are another treasure type. Spending gems at checkpoint facilities to upgrade the carried weapon is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

### Stage 1: Long Reach

**Capability:** Extends object capture distance and reach to designated anchors.

**Visible change:** A white rectangular signal rail sits along the top brace, ending in a small rounded violet receiver. It stays below the hero's sight line and behind the field ring.

**Attachment location:** Top brace rail.

### Stage 2: Heavy Lifter

**Capability:** Lifts medium objects and staggered medium enemies; heavy enemies and bosses remain immune.

**Visible change:** Three chunky yellow reinforcement collars fit onto the existing ring brackets, thickening the same three-spoke silhouette. The body gains a small rear counterweight. Long Reach remains fitted.

**Attachment location:** Three existing brackets and rear balance mount.

### Stage 3: Impact Pulse

**Capability:** Thrown targets produce a small damaging shockwave on collision.

**Visible change:** A second shallow violet induction rim fits directly behind the original front ring, visually nested rather than a separate floating ring. One pulse window on the case marks release readiness. Earlier attachments remain.

**Attachment location:** Ring rear flange and left body panel.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original hand-drawn 2D game concept art for DEAD EDEN, a colorful side-scrolling platformer shooter. Match the selected 2D Clipper, Resident and Sunnyvale references: confident dark olive or warm charcoal outlines, heavier outer contours, restrained interior lines, broad flat local colors, one or two crisp cel-shaded shadow shapes, and sparse graphic highlights. Use chunky rounded silhouettes and a few readable functional details. Describe enamel, ceramic, rubber, steel, skin and cloth through drawn shapes and marks rather than realistic reflections or surface rendering. Use only subtle painted texture inside large color areas. Preserve each asset's own palette; Sunnyvale colors do not replace other regions' palettes. Organic forms remain intact, with gentle eerie humor and no exposed viscera. No photorealism, volumetric lighting, ambient occlusion or franchise assets.

Design Graviton Tether. Role: Cargo-handling device for grabbing, throwing, and pulling the hero to marked anchors.
Scale: Approximately 0.68 m long and 0.38 m tall; front ring 0.32 m across.
Silhouette: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette.
Physical design: Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a yellow cargo casing, a white top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring.
Materials and colors: Cargo yellow #D8B250; off-white #E6DFCC; navy-gray #3D5261; dark rubber #384247; violet field light #B8A0F0. Wear is concentrated on handle edges and ring bumpers.
Critical consistency: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete hand-drawn 2D subject only, centered and fully visible on flat warm off-white with a simple flat contact shadow. Use a readable gameplay side pose with generous margins; preserve the selected reference's identity and proportions. Use clean outlines, flat local colors and crisp cel shadows. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create a clean hand-drawn 2D directional sprite study of the attached approved Graviton Tether design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors and cel shadows and a plain light-gray background. Maintain these proportions: Approximately 0.68 m long and 0.38 m tall; front ring 0.32 m across. Maintain these defining forms: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Preserve construction: Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a yellow cargo casing, a white top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Preserve the palette: Cargo yellow #D8B250; off-white #E6DFCC; navy-gray #3D5261; dark rubber #384247; violet field light #B8A0F0. Wear is concentrated on handle edges and ring bumpers. Lock these details: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Using the attached approved Graviton Tether reference, draw one clear full-subject hand-drawn 2D animation key pose in strict gameplay side view, showing one state selected from this list: Neutral ring; target acquisition; light load; heavy load; throw release; anchor pull; impact-pulse effect; four cumulative appearance stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: The three fingers spread slightly when acquiring a target. The ring carriage slides back under a heavy load, the field line tightens, and a release pulse propels the object. Pulling to an anchor tilts the whole weapon forward rather than extending a physical hook. Capability: Captures loose objects and small enemies after a brief lock, throws them, and pulls the hero to designated anchors. Later can capture medium enemies while staggered. Heavy enemies and bosses remain immune. Important limitation or opening: Capture takes time, and target size matters. It cannot create arbitrary grapple points or lift an entire mini-boss. Handling: Rear hand on the grip and support hand on the upper handle. Leave enough separation for the hero's wrists while aiming the open ring forward.  Keep effects small and separate enough that the body or weapon silhouette is visible. Plain light-gray background; no cinematic framing, text, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette, line weight and cel shadows unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Long Reach

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 1 of the approved DEAD EDEN Graviton Tether weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a yellow cargo casing, a white top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Show all cumulative attachments through this stage: 1. Long Reach: A white rectangular signal rail sits along the top brace, ending in a small rounded violet receiver. It stays below the hero's sight line and behind the field ring. Mount: Top brace rail. Do not include any later-stage attachment. Preserve rules: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Heavy Lifter

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 2 of the approved DEAD EDEN Graviton Tether weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a yellow cargo casing, a white top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Show all cumulative attachments through this stage: 1. Long Reach: A white rectangular signal rail sits along the top brace, ending in a small rounded violet receiver. It stays below the hero's sight line and behind the field ring. Mount: Top brace rail. 2. Heavy Lifter: Three chunky yellow reinforcement collars fit onto the existing ring brackets, thickening the same three-spoke silhouette. The body gains a small rear counterweight. Long Reach remains fitted. Mount: Three existing brackets and rear balance mount. Do not include any later-stage attachment. Preserve rules: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Impact Pulse

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 3 of the approved DEAD EDEN Graviton Tether weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a yellow cargo casing, a white top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Show all cumulative attachments through this stage: 1. Long Reach: A white rectangular signal rail sits along the top brace, ending in a small rounded violet receiver. It stays below the hero's sight line and behind the field ring. Mount: Top brace rail. 2. Heavy Lifter: Three chunky yellow reinforcement collars fit onto the existing ring brackets, thickening the same three-spoke silhouette. The body gains a small rear counterweight. Long Reach remains fitted. Mount: Three existing brackets and rear balance mount. 3. Impact Pulse: A second shallow violet induction rim fits directly behind the original front ring, visually nested rather than a separate floating ring. One pulse window on the case marks release readiness. Earlier attachments remain. Mount: Ring rear flange and left body panel. Do not include any later-stage attachment. Preserve rules: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the selected 2D reference, or select a neutral image for an asset that has no approved image yet, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size and in grayscale.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

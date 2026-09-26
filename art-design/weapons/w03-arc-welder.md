# Arc Welder

**Approved visual direction (C11):** [Hand-drawn 2D](../style-guide.md) — clean outlines, flat colors, cel shadows and layered scenery. [Selected references](../../concept-art/README.md).

**Asset ID:** W03\
**Category:** weapons\
**First appearance:** Level 4\
**Design status:** Confirmed hand-drawn 2D rendering style (C11); this asset's unselected appearance details remain proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Short-range electrical control tool repurposed from portable robot repair equipment.

## Scale and silhouette

Approximately 0.62 m long and 0.32 m tall; heavy two-handed hand tool.

A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. The hero's final design is not fixed by this measurement.

## Appearance and construction

The cream main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight.

## Color and materials

Cream #E7DECB; deep teal #397D7B; copper #AD7951; graphite #3D4752; electric cyan #73E5E3; hot amber gauge #E9AE54.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Projects a short arc that can jump between nearby enemies. Shocks living enemies and disrupts exposed robot systems. Sustained use overheats it.

Prongs flex slightly inward at activation. Arcs snap between the tips before extending to a target. The gauge rises, side vents widen when hot, and the body settles into a cooling shudder when firing stops.

## Openings and limitations

Limited reach and heat management. Electricity does not automatically penetrate every shield or disable every robot.

## Parts to keep separate for animation

Power case; two-prong emitter fork; insulating collars; rear grip; forward handle; top carry handle; cable; heat gauge; vent panels; coil insert; three upgrade mounts.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. These are illustrated components, not a mandated rig: frame-by-frame, cutout or hybrid animation remains a later production choice.

## Required pose and state references

Neutral off; held; ignition at prongs; sustained arc; near-overheat warning; cooling; Capacitor Burst; four cumulative stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand on the main grip and support hand on the underside forward handle. Top handle is for carrying, not the normal firing grip.

A narrow jagged cyan arc with a white center and sparse sparks. Chaining branches should remain separate readable lines. The capacitor discharge is a short local ring, shown separately from the clean model.

## Single-weapon gameplay rule

This weapon occupies the hero's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; the hero does not retain it as a backup or a separate utility tool. Images of the hero must not show additional carried guns.

Gems are the primary treasure, and artifacts are another treasure type. Spending gems at checkpoint facilities to upgrade the carried weapon is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

### Stage 1: Chain Reaction

**Capability:** Lets the arc jump to additional nearby targets.

**Visible change:** A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small windows pulse in sequence.

**Attachment location:** Upper fork mounting lugs.

### Stage 2: Coolant Jacket

**Capability:** Extends firing time before overheating.

**Visible change:** A thick turquoise cooling sleeve wraps around the rear half of the case, with two broad radiator fins and a small protected coolant window. Chain Reaction remains fitted.

**Attachment location:** Rear case perimeter, clear of both grips and the gauge.

### Stage 3: Capacitor Burst

**Capability:** Uses accumulated heat to stagger nearby enemies and interrupt exposed robot systems, followed by a recharge pause.

**Visible change:** A rounded accumulator pod sits under the body between the grip positions. Its two broad indicator bars fill with heat and empty during discharge. Earlier attachments remain fitted.

**Attachment location:** Central underside recess, without reducing hand clearance.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original hand-drawn 2D game concept art for DEAD EDEN, a colorful side-scrolling platformer shooter. Match the selected 2D Clipper, Resident and Sunnyvale references: confident dark olive or warm charcoal outlines, heavier outer contours, restrained interior lines, broad flat local colors, one or two crisp cel-shaded shadow shapes, and sparse graphic highlights. Use chunky rounded silhouettes and a few readable functional details. Describe enamel, ceramic, rubber, steel, skin and cloth through drawn shapes and marks rather than realistic reflections or surface rendering. Use only subtle painted texture inside large color areas. Preserve each asset's own palette; Sunnyvale colors do not replace other regions' palettes. Organic forms remain intact, with gentle eerie humor and no exposed viscera. No photorealism, volumetric lighting, ambient occlusion or franchise assets.

Design Arc Welder. Role: Short-range electrical control tool repurposed from portable robot repair equipment.
Scale: Approximately 0.62 m long and 0.32 m tall; heavy two-handed hand tool.
Silhouette: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance.
Physical design: The cream main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight.
Materials and colors: Cream #E7DECB; deep teal #397D7B; copper #AD7951; graphite #3D4752; electric cyan #73E5E3; hot amber gauge #E9AE54.
Critical consistency: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete hand-drawn 2D subject only, centered and fully visible on flat warm off-white with a simple flat contact shadow. Use a readable gameplay side pose with generous margins; preserve the selected reference's identity and proportions. Use clean outlines, flat local colors and crisp cel shadows. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create a clean hand-drawn 2D directional sprite study of the attached approved Arc Welder design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors and cel shadows and a plain light-gray background. Maintain these proportions: Approximately 0.62 m long and 0.32 m tall; heavy two-handed hand tool. Maintain these defining forms: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. Preserve construction: The cream main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Preserve the palette: Cream #E7DECB; deep teal #397D7B; copper #AD7951; graphite #3D4752; electric cyan #73E5E3; hot amber gauge #E9AE54. Lock these details: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Using the attached approved Arc Welder reference, draw one clear full-subject hand-drawn 2D animation key pose in strict gameplay side view, showing one state selected from this list: Neutral off; held; ignition at prongs; sustained arc; near-overheat warning; cooling; Capacitor Burst; four cumulative stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: Prongs flex slightly inward at activation. Arcs snap between the tips before extending to a target. The gauge rises, side vents widen when hot, and the body settles into a cooling shudder when firing stops. Capability: Projects a short arc that can jump between nearby enemies. Shocks living enemies and disrupts exposed robot systems. Sustained use overheats it. Important limitation or opening: Limited reach and heat management. Electricity does not automatically penetrate every shield or disable every robot. Handling: Rear hand on the main grip and support hand on the underside forward handle. Top handle is for carrying, not the normal firing grip.  Keep effects small and separate enough that the body or weapon silhouette is visible. Plain light-gray background; no cinematic framing, text, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette, line weight and cel shadows unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Chain Reaction

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 1 of the approved DEAD EDEN Arc Welder weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. The cream main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Show all cumulative attachments through this stage: 1. Chain Reaction: A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small windows pulse in sequence. Mount: Upper fork mounting lugs. Do not include any later-stage attachment. Preserve rules: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Coolant Jacket

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 2 of the approved DEAD EDEN Arc Welder weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. The cream main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Show all cumulative attachments through this stage: 1. Chain Reaction: A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small windows pulse in sequence. Mount: Upper fork mounting lugs. 2. Coolant Jacket: A thick turquoise cooling sleeve wraps around the rear half of the case, with two broad radiator fins and a small protected coolant window. Chain Reaction remains fitted. Mount: Rear case perimeter, clear of both grips and the gauge. Do not include any later-stage attachment. Preserve rules: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Capacitor Burst

```text
Use the selected hand-drawn 2D style: clean dark outlines, flat painted colors and crisp cel shadows; preserve the attached 2D identity reference.

Create stage 3 of the approved DEAD EDEN Arc Welder weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. The cream main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Show all cumulative attachments through this stage: 1. Chain Reaction: A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small windows pulse in sequence. Mount: Upper fork mounting lugs. 2. Coolant Jacket: A thick turquoise cooling sleeve wraps around the rear half of the case, with two broad radiator fins and a small protected coolant window. Chain Reaction remains fitted. Mount: Rear case perimeter, clear of both grips and the gauge. 3. Capacitor Burst: A rounded accumulator pod sits under the body between the grip positions. Its two broad indicator bars fill with heat and empty during discharge. Earlier attachments remain fitted. Mount: Central underside recess, without reducing hand clearance. Do not include any later-stage attachment. Preserve rules: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. Use a clean hand-drawn 2D side drawing on flat warm off-white, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the selected 2D reference, or select a neutral image for an asset that has no approved image yet, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size and in grayscale.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

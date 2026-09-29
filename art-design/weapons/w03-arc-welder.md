# Arc Welder

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** W03\
**Category:** weapons\
**First appearance:** Level 4\
**Design status:** Confirmed 2D rendering style (C11) and dark sci-fi mood (C15); C35 amends the rendering to flat paint lit in the engine (confirmed direction, validated by the approved lit-cutout test (2026-09-30)). The palette tokens (P21) and this asset's appearance and lore details are proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Short-range electrical control tool: crowd control and interrupting machine systems. It is an Arcadia repair tool, repurposed from the portable machine repair equipment field technicians carried. In Dave's hands it shocks people and cyborg dogs and disrupts exposed machine systems. Dave finds one in a workshop on Level 4.

*Proposed lore:* Arcadia technicians used the two-prong fork to reach the exposed service ports its machines keep for repairs, which is why the tool can disrupt exposed machine systems.

## Scale and silhouette

Approximately 0.62 m long and 0.32 m tall; heavy two-handed hand tool.

A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design ([hero brief](../../design/02-characters/hero.md)) is not fixed by this measurement.

## Appearance and construction

The pale service-gray main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight.

## Color and materials

Pale service gray #C3CBD2; Arcadia teal bumpers #2B8C88 (painted, with a status glow of #3FE0D0); copper #C8804A; graphite #4A5561; arc blue-white #A8DCFF with a white core; heat-gauge amber #FFB02E. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on the bumper corners, grips and prong tips.

Dark-scene readability: the pale case and the teal bumpers carry the silhouette against near-black scenery, with the engine's lamp light picking out the top edge and the prongs (no rim light is painted). Keep the arc blue-white so it never reads as an Arcadia or Link light (teal) or as an attack tell (red or amber). Only the heat gauge glows amber, because it is a warning.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Projects a short arc that can jump between nearby enemies. Shocks people and cyborg dogs and disrupts exposed machine systems. Sustained use overheats it.

Prongs flex slightly inward at activation. Arcs snap between the tips before extending to a target. The gauge rises, side vents widen when hot, and the body settles into a cooling shudder when firing stops.

## Openings and limitations

Limited reach and heat management. Electricity does not automatically penetrate every shield or disable every machine.

## Rig parts, normal maps and sockets

Power case; two-prong emitter fork; insulating collars; rear grip; forward handle; top carry handle; cable; heat gauge (glow on its own layer); vent panels; coil insert; three upgrade mounts.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. Under the lit cutout pipeline (C35, validated 2026-09-30) each listed part is painted flat with its own matching normal map, the grip is the socket where Dave's hand holds the weapon, and the muzzle marks where its flash light sits. Frame counts and timing remain later production choices.

## Required pose and state references

Neutral off; held; ignition at prongs; sustained arc; near-overheat warning; cooling; Capacitor Burst; four cumulative stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. No logos or legible text.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand on the main grip and support hand on the underside forward handle. Top handle is for carrying, not the normal firing grip.

A narrow jagged blue-white arc with a bright white center and sparse sparks. Chaining branches should remain separate readable lines. The capacitor discharge is a short local ring, shown separately from the clean model.

## Single-weapon gameplay rule

This weapon occupies Dave's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; Dave does not retain it as a backup or a separate utility tool. Images of Dave must not show additional carried guns.

Microchips (C19) are the primary collectible and the upgrade currency; evidence files (proposed) are optional journal finds with no stat effect. Re-flashing microchips into the carried weapon at a workbench (proposed name) to buy its upgrades is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

*Proposed:* each attachment seats a small re-flashed microchip module (a thumbnail-sized square chip with thin gold contact edges), showing the upgrade Dave bought at a workbench. Keep the modules small graphic shapes with no gold glow, so they never read as microchip pickups or change the silhouette.

### Stage 1: Chain Reaction

**Capability:** Lets the arc jump to additional nearby targets.

**Visible change:** A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small arc-blue windows pulse in sequence. A small square microchip module with thin gold contact edges is seated in a slot at the bridge's rear.

**Attachment location:** Upper fork mounting lugs.

### Stage 2: Coolant Jacket

**Capability:** Extends firing time before overheating.

**Visible change:** A thick deep-teal cooling sleeve wraps around the rear half of the case, with two broad radiator fins and a small protected coolant window. A small square microchip module with thin gold contact edges is seated in a slot at the sleeve's rear edge. Chain Reaction remains fitted.

**Attachment location:** Rear case perimeter, clear of both grips and the gauge.

### Stage 3: Capacitor Burst

**Capability:** Uses accumulated heat to stagger nearby enemies and interrupt exposed machine systems, followed by a recharge pause.

**Visible change:** A rounded accumulator pod sits under the body between the grip positions. Its two broad amber indicator bars fill with heat and empty during discharge. A small square microchip module with thin gold contact edges is seated in a slot on the pod's side face. Earlier attachments remain fitted.

**Attachment location:** Central underside recess, without reducing hand clearance.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Chunky rounded silhouette with a few readable functional details; suggest metal, plastic, ceramic, tape, rubber and glass through flat color areas and clean marks rather than painted reflections, with only subtle texture inside large color areas (the engine adds light and fine surface detail through a normal map). No painted light: no highlights, rim light, glow shapes, airbrushed gradients, photoreal volumetrics, glossy chrome or pixel art. Keep the weapon's own local colors. No franchise assets.

Design Arc Welder. Role: Short-range electrical control tool repurposed from portable machine repair equipment.
Scale: Approximately 0.62 m long and 0.32 m tall; heavy two-handed hand tool.
Silhouette: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance.
Physical design: The pale service-gray main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight.
Materials and colors: Pale service gray #C3CBD2; Arcadia teal bumpers #2B8C88 (painted, with a status glow of #3FE0D0); copper #C8804A; graphite #4A5561; arc blue-white #A8DCFF with a white core; heat-gauge amber #FFB02E. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on the bumper corners, grips and prong tips.
Critical consistency: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. No logos or legible text.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no blood. Use a readable gameplay side pose with generous margins and the stated proportions. Use clean dark outlines and flat local colors. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Arc Welder design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors, evenly lit with no baked shadows, on a flat mid-grey (#808080) background. Maintain these proportions: Approximately 0.62 m long and 0.32 m tall; heavy two-handed hand tool. Maintain these defining forms: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. Preserve construction: The pale service-gray main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Preserve the palette: Pale service gray #C3CBD2; Arcadia teal bumpers #2B8C88 (painted, with a status glow of #3FE0D0); copper #C8804A; graphite #4A5561; arc blue-white #A8DCFF with a white core; heat-gauge amber #FFB02E. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on the bumper corners, grips and prong tips. Lock these details: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. No logos or legible text. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Arc Welder reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Neutral off; held; ignition at prongs; sustained arc; near-overheat warning; cooling; Capacitor Burst; four cumulative stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: Prongs flex slightly inward at activation. Arcs snap between the tips before extending to a target. The gauge rises, side vents widen when hot, and the body settles into a cooling shudder when firing stops. Capability: Projects a short arc that can jump between nearby enemies. Shocks people and cyborg dogs and disrupts exposed machine systems. Sustained use overheats it. Important limitation or opening: Limited reach and heat management. Electricity does not automatically penetrate every shield or disable every machine. Handling: Rear hand on the main grip and support hand on the underside forward handle. Top handle is for carrying, not the normal firing grip. Keep effects small and separate enough that the body or weapon silhouette is visible. Use a flat mid-grey (#808080) background, evenly lit and flat-colored with no baked shadows, no rim light and no blood; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette and line weight unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Chain Reaction

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 1 of the approved DEAD EDEN Arc Welder weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. The pale service-gray main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Show all cumulative attachments through this stage: 1. Chain Reaction: A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small arc-blue windows pulse in sequence. A small square microchip module with thin gold contact edges is seated in a slot at the bridge's rear. Mount: Upper fork mounting lugs. Do not include any later-stage attachment. Preserve rules: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Coolant Jacket

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 2 of the approved DEAD EDEN Arc Welder weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. The pale service-gray main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Show all cumulative attachments through this stage: 1. Chain Reaction: A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small arc-blue windows pulse in sequence. A small square microchip module with thin gold contact edges is seated in a slot at the bridge's rear. Mount: Upper fork mounting lugs. 2. Coolant Jacket: A thick deep-teal cooling sleeve wraps around the rear half of the case, with two broad radiator fins and a small protected coolant window. A small square microchip module with thin gold contact edges is seated in a slot at the sleeve's rear edge. Chain Reaction remains fitted. Mount: Rear case perimeter, clear of both grips and the gauge. Do not include any later-stage attachment. Preserve rules: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Capacitor Burst

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 3 of the approved DEAD EDEN Arc Welder weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact rectangular power body behind a wide U-shaped emitter fork. Two blunt electrode prongs define its front silhouette; a top carry handle and lower rear grip make it read as an industrial appliance. The pale service-gray main case has teal bumper corners and one large round heat gauge on the left. A protected copper coil is visible through three broad side slots. A thick cable loops from the rear to the fork without trailing to an unseen backpack. The prongs are ceramic-insulated with dark metal tips. An underside forward handle supports the weight. Show all cumulative attachments through this stage: 1. Chain Reaction: A small horseshoe-shaped copper induction bridge mounts above the original fork. It is one solid support piece, not another pair of weapon barrels. Three small arc-blue windows pulse in sequence. A small square microchip module with thin gold contact edges is seated in a slot at the bridge's rear. Mount: Upper fork mounting lugs. 2. Coolant Jacket: A thick deep-teal cooling sleeve wraps around the rear half of the case, with two broad radiator fins and a small protected coolant window. A small square microchip module with thin gold contact edges is seated in a slot at the sleeve's rear edge. Chain Reaction remains fitted. Mount: Rear case perimeter, clear of both grips and the gauge. 3. Capacitor Burst: A rounded accumulator pod sits under the body between the grip positions. Its two broad amber indicator bars fill with heat and empty during discharge. A small square microchip module with thin gold contact edges is seated in a slot on the pod's side face. Earlier attachments remain fitted. Mount: Central underside recess, without reducing hand clearance. Do not include any later-stage attachment. Preserve rules: Exactly two emitter prongs, one self-contained body, no conventional bullet barrel, liquid fuel tank, backpack dependency, or dangling impossible cable. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the approved neutral image, or approve one for this unpictured asset, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size, in grayscale, as a solid silhouette and against a dark background.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects, glow shapes and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

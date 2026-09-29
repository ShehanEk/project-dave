# Graviton Tether

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** W05\
**Category:** weapons\
**First appearance:** Level 6\
**Design status:** Confirmed 2D rendering style (C11) and dark sci-fi mood (C15); C35 amends the rendering to flat paint lit in the engine (confirmed direction, validated by the approved lit-cutout test (2026-09-30)). The palette tokens (P21) and this asset's appearance and lore details are proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Cargo-handling device for grabbing, throwing, and pulling Dave to marked anchors. It comes from the Rootworks freight bays, where Arcadia's crews used it to move loose cargo. Dave picks it up on Level 6, in a freight bay before the arena.

*Proposed lore:* the ring's focusing fingers were made to lock onto crates, which is why they can also lock onto small enemies and loose props.

## Scale and silhouette

Approximately 0.68 m long and 0.38 m tall; front ring 0.32 m across.

A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design ([hero brief](../../design/02-characters/hero.md)) is not fixed by this measurement.

## Appearance and construction

Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a freight-yellow cargo casing, a pale top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring.

## Color and materials

Freight yellow #D9AC2A; pale brace gray #D4DADD; steel blue-gray #4A6275; dark rubber #2C363C; azure field light #5CA8FF with a white core. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on handle edges and ring bumpers.

Dark-scene readability: the yellow casing and the pale brace carry the silhouette against near-black scenery, and the open ring takes the engine's lamp light along its outer edge (no rim light is painted). The yellow is matte paint and never glows. The field light is azure-white, never violet (reserved for the Bloom) and never teal (Arcadia and Adam at rest). Anchor points in level art should carry a matching azure-white marker so the pairing reads (proposed).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Captures loose objects and small enemies after a brief lock, throws them, and pulls Dave to designated anchors. Later can capture medium enemies while staggered. Heavy enemies and bosses remain immune.

The three fingers spread slightly when acquiring a target. The ring carriage slides back under a heavy load, the field line tightens, and a release pulse propels the object. Pulling to an anchor tilts the whole weapon forward rather than extending a physical hook.

## Openings and limitations

The tether is the sole carried weapon when equipped. Mandatory fights must supply reachable replenishable throwable props and valid damage lines. Medium-target capture can use an environmental stagger; it never assumes a carried shotgun. Anchor movement is unavailable while another weapon is carried.

Capture takes time, and target size matters. It cannot create arbitrary grapple points or lift an entire mini-boss.

## Rig parts, normal maps and sockets

Power body; rear grip; top support handle; ring; three brackets; three focusing fingers; recoil carriage; cable; load indicator; three upgrade mounts. Tether lines, held-object effects, and impact pulse remain separate.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. Under the lit cutout pipeline (C35, validated 2026-09-30) each listed part is painted flat with its own matching normal map, the grip is the socket where Dave's hand holds the weapon, and the muzzle marks where its flash light sits. Frame counts and timing remain later production choices.

## Required pose and state references

Neutral ring; target acquisition; light load; heavy load; throw release; anchor pull; impact-pulse effect; four cumulative appearance stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. No violet anywhere: the field light is azure-white. No logos or legible text.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand on the grip and support hand on the upper handle. Leave enough separation for Dave's wrists while aiming the open ring forward.

No conventional ammunition projectile. Use a thin azure-white connection with a bright ring around the held target; show the target separately. Impact Pulse is a brief expanding ground-level ring after collision.

## Single-weapon gameplay rule

This weapon occupies Dave's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; Dave does not retain it as a backup or a separate utility tool. Images of Dave must not show additional carried guns.

Microchips (C19) are the primary collectible and the upgrade currency; evidence files (proposed) are optional journal finds with no stat effect. Re-flashing microchips into the carried weapon at a workbench (proposed name) to buy its upgrades is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

*Proposed:* each attachment seats a small re-flashed microchip module (a thumbnail-sized square chip with thin gold contact edges), showing the upgrade Dave bought at a workbench. Keep the modules small graphic shapes with no gold glow, so they never read as microchip pickups or change the silhouette.

### Stage 1: Long Reach

**Capability:** Extends object capture distance and reach to designated anchors.

**Visible change:** A pale rectangular signal rail sits along the top brace, ending in a small rounded azure receiver. It stays below Dave's sight line and behind the field ring. A small square microchip module with thin gold contact edges is seated in a slot at the rail's rear end.

**Attachment location:** Top brace rail.

### Stage 2: Heavy Lifter

**Capability:** Lifts medium objects and staggered medium enemies; heavy enemies and bosses remain immune.

**Visible change:** Three chunky yellow reinforcement collars fit onto the existing ring brackets, thickening the same three-spoke silhouette. The body gains a small rear counterweight. A small square microchip module with thin gold contact edges is seated in a slot on the counterweight's left face. Long Reach remains fitted.

**Attachment location:** Three existing brackets and rear balance mount.

### Stage 3: Impact Pulse

**Capability:** Thrown targets produce a small damaging shockwave on collision.

**Visible change:** A second shallow azure induction rim fits directly behind the original front ring, visually nested rather than a separate floating ring. One pulse window on the case marks release readiness. A small square microchip module with thin gold contact edges is seated in a slot beside that window. Earlier attachments remain.

**Attachment location:** Ring rear flange and left body panel.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Chunky rounded silhouette with a few readable functional details; suggest metal, plastic, ceramic, tape, rubber and glass through flat color areas and clean marks rather than painted reflections, with only subtle texture inside large color areas (the engine adds light and fine surface detail through a normal map). No painted light: no highlights, rim light, glow shapes, airbrushed gradients, photoreal volumetrics, glossy chrome or pixel art. Keep the weapon's own local colors. No franchise assets.

Design Graviton Tether. Role: Cargo-handling device for grabbing, throwing, and pulling the wielder to marked anchors.
Scale: Approximately 0.68 m long and 0.38 m tall; front ring 0.32 m across.
Silhouette: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette.
Physical design: Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a freight-yellow cargo casing, a pale top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring.
Materials and colors: Freight yellow #D9AC2A; pale brace gray #D4DADD; steel blue-gray #4A6275; dark rubber #2C363C; azure field light #5CA8FF with a white core. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on handle edges and ring bumpers.
Critical consistency: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. No violet anywhere: the field light is azure-white. No logos or legible text.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no blood. Use a readable gameplay side pose with generous margins and the stated proportions. Use clean dark outlines and flat local colors. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Graviton Tether design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors, evenly lit with no baked shadows, on a flat mid-grey (#808080) background. Maintain these proportions: Approximately 0.68 m long and 0.38 m tall; front ring 0.32 m across. Maintain these defining forms: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Preserve construction: Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a freight-yellow cargo casing, a pale top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Preserve the palette: Freight yellow #D9AC2A; pale brace gray #D4DADD; steel blue-gray #4A6275; dark rubber #2C363C; azure field light #5CA8FF with a white core. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated on handle edges and ring bumpers. Lock these details: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. No violet anywhere: the field light is azure-white. No logos or legible text. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Graviton Tether reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Neutral ring; target acquisition; light load; heavy load; throw release; anchor pull; impact-pulse effect; four cumulative appearance stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: The three fingers spread slightly when acquiring a target. The ring carriage slides back under a heavy load, the field line tightens, and a release pulse propels the object. Pulling to an anchor tilts the whole weapon forward rather than extending a physical hook. Capability: Captures loose objects and small enemies after a brief lock, throws them, and pulls the wielder to designated anchors. Later can capture medium enemies while staggered. Heavy enemies and bosses remain immune. Important limitation or opening: Capture takes time, and target size matters. It cannot create arbitrary grapple points or lift an entire mini-boss. Handling: Rear hand on the grip and support hand on the upper handle. Leave enough separation for the wielder's wrists while aiming the open ring forward. Keep effects small and separate enough that the body or weapon silhouette is visible. Use a flat mid-grey (#808080) background, evenly lit and flat-colored with no baked shadows, no rim light and no blood; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette and line weight unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Long Reach

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 1 of the approved DEAD EDEN Graviton Tether weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a freight-yellow cargo casing, a pale top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Show all cumulative attachments through this stage: 1. Long Reach: A pale rectangular signal rail sits along the top brace, ending in a small rounded azure receiver. It stays below the wielder's sight line and behind the field ring. A small square microchip module with thin gold contact edges is seated in a slot at the rail's rear end. Mount: Top brace rail. Do not include any later-stage attachment. Preserve rules: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. No violet anywhere: the field light is azure-white. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Heavy Lifter

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 2 of the approved DEAD EDEN Graviton Tether weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a freight-yellow cargo casing, a pale top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Show all cumulative attachments through this stage: 1. Long Reach: A pale rectangular signal rail sits along the top brace, ending in a small rounded azure receiver. It stays below the wielder's sight line and behind the field ring. A small square microchip module with thin gold contact edges is seated in a slot at the rail's rear end. Mount: Top brace rail. 2. Heavy Lifter: Three chunky yellow reinforcement collars fit onto the existing ring brackets, thickening the same three-spoke silhouette. The body gains a small rear counterweight. A small square microchip module with thin gold contact edges is seated in a slot on the counterweight's left face. Long Reach remains fitted. Mount: Three existing brackets and rear balance mount. Do not include any later-stage attachment. Preserve rules: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. No violet anywhere: the field light is azure-white. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Impact Pulse

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 3 of the approved DEAD EDEN Graviton Tether weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A forward circular field ring supported by three thick radial brackets, attached to a compact weighted body with a rear grip and broad upper support handle. The open ring is the defining silhouette. Three short mechanical focusing fingers sit evenly around the ring and point inward without meeting. The body has a freight-yellow cargo casing, a pale top brace, and a small visible recoil carriage connecting the ring to the main housing. A protected cable runs along the underside. All floating-target effects originate visibly at the ring. Show all cumulative attachments through this stage: 1. Long Reach: A pale rectangular signal rail sits along the top brace, ending in a small rounded azure receiver. It stays below the wielder's sight line and behind the field ring. A small square microchip module with thin gold contact edges is seated in a slot at the rail's rear end. Mount: Top brace rail. 2. Heavy Lifter: Three chunky yellow reinforcement collars fit onto the existing ring brackets, thickening the same three-spoke silhouette. The body gains a small rear counterweight. A small square microchip module with thin gold contact edges is seated in a slot on the counterweight's left face. Long Reach remains fitted. Mount: Three existing brackets and rear balance mount. 3. Impact Pulse: A second shallow azure induction rim fits directly behind the original front ring, visually nested rather than a separate floating ring. One pulse window on the case marks release readiness. A small square microchip module with thin gold contact edges is seated in a slot beside that window. Earlier attachments remain. Mount: Ring rear flange and left body panel. Do not include any later-stage attachment. Preserve rules: Exactly one ring, three brackets, and three focusing fingers. No physical grappling hook, additional barrel, organic tentacles, or unsupported floating machine components. No violet anywhere: the field light is azure-white. No logos or legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the approved neutral image, or approve one for this unpictured asset, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size, in grayscale, as a solid silhouette and against a dark background.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects, glow shapes and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

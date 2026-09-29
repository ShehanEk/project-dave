# Scrapjack Pistol

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** W01\
**Category:** weapons\
**First appearance:** Level 1\
**Design status:** Confirmed 2D rendering style (C11) and dark sci-fi mood (C15); C35 amends the rendering to flat paint lit in the engine (confirmed direction, validated by the approved lit-cutout test (2026-09-30)). The palette tokens (P21) and this asset's appearance and lore details are proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Dave's dependable precision sidearm: a homemade coil pistol built from lab scrap after the lockout, visually personal and improvised rather than issued by Arcadia. Hand-wound copper coils, a taped grip and a salvaged Arcadia battery cell with a teal charge light make up its look, and it fires compacted scrap bolts. It is the weapon Dave starts with, for reliable, accurate shooting while running and jumping.

*Proposed lore:* the battery cell came out of a discarded Arcadia lab instrument, and its serial plate is scratched out (a blank scuffed patch in the art, with no legible text). The pistol is the odd one out among Dave's gear, because every other weapon is repurposed Arcadia equipment.

## Scale and silhouette

Approximately 0.38 m long and 0.24 m tall; usable one-handed by Dave at the provisional 1.70 m human scale.

A compact, chunky L silhouette with a square scrap-feed housing, a short oversized round muzzle, and a backward-slanted taped grip. A small improvised sight sits high enough to read but does not dominate the outline. The copper coil bands and the battery cell sit inside this outline and do not change it.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design ([hero brief](../../design/02-characters/hero.md)) is not fixed by this measurement.

## Appearance and construction

A rust-red upper housing is bolted to a mismatched pale lower frame cut from a lab equipment case. Use three large visible fastener heads on the left side, one broad top service seam, and a recessed side feed window containing abstract compacted scrap. Two broad hand-wound copper coil bands, drawn as bold curved stripes rather than realistic wire, wrap the short round muzzle housing, which ends in a plain steel muzzle ring around a thick dark inner ring, not realistic internal rifling. A salvaged battery cell, drawn as a chunky rounded rectangle held by a scrap strap, sits flush in a recess on the left flank of the lower frame ahead of the guard, with one round teal charge light and a blank scratched serial patch. The grip is wrapped in overlapping strips of dark cloth tape with frayed pale edges. A rounded guard leaves generous hand clearance.

## Color and materials

Rust red #B5533A; lab-casing gray #C4CAD0; dark steel #56626C; hand-wound copper #D9884A; cloth-tape charcoal #2B3138 with frayed pale edges #8B96A0; battery-cell gunmetal #59636D; teal charge light #3FE0D0. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated at the grip, muzzle rim, and housing corners.

Dark-scene readability: against near-black scenery the pale lower frame and the teal charge light carry the silhouette, while the rust-red housing needs a heavy outline, and the engine's lamp light picks out its top edge (no rim light is painted). Dave's burnt-orange jacket sits close to the housing's warm hue, so when the pistol is held near the body keep the pale frame and dark outline between the red housing and the jacket. The teal glow is a small flat halo, never a beam.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Accurate scrap bolts with modest base damage. Three cumulative upgrades improve fire rate, light-armor penetration, and an optional charged weak-point shot. Heavy shields still demand openings. In the working resource proposal the low-output cell recycles scrap into bolts, so basic shots are unlimited with no magazine; the charge light is a status light, never an ammo gauge.

Small crisp recoil and a visible top block movement create a handmade but dependable feel. The copper coil bands flash a brief hot glow at each shot and the charge light dips slightly, then recovers. Dave can keep the muzzle level while running. Upgraded charging gradually opens a small top vent and brightens the capacitor window.

## Openings and limitations

Its base limitation is low damage against armor. Keep the visual silhouette compact after upgrades; it must not become a rifle or second shotgun.

## Rig parts, normal maps and sockets

Main body; taped grip; trigger and guard; moving top block; muzzle ring; copper coil bands; battery cell with its charge light (glow shape on its own layer); side feed insert; three reserved upgrade sockets. Muzzle flash, coil glow and bolt trails are separate effects.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. Under the lit cutout pipeline (C35, validated 2026-09-30) each listed part is painted flat with its own matching normal map, the grip is the socket where Dave's hand holds the weapon, and the muzzle marks where its flash light sits. Frame counts and timing remain later production choices.

## Required pose and state references

Base neutral prop; held one-handed; standard firing recoil; service/feed animation study; upgraded charge; Power Shot release; all four cumulative appearance stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One muzzle, one grip, no stock or scope. Keep the taped grip, rust-red upper housing, pale lower frame, copper coil bands and single teal-lit battery cell in every stage. Fictional prop design only, with no fabrication cross-sections, no logos and no legible text.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Main hand around the slanted grip; index finger clears the guard. Show a simple separate hand silhouette only on the handling sheet. No hands on the clean sprite reference.

A squat faceted scrap bolt with a hot white core and a short copper-orange trail, kept clearly different from red tell effects and amber warning lights. Standard bolt stays small; Power Shot is a thicker brighter version with a brief ring at release.

## Single-weapon gameplay rule

This weapon occupies Dave's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; Dave does not retain it as a backup or a separate utility tool. Images of Dave must not show additional carried guns.

Microchips (C19) are the primary collectible and the upgrade currency; evidence files (proposed) are optional journal finds with no stat effect. Re-flashing microchips into the carried weapon at a workbench (proposed name) to buy its upgrades is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

*Proposed:* each attachment seats a small re-flashed microchip module (a thumbnail-sized square chip with thin gold contact edges), showing the upgrade Dave bought at a workbench. Keep the modules small graphic shapes with no gold glow, so they never read as microchip pickups or change the silhouette.

### Stage 1: Quickcycle

**Capability:** Increases firing speed.

**Visible change:** A compact copper flywheel cover attaches flush to the anatomical left side of the rear housing, below the service seam. Its visible dial spins faster during firing; it does not add another barrel. A small square microchip module with thin gold contact edges is seated in a slot on the cover's rim.

**Attachment location:** Left rear housing circular socket.

### Stage 2: Punch-Through

**Capability:** Bolts penetrate light armor and continue through one small enemy.

**Visible change:** A short dark sleeve with two broad forward ribs fits around the existing muzzle. It extends the nose only slightly and leaves the coil bands visible behind it. A small square microchip module with thin gold contact edges is seated in a slot on the sleeve's left flank. The Quickcycle cover remains fitted.

**Attachment location:** Existing muzzle outer ring.

### Stage 3: Power Shot

**Capability:** Adds an optional charged bolt that hits exposed weak points hard.

**Visible change:** A rounded capacitor can sits on the top rear rail, behind the sight, with a small teal window that brightens toward white as the shot charges. Two thick insulated strips run into the housing, and a small square microchip module with thin gold contact edges is seated in the can's base plate. Charging opens one top vent; earlier upgrades remain visible.

**Attachment location:** Top rear rail, clear of the gripping hand and sight.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Chunky rounded silhouette with a few readable functional details; suggest metal, plastic, ceramic, tape, rubber and glass through flat color areas and clean marks rather than painted reflections, with only subtle texture inside large color areas (the engine adds light and fine surface detail through a normal map). No painted light: no highlights, rim light, glow shapes, airbrushed gradients, photoreal volumetrics, glossy chrome or pixel art. Keep the weapon's own local colors. No franchise assets.

Design Scrapjack Pistol. Role: Dependable precision sidearm; a homemade coil pistol built from lab scrap, visually personal and improvised rather than issued equipment.
Scale: Approximately 0.38 m long and 0.24 m tall; usable one-handed by the wielder at the provisional 1.70 m human scale.
Silhouette: A compact, chunky L silhouette with a square scrap-feed housing, a short oversized round muzzle, and a backward-slanted taped grip. A small improvised sight sits high enough to read but does not dominate the outline. The copper coil bands and the battery cell sit inside this outline and do not change it.
Physical design: A rust-red upper housing is bolted to a mismatched pale lower frame cut from a lab equipment case. Use three large visible fastener heads on the left side, one broad top service seam, and a recessed side feed window containing abstract compacted scrap. Two broad hand-wound copper coil bands, drawn as bold curved stripes rather than realistic wire, wrap the short round muzzle housing, which ends in a plain steel muzzle ring around a thick dark inner ring, not realistic internal rifling. A salvaged battery cell, drawn as a chunky rounded rectangle held by a scrap strap, sits flush in a recess on the left flank of the lower frame ahead of the guard, with one round teal charge light and a blank scratched serial patch. The grip is wrapped in overlapping strips of dark cloth tape with frayed pale edges. A rounded guard leaves generous hand clearance.
Materials and colors: Rust red #B5533A; lab-casing gray #C4CAD0; dark steel #56626C; hand-wound copper #D9884A; cloth-tape charcoal #2B3138 with frayed pale edges #8B96A0; battery-cell gunmetal #59636D; teal charge light #3FE0D0. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated at the grip, muzzle rim, and housing corners.
Critical consistency: One muzzle, one grip, no stock or scope. Keep the taped grip, rust-red upper housing, pale lower frame, copper coil bands and single teal-lit battery cell in every stage. Fictional prop design only, with no fabrication cross-sections, no logos and no legible text.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no blood. Use a readable gameplay side pose with generous margins and the stated proportions. Use clean dark outlines and flat local colors. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Scrapjack Pistol design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors, evenly lit with no baked shadows, on a flat mid-grey (#808080) background. Maintain these proportions: Approximately 0.38 m long and 0.24 m tall; usable one-handed by the wielder at the provisional 1.70 m human scale. Maintain these defining forms: A compact, chunky L silhouette with a square scrap-feed housing, a short oversized round muzzle, and a backward-slanted taped grip. A small improvised sight sits high enough to read but does not dominate the outline. The copper coil bands and the battery cell sit inside this outline and do not change it. Preserve construction: A rust-red upper housing is bolted to a mismatched pale lower frame cut from a lab equipment case. Use three large visible fastener heads on the left side, one broad top service seam, and a recessed side feed window containing abstract compacted scrap. Two broad hand-wound copper coil bands, drawn as bold curved stripes rather than realistic wire, wrap the short round muzzle housing, which ends in a plain steel muzzle ring around a thick dark inner ring, not realistic internal rifling. A salvaged battery cell, drawn as a chunky rounded rectangle held by a scrap strap, sits flush in a recess on the left flank of the lower frame ahead of the guard, with one round teal charge light and a blank scratched serial patch. The grip is wrapped in overlapping strips of dark cloth tape with frayed pale edges. A rounded guard leaves generous hand clearance. Preserve the palette: Rust red #B5533A; lab-casing gray #C4CAD0; dark steel #56626C; hand-wound copper #D9884A; cloth-tape charcoal #2B3138 with frayed pale edges #8B96A0; battery-cell gunmetal #59636D; teal charge light #3FE0D0. Upgrade modules add thin microchip-gold #FFD166 contact edges only. Wear is concentrated at the grip, muzzle rim, and housing corners. Lock these details: One muzzle, one grip, no stock or scope. Keep the taped grip, rust-red upper housing, pale lower frame, copper coil bands and single teal-lit battery cell in every stage. Fictional prop design only, with no fabrication cross-sections, no logos and no legible text. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Scrapjack Pistol reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Base neutral prop; held one-handed; standard firing recoil; service/feed animation study; upgraded charge; Power Shot release; all four cumulative appearance stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: Small crisp recoil and a visible top block movement create a handmade but dependable feel. The copper coil bands flash a brief hot glow at each shot and the charge light dips slightly, then recovers. The wielder can keep the muzzle level while running. Upgraded charging gradually opens a small top vent and brightens the capacitor window. Capability: Accurate scrap bolts with modest base damage. Three cumulative upgrades improve fire rate, light-armor penetration, and an optional charged weak-point shot. Heavy shields still demand openings. The charge light is a status light, never an ammo gauge. Important limitation or opening: Its base limitation is low damage against armor. Keep the visual silhouette compact after upgrades; it must not become a rifle or second shotgun. Handling: Main hand around the slanted grip; index finger clears the guard. Show a simple separate hand silhouette only on the handling sheet. No hands on the clean sprite reference. Keep effects small and separate enough that the body or weapon silhouette is visible. Use a flat mid-grey (#808080) background, evenly lit and flat-colored with no baked shadows, no rim light and no blood; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette and line weight unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Quickcycle

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 1 of the approved DEAD EDEN Scrapjack Pistol weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact, chunky L silhouette with a square scrap-feed housing, a short oversized round muzzle, and a backward-slanted taped grip. A small improvised sight sits high enough to read but does not dominate the outline. The copper coil bands and the battery cell sit inside this outline and do not change it. A rust-red upper housing is bolted to a mismatched pale lower frame cut from a lab equipment case. Use three large visible fastener heads on the left side, one broad top service seam, and a recessed side feed window containing abstract compacted scrap. Two broad hand-wound copper coil bands, drawn as bold curved stripes rather than realistic wire, wrap the short round muzzle housing, which ends in a plain steel muzzle ring around a thick dark inner ring, not realistic internal rifling. A salvaged battery cell, drawn as a chunky rounded rectangle held by a scrap strap, sits flush in a recess on the left flank of the lower frame ahead of the guard, with one round teal charge light and a blank scratched serial patch. The grip is wrapped in overlapping strips of dark cloth tape with frayed pale edges. A rounded guard leaves generous hand clearance. Show all cumulative attachments through this stage: 1. Quickcycle: A compact copper flywheel cover attaches flush to the anatomical left side of the rear housing, below the service seam. Its visible dial spins faster during firing; it does not add another barrel. A small square microchip module with thin gold contact edges is seated in a slot on the cover's rim. Mount: Left rear housing circular socket. Do not include any later-stage attachment. Preserve rules: One muzzle, one grip, no stock or scope. Keep the taped grip, rust-red upper housing, pale lower frame, copper coil bands and single teal-lit battery cell in every stage. Fictional prop design only, with no fabrication cross-sections, no logos and no legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Punch-Through

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 2 of the approved DEAD EDEN Scrapjack Pistol weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact, chunky L silhouette with a square scrap-feed housing, a short oversized round muzzle, and a backward-slanted taped grip. A small improvised sight sits high enough to read but does not dominate the outline. The copper coil bands and the battery cell sit inside this outline and do not change it. A rust-red upper housing is bolted to a mismatched pale lower frame cut from a lab equipment case. Use three large visible fastener heads on the left side, one broad top service seam, and a recessed side feed window containing abstract compacted scrap. Two broad hand-wound copper coil bands, drawn as bold curved stripes rather than realistic wire, wrap the short round muzzle housing, which ends in a plain steel muzzle ring around a thick dark inner ring, not realistic internal rifling. A salvaged battery cell, drawn as a chunky rounded rectangle held by a scrap strap, sits flush in a recess on the left flank of the lower frame ahead of the guard, with one round teal charge light and a blank scratched serial patch. The grip is wrapped in overlapping strips of dark cloth tape with frayed pale edges. A rounded guard leaves generous hand clearance. Show all cumulative attachments through this stage: 1. Quickcycle: A compact copper flywheel cover attaches flush to the anatomical left side of the rear housing, below the service seam. Its visible dial spins faster during firing; it does not add another barrel. A small square microchip module with thin gold contact edges is seated in a slot on the cover's rim. Mount: Left rear housing circular socket. 2. Punch-Through: A short dark sleeve with two broad forward ribs fits around the existing muzzle. It extends the nose only slightly and leaves the coil bands visible behind it. A small square microchip module with thin gold contact edges is seated in a slot on the sleeve's left flank. The Quickcycle cover remains fitted. Mount: Existing muzzle outer ring. Do not include any later-stage attachment. Preserve rules: One muzzle, one grip, no stock or scope. Keep the taped grip, rust-red upper housing, pale lower frame, copper coil bands and single teal-lit battery cell in every stage. Fictional prop design only, with no fabrication cross-sections, no logos and no legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Power Shot

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 3 of the approved DEAD EDEN Scrapjack Pistol weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A compact, chunky L silhouette with a square scrap-feed housing, a short oversized round muzzle, and a backward-slanted taped grip. A small improvised sight sits high enough to read but does not dominate the outline. The copper coil bands and the battery cell sit inside this outline and do not change it. A rust-red upper housing is bolted to a mismatched pale lower frame cut from a lab equipment case. Use three large visible fastener heads on the left side, one broad top service seam, and a recessed side feed window containing abstract compacted scrap. Two broad hand-wound copper coil bands, drawn as bold curved stripes rather than realistic wire, wrap the short round muzzle housing, which ends in a plain steel muzzle ring around a thick dark inner ring, not realistic internal rifling. A salvaged battery cell, drawn as a chunky rounded rectangle held by a scrap strap, sits flush in a recess on the left flank of the lower frame ahead of the guard, with one round teal charge light and a blank scratched serial patch. The grip is wrapped in overlapping strips of dark cloth tape with frayed pale edges. A rounded guard leaves generous hand clearance. Show all cumulative attachments through this stage: 1. Quickcycle: A compact copper flywheel cover attaches flush to the anatomical left side of the rear housing, below the service seam. Its visible dial spins faster during firing; it does not add another barrel. A small square microchip module with thin gold contact edges is seated in a slot on the cover's rim. Mount: Left rear housing circular socket. 2. Punch-Through: A short dark sleeve with two broad forward ribs fits around the existing muzzle. It extends the nose only slightly and leaves the coil bands visible behind it. A small square microchip module with thin gold contact edges is seated in a slot on the sleeve's left flank. The Quickcycle cover remains fitted. Mount: Existing muzzle outer ring. 3. Power Shot: A rounded capacitor can sits on the top rear rail, behind the sight, with a small teal window that brightens toward white as the shot charges. Two thick insulated strips run into the housing, and a small square microchip module with thin gold contact edges is seated in the can's base plate. Charging opens one top vent; earlier upgrades remain visible. Mount: Top rear rail, clear of the gripping hand and sight. Do not include any later-stage attachment. Preserve rules: One muzzle, one grip, no stock or scope. Keep the taped grip, rust-red upper housing, pale lower frame, copper coil bands and single teal-lit battery cell in every stage. Fictional prop design only, with no fabrication cross-sections, no logos and no legible text. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the approved neutral image, or approve one for this unpictured asset, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size, in grayscale, as a solid silhouette and against a dark background.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects, glow shapes and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

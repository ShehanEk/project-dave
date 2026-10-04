# Scrapjack Pistol

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** W01\
**Category:** weapons\
**First appearance:** Level 1\
**Design status:** Confirmed 2D rendering style (C11) and dark sci-fi mood (C15); C35 amends the rendering to flat paint lit in the engine (confirmed direction, validated by the approved lit-cutout test (2026-09-30)). The palette tokens (P21) and this asset's appearance and lore details are proposed. Dimensions are provisional art proportions, not engine specifications.

## Visual reference status

**Look chosen (2026-10-04):** [w01-scrapjack-look-v1.webp](../../concept-art/w01-scrapjack/w01-scrapjack-look-v1.webp), a lit concept with the C37 look. It is a look reference, not the source painting: the parts are painted flat from it with prompt 4 below, and the engine adds the light. It places two things differently from this brief, and the parts sheet follows the concept: the scrap feed window sits in the rust-red upper housing, and the battery cell is slung under the copper barrel ahead of the guard, piped to the coils. **Parts sheet in the game (2026-10-04):** [w01-scrapjack-parts-v1.webp](../../concept-art/w01-scrapjack/w01-scrapjack-parts-v1.webp), imported with `tools/art/import_parts_sheet.py scrapjack` as a lit rig of four parts (frame, upper housing, barrel, battery cell), about 26 px from grip to muzzle. Dave's fist wraps the grip; on each shot the upper housing and the barrel snap back together, the copper coils flash hot and cool, and the teal charge light dips and recovers.

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

A compacted scrap slug fired as a kinetic round (C37): a short tracer-ivory streak (#F2EBD3) with a dark outline and a faint fading trail, never amber, gold or green, so it stays clearly different from red and amber tells and from blue-white energy shots. Standard slug stays small; Power Shot is a thicker, brighter version with a brief ring at release.

## Shooting effects (C37)

*Chosen by the user (2026-10-04).* All effects are separate from the gun's parts and drawn by the engine.

- **Muzzle:** each shot flashes a short ivory flash at the muzzle with a brief ivory light (C35: firearm flashes are ivory; rapid fire holds one glow and never strobes). The copper coil bands glow hot for a beat and fade, and the teal charge light dips slightly, then recovers. A thin wisp of smoke lingers after a burst.
- **Shot:** the ivory tracer slug above, with a small travelling light so it lights the scenery it passes.
- **Hits:** armor, machines and walls throw white sparks and a few dark scrap chips; flesh shows the target's own blood (no spark). A blocked hit on armor reads as a glancing spark and a dull clank, never as a wound.
- **Feel (punchy but clean):** a crisp arm recoil and the top block snapping back; a small camera kick per shot; a brief hit-pause (about 30 ms) and the enemy's hit flash on a hit; a stronger shake and burst on a kill. Reduced Motion halves the camera kick and shake and drops the hit-pause.

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

## Look prompt — lit concept (C37)

A look test, not the source painting: lit concept art of the gun alone, so it shows how the Scrapjack should feel in the game. Approve one, then paint the parts flat from it with prompt 4.

```text
Original 2D concept art for DEAD EDEN, a mature dark sci-fi side-view platformer shooter. Look: light cyberpunk at night. Deep navy-black darks lit by practical lamps; strong, saturated colors against the dark; high contrast, never washed out, never pastel. Clean painted shapes with crisp near-black outlines, smooth realistic lighting with soft glows around light sources and a faint cool moonlight rim. Not photorealistic, not anime, not pixel art. No text, logos, watermark or UI.

Subject: the Scrapjack, a homemade coil pistol a rogue AI researcher built from lab scrap, alone, in strict side view, muzzle pointing right, large and centered. About 0.38 m long and 0.24 m tall: a compact, chunky L silhouette. A rust-red upper housing (#B5533A) bolted to a mismatched pale lab-casing grey lower frame (#C4CAD0) with three large fastener heads and one broad top service seam; a recessed side feed window showing dark compacted scrap; a short, oversized round muzzle housing wrapped in two broad hand-wound copper coil bands (#D9884A) glowing faintly hot orange at their edges, ending in a plain dark steel muzzle ring (#56626C); a salvaged gunmetal battery cell (#59636D) held by a scrap strap in a recess on the frame ahead of the guard, with one small round teal charge light (#3FE0D0) and a blank scratched serial patch; a backward-slanted grip wrapped in charcoal cloth tape (#2B3138) with frayed pale edges; a rounded trigger guard; a small improvised sight on top. Wear at the grip, the muzzle rim and the housing corners. It looks personal and improvised, not factory-made.
Setting: resting on a dark lab bench at night, lit from above-left by a cold white desk lamp (#D8E6F0) with a soft pool of light, the teal charge light and the warm coils the only other glows. No hand, no bullets, no muzzle flash, no text or logos.
```

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
## Image prompt 4 — rig parts sheet

Attach the approved look reference. This turns the lit concept into the flat source painting, already split into the gun's parts. Save it as a PNG for import: the coil bands get their own part so the engine can make them glow at each shot, and the teal charge light becomes a steady glow.

```text
Using the attached approved Scrapjack concept as the exact design reference, paint a 2D cutout-rig parts sheet of the same pistol for a side-view game. Same gun, same shapes, same proportions and same details (the rust-red upper housing with its fastener heads, scrap feed window and small sight, the pale grey lower frame with its trigger guard, the taped slanted grip, the copper coil barrel with its steel bands and muzzle ring, the battery cell under the barrel with its strap, teal light, blank serial patch and two small pipes up to the coils): not a redesign. Keep the rust and wear as flat painted marks. The reference is lit at night; this sheet is not. Convert it to flat, evenly lit base colors and remove the lamp light, reflections and shadows.

Style: flat base colors, evenly lit. No shadows, no highlights, no rim light, no gradients, no glow. Paint the copper coils as flat copper with no hot glow, and the charge light as a flat teal disc.

Color: keep every color at its exact hex value at full strength. Do not lighten, fade, desaturate or grey out the image. The grip tape is near-black, the steel bands and muzzle ring are mid-dark steel, the housing is a strong rust red, and the lower frame is the lightest large area.

Outlines: crisp near-black (#0B0D10), about 4-6 px on the outer contour and 2 px inside.

Background: transparent. If transparency is not possible, a flat solid mid-grey (#808080) with no texture, noise or vignette.

Layout: a landscape canvas. Draw each part below as a separate, complete piece, as seen in the side view with the muzzle pointing right, all at the same scale (the assembled pistol would be about 900 px long). Leave at least 60 px of empty space between parts; no part may touch or overlap another. No labels, text, numbers, grid lines, frames or drop shadows.

Parts, exactly these, once each:
1. Frame: the pale grey lower frame with the taped slanted grip and the trigger guard (trigger inside), with no upper housing, no barrel and no battery cell attached. Paint it complete where the other parts will cover it.
2. Upper housing: the rust-red top block with its fastener heads, the scrap feed window full of dark scrap, and the small sight, alone; its bottom edge extends a little so it overlaps the frame.
3. Barrel: the round barrel with its two copper coil sections between steel bands and the steel muzzle ring at its right end; its left end extends a little so it tucks under the upper housing.
4. Battery cell: the gunmetal cell in its scrap strap, with the flat teal charge light, the blank serial patch and the two short pipes that run up to the barrel.

Palette: rust red #B5533A; lab-casing grey #C4CAD0; dark steel #56626C; copper #D9884A; tape charcoal #2B3138 with frayed edges #8B96A0; battery gunmetal #59636D; teal charge light #3FE0D0. No text or logos, no hand, no bullets, no muzzle flash.
```

## Before sprite production

- Use the approved neutral image, or approve one for this unpictured asset, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size, in grayscale, as a solid silhouette and against a dark background.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects, glow shapes and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

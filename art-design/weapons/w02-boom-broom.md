# Boom Broom

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** W02\
**Category:** weapons\
**First appearance:** Level 2\
**Design status:** Confirmed 2D rendering style (C11) and dark sci-fi mood (C15); C35 amends the rendering to flat paint lit in the engine (confirmed direction, validated by the approved lit-cutout test (2026-09-30)). The palette tokens (P21) and this asset's appearance and lore details are proposed. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Pump-action industrial shotgun; the close-range weapon with the strongest physical punch. It is the chunky blaster Arcadia's maintenance crews used to clear clogged coolant pipes. Arcadia's asset system calls it a "high-pressure debris removal device" and still logs every blast as plumbing service. Dave takes one on Level 2 and turns it on the people, cyborg dogs and machines that hunt him.

*Proposed lore:* the crews nicknamed it the Boom Broom, and the small tag plate near the guard is Arcadia's asset tag, drawn as plain stripes with no legible text.

## Scale and silhouette

Approximately 0.92 m long, 0.30 m tall, and 0.18 m wide; comfortably two-handed.

A thick single barrel above a parallel magazine tube, an oversized ribbed pump, a compact receiver, and a short padded shoulder stock. The broad circular muzzle and low pump immediately communicate shotgun rather than rifle.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design ([hero brief](../../design/02-characters/hero.md)) is not fixed by this measurement.

## Appearance and construction

The upper barrel is a reclaimed length of galvanized coolant-pipe casing with a dark muzzle collar. The receiver is maintenance-crew orange and bears a small embossed pipe-cleaning pictogram (a brush inside a pipe, no lettering) and a blank asset-tag plate near the guard. A coolant-green sliding pump wraps around the lower tube. The rear grip joins a thick charcoal shoulder pad. A large side opening provides a readable stylized shell-ejection point. Base shells are squat red capsules with brass-colored rims.

## Color and materials

Maintenance orange #E0702A; galvanized pipe gray #AEB9BF; coolant green #3E9E7E; dark steel #444F58; shell red #C8503C; brass rims #C9A24D. Upgrade accents: ember orange #FF9436 for heat glows, pale ceramic gray #D6DCDF for the heat collar, heat-scorched bronze #8C4F2E for the insulated receiver panel, and thin microchip-gold #FFD166 contact edges on modules. Wear is concentrated on the muzzle collar, pump edges and stock pad.

Dark-scene readability: the pale barrel and the coolant-green pump carry the silhouette against near-black scenery, with the engine's lamp light picking out the barrel top (no rim light is painted). Dave's burnt-orange jacket is close to the receiver's orange, so keep a heavy dark outline around the receiver and let the pale barrel and green pump provide the contrast. The shells stay matte and opaque, never glowing red, so they cannot be mistaken for alarm-red attack tells; heat glows use ember orange, never alarm red or hazard amber.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

Wide scrap-pellet blast, strong close-range damage, knockback against small enemies, and stagger against larger ones. Base capacity is four shells. Damage falls off at range and pumping leaves a deliberate recovery gap.

Recoil lifts the muzzle with a solid shoulder kick. The support hand pulls the pump visibly backward and forward. A single oversized shell ejects and bounces. Reloading feeds individual capsules into a clearly visible underside port; the action can stop to fire.

## Openings and limitations

Long-distance accuracy and firing speed remain limited. The Twin Shell upgrade uses two shells and lengthens recovery; it does not turn the weapon into continuous automatic fire.

## Rig parts, normal maps and sockets

Receiver; single upper barrel; lower magazine tube; sliding pump; rear grip; stock and pad; trigger and guard; ejection detail; individual shell prop; asset-tag plate; three upgrade attachment areas. Heat-collar vent glows and pod-window glows sit on their own layers.

Plan overlapping drawing layers and visible pivots for the intended animation method. Keep projectiles, attack trails, warning overlays, impacts and environmental props separate from the character or weapon. Under the lit cutout pipeline (C35, validated 2026-09-30) each listed part is painted flat with its own matching normal map, the grip is the socket where Dave's hand holds the weapon, and the muzzle marks where its flash light sits. Frame counts and timing remain later production choices.

## Required pose and state references

Base clean prop; shoulder hold; single blast recoil; pump backward and forward; shell ejection; individual reload; two-shell blast; four cumulative appearance stages.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

One barrel and one lower magazine tube at every stage, not a double-barreled gun. Preserve the sliding pump and short stock. No real-world branding, logos or legible text, and no practical fabrication diagrams.

Anatomical left and right refer to the subject's own sides, not the viewer's. Do not automatically mirror an asymmetrical design when generating the opposite view.

## Handling and projectile reference

Rear hand at the trigger grip, support hand on the coolant-green pump, shoulder behind the pad. Keep pump travel clear of both guard and muzzle attachments.

A short broad fan of chunky stylized scrap particles, with a brief compressed-air ring. Show one red shell separately. Incendiary Shells add hot ember-orange sparks without hiding the spread.

## Single-weapon gameplay rule

This weapon occupies Dave's only weapon slot. Picking it up drops the previously carried weapon at this pickup location. Choosing another weapon leaves this one in the world; Dave does not retain it as a backup or a separate utility tool. Images of Dave must not show additional carried guns.

Microchips (C19) are the primary collectible and the upgrade currency; evidence files (proposed) are optional journal finds with no stat effect. Re-flashing microchips into the carried weapon at a workbench (proposed name) to buy its upgrades is the working economy proposal. See [Core gameplay rules](../../core-gameplay.md) for confirmed decisions and unresolved persistence details.

## Three cumulative upgrades

Base is stage 0. Stage 1 adds upgrade 1; stage 2 retains upgrade 1 and adds upgrade 2; stage 3 retains both and adds upgrade 3. These are the same weapon and three upgrades, not four different weapons.

*Proposed:* each attachment seats a small re-flashed microchip module (a thumbnail-sized square chip with thin gold contact edges), showing the upgrade Dave bought at a workbench. Keep the modules small graphic shapes with no gold glow, so they never read as microchip pickups or change the silhouette.

### Stage 1: Extended Tube

**Capability:** Expands capacity from four shells to six.

**Visible change:** The lower magazine tube gains a visibly longer pale pipe segment and a rounded orange end cap beneath the barrel. The barrel length stays unchanged. Six small embossed capacity marks replace the base four on the receiver. A small square microchip module with thin gold contact edges is seated in a slot on the end cap.

**Attachment location:** Front of the lower magazine tube, beyond the pump's travel.

### Stage 2: Incendiary Shells

**Capability:** Adds burning damage over time on affected enemies.

**Visible change:** A thick ceramic heat collar with three protected ember-orange vent windows fits behind the muzzle. Shell capsules gain an ember-orange band, and an insulated receiver panel darkens to heat-scorched bronze. A small square microchip module with thin gold contact edges is seated in a slot on the collar's left flank. Extended Tube remains fitted.

**Attachment location:** Outer barrel near the muzzle, clear of the magazine cap.

### Stage 3: Twin Shell

**Capability:** Unlocks an optional two-shell blast with greater damage and knockback and longer recovery.

**Visible change:** A paired pressure-indicator pod mounts atop the receiver, using two round ember-orange windows and a broad selector paddle on its left. Both windows flash together for the alternate blast. A small square microchip module with thin gold contact edges is seated in a slot at the pod's rear. All earlier attachments remain.

**Attachment location:** Top receiver mount, keeping the muzzle silhouette and shoulder line clear.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Chunky rounded silhouette with a few readable functional details; suggest metal, plastic, ceramic, tape, rubber and glass through flat color areas and clean marks rather than painted reflections, with only subtle texture inside large color areas (the engine adds light and fine surface detail through a normal map). No painted light: no highlights, rim light, glow shapes, airbrushed gradients, photoreal volumetrics, glossy chrome or pixel art. Keep the weapon's own local colors. No franchise assets.

Design Boom Broom. Role: Pump-action industrial shotgun; the close-range weapon with the strongest physical punch, built as a coolant-pipe clearing blaster for maintenance crews.
Scale: Approximately 0.92 m long, 0.30 m tall, and 0.18 m wide; comfortably two-handed.
Silhouette: A thick single barrel above a parallel magazine tube, an oversized ribbed pump, a compact receiver, and a short padded shoulder stock. The broad circular muzzle and low pump immediately communicate shotgun rather than rifle.
Physical design: The upper barrel is a reclaimed length of galvanized coolant-pipe casing with a dark muzzle collar. The receiver is maintenance-crew orange and bears a small embossed pipe-cleaning pictogram (a brush inside a pipe, no lettering) and a blank asset-tag plate near the guard. A coolant-green sliding pump wraps around the lower tube. The rear grip joins a thick charcoal shoulder pad. A large side opening provides a readable stylized shell-ejection point. Base shells are squat red capsules with brass-colored rims.
Materials and colors: Maintenance orange #E0702A; galvanized pipe gray #AEB9BF; coolant green #3E9E7E; dark steel #444F58; shell red #C8503C; brass rims #C9A24D. Upgrade accents: ember orange #FF9436 for heat glows, pale ceramic gray #D6DCDF for the heat collar, heat-scorched bronze #8C4F2E for the insulated receiver panel, and thin microchip-gold #FFD166 contact edges on modules. Wear is concentrated on the muzzle collar, pump edges and stock pad.
Critical consistency: One barrel and one lower magazine tube at every stage, not a double-barreled gun. Preserve the sliding pump and short stock. No real-world branding, logos or legible text, and no practical fabrication diagrams.
Show the base weapon, stage 0, with no upgrade attachments and no hands. Reserve the stated mounting regions without fitting the upgrades.

One complete 2D subject only, centered and fully visible on a flat mid-grey (#808080) background, evenly lit and flat-colored so it can be cut into parts: no baked shadows, no cast or contact shadow, no highlights, no rim light, no glow, no blood. Use a readable gameplay side pose with generous margins and the stated proportions. Use clean dark outlines and flat local colors. No studio-light gradients, perspective camera effects, environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated part counts. Draw one subject, not a multi-panel sheet.
```
## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Boom Broom design for DEAD EDEN. This is the same exact asset, not a redesign. Show left-facing and right-facing side drawings for gameplay, plus one small grip or moving-part detail only if needed. Use the same canvas scale and grip/pivot alignment in both directions. Use consistent flat colors, evenly lit with no baked shadows, on a flat mid-grey (#808080) background. Maintain these proportions: Approximately 0.92 m long, 0.30 m tall, and 0.18 m wide; comfortably two-handed. Maintain these defining forms: A thick single barrel above a parallel magazine tube, an oversized ribbed pump, a compact receiver, and a short padded shoulder stock. The broad circular muzzle and low pump immediately communicate shotgun rather than rifle. Preserve construction: The upper barrel is a reclaimed length of galvanized coolant-pipe casing with a dark muzzle collar. The receiver is maintenance-crew orange and bears a small embossed pipe-cleaning pictogram (a brush inside a pipe, no lettering) and a blank asset-tag plate near the guard. A coolant-green sliding pump wraps around the lower tube. The rear grip joins a thick charcoal shoulder pad. A large side opening provides a readable stylized shell-ejection point. Base shells are squat red capsules with brass-colored rims. Preserve the palette: Maintenance orange #E0702A; galvanized pipe gray #AEB9BF; coolant green #3E9E7E; dark steel #444F58; shell red #C8503C; brass rims #C9A24D. Upgrade accents: ember orange #FF9436 for heat glows, pale ceramic gray #D6DCDF for the heat collar, heat-scorched bronze #8C4F2E for the insulated receiver panel, and thin microchip-gold #FFD166 contact edges on modules. Wear is concentrated on the muzzle collar, pump edges and stock pad. Lock these details: One barrel and one lower magazine tube at every stage, not a double-barreled gun. Preserve the sliding pump and short stock. No real-world branding, logos or legible text, and no practical fabrication diagrams. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use stage 0 without upgrades, no hands, no action effects. Do not mirror asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```
## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Boom Broom reference, draw one clear full-subject 2D animation key pose in strict gameplay side view, showing one state chosen from this list: Base clean prop; shoulder hold; single blast recoil; pump backward and forward; shell ejection; individual reload; two-shell blast; four cumulative appearance stages. If no state is specified, show the main attack anticipation; for a weapon show a simplified hand-contact study of its standard firing pose. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: Recoil lifts the muzzle with a solid shoulder kick. The support hand pulls the pump visibly backward and forward. A single oversized shell ejects and bounces. Reloading feeds individual capsules into a clearly visible underside port; the action can stop to fire. Capability: Wide scrap-pellet blast, strong close-range damage, knockback against small enemies, and stagger against larger ones. Base capacity is four shells. Damage falls off at range and pumping leaves a deliberate recovery gap. Important limitation or opening: Long-distance accuracy and firing speed remain limited. The Twin Shell upgrade uses two shells and lengthens recovery; it does not turn the weapon into continuous automatic fire. Handling: Rear hand at the trigger grip, support hand on the coolant-green pump, shoulder behind the pad. Keep pump travel clear of both guard and muzzle attachments. Keep effects small and separate enough that the body or weapon silhouette is visible. Use a flat mid-grey (#808080) background, evenly lit and flat-colored with no baked shadows, no rim light and no blood; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```
## Image prompts — upgrade stages

Attach the approved base and, when available, the previous approved stage. Generate each stage separately. Keep pose, canvas scale, palette and line weight unchanged for comparison. Earlier attachments stay fitted.

### Stage 1 prompt: Extended Tube

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 1 of the approved DEAD EDEN Boom Broom weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A thick single barrel above a parallel magazine tube, an oversized ribbed pump, a compact receiver, and a short padded shoulder stock. The broad circular muzzle and low pump immediately communicate shotgun rather than rifle. The upper barrel is a reclaimed length of galvanized coolant-pipe casing with a dark muzzle collar. The receiver is maintenance-crew orange and bears a small embossed pipe-cleaning pictogram (a brush inside a pipe, no lettering) and a blank asset-tag plate near the guard. A coolant-green sliding pump wraps around the lower tube. The rear grip joins a thick charcoal shoulder pad. A large side opening provides a readable stylized shell-ejection point. Base shells are squat red capsules with brass-colored rims. Show all cumulative attachments through this stage: 1. Extended Tube: The lower magazine tube gains a visibly longer pale pipe segment and a rounded orange end cap beneath the barrel. The barrel length stays unchanged. Six small embossed capacity marks replace the base four on the receiver. A small square microchip module with thin gold contact edges is seated in a slot on the end cap. Mount: Front of the lower magazine tube, beyond the pump's travel. Do not include any later-stage attachment. Preserve rules: One barrel and one lower magazine tube at every stage, not a double-barreled gun. Preserve the sliding pump and short stock. No real-world branding, logos or legible text, and no practical fabrication diagrams. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 2 prompt: Incendiary Shells

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 2 of the approved DEAD EDEN Boom Broom weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A thick single barrel above a parallel magazine tube, an oversized ribbed pump, a compact receiver, and a short padded shoulder stock. The broad circular muzzle and low pump immediately communicate shotgun rather than rifle. The upper barrel is a reclaimed length of galvanized coolant-pipe casing with a dark muzzle collar. The receiver is maintenance-crew orange and bears a small embossed pipe-cleaning pictogram (a brush inside a pipe, no lettering) and a blank asset-tag plate near the guard. A coolant-green sliding pump wraps around the lower tube. The rear grip joins a thick charcoal shoulder pad. A large side opening provides a readable stylized shell-ejection point. Base shells are squat red capsules with brass-colored rims. Show all cumulative attachments through this stage: 1. Extended Tube: The lower magazine tube gains a visibly longer pale pipe segment and a rounded orange end cap beneath the barrel. The barrel length stays unchanged. Six small embossed capacity marks replace the base four on the receiver. A small square microchip module with thin gold contact edges is seated in a slot on the end cap. Mount: Front of the lower magazine tube, beyond the pump's travel. 2. Incendiary Shells: A thick ceramic heat collar with three protected ember-orange vent windows fits behind the muzzle. Shell capsules gain an ember-orange band, and an insulated receiver panel darkens to heat-scorched bronze. A small square microchip module with thin gold contact edges is seated in a slot on the collar's left flank. Extended Tube remains fitted. Mount: Outer barrel near the muzzle, clear of the magazine cap. Do not include any later-stage attachment. Preserve rules: One barrel and one lower magazine tube at every stage, not a double-barreled gun. Preserve the sliding pump and short stock. No real-world branding, logos or legible text, and no practical fabrication diagrams. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
### Stage 3 prompt: Twin Shell

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create stage 3 of the approved DEAD EDEN Boom Broom weapon, using the attached approved base and previous stage as references. Keep the original silhouette, core body, grips, materials, and part orientation. Base identity: A thick single barrel above a parallel magazine tube, an oversized ribbed pump, a compact receiver, and a short padded shoulder stock. The broad circular muzzle and low pump immediately communicate shotgun rather than rifle. The upper barrel is a reclaimed length of galvanized coolant-pipe casing with a dark muzzle collar. The receiver is maintenance-crew orange and bears a small embossed pipe-cleaning pictogram (a brush inside a pipe, no lettering) and a blank asset-tag plate near the guard. A coolant-green sliding pump wraps around the lower tube. The rear grip joins a thick charcoal shoulder pad. A large side opening provides a readable stylized shell-ejection point. Base shells are squat red capsules with brass-colored rims. Show all cumulative attachments through this stage: 1. Extended Tube: The lower magazine tube gains a visibly longer pale pipe segment and a rounded orange end cap beneath the barrel. The barrel length stays unchanged. Six small embossed capacity marks replace the base four on the receiver. A small square microchip module with thin gold contact edges is seated in a slot on the end cap. Mount: Front of the lower magazine tube, beyond the pump's travel. 2. Incendiary Shells: A thick ceramic heat collar with three protected ember-orange vent windows fits behind the muzzle. Shell capsules gain an ember-orange band, and an insulated receiver panel darkens to heat-scorched bronze. A small square microchip module with thin gold contact edges is seated in a slot on the collar's left flank. Extended Tube remains fitted. Mount: Outer barrel near the muzzle, clear of the magazine cap. 3. Twin Shell: A paired pressure-indicator pod mounts atop the receiver, using two round ember-orange windows and a broad selector paddle on its left. Both windows flash together for the alternate blast. A small square microchip module with thin gold contact edges is seated in a slot at the pod's rear. All earlier attachments remain. Mount: Top receiver mount, keeping the muzzle silhouette and shoulder line clear. Do not include any later-stage attachment. Preserve rules: One barrel and one lower magazine tube at every stage, not a double-barreled gun. Preserve the sliding pump and short stock. No real-world branding, logos or legible text, and no practical fabrication diagrams. Use a clean 2D side drawing on a flat mid-grey (#808080) background, evenly lit with no baked shadows, with the same pose, canvas scale, line weight and palette as the base reference. No hands, firing effects, scenery, labels, text, logos, or exploded internals. Make upgrade additions readable, attached, and clear of hand contacts and moving parts.
```
## Before sprite production

- Use the approved neutral image, or approve one for this unpictured asset, before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art.
- Check silhouette and target readability at intended gameplay size, in grayscale, as a solid silhouette and against a dark background.
- Establish a consistent canvas, foot baseline, weapon grip and pivot intent; draw a few key poses before adding small details.
- Keep effects, glow shapes and moving pieces separate. A concept PNG is not a finished sprite sheet, layered source file or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

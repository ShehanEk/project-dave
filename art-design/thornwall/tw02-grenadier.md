# Grenadier

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** TW02\
**Category:** thornwall (Thornwall, humans)\
**First appearance:** Level 5 (appears in L5–L9)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed, and so is the enemy gun kit (C27). This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Arc-lob gunner. He lobs frags at Dave and behind him.

*Proposed identity:* a Thornwall grenadier armed with the GL-6 frag launcher ([EG04](../enemy-guns/eg04-frag-launcher.md)). Thornwall came to sanitize, not to arrest, so frags are standard issue. He wears a gas mask against the smoke of his own weapons and the vapors of the sealed lower levels. He is human, not Linked, and he fights from a distance, one arc at a time.

He appears in Levels 5–9. His second frag lands behind Dave, so the safe move is always forward, toward him. Combat is lethal (C28): he bleeds like anyone else (C29), even behind the mask.

## Scale and silhouette

About 1.80 m tall (the shared Thornwall body), roughly 7.25 heads, with a stocky build.

A stocky figure with a close hood and a gas mask that pushes a snout and a round cheek canister out in front of the face, and a diagonal bandolier of fat grenades across the chest. In grayscale he reads by the round hooded head with the snout and canister bulge, and by the bandolier diagonal. He has no helmet brim, no back drum and no long coat.

In play he leans back with the launcher raised at about 60 degrees to lob.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* Thornwall's own look, shared by every contractor: plain dark tactical gear in muted warm greys and black, with none of Arcadia's cheer. A warm charcoal combat shirt and trousers, a near-black plate carrier with muted coyote-tan webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing on the kit is bright, so the guns and the tells carry all the color. There is no Arcadia grey, no white emblem, no teal, no name tapes and no police marks.

The gas mask overlay is a full-face dark mask with two round smoke lenses, a single large filter canister on the near cheek and a short corrugated hose to a small pouch at the collar, worn under a close dark hood and a padded skull cap, so no hair or skin shows. A bandolier crosses the chest diagonally from the near shoulder to the far hip, carrying six fat dark grenades with dark grey bands, and more grenade pouches sit at the hip. The weapon hand is bare inside a dark glove and empty: the GL-6 launcher is a separate sprite. He has no implant.

## Color and materials

*Proposed palette:* warm charcoal shirt and trousers #4A4B48; near-black plate carrier #25272A; muted coyote-tan webbing and pouches #8C7A5B; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; hood and skull cap #2A2C2F; mask #23262A with smoke lenses #3E444C and canister #6A6C70; hose #1E2023; grenades #2B2E32 with dark grey bands #4A4F55; skin (only at the wrists) #8E6A50.

**Tokens.** The tell is Hazard amber #FFB02E, then Alarm red #FF3B4E for the last 0.25 s, as a glow on the launcher's muzzle ring, which belongs to the gun asset (EG04). A thrown frag blinks amber, then red, before it bursts; that blink belongs to the projectile (EG04), not to the body. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, never painted in, and it never glows or uses a tell color. He shows no amber point and no teal light, because he is not Linked.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (the lean back with the launcher raised) and by the shouted "Frag out!" subtitle.

## Abilities and movement

- **Template:** Gunner (arc) (C26).
- **Weapon:** Frag Launcher, Thornwall GL-6 ([EG04](../enemy-guns/eg04-frag-launcher.md)).
- **Tell:** GLOW on the muzzle ring, plus the "Frag out!" subtitle and a shout.
- **Attack:** he braces as the muzzle ring goes amber, then red, and lobs 2 frags 0.6 s apart on fixed 0.9 s arcs: the first at Dave's grounded spot, the second 1.5 H behind him (away from the Grenadier). Each lands, blinks amber for 0.3 s and red for 0.25 s, then bursts in a 1.0 H radius for 0.15 s (1 damage, blocked by walls and floors). Minimum range 2 H, at most 2 frags alive, then a 1.8 s reload.
- **Counter:** move forward, toward him, off the landing spots (the escape is always forward), then rush him during the reload (3 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Stands with his feet planted and his weight back. For the windup he leans back and tips the launcher up to about 60 degrees while the muzzle ring warms; each lob is a small heave of the shoulders, the second one a beat behind the first. Between lobs he keeps the launcher raised and his head still behind the mask.

The reload is the opening: he breaks the launcher open, feeds grenades from the bandolier with the far hand, and stands rooted with his head down.

**Sample barks** *(proposed; muffled by the mask, with profanity where it fits. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Frag out!" (the windup)
- "Fire in the hole, motherfucker!" (the second lob)
- "Reloading! Keep him off me!" (the reload)
- "Move, move, it's coming down—" (to his team)
- "Ah, fuck! Ah—" (hit)

Death is a muffled grunt, and the launcher clatters to the floor.

## Openings and limitations

The reload is the opening: launcher broken open, the far hand at the bandolier, head down. Keep the snout, canister and bandolier as clean shapes so the silhouette holds. Do not add a helmet, a drum, a coat or a second gun.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head with the hood and skull cap; gas mask (its own part) with the canister and a small hose piece; torso with the plate carrier; bandolier (its own swinging part, with its six grenades); pelvis with the belt and grenade pouches; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand; the far hand is the support hand and the reload hand); near and far upper legs, lower legs and feet, with knee pads. The GL-6 is a separate sprite (EG04).

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the mask at the face; the bandolier at the near shoulder; the hose at the collar. The whole arm and the launcher tip up from the shoulder. Paint hidden overlap under every joint, and paint the far limbs complete.

**Sockets:** the gun socket at the near palm holds the launcher's rear grip; a support socket at the far palm meets its forward grip, and the far hand also reaches the bandolier for the reload. The muzzle marker, the muzzle-ring glow and the muzzle-flash light belong to the gun sprite (EG04), and thrown frags start from the muzzle marker.

**Normal maps:** one per part (green = up), soft-edged: the mask's lens rims, canister ribs and corrugated hose, hood folds, the bandolier straps and grenade casings, plate-carrier edges and cloth folds at the joints.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. Blood anchors sit on the head (at the hood's side), chest, belly, near upper arm and near thigh. No implant sparks.

**Motion and death:** Mixamo clips converted to the rig: a heavy-weapon idle, a slow walk, a lean-back lob and a hit flinch. Hand-key the launcher tilt and the reload where no clip fits. Death is a ragdoll pushed by the killing shot, and the launcher drops as a prop, never a pickup. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle (launcher low); walk; windup (lean back, launcher raised to about 60 degrees); attack (the two lobs); reload (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, launcher rear grip, support hand on the forward grip, bandolier reach).

Tell by pose: the lean back with the launcher raised is the windup, and the amber-then-red glow on the muzzle ring belongs to the gun and is added by the engine. Paint the hands in their grip shapes around empty space. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one mask, one bandolier of six grenades. The launcher is never painted into the art. No helmet brim, drum, coat or second gun. No implant, no teal, no violet, no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The canister sits on the near cheek and the sleeve patch and hip pouches on the near side; all are safe to mirror. The bandolier is its own part, so the rig can swap which shoulder it hangs from if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Grenadier, a Thornwall human enemy: a grenadier in a hood and a gas mask with a diagonal bandolier of grenades. Role: Arc-lob gunner. He lobs frags at Dave and behind him.
Scale: About 1.80 m tall (the shared Thornwall body), roughly 7.25 heads, with a stocky build.
Silhouette: A stocky figure with a close hood and a gas mask that pushes a snout and a round cheek canister out in front of the face, and a diagonal bandolier of fat grenades across the chest. In grayscale he reads by the round hooded head with the snout and canister bulge, and by the bandolier diagonal. He has no helmet brim, no back drum and no long coat.
Physical design: Thornwall's own look, shared by every contractor: plain dark tactical gear in muted warm greys and black, with none of Arcadia's cheer. A warm charcoal combat shirt and trousers, a near-black plate carrier with muted coyote-tan webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing on the kit is bright, so the guns and the tells carry all the color. There is no Arcadia grey, no white emblem, no teal, no name tapes and no police marks. The gas mask overlay is a full-face dark mask with two round smoke lenses, a single large filter canister on the near cheek and a short corrugated hose to a small pouch at the collar, worn under a close dark hood and a padded skull cap, so no hair or skin shows. A bandolier crosses the chest diagonally from the near shoulder to the far hip, carrying six fat dark grenades with dark grey bands, and more grenade pouches sit at the hip. The weapon hand is bare inside a dark glove and empty: the GL-6 launcher is a separate sprite. He has no implant.
Materials and colors: warm charcoal shirt and trousers #4A4B48; near-black plate carrier #25272A; muted coyote-tan webbing and pouches #8C7A5B; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; hood and skull cap #2A2C2F; mask #23262A with smoke lenses #3E444C and canister #6A6C70; hose #1E2023; grenades #2B2E32 with dark grey bands #4A4F55; skin (only at the wrists) #8E6A50. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the launcher's muzzle ring. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one mask, one bandolier of six grenades. The launcher is never painted into the art. No helmet brim, drum, coat or second gun. No implant, no teal, no violet, no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright and stocky with the hands empty and slightly curled, the mask on and the hood up; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Grenadier design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.80 m tall (the shared Thornwall body), roughly 7.25 heads, with a stocky build. Maintain these defining forms: A stocky figure with a close hood and a gas mask that pushes a snout and a round cheek canister out in front of the face, and a diagonal bandolier of fat grenades across the chest. In grayscale he reads by the round hooded head with the snout and canister bulge, and by the bandolier diagonal. He has no helmet brim, no back drum and no long coat. Preserve construction: Thornwall's own look, shared by every contractor: plain dark tactical gear in muted warm greys and black, with none of Arcadia's cheer. A warm charcoal combat shirt and trousers, a near-black plate carrier with muted coyote-tan webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing on the kit is bright, so the guns and the tells carry all the color. There is no Arcadia grey, no white emblem, no teal, no name tapes and no police marks. The gas mask overlay is a full-face dark mask with two round smoke lenses, a single large filter canister on the near cheek and a short corrugated hose to a small pouch at the collar, worn under a close dark hood and a padded skull cap, so no hair or skin shows. A bandolier crosses the chest diagonally from the near shoulder to the far hip, carrying six fat dark grenades with dark grey bands, and more grenade pouches sit at the hip. The weapon hand is bare inside a dark glove and empty: the GL-6 launcher is a separate sprite. He has no implant. Preserve the palette: warm charcoal shirt and trousers #4A4B48; near-black plate carrier #25272A; muted coyote-tan webbing and pouches #8C7A5B; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; hood and skull cap #2A2C2F; mask #23262A with smoke lenses #3E444C and canister #6A6C70; hose #1E2023; grenades #2B2E32 with dark grey bands #4A4F55; skin (only at the wrists) #8E6A50. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the launcher's muzzle ring. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one mask, one bandolier of six grenades. The launcher is never painted into the art. No helmet brim, drum, coat or second gun. No implant, no teal, no violet, no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Grenadier reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle (launcher low); walk; windup (lean back, launcher raised to about 60 degrees); attack (the two lobs); reload (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, launcher rear grip, support hand on the forward grip, bandolier reach). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their launcher-grip shapes around empty space; the launcher is a separate sprite and is never painted in. Movement language: Stands with his feet planted and his weight back. For the windup he leans back and tips the launcher up to about 60 degrees while the muzzle ring warms; each lob is a small heave of the shoulders, the second one a beat behind the first. Between lobs he keeps the launcher raised and his head still behind the mask. The reload is the opening: he breaks the launcher open, feeds grenades from the bandolier with the far hand, and stands rooted with his head down. Capability: Lobs two frags on fixed arcs, one at Dave's grounded spot and one behind him, then reloads, rooted. Important limitation or opening: The reload is the opening: launcher broken open, the far hand at the bandolier, head down. Keep the snout, canister and bandolier as clean shapes so the silhouette holds. Do not add a helmet, a drum, a coat or a second gun. Tell: GLOW on the launcher's muzzle ring (part of the gun, added by the engine), amber first and then red for the last 0.25 s, plus the "Frag out!" subtitle and a shout. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Build on the approved Rifleman (SE04), the shared Thornwall body. The hood, the gas mask and the bandolier are overlays painted over it.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The canister, the sleeve patch and the hip pouches must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Rifleman (helmet and carbine), the Heavy Gunner (helmet and back drum) and the Marksman (long coat). The Grenadier reads by the round hooded head with the snout and canister, and by the bandolier diagonal. The tell must read by pose and glow with the night overlay on.
- Convert the Mixamo clips (heavy-weapon idle, slow walk, lean-back lob, hit flinch) to the rig and hand-key the tell pose where no clip fits. Check that the launcher tips up to about 60 degrees without a gap at the shoulder, and that the bandolier swings as its own part.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

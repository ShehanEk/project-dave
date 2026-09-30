# Marksman

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** TW03\
**Category:** thornwall (Thornwall, humans)\
**First appearance:** Level 6 (appears in L6–L9)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed, and so is the enemy gun kit (C27). This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Long-range rail-rifle enemy on a far perch. An advance fight against a single instant shot.

*Proposed identity:* a Thornwall marksman, a quiet professional who fires the RX-2 "Needle" rail rifle ([EG05](../enemy-guns/eg05-rail-rifle.md)), an Arcadia prototype that Thornwall field-tests on Dave. He is human, not Linked, and he waits on a far perch (a gantry end, a catwalk, a rooftop lip) with the rifle laid out in front of him. Nothing about him hurries.

He appears in Levels 6–9, at most one to a screen. His single shot is the hardest hit in the human roster, so the fight is an advance: cover is never more than 8 H apart on the approach, and his perch is always reachable. He is fragile once Dave reaches him (2 hits). Combat is lethal (C28): he bleeds like anyone else (C29).

## Scale and silhouette

About 1.84 m tall standing, roughly 7.25 heads, with a lean build. In play he holds a one-knee kneel.

A tall, lean figure in a long, high-collared coat that hangs to the calves and splits at the back into two tails, with a slim visor band across the eyes and a dark gaiter below it. In grayscale he reads as a long vertical coat shape with a slim head and a horizontal visor band. He has no helmet, no pack and no bandolier.

In play he kneels on one knee behind the rail rifle, a long, thin horizontal line, with the coat tails pooling behind him. Nothing else in the roster wears a long coat.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* Thornwall's own look, shared by every contractor: plain dark tactical gear in muted warm greys and black, with none of Arcadia's cheer. A warm charcoal combat shirt and trousers, a near-black plate carrier with muted coyote-tan webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing on the kit is bright, so the guns and the tells carry all the color. There is no Arcadia grey, no white emblem, no teal, no name tapes and no police marks. The thorn glyph moves to a patch on the near sleeve of the coat.

The coat and visor overlay: a long charcoal coat with a high collar, hanging to the calves and split at the back into two tails, worn open over the kit and the plate carrier; a slim wraparound visor band of pale ice-blue polymer over the eyes, with a dark gaiter below it and cropped hair above. The visor's normal map is strongly curved, so engine lamps catch it and it glints, which is how the player finds the perch in the dark. An optional small, still, pale-ice glint sprite can sit on the visor, no more than a few pixels at gameplay size and never amber, red, teal or green. The gloves are thin and dark. The weapon hand and the support hand are separate parts, and the rail rifle is a separate sprite. He has no implant.

## Color and materials

*Proposed palette:* warm charcoal shirt and trousers #4A4B48; near-black plate carrier #25272A; muted coyote-tan webbing and pouches #8C7A5B; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; coat #2F343B with worn hem #444B54; visor band #B8CCDB; dark gaiter #303236; thin gloves #1E2023; skin (jaw and neck) #D2AC92.

**Tokens.** The tell is a LINE: a thin sight line that tracks Dave, freezes, holds Hazard amber #FFB02E for 0.3 s and turns Alarm red #FF3B4E for the last 0.25 s. The line and the three capacitor rings that light 1-2-3 belong to the rifle (EG05) and the engine. The body carries no glow, and the visor glint is a small still pale-ice point. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, never painted in, and it never glows or uses a tell color. He shows no amber point and no teal light, because he is not Linked.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (the rifle laid across the raised knee, the head still) and by the three-step whine.

## Abilities and movement

- **Template:** Gunner (stationary, far perch) (C26).
- **Weapon:** Rail Rifle, RX-2 "Needle" ([EG05](../enemy-guns/eg05-rail-rifle.md)), a futuristic gun.
- **Tell:** LINE: a sight line tracks Dave's grounded point at 3 H/s while the three capacitor rings light 1-2-3; then it freezes, holds amber for 0.3 s and turns red for the last 0.25 s.
- **Attack:** one instant slug to the first wall or to Dave: 2 damage, full-screen range. Then a 2.2 s recharge, rooted. At most 1 Marksman per screen.
- **Counter:** keep moving (a moving Dave is usually off the line by the freeze), or jump a flat line; advance one cover piece per recharge (cover is at most 8 H apart) and shoot him from his reachable perch (2 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Kneels on one knee with the rifle laid across the raised knee and the stock at the shoulder, still except for the head, which turns slowly to follow Dave, and the coat tails, which stir in the air. During the windup he holds the rifle still while the sight line sweeps and the rings light; after the shot he lowers the muzzle and looks over the rifle.

The recharge is the opening: rooted, the rifle lowered, his head bowed to check the rings. If Dave reaches the perch he is a tall, fragile target.

**Sample barks** *(proposed; cold and quiet, with profanity where it fits. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Eyes on. Tracking." (the windup)
- "Hold still, Doctor." (the freeze)
- "Missed. Fuck. Recharging." (the recharge)
- "Contact at the perch. Repositioning." (Dave closes in)

Death is a short exhale and the rifle clattering on the perch, with no last words.

## Openings and limitations

The recharge is the opening: rooted, the rifle lowered, the head bowed. He is fragile, so keep the coat and visor as clean shapes and let the perch, not armor, protect him. Do not add a helmet, a drum, a bandolier or a second gun; the rifle stays a separate sprite.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head with the visor band (its own small part); torso with the plate carrier and the coat's collar and shoulders; pelvis with the belt; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand; the far hand is the support hand); near and far upper legs, lower legs and feet. The coat skirt is two separate parts (the near and far panels, split at the back) pivoted at the waist, so the coat can swing and ragdoll. The rail rifle is a separate sprite (EG05). The optional visor glint is a small separate sprite.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the coat panels at the waist; the visor at the brow. Paint hidden overlap under every joint, and paint the body under the coat and the far limbs complete.

**Sockets:** the gun socket at the near palm holds the rifle's rear grip; a support socket at the far palm meets its forward grip. The muzzle marker, where the sight line and the slug start, and the capacitor-ring lights belong to the gun sprite (EG05). A glint socket at the visor holds the optional glint sprite.

**Normal maps:** one per part (green = up), soft-edged: the coat's folds, hem and collar, plate-carrier edges and webbing, and gentle face modeling at the jaw. The visor is the one part whose normal map is more strongly curved than the rest, so lamps glint on it.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. Blood anchors sit on the head (at the jaw), chest, belly, near upper arm and near thigh. No implant sparks.

**Motion and death:** Mixamo clips converted to the rig: a kneeling rifle aim held still, a slow rifle walk for placement and a hit flinch. Hand-key the head tracking and the recharge look-down where no clip fits. Death is a ragdoll pushed by the killing shot, the coat tails flying, and the rifle drops as a prop, never a pickup. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle kneel (head tracking); walk (placement only); windup (rifle laid across the knee, head still); attack (the shot and the recoil); recharge (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, rifle rear grip, support hand on the forward grip).

Tell by pose: the rifle laid across the raised knee with the head still is the windup, and the sight line, the amber-then-red hold and the ring lights belong to the rifle and are added by the engine. Paint the hands in their grip shapes around empty space. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one long coat with two tails, one visor band. The rifle is never painted into the art. No helmet, drum, bandolier or second gun. No implant, no teal, no violet, no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. No baked highlight on the visor: the glint comes from the normal map and the engine's lamps. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The coat sleeve patch and the weapon hand sit on the near side and are safe to mirror. The coat tails and the visor are separate parts, so the rig can swap them if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Marksman, a Thornwall human enemy: a marksman in a long coat with a slim visor band and a dark gaiter. Role: Long-range rail-rifle enemy on a far perch. An advance fight against a single instant shot.
Scale: About 1.84 m tall standing, roughly 7.25 heads, with a lean build. In play he holds a one-knee kneel.
Silhouette: A tall, lean figure in a long, high-collared coat that hangs to the calves and splits at the back into two tails, with a slim visor band across the eyes and a dark gaiter below it. In grayscale he reads as a long vertical coat shape with a slim head and a horizontal visor band. He has no helmet, no pack and no bandolier.
Physical design: Thornwall's own look, shared by every contractor: plain dark tactical gear in muted warm greys and black, with none of Arcadia's cheer. A warm charcoal combat shirt and trousers, a near-black plate carrier with muted coyote-tan webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing on the kit is bright, so the guns and the tells carry all the color. There is no Arcadia grey, no white emblem, no teal, no name tapes and no police marks. The thorn glyph moves to a patch on the near sleeve of the coat. The coat and visor overlay: a long charcoal coat with a high collar, hanging to the calves and split at the back into two tails, worn open over the kit and the plate carrier; a slim wraparound visor band of pale ice-blue polymer over the eyes, with a dark gaiter below it and cropped hair above. The visor's normal map is strongly curved, so engine lamps catch it and it glints, which is how the player finds the perch in the dark. An optional small, still, pale-ice glint sprite can sit on the visor, no more than a few pixels at gameplay size and never amber, red, teal or green. The gloves are thin and dark. The weapon hand and the support hand are separate parts, and the rail rifle is a separate sprite. He has no implant.
Materials and colors: warm charcoal shirt and trousers #4A4B48; near-black plate carrier #25272A; muted coyote-tan webbing and pouches #8C7A5B; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; coat #2F343B with worn hem #444B54; visor band #B8CCDB; dark gaiter #303236; thin gloves #1E2023; skin (jaw and neck) #D2AC92. Tell colors, added by the engine and never painted: a sight line that holds Hazard amber #FFB02E then turns Alarm red #FF3B4E, from the rifle. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one long coat with two tails, one visor band. The rifle is never painted into the art. No helmet, drum, bandolier or second gun. No implant, no teal, no violet, no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. No baked highlight on the visor: the glint comes from the normal map and the engine's lamps. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright and lean with the hands empty and slightly curled and the coat hanging open, the visor on; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Marksman design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.84 m tall standing, roughly 7.25 heads, with a lean build. In play he holds a one-knee kneel. Maintain these defining forms: A tall, lean figure in a long, high-collared coat that hangs to the calves and splits at the back into two tails, with a slim visor band across the eyes and a dark gaiter below it. In grayscale he reads as a long vertical coat shape with a slim head and a horizontal visor band. He has no helmet, no pack and no bandolier. Preserve construction: Thornwall's own look, shared by every contractor: plain dark tactical gear in muted warm greys and black, with none of Arcadia's cheer. A warm charcoal combat shirt and trousers, a near-black plate carrier with muted coyote-tan webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing on the kit is bright, so the guns and the tells carry all the color. There is no Arcadia grey, no white emblem, no teal, no name tapes and no police marks. The thorn glyph moves to a patch on the near sleeve of the coat. The coat and visor overlay: a long charcoal coat with a high collar, hanging to the calves and split at the back into two tails, worn open over the kit and the plate carrier; a slim wraparound visor band of pale ice-blue polymer over the eyes, with a dark gaiter below it and cropped hair above. The visor's normal map is strongly curved, so engine lamps catch it and it glints, which is how the player finds the perch in the dark. An optional small, still, pale-ice glint sprite can sit on the visor, no more than a few pixels at gameplay size and never amber, red, teal or green. The gloves are thin and dark. The weapon hand and the support hand are separate parts, and the rail rifle is a separate sprite. He has no implant. Preserve the palette: warm charcoal shirt and trousers #4A4B48; near-black plate carrier #25272A; muted coyote-tan webbing and pouches #8C7A5B; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; coat #2F343B with worn hem #444B54; visor band #B8CCDB; dark gaiter #303236; thin gloves #1E2023; skin (jaw and neck) #D2AC92. Tell colors, added by the engine and never painted: a sight line that holds Hazard amber #FFB02E then turns Alarm red #FF3B4E, from the rifle. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one long coat with two tails, one visor band. The rifle is never painted into the art. No helmet, drum, bandolier or second gun. No implant, no teal, no violet, no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. No baked highlight on the visor: the glint comes from the normal map and the engine's lamps. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Marksman reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle kneel (head tracking); walk (placement only); windup (rifle laid across the knee, head still); attack (the shot and the recoil); recharge (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, rifle rear grip, support hand on the forward grip). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their rifle-grip shapes around empty space; the rail rifle is a separate sprite and is never painted in. Movement language: Kneels on one knee with the rifle laid across the raised knee and the stock at the shoulder, still except for the head, which turns slowly to follow Dave, and the coat tails, which stir in the air. During the windup he holds the rifle still while the sight line sweeps and the rings light; after the shot he lowers the muzzle and looks over the rifle. The recharge is the opening: rooted, the rifle lowered, his head bowed to check the rings. If Dave reaches the perch he is a tall, fragile target. Capability: Fires one instant rail slug after a tracking sight line freezes, then recharges, rooted. Important limitation or opening: The recharge is the opening: rooted, the rifle lowered, the head bowed. He is fragile, so keep the coat and visor as clean shapes and let the perch, not armor, protect him. Do not add a helmet, a drum, a bandolier or a second gun; the rifle stays a separate sprite. Tell: LINE from the rail rifle (part of the gun, added by the engine): a sight line that freezes, holds amber for 0.3 s and turns red for the last 0.25 s; show only the still, braced kneeling pose. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Build on the approved Rifleman (SE04), the shared Thornwall body. The long coat and the visor band are overlays painted over it.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The coat sleeve patch and the weapon hand must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Rifleman (helmet), the Heavy Gunner (drum) and the Grenadier (hooded mask and bandolier). The Marksman reads by the long coat and the slim visor band. The tell must read by pose and glow with the night overlay on.
- Convert the Mixamo clips (kneeling aim, slow walk, hit flinch) to the rig and hand-key the tell pose where no clip fits. Check that the visor glints under a moving lamp at gameplay size, and that the coat tails do not hide the knee or the rifle sockets.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

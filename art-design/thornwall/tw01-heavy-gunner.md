# Heavy Gunner

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** TW01\
**Category:** thornwall (Thornwall, humans)\
**First appearance:** Level 5 (appears in L5–L9)\
**Design status:** Look follows C60 (approved 2026-10-12): painted HD parts on the lit cutout rig (C56), corporate cyberpunk (C58), alert and composed (C57), Thornwall violet trim (C60). Concept images are still to be generated. The lit cutout method is confirmed (C35). The roster entry (C31), human enemies (C25) and the enemy gun kit (C27) are confirmed. Behavior numbers (P23) are *proposed*. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Stationary machine-gunner and the roster's cover-only fight. A contractor who walks slowly, then plants a rotary gun.

*Proposed identity:* a Thornwall heavy-weapons contractor. Thornwall is the private military contractor that Arcadia keeps on retainer to guard the defense servers in the Rootworks, and once the board changes its orders from "guard" to "sanitize" it arrives the same night with heavy weapons. The Heavy Gunner carries the HG-40 "Thresher" rotary ([EG03](../enemy-guns/eg03-machine-gun.md)), which Arcadia's defense division sells as "perimeter denial", fed from a drum on his back. He is human, not Linked, and cold: this is a job, and the people in his lane are the invoice.

**Three looks on one rig** (C56, C60), all Caucasian (C43): **A, the anonymous heavy** (the visor stays down, nothing of the face shows); **B, the veteran** (visor up, grey stubble, a calm, hard face); **C, the woman gunner** (visor up, dark hair in a tight braid, a focused face). The game picks a look by entity id; stats, tells and timing are the same.

He appears in Levels 5–9. Dave cannot out-jump a rotary stream, so every Heavy Gunner position has a low crate or another floor within 3 H: the fight is about reaching cover and punishing the overheat. Combat is lethal (C28): he bleeds like anyone else (C29), though he takes more hits than any other human.

## Scale and silhouette

About 1.98 m tall: the shared Thornwall body drawn at 1.1x scale (still about 7.25 heads), bulked out with armor. He is visibly the largest human in the roster.

A tall, thick-set figure with a full-face helmet, oversized shoulder guards and thigh plates, and a big round ammunition drum riding on the back above the shoulders, standing on a wide, planted base. In grayscale he reads as the biggest human, with a helmet dome and a disc-shaped drum behind the shoulders.

In play the rotary hangs at his hip and the belt runs back over his shoulder to the drum. Nothing else in the roster has a round pack on the back: the Grenadier's bandolier crosses the chest, the Marksman's coat hangs straight, and the Riot Officer's bulk is a shield in front.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design (C60).* Thornwall's own look, shared by every contractor: professional, unhurried and never sloppy, in matte charcoal tactical gear with none of Arcadia's cheer. A charcoal combat shirt and trousers, a matte charcoal plate carrier with dark slate webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. Thin violet neon piping (#9B5CFF, Thornwall's color) runs along the carrier's shoulder straps, painted as a flat bright color with no glow. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing else on the kit is bright, so the guns and the tells carry the color. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks.

The heavy overlays, at 1.1x scale: a full-face matte charcoal helmet with a dark smoked visor that carries a slim violet strip, and a breather grille; oversized shoulder guards, thigh plates and knee armor over the kit, clean and well kept. A hip harness, a strap and cradle at the belt, takes the rotary's weight. The drum pack is a round ammunition drum about 0.36 m across (about 0.40 m at his 1.1x scale), carried on the back in a near-black harness, graphite with a pale ivory stripe and a small bone thorn glyph on its side, with a belt port at its front where the long feed belt starts. The weapon hand is bare inside a heavy dark glove and empty: the rotary is a separate sprite that carries only a short belt stub and its own heat collar. In look A the face is fully covered by the visor; in looks B and C the visor is up and an alert, steady face shows. He has no implant.

## Color and materials

*Proposed palette:* charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; charcoal helmet, shoulder guards and plates #34373B; smoked visor #20262C with violet strip and carrier piping #9B5CFF; drum #3A3D40 with pale ivory stripe #D8D2BC; feed belt #1E2023 with dark steel links #2A3341; hip harness #25272A; skin (the wrists, and the face in looks B and C) #C8A084.

**Tokens.** The tell is Hazard amber #FFB02E, then Alarm red #FF3B4E for the last 0.25 s, as a CHARGE glow that grows on the rotary's heat collar while the barrels spin up. The collar belongs to the gun asset (EG03), so the body carries no glow. Rapid fire holds one glow and never strobes. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, never painted in, and it never glows or uses a tell color. He shows no amber point and no teal light, because he is not Linked. **Neon (C60):** violet #9B5CFF marks Thornwall, who control him. It is steady, thinner and dimmer than any tell, never on the gun, its lamp or a weak point, and it goes dark when he dies.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (feet planted wide, the gun hauled to the hip) and by the rising whine.

## Abilities and movement

- **Template:** Gunner (stationary) (C26).
- **Weapon:** Machine Gun, HG-40 "Thresher" rotary ([EG03](../enemy-guns/eg03-machine-gun.md)).
- **Tell:** CHARGE: a 1.0 s spin-up: the barrels spin up with a rising whine and the collar glow grows amber, then red for the last 0.25 s.
- **Attack:** a 1.2 s flat stream (12 rounds, 0.1 s apart) at 0.5 H on his floor, then a 2.0 s overheat, rooted, venting steam.
- **Counter:** cover-only on his floor: get behind the low crate or onto another floor before the stream starts, then punish the overheat (5 hits). A crate or another floor is always within 3 H.

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Walks with a heavy, deliberate tread, the rotary slung low. To attack he plants his feet wide, drops his weight and hauls the rotary to hip height in a deep braced stance, so the stream leaves at about 0.5 H (about 0.85 m above the floor) and never at head height on Dave's floor. The barrels spin up while the collar warms, and the stream is a held stance with the shoulders shaking.

Then he stops, rooted, as the barrels vent steam and the gun hangs low: the overheat is the opening.

**Sample barks** *(proposed; cold and blunt, with profanity where it fits. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Get down! Get down or get dead!" (the spin-up)
- "Sit the fuck down!" (the stream)
- "Suppressing! Suppressing!" (the stream)
- "Barrels are hot! Somebody cover me!" (the overheat)
- "Fuck. He's inside the lane." (Dave closes in)

Death is a heavy grunt, then the rotary hitting the floor.

## Openings and limitations

The overheat is the opening: rooted, the barrels venting steam, the gun hanging low and his head bowed. Keep the drum and the helmet as clean, readable shapes so the silhouette holds. Do not add a shield, a second gun, a coat or a bandolier; those belong to other roster types.

## Rig parts, normal maps and sockets

**Looks (C56):** the three looks share one part list, skeleton, pivots, clips and hit zones; the head differs in every look. **Parts** *(painted once per look, facing right; near means the side toward the camera)*: the shared Thornwall body parts drawn at 1.1x: head; full-face helmet (its own part); torso with the plate carrier and shoulder guards; pelvis with the belt; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand; the far hand is the support hand); near and far upper legs with thigh plates, lower legs and feet, with knee armor. The drum pack is its own part on the back, with the long feed belt as a separate stretchable part from the drum's belt port to the gun's feed stub. A hip harness with its cradle sits at the belt. The rotary is a separate sprite (EG03) that carries only a short belt stub.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the helmet at the crown; the drum at its harness mount; the feed belt at the drum's belt port. Paint hidden overlap under every joint, and paint the far limbs and the part of the drum hidden by the shoulder complete.

**Sockets:** the gun socket at the near palm holds the rotary's rear grip; a support socket at the far palm meets its forward handle; the rotary's rear mount rests in the hip-harness cradle. The feed belt runs from a belt origin at the drum's port to an anchor at the gun's feed stub. The muzzle marker, the collar glow and the muzzle-flash light belong to the gun sprite (EG03), which also carries the looped chatter and the steam vent.

**Normal maps:** one per part (green = up), soft-edged: helmet plates and grille, shoulder guards and thigh plates, webbing, harness and hip-harness straps, the drum's rim and ribs, the belt's links, and cloth folds at the joints.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. Blood anchors sit on the head, chest, belly, near upper arm and near thigh. No implant sparks.

**Motion and death:** hand-keyed on the rig for the side view (C38): a heavy-weapon idle, a slow walk, a braced firing stance held in place and a hit flinch, plus the hauling-up windup and the venting overheat. Death is a ragdoll pushed by the killing shot, and the rotary comes loose (it drops as a prop, never a pickup). The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle (rotary slung low); walk; windup (plant the feet, haul the rotary to the hip); attack (the braced firing stance); overheat (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, rotary rear grip, support hand on the forward handle).

Tell by pose: planting the feet and hauling the rotary to the hip is the windup, and the amber-then-red glow grows on the rotary's collar, which belongs to the gun and is added by the engine. The overheat pose carries no glow. Paint the hands in their grip shapes around empty space. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads) at 1.1x scale, two arms and two legs, one helmet and one drum. The rotary is never painted into the art. No shield, coat, bandolier, gas mask or second gun. No implant, no teal, no neon except the violet trim (#9B5CFF), no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. Alert, awake faces where a face shows: no blank stare or slack mouth. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The drum sits on the back on the centerline, and the sleeve patch and hip pouch on the near side; all are safe to mirror. The drum is its own part, so the rig can swap its belt-port side if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Paint a single evenly lit, hand-painted, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: soft painted shading for form and folds, clean dark outlines (heavier outer contours, restrained interior lines), no baked cast shadows, no cel-shadow shapes, no rim light, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Heavy Gunner, a Thornwall human enemy: a heavy-weapons contractor in a full-face helmet with a back-mounted ammunition drum, drawn at 1.1x scale. Role: Stationary machine-gunner and the roster's cover-only fight. A contractor who walks slowly, then plants a rotary gun.
Scale: About 1.98 m tall: the shared Thornwall body drawn at 1.1x scale (still about 7.25 heads), bulked out with armor. He is visibly the largest human in the roster.
Silhouette: A tall, thick-set figure with a full-face helmet, oversized shoulder guards and thigh plates, and a big round ammunition drum riding on the back above the shoulders, standing on a wide, planted base. In grayscale he reads as the biggest human, with a helmet dome and a disc-shaped drum behind the shoulders.
Physical design: Thornwall's own look, shared by every contractor: professional, unhurried and never sloppy, in matte charcoal tactical gear with none of Arcadia's cheer. A charcoal combat shirt and trousers, a matte charcoal plate carrier with dark slate webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. Thin violet neon piping (#9B5CFF, Thornwall's color) runs along the carrier's shoulder straps, painted as a flat bright color with no glow. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing else on the kit is bright, so the guns and the tells carry the color. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks. The heavy overlays, at 1.1x scale: a full-face matte charcoal helmet with a dark smoked visor that carries a slim violet strip, and a breather grille; oversized shoulder guards, thigh plates and knee armor over the kit, clean and well kept. A hip harness, a strap and cradle at the belt, takes the rotary's weight. The drum pack is a round ammunition drum about 0.36 m across (about 0.40 m at his 1.1x scale), carried on the back in a near-black harness, graphite with a pale ivory stripe and a small bone thorn glyph on its side, with a belt port at its front where the long feed belt starts. The weapon hand is bare inside a heavy dark glove and empty: the rotary is a separate sprite that carries only a short belt stub and its own heat collar. In look A the face is fully covered by the visor; in looks B and C the visor is up and an alert, steady face shows. He has no implant.
Materials and colors: charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; charcoal helmet, shoulder guards and plates #34373B; smoked visor #20262C with violet strip and carrier piping #9B5CFF; drum #3A3D40 with pale ivory stripe #D8D2BC; feed belt #1E2023 with dark steel links #2A3341; hip harness #25272A; skin (the wrists, and the face in looks B and C) #C8A084. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the rotary's heat collar. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads) at 1.1x scale, two arms and two legs, one helmet and one drum. The rotary is never painted into the art. No shield, coat, bandolier, gas mask or second gun. No implant, no teal, no neon except the violet trim (#9B5CFF), no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. Alert, awake faces where a face shows: no blank stare or slack mouth. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright and heavy with the hands empty and slightly curled, the drum on the back; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Heavy Gunner design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.98 m tall: the shared Thornwall body drawn at 1.1x scale (still about 7.25 heads), bulked out with armor. He is visibly the largest human in the roster. Maintain these defining forms: A tall, thick-set figure with a full-face helmet, oversized shoulder guards and thigh plates, and a big round ammunition drum riding on the back above the shoulders, standing on a wide, planted base. In grayscale he reads as the biggest human, with a helmet dome and a disc-shaped drum behind the shoulders. Preserve construction: Thornwall's own look, shared by every contractor: professional, unhurried and never sloppy, in matte charcoal tactical gear with none of Arcadia's cheer. A charcoal combat shirt and trousers, a matte charcoal plate carrier with dark slate webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. Thin violet neon piping (#9B5CFF, Thornwall's color) runs along the carrier's shoulder straps, painted as a flat bright color with no glow. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing else on the kit is bright, so the guns and the tells carry the color. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks. The heavy overlays, at 1.1x scale: a full-face matte charcoal helmet with a dark smoked visor that carries a slim violet strip, and a breather grille; oversized shoulder guards, thigh plates and knee armor over the kit, clean and well kept. A hip harness, a strap and cradle at the belt, takes the rotary's weight. The drum pack is a round ammunition drum about 0.36 m across (about 0.40 m at his 1.1x scale), carried on the back in a near-black harness, graphite with a pale ivory stripe and a small bone thorn glyph on its side, with a belt port at its front where the long feed belt starts. The weapon hand is bare inside a heavy dark glove and empty: the rotary is a separate sprite that carries only a short belt stub and its own heat collar. In look A the face is fully covered by the visor; in looks B and C the visor is up and an alert, steady face shows. He has no implant. Preserve the palette: charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058; graphite pads #34373B; black boots and gloves #1E2023; bone thorn glyph #D8D2BC; charcoal helmet, shoulder guards and plates #34373B; smoked visor #20262C with violet strip and carrier piping #9B5CFF; drum #3A3D40 with pale ivory stripe #D8D2BC; feed belt #1E2023 with dark steel links #2A3341; hip harness #25272A; skin (the wrists, and the face in looks B and C) #C8A084. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the rotary's heat collar. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads) at 1.1x scale, two arms and two legs, one helmet and one drum. The rotary is never painted into the art. No shield, coat, bandolier, gas mask or second gun. No implant, no teal, no neon except the violet trim (#9B5CFF), no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph. No police marks. Alert, awake faces where a face shows: no blank stare or slack mouth. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Heavy Gunner reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle (rotary slung low); walk; windup (plant the feet, haul the rotary to the hip); attack (the braced firing stance); overheat (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, rotary rear grip, support hand on the forward handle). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their rotary-grip shapes around empty space; the rotary is a separate sprite and is never painted in. Movement language: Walks with a heavy, deliberate tread, the rotary slung low. To attack he plants his feet wide, drops his weight and hauls the rotary to hip height in a deep braced stance, so the stream leaves at about 0.5 H (about 0.85 m above the floor) and never at head height on Dave's floor. The barrels spin up while the collar warms, and the stream is a held stance with the shoulders shaking. Then he stops, rooted, as the barrels vent steam and the gun hangs low: the overheat is the opening. Capability: Plants a rotary machine gun and fires a flat 1.2 s stream at 0.5 H, then overheats, rooted. Important limitation or opening: The overheat is the opening: rooted, the barrels venting steam, the gun hanging low and his head bowed. Keep the drum and the helmet as clean, readable shapes so the silhouette holds. Do not add a shield, a second gun, a coat or a bandolier; those belong to other roster types. Tell: CHARGE on the rotary's heat collar (part of the gun, added by the engine): a glow that grows amber over the 1.0 s spin-up, then red for the last 0.25 s. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Generate the three looks as painted HD parts sheets (C56) with style-frame-v2 attached (layout as in the Night Guard's prompt 4, [SE01](../security/se01-night-guard.md); attach look A when generating B and C). Build on the approved Rifleman (SE04), the shared Thornwall body. The full-face helmet, the harness and the drum are overlays painted over it at 1.1x scale.
- Split each approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The drum, the sleeve patch and the hip pouch must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Rifleman (helmet and carbine), the Grenadier (hooded mask and bandolier) and the Riot Officer (helmet and shield). The Heavy Gunner reads as the biggest human, with a helmet dome and a round drum behind the shoulders. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (heavy-weapon idle, slow walk, braced firing stance, hit flinch) for the side view (C38). Check that the rotary sits at about 0.5 H in the braced stance, that the feed belt stretches from drum to gun without crossing the face, and that the drum does not hide the shoulder pivot.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

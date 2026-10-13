# Rifleman

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** SE04\
**Category:** security (Arcadia Response Team, lime; then Thornwall, violet; humans)\
**First appearance:** Level 3 (appears in L3–L9: Arcadia's Response Team at L3, a Thornwall man from L4)\
**Design status:** Look follows C60 (approved 2026-10-12): painted HD parts on the lit cutout rig (C56), corporate cyberpunk (C58), alert and composed (C57); lime trim on the Response Team skin, violet on the Thornwall skin. Concept images are still to be generated. The lit cutout method is confirmed (C35). The roster entry (C31), human enemies (C25) and the enemy gun kit (C27) are confirmed. Behavior numbers (P23) are *proposed*. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Aimed burst gunner and the roster's workhorse: the same soldier in Arcadia's uniform and then in Thornwall's.

*Proposed identity:* a rifleman of Arcadia's Response Team in Level 3, armed with the AR-7 "Warrant" carbine ([EG02](../enemy-guns/eg02-assault-rifle.md)) that Arcadia's defense division sells. From Level 4 the same body appears in Thornwall's plain kit. Thornwall is the private military contractor that Arcadia keeps on retainer to guard the defense servers in the Rootworks. When the board changes its orders from "guard" to "sanitize", it arrives the same night with rifles, machine guns and frags.

**Four looks on one rig** (C56, C60), all Caucasian (C43), two per skin. Response Team: **A, the team leader** (an athletic man in his forties, a short dark beard) and **B, the woman officer** (athletic, in her thirties, dark hair in a low bun at the back of the helmet). Thornwall: **A, the masked contractor** (anonymous, gaiter up, visor down) and **B, the shaved-head contractor** (a rangy man in his thirties, shaved head, visor up, a calm, hard face). The game picks a look by entity id; stats, tells and timing are the same.

The Rifleman is human, not Linked, and he is the base of the shared Thornwall body: the [Heavy Gunner](../thornwall/tw01-heavy-gunner.md), the [Grenadier](../thornwall/tw02-grenadier.md), the [Marksman](../thornwall/tw03-marksman.md) and the [Linked Trooper](../linked/lk04-linked-trooper.md) are overlays or skins on this body. At Level 3 he fights because he is on the Response Team; from Level 4 because Thornwall is paid to. Combat is lethal (C28): he bleeds like anyone else (C29).

## Scale and silhouette

About 1.80 m tall, roughly 7.25 heads, with an athletic build. This is the baseline height of the shared Thornwall body.

A squared, helmeted figure with a boxy helmet and a bracket on its brow, a visor band across the eyes, a plate carrier that squares off the chest and knee pads, so the outline is blocky and anonymous at a distance. He is the baseline soldier body: athletic, upright and neutral.

In play he fires from a half-kneel with the carbine shouldered low. In grayscale he reads as helmet, plate carrier and a medium-length rifle. The Heavy Gunner is bigger with a back drum, the Grenadier has a hooded mask and bandolier, the Marksman a long coat, and the Linked Trooper is bare-headed.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design (C60).* Thornwall's own look, shared by every contractor: professional, unhurried and never sloppy, in matte charcoal tactical gear with none of Arcadia's cheer. A charcoal combat shirt and trousers, a matte charcoal plate carrier with dark slate webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. Thin violet neon piping (#9B5CFF, Thornwall's color) runs along the carrier's shoulder straps, painted as a flat bright color with no glow. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing else on the kit is bright, so the guns and the tells carry the color. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks.

The plain helmet is a matte charcoal helmet with side rails, a flip-down bracket on the brow and no markings, with a dark smoked visor that carries a slim violet strip. On the masked contractor (look A) the dark neck gaiter is pulled up over the nose and mouth and the visor is down, so only a strip of skin shows around the eyes; on the shaved-head contractor (look B) the visor is flipped up on its bracket and the gaiter hangs at the throat, so a focused, steady face shows. The weapon hand is bare inside a dark glove and empty: the carbine is a separate sprite (the Response Team carries the clean AR-7, and Thornwall carries the matte charcoal TK-12 field version). He has no implant.

*Arcadia Response Team skin (Level 3, lime):* the same rig repainted in navy: a navy combat shirt and trousers, a navy plate carrier with pale webbing, a white-and-navy helmet with a dark visor and a thin lime visor strip, thin lime piping (#C6FF3D, Arcadia Security's color) along the carrier straps, and the white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) on the sleeve patch and the helmet side in place of the thorn glyph. Both Response Team looks wear the visor up and the gaiter down, so the face shows: alert and focused. Nothing else changes.

## Color and materials

*Proposed palette (Thornwall, the painted default):* charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058; charcoal helmet and pads #34373B; black boots and gloves #1E2023; dark neck gaiter #303236; smoked visor #2A3038 with violet strip and carrier piping #9B5CFF; bone thorn glyph #D8D2BC; skin #C8A084. *Response Team recolor:* navy shirt and trousers #1E2838; carrier #2A3B5C; webbing #8794A2; helmet white #E6EBF0 and navy #2A3B5C; visor #1B2430 with lime strip and piping #C6FF3D; gaiter #3A434F; emblem white #E9EDF0; skin #DDB18F. Hair by look: Response Team A dark brown #3A2B22, B dark brown #3A2B22; Thornwall B shaved.

**Tokens.** The tell is Hazard amber #FFB02E, then Alarm red #FF3B4E for the last 0.25 s, as a glow on the carbine's muzzle lamp, which belongs to the gun asset (EG02), plus a 0.2 s red blink before each later burst. The body carries no glow. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, never painted in, and it never glows or uses a tell color. He shows no amber point and no teal light, because he is not Linked. **Neon (C60):** the trim marks who controls him: violet #9B5CFF for Thornwall, lime #C6FF3D for the Arcadia Response Team, one per skin. It is steady, thinner and dimmer than any tell, never on the carbine or its muzzle lamp, and it goes dark when he dies.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (the shouldered carbine) and by the shouted bark, and the thorn glyph and the white emblem differ by shape as well as color.

## Abilities and movement

- **Template:** Gunner (C26).
- **Weapon:** Assault Rifle ([EG02](../enemy-guns/eg02-assault-rifle.md)): the AR-7 "Warrant" (Response Team) or the matte charcoal TK-12 (Thornwall).
- **Tell:** GLOW on the muzzle lamp, plus a 0.2 s red blink before each later burst.
- **Attack:** he shoulders the carbine as its lamp goes amber, then red, then fires 2 flat 3-round bursts (3 bursts from Level 5), 0.9 s apart, at 0.5 H on his own floor. He never aims at an airborne Dave and turns to face Dave only between bursts.
- **Counter:** one jump per burst, or stand behind a low crate, then close in during the 1.6 s magazine swap (3 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Moves in short crouching bounds between cover. To fire he drops into a half-kneel or a deep braced stance with the carbine shouldered low, so the muzzle sits at about 0.5 H (about 0.85 m above the floor) and never at head height on Dave's floor. He holds the aim through each 3-round burst, breathes, and re-aims for the next.

The magazine swap is the opening: rooted, the carbine tilted, one hand slapping in a fresh magazine, his head down.

**Sample barks** *(proposed; Response Team calls at Level 3, cold Thornwall calls from Level 4, with profanity where it fits. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Response Team, moving. Harlan is armed." (Level 3, first sight)
- "Push up! Push up!" (Level 3, advance)
- "Contact. Range six." (Thornwall, first sight)
- "Cleaning up. Nobody walks out." (Thornwall, the windup)
- "Mag! Changing!" (the magazine swap)
- "Fuck, he's fast." (Thornwall, hit)

Death is a grunt and a dropped rifle, with no last words.

## Openings and limitations

The magazine swap is the opening: hold the rooted, head-down pose long enough to read. He never fires at an airborne Dave. Do not add a shield, a drum pack, a coat or a second gun; those belong to other roster types. The helmet stays plain, and the Thornwall mark and the emblem live on the sleeve patch and helmet side only.

## Rig parts, normal maps and sockets

**Looks (C56):** the four looks share one part list, skeleton, pivots, clips and hit zones. **Parts** *(painted once per look, facing right; near means the side toward the camera)*: head; helmet (its own part, shared by all four looks) with the visor as a separate flip piece; torso with the plate carrier; pelvis with the belt and utility pouch; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand; the far hand is the support hand); near and far upper legs, lower legs and feet, with knee pads. The sleeve patch and the helmet-side patch are separate swappable decals, the Thornwall glyph or the Arcadia emblem. The carbine is a separate sprite (EG02). This is the shared Thornwall body: the drum pack, the gas mask with its bandolier, and the coat and visor are overlays painted over it.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the helmet at the crown. The whole arm aims from the shoulder. Paint hidden overlap under every joint, and paint the far limbs complete.

**Sockets:** the gun socket at the near palm holds the carbine's rear grip; a support socket at the far palm meets its foregrip. The muzzle marker and the muzzle-flash light belong to the gun sprite (EG02). The two skins (Response Team, Thornwall) share every part and normal map and change only color, the visor strip, the neon piping and the two patch decals; the two looks in a skin change the head, the visor state and the gaiter.

**Normal maps:** one per part (green = up), soft-edged: helmet rails and bracket, plate-carrier edges and webbing, pouch flaps, cloth folds at the joints, knee pads and gentle face modeling around the eye strip. Both skins share the normal maps.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. Blood anchors sit on the head, chest, belly, near upper arm and near thigh. No implant sparks.

**Motion and death:** hand-keyed on the rig for the side view (C38): a rifle idle, a rifle walk and run, a half-kneel rifle aim, a magazine change and a hit flinch. Death is a ragdoll pushed by the killing shot, and the carbine drops as a prop, never a pickup. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle (rifle low); walk and run; windup (shoulder the carbine from a half-kneel); attack (the burst stance); magazine swap (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, rifle grip, support hand on the foregrip, magazine slap); Arcadia Response Team skin (neutral pose, recolor only).

Tell by pose: shouldering the carbine is the windup, and the amber-then-red glow on the muzzle lamp belongs to the gun and is added by the engine. Paint the hands in their grip shapes around empty space. The Response Team skin is a recolor study in the neutral pose, so the palette swap can be checked without repainting the parts.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one helmet. The carbine is never painted into the art. No drum pack, gas mask, bandolier, coat, shield or second gun. No implant, no teal, no neon except the skin's own (violet for Thornwall, lime for the Response Team), no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph and the Arcadia emblem is a wordless mark. No police marks. Alert, awake faces: no blank stare or slack mouth. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The sleeve patch, the hip pouch and the weapon hand sit on the near side and are safe to mirror, and the two patch decals are separate parts, so a skin swap never touches the painted body.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Paint a single evenly lit, hand-painted, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: soft painted shading for form and folds, clean dark outlines (heavier outer contours, restrained interior lines), no baked cast shadows, no cel-shadow shapes, no rim light, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Rifleman, a human enemy in Thornwall's plain kit (the same body is Arcadia's Response Team at Level 3): a rifleman with a plain helmet. Role: Aimed burst gunner and the roster's workhorse: the same soldier in Arcadia's uniform and then in Thornwall's.
Scale: About 1.80 m tall, roughly 7.25 heads, with an athletic build. This is the baseline height of the shared Thornwall body.
Silhouette: A squared, helmeted figure with a boxy helmet and a bracket on its brow, a visor band across the eyes, a plate carrier that squares off the chest and knee pads, so the outline is blocky and anonymous at a distance. He is the baseline soldier body: athletic, upright and neutral.
Physical design: Thornwall's own look, shared by every contractor: professional, unhurried and never sloppy, in matte charcoal tactical gear with none of Arcadia's cheer. A charcoal combat shirt and trousers, a matte charcoal plate carrier with dark slate webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. Thin violet neon piping (#9B5CFF, Thornwall's color) runs along the carrier's shoulder straps, painted as a flat bright color with no glow. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing else on the kit is bright, so the guns and the tells carry the color. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks. The plain helmet is a matte charcoal helmet with side rails, a flip-down bracket on the brow and no markings, with a dark smoked visor that carries a slim violet strip. On the masked contractor (look A) the dark neck gaiter is pulled up over the nose and mouth and the visor is down, so only a strip of skin shows around the eyes; on the shaved-head contractor (look B) the visor is flipped up on its bracket and the gaiter hangs at the throat, so a focused, steady face shows. The weapon hand is bare inside a dark glove and empty: the carbine is a separate sprite (the Response Team carries the clean AR-7, and Thornwall carries the matte charcoal TK-12 field version). He has no implant.
Materials and colors: charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058; charcoal helmet and pads #34373B; black boots and gloves #1E2023; dark neck gaiter #303236; smoked visor #2A3038 with violet strip and carrier piping #9B5CFF; bone thorn glyph #D8D2BC; skin #C8A084. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the carbine's muzzle lamp. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one helmet. The carbine is never painted into the art. No drum pack, gas mask, bandolier, coat, shield or second gun. No implant, no teal, no neon except the skin's own (violet for Thornwall, lime for the Response Team), no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph and the Arcadia emblem is a wordless mark. No police marks. Alert, awake faces: no blank stare or slack mouth. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright, hands empty and slightly curled, the helmet on and the gaiter up; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Rifleman design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.80 m tall, roughly 7.25 heads, with an athletic build. This is the baseline height of the shared Thornwall body. Maintain these defining forms: A squared, helmeted figure with a boxy helmet and a bracket on its brow, a visor band across the eyes, a plate carrier that squares off the chest and knee pads, so the outline is blocky and anonymous at a distance. He is the baseline soldier body: athletic, upright and neutral. Preserve construction: Thornwall's own look, shared by every contractor: professional, unhurried and never sloppy, in matte charcoal tactical gear with none of Arcadia's cheer. A charcoal combat shirt and trousers, a matte charcoal plate carrier with dark slate webbing, a row of pouches across the chest and a utility pouch on the near hip, graphite knee pads, black boots and dark gloves, and a comm headset. Thin violet neon piping (#9B5CFF, Thornwall's color) runs along the carrier's shoulder straps, painted as a flat bright color with no glow. A small original Thornwall mark, a bone-white thorn glyph (a slim hooked thorn over a short bar, no lettering), sits on a sleeve patch on the near upper arm. Nothing else on the kit is bright, so the guns and the tells carry the color. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks. The plain helmet is a matte charcoal helmet with side rails, a flip-down bracket on the brow and no markings, with a dark smoked visor that carries a slim violet strip. On the masked contractor (look A) the dark neck gaiter is pulled up over the nose and mouth and the visor is down, so only a strip of skin shows around the eyes; on the shaved-head contractor (look B) the visor is flipped up on its bracket and the gaiter hangs at the throat, so a focused, steady face shows. The weapon hand is bare inside a dark glove and empty: the carbine is a separate sprite (the Response Team carries the clean AR-7, and Thornwall carries the matte charcoal TK-12 field version). He has no implant. Preserve the palette: charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058; charcoal helmet and pads #34373B; black boots and gloves #1E2023; dark neck gaiter #303236; smoked visor #2A3038 with violet strip and carrier piping #9B5CFF; bone thorn glyph #D8D2BC; skin #C8A084. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the carbine's muzzle lamp. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one helmet. The carbine is never painted into the art. No drum pack, gas mask, bandolier, coat, shield or second gun. No implant, no teal, no neon except the skin's own (violet for Thornwall, lime for the Response Team), no name tapes and no readable text or logos: the Thornwall mark is a wordless glyph and the Arcadia emblem is a wordless mark. No police marks. Alert, awake faces: no blank stare or slack mouth. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Rifleman reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle (rifle low); walk and run; windup (shoulder the carbine from a half-kneel); attack (the burst stance); magazine swap (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, rifle grip, support hand on the foregrip, magazine slap); Arcadia Response Team skin (neutral pose, recolor only). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their rifle-grip shapes around empty space; the carbine is a separate sprite and is never painted in. Movement language: Moves in short crouching bounds between cover. To fire he drops into a half-kneel or a deep braced stance with the carbine shouldered low, so the muzzle sits at about 0.5 H (about 0.85 m above the floor) and never at head height on Dave's floor. He holds the aim through each 3-round burst, breathes, and re-aims for the next. The magazine swap is the opening: rooted, the carbine tilted, one hand slapping in a fresh magazine, his head down. Capability: Fires two or three flat 3-round bursts with a pause between them, then swaps magazines, rooted. Important limitation or opening: The magazine swap is the opening: hold the rooted, head-down pose long enough to read. He never fires at an airborne Dave. Do not add a shield, a drum pack, a coat or a second gun; those belong to other roster types. The helmet stays plain, and the Thornwall mark and the emblem live on the sleeve patch and helmet side only. Tell: GLOW on the carbine's muzzle lamp (part of the gun, added by the engine), amber first and then red for the last 0.25 s, plus a 0.2 s red blink before each later burst. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Generate the four looks as painted HD parts sheets (C56) with style-frame-v2 attached (layout as in the Night Guard's prompt 4, [SE01](se01-night-guard.md); attach the first look when generating the others). Approve this body first among the Thornwall types, because it is the shared body that the Heavy Gunner, Grenadier, Marksman and Linked Trooper build on.
- Split each approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The sleeve patch, the hip pouch and the weapon hand must read correctly flipped, and both skins must swap cleanly.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Night Guard (cap and baton), the Riot Officer (helmet and shield) and the other Thornwall overlays (drum pack, mask and bandolier, long coat). The Rifleman reads as the baseline soldier: helmet, carrier and rifle. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (rifle idle, walk and run, half-kneel aim, magazine change, hit flinch) for the side view (C38). Check that the carbine sits at about 0.5 H in the fire pose.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

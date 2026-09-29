# Night Guard

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** SE01\
**Category:** security (Arcadia Security, humans)\
**First appearance:** Level 1 (appears in L1–L4; handles the Act 1 Hounds in L2–L3)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), with this asset as the approved test subject (2026-09-30). The roster entry (C31) and human enemies (C25) are confirmed. This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Visual reference status

No Night Guard image is selected yet. Generate a neutral design from prompt 1 and approve one before splitting it into rig parts or producing poses.

The lit cutout test build (C35) uses this asset: one Night Guard, painted flat, cut into rig parts, given normal maps, lit by the engine next to Dave, moved by Mixamo clips and killed as a ragdoll. The user approved that look on 2026-09-30, so the method is *confirmed and validated*; this brief's appearance details stay proposed until the final painting. The [style guide](../style-guide.md) defines the pipeline. For scale, the test puts the guard next to Dave's placeholder sprites ([h01-rook](../../concept-art/h01-rook/)), so keep the two at a believable relative size.

## Identity and role

Basic melee enemy and the first human Dave has to fight. A guard at work, who bleeds and stays down.

*Proposed identity:* Arcadia Security's night-shift campus guard, a contract officer in his forties who walks the Sunnyvale grounds after hours with a flashlight, a shock baton and a radio. He is human, not Linked, and he takes his orders from the security desk, not from Adam. That morning every post got the same notice: Dave Harlan, fired researcher, flagged as a security threat. He knows the face, so he shouts and swings. Combat is lethal (C28): he bleeds (C29), and when he goes down he stays down.

The Night Guard appears in Levels 1–4. In Act 1 he is also the handler of the [Hound](../hounds/k01-hound.md) (C30): he stays two paces behind the dog and joins the fight a beat after its lunges. After Level 1 the PA announces that lethal force is authorized and that Harlan is armed. The Night Guard is still the baton man: a tired person with a bad shift, who has no idea what Arcadia is doing beneath his feet.

## Scale and silhouette

About 1.78 m tall, roughly 7.25 heads, with a short neck and a heavy-set build.

A stocky, broad-shouldered figure topped by a peaked patrol cap whose short flat brim points forward, with a wide duty belt and a cluster of pouches, and the baton held low along the near thigh as a straight dark line with a small bulb at its tip. A radio hump sits on the near shoulder. In grayscale he reads as cap brim, heavy torso and one long straight rod. He has no helmet, no long gun and no shield, which sets him apart from the Sidearm Guard (bare head, vest and two-hand stance), the Riot Officer (helmet and shield) and the Rifleman (helmet and carbine).

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* Arcadia grey livery, a charcoal-grey with a blue cast: a zip-front duty jacket with a stand collar over a pale grey shirt, work trousers a shade darker, and black boots. A lanyard holds a blank ID card. A white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) sits on a patch on the near upper sleeve and on the side of the cap. The cap is a soft-topped peaked patrol cap with a short flat brim. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars.

A black duty belt carries a baton ring on the near hip, a flashlight, a keycard on a retractable reel, a small pouch and, for the handler variant, a coil of dog lead at the back (never shown attached to the dog). A radio is clipped to the near shoulder strap. The shock baton is a black rod about 0.65 m long with a pale rubber grip, a wrist loop, two steel contact studs and a small emitter lens at the tip; it is held low in the near hand, clear of the thigh so it can be cut out as its own sprite. The face is heavy-browed, with two days of stubble, tired eyes and a sweat-dark collar, and the expression is tense, not cruel. Wear shows at the cap brim, the belt and the boot toes. He has no implant.

## Color and materials

*Proposed palette:* skin #B58968; Arcadia grey jacket #4B5663; pale grey shirt #C7CED5; work trousers #3A434F; cap #414B57; black belt and boots #23272E; graphite belt gear #2C323A; baton #23272E with pale grip #AEB8C2 and steel studs #8FA0B3; emblem white #E9EDF0; blank ID card #D8DEE4.

**Tokens.** The tell is Hazard amber #FFB02E, then Alarm red #FF3B4E for the last 0.25 s, as a large additive glow on the baton tip. The emitter lens is painted dark and unlit, and the engine adds the glow. Fluid is human blood: Blood #B3212F drying to Dried blood #8A1A26, drawn by the engine as a spray, wound marks and floor pools and never painted into the parts. Blood never glows and never uses a tell color. He shows no small amber point and no teal light, because those belong to driven and harmless Linked people, and he is neither.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (baton overhead, weight back) and by the shouted bark.

## Abilities and movement

- **Template:** Brawler (C26): one melee attack.
- **Weapon:** shock baton (melee). He carries no gun.
- **Tell:** GLOW: the baton tip glows amber, then red for the last 0.25 s, with the shouted bark.
- **Attack:** one short overhead swing.
- **Counter:** step back out of reach, then shoot him during his winded pause (3 hits). He bleeds and stays down.

Walks a heavy patrol beat with the flashlight sweeping ahead and the baton swinging low. When he finds Dave he squares up, jogs in and plants his rear foot, then hauls the baton overhead with his weight back: that raised, leaning pose is the windup, and it is long enough to read. The swing is short and hard. Afterward he bends forward with one hand on his knee and the baton hanging, breathing hard: that winded pause is the opening.

As a handler in Levels 2–3 he stays two paces behind the Hound with one arm out to point, and his own windup starts 1.5 s after the Hound's lunge chain ends.

**Sample barks** *(proposed; scared and angry, with profanity where it fits. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Harlan! Get on the fucking ground!" (the windup)
- "Contact! He's on the depot roof!" (first sight)
- "Hound, get him! Go!" (handler command, Act 1)
- "Ah, shit! Ah, that's real—" (hit)
- "Christ. It's actually him." (idle alert)

Death is a grunt and the clatter of a dropped baton, with no last words.

## Openings and limitations

The winded pause after the swing is the opening, and it must be long and obvious: hunched, one hand on a knee, baton hanging, cap brim low. He has no ranged attack. Do not add a gun, a holster, armor plates or a shield: the [Sidearm Guard](se02-sidearm-guard.md) brings the first pistol and the [Riot Officer](se03-riot-officer.md) the first shield.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head; cap (its own part, so it can fly off in the ragdoll); torso with the duty jacket; pelvis with the duty belt; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand); near and far upper legs, lower legs and feet. Small swinging pieces: the radio on the near shoulder strap, the flashlight and the keycard reel on the belt, the lanyard and ID card, and the dog-lead coil (handler variant). The baton is its own sprite.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the cap at the crown; the lanyard at the collar; the baton at the grip. Paint hidden overlap under every joint, and paint the far limbs and anything the near hand covers complete.

**Sockets:** the weapon-hand socket at the near palm holds the baton, its axis along the fingers; a tip marker at the emitter lens anchors the tell glow (GLOW). There is no gun socket, since he carries no gun. The far hand has a free off-hand socket, used for the handler's pointing gesture.

**Normal maps:** one per part (green = up), soft-edged so the light stays smooth: the rolled cap brim, jacket seams, collar and zip, belt and pouch edges, cloth folds at the elbows and knees, the rounded baton, and gentle face modeling (brow, nose, cheek) so a lamp lights one side of the face.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26): a spray at the hit point, wound marks attached to the hit part and floor pools, all drawn by the engine. Blood anchors sit on the head, chest, belly, near upper arm and near thigh. No implant sparks, since he is not Linked.

**Motion and death:** Mixamo clips converted to the rig: a patrol idle, a walk, a run or jog, an overhead melee swing, and a hit flinch. Hand-key the raised-baton windup and the hands-on-knees winded pose where no clip fits. Death is a ragdoll: the parts become physics bodies pushed by the killing shot, and the cap and baton fly loose (the baton lands as a prop). The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle patrol (flashlight sweep); walk and run; windup (baton overhead, weight back); attack (the overhead swing); winded pause (the opening); hit reaction; handler point (Act 1); death launch (first ragdoll frame); resting corpse pose; the weapon hand (relaxed, baton grip, open drop).

Tell by pose: the raised baton and the leaning weight are the windup, and the engine adds the amber-then-red glow on the tip over that pose (amber first, then red for the last 0.25 s). The winded pause carries no glow. The resting corpse pose is the one authored pose the engine restores after a death or Continue: on the back or side, cap off, baton beside him.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms, two legs, one cap and one baton. No gun, holster, armor plates, shield, implant or amber point, since he is not Linked. No police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts; the tell glow, blood and dropped items come from the engine. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Everything asymmetric here (the baton hand, the radio, the belt gear and the sleeve patch) sits on the near side and is safe to mirror, since none of it carries lettering or handedness. Nothing needs a separate swap part.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Night Guard, an Arcadia Security human enemy: a night-shift campus guard armed with a shock baton. Role: Basic melee enemy and the first human Dave has to fight. A guard at work, who bleeds and stays down.
Scale: About 1.78 m tall, roughly 7.25 heads, with a short neck and a heavy-set build.
Silhouette: A stocky, broad-shouldered figure topped by a peaked patrol cap whose short flat brim points forward, with a wide duty belt and a cluster of pouches, and the baton held low along the near thigh as a straight dark line with a small bulb at its tip. A radio hump sits on the near shoulder. In grayscale he reads as cap brim, heavy torso and one long straight rod. He has no helmet, no long gun and no shield, which sets him apart from the Sidearm Guard (bare head, vest and two-hand stance), the Riot Officer (helmet and shield) and the Rifleman (helmet and carbine).
Physical design: Arcadia grey livery, a charcoal-grey with a blue cast: a zip-front duty jacket with a stand collar over a pale grey shirt, work trousers a shade darker, and black boots. A lanyard holds a blank ID card. A white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) sits on a patch on the near upper sleeve and on the side of the cap. The cap is a soft-topped peaked patrol cap with a short flat brim. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars. A black duty belt carries a baton ring on the near hip, a flashlight, a keycard on a retractable reel, a small pouch and, for the handler variant, a coil of dog lead at the back (never shown attached to the dog). A radio is clipped to the near shoulder strap. The shock baton is a black rod about 0.65 m long with a pale rubber grip, a wrist loop, two steel contact studs and a small emitter lens at the tip; it is held low in the near hand, clear of the thigh so it can be cut out as its own sprite. The face is heavy-browed, with two days of stubble, tired eyes and a sweat-dark collar, and the expression is tense, not cruel. Wear shows at the cap brim, the belt and the boot toes. He has no implant.
Materials and colors: skin #B58968; Arcadia grey jacket #4B5663; pale grey shirt #C7CED5; work trousers #3A434F; cap #414B57; black belt and boots #23272E; graphite belt gear #2C323A; baton #23272E with pale grip #AEB8C2 and steel studs #8FA0B3; emblem white #E9EDF0; blank ID card #D8DEE4. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, as a glow on the baton tip. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms, two legs, one cap and one baton. No gun, holster, armor plates, shield, implant or amber point, since he is not Linked. No police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts; the tell glow, blood and dropped items come from the engine. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing tired and upright with the baton held low in the near hand and clear of the thigh, a wary expression; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Night Guard design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.78 m tall, roughly 7.25 heads, with a short neck and a heavy-set build. Maintain these defining forms: A stocky, broad-shouldered figure topped by a peaked patrol cap whose short flat brim points forward, with a wide duty belt and a cluster of pouches, and the baton held low along the near thigh as a straight dark line with a small bulb at its tip. A radio hump sits on the near shoulder. In grayscale he reads as cap brim, heavy torso and one long straight rod. He has no helmet, no long gun and no shield, which sets him apart from the Sidearm Guard (bare head, vest and two-hand stance), the Riot Officer (helmet and shield) and the Rifleman (helmet and carbine). Preserve construction: Arcadia grey livery, a charcoal-grey with a blue cast: a zip-front duty jacket with a stand collar over a pale grey shirt, work trousers a shade darker, and black boots. A lanyard holds a blank ID card. A white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) sits on a patch on the near upper sleeve and on the side of the cap. The cap is a soft-topped peaked patrol cap with a short flat brim. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars. A black duty belt carries a baton ring on the near hip, a flashlight, a keycard on a retractable reel, a small pouch and, for the handler variant, a coil of dog lead at the back (never shown attached to the dog). A radio is clipped to the near shoulder strap. The shock baton is a black rod about 0.65 m long with a pale rubber grip, a wrist loop, two steel contact studs and a small emitter lens at the tip; it is held low in the near hand, clear of the thigh so it can be cut out as its own sprite. The face is heavy-browed, with two days of stubble, tired eyes and a sweat-dark collar, and the expression is tense, not cruel. Wear shows at the cap brim, the belt and the boot toes. He has no implant. Preserve the palette: skin #B58968; Arcadia grey jacket #4B5663; pale grey shirt #C7CED5; work trousers #3A434F; cap #414B57; black belt and boots #23272E; graphite belt gear #2C323A; baton #23272E with pale grip #AEB8C2 and steel studs #8FA0B3; emblem white #E9EDF0; blank ID card #D8DEE4. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, as a glow on the baton tip. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms, two legs, one cap and one baton. No gun, holster, armor plates, shield, implant or amber point, since he is not Linked. No police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts; the tell glow, blood and dropped items come from the engine. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Night Guard reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle patrol (flashlight sweep); walk and run; windup (baton overhead, weight back); attack (the overhead swing); winded pause (the opening); hit reaction; handler point (Act 1); death launch (first ragdoll frame); resting corpse pose; the weapon hand (relaxed, baton grip, open drop). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Movement language: Walks a heavy patrol beat with the flashlight sweeping ahead and the baton swinging low. When he finds Dave he squares up, jogs in and plants his rear foot, then hauls the baton overhead with his weight back: that raised, leaning pose is the windup, and it is long enough to read. The swing is short and hard. Afterward he bends forward with one hand on his knee and the baton hanging, breathing hard: that winded pause is the opening. As a handler in Levels 2–3 he stays two paces behind the Hound with one arm out to point, and his own windup starts 1.5 s after the Hound's lunge chain ends. Capability: A short-range melee attacker with one overhead swing; he is dangerous only up close. Important limitation or opening: The winded pause after the swing is the opening, and it must be long and obvious: hunched, one hand on a knee, baton hanging, cap brim low. He has no ranged attack. Do not add a gun, a holster, armor plates or a shield: the Sidearm Guard brings the first pistol and the Riot Officer the first shield. Tell: GLOW on the baton tip, amber first and then red for the last 0.25 s, added by the engine; paint the tip lens dark. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. This is the asset the lit cutout test uses (C35), so its painting comes first, and the test result may revise this brief.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The baton hand, radio and sleeve patch must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Sidearm Guard (bare head, vest, two-hand stance), the Riot Officer (helmet and shield) and the Rifleman (helmet and carbine). The Night Guard reads by the cap brim, the heavy torso and the long rod. The tell must read by pose and glow with the night overlay on.
- Convert the Mixamo clips (patrol idle, walk, run, overhead melee swing, hit flinch) to the rig and hand-key the tell pose where no clip fits. Check that the winded pause is long enough to read before the next swing.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

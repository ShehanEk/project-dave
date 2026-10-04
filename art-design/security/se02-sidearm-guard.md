# Sidearm Guard

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** SE02\
**Category:** security (Arcadia Security, humans)\
**First appearance:** Level 2 (appears in L2–L6)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed and so is the enemy gun kit (C27). This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Aimed pistol gunner and the first enemy with a gun. A guard who was handed a live pistol an hour ago.

*Proposed identity:* a younger patrol guard for Arcadia Security, issued the campus sidearm after the Level 1 lockdown: the AS-9 "Civic" smart pistol ([EG01](../enemy-guns/eg01-pistol.md)), made by Arcadia's own defense division. He is human, not Linked, and he is scared and angry. After Level 1 the PA told every team: "All teams: lethal force is authorized. Harlan is armed." He has never fired a live round at a person. He holds posts across the campus grounds in Levels 2–3 and at Arcadia's own security stations in the Rootworks in Levels 4–6.

Combat is lethal (C28). He fires, he reloads badly, and he bleeds like everyone else (C29).

## Scale and silhouette

About 1.76 m tall, roughly 7.25 heads, with a lean, narrow-shouldered build.

A lean, upright figure with a bare head and cropped hair, a soft armor vest with a raised collar that squares off the torso, a closed holster on the near thigh, and thin gloves.

In his fire pose he stands with bent knees and both arms straight out in front, low, in a two-hand stance. In grayscale he reads by the bare head, the boxy vest collar, the thigh holster and the extended two-hand pose. He is narrower than the Night Guard and carries no cap and no baton.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* Arcadia grey livery, a charcoal-grey with a blue cast: a long-sleeve pale grey shirt under a darker grey soft armor vest with a raised collar and a pale front panel, work trousers a shade darker, black boots and thin black gloves. A lanyard holds a blank ID card. The white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) sits on a patch on the near shoulder of the vest. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars.

A black duty belt carries a closed-flap holster on the near thigh (the flap stays shut: the pistol is a separate sprite and is never painted into the holster or the hand), two spare-magazine pouches at the front and a keycard reel. A radio is clipped to the vest strap, with a coiled earpiece cable running to the near ear. The face is young and pale under the eyes, with a tight jaw and wide, darting eyes, and the hair is cropped short. He has no implant.

## Color and materials

*Proposed palette:* skin #7E5A44; pale grey shirt #C7CED5; Arcadia grey vest #3F4854 with pale front panel #8794A2; work trousers #3A434F; black belt, gloves and boots #23272E; graphite pouches and holster #2C323A; earpiece cable #1C2026; emblem white #E9EDF0; blank ID card #D8DEE4.

**Tokens.** The tell is Hazard amber #FFB02E, then Alarm red #FF3B4E for the last 0.25 s, and it glows on the pistol's muzzle lamp, which belongs to the gun asset (EG01) and not to the body; the body carries no glow. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, never painted in, and it never glows or uses a tell color. He shows no amber point and no teal light, because he is not Linked.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (the low two-hand stance) and by the lock click and the shouted bark.

## Abilities and movement

- **Template:** Gunner (aimed) (C26).
- **Weapon:** Pistol, AS-9 "Civic" ([EG01](../enemy-guns/eg01-pistol.md)).
- **Tell:** GLOW: a two-hand stance, then the muzzle lamp goes amber, then red for the last 0.25 s with a lock click.
- **Attack:** one round: flat at 0.5 H on his own floor, or, from a ledge, one round at Dave's grounded spot, locked at red with no lead. He never aims at an airborne Dave.
- **Counter:** jump the flat round or keep moving, then rush him while he racks the slide during the 1.2 s rooted reload (3 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Holds a post with his weight on the balls of his feet. On seeing Dave he drops into a deep bent-knee two-hand stance that lowers the pistol to about 0.5 H (about 0.85 m above the floor); the round always leaves at that height, never at head height on Dave's floor. The stance is the windup, and it holds until the muzzle lamp turns red and the round leaves. After the shot he racks the slide, rooted, with his eyes on the pistol and not on Dave: that is the opening.

From a ledge he leans over the edge and aims down at Dave's grounded spot. The arms are rig parts, so the whole arm and pistol rotate at the shoulder to aim (about -60 to +30 degrees), and the shoulder cap must stay overlapped and round.

**Sample barks** *(proposed; scared and angry, with profanity where it fits. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Shots fired! He's got a fucking gun!" (first sight)
- "Drop it! I will shoot, I swear to God!" (the windup)
- "Reloading! Cover me!" (the slide rack)
- "Come on, come on, come on—" (a slow rack)
- "Oh God. I'm hit, I'm hit." (hit)

Death is a short gasp and a dropped pistol, or a half-finished "Tell Jo I'm—" that ends in silence.

## Openings and limitations

Racking the slide is the opening: he is rooted, head down, both hands on the pistol. Keep the low two-hand stance and both hands visible so the muzzle height reads. Do not add a laser sight (sight lines belong to the rail rifle and the cutter beam only), a helmet, a shield or a second gun.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head; torso with the soft vest and its raised collar; pelvis with the duty belt; near and far upper arms, lower arms and hands (the near hand is the separate pistol hand; the far hand is the support hand); near and far upper legs, lower legs and feet. Small pieces: the radio and coiled earpiece cable, the holster flap on the near thigh, two magazine pouches, the lanyard and ID card. The pistol is a separate sprite (EG01).

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the lanyard at the collar. The whole arm aims from the shoulder, so paint the shoulder cap round and overlapped. Paint hidden overlap under every joint and the far limbs complete.

**Sockets:** the gun socket at the near palm holds the pistol grip; the muzzle marker and the muzzle-flash light belong to the gun sprite (EG01). A support socket at the far palm marks where the far hand meets the grip in the two-hand stance. Nothing is painted into the holster.

**Normal maps:** one per part (green = up), soft-edged: vest quilting and raised collar, belt and pouch edges, shirt folds, glove seams, and gentle face modeling so a lamp lights one side of the face.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. Blood anchors sit on the head, chest, belly, near upper arm and near thigh. No implant sparks.

**Motion and death:** hand-keyed on the rig for the side view (C38): a pistol idle, a pistol walk, a short retreating run, a two-hand aim, and a hit flinch, plus the slide rack and the ledge-aim arm angles. Death is a ragdoll pushed by the killing shot, and the pistol drops as a prop, never a pickup. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle at a post; walk and retreating run; windup (deep two-hand stance, muzzle at 0.5 H); attack (the shot and the recoil); slide rack (the opening); ledge aim (arms angled down); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, one-hand grip, two-hand grip with the support hand cupped, slide-rack hand).

Tell by pose: the deep two-hand stance is the windup, and the amber-then-red glow on the muzzle lamp belongs to the gun and is added by the engine. Paint the hands in their grip shapes around empty space. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one closed holster, no cap or helmet. The pistol is never painted into the art or the holster, and there is no laser sight, no second gun, no armor plates, no shield and no implant. No police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The holster, the vest patch and the earpiece cable sit on the near side and are safe to mirror (no lettering, no handedness). Nothing needs a separate swap part.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Sidearm Guard, an Arcadia Security human enemy: a young patrol guard who fires the AS-9 "Civic" smart pistol. Role: Aimed pistol gunner and the first enemy with a gun. A guard who was handed a live pistol an hour ago.
Scale: About 1.76 m tall, roughly 7.25 heads, with a lean, narrow-shouldered build.
Silhouette: A lean, upright figure with a bare head and cropped hair, a soft armor vest with a raised collar that squares off the torso, a closed holster on the near thigh, and thin gloves.
Physical design: Arcadia grey livery, a charcoal-grey with a blue cast: a long-sleeve pale grey shirt under a darker grey soft armor vest with a raised collar and a pale front panel, work trousers a shade darker, black boots and thin black gloves. A lanyard holds a blank ID card. The white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) sits on a patch on the near shoulder of the vest. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars. A black duty belt carries a closed-flap holster on the near thigh (the flap stays shut: the pistol is a separate sprite and is never painted into the holster or the hand), two spare-magazine pouches at the front and a keycard reel. A radio is clipped to the vest strap, with a coiled earpiece cable running to the near ear. The face is young and pale under the eyes, with a tight jaw and wide, darting eyes, and the hair is cropped short. He has no implant.
Materials and colors: skin #7E5A44; pale grey shirt #C7CED5; Arcadia grey vest #3F4854 with pale front panel #8794A2; work trousers #3A434F; black belt, gloves and boots #23272E; graphite pouches and holster #2C323A; earpiece cable #1C2026; emblem white #E9EDF0; blank ID card #D8DEE4. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the pistol's muzzle lamp. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one closed holster, no cap or helmet. The pistol is never painted into the art or the holster, and there is no laser sight, no second gun, no armor plates, no shield and no implant. No police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright with both hands empty and slightly curled, the holster flap shut, a wary expression; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Sidearm Guard design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.76 m tall, roughly 7.25 heads, with a lean, narrow-shouldered build. Maintain these defining forms: A lean, upright figure with a bare head and cropped hair, a soft armor vest with a raised collar that squares off the torso, a closed holster on the near thigh, and thin gloves. Preserve construction: Arcadia grey livery, a charcoal-grey with a blue cast: a long-sleeve pale grey shirt under a darker grey soft armor vest with a raised collar and a pale front panel, work trousers a shade darker, black boots and thin black gloves. A lanyard holds a blank ID card. The white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) sits on a patch on the near shoulder of the vest. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars. A black duty belt carries a closed-flap holster on the near thigh (the flap stays shut: the pistol is a separate sprite and is never painted into the holster or the hand), two spare-magazine pouches at the front and a keycard reel. A radio is clipped to the vest strap, with a coiled earpiece cable running to the near ear. The face is young and pale under the eyes, with a tight jaw and wide, darting eyes, and the hair is cropped short. He has no implant. Preserve the palette: skin #7E5A44; pale grey shirt #C7CED5; Arcadia grey vest #3F4854 with pale front panel #8794A2; work trousers #3A434F; black belt, gloves and boots #23272E; graphite pouches and holster #2C323A; earpiece cable #1C2026; emblem white #E9EDF0; blank ID card #D8DEE4. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the pistol's muzzle lamp. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one closed holster, no cap or helmet. The pistol is never painted into the art or the holster, and there is no laser sight, no second gun, no armor plates, no shield and no implant. No police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Sidearm Guard reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle at a post; walk and retreating run; windup (deep two-hand stance, muzzle at 0.5 H); attack (the shot and the recoil); slide rack (the opening); ledge aim (arms angled down); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, one-hand grip, two-hand grip with the support hand cupped, slide-rack hand). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their pistol-grip shapes around empty space; the pistol is a separate sprite and is never painted in. Movement language: Holds a post with his weight on the balls of his feet. On seeing Dave he drops into a deep bent-knee two-hand stance that lowers the pistol to about 0.5 H (about 0.85 m above the floor); the round always leaves at that height, never at head height on Dave's floor. The stance is the windup, and it holds until the muzzle lamp turns red and the round leaves. After the shot he racks the slide, rooted, with his eyes on the pistol and not on Dave: that is the opening. From a ledge he leans over the edge and aims down at Dave's grounded spot. The arms are rig parts, so the whole arm and pistol rotate at the shoulder to aim (about -60 to +30 degrees), and the shoulder cap must stay overlapped and round. Capability: Fires one aimed pistol round at a time, flat on his floor or down at Dave's grounded spot, then racks the slide. Important limitation or opening: Racking the slide is the opening: he is rooted, head down, both hands on the pistol. Keep the low two-hand stance and both hands visible so the muzzle height reads. Do not add a laser sight (sight lines belong to the rail rifle and the cutter beam only), a helmet, a shield or a second gun. Tell: GLOW on the pistol's muzzle lamp (part of the gun, added by the engine), amber first and then red for the last 0.25 s with a lock click. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Paint it after the Night Guard, since the two share the Arcadia grey livery and the normal-map treatment.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The holster, vest patch and earpiece cable must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Night Guard (cap and long baton), the Riot Officer (helmet and shield) and the Rifleman (helmet and carbine). The Sidearm Guard reads by the bare head, the vest collar and the extended two-hand pose. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (pistol idle, walk and retreating run, two-hand aim, hit flinch) for the side view (C38). Check that the pistol sits at about 0.5 H in the fire pose, and that the ledge aim reaches both the down and the up angle without a gap at the shoulder.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

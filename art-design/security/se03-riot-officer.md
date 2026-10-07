# Riot Officer

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** SE03\
**Category:** security (Arcadia Security, humans)\
**First appearance:** Level 3 (appears in L3–L6)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed. This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Armored melee enemy with a front shield. The wall the Response Team fires past.

*Proposed identity:* a riot officer of Arcadia's Response Team, trained for crowd control and deployed with the [Peacekeeper](../mini-bosses/b01-the-peacekeeper.md) truck at the Level 3 product showcase. He is human, not Linked. When the PA calls Harlan armed, crowd control becomes a moving barricade: he keeps the shield up, keeps his voice flat and loud, and screens the Riflemen behind him, since enemy rounds pass through their own side. He appears in Levels 3–6.

Combat is lethal (C28). The shield is the armor, not the man: he bleeds and stays down like everyone else (C29).

## Scale and silhouette

About 1.86 m tall with the helmet, roughly 7.25 heads, and the broadest human build in the roster. The ballistic shield is about 1.30 m tall and 0.65 m across.

A heavily armored figure in a rounded helmet with a neck guard, with shoulder caps, a chest plate, forearm guards and thigh and shin guards, holding a tall curved shield slab out in front and a short shock maul low in the near hand. The head and shoulders show above the shield's top edge. In grayscale he is the widest shape in the roster, dominated by the vertical shield slab and the helmet dome, which sets him apart from the Rifleman (helmet and carbine) and the Heavy Gunner (drum pack).

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* Dark Arcadia grey riot armor over a black under-suit: a rounded helmet with a neck guard and a clear polymer visor pushed up, layered shoulder caps, a chest plate, forearm guards, thigh and shin guards and black boots, all scuffed at the edges and worn as armor, not fused to the body. The white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) is stenciled on the near shoulder cap and large on the shield face. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars.

The ballistic shield is a tall curved slab about 0.14 m thick, built from layered dark grey polymer plates, with a narrow horizontal viewport slit filled with pale polymer, a ribbed grip block, a forearm strap and a narrow lamp strip set into the top edge, painted dark grey and unlit. The shield is held by the far hand and stands clear of the body, so it is its own part. It is painted with a slight three-quarter turn (about 25 degrees toward the camera) so that its face, slit and emblem read at gameplay size; it is the one deliberate exception to strict side view. The shock maul is a stubby black club about 0.85 m long with a fat rubberized head ringed by steel contact studs, held low in the near hand and clear of the thigh. Under the visor the face is square-jawed and drawn tight, with hard eyes wet with sweat. He has no implant.

## Color and materials

*Proposed palette:* skin #E4BDA0; dark riot armor #414A56 with worn edges #7C8896; black under-suit and boots #23272E; helmet #3C4550; clear visor polymer #A9B8C6; shield plates #464F5B with pale viewport #B4C3D0; graphite grip and strap #2C323A; maul head #23272E with steel studs #8FA0B3; emblem white #E9EDF0.

**Tokens.** The tell is Hazard amber #FFB02E, then Alarm red #FF3B4E for the last 0.25 s, as a large additive glow on the shield's top lamp strip, added by the engine. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, never painted in, and it never glows or uses a tell color. He shows no amber point and no teal light, because he is not Linked.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the tell also reads by pose (the crouch and the planted shield) and by the shouted bark.

## Abilities and movement

- **Template:** Brawler + front armor (C26): the shield face is an armored zone that blocks Dave's bolts while it is up. A Rifleman's rounds pass through him.
- **Weapon:** ballistic shield + shock maul (melee).
- **Tell:** GLOW: he plants the shield and its top strobe strip goes amber, then red for the last 0.25 s ("Drop the gun!").
- **Attack:** one one-step shield bash.
- **Counter:** bait the bash and shoot him while the shield is down after it, or jump-shoot over the shield, or flank him (4 hits).

Advances in short planted steps behind the shield, the maul hand pressed against its back. For the windup he drops into a crouch and plants the shield's bottom edge on the floor like a wall while the strip lamp warms. The bash is one step and a heave: the shield leads, and the shoulder drives behind it.

Afterward the shield drops low and tilts forward, the arm overextended and the head and chest showing above it, his weight forward as he recovers. The shield is down, and that is the opening. He can also be flanked, since the shield covers only his front.

**Sample barks** *(proposed; shouted crowd-control orders, with profanity where the line breaks. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Drop the gun!" (the windup)
- "Shields up! Shields up!" (the advance)
- "Push him back! Push the fuck back!" (the bash)
- "Stay behind me! Rifles, stay behind me!" (to the Riflemen)
- "Get off me, get the fuck off—" (flanked)

Death is a heavy exhale and the shield clanging down, with no last words.

## Openings and limitations

The lowered shield after the bash is the opening. A jump over the shield or a flank shows the head and shoulders, since the armored zone is only the shield's face. Do not turn the plates into extra arms or a full exoskeleton, and do not give him a gun: the guns belong to the Riflemen he screens.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head; helmet (its own part) with the visor as a separate flip piece; torso with the chest plate; pelvis; near and far upper arms with shoulder caps, lower arms with forearm guards and hands (the near hand is the separate weapon hand holding the maul); near and far upper legs with thigh guards, lower legs with shin guards and feet. The shield is its own large part, and the maul is its own sprite.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the visor at the helmet brow. The shield has two pivots: one at the grip block, which tilts it forward into the lowered state, and one at its bottom edge, for the planted state. Paint hidden overlap under every joint, and paint the far limbs and the body behind the shield complete.

**Sockets:** the weapon-hand socket at the near palm holds the maul; the off-hand socket at the far palm holds the shield's grip block. A lamp marker at the shield's top strip anchors the tell glow (GLOW). He has no gun socket. The shield has four states: raised guard, planted, bash and lowered.

**Normal maps:** one per part (green = up), soft-edged: the shield's layered plates, bulged center and edge ribs, the helmet dome and neck guard, the armor plate edges and straps, cloth folds at the joints and gentle face modeling. The shield face is the armored zone; the front-armor toggle is set in the enemy's data, not in the art.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. Blood anchors sit on the head, chest, belly, near upper arm and near thigh; a bolt stopped by the shield draws no blood. No implant sparks.

**Motion and death:** hand-keyed on the rig for the side view (C38): a walk with the shield arm held forward, a crouch, a shoulder-charge bash and a hit stagger, plus the planted-shield windup and the lowered-shield recovery. Death is a ragdoll pushed by the killing shot, and the shield falls away as a prop. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Guarded advance (shield raised); idle guard; windup (crouch, shield planted); attack (the one-step bash); recovery with the shield down (the opening); hit stagger; death launch (first ragdoll frame); resting corpse pose; the weapon hands (maul grip, shield grip).

Tell by pose: the crouch and the planted shield are the windup, and the engine adds the amber-then-red glow on the shield's top strip. The lowered shield after the bash must show the head and chest clearly above its edge. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), exactly two arms and two legs. The plates are worn armor and must not become extra hands, arms or faces. One shield, one maul. No gun, no implant, no police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The shield stays on the far hand and the maul on the near hand, the emblem is a plain shape without lettering, and every armor piece is safe to mirror. The shield is a separate part, so the rig can swap its socket if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Riot Officer, an Arcadia Security human enemy: a riot officer with a ballistic shield and a shock maul. Role: Armored melee enemy with a front shield. The wall the Response Team fires past.
Scale: About 1.86 m tall with the helmet, roughly 7.25 heads, and the broadest human build in the roster. The ballistic shield is about 1.30 m tall and 0.65 m across.
Silhouette: A heavily armored figure in a rounded helmet with a neck guard, with shoulder caps, a chest plate, forearm guards and thigh and shin guards, holding a tall curved shield slab out in front and a short shock maul low in the near hand. The head and shoulders show above the shield's top edge. In grayscale he is the widest shape in the roster, dominated by the vertical shield slab and the helmet dome, which sets him apart from the Rifleman (helmet and carbine) and the Heavy Gunner (drum pack).
Physical design: Dark Arcadia grey riot armor over a black under-suit: a rounded helmet with a neck guard and a clear polymer visor pushed up, layered shoulder caps, a chest plate, forearm guards, thigh and shin guards and black boots, all scuffed at the edges and worn as armor, not fused to the body. The white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) is stenciled on the near shoulder cap and large on the shield face. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars. The ballistic shield is a tall curved slab about 0.14 m thick, built from layered dark grey polymer plates, with a narrow horizontal viewport slit filled with pale polymer, a ribbed grip block, a forearm strap and a narrow lamp strip set into the top edge, painted dark grey and unlit. The shield is held by the far hand and stands clear of the body, so it is its own part. It is painted with a slight three-quarter turn (about 25 degrees toward the camera) so that its face, slit and emblem read at gameplay size; it is the one deliberate exception to strict side view. The shock maul is a stubby black club about 0.85 m long with a fat rubberized head ringed by steel contact studs, held low in the near hand and clear of the thigh. Under the visor the face is square-jawed and drawn tight, with hard eyes wet with sweat. He has no implant.
Materials and colors: skin #E4BDA0; dark riot armor #414A56 with worn edges #7C8896; black under-suit and boots #23272E; helmet #3C4550; clear visor polymer #A9B8C6; shield plates #464F5B with pale viewport #B4C3D0; graphite grip and strap #2C323A; maul head #23272E with steel studs #8FA0B3; emblem white #E9EDF0. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the shield's top lamp strip. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), exactly two arms and two legs. The plates are worn armor and must not become extra hands, arms or faces. One shield, one maul. No gun, no implant, no police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright and braced with the shield held low in front on the far hand and the maul hanging in the near hand, both clear of the legs, the visor pushed up; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Riot Officer design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.86 m tall with the helmet, roughly 7.25 heads, and the broadest human build in the roster. The ballistic shield is about 1.30 m tall and 0.65 m across. Maintain these defining forms: A heavily armored figure in a rounded helmet with a neck guard, with shoulder caps, a chest plate, forearm guards and thigh and shin guards, holding a tall curved shield slab out in front and a short shock maul low in the near hand. The head and shoulders show above the shield's top edge. In grayscale he is the widest shape in the roster, dominated by the vertical shield slab and the helmet dome, which sets him apart from the Rifleman (helmet and carbine) and the Heavy Gunner (drum pack). Preserve construction: Dark Arcadia grey riot armor over a black under-suit: a rounded helmet with a neck guard and a clear polymer visor pushed up, layered shoulder caps, a chest plate, forearm guards, thigh and shin guards and black boots, all scuffed at the edges and worn as armor, not fused to the body. The white Arcadia emblem (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately) is stenciled on the near shoulder cap and large on the shield face. There are no police marks: no star or shield badge, no lettering, no checker bands and no blue or red light bars. The ballistic shield is a tall curved slab about 0.14 m thick, built from layered dark grey polymer plates, with a narrow horizontal viewport slit filled with pale polymer, a ribbed grip block, a forearm strap and a narrow lamp strip set into the top edge, painted dark grey and unlit. The shield is held by the far hand and stands clear of the body, so it is its own part. It is painted with a slight three-quarter turn (about 25 degrees toward the camera) so that its face, slit and emblem read at gameplay size; it is the one deliberate exception to strict side view. The shock maul is a stubby black club about 0.85 m long with a fat rubberized head ringed by steel contact studs, held low in the near hand and clear of the thigh. Under the visor the face is square-jawed and drawn tight, with hard eyes wet with sweat. He has no implant. Preserve the palette: skin #E4BDA0; dark riot armor #414A56 with worn edges #7C8896; black under-suit and boots #23272E; helmet #3C4550; clear visor polymer #A9B8C6; shield plates #464F5B with pale viewport #B4C3D0; graphite grip and strap #2C323A; maul head #23272E with steel studs #8FA0B3; emblem white #E9EDF0. Tell colors, added by the engine and never painted: Hazard amber #FFB02E, then Alarm red #FF3B4E, on the shield's top lamp strip. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), exactly two arms and two legs. The plates are worn armor and must not become extra hands, arms or faces. One shield, one maul. No gun, no implant, no police marks, readable text or logos, no teal or violet. No blood, wound, glow or shadow painted into the parts. No dismemberment and no exposed organs. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Riot Officer reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Guarded advance (shield raised); idle guard; windup (crouch, shield planted); attack (the one-step bash); recovery with the shield down (the opening); hit stagger; death launch (first ragdoll frame); resting corpse pose; the weapon hands (maul grip, shield grip). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Movement language: Advances in short planted steps behind the shield, the maul hand pressed against its back. For the windup he drops into a crouch and plants the shield's bottom edge on the floor like a wall while the strip lamp warms. The bash is one step and a heave: the shield leads, and the shoulder drives behind it. Afterward the shield drops low and tilts forward, the arm overextended and the head and chest showing above it, his weight forward as he recovers. The shield is down, and that is the opening. He can also be flanked, since the shield covers only his front. Capability: Blocks Dave's bolts with the shield and delivers one shield bash; he screens the Riflemen behind him. Important limitation or opening: The lowered shield after the bash is the opening. A jump over the shield or a flank shows the head and shoulders, since the armored zone is only the shield's face. Do not turn the plates into extra arms or a full exoskeleton, and do not give him a gun: the guns belong to the Riflemen he screens. Tell: GLOW on the shield's top lamp strip, amber first and then red for the last 0.25 s, added by the engine; paint the strip dark. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The shield and the maul must read correctly flipped, and the shield's three-quarter turn must hold up mirrored.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Rifleman (helmet and carbine), the Heavy Gunner (drum pack) and the Night Guard (cap and baton). The Riot Officer reads by the shield slab and the helmet dome. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (shield walk, crouch, shoulder-charge bash, hit stagger) for the side view (C38). Check that the shield-down pose clearly exposes the head and chest, and that the raised shield reads as a wall from the side.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

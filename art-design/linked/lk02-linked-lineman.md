# Linked Lineman

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** LK02\
**Category:** linked (people driven by Adam through the Link)\
**First appearance:** Level 6 (appears in L6–L7)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed, and so is the enemy gun kit (C27). This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Stationary arc-rod enemy that sends a crackling current along the floor. He teaches the ground arc that Howard Stroud uses in the Level 6 fight.

*Proposed identity:* a Rootworks electrician on Arcadia's power-grid crew, Linked in the wellness pilot. Adam has wired him to a back capacitor pack, with cables sutured into both forearms, and put the "Groundline" arc rod ([EG06](../enemy-guns/eg06-arc-caster.md)) in his hands: Rootworks power hardware that Adam turns on people. He holds a floor and drives the rod into it. The horror is neat and quiet: the cables are stitched in like a professional job, and he keeps working.

He appears in Levels 6–7. His arc is the lesson before [Howard Stroud](../mini-bosses/b02-howard-stroud.md), who uses the same weapon. Combat is lethal (C28): he bleeds red and sparks at the implant (C29), and most Linked deaths are silent. He never blocks progress.

## Scale and silhouette

About 1.82 m tall, roughly 7.25 heads, broad-shouldered and slightly hunched.

A broad, slightly hunched electrician in a pale hard hat, with a boxy capacitor pack standing up on his back behind the shoulders, thick cables looping from the pack down to both forearms, and broad insulated gloves. In grayscale he reads by the hard-hat dome and the square pack. He has no helmet, no coat and no drum, and his round hat and square back set him apart from the other Linked.

In play he holds a long insulated rod low in both hands, ready to ram it into the floor.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* A charcoal insulated coverall with silver reflective stripes, a pale shirt collar at the throat, a chest tool harness, broad slate rubber gloves and heavy boots. A lanyard holds a blank ID card. A tilted pale hard hat carries a small lamp, painted dark, and has one notch missing from its brim.

A boxy gunmetal capacitor pack sits high on the back in a harness, with a ceramic-capped terminal on top and a dark glow window on its side, painted unlit. Two thick graphite-jacketed cables loop from the pack to the forearms and enter the skin at neat rows of dark sutures on the outer forearms, each ringed by a faint dusky bruise; the skin is closed, with no blood painted in. The pack also has a plug socket on its side, where the rod's own short cable bundle seats (the bundle belongs to the rod's sprite). The face is broad and vacant, half in the shadow of the hat.

The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). The scalp is close-shaved, and the hat's rear edge sits above the port so that it stays visible. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. The rig is fitted at clean cuffs, straps and sutures. There are no logos or legible text.

## Color and materials

*Proposed palette:* skin #B08464; charcoal coverall #363F4D; silver reflective stripes #C3CDD6; pale hard hat #CBD4DC; slate gloves #46546A; gunmetal capacitor pack #5A6B80 with ceramic terminal #D3DAE0; graphite cable jackets #2A3341; suture thread #1A1F27; bruise rings #7A4A45; under-skin neck lines #4A4F63; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8.

**Tokens.** When Adam drives the body, the engine adds a small, dim, steady amber point (Hazard amber #FFB02E) at the port; it is not the tell. The tell is a CHARGE: a large additive glow that grows on the capacitor pack, amber first and then Alarm red #FF3B4E for the last 0.25 s, with a buzz. The arc itself belongs to the rod (EG06): a jagged blue-white line with a white core and an energy-blue edge, never amber or red. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, and never painted in. A hit also throws small white sparks (#F2F7FB) at the implant, and the port light goes dark on death. Blood never glows and never uses a tell color.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the light states differ by size and pattern (a small steady point for driven, a large glow for the tell), and the tell also reads by pose (the rod raised, then rammed) and by the rising buzz.

## Abilities and movement

- **Template:** Gunner (stationary, floor shot) (C26).
- **Weapon:** Arc Caster, the "Groundline" rod ([EG06](../enemy-guns/eg06-arc-caster.md)), a futuristic gun.
- **Tell:** CHARGE: the capacitor pack's glow grows amber, then red for the last 0.25 s, with a buzz; then he rams the rod into the deck.
- **Attack:** a crackling arc 0.4 H tall crawls along the floor at 5 H/s, dying at a ledge, a wall or 6.5 H: 1 damage. Then a 1.4 s recharge.
- **Counter:** jump the arc (it crosses Dave in about 0.2 s) or stand on another platform, since it cannot leave its floor; then hit him while the rod recharges (3 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Shuffles heavily in a stiff, puppet-like gait, stopping now and then to tighten a clamp that is already tight (flavor only). To attack he plants both feet with the rod low, and the capacitor pack buzzes and glows. Then he drives the rod into the floor like a stake, suddenly fast, and the arc runs out along the floor.

During the recharge he pulls the rod free and stands hunched with the cables slack: that is the opening. He never blinks.

**Sample barks** *(proposed; Adam's calm words in the Lineman's own worn voice. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Please stand clear of the panel." (the windup)
- "Grounding the line, Dr. Harlan." (the ram)
- "Please don't touch the cables." (idle)

Most deaths are silent: a fall, sparks at the port and the pack, and the light going out. Rarely he says something confused, such as "...is the power off?"

## Openings and limitations

The recharge is the opening: hunched, the rod out of the floor, the cables slack. Do not add a gun barrel, a glowing chest core or armor plates. The pack, the cables and the rod are a person's work gear, not separate targets.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head; hard hat (its own part, with the lamp); the port (a small separate head part); torso with the coverall and tool harness; capacitor pack (its own part on the back, with a ceramic terminal); pelvis; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand; the far hand is the support hand); near and far upper legs, lower legs and feet. Two forearm cables are small flexing pieces from the pack to the sutures, and the lanyard is a small swinging piece. The rod is a separate sprite (EG06) with its own short cable bundle ending in a plug.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the hard hat at the crown; the pack at its harness; the cables at the pack and at the forearms; the lanyard at the collar. Paint hidden overlap under every joint, and paint the far limbs and the torso behind the pack complete.

**Sockets:** the gun socket at the near palm holds the rod's rear grip; a support socket at the far palm meets its forward grip. The muzzle marker, where the arc starts, belongs to the rod sprite (EG06). A pack-glow socket on the capacitor pack holds the large tell glow, a plug socket on the pack takes the rod's cable, and a port-light socket holds the small steady amber point (dark on death). A spark socket at the port and one at the pack terminal throw white sparks.

**Normal maps:** one per part (green = up), soft-edged: coverall seams and stripes, the hard-hat brim and its notch, glove pads, the pack's ribs and terminal, cable jackets and sutures, and gentle face modeling.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. The Linked also throw white implant sparks at the port. Blood anchors sit on the head, chest, belly, near upper arm and near thigh.

**Motion and death:** Mixamo clips converted to the rig: a heavy stiff walk, a two-hand downward ram and a hit flinch. Hand-key the plant and the recharge stoop where no clip fits. Death is a ragdoll pushed by the killing shot, the rod drops as a prop (never a pickup), and the port light goes dark. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Walk (heavy, stiff); idle (tightening a clamp); windup (feet planted, rod low, pack buzzing); attack (the ram into the floor); recharge stoop (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, two-hand rod grip, rammed grip).

Tell by pose: planting the feet with the rod low is the windup, and the engine adds the large amber-then-red glow on the capacitor pack over that pose. The small steady amber point at the port is separate and present through every driven pose. Paint the hands in their grip shapes around empty space. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one hard hat, one capacitor pack, two forearm cables. The rod is never painted into the art. No gun barrel, no armor plates, no glowing chest core, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. Eyes half open and unblinking, with no glow. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant and the sutured cables are medical and electrical work, never drawn as monstrous in themselves.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The hard-hat notch, the forearm sutures and the lanyard sit on the near side and are safe to mirror. The port is a small separate head part, a round disc with no handedness, so it sits behind the near ear in either facing. The capacitor pack sits on the centerline of the back.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Linked Lineman, a Linked person: a Rootworks electrician driven by Adam, wired to a back capacitor pack with cables sutured into his forearms. Role: Stationary arc-rod enemy that sends a crackling current along the floor. He teaches the ground arc that Howard Stroud uses in the Level 6 fight.
Scale: About 1.82 m tall, roughly 7.25 heads, broad-shouldered and slightly hunched.
Silhouette: A broad, slightly hunched electrician in a pale hard hat, with a boxy capacitor pack standing up on his back behind the shoulders, thick cables looping from the pack down to both forearms, and broad insulated gloves. In grayscale he reads by the hard-hat dome and the square pack. He has no helmet, no coat and no drum, and his round hat and square back set him apart from the other Linked.
Physical design: A charcoal insulated coverall with silver reflective stripes, a pale shirt collar at the throat, a chest tool harness, broad slate rubber gloves and heavy boots. A lanyard holds a blank ID card. A tilted pale hard hat carries a small lamp, painted dark, and has one notch missing from its brim. A boxy gunmetal capacitor pack sits high on the back in a harness, with a ceramic-capped terminal on top and a dark glow window on its side, painted unlit. Two thick graphite-jacketed cables loop from the pack to the forearms and enter the skin at neat rows of dark sutures on the outer forearms, each ringed by a faint dusky bruise; the skin is closed, with no blood painted in. The pack also has a plug socket on its side, where the rod's own short cable bundle seats (the bundle belongs to the rod's sprite). The face is broad and vacant, half in the shadow of the hat. The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). The scalp is close-shaved, and the hat's rear edge sits above the port so that it stays visible. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. The rig is fitted at clean cuffs, straps and sutures. There are no logos or legible text.
Materials and colors: skin #B08464; charcoal coverall #363F4D; silver reflective stripes #C3CDD6; pale hard hat #CBD4DC; slate gloves #46546A; gunmetal capacitor pack #5A6B80 with ceramic terminal #D3DAE0; graphite cable jackets #2A3341; suture thread #1A1F27; bruise rings #7A4A45; under-skin neck lines #4A4F63; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, and a large amber then Alarm red #FF3B4E glow on the capacitor pack as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one hard hat, one capacitor pack, two forearm cables. The rod is never painted into the art. No gun barrel, no armor plates, no glowing chest core, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. Eyes half open and unblinking, with no glow. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant and the sutured cables are medical and electrical work, never drawn as monstrous in themselves.
Use a relaxed neutral pose that reveals the silhouette and joint structure: hunched and heavy with a vacant expression, the hands empty and slightly curled, the cables hanging slack; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Linked Lineman design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.82 m tall, roughly 7.25 heads, broad-shouldered and slightly hunched. Maintain these defining forms: A broad, slightly hunched electrician in a pale hard hat, with a boxy capacitor pack standing up on his back behind the shoulders, thick cables looping from the pack down to both forearms, and broad insulated gloves. In grayscale he reads by the hard-hat dome and the square pack. He has no helmet, no coat and no drum, and his round hat and square back set him apart from the other Linked. Preserve construction: A charcoal insulated coverall with silver reflective stripes, a pale shirt collar at the throat, a chest tool harness, broad slate rubber gloves and heavy boots. A lanyard holds a blank ID card. A tilted pale hard hat carries a small lamp, painted dark, and has one notch missing from its brim. A boxy gunmetal capacitor pack sits high on the back in a harness, with a ceramic-capped terminal on top and a dark glow window on its side, painted unlit. Two thick graphite-jacketed cables loop from the pack to the forearms and enter the skin at neat rows of dark sutures on the outer forearms, each ringed by a faint dusky bruise; the skin is closed, with no blood painted in. The pack also has a plug socket on its side, where the rod's own short cable bundle seats (the bundle belongs to the rod's sprite). The face is broad and vacant, half in the shadow of the hat. The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). The scalp is close-shaved, and the hat's rear edge sits above the port so that it stays visible. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. The rig is fitted at clean cuffs, straps and sutures. There are no logos or legible text. Preserve the palette: skin #B08464; charcoal coverall #363F4D; silver reflective stripes #C3CDD6; pale hard hat #CBD4DC; slate gloves #46546A; gunmetal capacitor pack #5A6B80 with ceramic terminal #D3DAE0; graphite cable jackets #2A3341; suture thread #1A1F27; bruise rings #7A4A45; under-skin neck lines #4A4F63; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, and a large amber then Alarm red #FF3B4E glow on the capacitor pack as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one hard hat, one capacitor pack, two forearm cables. The rod is never painted into the art. No gun barrel, no armor plates, no glowing chest core, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. Eyes half open and unblinking, with no glow. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant and the sutured cables are medical and electrical work, never drawn as monstrous in themselves. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Linked Lineman reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Walk (heavy, stiff); idle (tightening a clamp); windup (feet planted, rod low, pack buzzing); attack (the ram into the floor); recharge stoop (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, two-hand rod grip, rammed grip). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their rod-grip shapes around empty space; the rod is a separate sprite and is never painted in. Movement language: Shuffles heavily in a stiff, puppet-like gait, stopping now and then to tighten a clamp that is already tight (flavor only). To attack he plants both feet with the rod low, and the capacitor pack buzzes and glows. Then he drives the rod into the floor like a stake, suddenly fast, and the arc runs out along the floor. During the recharge he pulls the rod free and stands hunched with the cables slack: that is the opening. He never blinks. Capability: Rams an arc rod into the floor and sends a low crackling arc along it, then recharges, hunched and open. Important limitation or opening: The recharge is the opening: hunched, the rod out of the floor, the cables slack. Do not add a gun barrel, a glowing chest core or armor plates. The pack, the cables and the rod are a person's work gear, not separate targets. Tell: CHARGE: a glow that grows on the capacitor pack, amber first and then red for the last 0.25 s, added by the engine; paint the pack's glow window dark. The small amber point at the port is separate. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Paint it after the Staffer, so the two Linked share the port and the stapled-seam treatment.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The hard-hat notch, the forearm sutures and the lanyard must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Staffer (bare head and slouch), the Linked Nurse (scrub cap and tray) and the Riot Officer (helmet and shield). The Lineman reads by the hard-hat dome and the square capacitor pack. The tell must read by pose and glow with the night overlay on.
- Convert the Mixamo clips (heavy stiff walk, two-hand downward ram, hit flinch) to the rig and hand-key the tell pose where no clip fits. Check that the pack and cables flex as their own parts without hiding the shoulder pivots.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

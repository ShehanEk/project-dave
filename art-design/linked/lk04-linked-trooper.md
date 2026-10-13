# Linked Trooper

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** LK04\
**Category:** linked (people driven by Adam through the Link) (captured Thornwall contractors)\
**First appearance:** Level 8 (appears in L8–L10)\
**Design status:** Look follows C60 (approved 2026-10-12): painted HD parts on the lit cutout rig (C56), corporate cyberpunk (C58), alert and composed (C57), electric-blue trim for the Linked (C60). Concept images are still to be generated. The roster entry (C31), human enemies (C25) and the enemy gun kit (C27) are confirmed, and the lit cutout method is confirmed (C35). Behavior numbers (P23) are *proposed*. Dimensions are provisional art proportions, not engine specifications.

**Look updates:** C57 (2026-10-11): no sleepy or zombie-like look; the Link shows as technology (port light, electric-blue eye glint, synchronized precise moves). C60 (2026-10-12): the port is a clean ring-lit disc with no staples, bruise ring, seam or sutures; implants and cables are clean technology; electric blue #4D8DFF is the neon color of every Linked type.

## Identity and role

Slow plasma gunner: a captured Thornwall contractor whom Adam arms with its own weapon.

*Proposed identity:* a Thornwall contractor whom Adam caught and Linked after the board ordered "sanitize". Adam arms its captives with its own weapon, the "Lumen" plasma carbine ([EG07](../enemy-guns/eg07-plasma-gun.md)), and walks them in front of its other machines. The Trooper raises the carbine without hesitation: a soldier who still moves like one, alert and exact, with a slim blue Link visor band across steady, wide-open eyes. The unsettling part is what Adam did, not the hardware. Its Thornwall body is the shared body of the [Rifleman](../security/se04-rifleman.md).

**Three looks on one rig** (C56, C60), all Caucasian (C43): **A, the veteran** (in his forties, cropped dark hair, stubble, a level, composed face); **B, the young contractor** (in his twenties, close-cropped fair hair, clean-shaven, a precise, alert face); **C, the woman contractor** (in her thirties, dark hair in a tight bun at the back of the head, a calm, focused face). The game picks a look by entity id; stats, tells and timing are the same.

It appears in Levels 8–10; the Heirs later carry the same weapon. Combat is lethal (C28): it bleeds red and sparks at the implant (C29), and most Linked deaths are silent. It never blocks progress.

## Scale and silhouette

About 1.80 m tall, roughly 7.25 heads: the shared Thornwall body.

The Rifleman's body without the helmet: a bare-headed, upright soldier in a plate carrier, with a slim visor band across the eyes, standing at ready. In grayscale he reads by the bare head with the thin visor band and by the carrier. He has no helmet, no drum, no coat and no hood.

In play he holds a pearl-white carbine steady in front of him, its fat glass chamber a bulge ahead of the hand.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design (C60).* Thornwall's kit, taken over by Adam: the charcoal combat shirt and trousers, the matte charcoal plate carrier with dark slate webbing and thin electric-blue piping (#4D8DFF) along the shoulder straps, the color of the Linked now that Adam controls him (the chest pouches hang open and empty, since the plasma carbine needs no magazines), graphite knee pads, black boots and dark gloves. The Thornwall sleeve patch has been unpicked, leaving a clean pale rectangle where the thorn glyph was. The helmet is gone, and its chinstrap hangs from the belt. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks.

The Link signature: behind the near ear sits the Link port, a clean coin-sized disc with a pale steel rim and a thin ring light, set flush in the skin. There are no staples, bruise rings, seams or lines under the skin. The head is bare, with hair by look, and a slim electric-blue Link visor band (#4D8DFF, the Linked neon) is worn across the eyes on a thin strap round the head; it is translucent glass, and the open, alert eyes read through it. The engine makes the band glow steadily while Adam drives the body and darkens it on death; it stands in for the iris glint. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are wide open and alert and are painted without glow. The port is clean technology, never a monster feature, and nothing is exposed. The gaze is steady and level, and the face is set in a calm, composed look. The weapon hand is bare inside a dark glove and empty: the "Lumen" carbine is a separate sprite. There are no logos or legible text.

## Color and materials

*Proposed palette:* charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058 and electric-blue piping #4D8DFF; graphite pads #34373B; black boots and gloves #1E2023; cut-patch rectangle #5A5B56; skin #D2A585; visor band #4D8DFF over dark glass #1B2430; port disc #2E3B4E with pale steel rim #9AA5B1; hair by look: A dark #2B2623, B fair #C9B28A, C dark brown #3A2B22.

**Tokens.** When Adam drives the body, the engine adds a small, dim, steady amber point (Hazard amber #FFB02E) at the port; it is not the tell. The visor band glows a steady electric blue (#4D8DFF) in place of an iris glint; that is not the tell either, and it goes dark on death. The tell is a CHARGE: a glow that grows on the carbine's emitter ring, Hazard amber #FFB02E first and then Alarm red #FF3B4E for the last 0.25 s, with a deep hum. The ring belongs to the gun asset (EG07), so the body carries no tell glow. The plasma bolt is a white core with an energy-blue edge and a dark ring, never amber or red. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, and never painted in. A hit also throws small white sparks (#F2F7FB) at the implant, and the port light goes dark on death. Blood never glows and never uses a tell color. **Neon (C60):** electric blue #4D8DFF marks the Linked, the people Adam drives. It is steady, thinner and dimmer than any tell, never on the attacking part or a weak point, and it goes dark when the body dies.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the light states differ by size and pattern (a small steady point for driven, a growing glow on the emitter ring for the tell), and the tell also reads by pose (the carbine raised and locked) and by the hum.

## Abilities and movement

- **Template:** Gunner (C26).
- **Weapon:** Plasma Gun, Adam's "Lumen" carbine ([EG07](../enemy-guns/eg07-plasma-gun.md)).
- **Tell:** CHARGE: the carbine's emitter ring glows amber, then red for the last 0.25 s, while the plasma ball swells in the chamber and a deep hum rises.
- **Attack:** one slow plasma bolt (0.5 H across, at 3.5 H/s, flat at 0.5 H) that bursts on impact in a 1.0 H radius (a direct hit deals 2 damage, the burst 1), then a 1.4 s vent.
- **Counter:** jump the bolt, keep 1 H clear of the wall it hits, then punish the vent (4 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

Moves like a soldier drilled for years, but too precisely: the head, shoulders and feet turn together in one clean motion, and every step lands exactly on the beat. It raises the carbine without hesitation, the arms locking straight out at belt height so that the bolt leaves at about 0.5 H, and holds perfectly still while the plasma ball swells.

After the shot it lowers the weapon and stands, venting: that is the opening. Its eyes stay on Dave.

**Sample barks** *(proposed; Adam's calm words in the contractor's own rough voice. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Put it down, Dave. It will be easier." (the raise)
- "You can stop running, Dave." (idle)
- "Stand still. This will be quick." (the charge)

Most deaths are silent: a fall, sparks at the port, and the light going out. Rarely he says his own name, startled, such as "...Danny?"

## Openings and limitations

The vent after the shot is the opening: the weapon lowered, the body still, the emitter ring dark. Do not add a helmet, armor plates, a drum or a second gun, and do not turn the visor band or the port into a glowing weak point: the band is trim, and the port carries only the small steady amber point.

## Rig parts, normal maps and sockets

**Looks (C56):** the three looks share one part list, skeleton, pivots, clips and hit zones; the head and hair differ. **Parts** *(painted once per look, facing right; near means the side toward the camera)*: the shared Thornwall body parts: head with the visor band; the port (its own small part, with its ring light); torso with the plate carrier (the empty pouches are small swinging pieces); pelvis with the belt and the hanging chinstrap; near and far upper arms, lower arms and hands (the near hand is the separate weapon hand; the far hand is the support hand); near and far upper legs, lower legs and feet, with knee pads. The "Lumen" carbine is a separate sprite (EG07).

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the chinstrap at the belt. The whole arm aims from the shoulder. Paint hidden overlap under every joint, and paint the far limbs complete.

**Sockets:** the gun socket at the near palm holds the carbine's rear grip; a support socket at the far palm meets its forward grip. The muzzle marker, the emitter-ring glow, the chamber ball and the muzzle light belong to the gun sprite (EG07). A port-light socket on the port holds the small steady amber point (dark on death), and a spark socket at the port throws the white sparks.

**Normal maps:** one per part (green = up), soft-edged: plate-carrier edges and webbing, the open pouch flaps, knee pads, the visor band's rim, the port's rim and ring light, and gentle face modeling with wide eyes.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. The Linked also throw white implant sparks at the port. Blood anchors sit on the head, chest, belly, near upper arm and near thigh.

**Motion and death:** hand-keyed on the rig for the side view (C38): a rifle idle held perfectly still, a rifle walk, a locked-arm aim and a hit flinch, plus the raise and the vent. Death is a ragdoll pushed by the killing shot, the carbine drops as a prop (never a pickup), and the port light goes dark. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle (standing perfectly still); walk; windup (raise the carbine, arms locked at belt height); attack (the shot); vent (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, carbine rear grip, support hand on the forward grip).

Tell by pose: raising the carbine with the arms locked is the windup, and the growing amber-then-red glow on the emitter ring belongs to the gun and is added by the engine. The small steady amber point at the port is separate and present through every driven pose. Paint the hands in their grip shapes around empty space. The resting corpse pose is the one authored pose restored after a death or Continue.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one visor band. The carbine is never painted into the art. No helmet, drum, coat, hood or second gun. No exposed wiring, organs or wounds, no staples, plates through the skull, bruise rings or seams, no Arcadia navy, no teal, no violet, no name tapes and no readable text or logos. Eyes wide open and alert, painted without glow, with no blank stare; no sleepy, slack or vacant faces. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant and the visor band are clean technology, never drawn as monstrous in themselves.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The cut sleeve patch, the hip pouch and the hanging chinstrap sit on the near side and are safe to mirror. The port is a small separate head part, a round disc with no handedness, so it sits behind the near ear in either facing. The port is its own small part, so the rig can swap its side if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Paint a single evenly lit, hand-painted, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: soft painted shading for form and folds, clean dark outlines (heavier outer contours, restrained interior lines), no baked cast shadows, no cel-shadow shapes, no rim light, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Linked Trooper, a Linked person: a captured Thornwall contractor driven by Adam, bare-headed with a slim blue Link visor band across the eyes. Role: Slow plasma gunner: a captured Thornwall contractor whom Adam arms with its own weapon.
Scale: About 1.80 m tall, roughly 7.25 heads: the shared Thornwall body.
Silhouette: The Rifleman's body without the helmet: a bare-headed, upright soldier in a plate carrier, with a slim visor band across the eyes, standing at ready. In grayscale he reads by the bare head with the thin visor band and by the carrier. He has no helmet, no drum, no coat and no hood.
Physical design: Thornwall's kit, taken over by Adam: the charcoal combat shirt and trousers, the matte charcoal plate carrier with dark slate webbing and thin electric-blue piping (#4D8DFF) along the shoulder straps, the color of the Linked now that Adam controls him (the chest pouches hang open and empty, since the plasma carbine needs no magazines), graphite knee pads, black boots and dark gloves. The Thornwall sleeve patch has been unpicked, leaving a clean pale rectangle where the thorn glyph was. The helmet is gone, and its chinstrap hangs from the belt. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks. The Link signature: behind the near ear sits the Link port, a clean coin-sized disc with a pale steel rim and a thin ring light, set flush in the skin. There are no staples, bruise rings, seams or lines under the skin. The head is bare, with hair by look, and a slim electric-blue Link visor band (#4D8DFF, the Linked neon) is worn across the eyes on a thin strap round the head; it is translucent glass, and the open, alert eyes read through it. The engine makes the band glow steadily while Adam drives the body and darkens it on death; it stands in for the iris glint. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are wide open and alert and are painted without glow. The port is clean technology, never a monster feature, and nothing is exposed. The gaze is steady and level, and the face is set in a calm, composed look. The weapon hand is bare inside a dark glove and empty: the "Lumen" carbine is a separate sprite. There are no logos or legible text.
Materials and colors: charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058 and electric-blue piping #4D8DFF; graphite pads #34373B; black boots and gloves #1E2023; cut-patch rectangle #5A5B56; skin #D2A585; visor band #4D8DFF over dark glass #1B2430; port disc #2E3B4E with pale steel rim #9AA5B1; hair by look: A dark #2B2623, B fair #C9B28A, C dark brown #3A2B22. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, a steady electric-blue #4D8DFF glow on the visor band while driven, and a growing amber then Alarm red #FF3B4E glow on the carbine's emitter ring as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one visor band. The carbine is never painted into the art. No helmet, drum, coat, hood or second gun. No exposed wiring, organs or wounds, no staples, plates through the skull, bruise rings or seams, no Arcadia navy, no teal, no violet, no name tapes and no readable text or logos. Eyes wide open and alert, painted without glow, with no blank stare; no sleepy, slack or vacant faces. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant and the visor band are clean technology, never drawn as monstrous in themselves.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing perfectly upright at ready with the hands empty and slightly curled, the eyes wide open and looking level ahead, a calm, composed expression; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Linked Trooper design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.80 m tall, roughly 7.25 heads: the shared Thornwall body. Maintain these defining forms: The Rifleman's body without the helmet: a bare-headed, upright soldier in a plate carrier, with a slim visor band across the eyes, standing at ready. In grayscale he reads by the bare head with the thin visor band and by the carrier. He has no helmet, no drum, no coat and no hood. Preserve construction: Thornwall's kit, taken over by Adam: the charcoal combat shirt and trousers, the matte charcoal plate carrier with dark slate webbing and thin electric-blue piping (#4D8DFF) along the shoulder straps, the color of the Linked now that Adam controls him (the chest pouches hang open and empty, since the plasma carbine needs no magazines), graphite knee pads, black boots and dark gloves. The Thornwall sleeve patch has been unpicked, leaving a clean pale rectangle where the thorn glyph was. The helmet is gone, and its chinstrap hangs from the belt. There is no Arcadia navy, no white emblem, no teal, no name tapes and no police marks. The Link signature: behind the near ear sits the Link port, a clean coin-sized disc with a pale steel rim and a thin ring light, set flush in the skin. There are no staples, bruise rings, seams or lines under the skin. The head is bare, with hair by look, and a slim electric-blue Link visor band (#4D8DFF, the Linked neon) is worn across the eyes on a thin strap round the head; it is translucent glass, and the open, alert eyes read through it. The engine makes the band glow steadily while Adam drives the body and darkens it on death; it stands in for the iris glint. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are wide open and alert and are painted without glow. The port is clean technology, never a monster feature, and nothing is exposed. The gaze is steady and level, and the face is set in a calm, composed look. The weapon hand is bare inside a dark glove and empty: the "Lumen" carbine is a separate sprite. There are no logos or legible text. Preserve the palette: charcoal shirt and trousers #3E4043; matte charcoal plate carrier #25272A with dark slate webbing and pouches #4A5058 and electric-blue piping #4D8DFF; graphite pads #34373B; black boots and gloves #1E2023; cut-patch rectangle #5A5B56; skin #D2A585; visor band #4D8DFF over dark glass #1B2430; port disc #2E3B4E with pale steel rim #9AA5B1; hair by look: A dark #2B2623, B fair #C9B28A, C dark brown #3A2B22. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, a steady electric-blue #4D8DFF glow on the visor band while driven, and a growing amber then Alarm red #FF3B4E glow on the carbine's emitter ring as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one visor band. The carbine is never painted into the art. No helmet, drum, coat, hood or second gun. No exposed wiring, organs or wounds, no staples, plates through the skull, bruise rings or seams, no Arcadia navy, no teal, no violet, no name tapes and no readable text or logos. Eyes wide open and alert, painted without glow, with no blank stare; no sleepy, slack or vacant faces. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant and the visor band are clean technology, never drawn as monstrous in themselves. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Linked Trooper reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle (standing perfectly still); walk; windup (raise the carbine, arms locked at belt height); attack (the shot); vent (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the gun hand (relaxed, carbine rear grip, support hand on the forward grip). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. The hands take their carbine-grip shapes around empty space; the carbine is a separate sprite and is never painted in. Movement language: Moves like a soldier drilled for years, but too precisely: the head, shoulders and feet turn together in one clean motion, and every step lands exactly on the beat. It raises the carbine without hesitation, the arms locking straight out at belt height so that the bolt leaves at about 0.5 H, and holds perfectly still while the plasma ball swells. After the shot it lowers the weapon and stands, venting: that is the opening. Its eyes stay on Dave. Capability: Fires one slow plasma bolt that bursts on impact, then vents, standing still. Important limitation or opening: The vent after the shot is the opening: the weapon lowered, the body still, the emitter ring dark. Do not add a helmet, armor plates, a drum or a second gun, and do not turn the visor band or the port into a glowing weak point: the band is trim, and the port carries only the small steady amber point. Tell: CHARGE on the carbine's emitter ring (part of the gun, added by the engine): a glow that grows amber and then red for the last 0.25 s. The small amber point at the plate's port is separate. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Generate the three looks as painted HD parts sheets (C56) with style-frame-v2 attached (layout as in the Night Guard's prompt 4, [SE01](../security/se01-night-guard.md); attach look A when generating B and C). Build on the Rifleman (SE04), the shared Thornwall body. The bare head with its visor band, the cut patch and the open pouches are the changes painted over it. Build on the approved Rifleman (SE04), the shared Thornwall body. The bare head with its visor band, the cut patch and the open pouches are the changes painted over it.
- Split each approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The cut patch, the hip pouch, the chinstrap and the visor band must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Rifleman (helmet and carbine), the Staffer (bare head and everyday build) and the Warden (an Heir with a palm emitter). The Trooper reads by the bare head with its visor band and the perfectly still stance. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (still rifle idle, rifle walk, locked-arm aim, hit flinch) for the side view (C38). Check that the visor band stays a thin readable shape and that the port point reads at gameplay size.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

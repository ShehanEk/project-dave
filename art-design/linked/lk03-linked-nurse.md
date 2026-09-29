# Linked Nurse

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** LK03\
**Category:** linked (people driven by Adam through the Link)\
**First appearance:** Level 7 (appears in L7–L9)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed. This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Arc-throwing Linked enemy: a night nurse who tosses caustic sterilant vials in a spread.

*Proposed identity:* a night nurse at the Arcadia Wellness Center, where staff were fitted with the Link. She was once the person who handed out the wellness perk with a smile. Adam now drives her through a routine "preparation": caustic sterilant vials from the ward, tossed in a spread. Her scrubs carry dried stains from the clinic's night work, drawn as a separate overlay. She is not a gunner and carries no gun. She appears in Levels 7–9.

Combat is lethal (C28): she bleeds red and sparks at the implant (C29), and most Linked deaths are silent. She never blocks progress.

## Scale and silhouette

About 1.66 m tall, roughly 7.25 heads, with a slight build.

A slim woman in a loose scrub tunic and trousers and a pale scrub cap, holding a flat steel instrument tray at hip height in the near hand, so the tray reads as a flat horizontal bar in the silhouette. The far hand hangs empty, thumb and fingers curled to pluck and throw. In grayscale she reads by the slender build, the cap and the flat tray line. She has no helmet, no gun and no coat.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* Muted mint scrubs: a loose short-sleeve tunic over drawstring trousers, worn over a pale long-sleeve thermal top, with pale non-slip shoes. A lanyard holds a blank ID card. A pale scrub cap covers the crown. The tunic carries dried blood spots on the front and the near sleeve, which are a separate stain overlay (Dried blood #8A1A26) and never part of the tunic's own color.

The near hand holds a flat steel instrument tray at hip height, with three round wells that each seat a thumb-sized glass vial with a rubber cap and a milky pale fluid. The tray is its own part, and the vials are separate sprites (they are also the projectiles). The face is tired and gentle, with half-open unblinking eyes fixed on a point beyond Dave and a composed, professionally kind mouth. There are no needles and no syringes.

The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). Behind and below the cap the scalp is close-shaved. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. There are no logos or legible text.

## Color and materials

*Proposed palette:* skin #C9A088; muted mint scrubs #9CC7B8; pale thermal top #DDE7E3; scrub cap #E4ECE9; pale shoes #E4E8EA; lanyard #46546A; steel tray #9AA8B6 with dark wells #4A5866; vial glass #BFD0D8 with milky fluid #DCE6EC and rubber caps #46546A; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45; under-skin neck lines #4A4F63; stain overlay (a separate layer) Dried blood #8A1A26.

**Tokens.** When Adam drives the body, the engine adds a small, dim, steady amber point (Hazard amber #FFB02E) at the port; it is not the tell. The tell is a large additive glow on the tray hand, Hazard amber #FFB02E first and then Alarm red #FF3B4E for the last 0.25 s. The sterilant is a milky pale grey-blue (#DCE6EC), never violet, teal, amber, red or energy blue #5AA9FF; its splash puddles are flat, pale and dark-outlined, drawn by the engine, and are not blood. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, and never painted in. A hit also throws small white sparks (#F2F7FB) at the implant, and the port light goes dark on death. Blood never glows and never uses a tell color.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the light states differ by size and pattern (a small steady point for driven, a large glow for the tell), and the tell also reads by pose (the tray hand raised and tipped) and by the calm bark.

## Abilities and movement

- **Template:** Gunner (arc, no fuse) (C26).
- **Weapon:** thrown caustic sterilant vials (not a gun, so no EG ID).
- **Tell:** GLOW: her tray hand glows amber, then red for the last 0.25 s ("This won't hurt, Dr. Harlan").
- **Attack:** she tosses 3 vials 1.5 H apart on arcs; each lands in a splash of 0.4 H radius, which leaves a 0.7 H gap between splashes.
- **Counter:** step into a gap between the splashes, then close in while she refills (2 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

A calm, steady walk with the tray held level. For the windup she stops, and the tray hand rises to chest height and tips slightly while it glows; the free hand plucks the vials one by one. The throw is three quick underhand tosses, each on a fixed arc.

Then she refills: she looks down and seats new vials into the tray wells, rooted, and that is the opening.

**Sample barks** *(proposed; Adam's calm words in the Nurse's own soft, tired voice. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "This won't hurt, Dr. Harlan." (the windup)
- "Please remain still." (the throw)
- "Just a little pinch." (idle)
- "You're safe with us." (first sight)

Most deaths are silent: a fall, a spark at the port, and the light going out. Rarely she says something confused and human, such as "...I'm so tired."

## Openings and limitations

The refill is the opening: head down, hands busy at the tray, rooted. The tray hand is the tell, so keep the tray a flat, readable bar at hip height. Do not add a gun, syringes, a mask or armor, and do not paint the sterilant in a reserved color.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head; scrub cap (its own part); the port (a small separate head part); torso with the scrub tunic; the stain overlay (a separate decal layer on the tunic and near sleeve); pelvis; near and far upper arms, lower arms and hands (the near hand is the tray hand and the separate weapon-hand part; the far hand is the throwing hand); near and far upper legs, lower legs and feet. The tray is its own part on the near hand's socket, with its three wells; the lanyard is a small swinging piece. The vials are separate projectile sprites.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the cap at the crown; the tray at the grip, tipping about its long axis; the lanyard at the collar. Paint hidden overlap under every joint, and paint the far limbs and whatever the tray hides complete.

**Sockets:** the tray socket at the near palm holds the tray flat at hip height; the throwing socket at the far palm is where each vial leaves. A tray-glow socket on the tray hand holds the large tell glow, and a port-light socket holds the small steady amber point (dark on death). A spark socket at the port throws the white sparks. She has no gun socket.

**Normal maps:** one per part (green = up), soft-edged: scrub folds and drawstrings, the cap's gathered edge, the tray's rim and wells, the vials' glass curve and rubber caps, the staples and port rim, and gentle face modeling so a lamp lights one side of the face.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. The Linked also throw white implant sparks at the port. Blood anchors sit on the head, chest, belly, near upper arm and near thigh. The stain overlay is a separate layer of dried blood and never reacts to hits.

**Motion and death:** Mixamo clips converted to the rig: a slow steady walk, an underhand toss and a hit flinch. Hand-key the tray tip and the refill where no clip fits. Death is a ragdoll pushed by the killing shot, the tray drops as a prop, and the port light goes dark. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle (tray level); walk; windup (tray hand raised and tipped, free hand at the vials); attack (the underhand toss); refill (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the hands (tray grip, throwing hand open and curled).

Tell by pose: the raised, tipped tray hand is the windup, and the engine adds the large amber-then-red glow on the tray hand over that pose. The small steady amber point at the port is separate and present through every driven pose. The resting corpse pose is the one authored pose restored after a death or Continue: on her side, the tray beside her.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one tray with three vials, one cap. No gun, no needles or syringes, no mask, no armor, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple, and no reserved color on the sterilant. Eyes half open and unblinking, with no glow. No blood, wound, stain, glow or shadow painted into the parts (the stain is a separate overlay). No dismemberment. The implant is medical hardware, never drawn as monstrous in itself.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The tray hand, the sleeve stain and the lanyard sit on the near side and are safe to mirror. The port is a small separate head part, a round disc with no handedness, so it sits behind the near ear in either facing. The tray is a separate part, so the rig can swap its hand if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Linked Nurse, a Linked person: a night nurse driven by Adam, carrying a flat instrument tray with three glass vials. Role: Arc-throwing Linked enemy: a night nurse who tosses caustic sterilant vials in a spread.
Scale: About 1.66 m tall, roughly 7.25 heads, with a slight build.
Silhouette: A slim woman in a loose scrub tunic and trousers and a pale scrub cap, holding a flat steel instrument tray at hip height in the near hand, so the tray reads as a flat horizontal bar in the silhouette. The far hand hangs empty, thumb and fingers curled to pluck and throw. In grayscale she reads by the slender build, the cap and the flat tray line. She has no helmet, no gun and no coat.
Physical design: Muted mint scrubs: a loose short-sleeve tunic over drawstring trousers, worn over a pale long-sleeve thermal top, with pale non-slip shoes. A lanyard holds a blank ID card. A pale scrub cap covers the crown. The tunic is painted clean: its dried blood spots are a separate overlay added later, so no stain is painted in. The near hand holds a flat steel instrument tray at hip height, with three round wells that each seat a thumb-sized glass vial with a rubber cap and a milky pale fluid. The tray is its own part, and the vials are separate sprites (they are also the projectiles). The face is tired and gentle, with half-open unblinking eyes fixed on a point beyond Dave and a composed, professionally kind mouth. There are no needles and no syringes. The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). Behind and below the cap the scalp is close-shaved. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. There are no logos or legible text.
Materials and colors: skin #C9A088; muted mint scrubs #9CC7B8; pale thermal top #DDE7E3; scrub cap #E4ECE9; pale shoes #E4E8EA; lanyard #46546A; steel tray #9AA8B6 with dark wells #4A5866; vial glass #BFD0D8 with milky fluid #DCE6EC and rubber caps #46546A; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45; under-skin neck lines #4A4F63. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, and a large amber then Alarm red #FF3B4E glow on the tray hand as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in; the blood-spotted scrubs are a separate stain overlay, not part of this painting.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one tray with three vials, one cap. No gun, no needles or syringes, no mask, no armor, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple, and no reserved color on the sterilant. Eyes half open and unblinking, with no glow. No blood, wound, stain, glow or shadow painted into the parts (the stain is a separate overlay). No dismemberment. The implant is medical hardware, never drawn as monstrous in itself.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright and composed with the tray held level in the near hand and the far hand hanging open, a calm vacant expression; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Linked Nurse design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.66 m tall, roughly 7.25 heads, with a slight build. Maintain these defining forms: A slim woman in a loose scrub tunic and trousers and a pale scrub cap, holding a flat steel instrument tray at hip height in the near hand, so the tray reads as a flat horizontal bar in the silhouette. The far hand hangs empty, thumb and fingers curled to pluck and throw. In grayscale she reads by the slender build, the cap and the flat tray line. She has no helmet, no gun and no coat. Preserve construction: Muted mint scrubs: a loose short-sleeve tunic over drawstring trousers, worn over a pale long-sleeve thermal top, with pale non-slip shoes. A lanyard holds a blank ID card. A pale scrub cap covers the crown. The tunic is painted clean: its dried blood spots are a separate overlay added later, so no stain is painted in. The near hand holds a flat steel instrument tray at hip height, with three round wells that each seat a thumb-sized glass vial with a rubber cap and a milky pale fluid. The tray is its own part, and the vials are separate sprites (they are also the projectiles). The face is tired and gentle, with half-open unblinking eyes fixed on a point beyond Dave and a composed, professionally kind mouth. There are no needles and no syringes. The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). Behind and below the cap the scalp is close-shaved. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. There are no logos or legible text. Preserve the palette: skin #C9A088; muted mint scrubs #9CC7B8; pale thermal top #DDE7E3; scrub cap #E4ECE9; pale shoes #E4E8EA; lanyard #46546A; steel tray #9AA8B6 with dark wells #4A5866; vial glass #BFD0D8 with milky fluid #DCE6EC and rubber caps #46546A; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45; under-skin neck lines #4A4F63. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, and a large amber then Alarm red #FF3B4E glow on the tray hand as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in; the blood-spotted scrubs are a separate stain overlay, not part of this painting. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one tray with three vials, one cap. No gun, no needles or syringes, no mask, no armor, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple, and no reserved color on the sterilant. Eyes half open and unblinking, with no glow. No blood, wound, stain, glow or shadow painted into the parts (the stain is a separate overlay). No dismemberment. The implant is medical hardware, never drawn as monstrous in itself. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Linked Nurse reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle (tray level); walk; windup (tray hand raised and tipped, free hand at the vials); attack (the underhand toss); refill (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the hands (tray grip, throwing hand open and curled). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Movement language: A calm, steady walk with the tray held level. For the windup she stops, and the tray hand rises to chest height and tips slightly while it glows; the free hand plucks the vials one by one. The throw is three quick underhand tosses, each on a fixed arc. Then she refills: she looks down and seats new vials into the tray wells, rooted, and that is the opening. Capability: Tosses three caustic vials in a spread, then refills the tray, rooted. Important limitation or opening: The refill is the opening: head down, hands busy at the tray, rooted. The tray hand is the tell, so keep the tray a flat, readable bar at hip height. Do not add a gun, syringes, a mask or armor, and do not paint the sterilant in a reserved color. Tell: GLOW on the tray hand, amber first and then red for the last 0.25 s, added by the engine; paint the tray and hand without a glow. The small amber point at the port is separate. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Paint it after the Staffer, so the Linked share the port and the stapled-seam treatment.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The tray hand, the sleeve stain overlay and the lanyard must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Staffer (bare head and slouch), the Linked Lineman (hard hat and pack) and the Sidearm Guard (bare head, vest and two-hand stance). The Nurse reads by the scrub cap, the slim build and the flat tray line. The tell must read by pose and glow with the night overlay on.
- Convert the Mixamo clips (slow steady walk, underhand toss, hit flinch) to the rig and hand-key the tell pose where no clip fits. Check that the tray stays a readable flat bar at gameplay size and that the stain overlay tracks the tunic.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

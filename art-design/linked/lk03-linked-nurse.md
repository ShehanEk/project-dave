# Linked Nurse

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** LK03\
**Category:** linked (people driven by Adam through the Link)\
**First appearance:** Level 7 (appears in L7–L9)\
**Design status:** Look follows C60 (approved 2026-10-12): painted HD parts on the lit cutout rig (C56), corporate cyberpunk (C58), alert and composed (C57), electric-blue trim for the Linked (C60). Concept images are still to be generated. The roster entry (C31), human enemies (C25) and the enemy gun kit (C27) are confirmed, and the lit cutout method is confirmed (C35). Behavior numbers (P23) are *proposed*. Dimensions are provisional art proportions, not engine specifications.

**Look updates:** C57 (2026-10-11): no sleepy or zombie-like look; the Link shows as technology (port light, electric-blue eye glint, synchronized precise moves). C60 (2026-10-12): the port is a clean ring-lit disc with no staples, bruise ring, seam or sutures; implants and cables are clean technology; electric blue #4D8DFF is the neon color of every Linked type.

## Identity and role

Arc-throwing Linked enemy: a night nurse who tosses caustic sterilant vials in a spread.

*Proposed identity:* a night nurse at the Arcadia Wellness Center, where staff were fitted with the Link. She was once the person who handed out the wellness perk with a smile. Adam now drives her through a routine "preparation": caustic sterilant vials from the ward, tossed in a spread. She is not a gunner and carries no gun. She appears in Levels 7–9.

**Three looks on one rig** (C56, C60), all Caucasian (C43): **A, the night nurse** (a woman in her thirties, dark hair in a neat bun under the cap, a kind, composed face); **B, the male nurse** (a man in his late twenties, short fair hair, a gentle, steady face; the brief says "she" for the type, and look B is a man); **C, the senior nurse** (a woman in her fifties, grey hair in a short bob under the cap, reading glasses on a cord). The game picks a look by entity id; stats, tells and timing are the same.

Combat is lethal (C28): she bleeds red and sparks at the implant (C29), and most Linked deaths are silent. She never blocks progress.

## Scale and silhouette

About 1.66 m tall, roughly 7.25 heads, with a slight build.

A slim nurse in a crisp white clinic tunic and trousers and a white clinic cap, holding a flat steel instrument tray at hip height in the near hand, so the tray reads as a flat horizontal bar in the silhouette. The far hand hangs empty, thumb and fingers curled to pluck and throw. In grayscale she reads by the slender build, the cap and the flat tray line. She has no helmet, no gun and no coat.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design (C60).* A crisp white clinic uniform with electric-blue piping (#4D8DFF): a fitted short-sleeve tunic over straight trousers, worn over a pale blue-grey long-sleeve undershirt, with the piping along the collar, cuffs and hem and a blue band on the cap, and pale non-slip shoes. A lanyard holds a blank ID card. A white clinic cap covers the crown. The uniform is spotless.

The near hand holds a flat instrument tray at hip height, a sleek clinic product in brushed steel and white composite, with three round wells that each seat a thumb-sized glass vial with a rubber cap and a milky pale fluid. The tray is its own part, and the vials are separate sprites (they are also the projectiles). The face is gentle and composed, with wide-open, steady eyes that look straight at Dave and a calm, professionally kind, slightly too-perfect expression. There are no needles and no syringes.

The Link signature: behind the near ear sits the Link port, a clean coin-sized disc with a pale steel rim and a thin ring light, set flush in the skin. There are no staples, bruise rings, seams or lines under the skin. The hair is tucked under the cap, and the cap's rear edge sits above the port so that it stays visible. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are wide open and alert and are painted without glow; the engine adds a faint electric-blue glint (#4D8DFF) in the irises while Adam drives the body, and it goes dark on death. The port is clean technology, never a monster feature, and nothing is exposed. There are no logos or legible text.

## Color and materials

*Proposed palette:* skin #E3BDA3; white clinic tunic #EEF2F4 with electric-blue piping #4D8DFF; white trousers #E4E9EC; pale blue-grey undershirt #CFDAE3; clinic cap #F2F5F6 with blue band #4D8DFF; pale shoes #E4E8EA; lanyard #46546A; steel and white tray #C9D3DC with dark wells #4A5866; vial glass #BFD0D8 with milky fluid #DCE6EC and rubber caps #46546A; port disc #2E3B4E with pale steel rim #9AA5B1; hair by look: A dark brown #3A2B22, B fair #C9B28A, C grey #B4B8BD.

**Tokens.** When Adam drives the body, the engine adds a small, dim, steady amber point (Hazard amber #FFB02E) at the port; it is not the tell. It also adds a faint electric-blue glint (#4D8DFF) in both irises; that is not the tell either, and it goes dark on death. The tell is a large additive glow on the tray hand, Hazard amber #FFB02E first and then Alarm red #FF3B4E for the last 0.25 s. The sterilant is a milky pale grey-blue (#DCE6EC), never violet, teal, amber, red or energy blue #5AA9FF; its splash puddles are flat, pale and dark-outlined, drawn by the engine, and are not blood. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, and never painted in. A hit also throws small white sparks (#F2F7FB) at the implant, and the port light goes dark on death. Blood never glows and never uses a tell color. **Neon (C60):** electric blue #4D8DFF marks the Linked, the people Adam drives. It is steady, thinner and dimmer than any tell, never on the attacking part or a weak point, and it goes dark when the body dies.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the light states differ by size and pattern (a small steady point for driven, a large glow for the tell), and the tell also reads by pose (the tray hand raised and tipped) and by the calm bark.

## Abilities and movement

- **Template:** Gunner (arc, no fuse) (C26).
- **Weapon:** thrown caustic sterilant vials (not a gun, so no EG ID).
- **Tell:** GLOW: her tray hand glows amber, then red for the last 0.25 s ("This won't hurt, Dr. Harlan").
- **Attack:** she tosses 3 vials 1.5 H apart on arcs; each lands in a splash of 0.4 H radius, which leaves a 0.7 H gap between splashes.
- **Counter:** step into a gap between the splashes, then close in while she refills (2 hits).

*(H is Dave's height, the unit the encounter numbers use; all numbers are proposal P23.)*

A calm, brisk, even walk with the tray held level. For the windup she stops, and the tray hand rises to chest height and tips slightly while it glows; the free hand plucks the vials one by one. The throw is three quick underhand tosses, each on a fixed arc.

Then she refills: she looks down and seats new vials into the tray wells with quick, exact hand movements, rooted, and that is the opening.

**Sample barks** *(proposed; Adam's calm words in the Nurse's own soft, steady voice. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "This won't hurt, Dr. Harlan." (the windup)
- "Please remain still." (the throw)
- "Just a little pinch." (idle)
- "You're safe with us." (first sight)

Most deaths are silent: a fall, a spark at the port, and the light going out. Rarely she says something startled and human, such as "...is it still my shift?"

## Openings and limitations

The refill is the opening: head down, hands busy at the tray, rooted. The tray hand is the tell, so keep the tray a flat, readable bar at hip height. Do not add a gun, syringes, a mask or armor, and do not paint the sterilant in a reserved color.

## Rig parts, normal maps and sockets

**Looks (C56):** the three looks share one part list, skeleton, pivots, clips and hit zones; the head, hair and build details differ. **Parts** *(painted once per look, facing right; near means the side toward the camera)*: head; clinic cap (its own part); the port (a small separate head part); torso with the clinic tunic; pelvis; near and far upper arms, lower arms and hands (the near hand is the tray hand and the separate weapon-hand part; the far hand is the throwing hand); near and far upper legs, lower legs and feet. The tray is its own part on the near hand's socket, with its three wells; the lanyard is a small swinging piece. The vials are separate projectile sprites.

**Pivots:** neck base, shoulders, elbows, wrists, hip, knees and ankles; the cap at the crown; the tray at the grip, tipping about its long axis; the lanyard at the collar. Paint hidden overlap under every joint, and paint the far limbs and whatever the tray hides complete.

**Sockets:** the tray socket at the near palm holds the tray flat at hip height; the throwing socket at the far palm is where each vial leaves. A tray-glow socket on the tray hand holds the large tell glow, and a port-light socket holds the small steady amber point (dark on death). A spark socket at the port throws the white sparks. She has no gun socket.

**Normal maps:** one per part (green = up), soft-edged: tunic folds and piping, the cap's edge, the tray's rim and wells, the vials' glass curve and rubber caps, the port rim and ring light, and gentle face modeling so a lamp lights one side of the face.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. The Linked also throw white implant sparks at the port. Blood anchors sit on the head, chest, belly, near upper arm and near thigh.

**Motion and death:** hand-keyed on the rig for the side view (C38): a brisk, even walk, an underhand toss and a hit flinch, plus the tray tip and the refill. Death is a ragdoll pushed by the killing shot, the tray drops as a prop, and the port light goes dark. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Idle (tray level); walk; windup (tray hand raised and tipped, free hand at the vials); attack (the underhand toss); refill (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the hands (tray grip, throwing hand open and curled).

Tell by pose: the raised, tipped tray hand is the windup, and the engine adds the large amber-then-red glow on the tray hand over that pose. The small steady amber point at the port is separate and present through every driven pose. The resting corpse pose is the one authored pose restored after a death or Continue: on her side, the tray beside her.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one tray with three vials, one cap. No gun, no needles or syringes, no mask, no armor, no exposed wiring, organs or wounds, no staples, bruise rings or seams, no readable text or logos, no violet or purple, and no reserved color on the sterilant. Eyes wide open and alert, painted without glow (the engine adds the faint electric-blue iris glint); no sleepy, slack or vacant faces. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant is clean technology, never drawn as monstrous in itself.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The tray hand, the piping and the lanyard sit on the near side and are safe to mirror. The port is a small separate head part, a round disc with no handedness, so it sits behind the near ear in either facing. The tray is a separate part, so the rig can swap its hand if a mirrored view ever needs it.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Paint a single evenly lit, hand-painted, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: soft painted shading for form and folds, clean dark outlines (heavier outer contours, restrained interior lines), no baked cast shadows, no cel-shadow shapes, no rim light, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Linked Nurse, a Linked person: a night nurse driven by Adam, carrying a flat instrument tray with three glass vials. Role: Arc-throwing Linked enemy: a night nurse who tosses caustic sterilant vials in a spread.
Scale: About 1.66 m tall, roughly 7.25 heads, with a slight build.
Silhouette: A slim nurse in a crisp white clinic tunic and trousers and a white clinic cap, holding a flat steel instrument tray at hip height in the near hand, so the tray reads as a flat horizontal bar in the silhouette. The far hand hangs empty, thumb and fingers curled to pluck and throw. In grayscale she reads by the slender build, the cap and the flat tray line. She has no helmet, no gun and no coat.
Physical design: A crisp white clinic uniform with electric-blue piping (#4D8DFF): a fitted short-sleeve tunic over straight trousers, worn over a pale blue-grey long-sleeve undershirt, with the piping along the collar, cuffs and hem and a blue band on the cap, and pale non-slip shoes. A lanyard holds a blank ID card. A white clinic cap covers the crown. The uniform is spotless. The near hand holds a flat instrument tray at hip height, a sleek clinic product in brushed steel and white composite, with three round wells that each seat a thumb-sized glass vial with a rubber cap and a milky pale fluid. The tray is its own part, and the vials are separate sprites (they are also the projectiles). The face is gentle and composed, with wide-open, steady eyes that look straight at Dave and a calm, professionally kind, slightly too-perfect expression. There are no needles and no syringes. The Link signature: behind the near ear sits the Link port, a clean coin-sized disc with a pale steel rim and a thin ring light, set flush in the skin. There are no staples, bruise rings, seams or lines under the skin. The hair is tucked under the cap, and the cap's rear edge sits above the port so that it stays visible. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are wide open and alert and are painted without glow; the engine adds a faint electric-blue glint (#4D8DFF) in the irises while Adam drives the body, and it goes dark on death. The port is clean technology, never a monster feature, and nothing is exposed. There are no logos or legible text.
Materials and colors: skin #E3BDA3; white clinic tunic #EEF2F4 with electric-blue piping #4D8DFF; white trousers #E4E9EC; pale blue-grey undershirt #CFDAE3; clinic cap #F2F5F6 with blue band #4D8DFF; pale shoes #E4E8EA; lanyard #46546A; steel and white tray #C9D3DC with dark wells #4A5866; vial glass #BFD0D8 with milky fluid #DCE6EC and rubber caps #46546A; port disc #2E3B4E with pale steel rim #9AA5B1; hair by look: A dark brown #3A2B22, B fair #C9B28A, C grey #B4B8BD. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, a faint electric-blue #4D8DFF glint in the irises while driven, and a large amber then Alarm red #FF3B4E glow on the tray hand as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one tray with three vials, one cap. No gun, no needles or syringes, no mask, no armor, no exposed wiring, organs or wounds, no staples, bruise rings or seams, no readable text or logos, no violet or purple, and no reserved color on the sterilant. Eyes wide open and alert, painted without glow (the engine adds the faint electric-blue iris glint); no sleepy, slack or vacant faces. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant is clean technology, never drawn as monstrous in itself.
Use a relaxed neutral pose that reveals the silhouette and joint structure: standing upright and composed with the tray held level in the near hand and the far hand hanging open, a calm, alert, politely kind expression with the eyes wide open; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Linked Nurse design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.66 m tall, roughly 7.25 heads, with a slight build. Maintain these defining forms: A slim nurse in a crisp white clinic tunic and trousers and a white clinic cap, holding a flat steel instrument tray at hip height in the near hand, so the tray reads as a flat horizontal bar in the silhouette. The far hand hangs empty, thumb and fingers curled to pluck and throw. In grayscale she reads by the slender build, the cap and the flat tray line. She has no helmet, no gun and no coat. Preserve construction: A crisp white clinic uniform with electric-blue piping (#4D8DFF): a fitted short-sleeve tunic over straight trousers, worn over a pale blue-grey long-sleeve undershirt, with the piping along the collar, cuffs and hem and a blue band on the cap, and pale non-slip shoes. A lanyard holds a blank ID card. A white clinic cap covers the crown. The uniform is spotless. The near hand holds a flat instrument tray at hip height, a sleek clinic product in brushed steel and white composite, with three round wells that each seat a thumb-sized glass vial with a rubber cap and a milky pale fluid. The tray is its own part, and the vials are separate sprites (they are also the projectiles). The face is gentle and composed, with wide-open, steady eyes that look straight at Dave and a calm, professionally kind, slightly too-perfect expression. There are no needles and no syringes. The Link signature: behind the near ear sits the Link port, a clean coin-sized disc with a pale steel rim and a thin ring light, set flush in the skin. There are no staples, bruise rings, seams or lines under the skin. The hair is tucked under the cap, and the cap's rear edge sits above the port so that it stays visible. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are wide open and alert and are painted without glow; the engine adds a faint electric-blue glint (#4D8DFF) in the irises while Adam drives the body, and it goes dark on death. The port is clean technology, never a monster feature, and nothing is exposed. There are no logos or legible text. Preserve the palette: skin #E3BDA3; white clinic tunic #EEF2F4 with electric-blue piping #4D8DFF; white trousers #E4E9EC; pale blue-grey undershirt #CFDAE3; clinic cap #F2F5F6 with blue band #4D8DFF; pale shoes #E4E8EA; lanyard #46546A; steel and white tray #C9D3DC with dark wells #4A5866; vial glass #BFD0D8 with milky fluid #DCE6EC and rubber caps #46546A; port disc #2E3B4E with pale steel rim #9AA5B1; hair by look: A dark brown #3A2B22, B fair #C9B28A, C grey #B4B8BD. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, a faint electric-blue #4D8DFF glint in the irises while driven, and a large amber then Alarm red #FF3B4E glow on the tray hand as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one tray with three vials, one cap. No gun, no needles or syringes, no mask, no armor, no exposed wiring, organs or wounds, no staples, bruise rings or seams, no readable text or logos, no violet or purple, and no reserved color on the sterilant. Eyes wide open and alert, painted without glow (the engine adds the faint electric-blue iris glint); no sleepy, slack or vacant faces. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant is clean technology, never drawn as monstrous in itself. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Linked Nurse reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Idle (tray level); walk; windup (tray hand raised and tipped, free hand at the vials); attack (the underhand toss); refill (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the hands (tray grip, throwing hand open and curled). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and hand-painted (soft shading for form), with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Movement language: A calm, brisk, even walk with the tray held level. For the windup she stops, and the tray hand rises to chest height and tips slightly while it glows; the free hand plucks the vials one by one. The throw is three quick underhand tosses, each on a fixed arc. Then she refills: she looks down and seats new vials into the tray wells with quick, exact hand movements, rooted, and that is the opening. Capability: Tosses three caustic vials in a spread, then refills the tray, rooted. Important limitation or opening: The refill is the opening: head down, hands busy at the tray, rooted. The tray hand is the tell, so keep the tray a flat, readable bar at hip height. Do not add a gun, syringes, a mask or armor, and do not paint the sterilant in a reserved color. Tell: GLOW on the tray hand, amber first and then red for the last 0.25 s, added by the engine; paint the tray and hand without a glow. The small amber point at the port is separate. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Generate the three looks as painted HD parts sheets (C56) with style-frame-v2 attached (layout as in the Night Guard's prompt 4, [SE01](../security/se01-night-guard.md); attach look A when generating B and C). Do it after the Staffer, so the Linked share the clean port. Paint it after the Staffer, so the Linked share the port and the stapled-seam treatment.
- Split each approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The tray hand and the lanyard must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Staffer (bare head and everyday build), the Linked Lineman (hard hat and pack) and the Sidearm Guard (bare head, vest and two-hand stance). The Nurse reads by the clinic cap, the slim build and the flat tray line. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (brisk even walk, underhand toss, hit flinch) for the side view (C38). Check that the tray stays a readable flat bar at gameplay size.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

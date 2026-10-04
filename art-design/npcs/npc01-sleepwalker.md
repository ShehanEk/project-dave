# Sleepwalker

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** NPC01\
**Category:** npcs (protected people, not enemies)\
**First appearance:** Level 7 (harmless background staff, *proposed*; also seen in L8–L9)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The Sleepwalker is a protected NPC and no longer an enemy (C31). This asset's identity and appearance are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Harmless protected NPC: a Linked worker whose failing implant repeats old work routines. Never a target, never hostile, no combat.

*Proposed identity:* a member of Arcadia's Wellness Center facilities and records staff whose Link is failing. Adam's control has frayed, and the body falls back on the routines of its old job: opening doors, pushing carts, straightening charts, and covering its head in an old shelter drill when shots go off nearby. It carries no weapon, makes no attack and has no hit zone: player shots and enemy shots pass through it, no hit spark or blood is drawn, and encounters place it out of fire lines. Protected people are untouchable.

It appears in Levels 7–9 as quiet background life in the clinic corridors and the archive, and it is one of the roster's small horrors: staff still going through the motions. It teaches that not every moving body is a target, and it never blocks progress.

## Scale and silhouette

About 1.70 m upright, roughly 7.25 heads, with a slim build.

A slim, upright figure with a slightly tilted head, a neat knee-length belted service coat and a comparatively composed stance. In grayscale it reads by the long coat and the small, calm shape. It has no headgear, no hardware bulk and no held weapon, which sets it apart from every driven Linked person.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* A neat but worn knee-length service coat in charcoal-navy, belted at the waist, over a pale shirt, dark navy trousers and practical shoes. A lanyard holds a blank ID plate, and a small dull brass key ring hangs from the near side of the belt as a personal keepsake. A slim graphite bracer with a small status window, painted dark, sits on the near wrist. The hair is cropped short, with a small shaved patch at the port. The face has soft brows, a hesitant mouth and half-lidded eyes that blink slowly, the only Linked eyes that do.

The Link port sits behind the near ear: a coin-sized dark disc with a pale steel rim, sealed with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar. The port is painted dark and unlit; the engine adds a dim, steady teal light. The hardware is small and neat, so the figure reads as a person. There are no logos or legible text.

## Color and materials

*Proposed palette:* skin #CDAA90; charcoal-navy coat #404D66; pale shirt #D8DEE4; dark navy trousers #26344C; graphite bracer #2E3948; dull brass keys #B7A067; blank ID plate #D8DEE4; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45.

**Tokens.** The Link light is Arcadia teal #3FE0D0, dim and steady, added by the engine: a teal Link light means Adam is not driving this person, so it is harmless and protected. It never shows Hazard amber or Alarm red, and it has no tell. The brass keys are dull and never glow, and must not read as microchip gold (#FFD166). It has no hit zone, so no blood is ever drawn on it.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the state reads by the steady teal light and by behavior, a calm, unhurried body that never lunges.

## Abilities and movement

- **Template:** none: a protected NPC, not an enemy (the behavior templates are for enemies).
- **Weapon:** none. It has no attack, no tell and no hit zone.
- **Behavior:** it repeats old work routines on a fixed loop.
- **Reaction:** when shots or explosions go off nearby it flinches and covers its head, then resumes; it never runs into a fire line.
- **Counter:** none needed. It is never a target, encounters place it out of fire lines, and it never blocks progress.

Pauses to recognize an object, then reaches for a door handle, a cart or a chart with careful, stiff precision, and now and then loses track of the action and stands confused for a moment. Its routines are a loop of harmless work: pushing an empty cart along a fixed path, straightening a chart or a small object, reaching for a door handle that is or isn't there. When a routine snaps to its next step the motion turns briefly too quick, then settles.

When shots or explosions go off nearby it crouches and covers its head in an old shelter drill, then rises and resumes. It may also sit down against a wall and rest, its head slightly tilted.

**Sample barks** *(proposed; the Sleepwalker's own murmured habits, not Adam's words. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Just a moment."
- "Badge, please."
- "Meeting's at nine."
- "Is it morning?"

It never shouts, and it has no death sound, since it cannot be hurt.

## Protection and limitations

There is no opening, because it is not a target: it has no hit zone, and shots pass through it. Keep it visibly harmless: a relaxed posture and a dim, steady teal light, never amber or red. Do not give it a weapon, a hostile glow or a monstrous change.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head; the port (a small separate head part); torso with the upper half of the service coat; the coat skirt as two swinging parts (front and back) pivoted at the belt; pelvis with the belt; near and far upper arms, lower arms and hands (both are prop hands for a cart handle, a door handle or a chart; there is no weapon hand); near and far upper legs, lower legs and feet. Small swinging pieces: the key ring on the near belt, the lanyard and blank ID plate, and the bracer on the near wrist.

**Pivots:** neck base (the head tilts slightly), shoulders, elbows, wrists, hip, knees and ankles; the coat skirts at the belt; the key ring at the belt; the lanyard at the collar. Paint hidden overlap under every joint, and paint the far limbs and the body under the coat complete.

**Sockets:** no gun socket. Two prop sockets, at the near and far palms, hold a cart handle, a door handle or a chart. A port-light socket holds the dim, steady teal light.

**Normal maps:** one per part (green = up), soft-edged: coat seams, belt and buttons, the key ring, the bracer, the staples and port rim, and gentle face modeling with soft brows so a lamp lights one side of the face.

**Fluid:** none: it has no hit zone and is never hurt, so it has no blood anchors, sparks or pools.

**Motion and death:** hand-keyed on the rig for the side view (C38): an idle, a slow careful walk, a door-open reach, a cart push, a crouch-and-cover flinch and a sit-down, plus the confused pause. It has no hit clip, no death and no ragdoll, since it cannot be hurt or killed.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Neutral recognition; walk (careful, stiff); careful reach at a door; cart push; straighten a chart; confused pause; cover flinch (shots nearby); sitting rest; the prop hands (open, cart-handle grip, door-handle grip).

There is no hit reaction and no death pose: it has no hit zone and is never hurt. The teal Link light is steady in every pose. Any aftermath scene in the clinic is a separate authored prop, not this asset.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one port. No weapon, no hit zone, no amber or red, no armor, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. No blood, wound, glow or shadow painted into the parts. The implant is medical hardware, never drawn as monstrous in itself.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The key ring, the bracer and the lanyard sit on the near side and are safe to mirror. The port is a small separate head part, a round disc with no handedness, so it sits behind the near ear in either facing. The coat skirts are separate parts.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Sleepwalker, a protected non-combat person: a Wellness Center records worker whose Link implant is failing, in a neat service coat. Role: Harmless protected NPC: a Linked worker whose failing implant repeats old work routines. Never a target, never hostile, no combat.
Scale: About 1.70 m upright, roughly 7.25 heads, with a slim build.
Silhouette: A slim, upright figure with a slightly tilted head, a neat knee-length belted service coat and a comparatively composed stance. In grayscale it reads by the long coat and the small, calm shape. It has no headgear, no hardware bulk and no held weapon, which sets it apart from every driven Linked person.
Physical design: A neat but worn knee-length service coat in charcoal-navy, belted at the waist, over a pale shirt, dark navy trousers and practical shoes. A lanyard holds a blank ID plate, and a small dull brass key ring hangs from the near side of the belt as a personal keepsake. A slim graphite bracer with a small status window, painted dark, sits on the near wrist. The hair is cropped short, with a small shaved patch at the port. The face has soft brows, a hesitant mouth and half-lidded eyes that blink slowly, the only Linked eyes that do. The Link port sits behind the near ear: a coin-sized dark disc with a pale steel rim, sealed with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar. The port is painted dark and unlit; the engine adds a dim, steady teal light. The hardware is small and neat, so the figure reads as a person. There are no logos or legible text.
Materials and colors: skin #CDAA90; charcoal-navy coat #404D66; pale shirt #D8DEE4; dark navy trousers #26344C; graphite bracer #2E3948; dull brass keys #B7A067; blank ID plate #D8DEE4; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45. The Link light is added by the engine and never painted: a dim, steady Arcadia teal #3FE0D0 point at the port.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one port. No weapon, no hit zone, no amber or red, no armor, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. No blood, wound, glow or shadow painted into the parts. The implant is medical hardware, never drawn as monstrous in itself.
Use a relaxed neutral pose that reveals the silhouette and joint structure: calm and upright with a slight head tilt and a vacant, hesitant expression, the hands empty and relaxed; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Sleepwalker design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.70 m upright, roughly 7.25 heads, with a slim build. Maintain these defining forms: A slim, upright figure with a slightly tilted head, a neat knee-length belted service coat and a comparatively composed stance. In grayscale it reads by the long coat and the small, calm shape. It has no headgear, no hardware bulk and no held weapon, which sets it apart from every driven Linked person. Preserve construction: A neat but worn knee-length service coat in charcoal-navy, belted at the waist, over a pale shirt, dark navy trousers and practical shoes. A lanyard holds a blank ID plate, and a small dull brass key ring hangs from the near side of the belt as a personal keepsake. A slim graphite bracer with a small status window, painted dark, sits on the near wrist. The hair is cropped short, with a small shaved patch at the port. The face has soft brows, a hesitant mouth and half-lidded eyes that blink slowly, the only Linked eyes that do. The Link port sits behind the near ear: a coin-sized dark disc with a pale steel rim, sealed with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar. The port is painted dark and unlit; the engine adds a dim, steady teal light. The hardware is small and neat, so the figure reads as a person. There are no logos or legible text. Preserve the palette: skin #CDAA90; charcoal-navy coat #404D66; pale shirt #D8DEE4; dark navy trousers #26344C; graphite bracer #2E3948; dull brass keys #B7A067; blank ID plate #D8DEE4; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45. The Link light is added by the engine and never painted: a dim, steady Arcadia teal #3FE0D0 point at the port. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one port. No weapon, no hit zone, no amber or red, no armor, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. No blood, wound, glow or shadow painted into the parts. The implant is medical hardware, never drawn as monstrous in itself. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Sleepwalker reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Neutral recognition; walk (careful, stiff); careful reach at a door; cart push; straighten a chart; confused pause; cover flinch (shots nearby); sitting rest; the prop hands (open, cart-handle grip, door-handle grip). If no state is specified, show the careful reach at a door. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Movement language: Pauses to recognize an object, then reaches for a door handle, a cart or a chart with careful, stiff precision, and now and then loses track of the action and stands confused for a moment. Its routines are a loop of harmless work: pushing an empty cart along a fixed path, straightening a chart or a small object, reaching for a door handle that is or isn't there. When a routine snaps to its next step the motion turns briefly too quick, then settles. When shots or explosions go off nearby it crouches and covers its head in an old shelter drill, then rises and resumes. It may also sit down against a wall and rest, its head slightly tilted. Capability: Repeats harmless work routines and flinches at nearby fire; it has no attack. Important limitation or opening: There is no opening, because it is not a target: it has no hit zone, and shots pass through it. Keep it visibly harmless: a relaxed posture and a dim, steady teal light, never amber or red. Do not give it a weapon, a hostile glow or a monstrous change. Tell: none: the Sleepwalker has no tell; the dim steady teal Link light is added by the engine. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Paint it after the Staffer, so the Linked share the port and the stapled-seam treatment.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The key ring, the bracer and the lanyard must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Staffer (slouch, no coat), the Linked Nurse (scrub cap and tray) and the Fitted Heir (pale ceramic). The Sleepwalker reads by the long belted coat and the composed stance. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (idle, slow careful walk, door-open reach, cart push, crouch-and-cover flinch, sit-down) for the side view (C38). Check that the steady teal light reads as harmless next to a driven Linked person's amber point.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

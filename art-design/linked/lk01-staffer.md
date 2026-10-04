# Staffer

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** LK01\
**Category:** linked (people driven by Adam through the Link)\
**First appearance:** Level 1 (appears in L1–L10; first seen at the Level 1 alarm exit, after the core-node lockdown)\
**Design status:** Confirmed direction, validated: the lit cutout rig art method (C35), approved in the lit-cutout test on 2026-09-30. The roster entry (C31) and human enemies (C25) are confirmed. This asset's identity, appearance and behavior numbers (P23) are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Visual reference status

No Staffer image is selected yet. Generate a neutral design from prompt 1 and approve one before splitting it into rig parts or producing poses.

Nothing from earlier art carries over: the Staffer is a fresh design in the lit cutout method (C35). Paint it after the lit Night Guard test has settled the look, and use the approved [Night Guard](../security/se01-night-guard.md) painting for outline weight and the flat-color treatment.

## Identity and role

Basic Linked enemy: a person driven through a broken routine, who drops into a low lunge and grabs. It never blocks progress.

*Proposed identity:* a night-shift Arcadia employee in facilities and office support, who took the Link as a wellness perk. After Dave plugs into the core node in Level 1 and the campus locks down, Adam drives the staff still on shift toward the alarm exit: the Staffer is the first Linked person Dave meets, and the first sign that the calm voice can move people. Adam's order is a routine, not violence. The Staffer wants Dave back at his workstation, and it will hold him there with its hands.

Staffers appear in Levels 1–10, in the workwear of each act, and they never block progress: Dave can always jump past one. Combat is lethal (C28): a Staffer bleeds red and sparks at the implant (C29), and most Linked deaths are silent, with the port light just going out. Killing one is a choice, since it only reaches for Dave and never bars the route.

## Scale and silhouette

About 1.72 m upright, roughly 7.25 heads, and about 1.60 m in its habitual slouch, with a soft, slightly heavy build.

A soft, slightly pear-shaped office-worker body with a small forward head tilted to one side, drooping shoulders, arms hanging a little away from the torso as if held on strings, and two stiffly bent legs. It reads as an everyday person in a work jacket; only the padded grips strapped over both palms and the stapled port behind the ear hint at anything wrong. In grayscale it is the softest, most slouched human shape in the roster, with a bare head, no headgear and no held item.

Use a neutral 1.70 m adult silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* The Act 1 workwear, which is the default skin: a navy Arcadia staff jacket zipped halfway over a pale shirt with a loosened collar, charcoal trousers and scuffed slate shoes with pale rubber soles. The near sleeve is pushed up above the elbow, and the near shoe drags. A lanyard holds a blank ID card. Both hands wear padded restraint grips: slate rubber pads strapped over the palms with graphite wrist straps, which carry the tell glow in play. The face has heavy eyelids that stay half open, an unfocused gaze, a slack lower lip and tired shadows under the eyes.

The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). The scalp is close-shaved. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. There are no logos or legible text.

*Workwear per act (skins on the same body):* Act 1, the navy staff jacket above; Act 2, a slate server-hall vest over a grey polo, with a lanyard; Act 3, a pale clinic porter tunic; Act 4, a pale grey Garden-crew smock. Only the jacket, vest, tunic or smock changes; the body, hands, port and grips stay the same.

## Color and materials

*Proposed palette:* skin #BC957B; navy jacket #2C3D5A; pale shirt #D3DAE0; charcoal trousers #2F3948; slate shoes #46546A with pale rubber soles #B9C4CF; slate grips #46546A with graphite straps #2A3341; blank ID card #D8DEE4; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45; under-skin neck lines #4A4F63.

**Tokens.** When Adam drives the body, the engine adds a small, dim, steady amber point (Hazard amber #FFB02E) at the port; it is not the tell. The tell is a large additive glow on both hands, Hazard amber #FFB02E first and then Alarm red #FF3B4E for the last 0.25 s. The port, the grips and the lanyard are painted dark and unlit. Blood #B3212F (dried #8A1A26) is added by the engine as a spray, wound marks and pools, and never painted in. A hit also throws small white sparks (#F2F7FB) at the implant, and the port light goes dark on death. Blood never glows and never uses a tell color.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture and contrast so they do not depend on color alone: the light states differ by size and pattern (a small steady point for driven, a large glow for the tell), and the tell also reads by pose (the crouch) and by the calm bark.

## Abilities and movement

- **Template:** Brawler (low lunge) (C26).
- **Weapon:** none: a restraint grab with both hands.
- **Tell:** GLOW: it drops into a crouch as a large glow on both hands goes amber, then red for the last 0.25 s ("Please return to your workstation, Dave").
- **Attack:** a fast low grab, a low lunge with both hands.
- **Counter:** jump the grab and hit it while it stumbles (2 hits), or jump past it. It never blocks progress.

A stiff, puppet-like shuffle with the near shoe dragging and the head or a hand twitching between steps. Now and then the Staffer stops and repeats a fragment of its old job, tapping its ID card against a door reader that is not there (flavor only; it changes no timing). Then the twitching builds into the windup: the head snaps sideways, a shoulder hitches, the fingers flutter and the body drops into a crouch with the hands out.

The lunge is suddenly too fast, with the head and torso leading before the feet catch up. A missed grab leaves it stumbling forward, arms out and off balance: that stumble is the opening. It does not blink.

**Sample barks** *(proposed; Adam's calm words in the Staffer's own tired voice. Each is subtitle text plus a non-verbal shout or grunt sound, since there is no voice pipeline)*:

- "Please return to your workstation, Dave." (the windup)
- "It's very late, Dave." (idle)
- "Have you badged in?" (idle)
- "Good evening, Dr. Harlan." (first sight)

Most deaths are silent: a fall, a spark at the port, and the light going out. Rarely a Staffer says something confused and human, such as "...what time is it?"

## Openings and limitations

The stumble after a missed grab is the opening, and the long twitching windup gives Dave time to jump. Do not add armor plates, a held weapon or a glowing chest core: the port is a small light behind the ear, not a weak-point target. The Staffer never blocks Dave's route.

## Rig parts, normal maps and sockets

**Parts** *(painted once, facing right; near means the side toward the camera)*: head (the port is a small separate head part behind the near ear, with its staples); torso with the jacket; pelvis; near and far upper arms, lower arms and hands (both hands are grip hands with padded palms; the near hand is the separate weapon-hand part); near and far upper legs, lower legs and feet. Small swinging pieces: the lanyard and blank ID card, and the swapped jacket, vest, tunic or smock for each act's skin. There is no held weapon.

**Pivots:** neck base (the head tilts to one side), shoulders, elbows, wrists, hip, knees and ankles; the lanyard at the collar. Paint hidden overlap under every joint, and paint the far limbs and the hidden side of the torso complete.

**Sockets:** no gun or weapon socket, since the grab uses the hand parts. A port-light socket at the port holds the small steady amber point (dark on death). Two hand-glow sockets, one on each palm, hold the large tell glow. A spark socket at the port throws the white implant sparks.

**Normal maps:** one per part (green = up), soft-edged: jacket seams and the pushed-up sleeve, collar and zip, lanyard, rubber grip pads and straps, shoe soles, the staples and port rim, and gentle face modeling with heavy lids so a lamp lights one side of the face.

**Fluid:** human blood (Blood #B3212F, drying to #8A1A26), drawn by the engine: a spray at the hit point, wound marks attached to the hit part and floor pools. The Linked also throw white implant sparks at the port. Blood anchors sit on the head, chest, belly, near upper arm and near thigh.

**Motion and death:** hand-keyed on the rig for the side view (C38): a stiff walk with the arm swing damped, a low crouch-and-lunge grab, a stumble recovery and a hit flinch, plus the hanging arms, the dragging shoe and the crouch. Death is a ragdoll pushed by the killing shot, and the port light goes dark. The body then stays as a static corpse, restored after a death or Continue.

Plan the blood, the tell glows, the muzzle flashes, the implant lights and every other effect as separate layers, never painted into the parts. These are the intended rig components, not a finished rig: the lit Night Guard test settles the tool, the pivots and the clip retargeting.

## Required pose and state references

Neutral slouch; walk (stiff shuffle); routine (ID-card tap, flavor only); windup (twitch, then the low crouch with the hands out); attack (the low grab lunge); stumble recovery (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the grab hands (open with padded palms out, closed grip).

Tell by pose: the twitch and the low crouch with the hands out are the windup, and the engine adds the large amber-then-red glow on both hands over that pose. The small steady amber point at the port is separate: it is present through every driven pose and goes dark on death. The resting corpse pose is the one authored pose restored after a death or Continue: crumpled where it fell, ID card askew.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Realistic adult proportions (about 7.25 heads), two arms and two legs, one port, two padded grips. No held weapon, no armor plates, no full robotic body, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. Eyes half open and unblinking, with no glow. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant is medical hardware, never drawn as monstrous in itself.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. The pushed-up sleeve, the dragging shoe and the lanyard sit on the near side and are safe to mirror. The port is a small separate head part, a round disc with no handedness, so it sits behind the near ear in either facing. The workwear skins swap only the jacket part.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views. The design it describes is *proposed*.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Paint a single evenly lit, flat-color, side-view full-body painting of one character, facing right, on a flat mid-grey background (about #808080), suitable for splitting into rig parts: broad flat base colors with clean dark outlines (heavier outer contours, restrained interior lines), no baked shadows, no cel-shadow shapes, no painted highlights or rim light, no gradients, no glow, no blood painted in and no gun painted in. Use a relaxed open stance with the limbs slightly apart (the near arm, the one toward the camera, forward; the far arm back; feet flat on one baseline) so every part can be cut cleanly, and paint the far limbs complete. Paint every lamp, lens and implant light as dark, unlit glass or plastic; the engine adds all light.

Design Staffer, a Linked person: a night-shift Arcadia employee in facilities and office support, driven by Adam through a stapled implant port behind the ear. Role: Basic Linked enemy: a person driven through a broken routine, who drops into a low lunge and grabs. It never blocks progress.
Scale: About 1.72 m upright, roughly 7.25 heads, and about 1.60 m in its habitual slouch, with a soft, slightly heavy build.
Silhouette: A soft, slightly pear-shaped office-worker body with a small forward head tilted to one side, drooping shoulders, arms hanging a little away from the torso as if held on strings, and two stiffly bent legs. It reads as an everyday person in a work jacket; only the padded grips strapped over both palms and the stapled port behind the ear hint at anything wrong. In grayscale it is the softest, most slouched human shape in the roster, with a bare head, no headgear and no held item.
Physical design: The Act 1 workwear, which is the default skin: a navy Arcadia staff jacket zipped halfway over a pale shirt with a loosened collar, charcoal trousers and scuffed slate shoes with pale rubber soles. The near sleeve is pushed up above the elbow, and the near shoe drags. A lanyard holds a blank ID card. Both hands wear padded restraint grips: slate rubber pads strapped over the palms with graphite wrist straps, which carry the tell glow in play. The face has heavy eyelids that stay half open, an unfocused gaze, a slack lower lip and tired shadows under the eyes. The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). The scalp is close-shaved. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. There are no logos or legible text.
Materials and colors: skin #BC957B; navy jacket #2C3D5A; pale shirt #D3DAE0; charcoal trousers #2F3948; slate shoes #46546A with pale rubber soles #B9C4CF; slate grips #46546A with graphite straps #2A3341; blank ID card #D8DEE4; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45; under-skin neck lines #4A4F63. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, and a large amber then Alarm red #FF3B4E glow on both hands as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in.
Critical consistency: Realistic adult proportions (about 7.25 heads), two arms and two legs, one port, two padded grips. No held weapon, no armor plates, no full robotic body, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. Eyes half open and unblinking, with no glow. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant is medical hardware, never drawn as monstrous in itself.
Use a relaxed neutral pose that reveals the silhouette and joint structure: stiff in its habitual slouch with a vacant expression, arms hanging a little away from the body, the grips open; no active attacks or enemies nearby.

One complete 2D subject only, centered and fully visible on a flat mid-grey background (about #808080), in a strict side view facing right, with generous margins. No airbrushed or studio-light gradients, glossy chrome, volumetric light, photorealism, pixel art, perspective camera effects, environment, action effects, UI, text, logos, watermark, labels, measurement arrows, franchise costumes or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Create a clean 2D directional study of the attached approved Staffer design for DEAD EDEN. This is the same exact asset, not a redesign. Show the design facing right and facing left as two separate drawings on the same canvas scale and foot baseline. The left-facing drawing is a plain mirror of the right-facing rig parts, so carried items swap sides with it and must still read correctly. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Maintain these proportions: About 1.72 m upright, roughly 7.25 heads, and about 1.60 m in its habitual slouch, with a soft, slightly heavy build. Maintain these defining forms: A soft, slightly pear-shaped office-worker body with a small forward head tilted to one side, drooping shoulders, arms hanging a little away from the torso as if held on strings, and two stiffly bent legs. It reads as an everyday person in a work jacket; only the padded grips strapped over both palms and the stapled port behind the ear hint at anything wrong. In grayscale it is the softest, most slouched human shape in the roster, with a bare head, no headgear and no held item. Preserve construction: The Act 1 workwear, which is the default skin: a navy Arcadia staff jacket zipped halfway over a pale shirt with a loosened collar, charcoal trousers and scuffed slate shoes with pale rubber soles. The near sleeve is pushed up above the elbow, and the near shoe drags. A lanyard holds a blank ID card. Both hands wear padded restraint grips: slate rubber pads strapped over the palms with graphite wrist straps, which carry the tell glow in play. The face has heavy eyelids that stay half open, an unfocused gaze, a slack lower lip and tired shadows under the eyes. The Link signature: behind the near ear sits the Link port, a coin-sized dark disc with a pale steel rim, sealed into the skin with a ring of six to eight tiny bright staples and surrounded by a faint dusky bruise ring, with a thin seam running down the nape into the collar and faint dark lines under the skin of the neck (the cables under the skin; nothing is exposed). The scalp is close-shaved. The port is painted dark and unlit; when Adam drives the body the engine adds a small, dim, steady amber point there, and when the body dies the light goes dark. The eyes are half open and unblinking, with no glow. The port is medical hardware, never a monster feature, and nothing is exposed. There are no logos or legible text. Preserve the palette: skin #BC957B; navy jacket #2C3D5A; pale shirt #D3DAE0; charcoal trousers #2F3948; slate shoes #46546A with pale rubber soles #B9C4CF; slate grips #46546A with graphite straps #2A3341; blank ID card #D8DEE4; port disc #2E3B4E with pale steel rim #9AA5B1; staples #C8D0D8; bruise ring #7A4A45; under-skin neck lines #4A4F63. Lights are added by the engine and never painted: a small steady Hazard amber #FFB02E point at the port, and a large amber then Alarm red #FF3B4E glow on both hands as the tell. Blood #B3212F (dried #8A1A26) is added by the engine, never painted in. Lock these details: Realistic adult proportions (about 7.25 heads), two arms and two legs, one port, two padded grips. No held weapon, no armor plates, no full robotic body, no exposed wiring, organs or wounds, no readable text or logos, no violet or purple. Eyes half open and unblinking, with no glow. No blood, wound, glow or shadow painted into the parts. No dismemberment. The implant is medical hardware, never drawn as monstrous in itself. Keep all parts fully in frame and clearly separated; show both drawings without overlap. Use a neutral repeatable pose with the limbs slightly apart, no action effects, no scenery. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest pose reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached approved 2D identity reference.

Using the attached approved Staffer reference, draw one clear full-body 2D animation key pose in strict side view facing right, showing one state selected from this list: Neutral slouch; walk (stiff shuffle); routine (ID-card tap, flavor only); windup (twitch, then the low crouch with the hands out); attack (the low grab lunge); stumble recovery (the opening); hit reaction; death launch (first ragdoll frame); resting corpse pose; the grab hands (open with padded palms out, closed grip). If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Keep the painting evenly lit and flat-colored, with clean dark outlines, on a flat mid-grey background (about #808080): no baked shadows, no rim light, no glow, no blood painted in and no gun painted in. Movement language: A stiff, puppet-like shuffle with the near shoe dragging and the head or a hand twitching between steps. Now and then the Staffer stops and repeats a fragment of its old job, tapping its ID card against a door reader that is not there (flavor only; it changes no timing). Then the twitching builds into the windup: the head snaps sideways, a shoulder hitches, the fingers flutter and the body drops into a crouch with the hands out. The lunge is suddenly too fast, with the head and torso leading before the feet catch up. A missed grab leaves it stumbling forward, arms out and off balance: that stumble is the opening. It does not blink. Capability: A slow approach ending in one fast low grab; threat grows in groups rather than through complex individual attacks. Important limitation or opening: The stumble after a missed grab is the opening, and the long twitching windup gives Dave time to jump. Do not add armor plates, a held weapon or a glowing chest core: the port is a small light behind the ear, not a weak-point target. The Staffer never blocks Dave's route. Tell: GLOW on both hands, amber first and then red for the last 0.25 s, added by the engine; paint the grips dark. The small amber point at the port is separate and is also added by the engine. Keep effects out of the painting so the body silhouette is visible; the engine adds every glow, flash, spark and drop of blood. No cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Approve a neutral painting for this asset before splitting it into parts; none is selected yet. Paint it after the lit Night Guard test has settled the look.
- Split the approved painting into the rig parts above, with hidden overlap under every joint and the far limbs painted complete. Make a matching normal map for every part (green = up, same size and layout) and check the lit result under a moving lamp.
- Check both facings in the lit test, so the mirrored parts still take light from the lamp's side. The pushed-up sleeve, the dragging shoe and the port must read correctly flipped.
- Check the silhouette and the readability at gameplay size in the engine, in grayscale and against near-black backgrounds, next to the other people types: the Night Guard (cap and baton), the Linked Lineman (hard hat and capacitor pack) and the Linked Nurse (scrub cap and tray). The Staffer reads by the bare head, the slouch and the hanging arms. The tell must read by pose and glow with the night overlay on.
- Hand-key each move (a damped stiff walk, low crouch-and-lunge, stumble, hit flinch) for the side view (C38). Check that the port stays visible at gameplay size and that the glow reads on both palms.
- Keep blood, tell glows, muzzle flashes, implant lights and effects as separate layers. A concept painting is not a finished rig, atlas or validated animation.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

# Hound

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** K01\
**Category:** hounds\
**First appearance:** Level 2 (Curfew), with a Night Guard handler through Level 3; Adam-driven in Levels 7–8; Garden-built in Level 11\
**Design status:** Roster entry confirmed (C30, C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Cyborg guard dog and the first fast melee threat: it drops low, lunges, lunges again, then stands rigid.

**Who built and fields it *(proposed)*:** Arcadia Security runs a K9 unit on the Sunnyvale campus. The dogs are real working dogs, shepherd-type, fitted with Arcadia's K9 augmentation: debarked so they work in silence, a steel jaw, a lens in place of one eye, armored plates and a cable bundle where the tail was. Night Guards ([SE01](../security/se01-night-guard.md)) handle them on the campus grounds at night in Levels 2 and 3 (Act 1), starting with Curfew. In Levels 7 and 8 Adam drives the same dogs directly through their collar modules, with no handler. In Level 11 it casts its own copies in raw ceramic in the Garden.

**Why it attacks Dave:** in Act 1 the handler sets it on Dave, who has been flagged as an intruder after curfew. Later Adam simply sends it. It is an animal doing what it was trained to do, which is what makes it unsettling rather than cute. The hardware is shown as a working kit, not as horror for its own sake.

## Scale and silhouette

0.70 m at the shoulder plates; about 1.30 m from nose to rump, plus a 0.40 m cable tail. In the lunge the body stretches to about 1.70 m.

A lean, deep-chested shepherd-type dog held low and forward: a long muzzle with a heavy steel lower jaw that hangs slightly forward, two upright ears, a ridge of overlapping armor plates along the spine, a plated shoulder guard, and a thick cable bundle trailing where the tail was. The steel jaw, the spine ridge and the cable tail make it read as a modified working dog at gameplay size.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.* A real dog first, with the hardware fitted in clean, clinical ways.

- **Body:** shepherd-type build with a short, dense coat: black saddle over the back, tan on the legs, muzzle and chest. Small shaved patches at the plate edges show pale skin and neat rows of surgical staples. Real paws with dark pads and visible claws; no boots.
- **Head:** a natural upper muzzle and skull with a dark nose. The lower jaw is a steel mandible with a row of small blunt steel teeth and a round servo capsule at the hinge. It is held shut at rest: no tongue and no panting. The near-side eye (the anatomical right eye in the right-facing painting) is a round camera lens in a steel bezel; the far-side eye is natural, dark and unblinking. Both ears stand upright.
- **Throat and collar:** a wide gunmetal collar band carries the K9 control module at the throat, which is also the debarking hardware. A small status light sits on each side of the band, so the state reads from both facings.
- **Harness and plates:** an Arcadia-grey tactical harness (the guards' livery, [SE01](../security/se01-night-guard.md)) with a rigid grab handle across the shoulders, a pale reflective band and a small white Arcadia emblem patch on the near shoulder (an abstract arch-and-leaf mark, no lettering; the final logo is authored separately). Overlapping ivory-grey plates guard the shoulder and run along the spine as a ridge of five linked plates, bolted through the harness at clean seams. No leash is drawn, only a short cut-off leash ring on the handle.
- **Tail:** the tail is gone. A rubber-sleeved bundle of braided black cables leaves a sealed port plate on the rump and trails low, ending in a capped connector plug. It sways against the steps.

**Adam-driven skin** *(Levels 7–8, proposed)*: the same body and plates, repainted. The handle and leash ring are cut away, the coat is matted and the plates are scuffed.

**Garden-built skin** *(Level 11, proposed)*: Adam's copy, cast in raw ceramic on the same skeleton, with the same plates, jaw and cable tail but no fur and no harness. Pale, unglazed shells with visible casting seams and dark seam lines, a lens in both eye sockets, and a ceramic jaw on a steel hinge. It is a repaint of the same parts, and like every Garden-built variant it shortens only the amber part of the tell; red stays 0.25 s.

## Color and materials

*Proposed palette (Arcadia K9):* coat black #24211F and tan #A9784A; shaved skin #C9A08A; gunmetal #5A6B80 for the jaw, eye bezel and collar; plate ivory-grey #C9CCC4; harness Arcadia grey #4B5663 with a pale band #D3DAE0 and an emblem patch white #E9EDF0; cable sleeve near-black #1C232B; lens glass #14181E. *Garden-built skin:* cool ceramic #D8DEE3, ceramic shadow #8FA1B0 (far-side legs and recesses, a flat color), seam dark #2E3B4E, joint navy #0E1726.

Everything is painted as flat base colors with clean dark outlines and no baked shadow. The engine's lamps light the coat, plates and jaw smoothly through their normal maps. Keep the tan coat and the plates in mid-to-light values so the dog holds its silhouette when the scenery is dim; the black saddle is the only large dark area. Paint the far-side legs and ear a few percent darker as a flat local color, not as a shadow.

**Light and fluid *(proposed)*:**

- While the dog hunts, the lens eye shows only a small, dim, steady amber point (#FFB02E), as on every driven or hunting body. Otherwise it is dark glass.
- Collar lights (a repeater on each side, so the state reads from both facings): steady teal #3FE0D0 while the dog is idle or waiting under a handler, and the same small, dim, steady amber point once it hunts. Neither is a large glow, and neither is a detection or alert state (C16).
- The tell is a large additive glow on the jaw, along the teeth line and the hinge capsule: amber, then alarm red #FF3B4E for the last 0.25 s, on every lunge.
- Blood is red #B3212F, drying to #8A1A26, drawn as a separate spray, wound marks and floor pools, never painted into the base art. The plates throw white sparks instead. Blood never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- The Garden-built skin does not bleed red. It drips grey-rose lymph #A88A8C under gravity only, like an Heir *(proposed)*, and its lens eyes carry the same small amber point when it hunts.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Charger (light, with a dash counter) (C26). **Weapon:** steel jaw bite (melee). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** it drops low, chest near the floor and haunches up, as the jaw glows amber and then red (red for the last 0.25 s), with a wet wheeze. It is debarked, so there is no bark.
- **Attack:** a lunge of 2 H along the floor. After a 0.5 s crouch it lunges again with its own amber-then-red blip: 2 lunges in Act 1, 3 in Levels 7–8 and 11. At least 0.9 s pass from one lunge to the next. In Act 1 the handler's own wind-up starts 1.5 s after the chain ends, so dog and handler never attack together.
- **Counter:** jump each lunge, then shoot it during its rigid recovery. Aim slightly down. 2 hits.

It trots low, head below the shoulders, jaw shut and cable tail swaying against the steps. It never pants, wags or barks. In recovery it skids to a stop with the legs braced stiff, the head up and the jaw glow gone.

**Death:** it bleeds red and sparks at its plates, its legs twitch for about 1 s, and the body then stays as a static corpse.

## Openings and limitations

The rigid recovery after each lunge chain: a braced, stiff stop with the jaw dark. There is no armored weak point and no invulnerable state. The plates protect the shoulder and spine, but a hit anywhere counts. Keep the whole body one low, readable target.

## Rig parts, normal maps and sockets

- **Parts (four-legged rig, rigid parts):** head (skull and upper muzzle, with both ears attached); lens eye (its own part, on the near-side eye); lower steel jaw; neck; collar module with a separate light layer on each side; chest; rump; harness and handle (an overlay part, so the skins can swap it); shoulder plate; five spine plates; four legs, each in two parts (upper leg; lower leg with paw, the hind legs with a clear hock); tail cable in two segments with its plug.
- **Pivots:** neck base; jaw hinge at the servo capsule; the top of each upper leg; the knee or elbow and the hock; the tail root at the port plate; the rump as the root part.
- **Normal maps:** one per part, green = up: fine fur-flow relief on the coat, crisp bevels and bolt heads on the plates, brushed bevels and tooth relief on the jaw, a domed lens, round tubes with wrap ridges on the cable, tiny bumps for the staples.
- **Sockets:** no gun socket. Light sockets at the two collar lights, the lens eye and the jaw (the additive tell glow, attached to the lower jaw part). Spark points at each plate.
- **Fluid:** red blood: a spray at the hit point along the shot direction, wound marks attached to the hit part and a floor pool that glints under lamps. The Garden-built skin drips grey-rose lymph instead. Both are separate from the painted art.
- **Motion and death:** Mixamo clips are humanoid, so the dog's trot, crouch, lunge and stiff stop are hand-keyed on the rigid parts *(proposed)*. On death the parts become physics bodies pushed by the killing shot (a ragdoll), still joined at their pivots: no dismemberment (C29). The four leg parts twitch for about 1 s (a two-frame swap), then the body settles as a static corpse with a blood overlay.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Standing side view (neutral, jaw shut, legs apart so the near and far legs separate); stalking trot; tell crouch (low, jaw glow amber, then red); lunge (body stretched, jaw open); rigid recovery (braced stop); hit reaction; death frame (on its side, legs out) and the two-frame leg twitch. Skins: Arcadia K9 (teal collar lights while idle), Adam-driven (no handle, small amber collar lights) and Garden-built (raw ceramic).

Show lamp and jaw states as flat colored shapes with no glow halo: amber in the first half of the tell crouch, red in the last quarter, dark in recovery. Glows, sparks and blood are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Four legs, one steel lower jaw, one lens eye (on the near side) and one natural eye (on the far side), one cable bundle where the tail was, one shoulder plate and five spine plates. No tail, no tongue, no panting, no barking pose, no wagging, no floppy ears and no cute proportions. No leash drawn, no human features, no exposed organs or bones and no dismemberment. Plates never cover the jaw hinge or the lens. Blood, sparks and glows are never painted into the base art, and fluid never uses the tell colors. The collar lights are readability states only, not a detection or alert meter (C16).

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The lens eye is its own part on the near-side eye, so it shows in both facings while the far-side eye stays natural and hidden, and the collar lights repeat the state on both sides. Everything else is symmetric or centered, so the dog mirrors safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Hound, a real security dog (shepherd type) with corporate cyborg augmentation. Role: fast guard-dog charger that drops low, lunges, recovers stiffly and lunges again.
Scale: 0.70 m at the shoulder plates; about 1.30 m from nose to rump, plus a 0.40 m cable tail.
Silhouette: A lean, deep-chested dog held low and forward: a long muzzle with a heavy steel lower jaw that hangs slightly forward, two upright ears, a ridge of overlapping armor plates along the spine, a plated shoulder guard, and a thick cable bundle trailing where the tail was.
Physical design: Realistic dog anatomy with a short black-and-tan coat, and small shaved patches with neat staple rows at the plate edges. The lower jaw is a steel mandible with small blunt steel teeth and a round servo capsule at the hinge, held shut: no tongue, no panting. The near-side eye is a round camera lens in a steel bezel; the far-side eye is natural and dark. A wide gunmetal collar band with a control module at the throat and one small unlit status lamp on each side. An Arcadia-grey tactical harness with a rigid grab handle across the shoulders, a pale reflective band and a small white emblem patch with no lettering. One plate guards the shoulder and five overlapping ivory-grey plates run along the spine. The tail is replaced by a rubber-sleeved bundle of braided black cables ending in a capped plug.
Materials and colors: Coat black #24211F and tan #A9784A; shaved skin #C9A08A; gunmetal #5A6B80 for the jaw, eye bezel and collar; plate ivory-grey #C9CCC4; harness Arcadia grey #4B5663 with a pale band #D3DAE0 and a white emblem patch #E9EDF0; cable sleeve #1C232B; lens glass #14181E. Lamps and the lens are flat, unlit discs.
Critical consistency: Four legs, one steel jaw, one lens eye, one shoulder plate, five spine plates, a cable bundle instead of a tail. Unsettling, not cute: no tongue, no floppy ears, no wagging pose, no cartoon proportions, no exposed organs or bones.
Use a standing side view with the legs slightly apart so the near and far legs separate, head level and jaw shut; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Hound design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 0.70 m at the shoulder plates; about 1.30 m from nose to rump, plus a 0.40 m cable tail. Maintain these defining forms: A lean, deep-chested dog held low and forward: a long muzzle with a heavy steel lower jaw that hangs slightly forward, two upright ears, a ridge of overlapping armor plates along the spine, a plated shoulder guard, and a thick cable bundle trailing where the tail was. Preserve construction: Realistic dog anatomy with a short black-and-tan coat, and small shaved patches with neat staple rows at the plate edges. The lower jaw is a steel mandible with small blunt steel teeth and a round servo capsule at the hinge, held shut: no tongue, no panting. The near-side eye is a round camera lens in a steel bezel; the far-side eye is natural and dark. A wide gunmetal collar band with a control module at the throat and one small unlit status lamp on each side. An Arcadia-grey tactical harness with a rigid grab handle across the shoulders, a pale reflective band and a small white emblem patch with no lettering. One plate guards the shoulder and five overlapping ivory-grey plates run along the spine. The tail is replaced by a rubber-sleeved bundle of braided black cables ending in a capped plug. Preserve the palette: Coat black #24211F and tan #A9784A; shaved skin #C9A08A; gunmetal #5A6B80 for the jaw, eye bezel and collar; plate ivory-grey #C9CCC4; harness Arcadia grey #4B5663 with a pale band #D3DAE0 and a white emblem patch #E9EDF0; cable sleeve #1C232B; lens glass #14181E. Lamps and the lens are flat, unlit discs. Lock these details: Four legs, one steel jaw, one lens eye, one shoulder plate, five spine plates, a cable bundle instead of a tail. Unsettling, not cute: no tongue, no floppy ears, no wagging pose, no cartoon proportions, no exposed organs or bones. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

For a skin study, add one of these sentences to the end of the block. Adam-driven: "Repaint the same approved dog as the Adam-driven Hound: no harness handle or leash ring, a matted coat, scuffed plates, and small dim amber collar lamps in place of teal." Garden-built: "Repaint the same approved dog as the Garden-built Hound: raw unglazed pale ceramic shells with dark seam lines, no fur, no harness, a lens in both eye sockets and a ceramic jaw on a steel hinge; same plates, same cable tail."

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Hound reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Standing; stalking trot; tell crouch; lunge; rigid recovery; hit reaction; death frame. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It trots low with the head below the shoulders and the cable tail swaying against the steps. Before a lunge it drops low, chest near the floor and haunches up. The lunge stretches the body long with the jaw open. It ends in a rigid, braced stop. Capability: Lunges 2 H along the floor with its steel jaw, repeats after a short crouch, then stops rigid. Important limitation or opening: Its rigid braced recovery is the opening; there is no armored weak point. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks, oil or gun: the standing and trotting poses show one small flat teal collar lamp on each side and a dark jaw; the first half of the tell crouch shows the jaw seam and teeth line flat amber (#FFB02E) and the last quarter flat alarm red (#FF3B4E); the lunge keeps a red jaw seam; the rigid recovery shows a dark jaw; the death frame shows every lamp dark. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- No image is approved for this asset yet. Approve one neutral image (prompt 1) before producing animation poses.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art, and check the mirrored rig in the lit test.
- Split the approved painting into the rig parts listed above, with hidden overlap under every joint and the hidden areas (far limbs, anything a part covers) painted complete, and make a matching normal map for each part (green = up) once the flat painting is approved. The image generator prompts here ask only for the flat-color painting.
- Check the silhouette and every tell at gameplay size, in grayscale, and lit in-engine against dark night scenery with one lamp from the left and one from the right, so the normal maps light correctly on both facings.
- Establish a consistent canvas, ground baseline, socket and pivot intent; draw a few key poses before adding small details.
- Keep blood, sparks, oil, glows, muzzle flashes and light pools separate from the parts. A concept PNG is not a finished sprite sheet, layered source file, rig or validated animation.
- The lit cutout look is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): re-check this brief against the approved test look before production.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

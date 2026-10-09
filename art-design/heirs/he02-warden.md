# Warden

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../style-guide.md)).

**Asset ID:** HE02\
**Category:** heirs\
**First appearance:** Level 11 (The First Patient); returns in Level 12\
**Design status:** Roster entry confirmed (C31). Art method: lit cutout rig (C35), confirmed direction, validated by the approved lit-cutout test (2026-09-30). This asset's identity, appearance, palette and lore below are *proposed*; no concept image is selected yet. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

*Proposed:* an armored Heir gunner that lowers its front plate to fire one slow plasma bolt from its palm.

Heirs are Adam's synthetic people: pale-ceramic shells over grown tissue, with teal seams and a soft mask that projects a borrowed face, trained on minds Adam copied in the Memory Orchard. The Fitted Heir ([HE01](he01-fitted-heir.md)) introduces them in Level 10 (see its [introduction scene](he01-fitted-heir.md#introduction-scene-proposed-l10)). The Warden is cast on a copied Arcadia security officer: its borrowed face, its stance and its shouted "Drop it!" are a dead guard's habits, imitated exactly. It guards the Garden's inner halls in Levels 11 and 12.

**Why it attacks Dave:** Adam posts the Warden in front of what it wants kept, and the Warden treats Dave as the one who must drop it. The recording is a dead guard's; the plasma emitter grown into its palm is Adam's own technology ([EG07](../enemy-guns/eg07-plasma-gun.md)).

## Scale and silhouette

1.95 m tall; about 0.70 m across the shoulders; the front plate is about 0.55 m wide and 1.20 m tall. Realistic adult proportions, about 7.5 heads tall.

A broad-shouldered security stance: a tall front plate on the near-side forearm, a raised back housing and a double-image mask. With the plate raised it is a wall of ceramic and steel. With the plate lowered and the far-side palm raised, the silhouette opens into a clear gunman.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design.*

- **Plate:** a tall tower plate carried on the near-side forearm (the anatomical right, in the right-facing painting): a dark steel core with a pale ceramic rim, one corner cracked but the plate still functional. Raised, it covers the torso and head from the front; lowered, it hangs at the side. It is a separate rig part with two states.
- **Palm emitter:** the far-side hand's palm holds the emitter, an 0.08 m ceramic disc with an empty pale blue-tinted glass panel and a dark pearl emitter ring with a dark outline. It is an overlay on the hand part, with its socket at the palm center. The plasma ball is an effect.
- **Shell:** ceramic torso and limbs fitted with a molded security-officer vest and blank chest pouches, a patrol-cap crest over the mask, and hairline teal seams.
- **Back housing:** a raised core housing on the upper back under lifted back plates, with two teal seam cables running through slots into the neck and the near-side shoulder. It is a silhouette feature, not a target.
- **Double-image mask:** the soft slate mask is one panel with a seam down its center. It projects two profile faces slightly out of register: one calm borrowed face, and a second, displaced, flickering face, like a badly aligned projection. It is one mask on one head. At rest and when destroyed, the mask is blank.
- **Damage:** the ceramic cracks where it is hit, with grown grey-rose tissue underneath, as on the Fitted Heir ([HE01](he01-fitted-heir.md)). Cracks are separate overlay layers per part.

## Color and materials

*Proposed palette:* cool ceramic #D8DEE3 for the torso, limbs and plate rim; steel #1C2A3A for the plate core; slate #2E3B4E for the undersuit and mask; ceramic shadow #8FA1B0 for the far-side limbs (a flat color, not a painted shadow); joint navy #0E1726; seam teal #3FE0D0; palm emitter glass #BFD8EE (empty in the base art) in a dark pearl ring #C9D3DA.

Everything is painted as flat base colors with clean dark outlines and no baked shadow. The engine's lamps and the plasma's glow light the ceramic smoothly through its normal maps. Keep the plate core dark but lighter than pure black so it reads as a separate shape from the body, and keep the ceramic below pure white so lamplight still reads as light.

**Light and fluid *(proposed)*:**

- The seams glow a steady, dim teal at rest. While it hunts, a small, dim, steady amber point (#FFB02E) shows at the mask's eye, as on every driven or hunting body, and the seams stay teal.
- The tell (CHARGE) is a large additive glow ring around the palm emitter: amber, then alarm red #FF3B4E for the last 0.25 s, while the plasma ball swells and a deep hum rises. The ball inside is white with a #5AA9FF edge and a dark outline ring, never amber, red or teal.
- The mask flicker is teal-white and never red.
- Destroyed, everything goes dark.
- It drips grey-rose lymph #A88A8C (80% alpha) from the cracks under gravity only, never sprayed along the shot line, and leaves a grey-rose floor pool. Lymph never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- Light is a readability cue, not a detection or alert state (C16).

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Gunner + front armor (C26). **Weapon:** Plasma Gun, the "Lumen" emitter built into the palm ([EG07](../enemy-guns/eg07-plasma-gun.md)). Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (CHARGE):** it lowers its plate and raises the palm; the emitter glow grows amber and then red (red for the last 0.25 s) while a dead guard's recording shouts "Drop it!" and a deep hum rises.
- **Attack:** one slow plasma bolt, 0.5 H across at 3.5 H/s, flat at 0.5 H, 2 damage on a direct hit. It bursts on impact in a 1.0 H radius for 0.15 s (1 damage, blocked by walls).
- **Counter:** jump the bolt and stay clear of the burst, then shoot while the plate is down during the 1.4 s vent. 4 hits.

It stands in a disciplined guard posture, plate up, and moves in slow, measured steps. Its motion is hand-keyed for the side view (C38), and its death is a ragdoll.

## Openings and limitations

The plate is the guard: raised, it blocks Dave's bolts from the front. During the vent the plate stays lowered, the palm's emitter ring dims to the small amber point and a thin pale wisp rises from it; that is the opening. Hits on its back or lowered side count normally. Cracks and lymph show where it has been hit.

## Rig parts, normal maps and sockets

- **Parts (humanoid rig):** head with cap crest; mask (one part) with two separate face-projection layers; torso with the vest; pelvis; upper and lower arms; two hands, with the far-side hand as the weapon hand; upper and lower legs; two feet; the tower plate (on the near-side forearm, with two states, raised and lowered); the palm emitter (its own small overlay part on the weapon hand); back housing with two seam cables.
- **Overlays:** crack and grown-tissue overlays per part (two damage stages); seam glow masks (emissive, one per part).
- **Pivots:** the pelvis as the root; the neck base; shoulders, elbows and wrists; hips, knees and ankles; the plate moves with the near-side forearm between raised and lowered.
- **Normal maps:** one per part, green = up: matte ceramic with crisp seam grooves, the steel plate core with bevelled edges and a cracked corner, a domed glass emitter panel, ribbed cables.
- **Sockets:** the gun socket is the palm center of the weapon hand, where the [EG07](../enemy-guns/eg07-plasma-gun.md) palm-emitter overlay sits, with its own muzzle-flash light and the bolt's spawn point. The emitter is grown into the palm, so it never drops. Light sockets along the seams, at the emitter ring and on the mask.
- **Fluid:** grey-rose lymph: a drip from the hit part under gravity only, wound marks attached to the hit part and a floor pool, separate from the painted art.
- **Motion and death:** hand-keyed on the rig for the side view (C38): the guard steps, the plate lower and the palm raise. Death is a ragdoll: the parts become physics bodies pushed by the killing shot and stay joined at their pivots (no dismemberment, C29), the seams and emitter go dark, and the body settles as a static corpse with a lymph pool.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Neutral for the identity image (plate lowered at the side, palm turned inward, mask blank, so every part is visible); guard (plate up); plate lowered with the palm raised (the tell: emitter amber, then red); bolt release; vent (plate down, emitter dim); hit reaction with cracks and tissue; death (ragdoll corpse); double-image mask study. Draw the plasma ball in state studies only as a plain flat white disc with a blue edge.

Show seams, the emitter ring and the mask as flat colored shapes with no glow halo. Glows, the plasma effect, cracks, tissue and lymph are added later as separate layers.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

Two arms and two legs, no extra head or tail. The plate stays on the near-side forearm and the emitter on the far-side palm. One soft mask with a seam and two projected faces, never two heads. No held gun. The mask flicker is teal-white, never red; red appears only as the emitter tell. Hard ceramic and hardware apart from the soft mask, with tissue only inside cracks: no exposed organs or bone and no dismemberment.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. The plate is carried by the near-side arm and the emitter sits on the far-side hand in both facings, each on its own part, so the rig can swap which arm carries the plate if a mirrored facing needs it. The back housing sits on the centerline, and the mask is a profile drawing on its own part.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish.

Design the Warden, one of Adam's synthetic people: a pale-ceramic security-officer body with teal seams, a soft mask and a front plate. Role: armored Heir gunner that lowers its front plate to fire one slow plasma bolt from its palm.
Scale: 1.95 m tall; about 0.70 m across the shoulders; the front plate about 0.55 m wide and 1.20 m tall; realistic adult proportions, about 7.5 heads tall.
Silhouette: A broad-shouldered security stance: a tall front plate on the near-side forearm, a raised back housing and a soft mask. Raised, the plate makes a wall of ceramic and steel.
Physical design: A tall tower plate on the near-side forearm, a dark steel core with a pale ceramic rim and one corner cracked but the plate still functional, hanging lowered at the side so the torso is visible. The far-side palm holds a small 0.08 m ceramic disc with an empty pale blue-tinted glass panel in a dark pearl ring. Ceramic torso and limbs with a molded security-officer vest and blank chest pouches, a patrol-cap crest, and hairline teal seams. A raised core housing on the upper back under lifted back plates, with two teal seam cables through slots into the neck and the near-side shoulder. The soft slate mask is one panel with a seam down its center, blank. Intact, uncracked ceramic.
Materials and colors: Cool ceramic #D8DEE3; steel #1C2A3A for the plate core; slate #2E3B4E for the undersuit and mask; ceramic shadow #8FA1B0 on the far-side limbs; joint navy #0E1726; seam teal #3FE0D0 as flat, unlit lines; emitter glass #BFD8EE in a dark pearl ring #C9D3DA. Flat base colors only.
Critical consistency: Two arms and two legs, no extra head or tail. The plate stays on the near-side forearm and the emitter on the far-side palm. One soft mask with a seam, blank, never two heads. No held gun, no plasma ball, no blood or lymph, no cracks. No text or logos.
Use a relaxed neutral pose with the plate lowered at the side and the far-side palm turned inward, so every part is visible, the limbs slightly apart for rigging; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit flat painting: flat base colors with clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos, no gradients. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). The small palm emitter disc is part of the hand and is painted empty. Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Warden design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 1.95 m tall; about 0.70 m across the shoulders; the front plate about 0.55 m wide and 1.20 m tall; realistic adult proportions, about 7.5 heads tall. Maintain these defining forms: A broad-shouldered security stance: a tall front plate on the near-side forearm, a raised back housing and a soft mask. Raised, the plate makes a wall of ceramic and steel. Preserve construction: A tall tower plate on the near-side forearm, a dark steel core with a pale ceramic rim and one corner cracked but the plate still functional, hanging lowered at the side so the torso is visible. The far-side palm holds a small 0.08 m ceramic disc with an empty pale blue-tinted glass panel in a dark pearl ring. Ceramic torso and limbs with a molded security-officer vest and blank chest pouches, a patrol-cap crest, and hairline teal seams. A raised core housing on the upper back under lifted back plates, with two teal seam cables through slots into the neck and the near-side shoulder. The soft slate mask is one panel with a seam down its center, blank. Intact, uncracked ceramic. Preserve the palette: Cool ceramic #D8DEE3; steel #1C2A3A for the plate core; slate #2E3B4E for the undersuit and mask; ceramic shadow #8FA1B0 on the far-side limbs; joint navy #0E1726; seam teal #3FE0D0 as flat, unlit lines; emitter glass #BFD8EE in a dark pearl ring #C9D3DA. Flat base colors only. Lock these details: Two arms and two legs, no extra head or tail. The plate stays on the near-side forearm and the emitter on the far-side palm. One soft mask with a seam, blank, never two heads. No held gun, no plasma ball, no blood or lymph, no cracks. No text or logos. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit flat colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature dark sci-fi side-view shooter: realistic adult proportions, clean dark outlines, flat base colors, evenly lit with no baked shadows (lighting is added in-engine), grounded industrial and corporate sci-fi design, unsettling rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Warden reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Guard; plate lowered with the palm raised; bolt release; vent; hit reaction; death; double-image mask study. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It stands in a disciplined guard posture, plate raised, and moves in slow, measured steps. To attack it lowers the plate to its side and raises the far-side palm toward its target, holds still while the emitter charges, and releases one slow bolt. Afterward it stays planted with the plate down while the emitter vents. Capability: Fires one slow plasma bolt from a palm emitter, behind a front plate that blocks bolts from the front while it is raised. Important limitation or opening: During the vent the plate stays lowered and the emitter dims; that is the opening. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, lymph, tissue or sparks, and draw the plasma ball only as a plain flat white disc with a blue (#5AA9FF) edge: the guard shows flat teal seam lines, one small flat amber (#FFB02E) dot at the mask's eye and a dark emitter panel; the plate-lowered pose shows the emitter ring flat amber, or flat alarm red (#FF3B4E) for the last quarter of the charge; the bolt release keeps a red ring; the vent shows a dim amber ring; the death shows dark seams and a dark emitter; in the mask study the mask holds two flat teal-white line-drawn profile faces slightly out of register (a calm one and a displaced one). For hit reactions, draw hairline cracks only, with no tissue or fluid. Evenly lit flat color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
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

# Hand-painted 2D style (2026-10-11)

The user's art target after the pixel-art and pre-rendered 3D tests: **hand-painted 2D**, "Hollow Knight-like" HD sprite art. It is built as its own prototype, `prototypes/sunnyvale-handpainted/` (a copy of `sunnyvale-godot`; the pixel-art prototype stays as it is).

**Order of work (lesson from the 3D look test, C55):** one style frame first. Nothing in the engine changes until the user approves a still. The approved frame becomes the reference image attached to every later sheet prompt, so the sheets share one style.

## Style frame prompt

Generate at 16:9 (about 1920 x 1080 or the generator's nearest size). Save the chosen image as `concept-art/style-handpainted/style-frame-v1.webp` (store only; it is processed only on "process").

> Hand-painted 2D side-scrolling action game screenshot, in the style of Hollow Knight and Ori: painterly, soft brush texture, clean readable silhouettes, hand-drawn line work, high resolution, no pixel art, no 3D render, no text, no UI.
> Scene: a high-tech corporate campus at night, seen strictly from the side. In front, a wet stone walkway along the top of a dark brick retaining wall; puddles reflect orange and teal light. A tall slim street lamp casts a cold white pool of light. Behind, two-storey glass office pavilions with warm amber lit windows, desk plants in silhouette and roof gardens of dark trees lit warm from below; further back, a hazy skyline of glass towers with a few lit windows and one tower with a glowing teal arch emblem; a deep navy night sky with soft clouds. Layered depth with atmospheric fog between the layers; the far layers soft and blue.
> Characters, small in the frame (about one sixth of the image height), standing on the walkway under the lamp: on the left, Dave Harlan, a lean Caucasian man in his late thirties with short messy brown hair, burnt-orange zip jacket over a charcoal hoodie, white ID card on a lanyard, dark cargo trousers with knee pads, brown boots, fingerless gloves, aiming a chunky rust-red and cream nail-gun pistol with copper coils. On the right, facing him, a fit, broad-shouldered middle-aged Caucasian night security guard of average build (no big belly) in a navy uniform jacket with neon lime piping, a peaked cap with a lime band, raising a black baton whose tip glows amber.
> Palette: deep navy, slate and teal, warm amber accents; light is the focal point. Moody, quiet, tense.

**Check before approving:** the characters read clearly at their small size; the style is painted, not pixel art or 3D; the walkway reads as walkable (a clear lit top edge); the colours match the existing night look (navy, teal, amber).

## Style decision (2026-10-11)

The user approved the look of [style-frame-v1.webp](../concept-art/style-handpainted/style-frame-v1.webp): **"keep the detailed painterly look"** (not Hollow Knight's flatter shapes). Asked for after v1: a slimmer guard ("security guard is too fat"); his build is set by his parts sheet below, not by the frame. Readability rule for the game: the layers behind the walkway are darker and fogged, and characters and enemies keep a rim light, so the busy painting never competes with a fight.

## Sheets (ChatGPT, one chat, the style frame attached to every prompt)

Order: 1 Dave, 2 walkway and wall, 3 office pavilions, 4 sky and skyline, 5 props, 6 Night Guard (three variants), 7 Scrapjack. Later enemies (the Staffer and the rest of the roster) get 2 or 3 variants the same way. Ask for a 3:2 landscape image (1536 x 1024) with a transparent background unless the prompt says otherwise. Save each as named; they are stored only and processed on "process".

Every prompt starts with this paragraph:

> Match the attached style frame exactly: the same detailed hand-painted 2D style, brushwork, palette (deep navy, slate, teal, warm amber) and night mood. High resolution, clean painted edges, strict side view, flat orthographic, no perspective. No text, no labels, no grid, no UI, no pixel art, no 3D render.

**1. Dave Harlan parts sheet** → `concept-art/h01-dave/h01-dave-parts-hd-v1.png`

> [style paragraph] A cutout-rig parts sheet of one character for a 2D side-view action game: Dave Harlan, a lean Caucasian man in his late thirties (fair skin), short messy brown hair, light stubble, a tired determined face; a burnt-orange zip jacket over a charcoal hoodie, a white ID card with a red band on a lanyard, dark charcoal cargo trousers with black knee pads, brown leather boots, black fingerless gloves, a small black pouch at the right hip. No weapon. Paint the parts evenly lit (soft painted shading for form and folds, no cast shadows, no rim light, no glow), because the game lights them itself. Transparent background, each part separate and complete with clear space around it, all at the same scale, as seen facing right. Parts, once each: 1 head facing right with the neck extending below the collar line; 2 the hoodie's hood on its own, as it hangs behind the neck; 3 torso: the jacket from collar to waist, open at the front over the hoodie, no arms, shoulders complete, the hem a little below the waist; 4 pelvis: belt and pouch down to the top of the legs, no legs; 5 upper arm hanging straight down, shoulder at the top; 6 forearm hanging straight down, elbow at the top, ending at the wrist; 7 a gloved hand closed round an empty grip (the gun is separate), wrist at the top; 8 a gloved hand relaxed and open, wrist at the top; 9 thigh with the knee pad below the middle, hip at the top; 10 shin down to the boot top, knee at the top; 11 boot, toe pointing right, sole flat, ankle at the top; 12 the ID card on its lanyard loop, on its own. Give every limb a rounded end at each joint that extends past the joint by a quarter of the limb's width, so the pieces overlap when they rotate.

**2. Walkway and wall** → `concept-art/style-handpainted/walkway-hd-v1.png`

> [style paragraph] Two long horizontal strips for a side-scrolling platformer, one above the other with clear space between them, each one seamlessly tileable left to right (the left and right edges continue into each other exactly). Top strip: the walkable wet stone walkway seen from the front, a slab face about one tenth as tall as the strip is long, with a crisp cold-white lit top edge, slab joints, and puddle reflections of amber and teal light. Bottom strip: the dark stone retaining wall under it, stone courses with dark mortar, a little moss and a few hanging vines, darker toward the bottom. Transparent background.

**3. Office pavilions layer** → `concept-art/style-handpainted/campus-hd-v1.png`

> [style paragraph] A wide background layer for parallax, seamlessly tileable left to right: a row of two-storey glass office pavilions of different widths, warm amber lit rooms with desks, chairs and potted plants in silhouette, concrete floor bands, roof gardens of dark trees lit warm from below, hanging vines, and one glass sky bridge with a cyan rail between two buildings. Everything stands on one flat ground line along the bottom edge. Nothing in front of the buildings. Transparent background above and between the buildings.

**4. Sky and far skyline** → `concept-art/style-handpainted/far-hd-v1.png`

> [style paragraph] A wide far background, opaque (no transparency), seamlessly tileable left to right: a deep navy night sky with soft clouds, darkest at the top; along the bottom third a hazy skyline of distant glass towers with a few lit windows and red aviation lights, one taller tower with a glowing teal arch emblem, soft blue fog over the bottom. No foreground, no ground.

**5. Props** → `concept-art/style-handpainted/props-hd-v1.png`

> [style paragraph] A props sheet for a side-scrolling platformer, each prop separate, standing on its own base, with clear space around it, transparent background. A person would be 1.0 unit tall; sizes in that unit: a tall slim street lamp (2.0) with a cold-white lens under its head; a park bench (1.1 long); a concrete planter with clipped plants (0.8 long); a rounded hedge (0.8 long); a section of steel railing (1.3 long, posts at both ends and in the middle); a short bollard light (0.4); an intercom post with a small teal screen (0.6); a small guard booth (1.8 tall) with a warm lit window showing a desk and monitor, a door with a small lamp; a broken entry gate: two posts with amber lights and a sagging barrier with orange chevrons (2.8 long); a tall landmark pylon (2.0) with a glowing teal Arcadia leaf emblem at the top. Painted evenly lit like the frame's props, no cast shadows.

**6. Night Guard parts sheets, three variants** → `concept-art/se01-night-guard/se01-night-guard-parts-hd-{a,b,c}-v1.png`

Enemy variants (the user, 2026-10-11: "we should have 2-3 variations of the same enemy ... this will only change the look"): each enemy type gets 2 or 3 looks that share **one part list, one skeleton and the same proportions**, so every clip, hit zone, tell and timing stays the same; the game picks a look per enemy (by its entity id). Generate variant A first, then attach **both** the style frame and the variant A sheet to B and C, so the parts come out at the same scale and layout. All humans are Caucasian (C43). Same stats and behaviour for all three.

> [style paragraph] A cutout-rig parts sheet of one character, facing right: [VARIANT]. The uniform is the same for every guard: a navy uniform jacket with neon lime piping (exactly #C6FF3D), a peaked cap with a lime band, a grey shirt collar, dark trousers, black boots, a duty belt with a radio. Evenly lit (soft painted shading, no cast shadows, no rim light, no glow), transparent background, each part separate with clear space, same scale. Parts, once each: 1 head with the cap, neck below the collar line; 2 torso: the jacket from collar to waist, no arms, shoulders complete; 3 pelvis: duty belt and radio down to the top of the legs; 4 upper arm; 5 forearm; 6 hand gripping a baton handle (empty grip); 7 hand open; 8 thigh; 9 shin; 10 boot, toe right; 11 a black baton on its own, about as long as the forearm and hand together, with a metal tip. Limbs hanging straight down, the upper joint at the top, with rounded joint ends that overlap. [MATCH]

- **A, the veteran:** `a middle-aged Caucasian night security guard of average build (no big belly), short greying hair, stubble, a weathered stern face`; [MATCH] left out.
- **B, the young one:** `a fit, athletic Caucasian security guard in his mid twenties, clean-shaven, short dark hair, alert eager face`; [MATCH] = `Match the attached guard parts sheet exactly in part list, part sizes, proportions and layout; only the person changes.`
- **C, the woman:** `a fit Caucasian woman security guard in her thirties, athletic build, dark blonde hair tied back in a low bun under the cap, a calm hard face`; [MATCH] as for B.

Game side (when processed): a female guard needs female voice barks; the current barks use the male guard voice (generating new ones is an ElevenLabs job, only when the user asks).

**7. Scrapjack parts sheet** → `concept-art/w01-scrapjack/w01-scrapjack-parts-hd-v1.png`

> [style paragraph] A parts sheet of one weapon for a 2D side-view game, pointing right: the Scrapjack, a chunky scrap-built nail-gun pistol. Parts, separate with clear space, same scale, transparent background: 1 the aged-cream lower frame with the teal-wrapped grip and the trigger guard; 2 the rust-red upper housing with three bolt heads and a small side window; 3 the dark steel barrel with three copper coil rings and a muzzle ring; 4 a small battery cell with a glowing teal light. Evenly lit, no cast shadow.

## Sheets (2026-10-11, processed into prototypes/sunnyvale-handpainted)

| Sheet | File | Notes for the import |
| --- | --- | --- |
| Style frame | `concept-art/style-handpainted/style-frame-v1.webp` | The reference for every sheet |
| 1 Dave | `concept-art/h01-dave/h01-dave-parts-hd-v2.webp` | v2 fixed the grey cut caps on limb ends; the hood is soft but a little beanie-like; torso three-quarter |
| 2 Walkway and wall | `concept-art/style-handpainted/walkway-hd-v1.webp` | Crop the wall strip's own lit top row; blend the seams |
| 3 Office pavilions | `concept-art/style-handpainted/campus-hd-v1.webp` | Three buildings with gaps, one ground line; pad the edges so the repeat gap matches; dim and fog in the game |
| 4 Sky and skyline | `concept-art/style-handpainted/far-hd-v2.webp` | Opaque; skyline edge to edge (v1 was one cluster); blend about 60 px at the seam |
| 5 Props | `concept-art/style-handpainted/props-hd-v1.webp` | Recolour the lamp lens cold white; dim and cool the plant greens; slightly cleaner than the frame |
| 6 Night Guard A, B, C | `concept-art/se01-night-guard/se01-night-guard-parts-hd-a-v2.webp`, `-b-v1`, `-c-v1` | A v1 came out photorealistic and was redrawn in Dave's style; B changes the head only; C the head, torso and hands; lime about #CDE64E, keyed by colour range |
| 7 Scrapjack | `concept-art/w01-scrapjack/w01-scrapjack-parts-hd-v1.webp` | Four parts plus an assembled reference; four copper coils |

**Processed (2026-10-11, "process"):** characters with `tools/art/import_parts_sheet.py dave_hd | scrapjack_hd | night_guard_hd_a | night_guard_hd_b | night_guard_hd_c`, the environment with `tools/art/import_hd_env.py` (both in the hand-painted prototype). See the 09 handoff entry for what changed in the game.

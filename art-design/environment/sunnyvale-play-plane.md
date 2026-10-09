# Eon City play plane: props, terrain and objects (C39)

The painted background layers (the far city and the campus offices, C39) are pixel art. Everything Dave walks on, passes or uses is still drawn by code in the older flat C11/C24 style, and it no longer matches. This brief lists what to repaint and gives the ChatGPT prompts.

**Suggested order (2026-10-05):** Sheet 2 (street furniture, mostly the 62 lamps), then Sheet 4 (things Dave uses and picks up), Sheet 6 (wet paving), Sheet 7 (foreground layer), Sheet 3 (buildings and doors), Sheet 5 (the depot), Sheet 8 (details) and Sheet 9 (effects). Sheets 1, 2, 3, 5, 6, 7, 8 and 9 and Sheet 4 (items 1 to 12, two parts) are in the game. Sheet 10 (sign lettering, 2026-10-06) is in the game too; the character sheets come after.

## Review (2026-10-05)

Captured at 2560 x 1440 in A01, A02, A04 and A05.

| Problem | Where it shows |
| --- | --- |
| **Smooth vector, not pixels.** Props have perfectly smooth edges, gradients and round glows. The background has chunky square pixels about 3 world px wide, with stepped shading. | Every prop: lamps, planters, the guard booth, signs, stations |
| **Thick black outlines.** Props are drawn with 2–4 px dark outlines (the old C11 cel style). The background has no outlines; shapes separate by value and colour. | Planters, backstops, the booth, the station cabinet |
| **Too little detail.** Props are simple boxes and blobs (the hedge is a green dome; a backstop is a grey box with lines). The background has foliage clusters, window interiors, vines and lit edges. | Hedges, backstops, platforms, the bench |
| **The ground is an empty slab.** The walkway and its face fill the bottom third of the screen as flat navy with thin seam lines. The concept shows wet, reflective paving with a planter edge. | Every area; the biggest mismatch by area |
| **Soft glows instead of pixel light.** Lamp heads and the checkpoint lamp are smooth radial discs. The background's lights are pixel clusters with a stepped halo. | Lamps (62 in the level), stations, beacons |
| **Smooth text.** Signs use the UI font. (Fixed 2026-10-06 by Sheet 10's pixel font on Sheet 3's sign panels.) | WELCOME TO EON CITY, SERVICE WICKET, STAFF ANNEX |
| **The depot is still code-drawn.** Racks, cables, monitors and the floor are vector shapes. (Fixed 2026-10-06 by Sheet 5's painted wall; the ceiling fixtures stay code-drawn.) | A05, the whole interior |
| **The characters are smooth painted cutouts** with realistic lighting (C35), so they also read differently from the pixel background. See the end of this brief. | Dave, every enemy |

What already works: the colour scheme (C40) matches, the scale of the campus storeys against Dave (about 1.5 Dave per storey) reads right, and the gameplay cues (lit walkable top edges, amber hazard stripes, red only for attack tells) must stay.

## How the art comes into the game

- **One pixel size everywhere.** The far and campus layers are reduced to about two art pixels per generated "pixel" and drawn at 1.5 world px per art pixel. So one generated pixel is about **3 world px**, and Dave (94 world px tall) is about **31 generated pixels tall**. Every sheet below gives sizes in those generated pixels. They don't need to be exact: the importer measures each piece and fits it to its in-game size.
- **Watch the pixel size (C42).** Sheet 2 came back with the objects at the requested size but drawn with pixels half as big (about 2.5 times finer than the campus layer's). Its props keep those finer pixels, because at the background's pixel size the bench and card reader would stand taller than Dave. The shared text now asks for chunky pixels and gives thin parts' widths in pixels; check the next sheets' pixels against the campus layer before importing.
- **Transparent background, pieces apart.** Each sheet holds separate pieces with clear space between them. The importer cuts them apart by their transparent gaps, so nothing may touch or overlap.
- **Light.** Paint the night look into the pixels: dark, cool shading and glowing light sources, like the campus layer. The engine still adds the real light pools on top (lamps, the fountain, stations).
- **Side view only.** Strictly side-on and flat, with no perspective and no ground shadow. Each object's base sits on the bottom of its own space.
- **Attach the campus layer** (`concept-art/env-sunnyvale/sunnyvale-campus-v1.webp`) to every prompt as the style reference.

## Shared style text

Every prompt below starts with this paragraph:

> Pixel art game asset sheet for a 2D side-scrolling action game set on a high-tech corporate campus at night. Match the attached image exactly: the same pixel size (every pixel a crisp square block, the same size as in the attached image), the same palette (deep navy, steel and slate blues; warm orange interior light #E8A35C; small teal accents #3FE0D0) and the same soft night lighting and level of detail. Strict side view, flat and orthographic, no perspective. Transparent background. Every object separate, with clear empty space around it; nothing touching or overlapping. No text, no letters, no labels, no ground shadows, no thick outlines. For scale, a person standing next to these objects would be about 31 pixels tall. This is low-resolution pixel art with big, chunky pixels: each object is only as many pixels as listed below, a thin pole, rail or frame is 1 or 2 pixels wide, and no detail is smaller than one of those pixels.

## Sheet 1: walkway and terrain (do first)

**In the game (2026-10-05):** [sunnyvale-terrain-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-terrain-v1.webp), imported with `tools/art/import_pixel_sheet.py terrain`. The generated pixels are exactly 4 px, so it reduces two-to-one like the far layer. Where each piece is used:

- **Walkway:** GROUND and PORCH tops, until Sheet 6's wet paving replaced it.
- **Retaining wall:** the garden walls (WALL). Its face, dimmed, also sat under every walkway before the shadow, until Sheet 6's brick wall replaced it there.
- **Planter ledge:** PLATFORM; tall planter beds continue with the wall face.
- **Green-roof slab:** the A03 roofs.
- **Lattice column:** the roof supports.
- **Stone planter:** every backstop, drawn without its hedge so it never looks taller than the wall Dave clears.
- **AC unit:** the roof backstop; its block grew to 100 × 84 to fit it.

The pillar and the porch steps are not used yet. The pieces came out as planters and slabs rather than a seamless wet paving texture, so the walkway had no wet reflections; Sheet 6 redid it.

The pieces the level is built from. They repeat sideways (and the faces downward), so each must tile cleanly.

> [shared style text] This sheet holds terrain pieces for building platforms, laid out in rows with space between them:
> 1. A long walkway strip, 160 pixels wide and 14 pixels tall: wet dark stone paving seen from the side, with a thin cool-white lit edge along its top (the walkable surface), faint reflections of warm and teal lights in the wet stone, and a darker front lip. It must repeat seamlessly left to right.
> 2. The retaining wall below the walkway, 160 x 48 pixels: dark slate concrete panels with a few vines and a narrow planter ledge, getting darker toward the bottom. Seamless left to right and top to bottom.
> 3. A raised concrete planter ledge, 96 x 16 pixels, with the same cool-white lit top edge and clipped hedge along it. Seamless left to right.
> 4. A green-roof slab for rooftops, 128 x 14 pixels: a steel beam with a lit top edge and low grass and shrubs on top. Seamless left to right.
> 5. A steel support column for the rooftops, 16 x 64 pixels, a lattice of dark steel. Seamless top to bottom.
> 6. A heavy stone planter block, 24 x 24 pixels, dark stone with a hedge on top, solid and blunt.
> 7. A rooftop air-conditioning unit, 24 x 24 pixels: grey metal housing, a fan grille and a small teal status light.
> 8. A square concrete pillar, 20 x 56 pixels.
> 9. Three wide porch steps, 64 x 16 pixels, the same stone as the walkway with lit step edges.

## Sheet 2: street furniture

**In the game (2026-10-05):** [sunnyvale-props-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-props-v1.webp), imported with `tools/art/import_pixel_sheet.py props` at one art pixel per generated pixel (C42). Its generated pixels alternate between 4 and 5 px, so the importer finds each piece's own grid. Where each piece is used, everywhere but the depot:

- **Lamp post:** every path lamp; the pole repeats to the lamp's height, and the light sits at the lens. In lockdown the lens takes the lockdown colour and the head still swivels.
- **Railing:** the security railings, whole bays to about the railing's width, dimmed so the pale top rail never reads as a walkable edge.
- **Guide rail:** the chevron rails, one chevron per bay.
- **Planter, hedge, garden plant, card reader:** drawn as they are, the hedge and planter slightly dimmed.
- **Bench and bollard:** new prop kinds. One bench by the A01 target, one in the A02 courtyard and two bollards by the A02 guard booth.

The beacon is not used yet: the only beacons hang from the depot ceiling, which keeps its code-drawn look until Sheet 5.

> [shared style text] This sheet holds campus street furniture:
> 1. A tall path lamp post, about 50 pixels tall: slim dark steel pole, a flat modern lamp head glowing cold white, a small base.
> 2. A shorter bollard path light, about 14 pixels tall, glowing cold white on top.
> 3. A rectangular concrete planter with a clipped dark-green hedge, about 22 x 12 pixels.
> 4. A sculpted dark-green hedge, rounded and neatly clipped, with a cool blue rim of light on top, about 20 x 14 pixels.
> 5. A low garden plant with softly glowing teal seed pods, about 10 x 8 pixels.
> 6. A steel security railing section, about 50 x 16 pixels, thin rails and posts. It repeats sideways.
> 7. A low steel guide rail with amber chevron arrows on it, about 64 x 14 pixels.
> 8. A slim card-reader intercom post, about 6 x 20 pixels, with a small amber light.
> 9. A modern outdoor bench, about 30 x 10 pixels.
> 10. A small warning beacon on a short post, about 6 x 14 pixels, unlit (red glass, dark).

## Sheet 3: buildings, doors and landmarks

**In the game (2026-10-05):** [sunnyvale-buildings-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-buildings-v1.webp), imported with `tools/art/import_pixel_sheet.py buildings`. Unlike Sheet 2 this one came back at the campus layer's pixel size (about 5.7 px), so each generated pixel is 2 x 2 art pixels (3 world px) and the pieces match the background exactly. Where each piece is used (drawn at its own size, whatever the prop's `size`):

- **Guard booth:** every HOUSE prop (A01, A02, A03 roofs, A04). The A01 entrance was rearranged to fit it (gate x 140, booth 430, sign 670).
- **Broken gate:** the A01 entry gate.
- **Landmark tower:** the CLOCK props; the emblem head on a pylon that repeats down to the ground, with its glow on the painted emblem.
- **Reflecting pool:** the A04 fountain, with its light on the water.
- **Depot door and annex door:** the A04 depot door and the A06 annex doors (the depot's own door in A05 stays code-drawn until Sheet 5).

**Sign panels and projector (2026-10-06, with Sheet 10's lettering):**
- **Sign panels:** the three blank panels (50, 78 and 112 art pixels wide, 18 to 24 tall) are every SIGN's board, the depot's two signs too. The panel nearest the sign's width is used, its decorated left side and its end caps stay, and one plain column and one plain row repeat to the board's width and height, so a sign of any size keeps pixel-exact edges. The text is set on it in the pixel font (see Sheet 10), and the teal frame is recoloured to the text's colour (hue shift: green for the exit sign, amber or alarm red in the lockdown). The posts under the board are still code-drawn.
- **Billboard projector:** under each lockdown hologram, drawn upside down (the sheet's housing hangs under a ledge, lens down; the hologram sits above it) with its amber lens at the apex of the faint cone. The hologram rectangle, its scanlines, chevrons and flicker stay code-drawn. At 144 x 54 world px it is larger than the old 28 x 9 emitter.

Not used yet: the wall terminal panel (depot only). Its live screen (readout bars and trace, status LEDs that turn amber or red in the lockdown) is code-drawn at 90 x 130 world px, and the painted terminal is a static 72 x 81 world px picture with no LED row, so it would change the panel's footprint and drop its lockdown cue; it stays code-drawn.

> [shared style text] This sheet holds larger campus pieces:
> 1. A small glass security guard booth, about 60 x 50 pixels: steel frame, one lit window with a warm interior, a door.
> 2. A broken perimeter security gate, about 70 x 40 pixels: a heavy sliding steel gate knocked off its track.
> 3. The Arcadia landmark sign, a tall slim tower about 20 x 60 pixels with a glowing teal arch-and-leaf emblem near the top.
> 4. A low reflecting pool, about 70 x 10 pixels: a dark stone basin with still water lit teal from below.
> 5. A server-depot security door, about 36 x 52 pixels: heavy steel double door standing open, dark inside, a teal light strip above.
> 6. A staff annex door, about 34 x 50 pixels: plain steel door slightly open, a dim warm light inside, a blank sign panel above it.
> 7. A holographic billboard projector, about 30 x 10 pixels: a projector housing that would hang under a ledge, with a faint amber lens.
> 8. A wall terminal panel, about 18 x 22 pixels: a dark screen with a teal readout.
> 9. Three blank corporate sign panels in different widths (about 40, 60 and 90 pixels wide, 12 pixels tall): dark glass with a thin teal-lit frame and no text.

## Sheet 4: things Dave uses and picks up

Each object needs its states side by side, as listed.

**Part A, items 1 to 7, in the game (2026-10-05):** [sunnyvale-objects-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-objects-v1.webp), imported with `tools/art/import_pixel_sheet.py objects`. Its generated pixels came out about 5.3 px, the campus layer's size, so each is drawn 2 x 2 art pixels (3 world px) like the buildings: a recovery station stands 135 world px tall next to Dave's 94. Every piece draws native, bottom-centre on its object's origin, everywhere including the depot, and the collision and interaction areas did not move:

- **Recovery station:** every station. Lamp off while waiting, lamp on once it is the active checkpoint, with the old smooth glow over the lamp.
- **Workbench:** the depot's workbench, dimmed while locked, with a small amber (locked) or teal (usable) status lamp on the pegboard. The decorative bench in the depot scenery (`Scenery` WORKBENCH) is still code-drawn.
- **Weapon pad:** the depot's swap pad; the resting weapon and its tag sit on the plate. (Taken out of Level 1 on 2026-10-08, C51; the art is kept for Level 2: [swap pad for Level 2](../../level-design/swap-pad-for-level-2.md).)
- **Core node:** calm teal until the lockdown starts, alarm amber after it; the copy bar and Dave's drive are drawn on its housing.
- **Emergency hatch:** the closed door, then the open doorway once the lockdown opens it. The piece is shorter than the hatch's solid, so one band of its hazard posts repeats to come close to the solid's height.
- **Service wicket:** the barred gate with the amber reader (locked), the open frame with the teal reader, and the gate shut by the striped bar during the hold-out (its reader turns teal while the override runs).
- **Route lever:** up while off, down once pulled, with the matching symbol above it.

The sheet's pieces are bigger than the old drawings (the workbench is 225 world px wide against 108, the weapon pad 147 against 56), so they are wider than their interaction areas.

**Part B, items 8 to 12, in the game (2026-10-05):** [sunnyvale-objects2-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-objects2-v1.webp), imported with `tools/art/import_pixel_sheet.py objects2`. Its generated pixels came out about 7 px, a little coarser than the campus layer's, and the pickups are bigger than asked (the cluster is 22 pixels, not 12; the chip 10, not 8). Drawn 2 x 2 art pixels per generated pixel (3 world px), the pieces land close to the old drawings (a chip 30 world px against 29, the keycard 36 x 27 against 32 x 22, the walkway 18 px thick against its 20 px collision); at one art pixel they would have been about half their old size. Every piece draws native with nearest filtering through `scripts/world/pickup_skins.gd`, the depot too, and no collision shape, size or behaviour moved:

- **Service walkway:** the A04 plank once the switch extends it. The grating repeats sideways in phase with the world x; stowed, it is the same piece dimmed and cut to the stub.
- **Moving platform:** the A03 gap platform. Plain plate repeats on either side of the middle light, so the three lights stay in the caps and the middle; a cold-white lit edge is drawn over the plate's dark top (the walkable cue), and the lights keep a soft glow. The track and end stops stay code-drawn.
- **Pit cover:** the nine A03 roof pits and the A06 exit pit. The stripes repeat sideways and, in an 80 px roof pit, downward with the diagonals carried on; a pit shorter than the piece (54 px) is drawn as tall as the piece. The lip glow and warning triangle stay on top.
- **Chip and cluster:** every chip and five-chip pickup (30 and 66 world px; the old ones were 29 and 44), with the glint grown to match.
- **Keycard:** 36 x 27 world px, still bobbing, now in whole art pixels.
- **Med patch:** 36 world px.
- **Evidence file:** the A02 evidence file, drawn as the cream folder (39 x 51 world px) in place of the memo.
- **Chip cache:** closed with the amber padlock under a soft glow; opened, it is dimmed, the padlock painted over and the lid lifted.
- **Practice target:** the A01 and depot targets. The origin stays the board's centre (the hit zone); the pole repeats down to the floor line; a hit washes the board cold white and swells its glow, but never scales the pixels.

> [shared style text] This sheet holds interactive objects; where states are listed, draw the same object in each state next to each other:
> 1. A recovery station, about 12 x 26 pixels: a squat steel maintenance cabinet with a small status screen and a lamp on a short post. Two states: lamp off (dim slate) and lamp on (bright teal with a small halo).
> 2. A spare-parts workbench, about 60 x 26 pixels, with tools hanging on a pegboard.
> 3. A weapon pad, about 30 x 8 pixels: a low floor plate with a teal-lit outline.
> 4. A tall server core node, about 32 x 64 pixels: a glowing teal data column inside a steel frame, with a plug-in port. Two states: calm teal, and alarm amber.
> 5. An emergency hatch, about 22 x 64 pixels: a heavy steel hatch with hazard-amber stripes. Two states: closed and open.
> 6. A narrow service gate with a card reader on its post, about 20 x 50 pixels. Three states: reader amber (locked), reader teal (open), and the gate shut by a striped steel bar.
> 7. A wall lever on a small box, about 10 x 14 pixels. Two states: up and down.
> 8. A thin steel service walkway, 96 x 6 pixels, seamless left to right.
> 9. A moving maintenance platform, about 54 x 8 pixels: a steel plate with small teal running lights underneath.
> 10. A hazard pit cover, 64 x 14 pixels: black and amber diagonal warning stripes on dark steel, seamless left to right.
> 11. Pickups, each small and bright so they read at a glance: a gold microchip (about 8 x 8), a cluster of five microchips (about 12 x 12), a white keycard with a teal stripe (about 8 x 6), a medical patch with a white cross on teal (about 8 x 8), a paper evidence file folder (about 8 x 10), and a small locked chip cache box (about 16 x 12).
> 12. A practice target on a stand, about 14 x 30 pixels.

## Sheet 5: the server depot (A05) background

A painted layer like the campus strip, for the depot interior behind the play plane.

**In the game (2026-10-06):** [sunnyvale-depot-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-depot-v1.webp), 2000 x 667, opaque and very dark navy (not the transparent background asked for), imported with `tools/art/import_pixel_layer.py depot`. Its generated pixels measure about 6.5 px (6 to 7: the grid drifts a little), so like the campus layer it is reduced 3.25-to-one, two art pixels per generated pixel, and drawn at 1.5 world px per art pixel: 615 x 205 art pixels in 64 colours, 922 x 308 world px. That height is the depot's own (the ceiling block's underside to the floor line is 300), so no scale was needed beyond the shared pixel size; a rack comes out about 50 world px wide, a little narrower than the old 58 px racks. Its first and last columns already match (under one level apart), so it needs no seam blend, and tiled three times it reads as one wall: the cables end near the seam as loops would between two clamps and the I-beam shows one extra short plate.

- **Drawn:** by the depot backdrop (`area_backdrop.gd`, `DEPOT` mode) as a static back wall across A05's 2700 px, 2.9 repeats, sampled by global x on the shared art-pixel grid. It does not scroll (no parallax): it is the room's back wall and the old racks did not scroll either. Its bottom stands on the floor line (the painted floor beam is the dark floor line) and its top tucks 8 px behind the ceiling block, so only the I-beam's lower rows show under it. It sits on its own child canvas (nearest filtering, repeat) under the rest of the backdrop's drawing, so the haze shafts and lights stay smooth. A05's width, the neighbouring areas' layers and every collision are unchanged; the wall is clipped to A05's span and meets the end jambs.
- **Replaced:** the code-drawn back wall, panel seams, server racks and their blinking LEDs, hanging cables, and the floor strip with its teal base lights. The painted status lights are static, so nothing blinks on top of the wall. The old racks' clear zones around the core node, workbench and hatch are no longer needed (the `clear_zones` export stays for the fallback); those objects stand in front of the painted racks, which stay quieter and darker than they are.
- **Kept (code and engine):** the building above the ceiling, the ceiling fixtures (the lit, dark and red banks with their stagger), the haze shaft under each, the real `PointLight2D`s that light the wall, floor and Dave, and the end jambs. The code-drawn depot remains as the fallback when the PNG is missing from an export.
- **Lockdown:** a mild cool multiply in the calm and a red-leaning one in lockdown (the art is already very dark, so a strong tint would make it vanish), on top of the area's EnvironmentState modulate. On the live SC01 moment the wall's tint fades in over the banks' stagger, so it reddens as the ceiling lights switch. The painted teal and green status lights stay teal under the multiply (the old amber and red LEDs are gone).

> Pixel art background layer for a 2D side-scrolling game: the inside of a dark server depot at night, seen strictly from the side. Match the attached image exactly in pixel size, palette and lighting. A long wall of tall server racks with blinking teal and green status lights, bundles of cables hanging from a steel I-beam ceiling, cool teal ceiling lights in a row, a few wall monitors with teal graphs, and a dark floor line at the bottom. It must repeat seamlessly left to right. Wide image, transparent above the ceiling. No text, no people.

## Sheet 6: the wet paving (a redo of the walkway)

Sheet 1's walkway came out as a plain slab with lights. The concept's ground is wet, reflective stone, and it is the surface on screen the most.

**In the game (2026-10-05):** [sunnyvale-paving-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-paving-v1.webp), imported with `tools/art/import_pixel_sheet.py paving` as two pieces, the paving (top) and the wall (bottom). The strips came out about 1374 px wide (the 320-pixel ask became about 343 pixels) with pixels of exactly 4 px, kept at one art pixel per generated pixel like the props (C42): the paving is 20 art pixels, 30 world px, as thick as the old walkway (31); at 2 x 2 art pixels it would have been 60, twice as thick as today's. The pixels are therefore 1.5 world px, finer than the campus layer's 3. Each strip came with a dark outline column at both ends, which would show as a seam where it repeats. The importer keeps one as a 1-pixel cap for a lone block's ends (`make_strip`), and the strip between the caps is the whole repeat. The paving keeps its right outline in the repeat as one more slab joint (seven evenly spaced slabs; without it the last and first slab would merge into one double-width slab). The wall drops it and cross-fades its last 6 columns into the first, so the bricks run on across the repeat (the courses line up there, but the middle course ended in a dark brick and began with a lighter one). Where each piece is used (the terrain blocks, through `scripts/world/terrain_skins.gd`):

- **Walkway:** GROUND and PORCH tops, in place of Sheet 1's slab. The thin cold-white row is the lit walkable edge and sits on the block's top (the strip's own outline row above it is left out). The wet slabs, puddle streaks and leaves repeat every 344 art pixels (516 world px) in phase with the global x, so floor blocks that meet continue one pattern, and a lone block's ends show the 1-pixel caps.
- **Wall face:** the dimmed face under every walkway and under tall planter beds, in place of the vine wall: the brick strip once (three courses, 54 art pixels), ending on a mortar line, then the plain shadow. Next to the busy wet paving the plain bricks read calmer than the old hanging vines, which repeated mechanically every 100 px or so.

Kept: the Sheet 1 retaining wall (planter, hedge and vines) for the garden walls, the planter ledge, green-roof slab, support column, stone planter and AC unit, and the code-drawn depot floor. The old walkway piece (`terrain/walkway.png`) is no longer drawn.

> [shared style text] This sheet holds one long ground strip, 320 pixels wide and 20 pixels tall, seen from the side: wet dark stone paving slabs with a thin cool-white lit edge along the very top (the walkable surface), puddles that mirror warm orange window light and teal accent lights as short broken streaks, a few fallen leaves, and a darker stone lip at the bottom. It must repeat seamlessly left to right, with nothing at the left and right ends that would show a seam. A second strip under it, 320 x 40 pixels, is the stone retaining wall below the paving: dark slate blocks with thin mortar lines, a little moss, seamless left to right and top to bottom, darker than the paving.

## Sheet 7: foreground layer

A strip that passes in front of the play plane at the bottom of the screen and moves faster than the camera, the same depth trick as the far and campus layers. It adds a lot of depth for little cost.

> Pixel art foreground layer for a 2D side-scrolling game at night, very close to the camera, seen strictly from the side. Match the attached image exactly in pixel size and palette, but much darker: almost black silhouettes with only a faint cool blue rim light along their tops. Along the bottom edge: clipped hedges, the tops of steel railings, a few tall grass tufts, a lamp post base and a bench back, spaced out with wide empty gaps between them so the action behind stays visible. Everything touches the bottom edge and rises no more than a quarter of the image height. Wide image, about 6 times as wide as it is tall, transparent background, seamless left to right. No text.

**In the game (2026-10-07):** [sunnyvale-foreground-v2.webp](../../concept-art/env-sunnyvale/sunnyvale-foreground-v2.webp) (2000 x 667, transparent background; v1 was the first attempt and is not used). The generator did not draw a strip: it drew **a sheet of 14 separate near-black silhouettes (#050910) in 3 rows with irregular spacing**, with no rim light. `tools/art/import_pixel_sheet.py foreground` finds them (a `join` of 4 px keeps each hedge with its grass tuft, which touch or nearly touch, while a bench beside a hedge stays its own piece), names them in reading order (`rows` instead of a grid) and writes `assets/environment/sunnyvale/foreground/`: `hedge_a`, `hedge_b`, `hedge_c`, `hedge_d`, `hedge_long` (the double hedge), `railing`, `railing_short`, `bench_a`, `bench_b`, `bollard_a`, `bollard_b`, `grass_a`, `grass_b`, `grass_c`. The pixels came out about 5 px (4.7 px for most pieces, 6.2 for the bottom row's two hedges), one art pixel per generated pixel (no `upscale`); a hedge is 42 x 15 art pixels, the bench 37 x 14, a bollard 8 x 16 and the long hedge 66 x 11. The importer adds a faint cool-blue rim (#22344E) along every upward-facing edge, as the brief asked for and the generator left out (a `rim` entry; remove it and re-run to go back to pure black); without it the pieces vanish against the dark wall face under the walkway.

The game builds the strip itself, because the sheet is not one. `scripts/world/visuals/foreground_layer.gd` is a `Foreground` node in each outdoor area (A01 gate, A02 gardens, A03 roofs, A04 plaza, A06 exit; **not the depot**, an interior). It composes the pieces along the area's width from a seed per area id: wide, irregular gaps (about 75% of the width stays empty, 72 to 80% across the five areas), never the same piece or the same kind of piece twice in a row, never the same piece as two back, a mirrored piece now and then, and a margin at each end so neighbouring areas' rows never touch. The pieces are drawn **2.5 world px per art pixel**, larger than the play plane's 1.5 because they are close to the camera, which is **exactly 3 whole screen pixels at the game's zoom 1.2**, so every art pixel keeps the same width and nothing shimmers: a hedge is 105 world px wide and 38 tall, nothing is taller than 40 (48 screen px, about 7% of the 720p view). They stand on the **bottom edge of the screen** (they live on their own screen-space canvas layer, 3: above the world, below the night overlay at 5 and the HUD at 15), so they stay at the bottom whatever the camera does, in the roof areas' climb and the plaza's low floor. Dave's feet are never lower than about 75 world px (90 screen px) above that edge in the whole level (the lowest place he stands is A02's lower catch), so they never cover his feet, an enemy or a pickup. They slide past at **1.5 times the camera's motion** (a world-fixed object moves at 1.0), placed on whole screen pixels. They are not lit by the world's lamps and take no lockdown tint: under the red wash they just stay dark.

## Sheet 8: small details (decals)

Small things laid over the terrain to break up its repeats.

**In the game (2026-10-06):** [sunnyvale-details-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-details-v1.webp) (1774 x 887, transparent background), imported with `tools/art/import_pixel_sheet.py details` into `assets/environment/sunnyvale/details/` as eleven pieces: `puddle_a`, `puddle_b`, `puddle_c`, `crack_a`, `crack_b`, `grate`, `leaves`, `cable`, `vent`, `hose` and `box`. The sheet's rows are uneven, so the importer reads its eight columns as the cells (each listing its pieces top to bottom), and a new `join` setting grows the mask a few pixels while it finds the pieces, so the loose leaves and each crack's stray specks stay one piece. The generated pixels came out about 5.5 px (the campus layer's size), and the pieces are kept at **one art pixel per generated pixel (no `upscale`)**: 2 x 2 would have made a puddle 147 world px wide and the box 75 px tall (Dave is 94). At 1.5 world px per art pixel the sizes are a puddle 73 to 78 x 9 px, a crack 44 x 29 to 33, the grate 52 x 10, the leaves 58 x 10, the cable 168 x 13 (the pieces came out 2.5 to 4 times the pixel counts the prompt asked for, so the cable is longer than the 90 to 110 px a 30-pixel ask gives, and the grate is 52 px wide, not 35), the vent 60 x 10, the hose 58 x 19 and the box 45 x 39. `scripts/world/decal.gd` draws a piece nearest-filtered, bottom-centre on its origin, with `flip` and `tint`, and nothing when the PNG is missing.

Each area scene places its own decals under a `Decals` node that follows `Geometry` (static, no collision, no group; they draw over the walkway blocks and under the pickups, enemies and Dave). The walkway is seen from the front, so the flat pieces lie **in the paving's face under the lit edge** (puddles, cracks, the grate, cable and vent a few pixels down, the leaves on the edge or in the face) and never over the lit row itself; the hose and box stand on the edge like the other props. Clear space is 70 px around every pickup, station, lever, wicket, hatch, core node, workbench, pad, pit, enemy start and marker.

| Area | Decals | Placed |
| --- | --- | --- |
| A01 Gate | 10 | 3 puddles, 3 cracks, 3 leaves, a hose by the guard booth |
| A02 Gardens | 12 | 3 puddles, 4 cracks, 4 leaves, a box beside the booth |
| A03 Roofs | 10 | 3 puddles, 3 cracks, 4 leaves, all on the street paving (the roof terraces keep their green-roof slabs bare) |
| A04 Square | 11 | 3 puddles, 2 cracks, a leaf pile, 2 grates, 2 cables, a vent |
| A05 Depot | 8 | 2 cables, 3 vents, 2 grates, a hose in the far corner (no puddles, leaves or stone cracks) |
| A06 Exit | 11 | 3 puddles, 4 cracks, 3 leaves, a box behind the wicket |

> [shared style text] This sheet holds small ground details, each separate: three different puddles that reflect warm and teal light (about 20 x 3 pixels each), two cracks in stone (about 10 x 6), a drain grate (12 x 3), a small cluster of fallen leaves (8 x 3), a cable running across the ground (30 x 3), a floor vent with a faint teal glow (14 x 4), a coiled hose (10 x 6), and a cardboard box (12 x 10).

## Sheet 9: effects (frames)

**In the game (2026-10-06).** The user's sheet (`concept-art/env-sunnyvale/sunnyvale-effects-v1.webp`, 1254 x 1254, plain black background, a strict 6 x 6 grid) is cut by `tools/art/import_pixel_effects.py` into six strips in `assets/effects/pixel/` (muzzle_flash, bullet_impact, landing_dust, machine_break, checkpoint_sparkle, chip_glint, plus `effects.json`) and played by `scripts/effects/pixel_fx.gd`. The generated pixels came out about 6.6 px, kept at one art pixel per generated pixel; the black is keyed out by colour (not by brightness, so the dark smoke stays), and every strip shares one 48-colour palette. Where each is used:

1. **Muzzle flash** (orange and pale yellow, not the ivory the prompt asked for): each shot of the Scrapjack (`scrapjack.gd`), at the muzzle, turning and flipping with the aim; the old drawn starburst is the fallback. 1.5 world px per art pixel, additive.
2. **Bullet impact** (ivory-white sparks): every `ImpactSpark` (a bolt that hits armor, a machine or a wall): a hit is the whole burst, a blocked shot only the half that glances back toward the shooter (so the two still differ by shape), tinted by the impact colour; the Patrol Rover's armor spark (`armor_spark`) plays it smaller and warm. 3 world px per art pixel, additive.
3. **Landing dust** (pale blue-grey): the hero's landing after a real fall (`landing_dust`), and, bigger and warmer, a pit fall (`pit_dust`). Plain alpha.
4. **Machine breaking apart**: the Patrol Rover's defeat, in two parts that play one after the other (the spark frames for `machine_spark`, the dark-smoke frames for `machine_smoke`); the stall vent plays the smoke part. Plain alpha.
5. **Checkpoint saving sparkle** (teal stars): a committed recovery station (`checkpoint_sparkle`, at its lamp). Additive.
6. **Microchip pickup glint** (gold four-point star): a chip pickup (one glint), a five-chip cluster or a cache (three glints one after the other). Additive.

Reduced Motion plays fewer frames of each (a shorter play, never a missing cue) and dims the additive ones. A missing strip keeps the old smooth effect.

Each effect is a short row of frames, left to right, the same size each.

> [shared style text, but with a plain black background instead of transparent] This sheet holds short animation strips for game effects, one effect per row, each frame the same size and spaced evenly, read left to right: 1. a small muzzle flash, 4 frames of 12 x 8 pixels, ivory white and pale yellow; 2. a bullet impact on metal, 5 frames of 12 x 12 pixels, ivory sparks flying outward and fading; 3. a puff of dust where a foot lands, 5 frames of 16 x 8 pixels, pale blue-grey; 4. a machine breaking apart, 6 frames of 24 x 24 pixels, orange sparks and dark smoke; 5. a checkpoint saving sparkle, 6 frames of 16 x 16 pixels, teal; 6. a microchip pickup glint, 4 frames of 10 x 10 pixels, gold.

## Sheet 10: sign lettering (a pixel font)

**In the game (2026-10-06):** [sunnyvale-font-v1.webp](../../concept-art/env-sunnyvale/sunnyvale-font-v1.webp), a native bitmap font (117 x 52 px, pure white on transparent, 13 x 4 cells of 9 x 13 px with 5 x 7 px glyphs: A to Z, 0 to 9 and `. , ! ? - ' : / + & ( )`, 48 glyphs, every one clean), imported by `tools/art/import_pixel_font.py` into `assets/environment/sunnyvale/font/` (a one-row atlas and a glyph table: each glyph's rect, its advance of width + 1 pixel, space 3, and the rows Q and the comma hang below the baseline) and drawn by `scripts/world/pixel_font.gd`. A font pixel is drawn as a whole number of art pixels (1.5 world px each): 2 where the text fits that big (the hologram text; 2 art pixels is one pixel of the sign panels), else 1, wrapped onto two lines at a space if it has to be (WELCOME TO / EON CITY, FRONT / GARDENS, SERVICE / WICKET, EMERGENCY / EXIT). The panels are Sheet 3's (see there), so the sign text is the panel's tint colour on a pixel board, and every hologram's text (PLEASE REMAIN CALM, LOCKDOWN, THIS WAY, EXITS CLOSED FOR YOUR COMFORT) is amber pixels with the old flicker. Every text in the level is covered; a text with a character the font lacks, or an export without the art, keeps the code-drawn board and the UI font. A board is never wider than its sign's `size.x`, so every sign's lettering is 1 art pixel per font pixel (cap height 10.5 world px); 2 art pixels would need wider signs.

Before the font, sign text was drawn in the UI font, so it was smooth next to the pixel signs. Every sign's text is capital letters only (WELCOME TO EON CITY, FRONT GARDENS, GARDEN PATH, ROOF WALK, SERVICE WICKET, STAFF ANNEX, SERVER DEPOT, THIS WAY, EMERGENCY EXIT, LOCKDOWN, PLEASE REMAIN CALM, EXITS CLOSED FOR YOUR COMFORT). The tutorial prompts ("Move", "Jump", "Aim + Fire") are UI and stay as they are.

The letters must be **plain white**: the game tints them (teal for signs, green for exit signs, amber or red in lockdown). Image generators draw letters unreliably, so check every glyph; if the sheet has bad letters, a ready-made free pixel font is the fallback (the user would have to approve the download).

> Pixel art bitmap font sheet for a 2D game. A strict grid of cells, 13 columns by 4 rows, each cell the same size with clear empty space around its glyph and no grid lines drawn. Transparent background. Every glyph is drawn in pure white (#FFFFFF) only: no outline, no shadow, no glow, no colour, no anti-aliasing. Each glyph is exactly 5 pixels wide and 7 pixels tall (capital letters sit on the same baseline; Q and comma may hang 2 pixels below it), drawn with crisp, square, equal-sized pixels, strokes one pixel thick, in a clean, slightly squared sans-serif style like a classic 5 x 7 pixel font, easy to read at small size. Row 1: A B C D E F G H I J K L M. Row 2: N O P Q R S T U V W X Y Z. Row 3: 0 1 2 3 4 5 6 7 8 9 and then two empty cells. Row 4: . , ! ? - ' : / + & ( ) and one empty cell. Nothing else on the sheet: no title, no labels, no sample words.

## Characters

The characters are smooth painted cutout rigs (C35) with hand-keyed motion (C38), so they also look different from the pixel world. **The user asked for the prompts (2026-10-05).** The way to match keeps the rigs:

1. **Repaint the parts as pixel art.** Regenerate each character's parts sheet in pixel style (below).
2. **Render the rigs on the pixel grid.** Each character is drawn into a small low-resolution view and scaled up crisp, so even rotated limbs stay on the same 1.5 world px grid as the background. (Engine work, done after the sheets arrive.)

This keeps the animation, lighting, ragdolls and hit effects already built. Fully hand-drawn pixel animation frames would match best, but image generators can't draw consistent animation frames.

**Status (2026-10-07): the Night Guard, the Staffer, the Patrol Rover, the Scrapjack and Dave are done.** The guard's pixel parts sheet ([se01-night-guard-parts-pixel-v1.webp](../../concept-art/se01-night-guard/se01-night-guard-parts-pixel-v1.webp)) is imported as a `pixel_art` rig (`tools/art/import_parts_sheet.py night_guard`; the recipe is `tools/art/README.md`, "Pixel rigs") and drawn with nearest filtering, in rotation steps of about one art pixel, with its pelvis on whole art pixels. It was **not** rendered into a low-resolution view: lights from the world do not reach a SubViewport, so the lamps, normal maps, blood and ragdoll would all have to be rebuilt, and the cheap route (below) turned out to be enough. What was learned:

- **The generator draws much finer than asked.** The prompt said 66 pixels tall; the sheet's pixels are about 7.6 x 7.1 px, so each part is about 40 pixels across and the assembled guard would be about 186 pixels tall (0.55 world px per pixel, a third of the background's size). The importer finds each part's own pixel grid (the pixels drift between 7 and 8 px) and bins about 2.7 generated pixels into one art pixel, then draws the outline again on the new silhouette. The result is 68 art pixels (102 world px); the face is about 13 pixels wide, so the cap, the hair, the skin and the beard read and the eyes do not. A future prompt that wants more face should ask for a larger character canvas rather than "a handful of pixels"; one that wants the importer to do less should say "the assembled character is about 190 pixels tall" and accept a pixel finer than the world's.
- **Everything else in the pipeline survived**: the lamps shade the pixel parts smoothly (normal maps are made at the enlarged size and blurred over about one art pixel), the hand-keyed motion, the hit zones, the tell light and the ragdoll are unchanged, and the lime trim is the exact emissive mask. A rotated pixel limb shows small stair-steps (most visibly the raised arm in the windup and a corpse's limbs); at the game's size they read as pixel art.
- **The Staffer, second (2026-10-06).** His pixel parts sheet ([lk01-staffer-parts-pixel-v1.webp](../../concept-art/lk01-staffer/lk01-staffer-parts-pixel-v1.webp), look reference [lk01-staffer-look-v1.webp](../../concept-art/lk01-staffer/lk01-staffer-look-v1.webp)) is imported the same way (`import_parts_sheet.py staffer`). The sheet's pixels are about 9.1 x 9.0 px, so the assembled person would be about 106 pixels tall (the prompt asked for about 64): the importer bins 1.58 generated pixels into one art pixel and he stands 65 art pixels (97 world px, the old rig's height). Two parts needed their own treatment: the Link port was drawn on a finer grid (about 5.7 px pixels) and a third of the head's width, so it is binned by its own reduction (6 x 7 art pixels), and its centre pixel is repainted as the amber light; and the lanyard's neck loop is cut off. The port and the lanyard became joints of their own, so a pixel rig may have more joints than the guard's. His electric blue trim (#4D8DFF, proposed) is the glow mask. A lamp overhead blew his pale skin (#DFB798) out to white (the pixel normal maps are flat over a big part), so the importer darkens skin-tone palette entries (x0.84) and rounds the normal maps over 4 art pixels instead of 2. At game size the slouch, the stiff shuffle, the crouch with both hands out (the grip palms glow amber, then red) and the lunge all read; the face is a dark eye and a bruise.
- **The Patrol Rover, third (2026-10-06).** The first machine: its pixel parts sheet ([m01-patrol-rover-parts-pixel-v1.webp](../../concept-art/m01-patrol-rover/m01-patrol-rover-parts-pixel-v1.webp), look reference [m01-patrol-rover-look-v1.webp](../../concept-art/m01-patrol-rover/m01-patrol-rover-look-v1.webp)) is imported with `import_parts_sheet.py patrol_rover` (`build_machine_pixel`; the smooth sheet is `patrol_rover_smooth`). Its pixels are about 8 x 8 px, so the sheet's rover is about 172 generated pixels long; the importer bins 2.86 of them into one art pixel and it is 62 art pixels (93 world px) long, the old rover's length, so the body box and hit zones did not change (the prompt's "about 80 pixels long" would be 120 world px, a rover a third bigger). The parts fit as drawn (a pixel part is never rotated or scaled): the chassis has its wheel arches cut out and the rear deck's battery bay painted in dark, the lid is exactly the deck panel, the battery is bigger than the bay and sits under the lid, and one wheel part serves all four wheels. What the machine needed that a person did not: the wheel is made symmetric about its hub (a lumpy 14-pixel wheel wobbled as it spun), the thin magenta flank strip wins its cell before the outline does (otherwise it broke into dashes), and the patrol bounce and the windup shake became one art pixel (the rig sits on whole art pixels, so the old fractions rounded to nothing). At game size it reads as a small white-and-grey security car with a magenta strip, an amber lightbar (amber then red) on the rear roof, a bumper and a pod with one lens, and the stall (hatch up, teal battery on the deck) and the break-up read as before; the tyre tread and the pod's visor are the detail the pixel size loses.
- **The Scrapjack, fourth (2026-10-07).** The first prop: Dave's gun, its pixel parts sheet ([w01-scrapjack-parts-pixel-v1.webp](../../concept-art/w01-scrapjack/w01-scrapjack-parts-pixel-v1.webp), look reference [w01-scrapjack-look-v1.webp](../../concept-art/w01-scrapjack/w01-scrapjack-look-v1.webp)) is imported with `import_parts_sheet.py scrapjack` (`build_prop_pixel`; the smooth sheet is `scrapjack_smooth`). The sheet is the one that came out furthest from the prompt: it asked for a pistol about 26 pixels long, and the pixels are about 9.4 x 9.2 px, so the assembled pistol is about 123 generated pixels long. At the smooth gun's 26 world px (17 art pixels) it would be a black slab: every part's outline becomes a whole art pixel on each side, and the trigger guard, the scrap window, a coil and the teal light drop out. It is **24 art pixels (36 world px) long, 38% longer than the smooth gun**, binned 5 generated pixels to one art pixel (the battery cell, drawn 1.35 times bigger than the look wants it, 5.75): that keeps both copper coils, the window, a trigger guard and the teal light, and the muzzle is 30 world px from the grip (22.4 before). A future prompt that wants a gun of the old length should ask for "about 18 pixels long" and a trigger guard and coils at least two pixels across, or the importer has to throw detail away. The copper coils (#D9884A) glow per shot and the teal charge light (#3FE0D0) is steady: both are exact colours (the generator painted the coils in a dozen oranges, so the importer makes every warm pixel of the two coil boxes exactly copper). Dave is still the smooth Rook frame set, so the pixel gun sits in a smooth hand; the gun's turn is the aim pivot's own and is not stepped, and its recoil moves in whole art pixels.
- **Dave, fifth (2026-10-07).** The hero: his pixel parts sheet ([h01-dave-parts-pixel-v1.webp](../../concept-art/h01-dave/h01-dave-parts-pixel-v1.webp), look reference [h01-dave-look-v1.webp](../../concept-art/h01-dave/h01-dave-look-v1.webp)) is imported with `import_parts_sheet.py dave` and drawn by `hero_rig_visual.gd` in place of the Rook frames (kept as a fallback). Its pixels are about 7.9 x 8.0 px, so the assembled Dave is about 130 generated pixels tall (the prompt asked for 62); the importer bins 2.04 of them into one art pixel and he stands **64 art pixels (96 world px)**, the old frames' height (the brief's 62 pixels would be 94; rounding the joints to whole pixels makes the height jump by a pixel or two between neighbouring bin sizes, so the entry fixes 2.04). The head is 14 x 16 pixels: the hair, the forelock and the skin read, the eye came out as one block with the brow until the head's outline rule was relaxed and the two brow pixels were placed by hand; the healed eyebrow mark is lost. What else he needed: the sheet painted the revoked badge on the torso *and* as a part, so the importer paints it out of the chest (the hoodie below it is copied up) and the card hangs and swings on its own lanyard joint; the hood is a joint of its own behind the neck; the palette had to be given the card's pale grey, its red band, the eye's white and the wrist light's blue-grey (24 automatic colours went to near-identical charcoals); the sheet's skin (#D8A078) is lightened to the brief's #E1B596, which a lamp does not blow out. He has no neon and nothing glows. In motion the burnt-orange jacket is the brightest thing about him against the night, as intended; the dark hoodie, trousers and gloves make him darker overall than the cream-trousered Rook, so his silhouette leans on the jacket and the one-pixel outline. The Scrapjack is now at its own pixel size on him (it had been scaled to 0.65 for the Rook), and the near arm is posed every frame so his fist holds its grip at any aim (a two-bone solve in the rig's rotation steps; the gun itself turns smoothly), within an art pixel. Rotated limbs show small stair-steps, as on the enemies.
- **Pixels and the camera.** One art pixel is 1.5 world px, 1.8 screen px at the game's camera zoom of 1.2 on a 1280 x 720 screen, so a pixel is sometimes 1 and sometimes 2 screen px wide as things move, in the backgrounds too. A camera zoom of 4/3 would make it exactly 2 screen px at 720p (3 at 1080p, 4 at 1440p, 6 at 4K) and every pixel crisp; the rig's world position is therefore not snapped (it would only stutter a slow walk).

**Size.** At the background's pixel size Dave would be only 31 pixels tall, with 4-pixel arms and a 3-pixel hand: too coarse to rotate or to read a face or gun. So the characters use the finer pixels the props already use (C42): **Dave about 62 pixels tall** (1.5 world px per pixel). The Night Guard, Staffer and Rover scale from the same rule (the guard about 66 pixels, the Rover about 80 pixels long).

**Outline.** The background has no outlines, but the characters must stay readable against it, so they keep a **one-pixel near-black outline** (#0B0D10).

**Light.** Keep the sheets flat and evenly lit (no baked highlights, glow or cast shadow): the engine lights them through normal maps made from each part. A single darker shade for folds is fine.

### The pixel style block (all characters)

Take each character's existing "Image prompt 4: rig parts sheet" from its brief and attach that character's approved look concept and its current parts sheet as the design reference. In the prompt, **replace the Style, Outlines and Layout-scale paragraphs** with this block and leave everything else (the part list, joints, palette) as it is:

> Style: pixel art. Draw every part with crisp, square, equal-sized pixels on one grid across the whole sheet (each pixel a solid block, all the same size, no anti-aliasing, no blur, no gradients, no dithering, no JPEG noise). Keep it flat and evenly lit: base colours with at most one darker shade for folds, no highlights, no rim light, no glow, no cast shadow. Outline every part with a one-pixel near-black line (#0B0D10) on the outer contour only, with no interior outlines. The assembled character stands about [HEIGHT] pixels tall, so keep every part simple: hands are a few pixels, faces are a handful of pixels, and no detail is smaller than one pixel. Match the attached references' design exactly (same clothes, colours and details); only the drawing style changes to pixel art.
>
> Layout: a landscape canvas, each part separate and complete with at least 6 pixels of empty space around it, all at the same pixel size. Transparent background.

Use [HEIGHT] = 62 for Dave and the Staffer, 66 for the Night Guard, and for the Rover write "about 80 pixels long" in place of "stands about [HEIGHT] pixels tall". The Staffer and Scrapjack briefs ([LK01](../linked/lk01-staffer.md), [W01](../weapons/w01-scrapjack-pistol.md)) and the [Patrol Rover](../machines/m01-patrol-rover.md) and [Night Guard](../security/se01-night-guard.md) briefs hold the part lists. The glow colours stay exact (guard lime #C6FF3D, Rover magenta #FF3DD5) because the importer turns them into the glow mask.

### Dave Harlan's parts sheet (new)

*Done (2026-10-07): the sheet arrived as [h01-dave-parts-pixel-v1.webp](../../concept-art/h01-dave/h01-dave-parts-pixel-v1.webp) (it follows the [hero brief](../../design/02-characters/hero.md)'s outfit rather than the older colours in the prompt below: a charcoal hoodie with its hood as a separate part, dark cargo trousers, the revoked badge on its lanyard as a part) and Dave is a pixel rig in the game (above). The prompt is kept as written.* Before it, Dave was the one character with no rig: a set of whole frames (the old Rook sprites, auto-lit).

> Pixel art cutout-rig parts sheet of one character for a 2D side-view action game: Dave Harlan, an adult man in his late twenties, compact build, fair Caucasian skin (about #E1B596), cropped dark hair with one uneven forelock falling over the right side of the forehead and a small healed mark through the right eyebrow, a quietly resourceful expression with a hint of dry humour. He wears a rust-orange short work jacket (#C8683F) with sleeves ending at the wrist, a dark teal shirt (#2F5E62) under it, a short cream neck cloth (#EFE0BE), cream reinforced trousers (#E6D6B4) with charcoal knee patches (#3A3633), broad scuffed brown boots (#6B4A33), and one small belt pouch at the right hip. No weapon, no gun, no holster, no armour, no backpack, no logos or text.
>
> Style: pixel art. Crisp, square, equal-sized pixels on one grid across the whole sheet (each pixel a solid block, no anti-aliasing, no blur, no gradients, no dithering). Flat and evenly lit: base colours with at most one darker shade for folds, no highlights, no rim light, no glow, no cast shadow. A one-pixel near-black outline (#0B0D10) on each part's outer contour only. The assembled character stands about 62 pixels tall, so keep every part simple: hands are a few pixels, the face is a handful of pixels, and no detail is smaller than one pixel.
>
> Layout: a landscape canvas. Draw each part below as a separate, complete piece, as seen in the right-facing side view, all at the same pixel size, with at least 6 pixels of empty space around each; no part may touch or overlap another. Transparent background. No labels, text, numbers, grid lines or frames.
>
> Parts, exactly these, once each:
> 1. Head, facing right, with the neck extending a little below the collar line so it tucks under the torso.
> 2. Torso: the jacket from the collar to the waist with the teal shirt at the open neck and the cream neck cloth; no arms attached, shoulders complete where the arms join; the hem extends a little below the waist.
> 3. Pelvis: the belt and the small pouch, from the waist down to the top of the legs; no legs attached.
> 4. Upper arm: the jacket sleeve, hanging straight down, shoulder at the top.
> 5. Forearm: the sleeve down to the wrist, hanging straight down, elbow at the top.
> 6. Hand closed in a grip around an empty space (the gun is separate), fingers down, wrist at the top.
> 7. Hand relaxed and open, fingers down, wrist at the top.
> 8. Thigh: the cream trousers with the charcoal knee patch below the middle, straight down, hip at the top.
> 9. Shin: the trousers down to the boot top, straight down, knee at the top.
> 10. Boot: side view, toe pointing right, sole flat, ankle at the top.
>
> Joints: give every limb piece a rounded end at each joint that extends past the joint by about a quarter of the limb's width, in the same material, so the pieces overlap when assembled and no gap shows when they rotate.

Order of work: Night Guard first (he is the test subject for the rig, so the pixel-grid render gets judged on him), then the Staffer, the Rover, Dave and the Scrapjack. Check each result at gameplay size next to the background before doing the next.

## HUD and menu art (Sheets 11 to 13, planned 2026-10-07)

Until 2026-10-07 the HUD, tutorial prompts, pause menu, title screen and completion screen were smooth UI: rounded `StyleBoxFlat` panels from `assets/ui/c11_theme.tres`, hand-drawn vector icons (`chip_icon.gd`, `weapon_icon.gd`, `keycard_icon.gd`), Kenney vector key icons and the UI font. Three sheets make them match:

- **Sheet 11: frames, buttons and bars.** Panel and tag frames (9-slice), the four button states, health segments, weapon slot, ready dot and Quickcycle pip, slider, checkbox, focus brackets, divider. **In the game (2026-10-07).** The user's sheet (`concept-art/ui-sunnyvale/ui-frames-v2.webp`, exact 4 px blocks, so a 320 x 168 texel native sheet) was cut by `tools/art/import_pixel_ui.py` into `assets/ui/pixel/` (native) and `assets/ui/pixel/x3/` (the theme's frames at UI scale). The shared theme is now nine-slice frames: panels (every menu, the title's panel and the subtitle panel), the four button states, the focus brackets (keyboard and pad focus, outside the button), the slider track, fill and knob, the checkbox (the Settings toggles), the divider (the Controls tips) and the scroll bar. The HUD's health segments are the full and empty pieces (a segment just lost shows the pale hit flash for a quarter second), the weapon slot (stretched to the Scrapjack, dark fill behind) holds the gun, and the readiness light and Quickcycle pip are the lit and dark pieces. The banner strip backs the HUD objective and every toast (the HUD's and the objects' own).
- **Sheet 12: icons and key caps.** Chip, five chips, keycard, evidence folder, the Scrapjack icon, key caps (single, wide, arrows, mouse), toast marks. **In the game (2026-10-07).** From `concept-art/ui-sunnyvale/ui-icons-v1.webp` (exact 4 px blocks, 248 x 104 native): the HUD chip and keycard, the save mark, warning triangle and evidence folder on the HUD toasts, the swap arrows on the swap confirm, the gear on the pause menu's Settings button, the subtitle box and speaker beside the Settings rows, and the prompt tag (its pointer split off so the box nine-slices) behind the hero's interact prompt ("Save", "Pull lever", "Workbench", "Swap"). The key caps are built in the game from the blank and wide caps: the CURRENT binding's key label in the Sheet 10 pixel font, dark ink on the cap (A, D, W, E, Q, ESC, TAB, ENTER, F1, SPACE on the wide cap), the arrow glyphs inked on a cap, and the two mice (left or right button lit); Aim is the unlit mouse between the arrow glyphs. The tutorial prompts (tag frame) and the Controls table use them. The sheet's pistol icon was too muddy to use: the HUD's gun is the in-game pixel Scrapjack rig put together in its rest pose (24 x 14 UI px). Not used yet: the two padlocks, the tick, the pressed key cap.
- **Sheet 13: title art.** The DEAD EDEN logo (transparent) and a title backdrop. **In the game (2026-10-07).** The user's generated logo (`concept-art/ui-sunnyvale/title-logo-v1.webp`: steel-grey outlined letters, a teal line and a small arch-and-leaf emblem, drawn in 8 px blocks, so a 150 x 33 texel native logo) and backdrop (`title-backdrop-v1.webp`: the night campus plaza with the glowing tower, 1672 x 941) were imported by `tools/art/import_title_art.py` into `assets/ui/pixel/title_logo.png` and `title_backdrop.png` (1280 x 720). The title screen draws the logo nearest filtered at 5x (750 x 165 canvas px) over the sky at the top right, the backdrop covering the window, and the menu panel under the logo, clear of the tower and Dave.

UI pixels are drawn at **3 canvas px per UI pixel** (a 12-pixel chip icon is 36 px on the 1280 x 720 canvas). Text stays in the UI font for paragraphs and settings (the M6 text-size setting needs a scalable font); the caps-only pixel font from Sheet 10 can be used for HUD labels, button captions and headings, which are short. A lowercase pixel font would be needed to use it everywhere.

As built (2026-10-07): in-world UI (tutorial prompts, the interact prompt, the objects' toasts) uses 3 world px per UI pixel, the buildings' and objects' own pixel; the Controls table draws its key caps at 2 px per UI pixel so its nine rows fit the panel. Everything pixel is nearest filtered through its texture (a `CanvasTexture`), so text keeps its own filtering. In the pixel font: only the HUD's weapon tag (P01) and wallet (drawn CHIPS: 37), with a baked dark outline, 3 px per font pixel at Normal text size and 4 at Large, and the letters on the key caps. Still in the UI font: the objective, toasts, every button caption and heading, the Settings captions, the journal, the Controls table, subtitles, the prompts' action names and the interact prompt's words (all mixed case or long). Still smooth: the UI font itself, the pause dim, the hero's crosshair cursor (Kenney), and the title screen's own glow.

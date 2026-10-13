# Gun Hound

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60) ([style guide](../style-guide.md)).

**Asset ID:** K02\
**Category:** hounds\
**First appearance:** Level 5 (Test Subjects); returns in Level 6 (Cold Storage) only\
**Design status:** Roster entry confirmed (C30, C31). Look follows C60 (approved 2026-10-12): painted HD parts on the lit cutout rig (C56), corporate cyberpunk (C58), Thornwall violet trim (C60). Concept images are still to be generated. Dimensions are provisional art proportions, not engine specifications.

## Identity and role

Cyborg gun dog: it plants its legs, raises a rifle from its back and fires low bursts down its floor.

**Who built and fields it *(proposed)*:** Thornwall, the private military contractor, bought Arcadia's K9 kit and added a stabilized back mount for a carbine. The Gun Hound works beside Thornwall's Riflemen ([SE04](../security/se04-rifleman.md)) in the Rootworks, in Test Subjects (Level 5) and Cold Storage (Level 6), and nowhere else. It shares the Hound's body and rig ([K01](k01-hound.md)), refitted in Thornwall gear: matte charcoal and violet where Arcadia's kit is navy and lime, professional and tidy.

**Why it attacks Dave:** the board's order to Thornwall is "sanitize". The dog covers a lane low, where the men behind it cannot, and it holds that lane until its target stops moving. It is a working animal doing what it was trained to do.

## Scale and silhouette

0.70 m at the shoulder plates when standing, dropping to about 0.45 m when planted to fire; about 1.30 m from nose to rump, plus a 0.40 m tail. In the planted pose the rifle muzzle sits about 0.5 m above the floor (0.3 H).

The Hound's lean, deep-chested silhouette with a compact carbine lying along the spine on a short stabilized mount, muzzle forward over the dog's head. Planted, the dog is low and flat, forelegs braced, with the gun raised clear of its head on the mount arm.

Use a neutral 1.70 m human silhouette as a temporary scale reference on a separate comparison sheet. Dave's final design is not fixed by this measurement.

## Appearance and construction

*Proposed design (C60).* The same dog and the same K9 kit as the Hound ([K01](k01-hound.md)): visor band, steel jaw guard, collar module, plates and natural tail. Refitted for Thornwall:

- **Harness:** a matte charcoal tactical harness with dark slate webbing, quick-release buckles and a small carry loop (no handler handle), charcoal composite plates in place of white, neat cable clips along the plate edges, and a small patch carrying Thornwall's wordless thorn glyph in bone (the final mark is authored separately). A thin violet neon strip (#9B5CFF, Thornwall's color) runs along the spine plates, painted flat with no glow.
- **Collar and visor:** the collar module's lights are shielded, and the visor band is smoked glass with a thin violet edge line, so the dog gives nothing away. Once it hunts, the visor sensor still carries the small amber point.
- **Back mount:** a squat stabilized base bolted through the spine plates behind the shoulders, with a short pivoting arm that carries a carbine cradle. Stowed, the rifle lies flat along the spine, muzzle forward. Raised, the arm lifts it clear of the head. The rifle is Thornwall's matte charcoal TK-12 pattern of the AR-7 "Warrant" ([EG02](../enemy-guns/eg02-assault-rifle.md)) and is a separate sprite: paint the base, arm and empty cradle only.
- **Looks:** two looks on the Hound's rig (C56, C60), both Thornwall: **A**, a black-and-tan shepherd; **B**, a sable (grey-brown) shepherd with a dark mask. Same gear, same stats. It has no Adam-driven or Garden-built variant.

## Color and materials

*Proposed palette:* the Hound's coat, gunmetal and visor colors ([K01](k01-hound.md)), with Thornwall's matte charcoal gear (no teal): harness #25272A with dark slate webbing and buckles #4A5058; charcoal plates #34373B; bone thorn glyph patch #D8D2BC; smoked visor glass #14181E with a violet edge line and spine strip #9B5CFF; the rifle matte charcoal #2A2D31. Look B's sable coat is #7A6A58 with a dark mask #2A2622.

Everything is painted as evenly lit HD parts (C56): soft painted shading for form, clean dark outlines, no cast shadow, rim light or glow; the engine lights the coat, plates and gun mount through their normal maps. Keep the harness and plates in mid-dark values, not black, so the mount and the low planted silhouette read against dark scenery.

**Light and fluid *(proposed)*:**

- No collar lights (shielded). While the dog hunts, the visor sensor shows only a small, dim, steady amber point (#FFB02E).
- The tell lives on the gun: the rifle's muzzle lamp glows amber, then alarm red #FF3B4E for the last 0.25 s, with a 0.2 s red blink before each later burst. The muzzle flash is ivory (tracer ivory #F2EBD3) and separate.
- Blood is red #B3212F, drying to #8A1A26, drawn as a separate spray, wound marks and floor pools, never painted into the base art. The plates throw white sparks. Blood never glows, never uses a tell color and never covers a tell, a ledge or a pickup.
- **Neon (C60):** the violet spine strip #9B5CFF marks Thornwall, who control the dog. It is steady, thinner and dimmer than any tell, never on the rifle or its lamp, and it goes dark on death.

Color values are palette targets for later material work; image generators may approximate them. Pair important cues with geometry, posture, and contrast so they do not depend on color alone.

## Abilities and movement

**Template:** Gunner (dog rig) (C26). **Weapon:** Assault Rifle ([EG02](../enemy-guns/eg02-assault-rifle.md)), back-mounted, fired flat at 0.3 H. Distances are in H, Dave's height, the gameplay unit. The numbers are proposed (P23) and untested.

- **Tell (GLOW):** it plants its legs, belly low and forelegs braced, as the back gun rises and the rifle's muzzle lamp goes amber and then red (red for the last 0.25 s). A 0.2 s red blink comes before each later burst.
- **Attack:** two low 3-round bursts, the rounds 0.08 s apart and the bursts 0.9 s apart, fired flat at 0.3 H with a fixed ±0.04 H jitter. It turns to face Dave only between bursts and never aims at an airborne Dave.
- **Counter:** jump each low burst, then shoot it while the gun cycles (a 1.6 s magazine swap, rooted). 3 hits.

It trots like the Hound with the gun stowed and its head low. Planted, it does not move: the gun is the whole threat. Like the Hound, it bleeds red and sparks at its plates, and its legs twitch for about 1 s after death.

## Openings and limitations

The magazine swap after the second burst: the gun tilts up on its mount arm, the muzzle lamp goes dark and the dog stays planted and rooted. There is no armored weak point and no invulnerable state; a hit anywhere counts.

## Rig parts, normal maps and sockets

- **Parts:** the Hound's dog rig ([K01](k01-hound.md)), unchanged (same parts, pivots and normal-map rules), plus the mount base (on the spine plates), the mount arm and the gun cradle.
- **Pivots:** the mount arm pivots at the mount base to raise the gun; every other pivot is as K01.
- **Normal maps:** one per part, green = up, as K01; cable clips and buckles get shallow relief.
- **Sockets:** the gun socket is the cradle at the end of the mount arm. The [EG02](../enemy-guns/eg02-assault-rifle.md) sprite mounts there at its grip origin, the point the gun rotates about, with its own muzzle-flash light. Its muzzle marker sits at the muzzle lamp, about 0.5 m (0.3 H) above the floor in the planted pose. Spark points at each plate.
- **Fluid:** red blood, as K01: a separate spray, wound marks and floor pools. Plates throw white sparks.
- **Motion and death:** hand-keyed on the rigid parts, like every enemy (C38). On death the parts become physics bodies (a ragdoll, still joined at their pivots, with no dismemberment), the legs twitch for about 1 s, and the rifle and mount arm fall away as a static prop, never a pickup. The body stays as a static corpse.

Plan overlapping drawing layers and visible pivots for the rig. Keep blood, sparks, oil, glows, muzzle flashes, projectiles, attack trails, warning overlays, impacts and environmental props separate from the character. The cutout method is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35); frame counts, timing and export remain later production choices.

## Required pose and state references

Trot with the gun stowed (neutral); plant and raise (the gun rising, lamp amber, then red); low burst; magazine-swap recovery (gun tilted up, lamp dark); hit reaction; death frame with the rifle thrown clear.

Show the muzzle lamp as a flat colored shape with no glow halo: amber in the first half of the plant-and-raise, red in the last quarter, dark in recovery. The rifle is drawn only for state studies, as the separate EG02 sprite; the base painting leaves the cradle empty.

Make these as separate studies after the neutral design is approved. Use the approved neutral image as a reference so poses do not silently change anatomy or equipment.

## Consistency rules

The Hound's dog and augmentation, with Thornwall gear. One back-mounted gun only, on the spine mount: no second weapon, and the gun is never painted into the base art. The muzzle stays about 0.3 H above the floor when planted. No leash, no handler handle, no collar lights, no teal anywhere on the gear, and no neon except the violet spine strip. No tongue, no panting, no wagging, no floppy ears and no exposed organs or bones. The muzzle lamp is amber, or red for the last 0.25 s of the tell only; the muzzle flash is ivory and separate.

**Mirroring** *(proposed)*: paint once, facing right, and mirror the rig for left-facing play. Anatomical left and right belong to the character, so an asymmetric part must be mirror-safe or sit on a separate part the rig can swap. As on the Hound, the visor band is its own part and mirrors cleanly. The back mount and the gun sit on the spine and point along the facing, so they mirror safely.

## Image prompt 1 — neutral design

Copy the entire block into an image generator. Generate and approve this base design before requesting other views.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish.

Design the Gun Hound, a Thornwall security dog in sleek K9 armor with an empty back mount for a carbine. Role: gun dog that plants its legs, raises a back-mounted rifle and fires low bursts.
Scale: 0.70 m at the shoulder plates when standing, about 0.45 m when planted to fire; about 1.30 m from nose to rump, plus a 0.40 m tail.
Silhouette: The lean, deep-chested silhouette of a shepherd-type dog with a steel jaw guard, a slim visor band across the eyes, a ridge of charcoal plates along the spine, a natural tail, and a squat stabilized mount with a short pivoting arm and an empty carbine cradle behind the shoulders.
Physical design: Realistic dog anatomy with a short, groomed black-and-tan coat. A slim smoked-glass visor band across the eyes with a thin violet edge line, alert dark eyes behind it. The real lower jaw is covered by a brushed-steel jaw guard with a servo capsule at the hinge, held shut: no tongue, no panting. A gunmetal collar band with shielded lamps. A matte charcoal tactical harness with dark slate webbing, quick-release buckles, a small carry loop and a small patch with a wordless bone thorn glyph, charcoal composite plates, and neat cable clips along the plate edges. One charcoal plate guards the shoulder and five plates run along the spine, with a thin violet neon strip (#9B5CFF) along them, painted flat. A squat stabilized base bolted through the spine plates behind the shoulders carries a short pivoting arm and an empty carbine cradle. A natural tail carried low.
Materials and colors: Coat black #24211F and tan #A9784A; gunmetal #5A6B80; matte charcoal harness #25272A with dark slate webbing and buckles #4A5058; charcoal plates #34373B; bone glyph patch #D8D2BC; smoked visor glass #14181E; violet strip #9B5CFF. No teal. Lamps are flat, unlit shapes.
Critical consistency: Four legs, one steel jaw guard, one visor band, one shoulder plate, five spine plates, one stabilized mount with an EMPTY cradle, a natural tail. No rifle painted in. Alert, not cute: no tongue, no floppy ears, no wagging pose, no exposed organs or bones, no staples, sutures, matted fur or empty eye sockets.
Use a standing side view with the legs slightly apart so the near and far legs separate, head level, jaw shut and the mount arm lowered; no active attacks or enemies nearby.

One complete 2D subject only, strict side view facing right, full body, centered and fully visible on a flat mid-grey background (#808080), or transparent. Evenly lit hand-painted art: soft painted shading for form, clean dark outlines, and no baked lighting, no cast or contact shadows, no rim light, no glow halos. No blood, wounds, sparks or oil painted in, and no gun painted in (guns are separate sprites on a socket). Leave the carbine cradle empty; the rifle is a separate sprite. Pose the subject so its parts can be cut apart for a rig: limbs and moving parts slightly separated, with clear overlap under each joint. No environment, action effects, UI, watermark, text, logos, labels, measurement arrows or unrelated props. Preserve stated limb and part counts. Draw one subject, not a multi-panel sheet.
```

## Image prompt 2 — directional sprite study

Attach the approved neutral image as the visual reference. If a multi-view sheet changes the design, request each view individually with the same reference and reconcile inconsistencies before sprite production.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached 2D identity reference.

Create a clean 2D directional sprite study of the attached approved Gun Hound design for DEAD EDEN. This is the same exact asset, not a redesign. Show the approved right-facing painting and the same design facing left as separate full-body drawings on a flat mid-grey background (#808080), or transparent. The left-facing drawing is a mirror check: its near side shows the same parts, colors and lamps as the right-facing one, because the rig will mirror the painting. Use the same canvas scale and ground baseline in both directions. Maintain these proportions: 0.70 m at the shoulder plates when standing, about 0.45 m when planted to fire; about 1.30 m from nose to rump, plus a 0.40 m tail. Maintain these defining forms: The lean, deep-chested silhouette of a shepherd-type dog with a steel jaw guard, a slim visor band across the eyes, a ridge of charcoal plates along the spine, a natural tail, and a squat stabilized mount with a short pivoting arm and an empty carbine cradle behind the shoulders. Preserve construction: Realistic dog anatomy with a short, groomed black-and-tan coat. A slim smoked-glass visor band across the eyes with a thin violet edge line, alert dark eyes behind it. The real lower jaw is covered by a brushed-steel jaw guard with a servo capsule at the hinge, held shut: no tongue, no panting. A gunmetal collar band with shielded lamps. A matte charcoal tactical harness with dark slate webbing, quick-release buckles, a small carry loop and a small patch with a wordless bone thorn glyph, charcoal composite plates, and neat cable clips along the plate edges. One charcoal plate guards the shoulder and five plates run along the spine, with a thin violet neon strip (#9B5CFF) along them, painted flat. A squat stabilized base bolted through the spine plates behind the shoulders carries a short pivoting arm and an empty carbine cradle. A natural tail carried low. Preserve the palette: Coat black #24211F and tan #A9784A; gunmetal #5A6B80; matte charcoal harness #25272A with dark slate webbing and buckles #4A5058; charcoal plates #34373B; bone glyph patch #D8D2BC; smoked visor glass #14181E; violet strip #9B5CFF. No teal. Lamps are flat, unlit shapes. Lock these details: Four legs, one steel jaw guard, one visor band, one shoulder plate, five spine plates, one stabilized mount with an EMPTY cradle, a natural tail. No rifle painted in. Alert, not cute: no tongue, no floppy ears, no wagging pose, no exposed organs or bones, no staples, sutures, matted fur or empty eye sockets. Keep all parts fully in frame and clearly separated; show all required views without overlap. Use a neutral repeatable pose, evenly lit hand-painted colors with clean dark outlines, no baked lighting, no cast shadows, no glow halos, no blood and no painted-in gun, no action effects, no scenery. Do not invent new asymmetric features. No labels, text, logos, measuring graphics, cutaway internals, or dramatic perspective. Match the reference rather than inventing unseen decoration.
```

## Image prompt 3 — action and function studies

Use the approved neutral reference. Request one listed state per generation for the clearest sprite and animation reference; repeat for the other states. A support object or arena fragment may appear only where needed to explain contact or scale.

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish. Preserve the attached 2D identity reference.

Using the attached approved Gun Hound reference, draw one clear full-subject 2D animation key pose in strict gameplay side view facing right, showing one state selected from this list: Trot with the gun stowed; plant and raise; low burst; magazine-swap recovery; hit reaction; death frame. If no state is specified, show the main attack anticipation. Preserve anatomy, proportions, colors, attachments, and all part counts. Movement language: It trots like the Hound with the gun stowed and its head low. To fire it plants its legs, belly low and forelegs braced, and the mount arm raises the gun clear of its head. It does not move while firing. In recovery the gun tilts up and the dog stays rooted. Capability: Fires two low 3-round bursts from a back-mounted assault rifle, flat along the floor. Important limitation or opening: The magazine swap after the second burst: the gun tilts up on its arm and the dog stays planted; there is no armored weak point. Show lamps, lenses and seams only as flat colored shapes in the state's color, never with glow halos, and paint no blood, sparks or oil, and draw the rifle only as a plain, flat placeholder carbine silhouette with an unlit muzzle lamp and no muzzle flash (the real gun is a separate sprite): the trot shows an unlit cradle and dark lamps; the first half of the plant-and-raise shows the rifle's muzzle lamp flat amber (#FFB02E) and the last quarter flat alarm red (#FF3B4E); the burst shows a dark lamp; the magazine-swap recovery shows a dark lamp; the death frame shows every lamp dark. Evenly lit hand-painted color with clean dark outlines and no baked shadows, on a flat mid-grey background (#808080), or transparent; no cinematic framing, text, logos, labels, motion blur, or new equipment. The pose must use the exact approved design.
```

## Before sprite production

- Generate the two looks as painted HD parts sheets (C56) with style-frame-v2 attached, once the Hound's sheet exists. Approve one neutral image (prompt 1) before producing animation poses.
- Produce this only after the Hound ([K01](k01-hound.md)) is approved and plays well *(proposed)*: the Gun Hound reuses its rig, so it is built second.
- Keep anatomy, asymmetric attachments, outlines, palette and part counts consistent in left- and right-facing art, and check the mirrored rig in the lit test.
- Split the approved painting into the rig parts listed above, with hidden overlap under every joint and the hidden areas (far limbs, anything a part covers) painted complete, and make a matching normal map for each part (green = up) once the painting is approved. The image generator prompts here ask only for the evenly lit painting.
- Check the silhouette and every tell at gameplay size, in grayscale, and lit in-engine against dark night scenery with one lamp from the left and one from the right, so the normal maps light correctly on both facings.
- Establish a consistent canvas, ground baseline, socket and pivot intent; draw a few key poses before adding small details.
- Keep blood, sparks, oil, glows, muzzle flashes and light pools separate from the parts. A concept PNG is not a finished sprite sheet, layered source file, rig or validated animation.
- The lit cutout look is confirmed direction, validated by the approved lit-cutout test (2026-09-30) (C35): re-check this brief against the approved test look before production.

See [shared style guide](../style-guide.md) and [asset index](../README.md).

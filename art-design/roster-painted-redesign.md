# Enemy roster: the painted, corporate cyberpunk redesign

**Status:** approved by the user 2026-10-12 (C60: neon per controller, Sleepwalkers become Loopers). The user: "redesign/change enemies to reflect what we decided in the prototype". It keeps the roster itself (C31: 24 types in six factions plus four mini-bosses, the gun kit C27, the five behaviour templates C26, every tell and counter) and changes how the enemies look and read, to match what the Level 1 prototype settled: the hand-painted style (C56), alert people and no zombie look (C57), and corporate cyberpunk (C58). Once approved, each brief in `art-design/` and the concept's enemy tables are rewritten from this page.

## What the prototype decided

1. **Painted HD lit cutouts** (C56): every enemy is a painted parts sheet on a lit cutout rig, generated against the approved style frame, with hand-keyed motion and ragdoll deaths. Each type gets **two or three looks on one shared rig** (the Night Guard's veteran, young and woman; the Staffer's three teammates; the rover's two liveries).
2. **Alert people, never zombies** (C57): every human enemy stands upright, eyes open, moving with purpose. The Linked are calm, polite and precise, a little too perfect; the Link shows as technology (a clean port with a light ring, a glint in the eyes, synchronized moves), never as a dead face, a shuffle, stitches or wounds.
3. **Corporate cyberpunk** (C58): clean, expensive, engineered hardware; sleek uniforms; neon trim; holograms. Grit only on the service crews and contractors.
4. **Gameplay lessons kept:** tuned gameplay numbers stay fixed constants, not derived from art size (the rover's sight line, C58); chargers need backstops to stall against; every placement is checked in game after an art swap.

## Look rules for every enemy

- Painted against style-frame-v2; strict side view; evenly lit parts (the engine lights them); Caucasian skin for every human (C43).
- Faces: awake and readable. No blank stares, no slack jaws, no sutures, plates through skulls, exposed tissue, matted fur or dripping fluids. Blood is the engine's, on hits and deaths only (C29).
- Implants and cybernetics are clean products: brushed steel, white composite, a neon ring, a status light.
- One neon trim colour per **controller** (see below), painted as a flat stripe; the engine makes it glow; dark on death; never on the attacking part or a weak point; never teal, amber, red or white (scenery and tells own those).
- Silhouette tells the type, so two types of one colour never share a silhouette.

## Neon: one colour per controller (C60, replaces C36's per-type rule)

C36 gave every enemy type its own colour. With 24 types, and teal, amber, red, white and gold already reserved, there are not 24 colours a player can tell apart at a glance. Proposal: the colour says **who controls it**, and the silhouette says what it is.

| Colour | Who | Types |
| --- | --- | --- |
| Lime #C6FF3D | Arcadia Security | Night Guard, Sidearm Guard, Riot Officer, Rifleman (Response Team), Hound with a handler |
| Violet #9B5CFF | Thornwall | Rifleman (Thornwall), Heavy Gunner, Grenadier, Marksman, Gun Hound |
| Electric blue #4D8DFF | The Linked (people Adam drives) | Staffer, Linked Lineman, Linked Nurse, Linked Trooper |
| Magenta #FF3DD5 | Adam's own hardware | every machine, the Heirs, Adam-driven Hounds, Garden-built copies |

This keeps the three colours already in the game (lime guard, blue Staffer, magenta rover) and adds one.

## Type by type

| Type | Keep | Change |
| --- | --- | --- |
| **Night Guard** (SE01) | As built: fit, alert, navy uniform, lime piping, shock baton; three looks. | — |
| **Sidearm Guard** (SE02) | Pistol stance, muzzle-lamp tell. | Same uniform family as the Night Guard plus a light tactical vest and a holster; three looks (a young woman, a wiry man, a heavyset older man); the AS-9 pistol is a sleek white-and-graphite Arcadia product. |
| **Riot Officer** (SE03) | Shield and maul. | A clean white-and-navy ballistic shield with a lime edge strip and the Arcadia arch; full helmet with a dark visor. |
| **Rifleman** (SE04) | Burst rifle. | Arcadia Response Team: navy armour with lime; Thornwall: matte charcoal with violet. Two looks each. |
| **Heavy Gunner, Grenadier, Marksman** (TW01–03) | Their guns and tells. | Thornwall contractors: matte charcoal plate carriers, helmets with violet visor strips; professional, unhurried, never sloppy. |
| **Staffer** (LK01) | As built: three teammates, navy staff jacket, blue stripe, Link port, restraint grips. | In Level 2 they are Dave's old alignment team. |
| **Linked Lineman** (LK02) | Arc-caster rod, floor arc. | A Rootworks electrician in an insulated work suit; the cables run in a clean armoured sleeve from a back capacitor to the rod, **not** sutured into his arms; port and blue ring. |
| **Linked Nurse** (LK03) | Sterilant vials. | A crisp white clinic uniform with blue piping; composed and gentle-voiced; the vial tray is a sleek clinic product. |
| **Linked Trooper** (LK04) | Plasma carbine. | A captured Thornwall contractor in his own armour with a blue Link visor band over the eyes; **no** steel plate through the scalp, **no** unblinking stare: alert, synchronized, precise. |
| **Hound** (K01) | Double lunge, jaw tell. | A sleek armoured K9 (shepherd build) in a fitted harness with a visor band over the eyes, a steel jaw guard and a neon strip along the spine (lime with a handler, magenta when Adam drives it). **No** debarking, empty eye socket, cable tail or matted coat. Two looks: Arcadia K9, Adam-driven. |
| **Gun Hound** (K02) | Back-mounted rifle. | The same body in Thornwall charcoal with violet, a compact rifle on a stabilized back mount. |
| **Patrol Rover** (M01) | As built: the squat armoured van, magenta strip, two liveries. | — |
| **Security Drone** (M02) | Dive at the locked spot, lightbar tell. | A sleek ducted-fan drone in white composite with a magenta underglow strip, a lightbar and a folding shock fork. Two liveries (Arcadia white, Garden-built). |
| **Sentry Turret, Freight Loader, Sanitizer, Orderly, Keeper Drone** (M03–M07) | Their jobs and tells. | Clean industrial products in white, graphite and safety markings, magenta trim. The Orderly's stretcher carries a zipped bag, never a visible body. |
| **Pruner, Fitting Arm** (M08–M09) | Cutter beam; claw sweep. | Garden-built: unpainted factory-white polymer with assembly markings and magenta seams; the Pruner's "petal cowl" becomes a segmented aperture shutter. |
| **Fitted Heir, Warden** (HE01–02) | Their tells, their lines in dead colleagues' voices. | Sleek synthetic people: white-and-graphite shells, magenta seam lights, and a **face display** that shows a dead colleague's face. **No** cracked ceramic, grown tissue or lymph. Unsettling by being almost right, not by being wounded. |
| **The Peacekeeper** (B01) | Crowd-control truck, roof gun. | Built like the new rover, scaled up: an armoured white-and-navy truck with an Arcadia arch and a magenta strip (a machine Adam drives, so Adam's colour). |
| **Howard Stroud** (B02) | His fight, his last words. | A clean exo-frame and a Link crown with blue light; his own face stays visible and human, angry and scared, which is the horror. |
| **The Surgeon, the Sower** (B03–B04) | Their fights. | Precise, beautiful medical and launch machines in white and graphite with magenta; no gore on them. |
| **Looper** (NPC01, protected; was the Sleepwalker) | Protected, no hit zone. | Renamed (C60): staff whose failing implants hold them in a routine, eyes open and busy (filing, wiping a desk, walking the same corridor), port light flickering. |

## Gun kit (C27)

Unchanged in function. Visually, every Arcadia gun is a sleek white-and-graphite product with the arch logo; Thornwall's are matte charcoal; Adam's plasma and seeker read as magenta-trimmed hardware. Tell lamps stay amber then red.

## On approval

Rewrite each brief's appearance section, the concept's enemy tables and the style guide's neon rule (C36 becomes per controller), add the decision to `design/decisions.md`, and generate parts sheets per level as each type is built, Level 2's first: Sidearm Guard, Hound, Security Drone.

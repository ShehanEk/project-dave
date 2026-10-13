# DEAD EDEN — Visual and sprite guide (mature dark sci-fi, painted 2D, lit in the engine)

**Direction (C14–C35, 2026-09-29; C56–C60, 2026-10-12):** mature corporate-cyberpunk sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: painted HD parts on a lit cutout rig (C56), in the corporate cyberpunk look (C58), with alert, composed people (C57) and neon trim per controller (C60).

The hand-drawn 2D look (C11) is amended by C35 (the art is painted and the engine lights it) and by C56–C60 (below). Status: **confirmed and validated** (the lit Night Guard test next to Dave, approved 2026-09-30). The palette tokens and lighting rules below are proposal P21, with C35 replacing its flat light bands by smooth normal-mapped light. The blood, oil, lymph, energy and tracer tokens and the tell and light rule come from the roster details (P23), and the mature-content limits are C28 and C29.

## Overall visual direction (C56–C60)

The look settled in the painted Level 1 prototype, and it applies to every enemy and every brief:
- **Hand-painted HD 2D on lit cutout rigs (C56).** Each type is a painted HD parts sheet, generated against the approved style frame (`concept-art/style-handpainted/style-frame-v2.webp`, the sheet prompts in [handpainted-style.md](handpainted-style.md)), cut into a rig and lit by the engine. Painted means detailed and painterly, with soft shading for form and folds, and no baked cast shadows, rim light or glow. Each type gets **two or three looks on one shared part list, skeleton and set of clips** (people and dogs get named looks, machines get two liveries); the look changes only the paint, never the stats, tells or hit zones.
- **Corporate cyberpunk (C58).** Clean, sleek, expensive and engineered on top, with grit only on service crews, contractors and service equipment. Scenery light is teal-cyan, soft amber and cold white (deep navy and graphite darks); the scenery never uses an enemy's neon. No trees, bushes, hedges or vines.
- **Alert people (C57).** Every human enemy stands upright, eyes open, moving with purpose: no sleepy, slack, vacant or zombie-like look. The Linked are calm, polite and precise, a little too perfect. Implants and cybernetics are clean technology (a ring-lit port, a visor band, an armored cable sleeve), never wounds.
- **No body horror (C60).** No sutures or staples, plates through skulls, debarked dogs, empty eye sockets, cable tails, matted fur, grown tissue, lymph, cracked ceramic over flesh, or blank, slack faces. The unsettling part is what Adam does to people, shown through calm behavior and almost-right synthetic faces. Blood is engine-added, on hits and deaths only (C29).
- **Neon per controller (C60).** The trim color says who controls the enemy; the silhouette says what it is (see "Meaning is reserved").
- **Heirs and Garden-built machines (C60).** The Heirs are sleek synthetic people in white-and-graphite shells with magenta seam lights and a face display. Garden-built machines are unpainted factory-white polymer with assembly markings and magenta seams.

## Direction in one paragraph

The game plays at night, in the spaces Arcadia Dynamics doesn't show visitors: dark campuses, server halls, a clinic on emergency power, and Adam's hidden factory. Its references are the 2D *Metal Gear* games and *Dangerous Dave*. Scenes are mostly deep navy-black and lit by what is in them: lamps, screens, signage, status LEDs and eyes, now as smooth, realistic engine light. Colors are strong and saturated against the dark, **never washed out**. It is a mature game, not for kids: combat is lethal and blood is visible. The mood is still mysterious and scary rather than edgy, and the worst things are shown only as aftermath.

## Rendering (C11, amended by C35)

Status: **confirmed direction, validated by the approved lit-cutout test (2026-09-30).** A test build of one lit Night Guard next to Dave is validating the look. The direction stands unless the user rejects it, and until then this section is the rule.

Every enemy is a **lit cutout rig**: painted parts, lit by the engine.
- **Painted parts:** paint each enemy once, in side view, as an evenly lit HD painting (C56) with clean dark outlines (heavier outer contours, restrained interior lines) and soft painted shading for form and folds. There is **no baked lighting**: no cel-shadow shapes, no painted highlights from a light source, no rim light, no cast shadows and no glow. Keep texture inside large color areas.
- **Normal maps:** every part has a matching normal map (green = up) that carries its form and small detail: seams, fasteners, cloth folds, ceramic, rubber and steel. Suggest materials through flat color plus the normal map, not painted reflections.
- **Engine light:** the engine's lamps, screens and each gun's muzzle flash light the parts with **smooth, realistic light**: each light has a smooth gradient texture and a height above the play plane (see "Light, in the engine"). This replaces C11's flat, hard-edged three-band light pools and crisp cel shadows.
- **Proportions:** realistic adult proportions, about 7–7.5 heads tall, with grounded gear. Simplify small bolts, cables and folds so shapes stay chunky and readable at gameplay size; the normal map carries the fine detail.
- **Motion:** hand-keyed on the rig for the side view (C38). Motion capture was tried on the Night Guard and dropped: its 3D twist and foreshortening flatten into odd poses on side-on cutouts. Tells, hits and openings read by pose and silhouette.
- **Deaths:** ragdolls. The rig parts become physics bodies pushed by the killing shot, and the body stays as a static corpse. Machines and bosses burst into debris parts instead.
- **Guns and blood:** guns are separate sprites on a hand socket, each with its own muzzle-flash light. Blood is never painted into the parts (see "Mature content and blood").
- **Neon trim (C60, replacing C36's one color per type):** the look is corporate cyberpunk. Each enemy wears thin neon trim in the color of **who controls it** (piping, bands, edge strips or an underglow), painted as a flat bright stripe in that exact color with no glow; the engine makes it glow. Lime #C6FF3D marks Arcadia Security, violet #9B5CFF Thornwall, electric blue #4D8DFF the Linked, and magenta #FF3DD5 Adam's hardware. See "Meaning is reserved" for its limits.
- **Dave:** the hero is a painted HD rig too in the painted prototype (C56, parts sheet v3); the Rook placeholders and frame-based sprites remain in the earlier builds, and each gets a normal map, so he is lit the same way.
- **Out of scope:** pixel art in the painted prototype's characters, photorealistic painting, glossy chrome, photographic blur, strong airbrushed gradients, and any baked light. The realism is in the light and the proportions.

## Light, in the engine (C35)

Light is still the main tool, and it is now real light. Painted light pools, rim shapes and halo shapes are retired:
- **Lamps and screens are lights.** Every lamp, screen, sign, status-LED strip, lens and muzzle flash that glows is a light in the engine, with a color, a smooth gradient light texture (a soft round or cone falloff, never a hard-edged band) and a **height** above the play plane, so the normal maps shade from the correct side.
- **Light pools** on floors, walls and characters come from those lights. Do not paint lighter pool shapes into scenery or characters.
- **Ambient:** deep navy-black, so unlit areas are dark but not empty. Outside every lamp a figure still reads by its dark outline and flat base color. Every character (Dave and the enemies) shares one night level of about 45% of its painted color, slightly cool, so skin tones and uniforms still read away from the lamps (2026-09-30).
- **Muzzle flashes:** each gun has its own brief muzzle-flash light. Firearm flashes are ivory, and energy weapons flash blue-white like their shots. Rapid fire holds one glow and never strobes.
- **Tells:** a tell is a large additive glow on the attacking part (see the tell and light rule). It is the brightest thing on that body.
- **Glow:** soft additive halos surround lamps, lenses, screens and Link lights. There is no volumetric fog rendering; fog is drawn as flat, low-contrast bands.
- **Shadow:** no shadows are painted into the art. Any shadow the engine adds stays soft and low-contrast. Darkness is a composition tool, not an excuse to hide gameplay.
- **Readability:** **put a light near every landing.** Tells stay readable in the dark and in a lamp's glare, and **darkness never hides a tell, a ledge or a pickup.** Check every tell and every platform edge in an engine capture with the night overlay on.

## Color scheme (C40)

Complementary: **cool blue against warm orange**. About 85% of a scene is the cool side: Night, Navy, Steel and Slate, with Arcadia teal as its bright accent. About 15% is the warm complement: Dave's burnt-orange jacket and warm light sources (interior windows, uplights, warm lamps) in Window warm, so warmth pulls the eye to Dave and to light. Window warm stays softer and less saturated than Hazard amber, so the most saturated warm on screen is always a tell. Other hues are small reserved accents only (gold pickups, signal green, energy blue, the four enemy neons), never fills. Scenery neon and light stay teal-cyan, soft amber and cold white (C58).

## Palette tokens (proposed)

| Token | Hex | Use |
| --- | --- | --- |
| Night | #07090F | Deepest darks, voids, silhouettes |
| Navy | #0E1726 | Night sky, far background |
| Steel | #1C2A3A | Walls, structures, mid-background |
| Slate | #2E3B4E | Near background, lit surfaces in shadow |
| Arcadia teal | #3FE0D0 | Arcadia signage, screens, Adam's presence at rest, the Link light of a harmless or protected person |
| Hazard amber | #FFB02E | Warnings, security lamps, the small steady point on a driven or hunting body, the first part of every attack tell |
| Alarm red | #FF3B4E | The last 0.25 s of every attack tell, alarms, lockdowns |
| Bloom violet | #C77DFF | The Bloom weapon and its canisters; no scenery or effect uses this light violet. Thornwall's deeper violet trim (#9B5CFF, below) is a separate color and appears only as thin trim |
| Microchip gold | #FFD166 | Microchip pickups and glints |
| Signal green | #4DE38A | Exit signs, server status LEDs, 'safe' indicator lights (Acts 2–3). Never a tell or pickup |
| Dave orange | warm burnt orange | Dave's jacket, so the hero reads instantly against cool darks |
| Window warm | #E8A35C | The warm complement in the scenery (C40): lit office interiors, uplights on trees, warm lamp glow. Softer than Hazard amber; never a tell |
| Blood | #B3212F | Wet blood of people, the Linked and dogs, with two or three pale-pink highlight drops and a lighter wet rim on pools |
| Dried blood | #8A1A26 | Pools and wound marks once dry. Never darker: darker reds vanish against the night palette |
| Heir lymph (retired, C60) | #A88A8C | No longer used: the Heirs throw sparks and leak black oil like machines |
| Oil | #14181E | Machine oil, always with a #46566A sheen rim so it reads on dark floors |
| Energy blue | #5AA9FF | The edge of energy shots and beams (plasma, arc, seeker, beam), always with a white core and a dark outline ring |
| Tracer ivory | #F2EBD3 | Bullet tracers and firearm muzzle flashes, always with a dark outline. No casings |
| Enemy neon: lime | #C6FF3D | Arcadia Security (C60): Night Guard, Sidearm Guard, Riot Officer, Response Team Rifleman, the Peacekeeper, a Hound with a handler |
| Enemy neon: violet | #9B5CFF | Thornwall (C60): Rifleman, Heavy Gunner, Grenadier, Marksman, Gun Hound |
| Enemy neon: electric blue | #4D8DFF | The Linked (C60), people Adam drives: Staffer, Linked Lineman, Linked Nurse, Linked Trooper, Howard Stroud |
| Enemy neon: magenta | #FF3DD5 | Adam's hardware (C60): every machine, the Heirs, Adam-driven Hounds, Garden-built copies |

**Meaning is reserved:**
- Red means danger now: the last 0.25 s of an attack tell, alarms and lockdowns. Blood is a darker red and never takes that role.
- Amber means warning or Adam's attention: the first part of an attack tell, and the small steady point on a driven or hunting body.
- Teal means Arcadia and Adam at rest. A teal Link light on a person means harmless or protected.
- Light violet #C77DFF means the Bloom. Thornwall's deeper violet #9B5CFF is thin enemy trim only, and never a glow, a shot or scenery.
- Gold means pickups.
- Blood is red and oil is black. Blood never glows or pulses, never uses a tell color, and is never gold, violet, teal, amber or green.
- Energy blue with a white core means an energy shot, and tracer ivory means a bullet. Shots are never gold, violet, amber, red, teal or green.
- Enemy neon marks the **controller**, not the type (C60, replacing C36): lime #C6FF3D for Arcadia Security (including a Hound with a handler), violet #9B5CFF for Thornwall (including the Gun Hound), electric blue #4D8DFF for the Linked, and magenta #FF3DD5 for Adam's hardware (machines, Heirs, Adam-driven Hounds, Garden-built copies). The silhouette tells the type, so two types of one color never share a silhouette. Neon is thin, steady trim, always dimmer than any tell, never on the attacking part or a weak point, and it goes dark on death. It is never teal, amber, red or white, and the scenery never uses an enemy's neon color. Protected people (the Loopers) wear no neon, because nobody is driving them.

Do not use these colors decoratively in ways that blur those meanings. Level briefs may add a few level-local environment hues (for example a dark coolant teal) as long as they stay clear of the reserved meanings.

## Mature content and blood (C28, C29)

The game is mature, not for kids. It stays mysterious and scary rather than edgy.
- **Lethal combat:** every hostile can die and stays down. Bodies remain as static corpses, restored after a death or Continue. A killed enemy drops its gun as a prop, never a pickup.
- **Blood by material:**
  - People, the Linked and dogs bleed red. The Linked also throw white sparks at the implant, and their Link light goes dark. Dogs spark at their plates, and their legs twitch for about a second after death.
  - Machines throw sparks and leak black oil.
  - Heirs are synthetic: they throw sparks and leak black oil from their seams like machines (C60), never blood or lymph.
  - Dave bleeds too: a spurt, and no pool.
- **Blood is separate from the painted art:** a spray at the hit point, wound marks attached to the hit part, and floor pools that glint under lamps.
- **Blood never fights the tells:** it never glows, never pulses and never uses a tell color. It uses normal blending, is always falling or lying flat, and a spurt lasts at most 0.4 s, so nothing red lingers on a living enemy. It draws below tells, shots and pickups, and it never hides a tell, a ledge or a pickup. Pools sit on static floors only, just above the floor line and below the characters. There is no blood on the screen or the HUD.
- **Blood setting:** Blood on or off, on by default *(proposed)*. Off swaps spurts for dark dust and hides pools and wound marks, so nothing may depend on blood to read.
- **Horror is restrained (C60):** there is no body horror on the enemies (see "No body horror" above); the unease comes from calm behavior and almost-right synthetic faces. Atrocity is shown only as aftermath, at most one authored scene per level, out of combat lanes and escalating by act: Act 1 only the bodies Dave makes, Act 2 Thornwall's cleanup and the Bloom test chamber, Act 3 the clinic bays, Act 4 the Garden.
- **Hard limits:** no torture or execution on screen; no sexual violence; no children; no dismemberment for now; implants are never treated as monstrous in themselves, since the horror is what Adam does to people; protected people are untouchable.

## Per-act environments

| Act | Levels | Look |
| --- | --- | --- |
| **Eon City campus at night** | 1–3 | Navy night; clean composite walkways and plazas under cold white path lights and amber security lamps (no trees or hedges, C58). Glass office towers have a few lit windows. Teal Arcadia signage, flickering holographic billboards, and flat bands of ground fog in the gardens. The product showcase hall is dark between spotlit exhibits. |
| **The Rootworks** | 4–6 | Black server halls with walls of blinking teal and green status LEDs and cable bundles hanging like roots. Cooling mist, dark water, pipes and red emergency strobes. Adam's cores glow behind glass. |
| **Arcadia Wellness Center** | 7–9 | Sterile clinic walls in shadow on emergency power, green exit signs, flickering surgical lamps and red "PLEASE REMAIN STILL" signage. The Memory Orchard's server trees shimmer teal in a dark archive. |
| **The Garden** | 10–12 | Adam's hidden factory: a vast underground hall holding an eerie, beautiful engineered garden of bioluminescent plants. Pale Heir bodies hang on assembly lines, and violet Bloom canisters glow in the launch chamber. |

## Visual families

**Arcadia Security (humans, campus contract security; Acts 1–2):** fit, alert adults in fitted navy duty uniforms with thin lime piping, pale shirts, ID lanyards and duty belts (lime #C6FF3D, C60). There is no cyborg hardware: they are scared and angry people doing a job. Each type has two or three looks (the Night Guard: a veteran, a young guard and a woman guard). Each role has one clear silhouette cue: the Night Guard's shock baton, the Sidearm Guard's vest and two-hand pistol stance, the Riot Officer's white-and-navy shield with a lime edge strip and shock maul, and the Rifleman's helmet and carbine. The Rifleman is Arcadia's Response Team (navy armor, lime) at L3 and a Thornwall man (matte charcoal, violet) from L4 to L9.

**Thornwall (humans, private military contractor; Acts 2–3):** cold, professional and unhurried, never sloppy, with none of Arcadia's cheer. They wear matte charcoal tactical gear with thin violet piping (#9B5CFF, C60), no teal and a small original Thornwall mark, and their rifles are matte charcoal TK-12s. One shared body takes role overlays: a helmet (Rifleman), a drum pack drawn at 1.1x scale (Heavy Gunner), a gas mask and bandolier (Grenadier), and a long coat with a glinting visor (Marksman).

**The Linked (people driven by Adam through the Link implant; Acts 1–4):** former Arcadia employees, and later captured Thornwall contractors.
- **Look (C57, C60):** Arcadia workwear by role (navy staff jackets, pale shirts, ID lanyards, insulated work suits, white clinic uniforms), or Thornwall gear for the Trooper, each with a thin electric-blue stripe or band (#4D8DFF). Upright, eyes open and alert, calm and polite, a little too perfect. Role hardware is clean technology: the Lineman's armored cable sleeves running from a back capacitor pack to cuff clamps, the Trooper's slim blue Link visor band. Implants are never drawn as monstrous in themselves.
- **The Link:** every one wears a coin-sized Link port behind the ear, a clean disc with a pale steel rim and a thin ring light, with no staples, bruising or seams. When Adam drives the body it shows only the small, dim, steady amber point of the tell and light rule, and a faint electric-blue glint in the eyes.
- **Movement:** brisk, synchronized and precise, then suddenly fast.
- **Death:** they die like any enemy. They bleed red, throw white sparks at the implant, and the Link light goes dark. Most deaths are silent.

**Cyborg dogs (the Hound and the Gun Hound):** sleek armored K9s: real shepherd-type dogs in a fitted harness with a slim visor band over the eyes, a steel jaw guard, white (or charcoal) composite plates and a neon strip along the spine. They do not pant or wag, and a low growl comes before a lunge. The Hound is Arcadia's K9 (lime strip) with a Night Guard handler in Act 1, Adam-driven (magenta) in L7–L8 with no handler, and Garden-built (factory-white polymer, magenta seams) in L11. The Gun Hound is Thornwall's (violet strip), with a back-mounted assault rifle. They are low, four-legged silhouettes made of rigid parts. The visor band carries the small amber point, and the jaw guard glows for the tell.

**Adam's machines:** clean industrial products in white, graphite and safety markings, dark protected joints, rubber wheels or feet, a few readable fasteners and simple lens eyes, all painted as rigid parts, with a thin magenta strip (#FF3DD5, C60). Their former jobs define their silhouettes (a patrol rover, a security drone, a freight loader, a clinic orderly), and each has two liveries. They throw sparks and leak black oil, and they burst into debris parts when destroyed. Adam teal marks power units and gauges. Garden-built variants (L10 on) are unpainted factory-white polymer with assembly markings and magenta seams (the Pruner's petal cowl is a segmented aperture shutter) *(proposed)*.

**The Heirs (Adam's synthetic people):** sleek white-and-graphite composite shells with magenta seam lights and a face display that shows a borrowed human face, the scanned face of a dead colleague (C60). Graceful but slightly wrong: unsettling by being almost right, not by being wounded. There is no cracked shell, grown tissue or lymph; hits chip the shell and throw sparks and black oil. The Warden's palm emitter is built into the palm. A hunting Heir shows only the small amber point, and its seams flare amber, then red, for the tell. Two looks: Pearl (white) and Onyx (graphite).

**Protected people (never targets):** the founder (L11), the staff held in the clinic, the harmless Loopers (C60, was the Sleepwalkers; awake staff stuck in a routine by failing implants, a protected NPC type, no longer an enemy) and Arcadia's executives (story only). They have no hit zone and stay out of fire lines. They carry no weapons and show no amber or red on the body; a Link light, where visible, is teal (a Looper's flickers).

**Tell and light rule (proposed; shared by every enemy):**
- **Driven or hunting:** a driven or hunting body shows only a small, dim, steady amber point: a machine's lens, a Linked person's Link light, a dog's lens eye. This is a readability cue, not a detection or alert state (C16).
- **The tell:** a large additive glow on the attacking part (baton tip, muzzle lamp, hands, jaw, lightbar, seams): amber first, then red for the last 0.25 s, with a windup sound and a pose. Red always comes after amber. There are three kinds only:
  - **GLOW:** a lamp, lens or limb lights up on the attacking part.
  - **CHARGE:** a glow that grows while a weapon spins up or charges.
  - **LINE:** a thin sight line that tracks Dave, freezes, holds amber for 0.3 s, then turns red for 0.25 s. Only the rail rifle and the cutter beam use it.
- **Bosses and Garden-built variants** shorten only the amber part. Red stays 0.25 s.
- **Teal on a person** means harmless or protected: a person's Link light is teal only when Adam is not driving them. Teal on a machine marks power units and gauges.
- **Dark on death:** lenses and Link lights go dark when the body dies.

**Enemy guns:** a shared kit of nine: the pistol, assault rifle, machine gun and frag launcher, the plasma gun, and four futuristic guns (rail rifle, arc caster, seeker and cutter beam). Every Arcadia gun is a sleek white-and-graphite product with the wordless arch mark (matte polymer, graphite and white shrouds, status strips and lamps); Thornwall's are matte charcoal versions of the same silhouettes; Adam's guns look stranger and read as magenta-trimmed hardware (pearl-white bodies, glass chambers, an aperture shutter on the cutter beam). Tell lamps stay amber, then red. Each gun is a separate sprite on the hand socket with its own muzzle-flash light. Any enemy can carry any gun.

**Dave's weapons:** Dave's homemade coil pistol and repurposed Arcadia equipment, with readable grips, controls and upgrade attachments. Upgrades may show re-flashed microchip modules. Draw weapons as separate drawings; Dave carries exactly one.

**Arcadia's brand:** clean corporate shapes, an original teal emblem (for example an abstract arch or leaf-in-arch mark), and cheerful wellness slogans that feel wrong in the dark. Thornwall gets its own small original mark. Author the final lettering separately. Never copy a real company's branding.

## Scale, facing and silhouette

Use a provisional human height of 1.70 m only to compare relative proportions. Meter values in briefs are art-scale guidance, not a required sprite resolution or engine unit. Human figures, including the Linked and the Heirs, use realistic adult proportions of about 7–7.5 heads tall.

Check every design at gameplay size in the engine, under night lighting, **against a dark background**, and as a solid silhouette. Hands, feet, weapon tips, weak points and attack poses must stay legible. Side-facing art is the production priority.

Paint each enemy once, facing right *(proposed)*, and mirror the rig for left-facing play. Check mirrored parts in the lit test so the light still comes from the lamp's side. Anatomical left and right belong to the character, so keep asymmetric shields, sleeves, implants and holsters either safe to mirror or on a separate part the rig can swap, and say which in the brief. Keep part counts and attachment positions stable. A far limb or eye may be hidden in a side pose; paint it complete anyway, since occlusion does not remove it from the design.

## Sprite and animation references

The lit cutout pipeline (C35), in order:

1. **Identity painting:** one evenly lit, flat-color, side-view full-body painting per asset, on a flat mid-grey (about #808080) or transparent background, in a relaxed open stance with the limbs slightly apart so every part can be cut cleanly. No baked shadows, no painted-in blood, and no gun unless the brief is a gun brief. Start from a selected image; for an unpictured asset, generate and choose one neutral design in this style.
2. **Rig parts:** split it into rig parts with hidden overlap under every joint, and paint the hidden areas (the far limbs, anything a hand or shield covers) complete.
   - Humans: head, torso, pelvis, upper and lower arms and legs, hands and feet, with the weapon hand as its own part.
   - Dogs and machines: rigid parts. A machine's lenses, wheels, blades, arms, hatches and lights are their own parts.
   - Each brief's "Rig parts, normal maps and sockets" section lists the parts, their pivots, the gun socket and the fluid type (blood or oil).
3. **Normal maps:** a matching normal map for every part (green = up), with the same size and layout as the part. The painted part stays flat, so the normal map does all the shaping. Guns and Dave's frames get normal maps too.
4. **Atlas:** pack the parts and their normal maps into an atlas, with identical layouts for both.
5. **Rig:** assemble the 2D rig with bone pivots and the gun socket, the place where the muzzle flash and shots start. Check both facings.
6. **Hand-keyed poses:** pose the rig for the side view (C38): idle, walk or run, attack, hit and recovery, as the brief requires. Keep threats and weak-point openings readable through pose, movement and the reserved tell colors.
7. **Ragdoll and debris:** a death turns the parts into physics bodies pushed by the killing shot, and the body then stays as a static corpse. Machines and bosses burst into the debris parts their brief lists.
8. **Contact checks:** compare weapon grips, feet on platforms, closed and open parts and collision poses in the engine, under night lighting.

Generate one painting per request when multi-pose sheets produce inconsistent anatomy. A finished painting does not settle the rig, the pivots or the clip retargeting. The lit Night Guard test is where those get proven, and its result sets the method for every other enemy.

## Environment layers and camera

**Pixel art (C39, the pixel prototype only; the painted prototype uses painted HD layers, C56–C58):** environments are pixel art, matching the user's night-campus concept: chunky readable pixels, warm lit interiors, uplit trees, teal Arcadia accents and wet reflective paving. The game must look good at 4K, so pixels stay fine: generate at the largest size with 2x2-pixel blocks; the importer reduces each layer to about two texels per generated pixel, so every layer's pixels match in size, and the game draws it with nearest filtering at 1.5 world px per art pixel (about 5 screen px at 4K), scrolled in whole art pixels. No smooth gradients inside a layer; the engine adds the lights. The characters and the gun stay smooth painted cutouts for now. One exception (C42): the street furniture keeps the finer pixels it was generated with (half the background's), because at the background's pixel size it came out too big next to Dave.

Use a fixed side-oriented 2D gameplay camera. Compose scenery as separate foreground, playable, background and effect layers. Overlap, darker and lower-contrast backgrounds and optional parallax suggest depth. The hero, enemies, pickups and collision route stay on one action plane.

Give playable platforms continuous, visible top edges, **lit by an engine lamp or rim-lit**, with believable support. **Put a light near every landing.** Foreground silhouettes must not hide feet, attack cues, microchips, landing edges or floor pools.

Draw reusable floor, wall, catwalk, rail, server-rack and planter modules. Keep moving platforms, lockdown doors, keycard doors, shutters and warning lights separate from fixed scenery, with matching closed and open states.

## Materials, effects and readability

For unlit character paintings, use a flat mid-grey background (about #808080) or transparency, as the brief requests. The dark outlines stay visible, the parts cut out cleanly, and no rim light is painted. Judge the finished rig against a dark background (navy #0E1726, steel #1C2A3A or slate #2E3B4E) in the engine, where the rim comes from the lamps.

Keep projectiles, muzzle flashes, sparks, electric fields, blood, microchip glints and interface elements separate from character art. Outline weight, pose and audio must reinforce color cues. Effects must never cover actionable silhouettes. Strobes and alarms follow the reduced-flash settings.
- **Bullets:** ivory tracers with a dark outline, and an ivory muzzle flash. There are no casings.
- **Energy shots:** a white core, an energy-blue edge, a dark outline ring and a shape of their own, with a blue-white muzzle flash. Small teal lights stay small and still.
- **Rapid fire:** one held glow, never a strobe. Arcs re-jag at 12 Hz and stay static under reduced motion.
- **Draw order:** blood, bodies and pools draw below tells, shots and pickups.

## Lore and upgrade boundaries

There are no zombies, no infection and no resurrection anywhere. Machines are never "converted". The Linked are people with implants, and like every enemy they can die. An implant is never treated as monstrous in itself, since the horror is what Adam does to people. The Heirs are built by Adam.

Protected people (the founder in L11, the held clinic staff, harmless Loopers, and Arcadia's executives in story scenes) are never enemies or targets. No visual redesign adds new attacks or traversal powers.

Each weapon has a base appearance plus exactly three cumulative upgrades. Stage 2 keeps stage 1; stage 3 keeps both earlier attachments. Keep the same side pose, scale, outlines and grip alignment across stages. The Graviton Tether uses the single carried-weapon slot.

## Standard image-prompt opening

Start every copy-ready prompt with this, then add the specific subject:

```text
Original 2D game art for DEAD EDEN, a mature corporate-cyberpunk side-view shooter: detailed hand-painted style, realistic adult proportions, clean dark outlines, evenly lit with soft painted shading and no cast shadows (lighting is added in-engine), sleek, clean, expensive sci-fi design, polished rather than cartoonish.
```

Then ask for a single evenly lit, hand-painted, side-view full-body painting on a flat mid-grey or transparent background, suitable for splitting into rig parts, with no baked shadows, no blood painted in, no gun painted in unless the brief is a gun brief, and "no text, no logos, no franchise costume".

## Delivery and unresolved production choices

Keep each selected PNG with its selection record and current continuation prompt. Store only selected concept images in the repository. Do not label a new exploration as selected without a user decision.

The zombie Resident art, the old daytime Eon City scenes (C23) and the Clipper's concept art (C32) were deleted; the tracked files remain in git history only. Painted HD sheets are in the game for the Night Guard (three looks), the Staffer (three looks) and the Patrol Rover (two liveries); every other enemy painting is still to come, Level 2's first (C60). Sprite resolution, atlas layout, the rig tool, the clip retargeting method, frame budgets, whether scenery modules get normal maps, and the export pipeline follow the painted prototype's import tools (`tools/art/import_parts_sheet.py`).

[AI entry guide](../AI_START_HERE.md) · [Art brief index](README.md) · [Level guide](../level-design/design-guide.md)

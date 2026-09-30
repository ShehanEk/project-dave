# DEAD EDEN — Sound and music direction

**Direction (C14–C35, 2026-09-29):** mature dark sci-fi — evil corporation Arcadia Dynamics, sentient AI Adam, rogue AI researcher Dave Harlan; human, cyborg and machine enemies with guns; visible blood; no zombies, no stealth. Enemy art: lit cutout rig with smooth realistic lighting ([style guide](../../art-design/style-guide.md)).

**Document ID:** N04  
**Status:** Working design proposal. The premise, Adam, Dave Harlan and microchips are confirmed (C14, C17–C19), and so are the enemy gun kit and the mature tone (C27–C29). New names, details and numbers are *proposed* and untested.  
**Purpose:** defines act moods, weapon and enemy-gun identities, attack cues, restrained wet impacts, Adam's voice and Link chirps, mix priorities and an audio asset handoff.

**Decision references:** C15, C16, C27, C28, C29, P16, P17, P20, P23 — see the [decision register](../decisions.md).  
**Read with:** [dialogue and writing](dialogue-and-writing.md) · [interface and accessibility](interface-and-accessibility.md) · [status and enemy states](../04-world/status-and-enemy-states.md) · [encounter and boss fairness](../04-world/encounter-and-boss-fairness.md) · [README](../../level-design/README.md)

## Sound identity
Empty corporate spaces after hours sound large, clean and slightly wrong: fans that never stop, a public-address system with nobody in the room, and a calm voice that knows Dave's name. The mood is tense but restrained. Use low drones, steady mechanical hum, soft relay clicks, cooling water, restrained metallic contact and sparse musical tones, with organic sound kept mostly to combat. Gunfire is sharp, dry and short so it reads against the quiet, with one cue per burst and never a wall of noise. Impacts on people are restrained and wet, never a splatter. Avoid constant alarm noise, jump-scare stingers and a wall of wet horror effects.

These are composition and sound-design briefs. No audio files, licensed tracks, voice performances, or finished adaptive system are included.

### Sound palette (*proposed*)
| Element | Character | Use |
| --- | --- | --- |
| Low drones | Slow sub-bass beds that shift between acts | Sustain tension; never mask a cue |
| Server hum | Layered fan and transformer hum, denser in the Rootworks | Sets scale; thins out when a lockdown kills the lights |
| Distant alarms | Muffled, far-off and slow, never on Dave's plane | Suggest a wider facility without adding threat; never share a pitch or rhythm with a real attack tell |
| Adam's PA voice | Warm, calm and reverberant, through ceiling speakers and screens; a soft descending three-note chime before an announcement | Ambient announcements and lockdown warnings; the reverb tail stays short enough to keep speech intelligible, and every line is captioned |
| Link implant chirps | Teal (harmless Sleepwalkers and other protected people): a sparse, soft idle tick. Amber (the Linked): a steady two-tone hum while Adam drives the body. Red: a fast rising chirp as the attack tell | Every Link light, paired with the glow on the attacking part |
| Enemy gunfire | Sharp, dry, short and distinct per gun; one cue per burst; the rotary is a looped chatter | Every armed enemy; never louder than a tell's rising cue |
| Wet impacts | Three short, restrained wet-hit cues by material (people and dogs, the Linked, Heirs); machines use metal and spark sounds | Enemy hits and deaths; no splatter layers, no lingering gurgles |
| Human barks | Non-verbal shouts, grunts and breaths, each with a subtitle | Guards, contractors and the Linked; no recorded voice pipeline is assumed yet |
| Coolant and machinery | Water in pipes, valve hiss, pump pulses, conveyors and hydraulics | Scale and readable environmental cues, strongest in levels 4–6 |

## Campaign music palette
| Act / levels | Palette | Emotional motion |
| --- | --- | --- |
| Campus at night / 1–3 | Sparse low drones, muted pulses, hushed percussion, and a thin, detuned echo of Arcadia's corporate jingle in chime tones | Polished order develops small timing errors as Adam notices Dave; the Peacekeeper turns the showcase march into a strained, heavy loop under its looping sales reel |
| Rootworks / 4–6 | Server-hall hum, low resonant pipes, pulsing bass, metallic hand percussion, bowed textures | Curiosity becomes weight and dread; Howard Stroud's fight has a laboring pump pulse under the music |
| Wellness Center / 7–9 | Sparse piano-like tones, clean sustained notes, a slow monitor-beep rhythm, distant room resonance | Sterile calm becomes oppressive; quiet rooms of held staff and harmless Sleepwalkers allow relief |
| The Garden / 10–12 | Earlier themes warped by assembly-line rhythm, glassy bioluminescent tones and borrowed-voice vocal textures for the Heirs | Manufactured calm competes with dread as the launch nears, then the ending resolves to a simple, quiet human melody at dawn |

Use exploration, pressure, combat, and recovery layers. Enter and leave them smoothly at encounter boundaries; one stray enemy should not restart a whole boss track. Music intensity supports perceived danger without replacing attack warnings.

**There is no stealth-alert music system (C16):** no "spotted" sting, no search or alert states, and no music that implies detection. Layers follow authored encounter states only. **Lockdown stingers are allowed** (*proposed*, P20): a short, restrained sting, such as a low pulse and a fading chime, tied to a scripted lockdown event as part of its telegraph. It is never triggered by Dave being seen, and it always pairs with the visual and caption cues.

## Weapon sound signatures
| Weapon | Fire/action identity | Resource feedback |
| --- | --- | --- |
| Scrapjack | Crisp coil snap and small metal bolt; short controlled tail | Distinct charge rise and ready click at stage 3 |
| Boom Broom | Rounded close blast with a mechanical tube/chamber response, like a pipe being cleared | Individual shell insertion; dry click when empty; Twin Shell fuller but not painfully louder |
| Arc Welder | Focused electrical rasp with intermittent metallic buzz | Pitch and cadence rise toward heat limit; cooling hiss; separate burst discharge and recharge cue |
| Seedlobber | Soft pressure "thunk," pod bounce, pulsing fuse, compact seed burst | Seating click; fuse cadence readable separately from music |
| Graviton Tether | Low contained hum, acquisition ticks, tightened load tone, released air pulse | Distinct valid lock, invalid/broken lock, escape struggle and throw-ready cues |

Upgrade sounds enrich identity without changing it into another weapon. A bigger effect is not automatically a much louder effect. Avoid a constant high tone on an idle weapon. A workbench re-flash plays a short chip-write chirp, distinct from any Link chirp.

## Enemy gun sound signatures *(proposed, P23)*
Each enemy gun has its own identity, so a player can tell what is aimed at them before they see it. The looks are in the [enemy gun briefs](../../art-design/README.md).

| Gun | Cue | Notes |
| --- | --- | --- |
| EG01 Pistol, AS-9 "Civic" | A sharp crack, preceded by a lock click at red | One crack per round; a slide rack during the reload |
| EG02 Assault Rifle, AR-7 "Warrant" | One "brrt" per 3-round burst | A magazine clatter during the swap |
| EG03 Machine Gun, HG-40 "Thresher" | A rising rotary whine during the 1-second spin-up, then a looped chatter | Steam hiss during the overheat; the loop starts when the stream starts and stops at the overheat |
| EG04 Frag Launcher, GL-6 | A thump on launch, a crack on the burst | The shout "Frag out!" and a blink chirp on the landed grenade |
| EG05 Rail Rifle, RX-2 "Needle" | A three-step rising whine as the rings light, then one hard crack with a ringing tail | The camera shakes only if Dave is hit |
| EG06 Arc Caster, "Groundline" | A capacitor buzz, the rod slammed into the deck, a snap when the arc dies | Static under reduced motion |
| EG07 Plasma Gun, "Lumen" | A deep hum that rises as the ball swells, a "whump" on launch, a crackle on the burst | The Sower's chest cannon layers a lower body under it so the boss keeps its own signature |
| EG08 Seeker | A sonar ping on lock, a whine that rises as it closes in | A glassy pop when it is shot down |
| EG09 Cutter Beam | A soft petal-opening click, then a sizzling hum for the held beam | Scorch sizzle where it touches the floor |

**Rules:** one cue per burst, never one per round, so ten rounds do not stack into noise. The machine gun is a looped sound on its own player. Casings are not modeled, so there are no shell-drop sounds. Gunfire is spatial from the muzzle, limits simultaneous identical sounds, and never covers a tell's rising cue.

**Impacts and deaths.** Use restrained wet impacts on people, the Linked and dogs (a short thud, never a splatter), a dull ceramic crack and a soft drip on Heirs, and metal, spark fizz and a brief oil hiss on machines. A death adds a single short sound (a breath or a grunt; a falling chirp as a Link light dies; a debris clatter for a machine), and ragdoll bodies settle quietly. Linked deaths are mostly silent.

## Critical enemy and boss cues
Ordinary cues pair with visible tells: a Night Guard's baton hum and shouted challenge before the swing; a Sidearm Guard's lock click at red; a Rifleman's lamp chirp before each burst; a Heavy Gunner's rising rotary whine; a Grenadier's "Frag out!"; a Marksman's three-step whine; a Hound's wet wheeze before each lunge; a Security Drone's rising dive chirp; a Patrol Rover's wheel scrape; a Freight Loader's horn blast; a Sentry Turret's spin-up whine; a Keeper Drone's sonar ping and murmur; a Pruner's petal click; a Fitting Arm's servo whine. Every Linked person's chirp follows the Link light: a steady two-tone hum while Adam drives the body (the small amber point) and a fast rising chirp as the attack tell (the glow on the attacking part goes red). The soft idle tick (teal) belongs to harmless Sleepwalkers and other protected people. Machine warnings are spoken clearly and politely, and the words are part of the cue, never the only one.

The Peacekeeper uses a short chime and Arcadia's calm dispersal notice, then a wailing siren, wheel-spin revs and a rising lightbar tone before the ram, and a rising rotary whine before the roof gun, with its sales reel looping quietly on the side screen. Howard Stroud uses a deep pipe groan and creaking cable before each slam and a capacitor buzz before the arc, and in phase 2 his own voice breaks through. The Surgeon uses a clean scanner tone as its sight line tracks, a freeze tick, then a sizzling hum for the beam, and a descending whine before the injector dive.

The Sower has three distinct sound signatures, each synchronized with its light color and stance (see the [Sower brief](../../art-design/mini-bosses/b04-the-sower.md)). Stomp: a low pressurized hiss that ends in one deep boom on landing, then the arc wave's buzz. Plasma volley: a deep hum that rises before three slow "whumps". Seekers (phase 2): a whine that rises as each seeker closes in, and a glassy pop when it is shot down. A lingering shot keeps a quieter local sound as the next attack begins. At most two threat cues compete. Bloom canisters carry a faint, steady low hum that is never loud enough to mask a cue.

Do not let ordinary enemies reuse the Sower's exact long transition cues. Hearing-impaired players receive corresponding visual shapes/postures and optional captions.

## Interaction and world sound families
Specify separate events for footsteps by broad surface, landing, jump effort, health hit, immunity end, enemy hit and death by material, gun reload and vent, heal, microchip/cluster/cache, evidence-file discovery, keycard pickup, keycard door unlock and denied, checkpoint service, save complete, successful/failed purchase, swap, locked door, switch, lift, conveyor, dispenser, throw prop impact, fragile break, lockdown seal and release, emergency shutter, and story console.

Microchips use brief pitched ticks with limited variation, a bright chip click; dense trails should not create a shrill continuous scale. Evidence files use a slower small phrase, a quiet data-open tone. The keycard has its own short, rising two-note access tone, and the keycard door has a distinct unlock chime and a soft denied buzz. Checkpoint completion has a calm two-part signal, distinct from collecting microchips.

Room ambience indicates scale: glass offices and night gardens (HVAC hush, distant fountains and sprinklers, far-off alarms), server halls (layered fan hum, cooling water roar), resonant freight shafts, insulated clinic corridors (humming lamps, monitor beeps, muffled alarms) and the Garden's vast hall (a low drone and slow dripping). Stereo position follows the 2D play lane; background depth may color ambience but cannot falsely suggest an attack at a reachable position.

## Mix and interruption rules
Priority: immediate danger → damage/resource failure → interaction/save feedback → essential story → optional remarks → music detail → ambience. Duck lower layers briefly rather than merely making every priority sound louder. Adam's lockdown warnings take the immediate-danger tier, and its ambient announcements are optional remarks.

Limit simultaneous identical sounds and avoid stacking ten gun or hit sounds at full volume. Keep voice intelligible over machinery. Optional remarks stop when an imminent attack or essential story line begins; interrupted remarks are not immediately repeated.

Offer reduced dynamic range for quieter listening, separate volume controls, and sound captions that describe meaningful events. Caption "Rifle burst — right" only if the threat is actually on the right; do not invent omniscient alerts for hidden plot events.

## Audio handoff record
For each asset or event, list an ID, trigger, source actor/object, purpose, emotional tone, duration range, loop/one-shot behavior, priority, spatial behavior, interruption rule, variation needs (including Link state and lockdown phase), and caption equivalent. Keep musical stems, voice, ambience, and interaction sounds separately identifiable.

Review an encounter with music muted, then with dialogue muted, and finally with audio muted using visual cues. Each should remain understandable. These are future review scenarios; no mix or accessibility testing has happened yet.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)

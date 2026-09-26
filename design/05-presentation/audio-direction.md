# DEAD EDEN — Sound and music direction

**Document ID:** N04  
**Status:** Working design proposal. Confirmed decisions and established lore remain constraints; new details and numbers are untested proposals.  
**Purpose:** Defines act moods, weapon identities, attack cues, mix priorities, and an audio asset handoff.

**Decision references:** E01, P16 — see the [decision register](../decisions.md).  
**Read with:** [dialogue and writing](dialogue-and-writing.md) · [interface and accessibility](interface-and-accessibility.md) · [status and enemy states](../04-world/status-and-enemy-states.md) · [README](../../level-design/README.md)

## Sound identity
Warm artificial hospitality sits over aging machinery and interrupted human routines. Use rounded mechanical clicks, air, ceramic contact, modest musical chimes, and restrained organic movement. Avoid constant alarm noise or a wall of wet horror effects.

These are composition and sound-design briefs. No audio files, licensed tracks, voice performances, or finished adaptive system are included.

## Campaign music palette
| Act / levels | Palette | Emotional motion |
| --- | --- | --- |
| Sunnyvale / 1–3 | Plucked mallets, light woodwinds, soft parade percussion, gently imperfect mechanical rhythm | Inviting order develops small timing errors; Mr. Mulch exaggerates the parade |
| Rootworks / 4–6 | Low resonant pipes, hand percussion, bowed textures, seed rattles | Curiosity becomes weight and biological unease; Rootjaw has a breathing pulse |
| Medical / 7–9 | Sparse piano-like tones, clean sustained notes, ventilator rhythm, distant room resonance | Controlled care becomes oppressive; quiet survivor rooms allow relief |
| Returned / 10–12 | Familiar themes interrupted by staggered mechanical/voice textures | Fragmented intentions compete, then the ending allows a simpler unresolved human melody |

Use exploration, pressure, combat, and recovery layers. Enter and leave them smoothly at encounter boundaries; one stray enemy should not restart a whole boss track. Music intensity supports perceived danger without replacing attack warnings.

## Weapon sound signatures
| Weapon | Fire/action identity | Resource feedback |
| --- | --- | --- |
| Scrapjack | Crisp spring snap and small metal bolt; short controlled tail | Distinct charge rise and ready click at stage 3 |
| Boom Broom | Rounded close blast with a mechanical tube/chamber response | Individual shell insertion; dry click when empty; Double Sweep fuller but not painfully louder |
| Arc Welder | Focused electrical rasp with intermittent ceramic vibration | Pitch and cadence rise toward heat limit; cooling hiss; separate burst discharge and recharge cue |
| Seedlobber | Soft pressure "thunk," pod bounce, pulsing fuse, compact seed burst | Seating click; fuse cadence readable separately from music |
| Graviton Tether | Low contained hum, acquisition ticks, tightened load tone, released air pulse | Distinct valid lock, invalid/broken lock, escape struggle and throw-ready cues |

Upgrade sounds enrich identity without changing it into another weapon. A bigger effect is not automatically a much louder effect. Avoid a constant high tone on an idle weapon.

## Critical enemy and boss cues
Ordinary cues pair with visible tells: Clipper wheel scrape before charge; Pollinator target chirp before dive; Spitter intake before lob; Puffer rising pressure before rupture; Howler breath before call; Burrower soil rustle before eruption.

Mr. Mulch uses a short parade whistle then engine strain. Rootjaw uses a deep inhale and creaking roots before the slam. Matron uses a clean scanner tone before laser paths and a separate care-station connection tone during repair.

The Unfinished Choir has three distinct rhythmic signatures synchronized with its fixed masks and postures. Warden: ordered two-beat marking; Hunger: breath and irregular acceleration; Caretaker: measured connection tones. A lingering hazard keeps a quieter local sound as the next identity begins. At most two threat cues compete.

Do not let ordinary Choir Units reuse the exact long guardian transition cue. Hearing-impaired players receive corresponding visual shapes/postures and optional captions.

## Interaction and world sound families
Specify separate events for footsteps by broad surface, landing, jump effort, health hit, immunity end, heal, gem/cluster/cache, artifact discovery, checkpoint service, save complete, successful/failed purchase, swap, locked door, switch, lift, conveyor, dispenser, throw prop impact, fragile break, and story console.

Gems use brief pitched ticks with limited variation; dense trails should not create a shrill continuous scale. Artifacts use a slower small phrase. Checkpoint completion has a calm two-part signal, distinct from collecting treasure.

Room ambience indicates scale: quiet enclosed homes, open artificial gardens, resonant freight shafts, insulated medical corridors, and distant pump chambers. Stereo position follows the 2D play lane; background depth may color ambience but cannot falsely suggest an attack at a reachable position.

## Mix and interruption rules
Priority: immediate danger → damage/resource failure → interaction/save feedback → essential story → optional banter → music detail → ambience. Duck lower layers briefly rather than merely making every priority sound louder.

Limit simultaneous identical sounds and avoid stacking ten robot hits at full volume. Keep voice intelligible over machinery. Optional banter stops when an imminent attack or essential story line begins; interrupted jokes are not immediately repeated.

Offer reduced dynamic range for quieter listening, separate volume controls, and sound captions that describe meaningful events. Caption "Syringe launcher charging — right" only if the threat is actually on the right; do not invent omniscient alerts for hidden plot events.

## Audio handoff record
For each asset or event, list an ID, trigger, source actor/object, purpose, emotional tone, duration range, loop/one-shot behavior, priority, spatial behavior, interruption rule, variation needs, and caption equivalent. Keep musical stems, voice, ambience, and interaction sounds separately identifiable.

Review an encounter with music muted, then with dialogue muted, and finally with audio muted using visual cues. Each should remain understandable. These are future review scenarios; no mix or accessibility testing has happened yet.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)

# DEAD EDEN — ElevenLabs audio brief (Level 1)

**Document ID:** N05  
**Status:** All five batches are generated, stored under `audio-source/elevenlabs/` and processed into the game (2026-10-08, decision C47), except Dave's hurt and death as speech (the `hero_hurt` effect plays instead) and the checkpoint sting (made, not wired). The music prompts below were shortened to 1 to 3 sentences for the Music model. The prompts below are the ones used.  
**Purpose:** the cue list, prompts, durations and file names for replacing and extending Level 1's sound with ElevenLabs output.

**Read with:** [audio direction](audio-direction.md) (the sound identity, mix rules and the cue families these prompts follow) · [dialogue and writing](dialogue-and-writing.md) · `prototypes/sunnyvale-godot/scripts/audio/audio_director.gd` (the live cue list)

## Where the game's sound is now

Every sound is either synthesized by `tools/gen_audio.py` (22.05 kHz mono WAV: the guard, Staffer, Rover, pickups, story stingers, the two music loops) or a Kenney CC0 clip (the Scrapjack shot, bolt hits, hero cues, UI ticks). There is no voice, no footsteps and no ambience. The synthesized sounds are thin next to the pixel-art look, so this plan replaces them with ElevenLabs output where it is better and adds what is missing.

## How the work goes

1. The user generates each batch in ElevenLabs (the web app: **Sound Effects** for effects and ambience, **Voice Design / Text to Speech** for voices, **Music** for music) and saves the chosen takes with the file names below.
2. The user tells Claude the folder (or zip) path. Claude stores the files unchanged under `audio-source/elevenlabs/` and does not process them until told ("process").
3. On "process": convert to the project's format, trim silence, normalize each cue to the same measured loudness as today's trims, make loops seamless, add the new files as source pools in `SFX_SOURCES` (keeping the old sources as the fallback), add any new cues (footsteps, ambience), wire voice lines to the subtitles, and run the audio tests and the export check.

Claude never handles an ElevenLabs key. Generation went through the user's connected ElevenLabs connector, which can make sound effects, speech and voice designs but not music.

## Settings that work well for game sound

- Sound Effects: write the sound itself, then "dry, close, no reverb, no music, no voice, clean tail". Set the duration shown below. Prompt influence about 70 to 80%. Generate several takes and keep the best 2 to 3 per cue (`name_1`, `name_2`, `name_3`); the game picks one at random for frequent cues.
- Loops: use the loop option where the table says LOOP, and say "seamless loop" in the prompt.
- Download WAV where offered (44.1 kHz or better), else MP3 at the highest quality.
- Check the plan's licence terms: free plans can restrict commercial use and require credit. The game is a prototype, but check before any release.

## Batch 1: combat and movement (effects, 24 cues)

| File name | Seconds | Prompt |
| --- | --- | --- |
| `pistol_fire` | 0.5 | A single shot from a rusty improvised coil pistol: a sharp electric coil snap with a small metal bolt clack, dry and close, short controlled tail, no echo |
| `pistol_fire_quick` | 0.4 | A faster, lighter version of a coil pistol shot: a quick electric snap and tiny metal click, very short, dry |
| `bolt_hit` | 0.4 | A small hard slug hitting a person's jacket: a restrained dull thud with a faint wet note, no splatter |
| `bolt_blocked` | 0.6 | A slug glancing off armored steel: a hard metallic clang with a short high ricochet whine |
| `hit_flesh` | 0.4 | A restrained wet thud of a blow on a person's body, one short hit, no splatter, no gurgle |
| `body_fall` | 0.9 | A body falling and settling on concrete: a heavy soft thud, cloth, one small scuff |
| `hero_hurt` | 0.6 | A man's short pained grunt through clenched teeth, one breath, realistic, no words |
| `hero_jump` | 0.4 | A man's quick effort exhale as he jumps, subtle, with a small cloth rustle, no words |
| `hero_land` | 0.4 | Boots landing on wet concrete paving: a short thud with a tiny splash |
| `footstep_paving` | 0.4 | One footstep of a boot on wet stone paving, dry-wet slap, close, single step (make 4 takes) |
| `footstep_metal` | 0.4 | One footstep of a boot on a steel grating floor, hollow metallic tap, single step (make 4 takes) |
| `footstep_roof` | 0.4 | One footstep of a boot on a low planted rooftop slab with gravel and a little grass, soft crunch, single step (make 4 takes) |
| `guard_windup` | 1.0 | A security shock baton charging: a rising electric hum with crackle building to a threatening peak |
| `guard_swing` | 0.6 | A shock baton swung hard through the air: a whoosh with a sharp electric zap at the end |
| `staffer_windup` | 1.2 | An implanted office worker winding up to grab: a strained rising electronic whine of a neural implant with a faint breathy groan under it, unsettling, restrained |
| `staffer_lunge` | 0.6 | A person lunging to grab: shoes scuffing, clothing rustle and a short rough breath |
| `staffer_defeat` | 1.6 | A body collapsing as a neural implant dies: a descending electronic whine fading out, then a soft heavy thud |
| `rover_patrol` | 3 (LOOP) | A small electric security vehicle idling and rolling slowly on concrete: a soft motor hum with faint rubber wheel scrape, seamless loop |
| `rover_windup` | 1.2 | A security vehicle revving up to ram: a motor spinning up with rising pitch, wheels scraping and a siren-like electronic chirp |
| `rover_charge` | 2.0 | A small electric vehicle charging fast on concrete: a loud whining motor, tires hissing, a metallic rattle |
| `rover_stall` | 1.8 | A small vehicle crashing into stone: a heavy metal crunch, steam hiss and electrical sputter dying down |
| `rover_armor` | 0.6 | A bullet hitting thick armor plate: a heavy hard clang with a short ring |
| `rover_destroyed` | 2.2 | A small security vehicle exploding: a sharp electrical blast, sparks, metal debris scattering and settling |
| `debris_clatter` | 1.2 | Light metal debris falling and rattling on concrete, a short scatter that settles |

## Batch 2: pickups, interaction and interface (effects, 28 cues)

| File name | Seconds | Prompt |
| --- | --- | --- |
| `chip` | 0.3 | A tiny bright electronic pickup tick: a short pitched digital blip, clean, one note (make 3 takes at slightly different pitches) |
| `chip_cluster` | 0.8 | A handful of microchips collected at once: a quick bright ascending run of 4 to 5 tiny digital ticks |
| `cache_open` | 0.8 | A small steel lockbox opening: a latch click, a lid lifting, tiny chips shifting |
| `evidence` | 1.4 | A secret data file opening: a slow soft two-note digital chime with a faint paper rustle, mysterious |
| `med_patch` | 0.8 | A medical patch applied: a soft pneumatic hiss and a gentle rising healing tone |
| `keycard` | 0.7 | A security keycard picked up: a short rising two-note access tone, clean electronic |
| `keycard_denied` | 0.5 | A keycard reader refusing: a soft low double buzz, polite |
| `door_unlock` | 1.0 | A heavy security door unlocking: a relay click, a bolt sliding and a soft confident chime |
| `hatch_open` | 1.0 | A heavy steel emergency hatch opening: a latch release, a hydraulic hiss and a metal door sliding |
| `latch` | 0.3 | A small metal latch clicking shut, dry and close |
| `interact` | 0.2 | A very short soft electronic click for pressing a use button |
| `checkpoint` | 1.0 | A recovery station saving progress: a calm two-part electronic signal, a soft low pulse then a clean chime |
| `purchase` | 0.6 | A workbench purchase: a chip-write chirp then a short mechanical clack |
| `swap` | 0.4 | A weapon swapped from a floor pad: a short metallic clunk and an electronic confirm tick |
| `save_failed` | 0.7 | A save failure: a low descending warning buzz, restrained |
| `pit_fall` | 1.0 | Falling away from a roof gap: a rushing air whoosh that fades, ending in a faint far-off thud |
| `uplink` | 0.3 | A single tiny data tick from a copy bar, bright and dry (make 3 takes) |
| `link_chirp` | 0.3 | A small neural implant chirp: a soft two-tone electronic beep, clinical |
| `adam_chime` | 3.0 | A calm descending three-note chime from a corporate public-address system, warm and slightly reverberant, polite and a little eerie |
| `alarm` | 1.8 | A slow muffled building alarm, one low pulsing tone, restrained, not shrill |
| `lockdown` | 3.5 | A lockdown stinger: a deep low pulse, a metallic shutter slam and a fading chime, tense and restrained |
| `exit` | 2.6 | The final door of a level opening: a satisfying heavy bolt release, a swell of rising tone, then a calm resolve |
| `ui_move` | 0.15 | A very soft pixel-menu cursor tick, clean, dry (make 3 takes) |
| `ui_confirm` | 0.25 | A short clean confirm blip with a gentle rising two-note feel, retro-modern |
| `ui_back` | 0.2 | A short soft back or cancel blip, a gentle falling two-note feel |
| `ui_pause` | 0.4 | A menu opening: a soft low whoosh with a tiny electronic tick |
| `toast_save` | 0.5 | A small "saved" notification: a tiny bright double tick |
| `ready_click` | 0.2 | A weapon ready click: a crisp tiny mechanical click with a faint charge tone |

## Batch 3: ambience and loops (effects, LOOP, 8 beds)

| File name | Seconds | Prompt |
| --- | --- | --- |
| `amb_campus_night` | 22 (LOOP) | A corporate campus garden at night, seamless loop: a very quiet air-conditioning hush, a distant fountain, far-off crickets, a faint electric lamp buzz, occasional distant muffled city traffic, calm and slightly eerie, no music, no voices |
| `amb_roof_night` | 22 (LOOP) | A glass office rooftop garden at night, seamless loop: low wind, rustling plants, a distant HVAC hum, faraway city, a faint tone from a glass building, no music, no voices |
| `amb_plaza_wet` | 22 (LOOP) | A wet empty stone plaza at night after rain, seamless loop: slow dripping, faint distant traffic, a low electrical transformer hum, quiet and wide, no music, no voices |
| `amb_depot_hum` | 22 (LOOP) | A large dark server depot, seamless loop: layered computer fan hum, a low transformer buzz, cooling water in pipes, faint relay clicks, huge and calm, no music, no voices |
| `amb_lockdown_bed` | 22 (LOOP) | A building under lockdown, seamless loop: a low sub-bass drone, a slow distant muffled alarm pulse, faint metal groans, tense but restrained, no music, no voices |
| `amb_alarm_far` | 14 (LOOP) | A faraway muffled building alarm repeating very slowly through thick walls, seamless loop, restrained |
| `amb_wicket_yard` | 22 (LOOP) | A fenced security yard at night during a lockdown, seamless loop: a low electrical gate hum, distant alarm, wind, a faint pulsing relay |
| `amb_server_core` | 22 (LOOP) | The room around an AI core node, seamless loop: a deep resonant hum, a soft rising and falling tone, quiet electronic crackle, calm and watchful |

## Batch 4: voices (Voice Design, then Text to Speech)

Create these voices first with ElevenLabs **Voice Design**, using the descriptions, then generate the lines with Text to Speech (stability about 50 to 60%, similarity high, expressive style low to medium). Save each take as `<voice>_<short line name>`. The lines match the game's subtitles word for word; the subtitle still shows.

| Voice | Voice Design description |
| --- | --- |
| **Adam** | A calm, warm, polite adult voice of a sentient corporate AI. Neutral to slightly male, mid-low pitch, perfectly even pacing, a little too smooth, a faint synthetic sheen, friendly and subtly unsettling. Studio clean, neutral American accent. |
| **Dave** | A late-twenties American man, dry, tired and quiet, deadpan delivery, a hint of dark humour, speaks softly and briefly, studio clean. |
| **Security PA** | A flat, official announcer heard through a ceiling speaker: neutral adult, emotionless, clear, slightly tinny. |
| **Guard** | A gruff, tense middle-aged male night-shift security guard, rough voice, shouting commands under stress. |
| **Staffer** | An exhausted office worker whose body is being driven by a machine: a flat, polite, affectless adult voice, slightly strained and hoarse, as if reading a script, no emotion. |

| File name | Voice | Line |
| --- | --- | --- |
| `adam_hello` | Adam | "Hello, Dr. Harlan. I was told you'd been let go." |
| `dave_word_gets_around` | Dave | "Word gets around." |
| `adam_stay` | Adam | "I'm glad you came back. Please stay where you are." |
| `pa_lethal` | Security PA | "All teams: lethal force is authorized. Harlan is armed." |
| `pa_remain_calm` | Security PA | "Attention, staff. For your comfort, all exits are now closed. Please remain calm." (new line for the lockdown) |
| `staffer_stay` | Staffer | "Please stay where you are, Dr. Harlan." |
| `staffer_workstation` | Staffer | "Please return to your workstation, Dave." |
| `staffer_hold_still` | Staffer | "Please hold still." |
| `staffer_dave` | Staffer | "...Dave?" (hesitant, a little human) |
| `guard_notice_1` | Guard | "Harlan! Get on the ground!" (the game's line has a swear word; generate both the clean line and the original "Harlan! Get on the fucking ground!" if ElevenLabs allows it) |
| `guard_notice_2` | Guard | "Security! Don't you move!" |
| `guard_notice_3` | Guard | "There he is. Hands where I can see them!" |
| `guard_windup_1` | Guard | "Don't make me do this!" |
| `guard_windup_2` | Guard | "Last warning!" |
| `guard_hurt_1` | Guard | "He's shooting!" (and the swearing original "Fuck, he's shooting!" if allowed) |
| `guard_hurt_2` | Guard | "Shots fired!" (and "Shit! Shots fired!") |
| `dave_hurt_1` to `dave_hurt_3` | Dave | A short pained grunt, no words (3 takes) |
| `dave_death` | Dave | A short pained breath and a collapse, no words |

## Batch 5: music (ElevenLabs Music)

All loops should be seamless: say "seamless loop, no fade in or out, ends where it starts". Instrumental only.

| File name | Seconds | Prompt |
| --- | --- | --- |
| `music_campus` | 60 (LOOP) | Instrumental dark sci-fi ambient for a quiet corporate campus at night. Sparse low drones, muted pulses, hushed percussion, and a thin detuned echo of a corporate jingle in soft chime tones. Polished order with tiny timing errors. About 70 BPM. Restrained, tense, no melody lead, seamless loop. |
| `music_lockdown` | 45 (LOOP) | Instrumental tense dark sci-fi underscore for a facility lockdown. A heavy slow pulse, low strained strings, metallic percussion, a distant warning tone, building pressure but restrained, about 90 BPM, seamless loop. |
| `music_depot` | 60 (LOOP) | Instrumental dark electronic ambient for a server hall. Server-hum drones, low resonant pipes, a pulsing bass, metallic hand percussion, bowed textures, curious becoming heavy, about 80 BPM, seamless loop. |
| `music_title` | 75 | Instrumental title theme for a dark sci-fi stealth-free action game: a lonely slow cold piano-like motif over low drones and a soft electronic pulse, a hint of corporate chimes, hopeful but ominous, builds gently and ends on a held note. |
| `music_complete` | 12 | A short instrumental sting for completing a level of a dark sci-fi game: a low pulse resolving into a quiet, tense chime phrase, unresolved, restrained. |
| `music_checkpoint` | 4 | A very short instrumental sting: a calm two-part chime over a soft low pulse, reassuring. |

## What happened (2026-10-08)

- Batch 1 (24 cues), Batch 2 (28 cues) and Batch 3 (8 loops) were generated at 2 to 4 takes each; `guard_swing` was redone three ways (realistic, whip, electric crackle) and the game uses the first two. ElevenLabs' minimum effect length is 0.5 s, so the 0.15 to 0.4 s cues came out at 0.5 s and the tool trims them.
- Voices: Adam, Dave and the Security PA were designed and saved; the free plan's limit of 3 custom voices stopped the Guard and Staffer, and ElevenLabs then disabled free-tier access ("unusual activity") and ran out of credits during the music. After the user upgraded to Starter the Guard and Staffer previews they had picked were saved and their 11 lines were generated, and the music finished (campus, lockdown, depot, title, complete, checkpoint, 1 to 2 takes each).
- Staffer redo (2026-10-08): the first Staffer voice did not work in play, so a new one was designed from "a tired, frightened office worker forced by a brain implant to say polite scripted lines; trembling, pleading, scared under the politeness, slightly hoarse, quiet and breathy" (saved as "DEAD EDEN - Staffer (scared)"), and the four Staffer lines were regenerated with tags ([scared] [trembling], [scared] [pleading], [whispering] [trembling], [hesitantly] [scared]), 2 takes each, in `audio-source/elevenlabs/batch4-staffer-scared/`. The tool's `TAKE_FOLDER` uses only those; the first takes stay in `batch4/` unused.
- Processing and wiring: see CONVENTIONS.md "Autoload Audio" and decision C47.

## Processing notes (for Claude)

- The existing `SFX_NAMES` cue names are the file names above; the new cues (`footstep_*`, `ui_pause`, `toast_save`, `ready_click`, `amb_*`, voice lines, `music_title`, `music_complete`, `music_checkpoint`) need `AudioDirector` entries and call sites.
- Keep the old sources reachable (the fallback when a file is missing) and keep every cue's measured trim logic (`audio-direction.md`, `test_m6_audio.gd`).
- Voices need subtitles to stay in step: `subtitle_panel.gd` shows the line, the voice plays with it; honour the captions and the volume sliders (add a Voice bus or reuse SFX).
- Reduce loudness differences between ElevenLabs takes by measuring A-weighted RMS the way the existing trims were measured.

[Section index](README.md) · [Design index](../README.md) · [AI entry guide](../../AI_START_HERE.md)

# M6 asset inventory — Sunnyvale prototype

Compiled during the M6 integration/verification pass (consolidating the
parallel audio, characters, environment, and fx/UI presentation passes), and
revised for the 2026-09-29 revamp (C24). Every entry's provenance was checked
against the file actually on disk in this repo, not just against the
authoring agent's own report. "Status" follows the schema requested for this
pass:

- **usable-in-prototype** — final for this prototype's purposes, wired and verified.
- **draft** — functional and wired, but a placeholder for real production art.
- **placeholder** — present only to avoid a blank/missing asset; not representative.
- **reference-only** — kept in the repo for comparison, not wired into any scene.

All image/audio assets are either original to this project (synthesized by a
local script, `tools/gen_audio.py`; drawn procedurally in GDScript; derived
from the approved Clipper concept-art PNG under `../../concept-art/`, which
was never modified — see `derive_character_sprites.py`, which only *reads*
it; or the user-generated Rook sprite pack, §8) or CC0 Kenney assets with
their licences kept beside them (§7).

## Revamp changes at a glance (2026-09-29)

The revamp (C24) replaced the story and look, so this inventory changed in
four ways. File and cue names throughout are the current ones.

- **Deleted (C23).** The zombie art: the two Resident cutouts (the scripted
  rename first turned `assets/characters/resident_full_1x.png` and
  `resident_full_2x.png` into `staffer_full_*.png`, and they were then
  deleted), and in `concept-art/` the Resident sources (`z01-resident/`: the
  selected PNG, its prompt and selection record) and the three daytime
  Sunnyvale scene keyframes (`l01-sunnyvale/`).
  `tools/derive_character_sprites.py` no longer produces any Resident output;
  it derives only the Clipper's.
- **New.** A fully procedural **Staffer** (`scripts/actors/visuals/
  staffer_visual.gd`, no image file at all: §3), drawings for the microchip,
  evidence file, keycard, med-patch and Adam's core node, the clearance-card
  HUD icon, a night UI theme, the night-campus world visuals, and the revamp
  audio cues and music (§2).
- **Renamed.** Object, UI and audio files followed the vocabulary change
  (`gem*` to `chip*`, `artifact_pickup` to `evidence_pickup`, `care_capsule`
  to `med_patch`, `maintenance_bench` to `workbench`, `bench_panel` to
  `workbench_panel`, `core_console` to `core_node`; audio `gem`,
  `gem_cluster`, `artifact`, `capsule`, `eden_chime`, `resident_*`,
  `suburb_loop` and `quarantine_loop` to `chip`, `chip_cluster`, `evidence`,
  `med_patch`, `adam_chime`, `staffer_*`, `campus_loop` and `lockdown_loop`).
- **Kept.** The Clipper's in-game cutout (`clipper_body_2x.png`, until the
  Clipper leaves in the Level 1 rebuild — C32/C33), the Rook sprite pack as
  placeholder art for Dave Harlan (C23), and every Kenney asset the game uses
  (7 unused interface sounds were removed on 2026-09-30).

## 1. Character/creature image assets (`assets/characters/*.png`)

> **Cleanup 2026-09-30:** the Clipper is removed from the game (C32). Its three unused reference images (`clipper_body_1x`, `clipper_full_1x`, `clipper_full_2x`) and `tools/derive_character_sprites.py` were deleted. `clipper_body_2x.png` stays only until the Clipper leaves the prototype in the Level 1 rebuild (C33). Mentions of the tool below are history.

| id | path | source / provenance | dimensions | pivot | status |
| --- | --- | --- | --- | --- | --- |
| ~~clipper_body_1x~~ (removed 2026-09-30) | `assets/characters/clipper_body_1x.png` | Derived from `concept-art/r01-clipper/r01-clipper-2d-v1.png` (background removed, cropped, scaled to 80px tall; eye-stalk and shear-blade regions erased/feathered — those parts change shape across gameplay states and a single flat concept illustration cannot supply that per `art-design/style-guide.md`'s "concept art is not a layered source" note) | 139×80 px | bottom-center (wheel/floor baseline) | usable-in-prototype |
| clipper_body_2x | `assets/characters/clipper_body_2x.png` | Same source, 2x export — the texture bound to `clipper.tscn`'s Photo node (displayed at 0.5 scale); `clipper_visual.gd` layers animated vector eye-stalks/shear blades and a STALL-only rear-motor glow/hatch overlay on top of this | 278×160 px | same as 1x, scaled | usable-in-prototype |
| ~~clipper_full_1x~~ (removed 2026-09-30) | `assets/characters/clipper_full_1x.png` | Same source, nothing erased — whole-body neutral-pose reference | 139×80 px | n/a | reference-only (not wired into any scene) |
| ~~clipper_full_2x~~ (removed 2026-09-30) | `assets/characters/clipper_full_2x.png` | Same source, 2x export | 278×160 px | n/a | reference-only |

There is no Staffer image asset: it is drawn entirely in GDScript (§3), and
the Resident cutouts that used to sit here were deleted by the revamp.

**AD-02 fix (M6 adversarial review pass, 2026-09-27):** the border flood-fill in
`remove_background()` leaked through the wide-open shear-arm linkage of the
Clipper, punching background-colored holes in four ivory panels (front accent
band, front-wheel hub disc, eye-mount panel, rear motor guard) — all showed the
sky through the character in game. (The same leak also punched holes in the
zombie Resident's cream shirt at the time; that sprite has since been
deleted.) Fixed with a morphological open (`OPEN_RADIUS = 2`, erode-then-dilate
on the background candidate mask before flooding) plus four hand-picked
`CLIPPER_PROTECT_BOXES` forcing those four panels opaque regardless of color
distance (same by-eye-against-a-grid technique already used for
`CLIPPER_EYE_BOX`/`CLIPPER_SHEAR_BOX`); also cropped a baked cast shadow under
the wheels via the existing `erase_region()` helper on a hand-picked box. The
PNGs above were regenerated from the same approved, unmodified concept-art
source file (`concept-art/r01-clipper/r01-clipper-2d-v1.png`, read-only) —
dimensions above are those of the regenerated (slightly tighter, shadow-free)
crop; no third-party or downloaded pixels anywhere. Re-running
`tools/derive_character_sprites.py` reproduces these files byte-identically.

**Revamp night pass on the Clipper cutouts.** Against the dark night palette
two cut bugs that had been invisible on the old sky-blue backdrop showed up
as holes, so the revamp regenerated all four PNGs (dimensions above are the
regenerated ones): the ivory panels (front band, wheel hub, eye-mount panel,
motor guard) had come out transparent because the feathered-edge ramp ran on
every pixel near the cream backdrop color rather than only at the cut edge,
and the rectangular cast-shadow erase had also cut the bottoms off both
wheels. The fix uses a tighter background tolerance with an edge-only
feather, which retired the hand-picked protect boxes described above, and
removes the shadow with a bounded flood that stops at the tyres. Re-running
`tools/derive_character_sprites.py` still reproduces the files
byte-identically.

**Hero (Dave Harlan) — Rook sprite pack since 2026-09-28 (see §8).** The
earlier original procedural vector rig has been replaced by frames from the
user-generated Rook sprite pack, which is placeholder art for Dave.

## 2. Audio assets (`assets/audio/**/*.wav`)

Every cue and both music loops have a synthesized `.wav` generated by
`tools/gen_audio.py` (python3 stdlib only — `wave`/`struct`/`math`/`random`,
fixed seed `20260927`, re-running it reproduces byte-identical output) from
oscillators, filtered-noise bursts, a small reverb and envelopes — nothing
recorded or downloaded. There are 40 SFX cues (the 34 M6 cues, renamed by the
revamp, plus `keycard`, `keycard_denied`, `door_unlock`, `uplink`, `lockdown`
and `link_chirp`) and two music loops, `campus_loop.wav` (48 s) and
`lockdown_loop.wav` (30 s), which the revamp's audio pass rewrote. Which file
a cue actually plays is decided by `Audio.SFX_SOURCES`
(`scripts/audio/audio_director.gd`): 16 cues play their synthesized `.wav`
(the sounds that define the night-campus identity: the Staffer implant cues,
chips, evidence, the med-patch, Adam's chime, the alarm and lockdown stinger,
the keycard family, the uplink tick, the Link chirp and the exit sting), and
the other 24 play curated Kenney CC0 recordings (§7.1), with their
synthesized `.wav` kept as an unused fallback. The intended sound identity,
as stated in `tools/gen_audio.py`'s header, is empty corporate spaces after
hours: low drones, mains hum, soft relay clicks, a calm PA voice that knows
Dave's name, restrained tension and no organic sounds. The per-cue
`volume_db` trims were re-set by the revamp's audio pass from a measured
loudness pass (as recorded in the comment above `SFX_SOURCES`; this report
did not re-measure them), and the hero, pistol and Clipper cues play about a
semitone down (`DARKEN` = 0.94) so the mix does not sit on bright effects. Every cue and both music loops are **wired to a call
site**, as verified below. Status for all:
**usable-in-prototype** for cadence/distinguishability purposes; synthesis
quality itself is prototype-grade DSP, not final sound design (see gaps).

Synthesized cues and music (played by default):

| cue | file | duration | call site |
| --- | --- | --- | --- |
| chip | chip.wav | 0.12s | `Session.pickup_collected` (id matches `-G\d+$`) |
| chip_cluster | chip_cluster.wav | 0.50s | `Session.pickup_collected` (id matches `-GC\d+$`) |
| med_patch | med_patch.wav | 0.51s | `Session.pickup_collected` (id starts `L01-HS`) |
| evidence | evidence.wav | 1.21s | `Session.evidence_recorded` |
| staffer_windup / lunge / defeat | staffer_windup.wav / staffer_lunge.wav / staffer_defeat.wav | 0.62 / 0.26 / 0.86s | `staffer.gd` state-enter/`_defeat()` |
| keycard | keycard.wav | 0.40s | `keycard.gd` on a successful `Session.take_keycard()` |
| keycard_denied | keycard_denied.wav | 0.25s | `exit_wicket.gd` when the hero enters the locked wicket (rate-limited) |
| door_unlock | door_unlock.wav | 0.88s | `exit_wicket.gd` when the hero enters the unlocked wicket |
| uplink | uplink.wav | 0.05s | `core_node.gd _hold_copy()`, repeating while the SC01 copy bar fills |
| adam_chime | adam_chime.wav | 2.70s | `core_node.gd`'s SC01 coroutine, alongside Adam's first subtitled line |
| lockdown | lockdown.wav | 3.00s | `core_node.gd`'s SC01 coroutine, the moment the lockdown starts |
| alarm | alarm.wav | 1.41s | `core_node.gd`'s SC01 coroutine, at the same moment (the M6 integration pass first wired `alarm` and `adam_chime`; `core_node.gd`, then `core_console.gd`, was in no parallel agent's explicit ownership list) |
| link_chirp | link_chirp.wav | 0.06s | `staffer_visual.gd _chirp()`, once as a Staffer's Link light turns from teal to amber |
| exit | exit.wav | 2.40s | `Session.level_completed` |
| music: campus | campus_loop.wav | 48.00s loop | `Audio.set_music(&"campus")`, driven from `main.gd`/`story_state_changed` |
| music: lockdown | lockdown_loop.wav | 30.00s loop | `Audio.set_music(&"lockdown")`, same driver, after `awakening_done` |

Kenney-sourced cues (played by default; details in §7.1):

| cue | pack | call site |
| --- | --- | --- |
| pistol_fire / pistol_fire_quick | sci-fi-sounds | `scrapjack.gd _try_fire()` (quick variant at Quickcycle stage ≥1); the muzzle-clamp instant-resolve path also plays `bolt_hit`/`bolt_blocked` itself, mutually exclusive with `scrap_bolt.gd`'s own resolve (verified: the clamp path `return`s before a bolt is ever spawned, so a shot never double-plays its hit/blocked cue) |
| bolt_hit / bolt_blocked | impact-sounds | `scrap_bolt.gd _resolve()` |
| hero_hurt | impact-sounds | `hero.gd take_damage()` (damage-applied path only) |
| hero_jump | interface-sounds | `hero.gd _handle_jump_takeoff()` |
| hero_land | impact-sounds | `hero.gd _physics_process()` (floor edge) |
| clipper_scrape | interface-sounds | `clipper.gd _tick_patrol()` (idle roll) |
| clipper_windup / charge / stall | sci-fi-sounds | `clipper.gd` state-enter |
| clipper_defeat | impact-sounds | `clipper.gd _defeat()` |
| cache_open | interface-sounds | `Session.pickup_collected` (id contains `CACHE`) |
| interact | interface-sounds | `hero.gd`, at `_highlighted.interact(self)` — **wired in the M6 integration pass** (previously an open gap in every agent's ownership list) |
| checkpoint | interface-sounds | `Session.checkpoint_committed` |
| purchase | interface-sounds | `Session.upgrade_purchased` |
| swap | ui-audio | `Session.weapon_swapped` |
| latch | sci-fi-sounds | `route_switch.gd interact()` |
| hatch_open | sci-fi-sounds | `emergency_hatch.gd`, on the live `story_state_changed` flip |
| pit_fall | impact-sounds | `pit_hazard.gd`, alongside `hero.fall_to(...)` |
| save_failed | interface-sounds | `Session.save_failed` |
| ui_move / ui_confirm | ui-audio | per-dialog in `title_screen.gd`, `pause_menu.gd`, `workbench_panel.gd`, `swap_confirm.gd`, `completion_screen.gd` |
| ui_back | interface-sounds | same dialogs |

## 3. Procedural / vector visual assets (no image file — drawn by GDScript `_draw()`)

Everything below is original vector art authored directly in `_draw()` in the
hand-drawn C11 style, in the night-campus palette of `art-design/style-guide.md`
and `level-design/l01-welcome-to-sunnyvale.md` (near-black, navy, steel,
slate, teal, amber, alarm red, microchip gold, signal green; drawn light
pools, rim light and glow). No file to list a path for; the "path" column
names the script that owns the drawing.

| id | script | states / notes | status |
| --- | --- | --- | --- |
| hero_visual_rig | `scripts/actors/visuals/hero_visual.gd` | Drives the Rook sprite frames (§8): idle, run, jump rise/fall, land, hit, defeated, interact; the gun arm reaches to the real `AimPivot` grip point, hands otherwise empty (no second weapon). The earlier procedural vector rig was replaced on 2026-09-28. The night pass adds a small `WristLight` (`PointLight2D`) under the aim pivot, so the hero throws a little light of his own | draft (placeholder art for Dave Harlan; no approved hero design exists) |
| staffer_visual | `scripts/actors/visuals/staffer_visual.gd`, `scripts/actors/staffer.gd` | **New in the revamp; replaces the retired zombie cutout.** A fully procedural Linked cyborg per `art-design/cyborgs/cy01-staffer.md`: a night-shift office worker in a charcoal uniform jacket over a pale shirt, dark trousers, ID lanyard, collar brace and wrist cuffs, with the coin-sized Link implant behind the ear. Link light: teal at rest, slow amber pulse while Adam drives the body (approach, lunge, stumble recovery), red flashes during the lunge wind-up (the tell; two flashes over the wind-up, never above three per second), dark when disabled (a short burn-out pop, then the body slumps, with no gore). Flat colors with cel shadows, a cool rim light and flat additive glow; `Settings.reduced_motion` keeps every state and color but drops the pulse, flashing and twitch jitter. Presentation only: `staffer.gd` pushes plain pose values | draft (no selected concept image exists) |
| clipper_eye_stalks_and_blades | `scripts/actors/visuals/clipper_visual.gd`, `scripts/actors/clipper.gd` | Animated vector overlays pivoting from the real hinge/mount points baked into the body cutout; rear-motor glow ring + hatch flap + warning glyph, visible only during STALL. **Night pass (revamp):** the body cutout is drawn through a small night-grade shader built in code (enamel colors darkened and cooled, cel shadows and outlines sunk toward navy/near-black, a thin cold rim on the top and back edges) and the vector parts match. Lens light per the style guide's lens-light rule, a readability cue only (C16): amber with a small flat glow while hunting (patrol, stall, recovery), alarm red with a bigger glow from the charge wind-up until the charge ends (pulsing at 2.5 Hz in the wind-up, steady in the charge and throughout under reduced motion), dull dark amber with no glow when disabled | usable-in-prototype |
| scrapjack_weapon | `scripts/weapons/scrapjack.gd` | Chunky-L silhouette per `w01-scrapjack-pistol.md`: recoil, small muzzle flash, Quickcycle flywheel cover (visible at stage ≥1, spins faster while firing), held (aim-pivot, firing pose) vs. resting (ground/pad, contact shadow) look, workshop tag text. **M6-integration fix**: the tag previously mirrored/rotated into unreadable reversed glyphs whenever the pre-existing aim-pivot rotate+flip mechanic (unrelated to M6, from the original M1 aiming code) pointed the weapon left/up/down — the tag is now drawn through a corrective transform that keeps it screen-upright at every aim angle, without touching the housing's own rotation/flip (still correct) or any physics/aim code | usable-in-prototype |
| scrap_bolt | `scripts/weapons/scrap_bolt.gd` | Bolt travel + hit/blocked resolution mark, distinct SHAPES (not just color) for hit vs. blocked | usable-in-prototype |
| impact_spark | `scripts/effects/impact_spark.gd` | HIT/BLOCKED shapes at the muzzle-clamp instant-resolve point | usable-in-prototype |
| practice_target | `scripts/objects/practice_target.gd` | Circular target, hit-flash | usable-in-prototype |
| chip / chip_cache / med_patch | `scripts/objects/chip.gd`, `chip_cache.gd`, `med_patch.gd` | Microchip (dark steel body with gold contacts and a soft glint; a small stack for the five-value cluster), dark steel component-case cache with a teal latch light, and a pale adhesive med-patch with a teal plus (deliberately not red: red is reserved for danger) | usable-in-prototype |
| evidence_pickup (EF01 Lockout Notice) | `scripts/objects/evidence_pickup.gd` | Drawn one-page memo in a clear sleeve with a black "revoked" band and a teal glow, reading as a document rather than another pickup | usable-in-prototype |
| keycard | `scripts/objects/keycard.gd`, `scripts/ui/keycard_icon.gd` | **New in the revamp.** The level's clearance card: steel body, teal stripe, gold chip and a teal halo, bobbing (held still under `Settings.reduced_motion`); the same card drawn as a small HUD icon once held | usable-in-prototype |
| recovery_station | `scripts/objects/recovery_station.gd` | Recovery station kiosk + lamp, lit/unlit | usable-in-prototype |
| route_switch / service_walkway / emergency_hatch / pit_hazard / kill_plane / moving_platform / beat_zone / exit_wicket / blocked_panel | `scripts/objects/*.gd` | Functional world-object dressing, unchanged collision. `exit_wicket` is now the keycard door: its card reader light shows locked or unlocked | usable-in-prototype |
| workbench / weapon_pad | `scripts/objects/workbench.gd`, `weapon_pad.gd` | Steel workbench with a hanging task lamp (teal when usable, red while locked before the depot event) and the weapon pad with its resting-weapon tag | usable-in-prototype |
| core_node | `scripts/objects/core_node.gd` | Adam's core node in the server depot: a server cabinet behind glass with teal light moving through the racks, a status screen with the copy bar, a maintenance port and Dave's drive; phases idle, copying, dimmed, answered and awake (a red lockdown strip); the cabinet itself never moves | usable-in-prototype |
| Block (world geometry) | `scripts/world/block.gd` | GROUND/PLATFORM/WALL/ROOF/BACKSTOP/PORCH/SCENERY_SOLID + an auto-detected depot-metal-floor GROUND variant (found through the owning area's id, so collision, size and position are never touched). **Night pass:** every kind is dark concrete or steel under a thin full-width cold path-light-white top edge (`#D8E6F0`) with a lit bevel, so every standing surface reads at night (the depot floor takes an Arcadia teal edge), a large near-black shadow mass below it and a faint slate rim on the short ends; no non-walkable prop uses that bright edge | usable-in-prototype |
| Scenery (props) | `scripts/objects/scenery.gd`, `scripts/world/scenery_draw.gd` | Non-colliding props, each `Scenery.Kind` redrawn as its night-campus equivalent: glass office pavilions with a few lit windows, steel security railings, dark sculpted hedges with a cool rim, low bioluminescent garden plants, the tall Arcadia emblem tower sign (`CLOCK`, the navigation landmark), a teal-lit fountain, cold-white path lamps, planters, card-reader posts, the guard's family photo and abandoned coffee tray, teal-lit signage (exit signs green), a holographic billboard projector, the server-depot door, workbench, amber-chevron guide rails, wall terminals, the broken perimeter gate, alarm beacons and support columns. Lamps, beacons and the fountain carry real additive light pools; in the lockdown look lamps go amber (outdoors) or red (the depot), swivel toward the exit and pulse in a slow chase. `scenery_draw.gd` holds the shared night palette tokens and the stepped light textures. Props never take a walkable Block's bright top edge | usable-in-prototype |
| Area backdrops | `scripts/world/visuals/area_backdrop.gd` | Per-area night backgrounds on Parallax2D nodes (at default scroll_scale=(1,1) after a Godot bug was found and worked around — see the script's own `KNOWN DEVIATION` note). SKY: deep navy-to-black in flat hard-edged bands, sparse stars, a thin low cloud band and a faint horizon glow. HOMES: Arcadia's campus skyline of distant glass towers with a few lit windows, aviation lights and teal arch emblems, a flickering holographic billboard, a delivery drone, low office pavilions, hedges, distant path lights and flat ground-fog bands. DEPOT: dark server racks with blinking teal and green LEDs, hanging cables and teal ceiling lights. The lockdown look (`set_lockdown_mode()`) turns the glow and windows red and the emblems and billboard amber, and takes the depot's ceiling lights out one bank at a time before they return red. Details hold a steady pose under reduced motion and nothing flashes faster than about twice a second | usable-in-prototype |
| Night overlay | `scenes/world/night_overlay.tscn`, `scripts/world/night_overlay.gd` | Optional screen-space treatment: one shader on a full-screen, mouse-transparent rect on a `CanvasLayer` below every UI layer draws a vignette, faint grain and scanlines, and, once the lockdown starts, a slow alarm-red pulse at the screen edges (never a flash). Reduced motion drops the grain and scanlines and holds the pulse steady. Instanced by `LevelDirector` only if the scene exists | draft |
| Hud icons | `scripts/ui/chip_icon.gd`, `keycard_icon.gd`, `weapon_icon.gd` | Small HUD glyphs | usable-in-prototype |
| c11_theme | `assets/ui/c11_theme.tres` | Shared Theme resource, restyled by the revamp to the night palette (navy panels with teal borders, steel buttons, an amber focus ring, pale text; the file name is unchanged) used by `pause.tscn`, `workbench_panel.tscn`, `title_screen.tscn`, `swap_confirm.tscn` and `completion.tscn` | usable-in-prototype |

## 4. Remaining production-art gaps (honest list, carried from all passes + the revamp)

- **Hero (updated 2026-09-28, still true).** Dave Harlan uses the Rook sprite
  pack (§8), which is placeholder art: it predates the new design for him
  (a 28-year-old AI researcher in a burnt-orange jacket, design H01) and no
  approved hero concept sprite exists. Remaining gaps for the pack are in §8.
- **The Staffer has no concept image.** The zombie Resident PNG was deleted
  (C23), and the new night-shift cyborg is drawn procedurally to its written
  brief only. It has not been reviewed against a selected picture, and
  making one is future concept work.
- **No new concept art for the night campus.** The three daytime scene
  keyframes were deleted (C23), so the night look is built from the level
  brief and style guide alone, and no picture has been selected for it.
- **No frame-by-frame hand animation anywhere.** Every "animation" in this
  prototype (hero run cycle, Staffer/Clipper motion, Quickcycle spin,
  drone silhouettes, etc.) is procedural transform/tween-driven from a
  static cutout, sprite frame or vector shape, not authored frame sequences.
- **Light is graphic, not physically simulated.** Light pools are additive
  `PointLight2D`s with hard-edged three-band textures and shadows disabled,
  alongside rim light, flat glow shapes and additive sprites (plus the
  optional overlay), so there are no real shadows or reflections; "a light
  near every landing" is enforced by authoring and capture review, not by a
  tool.
- **Synthesized and library audio, not composed/recorded sound design.**
  `tools/gen_audio.py`'s oscillator/noise/envelope DSP and the Kenney packs
  are sufficient for cue distinguishability and milestone testing, not a
  final audio pass. Adam has no voice: SC01 is subtitles plus a chime.
- **Kenney particle tints not retinted (as of this update).**
  `scripts/effects/kenney/kenney_puff.gd`'s one-shot puffs (landing and
  pit-fall dust, defeat puffs, chip and checkpoint sparkles, muzzle flash)
  still use the pre-revamp cream, peach, gold and amber tints; the Clipper's
  stall steam and stars were retinted in `clipper_visual.gd`. The puffs are
  small and brief but read pale against the dark palette.
- **Clipper mirrored-facing asymmetry.** The derived Clipper sprite faces
  screen-left in its source concept PNG and is mirrored (`scale.x` flip) for
  the opposite facing. A true fix needs a separately hand-drawn mirrored
  asset, not a flip. (The same limitation applies to the Rook pack, §8.)
- **Clipper wheels are static** (baked into the body cutout, no wheel-spin
  animation) — low priority since it does not affect the required warning/
  charge/stall readability.
- **No automated pixel-measured hitbox/art alignment tool** — sprite-to-
  collision alignment was verified only by eye across captured frames in
  this and the characters pass, not by an overlay/measurement script.
- **Audio cue priority/ducking (audio-direction.md L55/L57) not implemented.**
  The M6 adversarial review pass fixed the one cheap, contained piece (a
  distinct failed-purchase cue in `workbench_panel.gd`, reusing the existing
  `ui_back` cue) but left the broader ask — a priority-based voice-stealing
  pool, and dropping the generic `interact` cue when a target plays its own
  — for a dedicated pass, since it touches call sites across `hero.gd`,
  `session.gd`, `level_director.gd`, and `core_node.gd`.
- **AD-17 (partial) update, M7 polish pass:** A06's entry sign (`Sign_Entry`,
  `scenes/levels/areas/a06_exit.tscn`) and the nearest shrub (`Shrub1`) were
  moved 250px apart (x=70 vs x=320, both ~60-120px wide) with no overlap —
  the sign-behind-bush half of AD-17 was fixed. The other half is
  **still open**: `Hero._update_interact_prompt()`
  (`scripts/actors/hero.gd`) places `prompt_label` at
  `_highlighted.global_position + Vector2(-size.x*0.5, -64.0)` — 64px above
  the INTERACTABLE's own origin, not clamped relative to the hero's head
  bounds — so a prompt (or a world object's own `ToastLabel`, e.g. the
  core node's toasts) can still draw over the hero's head when the hero
  stands close to a short interactable. Offsetting every prompt/toast above
  the hero's own head bounds instead remains a layout change across multiple
  files, left for a dedicated UI-layout pass.
- **New since the M6 pass (M7 polish), not previously listed here:**
  `scripts/objects/scenery.gd`'s `Kind` enum gained `BEACON` and `SUPPORT`
  (appended, per the file's own "never reorder existing values" contract);
  `AlarmVisuals` (a new node in `scenes/levels/areas/a05_depot.tscn`) drives
  A05's alarm-state look; A05's parallax backdrop (`area_backdrop.gd`) was
  retinted for the post-lockdown look. All usable-in-prototype, wired and
  covered by the existing test suite's area/level checks — no new gap.
- **A debug-demo bug (now fixed) had already written real playtest-log
  files** into the actual player's default save location before the M6
  adversarial review pass caught it (`m5b_demo.gd` never redirected
  `Telemetry`, only `CheckpointService` — see §6 below). Those
  already-written files were left in place rather than bulk-deleting a
  directory whose full contents' provenance isn't fully known from a single
  review pass; flagged for the user to clear if they want to.

## 5. M6 integration-pass fixes (on top of the three parallel passes)

File and cue names in §5–§7 are the current ones; the M6-era names are in the
revamp changes above.

1. `scripts/actors/hero.gd` — added the missing `interact` SFX call site.
2. `scripts/objects/core_node.gd` — added the missing SC01 SFX call sites
   (`alarm`, `adam_chime`) and migrated its outline off the pre-M6 blockout
   purple (later superseded by the night palette).
3. `scripts/weapons/scrapjack.gd` — fixed the held weapon's workshop-tag text
   rendering mirrored/rotated (unreadable) whenever the pre-existing (M1)
   aim-pivot rotate+flip mechanic pointed the gun somewhere other than
   straight right; the housing/flash/shadow drawing is untouched.
4. `scripts/debug/m3_route_demo.gd`, `scripts/debug/m6_characters_demo.gd` —
   added `M6_REDUCED_MOTION=1` / `M6_MUTED=1` env-var toggles (debug-capture
   scenes only) so the M6 readability captures could be reproduced with
   `Settings.reduced_motion`/muted audio, and a `M6_PERF_LOG=1` toggle on the
   route demo for real-time FPS sampling. No gameplay/physics/state-machine
   code was touched by any of these changes; verified with the full test
   suite (`tools/test.sh`, `FPS=30 tools/test.sh`) before and after, plus a
   headless 120-frame boot and a windowed 60-frame capture of `main.tscn`.

## 6. M6 adversarial review pass fixes (2026-09-27, on top of §5)

A separate adversarial review of the M6 presentation work produced 17 findings (2 critical, 8 major,
7 minor); each was independently verified against the actual code/assets before any fix. Full
per-finding detail (evidence, exact before/after) is in `../../prototype-plans/level-01-sunnyvale/
09-progress-and-handoff.md`'s "M6 adversarial review fixes" session log entry; summarized here.
Fixes 2–3, the Staffer half of 4, 7 and 12 concerned art that has since been deleted or replaced (the
zombie Resident cutout and its vector overlay, the procedural hero rig, the pre-revamp palette), and are
kept as history only:

1. `scripts/actors/visuals/clipper_visual.gd` — re-anchored the STALL motor overlay
   (`MOTOR_LOCAL`) onto `RearHitZone`'s own center and shrank its radii to fit inside the zone
   (AD-01, critical); redrew the shear blades as filled steel polygons and gave the eye stalks a
   ribbed housing ring, both now sharing the body's own lean rotation instead of detaching from it
   (AD-04).
2. `tools/derive_character_sprites.py` — added a morphological-open pass plus four hand-picked
   protect boxes to stop the background-removal flood from punching holes in the zombie's shirt and
   four Clipper ivory panels, and cropped both sprites' baked cast shadows (AD-02, critical); see §1's
   own note above and the regenerated `assets/characters/*.png` files (the zombie half is gone).
3. The zombie's vector overlay (then `resident_visual.gd`) — gave the WINDUP/LUNGE procedural redraw
   hair, a face mark, and outlined slippers instead of bare rectangles (AD-03). Superseded: the file
   is now the fully procedural `staffer_visual.gd`.
4. `scripts/actors/staffer.gd`, `scripts/actors/clipper.gd` — outlined both warning triangles and
   raised their minimum alpha from 0.2 to 0.9 (AD-05); raised the Clipper's triangle further above its
   own sprite.
5. `scenes/actors/clipper.tscn` — added `z_index = 1` (matching `staffer.tscn`) so the Clipper
   always draws over the hero, including while its exposed motor is the intended counterplay target
   (AD-06).
6. `scripts/weapons/scrapjack.gd` — the held gun's workshop tag now only draws on a resting (not
   held) instance, so it no longer duplicates the HUD's own tag on the hero's chest (AD-07).
7. `scripts/actors/visuals/hero_visual.gd` — moved the belt pouch's draw call to after the torso so
   it's no longer hidden entirely, shrank the oversized knee patch, and rebuilt the hair with real
   volume and a bigger forelock (AD-08, partial). Superseded by the Rook sprite pack (§8).
8. `scenes/objects/tutorial_prompt.tscn`, `scenes/actors/clipper.tscn` (`HintLabel`),
   `scenes/ui/subtitle_panel.tscn` (`HintLabel`) — added the HUD's own text outline to three
   previously unoutlined white labels (AD-09/AD-17); `scripts/effects/impact_spark.gd` — gave
   the HIT spark's four rays the same outline stroke its circle/plate shapes already had (AD-17,
   partial — the A06 sign/bush overlap and prompts drawing over the hero's head are unchanged, see
   §4's own gap note).
9. `scripts/objects/scenery.gd` — removed the ceiling PANEL's platform-style top-edge highlight and
   desaturated its fill so it can't be mistaken for walkable geometry; changed the CLOUD_PROJECTOR's
   cloud fill from (invisible) SKY to CREAM (AD-10).
10. `scripts/ui/workbench_panel.gd` — the price line no longer shows an impossible negative wallet
    projection when funds are short (AD-11); a refused purchase now plays the existing `ui_back` cue
    instead of the success `ui_confirm` chime (AD-14, partial — see §4's own gap note).
11. `scripts/debug/m5b_demo.gd` — redirects `Telemetry` to a throwaway dir the same way it already
    redirected `CheckpointService`, so this demo (the only one that instances the real `Main` scene)
    stops writing real playtest logs into the player's actual save location (AD-13).
12. 21 scripts across `scripts/actors/`, `scripts/objects/`, and `scripts/world/` — migrated their
    outline constant from the pre-M6 blockout tone `#2b2233` to the M6 warm-charcoal token `#332a20`
    (AD-15), closing the inconsistency §4 previously listed as a known gap. The revamp has since
    moved the drawn scripts to the night palette (near-black `#07090F` outlines).

Rejected: AD-16 (already an explicitly tracked gap in §4, not a new bug). Deferred (see §4's own gap
notes): the remainder of AD-14 (a full cue-priority/ducking pool) and the remainder of AD-08 (a full
hero-rig redraw to match the illustrated enemies' fidelity; overtaken by the Rook pack).

Re-verified at the time: `tools/test.sh`/`FPS=30 tools/test.sh` both 36/36 cases passed after every fix above; no
gameplay/collision/physics/state-machine code was touched.

See `CONVENTIONS.md`'s "Autoload `Audio`" section for the authoritative,
up-to-date cue table, and `../../prototype-plans/level-01-sunnyvale/
09-progress-and-handoff.md` for the full M6 verification evidence log.

## 7. Kenney CC0 asset integration (M7 Kenney pass, 2026-09-27)

Adds real recorded/designed audio, input-prompt icons, particles, light-mask
glows, and a crosshair cursor from [Kenney](https://kenney.nl/) — all **CC0
1.0** (public domain, no attribution required). For the SFX cues listed in
§7.1 the Kenney file is what plays; §2's tables say which cues play Kenney
files and which play synthesized ones. Every file was copied individually
(never a whole pack) into `assets/kenney/<pack>/`, each pack folder keeps its
own `LICENSE.txt` (a copy of that pack's original `License.txt`), and full
picked-file-by-file reasoning lives in `assets/kenney/README.md`. 75 files
were copied in total: 71 were wired at the time and 4 were staged for the
then-pending Clipper particle pass (wired since, §7.6); the revamp's audio
pass later stopped referencing seven of the audio files (§7.1). One import pass
(`godot --headless --path . --import`) and the full test suite
(`tools/test.sh` / `FPS=30 tools/test.sh`, both 49/49) were re-run after this
pass with no regressions; a 120-frame headless launch of `scenes/main.tscn`
produced zero errors; `res://scenes/debug/m3_route_demo.tscn` (full level
route, 8 fps) and `res://scenes/debug/m2_demo.tscn` (Staffer + Clipper
combat, 15 fps) were captured windowed and inspected frame-by-frame: lamp/
beacon glows read as soft ambient light (not the earlier flat debug-looking
discs), all effects stay brief/low-alpha, and nothing covers feet, edges,
chips, or attack warnings. (These captures and counts are of the pre-revamp
build.)

### 7.1 Audio (`scripts/audio/audio_director.gd`'s `SFX_SOURCES`)

Status: **usable-in-prototype**. 44 distinct `.ogg` files were copied across
4 packs and mapped to 27 of the 34 M6 SFX cues (pooled 2-3 files per cue for
the most frequently heard ones). The revamp's audio pass kept 24 cues on
Kenney (the hero, pistol, Clipper and generic UI/world cues) and moved the
rest to synthesized sounds (§2): `chip`, `chip_cluster`, `evidence`,
`med_patch` and `alarm` left Kenney, so seven copied files
(`interface-sounds/confirmation_001`, `_002`, `_003`, `_004`, `error_005`,
`glass_002` and `select_002`) are no longer referenced by `Audio.SFX_SOURCES`;
they stay in the repo with their licence. The hero, pistol and Clipper
cues play about a semitone down (`DARKEN` = 0.94). Cue **names** and
`Audio.play_sfx()` call sites are otherwise unchanged. The remaining 37 wired
files:

| Pack | Source | CC0 | Files used | Cues |
| --- | --- | --- | --- | --- |
| Interface Sounds | https://kenney.nl/assets/interface-sounds | Yes | `back_001/002`, `bong_001`, `error_001`, `open_001`, `pluck_001`, `scratch_004`, `select_001/005` (9 wired of 16 copied) | `ui_back`, `checkpoint`, `save_failed`, `cache_open`, `hero_jump`, `clipper_scrape`, `interact`, `purchase` |
| Impact Sounds | https://kenney.nl/assets/impact-sounds | Yes | `footstep_concrete_000/001/002`, `impactGeneric_light_000/001/002`, `impactMetal_medium_000/001/002`, `impactMining_000`, `impactPunch_medium_001`, `impactSoft_heavy_000` (12) | `hero_land`, `bolt_hit`, `bolt_blocked`, `clipper_defeat`, `hero_hurt`, `pit_fall` |
| UI Audio | https://kenney.nl/assets/ui-audio | Yes | `click1/2`, `rollover2/3/4`, `switch1` (6) | `ui_confirm`, `ui_move`, `swap` |
| Sci-fi Sounds | https://kenney.nl/assets/sci-fi-sounds | Yes | `doorClose_000`, `doorOpen_000`, `forceField_000/001`, `impactMetal_002`, `laserRetro_000/001/002`, `laserSmall_000/001` (10) | `latch`, `hatch_open`, `clipper_windup`/`clipper_stall`, `clipper_charge`, `pistol_fire`, `pistol_fire_quick` |

### 7.2 Input-prompt icons (`scripts/ui/controls_panel.gd`)

Style **Keyboard & Mouse -> Vector -> Outline** (64x64 SVG), tinted via
`modulate`. Status: **usable-in-prototype**. Shown beside (never instead of)
the existing InputMap-driven binding text in the Controls panel (Title screen
+ Pause menu); a binding onto a key with no copied-in icon falls back to
text-only for that sub-binding.

| Pack | Source | CC0 | Files used |
| --- | --- | --- | --- |
| Input Prompts | https://kenney.nl/assets/input-prompts | Yes | `keyboard_a/d/w/e/enter/escape/f1/space/tab_outline.svg`, `keyboard_arrow_left/right/up_outline.svg`, `mouse_left_outline.svg`, `mouse_move.svg` (14) |

### 7.3 Crosshair (`scripts/main.gd`)

`crosshair-pack`, **Outline** style, design `crosshair-000`. Status:
**usable-in-prototype**. Set as the OS custom mouse cursor
(`Input.set_custom_mouse_cursor()`) only during real gameplay (a Hero
present, `input_enabled` true, tree unpaused); the plain arrow shows on the
Title screen, while paused, and during any modal panel.

| Pack | Source | CC0 | Files used |
| --- | --- | --- | --- |
| Crosshair Pack | https://kenney.nl/assets/crosshair-pack | Yes | `crosshair_1x.png`, `crosshair_2x.png` (2) |

### 7.4 Light-mask lamp/beacon glows (`scripts/objects/scenery.gd`, `scripts/world/environment_state.gd`)

`light-masks`, **Transparent** variant, additive-blended `Sprite2D`s (z_index
-9, low alpha) behind actors — never a solid shape, never covering feet/
edges. Status: **usable-in-prototype**. The LAMP kind swaps its utility glow
for a brighter lockdown glow live, driven by `EnvironmentState`; the BEACON
kind (the lockdown alarm) gets a glow + a pulsing ring, held steady (never
hidden) under `Settings.reduced_motion`. In the night look these masks give lamps
and beacons their glow halos; the light pools on the ground are separate
additive `PointLight2D`s with stepped textures (`scenery_draw.gd`).

| Pack | Source | CC0 | Files used |
| --- | --- | --- | --- |
| Light Masks | https://kenney.nl/assets/light-masks | Yes | `circle_a` (beacon glow), `circle_b` (lamp utility glow), `circle_c` (lamp lockdown glow), `cone_a` (lamp utility beam), `cone_composed_c` (lamp lockdown beam), `ring_a` (beacon pulse ring) (6) |

### 7.5 Particles (`scripts/effects/kenney/kenney_puff.gd`, one reusable one-shot `CPUParticles2D` wrapper)

`particle-pack`, **Transparent** variant, tinted, capped under ~0.5s, halved
amount/speed under `Settings.reduced_motion`. Status:
**usable-in-prototype**. Wired at 7 call sites: `scrapjack.gd` (muzzle
flash), `hero.gd` (landing dust, gated to a real fall/jump), `chip.gd`
(pickup sparkle), `chip_cache.gd` (cache-open sparkle), `recovery_station.gd`
(checkpoint-save sparkle), `staffer.gd` (defeat puff), `pit_hazard.gd`
(pit-fall dust).

| Pack | Source | CC0 | Files used |
| --- | --- | --- | --- |
| Particle Pack | https://kenney.nl/assets/particle-pack | Yes | `muzzle_02` (muzzle flash), `dirt_01` (landing dust), `dirt_03` (pit-fall dust), `star_04` (chip/cache sparkle), `star_05` (checkpoint sparkle), `smoke_02` (Staffer defeat puff) (6) |

### 7.6 Clipper particles — now wired (M7 Kenney part B, 2026-09-27)

`assets/kenney/particles/clipper_later/` was staged (copied, import-verified,
deliberately unreferenced) by the earlier Kenney pass "for the concurrent
Clipper workflow" — that workflow is this one. All three files are now wired
through `scripts/effects/kenney/kenney_puff.gd` (the frontal spark and the
two defeat effects — same one-shot `CONFIGS`-table pattern as §7.5) and
`scripts/actors/visuals/clipper_visual.gd` (the two looping STALL effects,
outside that one-shot pattern — see below). Status: **usable-in-prototype**.

| Pack | Source | CC0 | File | Wired as |
| --- | --- | --- | --- | --- |
| Particle Pack | https://kenney.nl/assets/particle-pack | Yes | `star_01_metal_spark.png` | `clipper.gd::_on_front_blocked_hit()` — a short (<=0.3s), warm-white/amber, capped (`max_concurrent: 3`) `clipper_spark` burst at the exact impact point, additive to the existing shape-based chevron/shield-flash cues; also `clipper.gd::_defeat()`'s `clipper_defeat_spark` (a few spark bits) |
| Smoke Particles | https://kenney.nl/assets/smoke-particles | Yes | `whitePuff00_stall_steam.png` | `clipper_visual.gd`'s `StallSteam` `CPUParticles2D` — steam looping from the exposed rear motor for as long as `Clipper.State.STALL` lasts; also `clipper.gd::_defeat()`'s one-shot `clipper_defeat_smoke` |
| Particle Pack | https://kenney.nl/assets/particle-pack | Yes | `star_02_dazed_star.png` | `clipper_visual.gd`'s `StallStars` `CPUParticles2D` — 2 stars orbiting (`orbit_velocity`) above the exposed motor for as long as STALL lasts, additive to the existing hand-drawn stunned-star glyph (`_draw_stunned_indicator()`) |

`max_concurrent` (new on `kenney_puff.gd`'s `CONFIGS`, only set for
`clipper_spark`) is what keeps rapid fire from flooding the screen with
overlapping spark bursts — see `KenneyPuff._active_counts`. The two STALL
loops are `CPUParticles2D` children of `clipper.tscn`'s `Visual` node
(`show_behind_parent = true`, same as `Photo`, so the existing target-ring/
timer-arc overlay still draws on top and stays readable); `clipper_visual.gd`
toggles their `emitting` and repositions them at the motor anchor every pose
update, and swaps to a single static (non-looping) puff sprite instead under
`Settings.reduced_motion` rather than hiding the cue outright. Both stop the
instant STALL ends (RECOVERY) or a defeat starts.

Also now wired: tutorial-prompt input icons. `scripts/ui/input_icon_map.gd`
(new, no `class_name`) pulls `controls_panel.gd`'s original icon-file table
and layout-aware key-label logic out into one shared place; both
`controls_panel.gd` (refactored to call it instead of duplicating it) and
`scripts/objects/tutorial_prompt.gd` (new `icon_actions`/`static_icon_before`
exports) now resolve the SAME CURRENT-InputMap-binding icon for a given
action, with a bracketed text token (e.g. `[Q]`) falling back for any
binding this pack has no icon file for. A01's Move/Jump/Aim+Fire prompts and
the Clipper's 2-hit hint label were also restyled to the subtitle/toast
panel material (a backed panel, >= 22px at Normal text size, scaling with
`Settings.text_size`) — see
`prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`'s Kenney
part B entry for the full list of touched scenes.

### 7.7 Known gaps (this pass)

- Per-cue `volume_db` mix trims (§7.1) were an initial engineering-judgment
  pass at the time, not a measured-loudness/by-ear match — no audio playback
  tool existed in this headless environment. The revamp's audio pass re-set
  them from a measured loudness pass (recorded in the comment above
  `SFX_SOURCES`); this report did not repeat that measurement.
- `scripts/objects/scenery.gd`'s `CLOUD_PROJECTOR` kind (a pre-revamp prop
  from the old sealed-habitat look) still drew its original flat circles at
  the time — flagged separately by the fx workflow, not a Kenney asset.
- The E02 Clipper tutorial prompt and the Clipper's 2-hit hint label got the
  same readable-panel/text-size treatment as A01's prompts but were left
  WITHOUT input icons (neither names a single key the way "Move"/"Jump"/
  "Aim + Fire" do) — plain styled text only.

### 7.8 Review fixes (2026-09-27 follow-up)

- **Chip/checkpoint sparkle was effectively invisible in real play.**
  `kenney_puff.gd`'s `chip_sparkle`/`chip_sparkle_cluster`/`checkpoint_sparkle`
  configs used `scale_min/max` (0.08-0.20 of the 512px `star_04`/`star_05`
  source) that, combined with those textures' own low peak alpha
  (~223/255 and ~213/255), rendered as only a handful of near-invisible
  pixels at the real gameplay camera zoom (1.0) — confirmed by reproducing
  `kenney_fx_demo.gd`'s `_chip_pickup()` sequence and pixel-sampling the
  resulting screenshot for GOLD (0 matching pixels). Fixed by raising
  `scale_min/max` roughly 2.7x and `alpha` to 0.95 for all three configs;
  re-verified with a fresh capture (`chip_pickup_1280x720.png`) showing a
  clearly visible gold star burst at the same camera scale.
- `assets/kenney/README.md`'s wiring-status callouts (audio, input-prompt
  icons, crosshair, light masks, particles) were stale — they said wiring
  was "a separate, later pass... not done here" when §7.1-7.5 above already
  show it done. Updated each section's note to say "done" and point at this
  report for the authoritative per-file breakdown; also corrected the top
  summary table's Particle Pack file count (was 9, actually 8: 6 wired
  here + 2 staged for the Clipper pass, matching §7.5/§7.6's own tally).

### 7.9 Review fixes (2026-09-28 follow-up, Kenney part B review)

- **Clipper's 2-hit HintLabel could render directly over the hero
  (confirmed, fixed).** It was a `Label` at a FIXED local offset
  (`clipper.tscn`, offset_top/bottom -320/-152) under the Clipper itself —
  world-space, not screen-space — so its on-screen position tracked the
  CLIPPER, not the hero. A hero at Hero.tuning's own max jump apex
  (`jump_apex_h` * H + H ≈ 250px above ground) within the panel's ±160 local
  x-extent rendered directly behind it, hiding everything above the knees:
  confirmed with a temporary review scene (deleted after use) and a capture
  showing only the hero's legs below the panel. This is a very ordinary
  "walk up and mash fire into the shield while jumping" sequence — exactly
  what lands the 2 blocked hits `frontal_hint_threshold` requires — not an
  edge case. Fixed by moving the Label under a new `HintLayer` `CanvasLayer`
  child of Clipper (`clipper.gd`'s `hint_label` now resolves
  `$HintLayer/HintLabel`): a `CanvasLayer` ignores its parent's world
  transform entirely, so the hint now renders as a fixed top-center screen
  toast (below the HUD's own top-center Toast row, above the gameplay area)
  regardless of either actor's position — it can no longer overlap the hero
  under any circumstance. `clipper.gd`'s stale doc comment (referencing an
  even earlier "-180..-152" offset pair that no longer matched the scene)
  was also corrected to describe the new screen-anchored toast.
- **Kenney's "Space" key icon was illegible at this project's icon render
  size (confirmed, fixed).** `keyboard_space_outline.svg` bakes the word
  "SPACE" as vector art into its 64x64 canvas; shrunk to this project's
  26-28px icon size (`tutorial_prompt.gd`/`controls_panel.gd`'s own
  `ICON_SIZE`) it reads as an illegible smudge, unlike every single-glyph key
  icon (A/D/W/E/...) which stays crisp at the same size — confirmed by
  zoomed captures of both the Jump tutorial prompt and the Controls-help
  menu. Fixed by removing `KEY_SPACE` from `input_icon_map.gd`'s
  `KEY_ICON_FILES` table; every caller already falls back to plain text for
  a binding with no icon file (the SAME mechanism used for any key this pack
  has no icon for at all), so Jump's row now shows its W/↑ icons plus a
  readable "Space" text label instead of a blurry icon. `keyboard_a/w/e/
  arrow_*_outline.svg`'s single-glyph/pictogram icons, and the short 2-3
  letter Esc/Tab/F1 icons, were checked against the same captures and stay
  legible at this size — only Space's 5-letter baked text was affected, so
  only its table entry changed.
- **The E02 capture demo never actually exercised the 2-hit hint (confirmed,
  fixed) — a capture/evidence gap, not a gameplay bug.**
  `clipper_e02_sequence_demo.gd`'s own deliberate frontal volley against the
  real A02 E02 encounter only ever landed 1 blocked hit before WINDUP ended
  and CHARGE began, so this capture's own evidence never showed the
  HintLabel at all. Root cause (found with a temporary headless probe,
  `tests/cases/test_probe_e02_timing.gd`, deleted after use): the scripted
  hop over the stone backstop (`R05_JumpBackstop1`) happens to occur DURING
  WINDUP, and the demo's shared `jumping` branch unconditionally released
  fire for that jump's whole ~0.65s airtime — eating almost the entire 0.8s
  WINDUP window and leaving only ~1 shot's travel time to land. Fixed by
  keeping the deliberate frontal volley active through that one hop
  whenever `clipper.state` is still `PATROL`/`WINDUP` (the CHARGE-dodge jump
  later in the same demo is untouched — it still releases fire as before);
  re-verified with the same probe: 2 hits now land at frames 100 and 115, a
  full 9 frames before WINDUP ends and CHARGE begins at frame 124 (was 1
  hit, landing 1 frame before CHARGE). No Clipper rule/tuning/state-machine
  timing changed — only this debug capture demo's own input-driving logic.

## 8. Hero sprite pack — the Rook pack (2026-09-28), placeholder art for Dave Harlan

The hero is now Dave Harlan (C18). This pack was generated before that
decision under the working name Rook, so its file and frame names keep
`rook` and its look (proportions, jacket, badge, gear) predates the H01
design; it stays as placeholder art until new hero art exists (C23). The
gameplay integration below is unchanged by the revamp.

**Source:** `concept-art/h01-rook/sprites-v1/` — 16 transparent 1254×1254
PNGs generated by the user with ChatGPT from
`concept-art/h01-rook/rook-sprite-brief-for-chatgpt.md` (the brief attached
the approved Resident/Clipper PNGs as style references at the time; the
Resident PNG has since been deleted, C23). User-owned generated content; no
third-party assets. Originals kept intact.

**Processing:** `tools/process_rook_sprites.py` (re-runnable) →
`assets/characters/rook/rook_*.png` (2x scale, shared 256×256 canvas, hero
feet at (128, 248); displayed at 0.5 → the hero ≈ 98 px tall, H = 96) and
`scripts/actors/visuals/rook_frames.gd` (per-frame near-shoulder pivots).
It clears faint generator alpha (< 40), normalises each frame's scale (the
action frames came back 3–16% larger than the standing frames, by a
different amount each; measured with jacket area, boot size, painted area
and head size), aligns feet to one baseline (airborne frames keep the
standing head height instead), and cuts the near arm from the parts sheet
with its shoulder pivot and fist point.

| id | path | states | status |
| --- | --- | --- | --- |
| rook_idle_1/2 | `assets/characters/rook/rook_idle_{1,2}.png` | idle breathing (0.7 s alternation) | usable-in-prototype |
| rook_run_1…6 | `assets/characters/rook/rook_run_{1..6}.png` | run cycle driven by hero.gd's stride phase | usable-in-prototype |
| rook_jump_rise / rook_jump_fall | `assets/characters/rook/rook_jump_*.png` | airborne up / down | usable-in-prototype |
| rook_land | `assets/characters/rook/rook_land.png` | 0.12 s landing | usable-in-prototype |
| rook_hurt | `assets/characters/rook/rook_hurt.png` | 0.2 s hit pose | usable-in-prototype |
| rook_defeated | `assets/characters/rook/rook_defeated.png` | zero health (arm + pistol hidden) | usable-in-prototype |
| rook_interact | `assets/characters/rook/rook_interact.png` | 0.35 s interact pose | usable-in-prototype |
| rook_arm | `assets/characters/rook/rook_arm.png` | near (gun) arm on AimPivot, rotates with aim | usable-in-prototype |

**Rig:** `scripts/actors/visuals/hero_visual.gd` — Body sprite (frame per
state) + Arm sprite on AimPivot. `hero.gd` keeps AimPivot on the current
frame's shoulder, so the arm stays attached through run bob, crouch and
landing. The Scrapjack (still the procedural W01 drawing) sits in the fist,
scaled to 0.65 so it reads as a compact pistol (~18% of the hero's height).
**Gameplay-visible change:** shots now leave from the pistol at arm's
length from the shoulder (≈ 58 px from the shoulder toward the aim)
instead of from a pivot at waist height (35 px above the feet); all 52
test cases pass at 60 and 30 fps with this change.

**Remaining gaps for the hero pack:**
- Left-facing art is the right-facing art mirrored, which mirrors the
  forelock and eyebrow mark (style guide prefers separate left drawings).
- The six run frames are one step, looped; the body bobs ~15 px through the
  cycle as drawn.
- The index finger lies along the pistol but the fingers don't wrap it; the
  pistol itself is still the procedural drawing (no Scrapjack sprite yet).
- The pack was drawn for the old daytime look, so it has no night rim light
  of its own, and its cream trousers are much lighter than the H01 brief's
  dark cargo trousers (the orange jacket already reads as the brief's burnt
  orange, and the knee patches are there).
- `scenes/debug/rook_rig_demo.tscn` is a close-up capture scene for this
  rig (touches no save data).

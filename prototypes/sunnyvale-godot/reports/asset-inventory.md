# M6 asset inventory — Sunnyvale prototype

Compiled during the M6 integration/verification pass (consolidating the
parallel audio, characters, environment, and fx/UI presentation passes).
Every entry's provenance was checked against the file actually on disk in
this repo, not just against the authoring agent's own report. "Status"
follows the schema requested for this pass:

- **usable-in-prototype** — final for this prototype's purposes, wired and verified.
- **draft** — functional and wired, but a placeholder for real production art.
- **placeholder** — present only to avoid a blank/missing asset; not representative.
- **reference-only** — kept in the repo for comparison, not wired into any scene.

All image/audio assets are original to this project: either synthesized by a
local script (`tools/gen_audio.py`) or derived from the two approved
concept-art PNGs under `../../concept-art/` (which were never modified — see
`derive_character_sprites.py`, which only *reads* them). No third-party or
downloaded art/audio is used anywhere in this prototype.

## 1. Character/creature image assets (`assets/characters/*.png`)

| id | path | source / provenance | dimensions | pivot | status |
| --- | --- | --- | --- | --- | --- |
| resident_full_1x | `assets/characters/resident_full_1x.png` | Derived from `concept-art/z01-resident/z01-resident-2d-v1.png` via `tools/derive_character_sprites.py` (border flood-fill background removal, feathered edge, crop, scale to 92px tall) | 54×92 px | bottom-center (x=0 center, y=0 at feet/floor) | usable-in-prototype |
| resident_full_2x | `assets/characters/resident_full_2x.png` | Same source, 2x export — the texture actually bound to `resident.tscn`'s Photo node (displayed at 0.5 scale) | 108×184 px | same as 1x, scaled | usable-in-prototype |
| clipper_body_1x | `assets/characters/clipper_body_1x.png` | Derived from `concept-art/r01-clipper/r01-clipper-2d-v1.png` (background removed, cropped, scaled to 80px tall; eye-stalk and shear-blade regions erased/feathered — those parts change shape across gameplay states and a single flat concept illustration cannot supply that per `art-design/style-guide.md`'s "concept art is not a layered source" note) | 140×80 px | bottom-center (wheel/floor baseline) | usable-in-prototype |
| clipper_body_2x | `assets/characters/clipper_body_2x.png` | Same source, 2x export — the texture bound to `clipper.tscn`'s Photo node (displayed at 0.5 scale); `clipper_visual.gd` layers animated vector eye-stalks/shear blades and a STALL-only rear-motor glow/hatch overlay on top of this | 280×160 px | same as 1x, scaled | usable-in-prototype |
| clipper_full_1x | `assets/characters/clipper_full_1x.png` | Same source, nothing erased — whole-body neutral-pose reference | 140×80 px | n/a | reference-only (not wired into any scene) |
| clipper_full_2x | `assets/characters/clipper_full_2x.png` | Same source, 2x export | 280×160 px | n/a | reference-only |

**AD-02 fix (M6 adversarial review pass, 2026-09-27):** the border flood-fill in
`remove_background()` leaked through thin near-background-colored seams (a highlight streak on the
Resident's jacket collar) and, for the Clipper, through the wide-open shear-arm linkage, punching
background-colored holes in the Resident's cream shirt and four Clipper ivory panels (front accent
band, front-wheel hub disc, eye-mount panel, rear motor guard) — all showed the sky through the
character in game. Fixed with a morphological open (`OPEN_RADIUS = 2`, erode-then-dilate on the
background candidate mask before flooding) plus four hand-picked `CLIPPER_PROTECT_BOXES` forcing
those four panels opaque regardless of color distance (same by-eye-against-a-grid technique already
used for `CLIPPER_EYE_BOX`/`CLIPPER_SHEAR_BOX`); also cropped a baked cast shadow under both
sprites' feet/wheels via the existing `erase_region()` helper on two new hand-picked boxes. All six
PNGs above were regenerated from the same two approved, unmodified concept-art source files (still
`concept-art/z01-resident/z01-resident-2d-v1.png` / `concept-art/r01-clipper/r01-clipper-2d-v1.png`,
read-only) — dimensions above updated to match the regenerated (slightly tighter, shadow-free) crop
bbox; no third-party or downloaded pixels anywhere. Re-running `tools/derive_character_sprites.py`
reproduces these files byte-identically.

No approved concept sprite exists for the Hero (Rook), so `hero_visual.gd`
is an **original procedural vector rig** (jacket/shirt/trousers/knee-patch/
boots/neck-cloth/pouch/forelock per `design/02-characters/hero.md`) rather
than an image file — see §3.

## 2. Audio assets (`assets/audio/**/*.wav`)

All 36 files are synthesized by `tools/gen_audio.py` (python3 stdlib only —
`wave`/`struct`/`math`/`random`, fixed seed `20260927`, re-running it
reproduces byte-identical output) from oscillators, filtered-noise bursts,
and envelopes — nothing recorded or downloaded. All 34 SFX cues and both
music loops are **wired to a call site** (verified below); this M6
integration pass closed the two cues (`interact`, `eden_chime`/`alarm`) that
no single parallel art agent's ownership slice covered. Status for all:
**usable-in-prototype** for cadence/distinguishability purposes; synthesis
quality itself is prototype-grade DSP, not final sound design (see gaps).

| cue | file | duration | call site |
| --- | --- | --- | --- |
| gem | gem.wav | 0.09s | `Session.pickup_collected` (id matches `-G\d+$`) |
| gem_cluster | gem_cluster.wav | 0.21s | `Session.pickup_collected` (id matches `-GC\d+$`) |
| cache_open | cache_open.wav | 0.42s | `Session.pickup_collected` (id contains `CACHE`) |
| capsule | capsule.wav | 0.50s | `Session.pickup_collected` (id starts `L01-HS`) |
| artifact | artifact.wav | 0.88s | `Session.artifact_recorded` |
| checkpoint | checkpoint.wav | 0.50s | `Session.checkpoint_committed` |
| purchase | purchase.wav | 0.36s | `Session.upgrade_purchased` |
| swap | swap.wav | 0.17s | `Session.weapon_swapped` |
| save_failed | save_failed.wav | 0.40s | `Session.save_failed` |
| exit | exit.wav | 1.04s | `Session.level_completed` |
| pistol_fire / pistol_fire_quick | pistol_fire.wav / pistol_fire_quick.wav | 0.06s / 0.04s | `scrapjack.gd _try_fire()` (quick variant at Quickcycle stage ≥1); the muzzle-clamp instant-resolve path also plays `bolt_hit`/`bolt_blocked` itself, mutually exclusive with `scrap_bolt.gd`'s own resolve (verified: the clamp path `return`s before a bolt is ever spawned, so a shot never double-plays its hit/blocked cue) |
| bolt_hit / bolt_blocked | bolt_hit.wav / bolt_blocked.wav | 0.12s / 0.20s | `scrap_bolt.gd _resolve()` |
| hero_hurt | hero_hurt.wav | 0.22s | `hero.gd take_damage()` (damage-applied path only) |
| hero_jump | hero_jump.wav | 0.12s | `hero.gd _handle_jump_takeoff()` |
| hero_land | hero_land.wav | 0.14s | `hero.gd _physics_process()` (floor edge) |
| resident_windup / lunge / defeat | resident_windup.wav / resident_lunge.wav / resident_defeat.wav | 0.42 / 0.21 / 0.55s | `resident.gd` state-enter/`_defeat()` |
| clipper_scrape / windup / charge / stall / defeat | clipper_*.wav | 0.50 / 0.27 / 0.50 / 0.50 / 0.75s | `clipper.gd` state-enter/`_defeat()` |
| interact | interact.wav | 0.07s | `hero.gd`, at `_highlighted.interact(self)` — **wired in this M6 integration pass** (previously an open gap in every agent's ownership list) |
| latch | latch.wav | 0.10s | `route_switch.gd interact()` |
| eden_chime / alarm | eden_chime.wav / alarm.wav | 0.94 / 0.46s | `core_console.gd`'s SC01 coroutine — **wired in this M6 integration pass** (`alarm` on the ward-circuits warning, `eden_chime` alongside EDEN's subtitled line); `core_console.gd` was in no parallel agent's explicit ownership list |
| hatch_open | hatch_open.wav | 0.62s | `emergency_hatch.gd`, on the live `story_state_changed` flip |
| pit_fall | pit_fall.wav | 0.54s | `pit_hazard.gd`, alongside `hero.fall_to(...)` |
| ui_move / ui_confirm / ui_back | ui_move.wav / ui_confirm.wav / ui_back.wav | 0.04 / 0.10 / 0.10s | per-dialog in `title_screen.gd`, `pause_menu.gd`, `bench_panel.gd`, `swap_confirm.gd`, `completion_screen.gd` |
| music: suburb | suburb_loop.wav | 14.00s loop | `Audio.set_music(&"suburb")`, driven from `main.gd`/`story_state_changed` |
| music: quarantine | quarantine_loop.wav | 20.00s loop | `Audio.set_music(&"quarantine")`, same driver, after `awakening_done` |

## 3. Procedural / vector visual assets (no image file — drawn by GDScript `_draw()`)

Everything below is original C11-style vector art authored directly in
`_draw()`, using the palettes from `level-design/l01-welcome-to-sunnyvale.md`
and the per-subject art-design docs. No file to list a path for; the
"path" column names the script that owns the drawing.

| id | script | states / notes | status |
| --- | --- | --- | --- |
| hero_visual_rig | `scripts/actors/visuals/hero_visual.gd` | idle, run (procedural stride-phase limb swing), jump rise, fall, land squash, hit (tint+lean+shake, `Settings.reduced_motion`-gated), defeated (rotate+squash+fade), interact (brief forward bend); gun arm reaches to the real `AimPivot` grip point, hands otherwise empty (no second weapon) | draft (original design, no approved reference sprite exists for Rook) |
| resident_windup_lunge_overlay | `scripts/actors/visuals/resident_visual.gd`, `scripts/actors/resident.gd` | WINDUP/LUNGE swap the photo cutout for a small procedural vector redraw in z01-resident.md's palette (the source photo has only one relaxed-arm pose, no raised-arm variant to overlay) | draft |
| clipper_eye_stalks_and_blades | `scripts/actors/visuals/clipper_visual.gd`, `scripts/actors/clipper.gd` | Animated vector overlays pivoting from the real hinge/mount points baked into the body cutout; rear-motor glow ring + hatch flap + warning glyph, visible only during STALL | usable-in-prototype |
| scrapjack_weapon | `scripts/weapons/scrapjack.gd` | Chunky-L silhouette per `w01-scrapjack-pistol.md`: recoil, small muzzle flash, Quickcycle flywheel cover (visible at stage ≥1, spins faster while firing), held (aim-pivot, firing pose) vs. resting (ground/pad, contact shadow) look, workshop tag text. **M6-integration fix in this pass**: the tag previously mirrored/rotated into unreadable reversed glyphs whenever the pre-existing aim-pivot rotate+flip mechanic (unrelated to M6, from the original M1 aiming code) pointed the weapon left/up/down — the tag is now drawn through a corrective transform that keeps it screen-upright at every aim angle, without touching the housing's own rotation/flip (still correct) or any physics/aim code | usable-in-prototype |
| scrap_bolt | `scripts/weapons/scrap_bolt.gd` | Bolt travel + hit/blocked resolution mark, distinct SHAPES (not just color) for hit vs. blocked | usable-in-prototype |
| impact_spark | `scripts/effects/impact_spark.gd` | HIT/BLOCKED shapes at the muzzle-clamp instant-resolve point | usable-in-prototype |
| practice_target | `scripts/objects/practice_target.gd` | Circular target, hit-flash | usable-in-prototype |
| gem / gem_cache / care_capsule | `scripts/objects/gem.gd`, `gem_cache.gd`, `care_capsule.gd` | Small/large gem shapes, cache chest, capsule | usable-in-prototype |
| artifact_pickup (Welcome Key) | `scripts/objects/artifact_pickup.gd` | Drawn key silhouette + glow ring | usable-in-prototype |
| recovery_station | `scripts/objects/recovery_station.gd` | "Safe maintenance station" kiosk + lamp, lit/unlit | usable-in-prototype |
| route_switch / service_walkway / emergency_hatch / pit_hazard / kill_plane / moving_platform / beat_zone / exit_wicket / blocked_panel | `scripts/objects/*.gd` | Functional world-object dressing, unchanged collision | usable-in-prototype |
| maintenance_bench / weapon_pad | `scripts/objects/maintenance_bench.gd`, `weapon_pad.gd` | Bench + pad with resting-weapon tag | usable-in-prototype |
| core_console | `scripts/objects/core_console.gd` | Depot power-core housing + console screen, idle/warning/locked/awake phases. **M6-integration fix in this pass**: outline color migrated off the pre-M6 blockout purple (`#2b2233`) to the warm-charcoal C11 contour (`#332a20`); this script was in no parallel agent's explicit ownership list, so it had received no other M6 visual pass | usable-in-prototype |
| Block (world geometry) | `scripts/world/block.gd` | GROUND/PLATFORM/WALL/ROOF/BACKSTOP/PORCH/SCENERY_SOLID + an auto-detected depot-metal-floor GROUND variant | usable-in-prototype |
| Scenery (props) | `scripts/objects/scenery.gd` | HOUSE/FENCE/GATE/SHRUB/FLOWER/CLOCK/FOUNTAIN/LAMP/PLANTER/MAILBOX/PORTRAIT/BREAKFAST/SIGN/CLOUD_PROJECTOR/DEPOT_DOOR/WORKBENCH/RAIL/PANEL | usable-in-prototype |
| Area backdrops | `scripts/world/visuals/area_backdrop.gd` | Per-area SKY/HOMES/DEPOT parallax-layer backgrounds (Parallax2D at default scroll_scale=(1,1) after a Godot bug was found and worked around — see `deviations`) | usable-in-prototype |
| Hud icons | `scripts/ui/gem_icon.gd`, `weapon_icon.gd` | Small HUD glyphs | usable-in-prototype |
| c11_theme | `assets/ui/c11_theme.tres` | Shared Theme resource (cream/peach/warm-charcoal panels+buttons) used by `pause.tscn`, `bench_panel.tscn`, and (this M6 pass closed the last stragglers) `title_screen.tscn`, `swap_confirm.tscn`, `completion.tscn` | usable-in-prototype |

## 4. Remaining production-art gaps (honest list, carried from all passes + this integration pass)

- **Procedural hero.** Rook has no approved concept sprite; `hero_visual.gd`
  is an original vector rig, not a hand-drawn/frame-animated character. A
  real production pass would need concept art for Rook the way z01/r01 exist
  for the enemies.
- **No frame-by-frame hand animation anywhere.** Every "animation" in this
  prototype (hero run cycle, Resident/Clipper motion, Quickcycle spin,
  parallax bird bob, etc.) is procedural transform/tween-driven from a single
  static cutout or vector shape, not authored frame sequences.
- **Synthesized audio, not composed/recorded sound design.** `tools/
  gen_audio.py`'s oscillator/noise/envelope DSP is sufficient for cue
  distinguishability and milestone testing, not a final audio pass.
- **Resident/Clipper mirrored-facing asymmetry.** Both derived sprites face
  screen-left in their source concept PNGs and are mirrored (`scale.x`
  flip) for the opposite facing; this doubles the Resident's rolled-cardigan-
  sleeve asymmetry noted in `z01-resident.md`. A true fix needs a separately
  hand-drawn mirrored asset, not a flip.
- **Clipper wheels are static** (baked into the body cutout, no wheel-spin
  animation) — low priority since it does not affect the required warning/
  charge/stall readability.
- **No automated pixel-measured hitbox/art alignment tool** — sprite-to-
  collision alignment was verified only by eye across captured frames in
  this and the characters pass, not by an overlay/measurement script.
- **Procedural hero rig still reads as less refined than the illustrated
  enemy cutouts** (adversarial review AD-08). The M6 adversarial review pass
  fixed the concrete bugs (a belt pouch hidden entirely behind the torso, an
  oversized knee patch, flat cap-like hair with barely-visible forelock) but
  did not attempt a full redraw to match the enemies' sub-pixel contour
  fidelity or add a real face — that is a production-art undertaking (no
  approved Rook concept sprite exists to draw from) rather than a
  visual-node bug fix.
- **Audio cue priority/ducking (audio-direction.md L55/L57) not implemented.**
  The M6 adversarial review pass fixed the one cheap, contained piece (a
  distinct failed-purchase cue in `bench_panel.gd`, reusing the existing
  `ui_back` cue) but left the broader ask — a priority-based voice-stealing
  pool, and dropping the generic `interact` cue when a target plays its own
  — for a dedicated pass, since it touches call sites across `hero.gd`,
  `session.gd`, `level_director.gd`, and `core_console.gd`.
- **AD-17 (partial) update, M7 polish pass:** A06's "Quarantine Exit" sign
  (`Sign_Entry`, `scenes/levels/areas/a06_exit.tscn`) and the nearest shrub
  (`Shrub1`) are now 250px apart (x=70 vs x=320, both ~60-120px wide) with no
  overlap — the sign-behind-bush half of AD-17 is fixed. The other half is
  **still open**: `Hero._update_interact_prompt()`
  (`scripts/actors/hero.gd:342`) places `prompt_label` at
  `_highlighted.global_position + Vector2(-size.x*0.5, -64.0)` — 64px above
  the INTERACTABLE's own origin, not clamped relative to the hero's head
  bounds — so a prompt (or a world object's own `ToastLabel`, e.g.
  `core_console.gd`'s "EDEN awakens") can still draw over the hero's head
  when the hero stands close to a short interactable. Offsetting every
  prompt/toast above the hero's own head bounds instead remains a layout
  change across multiple files, left for a dedicated UI-layout pass.
- **New since the M6 pass (M7 polish), not previously listed here:**
  `scripts/objects/scenery.gd`'s `Kind` enum gained `BEACON` and `SUPPORT`
  (appended, per the file's own "never reorder existing values" contract);
  `AlarmVisuals` (a new node in `scenes/levels/areas/a05_depot.tscn`) drives
  A05's alarm-state look; A05's parallax backdrop (`area_backdrop.gd`) was
  retinted for the post-awakening look. All usable-in-prototype, wired and
  covered by the existing test suite's area/level checks — no new gap.
- **A debug-demo bug (now fixed) had already written real playtest-log
  files** into the actual player's default save location before the M6
  adversarial review pass caught it (`m5b_demo.gd` never redirected
  `Telemetry`, only `CheckpointService` — see §6 below). Those
  already-written files were left in place rather than bulk-deleting a
  directory whose full contents' provenance isn't fully known from a single
  review pass; flagged for the user to clear if they want to.

## 5. M6 integration-pass fixes (this pass, on top of the three parallel passes)

1. `scripts/actors/hero.gd` — added the missing `interact` SFX call site.
2. `scripts/objects/core_console.gd` — added the missing `alarm`/`eden_chime`
   SFX call sites and migrated its outline off the pre-M6 blockout purple.
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
09-progress-and-handoff.md`'s "M6 adversarial review fixes" session log entry; summarized here:

1. `scripts/actors/visuals/clipper_visual.gd` — re-anchored the STALL motor overlay
   (`MOTOR_LOCAL`) onto `RearHitZone`'s own center and shrank its radii to fit inside the zone
   (AD-01, critical); redrew the shear blades as filled steel polygons and gave the eye stalks a
   ribbed housing ring, both now sharing the body's own lean rotation instead of detaching from it
   (AD-04).
2. `tools/derive_character_sprites.py` — added a morphological-open pass plus four hand-picked
   protect boxes to stop the background-removal flood from punching holes in the Resident's shirt and
   four Clipper ivory panels, and cropped both sprites' baked cast shadows (AD-02, critical); see §1's
   own note above and the regenerated `assets/characters/*.png` files.
3. `scripts/actors/visuals/resident_visual.gd` — gave the WINDUP/LUNGE procedural redraw hair, a
   face mark, and outlined slippers instead of bare rectangles (AD-03).
4. `scripts/actors/resident.gd`, `scripts/actors/clipper.gd` — outlined both warning triangles and
   raised their minimum alpha from 0.2 to 0.9 (AD-05); raised the Clipper's triangle further above its
   own sprite.
5. `scenes/actors/clipper.tscn` — added `z_index = 1` (matching `resident.tscn`) so the Clipper
   always draws over the hero, including while its exposed motor is the intended counterplay target
   (AD-06).
6. `scripts/weapons/scrapjack.gd` — the held gun's workshop tag now only draws on a resting (not
   held) instance, so it no longer duplicates the HUD's own tag on the hero's chest (AD-07).
7. `scripts/actors/visuals/hero_visual.gd` — moved the belt pouch's draw call to after the torso so
   it's no longer hidden entirely, shrank the oversized knee patch, and rebuilt the hair with real
   volume and a bigger forelock (AD-08, partial — see §4's own gap note).
8. `scenes/objects/tutorial_prompt.tscn`, `scenes/actors/clipper.tscn` (`HintLabel`),
   `scenes/ui/subtitle_panel.tscn` (`HintLabel`) — added the HUD's own warm-charcoal text outline to
   three previously unoutlined white labels (AD-09/AD-17); `scripts/effects/impact_spark.gd` — gave
   the HIT spark's four rays the same outline stroke its circle/plate shapes already had (AD-17,
   partial — the A06 sign/bush overlap and prompts drawing over the hero's head are unchanged, see
   §4's own gap note).
9. `scripts/objects/scenery.gd` — removed the ceiling PANEL's platform-style top-edge highlight and
   desaturated its fill so it can't be mistaken for walkable geometry; changed the CLOUD_PROJECTOR's
   cloud fill from (invisible) SKY to CREAM (AD-10).
10. `scripts/ui/bench_panel.gd` — the price line no longer shows an impossible negative wallet
    projection when funds are short (AD-11); a refused purchase now plays the existing `ui_back` cue
    instead of the success `ui_confirm` chime (AD-14, partial — see §4's own gap note).
11. `scripts/debug/m5b_demo.gd` — redirects `Telemetry` to a throwaway dir the same way it already
    redirected `CheckpointService`, so this demo (the only one that instances the real `Main` scene)
    stops writing real playtest logs into the player's actual save location (AD-13).
12. 21 scripts across `scripts/actors/`, `scripts/objects/`, and `scripts/world/` — migrated their
    outline constant from the pre-M6 blockout tone `#2b2233` to the C11 warm-charcoal token `#332a20`
    (AD-15), closing the inconsistency §4 previously listed as a known gap.

Rejected: AD-16 (already an explicitly tracked gap in §4, not a new bug). Deferred (see §4's own gap
notes): the remainder of AD-14 (a full cue-priority/ducking pool) and the remainder of AD-08 (a full
hero-rig redraw to match the illustrated enemies' fidelity).

Re-verified: `tools/test.sh`/`FPS=30 tools/test.sh` both 36/36 cases passed after every fix above; no
gameplay/collision/physics/state-machine code was touched.

See `CONVENTIONS.md`'s "Autoload `Audio`" section for the authoritative,
up-to-date cue table, and `../../prototype-plans/level-01-sunnyvale/
09-progress-and-handoff.md` for the full M6 verification evidence log.

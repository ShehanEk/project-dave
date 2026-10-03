# Kenney asset credits (Sunnyvale prototype)

All assets below are from [Kenney](https://kenney.nl/), licensed **CC0 1.0**
(public domain — no attribution required, but credited here anyway). Each
pack folder keeps its own `LICENSE.txt` (the pack's original `License.txt`,
copied once per pack). Only the specific files actually selected for this
prototype were copied in — never a whole pack.

Every file below has been copied into the project, imported once, and
verified to load. Audio call sites, `ControlsPanel`/`TutorialPrompt` icons,
the mouse cursor, and every particle/light node (including the Patrol Rover's
armor-spark, stall and wreck effects) are now wired into game code, except
the unused files noted below — see the notes at the end of each section, and
`reports/asset-inventory.md` section 7 for the current, authoritative
per-file breakdown. `Audio.play_sfx()` cue **names** are unchanged; only the
underlying `.ogg` files each cue now loads changed.

| Pack | Source | Files used |
| --- | --- | --- |
| Interface Sounds | https://kenney.nl/assets/interface-sounds | 8 (7 unused files removed 2026-09-30, `scratch_004` removed with the Clipper, C33) |
| Impact Sounds | https://kenney.nl/assets/impact-sounds | 11 (`impactMining_000` removed with the Clipper, C33) |
| UI Audio | https://kenney.nl/assets/ui-audio | 6 |
| Sci-fi Sounds | https://kenney.nl/assets/sci-fi-sounds | 7 (`forceField_000`, `forceField_001` and `impactMetal_002` removed with the Clipper, C33) |
| Input Prompts | https://kenney.nl/assets/input-prompts | 14 |
| Crosshair Pack | https://kenney.nl/assets/crosshair-pack | 2 |
| Light Masks | https://kenney.nl/assets/light-masks | 6 |
| Particle Pack | https://kenney.nl/assets/particle-pack | 6 (5 in `particle-pack/`, 1 in `particles/machines/`) |
| Smoke Particles | https://kenney.nl/assets/smoke-particles | 1 (in `particles/machines/`) |

All licensed **CC0 1.0** — see each pack folder's own `LICENSE.txt`.

---

## 1. Audio — cue mapping

Chosen by name/category fit against `CONVENTIONS.md`'s cue list and by
measured duration (`tools/gen_audio.py`'s original synthesized duration is
listed for comparison — measured with a small headless Godot script loading
each `.ogg` as `AudioStreamOggVorbis` and reading `get_length()`, not by ear;
picks are name/category matches, not audition). Frequent cues get a 2–3 file
variety pool; the wiring pass should round-robin or randomly pick within a
cue's pool (the same pattern `Audio._sfx_pool` already round-robins players,
just applied to source files too).

| Cue | Was (synth) | Chosen file(s) | Pack | New len | Reason |
| --- | --- | --- | --- | --- | --- |
| `pistol_fire` | 0.06s | `laserRetro_000/001/002.ogg` (pool) | sci-fi-sounds | 0.24–0.26s | Short, punchy, lo-fi "retro" laser — fits the Scrapjack's scrappy improvised-weapon character better than a clean modern laser; not a long sustained beam. |
| `pistol_fire_quick` | 0.04s | `laserSmall_000/001.ogg` (pool) | sci-fi-sounds | 0.24s | Lighter/brighter "small" family, distinct timbre from the base fire pool, for the Quickcycle rapid-fire stage. |
| `bolt_hit` | 0.12s | `impactGeneric_light_000/001/002.ogg` (pool) | impact-sounds | 0.12–0.14s | Soft momentary bump — a hit on something that does not bleed, not a deflect. A hit on a person plays the synthesized `hit_flesh` instead (the shot skips `bolt_hit` there). |
| `bolt_blocked` | 0.20s | `impactMetal_medium_000/001/002.ogg` (pool) | impact-sounds | 0.12–0.27s | Clearly metallic clang, unambiguously distinct in timbre from `bolt_hit`'s soft generic impact. |
| `hero_hurt` | 0.22s | `impactPunch_medium_001.ogg` | impact-sounds | 0.41s | Solid body-punch impact for taking damage. |
| `hero_jump` | 0.12s | `pluck_001.ogg` | interface-sounds | 0.10s | Light plucky "boing" reads as a spring-loaded take-off. |
| `hero_land` | 0.14s | `footstep_concrete_000/001/002.ogg` (pool) | impact-sounds | 0.11–0.11s | Footfall thud on hard flooring, closest-length match to the original cue. |
| `staffer_windup` | 0.42s | **kept synthesized** | — | — | Revoiced in C33 as the implant chirp that tells a grab is coming. None of these four packs (interface/impact/UI/sci-fi) has an implant chirp — everything on offer is mechanical, UI, or object-impact. |
| `staffer_lunge` | 0.21s | **kept synthesized** | — | — | Revoiced in C33 as a grab whoosh. Same reason. |
| `staffer_defeat` | 0.55s | **kept synthesized** | — | — | Revoiced in C33 as a collapse plus an implant fizzle. Same reason. |
| `clipper_scrape` | 0.50s | **removed (C33)** | — | — | The Clipper is gone (the Patrol Rover replaced it); the cue, its fallback wav and `scratch_004.ogg` were removed. The Rover's idle roll is the synthesized `rover_patrol`. |
| `clipper_windup` | 0.27s | **removed (C33)** | — | — | Same: the cue, its wav and `forceField_000.ogg` were removed. The Rover's tell is the synthesized `rover_windup`. |
| `clipper_charge` | 0.50s | **removed (C33)** | — | — | Same: the cue, its wav and `impactMetal_002.ogg` were removed. The Rover's ram is the synthesized `rover_charge`. |
| `clipper_stall` | 0.50s | **removed (C33)** | — | — | Same: the cue, its wav and `forceField_001.ogg` were removed. The Rover's wall stall is the synthesized `rover_stall`. |
| `clipper_defeat` | 0.75s | **removed (C33)** | — | — | Same: the cue, its wav and `impactMining_000.ogg` were removed. The Rover's wreck is the synthesized `rover_destroyed`. |
| `chip` | 0.09s | **synthesized in the revamp** | — | — | The revamp (C24) replaced the Kenney pool with `tools/gen_audio.py`'s `chip.wav`; the unused Kenney files were removed. |
| `chip_cluster` | 0.21s | **synthesized in the revamp** | — | — | Now `chip_cluster.wav` from `tools/gen_audio.py`; the Kenney file was removed. |
| `cache_open` | 0.42s | `open_001.ogg` | interface-sounds | 0.15s | Panel/lid opening sound. |
| `med_patch` | 0.50s | **synthesized in the revamp** | — | — | Now `med_patch.wav` from `tools/gen_audio.py`; the Kenney file was removed. |
| `evidence` | 0.88s | **synthesized in the revamp** | — | — | Now `evidence.wav` from `tools/gen_audio.py`; the Kenney file was removed. |
| `interact` | 0.07s | `select_001.ogg` | interface-sounds | 0.04s | Quick, short acknowledgment tick. |
| `checkpoint` | 0.50s | `bong_001.ogg` | interface-sounds | 0.12s | Mellow single bell/bong for a recovery-station save. |
| `purchase` | 0.36s | `select_005.ogg` | interface-sounds | 0.38s | Fuller confirming tone for a bench upgrade transaction. |
| `swap` | 0.17s | `switch1.ogg` | ui-audio | 0.32s | Quick toggle click for a weapon swap. |
| `latch` | 0.10s | `doorClose_000.ogg` | sci-fi-sounds | 0.53s | Mechanical latch/lock thunk for pulling the route switch lever. |
| `adam_chime` | 0.94s | **kept synthesized** | — | — | Bespoke narrative beat (Adam's awakening line); none of these packs have a warm/organic "AI awakening" tone — only cold computer/glitch or hard UI sounds, which would undercut the moment. Optional per brief; synthesized reads better here. |
| `alarm` | 0.46s | **synthesized in the revamp** | — | — | Now `alarm.wav` from `tools/gen_audio.py`; the Kenney file was removed. |
| `hatch_open` | 0.62s | `doorOpen_000.ogg` | sci-fi-sounds | 0.53s | Direct "door/hatch opening" match. |
| `pit_fall` | 0.54s | `impactSoft_heavy_000.ogg` | impact-sounds | 0.51s | Heavier soft thud for landing in a pit hazard. |
| `exit` | 1.04s | **kept synthesized** | — | — | None of these one-shot UI/impact/sci-fi packs contain a finale/musical sting; everything is a short mechanical or UI click, wrong shape for a level-completion cue. |
| `ui_move` | 0.04s | `rollover2/3/4.ogg` (pool) | ui-audio | 0.06–0.11s | Soft hover tick for focus change — frequent, needs the variety pool. |
| `ui_confirm` | 0.10s | `click1.ogg`, `click2.ogg` (pool) | ui-audio | 0.06–0.09s | Menu confirm click. |
| `ui_back` | 0.10s | `back_001.ogg`, `back_002.ogg` (pool) | interface-sounds | 0.06–0.07s | Direct "back" name match. |
| `save_failed` | 0.40s | `error_001.ogg` | interface-sounds | 0.17s | Shorter error tone, kept distinct from `alarm`'s longer one. |

The 11 roster cues added by the C33 rebuild (`guard_windup`, `guard_swing`, `hit_flesh`, `body_fall`, `rover_patrol`, `rover_windup`, `rover_charge`, `rover_stall`, `rover_armor`, `rover_destroyed` and `debris_clatter`) are all synthesized by `tools/gen_audio.py`; no Kenney file is used for them. That leaves 19 of the 46 cues on Kenney files.

Music (`campus_loop`, `lockdown_loop`) is unaffected — no music pack was
part of this request, and both stay synthesized/looping as before.

**Wiring status: done.** `audio_director.gd`'s `SFX_SOURCES` dictionary maps
each cue above to its `.ogg` file(s) (a pool for cues with 2–3 variants,
round-robin-picked the same way `Audio._sfx_pool` already round-robins
players), and `_load_streams()` builds every cue's stream(s) from that table.
Cue names and the `Audio.play_sfx(...)` call sites are unchanged.

## 2. Input prompt icons

Style: **Keyboard & Mouse → Vector → Outline** (single-stroke line art,
64×64 SVG, imports cleanly as `CompressedTexture2D` in this Godot build —
verified with a throwaway import). Chosen over the filled/solid "Default"
variant because a single-color outline tints cleanly to warm charcoal
(`#332a20`) via `modulate` and matches the project's existing clean-vector
look (e.g. `chip_icon.gd`), rather than sitting on the cream panel as a solid
white blob. `mouse_move.svg` has no outline variant — its own design (mouse
silhouette + four-way arrow chevrons) is already a clean single-weight icon,
so it's used as-is.

| Binding | File |
| --- | --- |
| A | `keyboard_a_outline.svg` |
| D | `keyboard_d_outline.svg` |
| W | `keyboard_w_outline.svg` |
| Left | `keyboard_arrow_left_outline.svg` |
| Right | `keyboard_arrow_right_outline.svg` |
| Up | `keyboard_arrow_up_outline.svg` |
| Space | *(text only — see note below)* |
| E | `keyboard_e_outline.svg` |
| Escape | `keyboard_escape_outline.svg` |
| Tab | `keyboard_tab_outline.svg` |
| Enter | `keyboard_enter_outline.svg` |
| F1 | `keyboard_f1_outline.svg` |
| Mouse left button | `mouse_left_outline.svg` |
| Mouse move / aim | `mouse_move.svg` |

**Wiring status: done.** `ControlsPanel` (`scripts/ui/controls_panel.gd`)
renders each binding as a small `TextureRect` icon per key (falling back to
text for a binding with no icon above) instead of a joined string. The
icon-file table and layout-aware key-label logic now live in
`scripts/ui/input_icon_map.gd` (M7 Kenney part B), shared with
`scripts/objects/tutorial_prompt.gd`: A01's Move/Jump/Aim+Fire prompts and
every other prompt that names a binding now render the same icons inline,
with a bracketed text fallback (e.g. `[Q]`) for any key this pack has no icon
for. See `reports/asset-inventory.md` §7.6.

**Review fix (2026-09-28):** `keyboard_space_outline.svg` is still copied in
but deliberately has no entry in `input_icon_map.gd`'s `KEY_ICON_FILES`
anymore — unlike every other key here, Kenney bakes the word "SPACE" as
vector art into that one icon, which shrinks to an illegible smudge at this
project's 26-28px icon render size (confirmed by zoomed capture). Space now
uses the same bracketed/plain-text fallback every other icon-less binding
already gets — see `reports/asset-inventory.md` §7.9.

## 3. Crosshair

`crosshair-pack`, style **Outline** (two-tone: white fill + dark outline),
design `crosshair-000` — a classic circle-with-tick-mark reticle. Chosen for
readability on both the pale sky and the green lawn backdrops (the dark
outline keeps it visible on light backgrounds, the white fill keeps it
visible on the darker depot/lockdown interiors) and because its simple
geometry survives `modulate` tinting without losing legibility.

| File | Use |
| --- | --- |
| `crosshair_1x.png` (from `PNG/Outline/crosshair-000.png`, 74×74) | Aim cursor |
| `crosshair_2x.png` (from `PNG/Outline (2₧)/crosshair-000.png`, 148×148) | High-DPI variant |

**Wiring status: done.** `scripts/main.gd` calls
`Input.set_custom_mouse_cursor()` with this texture during actual gameplay
(picking the 1x/2x asset by the OS window size), and shows the plain arrow
cursor everywhere else (Title screen, menus).

## 4. Light masks

`light-masks`, **Transparent** variant (soft glow on alpha, not baked onto
black) so it composites and tints via `modulate`/`Light2D` color.

| File | Intended use |
| --- | --- |
| `circle_b.png` | Depot utility lamp glow (round bulb) |
| `cone_a.png` | Depot utility lamp cast beam (soft downward cone) |
| `circle_c.png` | Quarantine examination lamp glow (tighter, brighter round light) |
| `cone_composed_c.png` | Quarantine examination lamp beam (downward spotlight cone) |
| `circle_a.png` | Alarm beacon glow (distinct round shape, tint to warning color) |
| `ring_a.png` | Alarm beacon pulse ring (alternate/secondary shape) |

**Wiring status: done.** `scripts/objects/scenery.gd` preloads all six and
composites them as soft `Sprite2D`/glow children on the depot utility lamps,
the lockdown examination lamps, and the alarm beacon, tinted/retinted live
by `EnvironmentState`/`AlarmVisuals` per the style guide.

## 5. Particles (`particle-pack/`)

`particle-pack`, **Transparent** variant.

| File | Intended use |
| --- | --- |
| `dirt_01.png` | Hero landing dust puff |
| `star_04.png` | Gem pickup sparkle |
| `star_05.png` | Checkpoint-save sparkle (soft glow, distinct from chip's sharp sparkle) |
| `dirt_03.png` | Pit-fall dust (larger debris burst than the landing puff) |

**Wiring status: done.** `scripts/effects/kenney/kenney_puff.gd` is a single
reusable one-shot `CPUParticles2D` wrapper (a `kind` -> config table, see its
own doc comment) that every call site reaches through a plain `preload()` +
its static `spawn()` function: landing/pit dust at `hero.gd`/`pit_hazard.gd`, chip/cache sparkle at
`chip.gd`/`chip_cache.gd`, and checkpoint sparkle at `recovery_station.gd`. All respect
`Settings.reduced_motion` (fewer particles, less travel, never fully hidden)
and are tinted to the Sunnyvale palette per the style guide. The C33 rebuild
removed the `defeat_puff` kind and its `smoke_02.png`: the old Staffer's
`_defeat()` was its only caller, and people now die into ragdolls and blood
instead of a smoke puff. The C37 shooting pass removed the `muzzle_flash` kind
and its `muzzle_02.png`: tinted ivory it read as a white cloud, and the
Scrapjack's drawn ivory starburst and muzzle light now make the flash.

### Machine particles (`assets/kenney/particles/machines/`)

The earlier Kenney pass staged three files as Clipper candidates in
`particles/clipper_later/`, and M7 Kenney part B wired them to the Clipper. The
C33 rebuild moved the two the Patrol Rover uses to `particles/machines/` and
removed the third, `star_02_dazed_star.png` (the Clipper's orbiting "dazed"
stars, drawn by the deleted `clipper_visual.gd`):

| File | Used for |
| --- | --- |
| `star_01_metal_spark.png` (from `particle-pack/star_01.png`) | Metallic spark burst at the exact impact point of a blocked hit on the Patrol Rover's armor (`kenney_puff.gd` kind `armor_spark`, capped at 3 concurrent so rapid fire never floods the screen), the same spark on a hit to its exposed battery, and the spark spray of its wreck (`machine_spark`) — all fired from `patrol_rover.gd`, ADDITIVE to its own hand-drawn shape cue, never a replacement for it |
| `whitePuff00_stall_steam.png` (from `smoke-particles/PNG/White puff/whitePuff00.png`) | One-shot smoke puffs (`machine_smoke`): one when the rover's stall starts (`_enter_stall()`) and one at its wreck (`_defeat()`). The Clipper's looping stall steam and its reduced-motion static puff went with `clipper_visual.gd` |

Both wired kinds respect `Settings.reduced_motion` through `kenney_puff.gd`'s
own handling of one-shot kinds and are tinted to the Sunnyvale palette (warm
white/amber sparks, cream smoke) — see `scripts/effects/kenney/kenney_puff.gd`
for the exact configs, and `tests/cases/test_kenney_part_b.gd` for the covering
tests.

---

## Verification performed this pass

- Every file above copied from the read-only Kenney pack downloads into its
  `assets/kenney/<pack>/` folder — never a whole pack.
- Each pack's own `License.txt` copied once as `LICENSE.txt` alongside its
  files.
- `godot --headless --path . --import` run **once** after all files were
  staged (75 new assets imported cleanly).
- Every one of the 75 copied files confirmed to have a generated `.import`
  file.
- A one-off headless script (`load()` on every file under `assets/kenney/`)
  confirmed all 75 load through `ResourceLoader` with no failures.
- `NOIMPORT=1 tools/test.sh audio` and the full `NOIMPORT=1 tools/test.sh`
  suite both still pass — nothing in this pass touched gameplay, tuning,
  collision, IDs, save format, or any existing script/scene.

These counts are those of that pass (75 files). Later passes removed files:
the revamp's audio pass stopped using seven interface sounds (removed in the
2026-09-30 cleanup) and C33 removed five sounds with the Clipper. The table at
the top has the current per-pack counts.

**M7 Kenney part B addendum:** wired the three `clipper_later` files staged
above (no new files copied in; they now live in `particles/machines/`, see
"Machine particles") plus the existing Input Prompt icons into
`tutorial_prompt.gd` and the Clipper's hint label (now the Patrol Rover's) via
the shared `scripts/ui/input_icon_map.gd` mapping. Full
`tools/test.sh` (60 fps and `FPS=30`) both pass, 50/50 cases including the
new `tests/cases/test_kenney_part_b.gd` (36 checks). See
`reports/asset-inventory.md` §7 and
`prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md` for the
capture evidence and full session log.

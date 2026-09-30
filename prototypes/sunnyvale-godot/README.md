# DEAD EDEN — Sunnyvale prototype

A single-level (L01) Godot 4 prototype of DEAD EDEN's opening area. Dave
Harlan, a fired AI researcher, breaks into Arcadia Dynamics' Sunnyvale campus
at night, takes the level's clearance keycard, plugs into one of the core
nodes of Arcadia's sentient AI, Adam, to copy proof, and escapes through the
lockdown. Design authority: `../../prototype-plans/level-01-sunnyvale/`.
Implementation contracts (autoloads, IDs, node contracts, hard rules):
`CONVENTIONS.md`.

**Revamp (2026-09-29, C14–C24).** The prototype was rebuilt from the original
zombie-suburb version to the new story and look: cyborg Staffers instead of
zombie Residents, microchips instead of gems, the EF01 "Lockout Notice"
evidence file instead of the Welcome Key artifact, Adam's core-node scene
instead of the EDEN awakening, the L01-KC01 keycard that opens the exit, and a
dark night-campus look. Gameplay, tuning, timings and counts were unchanged.
Saves from a pre-revamp build are rejected as incompatible (the save schema
went to version 2 then), so **Continue** stays disabled until you start a new
run. The plan's README has the full old-to-new vocabulary table.

**Level 1 rebuild (2026-09-30, C33).** Level 1 was rebuilt from the ground up
around the approved enemy roster, after the lit-cutout test (C35). The C24
build's Staffers and the Clipper are gone. The level now has the SE01 Night
Guard (a guard with a stun baton), the M01 Patrol Rover (an armored charger:
let it crash into stone, then shoot the battery on its back) and, at the alarm
exit, the LK01 Staffer (a Linked night-shift worker). All are lit cutouts that
die and bleed, and there are 16 of them in the same 11 encounter groups. Every
enemy entity ID changed, so the save schema is now version 3 and **Continue**
stays disabled for an older save until you start a new run. At the exit wicket
a Security PA line plays before the completion screen opens. See
[Enemy lab](#enemy-lab) for a test strip with all three enemies.

## Opening the project

Godot **4.7.2.stable.official**. Open `project.godot` in the Godot editor,
or run headless/windowed from the command line:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path .          # editor
/Applications/Godot.app/Contents/MacOS/Godot --path . --headless --quit-after 120  # smoke run
```

The project boots to a title screen (`scenes/main.tscn`): **New Game**,
**Continue** (enabled only when a valid save exists — a corrupt primary save
transparently falls back to its own backup), and **Quit**.

## Running an exported build

`export_presets.cfg` defines two local-test presets ("Windows Desktop",
x86_64, embedded PCK; "macOS", universal, unsigned) built with:

```sh
Godot --headless --path . --export-release "Windows Desktop" exports/windows/Sunnyvale.exe
Godot --headless --path . --export-release "macOS" exports/macos/Sunnyvale.zip
```

(A third, undeclared-preset **macOS debug** build —
`Godot --headless --path . --export-debug "macOS" exports/macos-debug/SunnyvaleDebug.zip`
— exists only to carry the M7 export-verification driver described in
`reports/export-report.md`; it is not part of the two-preset deliverable.)

`exports/` is gitignored — re-run the commands above to produce a build; see
`reports/export-report.md` for exact commands, sizes, and verification
evidence (macOS release export: boots to the title screen with no errors,
verified in the M7 pass; save/continue/complete outside the editor verified
only on the macOS debug export of the same preset and source, since a
release export cannot run the export-verification driver — the release
build itself was not separately hand-played through save/continue/complete;
Windows: exported and file-type-confirmed, launch itself pending an actual
Windows PC — no Wine on the verifying Mac). **Any export built before
2026-09-30 predates the C33 rebuild, and one built before 2026-09-29 also
predates the revamp.** The old exports were deleted in the 2026-09-30
cleanup, so rebuild with the commands above, and treat the export evidence as
belonging to the pre-revamp build until it is re-run.

- **macOS**: unzip `Sunnyvale.zip` and open `DEAD EDEN - Sunnyvale
  Prototype.app`. The build is unsigned (no Apple Developer ID on this
  project — Godot's own official arm64 template is pre-signed ad-hoc by the
  Godot Foundation, which is only what lets it run on Apple Silicon at all,
  not a publisher signature), so Gatekeeper **may** refuse a plain
  double-click with **"cannot be opened because the developer cannot be
  verified"** (or, since adding the project's `.pck` after that template
  signing breaks its resource seal — confirmed via `spctl -a -vv`, which
  reports `code has no resources but signature indicates they must be
  present` — a stricter Mac could instead say the app **"is damaged and
  can't be opened."** in that harder-to-recover case, delete the `.app` and
  re-unzip a fresh copy from `Sunnyvale.zip` rather than trying to repair in place). If a dialog
  appears: right-click (or Control-click) the `.app` → **Open** → **Open** in
  the confirmation dialog; this is a one-time step per Mac. (The M7
  verification launched the exact same build cleanly with no dialog at
  all, including with a quarantine flag added to simulate a downloaded copy
  — Gatekeeper strictness varies by Mac/OS version/settings, so treat the
  above as "if it complains," not a certainty.)
- **Windows**: unzip if needed and run `Sunnyvale.exe` directly — it is a
  single embedded-PCK executable, nothing else to install. Windows
  SmartScreen may show an "unknown publisher" warning on first run for the
  same reason (unsigned build); choose **More info → Run anyway**.

Saves, settings, and playtest logs from an exported build land in the same
kind of per-OS `user://` location as the editor (see below), keyed by the
project's own name — a Windows build's save directory is **not** shared with
the macOS build, but note that a macOS **debug** export and macOS **release**
export of this same project *do* share one `app_userdata/DEAD EDEN -
Sunnyvale Prototype/` folder (same product name), so a checkpoint saved by
one is visible to the other, exactly like two ordinary launches of the same
build.

## Controls

| Action | Key / button |
| --- | --- |
| Move | A/D or arrow keys |
| Jump | Space / W / Up |
| Fire | Left mouse button |
| Interact (plug in, pick up an evidence file, workbench, station) | E |
| Pause / back out of a dialog / skip a scene | Escape |
| Journal (also opens from the pause menu) | Tab |
| Skip a noninteractive scene (e.g. SC01) | Enter |
| Controls help (title screen, or in-game via the pause menu) | F1 |

Pause (Escape) opens **Resume, Journal, Controls, Settings, Restart from
checkpoint, Quit to title** — gameplay, enemies, timers, and active-play-time
accumulation all stop while it's open (`get_tree().paused`). It only opens
during normal gameplay; it never fights a scene/dialog that already treats
Escape as its own skip/decline (SC01, the workbench, the weapon-swap pad, the
completion screen).

**Controls help**: the title screen has its own "Controls (F1)" button, and
F1 opens it directly from the title screen's main view or, during gameplay,
opens the pause menu straight to its own Controls view (exactly like Tab
opens the Journal). Either way it shows a read-only table of every action's
CURRENT key/mouse binding — read live from Godot's `InputMap`, so it always
matches whatever is actually bound — plus a few short gameplay tips. Escape
or its own Back button returns to whichever screen opened it.

## Saves, settings, and playtest logs

Everything lives under the user data directory (Godot's `user://`):

| Platform | Path |
| --- | --- |
| macOS | `~/Library/Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale Prototype/sunnyvale/` |
| Windows | `%APPDATA%\Godot\app_userdata\DEAD EDEN - Sunnyvale Prototype\sunnyvale\` |

- `checkpoint.json` / `checkpoint.bak.json` — the save and its own backup
  (`CheckpointService`; schema version 3: version 2 added the clearance
  keycard, and version 3 followed the C33 change of every enemy ID, so an
  older save is rejected). New Game (when replacing an existing run) and a
  confirmed "Play again" both clear these.
- `settings.json` — subtitles/text size/reduced-motion/volume, written
  separately from the checkpoint by `Settings` (never rolled back, never
  cleared by New Game/Play again).
- `playtests/run_<timestamp>.jsonl` — one line per logged event
  (`Telemetry`, local-only, never uploaded) for one played run: `run_start`,
  `area_enter`/`area_exit`, `beat_enter`, `branch_enter`/`branch_exit`,
  `encounter_complete`, `checkpoint_commit`, `death`,
  `restart_from_checkpoint`, `pause_start`/`pause_end`, `sc01_start`/
  `sc01_end`, `upgrade_purchase`, `weapon_swap`, `completion`. A run only
  starts logging once New Game/Continue is actually pressed on the title
  screen, OR "Play again" is confirmed on the completion screen
  (`LevelDirector._on_play_again_confirmed()` calls `Telemetry.run_start()`
  directly, the same as a real player's next run) — every test that drives
  either path redirects `Telemetry.set_playtest_dir()` to a throwaway folder
  first (an M7 pass found and fixed two tests that drove "Play again"
  without doing so; see `reports/export-report.md`).

Summarize a log against 07-acceptance-and-playtesting.md's report template:

```sh
python3 tools/summarize_playtest.py "<path to a run_....jsonl>"
```

## Tests

```sh
tools/test.sh              # full suite, 60fps fixed step (about 3 minutes)
tools/test.sh m5           # only cases whose filename contains "m5"
FPS=30 tools/test.sh       # repeat at a 30fps fixed step
NOIMPORT=1 tools/test.sh   # skip the import step (when another process may be importing)
```

Tests never touch a real save or a real playtest log — `tests/run_tests.gd`
redirects `CheckpointService` to one throwaway `user://` folder for the
whole run (reasserted before every case, and checked afterward against
regressions — AUD-01) and cleans it up afterward; `Telemetry` has no such
run-wide redirect, since most cases never touch it at all — each case that
actually starts a real run (`run_start()`) redirects `Telemetry.
set_playtest_dir()` to its own throwaway folder itself, same pattern, before
doing so.

## Enemy lab

`scenes/debug/enemy_lab.tscn` is a lit test strip of the night campus with all
three enemies, lamps, a stone backstop and an annex door. Use it to judge the
art, the tells, the ragdolls and the blood without playing the level. It uses
the real enemy scenes and never touches a real save: saves and play logs go to
`user://enemy_lab_throwaway`.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . res://scenes/debug/enemy_lab.tscn
/Applications/Godot.app/Contents/MacOS/Godot --path . res://scenes/debug/enemy_lab.tscn -- --autoplay
```

The second command plays a scripted tour of all three enemies (used for
captures). Otherwise move and shoot as in the game (A/D, Space, mouse aim, left
click), plus these keys:

| Key | Action |
| --- | --- |
| 1 / 2 / 3 | Spawn a Night Guard / Staffer (it wakes when Dave comes near) / Patrol Rover |
| K | Kill every enemy |
| C | Clear bodies and blood |
| N | Normal maps on/off |
| M | Moonlight on/off |
| B | Blood on/off |
| Z | Zoom |
| T | Slow motion |
| I | Dave invulnerable |
| F1 | Show or hide the help text |
| Esc | Quit |

## Current milestone status

See `../../prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`
for the authoritative, evidence-backed milestone table. Summary of the
pre-revamp build: M0-M6 verified, including a subsequent adversarial-review
pass that found and fixed real bugs across M4/M5 (see 09's own "M4/M5
adversarial review fixes" session log entry) and an M6 integration/verification
pass across the parallel audio, characters, environment, and fx/UI
presentation work (see 09's own "M6 presentation pass — integration and
verification" session log entry, and `reports/asset-inventory.md` for the
full per-asset provenance table and honest remaining production-art gaps).
M7 (validation/export): functional matrix T01-T20 verified, T21 mechanically
verified with its purely visual readability half only partially verified
(M6 captures only — see `reports/functional-matrix.md`'s T21 note), and
completion gates 1-5 verified (`reports/functional-matrix.md`); export: the
macOS release build boots to the title screen with no errors, and
save/continue/complete is verified on the macOS debug export of the same
preset/source (not separately hand-played on the release build); Windows
built and file-type-confirmed but not launch-tested (no Wine on the
verifying host; `reports/export-report.md`). **Playable, timing unverified
— implemented, unverified (gate 6 and T22-Windows/gate 7 pending)**: gate 6
(three+ first-time playtests) and gate 7's Windows launch (T22-Windows, no
Wine on the M7 host) are the two remaining pending items, by explicit
decision — no testers were available, and nothing here substitutes an
estimate for a measured result.

**Revamp (R1, 2026-09-29):** the rebuild to the new story and look is
described in the plan (`06-build-milestones.md` "R1") and its verification
record is 09's 2026-09-29 session-log entry (REVAMP REBUILD). The `reports/` documents use the
revamp vocabulary, but their measurements (test counts, RouteBot traversal
times, export sizes and driver output) were taken on the pre-revamp M7 build
and are labelled as such; nothing in them was re-measured by the revamp
unless it says so. The first-time-player timing gate is still pending.

**Level 1 rebuild (R2, 2026-09-30, C33):** built and tested. The plan's
`06-build-milestones.md` ("R2") describes it and its record is 09's latest
session-log entry. `tools/test.sh` passes 56/56 cases (56 files in
`tests/cases/`). The `reports/` documents now name the Patrol Rover and the
rebuilt placements, but their measurements (M7 test counts, RouteBot traversal
times, export sizes and driver output) are still those of the pre-revamp M7
build and are labelled as such. Not done: first-time playtests (gate 6), the
Windows launch, final painted enemy art and real Mixamo clips.

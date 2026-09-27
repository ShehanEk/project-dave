# M7 export report

## Engine and templates

Engine: **Godot 4.7.2.stable.official.ed1daf0bf**,
`/Applications/Godot.app/Contents/MacOS/Godot`. Host: MacBook Pro, Apple M1
Pro, 16 GB, macOS. No Wine on this host — a produced Windows binary cannot be
launched here (see T22 below).

Export templates: `~/Library/Application Support/Godot/export_templates/4.7.2.stable/`
(`version.txt` = `4.7.2.stable`, and every packaged binary's own version
string reads `4.7.2.stable.official.ed1daf0bf` — matching the editor exactly):
`windows_release_x86_64.exe`, `windows_debug_x86_64.exe` (+ console
variants), `macos.zip` (contains both the `template_release` and
`template_debug` macOS app templates).

## Presets (`export_presets.cfg`, committed — no signing secrets)

Two presets, no `custom_template/*` paths (uses the installed templates
above), `codesign/enable=false`/`codesign/codesign=0` (no Apple Developer ID
on this project — ad-hoc/no signing, correct for local testing):

| Preset | Platform | Architecture | Packaging choice |
| --- | --- | --- | --- |
| `Windows Desktop` | Windows | x86_64 | `binary_format/embed_pck=true` → **single embedded-PCK `.exe`**, nothing else to ship. `debug/export_console_wrapper=1` (a console build was not required by the task, and this flag only controls an *additional* console-wrapper variant Godot can emit alongside the windowed exe — it does not change `Sunnyvale.exe` itself, which is the plain windowed PE32+ GUI binary). |
| `macOS` | macOS | `universal` (arm64 + x86_64 in one binary) | Standard `.app` bundle, zipped by the exporter. |

A third, undeclared-preset **macOS debug** build (below) is produced by
passing `--export-debug "macOS" <path>` — same `macOS` preset, debug
template, custom output path. It exists solely to carry this report's M7
verification driver (`scripts/debug/m7_export_driver.gd`); it is not part of
the two-preset deliverable and is not something a player would ever receive.

## Export commands run (this session, from `prototypes/sunnyvale-godot/`)

```sh
GODOT=/Applications/Godot.app/Contents/MacOS/Godot
"$GODOT" --headless --path . --export-release "Windows Desktop" exports/windows/Sunnyvale.exe
"$GODOT" --headless --path . --export-release "macOS" exports/macos/Sunnyvale.zip
"$GODOT" --headless --path . --export-debug   "macOS" exports/macos-debug/SunnyvaleDebug.zip
```

All three completed with `[ DONE ] savepack` / `[ DONE ] export` and no
errors. `exports/` is gitignored (already covered by the existing
`.gitignore`). Verified syntax for Godot 4.7: `--export-release`/
`--export-debug <preset name> [output path]`, `--headless` required for a
CLI export (no display needed), run from the project directory via `--path .`
or with a working directory already inside it.

**Output sizes** (re-exported after this M7-audit-fix pass added
`exclude_filter="tests/*,scenes/debug/*"` to both presets — AUD-05 — so
these are slightly smaller than the original M7 pass's sizes):

| File | Size |
| --- | --- |
| `exports/windows/Sunnyvale.exe` | 110,418,792 bytes (~105 MB) — `PE32+ executable (GUI) x86-64 (stripped to external PDB), for MS Windows` (`file` confirmed) |
| `exports/macos/Sunnyvale.zip` | 60,526,991 bytes (~58 MB) |
| `exports/macos-debug/SunnyvaleDebug.zip` | 65,201,370 bytes (~62 MB; larger only because the debug template embeds debug/profiling symbols) |

Confirmed via `strings` on the packaged binaries: zero occurrences of
`res://tests/` or `res://scenes/debug/` in either the macOS release `.pck`
or the Windows embedded-PCK `.exe`; `res://scripts/debug/` is still present
(54 matches) since the macOS **debug** export's own verification driver
loads `route_bot.gd` from there.

## Bugs found and fixed during this M7 pass

Verification surfaced three real, reproducible bugs — none in gameplay rules,
tuning, IDs, counts, or collision, so each was fixed directly with a
regression check, per the task's own fix criterion:

1. **Real playtest-log leak into the player's actual save directory**
   (`scripts/telemetry.gd` contract violation). `LevelDirector.
   _on_play_again_confirmed()` (scripts/levels/level_director.gd:434) calls
   the REAL `Telemetry.run_start()` — correct for an actual player's "Play
   again" — but two existing test cases exercise that exact method on a
   directly-built `LevelDirector` (no `Main`, so nobody expected Telemetry to
   be "live") without ever redirecting `Telemetry.set_playtest_dir()` first:
   `tests/cases/test_m5_regress_play_again_hud.gd` and `tests/cases/
   test_m5_story.gd::_test_t20_completion_totals_and_replay()`. Every full
   suite run was silently writing 1-2 real `run_*.jsonl` files into
   `~/Library/Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale
   Prototype/sunnyvale/playtests/` — confirmed by isolating the leak with
   `tools/test.sh` filters and diffing that directory's file count before/
   after each candidate test. Fixed both tests with the same
   redirect-before/`end_run()`+reset-after pattern already used elsewhere in
   the suite (`test_m5_flow.gd`, `test_m5_regress_title_newgame_honesty.gd`),
   and added an explicit assertion in `test_m5_regress_play_again_hud.gd`
   that the real `Telemetry.run_start()` this test triggers lands in the
   test's own throwaway directory. Updated `telemetry.gd`'s own doc comment
   (which incorrectly claimed no test could ever produce a playtest file) to
   name this exception. Re-verified: `tools/test.sh` and `FPS=30 tools/
   test.sh`, run twice each, added **zero** new files to the real
   `playtests/` directory (154 before, 154 after, both fps). The **existing**
   ~150 files already in that directory predate this session (a mix of
   genuine prior play and this same class of bug, including the
   already-documented AD-13 finding) and were **not** deleted — that
   directory is real user data outside this repo and clearing it is the
   user's call, not this pass's. Regression coverage: the new assertion in
   `test_m5_regress_play_again_hud.gd`; the fix in `test_m5_story.gd` guards
   the same code path T20 already exercises.
2. **`m7_export_driver.gd` route-continuation bug** (verification tooling,
   not shipped game code): `_run_continue()` rebuilt its route from area
   index onward but always started at that area's OWN first route point,
   ignoring where the checkpoint respawn marker actually placed the hero —
   discovered live against the exported debug build (Continue resumed at
   CP01 inside A02 at local x=5850, but the bot's first collected point was
   A02's own `R01_Move` at local x=300, sending RouteBot walking *backward*
   into geometry only meant to be crossed forward once, and it got stuck).
   Fixed by dropping every leading route point still behind the hero's
   actual resume x before starting the bot.
3. **`m7_export_driver.gd` GDScript closure bug** (verification tooling): the
   completion-wait loop connected `Session.level_completed` with a lambda
   that reassigned a plain outer `bool` local (`completed = true`) — GDScript
   captures an outer local **by value** in a lambda, so the outer polling
   loop's own copy never actually changed, and the driver deterministically
   reported `FAIL ... never fired` on every real completion even though its
   own log line proved the signal had fired. The equivalent `checkpoint_
   reached` flag in the New Game phase happened to work only because that
   callback calls `get_tree().quit()` directly, before the mismatch could
   ever be observed. Fixed both by boxing the flag in a one-element `Array`
   (the same idiom `tests/cases/test_m5_flow.gd` already documents and uses
   for the identical reason), which a closure DOES share with its enclosing
   scope.

`tools/test.sh` and `FPS=30 tools/test.sh` (full suite, after all three
fixes): **40/40 cases passed**, both fps, run from a fresh import. No
gameplay/tuning/collision code was touched by any of the fixes above.

## Outside-editor verification (macOS; Windows launch not possible on this host)

**Driver mechanism** (see `scripts/main.gd` `_maybe_start_m7_export_driver()`/
`_maybe_redirect_m7_save_dir()` and `scripts/debug/m7_export_driver.gd`):
active only when **both** `OS.is_debug_build()` is true (always false for a
`--export-release` build, regardless of arguments — confirmed: the release
build ignores these flags entirely and just shows an ordinary title screen)
**and** the exact `--m7-phase=<newgame|continue>` argument is present. An
optional `--m7-save-dir=user://<path>` redirects `CheckpointService`/
`Telemetry` to a throwaway folder before the title screen's own first
`has_valid_save()` read, so the exported app's real default save location is
never touched. The driver drives the REAL game through real UI signal calls
(`NewGameButton.pressed.emit()`, etc.) and the existing debug `RouteBot`
(named-action input only, same as every other automated route in this
project) — never calls `Session`/`CheckpointService` directly.

**Command-line gotcha worth recording**: on this exported binary,
`OS.get_cmdline_user_args()` only returns arguments placed **after a literal
`--`**; passed without it, they land in `OS.get_cmdline_args()` but
`get_cmdline_user_args()` returns empty and the whole driver silently never
activates (confirmed by adding a temporary diagnostic print, reverted after
diagnosis). Every command below uses the required form.

### Verified sequence (macOS debug export, `exports/macos-debug/`)

```sh
cd exports/macos-debug && ditto -x -k SunnyvaleDebug.zip extracted
cd extracted
APP="DEAD EDEN - Sunnyvale Prototype.app/Contents/MacOS/DEAD EDEN - Sunnyvale Prototype"

# (a)/(b): New Game -> real checkpoint save, throwaway location
"./$APP" -- --m7-phase=newgame --m7-save-dir=user://m7_final/run3

# (c)/(d): Continue -> resumes the save -> drives to real completion
"./$APP" -- --m7-phase=continue --m7-save-dir=user://m7_final/run3
```

New Game run output:
```
DEAD EDEN Sunnyvale prototype booted on Godot 4.7.2-stable (official)
[M7DRIVER] starting phase=newgame
[M7DRIVER] title screen found — clicking New Game
[M7DRIVER] post-new-game checkpoint_id=CP00 objective=Find the maintenance depot. health=6 wallet=0 gems_found=0
[M7DRIVER] starting RouteBot toward the first checkpoint
[M7DRIVER] checkpoint_committed id=CP01 — real save written
[M7DRIVER] post-checkpoint checkpoint_id=CP01 objective=Find the maintenance depot. health=6 wallet=15 gems_found=15
```
(exit code 0; confirmed on disk: `~/Library/Application Support/Godot/
app_userdata/DEAD EDEN - Sunnyvale Prototype/m7_final/run3/checkpoint.json`,
a real, valid checkpoint snapshot, checkpoint_id `CP01` — proves (b).)

Continue run output:
```
DEAD EDEN Sunnyvale prototype booted on Godot 4.7.2-stable (official)
[M7DRIVER] starting phase=continue
[M7DRIVER] title screen found — clicking Continue
[M7DRIVER] post-continue checkpoint_id=CP01 objective=Find the maintenance depot. health=6 wallet=15 gems_found=15
[M7DRIVER] resumed at CP01 (area index 1) — driving to the end
[M7DRIVER] Session.level_completed fired
[M7DRIVER] completion screen present=true
[M7DRIVER] post-completion checkpoint_id=CP05 objective=Sunnyvale complete. health=6 wallet=45 gems_found=45
[M7DRIVER] DONE ok
```
(exit code 0 — proves (c) Continue restores the exported app's own save, and
(d) the run completes to the real completion screen outside the editor,
CP05 committed, wallet/gems_found=45 matching the main-route total.)

**Real save location untouched**: before/after every run above, `~/Library/
Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale Prototype/
sunnyvale/` contained no `checkpoint.json`/`checkpoint.bak.json` (only the
pre-existing `playtests/` directory, itself covered by finding #1 above and
now frozen at a stable file count). All automation used the
`--m7-save-dir=user://m7_final/run3` throwaway path instead. That throwaway
data (under `app_userdata/.../m7_final/`) was left in place — it is clearly
namespaced and harmless, and this session's earlier destructive-cleanup
attempt on the (unrelated) real `sunnyvale/` directory was correctly refused
by the sandbox; the person can delete `m7_final/` themselves if they want to.

### (a) Release build boots cleanly, no errors

```sh
cd exports/macos/extracted
stdbuf -o0 "./DEAD EDEN - Sunnyvale Prototype.app/Contents/MacOS/DEAD EDEN - Sunnyvale Prototype"
```
Output: `Godot Engine v4.7.2.stable.official.ed1daf0bf`, `OpenGL API 4.1
Metal - 91.7 - Compatibility - Using Device: Apple - Apple M1 Pro`, `DEAD EDEN
Sunnyvale prototype booted on Godot 4.7.2-stable (official)` — no `ERROR:`/
`WARNING:` lines, process stayed alive and responsive (title screen) for the
full observation window, no crash report under `~/Library/Logs/
DiagnosticReports`. (Note: without `stdbuf -o0`, this release binary's stdout
is fully block-buffered when redirected to a file/pipe and nothing appears
until a clean engine exit flushes it — a libc buffering artifact, not a
release-build defect; the debug template happens to flush per-line. Recorded
here so a future run doesn't misread silence as a hang.)

### T22 matrix row

| ID | Scenario | Result |
| --- | --- | --- |
| T22-macOS | Local macOS export launches, saves, continues, completes outside the editor | **verified**, with a release/debug split: the macOS **release** export launches cleanly to the title screen (see "(a)" below); save/continue/complete is verified via the driver sequence above run against the macOS **debug** export of the same preset/source, not the release build |
| T22-Windows | Local Windows export launches, saves, continues, completes outside the editor | **pending** — this Mac has no Wine, so `exports/windows/Sunnyvale.exe` cannot be launched here. Exact steps for a Windows PC: (1) copy `exports/windows/Sunnyvale.exe` over (single embedded-PCK file, nothing else needed); (2) double-click to run — if SmartScreen shows "unknown publisher" (unsigned build), choose **More info → Run anyway**; (3) **New Game**, play to the first recovery station (A02/A03) to commit a checkpoint; (4) quit, relaunch, **Continue**, confirm it resumes at that checkpoint; (5) play to the A06 exit wicket and confirm the completion screen; (6) checkpoint/save file lands at `%APPDATA%\Godot\app_userdata\DEAD EDEN - Sunnyvale Prototype\sunnyvale\checkpoint.json`. |

## macOS Gatekeeper / code-signing notes

`codesign/enable=false` in the preset means *we* apply no signature — but
Godot's own official arm64 export template ships **pre-signed ad-hoc** by
the Godot Foundation (`codesign -dv` on the exported `.app`:
`Identifier=godot.macos.template_release.arm64` /
`...template_debug.arm64`, `TeamIdentifier=6K46PWY5DM`), which is required
for any arm64 binary to run on Apple Silicon at all, signed or not.
Appending the project's own `.pck` after that signing invalidates the
template's resource seal: `spctl -a -vv` on the exported `.app` reports
`code has no resources but signature indicates they must be present`, on
both an unquarantined copy and one with a simulated
`com.apple.quarantine` xattr added. Despite that assessment failure, `open`
(LaunchServices, i.e. an ordinary double-click) launched the app
successfully in both cases on this Mac with no Gatekeeper dialog at all —
Gatekeeper enforcement can differ by machine/OS-version/settings, so the
existing README guidance (right-click → **Open** → **Open** if a dialog
*does* appear) is kept as the correct general fallback; this session simply
did not encounter that dialog. This is expected, ordinary behavior for any
unsigned/ad-hoc Godot export, not specific to this project.

## Status against 07's completion gates 6-7

- Gate 6 (measured first-playthrough timing): **pending**, per the explicit
  user decision recorded in the task brief — no first-time testers available
  this session. Nothing in this report substitutes an estimate for a
  measured result; RouteBot's own wall-clock times (automation running at
  maximum named-action input speed, not human pacing) are not, and must
  never be read as, a playtest measurement.
- Gate 7 (Windows test export launches and matches the verified editor
  route): **partially verified** — the macOS **release** export (what a
  player receives) is verified to boot cleanly to the title screen with no
  errors (see "(a) Release build boots cleanly" above); save/continue/
  complete (matching the editor route already proven by `tests/cases/
  test_m5_story.gd::_test_t18_zero_upgrade_finish()` and the M7 functional
  matrix) is verified only on the macOS **debug** export of the same preset
  and source, via the driver sequence above — the release and debug
  templates are different binaries, and the release .app was not separately
  hand-played through save/continue/complete. The Windows export is built,
  sized, and file-type-confirmed, but **T22-Windows itself is pending** —
  this host has no Wine and cannot launch it. See the exact steps above for
  whoever runs it on a real Windows PC.

**Overall M7 status**: playable, timing unverified (gate 6 pending by
explicit decision) and Windows launch unverified on this host (gate 7
partial — macOS release export boots verified, save/continue/complete
verified on the macOS debug export only, Windows pending exact-steps-
provided). See `reports/functional-matrix.md` for gates 1-5 and
T01-T20 (T21 mechanically verified, visual readability half partially
verified).

## Audit-fix pass (2026-09-27, post-export review)

An independent audit of this M7 pass found and this pass fixed three real
bugs, none touching gameplay rules/tuning/IDs/collision:

1. **AUD-01 (critical, save-data hygiene):** `tests/cases/test_m6_ui.gd`
   ended its `run()` by calling
   `CheckpointService.set_save_dir(CheckpointService.DEFAULT_SAVE_DIR)`
   instead of restoring the dir it found on entry — since `test_m6_ui.gd`
   sorts before every `test_m7_*.gd` case, every full-suite run left
   `CheckpointService` pointed at the REAL default save dir for the rest of
   the run, so `tests/run_tests.gd`'s own per-case and final `clear()` calls
   deleted a real `checkpoint.json`/`checkpoint.bak.json` on this machine,
   directly contradicting README.md/CONVENTIONS.md's "tests never touch a
   real save" guarantee. Fixed `test_m6_ui.gd` to save/restore the runner's
   own dir; hardened `tests/run_tests.gd` to reassert the throwaway dir
   before every case, fail any case that leaves it pointed elsewhere, and
   fingerprint the real save dir's `checkpoint.json`/`checkpoint.bak.json`
   modified-times before and after the whole run, failing the run if either
   changed. Re-verified: `tools/test.sh`/`FPS=30 tools/test.sh` both
   **40/40 cases passed**; a 40-second, 20ms-interval poll of the real save
   dir throughout a full-suite run found no `checkpoint*.json` appear at any
   point (previously it appeared there hundreds of times per run).
2. **AUD-06 (minor, verification-tooling hygiene):** `scripts/main.gd`'s
   `_maybe_start_m7_export_driver()` started the M7 export-verification
   driver on `--m7-phase=<phase>` alone, while
   `_maybe_redirect_m7_save_dir()` silently no-op'd whenever
   `--m7-save-dir` was left off — so a debug-export launch with only
   `--m7-phase=newgame` would press New Game against the exported app's own
   REAL default save dir. Fixed: whenever `--m7-phase` is present at all,
   the save dir is now always redirected (to the explicit `--m7-save-dir`
   if given, else a fresh `user://m7_throwaway/<ticks>`), plus a
   defense-in-depth check in the driver-start path that refuses to start if
   `CheckpointService` is ever still pointed at `DEFAULT_SAVE_DIR`. Confirmed
   inert in the release export before and after (no `[M7DRIVER]` output,
   real save dir untouched). Reproduced the original bug scenario against
   the freshly rebuilt macOS debug export (`--m7-phase=newgame` with no
   `--m7-save-dir`): New Game ran and committed a checkpoint under the new
   `user://m7_throwaway/...` path, the real `sunnyvale/` dir was confirmed
   untouched throughout.
3. **AUD-05 (minor, package hygiene):** both presets exported
   `res://tests/*` and `res://scenes/debug/*` into the shipped package
   (confirmed unreachable by a player, but still shipped). Added
   `exclude_filter="tests/*,scenes/debug/*"` to both presets (kept
   `scripts/debug/*`, which the macOS debug export's own verification driver
   loads `route_bot.gd` from). Re-exported all three artifacts; confirmed via
   `strings` that the release `.pck`/embedded-PCK `.exe` now contain zero
   `res://tests/` or `res://scenes/debug/` paths while `res://scripts/debug/`
   is still present (54 matches).

All three fixes were re-verified end to end after re-exporting: full test
suite 40/40 at both fixed-fps settings; the macOS release `.app` still boots
cleanly to the title screen with no `ERROR:`/`WARNING:` lines; the macOS
debug export's driver sequence (New Game -> real checkpoint save -> Continue
-> real completion, `Session.level_completed` fired, CP05 committed,
`gems_found=45`) still passes end to end with the real save dir confirmed
untouched throughout, using a fresh explicit throwaway dir
(`user://m7_reverify/run1`, removed after verification).

# 10 — Lessons and workflow

What building the Level 1 prototype (Eon City, `prototypes/sunnyvale-godot/`) taught us, and the working loop that turned out to work. Written 2026-10-09 after the C48–C53 passes, at the user's request ("store all the lessons you learned from prototype, and also store the workflow"). Use it before starting Level 2 or any new pass. Details and evidence for each pass stay in [09 — Progress and handoff](09-progress-and-handoff.md) and the [decision register](../../design/decisions.md).

## 1. The working loop

Every change, small or large, goes through the same steps.

1. **Read before building.** Read the code that owns the behaviour and the design doc that owns the rule (decisions, story scenes, area blueprints, CONVENTIONS.md). Build inside the existing systems: the user's rule is that everything stays within the Godot project, using its scenes, scripts and assets, with no outside tools and no new generated assets unless asked.
2. **Make the smallest change that does the job.** Tuning lives in `data/tuning/*.tres`; numbers shown to the player are read from the same tuning, never copied.
3. **Test in layers.**
   - One area or feature: `tools/test.sh <filter>` (for example `tools/test.sh c53`).
   - Then the full suite: `tools/test.sh` (headless, fixed fps, a throwaway save dir; it must end `RESULT: N/N cases passed` with no `SCRIPT ERROR` lines).
   - Every pass adds its own test file named after its decision (`test_c50_aim_steps.gd`, `test_c52_quickcycle.gd`, `test_c53_fun_pass.gd`) with a header that lists the contracts it checks.
4. **Look at it.** For UI or visuals, make a tiny capture demo under `scenes/debug/` and run `tools/capture.sh res://scenes/debug/<demo>.tscn <scratch dir> <frames> 30`, then read a few frames. Several layout problems (empty space, overflowing text, a dimmed offer) were only visible this way.
5. **Test the exported build.** Export the macOS debug preset to a scratch folder and run the M7 driver twice: `-- --m7-phase=newgame --m7-save-dir=user://<throwaway>` then `--m7-phase=continue`, expecting `[M7DRIVER] DONE ok`. Never use the real save dir.
6. **Relaunch the game for the user** (`Godot --path .` from the project folder) so they can play the change straight away.
7. **Report short and honest:** what changed in player terms, what was tested, what was not (nobody has playtested; sound not heard; Windows not run), and any deviation from what was proposed.
8. **Record it.** A C-number in the decision register for anything the user confirmed, a dated entry in 09 (files, constants, tests, verification), and edits to the owning docs (gameplay systems tables, spec JSON, story scenes).
9. **Commit only when the user says "commit".** Check `git diff --cached --name-only` first (earlier staged deletions ride along otherwise), keep GPG signing on, end the message with the attribution line. **Push only on "push"**: `git -c http.postBuffer=524288000 push origin sunnyvale-godot-prototype`.

### Generated assets (art and audio)

ElevenLabs (audio, voices, gpt-image-2 images) is used **only when the user asks**. When asked: estimate first, at most 4 generations per call and about 12 s between calls, every download approved by the user, signed URLs never printed. Raw results are stored first (`audio-source/elevenlabs/batchN/`, `concept-art/...`) and only processed into the game when the user says "process" (`tools/process_elevenlabs.py`, which writes `scripts/audio/eleven_manifest.gd`). The user picks voices and takes by ear; Claude cannot hear audio. Notes: [ElevenLabs audio brief](../../design/05-presentation/elevenlabs-audio-brief.md).

### Reviews ("adversarially review", "find what's wrong")

1. Split the review by lens and run read-only reviewers in parallel: combat and enemies, level flow and pacing, movement and game feel, rewards, story and clarity. Routine reviewers run on a cheaper model.
2. Check the strongest claims against the code before reporting (reviewers repeat stale numbers from old reports).
3. Give the user a short ranked list, a suggested first batch of small changes, the bigger ideas for later, and what to leave alone (for example: the user liked the Quickcycle, so fights got harder instead of the gun getting slower).
4. Build the batch the user picks as one decision (C53) with one test file.

### Keeping a feature for later

When a mechanic confuses players now but is wanted later (the weapon swap pad, C51): remove only its placement, keep the code, art and tests (tests place it at run time), and write a guide with the exact removed nodes and the steps to reuse it ([swap pad for Level 2](../../level-design/swap-pad-for-level-2.md)).

### Sharing a build with friends

- **Mac:** export the `macOS` preset with `--export-release`, unzip, rename the bundle to `DEAD EDEN - Eon City.app` (do not rename `config/name`: it names the save folder), ad-hoc sign it (`codesign --force --deep -s -`), zip with `ditto -c -k --keepParent`, and add a `HOW TO PLAY.txt` (controls and the Gatekeeper "Open Anyway" step). Universal binary, Apple Silicon and Intel.
- **Windows:** export the `Windows Desktop` preset with `--export-release` (one .exe with the game data embedded), zip it with a `HOW TO PLAY.txt` (extract first; SmartScreen: "More info", then "Run anyway"). The renderer is `gl_compatibility`, so OpenGL 3.3 is enough.
- **Testing a build Claude cannot run:** release builds switch the M7 driver off (`OS.is_debug_build()`), so test the debug export, or load the release game data with the Mac editor binary: `Godot --main-pack "<game>.exe" -- --m7-phase=newgame --m7-save-dir=user://<throwaway>`.
- Builds go in `exports/` (git-ignored). Files over 30 MB cannot be sent to the user's phone; the user shares them (Drive, Dropbox, WeTransfer).

## 2. What works and what does not

We learn along the way: after every pass, add a line to the [log](#6-learning-log) below, and move anything that keeps coming back into these lists.

### Works

| Practice | Why it works |
| --- | --- |
| One pass = one decision number + one test file | Easy to review, commit and roll back; the test header states the contracts |
| The user plays after every change (game relaunched for them) | Short real feedback ("staff voice is too low", "no difference after upgrade", "feels good") beats any estimate |
| Asking only real choices, with a recommended option and previews | The user decided aim style and upgrade size in one click each |
| Capture demos for UI, read frame by frame | Found empty space, overflowing text and a dimmed offer before the user saw them |
| Exported-build check on every pass | Catches files that work in the editor but are missing from an export |
| Parallel reviewers by lens, then checking their claims | Wide coverage fast; checking removed stale or wrong numbers |
| Store generated assets first, process on "process" | The user picks by ear and eye; nothing half-finished reaches the game |
| Keep a removed feature with a guide | The swap pad is ready for Level 2 without blocking Level 1 |
| Short reports that say what was not tested | The user knows what still needs their ears and eyes |

### Does not work

| What happened | Do instead |
| --- | --- |
| Strict 8-direction aim shipped first, made 5 of 6 Rovers unkillable | Run the full suite (and the route bot) before showing a visual change; separate how it looks from where shots go |
| Guessing what a short message means ("p1 and p2" read as decision ids) | Look at what the player sees on screen first; ask with the visible thing named |
| Trusting delegated output as-is (stale report numbers, a side session on an older branch) | Check the key numbers and the base branch before reporting or merging |
| A test that crashed halfway still "passed" | Read the suite output for `SCRIPT ERROR`; fix the runner (in progress) |
| Placing a long jump by feel, then iterating on bot failures | Work out the gap from the jump numbers (section 4) before editing the scene |
| Proposing lines for a character without checking the story | Read story-scenes.md before adding any dialogue |
| Spending generation credits fast (free tier ran out, account flagged) | Estimate first, small batches, only when asked |
| One huge handoff file (09 is over 2,500 lines) | Keep this short file for the rules; 09 keeps the evidence |
| Partial renames (the folder, branch and save folder still say Sunnyvale) | Rename the player-facing name only and record what stays, and why |
| A broad `rm -rf` on a relative glob (blocked by the safety check) | Write to a fresh folder or overwrite the file; remove only exact paths |

## 3. Design lessons: what made it more fun

1. **A number that looks fine on paper can be invisible in play.** The Quickcycle at 0.32 s to 0.24 s was "no difference". At 0.18 s (+78%) with feedback on every channel (a higher shot sound, a brighter teal muzzle light, a bigger flash, a spinning glowing flywheel, a toast) it "feels good". Make an upgrade at least about 1.7x and show it in sound, light, motion and text.
2. **Show numbers the way players think.** Shots per second on two bars, not an interval in seconds; what the chips buy ("enough for one of them. Choose."), not just a price.
3. **Enemies must be able to reach you.** Compare the time to kill with the approach time: a Guard noticed at 520 px walking 1 H/s needs about 5 s to arrive and dies in 0.64 s, so it was a walking target. Close the gap with approach speed, notice range and recovery, not with health.
4. **One attack token makes a mixed group a queue of duels.** Let mixed groups attack two at a time.
5. **Damage taken must land harder than damage dealt,** and a death needs a beat (hold, fade, reset behind black) so the player sees what killed them. Warn at low health.
6. **Free failure and identical jumps give no tension.** Vary the jumps (stepping stone, long jump, drop) and give some gaps a real cost (a pit with a reset). Put chips on the jump arcs so they teach the line.
7. **One purchase plus enough chips is not a choice.** Price two items so the main route buys one and exploring buys both (Quickcycle 40 plus Scrap Plating 25 against 45 on the route and a 20-chip cache).
8. **Collectibles and endings need a payoff.** A file the player can read, a rank and a best run to beat, and a line that points to the next level.
9. **Respect the story canon when adding lines.** Adam's first words belong to SC01, so the route lines went to the Security PA. Check [story scenes](../../design/05-presentation/story-scenes.md) first.
10. **Confusing leftovers hurt.** "P01" and "P02" on two identical guns read as a mystery: remove what has no purpose yet.
11. **Visual fidelity must not cost hits.** Snapping the arm to strict 8 directions made 5 of 6 Patrol Rovers unkillable; the fix kept the pose in 22.5-degree steps but fired exactly where the player aims (C50).
12. **Players need the premise.** A short narrated comic (SC00) before New Game, third person, skippable.

## 4. Technical lessons (Godot and this project)

- **A runtime error does not fail a test case by itself.** `await case.run()` returns normally after a script error, so `test_pixel_layers` stopped halfway for a day after the pad removal and still passed. Look for `SCRIPT ERROR` in the suite output (a runner fix is in progress in a side session, 2026-10-09).
- **A `##` comment between a `[node]` header and its first property in a hand-edited `.tscn` silently drops that property.** Put comments elsewhere.
- **GDScript lambdas capture locals by value.** Count in a one-element Array (`var box := [0]`, `box[0] += 1`).
- **`OS.get_cmdline_user_args()` only sees arguments after a literal `--`.**
- **Test switches:** the runner turns off `GameFeel.hit_pause_enabled` and `LevelDirector.death_beat_enabled` so frame-counted timings stay exact; a test that needs them turns them on and off itself.
- **Route bot rules:** the main route's jump gaps must stay at or under 192 px (2 H; `test_m3_regress_route`). A changed gap or ledge needs its `Route` markers (`hold_jump`, positions) moved too, and chips placed where the bot's own jump passes, or the area test reports a missed chip.
- **Jump numbers for level geometry:** apex about 154 px (1.6 H) after 0.42 s; a running jump covers about 300 px on the level and about 250 px when landing 80 px higher; the hero runs 384 px/s.
- **Enemy rules from the design:** every windup warns for at least 0.6 s (T04); the Rover's armor hint shows on the first blocked shot (C53).
- **Saves are whitelisted.** New state goes through `CheckpointService.validate_snapshot()` (the A01 plating upgrade, the health range), and older saves without the new key must still load. Never write the real save dir from tests or demos.
- **`config/name` names the `user://` save folder;** renaming it orphans saves. Rename the exported bundle instead.
- **Signal order matters for toasts.** A purchase emits `upgrade_purchased` and then `checkpoint_committed`; later toasts replace earlier ones, so the HUD remembers the pending upgrade and announces it in place of "Progress saved".
- **UI built in code** (`intro_comic.gd`, `evidence_reader.gd`) uses the shared theme `assets/ui/c11_theme.tres`, joins a group so tests can find it, and polls input edges in `_physics_process` (tests drive input with `Input.action_press()`, which sends no events). A key held when a modal opens must be released before it can close it.
- **Release builds strip debug drivers** (`OS.is_debug_build()`), and unsigned Mac exports show a broken resource seal; ad-hoc signing lets them open.
- **Reports go stale.** `reports/pacing-risk.md` still lists old enemy counts and bot times; measure again before trusting a number.

## 5. Process lessons

- The user wants short, plain answers, and decides on commits, pushes, downloads and spending (credits, paid plans).
- Ask only when the answer changes what gets built (aim style, upgrade size); otherwise pick the sensible default and say so.
- Delegated work is not proof: check a reviewer's numbers and a side session's base branch before trusting or merging (one side session tested against an older suite of 56 cases instead of 81).
- All human characters have Caucasian skin tones (C43), in prompts and briefs.
- Every generated art sheet is stored first and integrated only when the user says so.

## 6. Learning log

Add one row per pass: date, decision, what worked, what did not. Newest at the bottom.

| Date | Pass | Worked | Did not |
| --- | --- | --- | --- |
| 2026-10-08 | C47 ElevenLabs audio | Store first, process on request; the user picked voices by ear | Credits ran out on the free tier; mix levels set by table, never heard in play |
| 2026-10-08 | Staffer voice redo | A new "more human, scared" voice, then +6 dB after "too low" | The first voice and level were wrong; only playing it showed that |
| 2026-10-08 | C48 rename to Eon City | Several name rounds until the user picked | Paths, branch and save folder still say Sunnyvale |
| 2026-10-08 | C49 intro comic and narration | gpt-image-2 panels at medium quality; captions paced to the voice | — |
| 2026-10-08 | C50 aim steps | Asking with previews; 16-step pose with exact shots | Strict 8 directions broke the Rover fights |
| 2026-10-08 | C51 swap pad out of Level 1 | Removed placement only, guide written for Level 2 | Misread "p1 and p2" at first |
| 2026-10-08 | C52 Quickcycle and workbench | Big change plus feedback on every channel; capture demo for the menu | The 0.24 s version was never felt in play |
| 2026-10-09 | Shareable builds | Mac (signed ad hoc) and Windows zips with how-to notes; Windows data tested with `--main-pack` | The Windows .exe itself has not been run on Windows |
| 2026-10-09 | C53 fun pass, first batch | Lens reviewers plus checking; tests and export green | The long roof jump needed two tries; a C51 test had been passing while broken |

[Prototype plan index](README.md) · [Decision register](../../design/decisions.md)

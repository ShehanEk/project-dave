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
- **Lit characters can clip to white under a close lamp.** Light from several sources adds up (lamp, moonlight, glow). `lit_part.gdshader` has a soft limit per light (`knee_start`, `knee_soft`); Dave and the Patrol Rover (pale shell) use a lower one, Dave also little shine (`hero_rig_visual.gd`, `patrol_rover.gd`). `enemy_lamp_demo.tscn` puts every enemy under a lamp for checking. Check a new character standing under a lamp before calling its lighting done.
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
| 2026-10-10 | Dave under street lamps | A still capture demo (`lamp_light_demo.tscn`) and measured pixel values showed the clip; fixed in two tries | First guess (one soft limit for everyone) was not enough: moonlight and the lamp glow add on top, and his hair had leather-like gloss in its shine map |
| 2026-10-11 | C54 story props painted | Prompt written first and the user chose who generates; a cost estimate before the paid call; measuring the sheet (colour key, piece sizes, pixel size) before importing; a capture beside Dave to judge scale | The model drew a 1:1 table where the prompt asked 36 x 23, so the old size had to be restored per piece; no style reference made the pixels finer than the campus, so the photo's figures blurred; a lamp over the props clipped them until they were tinted down |
| 2026-10-11 | C55 pre-rendered look test | A copy of the prototype so the look test touches no gameplay; Blender scripts, not hand modelling; reusing the rig's clips for the 3D guard (timings already tuned); environment renders at the pixel pieces' exact layout so no level code changed; a quick 4-frame render before each full one; in-game captures after every change | The first normals came out with z flipped (Cycles' camera space looks down +Z); renders started half as bright as the pixel art until measured against its medians; one-sided window texture mapping gave stripes; a base-class switch silently changed `gun_hold()` and only the new grip test caught it |
| 2026-10-11 | C55 verdict | The pipeline itself worked (renders, lighting, gameplay intact) | The user: "this looks really bad". Programmer-built blockout models (rounded boxes) cannot stand in for a style; a look test needs art of near-final quality, or one hand-finished still, before any engine work. Show a single frame first, then build |
| 2026-10-11 | Art direction settled | Asking what the user disliked led to the real issue (pixel art looking low-res on 4K), which has cheaper fixes than a new style | A whole look-test prototype was built before checking one still; deleted the same day |
| 2026-10-11 | C56 hand-painted import | A style frame approved first, then every sheet generated with it attached and checked one by one (the photoreal guard caught and redrawn in Dave's style before the variants copied it); reusing the rigs and skins so the import was art plumbing, not new systems; measuring each sheet (part boxes, assembled previews) before wiring | Generated parts don't share one scale (the gun's loose parts were up to 15% off its assembled view, so it was cut from the assembled one); the HD lamp's arm moved its lens off the pole, which a test caught; the busy painted offices needed dimming before the fight read |
| 2026-10-11 | HD Dave sizing | Bisecting the two changes (height, gun length) against the failing test found the cause in two runs; a trace of the hero and rover showed the point-blank stall shots | The aim pivot follows the hero rig's shoulder and the muzzle follows the gun rig, so resizing art moved gameplay; widening (not scaling up) fixed "small and skinny" without touching it |
| 2026-10-11 | Hand-painted batch 2 | Asking for one sheet at a time and measuring each on arrival (boxes, lit edges, glow colours) made the import mostly mechanical; a full-level capture tour found the real problems; re-laying pieces out at the painting's own proportions instead of squeezing them into the pixel layouts | Generated parts aren't one scale (the rover's wheel 1.45x its arches) and template matching failed on overlapped parts, so they were placed by hand on a grid; the first detail pass read the already-overwritten sizes; every hard-coded art-px constant in the object scripts had to be found and moved |
| 2026-10-11 | Hand-painted batch 3 (UI, effects, font) | Handing out the painted piece as a texture that reports the pixel piece's size (ImageTexture size override, tested first in a 3-frame capture) kept every UI layout and caller unchanged; reading glyphs from the TTF's own atlas lettered the key caps without a viewport; comparing the two prototypes side by side answered "why does pixel look better" with evidence | One combined sheet put about 50 pieces on one image, so the frames came out small; mipmaps were expected to fix the painted noise and barely did (the busyness is in the paintings, not the sampling) |
| 2026-10-11 | C57 hero, enemies, hit boxes | Tracing the "sleepy" look to its source words in the prompts and briefs (and to C22, which the prompts contradicted); a probe that measures each painted outline against every collision shape found the one real mismatch (the rover) instead of guessing; rendering poses side by side on a plain background to judge motion | Reading gameplay frames to judge animation (tracking by colour caught the orange chevrons); the first idea, a body lift on the Staffer walk, broke a test that was right (a walk always has a foot down) |
| 2026-10-12 | C57 gun, feet, sizes | Rendering the same nine aim steps in both prototypes side by side showed what "pixel gun angles are good" meant (a bent elbow, the gun at the chest); measuring the muzzle distance before changing the gun; a lineup of every asset next to Dave made the size check concrete; finding the floating feet in the floor art (the lit lip 3 px under the floor line), not in the rig | I scaled the gun up to look "chunkier" before checking with the user, who then said it was already too large: ask or compare with their reference first |
| 2026-10-12 | C58 art direction review | Reviewing every source sheet and an in-game capture of all six areas side by side, then sorting assets into replace, tweak and keep; ranking by how much of the screen each asset covers (the walkway and roofs are on screen all the time); checking the request against standing colour rules (pink neon would clash with the Rover's C36 colour) and asking the two real choices before writing the prompt | C57 fixed only the words "stone" and "brick" and kept "trees and planted roof gardens", so the art still read medieval: when the user names a feel, list every asset that breaks it, not only the one they mention |
| 2026-10-12 | C58 rain and glow | Testing the renderer's limits with a ten-line scratch scene before designing (screen mipmaps work in Compatibility, the built-in 2D glow barely shows); exaggerating the glow (strength 4) to see what it keys; before and after captures of the same view; a headless probe that counted live splashes and printed their positions | Keying the glow on already-blurred colours: thin neon lost its halo and big windows got it, fixed by a difference of blurs; the indoor mask computed in the parallax-shifted coordinates let rain fall in the depot (caught only by capturing the depot); a capture camera that differs from the game camera put the splashes off screen, so judge splashes at the game camera |
| 2026-10-12 | C58 Batch 5 process | Two parallel subagents split by file (characters, environment) with only one allowed to run Godot, so the import cache never clashed; a tarball backup before any overwrite; isolating a test failure by restoring one value at a time (the rover's old size passed, then the eye height alone explained it); tracing the bot run tick by tick instead of guessing | Deriving gameplay numbers (the rover's sight line) from art size: the new art changed the encounter timing, so tuned gameplay values now stay fixed constants; a test that does not reset input between sub-runs failed only when an earlier run's timing changed |
| 2026-10-12 | C58 Batch 6 (last plants) | Keeping each prop's role (the pool's teal underlight, the flower's teal pods) so the scenery code needed no change; importing only the two changed props and confirming every other props.json entry came out identical; capturing each placement in game | A replaced prop can be hidden by a neighbour that was designed to go with the old art (the flower sat inside its planter, and the barrier block that replaced the planter covered it): check each placement after a swap, not just the sheet |
| 2026-10-12 | C59–C61 Level 2 design, the move, M1 | Reading the owning docs (start guide, concept, the old L2 brief, the enemy briefs) before designing, so the new level kept every campaign obligation (weapon, three enemy introductions, first gun, exit); one compact proposal plus four multiple-choice questions got four quick decisions; a git tag before removing the pixel prototype, and untracked leftovers moved, not deleted; splitting work by file ownership (two doc agents, then one code agent alone on the save system) | Writing a spec detail from memory (the Peacekeeper's lime) instead of applying the rule I had just written (magenta for machines Adam drives): check each table row against the rule; two helpers on one file (CONVENTIONS.md) needed a coordination message |
| 2026-10-13 | Level 2 build (M2–M4, Batch 7) | Parallel builders split by file ownership with a told-in-advance hand-off (part names for the painted sheets sent before the placeholder rigs were made, so the art dropped in without code changes); one combined prompt for 13 sheets; fair-fight tests that play each encounter as a player would; checking captures after every art import | Inheriting state across levels changed the look (Level 1's lockdown tint washed the lab pink); a size kept from a placeholder (the drone's 54 px) made the painted drone a speck — judge new art at game scale before keeping old numbers; a probe that `load()`s a level resource from a pack path with a space hung, so probes use file checks with a timeout |
| 2026-10-13 | Level 2 story beats (M5) | Story as data on the LevelDef (lines keyed by the beats the level already had, so no new triggers and the route test's beat count held); new story state as story flags that roll back with a death; a capture demo that jumps between the beats, which showed lines queueing and playing an area late | A queue that waits its turn plays lines long after their place when the player moves fast — a new scene now cuts the old one short; a pack probe run with `-s` has no autoloads, so every script using `Session` fails to compile there — check those in the exported app itself (`--level=L02` with a throwaway save) |

[Prototype plan index](README.md) · [Decision register](../../design/decisions.md)

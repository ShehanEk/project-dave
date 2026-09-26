# 07 — Acceptance and playtesting

**Approved visual direction (C11):** [Hand-drawn 2D](../../art-design/style-guide.md). [Selected references](../../concept-art/l01-sunnyvale/README.md).

## Completion gates

A complete prototype must launch, finish, preserve the confirmed rules, and meet the measured duration target. A working editor scene alone is not a finished deliverable.

1. No parser errors, missing required resources, or blocking runtime errors.
2. All six areas in order; two enemy types; one carried pistol; no companion or boss.
3. Fair stage-0 completion with zero optional gems, no artifact, and no purchase.
4. Coherent checkpoint, swap, purchase, and story persistence.
5. Readable chosen 2D direction with any remaining art placeholders explicitly listed.
6. First-playthrough timing evidence satisfies the protocol below.
7. Windows test export launches and matches the verified editor route.

## Functional matrix

| ID | Scenario | Pass condition |
| --- | --- | --- |
| T01 | New Game | Six health, zero gems, stage 0, one held W01-P01, core installed, EDEN asleep, CP00 |
| T02 | Movement course | Variable jump, grace/buffer, low ceiling, and platform carry work without extra abilities |
| T03 | Wall / enemy shots | Solid walls block; Resident body hits damage; Clipper frontal hits show blocked feedback |
| T04 | Resident | Every lunge warns; one attack deals at most one health during immunity |
| T05 | Clipper | Charge stays grounded and straight; backstop exposes rear; three base hits fit a fair opening |
| T06 | Mixed lane | At most two enemies active; only one windup/active attacker; usable retreat remains |
| T07 | Roof fall | Recovery lane reaches the route by normal jumps; no damage, trap, or forced fight |
| T08 | SW01 | Walkway extends once; repeated use/reload cannot retract it under the hero |
| T09 | Main treasure | 45 available before bench; ignoring some/all never blocks a route |
| T10 | Optional routes | Welcome Key and separate 20-value cache reachable without new abilities |
| T11 | Rollback | Save, collect treasure, take damage, defeat enemy, then die: restore one consistent snapshot |
| T12 | Care / station | Full-health capsule remains; station heals and saves without respawning rewards/enemies |
| T13 | Same-type swap | Confirm exchanges two existing IDs; cancel changes neither; swap-back yields no third instance |
| T14 | Upgrade | 40 gems deducted once; stage 1 fitted and saved; refusal/insufficient funds/repeat buy changes nothing |
| T15 | Post-upgrade swap | Incoming pistol receives earned stage 1 without a second purchase or extra equipment |
| T16 | SC01 normal / skip | Same objective, installed core, open hatch, awakening state, and CP04; no duplicate event |
| T17 | Resume after awakening | Quarantine geometry already settled; no blocked spawn, surprise damage, or replayed latch |
| T18 | Zero-upgrade finish | Base pistol and normal movement finish A06; no gem or artifact gate |
| T19 | Save failure / invalid save | No partial purchase; valid backup or clear recovery option; no half-loaded world |
| T20 | Completion / replay | Found-gem total is independent of wallet spend; fresh run resets all run progress |
| T21 | Pause / subtitles / resize | Gameplay stops while paused; text and warnings remain readable; input resumes correctly |
| T22 | Export | Local Windows build starts, saves, continues, and completes outside the editor |

Automate the high-value state contracts in a small Godot test harness: (a) snapshot restoration/no duplicate IDs, (b) upgrade transaction including failed persistence, and (c) SC01 skip/resume equivalence. Run gameplay/visual checks manually. Do not create a large testing framework before a playable route exists.

## Timing protocol

Recruit **at least three first-time players** for the minimum timing gate; five is preferable. State input familiarity. Explain basic controls but do not coach the route. Use default damage/speed settings and a fresh run for each.

Log:
- active session time, pause/menu/long reading time, loading, and completion;
- time spent in each area and optional branch;
- failed-attempt time and retry counts;
- collected gems, upgrade purchase, artifact discovery;
- confusion points, missed warnings, damage sources, and places that felt repetitive.

**Successful-progress main-route time** includes only the main-route intervals retained through successful checkpoint progression. Exclude intervals later rolled back by death/restart, optional branch intervals, pause/loading, and extended menu reading. Keep the raw first-completion active time alongside it so retry frustration is visible. Brief ordinary story/bench use can remain in the planned budget; required noninteractive/interface delay stays below 60 seconds.

**Minimum duration pass:** all three initial first-time main-route measures fall between 600 and 900 seconds, with a preferred median near 720–840 seconds. If testing five or more, require at least 80% within that band and a median within it; investigate each outlier rather than hiding it. A very fast experienced replay is recorded separately and is not a reason to add a timer gate.

If the timing gate fails, use 01's area-by-area adjustments and retest with fresh players where possible. Keep old results labeled by build and tuning version. Never replace missing player measurements with estimated beat totals or an AI's prediction.

## Readability and performance

Record test PC, resolution, engine build, and graphics mode. Aim for stable 60 fps on that machine, with a responsive 30 fps fallback check; these are targets, not guaranteed requirements for every computer. Check the square and quarantine transition for spikes. Inspect at normal game scale with muted audio, grayscale screenshots, and reduced shake/background motion.

Capture at least: first Resident warning, Clipper stall, rooftop recovery, mixed square lane, depot bench, and transformed exit. Screenshots demonstrate composition; only a playthrough verifies traversal and controls.

## Report template

~~~text
Build / date / engine:
Tester familiarity:
Main-route successful-progress time:
Optional branch time:
Raw active first-completion time:
Pause/loading/extended reading:
Deaths and retry overhead:
Area times:
Gems found / wallet / upgrade / artifact:
Functional failures:
Confusion or dull sections:
Machine / resolution / observed performance:
Changes required / next retest:
~~~

Store future reports under the prototype project's reports/playtests/. No results exist at planning time.

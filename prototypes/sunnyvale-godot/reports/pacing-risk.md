# Pacing risk — 10–15 minute timing gate (UNVERIFIED)

Authority: `../../prototype-plans/level-01-sunnyvale/01-player-journey-and-pacing.md`
(budgets, allowed/forbidden adjustments) and
`07-acceptance-and-playtesting.md` (the 600–900s minimum-duration pass
criteria and timing protocol). See `playtests/README.md` and
`playtests/results/README.md` for the kit that will collect the real
measurement.

## Status: the gate is UNVERIFIED

No first-time player has completed a timed run of this build. **This
document contains no human playtest data** — none exists yet (M6/M7 progress
log, `../../prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`,
records "no measured playtest"). Everything below is either (a) automated
RouteBot traversal data, which is explicitly *not* pacing evidence, or (b)
qualitative reasoning about which areas look most exposed to running short.
No number in this document should be read as, or substituted for, a measured
first-time-player time. 07 is explicit: "Never replace missing player
measurements with estimated beat totals or an AI's prediction."

## The only data we currently have: RouteBot traversal time

`tests/cases/test_m3_level.gd` drives the debug `RouteBot`
(`scripts/debug/route_bot.gd`) through the assembled `level_01.tscn`. The
bot **never fights** (it runs with `debug_invulnerable = true` specifically
so a stray hit can't tear the level down mid-traversal — see
`route_bot.gd`/09's own notes), **never reads** any dialogue or journal
text, and **never hesitates**, backtracks, explores off-route, or aims
carefully — it walks the shortest authored path from route point to route
point as fast as its scripted inputs allow. Its time is therefore a **floor
on bare traversal**, not a simulation of a first-time player, and must never
be presented as pacing evidence.

Re-run this session (`NOIMPORT=1 tools/test.sh m3_level`, current build):

| Area | Bot traversal (this run) | Bot traversal (09's prior recorded run) | 01's per-area budget |
| --- | ---: | ---: | ---: |
| L01-A01 Perimeter gate | 9.38s | 9.38s | 75s |
| L01-A02 Front gardens | 17.85s | 17.95s | 150s |
| L01-A03 Rooftop walk | 20.72s | 22.18s | 135s |
| L01-A04 Neighborhood square | 21.63s | 21.77s | 165s |
| L01-A05 Maintenance depot | 8.60s | 8.02s | 90s |
| L01-A06 Alarm exit | 17.35s | 17.75s | 135s |
| **Main route total** | **95.53s** | **97.05s** | **750s (12:30)** |
| OPT01 branch (full route with branch) | 95.58s | 107.95s | +45–60s over main route, per 01 |
| OPT02 branch (full route with branch) | 96.95s | 98.47s | +45–60s over main route, per 01 |

The six main-route areas and both full-route totals agree within a few
seconds run to run (minor variance is expected — the bot's approach
angles/jump timing can shift slightly frame to frame; this is not a
regression). The **OPT01 branch row does not**: 95.58s this run vs 107.95s
in 09's prior run, a 12.4s (~13%) difference — larger than any other row's
run-to-run variance here, and worth flagging even though nothing in this
document treats it as pacing evidence. Separately, note that the OPT01
detour costs almost nothing over the main route in raw bot traversal this
run (main-route total 95.53s vs OPT01-branch total 95.58s, i.e. ~0.05s more
end to end for taking the detour) — 01's own +45–60s budget for that branch
is not visible in bare traversal time at all and depends entirely on the
artifact/reading content the branch is meant to add, which no automated run
can measure. Reproduce with:
`cd prototypes/sunnyvale-godot && NOIMPORT=1 tools/test.sh m3_level` (or
`tools/test.sh m3_level` when nothing else is importing).

Bot traversal as a fraction of each area's design budget:

| Area | Bot / budget |
| --- | ---: |
| L01-A01 | ~12–13% |
| L01-A02 | ~12% |
| L01-A03 | ~15–16% |
| L01-A04 | ~13% |
| L01-A05 | ~9–10% |
| L01-A06 | ~13% |

Total main-route bot time (~96s) is about **13% of the 750s design budget**
— consistent with a bot that skips all combat, reading, and exploration,
which are exactly the activities the 12:30 budget is built from (01: "First-
time aiming, ordinary traversal, a short story beat, and a brief bench
visit are part of the experience"). This ratio being low and roughly even
across areas is reassuring about geometry (no area's raw layout is
disproportionately short relative to its budget) but says nothing about
whether combat, reading, and exploration will actually fill the remaining
~87% for a first-time player — that is precisely what is unverified.

## Which areas look most at risk of running short — qualitatively

This section is **reasoning from design content and the traversal-floor
data above**, not a prediction of measured times. Ranked by exposure:

1. **L01-A05 Maintenance depot (highest concern).** Zero enemies, zero
   main-route gems (`02-area-blueprints.md`: "Population: 0 Residents, 0
   Clippers. Main-route treasure: 0 gems"), and the lowest bot/budget ratio
   (~9–10%) of any area. Its entire 90s budget depends on the player
   actually stopping to read the EDEN-wakes story beat and consider the
   bench/upgrade choice (01: "Discovery; EDEN wakes, then a safe upgrade
   choice"). A player who skips dialogue quickly (Enter/skip is a supported
   input) or declines the upgrade without lingering could clear this area in
   well under half its budget with nothing else to fill the gap — it has no
   combat or platforming fallback to absorb that.
2. **L01-A03 Rooftop walk.** Highest bot/budget ratio (~15–16%) among the
   combat-bearing areas, and its "population" is light (2 Residents, 0
   Clippers — `02`). It is explicitly a movement-focused area ("Confidence;
   movement with visible recovery" — 01), so a player who is comfortable
   with the platforming (which most players become by A03, having already
   done A01's tutorial jumps) may cross it close to the bot's own pace with
   only two lightweight enemy beats to slow them down. Less "content
   density" per second of budget than A02/A04, which lean more on combat
   variety to fill time.
3. **L01-A01 Perimeter gate (lower concern despite similar ratio).** Zero
   enemies by design (it is the pure-tutorial area — 01: "Curiosity; learn
   inputs without danger"), so a short traversal-heavy time here is
   *intended*, not a risk sign in the same way A05 is — the budget itself
   (75s, smallest of the six) already assumes minimal content. Listed for
   completeness, not flagged as high-risk.
4. **L01-A02 / L01-A04 / L01-A06 (lower concern).** These carry the bulk of
   the enemy population (2+2, 4+2, 1+2 Residents/Clippers respectively —
   `02`) and the largest gem hauls, giving first-time combat (aiming,
   learning warning tells, retreating) the most room to naturally expand
   time beyond the bot's floor. Their bot/budget ratios (~12–13%) are also
   the most "average" of the six.

None of this predicts pass or fail against the 600–900s gate — a first-time
player could easily read every journal entry and explore every optional
route and land well inside the target band, or conversely blitz through
disengaged and come in short. Only real testers resolve this.

## Adjustment levers if playtests come in under 600s

Per 01's "Measurement and adjustment" section, **only for the areas that
measure short**, not applied preemptively:

**Allowed:**
- Add a **distinct playable traversal beat or encounter setup** within the
  rushed area(s) specifically — new content, not more of the same.
- Keep the **existing enemy roster and learning order** intact; do not
  introduce a new enemy type or reorder when threats are first taught.
- **Re-budget beats and update `02-area-blueprints.md`'s encounter table and
  `prototype-spec.json` together** in the same change, so the design
  document and the data driving the level never drift apart.
- Treat this as area-by-area: only touch the area(s) playtests actually
  showed as short, using fresh players for the retest where possible (07).

**Forbidden** (01: "Do not obtain twelve minutes by..."; CONVENTIONS.md
reiterates via the pacing-rules cross-reference):
- Slower player movement (reduced run speed, weaker jump, etc).
- More enemy health / durability on any existing enemy.
- Hidden or obscured required switches.
- Forced backtracking that wasn't part of the authored route.
- Repeating the same encounter/wave to pad time.
- Extending platform/moving-object wait times as a timer-padding measure
  (the existing ~6s max missed-cycle wait is a design ceiling, not a lever
  to raise).
- Any change that amounts to a timer instead of authored content ("estimates
  alone cannot mark the duration requirement complete" — 07).

If a playtest instead comes in **over 900s**, 01's guidance is the mirror
image: separate out confusion/failed-attempt time from purposeful play
first, improve signage and recovery clarity, shorten empty travel, and
reduce redundant encounters — cutting the depot reveal is explicitly the
*last* resort, not the first.

## No invented numbers

Every second-level figure in this document above the "adjustment levers"
section is either a RouteBot measurement this session actually ran and
observed, or 01/07's own already-published design budgets. No line in this
file estimates or predicts a human playtest result.

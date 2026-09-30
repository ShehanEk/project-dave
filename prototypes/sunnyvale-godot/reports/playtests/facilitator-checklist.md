# Facilitator checklist — live observation

Authority: `../../../prototype-plans/level-01-sunnyvale/07-acceptance-and-playtesting.md`
("Timing protocol" — "confusion points, missed warnings, damage sources, and
places that felt repetitive"). Fill one copy of this per tester, during the
session (not from memory afterward). Use it to fill `report-template.md`'s
"Confusion or dull sections" and "Functional failures" fields; the timing
and chip/upgrade fields come from `tools/summarize_playtest.py`, not from
this sheet.

Do not coach from this checklist during play — see `README.md`'s "before
the session" section. Take notes silently; ask nothing until the run ends.

## Session info

- Tester: __________ (first-time on this build? Y/N)
- Tester familiarity (platformer/shooter genre experience, self-reported):
  __________
- Build / date: __________
- Machine / resolution / graphics mode: __________

## Confusion points

Any moment the tester stopped, backtracked without a reason, tried the same
failed action repeatedly, or said something like "wait, how do I—" out loud.
Note the area/beat ID (see the project's area IDs, e.g. `L01-A02-B01`) and
what they were confused about.

| Time (approx) | Area / beat | What happened |
| --- | --- | --- |
| | | |

## Missed warnings

Any enemy attack, hazard, or hint the tester did not react to before taking
the resulting hit (e.g. walked into a Night Guard's raised baton, walked into
the grab of a Staffer coming out of an annex door, ran into a Patrol Rover's
charge lane without noticing its amber lightbar and rock-back). Distinct from
ordinary damage taken while reacting correctly but losing the exchange.

| Time (approx) | Area / encounter | Warning missed | Result |
| --- | --- | --- | --- |
| | | | |

## Damage sources

Tally where health was actually lost, by cause (Night Guard baton swing,
Staffer grab lunge, Patrol Rover charge, fall, other). This is separate
from the `death` events in the log (which only record the death that
triggered a respawn) — note every hit, not just fatal ones.

| Area | Cause | Count |
| --- | --- | --- |
| | | |

## Repetitive / dull places

Any stretch the tester's energy visibly dropped, that felt like "more of the
same" rather than new content (e.g. a third near-identical Night Guard lane, an
empty travel stretch with nothing to react to). Note which area and roughly
how long it lasted — this maps directly to 01's "avoid eleven identical flat
shooting lanes" and "reduce redundant encounters" guidance.

| Area | What felt repetitive | Approx duration |
| --- | --- | --- |
| | | |

## Functional failures

Anything that looked like a bug rather than a design/pacing issue: a stuck
camera, an enemy that didn't respond, a UI element that didn't update, a
crash, a save that didn't take. Note exact repro steps if possible — these
matter for the functional matrix (07's T01–T23), not just pacing.

| Time (approx) | What happened | Repro steps |
| --- | --- | --- |
| | | |

## Free notes

Anything else worth recording that doesn't fit the categories above
(reactions, quotes, things they said out loud, whether they noticed the
optional branches at all, whether they used Quickcycle/upgrade, etc).

# 01 — Player journey and pacing

**Visual direction (C11, C15, C35):** [hand-drawn 2D in a dark night-campus palette, painted flat and lit in the engine](../../art-design/style-guide.md). Revamped 2026-09-29 (C14–C24) and rebuilt 2026-09-30 (C33); there are no selected scene images for the new look.

## What the duration means

Target a **10–15 minute first successful playthrough**, centered on **12:30** for the main route. Normal observation, first-time aiming, ordinary traversal, a short story beat, and a brief workbench visit are part of the experience. A confident replay may be faster; do not impose a minimum completion timer.

Exclude loading, pause/settings time, developer interruptions, discarded checkpoint attempts, and exhaustive journal reading from the main-route measure. Track those separately. Optional branches are additional, not required to rescue an undersized main route. Keep required story/interface delay under 60 seconds in total and skippable.

## Planned time allocation

| Area | Target | Cumulative | Player experience |
| --- | ---: | ---: | --- |
| L01-A01 Perimeter gate | 1:15 | 1:15 | Curiosity; learn inputs without danger |
| L01-A02 Front gardens | 2:30 | 3:45 | Unease; learn each threat separately |
| L01-A03 Rooftop walk | 2:15 | 6:00 | Confidence; movement with visible recovery |
| L01-A04 Campus plaza | 2:45 | 8:45 | Pressure; combine known threats, then take the keycard |
| L01-A05 Server depot | 1:30 | 10:15 | Discovery; Adam answers, then a safe upgrade choice |
| L01-A06 Alarm exit | 2:15 | 12:30 | Payoff; familiar skills under the lockdown, then the keycard wicket |

These estimates allocate attention, not enforced dwell time. A beat can span several camera views. Begin with roughly 3–6 connected views per area, fewer in the depot, and tune the actual content against playtests rather than a screen-count formula.

## Keeping the level substantial

Alternate survey → action → recovery → reward. Gardens isolate threats; roofs emphasize jumps; the plaza mixes learned patterns; the depot changes the meaning of the scenery when Adam answers and the campus locks down; the exit tests recognition after that change. Encounters have navigable floors, routes to retreat, and small environmental stories: a night-shift employee badging into a door that is already open, sprinklers watering an empty lawn. Avoid eleven identical flat shooting lanes.

Movement should stay responsive. Do not obtain twelve minutes by reducing running speed, multiplying enemy health, hiding a required switch, forcing repeated backtracking, repeating the same wave, or extending platform waits. Moving-platform missed-cycle wait should be at most about 6 seconds in the first blockout; tune down if it feels idle.

The keycard adds no separate detour and no budget of its own: it sits on the A04 main route just past the far-porch recovery station (the B07 beat), so it is picked up on the way to the depot door.

The two optional routes take approximately 45–60 seconds each: a guard-post loft with the Lockout Notice evidence file and a roof cache worth 20 chips. Both return near their departure point. Together they put the central first-run estimate near 14:00–14:30. Neither contains mandatory story evidence or upgrade access.

## Measurement and adjustment

Instrument area entry/exit, encounter completion, checkpoint commits, deaths, optional-branch entry/exit, pause/menu intervals, upgrade purchase, and completion. Never upload telemetry; keep local playtest logs.

If the main route is under 10 minutes for new players, first identify the rushed areas. Add a distinct playable traversal beat or encounter setup within those areas; keep the enemy roster and learning order. Re-budget beats and update the encounter table and JSON together. Do not count optional routes as mandatory time.

If it exceeds 15 minutes, separate confusion, failed attempts, menus, and purposeful play. Improve signs and recovery, shorten empty travel, and reduce redundant encounters before cutting the depot's Adam scene. Use the pass criteria in [07](07-acceptance-and-playtesting.md); estimates alone cannot mark the duration requirement complete.

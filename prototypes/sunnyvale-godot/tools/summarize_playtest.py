#!/usr/bin/env python3
"""Summarize one Sunnyvale Telemetry JSONL playtest log into
07-acceptance-and-playtesting.md's report template fields.

Usage:
    python3 tools/summarize_playtest.py path/to/run_....jsonl

Python 3 stdlib only (json, sys, argparse) — no dependencies, per M5 part 2's
brief. Reads a log written by scripts/telemetry.gd (one JSON object per
line, each carrying at least "event", "t_active", "t_wall").

Definitions (07's own wording):
  - "Main-route successful-progress time": only the main-route intervals
    retained through successful checkpoint progression. An interval later
    ROLLED BACK by a death/restart (i.e. before the checkpoint it was heading
    toward ever actually committed) is excluded entirely, not just up to the
    rollback point — the player will walk it again and that second, kept
    attempt is what counts. Optional-branch time (between a branch_enter and
    its matching branch_exit) and any time spent paused are also excluded.
  - "Raw active first-completion time": the checkpoint_commit at the FIRST
    ever "completion" event's own t_active (i.e. Session's own
    run_meta["active_seconds"] at that moment) — already excludes pause and
    loading by construction (LevelDirector only ticks it while
    hero.input_enabled is true), so this is reported directly from the
    completion event, not resummed from intervals.
  - "Optional branch time": sum of (branch_exit.t_active - branch_enter.
    t_active) per branch_id, matched in order.
  - "Area times": last area_exit.t_active - area_enter.t_active per area_id
    occurrence, summed per area (an area entered more than once, e.g. after a
    death, sums every visit).
"""

import argparse
import json
import sys
from collections import defaultdict


def load_events(path):
    events = []
    with open(path, "r") as f:
        for line_no, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError as e:
                print("warning: skipping malformed line %d: %s" % (line_no, e), file=sys.stderr)
    return events


def branch_time(events):
    total = 0.0
    per_branch = defaultdict(float)
    open_enter = {}
    for e in events:
        if e.get("event") == "branch_enter":
            open_enter[e.get("branch_id", "")] = e["t_active"]
        elif e.get("event") == "branch_exit":
            bid = e.get("branch_id", "")
            if bid in open_enter:
                dt = e["t_active"] - open_enter.pop(bid)
                per_branch[bid] += max(0.0, dt)
                total += max(0.0, dt)
    return total, dict(per_branch)


def area_times(events):
    per_area = defaultdict(float)
    open_enter = {}
    for e in events:
        ev = e.get("event")
        if ev == "area_enter":
            open_enter[e.get("area_id", "")] = e["t_active"]
        elif ev == "area_exit":
            aid = e.get("area_id", "")
            if aid in open_enter:
                dt = e["t_active"] - open_enter.pop(aid)
                per_area[aid] += max(0.0, dt)
    return dict(per_area)


## ADV-06: `t_active` is FROZEN while the tree is paused (LevelDirector only
## ticks it while `hero.input_enabled` is true, and PauseMenu's whole
## suspend mechanism IS `get_tree().paused = true`, which stops that same
## `_physics_process` from running at all) — so `pause_end.t_active -
## pause_start.t_active` is always exactly 0, not the real time the player
## spent paused. Real elapsed pause time needs `t_wall` (real seconds since
## `run_start()`), which keeps advancing regardless of pause.
def pause_time(events):
    total = 0.0
    count = 0
    open_start = None
    for e in events:
        ev = e.get("event")
        if ev == "pause_start":
            open_start = e.get("t_wall", 0.0)
        elif ev == "pause_end" and open_start is not None:
            total += max(0.0, e.get("t_wall", 0.0) - open_start)
            count += 1
            open_start = None
    return total, count


def deaths_and_restarts(events):
    deaths = [e for e in events if e.get("event") == "death"]
    restarts = [e for e in events if e.get("event") == "restart_from_checkpoint"]
    return len(deaths), len(restarts)


def raw_active_first_completion(events):
    for e in events:
        if e.get("event") == "completion":
            return e.get("active_seconds", e.get("t_active", 0.0))
    return None


## Main-route successful-progress time: sum the active-time between
## consecutive successful checkpoint_commit events (main-route only, i.e.
## checkpoint ids other than "UPG01" which is a workbench detour, not route
## progress), MINUS any optional-branch time, treating `run_start` (ADV-02:
## the real game never emits a "CP00" checkpoint_commit, so without this the
## very first main-route interval — run start to CP01 — was silently dropped
## entirely) as the boundary before the first checkpoint.
##
## Pause time needs NO subtraction here (unlike the naive first attempt at
## this — see ADV-06): `t_active` never advances while `get_tree().paused` is
## true in the first place (LevelDirector only ticks it while
## `hero.input_enabled` is true, and pausing stops that same
## `_physics_process` from running at all), so a `checkpoint_commit`-to-
## `checkpoint_commit` `t_active` delta already excludes every pause inside
## it for free.
##
## A death/restart before the next checkpoint commits means everything
## BEFORE that reset was a rolled-back attempt at the SAME next checkpoint —
## ADV-02: `t_active` itself is never rolled back on death, so without this
## the discarded attempt's own time silently stayed IN the interval. Only
## the surviving attempt (from the LAST death/restart inside this segment,
## if any, up to the checkpoint that actually committed) is kept.
def main_route_progress_time(events):
    commits = [e for e in events if e.get("event") == "checkpoint_commit"
               and e.get("checkpoint_id") != "UPG01"]
    if not commits:
        return 0.0
    run_start_events = [e for e in events if e.get("event") == "run_start"]
    t_run_start = run_start_events[0]["t_active"] if run_start_events else 0.0
    branch_total, _ = branch_time(events)
    resets = [e["t_active"] for e in events
              if e.get("event") in ("death", "restart_from_checkpoint")]

    boundaries = [t_run_start] + [c["t_active"] for c in commits]
    total = 0.0
    for i in range(1, len(boundaries)):
        t0 = boundaries[i - 1]
        t1 = boundaries[i]
        resets_in_segment = [r for r in resets if t0 < r < t1]
        effective_t0 = max(resets_in_segment) if resets_in_segment else t0
        total += max(0.0, t1 - effective_t0)
    return max(0.0, total - branch_total)


def chips_upgrade_evidence(events):
    upgrades = [e for e in events if e.get("event") == "upgrade_purchase"]
    for e in reversed(events):
        if e.get("event") == "completion":
            return {
                "chips_found": e.get("chips_found"),
                "evidence_found": e.get("evidence_found"),
                "upgrade_stage": e.get("upgrade_stage"),
                "upgrade_purchases": len(upgrades),
            }
    return {"chips_found": None, "evidence_found": None, "upgrade_stage": None,
            "upgrade_purchases": len(upgrades)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", help="path to a Telemetry JSONL playtest log")
    args = parser.parse_args()

    events = load_events(args.log)
    if not events:
        print("No events found in %s" % args.log, file=sys.stderr)
        sys.exit(1)

    run_start = next((e for e in events if e.get("event") == "run_start"), {})
    b_total, b_per = branch_time(events)
    areas = area_times(events)
    p_total, p_count = pause_time(events)
    deaths, restarts = deaths_and_restarts(events)
    raw_active = raw_active_first_completion(events)
    main_route = main_route_progress_time(events)
    stats = chips_upgrade_evidence(events)

    print("Build / date / engine: %s / %s" % (run_start.get("build", "?"), run_start.get("engine", "?")))
    print("Tester familiarity: (fill in manually)")
    print("Main-route successful-progress time: %.1fs" % main_route)
    print("Optional branch time: %.1fs %s" % (b_total, b_per if b_per else ""))
    print("Raw active first-completion time: %s" %
          ("%.1fs" % raw_active if raw_active is not None else "(no completion event)"))
    print("Pause/loading/extended reading: %.1fs across %d pause(s)" % (p_total, p_count))
    print("Deaths and retry overhead: %d death(s), %d restart(s)" % (deaths, restarts))
    print("Area times:")
    for area_id in sorted(areas):
        print("  %s: %.1fs" % (area_id, areas[area_id]))
    print("Chips found / wallet / upgrade / evidence: chips_found=%s upgrade_stage=%s evidence_found=%s (%d purchase(s))" %
          (stats["chips_found"], stats["upgrade_stage"], stats["evidence_found"], stats["upgrade_purchases"]))
    print("Functional failures: (fill in manually)")
    print("Confusion or dull sections: (fill in manually)")
    print("Machine / resolution / observed performance: (fill in manually)")
    print("Changes required / next retest: (fill in manually)")


if __name__ == "__main__":
    main()

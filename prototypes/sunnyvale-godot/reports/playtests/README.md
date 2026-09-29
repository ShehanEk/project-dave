# Playtest kit — Sunnyvale L01 timing gate

Authority: `../../../prototype-plans/level-01-sunnyvale/07-acceptance-and-playtesting.md`
("Timing protocol") and `01-player-journey-and-pacing.md`. This kit exists
because the **10–15 minute first-playthrough timing gate is currently
PENDING** — no first-time testers have run the prototype yet (see
`../pacing-risk.md` and `../../../prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`).
Nothing here estimates that gate; it only prepares the kit that will let
real testers close it.

## Who qualifies as a first-time player

- Has **never played this prototype build before** (a repeat tester on a
  later build is a "familiar" replay, not a first-time run — log it
  separately, it does not count toward the timing gate).
- Any general platformer/shooter familiarity is fine and should be recorded
  (07 asks for "tester familiarity" in the report) — the gate is about the
  *level*, not about the genre.
- Needs no special hardware; any machine that runs the build at a playable
  frame rate qualifies. Record the machine/resolution per 07's "Readability
  and performance" section.
- **At least three** first-time testers are the minimum for the gate; five
  is preferable (07). Recruit fresh players for a retest after any tuning
  change — do not reuse a tester who has already seen the route.

## Before the session: what to tell the tester

Explain only the basic controls (see the project `README.md`'s control
table — move, jump, fire, interact, pause, journal). Do **not** explain or
hint at the route, where treasure, the keycard or the optional branches
are, enemy tactics, or that upgrades exist. Do not coach: if they ask "where do I go?"
or "what does this do?", say only "explore and find out" or repeat the
control they asked about. Coaching invalidates the run for the timing gate.

Use **default settings** (no volume/reduced-motion/text-size changes
required — those don't affect timing) and start from a **fresh run**: if
`checkpoint.json`/`checkpoint.bak.json` already exist for this build (see
paths below), delete or rename them before the session, or use "New Game"
which offers to replace an existing save. A Continue from a partial save is
not a first-time run.

**On a shared/dev machine (AUD-10): archive or clear `sunnyvale/playtests/`
before the session.** A machine that has run this build's tests, demos, or
earlier sessions before can already have many stale `run_*.jsonl` files in
that folder (mtime, not filename, is the only reliable "newest" signal, and
a large pre-existing pile makes it easy to grab the wrong file by mistake).
Move the existing folder aside (e.g. rename it to `playtests_pre_<date>/`)
or note its current file count/latest mtime before the tester starts, so the
one file the session produces is unambiguous.

Let the tester play uninterrupted. Do not pause the game for them, do not
narrate, and do not answer non-control questions until they finish or give
up. Facilitator observation fields are in `facilitator-checklist.md`.

## Finding and sending the log

The build writes one JSONL file per run under the OS user-data directory,
started only when the tester actually presses New Game/Continue on the
title screen:

| Platform | Path |
| --- | --- |
| macOS | `~/Library/Application Support/Godot/app_userdata/DEAD EDEN - Sunnyvale Prototype/sunnyvale/playtests/run_<timestamp>.jsonl` |
| Windows | `%APPDATA%\Godot\app_userdata\DEAD EDEN - Sunnyvale Prototype\sunnyvale\playtests\run_<timestamp>.jsonl` |

(These mirror the project `README.md`'s "Saves, settings, and playtest logs"
table — `sunnyvale/` is the same folder that also holds `checkpoint.json`
and `settings.json`, with a `playtests/` subfolder.)

After the tester's session, copy the newest `run_*.jsonl` file from that
folder and send it to whoever is compiling results. **Privacy: playtest
logs stay local.** They are never uploaded anywhere by the game itself
(`Telemetry` only ever writes to local disk — see `scripts/telemetry.gd`),
contain no player-identifying information (no name, account, network data —
only in-game event timings and positions), and should be shared only within
the team compiling this prototype's results (e.g. as a file attachment),
never posted publicly. Store the file — or a copy of it — under
`results/` in this kit (see `results/README.md`) once a facilitator has
filled in the human-observed fields for it.

## Summarizing a log

From the project root:

```sh
python3 tools/summarize_playtest.py "path/to/run_....jsonl"
```

This prints the machine-derivable fields of `report-template.md` (main-route
successful-progress time, optional branch time, raw active first-completion
time, pause time, deaths/restarts, per-area times, chips/upgrade/evidence).
It leaves the fields only a human facilitator can fill in —
tester familiarity, functional failures, confusion/dull sections, machine
and observed performance, and next-retest notes — marked
`(fill in manually)`. Copy its output into a fresh copy of
`report-template.md`, fill in the manual fields from
`facilitator-checklist.md`'s notes, and save the result under `results/`
alongside the raw log.

## Files in this kit

- `README.md` — this file.
- `facilitator-checklist.md` — what to watch for and write down live during
  the session (07's observation fields: confusion points, missed warnings,
  damage sources, repetitive places).
- `report-template.md` — 07's report template, verbatim, one copy per
  tester per session.
- `fixtures/synthetic_full_run.jsonl` — a hand-computed synthetic log (not a
  real playtest) used to verify `tools/summarize_playtest.py`'s math; see
  its header comment.
- `results/` — where real completed reports and their raw logs go. Empty
  until the first real playtest session (see `results/README.md`).

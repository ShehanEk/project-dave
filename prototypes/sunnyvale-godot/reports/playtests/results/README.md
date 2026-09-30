# Playtest results

**No results exist yet.** The 10–15 minute first-playthrough timing gate
(`../../../prototype-plans/level-01-sunnyvale/07-acceptance-and-playtesting.md`)
is **PENDING** — no first-time testers have been recruited or run against
this build yet (see `../../pacing-risk.md` for the only data currently
available, which is bot traversal time, not human pacing evidence).

When a real session happens:

1. Run the session per `../README.md` and `../facilitator-checklist.md`.
2. Copy the tester's raw `run_....jsonl` log into this folder.
3. Run `python3 tools/summarize_playtest.py <that log>` from the project
   root and fill a copy of `../report-template.md` with its output plus the
   facilitator's manual notes.
4. Save the filled report next to its raw log here, named so the two are
   obviously paired (e.g. `2026-xx-xx-tester1.md` /
   `2026-xx-xx-tester1.jsonl`).
5. Update `../../pacing-risk.md` and
   `../../../prototype-plans/level-01-sunnyvale/09-progress-and-handoff.md`
   once at least three first-time results exist, per 07's minimum.

Never replace a missing measurement with an estimate or an AI's prediction
(07's own instruction) — an empty `results/` folder is the honest state
until real testers run the build.

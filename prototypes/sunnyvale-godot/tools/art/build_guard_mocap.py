#!/usr/bin/env python3
"""Night Guard motion from Mixamo clips (C35): turn converted clips into his
game clips in assets/characters/lit/night_guard/mocap/.

Input is a folder of clips already converted by mixamo_to_rig.py (Blender):
  idle.json, walking.json, running.json, bash.json, hit_reaction.json
converted with
  --hip-height-px 47 --hip-ref rest --foot-offset auto --forward=-y
(plus --in-place for walking and running). Mixamo sources, downloaded by the
user 2026-09-30: "Idle", "Walking", "Running", "Bash", "Hit Reaction" (FBX Binary, 30 fps).

Each game clip is a slice of a source clip, played at a rate that matches the
game: gaits so the planted foot moves at his walking speed (no foot slide),
the Bash split at its wind-up, swing and recovery and retimed to the tuning's
windup_time, swing_time and recovery_time. The Bash wind-up swings the arm
back and round behind him (in the side view, a windmill), so its baton arm is
rebuilt to rise in front of him and hold overhead until the swing.
  python3 tools/art/build_guard_mocap.py DIR
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "assets", "characters", "lit", "night_guard", "mocap")

# Planted-foot speed of each gait at 30 fps on the Night Guard rig (px/s),
# measured by forward kinematics on rig.json. brawler.gd scales the walk by
# (speed / 70 px/s) and the chase by (speed / approach speed), so the clips
# are timed for those reference speeds.
WALK_NATIVE, RUN_NATIVE = 82.0, 100.0
WALK_REFERENCE = 70.0
APPROACH_SPEED = 1.05 * 96.0

# The Bash, in source frames: wind-up (the pull back and the arm over the
# top), the swing down, and the recovery back to the stance.
WINDUP = (12, 27)
SWING = (27, 36)
RECOVER = (36, 72)
RAISED_BY = 21              # the baton is overhead by here and held to the swing
WINDUP_TIME, SWING_TIME, RECOVERY_TIME = 0.5, 0.22, 1.2
# The flinch of the Hit Reaction (from rest, to the doubled-over peak, and
# back up), played fast so a shot reads as a hit without a long stagger.
HIT = (8, 48)
HIT_TIME = 0.55


def load(d, name):
    with open(os.path.join(d, name + ".json")) as f:
        return json.load(f)


def wrap(a):
    return (a + math.pi) % (2.0 * math.pi) - math.pi


def raise_overhead(frames):
    """The wind-up's baton arm, rebuilt: from the stance the arm rises in front
    of him to the raised pose the swing starts from (the Bash's own frame at
    the top), then holds it overhead for the rest of the wind-up. The capture
    pulls the arm back low and swings it round behind him, which flattens to
    a windmill in the side view; the body keeps its captured weight shift."""
    first, last = WINDUP
    top = RAISED_BY
    u0 = frames[first]["rot"]["near_upper_arm"]
    f0 = frames[first]["rot"]["near_forearm"]
    u1 = frames[last]["rot"]["near_upper_arm"]
    f1 = frames[last]["rot"]["near_forearm"]
    du = wrap(u1 - u0)
    if du > 0.0:                                        # always up through the front
        du -= 2.0 * math.pi
    g0 = u0 + f0                                        # the forearm's own direction
    dg = wrap((u1 + f1) - g0)
    if dg > 0.0:
        dg -= 2.0 * math.pi
    for i in range(first, last + 1):
        t = min(1.0, (i - first) / float(top - first))
        e = t * t * (3.0 - 2.0 * t)
        u = u0 + du * e
        g = g0 + dg * e
        frames[i]["rot"]["near_upper_arm"] = round(wrap(u), 5)
        frames[i]["rot"]["near_forearm"] = round(wrap(g - u), 5)


def clip(src, name, first, last, seconds=None, rate=1.0, loop=False):
    frames = src["frames"][first:last + 1]
    n = len(frames)
    fps = (n - 1) / seconds if seconds else src["fps"] * rate
    return {"name": name, "source": "mixamo:" + src["name"], "fps": round(fps, 3), "frame_count": n,
            "loop": loop, "joints": src["joints"], "hip_height_px": src.get("hip_height_px"),
            "frames": frames}


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    d = sys.argv[1]
    idle, walking, running, bash, hit = (load(d, n) for n in ("idle", "walking", "running", "bash", "hit_reaction"))
    raise_overhead(bash["frames"])
    clips = [
        clip(idle, "idle", 0, idle["frame_count"] - 1, loop=True),
        clip(walking, "walk", 0, walking["frame_count"] - 1, rate=WALK_REFERENCE / WALK_NATIVE, loop=True),
        clip(running, "stalk", 0, running["frame_count"] - 1, rate=APPROACH_SPEED / RUN_NATIVE, loop=True),
        clip(bash, "windup", *WINDUP, seconds=WINDUP_TIME),
        clip(bash, "swing", *SWING, seconds=SWING_TIME),
        clip(bash, "recover", *RECOVER, seconds=RECOVERY_TIME),
        clip(hit, "hit", *HIT, seconds=HIT_TIME),
    ]
    os.makedirs(OUT, exist_ok=True)
    for c in clips:
        with open(os.path.join(OUT, c["name"] + ".json"), "w") as f:
            json.dump(c, f, separators=(",", ":"))
        print("%-8s %3d frames @ %6.2f fps = %.2fs loop=%s" % (c["name"], c["frame_count"], c["fps"],
              (c["frame_count"] - 1) / c["fps"], c["loop"]))


if __name__ == "__main__":
    main()

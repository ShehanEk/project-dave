#!/usr/bin/env python3
"""tools/gen_audio.py — generate every ORIGINAL sound cue for the Sunnyvale
prototype's M6 presentation pass, using only the python3 standard library
(wave, struct, math, random). Deterministic: a fixed seed means re-running
this script reproduces byte-identical WAVs.

Writes:
    assets/audio/sfx/<cue>.wav     (34 one-shot cues, mono 16-bit PCM)
    assets/audio/music/<name>.wav  (2 seamless loops, mono 16-bit PCM)

These are synthesized procedurally (sine/square/saw oscillators, filtered
noise bursts, envelopes) — not recordings, not downloads, not licensed
samples. See CONVENTIONS.md's "Audio" section for the cue list, the
Audio autoload API that plays them, and which script still needs to call
each one.

Usage:
    python3 tools/gen_audio.py
"""
import math
import os
import random
import struct
import wave

SEED = 20260927
SR = 22050  # sample rate for every generated file (mono, 16-bit PCM)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX_DIR = os.path.join(ROOT, "assets", "audio", "sfx")
MUSIC_DIR = os.path.join(ROOT, "assets", "audio", "music")


# ---------------------------------------------------------------------------
# Low-level DSP helpers. Everything is a plain list[float] in [-1, 1] until
# to_wav() quantizes it to 16-bit PCM at the very end.
# ---------------------------------------------------------------------------

def n_samples(seconds: float) -> int:
    return max(1, int(round(seconds * SR)))


def note_freq(semitones_from_a4: float) -> float:
    """Equal-temperament frequency, A4 = 440 Hz."""
    return 440.0 * (2.0 ** (semitones_from_a4 / 12.0))


def silence(seconds: float):
    return [0.0] * n_samples(seconds)


def sine(freq: float, seconds: float, phase: float = 0.0):
    n = n_samples(seconds)
    w = 2.0 * math.pi * freq
    return [math.sin(w * (i / SR) + phase) for i in range(n)]


def square(freq: float, seconds: float, duty: float = 0.5):
    n = n_samples(seconds)
    out = [0.0] * n
    for i in range(n):
        t = (freq * (i / SR)) % 1.0
        out[i] = 1.0 if t < duty else -1.0
    return out


def saw(freq: float, seconds: float):
    n = n_samples(seconds)
    out = [0.0] * n
    for i in range(n):
        t = (freq * (i / SR)) % 1.0
        out[i] = 2.0 * t - 1.0
    return out


def sweep(f0: float, f1: float, seconds: float, shape: str = "lin", osc: str = "sine"):
    """Frequency sweep from f0 to f1 over `seconds`. shape='lin'|'exp'."""
    n = n_samples(seconds)
    out = [0.0] * n
    phase = 0.0
    for i in range(n):
        frac = i / max(1, n - 1)
        if shape == "exp" and f0 > 0 and f1 > 0:
            f = f0 * ((f1 / f0) ** frac)
        else:
            f = f0 + (f1 - f0) * frac
        phase += 2.0 * math.pi * f / SR
        if osc == "square":
            out[i] = 1.0 if (phase % (2.0 * math.pi)) < math.pi else -1.0
        else:
            out[i] = math.sin(phase)
    return out


def noise(seconds: float, seed: int):
    rnd = random.Random(seed)
    n = n_samples(seconds)
    return [rnd.uniform(-1.0, 1.0) for _ in range(n)]


def lowpass(x, alpha: float):
    """One-pole lowpass; alpha in (0,1], smaller = darker/softer."""
    y = [0.0] * len(x)
    prev = 0.0
    for i, v in enumerate(x):
        prev = prev + alpha * (v - prev)
        y[i] = prev
    return y


def highpass(x, alpha: float):
    """One-pole highpass; alpha close to 1 keeps most of the signal."""
    y = [0.0] * len(x)
    prev_x = 0.0
    prev_y = 0.0
    for i, v in enumerate(x):
        cur = alpha * (prev_y + v - prev_x)
        y[i] = cur
        prev_y = cur
        prev_x = v
    return y


def bandpass(x, alpha_low: float, alpha_high: float):
    return highpass(lowpass(x, alpha_low), alpha_high)


def gain(x, g: float):
    return [v * g for v in x]


def mix(*tracks, at=None):
    """Sum tracks. `at` (optional) is a list of sample offsets, one per
    track, of the same length as `tracks` (default: all start at 0)."""
    offsets = at if at is not None else [0] * len(tracks)
    n = max((off + len(t) for t, off in zip(tracks, offsets)), default=0)
    out = [0.0] * n
    for t, off in zip(tracks, offsets):
        for i, v in enumerate(t):
            out[off + i] += v
    return out


def concat(*tracks):
    out = []
    for t in tracks:
        out.extend(t)
    return out


def pad_to(x, seconds):
    n = n_samples(seconds)
    if len(x) >= n:
        return x[:n]
    return x + [0.0] * (n - len(x))


def env_line(n: int, points):
    """points: [(fraction 0..1, level), ...] sorted by fraction; linear
    interpolation between them, held flat before the first / after the
    last point."""
    if n <= 0:
        return []
    out = [0.0] * n
    for i in range(n):
        frac = i / max(1, n - 1)
        lo, hi = points[0], points[-1]
        for j in range(len(points) - 1):
            if points[j][0] <= frac <= points[j + 1][0]:
                lo, hi = points[j], points[j + 1]
                break
        span = hi[0] - lo[0]
        t = 0.0 if span <= 0 else (frac - lo[0]) / span
        out[i] = lo[1] + (hi[1] - lo[1]) * t
    return out


def apply_env(x, points):
    e = env_line(len(x), points)
    return [a * b for a, b in zip(x, e)]


def apply_pluck(x, decay_seconds: float, attack_seconds: float = 0.003):
    """Fast attack, exponential decay — good for percussive / plucked tones.
    Always settles to ~0 well before the sound ends, which is what makes
    these safe to place anywhere in a seamless music loop."""
    n = len(x)
    decay_samples = max(1.0, decay_seconds * SR)
    attack_samples = max(1.0, attack_seconds * SR)
    out = [0.0] * n
    for i in range(n):
        a = min(1.0, i / attack_samples)
        d = math.exp(-i / decay_samples)
        out[i] = x[i] * a * d
    return out


def normalize(x, peak: float = 0.9):
    m = max((abs(v) for v in x), default=0.0)
    if m <= 1e-9:
        return x
    k = peak / m
    return [v * k for v in x]


def clip(x):
    return [max(-1.0, min(1.0, v)) for v in x]


def to_wav(path: str, samples, sr: int = SR):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    samples = clip(samples)
    ints = [int(round(v * 32767)) for v in samples]
    data = struct.pack("<%dh" % len(ints), *ints)
    with wave.open(path, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(data)


# ---------------------------------------------------------------------------
# Loop-locked oscillators — for any tone that must sustain, unbroken, across
# the entire length of a music loop (drones, tremolo/pulse LFOs). Picking
# freq = k / loop_seconds for an integer k guarantees sin(2*pi*f*(t+L)) ==
# sin(2*pi*f*t): an EXACT integer number of cycles fit in the loop, so the
# waveform is bit-for-bit periodic and the loop point is inaudible. Short
# plucked/percussive notes (apply_pluck) don't need this: they decay to ~0
# well inside their own slot, so they never straddle the wrap point.
# ---------------------------------------------------------------------------

def loop_locked_freq(target_hz: float, loop_seconds: float) -> float:
    k = max(1, round(target_hz * loop_seconds))
    return k / loop_seconds


# ---------------------------------------------------------------------------
# One-shot SFX cues (05-content-and-assets.md / audio-direction.md).
# Each function returns a finished, normalized list[float].
# ---------------------------------------------------------------------------

def sfx_pistol_fire():
    # "Crisp spring snap and small metal bolt; short controlled tail."
    snap = apply_pluck(bandpass(noise(0.05, 101), 0.6, 0.5), 0.02, 0.001)
    tick = apply_pluck(sine(1900, 0.06), 0.03, 0.001)
    tail = apply_env(sine(420, 0.05), [(0, 0.0), (0.05, 1.0), (1.0, 0.0)])
    tail = apply_pluck(tail, 0.03)
    return normalize(mix(gain(snap, 1.0), gain(tick, 0.6), gain(tail, 0.35)))


def sfx_pistol_fire_quick():
    # Quickcycle variant: tighter, brighter, with a second micro-click
    # riding the tail to read as "faster cycle" rather than just "quieter".
    snap = apply_pluck(bandpass(noise(0.035, 102), 0.75, 0.55), 0.012, 0.001)
    tick = apply_pluck(sine(2300, 0.04), 0.016, 0.0008)
    click2 = apply_pluck(sine(2600, 0.02), 0.008, 0.0005)
    out = mix(gain(snap, 1.0), gain(tick, 0.55), gain(click2, 0.4),
              at=[0, 0, n_samples(0.02)])
    return normalize(out)


def sfx_bolt_hit():
    thump = apply_pluck(sine(150, 0.12), 0.05)
    crack = apply_pluck(bandpass(noise(0.06, 103), 0.5, 0.4), 0.025, 0.001)
    return normalize(mix(gain(thump, 0.9), gain(crack, 0.7)))


def sfx_bolt_blocked():
    # Harder metallic clang — a different color from bolt_hit so a blocked
    # shot never reads as a normal hit.
    ring = apply_pluck(mix(sine(1200, 0.2), sine(1214, 0.2)), 0.09, 0.001)
    clank = apply_pluck(bandpass(noise(0.05, 104), 0.7, 0.5), 0.02, 0.001)
    return normalize(mix(gain(ring, 0.8), gain(clank, 0.8)))


def sfx_hero_hurt():
    body = sweep(320, 150, 0.22, shape="exp")
    body = apply_pluck(body, 0.11, 0.002)
    rasp = apply_pluck(lowpass(noise(0.18, 105), 0.35), 0.09, 0.002)
    return normalize(mix(gain(body, 0.8), gain(rasp, 0.5)))


def sfx_hero_jump():
    return normalize(apply_pluck(sweep(320, 620, 0.12, shape="lin"), 0.09, 0.002))


def sfx_hero_land():
    thump = apply_pluck(sine(95, 0.14), 0.06)
    puff = apply_pluck(lowpass(noise(0.08, 106), 0.25), 0.04, 0.001)
    return normalize(mix(gain(thump, 0.85), gain(puff, 0.45)))


def sfx_resident_windup():
    # Organic, rounded — deliberately NOT mechanical, to stay distinct from
    # every Clipper cue.
    body = sweep(150, 240, 0.42, shape="lin")
    body = lowpass(body, 0.18)
    body = apply_env(body, [(0, 0.0), (0.15, 1.0), (0.85, 0.9), (1.0, 0.0)])
    return normalize(gain(body, 0.9))


def sfx_resident_lunge():
    rise = apply_env(sweep(220, 340, 0.18, shape="lin"), [(0, 0.2), (0.7, 1.0), (1.0, 0.0)])
    rise = lowpass(rise, 0.3)
    hit = apply_pluck(lowpass(noise(0.05, 107), 0.4), 0.03, 0.001)
    return normalize(mix(gain(rise, 0.75), gain(hit, 0.6), at=[0, n_samples(0.16)]))


def sfx_resident_defeat():
    body = sweep(230, 90, 0.55, shape="exp")
    body = lowpass(body, 0.12)
    body = apply_env(body, [(0, 0.0), (0.1, 1.0), (1.0, 0.0)])
    return normalize(gain(body, 0.85))


def sfx_clipper_scrape():
    # Idle roll: rough, periodic, unmistakably mechanical.
    base = bandpass(noise(0.5, 108), 0.55, 0.6)
    tremolo = [0.6 + 0.4 * math.sin(2 * math.pi * 5.0 * (i / SR)) for i in range(len(base))]
    out = [a * b for a, b in zip(base, tremolo)]
    out = apply_env(out, [(0, 0.0), (0.08, 1.0), (0.85, 1.0), (1.0, 0.0)])
    return normalize(gain(out, 0.8))


def sfx_clipper_windup():
    # Shears open: two quick metallic clicks, then a short rising ring.
    click1 = apply_pluck(sine(2100, 0.03), 0.012, 0.0005)
    click2 = apply_pluck(sine(2400, 0.03), 0.012, 0.0005)
    ring = apply_pluck(sweep(900, 1500, 0.18, shape="lin"), 0.09, 0.002)
    out = mix(gain(click1, 0.7), gain(click2, 0.7), gain(ring, 0.55),
              at=[0, n_samples(0.05), n_samples(0.09)])
    return normalize(out)


def sfx_clipper_charge():
    buzz = sweep(180, 520, 0.5, shape="exp", osc="square")
    buzz = lowpass(buzz, 0.5)
    buzz = apply_env(buzz, [(0, 0.0), (0.1, 1.0), (0.9, 1.0), (1.0, 0.0)])
    return normalize(gain(buzz, 0.75))


def sfx_clipper_stall():
    # Wall stall: a warble that stutters and abruptly cuts, unlike the
    # smooth rise of clipper_charge.
    n = n_samples(0.5)
    wobble = square(140, 0.5, duty=0.5)
    lfo = [1.0 if math.sin(2 * math.pi * 9.0 * (i / SR)) > -0.2 else 0.0 for i in range(n)]
    out = [w * g for w, g in zip(wobble, lfo)]
    out = lowpass(out, 0.4)
    out = apply_env(out, [(0, 0.0), (0.05, 1.0), (0.9, 0.8), (1.0, 0.0)])
    return normalize(gain(out, 0.7))


def sfx_clipper_defeat():
    down = sweep(420, 60, 0.6, shape="exp", osc="square")
    down = lowpass(down, 0.35)
    down = apply_env(down, [(0, 0.0), (0.08, 1.0), (0.8, 0.5), (1.0, 0.0)])
    clunk = apply_pluck(sine(85, 0.2), 0.09)
    return normalize(mix(gain(down, 0.7), gain(clunk, 0.7), at=[0, n_samples(0.55)]))


def sfx_gem():
    tone = apply_pluck(sine(1760, 0.09), 0.045, 0.001)
    return normalize(gain(tone, 0.85))


def sfx_gem_cluster():
    freqs = [1760, 2093, 2637]
    parts = [apply_pluck(sine(f, 0.12), 0.05, 0.001) for f in freqs]
    offs = [0, n_samples(0.045), n_samples(0.09)]
    return normalize(mix(*parts, at=offs))


def sfx_cache_open():
    clunk = apply_pluck(sine(110, 0.12), 0.05)
    freqs = [880, 1108, 1318]
    chime = [apply_pluck(sine(f, 0.2), 0.09, 0.002) for f in freqs]
    offs = [n_samples(0.1), n_samples(0.16), n_samples(0.22)]
    return normalize(mix(gain(clunk, 0.8), *[gain(c, 0.6) for c in chime], at=[0] + offs))


def sfx_artifact():
    # "A slower small phrase" — distinct from the single gem tick.
    freqs = [note_freq(-3), note_freq(1), note_freq(4), note_freq(9)]
    parts = [apply_pluck(sine(f, 0.4), 0.24, 0.004) for f in freqs]
    offs = [n_samples(i * 0.16) for i in range(len(freqs))]
    return normalize(mix(*parts, at=offs))


def sfx_capsule():
    warm = apply_env(mix(sine(440, 0.5), sine(556, 0.5)),
                      [(0, 0.0), (0.3, 1.0), (0.8, 0.8), (1.0, 0.0)])
    return normalize(gain(warm, 0.7))


def sfx_interact():
    return normalize(apply_pluck(sine(660, 0.07), 0.035, 0.001))


def sfx_checkpoint():
    # "Calm two-part signal", distinct from purchase's brighter arpeggio.
    a = apply_pluck(sine(523.25, 0.22), 0.12, 0.003)
    b = apply_pluck(sine(659.25, 0.3), 0.18, 0.003)
    return normalize(mix(gain(a, 0.75), gain(b, 0.75), at=[0, n_samples(0.2)]))


def sfx_purchase():
    freqs = [523.25, 659.25, 783.99]
    parts = [apply_pluck(sine(f, 0.22), 0.11, 0.002) for f in freqs]
    offs = [n_samples(i * 0.07) for i in range(len(freqs))]
    return normalize(mix(*parts, at=offs))


def sfx_swap():
    down = apply_pluck(sweep(700, 420, 0.08, shape="lin"), 0.05, 0.001)
    up = apply_pluck(sweep(420, 900, 0.09, shape="lin"), 0.05, 0.001)
    return normalize(mix(gain(down, 0.75), gain(up, 0.75), at=[0, n_samples(0.08)]))


def sfx_latch():
    clunk = apply_pluck(sine(140, 0.1), 0.045)
    click = apply_pluck(bandpass(noise(0.03, 109), 0.6, 0.5), 0.015, 0.0005)
    return normalize(mix(gain(clunk, 0.85), gain(click, 0.6), at=[0, n_samples(0.02)]))


def sfx_eden_chime():
    freqs = [note_freq(0), note_freq(7), note_freq(12)]
    parts = [apply_pluck(sine(f, 0.7), 0.4, 0.01) for f in freqs]
    offs = [n_samples(i * 0.12) for i in range(len(freqs))]
    return normalize(mix(*parts, at=offs))


def sfx_alarm():
    # Restrained per audio-direction.md ("avoid constant alarm noise") —
    # two short pulses, not a siren wall.
    pulse = apply_env(mix(square(500, 0.18), square(506, 0.18)),
                       [(0, 0.0), (0.08, 1.0), (0.85, 0.8), (1.0, 0.0)])
    pulse = lowpass(pulse, 0.55)
    return normalize(concat(gain(pulse, 0.7), silence(0.1), gain(pulse, 0.7)))


def sfx_hatch_open():
    hiss = apply_env(bandpass(noise(0.5, 110), 0.35, 0.4),
                      [(0, 0.0), (0.3, 1.0), (0.8, 0.6), (1.0, 0.0)])
    clank = apply_pluck(sine(100, 0.2), 0.09)
    return normalize(mix(gain(hiss, 0.6), gain(clank, 0.75), at=[0, n_samples(0.42)]))


def sfx_pit_fall():
    whoosh = apply_env(sweep(700, 140, 0.4, shape="exp"), [(0, 0.0), (0.15, 1.0), (1.0, 0.2)])
    whoosh = lowpass(whoosh, 0.3)
    thud = apply_pluck(sine(90, 0.16), 0.06)
    return normalize(mix(gain(whoosh, 0.65), gain(thud, 0.8), at=[0, n_samples(0.38)]))


def sfx_exit():
    freqs = [note_freq(0), note_freq(4), note_freq(7), note_freq(12)]
    parts = [apply_pluck(sine(f, 0.5), 0.3, 0.003) for f in freqs]
    offs = [n_samples(i * 0.11) for i in range(len(freqs))]
    tail = apply_pluck(mix(sine(note_freq(12), 0.6), sine(note_freq(19), 0.6)), 0.4, 0.01)
    return normalize(mix(*parts, gain(tail, 0.5), at=offs + [n_samples(len(freqs) * 0.11)]))


def sfx_ui_move():
    return normalize(apply_pluck(sine(500, 0.045), 0.02, 0.0005))


def sfx_ui_confirm():
    a = apply_pluck(sine(600, 0.06), 0.03, 0.0005)
    b = apply_pluck(sine(900, 0.06), 0.03, 0.0005)
    return normalize(mix(gain(a, 0.7), gain(b, 0.7), at=[0, n_samples(0.04)]))


def sfx_ui_back():
    a = apply_pluck(sine(700, 0.06), 0.03, 0.0005)
    b = apply_pluck(sine(480, 0.06), 0.03, 0.0005)
    return normalize(mix(gain(a, 0.7), gain(b, 0.7), at=[0, n_samples(0.04)]))


def sfx_save_failed():
    down = sweep(360, 160, 0.4, shape="exp")
    down = apply_env(down, [(0, 0.0), (0.1, 1.0), (1.0, 0.0)])
    return normalize(gain(down, 0.8))


SFX_GENERATORS = {
    "pistol_fire": sfx_pistol_fire,
    "pistol_fire_quick": sfx_pistol_fire_quick,
    "bolt_hit": sfx_bolt_hit,
    "bolt_blocked": sfx_bolt_blocked,
    "hero_hurt": sfx_hero_hurt,
    "hero_jump": sfx_hero_jump,
    "hero_land": sfx_hero_land,
    "resident_windup": sfx_resident_windup,
    "resident_lunge": sfx_resident_lunge,
    "resident_defeat": sfx_resident_defeat,
    "clipper_scrape": sfx_clipper_scrape,
    "clipper_windup": sfx_clipper_windup,
    "clipper_charge": sfx_clipper_charge,
    "clipper_stall": sfx_clipper_stall,
    "clipper_defeat": sfx_clipper_defeat,
    "gem": sfx_gem,
    "gem_cluster": sfx_gem_cluster,
    "cache_open": sfx_cache_open,
    "artifact": sfx_artifact,
    "capsule": sfx_capsule,
    "interact": sfx_interact,
    "checkpoint": sfx_checkpoint,
    "purchase": sfx_purchase,
    "swap": sfx_swap,
    "latch": sfx_latch,
    "eden_chime": sfx_eden_chime,
    "alarm": sfx_alarm,
    "hatch_open": sfx_hatch_open,
    "pit_fall": sfx_pit_fall,
    "exit": sfx_exit,
    "ui_move": sfx_ui_move,
    "ui_confirm": sfx_ui_confirm,
    "ui_back": sfx_ui_back,
    "save_failed": sfx_save_failed,
}


# ---------------------------------------------------------------------------
# Music loops. Pad/pulse drones use loop_locked_freq() so the buffer tiles
# with no audible seam; melodic plucks decay to ~0 within their own step so
# they never straddle the wrap point either. See loop_locked_freq()'s
# comment for why this produces an exact, bit-identical loop point.
# ---------------------------------------------------------------------------

def _step_pattern(loop_seconds, steps, degrees, base_note, decay, amp, seed, gap=0.22):
    """Renders `steps` evenly-sized slots across the loop; `degrees[i]` is a
    semitone offset from `base_note` (None = rest). `gap` shortens each
    note's decay relative to its slot so it always settles before the next
    one starts (and, on the last step, before the loop wraps)."""
    n_total = n_samples(loop_seconds)
    bounds = [round(s * n_total / steps) for s in range(steps + 1)]
    rnd = random.Random(seed)
    out = [0.0] * n_total
    for s in range(steps):
        deg = degrees[s % len(degrees)]
        if deg is None:
            continue
        slot_n = bounds[s + 1] - bounds[s]
        slot_seconds = slot_n / SR
        note_seconds = slot_seconds * (1.0 - gap)
        vel = 0.85 + 0.15 * rnd.random()  # gentle, deterministic "imperfection"
        freq = note_freq(base_note + deg)
        # Clamp the decay so exp(-note/decay) is inaudibly small (<1%) by
        # the end of the note's own slot — a note whose tail were still
        # loud when its array simply ends would cut off as an audible
        # click, both mid-loop and (worst case) right at the seam.
        actual_decay = min(decay, note_seconds / 5.0)
        tone = apply_pluck(sine(freq, note_seconds), actual_decay, 0.004)
        tone = gain(tone, amp * vel)
        for i, v in enumerate(tone):
            idx = bounds[s] + i
            if idx < n_total:
                out[idx] += v
    return out


def music_suburb_loop():
    loop_seconds = n_samples(14.0) / SR
    n_total = n_samples(loop_seconds)

    root = loop_locked_freq(note_freq(-24), loop_seconds)   # low C, warm pad root
    fifth = loop_locked_freq(note_freq(-17), loop_seconds)  # fifth above
    lfo_hz = loop_locked_freq(0.15, loop_seconds)
    pad = [0.0] * n_total
    for i in range(n_total):
        t = i / SR
        trem = 0.82 + 0.18 * math.sin(2 * math.pi * lfo_hz * t)
        pad[i] = trem * 0.5 * (math.sin(2 * math.pi * root * t) + 0.6 * math.sin(2 * math.pi * fifth * t))
    pad = gain(pad, 0.09)

    # Major pentatonic melody (0, 2, 4, 7, 9 semitones), gently imperfect
    # rhythm via varied velocity and one rest — never a rigid metronome.
    degrees = [0, None, 2, 4, 0, 7, 4, 2, 9, 7, 4, None, 2, 0, 4, 2]
    melody = _step_pattern(loop_seconds, 16, degrees, base_note=3, decay=0.5,
                            amp=0.5, seed=SEED + 1)

    # Soft mechanical tick riding the off-beats — "gently imperfect
    # mechanical rhythm" per audio-direction.md.
    tick_degrees = [None, 0, None, 0, None, None, 0, None,
                    None, 0, None, None, 0, None, 0, None]
    n_step = n_total // 16
    tick = [0.0] * n_total
    rnd = random.Random(SEED + 2)
    for s, has in enumerate(tick_degrees):
        if has is None:
            continue
        start = s * n_step
        burst = apply_pluck(bandpass(noise(0.04, SEED + 100 + s), 0.6, 0.5), 0.02, 0.001)
        vel = 0.7 + 0.3 * rnd.random()
        for i, v in enumerate(burst):
            idx = start + i
            if idx < n_total:
                tick[idx] += v * 0.18 * vel

    return normalize(mix(pad, melody, tick), peak=0.85)


def music_quarantine_loop():
    # A restrained variation of the SAME material: minor tint, slower,
    # plus a clinical pulse (audio-direction.md "Rootworks" style breathing
    # is Act 2 — here we keep it sparse/sterile per the level brief).
    loop_seconds = n_samples(20.0) / SR
    n_total = n_samples(loop_seconds)

    root = loop_locked_freq(note_freq(-24), loop_seconds)
    minor_third_up = loop_locked_freq(note_freq(-21), loop_seconds)  # flattened 3rd, minor tint
    lfo_hz = loop_locked_freq(0.09, loop_seconds)  # slower tremolo than suburb
    pad = [0.0] * n_total
    for i in range(n_total):
        t = i / SR
        trem = 0.85 + 0.15 * math.sin(2 * math.pi * lfo_hz * t)
        pad[i] = trem * 0.5 * (math.sin(2 * math.pi * root * t) + 0.55 * math.sin(2 * math.pi * minor_third_up * t))
    pad = gain(pad, 0.1)

    # Minor pentatonic (0, 3, 5, 7, 10), sparser and slower than the
    # suburb melody — half the note density, longer decays.
    degrees = [0, None, None, 3, None, 5, None, None,
               7, None, None, 3, None, 0, None, None]
    melody = _step_pattern(loop_seconds, 16, degrees, base_note=3, decay=0.9,
                            amp=0.42, seed=SEED + 3)

    # Clinical pulse: an evenly-spaced, sterile blip — distinct in color
    # from the suburb tick (pure filtered tone, not noise-textured).
    interval = loop_seconds / 8.0
    n_interval = n_total // 8
    pulse = [0.0] * n_total
    for k in range(8):
        start = k * n_interval
        blip = apply_pluck(sine(880, 0.05), 0.03, 0.001)
        blip = mix(blip, gain(apply_pluck(bandpass(noise(0.02, SEED + 200 + k), 0.6, 0.5), 0.012, 0.0005), 0.4))
        for i, v in enumerate(blip):
            idx = start + i
            if idx < n_total:
                pulse[idx] += v * 0.22

    return normalize(mix(pad, melody, pulse), peak=0.85)


MUSIC_GENERATORS = {
    "suburb_loop": music_suburb_loop,
    "quarantine_loop": music_quarantine_loop,
}


def main():
    random.seed(SEED)
    total_bytes = 0

    for cue_name in sorted(SFX_GENERATORS):
        samples = SFX_GENERATORS[cue_name]()
        path = os.path.join(SFX_DIR, cue_name + ".wav")
        to_wav(path, samples)
        total_bytes += os.path.getsize(path)
        print("sfx  %-22s %6d samples  %.3fs" % (cue_name, len(samples), len(samples) / SR))

    for name in sorted(MUSIC_GENERATORS):
        samples = MUSIC_GENERATORS[name]()
        path = os.path.join(MUSIC_DIR, name + ".wav")
        to_wav(path, samples)
        total_bytes += os.path.getsize(path)
        print("music %-22s %6d samples  %.3fs" % (name, len(samples), len(samples) / SR))

    print("Total: %d files, %.1f KB" % (
        len(SFX_GENERATORS) + len(MUSIC_GENERATORS), total_bytes / 1024.0))


if __name__ == "__main__":
    main()

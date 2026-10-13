#!/usr/bin/env python3
"""tools/gen_audio.py — generate every ORIGINAL sound cue for the Dead Eden
Level 1 prototype, using only the python3 standard library (wave, struct,
math, random). Deterministic: a fixed seed means re-running this script
reproduces byte-identical WAVs.

Writes:
    assets/audio/sfx/<cue>.wav     (46 one-shot cues, mono 16-bit PCM)
    assets/audio/music/<name>.wav  (2 seamless loops, mono 16-bit PCM)

Sound identity (design/05-presentation/audio-direction.md): empty corporate
spaces after hours — low drones, mains hum, soft relay clicks, a calm PA
voice that knows Dave's name. Tense but restrained. Organic sound stays in
combat and stays small: a restrained wet hit, a body landing, the rustle of
cloth. Never a splatter, a scream or a groan; machines die in metal, sparks
and clatter. Every pitched cue and both loops sit around D (open fifths, one
flattened second for unease, never a bright major third), so cues that
overlap in play never clash. Link implants chirp in the top octaves, Adam's
PA chime is soft and reverberant, alarms stay low.

These are synthesized procedurally (sine/pulse/saw oscillators, filtered
noise, envelopes, a small reverb) — not recordings, not downloads, not
licensed samples. See CONVENTIONS.md's "Audio" section for the cue list and
the Audio autoload API that plays them. Which .wav the game actually plays
for a cue is decided by Audio.SFX_SOURCES in scripts/audio/audio_director.gd
(a cue may still be sourced from Kenney .ogg files; its .wav here is then the
fallback). After generating, this script cross-checks that file against
this one (comment lines ignored) and exits non-zero if a director cue has no
generator.

Usage:
    python3 tools/gen_audio.py                       # everything
    python3 tools/gen_audio.py adam_chime alarm      # only these cues/loops
    python3 tools/gen_audio.py --out DIR [names...]  # audition into DIR/sfx, DIR/music
"""
import math
import os
import random
import re
import struct
import sys
import wave

SEED = 20260927
SR = 22050  # sample rate for every generated file (mono, 16-bit PCM)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SFX_DIR = os.path.join(ROOT, "assets", "audio", "sfx")
MUSIC_DIR = os.path.join(ROOT, "assets", "audio", "music")
DIRECTOR = os.path.join(ROOT, "scripts", "audio", "audio_director.gd")


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
# Pitch names, band-limited oscillators, resonant filters, reverb and the
# "finish" step every rebuilt cue goes through. Added by the Dead Eden
# rebuild; the helpers above are unchanged so the untouched cues stay
# byte-identical.
# ---------------------------------------------------------------------------

_NOTE_STEPS = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}


def hz(name: str) -> float:
    """Scientific pitch name -> Hz. hz('D5'), hz('Eb3'), hz('F#4'); A4 = 440."""
    acc = 0
    i = 1
    while name[i] in "#b":
        acc += 1 if name[i] == "#" else -1
        i += 1
    return note_freq(_NOTE_STEPS[name[0]] + acc + 12 * (int(name[i:]) - 4))


def cents(freq: float, c: float) -> float:
    return freq * (2.0 ** (c / 1200.0))


def harm_saw(n: int):
    return [1.0 / k for k in range(1, n + 1)]


def harm_square(n: int):
    return [(1.0 / k) if k % 2 else 0.0 for k in range(1, n + 1)]


def harm_pulse(duty: float, n: int):
    return [abs(math.sin(math.pi * k * duty)) / k for k in range(1, n + 1)]


def partials(freq, seconds: float, amps, max_hz: float = 9000.0, phase: float = 0.0):
    """Additive (band-limited) oscillator: amps[k-1] is the level of harmonic k
    and any partial at or above `max_hz` is dropped, so bright pulse/saw
    timbres never alias at this sample rate. `freq` is a number, or a
    per-sample list for glides."""
    n = n_samples(seconds)
    out = [0.0] * n
    if isinstance(freq, (int, float)):
        for k, a in enumerate(amps, start=1):
            if a == 0.0 or k * freq >= max_hz:
                continue
            w = 2.0 * math.pi * k * freq / SR
            ph = k * phase
            out = [o + a * math.sin(w * i + ph) for i, o in enumerate(out)]
        return out
    ph = phase
    live = [(k, a) for k, a in enumerate(amps, start=1) if a != 0.0]
    for i in range(n):
        f = freq[i] if i < len(freq) else freq[-1]
        ph += 2.0 * math.pi * f / SR
        s = 0.0
        for k, a in live:
            if k * f < max_hz:
                s += a * math.sin(k * ph)
        out[i] = s
    return out


def _rbj(kind: str, fc: float, q: float):
    fc = min(fc, SR * 0.45)
    w0 = 2.0 * math.pi * fc / SR
    cw, sw = math.cos(w0), math.sin(w0)
    alpha = sw / (2.0 * q)
    if kind == "lp":
        b0, b1, b2 = (1.0 - cw) / 2.0, 1.0 - cw, (1.0 - cw) / 2.0
    elif kind == "hp":
        b0, b1, b2 = (1.0 + cw) / 2.0, -(1.0 + cw), (1.0 + cw) / 2.0
    else:  # "bp": constant 0 dB peak gain
        b0, b1, b2 = alpha, 0.0, -alpha
    a0, a1, a2 = 1.0 + alpha, -2.0 * cw, 1.0 - alpha
    return b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0


def _biquad(x, coeffs):
    b0, b1, b2, a1, a2 = coeffs
    y = [0.0] * len(x)
    x1 = x2 = y1 = y2 = 0.0
    for i, v in enumerate(x):
        o = b0 * v + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        y[i] = o
        x2, x1 = x1, v
        y2, y1 = y1, o
    return y


def blp(x, fc: float, q: float = 0.7071):
    """Two-pole (12 dB/oct) lowpass at `fc` Hz."""
    return _biquad(x, _rbj("lp", fc, q))


def bhp(x, fc: float, q: float = 0.7071):
    return _biquad(x, _rbj("hp", fc, q))


def bbp(x, fc: float, q: float = 1.0):
    return _biquad(x, _rbj("bp", fc, q))


def svf(x, cutoff, q: float = 0.8, mode: str = "bp"):
    """Trapezoidal state-variable filter with a swept cutoff. `cutoff` is a
    number or a per-sample list (Hz); mode 'lp' | 'hp' | 'bp' (unity peak)."""
    n = len(x)
    y = [0.0] * n
    k = 1.0 / q
    ic1 = ic2 = 0.0
    const = isinstance(cutoff, (int, float))
    a1 = a2 = a3 = 0.0
    if const:
        g = math.tan(math.pi * min(cutoff, SR * 0.45) / SR)
        a1 = 1.0 / (1.0 + g * (g + k))
        a2 = g * a1
        a3 = g * a2
    for i in range(n):
        if not const:
            g = math.tan(math.pi * min(cutoff[i], SR * 0.45) / SR)
            a1 = 1.0 / (1.0 + g * (g + k))
            a2 = g * a1
            a3 = g * a2
        v0 = x[i]
        v3 = v0 - ic2
        v1 = a1 * ic1 + a2 * v3
        v2 = ic2 + a2 * ic1 + a3 * v3
        ic1 = 2.0 * v1 - ic1
        ic2 = 2.0 * v2 - ic2
        if mode == "lp":
            y[i] = v2
        elif mode == "hp":
            y[i] = v0 - k * v1 - v2
        else:
            y[i] = k * v1
    return y


def exp_curve(f0: float, f1: float, n: int):
    """Per-sample exponential glide from f0 to f1 (for partials()/svf())."""
    return [f0 * ((f1 / f0) ** (i / max(1, n - 1))) for i in range(n)]


def soft_clip(x, drive: float):
    d = math.tanh(drive)
    return [math.tanh(drive * v) / d for v in x]


def echo(x, delay_s: float, feedback: float, repeats: int = 3, lp: float = 0.6):
    """Dark tape-style repeats: each repeat is the previous one, lowpassed and
    scaled by `feedback`. Returns x followed by the repeats (longer)."""
    d = n_samples(delay_s)
    out = list(x) + [0.0] * (d * repeats)
    tap = list(x)
    for r in range(1, repeats + 1):
        tap = [v * feedback for v in lowpass(tap, lp)]
        for i, v in enumerate(tap):
            out[i + d * r] += v
    return out


def fade(x, in_s: float = 0.0, out_s: float = 0.0):
    """Linear fade-in / fade-out — keeps every cue from starting or stopping
    on a step, which is what a click is."""
    y = list(x)
    n = len(y)
    ni = min(n, n_samples(in_s)) if in_s > 0 else 0
    no = min(n, n_samples(out_s)) if out_s > 0 else 0
    for i in range(ni):
        y[i] *= i / ni
    for i in range(no):
        y[n - 1 - i] *= i / no
    return y


def pluck(x, tau: float, attack: float = 0.003, tail: float = 0.03):
    """apply_pluck() plus a fade over the last `tail` seconds: a plucked buffer
    that is cut off while still at a few percent would end on a step, which is
    a click. Every note the rebuilt cues and loops place goes through this."""
    return fade(apply_pluck(x, tau, attack), 0.0, tail)


def finish(x, peak: float = 0.9, fade_in_s: float = 0.0008, fade_out_s: float = 0.012):
    """Common tail of every rebuilt cue: DC block, normalize, short fades."""
    x = highpass(x, 0.997)
    x = normalize(x, peak)
    return fade(x, fade_in_s, fade_out_s)


def click(freq: float, seconds: float, tau: float, seed: int, q: float = 1.0):
    """A short band-limited noise tick (relay, latch, card contact), peak 1."""
    return normalize(pluck(svf(noise(seconds, seed), freq, q, "bp"), tau, 0.0004, tail=seconds * 0.4), 1.0)


# --- reverb --------------------------------------------------------------------
# Freeverb-style Schroeder reverb: 8 damped feedback combs in parallel into 4
# allpasses in series (delays are Freeverb's, halved for this sample rate).
# Mono, dark by default. `wet` is calibrated so wet=1.0 comes out at the same
# RMS as the dry signal for noise-like material, whatever rt60/damp is.

_COMB_DELAYS = (557, 593, 641, 677, 709, 743, 787, 811)
_ALLPASS_DELAYS = (223, 167, 131, 89)
_REV_NORM = {}


def _comb(x, d, g, damp):
    n = len(x)
    y = [0.0] * n
    buf = [0.0] * d
    idx = 0
    store = 0.0
    keep = 1.0 - damp
    for i in range(n):
        o = buf[idx]
        store = o * keep + store * damp
        buf[idx] = x[i] + store * g
        y[i] = o
        idx += 1
        if idx == d:
            idx = 0
    return y


def _allpass(x, d, g=0.5):
    n = len(x)
    y = [0.0] * n
    buf = [0.0] * d
    idx = 0
    for i in range(n):
        b = buf[idx]
        v = x[i]
        y[i] = b - v
        buf[idx] = v + b * g
        idx += 1
        if idx == d:
            idx = 0
    return y


def _reverb_chain(x, rt60, damp):
    acc = None
    for d in _COMB_DELAYS:
        g = 10.0 ** (-3.0 * d / (SR * rt60))
        y = _comb(x, d, g, damp)
        acc = y if acc is None else [a + b for a, b in zip(acc, y)]
    for d in _ALLPASS_DELAYS:
        acc = _allpass(acc, d)
    return acc


def _reverb_norm(rt60, damp):
    key = (round(rt60, 3), round(damp, 3))
    if key not in _REV_NORM:
        probe = noise(rt60 * 1.5 + 0.8, 4242)
        out = _reverb_chain(probe, rt60, damp)
        half = len(out) // 2
        rms_in = math.sqrt(sum(v * v for v in probe[half:]) / (len(probe) - half))
        rms_out = math.sqrt(sum(v * v for v in out[half:]) / (len(out) - half))
        _REV_NORM[key] = rms_in / max(rms_out, 1e-9)
    return _REV_NORM[key]


def reverb(x, rt60=1.8, damp=0.35, wet=0.3, dry=1.0, predelay=0.0, tail=None):
    """Adds reverb. `tail` extends the output so the tail can ring out
    (default 0.8 * rt60 seconds; 0 keeps the input's length + predelay)."""
    n_tail = n_samples(rt60 * 0.8) if tail is None else (0 if tail <= 0 else n_samples(tail))
    pd = n_samples(predelay) if predelay > 0 else 0
    n = len(x) + pd + n_tail
    wet_in = [0.0] * pd + list(x) + [0.0] * n_tail
    w = _reverb_chain(wet_in, rt60, damp)
    k = wet * _reverb_norm(rt60, damp)
    out = [k * v for v in w]
    if dry:
        for i, v in enumerate(x):
            out[i] += dry * v
    return out


# ---------------------------------------------------------------------------
# Loop-locked oscillators — for any tone that must sustain, unbroken, across
# the entire length of a music loop (drones, tremolo/pulse LFOs). Picking
# freq = k / loop_seconds for an integer k guarantees sin(2*pi*f*(t+L)) ==
# sin(2*pi*f*t): an EXACT integer number of cycles fit in the loop, so the
# waveform is bit-for-bit periodic and the loop point is inaudible. Short
# plucked/percussive notes (apply_pluck) don't need this when they decay to
# ~0 well inside their own slot; anything that can ring across the wrap point
# (echoes, reverb tails, bells) is added with _wrap_add() instead, so its tail
# wraps around to the start of the loop rather than being cut off.
# ---------------------------------------------------------------------------

def loop_locked_freq(target_hz: float, loop_seconds: float) -> float:
    k = max(1, round(target_hz * loop_seconds))
    return k / loop_seconds


# ---------------------------------------------------------------------------
# One-shot SFX cues (05-content-and-assets.md / audio-direction.md).
# Each function returns a finished list[float].
# ---------------------------------------------------------------------------

# --- kept as they were: hero, pistol (the game plays Kenney sources for most of
# these; see Audio.SFX_SOURCES) and the generic UI/world cues ------------------

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


def sfx_cache_open():
    clunk = apply_pluck(sine(110, 0.12), 0.05)
    freqs = [880, 1108, 1318]
    chime = [apply_pluck(sine(f, 0.2), 0.09, 0.002) for f in freqs]
    offs = [n_samples(0.1), n_samples(0.16), n_samples(0.22)]
    return normalize(mix(gain(clunk, 0.8), *[gain(c, 0.6) for c in chime], at=[0] + offs))


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
    click_ = apply_pluck(bandpass(noise(0.03, 109), 0.6, 0.5), 0.015, 0.0005)
    return normalize(mix(gain(clunk, 0.85), gain(click_, 0.6), at=[0, n_samples(0.02)]))


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


# --- rebuilt for the night campus ----------------------------------------------

def _soft_tone(freq, seconds, tau, attack=0.004, amps=(1.0, 0.30, 0.10)):
    """A soft, glassy note (sine + gentle 2nd/3rd partial, plucked decay): the
    teal 'Arcadia at rest' voice used by pickups, confirms and chirps."""
    return pluck(partials(freq, seconds, list(amps), max_hz=9000.0), tau, attack, tail=seconds * 0.3)


def _blip(freq, seconds, tau, duty=0.25, attack=0.0005, max_hz=9500.0):
    """One crisp digital blip: a band-limited pulse wave, fast exponential
    decay, tail faded so it never ends on a step."""
    return pluck(partials(freq, seconds, harm_pulse(duty, 14), max_hz=max_hz), tau, attack, tail=seconds * 0.3)


def _bell(freq, seconds, tau, ratios=(1.0, 2.0, 3.0, 4.1), amps=(1.0, 0.40, 0.16, 0.08), attack=0.008, sag_cents=0.0):
    """Soft bell/chime voice: a few partials, the higher ones dying faster.
    `sag_cents` lets the pitch droop by that much over the note, like a tired
    speaker."""
    out = [0.0] * n_samples(seconds)
    sag = 2.0 ** (-sag_cents / 1200.0)
    for r, a in zip(ratios, amps):
        f = freq * r
        if f > 9000.0:
            continue
        tone = sweep(f, f * sag, seconds, shape="exp") if sag_cents else sine(f, seconds)
        p = pluck(tone, tau / (1.0 + 0.45 * (r - 1.0)), attack, tail=min(0.25, seconds * 0.25))
        out = [o + a * v for o, v in zip(out, p)]
    return out


# --- building blocks for the combat cues: the stun baton, sparks, bodies and
# metal (Night Guard, Staffer, Patrol Rover, debris) ------------------------------

def _crackle(seconds, seed, rate0, rate1, f_lo=2000.0, f_hi=7000.0, tau=0.003, level=(0.35, 1.0), curve=1.0):
    """Sparse electrical crackle (a stun baton, sparks, a shorting implant): a
    random train of tiny band-limited noise cracks. The event rate glides from
    `rate0` to `rate1` per second (`curve` bends the glide), each crack is one
    of six precomputed ticks at a random level, and a seed always renders the
    same train."""
    n = n_samples(seconds)
    out = [0.0] * n
    rnd = random.Random(seed)
    ticks = [click(f_lo * ((f_hi / f_lo) ** rnd.random()), tau * 8.0, tau, seed * 16 + j, q=rnd.uniform(0.8, 1.6))
             for j in range(6)]
    t = 0.0
    while True:
        frac = min(1.0, t / seconds)
        t += rnd.expovariate(max(0.5, rate0 + (rate1 - rate0) * (frac ** curve)))
        i = int(t * SR)
        if i >= n:
            break
        g = rnd.uniform(level[0], level[1])
        for k, v in enumerate(ticks[rnd.randrange(len(ticks))]):
            if i + k >= n:
                break
            out[i + k] += v * g
    return out


def _gate(seconds, seed, block_s, p0, p1, smooth=0.04):
    """A random on/off gate, like a contact that keeps making and breaking: each
    `block_s` block is on with a probability gliding p0 -> p1 (so the sputter
    thins out and dies), edges softened by a one-pole lowpass."""
    n = n_samples(seconds)
    rnd = random.Random(seed)
    blk = max(1, n_samples(block_s))
    out = [0.0] * n
    for i in range(0, n, blk):
        on = 1.0 if rnd.random() < p0 + (p1 - p0) * (i / max(1, n - 1)) else 0.0
        for j in range(i, min(n, i + blk)):
            out[j] = on
    return lowpass(out, smooth)


def _thud(f0, f1, seconds, tau, attack=0.003, amps=(1.0, 0.45, 0.22)):
    """A low body hit: an exponential pitch drop f0 -> f1 with two overtones (so
    it still reads on speakers that cannot reproduce 40 Hz), plucked."""
    curve = exp_curve(f0, f1, n_samples(seconds))
    return pluck(partials(curve, seconds, list(amps), max_hz=1400.0), tau, attack, tail=seconds * 0.3)


def _metal(freq, seconds, tau, amps=(1.0, 0.7, 0.4, 0.2), attack=0.0006):
    """A struck steel plate: free-bar mode ratios (1, 2.76, 5.40, 8.93) in the
    _bell voice, the upper modes dying faster."""
    return _bell(freq, seconds, tau, ratios=(1.0, 2.76, 5.40, 8.93), amps=amps, attack=attack)


def _clunk(freq, seed):
    """A dull hit on a heavy panel: a short pitch-dropped knock, a band-limited
    noise tick and a faint, quickly damped ring. Peak 1."""
    body = pluck(partials(exp_curve(freq * 1.25, freq, n_samples(0.12)), 0.12, [1.0, 0.5], max_hz=3000.0),
                 0.035, 0.0008, tail=0.05)
    knock = pluck(svf(noise(0.06, seed), freq * 5.0, 0.9, "bp"), 0.012, 0.0004, tail=0.03)
    ring = gain(_metal(freq * 2.3, 0.18, 0.05), 0.35)
    return normalize(mix(body, gain(knock, 0.8), ring), 1.0)


def _clatter(seconds, seed, parts, f_lo, f_hi, first=0.0, span=0.35, heavy=0.3, level=1.0):
    """Metal parts landing on a hard floor. Each of `parts` pieces lands at a
    random moment in the first `span` of the cue (after `first` seconds) and
    bounces a few times, the gaps shrinking and the level halving like a
    dropped plate coming to rest. A piece is a bright ping (a small plate,
    pitched between f_lo and f_hi) or, with chance `heavy`, a dull clunk (a
    chassis panel). A seed always renders the same pile."""
    n = n_samples(seconds)
    out = [0.0] * n
    rnd = random.Random(seed)
    pings = [normalize(_metal(f_lo * ((f_hi / f_lo) ** rnd.random()), 0.16, rnd.uniform(0.02, 0.05), attack=0.0005), 1.0)
             for _ in range(6)]
    clunks = [_clunk(rnd.uniform(170.0, 340.0), seed * 8 + j) for j in range(3)]
    for p in range(parts):
        voice = clunks[rnd.randrange(len(clunks))] if rnd.random() < heavy else pings[rnd.randrange(len(pings))]
        t = first + (0.0 if p == 0 else rnd.uniform(0.0, seconds * span))
        gap = rnd.uniform(0.045, 0.11)
        decel = rnd.uniform(0.62, 0.80)
        g = level * rnd.uniform(0.6, 1.0)
        while t < seconds - 0.04 and g > 0.05:
            i = int(t * SR)
            for k, v in enumerate(voice):
                if i + k >= n:
                    break
                out[i + k] += v * g
            t += gap * rnd.uniform(0.7, 1.3)
            gap *= decel
            g *= rnd.uniform(0.45, 0.65)
    return out


def _landing(seed, rustle=0.22):
    """A body landing on a hard floor: a dull torso thud, the hips and legs a
    beat behind, cloth and gear settling. Shared by body_fall and the Staffer's
    collapse so a person always lands the same way. Peak about 1.1."""
    torso = _thud(88.0, 42.0, 0.30, 0.055, attack=0.004)
    legs = gain(_thud(112.0, 56.0, 0.20, 0.040, attack=0.003), 0.5)
    whump = pluck(blp(noise(0.16, seed), 520.0), 0.035, 0.005, tail=0.06)
    cloth = pluck(blp(noise(0.30, seed + 2), 950.0), 0.09, 0.012, tail=0.12)
    scuff = gain(pluck(svf(noise(0.26, seed + 1), 1600.0, 0.6, "bp"), 0.06, 0.02, tail=0.10), rustle)
    return mix(torso, legs, gain(whump, 1.6), gain(cloth, 0.60), scuff,
               at=[0, n_samples(0.07), 0, n_samples(0.03), n_samples(0.11)])


def sfx_staffer_windup():
    # The attack tell (red Link light) of a driven office worker: the twitch is a
    # pair of small cloth rustles, and the implant's two-tone hum (a fourth
    # apart) climbs and flutters faster under a stepped, rising chirp that peaks
    # right as the 0.65 s windup ends. No servo: the body is a person's, only
    # the port makes a sound.
    dur = 0.62
    n = n_samples(dur)
    lo = exp_curve(hz("D4"), hz("A4"), n)
    hi = [f * (4.0 / 3.0) for f in lo]
    hum = mix(partials(lo, dur, [1.0, 0.26, 0.09], max_hz=5000.0),
              partials(hi, dur, [1.0, 0.26, 0.09], max_hz=6000.0))
    ph = 0.0
    flutter = [0.0] * n
    for i in range(n):
        ph += 2.0 * math.pi * (9.0 + 17.0 * (i / (n - 1))) / SR  # the twitch quickens
        flutter[i] = 0.72 + 0.28 * math.sin(ph)
    hum = [h * f for h, f in zip(hum, flutter)]
    hum = apply_env(hum, [(0, 0.0), (0.08, 0.6), (0.85, 1.0), (0.96, 0.9), (1.0, 0.0)])
    rustle_a = pluck(svf(noise(0.06, 751), 1500.0, 1.2, "bp"), 0.014, 0.004, tail=0.025)
    rustle_b = pluck(svf(noise(0.06, 752), 1200.0, 1.2, "bp"), 0.014, 0.004, tail=0.025)
    steps = 8
    parts, offs = [], []
    for k in range(steps):
        f = 1300.0 * ((3800.0 / 1300.0) ** (k / (steps - 1)))
        blip = apply_env(partials(f, 0.042, [1.0, 0.18], max_hz=9000.0),
                         [(0, 0.0), (0.06, 1.0), (0.55, 0.6), (1.0, 0.0)])
        parts.append(gain(blip, 0.34 + 0.66 * k / (steps - 1)))
        offs.append(n_samples(0.27 + 0.038 * k))
    chirp = mix(*parts, at=offs)
    out = mix(gain(hum, 0.6), gain(chirp, 0.5), gain(rustle_a, 0.34), gain(rustle_b, 0.26),
              at=[0, 0, n_samples(0.04), n_samples(0.16)])
    return finish(out, 0.9, fade_out_s=0.02)


def sfx_staffer_lunge():
    # The grab. Head and torso lead and the feet catch up, so it is all air and
    # cloth, and fast: a tight whoosh whose band leaps upward and peaks as the
    # arms come round, a dry swish of sleeve, a low thrust as the weight goes
    # forward, and the port's one small blip. No servo burst.
    dur = 0.24
    n = n_samples(dur)
    rise = int(n * 0.55)
    band = exp_curve(500.0, 3200.0, rise) + exp_curve(3200.0, 2500.0, n - rise)
    whoosh = svf(noise(dur, 302), band, q=1.8, mode="bp")
    whoosh = apply_env(whoosh, [(0, 0.0), (0.10, 0.45), (0.42, 1.0), (0.62, 0.65), (1.0, 0.0)])
    swish = svf(noise(dur, 753), 4200.0, 0.8, "bp")
    swish = apply_env(swish, [(0, 0.0), (0.3, 1.0), (0.55, 0.5), (1.0, 0.0)])
    thrust = _thud(150.0, 70.0, 0.14, 0.05)
    blip = apply_env(sweep(2500.0, 3500.0, 0.035, shape="exp"), [(0, 0.0), (0.15, 1.0), (1.0, 0.0)])
    out = mix(gain(whoosh, 1.4), gain(swish, 0.30), gain(thrust, 0.30), gain(blip, 0.18),
              at=[0, 0, n_samples(0.02), 0])
    return finish(out, 0.9, fade_out_s=0.03)


def sfx_staffer_defeat():
    # A collapse: the Link light dies and the body goes down. The port shorts in a
    # spit of sparks while a thin tone spools down through the top octaves (the
    # light going out); then the body lands 0.45 s after the kill, when the
    # ragdoll reaches the floor, with the same landing as body_fall. No groan,
    # no last word.
    fizz = _crackle(0.40, 761, 130.0, 10.0, 3000.0, 8000.0, 0.0018, curve=0.7)
    nf = n_samples(0.30)
    tone = partials(exp_curve(3400.0, 520.0, nf), 0.30, [1.0, 0.18], max_hz=8000.0)
    ph = 0.0
    for i in range(nf):
        ph += 2.0 * math.pi * (26.0 - 14.0 * (i / nf)) / SR
        tone[i] *= 0.6 + 0.4 * math.sin(ph)
    tone = apply_env(tone, [(0, 0.0), (0.05, 1.0), (0.55, 0.5), (1.0, 0.0)])
    pop = click(3200, 0.014, 0.004, 762, q=1.1)
    body = _landing(763)
    out = mix(gain(pop, 0.8), gain(fizz, 0.8), gain(tone, 0.42), body, at=[0, 0, 0, n_samples(0.45)])
    return finish(out, 0.9, fade_out_s=0.06)


def sfx_chip():
    # Crisp digital blip pair: an open fourth (A6 -> D7), pulse timbre.
    a = _blip(hz("A6"), 0.040, 0.010)
    b = _blip(hz("D7"), 0.090, 0.022)
    out = blp(mix(gain(a, 0.8), b, at=[0, n_samples(0.026)]), 5200.0)
    return finish(out, 0.9, fade_out_s=0.012)


def sfx_chip_cluster():
    # Brighter and multi-note: an open-fifth ladder D6-A6-D7-A7 with a
    # sparkle and a tiny slap on the last note.
    notes = ["D6", "A6", "D7", "A7"]
    step = 0.052
    parts, offs = [], []
    for j, nm in enumerate(notes):
        last = j == len(notes) - 1
        p = _blip(hz(nm), 0.20 if last else 0.06, 0.060 if last else 0.013,
                  duty=0.5 if last else 0.25)
        parts.append(gain(p, 0.68 + 0.1 * j))
        offs.append(n_samples(step * j))
    sparkle = pluck(sine(hz("D8"), 0.10), 0.022, 0.0005, tail=0.03)
    out = mix(*parts, gain(sparkle, 0.22), at=offs + [offs[-1]])
    out = echo(out, 0.07, 0.30, repeats=2, lp=0.5)
    out = blp(out, 6500.0)
    return finish(out, 0.9, fade_out_s=0.05)


def sfx_evidence():
    # A data-save chirp: quick burst of data chatter, then a small, quiet
    # rising three-note "file opened" phrase with a short room.
    chatter = ["G7", "D7", "A7", "F7", "C8", "G7", "A7"]
    parts, offs = [], []
    for j, nm in enumerate(chatter):
        b = _blip(hz(nm), 0.020, 0.0035, duty=0.25)
        parts.append(gain(b, 0.32 + 0.05 * j))
        offs.append(n_samples(0.022 * j))
    phrase = [("D5", 0.19), ("A5", 0.30), ("D6", 0.43)]
    for nm, t in phrase:
        parts.append(gain(_soft_tone(hz(nm), 0.42, 0.20, attack=0.006), 0.85))
        offs.append(n_samples(t))
    dry = blp(mix(*parts, at=offs), 8000.0)
    out = reverb(dry, rt60=0.9, damp=0.5, wet=0.22, predelay=0.012, tail=0.35)
    return finish(out, 0.88, fade_out_s=0.08)


def sfx_med_patch():
    # A soft pneumatic hiss, then a gentle two-note monitor beep.
    dur = 0.36
    hiss = svf(noise(dur, 304), 3600.0, q=0.55, mode="bp")
    hiss = blp(bhp(hiss, 1400.0), 6000.0)
    hiss = [h * math.exp(-(i / SR) / 0.10) for i, h in enumerate(hiss)]
    hiss = fade(hiss, 0.025, 0.05)
    beep1 = _soft_tone(hz("A5"), 0.16, 0.05, attack=0.008, amps=(1.0, 0.15))
    beep2 = _soft_tone(hz("D6"), 0.24, 0.08, attack=0.008, amps=(1.0, 0.15))
    out = mix(gain(hiss, 0.55), gain(beep1, 0.8), gain(beep2, 0.8),
              at=[0, n_samples(0.15), n_samples(0.27)])
    return finish(out, 0.85, fade_out_s=0.04)


def sfx_adam_chime():
    # Adam's PA chime: a falling fifth, A5 -> D5 — soft, corporate, reverberant.
    # Pleasant on first hearing, slightly wrong on second: D5 sits 35 cents
    # flat with an inharmonic ring on top and sags a little further as it
    # rings, and a ghost D3 blooms late in the tail like a second speaker in
    # another room.
    n1 = _bell(hz("A5"), 1.3, 0.50)
    n2 = _bell(cents(hz("D5"), -35.0), 1.7, 0.66, ratios=(1.0, 2.0, 3.02, 4.16), sag_cents=25.0)
    ghost = apply_env(sine(cents(hz("D3"), 22.0), 1.5), [(0, 0.0), (0.4, 1.0), (1.0, 0.0)])
    dry = mix(gain(n1, 0.9), gain(n2, 0.85), gain(ghost, 0.10),
              at=[0, n_samples(0.46), n_samples(0.85)])
    wet = reverb(dry, rt60=2.3, damp=0.55, wet=0.55, predelay=0.02, tail=0.6)
    wet = pad_to(wet, 2.7)
    return finish(wet, 0.88, fade_out_s=0.5)


def sfx_alarm():
    # A low emergency tone, never piercing: four alternating pulses, A3 / D3
    # (a falling fifth), detuned pairs so each pulse throbs. Everything above
    # ~1.1 kHz is gone; the loudest partials are under 500 Hz. Soft-clipped
    # before the filter to tame the peaks the detuned pair makes when it beats
    # (about 4 dB less crest), so it can sit next to the lockdown stinger,
    # which the game plays at the same instant, without hitting full scale.
    f_hi, f_lo = hz("A3"), hz("D3")
    pulses = []
    for k in range(4):
        f = f_hi if k % 2 == 0 else f_lo
        seg = mix(partials(f, 0.30, harm_saw(9), max_hz=1400.0),
                  partials(f * 1.006, 0.30, harm_saw(9), max_hz=1400.0))
        pulses.append(apply_env(seg, [(0, 0.0), (0.07, 1.0), (0.75, 0.9), (1.0, 0.0)]))
    gap = silence(0.07)
    out = concat(pulses[0], gap, pulses[1], gap, pulses[2], gap, pulses[3])
    out = blp(soft_clip(normalize(out, 1.0), 2.5), 1100.0, 0.7)
    return finish(out, 0.85, fade_out_s=0.05)


def sfx_lockdown():
    # Alarm stinger for the moment the lockdown starts: a low double pulse
    # (heartbeat, not a hit), then the PA chime again, lower, colder and
    # fading — restrained, never a jump scare. It overlaps sfx_alarm(), which
    # plays at the same instant: the pulse lands under the klaxon's first note
    # and the chime sits in the same key (A/D) above it.
    def pulse(f0, f1, tau, seconds):
        # sub sweep plus two upper harmonics, so the pulse still reads on
        # speakers that cannot reproduce 40 Hz
        return mix(pluck(sweep(f0, f1, seconds, shape="exp"), tau, 0.004, tail=0.1),
                   gain(pluck(sweep(2 * f0, 2 * f1, seconds, shape="exp"), tau * 0.6, 0.004, tail=0.1), 0.5),
                   gain(pluck(sweep(3 * f0, 3 * f1, seconds, shape="exp"), tau * 0.4, 0.004, tail=0.1), 0.25))
    boom = pulse(88, 38, 0.28, 0.9)
    thud = pluck(blp(noise(0.12, 401), 380.0), 0.03, 0.001, tail=0.05)
    second = gain(pulse(80, 42, 0.20, 0.6), 0.55)
    c1 = _bell(hz("A4"), 1.6, 0.62)
    c2 = _bell(cents(hz("D4"), -50.0), 2.0, 0.85, ratios=(1.0, 2.0, 3.02, 4.16), sag_cents=20.0)
    rub = apply_env(mix(sine(hz("A3"), 1.6), sine(hz("Bb3"), 1.6)),
                    [(0, 0.0), (0.35, 1.0), (1.0, 0.0)])
    dry = mix(gain(boom, 0.40), gain(thud, 0.20), gain(second, 0.60), gain(c1, 0.50), gain(c2, 0.47), gain(rub, 0.08),
              at=[0, 0, n_samples(0.34), n_samples(0.62), n_samples(1.05), n_samples(0.9)])
    wet = reverb(dry, rt60=2.8, damp=0.6, wet=0.5, predelay=0.03, tail=0.5)
    wet = pad_to(wet, 3.0)
    return finish(wet, 0.9, fade_out_s=0.6)


def sfx_keycard():
    # Pickup chirp: a card swipe, then a short rising two-note access tone
    # (D5 -> A5, the same fifth the unlock beep answers an octave higher).
    swipe = svf(noise(0.07, 501), exp_curve(2200.0, 6200.0, n_samples(0.07)), q=1.4, mode="bp")
    swipe = apply_env(swipe, [(0, 0.0), (0.5, 1.0), (1.0, 0.0)])
    n1 = _soft_tone(hz("D5"), 0.11, 0.05, attack=0.004, amps=(1.0, 0.35, 0.12))
    n2 = _soft_tone(hz("A5"), 0.26, 0.10, attack=0.004, amps=(1.0, 0.35, 0.12))
    out = mix(gain(swipe, 0.32), gain(n1, 0.8), gain(n2, 0.85),
              at=[0, n_samples(0.06), n_samples(0.14)])
    return finish(out, 0.88, fade_out_s=0.03)


def sfx_keycard_denied():
    # A short, soft, low reader buzz: two pulses around D3 with a reader
    # click in front. Lowpassed so it says "no" without nagging.
    def buzz(seconds):
        f = hz("D3")
        x = mix(partials(f, seconds, harm_square(7), max_hz=1100.0),
                partials(f * 1.012, seconds, harm_square(7), max_hz=1100.0))
        return apply_env(x, [(0, 0.0), (0.10, 1.0), (0.8, 0.85), (1.0, 0.0)])
    b = buzz(0.095)
    body = blp(concat(b, silence(0.05), b), 700.0)
    tick = gain(click(1300, 0.012, 0.004, 502, q=1.5), 0.5)
    out = mix(tick, body, at=[0, n_samples(0.008)])
    return finish(out, 0.8, fade_out_s=0.02)


def sfx_door_unlock():
    # A mechanical bolt clunk and retract clack, then a two-note teal
    # confirmation beep (D6 -> A6) in a small room.
    clunk = pluck(sweep(105, 52, 0.16, shape="exp"), 0.055, 0.002, tail=0.08)
    clunk_click = gain(click(1700, 0.02, 0.006, 601, q=1.2), 0.7)
    clack = gain(click(2600, 0.02, 0.005, 602, q=1.5), 0.5)
    clack_body = gain(pluck(sweep(160, 90, 0.08, shape="exp"), 0.03, 0.001, tail=0.04), 0.5)
    b1 = _soft_tone(hz("D6"), 0.16, 0.07, attack=0.004, amps=(1.0, 0.25, 0.15))
    b2 = _soft_tone(hz("A6"), 0.30, 0.12, attack=0.004, amps=(1.0, 0.25, 0.15))
    dry = mix(gain(clunk, 0.75), gain(clunk_click, 0.8), gain(clack, 0.8), gain(clack_body, 0.8), gain(b1, 0.7), gain(b2, 0.75),
              at=[0, 0, n_samples(0.085), n_samples(0.085), n_samples(0.20), n_samples(0.28)])
    out = reverb(dry, rt60=0.7, damp=0.5, wet=0.22, tail=0.3)
    return finish(out, 0.9, fade_out_s=0.06)


def sfx_uplink():
    # Data-transfer tick, played every ~0.45 s during the SC01 copy bar: three
    # micro pulses. Short and soft so 8 repeats never fatigue.
    notes = [hz("G7"), hz("D7"), hz("A7")]
    parts, offs = [], []
    for j, f in enumerate(notes):
        b = apply_env(partials(f, 0.014, harm_pulse(0.125, 8), max_hz=8500.0),
                      [(0, 0.0), (0.1, 1.0), (1.0, 0.0)])
        parts.append(gain(b, 0.85 - 0.12 * j))
        offs.append(n_samples(0.019 * j))
    out = blp(mix(*parts, at=offs), 6500.0)
    return finish(out, 0.8, fade_out_s=0.006)


def sfx_link_chirp():
    # A tiny implant chirp (teal idle state): two soft rising sweeps.
    c1 = apply_env(sweep(2500, 3300, 0.026, shape="exp"), [(0, 0.0), (0.15, 1.0), (1.0, 0.0)])
    c2 = apply_env(sweep(3000, 4000, 0.034, shape="exp"), [(0, 0.0), (0.12, 1.0), (1.0, 0.0)])
    out = mix(c1, gain(c2, 0.8), at=[0, n_samples(0.030)])
    return finish(out, 0.7, fade_out_s=0.006)


def sfx_exit():
    # Level-completion sting: a rising open-fifth ladder (D4-A4-D5-A5) over a
    # low D/A swell, resolved but cool — you got out, and Adam knows. The top
    # note has a faint detuned twin. Same key as the unlock beep it follows.
    notes = ["D4", "A4", "D5", "A5"]
    parts, offs = [], []
    for j, nm in enumerate(notes):
        parts.append(gain(_bell(hz(nm), 1.5, 0.55), 0.8))
        offs.append(n_samples(0.16 * j))
    twin = gain(_bell(cents(hz("A5"), 12.0), 1.3, 0.5), 0.3)
    swell = apply_env(mix(sine(hz("D2"), 1.9), sine(hz("A2"), 1.9)),
                      [(0, 0.0), (0.3, 1.0), (1.0, 0.0)])
    dry = mix(*parts, twin, gain(swell, 0.35), at=offs + [offs[-1], 0])
    wet = reverb(dry, rt60=2.0, damp=0.5, wet=0.4, predelay=0.02, tail=0.5)
    return finish(pad_to(wet, 2.4), 0.88, fade_out_s=0.4)


# --- the Level 1 roster (C33): Night Guard, people going down, Patrol Rover ------
# Human combat is restrained and a little wet (audio-direction.md: a short thud,
# never a splatter); machines break in metal, sparks and clatter. The baton, hit
# and fall cues started as the lit-cutout test's placeholders (baton_crackle,
# baton_swing, flesh_hit, body_fall, from the since-removed
# tools/spike/make_spike_audio.py) and were rebuilt here on the shared DSP
# helpers so they match the rest of the set.

def sfx_guard_windup():
    # The Night Guard hauls the baton overhead: a stun baton charging, about 0.5 s.
    # A hard mains buzz (a pulse wave gliding A2 -> D3, a rising fourth, in two
    # detuned twins) whose filter opens as the charge builds, over a raspy arc
    # that stutters at 18 Hz and quickens to 44 Hz until it fuses into one
    # continuous zap, plus a thin capacitor whine and a crackle that goes from
    # sparse to spitting right as the swing lands. A thumb-switch click opens it.
    dur = 0.5
    n = n_samples(dur)
    f0, f1 = hz("A2"), hz("D3")
    curve = [f0 * ((f1 / f0) ** ((i / (n - 1)) ** 1.5)) for i in range(n)]
    pulse = harm_pulse(0.16, 30)
    buzz = mix(partials(curve, dur, pulse, max_hz=5200.0),
               gain(partials([f * 1.012 for f in curve], dur, pulse, max_hz=5200.0), 0.7))
    buzz = svf(buzz, exp_curve(420.0, 3600.0, n), q=0.9, mode="lp")
    buzz = soft_clip(normalize(buzz, 1.0), 2.4)
    buzz = apply_env(buzz, [(0, 0.0), (0.03, 0.30), (0.75, 0.80), (0.97, 1.0), (1.0, 0.0)])
    rasp = svf(noise(dur, 703), exp_curve(1800.0, 3200.0, n), q=1.2, mode="bp")
    ph = 0.0
    for i in range(n):
        ph += 2.0 * math.pi * (18.0 + 26.0 * (i / (n - 1))) / SR
        rasp[i] *= max(0.0, math.sin(ph)) ** 3
    rasp = apply_env(rasp, [(0, 0.0), (0.1, 0.15), (0.8, 0.8), (0.97, 1.0), (1.0, 0.0)])
    whine = apply_env(sweep(1000.0, 2500.0, dur, shape="exp"),
                      [(0, 0.0), (0.4, 0.25), (0.95, 1.0), (1.0, 0.0)])
    crack = _crackle(dur, 701, 6.0, 95.0, 1500.0, 6500.0, 0.0035, level=(0.3, 0.8), curve=1.7)
    switch = click(1500, 0.03, 0.008, 702, q=1.2)
    out = mix(gain(buzz, 0.7), gain(rasp, 1.0), gain(whine, 0.12), gain(crack, 0.5), gain(switch, 0.5))
    return finish(soft_clip(out, 1.0), 0.9, fade_out_s=0.02)


def sfx_guard_swing():
    # One short, hard overhead swing: air rushing past a heavy baton. A band of
    # noise that climbs as the arm comes over and falls as it lands, a low
    # pressure pulse for the weight, and the baton's mains buzz caught under it
    # for a moment (with a few sparks) so it is his baton and not a bat.
    dur = 0.30
    n = n_samples(dur)
    half = n // 2
    band = exp_curve(600.0, 2300.0, half) + exp_curve(2300.0, 750.0, n - half)
    air = svf(noise(dur, 711), band, q=2.0, mode="bp")
    air = apply_env(air, [(0, 0.0), (0.16, 0.85), (0.38, 1.0), (0.70, 0.45), (1.0, 0.0)])
    weight = apply_env(blp(noise(dur, 712), 380.0), [(0, 0.0), (0.2, 1.0), (0.5, 0.75), (1.0, 0.0)])
    hum = apply_env(partials(hz("D3"), dur, harm_pulse(0.2, 14), max_hz=3500.0),
                    [(0, 0.0), (0.15, 1.0), (0.6, 0.7), (1.0, 0.0)])
    sparks = _crackle(dur, 713, 45.0, 8.0, 2000.0, 7000.0, 0.003, level=(0.2, 0.5))
    out = mix(gain(air, 1.5), gain(weight, 1.2), gain(hum, 0.10), gain(sparks, 0.30))
    return finish(out, 0.9, fade_out_s=0.05)


def sfx_hit_flesh():
    # A restrained wet impact on a person (audio-direction.md: a short thud, never
    # a splatter): a short low thump for the blow, a damp slap on top, and a
    # small moist squelch riding the tail. Nothing bright.
    thump = _thud(125.0, 62.0, 0.12, 0.030, amps=(1.0, 0.40, 0.15))
    slap = pluck(blp(noise(0.08, 721), 2400.0), 0.025, 0.0007, tail=0.03)
    wet = svf(noise(0.16, 722), exp_curve(1250.0, 380.0, n_samples(0.16)), q=2.4, mode="bp")
    wet = pluck(wet, 0.045, 0.004, tail=0.08)
    out = mix(gain(thump, 0.8), gain(slap, 1.4), gain(wet, 0.7), at=[0, 0, n_samples(0.012)])
    return finish(out, 0.9, fade_out_s=0.03)


def sfx_body_fall():
    # A body landing: a dull thud (the torso), the hips and legs a beat behind,
    # cloth and gear settling. Low and short, with no clank in it.
    return finish(_landing(731), 0.9, fade_out_s=0.06)


def sfx_rover_patrol():
    # The Patrol Rover's idle roll, quiet: an electric drive hum (a soft A3 with a
    # slow wobble and a thin upper whine), tread ticking over paving joints, and
    # two small relay ticks. Faded at both ends so plays that follow each other
    # overlap into one steady roll.
    dur = 0.62
    n = n_samples(dur)
    wob = [220.0 * (1.0 + 0.012 * math.sin(2.0 * math.pi * 3.0 * (i / SR))) for i in range(n)]
    hum = blp(partials(wob, dur, [1.0, 0.5, 0.32, 0.18, 0.1], max_hz=3200.0), 1500.0)
    whine = partials([f * 4.0 for f in wob], dur, [1.0, 0.3], max_hz=4000.0)
    tread = blp(noise(dur, 741), 520.0)
    tread = [t * (0.55 + 0.45 * math.sin(2.0 * math.pi * 9.0 * (i / SR)) ** 2) for i, t in enumerate(tread)]
    body = mix(gain(hum, 0.8), gain(whine, 0.10), gain(tread, 0.9))
    body = apply_env(body, [(0, 0.0), (0.10, 1.0), (0.80, 0.85), (1.0, 0.0)])
    tick_a = click(2100, 0.02, 0.004, 742, q=1.3)
    tick_b = click(1700, 0.02, 0.004, 743, q=1.3)
    out = mix(body, gain(tick_a, 0.35), gain(tick_b, 0.22), at=[0, n_samples(0.03), n_samples(0.33)])
    return finish(out, 0.85, fade_in_s=0.04, fade_out_s=0.10)


def sfx_rover_windup():
    # The rock-back before the ram (lightbar amber, then red for the last quarter
    # second): a two-part siren whoop, each part a rising sweep and the second
    # climbing higher, over wheel-spin revs that climb the whole way. It sits
    # mostly under about 2 kHz, so it warns without shrieking.
    dur = 0.80
    n = n_samples(dur)
    na = n_samples(0.40)
    siren_hz = exp_curve(270.0, 700.0, na) + exp_curve(330.0, 980.0, n - na)
    siren = partials(siren_hz, dur, harm_saw(6), max_hz=4000.0)
    siren = svf(siren, 2200.0, q=0.7, mode="lp")
    siren = apply_env(siren, [(0, 0.0), (0.02, 0.8), (0.47, 1.0), (0.495, 0.35), (0.52, 0.9), (0.97, 1.0), (1.0, 0.0)])
    drive = partials(exp_curve(150.0, 640.0, n), dur, [1.0, 0.6, 0.35, 0.2], max_hz=3500.0)
    rev = 0.0
    for i in range(n):
        f = 150.0 * ((640.0 / 150.0) ** (i / (n - 1)))
        rev += 2.0 * math.pi * (f / 7.0) / SR  # the rotor's grain follows the pitch
        drive[i] *= 0.78 + 0.22 * math.sin(rev)
    drive = apply_env(drive, [(0, 0.0), (0.10, 0.5), (0.9, 1.0), (1.0, 0.0)])
    slip = svf(noise(dur, 751), 1800.0, q=1.1, mode="bp")
    ph = 0.0
    for i in range(n):
        ph += 2.0 * math.pi * (10.0 + 24.0 * (i / (n - 1))) / SR  # the tread bites faster and faster
        slip[i] *= 0.55 + 0.45 * math.sin(ph)
    slip = apply_env(slip, [(0, 0.0), (0.1, 0.25), (0.95, 1.0), (1.0, 0.0)])
    out = mix(gain(siren, 0.85), gain(drive, 0.40), gain(slip, 0.28))
    return finish(out, 0.9, fade_out_s=0.02)


def sfx_rover_charge():
    # The ram: the drive motor surges (a hard, gritty pitch climb) with the tyres
    # biting into the deck, a low kick as the wheels grab, and the tread rumble
    # that follows. No siren, so it never reads as the windup again.
    dur = 0.80
    n = n_samples(dur)
    surge = partials(exp_curve(170.0, 540.0, n), dur, [1.0, 0.75, 0.55, 0.38, 0.25, 0.16, 0.10], max_hz=4200.0)
    surge = soft_clip(normalize(surge, 1.0), 2.2)
    surge = svf(surge, exp_curve(700.0, 2600.0, n), q=0.8, mode="lp")
    surge = apply_env(surge, [(0, 0.0), (0.04, 1.0), (0.55, 0.85), (1.0, 0.0)])
    rumble = blp(noise(dur, 761), 800.0)
    rumble = [r * (0.6 + 0.4 * math.sin(2.0 * math.pi * 26.0 * (i / SR))) for i, r in enumerate(rumble)]
    rumble = apply_env(rumble, [(0, 0.0), (0.06, 0.7), (0.6, 1.0), (1.0, 0.0)])
    kick = _thud(120.0, 52.0, 0.16, 0.05)
    out = mix(gain(surge, 0.75), gain(rumble, 1.0), gain(kick, 0.6))
    return finish(out, 0.9, fade_out_s=0.05)


def sfx_rover_stall():
    # The ram meets a wall: a crash (a heavy slam, a crunch of shell, a ringing
    # steel rebound), the wheels spinning down against the wall, and the
    # electronics fizzing and sputtering out. Just under a second.
    slam = _thud(150.0, 46.0, 0.34, 0.085, attack=0.002)
    crunch = pluck(svf(noise(0.20, 771), 1300.0, 0.5, "bp"), 0.045, 0.0006, tail=0.08)
    ring = gain(_metal(410.0, 0.55, 0.17, attack=0.0007), 0.5)
    rebound = gain(_metal(545.0, 0.35, 0.10, attack=0.0007), 0.28)
    crash = mix(gain(slam, 1.0), gain(crunch, 0.8), ring, rebound, at=[0, 0, 0, n_samples(0.045)])
    ns = n_samples(0.85)
    spin = partials(exp_curve(520.0, 110.0, ns), 0.85, [1.0, 0.5, 0.28], max_hz=3000.0)
    ph = 0.0
    for i in range(ns):
        ph += 2.0 * math.pi * (28.0 - 18.0 * (i / ns)) / SR  # the grain slows as the wheels wind down
        spin[i] *= 0.8 + 0.2 * math.sin(ph)
    spin = apply_env(spin, [(0, 0.0), (0.05, 1.0), (0.7, 0.5), (1.0, 0.0)])
    slip = apply_env(svf(noise(0.85, 772), 2300.0, 0.6, "bp"), [(0, 0.0), (0.05, 1.0), (0.6, 0.3), (1.0, 0.0)])
    fizz = _crackle(0.85, 773, 210.0, 12.0, 2500.0, 7500.0, 0.002, level=(0.25, 0.8), curve=0.7)
    arc = partials(hz("D3"), 0.85, harm_square(13), max_hz=2800.0)
    arc = [a * g for a, g in zip(arc, _gate(0.85, 774, 0.025, 0.9, 0.05))]
    arc = apply_env(arc, [(0, 0.0), (0.05, 1.0), (0.5, 0.5), (1.0, 0.0)])
    at = n_samples(0.06)
    out = mix(crash, gain(spin, 0.30), gain(slip, 0.22), gain(fizz, 0.40), gain(arc, 0.14),
              at=[0, at, at, n_samples(0.10), n_samples(0.10)])
    return finish(out, 0.9, fade_out_s=0.10)


def sfx_rover_armor():
    # The armored front turns a shot: a hard steel clang (two slightly detuned
    # plate strikes), a padded knock under it, the strike's tick, and the bolt
    # whining away.
    clang = mix(_metal(1180.0, 0.40, 0.11), gain(_metal(1247.0, 0.40, 0.10), 0.6))
    knock = _thud(340.0, 170.0, 0.10, 0.028, attack=0.0008, amps=(1.0, 0.5))
    tick = click(3200, 0.02, 0.005, 781, q=1.4)
    zing = pluck(sweep(3900.0, 1500.0, 0.09, shape="exp"), 0.03, 0.0006, tail=0.04)
    out = mix(gain(clang, 0.85), gain(knock, 0.55), gain(tick, 0.5), gain(zing, 0.18),
              at=[0, 0, 0, n_samples(0.012)])
    return finish(out, 0.9, fade_out_s=0.08)


def sfx_rover_destroyed():
    # A small machine bursting: a crump (a low thump and a gust of noise, pressed
    # together so the burst is dense rather than spiky) with sparks spitting, the
    # electronics dropping away, a brief hiss of oil, and the parts clattering
    # down as they land. Just under a second.
    thump = _thud(170.0, 45.0, 0.35, 0.10, attack=0.002)
    gust = pluck(blp(noise(0.25, 791), 3200.0), 0.07, 0.001, tail=0.08)
    sparks = _crackle(0.45, 792, 120.0, 20.0, 2500.0, 8000.0, 0.002, level=(0.25, 0.7), curve=0.8)
    burst = soft_clip(mix(gain(thump, 1.0), gain(gust, 0.9), gain(sparks, 0.6), at=[0, 0, n_samples(0.02)]), 1.4)
    nd = n_samples(0.40)
    dying = partials(exp_curve(900.0, 90.0, nd), 0.40, [1.0, 0.4], max_hz=3000.0)
    dying = apply_env(dying, [(0, 0.0), (0.03, 1.0), (0.5, 0.45), (1.0, 0.0)])
    oil = apply_env(svf(noise(0.30, 793), 4200.0, 0.6, "bp"), [(0, 0.0), (0.12, 1.0), (1.0, 0.0)])
    clatter = _clatter(0.78, 794, 10, 700.0, 3600.0, first=0.08, span=0.45)
    out = mix(gain(burst, 1.0), gain(dying, 0.28), gain(oil, 0.13), gain(clatter, 0.75),
              at=[0, 0, n_samples(0.25), n_samples(0.12)])
    return finish(out, 0.9, fade_out_s=0.15)


def sfx_debris_clatter():
    # Metal parts landing: five small pieces bouncing to rest (a dome, a lightbar,
    # a hatch lid, wheels), mostly bright pings with a duller clunk or two.
    return finish(_clatter(0.60, 801, 5, 900.0, 4200.0, heavy=0.35), 0.9, fade_out_s=0.08)


SFX_GENERATORS = {
    "pistol_fire": sfx_pistol_fire,
    "pistol_fire_quick": sfx_pistol_fire_quick,
    "bolt_hit": sfx_bolt_hit,
    "bolt_blocked": sfx_bolt_blocked,
    "hero_hurt": sfx_hero_hurt,
    "hero_jump": sfx_hero_jump,
    "hero_land": sfx_hero_land,
    "staffer_windup": sfx_staffer_windup,
    "staffer_lunge": sfx_staffer_lunge,
    "staffer_defeat": sfx_staffer_defeat,
    "chip": sfx_chip,
    "chip_cluster": sfx_chip_cluster,
    "cache_open": sfx_cache_open,
    "evidence": sfx_evidence,
    "med_patch": sfx_med_patch,
    "interact": sfx_interact,
    "checkpoint": sfx_checkpoint,
    "purchase": sfx_purchase,
    "swap": sfx_swap,
    "latch": sfx_latch,
    "adam_chime": sfx_adam_chime,
    "alarm": sfx_alarm,
    "hatch_open": sfx_hatch_open,
    "pit_fall": sfx_pit_fall,
    "exit": sfx_exit,
    "ui_move": sfx_ui_move,
    "ui_confirm": sfx_ui_confirm,
    "ui_back": sfx_ui_back,
    "save_failed": sfx_save_failed,
    "keycard": sfx_keycard,
    "keycard_denied": sfx_keycard_denied,
    "door_unlock": sfx_door_unlock,
    "uplink": sfx_uplink,
    "lockdown": sfx_lockdown,
    "link_chirp": sfx_link_chirp,
    "guard_windup": sfx_guard_windup,
    "guard_swing": sfx_guard_swing,
    "hit_flesh": sfx_hit_flesh,
    "body_fall": sfx_body_fall,
    "rover_patrol": sfx_rover_patrol,
    "rover_windup": sfx_rover_windup,
    "rover_charge": sfx_rover_charge,
    "rover_stall": sfx_rover_stall,
    "rover_armor": sfx_rover_armor,
    "rover_destroyed": sfx_rover_destroyed,
    "debris_clatter": sfx_debris_clatter,
}


# ---------------------------------------------------------------------------
# Music loops. Both are built on a loop-locked drone (exact integer cycles per
# loop), with every other layer added through _wrap_add() so anything that
# rings past the end of the buffer wraps around to its start, and every
# stateful effect (reverb, lowpassed noise) run over the loop twice with only
# the second pass kept. The loop point is therefore continuous by construction
# (tests/cases/test_m6_audio.gd checks the seam on the written files).
# ---------------------------------------------------------------------------

def _wrap_add(buf, samples, start, k=1.0):
    n = len(buf)
    start %= n
    m = len(samples)
    first = min(m, n - start)
    for i in range(first):
        buf[start + i] += samples[i] * k
    for i in range(first, m):
        buf[i - first] += samples[i] * k


def _acc(target, src, k=1.0):
    for i, v in enumerate(src):
        target[i] += v * k


def _lock_sine(freq, L, n, amp, am_cycles=0, am_depth=0.0, am_phase=0.0, phase=0.0):
    """Sine with an exact whole number of cycles per loop, optionally with a
    slow amplitude swell of `am_cycles` whole cycles per loop."""
    w = 2.0 * math.pi * loop_locked_freq(freq, L) / SR
    if am_cycles <= 0:
        return [amp * math.sin(w * i + phase) for i in range(n)]
    v = 2.0 * math.pi * am_cycles / n
    return [amp * math.sin(w * i + phase) * (1.0 + am_depth * math.sin(v * i + am_phase)) for i in range(n)]


def _breath(n, t0, t1):
    """Raised-cosine swell, exactly 0 outside [t0, t1] seconds: a slow breath
    that starts and ends silent inside the loop."""
    e = [0.0] * n
    i0 = int(t0 * SR)
    i1 = min(int(t1 * SR), n)
    span = max(1, i1 - i0)
    for i in range(i0, i1):
        e[i] = 0.5 - 0.5 * math.cos(2.0 * math.pi * (i - i0) / span)
    return e


def _loop_reverb(send, **kw):
    """Steady-state reverb of a periodic signal: run it twice back-to-back,
    keep the second pass (so the tail of the end wraps into the start)."""
    n = len(send)
    return reverb(list(send) + list(send), tail=0.0, dry=0.0, **kw)[n:2 * n]


def _ping(freq):
    # Sonar-style ping: a near-pure sine with a small downward glide.
    dur = 1.5
    n = n_samples(dur)
    curve = [freq * (1.0 + 0.035 * math.exp(-(i / SR) / 0.05)) for i in range(n)]
    x = partials(curve, dur, [1.0, 0.10, 0.03], max_hz=6000.0)
    return pluck(x, 0.30, 0.002, tail=0.15)


def _sum_layers(layers, levels_db):
    out = None
    for name, buf in layers.items():
        g = 10.0 ** (levels_db.get(name, 0.0) / 20.0)
        if out is None:
            out = [v * g for v in buf]
        else:
            for i, v in enumerate(buf):
                out[i] += v * g
    return out


def _finish_loop(x, rms_db, peak_ceiling=0.8):
    mean = sum(x) / len(x)
    x = [v - mean for v in x]
    rms = math.sqrt(sum(v * v for v in x) / len(x))
    k = (10.0 ** (rms_db / 20.0)) / max(rms, 1e-9)
    x = [v * k for v in x]
    pk = max(abs(v) for v in x)
    if pk > peak_ceiling:
        x = [v * peak_ceiling / pk for v in x]
    return x


# The "mix desks": per-layer level in dB, applied to layers rendered at their
# natural amplitude. Dry layers go straight into the mix; send layers are
# summed into one reverb bus (and `BLEED` leaks a little of a send layer
# into the dry mix so pings and clicks keep an attack). The overall RMS is
# then set by CAMPUS_RMS_DB / LOCKDOWN_RMS_DB. Both loops land near -29 dB
# A-weighted (about 8-10 dB under the average SFX as played, so effects stay
# on top and the music stays a bed) with peaks around -6 / -4 dBFS, leaving
# headroom for SFX on the same master bus. Most of the raw RMS is low
# drone that a laptop speaker drops below ~100 Hz, hence the mid-range body.
CAMPUS_DRY_DB = {"sub": -14.0, "body": 0.0, "swell": 6.0, "hum": 2.0, "air": 0.0, "heart": -2.0}
CAMPUS_SEND_DB = {"shimmer": 0.0, "pings": -8.0, "ghost": -6.0, "clicks": 8.0}
CAMPUS_BLEED_DB = {"pings": -20.0, "clicks": -12.0}
CAMPUS_RMS_DB = -21.0

LOCKDOWN_DRY_DB = {"bed": 0.0, "bass": 0.0, "ticks": 2.0}
LOCKDOWN_SEND_DB = {"motif": -9.0}
LOCKDOWN_RMS_DB = -19.5


def _campus_layers():
    # Campus at night (levels 1-3): a dark, sparse ambient bed at 60 BPM, 12
    # bars. Low D drone with an open fifth and slowly beating twins, mains
    # hum and HVAC breath far off, occasional sonar pings with dark echoes,
    # a soft double-pulse heartbeat, distant relay clicks — and once per loop
    # a ghost of Arcadia's PA chime, detuned and half a room away. A flattened
    # second (Eb) breathes in and out through the middle: Adam noticing Dave.
    n = n_samples(48.0)
    L = n / SR
    dry = {k: [0.0] * n for k in ("sub", "body", "swell", "hum", "air", "heart")}
    send = {k: [0.0] * n for k in ("shimmer", "pings", "ghost", "clicks")}

    d2 = hz("D2")
    _acc(dry["sub"], _lock_sine(hz("D1"), L, n, 0.30))
    _acc(dry["sub"], _lock_sine(d2, L, n, 0.28, am_cycles=2, am_depth=0.3, am_phase=0.5))
    # dark saw-ish body: harmonics of D2 with no 5th (no bright major third),
    # each in two twins +0.0625 Hz apart (a 16 s beat), each with its own slow swell
    body = [(2, 0.30), (3, 0.28), (4, 0.20), (6, 0.10), (7, 0.06), (8, 0.04)]
    for j, (k, a) in enumerate(body):
        for twin, dt in enumerate((0.0, 3.0 / L)):
            _acc(dry["body"], _lock_sine(d2 * k + dt, L, n, a * 0.5, am_cycles=2 + (j % 3),
                                         am_depth=0.35, am_phase=1.7 * j + twin))
    _acc(dry["body"], _lock_sine(hz("A2"), L, n, 0.12, am_cycles=2, am_depth=0.5, am_phase=0.8))
    swell = _breath(n, 13.0, 37.0)
    for f, a in ((hz("Eb3"), 0.05), (hz("Eb4"), 0.022), (hz("Eb5"), 0.02)):  # upper Eb kept low: its beat against the D drone is rough
        tone = _lock_sine(f, L, n, a)
        _acc(dry["swell"], [t * s for t, s in zip(tone, swell)])
    _acc(send["shimmer"], _lock_sine(hz("A4"), L, n, 0.04, am_cycles=3, am_depth=0.9, am_phase=0.3))

    # distant hum: 60 Hz mains + harmonics, with a slowly beating twin
    for h, a in ((60.0, 0.05), (120.0, 0.045), (180.0, 0.025)):
        _acc(dry["hum"], _lock_sine(h, L, n, a, am_cycles=3, am_depth=0.3, am_phase=h))
        _acc(dry["hum"], _lock_sine(h + 0.25, L, n, a * 0.6))
    air = noise(48.0, SEED + 11)
    air = lowpass(air + air, 0.045)[n:]
    rms_air = math.sqrt(sum(v * v for v in air) / n)
    v_air = 2.0 * math.pi * 2 / n
    _acc(dry["air"], [v / rms_air * 0.05 * (1.0 + 0.5 * math.sin(v_air * i)) for i, v in enumerate(air)])

    # sonar pings (irregular on purpose: the order slips as Adam notices)
    rnd = random.Random(SEED + 12)
    pings = [(4.9, "A5", 1.0), (9.7, "D5", 0.8), (17.6, "F5", 0.85), (22.4, "Eb5", 0.7),
             (28.9, "A5", 0.9), (34.6, "D5", 0.75), (41.7, "F5", 0.8)]
    for t, nm, a in pings:
        p = echo(_ping(hz(nm)), 0.75, 0.42, repeats=3, lp=0.5)
        _wrap_add(send["pings"], p, int((t + rnd.uniform(-0.05, 0.05)) * SR), a)

    # ghost of the corporate jingle: A4 -> D4, the second a little flat
    g1 = _bell(hz("A4"), 2.2, 0.9)
    g2 = _bell(cents(hz("D4"), -60.0), 2.8, 1.1, ratios=(1.0, 2.0, 3.02, 4.16), sag_cents=20.0)
    _wrap_add(send["ghost"], g1, int(25.6 * SR), 1.0)
    _wrap_add(send["ghost"], g2, int(26.55 * SR), 0.9)

    # soft double-pulse heartbeat every 8 s, skipping the ghost jingle's slot
    # (sub + a little 2nd harmonic)
    for t in (2.0, 10.0, 18.0, 34.0, 42.0):
        lub = mix(pluck(sweep(64, 38, 0.5, shape="exp"), 0.11, 0.004, tail=0.15),
                  gain(pluck(sweep(128, 76, 0.4, shape="exp"), 0.07, 0.004, tail=0.12), 0.4))
        dub = gain(lub, 0.6)
        _wrap_add(dry["heart"], lub, int(t * SR))
        _wrap_add(dry["heart"], dub, int((t + 0.36) * SR))

    # distant relay clicks
    for j, t in enumerate((7.3, 14.9, 22.6, 30.4, 37.7, 44.6)):
        _wrap_add(send["clicks"], click(1800, 0.02, 0.004, SEED + 30 + j, q=2.0), int(t * SR))
    return dry, send


def music_campus_loop():
    dry, send = _campus_layers()
    mixed = _sum_layers(dry, CAMPUS_DRY_DB)
    wet = _loop_reverb(_sum_layers(send, CAMPUS_SEND_DB), rt60=4.5, damp=0.55, wet=1.0, predelay=0.03)
    for name, db in CAMPUS_BLEED_DB.items():
        _acc(mixed, send[name], 10.0 ** ((CAMPUS_SEND_DB[name] + db) / 20.0))
    _acc(mixed, wet)
    return _finish_loop(mixed, CAMPUS_RMS_DB)


def _lockdown_layers():
    # Lockdown (after SC01): the same D, now under pressure — 96 BPM, 12 bars,
    # a pulsing low bass, a muffled far-off two-tone alarm motif (one note per
    # beat, then a long rest, so it never reads as an attack tell), a dry clock
    # ticking on every beat, and the flattened second (Eb) pressing in under
    # the bass in bars 5-6 and 11-12. Urgent, not harsh: nothing bright,
    # nothing loud, no riser.
    n = n_samples(30.0)
    L = n / SR
    beat = L / 48.0
    dry = {k: [0.0] * n for k in ("bed", "bass", "ticks")}
    send = {"motif": [0.0] * n}

    # drone bed, ducked on every beat so the whole thing pulses
    bed = [0.0] * n
    d2 = hz("D2")
    _acc(bed, _lock_sine(hz("D1"), L, n, 0.08))
    for j, (k, a) in enumerate([(1, 0.12), (2, 0.28), (3, 0.24), (4, 0.16), (6, 0.08)]):
        for twin, dt in enumerate((0.0, 6.0 / L)):  # +0.2 Hz beating
            _acc(bed, _lock_sine(d2 * k + dt, L, n, a * 0.5, am_cycles=2 + (j % 2),
                                 am_depth=0.3, am_phase=1.3 * j + twin))
    _acc(bed, _lock_sine(hz("A2"), L, n, 0.10, am_cycles=3, am_depth=0.4, am_phase=0.4))
    for h, a in ((60.0, 0.03), (120.0, 0.03), (180.0, 0.02)):
        _acc(bed, _lock_sine(h, L, n, a))
    for b0, b1 in ((4, 6), (10, 12)):  # Eb + D minor-second rub
        swell = _breath(n, b0 * 4 * beat, b1 * 4 * beat)
        for f, a in ((hz("Eb3"), 0.07), (hz("D3"), 0.05), (hz("Eb4"), 0.02)):
            tone = _lock_sine(f, L, n, a)
            _acc(bed, [t * s for t, s in zip(tone, swell)])
    beat_n = n / 48.0
    duck = [1.0 - 0.38 * math.exp(-((i % beat_n) / SR) / 0.11) for i in range(n)]
    _acc(dry["bed"], [b * d for b, d in zip(bed, duck)])

    # pulsing low bass: eighth notes, accents on 1 and 3; Eb under bars 5-6,
    # Bb then Eb in the last two bars, D everywhere else
    roots = ["D2"] * 4 + ["Eb2"] * 2 + ["D2"] * 4 + ["Bb1", "Eb2"]
    accent = [1.0, 0.5, 0.7, 0.5, 0.9, 0.5, 0.7, 0.5]
    slot = n / 96.0
    for bar in range(12):
        hit = partials(hz(roots[bar]), 0.36, [0.55, 1.0, 0.65, 0.3], max_hz=1200.0)
        hit = soft_clip(pluck(hit, 0.17, 0.003, tail=0.08), 1.6)
        for s in range(8):
            _wrap_add(dry["bass"], hit, int(round((bar * 8 + s) * slot)), accent[s])

    # muffled distant alarm motif: A4 then D4 — Adam's chime interval (a
    # falling fifth), now as a hollow klaxon — a beat each, every two bars
    motif = []
    for nm in ("A4", "D4"):
        seg = partials(hz(nm), beat * 0.92, harm_square(7), max_hz=1600.0)
        motif.append(apply_env(seg, [(0, 0.0), (0.06, 1.0), (0.85, 0.9), (1.0, 0.0)]))
    motif = blp(concat(motif[0], motif[1]), 900.0, 0.6)
    for bar in range(0, 12, 2):
        _wrap_add(send["motif"], motif, int(round(bar * 4 * beat * SR)))

    # a dry clock: tick (high) and tock (lower, with a little body) every beat
    tick = click(2800, 0.04, 0.008, SEED + 41, q=1.6)
    tock = mix(click(2000, 0.045, 0.010, SEED + 42, q=1.4),
               gain(pluck(sweep(200, 120, 0.05, shape="exp"), 0.02, 0.001, tail=0.03), 0.5))
    for b in range(48):
        _wrap_add(dry["ticks"], tick if b % 2 == 0 else tock, int(round(b * beat * SR)))
    _wrap_add(dry["ticks"], tick, int(round(47.5 * beat * SR)), 0.6)  # a stutter into the wrap
    return dry, send


def music_lockdown_loop():
    dry, send = _lockdown_layers()
    mixed = _sum_layers(dry, LOCKDOWN_DRY_DB)
    wet = _loop_reverb(_sum_layers(send, LOCKDOWN_SEND_DB), rt60=3.2, damp=0.6, wet=0.9, predelay=0.02)
    _acc(mixed, wet)
    return _finish_loop(mixed, LOCKDOWN_RMS_DB)


MUSIC_GENERATORS = {
    "campus_loop": music_campus_loop,
    "lockdown_loop": music_lockdown_loop,
}


# ---------------------------------------------------------------------------
# Director cross-check + main
# ---------------------------------------------------------------------------

def check_director_sync():
    """audio_director.gd's cue list and this file must agree. Errors: a cue in
    SFX_NAMES, a `SFX_DIR + "x.wav"` source or a MUSIC_FILES loop with no
    generator here. Notes: generators no cue uses, and .wav files on disk that
    nothing generates any more (delete them and their .import)."""
    try:
        with open(DIRECTOR, encoding="utf-8") as fh:
            text = fh.read()
    except OSError:
        print("note: %s not found, skipping the director cross-check" % DIRECTOR)
        return True
    # comment lines are prose: a quoted example in one must not read as a cue or a wav
    text = "\n".join(ln for ln in text.splitlines() if not ln.lstrip().startswith("#"))
    ok = True
    m = re.search(r"const SFX_NAMES[^=]*=\s*\[(.*?)\]", text, re.S)
    cues = re.findall(r'&"([a-z0-9_]+)"', m.group(1)) if m else []
    if not cues:
        print("ERROR: could not read SFX_NAMES from %s" % DIRECTOR)
        return False
    for cue in cues:
        if cue not in SFX_GENERATORS:
            print("ERROR: director cue %r has no generator in gen_audio.py" % cue)
            ok = False
    for base in sorted(set(re.findall(r'SFX_DIR \+ "([a-z0-9_]+)\.wav"', text))):
        if base not in SFX_GENERATORS:
            print("ERROR: director plays %s.wav but nothing generates it" % base)
            ok = False
    m = re.search(r"const MUSIC_FILES\s*:?=\s*\{(.*?)\}", text, re.S)
    for key, base in re.findall(r'&"([a-z0-9_]+)"\s*:\s*"([a-z0-9_]+)"', m.group(1)) if m else []:
        if base not in MUSIC_GENERATORS:
            print("ERROR: music track %r -> %s has no generator" % (key, base))
            ok = False
    extra = sorted(set(SFX_GENERATORS) - set(cues))
    if extra:
        print("note: generators with no director cue: %s" % ", ".join(extra))
    for directory, known in ((SFX_DIR, SFX_GENERATORS), (MUSIC_DIR, MUSIC_GENERATORS)):
        if os.path.isdir(directory):
            for f in sorted(os.listdir(directory)):
                if f.endswith(".wav") and f[:-4] not in known:
                    print("note: stale file %s (no generator): delete it and its .import" % os.path.join(directory, f))
    return ok


def main(argv):
    out_root = None
    names = []
    i = 0
    while i < len(argv):
        if argv[i] == "--out" and i + 1 < len(argv):
            out_root = argv[i + 1]
            i += 2
        else:
            names.append(argv[i])
            i += 1
    sfx_dir = os.path.join(out_root, "sfx") if out_root else SFX_DIR
    music_dir = os.path.join(out_root, "music") if out_root else MUSIC_DIR
    known = set(SFX_GENERATORS) | set(MUSIC_GENERATORS)
    unknown = [nm for nm in names if nm not in known]
    if unknown:
        print("unknown name(s): %s\nvalid: %s" % (", ".join(unknown), ", ".join(sorted(known))))
        return 2

    random.seed(SEED)
    total_bytes = 0
    made = 0

    for cue_name in sorted(SFX_GENERATORS):
        if names and cue_name not in names:
            continue
        samples = SFX_GENERATORS[cue_name]()
        path = os.path.join(sfx_dir, cue_name + ".wav")
        to_wav(path, samples)
        total_bytes += os.path.getsize(path)
        made += 1
        print("sfx  %-22s %6d samples  %.3fs" % (cue_name, len(samples), len(samples) / SR))

    for name in sorted(MUSIC_GENERATORS):
        if names and name not in names:
            continue
        samples = MUSIC_GENERATORS[name]()
        path = os.path.join(music_dir, name + ".wav")
        to_wav(path, samples)
        total_bytes += os.path.getsize(path)
        made += 1
        print("music %-22s %6d samples  %.3fs" % (name, len(samples), len(samples) / SR))

    print("Total: %d files, %.1f KB" % (made, total_bytes / 1024.0))
    if out_root is None and not names:
        return 0 if check_director_sync() else 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

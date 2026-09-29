#!/usr/bin/env python3
"""Synthesize the few placeholder sounds the lit-cutout test needs (C35).

Writes 16-bit mono WAVs to spike/lit_cutout/audio/:
  baton_crackle.wav  rising electric buzz for the baton wind-up (0.5 s)
  baton_swing.wav    short whoosh for the committed strike
  flesh_hit.wav      restrained wet impact for a hit on a person
  body_fall.wav      dull thud when a body lands
Run from the project root:  python3 tools/spike/make_spike_audio.py
"""
import os
import wave

import numpy as np

SR = 44100
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "spike", "lit_cutout", "audio"))
RNG = np.random.default_rng(9)


def lowpass(x, cutoff):
    a = np.exp(-2.0 * np.pi * cutoff / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def env(n, attack, release):
    t = np.arange(n) / SR
    e = np.minimum(1.0, t / max(attack, 1e-4))
    e *= np.exp(-np.maximum(t - attack, 0.0) / max(release, 1e-4))
    return e


def save(name, x, gain=0.8):
    x = x / (np.max(np.abs(x)) + 1e-9) * gain
    data = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    with wave.open(os.path.join(OUT, name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())


def main():
    os.makedirs(OUT, exist_ok=True)
    # crackle: a buzzing 110->160 Hz square with sparse sharp crackles, rising
    n = int(0.5 * SR)
    t = np.arange(n) / SR
    f = 110 + 50 * (t / t[-1]) ** 2
    ph = 2 * np.pi * np.cumsum(f) / SR
    buzz = np.sign(np.sin(ph)) * 0.35 + np.sin(ph * 3) * 0.15
    crack = (RNG.random(n) < 0.004).astype(np.float64) * RNG.normal(0, 1, n)
    crack = np.convolve(crack, np.exp(-np.arange(200) / 30.0), "same")
    x = (buzz + crack * 0.8) * (0.25 + 0.75 * (t / t[-1])) * env(n, 0.02, 2.0)
    save("baton_crackle.wav", x, 0.55)
    # swing: band-limited noise sweeping down
    n = int(0.28 * SR)
    noise = RNG.normal(0, 1, n)
    x = lowpass(noise, 2200) - lowpass(noise, 300)
    x *= np.sin(np.linspace(0, np.pi, n)) ** 1.5
    save("baton_swing.wav", x, 0.6)
    # flesh hit: short low thump + a damp slap
    n = int(0.22 * SR)
    t = np.arange(n) / SR
    thump = np.sin(2 * np.pi * (95 - 40 * t / t[-1]) * t) * env(n, 0.002, 0.06)
    slap = lowpass(RNG.normal(0, 1, n), 1600) * env(n, 0.001, 0.025)
    save("flesh_hit.wav", thump * 0.9 + slap * 1.4, 0.7)
    # body fall: low thud with a little rustle
    n = int(0.45 * SR)
    t = np.arange(n) / SR
    thud = np.sin(2 * np.pi * (70 - 25 * t / t[-1]) * t) * env(n, 0.004, 0.12)
    rustle = lowpass(RNG.normal(0, 1, n), 900) * env(n, 0.01, 0.15) * 0.5
    save("body_fall.wav", thud + rustle, 0.75)
    print("audio ->", OUT)


if __name__ == "__main__":
    main()

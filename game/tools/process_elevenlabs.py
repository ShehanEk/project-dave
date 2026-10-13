#!/usr/bin/env python3
"""Turns the ElevenLabs takes under audio-source/elevenlabs/ into game audio (N05).

    python3 tools/process_elevenlabs.py            # everything
    python3 tools/process_elevenlabs.py --report   # measure only, write nothing

Inputs (never modified): audio-source/elevenlabs/batch1..4/<cue>_<n>.mp3
Outputs:
    assets/audio/eleven/sfx/<cue>_<n>.wav     mono 44.1 kHz 16-bit one-shots
    assets/audio/eleven/amb/<name>.wav        mono 32 kHz seamless loops
    assets/audio/eleven/voice/<line>_<n>.wav  mono 44.1 kHz voice lines
    assets/audio/eleven/music/<track>.wav     stereo 32 kHz seamless music loops, and the
                                              stereo 44.1 kHz stings (sting_*.wav)
    scripts/audio/eleven_manifest.gd          what the Audio director plays, with each
                                              cue's mix trim (the director falls back to
                                              the old Kenney / synthesized source for a
                                              cue that has no entry or no loadable file)

What it does to each take:
  * decodes the mp3 with macOS afconvert (float, mono, downmixed),
  * trims the silence before and after the sound and fades the end,
  * windup tells are cut to their animation (the LAST seconds are kept, so the
    rising climax stays) because the clips are longer than the windups,
  * loops get an equal-power crossfade of the end into the start,
  * a gentle high-pass removes sub-bass rumble and DC,
  * every sound-effect take is peak-normalized to PEAK_DB, and the cue's trim
    (PEAK_MIX_DB below: the peak level the cue plays at through the SFX bus) sets
    where it sits in the mix. A-weighted loudness is a poor guide for short or
    bass-heavy cues (a thud or a footstep reads 30 dB lower than it sounds), so
    only the ambience beds and the voice lines are levelled by A-weighted loudness
    (against the music loops and a fixed speech level).
"""
import math
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import wave

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)                                   # prototypes/sunnyvale-godot
REPO = os.path.dirname(os.path.dirname(ROOT))                  # repo root
SRC = os.path.join(REPO, "audio-source", "elevenlabs")
OUT = os.path.join(ROOT, "assets", "audio", "eleven")
MANIFEST = os.path.join(ROOT, "scripts", "audio", "eleven_manifest.gd")
RES = "res://assets/audio/eleven/"

SFX_RATE = 44100
AMB_RATE = 32000
PEAK_DB = -1.5            # the loudest sample of any file, before the cue trim

# --- which takes are used -----------------------------------------------------------

# Cues whose old source stays (the user did not ask to replace them or they have no
# ElevenLabs take): none today. Cues with several variants list every take that
# passes the checks; these names are the batch1/batch2 file stems.
GUARD_SWING_STEMS = ["guard_swing_real", "guard_swing_whip"]   # the first four takes sounded fake

# Cue -> source stems. A plain cue uses every <cue>_<n>.mp3 found.
SFX_CUES = [
    # batch 1
    "pistol_fire", "pistol_fire_quick", "bolt_hit", "bolt_blocked", "hit_flesh", "body_fall",
    "hero_hurt", "hero_jump", "hero_land", "footstep_paving", "footstep_metal", "footstep_roof",
    "guard_windup", "staffer_windup", "staffer_lunge", "staffer_defeat",
    "rover_patrol", "rover_windup", "rover_charge", "rover_stall", "rover_armor",
    "rover_destroyed", "debris_clatter",
    # batch 2
    "chip", "chip_cluster", "cache_open", "evidence", "med_patch", "keycard", "keycard_denied",
    "door_unlock", "hatch_open", "latch", "interact", "checkpoint", "purchase", "swap",
    "save_failed", "pit_fall", "uplink", "link_chirp", "adam_chime", "alarm", "lockdown", "exit",
    "ui_move", "ui_confirm", "ui_back", "ui_pause", "toast_save", "ready_click",
]
# Enemy barks (round two): the guards' and Staffers' spoken lines, played positionally at
# the speaker through play_sfx() like any cue (mono), 2 takes each.
BARK_CUES = [
    "bark_guard_ground", "bark_guard_security", "bark_guard_there_he_is",
    "bark_guard_dont_make_me", "bark_guard_last_warning", "bark_guard_hes_shooting",
    "bark_guard_shots_fired",
    "bark_staffer_stay", "bark_staffer_workstation", "bark_staffer_hold_still", "bark_staffer_dave",
]
SFX_CUES += BARK_CUES
# guard_swing is special-cased below (it uses GUARD_SWING_STEMS).

# Windup tells: keep the last N seconds (the windup animation lasts N - 0.05).
FIT_TO_WINDUP = {"guard_windup": 0.55, "staffer_windup": 0.70, "rover_windup": 0.85}
# Longest the clip may run after trimming, with the fade-out used when it is cut.
MAX_LEN = {"rover_patrol": (1.2, 0.20)}

# Amount of silence kept around the sound, ms (before, after), and the end fade.
EDGE_MS = {"default": (4, 40, 25), "voice": (30, 150, 60), "step": (3, 20, 15)}

# The loops: file stem -> (take to use, crossfade seconds, music key it sits under).
AMBIENCE = {
    "amb_campus_night": (1, 0.8, "campus"),
    "amb_roof_night": (1, 0.8, "campus"),
    "amb_plaza_wet": (1, 0.8, "campus"),
    "amb_depot_hum": (1, 0.8, "campus"),
    "amb_lockdown_bed": (1, 0.8, "lockdown"),
    "amb_alarm_far": (1, 0.5, "lockdown"),
    "amb_wicket_yard": (1, 0.8, "lockdown"),
    "amb_server_core": (1, 0.8, "lockdown"),
}
# Beds sit this far under the music loop's own A-weighted level (dB), per bed.
AMBIENCE_UNDER_MUSIC_DB = {
    "amb_campus_night": 9.0, "amb_roof_night": 9.0, "amb_plaza_wet": 9.0, "amb_depot_hum": 8.0,
    "amb_lockdown_bed": 9.0, "amb_alarm_far": 14.0, "amb_wicket_yard": 9.0, "amb_server_core": 8.0,
}

# Music loops (round two): track key -> (file stem, take, crossfade seconds, the old loop
# whose A-weighted level it is matched to, dB above that level). Stereo, 32 kHz.
MUSIC_RATE = 32000
STING_RATE = 44100
MUSIC_TRACKS = {
    "campus": ("music_campus", 1, 3.0, "campus", 0.0),
    "lockdown": ("music_lockdown", 1, 2.5, "lockdown", 0.0),
    "depot": ("music_depot", 1, 3.0, "campus", 0.0),
    "title": ("music_title", 1, 3.0, "campus", 2.0),
}
# One-shot stings, played as cues: cue -> (file stem, take, peak dBFS it plays at).
STINGS = {
    "sting_complete": ("music_complete", 1, -5.0),
    "sting_checkpoint": ("music_checkpoint", 1, -9.0),
}

VOICE_LINES = ["adam_hello", "adam_stay", "dave_word_gets_around", "pa_lethal", "pa_remain_calm"]
# Peak level (dBFS) each voice line plays at: Adam clearest, Dave a little lower, the PA
# tinny and set back in the room.
VOICE_PEAK_MIX_DB = {
    "adam_hello": -4.0, "adam_stay": -4.0, "dave_word_gets_around": -5.0,
    "pa_lethal": -6.0, "pa_remain_calm": -6.0,
}
# The SC00 intro comic's narration (C49): one line per panel by the designed "DEAD EDEN -
# Narrator" voice, plus Stroud's line on panel 4 (the library voice "Mac Halloway").
# The narrator sits on top (the title music is ducked under it), Stroud a little lower.
INTRO_LINES = ["intro_narration_%02d" % i for i in range(1, 9)] + ["intro_stroud_04"]
VOICE_LINES += INTRO_LINES
for _line in INTRO_LINES:
    VOICE_PEAK_MIX_DB[_line] = -4.0 if _line == "intro_stroud_04" else -3.0
# Lines that use only these takes (the game plays a random take of a line otherwise).
VOICE_TAKES = {line: [1] for line in INTRO_LINES}

# The peak level (dBFS) each cue plays at through its trim. Loudest and most dramatic
# (-2 to -5): the pistol, the Rover's ram and wreck, the lockdown stinger, Adam's chime,
# the enemy tells. Strikes, story beats and access cues -6 to -9; hits on people, the
# hero's own sounds and pickups -8 to -14; steps, the Rover's roll and interface ticks
# lowest (-13 to -22).
PEAK_MIX_DB = {
    "pistol_fire": -3.0, "pistol_fire_quick": -4.0, "bolt_hit": -10.0, "bolt_blocked": -4.0,
    "hero_hurt": -8.0, "hero_jump": -14.0, "hero_land": -12.0,
    "footstep_paving": -20.0, "footstep_metal": -20.0, "footstep_roof": -22.0,
    "hit_flesh": -9.0, "body_fall": -9.0,
    "guard_windup": -5.0, "guard_swing": -6.0,
    "staffer_windup": -5.0, "staffer_lunge": -7.0, "staffer_defeat": -6.0,
    "rover_patrol": -16.0, "rover_windup": -5.0, "rover_charge": -4.0, "rover_stall": -4.0,
    "rover_armor": -7.0, "rover_destroyed": -3.0, "debris_clatter": -14.0,
    "chip": -12.0, "chip_cluster": -10.0, "cache_open": -10.0, "evidence": -6.0,
    "med_patch": -10.0, "keycard": -8.0, "keycard_denied": -10.0, "door_unlock": -7.0,
    "hatch_open": -7.0, "latch": -10.0, "interact": -12.0, "checkpoint": -8.0,
    "purchase": -10.0, "swap": -12.0, "save_failed": -9.0, "pit_fall": -8.0,
    "uplink": -18.0, "link_chirp": -12.0, "adam_chime": -4.0, "alarm": -8.0,
    "lockdown": -4.0, "exit": -2.0,
    "ui_move": -18.0, "ui_confirm": -13.0, "ui_back": -13.0, "ui_pause": -13.0,
    "toast_save": -14.0, "ready_click": -14.0,
    # barks: speech reads louder than its peak, so the guards sit below the pistol
    "bark_guard_ground": -7.0, "bark_guard_security": -7.0, "bark_guard_there_he_is": -7.0,
    "bark_guard_dont_make_me": -7.0, "bark_guard_last_warning": -7.0,
    "bark_guard_hes_shooting": -7.0, "bark_guard_shots_fired": -7.0,
    # the scared Staffer voice is quiet and breathy: the user heard it too low at -10 / -11
    # (playtest 2026-10-08), so it sits 6 dB higher, just above the shouting guards' peak
    "bark_staffer_stay": -4.0, "bark_staffer_workstation": -4.0,
    "bark_staffer_hold_still": -4.0, "bark_staffer_dave": -5.0,
}
# Takes whose A-weighted level (peak-normalized) is this many dB away from the cue's
# median are listed in the report for a listen; they are still used.
OUTLIER_DB = 14.0

# --- audio helpers ---------------------------------------------------------------------


def decode(path, rate):
    """mp3 -> float32 mono numpy at `rate` via afconvert."""
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, "x.wav")
        subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEF32@%d" % rate, "-c", "1", path, wav],
                       check=True, capture_output=True)
        return read_float_wav(wav)


def read_float_wav(path, mono=True):
    with open(path, "rb") as fh:
        data = fh.read()
    pos = 12
    fmt = None
    while pos + 8 <= len(data):
        cid = data[pos:pos + 4]
        size = struct.unpack("<I", data[pos + 4:pos + 8])[0]
        body = data[pos + 8:pos + 8 + size]
        if cid == b"fmt ":
            fmt = struct.unpack("<HHIIHH", body[:16])
        elif cid == b"data":
            tag, channels, rate, _, _, bits = fmt
            if tag == 3 and bits == 32:
                x = np.frombuffer(body, dtype="<f4").astype(np.float64)
            elif tag == 1 and bits == 16:
                x = np.frombuffer(body, dtype="<i2").astype(np.float64) / 32768.0
            else:
                raise ValueError("unsupported wav format %s/%s in %s" % (tag, bits, path))
            if channels > 1:
                x = x.reshape(-1, channels)
                if mono:
                    x = x.mean(axis=1)
            elif not mono:
                x = x.reshape(-1, 1)
            return x
        pos += 8 + size + (size & 1)
    raise ValueError("no data chunk in %s" % path)


def write_wav(path, x, rate):
    """Mono (1-D) or stereo ((n, 2)) 16-bit wav."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pcm = np.clip(np.round(x * 32767.0), -32768, 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1 if x.ndim == 1 else x.shape[1])
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(pcm.tobytes())


def a_weight_curve(n, rate):
    f = np.fft.rfftfreq(n, 1.0 / rate)
    f2 = f * f
    ra = (12194.0 ** 2 * f2 * f2) / ((f2 + 20.6 ** 2) * np.sqrt((f2 + 107.7 ** 2) * (f2 + 737.9 ** 2)) * (f2 + 12194.0 ** 2))
    ra[0] = 0.0
    return ra * 10 ** (2.0 / 20.0)


def a_weighted(x, rate):
    return np.fft.irfft(np.fft.rfft(x) * a_weight_curve(len(x), rate), n=len(x))


def loudest_db(x, rate, window_s=0.2):
    """A-weighted RMS of the loudest `window_s`, dBFS (a clip shorter than the window is
    measured as if padded with silence, the way a short cue lands in the measurement)."""
    y = a_weighted(x, rate)
    w = max(1, int(round(window_s * rate)))
    sq = np.concatenate([[0.0], np.cumsum(y * y)])
    if len(y) <= w:
        best = sq[-1] / w
    else:
        best = ((sq[w:] - sq[:-w]) / w).max()
    return 10.0 * math.log10(max(best, 1e-12))


def mean_db(x, rate):
    y = a_weighted(x, rate)
    return 10.0 * math.log10(max(float(np.mean(y * y)), 1e-12))


def peak_db(x):
    return 20.0 * math.log10(max(float(np.max(np.abs(x))), 1e-9))


def highpass(x, rate, fc):
    """Smooth zero-phase 4th-order high-pass in the frequency domain."""
    f = np.fft.rfftfreq(len(x), 1.0 / rate)
    f[0] = 1e-6
    return np.fft.irfft(np.fft.rfft(x) / (1.0 + (fc / f) ** 4), n=len(x))


def trim_silence(x, rate, pre_ms, post_ms, fade_ms, floor_db=-45.0):
    win = max(1, int(rate * 0.005))
    sq = np.concatenate([[0.0], np.cumsum(x * x)])
    env = np.sqrt((sq[win:] - sq[:-win]) / win)
    thr = env.max() * 10 ** (floor_db / 20.0)
    idx = np.nonzero(env > thr)[0]
    if len(idx) == 0:
        return x
    start = max(0, int(idx[0]) - int(rate * pre_ms / 1000.0))
    end = min(len(x), int(idx[-1]) + win + int(rate * post_ms / 1000.0))
    y = x[start:end].copy()
    fo = min(len(y), int(rate * fade_ms / 1000.0))
    if fo > 1:
        y[-fo:] *= 0.5 * (1.0 + np.cos(np.linspace(0, math.pi, fo)))
    fi = min(len(y), int(rate * 0.002))
    if fi > 1:
        y[:fi] *= np.linspace(0.0, 1.0, fi)
    return y


def keep_last(x, rate, seconds, fade_in_ms=25):
    n = int(rate * seconds)
    if len(x) <= n:
        return x
    y = x[-n:].copy()
    fi = int(rate * fade_in_ms / 1000.0)
    y[:fi] *= np.linspace(0.0, 1.0, fi)
    return y


def keep_first(x, rate, seconds, fade_out_s):
    n = int(rate * seconds)
    if len(x) <= n:
        return x
    y = x[:n].copy()
    fo = int(rate * fade_out_s)
    y[-fo:] *= 0.5 * (1.0 + np.cos(np.linspace(0, math.pi, fo)))
    fi = int(rate * 0.04)
    y[:fi] *= np.linspace(0.0, 1.0, fi)
    return y


def make_loop(x, rate, xfade_s):
    """Equal-power crossfade of the last xf samples into the first xf, so the file's
    last sample runs straight into its first when it repeats."""
    xf = int(rate * xfade_s)
    n = len(x)
    body = x[: n - xf].copy()
    t = np.linspace(0.0, math.pi / 2.0, xf)
    body[:xf] = body[:xf] * np.sin(t) + x[n - xf:] * np.cos(t)
    return body


def seam_ratio(x):
    """Jump across the wrap point relative to the typical sample-to-sample step."""
    d = np.abs(np.diff(x))
    return float(abs(x[0] - x[-1]) / max(float(np.mean(d)), 1e-9))


# --- file discovery ------------------------------------------------------------------------


# Stems that were regenerated: only this folder's takes are used, the older takes stay
# stored but unused. The Staffer barks were redone with a new, more human and scared voice
# ("DEAD EDEN - Staffer (scared)") after the first Staffer voice did not work in play.
TAKE_FOLDER = {
    "bark_staffer_stay": "batch4-staffer-scared",
    "bark_staffer_workstation": "batch4-staffer-scared",
    "bark_staffer_hold_still": "batch4-staffer-scared",
    "bark_staffer_dave": "batch4-staffer-scared",
}


def find_takes(stem):
    """All <stem>_<n>.mp3 across the batch folders (or only TAKE_FOLDER's), sorted by n."""
    found = []
    for batch in sorted(os.listdir(SRC)):
        d = os.path.join(SRC, batch)
        if not os.path.isdir(d) or TAKE_FOLDER.get(stem, batch) != batch:
            continue
        for f in os.listdir(d):
            if f.startswith(stem + "_") and f.endswith(".mp3"):
                tail = f[len(stem) + 1:-4]
                if tail.isdigit():
                    found.append((int(tail), os.path.join(d, f)))
    return [p for _, p in sorted(found)]


def edge_for(cue):
    if cue.startswith("bark_"):
        return EDGE_MS["voice"]
    if cue.startswith("footstep_"):
        return EDGE_MS["step"]
    return EDGE_MS["default"]


# --- the three kinds of output --------------------------------------------------------------


def process_cue(cue, stems, write, notes):
    """Returns {"files": [...], "volume_db": float, "limited": False} or None."""
    rate = SFX_RATE
    clips = []
    for stem in stems:
        for path in find_takes(stem):
            x = highpass(decode(path, rate), rate, 35.0)
            pre, post, fade = edge_for(cue)
            x = trim_silence(x, rate, pre, post, fade)
            if cue in FIT_TO_WINDUP:
                x = keep_last(x, rate, FIT_TO_WINDUP[cue])
            if cue in MAX_LEN:
                x = keep_first(x, rate, MAX_LEN[cue][0], MAX_LEN[cue][1])
            name = os.path.basename(path)[:-4]
            if peak_db(x) < -60.0 or len(x) < int(rate * 0.04):
                notes.append("  SKIP %s: silent or too short" % name)
                continue
            clips.append((name, x * 10 ** ((PEAK_DB - peak_db(x)) / 20.0)))
    if not clips:
        return None
    levels = [loudest_db(x, rate) for _, x in clips]
    median = sorted(levels)[len(levels) // 2]
    files = []
    for i, ((name, y), lv) in enumerate(zip(clips, levels), 1):
        out = os.path.join(OUT, "sfx", "%s_%d.wav" % (cue, i))
        if write:
            write_wav(out, y, rate)
        files.append(RES + "sfx/%s_%d.wav" % (cue, i))
        flag = "   <- far from the other takes, listen" if abs(lv - median) > OUTLIER_DB else ""
        notes.append("  %-22s <- %-22s %5.2fs  A-weighted %6.1f%s" % (
            os.path.basename(out), name, len(y) / rate, lv, flag))
    trim = PEAK_MIX_DB[cue] - PEAK_DB
    return {"files": files, "volume_db": round(trim, 1), "limited": False}


def music_level(key):
    name = {"campus": "campus_loop", "lockdown": "lockdown_loop"}[key]
    path = os.path.join(ROOT, "assets", "audio", "music", name + ".wav")
    with wave.open(path, "rb") as w:
        n = w.getnframes()
        rate = w.getframerate()
        raw = np.frombuffer(w.readframes(n), dtype="<i2").astype(np.float64) / 32768.0
        if w.getnchannels() > 1:
            raw = raw.reshape(-1, w.getnchannels()).mean(axis=1)
    return mean_db(raw, rate)


def process_ambience(write, notes):
    out = {}
    levels = {k: music_level(k) for k in ("campus", "lockdown")}
    for name, (take, xfade, music_key) in AMBIENCE.items():
        takes = find_takes(name)
        if len(takes) < take:
            notes.append("MISSING %s take %d" % (name, take))
            continue
        x = highpass(decode(takes[take - 1], AMB_RATE), AMB_RATE, 25.0)
        before = seam_ratio(x)
        y = make_loop(x, AMB_RATE, xfade)
        after = seam_ratio(y)
        # the whole file sits at its own mean level; the trim brings it under the music
        target = levels[music_key] - AMBIENCE_UNDER_MUSIC_DB[name]
        ref = mean_db(y, AMB_RATE)
        y = y * 10 ** ((PEAK_DB - peak_db(y)) / 20.0)
        file_level = mean_db(y, AMB_RATE)
        trim = max(-30.0, min(0.0, target - file_level))
        if write:
            write_wav(os.path.join(OUT, "amb", name + ".wav"), y, AMB_RATE)
        out[name] = {"file": RES + "amb/%s.wav" % name, "volume_db": round(trim, 1),
                     "limited": (target - file_level) > 0.0}
        notes.append("  %-20s %5.2fs  seam jump %.1f -> %.1f x typical step; file %.1f dB, wants %.1f (music %s %.1f)" % (
            name, len(y) / AMB_RATE, before, after, file_level, target, music_key, levels[music_key]))
    return out


def process_voice(write, notes):
    out = {}
    for line in VOICE_LINES:
        takes = find_takes(line)
        if line in VOICE_TAKES:
            takes = [t for n, t in enumerate(takes, 1) if n in VOICE_TAKES[line]]
        clips = []
        for path in takes:
            x = highpass(decode(path, SFX_RATE), SFX_RATE, 70.0)
            pre, post, fade = EDGE_MS["voice"]
            x = trim_silence(x, SFX_RATE, pre, post, fade)
            clips.append((os.path.basename(path)[:-4], x))
        if not clips:
            notes.append("MISSING voice line %s" % line)
            continue
        files = []
        for i, (name, x) in enumerate(clips, 1):
            y = x * 10 ** ((PEAK_DB - peak_db(x)) / 20.0)
            if write:
                write_wav(os.path.join(OUT, "voice", "%s_%d.wav" % (line, i)), y, SFX_RATE)
            files.append(RES + "voice/%s_%d.wav" % (line, i))
            notes.append("  %-26s <- %-26s %5.2fs" % ("%s_%d.wav" % (line, i), name, len(y) / SFX_RATE))
        out[line] = {"files": files, "volume_db": round(VOICE_PEAK_MIX_DB[line] - PEAK_DB, 1),
                     "limited": False}
    return out


def decode_stereo(path, rate):
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, "x.wav")
        subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEF32@%d" % rate, "-c", "2", path, wav],
                       check=True, capture_output=True)
        x = read_float_wav(wav, mono=False)
    return x if x.shape[1] == 2 else np.repeat(x, 2, axis=1)


def stereo_mean_db(x, rate):
    power = [float(np.mean(a_weighted(x[:, c], rate) ** 2)) for c in range(x.shape[1])]
    return 10.0 * math.log10(max(sum(power) / len(power), 1e-12))


def stereo_hp(x, rate, fc):
    return np.stack([highpass(x[:, c], rate, fc) for c in range(x.shape[1])], axis=1)


def trim_head(x, rate, floor=0.002, keep_ms=8):
    """Drop the near-silence an mp3 decode leaves at the start of a track."""
    idx = np.nonzero(np.max(np.abs(x), axis=1) > floor)[0]
    if len(idx) == 0:
        return x
    return x[max(0, int(idx[0]) - int(rate * keep_ms / 1000.0)):]


def make_loop_stereo(x, rate, xfade_s):
    xf = int(rate * xfade_s)
    body = x[: len(x) - xf].copy()
    t = np.linspace(0.0, math.pi / 2.0, xf)[:, None]
    body[:xf] = body[:xf] * np.sin(t) + x[len(x) - xf:] * np.cos(t)
    return body


def process_music(write, notes):
    out = {}
    for key, (stem, take, xfade, level_key, offset) in MUSIC_TRACKS.items():
        takes = find_takes(stem)
        if len(takes) < take:
            notes.append("MISSING %s take %d" % (stem, take))
            continue
        x = stereo_hp(decode_stereo(takes[take - 1], MUSIC_RATE), MUSIC_RATE, 25.0)
        x = trim_head(x, MUSIC_RATE)
        y = make_loop_stereo(x, MUSIC_RATE, xfade)
        target = music_level(level_key) + offset
        gain_db = target - stereo_mean_db(y, MUSIC_RATE)
        gain = 10 ** (gain_db / 20.0)
        peak = float(np.max(np.abs(y))) * gain
        limited = peak > 10 ** (PEAK_DB / 20.0)
        if limited:
            gain *= 10 ** (PEAK_DB / 20.0) / peak
        y = y * gain
        if write:
            write_wav(os.path.join(OUT, "music", key + ".wav"), y, MUSIC_RATE)
        out[key] = {"file": RES + "music/%s.wav" % key, "volume_db": 0.0, "limited": limited}
        notes.append("  %-9s <- %s_%d  %5.2fs  seam jump %.1f -> %.1f x typical step  gain %+.1f dB%s" % (
            key, stem, take, len(y) / MUSIC_RATE, seam_ratio(x[:, 0]), seam_ratio(y[:, 0]), gain_db,
            "  (limited by peaks)" if limited else ""))
    return out


def process_stings(write, notes):
    out = {}
    for cue, (stem, take, peak_target) in STINGS.items():
        takes = find_takes(stem)
        if len(takes) < take:
            notes.append("MISSING %s take %d" % (stem, take))
            continue
        x = stereo_hp(decode_stereo(takes[take - 1], STING_RATE), STING_RATE, 30.0)
        x = trim_head(x, STING_RATE)
        env = np.max(np.abs(x), axis=1)
        idx = np.nonzero(env > 0.003)[0]
        end = min(len(x), int(idx[-1]) + int(STING_RATE * 0.15)) if len(idx) else len(x)
        x = x[:end].copy()
        fo = min(len(x), int(STING_RATE * 0.25))
        x[-fo:] *= (0.5 * (1.0 + np.cos(np.linspace(0, math.pi, fo))))[:, None]
        fi = int(STING_RATE * 0.006)
        x[:fi] *= np.linspace(0.0, 1.0, fi)[:, None]
        x = x * 10 ** ((PEAK_DB - 20.0 * math.log10(max(float(np.max(np.abs(x))), 1e-9))) / 20.0)
        if write:
            write_wav(os.path.join(OUT, "music", cue + ".wav"), x, STING_RATE)
        out[cue] = {"files": [RES + "music/%s.wav" % cue], "volume_db": round(peak_target - PEAK_DB, 1),
                    "limited": False}
        notes.append("  %-17s <- %s_%d  %5.2fs" % (cue, stem, take, len(x) / STING_RATE))
    return out


def gd_literal(d, indent="\t"):
    lines = []
    for key in sorted(d):
        v = d[key]
        if "files" in v:
            files = ", ".join('"%s"' % f for f in v["files"])
            lines.append('%s&"%s": {"files": [%s], "volume_db": %.1f},' % (indent, key, files, v["volume_db"]))
        else:
            lines.append('%s&"%s": {"file": "%s", "volume_db": %.1f},' % (indent, key, v["file"], v["volume_db"]))
    return "\n".join(lines)


def write_manifest(sfx, amb, voice, music):
    text = (
        "extends RefCounted\n"
        "## GENERATED by tools/process_elevenlabs.py from the ElevenLabs takes under\n"
        "## audio-source/elevenlabs/ (N05). Do not edit by hand; rerun the tool.\n"
        "## The Audio director plays a cue from `SFX` when it has an entry whose files load,\n"
        "## and falls back to the cue's old source in SFX_SOURCES otherwise. `volume_db` is\n"
        "## each entry's mix trim (the files are levelled per cue, see the tool's docstring).\n"
        "## No `class_name` (the project's import-cache rule): the director preloads it by path.\n\n"
        "const SFX := {\n" + gd_literal(sfx) + "\n}\n\n"
        "## Seamless loops, one file each, played by Audio.set_ambience().\n"
        "const AMBIENCE := {\n" + gd_literal(amb) + "\n}\n\n"
        "## Spoken lines, played by Audio.play_voice(); several files are alternate takes.\n"
        "const VOICE := {\n" + gd_literal(voice) + "\n}\n\n"
        "## Music loops, one stereo file each (levelled to the old synthesized loops), played by\n"
        "## Audio.set_music(); a track here replaces the synthesized loop of the same key.\n"
        "const MUSIC := {\n" + gd_literal(music) + "\n}\n"
    )
    with open(MANIFEST, "w", encoding="utf-8") as fh:
        fh.write(text)


def main(argv):
    write = "--report" not in argv
    if shutil.which("afconvert") is None:
        print("afconvert (macOS) is required to decode the mp3 takes")
        return 1
    if not os.path.isdir(SRC):
        print("no %s" % SRC)
        return 1
    if write:
        for sub in ("sfx", "amb", "voice", "music"):
            d = os.path.join(OUT, sub)
            if os.path.isdir(d):
                for f in os.listdir(d):
                    if f.endswith(".wav"):
                        os.remove(os.path.join(d, f))
    notes = []
    sfx = {}
    for cue in SFX_CUES:
        notes.append(cue)
        r = process_cue(cue, [cue], write, notes)
        if r:
            sfx[cue] = r
        else:
            notes.append("  (no takes)")
    notes.append("guard_swing")
    r = process_cue("guard_swing", GUARD_SWING_STEMS, write, notes)
    if r:
        sfx["guard_swing"] = r
    notes.append("ambience")
    amb = process_ambience(write, notes)
    notes.append("voice")
    voice = process_voice(write, notes)
    notes.append("music")
    music = process_music(write, notes)
    notes.append("stings")
    sfx.update(process_stings(write, notes))
    if write:
        write_manifest(sfx, amb, voice, music)
    print("\n".join(notes))
    total = (sum(len(v["files"]) for v in sfx.values()) + len(amb) + len(music)
             + sum(len(v["files"]) for v in voice.values()))
    limited = [k for k, v in list(sfx.items()) + list(voice.items()) + list(music.items()) if v["limited"]]
    print("\n%d cues, %d ambience loops, %d voice lines, %d music loops, %d files%s" % (
        len(sfx), len(amb), len(voice), len(music), total, "" if write else " (report only, nothing written)"))
    if limited:
        print("limited by peak headroom (play quieter than their target): %s" % ", ".join(limited))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

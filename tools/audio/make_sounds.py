"""Render every Boop! sound effect from code into assets/sounds/*.wav.

    python tools/audio/make_sounds.py

Synthesised rather than sampled so the set is deterministic, tiny, license-free
and re-tunable: change a number, re-run, commit the WAVs. Pure standard
library (math, random, wave, struct) so it runs on any Python 3.

Design notes
- Every sound gets a 4 ms fade-in and a fade-out to the last sample, so nothing
  clicks when the pool restarts a player mid-play.
- Peak-normalised to -3 dBFS, then each sound is scaled by its own gain so the
  set is balanced by ear (boops are frequent, so they are the quietest).
- The boop is pre-rendered at 19 semitone steps (boop_00 … boop_18) instead of
  pitch-shifting at runtime: iOS AVPlayer rate changes preserve pitch, so a
  rate-based pitch would not actually change pitch on the device.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

SR = 44100
OUT = Path(__file__).resolve().parents[2] / "assets" / "sounds"
TAU = 2 * math.pi


def env_exp(t: float, decay: float) -> float:
    return math.exp(-t / decay)


def finish(samples: list[float], gain: float = 1.0, fade_in_ms: float = 4.0) -> list[float]:
    n = len(samples)
    fi = max(1, int(SR * fade_in_ms / 1000))
    for i in range(min(fi, n)):
        samples[i] *= i / fi
    fo = max(1, int(n * 0.12))
    for i in range(fo):
        samples[n - 1 - i] *= i / fo
    peak = max(1e-9, max(abs(s) for s in samples))
    k = (10 ** (-3 / 20)) / peak * gain
    return [s * k for s in samples]


def write(name: str, samples: list[float]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{name}.wav"
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))
    print(f"  {path.name:<16} {len(samples) / SR * 1000:5.0f} ms")


def boop(f0: float) -> list[float]:
    """A soft rubber-toy 'boop': a quick upward chirp that settles, with a
    rounded second partial and a tiny breathy onset."""
    dur = 0.16
    n = int(SR * dur)
    out = []
    phase = 0.0
    rnd = random.Random(7)
    for i in range(n):
        t = i / SR
        # pitch: starts 15% low, chirps to +22% at 18 ms, settles to f0
        glide = 0.85 + 0.37 * (1 - env_exp(t, 0.006)) - 0.22 * (1 - env_exp(t, 0.045))
        f = f0 * glide
        phase += TAU * f / SR
        body = math.sin(phase) + 0.28 * math.sin(2 * phase) + 0.08 * math.sin(3 * phase)
        breath = (rnd.random() * 2 - 1) * 0.12 * env_exp(t, 0.006)
        amp = (1 - env_exp(t, 0.003)) * env_exp(t, 0.055)
        out.append((body + breath) * amp)
    return out


def squeak(f0: float, dur: float, vib: float = 28.0, depth: float = 0.06, up: float = 0.25) -> list[float]:
    n = int(SR * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = f0 * (1 + up * (t / dur)) * (1 + depth * math.sin(TAU * vib * t))
        phase += TAU * f / SR
        s = math.sin(phase) + 0.35 * math.sin(2 * phase + 0.4)
        amp = (1 - env_exp(t, 0.008)) * (1 - (t / dur) ** 3)
        out.append(s * amp)
    return out


def giggle() -> list[float]:
    """Four bouncy squeaks: hee-hee-hee-hee, falling."""
    out: list[float] = []
    pitches = [1250, 1180, 1100, 1020]
    for k, p in enumerate(pitches):
        out += squeak(p, 0.075, vib=34, depth=0.05, up=0.18)
        out += [0.0] * int(SR * (0.035 + 0.005 * k))
    return out


def boing() -> list[float]:
    dur = 0.55
    n = int(SR * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        wob = math.sin(TAU * 11 * t) * 0.18 * env_exp(t, 0.18)
        f = 210 * (1 + 0.9 * env_exp(t, 0.03)) * (1 + wob)
        phase += TAU * f / SR
        s = math.sin(phase) + 0.25 * math.sin(2 * phase)
        out.append(s * env_exp(t, 0.16) * (1 - env_exp(t, 0.004)))
    return out


def bell(freq: float, dur: float, decay: float) -> list[float]:
    n = int(SR * dur)
    partials = [(1.0, 1.0), (2.0, 0.5), (2.76, 0.32), (5.4, 0.14)]
    out = []
    for i in range(n):
        t = i / SR
        s = sum(a * math.sin(TAU * freq * r * t) * env_exp(t, decay / r ** 0.5) for r, a in partials)
        out.append(s * (1 - env_exp(t, 0.002)))
    return out


def mix(*tracks: tuple[float, list[float]]) -> list[float]:
    length = max(int(off * SR) + len(tr) for off, tr in tracks)
    out = [0.0] * length
    for off, tr in tracks:
        o = int(off * SR)
        for i, s in enumerate(tr):
            out[o + i] += s
    return out


def chime() -> list[float]:
    """Combo tier: a quick major-triad sparkle (C6 E6 G6 C7)."""
    notes = [1046.5, 1318.5, 1568.0, 2093.0]
    return mix(*[(0.055 * k, bell(f, 0.9, 0.22)) for k, f in enumerate(notes)])


def fanfare() -> list[float]:
    """Unlock / new best: a bouncier, longer arpeggio that resolves up."""
    notes = [784.0, 988.0, 1175.0, 1568.0, 1976.0, 2349.0]
    return mix(*[(0.075 * k, bell(f, 1.2, 0.3)) for k, f in enumerate(notes)])


def pop() -> list[float]:
    """Rush hit: a bright cork pop."""
    dur = 0.09
    n = int(SR * dur)
    rnd = random.Random(3)
    out = []
    phase = 0.0
    lp = 0.0
    for i in range(n):
        t = i / SR
        f = 900 * (1 + 1.2 * env_exp(t, 0.008))
        phase += TAU * f / SR
        noise = rnd.random() * 2 - 1
        lp += 0.35 * (noise - lp)
        out.append((math.sin(phase) * 0.9 + lp * 0.6 * env_exp(t, 0.004)) * env_exp(t, 0.025))
    return out


def golden() -> list[float]:
    return mix((0.0, pop()), (0.02, bell(1568.0, 0.6, 0.18)), (0.07, bell(2349.0, 0.6, 0.16)))


def oops() -> list[float]:
    """Booped a sleeper: a soft descending 'wah-wah'."""
    out = squeak(420, 0.16, vib=7, depth=0.03, up=-0.25) + [0.0] * int(SR * 0.03) + squeak(330, 0.24, vib=6, depth=0.04, up=-0.3)
    return out


def sneeze() -> list[float]:
    """A tiny 'a-CHOO': a rising squeaky inhale then a filtered noise burst."""
    rnd = random.Random(11)
    inhale = squeak(700, 0.22, vib=9, depth=0.02, up=0.6)
    inhale = [s * 0.55 for s in inhale]
    burst_len = int(SR * 0.28)
    burst = []
    lp = bp = 0.0
    for i in range(burst_len):
        t = i / SR
        x = rnd.random() * 2 - 1
        lp += 0.5 * (x - lp)
        bp += 0.25 * (lp - bp)
        tone = math.sin(TAU * (620 - 300 * t) * t) * 0.35
        burst.append((lp - bp + tone) * env_exp(t, 0.07) * (1 - env_exp(t, 0.004)))
    return inhale + [0.0] * int(SR * 0.05) + burst


def whoosh() -> list[float]:
    """Rush start: an airy sweep."""
    dur = 0.5
    n = int(SR * dur)
    rnd = random.Random(5)
    out = []
    lp = 0.0
    for i in range(n):
        t = i / SR
        a = 0.05 + 0.5 * math.sin(math.pi * t / dur) ** 2
        k = 0.04 + 0.4 * (t / dur)
        lp += k * ((rnd.random() * 2 - 1) - lp)
        out.append(lp * a)
    return out


def tick() -> list[float]:
    """Last-3-seconds countdown tick."""
    return [s * 0.8 for s in bell(1760.0, 0.12, 0.03)]


def hug() -> list[float]:
    """Hug: a warm, low 'mmm' hum with slow vibrato."""
    dur = 0.7
    n = int(SR * dur)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = 330 * (1 + 0.012 * math.sin(TAU * 5.5 * t)) * (1 + 0.06 * (t / dur))
        phase += TAU * f / SR
        s = math.sin(phase) + 0.4 * math.sin(2 * phase) + 0.15 * math.sin(3 * phase)
        amp = (1 - env_exp(t, 0.06)) * (1 - (t / dur) ** 2)
        out.append(s * amp)
    return out


def main() -> None:
    print(f"rendering into {OUT}")
    base = 620.0  # boop_00
    for k in range(19):  # 12 critter base pitches + 7 combo steps
        write(f"boop_{k:02d}", finish(boop(base * 2 ** (k / 12)), gain=0.55))
    write("giggle", finish(giggle(), gain=0.5))
    write("boing", finish(boing(), gain=0.6))
    write("chime", finish(chime(), gain=0.55))
    write("fanfare", finish(fanfare(), gain=0.6))
    write("pop", finish(pop(), gain=0.6))
    write("golden", finish(golden(), gain=0.65))
    write("oops", finish(oops(), gain=0.5))
    write("sneeze", finish(sneeze(), gain=0.6))
    write("whoosh", finish(whoosh(), gain=0.45))
    write("tick", finish(tick(), gain=0.4))
    write("hug", finish(hug(), gain=0.45))


if __name__ == "__main__":
    main()

import numpy as np, scipy.io.wavfile as wv
from scipy import signal

SR = 48000
DUR = 23.9
N = int(DUR * SR)
rng = np.random.default_rng(3)

def tt(d): return np.arange(int(d * SR)) / SR
def hz(m): return 440.0 * 2 ** ((m - 69) / 12)
NOTE = {n: i for i, n in enumerate(['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'])}
def m(name):  # 'D3', 'A#2'
    return NOTE[name[:-1]] + 12 * (int(name[-1]) + 1)

class Bus:
    def __init__(s): s.x = np.zeros((N, 2))
    def add(s, sig, at, gain=1.0, pan=0.0):
        i0 = int(at * SR)
        if sig.ndim == 1:
            l = np.cos((pan + 1) * np.pi / 4); r = np.sin((pan + 1) * np.pi / 4)
            sig = np.stack([sig * l * 1.414, sig * r * 1.414], 1)
        if i0 < 0: sig = sig[-i0:]; i0 = 0
        n = min(len(sig), N - i0)
        if n > 0: s.x[i0:i0 + n] += sig[:n] * gain

def sos(kind, f, order=2):
    return signal.butter(order, f, btype=kind, fs=SR, output='sos')
def filt(x, kind, f, order=2):
    return signal.sosfilt(sos(kind, f, order), x, axis=0)
def env_exp(n, dec, att=0.003):
    t = np.arange(n) / SR
    a = np.minimum(1, t / max(att, 1e-4))
    return a * np.exp(-t / dec)
def noise(d): return rng.standard_normal(int(d * SR))
def sweep_bp(x, f0, f1, q=2.0, block=256, curve=None):
    out = np.zeros_like(x); zi = None; nb = len(x) // block + 1
    for b in range(nb):
        p = b / max(1, nb - 1)
        if curve is not None: p = curve(p)
        f = f0 * (f1 / f0) ** p if f1 > 0 else f0
        lo, hi = f / (1 + 1 / q), min(f * (1 + 1 / q), SR / 2 - 100)
        s_ = signal.butter(2, [lo, hi], btype='band', fs=SR, output='sos')
        seg = x[b * block:(b + 1) * block]
        if len(seg) == 0: break
        if zi is None: zi = np.zeros((s_.shape[0], 2))
        y, zi = signal.sosfilt(s_, seg, zi=zi)
        out[b * block:b * block + len(seg)] = y
    return out

def bell(freqs, d, dec, amps=None, inharm=True):
    t = tt(d); y = np.zeros_like(t)
    amps = amps or [1] * len(freqs)
    for f, a in zip(freqs, amps):
        y += a * np.sin(2 * np.pi * f * t) * np.exp(-t / dec)
        if inharm: y += 0.18 * a * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t / (dec * 0.35))
    y *= np.minimum(1, t / 0.002)
    return y

def pad_voice(f, d, bright=0.75, det=0.0025):
    t = tt(d); y = np.zeros_like(t)
    for dd in (-det, 0, det):
        ph = rng.uniform(0, 6.28)
        for k in range(1, 9):
            y += (bright ** k) / k * np.sin(2 * np.pi * f * (1 + dd) * k * t + ph * k)
    return y / 3

music, fxb, voice, verb_send = Bus(), Bus(), Bus(), Bus()

# ---------------- music: pad progression (D minor) ----------------
chords = [
    (0.15, 2.3, ['D2', 'A2', 'D3', 'F3', 'A3'], 0.45, 0.08),
    (2.2, 6.95, ['D2', 'A2', 'D3', 'F3', 'A3', 'E4'], 0.62, 0.30),
    (6.9, 10.35, ['A#1', 'A#2', 'D3', 'F3', 'A3'], 0.62, 0.20),
    (10.3, 14.25, ['F2', 'C3', 'F3', 'A3', 'C4'], 0.68, 0.20),
    (14.2, 17.85, ['C2', 'G2', 'C3', 'E3', 'G3', 'D4'], 0.7, 0.22),
    (17.8, 20.15, ['D2', 'A2', 'D3', 'F3', 'A3', 'E4'], 0.72, 0.24),
    (20.1, 23.9, ['A#1', 'F2', 'D3', 'F3', 'A3', 'D4'], 0.66, 0.22),
]
for (a, b, notes, br, g) in chords:
    d = b - a + 0.6
    y = sum(pad_voice(hz(m(n)), d, br) for n in notes) / len(notes)
    t = tt(d)
    e = np.minimum(1, t / 0.45) * np.clip((d - t) / 0.6, 0, 1)
    if a < 1: e *= np.minimum(1, t / 2.0)
    if a > 20: e *= np.clip(1 - (t - 2.4) / 1.4, 0, 1)  # final fade
    y = filt(y * e, 'lowpass', 1400 if a < 17 else 2200)
    music.add(y, a, g, 0)
# rising swell over reveal (filter opens)
d = 3.4; y = sum(pad_voice(hz(m(n)), d, 0.85) for n in ['A#3', 'D4', 'F4']) / 3
y = sweep_bp(y, 300, 2400, q=0.8) * np.linspace(0, 1, len(y)) ** 2
music.add(y, 6.9, 0.25)
# sub bass under sections
for (a, b, root) in [(2.4, 6.9, 'D2'), (6.9, 10.3, 'A#1'), (10.3, 14.2, 'F1'), (14.2, 17.8, 'C2'), (17.8, 20.1, 'D2'), (20.1, 23.6, 'A#1')]:
    d = b - a; t = tt(d); f = hz(m(root))
    y = np.sin(2 * np.pi * f * t) * np.minimum(1, t / 0.3) * np.clip((d - t) / 0.3, 0, 1)
    if a > 20: y *= np.clip(1 - (t - 1.5) / 2.0, 0, 1)
    music.add(y, a, 0.16)
# pulses: 8ths at 120 bpm through team + workspace, 16ths in the build
arp = {10.3: ['F4', 'A4', 'C5', 'A4'], 14.2: ['C5', 'E5', 'G5', 'E5'], 17.0: ['D5', 'F5', 'A5', 'F5']}
tpos = 10.55; k = 0
while tpos < 17.8:
    key = max(kk for kk in arp if kk <= tpos)
    n = arp[key][k % 4]
    step = 0.125 if tpos > 17.2 else 0.25
    pl = np.sin(2 * np.pi * hz(m(n)) * tt(0.2)) + 0.3 * np.sin(4 * np.pi * hz(m(n)) * tt(0.2))
    pl *= env_exp(len(pl), 0.07)
    music.add(filt(pl, 'lowpass', 3000), tpos, 0.035 + 0.02 * (tpos > 14.2), pan=0.35 * np.sin(k * 1.3))
    tpos += step; k += 1

# ---------------- effects ----------------
def whoosh(d, f0, f1, q=1.6, metal=False, curve=None):
    x = noise(d); y = sweep_bp(x, f0, f1, q, curve=curve)
    t = tt(d); e = np.sin(np.pi * np.clip(t / d, 0, 1)) ** 1.5
    y *= e
    if metal:
        dl = int(0.0023 * SR); z = y.copy()
        for i in range(dl, len(z)): z[i] += 0.6 * z[i - dl]
        y = 0.6 * y + 0.4 * z / 3
    return y / (np.abs(y).max() + 1e-9)

def impact(f0=70, f1=34, d=1.0, nlp=300):
    t = tt(d); f = f1 + (f0 - f1) * np.exp(-t / 0.12)
    ph = 2 * np.pi * np.cumsum(f) / SR
    y = np.sin(ph) * env_exp(len(t), 0.35, 0.002)
    y += 0.5 * filt(noise(d), 'lowpass', nlp) * env_exp(len(t), 0.09)
    return y / np.abs(y).max()

def click(d=0.012, hp=2500):
    y = filt(noise(d), 'highpass', hp) * env_exp(int(d * SR), d / 4, 0.0005)
    return y / (np.abs(y).max() + 1e-9)

def tone(f, d, dec, h2=0.2):
    t = tt(d); y = (np.sin(2 * np.pi * f * t) + h2 * np.sin(4 * np.pi * f * t)) * env_exp(len(t), dec, 0.004)
    return y

def glide(f0, f1, d, dec=None):
    t = tt(d); f = f0 * (f1 / f0) ** (t / d); ph = 2 * np.pi * np.cumsum(f) / SR
    e = np.sin(np.pi * t / d) if dec is None else env_exp(len(t), dec, 0.01)
    return np.sin(ph) * e

def add(sig, at, g, pan=0, send=0.0):
    fxb.add(sig, at, g, pan)
    if send: verb_send.add(sig, at, g * send, pan)

# 0:00 ignition
y = filt(noise(1.6), 'lowpass', 70, 4) * np.sin(np.pi * np.clip(tt(1.6) / 1.6, 0, 1)); add(y / np.abs(y).max(), 0.0, 0.10)
t = tt(0.8); y = sum(np.sin(2 * np.pi * 110 * k * t) / k for k in range(1, 6)) * np.sin(np.pi * t / 0.8) ** 2 * (1 + 0.3 * np.sin(2 * np.pi * 9 * t))
add(filt(y, 'lowpass', 900) / 3, 0.08, 0.05, send=0.2)
w = whoosh(0.95, 250, 3200, metal=True, curve=lambda p: np.sin(p * np.pi) * 0.85)
fxb.add(np.stack([w * np.linspace(0.9, 0.3, len(w)), w * np.linspace(0.4, 1.0, len(w))], 1), 0.35, 0.22)
verb_send.add(w, 0.35, 0.05)
add(bell([hz(m('D6')), hz(m('A6')), hz(m('D7'))], 2.0, 0.6, [1, 0.6, 0.25]), 0.97, 0.09, send=0.5)
add(impact(), 1.24, 0.42, send=0.15)
t = tt(0.9); y = (np.sin(2 * np.pi * hz(m('D7')) * t) + 0.6 * np.sin(2 * np.pi * hz(m('A7')) * t)) * (0.5 + 0.5 * np.sin(2 * np.pi * 13 * t)) * np.sin(np.pi * t / 0.9) ** 2
add(y, 1.12, 0.018, send=0.6)

# 0:02 roles
for (at, kind) in [(4.3, 'eng'), (4.85, 'des'), (5.4, 'res'), (5.95, 'back')]:
    if kind in ('eng', 'back'):
        add(click(0.01, 1800), at, 0.10, pan=0.1)
        add(tone(hz(m('D2')), 0.35, 0.12, 0.5), at, 0.22)
    if kind == 'des':
        add(bell([hz(m('A6'))], 0.6, 0.18, [1]), at, 0.07, pan=-0.2, send=0.4)
        y = filt(noise(0.35), 'highpass', 6000) * np.sin(np.pi * tt(0.35) / 0.35) ** 2; add(y, at, 0.02, send=0.5)
    if kind == 'res':
        y = glide(3000, 300, 0.32)[::-1] * np.linspace(0, 1, int(0.32 * SR)) ** 2; add(y, at - 0.08, 0.035, pan=0.2, send=0.3)
        mod = np.concatenate([np.sin(2 * np.pi * (1200 if i % 2 else 2200) * tt(0.028)) for i in range(7)])
        add(filt(mod, 'bandpass', [900, 2600]) * 0.5, at + 0.05, 0.012, pan=-0.3)
    if kind == 'back':
        add(bell([hz(m('D6'))], 0.6, 0.2), at, 0.04, send=0.3)
        add(impact(90, 45, 0.7), at, 0.22)

# 0:05 reveal
R = np.random.default_rng(11)
pent = ['D5', 'F5', 'G5', 'A5', 'C6', 'D6']
for i in range(26):
    at = 7.1 + i * 0.085 + R.uniform(-0.02, 0.02)
    add(tone(hz(m(pent[i % 6])), 0.08, 0.018, 0.1), at, 0.012 + 0.006 * (i / 26), pan=R.uniform(-0.8, 0.8), send=0.3)
for i in range(14):
    at = 8.6 + i * 0.09
    add(click(0.006, 3500), at, 0.03, pan=R.uniform(-0.7, 0.7))
    if i % 4 == 0: add(filt(noise(0.04), 'bandpass', [3000, 6000]) * env_exp(int(0.04 * SR), 0.01), at + 0.02, 0.015, pan=R.uniform(-0.6, 0.6))
add(impact(73, 36, 1.6, 200), 9.0, 0.48, send=0.25)
t = tt(0.45); f = hz(m('D4')) * (hz(m('A4')) / hz(m('D4'))) ** (t / 0.45)
y = sum(np.sin(2 * np.pi * np.cumsum(f * k) / SR) / k for k in range(1, 6)) * (t / 0.45) ** 2
add(filt(y, 'lowpass', 2500), 9.88, 0.05, send=0.3)

# 0:08 team
w = whoosh(0.8, 150, 2400, q=1.2); add(w, 10.3, 0.12, send=0.2)
MSGT = [(10.95, 260, 610), (11.45, 960, 1310), (11.95, 1310, 960), (12.45, 960, 1660), (12.95, 1660, 960)]
for (at, x0, x1) in MSGT:
    add(click(0.008, 3000), at, 0.06, pan=(x0 - 960) / 960 * 0.8)
    add(tone(hz(m('A5')), 0.12, 0.03, 0.05), at, 0.025, pan=(x0 - 960) / 960 * 0.8)
    p = tone(hz(m('D6')), 0.45, 0.15, 0.0)
    pan = np.linspace((x0 - 960) / 960 * 0.9, (x1 - 960) / 960 * 0.9, len(p))
    L = np.cos((pan + 1) * np.pi / 4) * 1.414; Rr = np.sin((pan + 1) * np.pi / 4) * 1.414
    fxb.add(np.stack([p * L, p * Rr], 1), at + 0.42, 0.025); verb_send.add(p, at + 0.42, 0.012)
y = np.concatenate([tone(hz(m('F4')), 0.14, 0.06, 0.6), tone(hz(m('D4')), 0.22, 0.08, 0.6)]); add(filt(y, 'lowpass', 1200), 11.97, 0.07)
add(glide(hz(m('D5')), hz(m('A5')), 0.3) * 0.8, 12.47, 0.05, send=0.3)
for i, n in enumerate(['D6', 'F6', 'A6']): add(bell([hz(m(n))], 0.9, 0.25), 12.97 + i * 0.07, 0.045, pan=0.3, send=0.4)
d = 1.2; t = tt(d); y = sum(pad_voice(hz(m(n)), d, 0.8) for n in ['F3', 'A3', 'C4', 'F4']) / 4 * (t / d) ** 2
add(filt(y, 'lowpass', 2500), 12.95, 0.14, send=0.3)
for i in range(3): add(tone(hz(m('A5')), 0.06, 0.02, 0.4) + tone(hz(m('A4')), 0.06, 0.02), 13.85 + i * 0.12, 0.03)

# 0:12 workspace
w = whoosh(0.45, 400, 5000, q=1.4)
fxb.add(np.stack([w * np.linspace(0.3, 1, len(w)), w * np.linspace(1, 0.3, len(w))], 1), 13.95, 0.2)
pans = {14.22: 0.0, 14.7: 0.6, 14.95: -0.6, 15.2: -0.6, 15.45: 0.6, 15.7: 0.0, 15.95: 0.0}
for i, (at, pn) in enumerate(pans.items()):
    n = ['D5', 'E5', 'F5', 'G5', 'A5', 'C6', 'D6'][i]
    add(tone(hz(m(n)), 0.12, 0.035, 0.3), at + 0.05, 0.03, pan=pn, send=0.25)
    add(click(0.006, 2500), at + 0.05, 0.02, pan=pn)
add(tone(120, 0.25, 0.06, 0.2), 14.3, 0.12)
for i in range(9): add(click(0.004, 4000), 15.0 + i * 0.075, 0.015, pan=0.6)
add(glide(400, 820, 2.2) * 0.6, 15.0, 0.012)
for i in range(30):
    at = 15.35 + i * 0.06 + R.uniform(0, 0.02)
    if at > 17.7: break
    add(filt(noise(0.012), 'bandpass', [1500, 5000]) * env_exp(int(0.012 * SR), 0.003), at, 0.012, pan=-0.6)
t = tt(1.6); y = filt(noise(1.6), 'highpass', 5000) * (0.5 + 0.5 * np.sin(2 * np.pi * 3 * t)) * np.sin(np.pi * t / 1.6) ** 2
add(y, 15.6, 0.006, pan=0.6, send=0.4)
for i, n in enumerate(['D6', 'A6', 'D7']): add(bell([hz(m(n))], 0.8, 0.25), 16.9 + i * 0.06, 0.04, send=0.4)
for (at, pn) in pans.items():
    if at > 14.5: add(tone(hz(m('A6')), 0.2, 0.06, 0.0), at + 0.4, 0.012, pan=pn * 1.2)
d = 0.65; t = tt(d); f = hz(m('D3')) * 2 ** (t / d)
y = sum(np.sin(2 * np.pi * np.cumsum(f * k) / SR) / k for k in range(1, 7)) * (t / d) ** 2
y += 0.6 * whoosh(d, 300, 6000, q=1) * (t / d)
add(filt(y, 'lowpass', 4000), 17.15, 0.06, send=0.2)

# 0:16 connects
w = whoosh(0.55, 600, 8000, q=1.0, curve=lambda p: p ** 1.5); add(w, 17.8, 0.12)
for i in range(6): add(tone(hz(m(['D6', 'C6', 'A5', 'G5', 'F5', 'D5'][i])), 0.06, 0.02, 0.2), 18.0 + i * 0.05, 0.02)
add(impact(62, 38, 1.4, 260), 18.3, 0.36, send=0.25)
add(bell([hz(m('D5')), hz(m('A5')), hz(m('D6'))], 2.0, 0.6, [1, 0.6, 0.4]), 18.5, 0.06, send=0.5)
t = tt(0.9); y = filt(noise(0.9), 'highpass', 7000) * np.sin(np.pi * t / 0.9) ** 2; add(y, 18.66, 0.012, send=0.6)
add(tone(hz(m('D2')), 0.5, 0.18, 0.3), 19.6, 0.15)

# 0:18 final
rv = filt(noise(0.35), 'bandpass', [800, 9000]) * np.linspace(0, 1, int(0.35 * SR)) ** 3
add(rv, 19.76, 0.08, send=0.3)
add(impact(80, 36, 1.8, 400), 20.1, 0.45, send=0.3)
add(click(0.02, 1200), 20.1, 0.12)
add(bell([hz(m('D3')), hz(m('D4')), hz(m('A4'))], 3.0, 1.1, [1, 0.7, 0.4], inharm=False), 20.5, 0.11, send=0.4)
for i, n in enumerate(['A5', 'C6', 'D6']): add(bell([hz(m(n))], 0.8, 0.22), [20.95, 21.35, 21.75][i], 0.035, send=0.5)
t = tt(1.0); y = (np.sin(2 * np.pi * hz(m('D7')) * t) + 0.5 * np.sin(2 * np.pi * hz(m('A7')) * t)) * (0.5 + 0.5 * np.sin(2 * np.pi * 11 * t)) * np.sin(np.pi * t / 1.0) ** 2
add(y, 22.15, 0.008, send=0.6)
add(click(0.008, 1500), 22.45, 0.03)
d = 1.4; t = tt(d); y = np.sin(2 * np.pi * hz(m('D2')) * t) * (1 - t / d) ** 2 + 0.3 * filt(noise(d), 'bandpass', [200, 1200]) * (1 - t / d) ** 3
add(y, 22.5, 0.12, send=0.3)

# ---------------- voice ----------------
vtimes = {'l1': (2.35, 0.20), 'l2': (6.05, 0.06), 'l3': (8.9, 0.24)}
venv = np.zeros(N)
for k, (at, send) in vtimes.items():
    sr, a = wv.read(f'voice/{k}.wav'); a = a.astype(float) / 32768
    a = signal.resample_poly(a, 320, 147)
    a = filt(a, 'highpass', 90)
    a = a / np.abs(a).max()
    # slight warmth
    a = 0.85 * a + 0.15 * filt(a, 'lowpass', 2500)
    voice.add(a, at, 0.5)
    verb_send.add(a, at, 0.5 * send)
    i0 = int(at * SR); venv[i0:i0 + len(a)] = np.maximum(venv[i0:i0 + len(a)], np.abs(a))
# duck envelope
win = int(0.08 * SR)
venv = np.convolve(venv, np.ones(win) / win, 'same')
duck = 1 - 0.5 * np.clip(venv * 6, 0, 1)
duck = np.convolve(duck, np.ones(int(0.12 * SR)) / int(0.12 * SR), 'same')

# ---------------- reverb ----------------
def ir(length, dec):
    t = tt(length)
    l = rng.standard_normal(len(t)) * np.exp(-t / dec); r = rng.standard_normal(len(t)) * np.exp(-t / dec)
    l = filt(l, 'lowpass', 6000); r = filt(r, 'lowpass', 6000)
    return np.stack([l, r], 1) / np.sqrt(np.sum(l ** 2))
IR = ir(2.4, 0.55)
vs = verb_send.x
wet = np.stack([signal.fftconvolve(vs[:, 0], IR[:, 0])[:N], signal.fftconvolve(vs[:, 1], IR[:, 1])[:N]], 1)
wet = filt(wet, 'highpass', 200)
# music gets its own gentle space too
mwet = np.stack([signal.fftconvolve(music.x[:, 0], IR[:, 0])[:N], signal.fftconvolve(music.x[:, 1], IR[:, 1])[:N]], 1)

mix = (music.x + 0.25 * mwet) * duck[:, None] * 1.0 + fxb.x * 1.0 + voice.x * 1.0 + wet * 0.9
# gentle glue: soft clip
pk = np.abs(mix).max(); mix = mix / pk * 0.95
mix = np.tanh(mix * 1.25) / np.tanh(1.25)
# final fade
t = np.arange(N) / SR
mix *= np.clip((DUR - t) / 0.5, 0, 1)[:, None]
mix = mix / np.abs(mix).max() * 0.89
wv.write('audio.wav', SR, (mix * 32767).astype(np.int16))
print('ok', mix.shape, 'voice peak share', np.abs(voice.x).max(), np.abs(music.x).max(), np.abs(fxb.x).max())

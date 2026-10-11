"use client";

// G7 — every element type has its own short sound. All sounds are synthesized
// with WebAudio (no audio files), so nothing is copied from the reference site.

import { useSyncExternalStore } from "react";

let ctx = null;
let muted = false;
const listeners = new Set();

if (typeof window !== "undefined") {
  try {
    const saved = localStorage.getItem("kiln-sound");
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    muted = saved === null ? reduce : saved === "off";
  } catch {}
}

function audio() {
  if (!ctx) {
    const AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return null;
    ctx = new AC();
  }
  if (ctx.state === "suspended") ctx.resume();
  return ctx;
}

function tone(a, { f = 880, f2, type = "sine", dur = 0.06, vol = 0.18, at = 0 }) {
  const t = a.currentTime + at;
  const o = a.createOscillator();
  const g = a.createGain();
  o.type = type;
  o.frequency.setValueAtTime(f, t);
  if (f2) o.frequency.exponentialRampToValueAtTime(f2, t + dur);
  g.gain.setValueAtTime(0.0001, t);
  g.gain.exponentialRampToValueAtTime(vol, t + 0.004);
  g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
  o.connect(g).connect(a.destination);
  o.start(t);
  o.stop(t + dur + 0.02);
}

function noise(a, { dur = 0.04, vol = 0.12, at = 0, hp = 1800 }) {
  const t = a.currentTime + at;
  const len = Math.floor(a.sampleRate * dur);
  const buf = a.createBuffer(1, len, a.sampleRate);
  const d = buf.getChannelData(0);
  for (let i = 0; i < len; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / len) ** 2;
  const src = a.createBufferSource();
  src.buffer = buf;
  const filt = a.createBiquadFilter();
  filt.type = "highpass";
  filt.frequency.value = hp;
  const g = a.createGain();
  g.gain.value = vol;
  src.connect(filt).connect(g).connect(a.destination);
  src.start(t);
}

const SOUNDS = {
  tick: (a) => tone(a, { f: 2200, f2: 1600, type: "triangle", dur: 0.035, vol: 0.08 }),
  nav: (a) => { tone(a, { f: 1400, f2: 1100, type: "triangle", dur: 0.04, vol: 0.1 }); noise(a, { dur: 0.02, vol: 0.05 }); },
  pop: (a) => tone(a, { f: 380, f2: 820, type: "sine", dur: 0.09, vol: 0.2 }),
  shuffle: (a) => { for (let i = 0; i < 5; i++) noise(a, { dur: 0.03, vol: 0.09, at: i * 0.07, hp: 2400 }); },
  key: (a) => { tone(a, { f: 160, f2: 90, type: "sine", dur: 0.07, vol: 0.28 }); noise(a, { dur: 0.025, vol: 0.08, hp: 3000 }); },
  command: (a) => { tone(a, { f: 660, type: "sine", dur: 0.08, vol: 0.14 }); tone(a, { f: 990, type: "sine", dur: 0.12, vol: 0.12, at: 0.07 }); },
  swatch: (a) => tone(a, { f: 1200, f2: 700, type: "triangle", dur: 0.05, vol: 0.12 }),
  open: (a) => { tone(a, { f: 392, type: "sine", dur: 0.35, vol: 0.08 }); tone(a, { f: 494, type: "sine", dur: 0.35, vol: 0.06, at: 0.04 }); tone(a, { f: 587, type: "sine", dur: 0.4, vol: 0.05, at: 0.08 }); },
  nock: (a) => { tone(a, { f: 520, f2: 260, type: "square", dur: 0.05, vol: 0.05 }); tone(a, { f: 260, f2: 180, type: "sine", dur: 0.1, vol: 0.18 }); },
  success: (a) => { tone(a, { f: 784, type: "sine", dur: 0.1, vol: 0.12 }); tone(a, { f: 1175, type: "sine", dur: 0.16, vol: 0.1, at: 0.08 }); },
};

export function play(name) {
  if (muted || typeof window === "undefined") return;
  const a = audio();
  if (!a) return;
  try { (SOUNDS[name] || SOUNDS.tick)(a); } catch {}
}

export function setMuted(v) {
  muted = v;
  try { localStorage.setItem("kiln-sound", v ? "off" : "on"); } catch {}
  listeners.forEach((l) => l());
}

export function useMuted() {
  return useSyncExternalStore(
    (l) => { listeners.add(l); return () => listeners.delete(l); },
    () => muted,
    () => true
  );
}

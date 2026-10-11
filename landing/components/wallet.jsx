"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { motion, AnimatePresence } from "motion/react";
import { ArrowUp, ArrowDown, ArrowLeft, ArrowRight, Maximize2, X } from "lucide-react";
import Card from "./Card";
import { Label } from "./ui";
import { ScaledScreen, SCREENS } from "./screens";
import { play } from "@/lib/sound";

const N = SCREENS.length;
const CARD_W = 380;
const STEP = 44; // visible strip of each card in the stack
const SPREAD = 116; // extra room under the active card
const PREVIEW_W = 688;
const EASE = [0.22, 1, 0.36, 1];

function useFlip(n) {
  const [state, setState] = useState({ i: 0, dir: 1 });
  const go = useCallback((to) => {
    setState((s) => {
      const t = ((to % n) + n) % n;
      if (t === s.i) return s;
      play("tick");
      return { i: t, dir: t > s.i ? 1 : -1 };
    });
  }, [n]);
  return [state, go];
}

function useWheelFlip(ref, onStep, enabled = true) {
  useEffect(() => {
    const el = ref.current;
    if (!el || !enabled) return;
    let last = 0;
    const onWheel = (e) => {
      e.preventDefault();
      const now = Date.now();
      if (now - last < 260 || Math.abs(e.deltaY) < 4) return;
      last = now;
      onStep(e.deltaY > 0 ? 1 : -1);
    };
    el.addEventListener("wheel", onWheel, { passive: false });
    return () => el.removeEventListener("wheel", onWheel);
  }, [ref, onStep, enabled]);
}

/* Big preview that flips top → bottom when the active screen changes */
function FlipView({ i, dir, width, onClick }) {
  const h = (width * 750) / 1200;
  return (
    <div className="flip-view" style={{ width, height: h }} onClick={onClick}>
      <AnimatePresence initial={false} custom={dir}>
        <motion.div
          key={i}
          custom={dir}
          className="flip-page"
          variants={{
            enter: (d) => ({ y: d > 0 ? "-18%" : "18%", opacity: 0, scale: 0.98 }),
            center: { y: 0, opacity: 1, scale: 1 },
            exit: (d) => ({ y: d > 0 ? "18%" : "-18%", opacity: 0, scale: 0.98 }),
          }}
          initial="enter"
          animate="center"
          exit="exit"
          transition={{ duration: 0.45, ease: EASE }}
        >
          <ScaledScreen id={i} width={width} />
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

function Lightbox({ start, onClose }) {
  const [{ i, dir }, go] = useFlip(N);
  const [w, setW] = useState(1000);
  const ref = useRef(null);
  useEffect(() => { go(start); }, [start, go]);
  useEffect(() => {
    const fit = () => setW(Math.min(innerWidth * 0.84, 1200, (innerHeight - 170) * 1.6));
    fit();
    addEventListener("resize", fit);
    const onKey = (e) => {
      if (e.key === "Escape") onClose();
      if (e.key === "ArrowRight" || e.key === "ArrowDown") go(i + 1);
      if (e.key === "ArrowLeft" || e.key === "ArrowUp") go(i - 1);
    };
    addEventListener("keydown", onKey);
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { removeEventListener("resize", fit); removeEventListener("keydown", onKey); document.body.style.overflow = prev; };
  }, [i, go, onClose]);
  useWheelFlip(ref, (d) => go(i + d));
  return createPortal(
    <motion.div ref={ref} className="lightbox" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.2 }} onClick={onClose}>
      <motion.div className="lb-stage" initial={{ scale: 0.96, y: 12 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.97, y: 8 }} transition={{ duration: 0.3, ease: EASE }} onClick={(e) => e.stopPropagation()}>
        <FlipView i={i} dir={dir} width={w} />
        <div className="lb-bar">
          <span className="mono lb-count">{String(i + 1).padStart(2, "0")} / {String(N).padStart(2, "0")}</span>
          <span className="lb-name"><b>{SCREENS[i].name}</b> — {SCREENS[i].desc}</span>
          <span className="lb-dots">
            {SCREENS.map((_, k) => <button key={k} className={k === i ? "on" : ""} onClick={() => go(k)} aria-label={SCREENS[k].name} />)}
          </span>
        </div>
      </motion.div>
      <button className="lb-btn left" onClick={(e) => { e.stopPropagation(); go(i - 1); }} aria-label="Previous"><ArrowLeft size={20} /></button>
      <button className="lb-btn right" onClick={(e) => { e.stopPropagation(); go(i + 1); }} aria-label="Next"><ArrowRight size={20} /></button>
      <button className="lb-btn close" onClick={onClose} aria-label="Close"><X size={20} /></button>
    </motion.div>,
    document.body
  );
}

export function ScreensWallet() {
  const [{ i, dir }, go] = useFlip(N);
  const [open, setOpen] = useState(null);
  const stackRef = useRef(null);
  const step = useCallback((d) => go(i + d), [go, i]);
  useWheelFlip(stackRef, step, open === null);

  const openAt = (k) => { play("nock"); setOpen(k); };

  return (
    <Card w={4} h={3} arrow={false} noSpot className="wallet-card">
      <div className="wallet-head">
        <Label dot="var(--ember)">Look inside</Label>
        <p className="h-display" style={{ fontSize: 34, letterSpacing: -0.8 }}>The app, screen by screen.</p>
        <p className="feat-desc">Hover a card to pull it out. Scroll over the stack to flip, click to open full size.</p>
      </div>

      <div className="wallet" ref={stackRef} style={{ height: STEP * (N - 1) + SPREAD + 278 }}>
        {SCREENS.map((s, k) => {
          const y = k * STEP + (k > i ? SPREAD : 0) - (k === i ? 6 : 0);
          return (
            <motion.div
              key={s.name}
              role="button"
              tabIndex={0}
              className={`w-card ${k === i ? "on" : ""}`}
              style={{ zIndex: k + 1 }}
              animate={{ y }}
              transition={{ type: "spring", stiffness: 320, damping: 32 }}
              onMouseEnter={() => go(k)}
              onFocus={() => go(k)}
              onClick={() => openAt(k)}
              onKeyDown={(e) => { if (e.key === "Enter") openAt(k); }}
            >
              <span className="w-tab">
                <span className="mono">{String(k + 1).padStart(2, "0")}</span>
                <b>{s.name}</b>
                <i />
              </span>
              <ScaledScreen id={k} width={CARD_W} />
            </motion.div>
          );
        })}
      </div>

      <div className="wallet-preview">
        <FlipView i={i} dir={dir} width={PREVIEW_W} onClick={() => openAt(i)} />
        <div className="wp-bar">
          <span className="wp-text">
            <AnimatePresence mode="wait" initial={false}>
              <motion.span key={i} initial={{ opacity: 0, y: -6 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 6 }} transition={{ duration: 0.18 }} style={{ display: "flex", flexDirection: "column", gap: 4 }}>
                <b>{SCREENS[i].name}</b>
                <span>{SCREENS[i].desc}</span>
              </motion.span>
            </AnimatePresence>
          </span>
          <span className="mono wp-count">{String(i + 1).padStart(2, "0")} / {String(N).padStart(2, "0")}</span>
          <button className="wp-btn" onClick={() => go(i - 1)} aria-label="Previous"><ArrowUp size={16} /></button>
          <button className="wp-btn" onClick={() => go(i + 1)} aria-label="Next"><ArrowDown size={16} /></button>
          <button className="wp-btn" onClick={() => openAt(i)} aria-label="Open full size"><Maximize2 size={16} /></button>
        </div>
      </div>

      <AnimatePresence>{open !== null && <Lightbox start={open} onClose={() => setOpen(null)} />}</AnimatePresence>
    </Card>
  );
}

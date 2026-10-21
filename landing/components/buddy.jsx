"use client";

import { useEffect, useState } from "react";
import { motion, useReducedMotion } from "motion/react";

// Blot — one ink body, two hook-eyes, no mouth; geometry from Pencil.
// Idle: blinks every few seconds. Active (hover on itself or on `active` from a parent):
// eyes turn into ^ ^, the slot becomes a smile and the whole thing does one squash-and-jump.

const JUMP = {
  y: [0, 0, -0.3, -0.34, 0, 0, 0],
  scaleY: [1, 0.84, 1.1, 1, 0.88, 1.04, 1],
  scaleX: [1, 1.12, 0.93, 1, 1.1, 0.98, 1],
  times: [0, 0.14, 0.38, 0.52, 0.74, 0.87, 1],
};

export function useHover() {
  const [on, set] = useState(false);
  return [on, { onMouseEnter: () => set(true), onMouseLeave: () => set(false) }];
}

// Wraps anything and makes it jump once each time `active` turns on.
export function Jump({ active, height = 64, children, className = "", style }) {
  const reduce = useReducedMotion();
  const [n, setN] = useState(0);
  useEffect(() => { if (active && !reduce) setN((v) => v + 1); }, [active, reduce]);
  return (
    <motion.span
      key={n}
      className={`jump ${className}`}
      style={{ display: "inline-block", originY: 1, ...style }}
      animate={n ? { y: JUMP.y.map((v) => v * height), scaleY: JUMP.scaleY, scaleX: JUMP.scaleX } : undefined}
      transition={{ duration: 0.7, times: JUMP.times, ease: "easeOut" }}
    >
      {children}
    </motion.span>
  );
}

export function BuddyFace({ size = 56, stroke = "var(--text)", ember = "var(--ember)", happy = false }) {
  const reduce = useReducedMotion();
  return (
    <svg width={size} height={size * (64 / 56)} viewBox="0 -20 120 140" aria-hidden style={{ display: "block", overflow: "visible" }}>
      <path d="M0 88v-54c0-7 4-11 12-15 14-7 26-14 38-17 5-1 10-1 14-1 29 0 54 17 55 44l1 43q0 12-12 12h-96q-12 0-12-12z" fill={stroke} />
      <circle cx="23" cy="62" r="5" fill={ember} />
      <motion.g style={{ transformBox: "fill-box", originY: 0.5 }}
        animate={!happy && !reduce ? { scaleY: [1, 1, 0.12, 1] } : { scaleY: 1 }}
        transition={!happy && !reduce ? { duration: 4.2, times: [0, 0.93, 0.965, 1], repeat: Infinity } : { duration: 0.12 }}>
        {[57, 80].map((x) => happy ? (
          <path key={x} d={`M${x} 38l8-9 8 9`} fill="none" stroke="var(--bg)" strokeWidth="4.2" strokeLinecap="round" strokeLinejoin="round" />
        ) : (
          <g key={x}>
            <rect x={x} y="23" width="16" height="21" rx="2.5" fill="var(--bg)" />
            <rect x={x} y="30" width="7" height="7" fill={stroke} />
          </g>
        ))}
      </motion.g>
    </svg>
  );
}

// Self-contained: hover it to make it smile and jump. Pass `active` to drive it from a parent.
export function BlotBuddy({ active, size = 56, ...face }) {
  const [hover, bind] = useHover();
  const on = active ?? hover;
  return (
    <span {...(active === undefined ? bind : {})} style={{ display: "inline-block", lineHeight: 0 }}>
      <Jump active={on} height={size * (64 / 56)}>
        <BuddyFace size={size} happy={on} {...face} />
      </Jump>
    </span>
  );
}

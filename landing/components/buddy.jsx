"use client";

import { useEffect, useState } from "react";
import { motion, useReducedMotion } from "motion/react";

// Kiln Buddy — the arch mark with a face: two vertical eyes, the ember slot as a mouth.
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

export function BuddyFace({ size = 56, stroke = "#EDEDED", ember = "#EDEDED", weight, happy = false }) {
  const reduce = useReducedMotion();
  const w = weight ?? size * 0.125;
  const eyes = [19.25, 36.75];
  const ew = Math.max(4.2, w * 0.72);
  const spring = { type: "spring", stiffness: 420, damping: 22 };
  return (
    <svg width={size} height={size * (64 / 56)} viewBox="0 0 56 64" aria-hidden style={{ display: "block", overflow: "visible" }}>
      <path
        d={`M${w / 2} ${64 - w / 2} V28 a${28 - w / 2} ${28 - w / 2} 0 0 1 ${56 - w} 0 V${64 - w / 2} Z`}
        fill="none" stroke={stroke} strokeWidth={w} strokeLinejoin="round"
      />
      {/* eyes: sticks that blink, or ^ ^ when happy */}
      <motion.g
        style={{ transformBox: "fill-box", originY: 0.5 }}
        animate={!happy && !reduce ? { scaleY: [1, 1, 0.12, 1] } : { scaleY: 1 }}
        transition={!happy && !reduce ? { duration: 4.2, times: [0, 0.93, 0.965, 1], repeat: Infinity, ease: "easeInOut" } : { duration: 0.1 }}
      >
        {eyes.map((cx) => (
          <motion.rect
            key={cx} x={cx - ew / 2} y={22.2} width={ew} height={12.6} rx={ew / 2} fill={stroke}
            animate={{ opacity: happy ? 0 : 1, scaleY: happy ? 0.3 : 1 }}
            style={{ transformBox: "fill-box", originY: 0.5 }}
            transition={{ duration: 0.12 }}
          />
        ))}
      </motion.g>
      {eyes.map((cx) => (
        <motion.path
          key={"h" + cx} d={`M${cx - 4.6} 31 Q${cx} 22.5 ${cx + 4.6} 31`}
          fill="none" stroke={stroke} strokeWidth={Math.max(2.8, w * 0.5)} strokeLinecap="round"
          initial={false}
          animate={{ pathLength: happy ? 1 : 0, opacity: happy ? 1 : 0 }}
          transition={{ duration: 0.18 }}
        />
      ))}
      {/* mouth: the ember slot, morphs into a smile */}
      <motion.rect
        x="18" y="42" width="20" height="7" rx="2" fill={ember}
        style={{ transformBox: "fill-box", originX: 0.5, originY: 0.5 }}
        initial={false}
        animate={{ opacity: happy ? 0 : 1, scaleX: happy ? 1.15 : 1 }}
        transition={{ duration: 0.12 }}
      />
      <motion.path
        d="M18.5 41.5 Q28 53 37.5 41.5"
        fill="none" stroke={ember} strokeWidth={Math.max(4, w * 0.7)} strokeLinecap="round"
        initial={false}
        animate={{ pathLength: happy ? 1 : 0, opacity: happy ? 1 : 0 }}
        transition={happy ? spring : { duration: 0.12 }}
      />
    </svg>
  );
}

// Self-contained: hover it to make it smile and jump. Pass `active` to drive it from a parent.
export function KilnBuddy({ active, size = 56, ...face }) {
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

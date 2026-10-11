"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { motion, AnimatePresence, useInView, useMotionValue, useSpring, useTransform, animate } from "motion/react";
import {
  Sparkle, Box, HardDrive, Folder, ShieldCheck, ArrowRight, Mail, Check, Rss, Send,
  GitCommitHorizontal, SquareTerminal, X,
} from "lucide-react";
import { siGithub, siGit, siLinear, siFigma, siNotion, siVercel } from "simple-icons";
import Card from "./Card";
import { Label, Badge, Traffic, Btn, Step, Approval, DiffLine, PlanItem, Brand, TerminalBlock } from "./ui";
import { play } from "@/lib/sound";

const OUT_BACK = [0.175, 0.885, 0.32, 1.275];

function useCountUp(to, active, { duration = 1.1, decimals = 0 } = {}) {
  const [v, setV] = useState(0);
  useEffect(() => {
    if (!active) return;
    const c = animate(0, to, { duration, ease: [0.19, 1, 0.22, 1], onUpdate: (x) => setV(x) });
    return () => c.stop();
  }, [active, to, duration]);
  return v.toFixed(decimals);
}

/* Manifesto-style hero shared by Features / Changelog */
export function Hero({ title, lines, footnote, children }) {
  return (
    <Card w={2} h={2} arrow={false} noSpot>
      <div className="manifesto">
        <h1 className="h-display">{title}</h1>
        <div className="rule" />
        <div className="lines tight">
          {lines.map((l, i) => (typeof l === "string" ? <p key={i}>{l}</p> : <p key={i}><strong>{l.b}</strong></p>))}
        </div>
        {children}
        {footnote && <div className="footnote"><span>*</span><span>{footnote}</span></div>}
      </div>
    </Card>
  );
}

/* Big ghost word that rapid-fires on hover (shared with Home's “Local”) */
export function BigType({ words, size = 66, caption }) {
  const [i, setI] = useState(0);
  const [slam, setSlam] = useState(0);
  const busy = useRef(false);
  const fire = () => {
    if (busy.current) return;
    busy.current = true;
    let k = 0;
    const id = setInterval(() => {
      k += 1;
      play("tick");
      if (k >= 6) { clearInterval(id); setI(0); setSlam((s) => s + 1); setTimeout(() => (busy.current = false), 300); }
      else setI(k % words.length);
    }, 80);
  };
  return (
    <Card caption={caption} onMouseEnter={fire}>
      <div className="local-in">
        <motion.b style={{ fontSize: size }} key={slam} initial={slam ? { scale: 2.2 } : false} animate={{ scale: 1 }} transition={{ duration: 0.2, ease: [0.55, 0.055, 0.675, 0.19] }}>
          {words[i][0]}
        </motion.b>
        <span style={{ fontSize: 20 }}>{words[i][1]}</span>
      </div>
    </Card>
  );
}

/* ============ FEATURES ============ */

const MODELS = [
  [Sparkle, "Kiln 1 · High", "default"],
  [Box, "Anthropic", "your key"],
  [Box, "OpenAI", "your key"],
  [Box, "Google", "your key"],
  [HardDrive, "Ollama · local", "offline"],
];
export function AnyModel() {
  const [m, setM] = useState(0);
  return (
    <Card w={2} caption={{ title: "Models", text: "pick one per task" }}>
      <div className="feat-head" style={{ left: 24, top: 28, width: 236 }}>
        <Label dot="var(--ember)">Models</Label>
        <p className="h-card">Any model. Switch per task.</p>
        <p className="feat-desc" style={{ fontSize: 15 }}>Bring your own key or use Kiln credits. No vendor lock-in.</p>
      </div>
      <div className="model-menu">
        <div className="mm-label">Model for this task</div>
        {MODELS.map(([I, l, meta], i) => (
          <button key={l} className="mm-row" onClick={() => { setM(i); play("tick"); }}>
            {m === i && <motion.span layoutId="mm-sel" className="sel" transition={{ duration: 0.25, ease: OUT_BACK }} />}
            <I size={16} color={m === i ? "var(--text)" : "var(--text-2)"} />
            <span style={{ fontWeight: m === i ? 500 : 400 }}>{l}</span>
            <em>{meta}</em>
          </button>
        ))}
      </div>
    </Card>
  );
}

export function Cost() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.6 });
  const v = useCountUp(0.42, inView, { decimals: 2 });
  return (
    <Card ref={ref} caption={{ title: "Cost", text: "known before it runs" }} artClass="pad24">
      <Label>Cost up front</Label>
      <b className="big-num">${v}</b>
      <p className="feat-desc">estimated before Kiln starts. hard cap per task.</p>
      <div className="cap">
        <span className="track"><motion.i initial={{ width: 0 }} animate={inView ? { width: "21%" } : {}} transition={{ duration: 1.1, ease: [0.19, 1, 0.22, 1] }} /></span>
        <span className="mono">cap $2.00</span>
      </div>
    </Card>
  );
}

const BRANCHES = [["fix-pnl", "running"], ["csv-export", "ready"], ["tests-fees", "queued"]];
const NEXT = { running: "ready", ready: "queued", queued: "running" };
export function Parallel() {
  const [st, setSt] = useState(BRANCHES.map((b) => b[1]));
  useEffect(() => {
    const id = setInterval(() => setSt((s) => s.map((x) => NEXT[x])), 2400);
    return () => clearInterval(id);
  }, []);
  return (
    <Card caption={{ title: "Parallel", text: "one worktree per task" }} artClass="pad24 gap14">
      <Label>Parallel</Label>
      <p className="h-card-sm">3 tasks, 3 worktrees.</p>
      <div className="branches">
        {BRANCHES.map(([b], i) => (
          <div key={b} className="branch">
            <i className={`bdot ${st[i]}`} />
            <span className="mono">{b}</span>
            <AnimatePresence mode="wait">
              <motion.em key={st[i]} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -4 }} transition={{ duration: 0.15 }}>{st[i]}</motion.em>
            </AnimatePresence>
          </div>
        ))}
      </div>
    </Card>
  );
}

const REVIEW_DIFF = [
  ["@", "", "@@ -4,9 +4,10 @@ export function calcFee"], [" ", 4, "export function calcFee(order: Order): number {"],
  [" ", 5, "  const lots = order.qty / LOT_SIZE"], ["-", 6, "  const perLot = roundFee(order.price * FEE_RATE)"],
  ["-", 7, "  return perLot * lots"], ["+", 6, "  const fee = new Decimal(order.price)"], ["+", 7, "    .times(FEE_RATE)"],
  ["+", 8, "    .times(lots)"], ["+", 9, "  return roundFee(fee.toNumber())"], [" ", 10, "}"], [" ", 11, ""],
  [" ", 12, "export function roundFee(value: number) {"], ["-", 13, "  return Math.round(value * 100) / 100"],
  ["+", 13, "  return new Decimal(value).toDP(2).toNumber()"],
];
export function ReviewFirst() {
  const [tab, setTab] = useState(0);
  return (
    <Card w={2} h={2} caption={{ title: "Review", text: "nothing merges without you" }}>
      <div className="feat-head" style={{ left: 44, top: 44, width: 420 }}>
        <Label>Review-first</Label>
        <p className="h-card lg">Every task ends as a diff you can read.</p>
        <p className="feat-desc">Plan up front, changes grouped by file, one click to commit or open a PR.</p>
      </div>
      <div className="review-pane">
        <div className="rp-head">
          {["Changes · 3", "Terminal", "Preview"].map((t, i) => (
            <button key={t} className={`chip ${tab === i ? "sel" : ""}`} onClick={() => { setTab(i); play("tick"); }}>
              {tab === i && <motion.span layoutId="rp-tab" className="chip-bg" transition={{ duration: 0.25, ease: OUT_BACK }} />}
              <span>{t}</span>
            </button>
          ))}
        </div>
        <AnimatePresence mode="wait">
          <motion.div key={tab} initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.15 }} style={{ padding: tab === 0 ? "6px 0" : 16 }}>
            {tab === 0 && REVIEW_DIFF.map((d, i) => <DiffLine key={i} k={d[0]} n={d[1]} code={d[2]} />)}
            {tab === 1 && <TerminalBlock cmd="npm test" />}
            {tab === 2 && (
              <div className="preview">
                <span className="mono">tradr · portfolio</span>
                <b>PnL today</b>
                <strong>+$1,250.37</strong>
                <span className="match"><Check size={14} />matches broker statement to the cent</span>
              </div>
            )}
          </motion.div>
        </AnimatePresence>
      </div>
    </Card>
  );
}

function useTilt(max = 3) {
  const rx = useMotionValue(0);
  const ry = useMotionValue(0);
  const rotate = useSpring(useTransform(rx, [-0.5, 0.5], [-max, max]), { stiffness: 180, damping: 20 });
  const x = useSpring(useTransform(rx, [-0.5, 0.5], [-10, 10]), { stiffness: 180, damping: 20 });
  const y = useSpring(useTransform(ry, [-0.5, 0.5], [-8, 8]), { stiffness: 180, damping: 20 });
  const handlers = {
    onMouseMove: (e) => {
      const r = e.currentTarget.getBoundingClientRect();
      rx.set((e.clientX - r.left) / r.width - 0.5);
      ry.set((e.clientY - r.top) / r.height - 0.5);
    },
    onMouseLeave: () => { rx.set(0); ry.set(0); },
  };
  return { style: { rotate, x, y }, handlers };
}

export function Approvals() {
  const t = useTilt(3);
  return (
    <Card w={2} h={2} caption={{ title: "Approvals", text: "allow once or forever" }} {...t.handlers}>
      <div className="feat-head" style={{ left: 44, top: 44, width: 440 }}>
        <Label dot="var(--warning)">Approvals</Label>
        <p className="h-card lg">Asks before risky commands. Tells you why.</p>
        <p className="feat-desc">Network, installs and writes outside the project always stop for a yes. Allow once or forever.</p>
      </div>
      <motion.div className="window dark crop-approve" style={t.style}>
        <div className="win-head"><Traffic /><span className="win-title">Bump deps, fix what breaks</span></div>
        <Approval
          title="Install 3 packages from npm?"
          cmd="npm install vite@6 vitest@3 @types/node"
          reason="Major bumps for vite and vitest. Needs network access to the npm registry only."
        />
        <Step icon={ShieldCheck} verb="Allowed" target="npm test" meta="always" />
      </motion.div>
    </Card>
  );
}

export function LocalHistory() {
  return (
    <Card caption={{ title: "Local-first", text: "your disk" }} artClass="pad24 gap12">
      <Label>Local-first</Label>
      <p className="h-card-sm">History and code stay on your Mac.</p>
      <div className="path-box"><Folder size={14} color="var(--text-3)" /><span className="mono">~/Library/Kiln/tasks</span></div>
    </Card>
  );
}

const STACK = [["GitHub", siGithub], ["Git", siGit], ["Terminal", "term"], ["Linear", siLinear], ["Figma", siFigma], ["Notion", siNotion], ["Vercel", siVercel]];
export function Stack() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.5 });
  const [tip, setTip] = useState(null);
  return (
    <Card ref={ref} w={2} caption={{ title: "Stack", text: "works with what you use" }}>
      <div className="feat-head" style={{ left: 24, top: 28, width: 300 }}>
        <Label>Your stack</Label>
        <p className="h-card">Git, GitHub, your editor and terminal.</p>
      </div>
      <div className="dock" style={{ position: "absolute", left: 180, top: 150 }}>
        {STACK.map(([n, icon], i) => (
          <motion.div
            key={n} className="dock-tile"
            initial={{ y: 100, opacity: 0 }} animate={inView ? { y: 0, opacity: 1 } : {}}
            transition={{ duration: 0.5, delay: i * 0.06, ease: OUT_BACK }}
            onMouseEnter={() => setTip(i)} onMouseLeave={() => setTip(null)}
          >
            {icon === "term" ? <SquareTerminal size={26} /> : <Brand icon={icon} size={24} />}
            {tip === i && <span className="tooltip">{n}</span>}
          </motion.div>
        ))}
      </div>
    </Card>
  );
}

/* Benchmark chart — illustrative numbers, lines draw in on scroll */
const W = 980, H = 290;
const lx = Math.log(0.04), hx = Math.log(2.5);
const PX = (c) => ((Math.log(c) - lx) / (hx - lx)) * W;
const PY = (v) => H - ((v - 15) / 45) * H;
const SERIES = [
  ["Astra 6", "#C4C4C4", [[0.12, 22], [0.22, 27], [0.4, 31], [0.7, 33], [1.1, 36]]],
  ["Opus 5.5", "#5D5D5D", [[0.35, 31], [0.6, 37], [0.9, 42], [1.3, 46], [1.9, 50]]],
  ["Kiln 1", "var(--ember)", [[0.06, 34], [0.1, 41], [0.16, 47], [0.28, 52], [0.45, 56]]],
];
const EFF = ["low", "med", "high", "xhigh", "max"];

export function Benchmark() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.4 });
  const [hot, setHot] = useState(null);
  return (
    <Card ref={ref} w={4} h={2} arrow={false}>
      <div className="feat-head" style={{ left: 48, top: 44, width: 560 }}>
        <Label dot="var(--ember)">Benchmark · 500 real repo tasks</Label>
        <p className="h-card lg" style={{ fontSize: 30 }}>Better results for less money.</p>
        <p className="feat-desc">Pass rate vs. cost per task at every reasoning effort, from low to max.</p>
      </div>
      <div className="legend">
        {SERIES.slice().reverse().map(([n, c]) => (
          <span key={n} onMouseEnter={() => setHot(n)} onMouseLeave={() => setHot(null)}><i style={{ background: c }} />{n}</span>
        ))}
      </div>
      <div className="chart">
        <svg width="100%" height="100%" viewBox={`-72 -28 ${W + 104} ${H + 80}`} overflow="visible">
          {[20, 30, 40, 50, 60].map((v) => (
            <g key={v}>
              <line x1={0} x2={W} y1={PY(v)} y2={PY(v)} stroke="var(--border)" />
              <text x={-14} y={PY(v) + 4} textAnchor="end" className="ax">{v}</text>
            </g>
          ))}
          <line x1={0} x2={0} y1={0} y2={H} stroke="var(--border-strong)" strokeWidth={1.5} />
          {[0.05, 0.1, 0.25, 0.5, 1, 2].map((c) => (
            <text key={c} x={PX(c)} y={H + 26} textAnchor="middle" className="ax">${c < 1 ? c.toFixed(2) : c}</text>
          ))}
          <text x={-52} y={H / 2} transform={`rotate(-90 -52 ${H / 2})`} textAnchor="middle" className="ax-title">Pass rate (%)</text>
          <text x={W} y={H + 50} textAnchor="end" className="ax-title">Cost per task, USD (log)</text>
          {SERIES.map(([n, c, pts], si) => {
            const dim = hot && hot !== n;
            return (
              <g key={n} style={{ opacity: dim ? 0.2 : 1, transition: "opacity 200ms" }}>
                <motion.path
                  d={"M " + pts.map(([x, y]) => `${PX(x).toFixed(1)} ${PY(y).toFixed(1)}`).join(" L ")}
                  fill="none" stroke={c} strokeWidth={2.5} strokeLinejoin="round"
                  initial={{ pathLength: 0 }} animate={inView ? { pathLength: 1 } : {}}
                  transition={{ duration: 0.9, delay: 0.2 + si * 0.25, ease: [0.165, 0.84, 0.44, 1] }}
                />
                {pts.map(([x, y], i) => (
                  <g key={i}>
                    <motion.circle
                      cx={PX(x)} cy={PY(y)} r={8} fill={c} stroke="#1A1A1A" strokeWidth={1.3}
                      initial={{ scale: 0 }} animate={inView ? { scale: 1 } : {}}
                      style={{ transformOrigin: `${PX(x)}px ${PY(y)}px` }}
                      transition={{ duration: 0.3, delay: 0.2 + si * 0.25 + i * 0.15, ease: OUT_BACK }}
                    />
                    {n === "Kiln 1" && <text x={PX(x)} y={PY(y) - 16} textAnchor="middle" className="eff">{EFF[i]}</text>}
                  </g>
                ))}
              </g>
            );
          })}
        </svg>
        <motion.div
          className="callout" style={{ left: 72 + PX(0.19), top: 28 + PY(44) }}
          initial={{ opacity: 0, y: 8 }} animate={inView ? { opacity: 1, y: 0 } : {}} transition={{ delay: 1.6, duration: 0.4, ease: OUT_BACK }}
        >
          <b>4× cheaper</b>
          <span>than Opus 5.5 at the same pass rate</span>
        </motion.div>
      </div>
      <span className="mono disclaimer">* illustrative data for a design mockup</span>
    </Card>
  );
}

export function CTA({ title = "Try it before everyone else.", text = "Free during beta. First wave opens to 500 developers." }) {
  return (
    <Card w={4} arrow={false} className="cta-card dark">
      <div className="cta-in">
        <div>
          <p className="h-display" style={{ color: "#ECECEC" }}>{title}</p>
          <p style={{ fontSize: 17, color: "#8A8A8A", marginTop: 10 }}>{text}</p>
        </div>
        <Link href="/beta" className="cta-btn" onClick={() => play("nav")}>
          <ArrowRight size={18} />Join the beta
        </Link>
      </div>
    </Card>
  );
}

/* ============ BETA ============ */

function Chips({ options, multi, init }) {
  const [sel, setSel] = useState(init);
  return (
    <div className="chips">
      {options.map((o) => {
        const on = sel.includes(o);
        return (
          <motion.button
            type="button" key={o} className={`pick ${on ? "on" : ""}`} whileTap={{ scale: 0.94 }}
            onClick={() => {
              play("swatch");
              setSel((s) => (multi ? (on ? s.filter((x) => x !== o) : [...s, o]) : [o]));
            }}
          >
            {o}
          </motion.button>
        );
      })}
    </div>
  );
}

export function Signup() {
  const [done, setDone] = useState(false);
  const [email, setEmail] = useState("");
  return (
    <Card w={2} h={2} arrow={false} noSpot>
      <form
        className="manifesto signup"
        style={{ gap: 18, padding: 48 }}
        onSubmit={(e) => { e.preventDefault(); setDone(true); play("success"); }}
      >
        <h1 className="h-display"><span className="muted">Join the </span>Kiln<span className="muted"> beta.</span></h1>
        <p style={{ fontSize: 18, color: "var(--text-2)" }}>free while in beta. seats open in waves.</p>
        <div className="rule" />
        <label className="field">
          <span>Work email</span>
          <span className="input-wrap">
            <Mail size={16} color="var(--text-3)" />
            <input type="email" required placeholder="you@company.com" value={email} onChange={(e) => setEmail(e.target.value)} />
          </span>
        </label>
        <div className="field"><span>What do you build?</span><Chips multi options={["Web", "iOS / macOS", "Backend", "Data / ML"]} init={["Web", "iOS / macOS"]} /></div>
        <div className="field"><span>What do you use today?</span><Chips options={["Codex", "Claude Code", "Cursor", "Nothing yet"]} init={["Claude Code"]} /></div>
        <div className="field" style={{ paddingTop: 6 }}>
          <motion.button type="submit" className={`submit ${done ? "done" : ""}`} whileTap={{ scale: 0.97 }} layout>
            <AnimatePresence mode="wait">
              <motion.span key={String(done)} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.18 }}>
                {done ? <><Check size={18} />You&apos;re on the list</> : <><ArrowRight size={18} />Request access</>}
              </motion.span>
            </AnimatePresence>
          </motion.button>
          <div className="footnote" style={{ fontSize: 13 }}><span>*</span><span>one email when your seat opens. no newsletter.</span></div>
        </div>
      </form>
    </Card>
  );
}

export function WhatYouGet() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.5 });
  const items = ["Kiln credits on us for the whole beta", "Any model with your own key", "A direct line to the builder", "Your feedback shipped in the weekly changelog"];
  return (
    <Card ref={ref} w={2} arrow={false} artClass="pad28 gap14">
      <Label dot="var(--success)">What you get</Label>
      <div className="get-list">
        {items.map((t, i) => (
          <motion.div key={t} initial={{ opacity: 0, x: -10 }} animate={inView ? { opacity: 1, x: 0 } : {}} transition={{ delay: i * 0.08, duration: 0.35, ease: OUT_BACK }}>
            <PlanItem size={16}><span style={{ color: "var(--text)" }}>{t}</span></PlanItem>
          </motion.div>
        ))}
      </div>
    </Card>
  );
}

export function FirstWave() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.6 });
  const v = useCountUp(500, inView, { duration: 1.4 });
  return (
    <Card ref={ref} arrow={false} artClass="pad24 gap6">
      <Label dot="var(--ember)">First wave</Label>
      <b className="big-num" style={{ fontSize: 72, letterSpacing: -3 }}>{v}</b>
      <p className="feat-desc">seats. invites go out every monday.</p>
    </Card>
  );
}

const FAQ = [
  ["Is it free?", "Yes, for the whole beta. Pricing comes later and beta users keep a discount."],
  ["Which models?", "Kiln 1 by default, or Anthropic, OpenAI, Google and local Ollama with your key."],
  ["What Mac do I need?", "Apple silicon and macOS 14 Sonoma or newer."],
  ["Is my code sent anywhere?", "Only to the model you pick. History and diffs stay on your Mac."],
];
export function Faq() {
  return (
    <Card w={4} arrow={false} artClass="faq-art">
      <Label dot={false}>FAQ</Label>
      <div className="faq">
        {FAQ.map(([q, a]) => (
          <div key={q} className="faq-item"><b>{q}</b><p>{a}</p></div>
        ))}
      </div>
    </Card>
  );
}

/* ============ CHANGELOG ============ */

export function Subscribe() {
  const [done, setDone] = useState(false);
  return (
    <form className="subscribe" onSubmit={(e) => { e.preventDefault(); setDone(true); play("success"); }}>
      <span className="input-wrap pill">
        <Mail size={16} color="var(--text-3)" />
        <input type="email" required placeholder="you@company.com" />
      </span>
      <motion.button type="submit" className="btn emph pill sub-btn" whileTap={{ scale: 0.96 }}>
        {done ? <><Check size={16} />Subscribed</> : "Get it weekly"}
      </motion.button>
    </form>
  );
}

const METRICS = [["Waitlist", 312, 0, "+48", true], ["Tasks run", 1240, 0, "+31%", true], ["Tests green", 94, 0, "+6 pt", true], ["Crash-free", 97.1, 1, "−0.8 pt", false]];
function Metric({ label, to, dec, delta, good, active }) {
  const v = useCountUp(to, active, { decimals: dec });
  const shown = to >= 1000 ? Number(v).toLocaleString("en-US") : v;
  return (
    <div className="metric">
      <span>{label}</span>
      <b>{shown}{label === "Tests green" || label === "Crash-free" ? "%" : ""}</b>
      <em className="mono" style={{ color: good ? "var(--success)" : "var(--danger)" }}>{delta}</em>
    </div>
  );
}
export function ThisWeek() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.5 });
  return (
    <Card ref={ref} w={2} arrow={false} artClass="pad-week">
      <Label dot="var(--ember)">Week 6 · Oct 12</Label>
      <div className="metrics">
        {METRICS.map(([l, t, d, delta, g]) => <Metric key={l} label={l} to={t} dec={d} delta={delta} good={g} active={inView} />)}
      </div>
      <p style={{ fontSize: 14, color: "var(--text-2)" }}>crash-free dropped after the worktree release. fix is in v0.4.</p>
    </Card>
  );
}

export function NextUp() {
  return (
    <Card caption={{ title: "Next", text: "you vote" }} artClass="pad24 gap12">
      <Label>Next up</Label>
      <div className="next-box">
        <PlanItem state="active" size={14}>Xcode project support</PlanItem>
        <PlanItem state="todo" size={14}><span style={{ color: "var(--text-2)" }}>Ollama models offline</span></PlanItem>
        <PlanItem state="todo" size={14}><span style={{ color: "var(--text-2)" }}>Share a task as a link</span></PlanItem>
      </div>
    </Card>
  );
}

const TAGS = { NEW: "success", IMPROVED: "", FIXED: "danger" };
function Changes({ items, size = 15 }) {
  return (
    <div className="rel-changes">
      {items.map(([k, s], i) => (
        <div key={i} className="rel-change">
          <span className="tag-wrap"><Badge tone={TAGS[k]}>{k}</Badge></span>
          <p style={{ fontSize: size }}>{s}</p>
        </div>
      ))}
    </div>
  );
}

export function LatestRelease() {
  const t = useTilt(2.5);
  return (
    <Card w={4} h={2} arrow={false} {...t.handlers}>
      <div className="release-col">
        <div className="rel-meta"><Badge tone="inverse">v0.4</Badge><Label dot="var(--ember)">Latest · Oct 12, 2026</Label></div>
        <p className="rel-title">Approvals that explain themselves.</p>
        <p className="feat-desc">Beta testers kept hitting “Deny” because they didn&apos;t know what a command would do. Now every approval says why it&apos;s needed and what it touches.</p>
        <Changes items={[
          ["NEW", "Every approval shows a reason and the exact scope: network, files, or both."],
          ["NEW", "“Always allow” adds the command to your allow list, editable in Settings."],
          ["IMPROVED", "Approvals wait in the menu bar, so you can say yes without opening the window."],
          ["FIXED", "Crash when two worktrees finished at the same second."],
        ]} />
      </div>
      <motion.div className="window dark crop-release" style={{ x: t.style.x, y: t.style.y }}>
        <div className="win-head"><Traffic /><span className="win-title">Починить расчёт PnL</span></div>
        <Approval />
        <div className="allow-list">
          {[["npm test", "Added by you · ran 41 times"], ["npm install", "Added just now · npm registry only"]].map(([c, d], i) => (
            <div key={c} className="allow-row" style={i ? { borderBottom: 0 } : undefined}>
              <span><b className="mono">{c}</b><em>{d}</em></span>
              <X size={14} color="var(--text-3)" />
            </div>
          ))}
        </div>
      </motion.div>
    </Card>
  );
}

export function Release({ v, date, title, items }) {
  return (
    <Card w={2} arrow={false} artClass="pad28 gap12">
      <div className="rel-meta"><Badge>{v}</Badge><Label dot={false}>{date}</Label></div>
      <p className="h-card">{title}</p>
      <Changes items={items} size={14} />
    </Card>
  );
}

export function FirstCommit() {
  return (
    <Card caption={{ title: "Origin", text: "where it started" }} artClass="pad24 gap10">
      <Label dot={false}>First commit</Label>
      <div className="commit-box">
        <span className="mono" style={{ color: "#E36A62", fontSize: 12 }}><GitCommitHorizontal size={12} style={{ verticalAlign: -2, marginRight: 4 }} />a1f9c2e</span>
        <span className="mono" style={{ color: "#ECECEC", fontSize: 13 }}>init: kiln can read a repo</span>
        <span className="mono" style={{ color: "#8A8A8A", fontSize: 11 }}>Aug 31, 2026 · 02:14</span>
      </div>
    </Card>
  );
}

export function Follow() {
  return (
    <Card arrow={false} artClass="pad24 gap12">
      <Label dot="var(--warning)">Follow</Label>
      <p className="h-card-sm">RSS, email or the beta Telegram.</p>
      <div style={{ display: "flex", gap: 8 }}>
        <Btn icon={Rss} pill style={{ height: 36, background: "var(--surface)", borderColor: "var(--border-strong)" }} onClick={() => play("tick")}>RSS</Btn>
        <Btn icon={Send} pill style={{ height: 36, background: "var(--surface)", borderColor: "var(--border-strong)" }} onClick={() => play("tick")}>Telegram</Btn>
      </div>
    </Card>
  );
}

export function WeekCounter() {
  return (
    <Card arrow={false}>
      <div className="local-in">
        <b style={{ fontSize: 96, letterSpacing: -4 }}>W6</b>
        <span style={{ fontSize: 18 }}>weeks since first commit</span>
      </div>
    </Card>
  );
}


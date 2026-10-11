"use client";

import { useEffect, useRef, useState } from "react";
import {
  motion, AnimatePresence, useInView, useScroll, useTransform, useMotionValue, useSpring, useReducedMotion,
} from "motion/react";
import {
  Wrench, FileUp, FlaskConical, BookOpen, Flame, Command, CornerDownLeft, GitPullRequest, Package, Bug,
  ArrowDown, ArrowUpRight, GitMerge, Download, FileText, Search, Terminal, Pencil, CircleCheck,
  GitCommitHorizontal, Trash2, Loader, SquareTerminal,
} from "lucide-react";
import { siGithub, siGit, siLinear, siFigma, siNotion, siVercel } from "simple-icons";
import Card from "./Card";
import {
  Label, Badge, Traffic, Btn, Step, Approval, Composer, DiffLine, PlanItem, Changes, TerminalBlock,
  Brand, GithubMark, KilnArch, AppIcon,
} from "./ui";
import { KilnBuddy, Jump, useHover } from "./buddy";
import { play } from "@/lib/sound";

const OUT_BACK = [0.175, 0.885, 0.32, 1.275];

/* 1 — Manifesto: “Kiln” stays, the rest of the headline flips top → bottom every 5s */
const HEADLINES = [
  [" works while you ", "ship"],
  [" reads before it ", "writes"],
  [" asks before it ", "runs"],
  [" tests before you ", "merge"],
  [" plans, then it ", "edits"],
];

function RotatingHeadline() {
  const [i, setI] = useState(0);
  const reduce = useReducedMotion();
  useEffect(() => {
    const id = setInterval(() => {
      if (!document.hidden) setI((v) => (v + 1) % HEADLINES.length);
    }, 5000);
    return () => clearInterval(id);
  }, []);
  const [mid, word] = HEADLINES[i];
  return (
    <h1 className="h-display headline">
      Kiln
      <span className="flip">
        <AnimatePresence initial={false}>
          <motion.span
            key={i}
            className="flip-item"
            initial={{ y: reduce ? 0 : "-110%", opacity: 0, filter: reduce ? "none" : "blur(4px)" }}
            animate={{ y: 0, opacity: 1, filter: "blur(0px)" }}
            exit={{ y: reduce ? 0 : "110%", opacity: 0, filter: reduce ? "none" : "blur(4px)" }}
            transition={{ duration: 0.55, ease: [0.22, 1, 0.36, 1] }}
          >
            <span className="muted">{mid}</span><span className="u">{word}</span>.
          </motion.span>
        </AnimatePresence>
      </span>
    </h1>
  );
}

export function Manifesto() {
  return (
    <Card w={2} h={2} arrow={false} noSpot>
      <div className="manifesto">
        <RotatingHeadline />
        <div className="rule" />
        <div className="lines">
          <p>i read your repo before i touch it.</p>
          <p>i write a plan, then i follow it.</p>
          <p>i run the tests. i don&apos;t guess.</p>
          <p>i ask before anything leaves the sandbox.</p>
          <p>i show you every line i changed.</p>
          <p>you review. you merge. you stay in charge.</p>
          <p>fewer tabs. more shipped*.</p>
        </div>
        <div className="footnote"><span>*</span><span>Less typing, better code.</span></div>
      </div>
    </Card>
  );
}

/* 2 — Tasks widget: dock rises in on scroll, tabs swap with a springy ring */
const TASKS = [
  [Wrench, "Fix PnL rounding", "tradr"],
  [FileUp, "CSV export", "tradr"],
  [FlaskConical, "Tests for fees.ts", "tradr"],
  [BookOpen, "Explain auth flow", "kodshag"],
];
const DOCK = [
  ["Kiln", null], ["GitHub", siGithub], ["Git", siGit], ["Terminal", "term"],
  ["Linear", siLinear], ["Figma", siFigma], ["Notion", siNotion], ["Vercel", siVercel],
];

export function Tasks() {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.5 });
  const [sel, setSel] = useState(0);
  const [tip, setTip] = useState(null);
  return (
    <Card ref={ref} w={2} caption={{ title: "Tasks", text: "every job in its own tab" }} artClass="tasks-art">
      <Label dot="var(--ember)">Kiln · Tasks</Label>
      <div className="task-tabs">
        {TASKS.map(([I, t, p], i) => (
          <button key={t} className="task-tab" onClick={() => { setSel(i); play("tick"); }}>
            {sel === i && (
              <motion.span layoutId="task-ring" className="ring" transition={{ duration: 0.35, ease: OUT_BACK }} />
            )}
            <span className="head"><I size={15} />{t}</span>
            <span className="proj">{p}</span>
          </button>
        ))}
      </div>
      <div className="dock">
        {DOCK.map(([name, icon], i) => (
          <motion.div
            key={name}
            className={`dock-tile ${icon === null ? "kiln" : ""}`}
            initial={{ y: 100, opacity: 0 }}
            animate={inView ? { y: 0, opacity: 1 } : {}}
            transition={{ duration: 0.5, delay: i * 0.06, ease: OUT_BACK }}
            onMouseEnter={() => setTip(i)}
            onMouseLeave={() => setTip(null)}
          >
            {icon === null ? <KilnBuddy active={tip === i} size={24} weight={4} /> : icon === "term" ? <SquareTerminal size={26} /> : <Brand icon={icon} size={24} />}
            <AnimatePresence>
              {tip === i && (
                <motion.span className="tooltip" initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} transition={{ duration: 0.1 }}>
                  {name}
                </motion.span>
              )}
            </AnimatePresence>
          </motion.div>
        ))}
      </div>
    </Card>
  );
}

/* 3 — Agent window crop */
export function AgentCrop() {
  return (
    <Card h={2} caption={{ title: "Agent", text: "plans, edits, asks" }}>
      <div className="window dark crop-agent">
        <div className="win-head"><Traffic /><span style={{ width: 12 }} /><span className="win-title">Починить расчёт PnL</span></div>
        <div>
          <Step icon={FileText} verb="Read" target="src/lib/pnl.ts" meta="212 lines" />
          <Step icon={Search} verb="Searched" target="roundFee" meta="4 matches" />
          <Step icon={Terminal} verb="Ran" target="npm test -- pnl" meta="2.9s" />
        </div>
        <p className="agent-msg">Комиссия округляется до умножения на лоты. Переношу округление в конец.</p>
        <Approval />
        <Composer ctx={[]} placeholder="Reply to steer Kiln" />
      </div>
    </Card>
  );
}

/* 4 — Builder: a dark circle floods the card from the GitHub tile */
export function Builder() {
  return (
    <Card arrow={false} className="builder" onMouseEnter={() => play("pop")}>
      <span className="flood" />
      <div className="builder-in">
        <div className="who">
          <span className="avatar">Y</span>
          <span className="names"><b>Yaroslav</b><span>@hqzdev</span></span>
          <span className="gh"><GithubMark size={24} color="#fff" /></span>
        </div>
        <p className="bio">building kiln in public. one agent, one Mac, no cloud VMs.</p>
        <a className="follow" href="https://github.com/Hqzdev" target="_blank" rel="noreferrer">
          <ArrowUpRight size={16} />Follow the build
        </a>
      </div>
    </Card>
  );
}

/* 5 — Prompt stack: click shuffles the composers */
const PROMPTS = [
  "Fix the flaky checkout test",
  "Explain how auth works here",
  "Add CSV export to trades",
  "Write tests for fees.ts",
  "Bump deps, fix what breaks",
];
export function PromptStack() {
  const [n, setN] = useState(0);
  const [order, setOrder] = useState(PROMPTS);
  const shuffle = () => {
    setN((v) => v + 1);
    play("shuffle");
    setTimeout(() => setOrder((o) => [...o.slice(1), o[0]]), 360);
  };
  return (
    <Card w={2} caption={{ title: "Prompts", text: "say it like you'd say it to a teammate" }} className="prompt-card" onClick={shuffle}>
      {order.map((p, i) => (
        <motion.div
          key={`${i}-${n}`}
          className="dark stack-item"
          style={{ left: 70 + i * 92, top: 96 - i * 6 }}
          initial={false}
          animate={n > 0 ? { x: [0, -31, 0], rotate: [8, -2, 8] } : undefined}
          transition={{ duration: 0.14, delay: i * 0.07, ease: [0.455, 0.03, 0.515, 0.955] }}
        >
          <Composer
            text={p}
            textColor="var(--text)"
            ctx={i === 4 ? ["project", "branch"] : []}
            tools={["approval"]}
          />
        </motion.div>
      ))}
    </Card>
  );
}

/* 6 — Beta pass: tilts toward the cursor like a card held in hand */
export function BetaPass() {
  const rx = useMotionValue(0);
  const ry = useMotionValue(0);
  const rot = useSpring(useTransform(rx, [-0.5, 0.5], [-4, 4]), { stiffness: 200, damping: 20 });
  const x = useSpring(useTransform(rx, [-0.5, 0.5], [-12, 12]), { stiffness: 200, damping: 20 });
  const y = useSpring(useTransform(ry, [-0.5, 0.5], [-10, 10]), { stiffness: 200, damping: 20 });
  return (
    <Card
      href="/beta"
      caption={{ title: "Beta", text: "free while in beta" }}
      onMouseMove={(e) => {
        const r = e.currentTarget.getBoundingClientRect();
        rx.set((e.clientX - r.left) / r.width - 0.5);
        ry.set((e.clientY - r.top) / r.height - 0.5);
      }}
      onMouseLeave={() => { rx.set(0); ry.set(0); }}
    >
      <motion.div className="beta-pass" style={{ rotate: rot, x, y }}>
        <b>Beta access</b>
        <div className="row">
          <Flame size={26} color="#FFFFFFCC" />
          <div className="price"><strong>$0</strong><span>PER MONTH</span></div>
        </div>
      </motion.div>
    </Card>
  );
}

/* 7 — Agent loop: tabs swap content, the selection box springs between rows */
const LOOP = {
  Plan: {
    key: "P", hint: "Kiln is planning", sub: "tradr · 2 of 4 steps · 1m 12s", related: "Plan",
    rows: [
      ["done", "Find where PnL and fees are computed"],
      ["done", "Reproduce the drift with a failing test"],
      ["active", "Move rounding to the end, use decimal.js"],
      ["todo", "Run the full suite and the linter"],
    ],
    extra: <Changes />,
  },
  Run: {
    key: "R", hint: "Kiln is running", sub: "tradr · step 3 of 4 · 2m 05s", related: "Steps",
    rows: [
      [FileText, "Read src/lib/pnl.ts", "212 lines"],
      [Search, "Searched roundFee", "4 matches"],
      [Pencil, "Edited src/lib/fees.ts", "+9 −8"],
      [Terminal, "Ran npm test -- pnl", "2.9s"],
    ],
    extra: <TerminalBlock cmd="npm test -- pnl" />,
  },
  Review: {
    key: "V", hint: "Ready for review", sub: "tradr · 3 files · +36 −14", related: "Changes",
    rows: [
      [FileText, "src/lib/pnl.ts", "+18 −6"],
      [FileText, "src/lib/fees.ts", "+9 −8"],
      [FileText, "src/lib/pnl.test.ts", "+9"],
    ],
    extra: (
      <div className="mini-diff">
        <DiffLine k="-" n={6} code="  const perLot = roundFee(order.price * FEE)" />
        <DiffLine k="+" n={6} code="  const fee = new Decimal(order.price)" />
        <DiffLine k="+" n={7} code="    .times(FEE).times(lots)" />
        <DiffLine k="+" n={8} code="  return roundFee(fee.toNumber())" />
      </div>
    ),
  },
  Ship: {
    key: "S", hint: "Shipped", sub: "tradr · merged · 3m 40s", related: "Checks",
    rows: [
      [CircleCheck, "CI passed on kiln/fix-pnl-rounding", "20/20"],
      [GitPullRequest, "PR #43 opened and approved", "you"],
      [GitMerge, "Merged into main", "now"],
      [Trash2, "Worktree cleaned up", "auto"],
    ],
    extra: <TerminalBlock cmd="gh pr merge 43 --squash" lines={["✓ Squashed and merged pull request #43", "✓ Deleted branch kiln/fix-pnl-rounding"]} />,
  },
};

export function AgentLoop() {
  const [tab, setTab] = useState("Plan");
  const [hover, setHover] = useState(null);
  const [row, setRow] = useState({ Plan: 2, Run: 3, Review: 1, Ship: 2 });
  const d = LOOP[tab];
  return (
    <Card w={2} h={2} caption={{ title: "Loop", text: "plan, run, review, ship" }} artClass="loop-art">
      <div className="loop-tabs">
        {Object.keys(LOOP).map((t) => (
          <button
            key={t}
            className={`loop-tab ${tab === t ? "on" : ""}`}
            onMouseEnter={() => setHover(t)}
            onMouseLeave={() => setHover(null)}
            onClick={() => { setTab(t); play("tick"); }}
          >
            <i />{t}
          </button>
        ))}
        <span style={{ flex: 1 }} />
        <motion.span key={hover || tab} className="keyhint" initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.1 }}>
          {LOOP[hover || tab].key}
        </motion.span>
      </div>
      <div className="loop-panel">
        <AnimatePresence mode="wait">
          <motion.div
            key={tab}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -6 }}
            transition={{ duration: 0.2 }}
            className="loop-content"
          >
            <div className="hints"><span>{d.hint}</span><Badge>kiln/fix-pnl-rounding</Badge></div>
            <div className="task-box">
              <span className="tile"><Wrench size={20} color="#EDEDED" /></span>
              <span className="txt"><b>Fix PnL rounding</b><span className="mono">{d.sub}</span></span>
            </div>
            <div className="related"><span>{d.related}</span><i /></div>
            <div className="loop-rows">
              {d.rows.map((r, i) => (
                <button key={i} className="loop-row" onClick={() => { setRow((s) => ({ ...s, [tab]: i })); play("tick"); }}>
                  {row[tab] === i && (
                    <motion.span layoutId={`loop-sel-${tab}`} className="sel" transition={{ duration: 0.25, ease: OUT_BACK }} />
                  )}
                  {typeof r[0] === "string" ? (
                    <PlanItem state={r[0]} size={15}>{r[1]}</PlanItem>
                  ) : (
                    <span className="loop-step">
                      {(() => { const I = r[0]; return <I size={15} />; })()}
                      <span>{r[1]}</span>
                      <em>{r[2]}</em>
                    </span>
                  )}
                </button>
              ))}
            </div>
            {d.extra}
          </motion.div>
        </AnimatePresence>
      </div>
    </Card>
  );
}

/* 8 — Command palette: rises on hover, the ember row jiggles, click runs it */
export function CommandCard() {
  const ref = useRef(null);
  const inView = useInView(ref, { amount: 0.5 });
  const [run, setRun] = useState(false);
  useEffect(() => {
    if (!run) return;
    const t = setTimeout(() => setRun(false), 3200);
    return () => clearTimeout(t);
  }, [run]);
  return (
    <Card ref={ref} w={2} h={2} caption={{ title: "Command", text: "⌘K from anywhere" }} className="cmd-card">
      <div className="palette">
        <div className="pal-input">
          <Command size={22} color="var(--ember)" />
          <span className="field">Type a task to get started…</span>
        </div>
        <button
          className={`pal-hl ${inView && !run ? "jiggle" : ""}`}
          onClick={(e) => { e.stopPropagation(); setRun((v) => !v); play("command"); }}
        >
          <span>Run the tests and fix what fails</span>
          <CornerDownLeft size={20} />
        </button>
        <div className="pal-list">
          {[[BookOpen, "Explain this repo", "⌘E"], [GitPullRequest, "Review open PR #42", "⌘R"], [FlaskConical, "Write tests for fees.ts"], [Package, "Bump deps and fix what breaks"], [Bug, "Find why PnL drifts"]].map(([I, l, m]) => (
            <div key={l} className="sidebar-item pal-item"><I size={16} color="var(--text-2)" /><span>{l}</span>{m && <span className="meta">{m}</span>}</div>
          ))}
        </div>
        <AnimatePresence>
          {run && (
            <motion.div
              className="pal-sheet dark"
              initial={{ y: 200, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: 200, opacity: 0 }}
              transition={{ duration: 0.5, ease: OUT_BACK }}
            >
              <div className="sheet-head"><Loader size={14} className="spin" />Running · Run the tests and fix what fails</div>
              <Step icon={Terminal} verb="Ran" target="npm test" meta="1 failed" />
              <Step icon={Search} verb="Read" target="checkout.test.ts" meta="88 lines" />
              <Step icon={Pencil} verb="Editing" target="src/cart/total.ts" meta="…" />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </Card>
  );
}

/* 9 — ⌘K keycaps: click or press the real ⌘K */
export function Keycaps() {
  const [pressed, setPressed] = useState(false);
  const [open, setOpen] = useState(false);
  const [hl, setHl] = useState(0);
  const trigger = () => {
    play("key");
    setPressed(true);
    setTimeout(() => setPressed(false), 120);
    setOpen(true);
    setHl(0);
  };
  useEffect(() => {
    const onKey = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") { e.preventDefault(); trigger(); }
    };
    addEventListener("keydown", onKey);
    return () => removeEventListener("keydown", onKey);
  }, []);
  useEffect(() => {
    if (!open) return;
    const a = setTimeout(() => setHl(1), 700);
    const b = setTimeout(() => setHl(2), 1200);
    const c = setTimeout(() => setOpen(false), 2400);
    return () => { clearTimeout(a); clearTimeout(b); clearTimeout(c); };
  }, [open]);
  return (
    <Card caption={{ title: "⌘K", text: "try it" }} className="keys-card" onClick={trigger}>
      <div className="keys-in">
        <span className="label" style={{ fontSize: 13, fontWeight: 600, color: "var(--text-2)" }}>Press here</span>
        <ArrowDown size={20} className="keys-arrow" color="var(--text-2)" />
        <div className="keys">
          {["⌘", "K"].map((k) => (
            <motion.span key={k} className="keycap" animate={pressed ? { scale: 0.85, opacity: 0.65 } : { scale: 1, opacity: 1 }} transition={{ duration: 0.1 }}>
              {k}
            </motion.span>
          ))}
        </div>
      </div>
      <AnimatePresence>
        {open && (
          <motion.div className="mini-pal" initial={{ opacity: 0, scale: 0.92, y: 10 }} animate={{ opacity: 1, scale: 1, y: 0 }} exit={{ opacity: 0, scale: 0.95 }} transition={{ duration: 0.25, ease: OUT_BACK }}>
            <div className="mp-in"><Command size={14} color="var(--ember)" /><span>fix</span><i /></div>
            {["Fix PnL rounding", "Fix flaky checkout test", "Fix lint errors"].map((t, i) => (
              <motion.div
                key={t}
                className={`mp-row ${hl === i ? "on" : ""}`}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.25, delay: 0.1 + i * 0.1 }}
              >
                <Wrench size={13} />{t}
              </motion.div>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </Card>
  );
}

/* 10 — Diff crop: scroll-linked, code drifts up and added lines light up */
const DIFF = [
  ["@", "", "@@ -1,13 +1,14 @@ fees.ts"], [" ", 1, "import { LOT_SIZE, FEE_RATE } from './config'"], ["+", 2, "import Decimal from 'decimal.js'"],
  [" ", 3, ""], [" ", 4, "export function calcFee(order) {"], [" ", 5, "  const lots = order.qty / LOT_SIZE"],
  ["-", 6, "  const perLot = roundFee(order.price * FEE)"], ["-", 7, "  return perLot * lots"],
  ["+", 6, "  const fee = new Decimal(order.price)"], ["+", 7, "    .times(FEE).times(lots)"], ["+", 8, "  return roundFee(fee.toNumber())"],
  [" ", 9, "}"], [" ", 10, ""], ["@", "", "@@ -31,8 +32,8 @@ roundFee"], [" ", 32, "export function roundFee(v) {"],
  ["-", 33, "  return Math.round(v * 100) / 100"], ["+", 33, "  return new Decimal(v).toDP(2).toNumber()"], [" ", 34, "}"],
  [" ", 35, ""], [" ", 36, "export const ZERO_FEE = 0"], [" ", 37, ""], ["@", "", "@@ -52,6 +53,9 @@ feeForOrders"],
  [" ", 53, "export function feeForOrders(orders) {"], ["+", 54, "  if (!orders.length) return 0"], ["+", 55, "  return orders"],
  ["+", 56, "    .map(calcFee)"], ["+", 57, "    .reduce((a, b) => a + b, 0)"], [" ", 58, "}"],
];
const ADDED = DIFF.map((d, i) => (d[0] === "+" ? i : -1)).filter((i) => i >= 0);

function LitLine({ p, d, order }) {
  const start = 0.25 + (order / ADDED.length) * 0.4;
  const o = useTransform(p, [start, start + 0.06], [0.4, 1]);
  return <motion.div style={{ opacity: o }}><DiffLine k={d[0]} n={d[1]} code={d[2]} /></motion.div>;
}

export function DiffCrop() {
  const ref = useRef(null);
  const { scrollYProgress: p } = useScroll({ target: ref, offset: ["start end", "end start"] });
  const y = useTransform(p, [0.2, 0.75], [0, -120]);
  return (
    <Card ref={ref} h={2} caption={{ title: "Review", text: "line by line" }}>
      <div className="window dark crop-diff">
        <div className="win-head" style={{ padding: "0 18px" }}>
          <Traffic />
          <span className="mono" style={{ fontSize: 12 }}>src/lib/fees.ts</span>
          <span className="mono" style={{ fontSize: 12, color: "var(--success)" }}>+13</span>
          <span className="mono" style={{ fontSize: 12, color: "var(--danger)" }}>−3</span>
        </div>
        <div className="code-viewport">
          <motion.div style={{ y }} className="code">
            {DIFF.map((d, i) =>
              d[0] === "+" ? <LitLine key={i} p={p} d={d} order={ADDED.indexOf(i)} /> : <DiffLine key={i} k={d[0]} n={d[1]} code={d[2]} />
            )}
          </motion.div>
        </div>
        <div className="commit-bar">
          <Btn icon={GitCommitHorizontal} emph>Commit &amp; push</Btn>
        </div>
      </div>
    </Card>
  );
}

/* 11 — “Local”: rapid-fire words on hover, then a slam back */
const WORDS = [["Local", "runs on your Mac"], ["Private", "your code stays yours"], ["Offline", "works on a plane"], ["Yours", "any model, no lock-in"]];
export function LocalType() {
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
      if (k >= 6) {
        clearInterval(id);
        setI(0);
        setSlam((s) => s + 1);
        setTimeout(() => (busy.current = false), 300);
      } else setI(k % WORDS.length);
    }, 80);
  };
  return (
    <Card caption={{ title: "Local", text: "stays on your Mac" }} className="local-card" onMouseEnter={fire}>
      <div className="local-in">
        <motion.b key={slam} initial={slam ? { scale: 2.2 } : false} animate={{ scale: 1 }} transition={{ duration: 0.2, ease: [0.55, 0.055, 0.675, 0.19] }}>
          {WORDS[i][0]}
        </motion.b>
        <span>{WORDS[i][1]}</span>
      </div>
    </Card>
  );
}

/* 12 — Kiln mark: the kiln heats up on hover */
export function KilnMark() {
  return (
    <Card caption={{ title: "Kiln", text: "task in, code out" }} className="mark-card" onMouseEnter={() => play("open")}>
      <span className="arch" />
      <span className="ember" />
    </Card>
  );
}

/* 13 — Agent log: click a day, its runs pop in */
const DAYS = [["Sun", 11, 0, 0], ["Mon", 12, 3, 2], ["Tue", 13, 5, 4], ["Wed", 14, 2, 1], ["Thu", 15, 4, 3], ["Fri", 16, 0, 0], ["Sat", 17, 1, 0]];
const FULL = { Sun: "Sunday", Mon: "Monday", Tue: "Tuesday", Wed: "Wednesday", Thu: "Thursday", Fri: "Friday", Sat: "Saturday" };
export function AgentLog() {
  const [d, setD] = useState(1);
  const [name, num, runs, merged] = DAYS[d];
  return (
    <Card caption={{ title: "Log", text: "day by day" }} artClass="log-art">
      <div className="log-panel">
        <span className="mono log-label">AGENT LOG</span>
        <b className="log-date">{FULL[name]}, Oct {num}</b>
        <div className="days">
          {DAYS.map(([n, nn, r], i) => (
            <button key={n} className={`day ${i === d ? "on" : ""}`} onClick={(e) => { e.stopPropagation(); setD(i); play("tick"); }}>
              {i === d && <motion.span layoutId="day-pill" className="day-pill" transition={{ duration: 0.25, ease: OUT_BACK }} />}
              <span className="dn">{n}</span>
              <span className="dd">{nn}</span>
              <span className="marks">
                {Array.from({ length: Math.min(r, 3) }).map((_, k) => (
                  <motion.i key={`${i}-${k}-${d}`} initial={i === d ? { scale: 0 } : false} animate={{ scale: 1 }} transition={{ duration: 0.2, delay: k * 0.05, ease: OUT_BACK }} />
                ))}
              </span>
            </button>
          ))}
        </div>
      </div>
      <div className="log-panel">
        <span className="mono log-label">RUNS ON {name.toUpperCase()}</span>
        <span className="log-row"><GitMerge size={16} /><motion.span key={d} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }}>{runs} tasks · {merged} merged</motion.span></span>
      </div>
    </Card>
  );
}

/* 14 — Sandbox: options lift on hover, highlight slides to the chosen one */
const MODES = [["Read-only", "Reads files. Every write asks first."], ["Workspace", "Edits inside the project. Network asks."], ["Full", "Edits anywhere. Use with care."]];
export function Sandbox() {
  const [m, setM] = useState(1);
  return (
    <Card caption={{ title: "Sandbox", text: "you set the limits" }} artClass="sandbox-art">
      <Label dot="var(--success)">Sandbox</Label>
      <p className="h-card-sm">Asks before anything leaves it.</p>
      <div className="seg">
        {MODES.map(([l], i) => (
          <button key={l} className={`seg-opt ${m === i ? "on" : ""}`} onClick={(e) => { e.stopPropagation(); setM(i); play("swatch"); }}>
            {m === i && <motion.span layoutId="seg-hl" className="seg-hl" transition={{ duration: 0.5, ease: OUT_BACK }} />}
            <span>{l}</span>
          </button>
        ))}
      </div>
      <AnimatePresence mode="wait">
        <motion.p key={m} className="seg-desc" style={m === 2 ? { color: "var(--warning)" } : undefined} initial={{ opacity: 0, y: 4 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} transition={{ duration: 0.15 }}>
          {MODES[m][1]}
        </motion.p>
      </AnimatePresence>
    </Card>
  );
}

/* 15 — Download: the icon flips, a tooltip pops above the button */
export function DownloadCard() {
  const [hover, bind] = useHover();
  return (
    <Card arrow={false} className="dl-card dark" onMouseEnter={() => { bind.onMouseEnter(); play("nock"); }} onMouseLeave={bind.onMouseLeave}>
      <div className="dl-in">
        <Jump active={hover} height={88} className="dl-icon"><AppIcon size={88} happy={hover} /></Jump>
        <b>Kiln for macOS</b>
        <span className="dl-btn-wrap">
          <span className="dl-tip mono">Kiln-1.4.dmg · 48 MB</span>
          <a className="dl-btn" href="/beta"><Download size={16} />Download beta</a>
        </span>
        <span className="mono dl-meta">v1.4 · Apple silicon · macOS 14+</span>
      </div>
    </Card>
  );
}


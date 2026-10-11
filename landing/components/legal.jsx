"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { motion, useInView } from "motion/react";
import {
  HardDrive, KeyRound, History, GitCompare, Mail, Bug, Send, ShieldCheck, Star, GitFork, Users, CircleDot,
  ArrowUpRight, GitCommitHorizontal, Scale, BookOpen,
} from "lucide-react";
import Card from "./Card";
import { Label, Badge, GithubMark } from "./ui";
import { Hero } from "./pages";
import { Toc, Reveal, useScrollSpy, Note } from "./docs";
import { play } from "@/lib/sound";

const OUT_BACK = [0.175, 0.885, 0.32, 1.275];

/* ============ PRIVACY ============ */
function ListCard({ label, dot, title, items }) {
  const ref = useRef(null);
  const inView = useInView(ref, { once: true, amount: 0.5 });
  return (
    <Card ref={ref} w={2} arrow={false} artClass="pad28 gap12">
      <Label dot={dot}>{label}</Label>
      <p className="h-card">{title}</p>
      <div className="pv-list">
        {items.map(([I, t], i) => (
          <motion.span key={t} initial={{ opacity: 0, y: 10 }} animate={inView ? { opacity: 1, y: 0 } : {}} transition={{ delay: 0.1 + i * 0.07, duration: 0.35, ease: OUT_BACK }}>
            <I size={15} />{t}
          </motion.span>
        ))}
      </div>
    </Card>
  );
}

const PV = [
  ["summary", "The short version"],
  ["on-device", "What stays on your Mac"],
  ["leaves", "What leaves your Mac"],
  ["models", "Model providers"],
  ["never", "What we never do"],
  ["retention", "Retention & deletion"],
  ["rights", "Your rights"],
  ["contact", "Contact"],
];

export function PrivacyPage() {
  const ids = useMemo(() => PV.map(([id]) => id), []);
  const active = useScrollSpy(ids);
  return (
    <>
      <div className="grid">
        <Hero
          title={<>Privacy<span className="muted">, in plain words.</span></>}
          lines={[
            "your code is yours.",
            "it stays on your Mac unless a task needs it.",
            "when it leaves, it goes only to the model you picked.",
            { b: "we never train on it*." },
            "you can delete everything in one click.",
          ]}
          footnote="and we never sell anything about you."
        />
        <ListCard label="Stays on your Mac" dot="var(--success)" title="Code, history and keys." items={[[HardDrive, "Your repositories"], [History, "Task history & plans"], [GitCompare, "Diffs and worktrees"], [KeyRound, "API keys — in Keychain"]]} />
        <ListCard label="Leaves your Mac" dot="var(--warning)" title="Only what a task needs." items={[[Send, "Prompt + context → your model"], [Mail, "Your email, for sign-in"], [Bug, "Crash reports — opt-in"], [ShieldCheck, "Usage counts, no content"]]} />
      </div>

      <div className="legal">
        <Toc items={PV} active={active} layoutId="pv-toc" />
        <article className="prose">
          <header className="prose-head">
            <span style={{ display: "flex", gap: 8, alignItems: "center" }}><Label dot={false}>Last updated · Oct 11, 2026</Label><Badge>Draft</Badge></span>
            <h1>Privacy policy</h1>
            <p className="lead">This page explains what Kiln collects, why, and how to make it go away. It&apos;s written for people, not lawyers — the formal version will replace this draft before the public launch.</p>
          </header>
          <Reveal id="summary"><h2>The short version</h2><p>Kiln is a Mac app. It reads and edits code on your computer. To do the thinking it sends the relevant parts of a task to the model you choose. Everything else — your repositories, history, diffs and keys — stays on your Mac.</p></Reveal>
          <Reveal id="on-device"><h2>What stays on your Mac</h2><ul><li>Repositories, worktrees and every diff Kiln makes.</li><li>Task history, plans and terminal output in <code>~/Library/Kiln</code>.</li><li>API keys, stored in the macOS Keychain and never synced by us.</li></ul></Reveal>
          <Reveal id="leaves"><h2>What leaves your Mac</h2><ul><li><strong>Task context</strong> — the prompt and the files Kiln decides it needs, sent to your model provider.</li><li><strong>Account</strong> — your email and sign-in method.</li><li><strong>Diagnostics</strong> — crash reports only if you turn them on; anonymous counts such as tasks per day.</li></ul></Reveal>
          <Reveal id="models"><h2>Model providers</h2><p>With Kiln credits, requests go through our servers to the provider without being stored. With your own key, they go straight from your Mac to the provider and their terms apply.</p><Note>Ollama models run locally — nothing leaves your Mac at all.</Note></Reveal>
          <Reveal id="never"><h2>What we never do</h2><ul><li>Train models on your code or prompts.</li><li>Sell or rent any data about you.</li><li>Read your repositories on our servers.</li></ul></Reveal>
          <Reveal id="retention"><h2>Retention &amp; deletion</h2><p>Account data is kept while your account is active and deleted within 30 days after you close it. Local data is deleted when you remove <code>~/Library/Kiln</code> or press <strong>Settings → Account → Delete all data</strong>.</p></Reveal>
          <Reveal id="rights"><h2>Your rights</h2><p>You can ask for a copy of your data, correct it, or have it deleted at any time — wherever you live.</p></Reveal>
          <Reveal id="contact"><h2>Contact</h2><p>Questions go to <a href="mailto:privacy@kiln.dev">privacy@kiln.dev</a>. A human answers, usually within two days.</p></Reveal>
        </article>
      </div>
    </>
  );
}

/* ============ GITHUB ============ */
function useCount(to, on) {
  const [v, setV] = useState(0);
  useEffect(() => {
    if (!on) return;
    let raf;
    const t0 = performance.now();
    const tick = (t) => {
      const p = Math.min(1, (t - t0) / 1100);
      setV(Math.round(to * (1 - Math.pow(1 - p, 4))));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [on, to]);
  return v;
}

function Stats() {
  const ref = useRef(null);
  const on = useInView(ref, { once: true, amount: 0.5 });
  const s = [[Star, "Stars", useCount(1284, on)], [GitFork, "Forks", useCount(96, on)], [Users, "Contributors", useCount(23, on)], [CircleDot, "Open issues", useCount(41, on)]];
  return (
    <Card ref={ref} w={2} arrow={false} artClass="pad-week">
      <Label dot="var(--ember)">Hqzdev / kiln-skills</Label>
      <div className="metrics">
        {s.map(([I, l, v]) => (
          <div key={l} className="metric"><span style={{ display: "flex", gap: 6, alignItems: "center" }}><I size={13} />{l}</span><b>{v.toLocaleString("en-US")}</b></div>
        ))}
      </div>
      <p style={{ fontSize: 14, color: "var(--text-2)" }}>the skills library, sandbox runner and this site are open source.</p>
    </Card>
  );
}

function StarCard() {
  return (
    <Card arrow={false} className="dl-card dark" onMouseEnter={() => play("pop")}>
      <div className="dl-in">
        <span className="gh-big"><GithubMark size={44} color="#ECECEC" /></span>
        <b>Follow the build</b>
        <a className="dl-btn" href="https://github.com/Hqzdev" target="_blank" rel="noreferrer"><Star size={16} />Star on GitHub</a>
        <span className="mono dl-meta">github.com/Hqzdev</span>
      </div>
    </Card>
  );
}

function License() {
  return (
    <Card arrow={false} artClass="pad24 gap10">
      <Label>License</Label>
      <p className="h-card-sm">MIT for the skills and the sandbox.</p>
      <div className="path-box"><Scale size={14} color="var(--text-3)" /><span className="mono">LICENSE · MIT</span></div>
    </Card>
  );
}

// deterministic pseudo-random contributions so SSR and client match
function contrib() {
  let seed = 7;
  const r = () => ((seed = (seed * 9301 + 49297) % 233280) / 233280);
  return Array.from({ length: 52 * 7 }, (_, i) => {
    const w = Math.floor(i / 7);
    const base = w > 40 ? 0.75 : w > 30 ? 0.5 : 0.25;
    const x = r();
    return x < 1 - base ? 0 : Math.ceil(((x - (1 - base)) / base) * 4);
  });
}
const LEVELS = ["var(--surface-2)", "#f3c4c5", "#ee9294", "#e8686c", "var(--ember)"];

function Heatmap() {
  const ref = useRef(null);
  const on = useInView(ref, { once: true, amount: 0.4 });
  const data = useMemo(contrib, []);
  const [tip, setTip] = useState(null);
  const total = data.reduce((a, b) => a + b, 0);
  return (
    <Card ref={ref} w={4} arrow={false} artClass="heat-art">
      <div style={{ display: "flex", alignItems: "baseline", gap: 12 }}>
        <Label dot="var(--ember)">Activity</Label>
        <span style={{ fontSize: 14, color: "var(--text-2)" }}>{total.toLocaleString("en-US")} commits in the last year</span>
        <span style={{ flex: 1 }} />
        <span className="heat-legend">less{LEVELS.map((c) => <i key={c} style={{ background: c }} />)}more</span>
      </div>
      <div className="heat" onMouseLeave={() => setTip(null)}>
        {Array.from({ length: 52 }, (_, w) => (
          <div key={w} className="heat-col">
            {data.slice(w * 7, w * 7 + 7).map((v, d) => (
              <motion.i
                key={d}
                style={{ background: LEVELS[v] }}
                initial={{ scale: 0, opacity: 0 }}
                animate={on ? { scale: 1, opacity: 1 } : {}}
                transition={{ delay: w * 0.012 + d * 0.01, duration: 0.25, ease: OUT_BACK }}
                onMouseEnter={() => setTip({ w, d, v })}
              />
            ))}
          </div>
        ))}
      </div>
      <div className="heat-tip mono">
        {tip ? `${tip.v === 0 ? "No" : tip.v * 3} commits · week ${tip.w + 1}, ${["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][tip.d]}` : "hover a square"}
      </div>
    </Card>
  );
}

const REPOS = [
  ["kiln-skills", "Community skills for Kiln — testing, release notes, framework conventions.", "Markdown", "#5D5D5D", 1284],
  ["kiln-sandbox", "The isolated shell Kiln runs commands in. macOS seatbelt + network policy.", "Swift", "#F05138", 412],
  ["kiln-site", "This landing page. Next.js, Motion, no gradients.", "JavaScript", "#D9A84A", 88],
];
function Repo({ name, desc, lang, color, stars }) {
  return (
    <Card arrow={false} className="repo-card" artClass="pad24 gap10" onMouseEnter={() => play("tick")}>
      <span className="repo-name"><BookOpen size={15} /><b>{name}</b><Badge>Public</Badge></span>
      <p className="feat-desc" style={{ fontSize: 14 }}>{desc}</p>
      <span className="repo-meta">
        <span><i style={{ background: color }} />{lang}</span>
        <span><Star size={13} />{stars.toLocaleString("en-US")}</span>
      </span>
      <a className="repo-open" href="https://github.com/Hqzdev" target="_blank" rel="noreferrer">Open<ArrowUpRight size={14} /></a>
    </Card>
  );
}

function GoodFirst() {
  return (
    <Card arrow={false} artClass="pad24 gap10">
      <Label dot="var(--success)">Good first issues</Label>
      {["Skill: Django migrations", "Sandbox: allow Homebrew cache", "Site: reduce motion on Safari"].map((t, i) => (
        <span key={t} className="gfi"><CircleDot size={14} color="var(--success)" /><span>{t}</span><em className="mono">#{112 + i * 7}</em></span>
      ))}
    </Card>
  );
}

const COMMITS = [
  ["e41b9a0", "feat(approvals): show reason and scope on every prompt", "2h"],
  ["7c2d113", "fix(worktrees): crash when two tasks finish together", "1d"],
  ["a90f6e2", "feat(skills): load SKILL.md by description match", "3d"],
  ["3be7d48", "perf(diff): virtualize long files in review pane", "4d"],
  ["f12c0aa", "chore: bump sandbox profile for Xcode 17", "6d"],
];
function Commits() {
  return (
    <Card w={4} arrow={false} artClass="pad28 gap12">
      <Label>Recent commits · main</Label>
      <div className="commits dark">
        {COMMITS.map(([h, m, t], i) => (
          <motion.div key={h} className="commit-row" initial={{ opacity: 0, x: -12 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }} transition={{ delay: i * 0.06, duration: 0.3 }}>
            <GitCommitHorizontal size={14} color="var(--text-3)" />
            <span className="mono h">{h}</span>
            <span className="m">{m}</span>
            <span className="mono t">{t}</span>
          </motion.div>
        ))}
      </div>
    </Card>
  );
}

export function GithubPage() {
  return (
    <div className="grid">
      <Hero
        title={<>Kiln<span className="muted"> is built in public.</span></>}
        lines={["the agent is closed. the parts you touch are not.", "skills, the sandbox and this site are MIT.", "issues are the roadmap.", { b: "every PR gets a reply within a day*." }, "good first issues are tagged."]}
        footnote="usually within hours. it's one person."
      />
      <Stats />
      <StarCard />
      <License />
      <Heatmap />
      {REPOS.map(([n, d, l, c, s]) => <Repo key={n} name={n} desc={d} lang={l} color={c} stars={s} />)}
      <GoodFirst />
      <Commits />
    </div>
  );
}


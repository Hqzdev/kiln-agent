"use client";

// Blot app screens rebuilt in HTML from the same mini-UI kit — no image files.
// Each screen is a fixed 1200×750 "window"; <ScaledScreen> scales it to any width.

import {
  SquarePen, Search, Clock3, Puzzle, Folder, FolderOpen, Settings, PanelLeft, History, Ellipsis, BookOpen, Bug,
  FlaskConical, GitPullRequest, Activity, PanelRight, FileText, Terminal, Pencil, Plus, CircleCheck, CircleX, Play,
  Moon, Sparkle, Shield, Server, Plug, Keyboard, SlidersHorizontal, ArrowLeft, Mail, Lock, ArrowRight, Undo2,
  GitCommitHorizontal, Copy, Columns2, X, MessageSquare, FileCode,
} from "lucide-react";
import { siApple, siGithub } from "simple-icons";
import {
  Traffic, Badge, Btn, Chip, Step, Approval, Composer, DiffLine, PlanItem, Changes, TerminalBlock, BlotArch, Brand, Toggle,
} from "./ui";
import { BlotBuddy } from "./buddy";

export const SCREEN_W = 1200;
export const SCREEN_H = 750;

export function ScaledScreen({ id, width, style }) {
  const s = width / SCREEN_W;
  const S = SCREENS[id].C;
  return (
    <div style={{ width, height: SCREEN_H * s, overflow: "hidden", position: "relative", ...style }}>
      <div style={{ width: SCREEN_W, height: SCREEN_H, transform: `scale(${s})`, transformOrigin: "0 0" }}>
        <S />
      </div>
    </div>
  );
}

/* ---------- shell pieces ---------- */
const SI = ({ icon: I, children, meta, sel, indent, muted }) => (
  <div className="sidebar-item" style={{ background: sel ? "var(--selected)" : undefined, paddingLeft: indent ? 36 : 10 }}>
    {I && <I size={16} color={sel ? "var(--text)" : "var(--text-2)"} />}
    <span style={{ flex: 1, color: muted ? "var(--text-2)" : "var(--text)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{children}</span>
    {meta && <span className="meta">{meta}</span>}
  </div>
);

function Sidebar({ sel = "tradr" }) {
  return (
    <aside className="sb">
      <div className="sb-top"><Traffic /><span style={{ flex: 1 }} /><span className="icon-btn"><PanelLeft size={16} /></span></div>
      <div className="sb-body">
        <SI icon={SquarePen} meta="⌘N">New task</SI>
        <SI icon={Search} meta="⌘K">Search</SI>
        <SI icon={Clock3} sel={sel === "auto"}>Automations</SI>
        <SI icon={Puzzle} sel={sel === "skills"}>Skills</SI>
        <div className="sb-sec"><span style={{ flex: 1 }}>Projects</span><Plus size={14} /></div>
        <SI icon={Folder}>kodshag</SI>
        <SI icon={FolderOpen} sel={sel === "tradr"}>tradr</SI>
        <SI indent muted sel={sel === "thread"} meta={<span style={{ color: "var(--success)" }}>●</span>}>Починить расчёт PnL</SI>
        <SI indent muted meta="2h">Экспорт сделок в CSV</SI>
        <SI indent muted meta="1d">Экраны онбординга SwiftUI</SI>
        <SI indent><span style={{ color: "var(--text-3)" }}>Show more</span></SI>
        <SI icon={Folder}>notchai</SI>
        <SI icon={Folder}>knot</SI>
      </div>
      <div className="sb-foot">
        <span className="s-avatar">Y</span>
        <b style={{ flex: 1, fontWeight: 500 }}>Yaroslav</b>
        <Badge>Pro</Badge>
        <span className="icon-btn"><Settings size={16} /></span>
      </div>
    </aside>
  );
}

const Head = ({ children }) => <div className="mhead">{children}</div>;
const Spacer = () => <span style={{ flex: 1 }} />;
const Ico = ({ icon: I }) => <span className="icon-btn"><I size={16} /></span>;

/* ---------- 01 New task ---------- */
function NewTask() {
  return (
    <div className="scr dark">
      <Sidebar />
      <main className="main">
        <Head><Spacer /><Ico icon={History} /><Ico icon={Ellipsis} /></Head>
        <div className="hero">
          <BlotBuddy size={44} stroke="var(--text-3)" ember="var(--text-3)" weight={5} />
          <p className="hero-t">What should we build in tradr?</p>
          <p className="mono" style={{ fontSize: 12, color: "var(--text-3)" }}>main · 2 uncommitted files · last run 2h ago</p>
          <div style={{ display: "flex", gap: 8, paddingTop: 8 }}>
            {[[BookOpen, "Explain the order engine"], [Bug, "Find why PnL drifts"], [FlaskConical, "Write tests for fees.ts"], [GitPullRequest, "Review open PR #42"]].map(([I, l]) => (
              <span key={l} className="chip" style={{ border: "1px solid var(--border)", padding: "0 10px" }}><I size={14} />{l}</span>
            ))}
          </div>
        </div>
        <div className="composer-area">
          <Composer style={{ width: 680 }} />
          <span style={{ fontSize: 11, color: "var(--text-3)" }}>Blot can make mistakes. Review every diff before you merge.</span>
        </div>
      </main>
    </div>
  );
}

/* ---------- 02 Agent working ---------- */
function Working() {
  return (
    <div className="scr dark">
      <Sidebar sel="thread" />
      <main className="main">
        <Head>
          <b style={{ fontWeight: 500 }}>Починить расчёт PnL</b>
          <Badge>blot/fix-pnl-rounding</Badge>
          <Spacer />
          <Chip icon={Activity}><span style={{ color: "var(--text-2)" }}>Working · 1m 12s</span></Chip>
          <Ico icon={PanelRight} /><Ico icon={Ellipsis} />
        </Head>
        <div className="thread">
          <div className="col">
            <div style={{ display: "flex", justifyContent: "flex-end" }}>
              <div className="bubble">PnL в портфеле иногда расходится с брокером на 1–2 копейки. Найди причину и почини.</div>
            </div>
            <p className="agent-msg">Посмотрю, где считаются PnL и комиссии, и воспроизведу расхождение тестом.</p>
            <div>
              <Step icon={FileText} verb="Read" target="src/lib/pnl.ts" meta="212 lines" />
              <Step icon={Search} verb="Searched" target="roundFee" meta="4 matches" />
              <Step icon={Terminal} verb="Ran" target="npm test -- pnl" meta="2.9s" />
            </div>
            <TerminalBlock ok={false} status="exit 1" lines={[{ t: "FAIL  src/lib/pnl.test.ts", style: { color: "var(--danger)" } }, "  ✕ fee on 7 lots — expected 1250.37, received 1250.38"]} />
            <div className="plan-box">
              <span style={{ fontSize: 12, fontWeight: 500, color: "var(--text-3)" }}>Plan · 2 of 4</span>
              <PlanItem>Найти, где считаются PnL и комиссии</PlanItem>
              <PlanItem>Воспроизвести расхождение тестом</PlanItem>
              <PlanItem state="active">Перенести округление и подключить decimal.js</PlanItem>
              <PlanItem state="todo">Прогнать весь набор тестов и линтер</PlanItem>
            </div>
            <Approval />
          </div>
        </div>
        <div className="composer-area" style={{ paddingTop: 0 }}>
          <Composer ctx={[]} placeholder="Reply to steer Blot · Esc to stop" style={{ width: 680 }} />
        </div>
      </main>
    </div>
  );
}

/* ---------- 03 Review ---------- */
const RDIFF = [
  ["@", "", "@@ -1,13 +1,14 @@ fees.ts"], [" ", 1, "import { LOT_SIZE, FEE_RATE } from './config'"], ["+", 2, "import Decimal from 'decimal.js'"],
  [" ", 3, "import type { Order } from '../types'"], [" ", 4, ""], [" ", 5, "export function calcFee(order: Order): number {"],
  [" ", 6, "  const lots = order.qty / LOT_SIZE"], ["-", 7, "  const perLot = roundFee(order.price * FEE_RATE)"], ["-", 8, "  return perLot * lots"],
  ["+", 7, "  const fee = new Decimal(order.price)"], ["+", 8, "    .times(FEE_RATE)"], ["+", 9, "    .times(lots)"], ["+", 10, "  return roundFee(fee.toNumber())"],
  [" ", 11, "}"], [" ", 12, ""], ["@", "", "@@ -31,8 +32,8 @@ export function roundFee"], [" ", 32, "export function roundFee(value: number): number {"],
  ["-", 33, "  if (!Number.isFinite(value)) return 0"], ["-", 34, "  return Math.round(value * 100) / 100"],
  ["+", 33, "  if (!Number.isFinite(value)) throw new FeeError(value)"], ["+", 34, "  return new Decimal(value).toDecimalPlaces(2).toNumber()"],
  [" ", 35, "}"], [" ", 36, ""], [" ", 37, "export const ZERO_FEE = 0"],
];
function Review() {
  return (
    <div className="scr dark">
      <Sidebar sel="thread" />
      <div style={{ width: 400, display: "flex", flexDirection: "column", borderRight: "1px solid var(--border)" }}>
        <Head><b style={{ fontWeight: 500, flex: 1 }}>Починить расчёт PnL</b><Chip icon={CircleCheck}><span style={{ color: "var(--text-2)" }}>Done · 3m 40s</span></Chip></Head>
        <div className="thread" style={{ padding: "0 20px 16px" }}>
          <div className="col" style={{ width: "100%" }}>
            <div>
              <Step icon={Pencil} verb="Edited" target="src/lib/fees.ts" meta="+9 −8" />
              <Step icon={Pencil} verb="Edited" target="src/lib/pnl.ts" meta="+18 −6" />
              <Step icon={Plus} verb="Created" target="pnl.test.ts case" meta="+9" />
              <Step icon={Terminal} verb="Ran" target="npm test" meta="1.84s" />
            </div>
            <TerminalBlock cmd="npm test" />
            <p className="agent-msg">Готово. Округление теперь одно — в конце расчёта, арифметика через decimal.js. Добавил тест на 7 лотов, весь набор зелёный (20/20).</p>
            <Changes />
          </div>
        </div>
      </div>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", background: "#181818", minWidth: 0 }}>
        <Head><Chip sel>Changes · 3</Chip><Chip>Terminal</Chip><Chip>Preview</Chip><Spacer /><Ico icon={Columns2} /><Ico icon={X} /></Head>
        <div style={{ flex: 1, display: "flex", minHeight: 0 }}>
          <div style={{ width: 170, borderRight: "1px solid var(--border)", padding: "10px 6px", display: "flex", flexDirection: "column", gap: 1 }}>
            <div className="sb-sec" style={{ padding: "4px 6px 8px" }}>Changed files</div>
            {[["fees.ts", "+9", "−8", 1], ["pnl.ts", "+18", "−6"], ["pnl.test.ts", "+9", "−0"]].map(([p, a, d, s]) => (
              <div key={p} className="file-row" style={{ padding: "0 8px", background: s ? "var(--selected)" : undefined }}>
                <FileCode size={14} color="var(--text-3)" /><span className="path">{p}</span><span className="add">{a}</span><span className="del">{d}</span>
              </div>
            ))}
          </div>
          <div style={{ flex: 1, display: "flex", flexDirection: "column", background: "var(--bg)", minWidth: 0 }}>
            <div className="mhead" style={{ height: 40 }}>
              <span className="mono" style={{ fontSize: 12 }}>src/lib/fees.ts</span>
              <span className="mono" style={{ fontSize: 12, color: "var(--success)" }}>+9</span>
              <span className="mono" style={{ fontSize: 12, color: "var(--danger)" }}>−8</span>
              <Spacer /><Ico icon={Copy} />
            </div>
            <div style={{ flex: 1, overflow: "hidden", padding: "6px 0" }}>
              {RDIFF.map((d, i) => <DiffLine key={i} k={d[0]} n={d[1]} code={d[2]} />)}
            </div>
          </div>
        </div>
        <div className="mhead" style={{ borderTop: "1px solid var(--border)", borderBottom: 0, height: 60 }}>
          <span className="s-field mono">fix(pnl): round fees once after lot multiplication</span>
          <Btn icon={Undo2}>Discard</Btn>
          <Btn icon={GitCommitHorizontal} emph>Commit &amp; push</Btn>
        </div>
      </div>
    </div>
  );
}

/* ---------- 04 Command palette ---------- */
function Palette() {
  return (
    <div className="scr dark" style={{ display: "block" }}>
      <NewTask />
      <div className="scrim" />
      <div className="s-palette">
        <div className="mhead" style={{ height: 52, padding: "0 16px", gap: 10 }}>
          <Search size={16} color="var(--text-2)" />
          <span style={{ flex: 1, fontSize: 15 }}>pnl<i className="caret" /></span>
          <Badge>esc</Badge>
        </div>
        <div style={{ padding: "0 8px 8px" }}>
          <div className="sb-sec" style={{ padding: "12px 10px 4px" }}>Tasks</div>
          <SI icon={MessageSquare} sel meta="tradr · running">Починить расчёт PnL</SI>
          <SI icon={MessageSquare} meta="tradr · 3d">Тесты для pnl.ts — покрытие 90%</SI>
          <div className="sb-sec" style={{ padding: "12px 10px 4px" }}>Files</div>
          <SI icon={FileCode} meta="tradr">src/lib/pnl.ts</SI>
          <SI icon={FileCode} meta="tradr">src/lib/pnl.test.ts</SI>
          <div className="sb-sec" style={{ padding: "12px 10px 4px" }}>Actions</div>
          <SI icon={SquarePen} meta="↵">New task about “pnl”</SI>
          <SI icon={GitPullRequest} meta="⌘⇧P">Open PR for blot/fix-pnl-rounding</SI>
        </div>
        <div className="mhead" style={{ borderTop: "1px solid var(--border)", borderBottom: 0, height: 36, gap: 16, padding: "0 16px" }}>
          {["↑↓ navigate", "↵ open", "⌘↵ open in new window"].map((t) => <span key={t} style={{ fontSize: 11, color: "var(--text-3)" }}>{t}</span>)}
        </div>
      </div>
    </div>
  );
}

/* ---------- list + detail helpers ---------- */
const Row = ({ t, d, trail, last, mono }) => (
  <div className="s-row" style={last ? { borderBottom: 0 } : undefined}>
    <span style={{ flex: 1, display: "flex", flexDirection: "column", gap: 3 }}>
      <b className={mono ? "mono" : ""} style={{ fontWeight: mono ? 400 : 500, fontSize: mono ? 12 : 13 }}>{t}</b>
      <span style={{ fontSize: 12, color: "var(--text-2)", lineHeight: 1.45 }}>{d}</span>
    </span>
    {trail}
  </div>
);
const Group = ({ title, action, children }) => (
  <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
    <div style={{ display: "flex", alignItems: "center", height: 26 }}><b style={{ flex: 1, fontSize: 14, fontWeight: 500 }}>{title}</b>{action}</div>
    <div className="s-card">{children}</div>
  </div>
);
const Sel = ({ icon, children }) => <span className="chip" style={{ border: "1px solid var(--border-strong)", color: "var(--text)" }}>{icon && (() => { const I = icon; return <I size={14} />; })()}{children}</span>;
const LI = ({ icon: I, t, s, on = true, sel }) => (
  <div className="s-li" style={sel ? { background: "var(--selected)" } : undefined}>
    <span className="s-tile"><I size={16} color={sel ? "var(--text)" : "var(--text-2)"} /></span>
    <span style={{ flex: 1, display: "flex", flexDirection: "column", gap: 2 }}><b style={{ fontWeight: 500 }}>{t}</b><span style={{ fontSize: 12, color: "var(--text-3)" }}>{s}</span></span>
    <Toggle on={on} />
  </div>
);

/* ---------- 05 Automations ---------- */
function Automations() {
  return (
    <div className="scr dark">
      <Sidebar sel="auto" />
      <main className="main">
        <Head><b style={{ fontWeight: 500 }}>Automations</b><Badge>4 active</Badge><Spacer /><Btn icon={Plus} emph>New automation</Btn></Head>
        <div style={{ flex: 1, display: "flex", minHeight: 0 }}>
          <div className="s-list">
            <span className="s-field"><Search size={14} color="var(--text-3)" /><span style={{ color: "var(--text-3)" }}>Search automations</span></span>
            <div className="sb-sec">Scheduled</div>
            <LI icon={Clock3} t="Triage new issues" s="Weekdays at 09:00 · tradr" sel />
            <LI icon={Moon} t="Nightly dependency bump" s="Every day at 03:00 · tradr" />
            <LI icon={FileText} t="Draft the weekly changelog" s="Mondays at 10:00 · blot" />
            <LI icon={FlaskConical} t="Hunt flaky tests" s="Fridays at 18:00 · kodshag" on={false} />
            <div className="sb-sec">On events</div>
            <LI icon={GitPullRequest} t="Review every new PR" s="Pull request opened · tradr" />
            <LI icon={CircleX} t="Fix failing CI on main" s="CI failed on main · tradr" on={false} />
          </div>
          <div className="s-detail">
            <div className="s-titlerow">
              <span className="s-tile lg"><Clock3 size={20} /></span>
              <span style={{ flex: 1 }}>
                <span style={{ display: "flex", gap: 8, alignItems: "center" }}><b className="s-h">Triage new issues</b><Badge tone="success">active</Badge></span>
                <span style={{ fontSize: 13, color: "var(--text-2)" }}>Next run tomorrow at 09:00 · last run 2h ago</span>
              </span>
              <Btn icon={Play}>Run now</Btn>
            </div>
            <Group title="Trigger">
              <Row t="Schedule" d="Runs in the background, even with the window closed." trail={<Sel icon={Clock3}>Weekdays · 09:00</Sel>} />
              <Row t="Project" d="Blot works in a fresh worktree of this project." trail={<Sel icon={Folder}>tradr</Sel>} />
              <Row t="Approvals" d="What the automation may do without asking you." trail={<Sel icon={Shield}>Labels &amp; comments only</Sel>} last />
            </Group>
            <Group title="Recent runs">
              <div style={{ padding: "6px 0" }}>
                <Step icon={CircleCheck} iconColor="var(--success)" verb="Today 09:00" target="4 issues labeled, 1 duplicate" meta="1m 12s" />
                <Step icon={CircleCheck} iconColor="var(--success)" verb="Fri 09:00" target="7 issues labeled" meta="1m 48s" />
                <Step icon={CircleX} iconColor="var(--danger)" verb="Thu 09:00" target="GitHub token expired" meta="4s" />
              </div>
            </Group>
          </div>
        </div>
      </main>
    </div>
  );
}

/* ---------- 06 Skills ---------- */
function Skills() {
  return (
    <div className="scr dark">
      <Sidebar sel="skills" />
      <main className="main">
        <Head><b style={{ fontWeight: 500 }}>Skills</b><span style={{ width: 8 }} /><Chip sel>Installed · 6</Chip><Chip>Browse</Chip><Chip>Team · 2</Chip><Spacer /><Btn icon={Plus} emph>Create skill</Btn></Head>
        <div style={{ flex: 1, display: "flex", minHeight: 0 }}>
          <div className="s-list">
            <span className="s-field"><Search size={14} color="var(--text-3)" /><span style={{ color: "var(--text-3)" }}>Search skills</span></span>
            <div className="sb-sec">Enabled</div>
            <LI icon={FileText} t="Release notes in my voice" s="Used 6 times · by you" sel />
            <LI icon={FlaskConical} t="Write tests first" s="Used 41 times · by you" />
            <LI icon={GitCommitHorizontal} t="Conventional commits" s="Used 128 times · built-in" />
            <LI icon={Sparkle} t="SwiftUI conventions" s="Auto in Swift projects · built-in" />
            <div className="sb-sec">Disabled</div>
            <LI icon={Puzzle} t="Tailwind v4 rules" s="Not used yet · community" on={false} />
          </div>
          <div className="s-detail">
            <div className="s-titlerow">
              <span className="s-tile lg"><FileText size={20} /></span>
              <span style={{ flex: 1 }}>
                <span style={{ display: "flex", gap: 8, alignItems: "center" }}><b className="s-h">Release notes in my voice</b><Badge>v1.2</Badge></span>
                <span style={{ fontSize: 13, color: "var(--text-2)" }}>Turns merged PRs into a short changelog entry.</span>
              </span>
              <Btn icon={Pencil}>Edit</Btn>
            </div>
            <Group title="When Blot uses it">
              <Row t="Use automatically" d="Loads when a task mentions changelog, release or what's new." trail={<Toggle />} />
              <Row t="Projects" d="Where this skill is available." trail={<Sel icon={Folder}>All projects</Sel>} last />
            </Group>
            <Group title="SKILL.md">
              <div className="terminal" style={{ border: 0 }}>
                <div className="out" style={{ gap: 5 }}>
                  {[["---", 3], ["name: release-notes", 1], ["description: Draft the weekly changelog from merged PRs", 1], ["---", 3], ["1. Run git log since the last tag.", 2], ["2. Group changes into NEW / IMPROVED / FIXED.", 2], ["3. Lead with the one change users will feel.", 2], ["4. Under 120 words. Real numbers. No hype.", 2]].map(([l, c], i) => (
                    <span key={i} style={{ color: c === 1 ? "var(--text)" : c === 3 ? "var(--text-3)" : "var(--text-2)" }}>{l}</span>
                  ))}
                </div>
              </div>
            </Group>
          </div>
        </div>
      </main>
    </div>
  );
}

/* ---------- 07 Permissions ---------- */
function Permissions() {
  const nav = [["Personal", [[SlidersHorizontal, "General"], [Keyboard, "Keyboard shortcuts"]]], ["Agent", [[Shield, "Permissions", 1], [Sparkle, "Models"], [Server, "Environments"], [Puzzle, "Skills"]]], ["Integrations", [[Plug, "MCP servers"], [GitPullRequest, "Git & GitHub"]]]];
  const seg = (opts, on) => (
    <span style={{ display: "flex", gap: 2, padding: 2, borderRadius: 10, border: "1px solid var(--border)" }}>
      {opts.map((o) => <span key={o} className={`chip ${o === on ? "sel" : ""}`}>{o}</span>)}
    </span>
  );
  return (
    <div className="scr dark">
      <aside className="sb">
        <div className="sb-top"><Traffic /><Spacer /><Ico icon={ArrowLeft} /></div>
        <div style={{ padding: "4px 18px 10px", fontSize: 20, fontWeight: 600, letterSpacing: -0.3 }}>Settings</div>
        <div style={{ padding: "0 8px" }}><span className="s-field"><Search size={14} color="var(--text-3)" /><span style={{ color: "var(--text-3)" }}>Search settings</span></span></div>
        <div className="sb-body">
          {nav.map(([g, items]) => (
            <div key={g}>
              <div className="sb-sec">{g}</div>
              {items.map(([I, l, s]) => <SI key={l} icon={I} sel={s}>{l}</SI>)}
            </div>
          ))}
        </div>
      </aside>
      <main className="main" style={{ alignItems: "center", padding: "40px 40px 0", overflow: "hidden" }}>
        <div style={{ width: 640, display: "flex", flexDirection: "column", gap: 28 }}>
          <b style={{ fontSize: 28, fontWeight: 600, letterSpacing: -0.5 }}>Permissions</b>
          <Group title="Sandbox">
            <Row t="Sandbox mode" d="Where Blot may write. Full access edits any file without asking." trail={seg(["Read-only", "Workspace", "Full access"], "Workspace")} />
            <Row t="Network access" d="When off, package installs stop and ask first." trail={<Toggle on={false} />} last />
          </Group>
          <Group title="Approvals">
            <Row t="Ask before running commands" d="Pause for approval before any command not on the allow list." trail={<Toggle />} />
            <Row t="Auto-approve edits inside the project" d="File changes apply at once — you review the diff afterwards." trail={<Toggle />} last />
          </Group>
          <Group title="Always allowed commands" action={<Btn icon={Plus}>Add command</Btn>}>
            <Row mono t="npm test" d="Added by you · ran 41 times" trail={<X size={14} color="var(--text-3)" />} />
            <Row mono t="git status" d="Built-in · read-only" trail={<X size={14} color="var(--text-3)" />} last />
          </Group>
        </div>
      </main>
    </div>
  );
}

/* ---------- 08 Log in ---------- */
const GoogleG = () => (
  <svg width="16" height="16" viewBox="0 0 48 48" aria-hidden>
    <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z" />
    <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z" />
    <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z" />
    <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z" />
  </svg>
);
function Login() {
  const P = ({ children, icon }) => <span className="s-prov">{icon}{children}</span>;
  return (
    <div className="scr dark" style={{ flexDirection: "column" }}>
      <div className="mhead" style={{ borderBottom: 0, padding: "0 18px" }}><Traffic /></div>
      <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", paddingBottom: 40 }}>
        <div style={{ width: 340, display: "flex", flexDirection: "column", alignItems: "center", gap: 20 }}>
          <BlotBuddy size={40} stroke="var(--text)" ember="var(--text)" weight={6} />
          <div style={{ textAlign: "center" }}>
            <b style={{ fontSize: 26, fontWeight: 600, letterSpacing: -0.5 }}>Welcome back</b>
            <p style={{ fontSize: 14, color: "var(--text-2)", marginTop: 6 }}>Log in to pick up your tasks where Blot left off.</p>
          </div>
          <div style={{ width: "100%", display: "flex", flexDirection: "column", gap: 8 }}>
            <P icon={<Brand icon={siApple} size={16} />}>Continue with Apple</P>
            <P icon={<GoogleG />}>Continue with Google</P>
            <P icon={<Brand icon={siGithub} size={16} />}>Continue with GitHub</P>
          </div>
          <div style={{ width: "100%", display: "flex", alignItems: "center", gap: 12, color: "var(--text-3)", fontSize: 12 }}><i className="s-rule" />or<i className="s-rule" /></div>
          <div style={{ width: "100%", display: "flex", flexDirection: "column", gap: 10 }}>
            <span className="s-field lg"><Mail size={16} color="var(--text-3)" /><span>yaroslav@hqz.dev</span></span>
            <span className="s-field lg"><Lock size={16} color="var(--text-3)" /><span>••••••••••••</span></span>
            <span className="s-prov emph"><ArrowRight size={16} />Log in</span>
          </div>
          <span style={{ fontSize: 13, color: "var(--text-2)", textDecoration: "underline" }}>Email me a sign-in code instead</span>
        </div>
      </div>
    </div>
  );
}

export const SCREENS = [
  { C: NewTask, name: "New task", desc: "Pick a project, describe the job, pick a model." },
  { C: Working, name: "Agent at work", desc: "Plan, steps and test output stream in. Risky commands stop for a yes." },
  { C: Review, name: "Review", desc: "Every task ends as a diff. Commit or open a PR in one click." },
  { C: Palette, name: "Command palette", desc: "⌘K finds tasks, files and actions across projects." },
  { C: Automations, name: "Automations", desc: "Scheduled and event-driven jobs that run while you sleep." },
  { C: Skills, name: "Skills", desc: "Reusable instructions Blot loads when a task needs them." },
  { C: Permissions, name: "Permissions", desc: "You decide what runs without asking — per Mac or per project." },
  { C: Login, name: "Sign in", desc: "Apple, Google, GitHub or a code to your email." },
];


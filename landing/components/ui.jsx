import {
  ArrowUp, ChevronDown, Folder, GitBranch, Laptop, Mic, Plus, ShieldCheck, ShieldAlert,
  Sparkle, X, CheckCheck, Play, GitCompare, Eye, FileCode, Terminal, CircleCheck, CircleDot, Circle,
} from "lucide-react";
import { siGithub } from "simple-icons";
import { BuddyFace } from "./buddy";

export function Brand({ icon, size = 24, color = "currentColor" }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={color} aria-hidden>
      <path d={icon.path} />
    </svg>
  );
}

export const GithubMark = (p) => <Brand icon={siGithub} {...p} />;

export function BlotArch({ size = 56, stroke = "var(--text)", ember = "var(--ember)" }) {
  return <BuddyFace size={size} stroke={stroke} ember={ember} />;
}

export function AppIcon({ size = 88, happy = false }) {
  return (
    <div
      style={{
        width: size, height: size, borderRadius: size * 0.234, background: "#171717",
        border: "1px solid #FFFFFF1F", display: "grid", placeItems: "center",
        boxShadow: "0 6px 18px #00000080",
      }}
    >
      <BuddyFace size={size * 0.44} happy={happy} />
    </div>
  );
}

export const Label = ({ dot, children, style }) => (
  <span className="label" style={style}>
    {dot !== false && <i style={dot ? { background: dot } : undefined} />}
    {children}
  </span>
);

export const Badge = ({ tone, children, style }) => (
  <span className={`badge ${tone || ""}`} style={style}>{children}</span>
);

export const Traffic = () => (
  <div className="traffic">
    <span style={{ background: "#FF5F57" }} />
    <span style={{ background: "#FEBC2E" }} />
    <span style={{ background: "#28C840" }} />
  </div>
);

export const Btn = ({ icon: I, children, emph, pill, className = "", style, ...rest }) => (
  <button className={`btn ${emph ? "emph" : ""} ${pill ? "pill" : ""} ${className}`} style={style} {...rest}>
    {I && <I size={14} />}
    {children}
  </button>
);

export const Chip = ({ icon: I, children, chevron, sel, style }) => (
  <span className={`chip ${sel ? "sel" : ""}`} style={style}>
    {I && <I size={14} />}
    {children}
    {chevron && <ChevronDown size={12} color="var(--text-3)" />}
  </span>
);

export const Step = ({ icon: I, verb, target, meta, iconColor }) => (
  <div className="step">
    <I size={14} color={iconColor} />
    <span className="verb">{verb}</span>
    <span className="target">{target}</span>
    <span className="meta">{meta}</span>
  </div>
);

export const Approval = ({
  title = "Run command with network access?",
  cmd = "npm install decimal.js@10.4.3",
  reason = "Нужна библиотека для точной десятичной арифметики. Сеть — только npm registry.",
}) => (
  <div className="approval">
    <div className="head"><ShieldAlert size={16} color="var(--warning)" />{title}</div>
    <div className="cmd">{cmd}</div>
    <div className="reason">{reason}</div>
    <div className="actions">
      <Btn icon={X}>Deny</Btn>
      <Btn icon={CheckCheck}>Always allow npm</Btn>
      <Btn icon={Play} emph>Run once</Btn>
    </div>
  </div>
);

export function Composer({ text, placeholder, ctx = ["project", "env", "branch"], tools = ["approval", "model", "voice"], textColor, style }) {
  return (
    <div className="composer" style={style}>
      {ctx.length > 0 && (
        <div className="ctx">
          {ctx.includes("project") && <Chip icon={Folder} chevron>tradr</Chip>}
          {ctx.includes("env") && <Chip icon={Laptop} chevron>This Mac</Chip>}
          {ctx.includes("branch") && <Chip icon={GitBranch} chevron>main</Chip>}
        </div>
      )}
      <div className="input" style={textColor ? { color: textColor } : undefined}>
        {text ?? placeholder ?? "Ask Blot to build, fix or explain anything in tradr"}
      </div>
      <div className="tools">
        <span className="icon-btn"><Plus size={16} /></span>
        {tools.includes("approval") && <Chip icon={ShieldCheck} chevron>Ask before running</Chip>}
        <span style={{ flex: 1 }} />
        {tools.includes("model") && <Chip icon={Sparkle} chevron>Blot 1 · High</Chip>}
        {tools.includes("voice") && <span className="icon-btn"><Mic size={16} /></span>}
        <span className="icon-btn send"><ArrowUp size={16} /></span>
      </div>
    </div>
  );
}

export function DiffLine({ k = " ", n, code, style }) {
  const cls = k === "+" ? "add" : k === "-" ? "del" : k === "@" ? "hunk" : "";
  return (
    <div className={`diff-line ${cls}`} style={style}>
      <span className="n">{k === "@" ? "" : n}</span>
      <span className="s">{k === "+" ? "+" : k === "-" ? "−" : " "}</span>
      <span className="c">{code}</span>
    </div>
  );
}

export function PlanItem({ state = "done", children, size = 13 }) {
  const I = state === "done" ? CircleCheck : state === "active" ? CircleDot : Circle;
  const color = state === "done" ? "var(--success)" : state === "active" ? "var(--text)" : "var(--text-3)";
  return (
    <div className={`plan-item ${state}`} style={{ fontSize: size }}>
      <I size={16} color={color} />
      <span>{children}</span>
    </div>
  );
}

export const FileRow = ({ path, add, del, sel }) => (
  <div className="file-row" style={sel ? { background: "var(--selected)" } : undefined}>
    <FileCode size={14} color="var(--text-3)" />
    <span className="path">{path}</span>
    <span className="add">{add}</span>
    <span className="del">{del}</span>
  </div>
);

export const Changes = ({ title = "3 files changed", stat = "+36 −14", files }) => (
  <div className="changes">
    <div className="head">
      <GitCompare size={14} />
      <b>{title}</b>
      <span className="stat">{stat}</span>
      <Btn icon={Eye}>Review</Btn>
    </div>
    <div className="files">
      {(files || [["src/lib/pnl.ts", "+18", "−6"], ["src/lib/fees.ts", "+9", "−8"], ["src/lib/pnl.test.ts", "+9", "−0"]]).map(([p, a, d]) => (
        <FileRow key={p} path={p} add={a} del={d} />
      ))}
    </div>
  </div>
);

export const TerminalBlock = ({ cmd = "npm test -- pnl", status = "exit 0", ok = true, lines }) => (
  <div className="terminal">
    <div className="head">
      <Terminal size={14} />
      <span className="cmd">{cmd}</span>
      <Badge tone={ok ? "success" : "danger"}>{status}</Badge>
    </div>
    <div className="out">
      {(lines || ["PASS  src/lib/pnl.test.ts (14 tests)", "PASS  src/lib/fees.test.ts (6 tests)", "Tests: 20 passed, 0 failed · 1.84s"]).map((l, i) => (
        <span key={i} style={typeof l === "object" ? l.style : undefined}>{typeof l === "object" ? l.t : l}</span>
      ))}
    </div>
  </div>
);

export const Toggle = ({ on = true }) => (
  <span className="toggle" style={on ? undefined : { background: "var(--surface-2)", justifyContent: "flex-start" }}>
    <span style={on ? undefined : { background: "var(--text-3)" }} />
  </span>
);

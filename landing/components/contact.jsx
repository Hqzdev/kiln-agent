"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Mail, Send, CircleDot, Copy, Check, ArrowRight, MapPin, Clock3 } from "lucide-react";
import { siX } from "simple-icons";
import Card from "./Card";
import { Label, Brand, GithubMark } from "./ui";
import { play } from "@/lib/sound";

const OUT_BACK = [0.175, 0.885, 0.32, 1.275];
const TOPICS = ["Beta access", "Bug", "Feature idea", "Partnership", "Press"];

function ContactForm() {
  const [topic, setTopic] = useState("Beta access");
  const [done, setDone] = useState(false);
  return (
    <Card w={2} h={2} arrow={false} noSpot>
      <form className="manifesto signup" style={{ gap: 16, padding: 48 }} onSubmit={(e) => { e.preventDefault(); setDone(true); play("success"); }}>
        <h1 className="h-display">Talk to a <span className="u">human</span><span className="muted">.</span></h1>
        <p style={{ fontSize: 18, color: "var(--text-2)" }}>no bots, no ticket queue. one person reads everything.</p>
        <div className="rule" />
        <div style={{ display: "flex", gap: 10 }}>
          <label className="field" style={{ flex: 1 }}><span>Name</span><span className="input-wrap"><input required placeholder="Your name" /></span></label>
          <label className="field" style={{ flex: 1 }}><span>Email</span><span className="input-wrap"><Mail size={16} color="var(--text-3)" /><input type="email" required placeholder="you@company.com" /></span></label>
        </div>
        <div className="field">
          <span>About</span>
          <div className="chips">
            {TOPICS.map((t) => (
              <motion.button type="button" key={t} whileTap={{ scale: 0.94 }} className={`pick ${topic === t ? "on" : ""}`} onClick={() => { setTopic(t); play("swatch"); }}>{t}</motion.button>
            ))}
          </div>
        </div>
        <label className="field">
          <span>Message</span>
          <textarea className="textarea" required rows={4} placeholder={topic === "Bug" ? "What happened, what you expected, Kiln version…" : "A few lines is plenty."} />
        </label>
        <motion.button type="submit" className={`submit ${done ? "done" : ""}`} whileTap={{ scale: 0.97 }}>
          <AnimatePresence mode="wait">
            <motion.span key={String(done)} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.18 }}>
              {done ? <><Check size={18} />Sent — reply within a day</> : <><ArrowRight size={18} />Send message</>}
            </motion.span>
          </AnimatePresence>
        </motion.button>
      </form>
    </Card>
  );
}

function CopyEmail() {
  const [ok, setOk] = useState(false);
  const copy = async () => {
    try { await navigator.clipboard.writeText("hello@kiln.dev"); } catch {}
    setOk(true); play("tick");
    setTimeout(() => setOk(false), 1600);
  };
  return (
    <Card w={2} arrow={false} artClass="pad28 gap12">
      <Label dot="var(--ember)">Email</Label>
      <button className="email-big" onClick={copy}>
        <span>hello@kiln.dev</span>
        <AnimatePresence mode="wait" initial={false}>
          <motion.span key={String(ok)} className="email-copy" initial={{ opacity: 0, scale: 0.6 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.6 }} transition={{ duration: 0.2, ease: OUT_BACK }}>
            {ok ? <Check size={18} /> : <Copy size={18} />}
          </motion.span>
        </AnimatePresence>
      </button>
      <p className="feat-desc" style={{ fontSize: 15 }}>{ok ? "Copied to clipboard." : "Click to copy. Privacy questions: privacy@kiln.dev"}</p>
    </Card>
  );
}

function useClock() {
  const [now, setNow] = useState(null);
  useEffect(() => {
    const tick = () => setNow(new Date());
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, []);
  return now;
}

function LocalTime() {
  const now = useClock();
  const parts = now
    ? new Intl.DateTimeFormat("en-GB", { timeZone: "Asia/Yekaterinburg", hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false }).formatToParts(now)
    : [];
  const get = (t) => parts.find((p) => p.type === t)?.value ?? "--";
  const h = Number(get("hour"));
  const awake = now ? h >= 9 && h < 24 : true;
  return (
    <Card arrow={false} artClass="pad24 gap10">
      <Label dot={awake ? "var(--success)" : "var(--text-3)"}>{awake ? "Online now" : "Asleep"}</Label>
      <b className="clock mono">
        {get("hour")}<span className="blink">:</span>{get("minute")}
        <small>{get("second")}</small>
      </b>
      <span className="feat-desc" style={{ fontSize: 14, display: "flex", gap: 6, alignItems: "center" }}><MapPin size={14} />Perm · UTC+5</span>
    </Card>
  );
}

function Response() {
  return (
    <Card arrow={false} artClass="pad24 gap10">
      <Label>Typical reply</Label>
      <b className="big-num" style={{ fontSize: 44 }}>&lt; 24h</b>
      <span className="feat-desc" style={{ fontSize: 14, display: "flex", gap: 6, alignItems: "center" }}><Clock3 size={14} />bugs from beta users first</span>
    </Card>
  );
}

const CHANNELS = [
  ["Telegram", "@kiln_beta", "Beta chat, fastest replies", <Send key="t" size={20} />, "https://t.me/"],
  ["GitHub", "Hqzdev", "Bugs and feature requests", <GithubMark key="g" size={20} />, "https://github.com/Hqzdev"],
  ["X", "@kilndev", "Updates and build log", <Brand key="x" icon={siX} size={18} />, "https://x.com/"],
  ["Issues", "Good first issues", "Want to contribute?", <CircleDot key="i" size={20} />, "/github"],
];
function Channel({ name, handle, desc, icon, href }) {
  return (
    <Card arrow={false} className="channel" onMouseEnter={() => play("tick")}>
      <a className="ch-in" href={href} target={href.startsWith("http") ? "_blank" : undefined} rel="noreferrer">
        <span className="ch-icon">{icon}</span>
        <span className="ch-txt"><b>{name}</b><span className="mono">{handle}</span></span>
        <span className="feat-desc" style={{ fontSize: 14 }}>{desc}</span>
        <span className="ch-go"><ArrowRight size={16} /></span>
      </a>
    </Card>
  );
}

export function ContactPage() {
  return (
    <div className="grid">
      <ContactForm />
      <CopyEmail />
      <LocalTime />
      <Response />
      {CHANNELS.map(([n, h, d, i, href]) => <Channel key={n} name={n} handle={h} desc={d} icon={i} href={href} />)}
    </div>
  );
}

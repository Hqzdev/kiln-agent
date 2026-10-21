"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Mail, Send, CircleDot, Copy, Check, ArrowRight, MapPin, Clock3 } from "lucide-react";
import { siX } from "simple-icons";
import Card from "./Card";
import { Label, Brand, GithubMark } from "./ui";
import { play } from "@/lib/sound";
import { useClipboard } from "@/lib/useClipboard";
import { emailDraft } from "@/lib/emailDraft.mjs";
import FormFeedback from "./FormFeedback";
import FormInput from "./FormInput";

const OUT_BACK = [0.175, 0.885, 0.32, 1.275];
const TOPICS = ["Beta access", "Bug", "Feature idea", "Partnership", "Press"];

function ContactForm() {
  const [topic, setTopic] = useState("Beta access");
  const [done, setDone] = useState(false);
  return (
    <Card w={2} h={2} arrow={false} noSpot>
      <form className="manifesto signup" style={{ gap: 16, padding: 48 }} onChange={() => setDone(false)} onSubmit={(e) => {
        e.preventDefault();
        const data = new FormData(e.currentTarget);
        window.location.href = emailDraft(`Blot: ${topic}`, Object.fromEntries(data));
        setDone(true);
      }}>
        <h1 className="h-display">Talk to a <span className="u">human</span><span className="muted">.</span></h1>
        <p style={{ fontSize: 18, color: "var(--text-2)" }}>no bots, no ticket queue. one person reads everything.</p>
        <div className="rule" />
        <div style={{ display: "flex", gap: 10 }}>
          <label className="field" style={{ flex: 1 }}><span>Name</span><FormInput name="Name" autoComplete="name" placeholder="Your name" /></label>
          <label className="field" style={{ flex: 1 }}><span>Email</span><FormInput type="email" name="Email" autoComplete="email" icon={Mail} placeholder="you@company.com" /></label>
        </div>
        <div className="field">
          <span>About</span>
          <div className="chips">
            {TOPICS.map((t) => (
              <motion.button type="button" key={t} aria-pressed={topic === t} whileTap={{ scale: 0.94 }} className={`pick ${topic === t ? "on" : ""}`} onClick={() => { setTopic(t); setDone(false); play("swatch"); }}>{t}</motion.button>
            ))}
          </div>
        </div>
        <label className="field">
          <span>Message</span>
          <FormInput multiline name="Message" rows={4} placeholder={topic === "Bug" ? "What happened, what you expected, Blot version…" : "A few lines is plenty."} />
        </label>
        <motion.button type="submit" className="submit" whileTap={{ scale: 0.97 }}>
          <AnimatePresence mode="wait">
            <motion.span key={String(done)} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }} transition={{ duration: 0.18 }}>
              <><Mail size={18} />Open email draft</>
            </motion.span>
          </AnimatePresence>
        </motion.button>
        <FormFeedback>{done ? "Continue in your email app and send the draft. If it did not open, email hello@blot.dev." : "Your email app opens with this message. You send it from there."}</FormFeedback>
      </form>
    </Card>
  );
}

function CopyEmail() {
  const { state, copy } = useClipboard("hello@blot.dev");
  const ok = state === "copied";
  return (
    <Card w={2} arrow={false} artClass="pad28 gap12">
      <Label dot="var(--ember)">Email</Label>
      <button type="button" className="email-big" onClick={copy} disabled={state === "copying"} aria-label={ok ? "Email copied" : "Copy hello@blot.dev"}>
        <span>hello@blot.dev</span>
        <AnimatePresence mode="wait" initial={false}>
          <motion.span key={String(ok)} className="email-copy" initial={{ opacity: 0, scale: 0.6 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.6 }} transition={{ duration: 0.2, ease: OUT_BACK }}>
            {ok ? <Check size={18} /> : <Copy size={18} />}
          </motion.span>
        </AnimatePresence>
      </button>
      <FormFeedback error={state === "error"}>{state === "error" ? "Could not copy. Select hello@blot.dev and copy it manually." : ok ? "Copied to clipboard." : "Click to copy. Privacy questions: privacy@blot.dev"}</FormFeedback>
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
  ["Telegram", "@blot_beta", "Beta chat, fastest replies", <Send key="t" size={20} />, "https://t.me/"],
  ["GitHub", "Hqzdev", "Bugs and feature requests", <GithubMark key="g" size={20} />, "https://github.com/Hqzdev"],
  ["X", "@blotdev", "Updates and build log", <Brand key="x" icon={siX} size={18} />, "https://x.com/"],
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

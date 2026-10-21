"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { motion, MotionConfig } from "motion/react";
import { MousePointer2, Volume2, VolumeX } from "lucide-react";
import { play, setMuted, useMuted } from "@/lib/sound";
import ThemeControl from "./ThemeControl";

export function MotionPreferences({ children }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}

const LINKS = [
  { href: "/", label: "Home" },
  { href: "/features", label: "Features" },
  { href: "/changelog", label: "Changelog", dot: true },
  { href: "/beta", label: "Beta" },
];

// G3 — grey pill slides under the clicked item. G4 — fades out near the footer.
export function Nav() {
  const path = usePathname();
  const muted = useMuted();
  const [hidden, setHidden] = useState(false);

  useEffect(() => {
    const onScroll = () => {
      const max = document.documentElement.scrollHeight - innerHeight;
      const p = max > 0 ? scrollY / max : 0;
      setHidden(max > 400 && p > 0.95);
    };
    onScroll();
    addEventListener("scroll", onScroll, { passive: true });
    addEventListener("resize", onScroll);
    return () => { removeEventListener("scroll", onScroll); removeEventListener("resize", onScroll); };
  }, [path]);

  return (
    <div className={`nav-wrap ${hidden ? "hidden" : ""} ${path.startsWith("/workspace") ? "workspace-nav" : ""}`}>
      <nav className="nav" aria-label="Main navigation">
        {LINKS.map((l) => {
          const active = l.href === "/" ? path === "/" : path.startsWith(l.href);
          return (
            <Link key={l.href} href={l.href} aria-current={active ? "page" : undefined} className={`nav-item ${active ? "active" : ""}`} onClick={() => play("nav")}>
              {active && (
                <motion.span layoutId="nav-pill" className="pill" transition={{ duration: 0.2, ease: "easeOut" }} />
              )}
              {l.dot && <span className="dot" />}
              {l.label}
            </Link>
          );
        })}
        <button
          className="nav-sound"
          aria-label={muted ? "Turn sound on" : "Turn sound off"}
          aria-pressed={!muted}
          onClick={() => { setMuted(!muted); if (muted) setTimeout(() => play("tick"), 0); }}
        >
          {muted ? <VolumeX size={18} /> : <Volume2 size={18} />}
        </button>
        <ThemeControl />
      </nav>
    </div>
  );
}

export function Footer({ className = "" }) {
  return (
    <footer className={`footer ${className}`}>
      <span className="label"><i style={{ background: "var(--ember)" }} />Blot · 2026</span>
      <nav aria-label="Ссылки в футере">
        <Link href="/workspace" onClick={() => play("nav")}>Задачи</Link>
        <a href="/BLOT_TECHNICAL_SPECIFICATION.md" download>Скачать техническое задание ↓</a>
        {[["/changelog", "Changelog"], ["/docs", "Docs"], ["/privacy", "Privacy"], ["/github", "GitHub"], ["/contact", "Contact"]].map(([href, label]) => (
          <Link key={href} href={href} onClick={() => play("nav")}>{label}</Link>
        ))}
      </nav>
    </footer>
  );
}

// Cards reflow in CSS so text and controls retain their readable sizes.
export function Stage({ children, hint = true }) {
  const [gone, setGone] = useState(false);
  useEffect(() => {
    const onScroll = () => { if (scrollY > 40) setGone(true); };
    addEventListener("scroll", onScroll, { passive: true });
    return () => removeEventListener("scroll", onScroll);
  }, []);
  return (
    <main className="page" id="main-content" tabIndex={-1}>
      <div className="stage">
        {hint ? (
          <div className={`look-around ${gone ? "gone" : ""}`}>
            <MousePointer2 size={16} />
            Look around…
          </div>
        ) : (
          <div style={{ height: 56 }} />
        )}
        {children}
        <Footer />
      </div>
    </main>
  );
}

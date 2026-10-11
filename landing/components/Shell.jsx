"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { motion } from "motion/react";
import { MousePointer2, Volume2, VolumeX } from "lucide-react";
import { play, setMuted, useMuted } from "@/lib/sound";
import { KilnArch } from "./ui";

// G1 — white overlay until assets are ready, fades 500ms, then leaves layout.
export function Loader() {
  const [state, setState] = useState("on");
  useEffect(() => {
    const done = () => {
      setState("fading");
      setTimeout(() => setState("off"), 520);
    };
    if (document.readyState === "complete") requestAnimationFrame(done);
    else window.addEventListener("load", done, { once: true });
    const t = setTimeout(done, 1500);
    return () => clearTimeout(t);
  }, []);
  if (state === "off") return null;
  return (
    <div className={`loader ${state === "fading" ? "done" : ""}`}>
      <KilnArch size={36} stroke="#0D0D0D" ember="#E5484D" />
    </div>
  );
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
    <div className={`nav-wrap ${hidden ? "hidden" : ""}`}>
      <nav className="nav">
        {LINKS.map((l) => {
          const active = l.href === "/" ? path === "/" : path.startsWith(l.href);
          return (
            <Link key={l.href} href={l.href} className={`nav-item ${active ? "active" : ""}`} onClick={() => play("nav")}>
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
          onClick={() => { setMuted(!muted); if (muted) setTimeout(() => play("tick"), 0); }}
        >
          {muted ? <VolumeX size={18} /> : <Volume2 size={18} />}
        </button>
      </nav>
    </div>
  );
}

// Scales the fixed 1180px bento layout to fit narrower windows without reflowing it.
export function Stage({ children, hint = true }) {
  const [gone, setGone] = useState(false);
  useEffect(() => {
    const fit = () => {
      const base = innerWidth <= 760 ? 580 : 1180;
      const s = Math.min(1, (innerWidth - 32) / base);
      document.documentElement.style.setProperty("--scale", String(s));
    };
    fit();
    addEventListener("resize", fit);
    const onScroll = () => { if (scrollY > 40) setGone(true); };
    addEventListener("scroll", onScroll, { passive: true });
    return () => { removeEventListener("resize", fit); removeEventListener("scroll", onScroll); };
  }, []);
  return (
    <main className="page">
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
        <footer className="footer">
          <span className="label"><i style={{ background: "var(--ember)" }} />Kiln · 2026</span>
          <nav>
            {[["/changelog", "Changelog"], ["/docs", "Docs"], ["/privacy", "Privacy"], ["/github", "GitHub"], ["/contact", "Contact"]].map(([h, l]) => (
              <Link key={h} href={h} onClick={() => play("nav")}>{l}</Link>
            ))}
          </nav>
        </footer>
      </div>
    </main>
  );
}

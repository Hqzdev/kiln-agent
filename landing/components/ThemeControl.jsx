"use client";

import { useEffect, useState } from "react";
import { Monitor, Moon, Sun } from "lucide-react";

const THEMES = ["system", "light", "dark"];

export default function ThemeControl() {
  const [theme, setTheme] = useState("system");
  useEffect(() => {
    try {
      const saved = localStorage.getItem("blot-theme");
      if (THEMES.includes(saved)) setTheme(saved);
    } catch { /* The system theme also works when storage is unavailable. */ }
  }, []);
  useEffect(() => {
    const preference = matchMedia("(prefers-color-scheme: dark)");
    const apply = () => {
      document.documentElement.classList.toggle("dark", theme === "dark" || (theme === "system" && preference.matches));
      document.documentElement.style.colorScheme = theme === "system" ? "light dark" : theme;
    };
    apply();
    preference.addEventListener("change", apply);
    return () => preference.removeEventListener("change", apply);
  }, [theme]);

  const next = THEMES[(THEMES.indexOf(theme) + 1) % THEMES.length];
  const Icon = theme === "system" ? Monitor : theme === "light" ? Sun : Moon;
  return <button className="nav-sound" type="button" aria-label={`Theme: ${theme}. Switch to ${next}`} title={`Theme: ${theme}`} onClick={() => {
    setTheme(next);
    try { localStorage.setItem("blot-theme", next); } catch { /* Keep the preference for this session. */ }
  }}><Icon size={18} aria-hidden="true" /></button>;
}

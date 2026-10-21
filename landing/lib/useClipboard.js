"use client";

import { useEffect, useState } from "react";

export function useClipboard(text) {
  const [state, setState] = useState("idle");

  useEffect(() => { setState("idle"); }, [text]);
  useEffect(() => {
    if (state !== "copied") return;
    const timer = setTimeout(() => setState("idle"), 2000);
    return () => clearTimeout(timer);
  }, [state]);

  const copy = async () => {
    if (state === "copying") return;
    setState("copying");
    try {
      await navigator.clipboard.writeText(text);
      setState("copied");
    } catch {
      setState("error");
    }
  };

  return { state, copy };
}

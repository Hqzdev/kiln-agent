"use client";

import { useEffect, useId, useRef, useState } from "react";
import { Check, ChevronDown } from "lucide-react";

export default function CatalogSelect({ label, value, options, onChange, compact = false }) {
  const id = useId();
  const rootRef = useRef(null);
  const triggerRef = useRef(null);
  const listRef = useRef(null);
  const searchRef = useRef({ text: "", time: 0 });
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const selectedIndex = Math.max(0, options.findIndex((option) => option.value === value));

  useEffect(() => {
    if (!open) return;
    listRef.current?.focus();
    const closeOutside = (event) => {
      if (!rootRef.current?.contains(event.target)) setOpen(false);
    };
    document.addEventListener("pointerdown", closeOutside);
    return () => document.removeEventListener("pointerdown", closeOutside);
  }, [open]);

  useEffect(() => {
    if (open) listRef.current?.children[activeIndex]?.scrollIntoView({ block: "nearest" });
  }, [open, activeIndex]);

  const show = (index = selectedIndex) => {
    setActiveIndex(index);
    searchRef.current = { text: "", time: 0 };
    setOpen(true);
  };

  const close = () => {
    setOpen(false);
    triggerRef.current?.focus();
  };

  const select = (index) => {
    onChange(options[index].value);
    close();
  };

  const handleKey = (event) => {
    const last = options.length - 1;
    if (event.key === "Tab") { setOpen(false); return; }
    if (event.key === "Escape") { event.preventDefault(); close(); return; }
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      select(activeIndex);
      return;
    }
    const next = event.key === "ArrowDown" ? Math.min(activeIndex + 1, last)
      : event.key === "ArrowUp" ? Math.max(activeIndex - 1, 0)
      : event.key === "Home" ? 0 : event.key === "End" ? last : null;
    if (next !== null) { event.preventDefault(); setActiveIndex(next); return; }
    if (event.key.length === 1 && !event.metaKey && !event.ctrlKey && !event.altKey) {
      event.preventDefault();
      const now = Date.now();
      const text = (now - searchRef.current.time < 700 ? searchRef.current.text : "") + event.key.toLocaleLowerCase();
      searchRef.current = { text, time: now };
      const index = options.findIndex((option) => option.label.toLocaleLowerCase().startsWith(text));
      if (index !== -1) setActiveIndex(index);
    }
  };

  return (
    <div className={`ws-select${compact ? " compact" : ""}`} ref={rootRef} onBlur={(event) => {
      if (!event.currentTarget.contains(event.relatedTarget)) setOpen(false);
    }}>
      <button className="ws-select-trigger" ref={triggerRef} type="button" aria-label={`${label}: ${options[selectedIndex].label}`} aria-haspopup="listbox" aria-expanded={open} aria-controls={open ? id : undefined} onClick={() => open ? close() : show()} onKeyDown={(event) => {
        if (event.key === "ArrowDown" || event.key === "ArrowUp") {
          event.preventDefault();
          show();
        }
      }}>
        <span>{options[selectedIndex].label}</span><ChevronDown size={14} aria-hidden="true" />
      </button>
      {open && <div className="ws-select-menu" id={id} ref={listRef} role="listbox" tabIndex={-1} aria-label={label} aria-activedescendant={`${id}-${activeIndex}`} onKeyDown={handleKey}>
        {options.map((option, index) => <div key={option.value} id={`${id}-${index}`} role="option" aria-selected={option.value === value} className={`ws-select-option${index === activeIndex ? " active" : ""}`} onPointerMove={() => setActiveIndex(index)} onClick={() => select(index)}>
          <span>{option.label}</span>{option.value === value && <Check size={14} aria-hidden="true" />}
        </div>)}
      </div>}
    </div>
  );
}

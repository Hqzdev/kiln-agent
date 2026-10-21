export function emailDraft(subject, fields) {
  const body = Object.entries(fields)
    .map(([label, value]) => `${label}: ${String(value).trim()}`)
    .join("\n\n");
  return `mailto:hello@blot.dev?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
}

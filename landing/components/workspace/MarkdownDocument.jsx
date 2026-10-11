import { posix } from "node:path";
import { documents } from "@/lib/workspace/documentation.mjs";

function documentHref(href, sourcePath) {
  if (/^https?:\/\//.test(href) || href.startsWith("#")) return href;
  const [path, anchor] = href.split("#");
  const target = posix.normalize(posix.join(posix.dirname(sourcePath), path));
  const document = documents.find((item) => item.path === target);
  return document ? `${document.href}${anchor ? `#${anchor}` : ""}` : null;
}

function inline(text, sourcePath) {
  const pattern = /`([^`]+)`|\*\*([^*]+)\*\*|\[([^\]]+)\]\(([^)]+)\)/g;
  const nodes = [];
  let cursor = 0;
  for (const match of text.matchAll(pattern)) {
    if (match.index > cursor) nodes.push(text.slice(cursor, match.index));
    const key = match.index;
    if (match[1]) nodes.push(<code key={key}>{match[1]}</code>);
    else if (match[2]) nodes.push(<strong key={key}>{match[2]}</strong>);
    else {
      const href = documentHref(match[4], sourcePath);
      nodes.push(href ? <a key={key} href={href} {...(href.startsWith("http") ? { target: "_blank", rel: "noreferrer" } : {})}>{match[3]}</a> : match[3]);
    }
    cursor = match.index + match[0].length;
  }
  if (cursor < text.length) nodes.push(text.slice(cursor));
  return nodes;
}

const cells = (line) => line.trim().replace(/^\|/, "").replace(/\|$/, "").split(/(?<!\\)\|/).map((cell) => cell.trim().replace(/\\\|/g, "|"));
const isList = (line) => /^(?:[-*]|\d+\.)\s+/.test(line);

export default function MarkdownDocument({ content, sourcePath }) {
  const lines = content.split("\n");
  const blocks = [];
  let index = lines[0].startsWith("# ") ? 1 : 0;
  while (index < lines.length) {
    const line = lines[index];
    if (!line.trim()) { index++; continue; }
    const key = index;
    if (line.startsWith("```")) {
      const language = line.slice(3).trim();
      const code = [];
      index++;
      while (index < lines.length && !lines[index].startsWith("```")) code.push(lines[index++]);
      index++;
      blocks.push(<div key={key} className="ws-doc-code">{language && <span>{language}</span>}<pre tabIndex={0}><code>{code.join("\n")}</code></pre></div>);
      continue;
    }
    const heading = /^(#{1,6})\s+(.+)$/.exec(line);
    if (heading) {
      const Heading = `h${Math.min(heading[1].length, 6)}`;
      blocks.push(<Heading key={key}>{inline(heading[2], sourcePath)}</Heading>);
      index++;
      continue;
    }
    if (line.startsWith("|") && /^\s*\|?\s*:?-{3,}/.test(lines[index + 1] || "")) {
      const header = cells(line);
      const rows = [];
      index += 2;
      while (index < lines.length && lines[index].startsWith("|")) rows.push(cells(lines[index++]));
      blocks.push(<div key={key} className="ws-doc-table" tabIndex={0} role="region" aria-label={`Таблица: ${header.join(", ")}`}><table><thead><tr>{header.map((cell, column) => <th key={column}>{inline(cell, sourcePath)}</th>)}</tr></thead><tbody>{rows.map((row, rowIndex) => <tr key={rowIndex}>{row.map((cell, column) => <td key={column}>{inline(cell, sourcePath)}</td>)}</tr>)}</tbody></table></div>);
      continue;
    }
    if (isList(line)) {
      const ordered = /^\d+\./.test(line);
      const List = ordered ? "ol" : "ul";
      const items = [];
      while (index < lines.length && isList(lines[index]) && /^\d+\./.test(lines[index]) === ordered) items.push(lines[index++].replace(/^(?:[-*]|\d+\.)\s+/, ""));
      blocks.push(<List key={key}>{items.map((item, itemIndex) => <li key={itemIndex}>{inline(item, sourcePath)}</li>)}</List>);
      continue;
    }
    const paragraph = [line];
    index++;
    while (index < lines.length && lines[index].trim() && !/^(?:#|```|\|)/.test(lines[index]) && !isList(lines[index])) paragraph.push(lines[index++]);
    blocks.push(<p key={key}>{inline(paragraph.join(" "), sourcePath)}</p>);
  }
  return <article className="ws-doc-body">{blocks}</article>;
}

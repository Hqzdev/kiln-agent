"use client";

import { useState } from "react";
import { ArrowRight, MoveHorizontal, Flag } from "lucide-react";
import { projectPlan, schedule } from "@/lib/workspace/data.mjs";
import { formatDate } from "@/lib/workspace/project-plan.mjs";

const weeks = [
  ["12–18", "октябрь"], ["19–25", "октябрь"], ["26–01", "окт / ноя"],
  ["02–08", "ноябрь"], ["09–15", "ноябрь"], ["16–22", "ноябрь"], ["23–29", "ноябрь"],
  ["30–06", "ноя / дек"], ["07–13", "декабрь"], ["14–15", "декабрь"],
];
const dayValue = (date) => new Date(`${date}T00:00:00Z`).getTime() / 86400000;
const timelineStart = dayValue(schedule.start);

// Each column represents one week; the final, partial week keeps the same scale.
const barPosition = (stream) => {
  const left = (dayValue(stream.start) - timelineStart) / 70 * 100;
  const width = (dayValue(stream.end) - dayValue(stream.start) + 1) / 70 * 100;
  return { left: `${left}%`, width: `${width}%` };
};

export default function Roadmap({ onOpenTask, onOpenStream }) {
  const [selectedId, setSelectedId] = useState(projectPlan.streams[0].id);
  const selected = projectPlan.streams.find((stream) => stream.id === selectedId);
  const [expandedId, setExpandedId] = useState(null);
  const selectedTasks = projectPlan.getTasksForStream(selected).filter((task) => task.status !== "completed");
  const expanded = expandedId === selectedId;
  const visibleTasks = expanded ? selectedTasks : selectedTasks.slice(0, 8);

  return (
    <div className="ws-roadmap">
      <div className="ws-section-intro"><div><span className="ws-eyebrow">12 ОКТЯБРЯ — 15 ДЕКАБРЯ 2026</span><h2>Каждый блок — к своему сроку.</h2><p>Функции готовы к 1 декабря. Следующие две недели — проверка и исправления.</p></div><div className="ws-road-legend"><span><i />Разработка</span><span><i className="qa" />Проверка</span><span><i className="delivery" />Сдача</span></div></div>
      <div className="ws-road-scroll-hint"><MoveHorizontal size={14} /> Таблица прокручивается по горизонтали · выберите блок, чтобы увидеть результат</div>
      <div className="ws-road-scroll" tabIndex={0} role="region" aria-label="Roadmap по неделям. Прокрутка по горизонтали">
        <div className="ws-gantt">
          <div className="ws-week-header"><div>БЛОК РЕАЛИЗАЦИИ</div>{weeks.map(([days, month], index) => <div key={index}><span>{month}</span><strong>{days}</strong></div>)}</div>
          {projectPlan.streams.map((stream) => {
            const phase = stream.type === "qa" ? "qa" : stream.id === "delivery" ? "delivery" : "development";
            const tasks = projectPlan.getTasksForStream(stream);
            const completed = tasks.filter((task) => task.status === "completed").length;
            const percent = tasks.length ? Math.round(completed / tasks.length * 100) : 0;
            return <div key={stream.id} className={`ws-gantt-row ${selectedId === stream.id ? "selected" : ""}`}>
              <button className="ws-stream-name" onClick={() => onOpenStream(stream.id)} aria-label={`${stream.title}: выполнено ${percent}%. Открыть задачи блока`}><span>{stream.title}<small>{tasks.length} задач · {completed} готово · <strong>{percent}%</strong></small></span><span>{formatDate(stream.end)}</span></button>
              <div className="ws-gantt-track"><button className={`ws-gantt-bar ${phase} ${stream.start === stream.end ? "milestone" : ""}`} style={barPosition(stream)} onClick={() => setSelectedId(stream.id)} aria-label={`${stream.title}: ${formatDate(stream.start)} — ${formatDate(stream.end)}. Открыть результат`} aria-pressed={selectedId === stream.id}>{stream.start === stream.end ? <Flag size={13} /> : <span>до {formatDate(stream.end)}</span>}</button></div>
            </div>;
          })}
          <div className="ws-road-gates"><span>КОНТРОЛЬНЫЕ ДАТЫ</span><div><span style={{ left: `${50 / 70 * 100}%` }}>01.12 · Функции готовы</span><span style={{ left: `${64 / 70 * 100}%` }}>15.12 · Сдача</span></div></div>
        </div>
      </div>
      <section className="ws-stream-detail" aria-live="polite" aria-labelledby="ws-stream-title">
        <div className="ws-stream-detail-header"><span className="ws-eyebrow">КОНТРОЛЬНЫЙ РЕЗУЛЬТАТ</span><span>{formatDate(selected.start)} — {formatDate(selected.end, { year: "numeric" })}</span></div>
        <h3 id="ws-stream-title">{selected.title}</h3>
        <div className="ws-stream-outcomes"><div><span>Что сдаём</span><p>{selected.output}</p></div><div><span>Как проверяем</span><p>{selected.gate}</p></div></div>
        <div className="ws-stream-tasks" id="ws-stream-tasks"><span>Оставшиеся задачи блока · {selectedTasks.length}</span>{visibleTasks.map((task) => <button key={task.id} onClick={() => onOpenTask(task)}><span className="ws-task-id">{task.id}</span><span>{task.title}</span><ArrowRight size={14} /></button>)}</div>
        {selectedTasks.length > 8 && <button className="ws-show-stream-tasks" aria-expanded={expanded} aria-controls="ws-stream-tasks" onClick={() => setExpandedId(expanded ? null : selectedId)}>{expanded ? "Свернуть список" : `Показать все задачи блока (${selectedTasks.length})`}</button>}
      </section>
      <p className="ws-road-note">План зависит от прохождения контрольных проверок. После 1 декабря — фиксация функций; 2–14 декабря сохраняем для аудита, багфиксов и финальной регрессии.</p>
    </div>
  );
}

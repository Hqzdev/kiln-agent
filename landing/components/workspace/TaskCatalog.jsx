"use client";

import { useRef, useState } from "react";
import { ArrowUpRight, Search, X, ListFilter, ChevronRight, ChevronLeft, Check, CircleCheck } from "lucide-react";
import { projectPlan } from "@/lib/workspace/data.mjs";
import { formatDate } from "@/lib/workspace/project-plan.mjs";
import CatalogSelect from "./CatalogSelect";

const PAGE_SIZE = 50;

function Pagination({ page, pageCount, onChange }) {
  if (pageCount <= 1) return null;
  return <nav className="ws-pagination" aria-label="Страницы каталога"><button aria-label="Предыдущая страница задач" disabled={page === 1} onClick={() => onChange(page - 1)}><ChevronLeft size={14} /></button><div className="ws-page-picker">Страница <CatalogSelect compact label="Номер страницы каталога" value={page} onChange={onChange} options={Array.from({ length: pageCount }, (_, index) => ({ value: index + 1, label: String(index + 1) }))} /> из {pageCount}</div><button aria-label="Следующая страница задач" disabled={page === pageCount} onClick={() => onChange(page + 1)}><ChevronRight size={14} /></button></nav>;
}

export default function TaskCatalog({ onOpenTask, status = "active", type = "all", onScopeChange }) {
  const [query, setQuery] = useState("");
  const [epic, setEpic] = useState("all");
  const [page, setPage] = useState(1);
  const contentRef = useRef(null);
  const isCompleted = status === "completed";
  const scopedTasks = projectPlan.getTasksForStatus(status);
  const availableTypes = projectPlan.types.filter((item) => projectPlan.remainingTasks.some((task) => task.type === item.id));
  const results = projectPlan.findTasks({ type, epic, query, status });
  const pageCount = Math.max(1, Math.ceil(results.length / PAGE_SIZE));
  const currentPage = Math.min(page, pageCount);
  const visibleTasks = results.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);
  const groups = projectPlan.types.map((item) => ({ ...item, tasks: visibleTasks.filter((task) => task.type === item.id) })).filter((item) => item.tasks.length);
  const activeType = projectPlan.getType(type);
  const availableEpics = projectPlan.epics.filter((item) => scopedTasks.some((task) => task.epicId === item.id && (type === "all" || task.type === type)));
  const changeType = (value) => { setEpic("all"); setQuery(""); setPage(1); onScopeChange({ status: "active", type: value }); };
  const showCompleted = () => { setEpic("all"); setQuery(""); setPage(1); onScopeChange({ status: "completed", type: "all" }); };
  const changeQuery = (value) => { setQuery(value); setPage(1); };
  const changePage = (value) => { setPage(value); contentRef.current?.scrollIntoView({ block: "start", behavior: "auto" }); };

  return (
    <div className="ws-catalog">
      <aside className="ws-type-sidebar" aria-label="Типы задач">
        <div className="ws-sidebar-title"><ListFilter size={14} /> ТИП ЗАДАЧИ</div>
        <div className="ws-type-list">
          <button aria-pressed={!isCompleted && type === "all"} className={!isCompleted && type === "all" ? "selected" : ""} onClick={() => changeType("all")}><span>Все задачи</span><span>{projectPlan.remainingTasks.length}</span></button>
          <button aria-pressed={isCompleted} className={`ws-sidebar-completed ${isCompleted ? "selected" : ""}`} onClick={showCompleted}><span><CircleCheck size={14} />Выполненные</span><span>{projectPlan.completedTasks.length}</span></button>
          {availableTypes.map((item) => (
            <button key={item.id} aria-pressed={!isCompleted && type === item.id} className={!isCompleted && type === item.id ? "selected" : ""} onClick={() => changeType(item.id)}><span>{item.label}</span><span>{projectPlan.getTasksForType(item.id, { status: "active" }).length}</span></button>
          ))}
        </div>
        <div className="ws-slice-note"><span>ПОЛНЫЙ ПЛАН РЕАЛИЗАЦИИ</span><p>{projectPlan.tasks.length} подзадач в {projectPlan.epics.length} блоках. Каждая связана с ТЗ и roadmap.</p><a href="/KILN_TECHNICAL_SPECIFICATION.md" download>Скачать ТЗ <ArrowUpRight size={13} /></a></div>
      </aside>
      <div className="ws-task-content" ref={contentRef}>
        <div className="ws-task-toolbar">
          <div><h2>{isCompleted ? "Выполненные задачи" : activeType?.label || "План реализации"}</h2><p>{isCompleted ? "Готовые результаты со ссылками на документы и проверку." : activeType?.description || "Откройте задачу: от экранов и файлов до итоговой проверки."}</p></div>
          <div className="ws-search"><Search size={16} /><input id="ws-task-search" type="search" aria-label="Поиск задач, экранов и файлов" placeholder="Задача, экран или файл…" value={query} onChange={(event) => changeQuery(event.target.value)} />{query && <button aria-label="Очистить поиск" onClick={() => changeQuery("")}><X size={15} /></button>}</div>
        </div>
        <div className="ws-catalog-controls"><div className="ws-epic-filter">Блок <CatalogSelect label="Блок реализации" value={epic} onChange={(value) => { setEpic(value); setPage(1); }} options={[{ value: "all", label: "Все блоки" }, ...availableEpics.map((item) => ({ value: item.id, label: `${item.id} · ${item.title}` }))]} /></div><Pagination page={currentPage} pageCount={pageCount} onChange={changePage} /></div>
        <div className={`ws-list-meta ${isCompleted ? "completed" : ""}`}><span aria-live="polite">{results.length} из {scopedTasks.length} задач{results.length > PAGE_SIZE && ` · показаны ${(currentPage - 1) * PAGE_SIZE + 1}–${Math.min(currentPage * PAGE_SIZE, results.length)}`}</span><span>{isCompleted ? <Check size={12} /> : <i />}{isCompleted ? "Выполнено" : "Запланировано"}</span></div>
        <div className="ws-column-labels"><span>ЗАДАЧА / {isCompleted ? "ГОТОВЫЙ" : "ОЖИДАЕМЫЙ"} РЕЗУЛЬТАТ</span><span>ПРИОРИТЕТ</span><span>{isCompleted ? "ГОТОВО" : "ДЕДЛАЙН"}</span><span /></div>
        {groups.map((group) => (
          <section key={group.id} className="ws-task-group" aria-labelledby={`type-${group.id}`}>
            <div className="ws-group-heading"><h3 id={`type-${group.id}`}>{group.label}<span>{group.tasks.length}</span></h3><span>{group.owner}</span></div>
            {group.tasks.map((task) => (
              <button key={task.id} className={`ws-task-row ${isCompleted ? "completed" : ""}`} onClick={() => onOpenTask(task)} aria-label={`${task.id}: ${task.title}. Открыть подробности`}>
                <span className="ws-task-summary"><span className="ws-task-id">{task.id}</span><strong>{task.title}</strong><span className="ws-task-excerpt">{task.result}</span></span>
                <span className={`ws-priority ${task.priority === "P1" ? "secondary" : ""}`}>{task.priority}</span>
                <time dateTime={isCompleted ? task.completedAt : task.due}>{formatDate(isCompleted ? task.completedAt : task.due)}</time><ChevronRight size={17} />
              </button>
            ))}
          </section>
        ))}
        {!results.length && <div className="ws-empty"><Search size={24} /><h3>Задачи не найдены</h3><p>Попробуйте другой запрос или выберите все типы.</p><button className="ws-button" onClick={() => { if (isCompleted) showCompleted(); else changeType("all"); }}>Сбросить фильтры</button></div>}
        <div className="ws-catalog-pagination"><Pagination page={currentPage} pageCount={pageCount} onChange={changePage} /></div>
        <div className="ws-catalog-foot"><span>P0 — обязательно для сдачи · P1 — расширение базовой функции</span><span>Сроки уточняются по результатам работы.</span></div>
      </div>
    </div>
  );
}

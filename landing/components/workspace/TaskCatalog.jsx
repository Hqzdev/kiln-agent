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

export default function TaskCatalog({ onOpenTask, status = "active", type = "all", stream = "all", onScopeChange }) {
  const [query, setQuery] = useState("");
  const [epic, setEpic] = useState("all");
  const [page, setPage] = useState(1);
  const contentRef = useRef(null);
  const isCompleted = status === "completed";
  const activeStream = projectPlan.getStream(stream);
  const scopedTasks = activeStream ? projectPlan.getTasksForStream(activeStream) : projectPlan.getTasksForStatus(status);
  const availableTypes = projectPlan.types.filter((item) => projectPlan.tasks.some((task) => task.type === item.id));
  const results = projectPlan.findTasks({ type, epic, stream, query, status });
  const pageCount = Math.max(1, Math.ceil(results.length / PAGE_SIZE));
  const currentPage = Math.min(page, pageCount);
  const visibleTasks = results.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);
  const groups = type === "all" && !isCompleted
    ? [{ id: "execution-order", label: "Порядок выполнения", owner: "Сначала предыдущие задачи, затем зависящие от них", tasks: visibleTasks }]
    : visibleTasks.reduce((items, task) => {
    const previous = items.at(-1);
    if (previous?.epicId === task.epicId) previous.tasks.push(task);
    else items.push({ id: `${task.epicId}-${task.planOrder}`, epicId: task.epicId, label: task.epicTitle, owner: projectPlan.getType(task.type).owner, tasks: [task] });
    return items;
  }, []);
  const activeType = projectPlan.getType(type);
  const availableEpics = projectPlan.epics.filter((item) => scopedTasks.some((task) => task.epicId === item.id && (type === "all" || task.type === type)));
  const changeType = (value) => { setEpic("all"); setQuery(""); setPage(1); onScopeChange({ status: value === "architecture" ? "all" : "active", type: value }); };
  const showCompleted = () => { setEpic("all"); setQuery(""); setPage(1); onScopeChange({ status: "completed", type: "all" }); };
  const changeQuery = (value) => { setQuery(value); setPage(1); };
  const changePage = (value) => { setPage(value); contentRef.current?.scrollIntoView({ block: "start", behavior: "auto" }); };

  return (
    <div className="ws-catalog">
      <aside className="ws-type-sidebar" aria-label="Типы задач">
        <div className="ws-sidebar-title"><ListFilter size={14} /> ТИП ЗАДАЧИ</div>
        <div className="ws-type-list">
          <button aria-pressed={!activeStream && !isCompleted && type === "all"} className={!activeStream && !isCompleted && type === "all" ? "selected" : ""} onClick={() => changeType("all")}><span>Все задачи</span><span>{projectPlan.remainingTasks.length}</span></button>
          <button aria-pressed={isCompleted} className={`ws-sidebar-completed ${isCompleted ? "selected" : ""}`} onClick={showCompleted}><span><CircleCheck size={14} />Выполненные</span><span>{projectPlan.completedTasks.length}</span></button>
          {availableTypes.map((item) => (
            <button key={item.id} aria-pressed={!isCompleted && type === item.id} className={!isCompleted && type === item.id ? "selected" : ""} onClick={() => changeType(item.id)}><span>{item.label}</span><span>{projectPlan.getTasksForType(item.id, { status: item.id === "architecture" ? "all" : "active" }).length}</span></button>
          ))}
        </div>
        <div className="ws-slice-note"><span>ПОЛНЫЙ ПЛАН РЕАЛИЗАЦИИ</span><p>{projectPlan.tasks.length} подзадач в {projectPlan.epics.length} блоках. Каждая связана с ТЗ и roadmap.</p><a href="/implementation-plan.md" download>Скачать порядок работ <ArrowUpRight size={13} /></a><a href="/BLOT_TECHNICAL_SPECIFICATION.md" download>Скачать ТЗ <ArrowUpRight size={13} /></a></div>
      </aside>
      <div className="ws-task-content" ref={contentRef}>
        <div className="ws-task-toolbar">
          <div><h2>{activeStream?.title || (isCompleted ? "Выполненные задачи" : activeType?.label || "План реализации")}</h2><p>{activeStream ? "Все задачи выбранного блока, включая выполненные." : isCompleted ? "Готовые результаты со ссылками на документы и проверку." : activeType?.description || "Выполняйте сверху вниз: зависимости идут раньше задач, которые их используют."}</p></div>
          <div className="ws-search"><Search size={16} /><input id="ws-task-search" type="search" aria-label="Поиск задач, экранов и файлов" placeholder="Задача, экран или файл…" value={query} onChange={(event) => changeQuery(event.target.value)} />{query && <button aria-label="Очистить поиск" onClick={() => changeQuery("")}><X size={15} /></button>}</div>
        </div>
        <div className="ws-catalog-controls"><div className="ws-epic-filter">Блок <CatalogSelect label="Блок реализации" value={epic} onChange={(value) => { setEpic(value); setPage(1); }} options={[{ value: "all", label: "Все блоки" }, ...availableEpics.map((item) => ({ value: item.id, label: `${item.id} · ${item.title}` }))]} /></div><Pagination page={currentPage} pageCount={pageCount} onChange={changePage} /></div>
        <div className={`ws-list-meta ${isCompleted ? "completed" : ""}`}><span aria-live="polite">{results.length} из {scopedTasks.length} задач{results.length > PAGE_SIZE && ` · показаны ${(currentPage - 1) * PAGE_SIZE + 1}–${Math.min(currentPage * PAGE_SIZE, results.length)}`}</span><span>{status === "all" ? `${results.filter((task) => task.status === "completed").length} из ${results.length} выполнено` : <>{isCompleted ? <Check size={12} /> : <i />}{isCompleted ? "Выполнено" : "Запланировано"}</>}</span></div>
        <div className="ws-column-labels"><span>ЗАДАЧА / {isCompleted ? "ГОТОВЫЙ" : "ОЖИДАЕМЫЙ"} РЕЗУЛЬТАТ</span><span>ПРИОРИТЕТ</span><span>{status === "all" ? "ГОТОВО / СРОК" : isCompleted ? "ГОТОВО" : "ДЕДЛАЙН"}</span><span /></div>
        {groups.map((group) => (
          <section key={group.id} className="ws-task-group" aria-labelledby={`type-${group.id}`}>
            <div className="ws-group-heading"><h3 id={`type-${group.id}`}>{group.label}<span>{group.tasks.length}</span></h3><span>{group.owner}</span></div>
            {group.tasks.map((task) => {
              const unfinished = projectPlan.getUnfinishedDependencies(task);
              const readiness = unfinished.length ? `Сначала: ${unfinished.map((item) => item.id).join(", ")}` : "Можно начать";
              return (
              <button key={task.id} className={`ws-task-row ${task.status === "completed" ? "completed" : ""}`} onClick={() => onOpenTask(task)} aria-label={`${task.id}: ${task.title}. ${task.status === "completed" ? "Выполнено. " : ""}Открыть подробности`}>
                <span className="ws-task-summary"><span className="ws-task-id">{task.id}</span><strong>{task.planOrder}. {task.title}</strong><span className="ws-task-excerpt">{task.status === "completed" && <span className="ws-task-completion"><Check size={12} /> Выполнено</span>}{task.status !== "completed" && <span className="ws-task-readiness">{readiness} · </span>}{task.result}</span></span>
                <span className={`ws-priority ${task.priority === "P1" ? "secondary" : ""}`}>{task.priority}</span>
                <time dateTime={task.status === "completed" ? task.completedAt : task.due}>{formatDate(task.status === "completed" ? task.completedAt : task.due)}</time><ChevronRight size={17} />
              </button>
              );
            })}
          </section>
        ))}
        {!results.length && <div className="ws-empty"><Search size={24} /><h3>Задачи не найдены</h3><p>Попробуйте другой запрос или выберите все типы.</p><button className="ws-button" onClick={() => { if (isCompleted) showCompleted(); else changeType("all"); }}>Сбросить фильтры</button></div>}
        <div className="ws-catalog-pagination"><Pagination page={currentPage} pageCount={pageCount} onChange={changePage} /></div>
        <div className="ws-catalog-foot"><span>P0 — обязательно для сдачи · P1 — расширение базовой функции</span><span>Независимые задачи можно выполнять параллельно; срок не отменяет зависимость.</span></div>
      </div>
    </div>
  );
}

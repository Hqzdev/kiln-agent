"use client";

import { useEffect, useRef } from "react";
import { X, ArrowRight, Check, FlaskConical, FileCode2, ArrowDownToLine } from "lucide-react";
import { projectPlan } from "@/lib/workspace/data.mjs";
import { formatDate } from "@/lib/workspace/project-plan.mjs";

function DetailList({ title, items, icon: Icon }) {
  return <section className="ws-detail-section"><h3>{Icon && <Icon size={16} />}{title}</h3><ul>{items.map((item) => <li key={item}>{item}</li>)}</ul></section>;
}

function RelatedTasks({ tasks, onOpenTask }) {
  return <div className="ws-dependencies">{tasks.map((task) => task.status === "completed"
    ? <div className="ws-related-completed" key={task.id}><span className="ws-task-id">{task.id}</span><span>{task.title}</span><span><Check size={12} />Выполнено</span></div>
    : <button key={task.id} onClick={() => onOpenTask(task)}><span className="ws-task-id">{task.id}</span><span>{task.title}</span><ArrowRight size={15} /></button>)}</div>;
}

export default function TaskDetail({ task, onClose, onOpenTask }) {
  const dialogRef = useRef(null);
  const type = task && projectPlan.getType(task.type);
  const relatedPackages = task?.workPackageIds?.map((id) => projectPlan.getTask(id)) || [];
  const subtasks = task && !task.epicId ? projectPlan.getTasksForPackage(task.id) : [];
  const stream = task?.streamId && projectPlan.getStream(task.streamId);
  const completed = task?.status === "completed";
  const unfinished = task ? projectPlan.getUnfinishedDependencies(task) : [];

  useEffect(() => {
    const dialog = dialogRef.current;
    if (task && !dialog.open) dialog.showModal();
    if (!task && dialog.open) dialog.close();
    if (task) dialog.scrollTop = 0;
  }, [task]);

  useEffect(() => {
    if (!task) return;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => { document.body.style.overflow = previousOverflow; };
  }, [Boolean(task)]);

  return (
    <dialog className="ws-task-dialog" ref={dialogRef} aria-labelledby="ws-detail-title" onCancel={(event) => { event.preventDefault(); onClose(); }} onClick={(event) => { if (event.target === dialogRef.current) { const rect = event.currentTarget.getBoundingClientRect(); if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) onClose(); } }}>
      {task && <>
        <div className="ws-dialog-top"><span className="ws-task-id">{task.id} / {task.epicId ? type.label : "Пакет работ"}</span><button autoFocus aria-label="Закрыть задачу" onClick={onClose}><X size={20} /></button></div>
        <div className="ws-dialog-body">
          <div className={`ws-detail-meta ${completed ? "completed" : ""}`}><span>{completed ? <Check size={12} /> : <i />}{completed ? "Выполнено" : unfinished.length ? "Ожидает зависимостей" : "Можно начать"}</span><span>{task.priority}</span><span>{completed ? `Готово ${formatDate(task.completedAt, { year: "numeric" })}` : `До ${formatDate(task.due, { year: "numeric" })}`}</span></div>
          {task.planOrder && <p className="ws-detail-caption">Шаг {task.planOrder} из {projectPlan.tasks.length} · {unfinished.length ? `Сначала завершите: ${unfinished.map((item) => item.id).join(", ")}` : completed ? "Результат уже подтверждён." : "Все зависимости выполнены. Можно начинать параллельно с другими готовыми задачами."}</p>}
          <h2 id="ws-detail-title">{task.title}</h2><p className="ws-detail-goal">{task.goal}</p>
          {task.deliverables?.length > 0 && <section className="ws-document-results"><h3>{completed ? "Готовый результат" : "Подготовленные документы"}</h3><p>{task.documentationSummary}</p>{task.deliverables.map((artifact) => <div key={artifact.id}><a href={artifact.href}><FileCode2 size={15} /><span>{artifact.path}</span><ArrowRight size={14} /></a><a href={artifact.downloadUrl} download aria-label={`Скачать ${artifact.title}`}><ArrowDownToLine size={15} /></a></div>)}{completed && <a className="ws-review-document" href={task.completionEvidence.href}>Протокол проверки документов <ArrowRight size={13} /></a>}</section>}
          <div className="ws-detail-result"><span>ЧТО ПОЛУЧАЕМ В ИТОГЕ</span><p>{task.result}</p></div>
          <div className="ws-detail-owner"><span>Роль исполнителя</span><strong>{type.owner}</strong></div>
          {stream && <div className="ws-detail-owner ws-detail-roadmap"><span>Блок roadmap</span><strong>{stream.title}</strong></div>}
          {task.writingGuide && <section className="ws-detail-section"><h3>{["document", "design", "verification", "configuration", "release"].includes(task.implementationKind) ? "Что конкретно сделать" : "Что конкретно написать"}</h3><p className="ws-detail-caption">{task.writingGuide}</p></section>}
          <section className="ws-detail-section"><h3>Экраны и поверхности</h3><div className="ws-screen-tags">{task.screens.map((screen) => <span key={screen}>{screen}</span>)}</div></section>
          <section className="ws-detail-section"><h3><FileCode2 size={16} /> Файлы и ответственность</h3><p className="ws-detail-caption">{task.deliverables?.length ? "Подготовленные MD доступны выше. Остальные файлы относятся к реализации задачи." : "Предложенные пути будущего продукта. Создаём при реализации задачи."}</p><div className="ws-file-list">{task.files.map((file) => <div key={file.path}><code>{file.path}</code><p>{file.purpose}</p></div>)}</div></section>
          <section className="ws-detail-section"><h3>Как выполнить и проверить</h3><ol className="ws-steps">{task.steps.map((step, index) => <li key={step}><span>{String(index + 1).padStart(2, "0")}</span><p>{step}</p></li>)}</ol></section>
          <DetailList title="Критерии готовности" items={task.acceptance} icon={Check} />
          <DetailList title={completed ? "Проверка результата" : "Что тестируем"} items={completed ? task.completionChecks : task.tests} icon={FlaskConical} />
          <section className="ws-detail-section"><h3>Зависимости</h3>{task.dependencies.length ? <RelatedTasks tasks={task.dependencies.map((id) => projectPlan.getTask(id))} onOpenTask={onOpenTask} /> : <p className="ws-detail-caption">Можно начать без других задач каталога.</p>}</section>
          {relatedPackages.length > 0 && <section className="ws-detail-section"><h3>Подробный план пакета работ</h3><RelatedTasks tasks={relatedPackages} onOpenTask={onOpenTask} /></section>}
          {subtasks.length > 0 && <section className="ws-detail-section"><h3>Подзадачи пакета · {subtasks.length}</h3><RelatedTasks tasks={subtasks} onOpenTask={onOpenTask} /></section>}
          <div className="ws-detail-coverage"><span>Пункты полного ТЗ</span><code>{task.covers.join(" · ")}</code></div>
        </div>
      </>}
    </dialog>
  );
}

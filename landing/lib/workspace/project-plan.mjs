export class ProjectPlan {
  #types;
  #tasks;
  #streams;
  #workPackages;
  #epics;
  #index;

  constructor({ types, tasks, streams, workPackages = [], epics = [] }) {
    this.#types = freeze(types);
    this.#tasks = freeze(tasks);
    this.#streams = freeze(streams);
    this.#workPackages = freeze(workPackages);
    this.#epics = freeze(epics);
    const entries = [...tasks, ...workPackages];
    this.#index = new Map(entries.map((task) => [task.id, task]));
    if (this.#index.size !== entries.length) throw new Error("Task identifiers must be unique.");
    for (const task of entries) {
      if (!["planned", "completed"].includes(task.status)) throw new Error(`Unknown task status: ${task.id}`);
      if (task.status === "completed" && (!task.completedAt || !task.deliverables?.length)) throw new Error(`Missing completion evidence: ${task.id}`);
      if (!types.some((type) => type.id === task.type)) throw new Error(`Unknown task type: ${task.type}`);
      if (task.dependencies.some((id) => !this.#index.has(id))) throw new Error(`Unknown dependency in ${task.id}`);
      if (task.workPackageIds?.some((id) => !workPackages.some((item) => item.id === id))) throw new Error(`Unknown work package in ${task.id}`);
    }
    for (const stream of streams) if (stream.taskIds.some((id) => !this.#index.has(id))) throw new Error(`Unknown roadmap task in ${stream.id}`);
  }

  get types() { return this.#types; }
  get tasks() { return this.#tasks; }
  get streams() { return this.#streams; }
  get workPackages() { return this.#workPackages; }
  get epics() { return this.#epics; }
  get completedTasks() { return this.#tasks.filter((task) => task.status === "completed"); }
  get remainingTasks() { return this.#tasks.filter((task) => task.status !== "completed"); }
  getTask(id) { return this.#index.get(id); }
  getType(id) { return this.#types.find((type) => type.id === id); }
  getTasksForStatus(status = "all") { return status === "completed" ? this.completedTasks : status === "active" ? this.remainingTasks : this.#tasks; }
  getTasksForType(type, { status = "all" } = {}) { return this.getTasksForStatus(status).filter((task) => task.type === type); }
  getTasksForStream(stream) { return this.#tasks.filter((task) => stream.taskIds.includes(task.id)); }
  getTasksForPackage(id) { return this.#tasks.filter((task) => task.workPackageIds.includes(id)); }
  getStream(id) { return this.#streams.find((stream) => stream.id === id); }

  findTasks({ type = "all", epic = "all", stream = "all", query = "", status = "all" } = {}) {
    const terms = query.toLocaleLowerCase("ru").trim().split(/\s+/).filter(Boolean);
    return this.getTasksForStatus(status).filter((task) => {
      if (type !== "all" && task.type !== type) return false;
      if (epic !== "all" && task.epicId !== epic) return false;
      if (stream !== "all" && task.streamId !== stream) return false;
      const text = [task.id, task.title, task.goal, task.result, task.epicTitle, ...task.workPackageIds, this.getType(task.type).label, ...task.screens, ...task.files.map((file) => `${file.path} ${file.purpose}`)].join(" ").toLocaleLowerCase("ru");
      return terms.every((term) => text.includes(term));
    }).sort((a, b) => this.#types.findIndex((type) => type.id === a.type) - this.#types.findIndex((type) => type.id === b.type));
  }
}

function freeze(value) {
  if (value && typeof value === "object" && !Object.isFrozen(value)) {
    Object.values(value).forEach(freeze);
    Object.freeze(value);
  }
  return value;
}

export function formatDate(date, options = {}) {
  return new Intl.DateTimeFormat("ru-RU", { day: "numeric", month: "short", timeZone: "Asia/Yekaterinburg", ...options }).format(new Date(`${date}T12:00:00Z`));
}

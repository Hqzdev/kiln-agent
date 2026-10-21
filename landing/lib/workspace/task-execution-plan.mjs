// Prerequisites always precede their consumers. Importance selects among independent tasks.
const epicOrder = ["P0", "A2", "J3", "D1", "J5", "J6", "J4", "J9", "J10", "J12", "J11", "J13", "J7", "J8", "S14", "L23", "M15", "R16", "B17", "G19", "I18", "H20", "E21", "Q22"];

export class TaskExecutionPlan {
  #tasks;

  constructor(tasks) {
    const index = new Map(tasks.map((task) => [task.id, task]));
    if (index.size !== tasks.length) throw new Error("Duplicate task identifiers.");
    const pending = new Map();
    const dependents = new Map(tasks.map((task) => [task.id, []]));
    for (const task of tasks) {
      if (!epicOrder.includes(task.epicId)) throw new Error(`Unknown epic: ${task.epicId}`);
      if (new Set(task.dependencies).size !== task.dependencies.length) throw new Error(`Duplicate dependencies: ${task.id}`);
      pending.set(task.id, task.dependencies.length);
      for (const id of task.dependencies) {
        if (!index.has(id)) throw new Error(`Unknown dependency ${id} in ${task.id}`);
        dependents.get(id).push(task.id);
      }
    }
    const compare = (a, b) => a.priority.localeCompare(b.priority)
      || epicOrder.indexOf(a.epicId) - epicOrder.indexOf(b.epicId)
      || Number(a.id.split(".")[1]) - Number(b.id.split(".")[1]);
    const ready = tasks.filter((task) => pending.get(task.id) === 0);
    const ordered = [];
    while (ready.length) {
      ready.sort(compare);
      const task = ready.shift();
      ordered.push(Object.freeze({ ...task, planOrder: ordered.length + 1 }));
      for (const id of dependents.get(task.id)) {
        pending.set(id, pending.get(id) - 1);
        if (pending.get(id) === 0) ready.push(index.get(id));
      }
    }
    if (ordered.length !== tasks.length) {
      throw new Error(`Dependency cycle: ${tasks.filter((task) => pending.get(task.id) > 0).map((task) => task.id).join(", ")}`);
    }
    this.#tasks = Object.freeze(ordered);
  }

  get tasks() { return this.#tasks; }
}

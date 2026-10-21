import test from "node:test";
import assert from "node:assert/strict";
import { TaskExecutionPlan } from "./task-execution-plan.mjs";
import { projectPlan } from "./data.mjs";

const task = (id, dependencies = [], priority = "P0") => ({ id, epicId: id.split(".")[0], dependencies, priority });

test("prerequisites override importance and supplied order", () => {
  const tasks = new TaskExecutionPlan([task("J3.1", ["A2.4"]), task("A2.4", [], "P1")]).tasks;
  assert.deepEqual(tasks.map((item) => item.id), ["A2.4", "J3.1"]);
});

test("independent required tasks precede optional extensions", () => {
  const tasks = new TaskExecutionPlan([task("H20.1", [], "P1"), task("J3.1")]).tasks;
  assert.equal(tasks[0].id, "J3.1");
});

test("invalid graphs fail instead of silently dropping tasks", () => {
  assert.throws(() => new TaskExecutionPlan([task("J3.1", ["missing"])]), /Unknown dependency/);
  assert.throws(() => new TaskExecutionPlan([task("J3.1", ["J3.2"]), task("J3.2", ["J3.1"])]), /cycle/);
  assert.throws(() => new TaskExecutionPlan([task("J3.1"), task("J3.1")]), /Duplicate task/);
});

test("complete catalog retains all tasks and places every prerequisite first", () => {
  assert.equal(projectPlan.tasks.length, projectPlan.epics.reduce((sum, epic) => sum + epic.tasks.length, 0));
  assert.equal(new Set(projectPlan.tasks.map((item) => item.id)).size, projectPlan.tasks.length);
  for (const task of projectPlan.tasks) {
    for (const id of task.dependencies) {
      assert.ok(projectPlan.getTask(id).planOrder < task.planOrder, `${id} must precede ${task.id}`);
    }
  }
});

test("filters preserve the plan order and readiness reflects actual completion", () => {
  for (const type of projectPlan.types) {
    const tasks = projectPlan.findTasks({ type: type.id });
    assert.deepEqual(tasks.map((task) => task.id), projectPlan.tasks.filter((task) => task.type === type.id).map((task) => task.id));
  }
  for (const task of projectPlan.remainingTasks) {
    assert.equal(projectPlan.canStart(task), task.dependencies.every((id) => projectPlan.getTask(id).status === "completed"));
  }
  assert.ok(!projectPlan.canStart(projectPlan.getTask("J3.2")));
});

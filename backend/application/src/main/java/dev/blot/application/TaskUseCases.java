package dev.blot.application;

import dev.blot.core.Run;
import dev.blot.core.Task;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

final class TaskUseCases {
  private final UseCaseSupport support;

  TaskUseCases(UseCaseSupport support) {
    this.support = support;
  }

  ApplicationResult<List<Task>> list(UUID runId) {
    if (runId == null) return support.invalid("runId", "must not be null");
    return support.unitOfWork.transact(
        tx -> {
          if (tx.runs().findById(runId).isEmpty())
            return ApplicationResult.failure(new ApplicationError.NotFound("run", runId));
          return ApplicationResult.success(
              tx.tasks().findByRunId(runId).stream()
                  .sorted(Comparator.comparing(Task::createdAt).thenComparing(Task::id))
                  .toList());
        });
  }

  ApplicationResult<Task> create(BlotApplicationService.CreateTask command) {
    if (command == null) return support.invalid("command", "must not be null");
    if (command.projectId() == null || command.runId() == null)
      return support.invalid("projectId/runId", "must not be null");
    if (command.title() == null || command.title().isBlank())
      return support.invalid("title", "must not be blank");
    if (command.acceptanceCriteria() == null || command.acceptanceCriteria().isEmpty())
      return support.invalid("acceptanceCriteria", "must contain at least one criterion");
    if (command.acceptanceCriteria().stream().anyMatch(value -> value == null || value.isBlank()))
      return support.invalid("acceptanceCriteria", "must not contain blank criteria");
    if (command.dependencyIds() == null)
      return support.invalid("dependencyIds", "must not be null");
    if (command.dependencyIds().stream().anyMatch(Objects::isNull))
      return support.invalid("dependencyIds", "must not contain null");
    List<String> criteria = List.copyOf(command.acceptanceCriteria());
    Set<UUID> dependencies = Set.copyOf(command.dependencyIds());
    return support.unitOfWork.transact(
        tx -> {
          Run run = tx.runs().findById(command.runId()).orElse(null);
          if (run == null)
            return ApplicationResult.failure(new ApplicationError.NotFound("run", command.runId()));
          if (!run.projectId().equals(command.projectId()))
            return ApplicationResult.failure(
                new ApplicationError.Conflict(
                    "run", run.id(), "run does not belong to the requested project"));
          for (UUID dependencyId : dependencies) {
            Task dependency = tx.tasks().findById(dependencyId).orElse(null);
            if (dependency == null)
              return ApplicationResult.failure(
                  new ApplicationError.NotFound("task dependency", dependencyId));
            if (!dependency.runId().equals(run.id())
                || !dependency.projectId().equals(run.projectId()))
              return ApplicationResult.failure(
                  new ApplicationError.Conflict(
                      "task dependency", dependencyId, "dependency belongs to another run"));
          }
          UUID taskId = support.newId();
          if (tx.tasks().findById(taskId).isPresent())
            return ApplicationResult.failure(
                new ApplicationError.Conflict("task", taskId, "id already exists"));
          Instant now = support.clock.instant();
          Task task;
          try {
            task =
                new Task(
                    taskId,
                    run.projectId(),
                    run.id(),
                    command.title(),
                    criteria,
                    dependencies,
                    now);
          } catch (IllegalArgumentException exception) {
            return support.invalid("task", exception.getMessage());
          }
          tx.tasks().save(task);
          tx.appendEvent(
              support.event(
                  run.projectId(),
                  run.id(),
                  taskId,
                  0,
                  now,
                  "task.created",
                  Map.of("title", task.title())));
          return ApplicationResult.success(task);
        });
  }
}

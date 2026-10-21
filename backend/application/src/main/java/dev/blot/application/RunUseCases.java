package dev.blot.application;

import dev.blot.application.BlotApplicationService.ChangeRunStatus;
import dev.blot.application.BlotApplicationService.CreateRun;
import dev.blot.application.BlotUnitOfWork.RunRepository;
import dev.blot.core.Run;
import dev.blot.core.RunStatus;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

final class RunUseCases {
  private final UseCaseSupport support;

  RunUseCases(UseCaseSupport support) {
    this.support = support;
  }

  ApplicationResult<Run> create(CreateRun command) {
    if (command == null) {
      return UseCaseSupport.invalid("command", "must not be null");
    }
    if (command.projectId() == null) {
      return UseCaseSupport.invalid("projectId", "must not be null");
    }
    if (command.goal() == null || command.goal().isBlank()) {
      return UseCaseSupport.invalid("goal", "must not be blank");
    }

    return support.unitOfWork.transact(
        transaction -> {
          if (transaction.projects().findById(command.projectId()).isEmpty()) {
            return ApplicationResult.failure(
                new ApplicationError.NotFound("project", command.projectId()));
          }

          RunRepository runs = transaction.runs();
          UUID runId = support.newId();
          if (runs.findById(runId).isPresent()) {
            return ApplicationResult.failure(
                new ApplicationError.Conflict("run", runId, "id already exists"));
          }

          Instant now = support.clock.instant();
          Run run = new Run(runId, command.projectId(), command.goal(), now, RunStatus.DRAFT, 0);
          runs.save(run);
          transaction.appendEvent(
              support.event(
                  run.projectId(),
                  run.id(),
                  run.id(),
                  run.version(),
                  now,
                  "run.created",
                  Map.of("goal", run.goal(), "status", run.status().name())));
          return ApplicationResult.success(run);
        });
  }

  ApplicationResult<Run> get(UUID runId) {
    if (runId == null) {
      return UseCaseSupport.invalid("runId", "must not be null");
    }
    return support.unitOfWork.transact(
        transaction ->
            transaction
                .runs()
                .findById(runId)
                .<ApplicationResult<Run>>map(ApplicationResult::success)
                .orElseGet(
                    () -> ApplicationResult.failure(new ApplicationError.NotFound("run", runId))));
  }

  ApplicationResult<Run> changeStatus(ChangeRunStatus command) {
    if (command == null) {
      return UseCaseSupport.invalid("command", "must not be null");
    }
    if (command.runId() == null || command.status() == null) {
      return UseCaseSupport.invalid("runId/status", "must not be null");
    }
    if (command.expectedVersion() < 0) {
      return UseCaseSupport.invalid("expectedVersion", "must not be negative");
    }

    return support.unitOfWork.transact(
        transaction -> {
          RunRepository runs = transaction.runs();
          Run current = runs.findById(command.runId()).orElse(null);
          if (current == null) {
            return ApplicationResult.failure(new ApplicationError.NotFound("run", command.runId()));
          }
          if (current.version() != command.expectedVersion()) {
            return ApplicationResult.failure(
                new ApplicationError.VersionConflict(
                    "run", current.id(), command.expectedVersion(), current.version()));
          }
          if (!RunTransitions.allows(current.status(), command.status())) {
            return ApplicationResult.failure(
                new ApplicationError.InvalidTransition(
                    current.id(), current.status(), command.status()));
          }

          Instant now = support.clock.instant();
          Run updated =
              new Run(
                  current.id(),
                  current.projectId(),
                  current.goal(),
                  current.createdAt(),
                  command.status(),
                  current.version() + 1);
          runs.save(updated);
          transaction.appendEvent(
              support.event(
                  updated.projectId(),
                  updated.id(),
                  updated.id(),
                  updated.version(),
                  now,
                  "run.status_changed",
                  Map.of("from", current.status().name(), "to", updated.status().name())));
          return ApplicationResult.success(updated);
        });
  }
}

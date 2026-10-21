package dev.blot.application;

import dev.blot.core.Run;
import dev.blot.core.SpecificationRevision;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

final class SpecificationUseCases {
  private final UseCaseSupport support;

  SpecificationUseCases(UseCaseSupport support) {
    this.support = support;
  }

  ApplicationResult<List<SpecificationRevision>> history(UUID runId) {
    if (runId == null) return support.invalid("runId", "must not be null");
    return support.unitOfWork.transact(
        tx -> {
          if (tx.runs().findById(runId).isEmpty())
            return ApplicationResult.failure(new ApplicationError.NotFound("run", runId));
          return ApplicationResult.success(
              tx.specifications().findByRunId(runId).stream()
                  .sorted(Comparator.comparingInt(SpecificationRevision::revision))
                  .toList());
        });
  }

  ApplicationResult<SpecificationRevision> add(
      BlotApplicationService.AddSpecificationRevision command) {
    if (command == null) return support.invalid("command", "must not be null");
    if (command.runId() == null) return support.invalid("runId", "must not be null");
    if (command.content() == null || command.content().isBlank())
      return support.invalid("content", "must not be blank");
    return support.unitOfWork.transact(
        tx -> {
          Run run = tx.runs().findById(command.runId()).orElse(null);
          if (run == null)
            return ApplicationResult.failure(new ApplicationError.NotFound("run", command.runId()));
          var repository = tx.specifications();
          var existing = repository.findByRunId(run.id());
          int revisionNumber =
              existing.stream().mapToInt(SpecificationRevision::revision).max().orElse(0) + 1;
          UUID id = support.newId();
          if (existing.stream().anyMatch(item -> item.id().equals(id)))
            return ApplicationResult.failure(
                new ApplicationError.Conflict("specification revision", id, "id already exists"));
          Instant now = support.clock.instant();
          SpecificationRevision revision;
          try {
            revision =
                new SpecificationRevision(id, run.id(), revisionNumber, command.content(), now);
          } catch (IllegalArgumentException exception) {
            return support.invalid("content", exception.getMessage());
          }
          repository.save(revision);
          tx.appendEvent(
              support.event(
                  run.projectId(),
                  run.id(),
                  id,
                  revisionNumber,
                  now,
                  "specification.revision_created",
                  Map.of("revision", Integer.toString(revisionNumber))));
          return ApplicationResult.success(revision);
        });
  }
}

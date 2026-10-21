package dev.blot.application;

import dev.blot.core.Project;
import dev.blot.core.Run;
import dev.blot.core.SpecificationRevision;
import dev.blot.core.Task;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;

/**
 * Transaction boundary for application state and its durable event outbox. Implementations must
 * provide isolation that prevents lost updates and duplicate revision numbers. All repository
 * writes and appended events commit together; an exception from the operation rolls everything
 * back. Event delivery happens after commit, never from inside the transaction.
 */
public interface BlotUnitOfWork {

  /** Executes one application operation with atomic state and outbox persistence. */
  <T> T transact(Function<Transaction, T> operation);

  interface Transaction {
    ProjectRepository projects();

    RunRepository runs();

    SpecificationRevisionRepository specifications();

    TaskRepository tasks();

    /** Appends to a durable outbox; delivery happens only after this transaction commits. */
    void appendEvent(ApplicationEvent event);
  }

  interface ProjectRepository {
    Optional<Project> findById(UUID projectId);

    void save(Project project);
  }

  interface RunRepository {
    Optional<Run> findById(UUID runId);

    void save(Run run);
  }

  interface SpecificationRevisionRepository {
    List<SpecificationRevision> findByRunId(UUID runId);

    void save(SpecificationRevision revision);
  }

  interface TaskRepository {
    Optional<Task> findById(UUID taskId);

    List<Task> findByRunId(UUID runId);

    void save(Task task);
  }
}

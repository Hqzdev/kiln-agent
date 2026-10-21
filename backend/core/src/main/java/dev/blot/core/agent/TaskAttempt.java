package dev.blot.core.agent;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

public record TaskAttempt(
    UUID id,
    UUID projectId,
    UUID runId,
    UUID taskId,
    UUID assignmentId,
    UUID sessionId,
    int attemptNumber,
    TaskAttemptStatus status,
    Optional<UUID> artifactId,
    Optional<String> resultDigest,
    Instant createdAt,
    Instant updatedAt,
    long version) {

  public TaskAttempt {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(projectId, "projectId");
    Objects.requireNonNull(runId, "runId");
    Objects.requireNonNull(taskId, "taskId");
    Objects.requireNonNull(assignmentId, "assignmentId");
    Objects.requireNonNull(sessionId, "sessionId");
    Objects.requireNonNull(status, "status");
    Objects.requireNonNull(artifactId, "artifactId");
    Objects.requireNonNull(resultDigest, "resultDigest");
    Objects.requireNonNull(createdAt, "createdAt");
    Objects.requireNonNull(updatedAt, "updatedAt");

    resultDigest = resultDigest.map(String::strip);

    if (attemptNumber < 1) {
      throw new IllegalArgumentException("attemptNumber must be at least 1");
    }
    if (updatedAt.isBefore(createdAt)) {
      throw new IllegalArgumentException("updatedAt must not precede createdAt");
    }
    if (version < 0) {
      throw new IllegalArgumentException("version must not be negative");
    }

    boolean submitted =
        status == TaskAttemptStatus.SUBMITTED
            || status == TaskAttemptStatus.IN_REVIEW
            || status == TaskAttemptStatus.CHANGES_REQUESTED
            || status == TaskAttemptStatus.ACCEPTED;

    if (submitted && (artifactId.isEmpty() || resultDigest.isEmpty())) {
      throw new IllegalArgumentException(
          "Submitted attempts must reference an artifact and its digest");
    }
    if (resultDigest.filter(String::isEmpty).isPresent()) {
      throw new IllegalArgumentException("resultDigest must not be blank");
    }
  }
}

package dev.blot.core.agent;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

public record AgentAssignment(
    UUID id,
    UUID projectId,
    UUID runId,
    UUID taskId,
    UUID profileId,
    Optional<UUID> sessionId,
    AssignmentStatus status,
    Instant createdAt,
    long version) {

  public AgentAssignment {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(projectId, "projectId");
    Objects.requireNonNull(runId, "runId");
    Objects.requireNonNull(taskId, "taskId");
    Objects.requireNonNull(profileId, "profileId");
    Objects.requireNonNull(sessionId, "sessionId");
    Objects.requireNonNull(status, "status");
    Objects.requireNonNull(createdAt, "createdAt");

    if (status == AssignmentStatus.ACTIVE && sessionId.isEmpty()) {
      throw new IllegalArgumentException("An active assignment must have a session");
    }
    if (version < 0) {
      throw new IllegalArgumentException("version must not be negative");
    }
  }
}

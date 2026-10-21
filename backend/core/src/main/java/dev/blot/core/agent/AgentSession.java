package dev.blot.core.agent;

import java.time.Instant;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

public record AgentSession(
    UUID id,
    UUID projectId,
    UUID runId,
    UUID profileId,
    long profileVersion,
    String instructionKey,
    int instructionRevision,
    Set<AgentCapability> grantedCapabilities,
    AgentSessionStatus status,
    Instant createdAt,
    Instant updatedAt,
    long version) {

  public AgentSession {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(projectId, "projectId");
    Objects.requireNonNull(runId, "runId");
    Objects.requireNonNull(profileId, "profileId");
    Objects.requireNonNull(instructionKey, "instructionKey");
    Objects.requireNonNull(grantedCapabilities, "grantedCapabilities");
    Objects.requireNonNull(status, "status");
    Objects.requireNonNull(createdAt, "createdAt");
    Objects.requireNonNull(updatedAt, "updatedAt");

    instructionKey = instructionKey.strip();
    grantedCapabilities = Set.copyOf(grantedCapabilities);

    if (instructionKey.isEmpty()) {
      throw new IllegalArgumentException("instructionKey must not be blank");
    }
    if (profileVersion < 1 || instructionRevision < 1) {
      throw new IllegalArgumentException("Profile and instruction versions must be positive");
    }
    if (updatedAt.isBefore(createdAt)) {
      throw new IllegalArgumentException("updatedAt must not precede createdAt");
    }
    if (version < 0) {
      throw new IllegalArgumentException("version must not be negative");
    }
  }
}

package dev.blot.core.agent;

import java.util.Objects;
import java.util.Set;
import java.util.UUID;

public record AgentProfile(
    UUID id,
    String key,
    String displayName,
    AgentRole role,
    String modelId,
    String instructionKey,
    int instructionRevision,
    Set<AgentCapability> capabilities,
    boolean enabled,
    long version) {

  public AgentProfile {
    Objects.requireNonNull(id, "id must not be null");
    Objects.requireNonNull(key, "key must not be null");
    Objects.requireNonNull(displayName, "displayName must not be null");
    Objects.requireNonNull(role, "role must not be null");
    Objects.requireNonNull(modelId, "modelId must not be null");
    Objects.requireNonNull(instructionKey, "instructionKey must not be null");
    Objects.requireNonNull(capabilities, "capabilities must not be null");

    key = key.strip();
    displayName = displayName.strip();
    modelId = modelId.strip();
    instructionKey = instructionKey.strip();
    capabilities = Set.copyOf(capabilities);

    if (key.isEmpty() || displayName.isEmpty() || modelId.isEmpty() || instructionKey.isEmpty()) {
      throw new IllegalArgumentException("Profile text fields must not be blank");
    }
    if (instructionRevision < 1) {
      throw new IllegalArgumentException("instructionRevision must be at least 1");
    }
    if (version < 1) {
      throw new IllegalArgumentException("version must be at least 1");
    }
  }
}

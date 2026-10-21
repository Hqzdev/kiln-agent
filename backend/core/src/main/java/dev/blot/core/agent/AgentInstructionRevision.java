package dev.blot.core.agent;

import java.time.Instant;
import java.util.Objects;

public record AgentInstructionRevision(
    String key, int revision, AgentRole role, String content, Instant createdAt) {

  public AgentInstructionRevision {
    Objects.requireNonNull(key, "key");
    Objects.requireNonNull(role, "role");
    Objects.requireNonNull(content, "content");
    Objects.requireNonNull(createdAt, "createdAt");

    key = key.strip();
    content = content.strip();

    if (key.isEmpty()) {
      throw new IllegalArgumentException("key must not be blank");
    }
    if (revision < 1) {
      throw new IllegalArgumentException("revision must be at least 1");
    }
    if (content.isEmpty()) {
      throw new IllegalArgumentException("content must not be blank");
    }
  }
}

package dev.blot.core;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public record SpecificationRevision(
    UUID id, UUID runId, int revision, String content, Instant createdAt) {
  public SpecificationRevision {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(runId, "runId");
    Objects.requireNonNull(content, "content");
    Objects.requireNonNull(createdAt, "createdAt");

    content = content.strip();
    if (content.isEmpty()) {
      throw new IllegalArgumentException("content must not be blank");
    }
    if (revision < 1) {
      throw new IllegalArgumentException("revision must be at least 1");
    }
  }
}

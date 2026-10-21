package dev.blot.application;

import java.time.Instant;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

/**
 * Immutable event draft stored in the same transaction as its state change. The infrastructure
 * adapter assigns the monotonic sequence number when writing this draft to the outbox.
 */
public record ApplicationEvent(
    UUID eventId,
    UUID projectId,
    UUID runId,
    UUID entityId,
    int schemaVersion,
    long entityVersion,
    Instant occurredAt,
    String type,
    Map<String, String> payload) {

  public ApplicationEvent {
    Objects.requireNonNull(eventId, "eventId");
    Objects.requireNonNull(projectId, "projectId");
    Objects.requireNonNull(entityId, "entityId");
    Objects.requireNonNull(occurredAt, "occurredAt");
    Objects.requireNonNull(type, "type");
    Objects.requireNonNull(payload, "payload");
    if (schemaVersion < 1) {
      throw new IllegalArgumentException("schemaVersion must be at least 1");
    }
    if (entityVersion < 0) {
      throw new IllegalArgumentException("entityVersion must not be negative");
    }
    type = type.strip();
    if (type.isEmpty()) {
      throw new IllegalArgumentException("type must not be blank");
    }
    payload = Map.copyOf(payload);
  }
}

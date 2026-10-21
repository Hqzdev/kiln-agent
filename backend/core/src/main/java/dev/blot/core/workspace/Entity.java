package dev.blot.core.workspace;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

/** Общие данные записи не зависят от способа хранения. */
public record Entity<T>(
    UUID id,
    UUID ownerId,
    UUID projectId,
    UUID parentId,
    long version,
    Instant createdAt,
    Instant updatedAt,
    T data) {
  public Entity {
    Objects.requireNonNull(id);
    Objects.requireNonNull(ownerId);
    Objects.requireNonNull(createdAt);
    Objects.requireNonNull(updatedAt);
    Objects.requireNonNull(data);
    if (version < 0) throw new IllegalArgumentException("Отрицательная версия");
  }

  public Entity<T> change(T value, Instant now) {
    return new Entity<>(id, ownerId, projectId, parentId, version + 1, createdAt, now, value);
  }
}

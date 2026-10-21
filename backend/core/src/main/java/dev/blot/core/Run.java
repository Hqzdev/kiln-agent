package dev.blot.core;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public record Run(
    UUID id, UUID projectId, String goal, Instant createdAt, RunStatus status, long version) {

  public Run {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(projectId, "projectId");
    Objects.requireNonNull(goal, "goal");
    Objects.requireNonNull(createdAt, "createdAt");
    Objects.requireNonNull(status, "status");

    goal = goal.strip();

    if (goal.isEmpty()) {
      throw new IllegalArgumentException("Цель не может быть пустой");
    }

    if (version < 0) {
      throw new IllegalArgumentException("Версия не может быть отрицательной");
    }
  }
}

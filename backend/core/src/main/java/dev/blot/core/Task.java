package dev.blot.core;

import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

public record Task(
    UUID id,
    UUID projectId,
    UUID runId,
    String title,
    List<String> acceptanceCriteria,
    Set<UUID> dependencyIds,
    Instant createdAt) {
  public Task {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(projectId, "projectId");
    Objects.requireNonNull(runId, "runId");
    Objects.requireNonNull(title, "title");
    Objects.requireNonNull(acceptanceCriteria, "acceptanceCriteria");
    Objects.requireNonNull(dependencyIds, "dependencyIds");
    Objects.requireNonNull(createdAt, "createdAt");

    title = title.strip();

    if (title.isEmpty()) {
      throw new IllegalArgumentException("Название задачи не может быть пустым");
    }

    acceptanceCriteria =
        acceptanceCriteria.stream()
            .map(criterion -> Objects.requireNonNull(criterion, "acceptanceCriterion").strip())
            .toList();

    if (acceptanceCriteria.isEmpty() || acceptanceCriteria.stream().anyMatch(String::isEmpty)) {
      throw new IllegalArgumentException("Нужно указать непустые условия готовности");
    }

    dependencyIds = Set.copyOf(dependencyIds);

    if (dependencyIds.contains(id)) {
      throw new IllegalArgumentException("Задача не может зависеть от самой себя");
    }
  }
}

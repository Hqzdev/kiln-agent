package dev.blot.core;

import java.nio.file.Path;
import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public record Project(UUID id, String name, Path repositoryPath, Instant createdAt) {
  public Project {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(name, "name");
    Objects.requireNonNull(repositoryPath, "repositoryPath");
    Objects.requireNonNull(createdAt, "createdAt");

    name = name.strip();

    if (name.isEmpty()) {
      throw new IllegalArgumentException("Название проекта не может быть пустым");
    }

    if (!repositoryPath.isAbsolute()) {
      throw new IllegalArgumentException("Путь к репозиторию должен быть абсолютным");
    }

    repositoryPath = repositoryPath.normalize();
  }
}

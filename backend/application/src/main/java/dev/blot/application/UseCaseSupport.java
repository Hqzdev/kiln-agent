package dev.blot.application;

import java.time.Clock;
import java.time.Instant;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Supplier;

final class UseCaseSupport {
  final BlotUnitOfWork unitOfWork;
  final Clock clock;
  private final Supplier<UUID> idGenerator;

  UseCaseSupport(BlotUnitOfWork unitOfWork, Clock clock, Supplier<UUID> idGenerator) {
    this.unitOfWork = Objects.requireNonNull(unitOfWork, "unitOfWork");
    this.clock = Objects.requireNonNull(clock, "clock");
    this.idGenerator = Objects.requireNonNull(idGenerator, "idGenerator");
  }

  UUID newId() {
    return Objects.requireNonNull(idGenerator.get(), "generated id");
  }

  ApplicationEvent event(
      UUID projectId,
      UUID runId,
      UUID entityId,
      long entityVersion,
      Instant occurredAt,
      String type,
      Map<String, String> payload) {
    return new ApplicationEvent(
        newId(), projectId, runId, entityId, 1, entityVersion, occurredAt, type, payload);
  }

  static <T> ApplicationResult<T> invalid(String field, String reason) {
    return ApplicationResult.failure(new ApplicationError.Validation(field, reason));
  }
}

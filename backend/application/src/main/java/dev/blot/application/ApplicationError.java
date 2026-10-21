package dev.blot.application;

import dev.blot.core.RunStatus;
import java.util.UUID;

public sealed interface ApplicationError
    permits ApplicationError.NotFound,
        ApplicationError.VersionConflict,
        ApplicationError.InvalidTransition,
        ApplicationError.Conflict,
        ApplicationError.Validation {

  record NotFound(String resource, UUID id) implements ApplicationError {}

  record VersionConflict(String resource, UUID id, long expected, long actual)
      implements ApplicationError {}

  record InvalidTransition(UUID runId, RunStatus from, RunStatus to) implements ApplicationError {}

  record Conflict(String resource, UUID id, String reason) implements ApplicationError {}

  record Validation(String field, String reason) implements ApplicationError {}
}

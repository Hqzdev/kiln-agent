package dev.blot.application;

import java.util.Objects;

public sealed interface ApplicationResult<T>
    permits ApplicationResult.Success, ApplicationResult.Failure {

  record Success<T>(T value) implements ApplicationResult<T> {
    public Success {
      Objects.requireNonNull(value, "value");
    }
  }

  record Failure<T>(ApplicationError error) implements ApplicationResult<T> {
    public Failure {
      Objects.requireNonNull(error, "error");
    }
  }

  static <T> ApplicationResult<T> success(T value) {
    return new Success<>(value);
  }

  static <T> ApplicationResult<T> failure(ApplicationError error) {
    return new Failure<>(error);
  }
}

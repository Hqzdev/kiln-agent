package dev.blot.api;

import dev.blot.application.ApplicationError;

final class ApplicationFailure extends RuntimeException {
  private final ApplicationError error;

  ApplicationFailure(ApplicationError error) {
    this.error = error;
  }

  ApplicationError error() {
    return error;
  }
}

package dev.blot.application.ports;

import java.nio.file.Path;
import java.util.List;
import java.util.function.BooleanSupplier;

public interface ProcessGateway {
  record Result(int exitCode, String output, boolean truncated) {}

  Result run(
      Path workspace,
      List<String> allowedPaths,
      String program,
      List<String> arguments,
      int timeoutSeconds,
      BooleanSupplier cancelled);
}

package dev.blot.application.ports;

import java.nio.file.Path;
import java.util.UUID;

public interface WorkspaceCleaner {
  void removeRun(Path repository, UUID runId);
}

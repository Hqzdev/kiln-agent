package dev.blot.api;

import dev.blot.application.ports.WorkspaceStore;
import java.util.Map;
import org.springframework.web.bind.annotation.*;

@RestController
public final class BlotController {
  private final WorkspaceStore store;

  public BlotController(WorkspaceStore store) {
    this.store = store;
  }

  @GetMapping("/health")
  public Object health() {
    return Map.of("status", "UP");
  }

  @GetMapping("/ready")
  public Object ready() {
    store.transact(tx -> null);
    return Map.of("status", "UP", "schemaVersion", 2);
  }
}

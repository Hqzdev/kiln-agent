package dev.blot.core.workspace;

import java.util.UUID;

public record ReviewData(
    UUID taskId,
    UUID artifactId,
    String artifactHash,
    UUID authorSessionId,
    UUID reviewerSessionId,
    String decision,
    java.util.List<String> findings) {
  public ReviewData {
    findings = findings == null ? null : java.util.List.copyOf(findings);
  }
}

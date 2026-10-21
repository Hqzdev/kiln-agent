package dev.blot.core.workspace;

import java.util.UUID;

public record GrantData(
    UUID preparedActionId,
    String actionHash,
    java.time.Instant expiresAt,
    int usesRemaining,
    UUID grantedBy,
    boolean revoked) {}

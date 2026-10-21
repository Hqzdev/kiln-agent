package dev.blot.core.workspace;

import java.time.Instant;
import java.util.UUID;

public record ChallengeData(
    UUID accountId,
    String purpose,
    String codeHash,
    Instant expiresAt,
    Instant resendAt,
    int attempts,
    boolean used) {}

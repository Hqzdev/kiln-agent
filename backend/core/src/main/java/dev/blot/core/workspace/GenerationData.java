package dev.blot.core.workspace;

import java.util.UUID;

public record GenerationData(
    UUID conversationId,
    UUID sessionId,
    String status,
    String error,
    Long inputTokens,
    Long outputTokens) {}

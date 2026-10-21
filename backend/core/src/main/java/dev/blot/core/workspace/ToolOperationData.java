package dev.blot.core.workspace;

import java.util.UUID;

public record ToolOperationData(
    UUID sessionId,
    UUID preparedActionId,
    String name,
    String status,
    Object result,
    String error) {}

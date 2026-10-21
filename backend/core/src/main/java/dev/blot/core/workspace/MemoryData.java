package dev.blot.core.workspace;

import java.util.UUID;

public record MemoryData(
    String scope, UUID scopeId, String content, UUID sourceId, String status) {}

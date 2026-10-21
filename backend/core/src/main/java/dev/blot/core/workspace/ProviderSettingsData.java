package dev.blot.core.workspace;

public record ProviderSettingsData(
    String model, int contextTokens, int outputTokens, long runTokenBudget) {}

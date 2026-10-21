package dev.blot.core.workspace;

public record BudgetData(long limit, long reserved, long spent, boolean usageUnknown) {}

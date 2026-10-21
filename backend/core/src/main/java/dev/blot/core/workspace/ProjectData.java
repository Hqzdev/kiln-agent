package dev.blot.core.workspace;

public record ProjectData(
    String name, String repositoryPath, String baseSha, String defaultBranch, boolean archived) {}

package dev.blot.core.workspace;

public record AccountData(
    String email, String passwordHash, boolean verified, String displayName) {}

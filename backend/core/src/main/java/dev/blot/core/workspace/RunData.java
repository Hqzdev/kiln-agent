package dev.blot.core.workspace;

import java.util.UUID;

public record RunData(
    String goal, String status, UUID planId, long requirementsVersion, String waitingReason) {}

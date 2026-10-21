package dev.blot.application;

import dev.blot.core.RunStatus;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;

final class RunTransitions {
  private static final Map<RunStatus, Set<RunStatus>> ALLOWED = allowedTransitions();

  private RunTransitions() {}

  static boolean allows(RunStatus from, RunStatus to) {
    return ALLOWED.getOrDefault(from, Set.of()).contains(to);
  }

  private static Map<RunStatus, Set<RunStatus>> allowedTransitions() {
    Map<RunStatus, Set<RunStatus>> transitions = new EnumMap<>(RunStatus.class);
    transitions.put(RunStatus.DRAFT, EnumSet.of(RunStatus.PLANNING, RunStatus.CANCELLED));
    transitions.put(
        RunStatus.PLANNING,
        EnumSet.of(
            RunStatus.RUNNING,
            RunStatus.WAITING,
            RunStatus.FAILED,
            RunStatus.CANCELLED,
            RunStatus.INTERRUPTED));
    transitions.put(
        RunStatus.RUNNING,
        EnumSet.of(
            RunStatus.WAITING,
            RunStatus.PAUSED,
            RunStatus.REVIEWING,
            RunStatus.COMPLETED,
            RunStatus.FAILED,
            RunStatus.CANCELLED,
            RunStatus.INTERRUPTED));
    transitions.put(
        RunStatus.WAITING,
        EnumSet.of(
            RunStatus.PLANNING,
            RunStatus.RUNNING,
            RunStatus.PAUSED,
            RunStatus.CANCELLED,
            RunStatus.INTERRUPTED));
    transitions.put(
        RunStatus.PAUSED,
        EnumSet.of(
            RunStatus.PLANNING, RunStatus.RUNNING, RunStatus.CANCELLED, RunStatus.INTERRUPTED));
    transitions.put(
        RunStatus.REVIEWING,
        EnumSet.of(RunStatus.RUNNING, RunStatus.COMPLETED, RunStatus.FAILED, RunStatus.CANCELLED));
    return Map.copyOf(transitions);
  }
}

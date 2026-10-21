package dev.blot.application.agent;

import dev.blot.core.Task;
import dev.blot.core.agent.AgentAssignment;
import dev.blot.core.agent.AgentProfile;
import dev.blot.core.agent.AgentSession;
import dev.blot.core.agent.AssignmentStatus;
import java.time.Clock;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Supplier;

/** Creates assignments while keeping task, project, run, profile, and session ownership aligned. */
public final class AgentAssignmentFactory {
  private final Clock clock;
  private final Supplier<UUID> idGenerator;

  public AgentAssignmentFactory(Clock clock, Supplier<UUID> idGenerator) {
    this.clock = Objects.requireNonNull(clock, "clock");
    this.idGenerator = Objects.requireNonNull(idGenerator, "idGenerator");
  }

  public AgentAssignment assign(Task task, AgentProfile profile) {
    Objects.requireNonNull(task, "task");
    Objects.requireNonNull(profile, "profile");
    if (!profile.enabled()) {
      throw new IllegalArgumentException("Cannot assign a disabled profile");
    }

    return new AgentAssignment(
        generatedId(),
        task.projectId(),
        task.runId(),
        task.id(),
        profile.id(),
        Optional.empty(),
        AssignmentStatus.ASSIGNED,
        clock.instant(),
        0);
  }

  public AgentAssignment activate(AgentAssignment assignment, AgentSession session) {
    Objects.requireNonNull(assignment, "assignment");
    Objects.requireNonNull(session, "session");
    if (assignment.status() != AssignmentStatus.ASSIGNED) {
      throw new IllegalArgumentException("Only an assigned task can be activated");
    }
    if (!assignment.projectId().equals(session.projectId())
        || !assignment.runId().equals(session.runId())
        || !assignment.profileId().equals(session.profileId())) {
      throw new IllegalArgumentException("Session does not belong to this assignment");
    }

    return new AgentAssignment(
        assignment.id(),
        assignment.projectId(),
        assignment.runId(),
        assignment.taskId(),
        assignment.profileId(),
        Optional.of(session.id()),
        AssignmentStatus.ACTIVE,
        assignment.createdAt(),
        assignment.version() + 1);
  }

  private UUID generatedId() {
    return Objects.requireNonNull(idGenerator.get(), "generated assignment id");
  }
}

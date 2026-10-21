package dev.blot.core.agent;

import java.util.EnumSet;
import java.util.Objects;
import java.util.Set;

/** Calculates the capabilities a role may receive after project and permission checks. */
public final class AgentCapabilityPolicy {
  private static final Set<AgentCapability> COMMON =
      Set.of(
          AgentCapability.PROJECT_READ,
          AgentCapability.ARTIFACT_READ,
          AgentCapability.TASK_MESSAGE,
          AgentCapability.USER_QUESTION);

  public Set<AgentCapability> effectiveCapabilities(
      AgentProfile profile,
      Set<AgentCapability> projectCapabilities,
      Set<AgentCapability> activePermissionCapabilities) {
    Objects.requireNonNull(profile, "profile");
    Objects.requireNonNull(projectCapabilities, "projectCapabilities");
    Objects.requireNonNull(activePermissionCapabilities, "activePermissionCapabilities");

    EnumSet<AgentCapability> allowed = EnumSet.copyOf(COMMON);
    allowed.addAll(roleCapabilities(profile.role()));
    allowed.retainAll(profile.capabilities());
    allowed.retainAll(projectCapabilities);
    allowed.retainAll(activePermissionCapabilities);
    return Set.copyOf(allowed);
  }

  private Set<AgentCapability> roleCapabilities(AgentRole role) {
    Objects.requireNonNull(role, "role");
    return switch (role) {
      case PRODUCT_LEAD -> Set.of(AgentCapability.TASK_PLAN);
      case PROJECT_MANAGER -> Set.of(AgentCapability.TASK_PLAN, AgentCapability.TASK_ASSIGN);
      case TECH_LEAD, RESEARCHER -> Set.of(AgentCapability.TASK_EXECUTE);
      case DESIGN_LEAD -> Set.of(AgentCapability.TASK_EXECUTE, AgentCapability.PROJECT_WRITE);
      case BACKEND_DEVELOPER, NATIVE_FRONTEND_DEVELOPER ->
          Set.of(
              AgentCapability.TASK_EXECUTE,
              AgentCapability.PROJECT_WRITE,
              AgentCapability.PROCESS_RUN);
      case REVIEWER -> Set.of(AgentCapability.RESULT_REVIEW);
      case QA_ENGINEER ->
          Set.of(
              AgentCapability.TASK_EXECUTE,
              AgentCapability.QUALITY_REPORT,
              AgentCapability.PROCESS_RUN);
      case SECURITY_ENGINEER ->
          Set.of(
              AgentCapability.TASK_EXECUTE,
              AgentCapability.SECURITY_REPORT,
              AgentCapability.PROCESS_RUN);
      case INTEGRATOR ->
          Set.of(
              AgentCapability.TASK_EXECUTE,
              AgentCapability.PROJECT_WRITE,
              AgentCapability.PROCESS_RUN,
              AgentCapability.EXTERNAL_ACTION_PREPARE);
    };
  }
}

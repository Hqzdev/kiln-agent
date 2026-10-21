package dev.blot.application.workspace;

/** Ожидаемая ошибка сценария без секретных технических подробностей. */
public final class WorkspaceFailure extends RuntimeException {
  private final int status;
  private final String code;
  private final java.util.UUID resourceId;

  public WorkspaceFailure(int status, String code, String message) {
    this(status, code, message, null);
  }

  private WorkspaceFailure(int status, String code, String message, java.util.UUID resourceId) {
    super(message);
    this.status = status;
    this.code = code;
    this.resourceId = resourceId;
  }

  public WorkspaceFailure forResource(java.util.UUID id) {
    return new WorkspaceFailure(status, code, getMessage(), id);
  }

  public java.util.UUID resourceId() {
    return resourceId;
  }

  public int status() {
    return status;
  }

  public String code() {
    return code;
  }

  public static WorkspaceFailure invalid(String message) {
    return new WorkspaceFailure(400, "validation", message);
  }

  public static WorkspaceFailure missing() {
    return new WorkspaceFailure(404, "not_found", "Запись не найдена");
  }

  public static WorkspaceFailure conflict(String message) {
    return new WorkspaceFailure(409, "version_conflict", message);
  }
}

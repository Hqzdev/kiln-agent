package dev.blot.core.agent;

public enum AgentSessionStatus {
  CREATED,
  RUNNING,
  WAITING_FOR_USER,
  PAUSED,
  COMPLETED,
  FAILED,
  CANCELLED
}

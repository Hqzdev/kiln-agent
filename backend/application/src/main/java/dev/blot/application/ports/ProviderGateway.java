package dev.blot.application.ports;

import java.util.*;
import java.util.function.BooleanSupplier;
import java.util.function.Consumer;

public interface ProviderGateway {
  record Message(
      String role, String content, String name, String functionStateId, Object functionCall) {
    public Message(String role, String content, String name, String state) {
      this(role, content, name, state, null);
    }
  }

  record Function(String name, String description, Map<String, Object> parameters) {}

  record Request(
      UUID ownerId,
      String model,
      List<Message> messages,
      List<Function> functions,
      int maxOutputTokens,
      UUID projectId,
      UUID runId,
      UUID sessionId,
      String purpose) {
    public Request(
        UUID owner,
        String model,
        List<Message> messages,
        List<Function> functions,
        int output,
        UUID project,
        UUID run,
        UUID session) {
      this(
          owner,
          model,
          messages,
          functions,
          output,
          project,
          run,
          session,
          session != null ? "AGENT" : run != null ? "PLAN" : "WORK");
    }

    public Request(
        UUID owner, String model, List<Message> messages, List<Function> functions, int output) {
      this(owner, model, messages, functions, output, null, null, null);
    }
  }

  record ToolCall(String name, Object arguments, String stateId) {}

  record Reply(String text, List<ToolCall> calls, Long inputTokens, Long outputTokens) {}

  Reply generate(Request request, Consumer<String> onText, BooleanSupplier cancelled);

  default String concurrencyKey(UUID owner) {
    return owner.toString();
  }

  List<String> models(UUID owner);

  long countTokens(UUID owner, String model, String text);
}

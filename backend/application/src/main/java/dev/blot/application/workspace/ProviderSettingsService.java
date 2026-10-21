package dev.blot.application.workspace;

import dev.blot.application.ports.*;
import dev.blot.core.workspace.*;
import java.util.*;

public final class ProviderSettingsService {
  private final WorkspaceStore store;
  private final Records records;

  public ProviderSettingsService(WorkspaceStore store, Records records) {
    this.store = store;
    this.records = records;
  }

  public ProviderSettingsData get(UUID owner) {
    return store.transact(
        tx ->
            tx
                .list(
                    EntityKind.PROVIDER_SETTINGS, owner, null, null, ProviderSettingsData.class, 1)
                .stream()
                .findFirst()
                .orElseThrow(
                    () ->
                        new WorkspaceFailure(
                            503,
                            "provider_unconfigured",
                            "Выберите модель и её проверенный лимит контекста"))
                .data());
  }

  public Entity<ProviderSettingsData> save(
      WorkspaceStore.Transaction tx, Actor actor, ProviderSettingsData value, Long version) {
    validate(value);
    var old =
        tx.list(
            EntityKind.PROVIDER_SETTINGS,
            actor.accountId(),
            null,
            null,
            ProviderSettingsData.class,
            1);
    if (old.isEmpty())
      return records.create(tx, EntityKind.PROVIDER_SETTINGS, actor.accountId(), null, null, value);
    Records.version(old.getFirst(), version);
    return records.change(tx, EntityKind.PROVIDER_SETTINGS, old.getFirst(), value);
  }

  public static void validate(ProviderSettingsData value) {
    if (value == null) throw WorkspaceFailure.invalid("Нужны настройки модели");
    Records.text(value.model(), "model", 100);
    if (value.contextTokens() < 8192
        || value.contextTokens() > 2_000_000
        || value.outputTokens() < 256
        || value.outputTokens() > value.contextTokens() / 4
        || value.runTokenBudget() < value.contextTokens())
      throw WorkspaceFailure.invalid("Неверные лимиты модели");
  }

  public ProviderSettingsData forSession(UUID owner, UUID session) {
    if (session == null) return get(owner);
    return store.transact(
        tx ->
            tx
                .list(
                    EntityKind.AGENT_CONFIGURATION,
                    owner,
                    null,
                    session,
                    AgentConfigurationData.class,
                    1)
                .stream()
                .findFirst()
                .orElseThrow(
                    () ->
                        new WorkspaceFailure(
                            409,
                            "session_configuration_missing",
                            "Повторите задачу новым назначением"))
                .data()
                .settings());
  }
}

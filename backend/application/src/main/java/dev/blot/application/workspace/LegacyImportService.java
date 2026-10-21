package dev.blot.application.workspace;

import dev.blot.application.ports.*;
import dev.blot.core.workspace.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/** История v1 переносится как неизменяемый архив после явного выбора владельца на Mac. */
public final class LegacyImportService {
  private final ProjectService projects;
  private final ArtifactStore artifacts;
  private final Records records;
  private final JsonCodec json;

  public LegacyImportService(
      ProjectService projects, ArtifactStore artifacts, Records records, JsonCodec json) {
    this.projects = projects;
    this.artifacts = artifacts;
    this.records = records;
    this.json = json;
  }

  public Entity<ProjectData> adopt(
      WorkspaceStore.Transaction tx, Actor actor, UUID source, boolean confirmed) {
    if (!actor.local() || actor.deviceId() != null || !confirmed)
      throw new WorkspaceFailure(
          403, "local_confirmation_required", "Подтвердите перенос старого проекта на Mac");
    String archive = tx.legacyArchive(source);
    var data = json.read(archive, Map.class);
    var old = (Map<?, ?>) ((List<?>) data.get("project")).getFirst();
    var project =
        projects.create(tx, actor, (String) old.get("name"), (String) old.get("repositoryPath"));
    tx.claimLegacy(source, actor.accountId(), project.id());
    var stored = artifacts.write(archive.getBytes(StandardCharsets.UTF_8));
    records.create(
        tx,
        EntityKind.ARTIFACT,
        actor.accountId(),
        project.id(),
        null,
        new ArtifactData(
            stored.hash(),
            "application/vnd.blot.legacy+json",
            stored.relativePath(),
            project.data().baseSha(),
            null,
            null));
    return project;
  }
}

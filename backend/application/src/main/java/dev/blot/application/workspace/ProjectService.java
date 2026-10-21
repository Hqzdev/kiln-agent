package dev.blot.application.workspace;

import dev.blot.application.ports.*;
import dev.blot.core.workspace.*;
import java.nio.file.*;
import java.util.*;

public final class ProjectService {
  private final GitGateway git;
  private final Records records;
  private final ProjectAccess access;

  public ProjectService(GitGateway git, Records records, ProjectAccess access) {
    this.git = git;
    this.records = records;
    this.access = access;
  }

  public Entity<ProjectData> create(
      WorkspaceStore.Transaction tx, Actor actor, String name, String path) {
    return create(tx, actor, inspect(actor, name, path));
  }

  public ProjectData inspect(Actor actor, String name, String path) {
    if (!actor.local() || actor.deviceId() != null)
      throw new WorkspaceFailure(403, "local_required", "Выберите папку на Mac");
    Path root = Path.of(Records.text(path, "repositoryPath", 4096));
    access.authorize(root);
    try {
      root = root.toRealPath();
    } catch (java.io.IOException e) {
      throw WorkspaceFailure.invalid("Папка недоступна");
    }
    var info = git.inspect(root);
    return new ProjectData(
        Records.text(name, "name", 200),
        root.toString(),
        info.baseSha(),
        info.defaultBranch(),
        false);
  }

  public Entity<ProjectData> create(
      WorkspaceStore.Transaction tx, Actor actor, ProjectData project) {
    if (!actor.local() || actor.deviceId() != null)
      throw new WorkspaceFailure(403, "local_required", "Выберите папку на Mac");
    return records.create(tx, EntityKind.PROJECT, actor.accountId(), null, null, project);
  }

  public Entity<ProjectData> restoreAccess(WorkspaceStore.Transaction tx, Actor actor, UUID id) {
    if (!actor.local() || actor.deviceId() != null)
      throw new WorkspaceFailure(403, "local_required", "Выберите папку на Mac");
    var project = Records.require(tx, EntityKind.PROJECT, actor.accountId(), id, ProjectData.class);
    access.authorize(Path.of(project.data().repositoryPath()));
    return project;
  }

  public void archive(WorkspaceStore.Transaction tx, Actor actor, UUID id, Long version) {
    var e = Records.require(tx, EntityKind.PROJECT, actor.accountId(), id, ProjectData.class);
    Records.version(e, version);
    var d = e.data();
    records.change(
        tx,
        EntityKind.PROJECT,
        e,
        new ProjectData(d.name(), d.repositoryPath(), d.baseSha(), d.defaultBranch(), true));
  }
}

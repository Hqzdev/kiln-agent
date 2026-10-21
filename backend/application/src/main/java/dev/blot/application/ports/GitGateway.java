package dev.blot.application.ports;

import java.nio.file.Path;
import java.util.UUID;

public interface GitGateway {
  record Repository(
      String baseSha, String defaultBranch, boolean dirty, String parentSha, String message) {
    public Repository(String base, String branch, boolean dirty) {
      this(base, branch, dirty, null, null);
    }
  }

  record Remote(String defaultBranch, java.util.List<String> pushUrls) {}

  Remote remote(Path workspace, String name);

  String remoteHead(Path workspace, String name, String fullRef);

  Repository inspect(Path root);

  Path createWorkspace(Path repository, UUID run, UUID session);

  String snapshot(Path workspace);

  void integrate(Path workspace, String patch);

  String commit(Path workspace, String expectedBase, String expectedSnapshotHash, String message);

  String push(Path workspace, String remote, String refspec, String expectedCommit);
}

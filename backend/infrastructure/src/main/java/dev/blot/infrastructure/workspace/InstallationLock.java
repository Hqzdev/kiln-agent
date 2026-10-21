package dev.blot.infrastructure.workspace;

import java.nio.channels.*;
import java.nio.file.*;

/** Два экземпляра backend не могут обслуживать одну базу одновременно. */
public final class InstallationLock implements AutoCloseable {
  private final FileChannel channel;
  private final FileLock lock;

  public InstallationLock(Path database) {
    try {
      Files.createDirectories(database.toAbsolutePath().getParent());
      channel =
          FileChannel.open(
              database.resolveSibling(database.getFileName() + ".lock"),
              StandardOpenOption.CREATE,
              StandardOpenOption.WRITE);
      lock = channel.tryLock();
      if (lock == null) {
        channel.close();
        throw new IllegalStateException("Backend этой установки уже работает");
      }
    } catch (java.io.IOException | OverlappingFileLockException e) {
      throw new IllegalStateException("Не удалось получить блокировку установки", e);
    }
  }

  public void close() {
    try {
      lock.release();
      channel.close();
    } catch (java.io.IOException e) {
      throw new IllegalStateException("Не удалось освободить блокировку установки", e);
    }
  }
}

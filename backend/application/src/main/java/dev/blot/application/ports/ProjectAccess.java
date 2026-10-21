package dev.blot.application.ports;

import java.nio.file.Path;

/** Системный доступ к папке не заменяет проверки владельца и области задачи. */
public interface ProjectAccess {
  void authorize(Path directory);
}

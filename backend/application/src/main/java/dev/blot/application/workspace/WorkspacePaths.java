package dev.blot.application.workspace;

import java.nio.file.*;

/** Одинаковые правила путей для плана, Mote и фактического обращения к файлам. */
public final class WorkspacePaths {
  private WorkspacePaths() {}

  public static boolean containsGitMetadata(Path path) {
    for (Path part : path) if (part.toString().equalsIgnoreCase(".git")) return true;
    return false;
  }

  public static boolean isSafeRelative(String value) {
    if (value == null || value.isBlank()) return false;
    try {
      Path path = Path.of(value);
      if (path.isAbsolute() || path.startsWith("..") || containsGitMetadata(path)) return false;
      return value.equals(".") || path.normalize().toString().equals(value);
    } catch (InvalidPathException failure) {
      return false;
    }
  }
}

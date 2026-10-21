package dev.blot.application.ports;

public interface ArtifactStore {
  record Stored(String hash, String relativePath) {}

  Stored write(byte[] content);

  byte[] read(String relativePath, String expectedHash, int offset, int length);

  void removeUnused(java.util.Set<String> referenced, java.time.Instant olderThan);
}

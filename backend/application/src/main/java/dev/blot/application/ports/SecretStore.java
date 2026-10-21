package dev.blot.application.ports;

import java.util.Optional;

/** Секреты не сохраняются в общей базе и не выдаются клиентским GET. */
public interface SecretStore {
  Optional<String> get(String key);

  void put(String key, String value);

  void remove(String key);
}

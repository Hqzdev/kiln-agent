package dev.blot.application.ports;

/** JSON остаётся инфраструктурной подробностью. */
public interface JsonCodec {
  String write(Object value);

  <T> T read(String text, Class<T> type);

  <T> T convert(Object value, Class<T> type);
}

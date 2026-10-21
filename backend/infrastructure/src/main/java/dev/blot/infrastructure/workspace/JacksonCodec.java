package dev.blot.infrastructure.workspace;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import dev.blot.application.ports.JsonCodec;
import java.io.IOException;
import java.time.Instant;

public final class JacksonCodec implements JsonCodec {
  private final ObjectMapper mapper;

  public JacksonCodec() {
    var dates = new SimpleModule();
    dates.addSerializer(Instant.class, new ToStringSerializer());
    dates.addDeserializer(
        Instant.class,
        new StdDeserializer<Instant>(Instant.class) {
          public Instant deserialize(JsonParser p, DeserializationContext c) throws IOException {
            return Instant.parse(p.getText());
          }
        });
    mapper =
        JsonMapper.builder()
            .addModule(dates)
            .enable(MapperFeature.SORT_PROPERTIES_ALPHABETICALLY)
            .enable(SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS)
            .build();
  }

  public String write(Object value) {
    try {
      return mapper.writeValueAsString(value);
    } catch (IOException e) {
      throw new IllegalArgumentException("Нельзя записать JSON", e);
    }
  }

  public <T> T read(String text, Class<T> type) {
    try {
      return mapper.readValue(text, type);
    } catch (IOException e) {
      throw new IllegalArgumentException("Неверный JSON", e);
    }
  }

  public <T> T convert(Object value, Class<T> type) {
    return mapper.convertValue(value, type);
  }
}

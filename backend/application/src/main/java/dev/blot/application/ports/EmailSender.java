package dev.blot.application.ports;

public interface EmailSender {
  void sendCode(String email, String code, String purpose);
}

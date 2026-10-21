package dev.blot.application.ports;

import java.util.List;

public interface CertificateInspector {
  record CertificateInfo(String subject, String issuer, String sha256, String notAfter) {}

  List<CertificateInfo> inspect(String pem);
}

import Foundation
import Security
import CryptoKit

/// Публичный отпечаток приходит из QR-кода Mac, а не из ответа неизвестного сервера.
public final class PinnedBackendSession: NSObject, URLSessionDelegate, Sendable {
    private let fingerprint: String
    public init(fingerprint: String) { self.fingerprint = fingerprint.lowercased() }
    public func makeSession() -> URLSession { URLSession(configuration: .default, delegate: self, delegateQueue: nil) }
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust,
              let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate], let certificate = chain.first else {
            completionHandler(.performDefaultHandling, nil); return
        }
        let digest = SHA256.hash(data: SecCertificateCopyData(certificate) as Data).map { String(format: "%02x", $0) }.joined()
        guard digest == fingerprint else { completionHandler(.cancelAuthenticationChallenge, nil); return }
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}

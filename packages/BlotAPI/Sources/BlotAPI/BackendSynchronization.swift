import Foundation

public enum BackendUpdate: Sendable {
    case snapshot(BackendSnapshot)
    case event(BackendEvent)
    case connectionLost(String)
}

/// Холодный старт получает snapshot; обрыв соединения продолжает события с последней позиции.
public struct BackendSynchronization: Sendable {
    private let client: BackendClient
    public init(client: BackendClient) { self.client = client }

    public func updates() -> AsyncThrowingStream<BackendUpdate, any Error> {
        AsyncThrowingStream { continuation in
            let task = _Concurrency.Task {
                do {
                    var cursor: Int64 = 0
                    var needsSnapshot = true
                    var delay: UInt64 = 1
                    while !_Concurrency.Task.isCancelled {
                        do {
                            if needsSnapshot {
                                let snapshot = try await client.snapshot()
                                guard let watermark = Int64(snapshot.watermark) else {
                                    throw URLError(.cannotParseResponse)
                                }
                                continuation.yield(.snapshot(snapshot))
                                cursor = watermark
                                needsSnapshot = false
                            }
                            let events = try await client.events(after: cursor)
                            for try await event in events {
                                guard let sequence = event.sequence, sequence > cursor else { continue }
                                continuation.yield(.event(event))
                                cursor = sequence
                                delay = 1
                            }
                            try _Concurrency.Task.checkCancellation()
                            continuation.yield(
                                .connectionLost("Соединение с сервером закрыто; переподключаемся"))
                        } catch let failure as BackendFailure {
                            guard failure.code == "replay_unavailable" else { throw failure }
                            needsSnapshot = true
                        } catch {
                            try _Concurrency.Task.checkCancellation()
                            guard error is URLError else { throw error }
                            continuation.yield(.connectionLost(error.localizedDescription))
                        }
                        try await _Concurrency.Task.sleep(for: .seconds(delay))
                        delay = min(delay * 2, 30)
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

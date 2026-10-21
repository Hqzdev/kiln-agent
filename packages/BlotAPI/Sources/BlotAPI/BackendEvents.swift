import Foundation

public struct BackendEventStream: Sendable {
    private let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }

    public func events(baseURL: URL, token: String, after: Int64) -> AsyncThrowingStream<
        BackendEvent, any Error
    > {
        AsyncThrowingStream { continuation in
            let task = _Concurrency.Task {
                do {
                    let url = baseURL.appendingPathComponent("v2/events").appending(queryItems: [
                        URLQueryItem(name: "after", value: String(after))
                    ])
                    var request = URLRequest(url: url)
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    let (bytes, response) = try await session.bytes(for: request)
                    guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
                    if http.statusCode != 200 {
                        var body = Data()
                        for try await byte in bytes {
                            body.append(byte)
                            if body.count > 65_536 { break }
                        }
                        if let failure = try? JSONDecoder().decode(BackendFailure.self, from: body) {
                            throw failure
                        }
                        throw URLError(.badServerResponse)
                    }
                    var parser = ServerSentEventParser()
                    for try await byte in bytes {
                        try _Concurrency.Task.checkCancellation()
                        if let data = try parser.append(byte) {
                            let event = try JSONDecoder().decode(BackendEvent.self, from: Data(data.utf8))
                            guard event.schemaVersion == 2, event.sequence != nil else {
                                throw URLError(.cannotParseResponse)
                            }
                            continuation.yield(event)
                        }
                    }
                    continuation.finish()
                } catch { continuation.finish(throwing: error) }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

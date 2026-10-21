import Foundation
import Darwin

struct Job: Decodable {
    let id: String
    let program: String
    let arguments: [String]
    let timeoutSeconds: Int
}
struct JobResult: Encodable {
    let id: String
    let exitCode: Int32
    let output: String
    let truncated: Bool
}
final class OutputBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var data = Data()
    private var exceeded = false
    func append(_ bytes: Data) {
        lock.lock(); defer { lock.unlock() }
        let count = min(bytes.count, max(0, 131_072 - data.count))
        data.append(bytes.prefix(count)); exceeded = exceeded || count < bytes.count
    }
    func result() -> (String, Bool) {
        lock.lock(); defer { lock.unlock() }
        return (String(decoding: data, as: UTF8.self), exceeded)
    }
}

/// Этот бинарник устанавливается только внутри гостевой macOS.
final class GuestJobRunner {
    private let exchange = URL(fileURLWithPath: "/Volumes/My Shared Files/job", isDirectory: true)
    func waitForJob() {
        while true {
            do {
                let request = exchange.appendingPathComponent("request.json")
                let data = try Data(contentsOf: request)
                guard data.count <= 1_048_576 else { return }
                let job = try JSONDecoder().decode(Job.self, from: data)
                let result = try run(job)
                try JSONEncoder().encode(result).write(to: exchange.appendingPathComponent("result.json"), options: .atomic)
                return
            } catch CocoaError.fileReadNoSuchFile { Thread.sleep(forTimeInterval: 1) }
            catch { return }
        }
    }
    private func run(_ job: Job) throws -> JobResult {
        let workspace = exchange.appendingPathComponent("workspace", isDirectory: true)
        guard UUID(uuidString: job.id) != nil, (1...1800).contains(job.timeoutSeconds), job.arguments.count <= 100,
              !job.arguments.contains(where: { $0.utf8.count > 8192 || $0.contains("\0") }) else { throw CocoaError(.fileReadCorruptFile) }
        let executables = ["gradle": "/bin/sh", "swift": "/usr/bin/swift", "xcodebuild": "/usr/bin/xcodebuild"]
        guard let executable = executables[job.program] else { throw CocoaError(.fileReadCorruptFile) }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = (job.program == "gradle" ? [workspace.appendingPathComponent("gradlew").path] : []) + job.arguments
        process.currentDirectoryURL = workspace
        let home = "/Users/Shared/BlotBuild"
        process.environment = ["HOME": home, "TMPDIR": home + "/tmp", "PATH": "/usr/bin:/bin:/usr/sbin:/sbin",
                               "JAVA_HOME": "/Library/Java/JavaVirtualMachines/blot/Contents/Home",
                               "GRADLE_USER_HOME": home + "/gradle", "CLANG_MODULE_CACHE_PATH": home + "/module-cache"]
        let pipe = Pipe()
        process.standardOutput = pipe; process.standardError = pipe; process.standardInput = FileHandle.nullDevice
        let buffer = OutputBuffer()
        let reading = DispatchGroup()
        reading.enter()
        DispatchQueue.global().async {
            while true {
                let bytes = pipe.fileHandleForReading.availableData
                if bytes.isEmpty { break }
                buffer.append(bytes)
            }
            reading.leave()
        }
        try process.run()
        let deadline = Date().addingTimeInterval(TimeInterval(job.timeoutSeconds))
        while process.isRunning && Date() < deadline { Thread.sleep(forTimeInterval: 0.1) }
        let timedOut = process.isRunning
        if timedOut { process.terminate(); Thread.sleep(forTimeInterval: 0.2); if process.isRunning { kill(process.processIdentifier, SIGKILL) } }
        process.waitUntilExit()
        // Потомки могут держать pipe открытым. После результата host останавливает всю VM.
        _ = reading.wait(timeout: .now() + 1)
        let (output, truncated) = buffer.result()
        return JobResult(id: job.id, exitCode: timedOut ? 124 : process.terminationStatus, output: output, truncated: truncated)
    }
}
GuestJobRunner().waitForJob()
// KeepAlive не должен повторно запускать уже выполненную команду.
while true { Thread.sleep(forTimeInterval: 3600) }

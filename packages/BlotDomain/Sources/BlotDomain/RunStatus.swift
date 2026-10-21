public enum RunStatus: String, Codable, CaseIterable, Sendable {
    case draft = "DRAFT"
    case planning = "PLANNING"
    case running = "RUNNING"
    case waiting = "WAITING"
    case paused = "PAUSED"
    case reviewing = "REVIEWING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case cancelled = "CANCELLED"
    case interrupted = "INTERRUPTED"
}

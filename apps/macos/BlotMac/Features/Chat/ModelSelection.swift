import Foundation

enum ReasoningEffort: String, CaseIterable, Identifiable {
    case low = "Low", medium = "Medium", high = "High", veryHigh = "Very high", max = "Max"
    var id: String { rawValue }
    var index: Double { Double(Self.allCases.firstIndex(of: self) ?? 2) }
    init(index: Double) {
        self = Self.allCases[Swift.min(Self.allCases.count - 1, Swift.max(0, Int(index.rounded())))]
    }
}

struct ModelOption: Identifiable {
    let name: String
    var id: String { name }
    var supportsReasoning: Bool { !name.localizedCaseInsensitiveContains("mini") }

    static func options(from labels: [String]) -> [ModelOption] {
        var names: [String] = []
        for label in labels {
            let name = label.components(separatedBy: " · ").first ?? label
            if !names.contains(name) { names.append(name) }
        }
        return names.map { ModelOption(name: $0) }
    }
}

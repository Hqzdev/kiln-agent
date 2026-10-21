import Foundation

/// Local sample shared by the profile menu and the existing usage screen.
struct AccountUsage {
    let usedFraction: Double
    let resetDescription: String

    var usedPercent: Int { Int((usedFraction * 100).rounded()) }
    var remainingPercent: Int { max(0, 100 - usedPercent) }

    static let preview = AccountUsage(usedFraction: 0.62, resetDescription: "resets Monday at 00:00")
}

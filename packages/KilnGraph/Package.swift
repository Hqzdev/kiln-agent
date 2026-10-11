// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "KilnGraph",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "KilnGraph", targets: ["KilnGraph"])],
    dependencies: [.package(path: "../KilnDomain"), .package(path: "../KilnDesign")],
    targets: [
        .target(name: "KilnGraph", dependencies: ["KilnDomain", "KilnDesign"]),
        .testTarget(name: "KilnGraphTests", dependencies: ["KilnGraph"]),
    ]
)

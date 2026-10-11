// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "KilnDomain",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "KilnDomain", targets: ["KilnDomain"])],
    dependencies: [],
    targets: [
        .target(name: "KilnDomain", dependencies: []),
        .testTarget(name: "KilnDomainTests", dependencies: ["KilnDomain"]),
    ]
)

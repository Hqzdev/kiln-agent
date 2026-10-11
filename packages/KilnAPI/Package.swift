// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "KilnAPI",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "KilnAPI", targets: ["KilnAPI"])],
    dependencies: [.package(path: "../KilnDomain")],
    targets: [
        .target(name: "KilnAPI", dependencies: ["KilnDomain"]),
        .testTarget(name: "KilnAPITests", dependencies: ["KilnAPI"]),
    ]
)

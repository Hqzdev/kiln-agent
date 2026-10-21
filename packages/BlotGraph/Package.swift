// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BlotGraph",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "BlotGraph", targets: ["BlotGraph"])],
    dependencies: [.package(path: "../BlotDomain"), .package(path: "../BlotDesign")],
    targets: [
        .target(name: "BlotGraph", dependencies: ["BlotDomain", "BlotDesign"]),
        .testTarget(name: "BlotGraphTests", dependencies: ["BlotGraph"]),
    ]
)

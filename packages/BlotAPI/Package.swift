// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BlotAPI",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "BlotAPI", targets: ["BlotAPI"])],
    dependencies: [.package(path: "../BlotDomain")],
    targets: [
        .target(name: "BlotAPI", dependencies: ["BlotDomain"]),
        .testTarget(name: "BlotAPITests", dependencies: ["BlotAPI"]),
    ]
)

// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BlotDomain",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "BlotDomain", targets: ["BlotDomain"])],
    dependencies: [],
    targets: [
        .target(name: "BlotDomain", dependencies: []),
        .testTarget(name: "BlotDomainTests", dependencies: ["BlotDomain"]),
    ]
)

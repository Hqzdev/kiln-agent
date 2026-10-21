// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BlotDesign",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "BlotDesign", targets: ["BlotDesign"])],
    dependencies: [],
    targets: [
        .target(name: "BlotDesign", dependencies: []),
        .testTarget(name: "BlotDesignTests", dependencies: ["BlotDesign"]),
    ]
)

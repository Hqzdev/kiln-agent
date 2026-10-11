// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "KilnDesign",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [.library(name: "KilnDesign", targets: ["KilnDesign"])],
    dependencies: [],
    targets: [
        .target(name: "KilnDesign", dependencies: []),
        .testTarget(name: "KilnDesignTests", dependencies: ["KilnDesign"]),
    ]
)

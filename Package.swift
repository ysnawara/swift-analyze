// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "swift-analyze",
    products: [
        .executable(name: "swift-analyze", targets: ["SwiftAnalyze"]),
        .library(name: "SwiftAnalyzeCore", targets: ["SwiftAnalyzeCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftAnalyze",
            dependencies: [
                "SwiftAnalyzeCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "SwiftAnalyzeCore"),
        .testTarget(
            name: "SwiftAnalyzeCoreTests",
            dependencies: ["SwiftAnalyzeCore"]
        ),
    ]
)

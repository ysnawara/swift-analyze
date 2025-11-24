// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WeatherApp",
    products: [
        .library(name: "WeatherCore", targets: ["WeatherCore"]),
        .executable(name: "weather-cli", targets: ["WeatherCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(name: "WeatherCore", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        .executableTarget(name: "WeatherCLI", dependencies: [
            "WeatherCore",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "WeatherCoreTests", dependencies: ["WeatherCore"]),
    ]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tintify",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "Tintify",
            dependencies: [
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TintifyTests",
            dependencies: ["Tintify"],
            path: "Tests"
        ),
    ]
)

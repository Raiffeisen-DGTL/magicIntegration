// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MagicIntegration",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "MagicIntegration",
            targets: ["MagicIntegration"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Raiffeisen-DGTL/raifmagiccore.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Raiffeisen-DGTL/CodeOwners.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Raiffeisen-DGTL/CodeStyler.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/Raiffeisen-DGTL/CommandExecutor.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "MagicIntegration",
            dependencies: [
                .product(name: "RaifMagicCore", package: "RaifMagicCore"),
                .product(name: "CommandExecutor", package: "CommandExecutor"),
                .product(name: "CodeOwners", package: "CodeOwners"),
                .product(name: "CodeStyler", package: "CodeStyler")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)

// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "THOTP",
    platforms: [.iOS(.v18), .tvOS(.v18), .macOS(.v15), .watchOS(.v11)],
    products: [
        .library(
            name: "THOTP",
            targets: ["THOTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ericlewis/URL-QueryItem.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/norio-nomura/Base32.git", .upToNextMajor(from: "0.7.0"))
    ],
    targets: [
        .target(
            name: "THOTP",
            dependencies: ["URL-QueryItem", "Base32"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]),
        .testTarget(
            name: "THOTPTests",
            dependencies: ["THOTP", "Base32"]),
        .testTarget(
            name: "THOTPBenchmarks",
            dependencies: ["THOTP", "Base32"]),
    ]
)

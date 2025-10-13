// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "THOTP",
    platforms: [.iOS(.v16), .tvOS(.v16), .macOS(.v13), .watchOS(.v9)],
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
    ]
)

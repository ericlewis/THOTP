// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "THOTP",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(
            name: "THOTP",
            type: .static,
            targets: ["THOTP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ericlewis/URL-QueryItem.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/norio-nomura/Base32.git", .upToNextMajor(from: "0.7.0"))
    ],
    targets: [
        .target(
            name: "THOTP",
            dependencies: ["URL-QueryItem", "Base32"]),
        .testTarget(
            name: "THOTPTests",
            dependencies: ["THOTP", "Base32"]),
    ]
)

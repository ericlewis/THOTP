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
    ],
    targets: [
        .target(
            name: "THOTP",
            dependencies: []),
        .testTarget(
            name: "THOTPTests",
            dependencies: ["THOTP"]),
    ]
)

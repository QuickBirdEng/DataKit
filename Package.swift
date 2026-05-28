// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DataKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "DataKit",
            targets: ["DataKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/QuickBirdEng/crc-swift.git",
            from: "0.1.1"
        ),
    ],
    targets: [
        .target(
            name: "DataKit",
            dependencies: [
                .product(name: "CRC", package: "crc-swift"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
            ]
        ),
        .testTarget(
            name: "DataKitTests",
            dependencies: ["DataKit"]
        ),
    ]
)

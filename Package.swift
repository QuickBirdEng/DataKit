// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "DataKit",
    products: [
        .library(
            name: "DataKit",
            targets: ["DataKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/QuickBirdEng/crc-swift.git",
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "DataKit",
            dependencies: [
                .product(name: "CRC", package: "crc-swift"),
            ]
        ),
        .testTarget(
            name: "DataKitTests",
            dependencies: ["DataKit"]
        ),
    ]
)

// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "DataKit",
    products: [
        .library(
            name: "DataKit",
            targets: ["DataKit"]
        ),
        .library(
            name: "DataKit+CRC",
            targets: ["DataKit+CRC"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/QuickBirdEng/crc-swift.git",
            .branch("package")
        ),
    ],
    targets: [
        .target(
            name: "DataKit",
            dependencies: []
        ),
        .target(
            name: "DataKit+CRC",
            dependencies: [
                "DataKit",
                .product(name: "CRC", package: "crc-swift"),
            ]
        ),
        .testTarget(
            name: "DataKitTests",
            dependencies: ["DataKit"]
        ),
    ]
)

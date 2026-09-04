// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrackerData",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TrackerData",
            targets: ["TrackerData"]
        )
    ],
    dependencies: [
        .package(path: "../TrackerDomain"),
        .package(url: "https://github.com/appmetrica/appmetrica-sdk-ios.git", from: "5.9.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
        .package(url: "https://github.com/alrzi/KeyValueStorage.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TrackerData",
            dependencies: [
                .product(name: "TrackerDomain", package: "TrackerDomain"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "AppMetricaCore", package: "appmetrica-sdk-ios"),
                .product(name: "KeyValueStorage", package: "KeyValueStorage"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TrackerDataTests",
            dependencies: ["TrackerData"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

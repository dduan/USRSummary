// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "USRSummary",
    dependencies: [
        .package(
            url: "https://github.com/apple/indexstore-db",
            .revision("swift-5.5.2-RELEASE")
        ),
        .package(
            url: "https://github.com/dduan/Pathos",
            from: "0.4.2"
        ),
    ],
    targets: [
        .executableTarget(name: "usr-summary", dependencies: [
            .product(name: "IndexStoreDB", package: "indexstore-db"),
            .product(name: "Pathos", package: "Pathos"),
        ]),
    ]
)

// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OTAtomics",
    platforms: [
        .macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "OTAtomics", type: .static, targets: ["OTAtomics"])
    ],
    targets: [
        .target(name: "OTAtomics"),
        .testTarget(name: "OTAtomicsTests", dependencies: ["OTAtomics"])
    ]
)

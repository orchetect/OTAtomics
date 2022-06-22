// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OTAtomics",
    
    platforms: [
        .macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    
    products: [
        .library(
            name: "OTAtomics",
            type: .static,
            targets: ["OTAtomics"])
    ],
    
    dependencies: [
        // none
    ],
    
    targets: [
        .target(
            name: "OTAtomics",
            dependencies: []),
        .testTarget(
            name: "OTAtomicsTests",
            dependencies: ["OTAtomics"])
    ]
)

func addShouldTestFlag() {
    // swiftSettings may be nil so we can't directly append to it
    
    var swiftSettings = package.targets
        .first(where: { $0.name == "OTAtomicsTests" })?
        .swiftSettings ?? []
    
    swiftSettings.append(.define("shouldTestCurrentPlatform"))
    
    package.targets
        .first(where: { $0.name == "OTAtomicsTests" })?
        .swiftSettings = swiftSettings
}

// Swift version in Xcode 12.5.1 which introduced watchOS testing
#if os(watchOS) && swift(>=5.4.2)
addShouldTestFlag()
#elseif os(watchOS)
// don't add flag
#else
addShouldTestFlag()
#endif

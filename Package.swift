// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "cupsadmin",
    // Executable names must differ case-insensitively (cupsadmin vs CUPSAdminApp) on APFS.
    // macOS 14: the app needs ContentUnavailableView/Observation, and SwiftPM has one deployment target per package.
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "cupsadmin", targets: ["cupsadmin"]),
        .executable(name: "CUPSAdminApp", targets: ["CUPSAdminApp"]),
        .library(name: "CupsKit", targets: ["CupsKit"]),
    ],
    targets: [
        // driver-profiles.json is compiled into the code: the CLI ships as a single binary with no resource bundle.
        .target(name: "CupsKit", path: "Sources/CupsKit", resources: [.embedInCode("Resources/driver-profiles.json")]),
        .executableTarget(name: "cupsadmin", dependencies: ["CupsKit"], path: "Sources/cupsadmin"),
        .executableTarget(name: "CUPSAdminApp", dependencies: ["CupsKit"], path: "Sources/CUPSAdminApp"),
        .testTarget(name: "CupsKitTests", dependencies: ["CupsKit"], path: "Tests/CupsKitTests"),
    ],
    // Tools 6.0 for Swift Testing with only the Command Line Tools; code stays in Swift 5 mode.
    swiftLanguageModes: [.v5]
)

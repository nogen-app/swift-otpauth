// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-OTPAuth",
		platforms: [
			.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
		],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftOTPAuth",
            targets: ["SwiftOTPAuth"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
			.package(url: "https://github.com/lachlanbell/SwiftOTP.git", .upToNextMinor(from: "3.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftOTPAuth",
            dependencies: [
							.product(name: "SwiftOTP", package: "SwiftOTP")
						]),
        .testTarget(
            name: "SwiftOTPAuthTests",
            dependencies: [
							"SwiftOTPAuth",
							.product(name: "SwiftOTP", package: "SwiftOTP")
						]),
    ]
)

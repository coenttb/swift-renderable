// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rendering: Self = "Rendering"
    static let renderingAsync: Self = "RenderingAsync"
    static let renderingTestSupport: Self = "Rendering TestSupport"
}

extension Target.Dependency {
    static var rendering: Self { .target(name: .rendering) }
    static var renderingAsync: Self { .target(name: .renderingAsync) }
    static var renderingTestSupport: Self { .target(name: .renderingTestSupport) }
}

extension Target.Dependency {
    static var inlineSnapshotTesting: Self {
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")
    }
    static var asyncAlgorithms: Self {
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
    }
    static var testingPerformance: Self {
        .product(name: "TestingPerformance", package: "swift-testing-performance")
    }
}

let package = Package(
    name: "swift-renderable",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: .rendering, targets: [.rendering]),
        .library(name: .renderingAsync, targets: [.renderingAsync]),
        .library(name: .renderingTestSupport, targets: [.renderingTestSupport]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.3"),
        .package(url: "https://github.com/coenttb/swift-testing-performance", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: .rendering,
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .target(
            name: .renderingAsync,
            dependencies: [
                .rendering,
                .asyncAlgorithms,
            ]
        ),
        .target(
            name: .renderingTestSupport,
            dependencies: [
                .rendering,
                .renderingAsync,
                .inlineSnapshotTesting,
                .testingPerformance,
            ]
        ),
        .testTarget(
            name: .rendering.tests,
            dependencies: [
                .rendering,
                .renderingTestSupport,
            ]
        ),
        .testTarget(
            name: .renderingAsync.tests,
            dependencies: [
                .rendering,
                .renderingAsync,
                .renderingTestSupport,
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings =
        existing + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportsByDefault"),
        ]
}

// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let rendering: Self = "Rendering"
    static let renderingHTML: Self = "Rendering HTML"
    static let renderingTestSupport: Self = "Rendering TestSupport"
    static let renderingHTMLTestSupport: Self = "Rendering HTML TestSupport"
}

extension Target.Dependency {
    static var rendering: Self { .target(name: .rendering) }
    static var renderingHTML: Self { .target(name: .renderingHTML) }
    static var renderingTestSupport: Self { .target(name: .renderingTestSupport) }
    static var renderingHTMLTestSupport: Self { .target(name: .renderingHTMLTestSupport) }
}

extension Target.Dependency {
    static var inlineSnapshotTesting: Self {
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")
    }
    static var incits4_1986: Self {
        .product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
    }
    static var iso9899: Self {
        .product(name: "ISO 9899", package: "swift-iso-9899")
    }
    static var standards: Self {
        .product(name: "Standards", package: "swift-standards")
    }
    static var testingPerformance: Self {
        .product(name: "TestingPerformance", package: "swift-testing-performance")
    }
    static var asyncAlgorithms: Self {
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
    }
}

let package = Package(
    name: "pointfree-html",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .macCatalyst(.v18),
    ],
    products: [
        .library(name: .rendering, targets: [.rendering]),
        .library(name: .renderingHTML, targets: [.renderingHTML]),
        .library(name: .renderingTestSupport, targets: [.renderingTestSupport]),
        .library(name: .renderingHTMLTestSupport, targets: [.renderingHTMLTestSupport]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.3"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-iso-9899", from: "0.1.0"),
        .package(url: "https://github.com/coenttb/swift-testing-performance", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: .rendering,
            dependencies: [
                .asyncAlgorithms,
            ]
        ),
        .target(
            name: .renderingHTML,
            dependencies: [
                .rendering,
                .asyncAlgorithms,
                .product(name: "OrderedCollections", package: "swift-collections"),
                .incits4_1986,
                .standards,
                .iso9899
            ]
        ),
        .target(
            name: .renderingTestSupport,
            dependencies: [
                .rendering,
                .inlineSnapshotTesting,
            ]
        ),
        .target(
            name: .renderingHTMLTestSupport,
            dependencies: [
                .renderingHTML,
                .renderingTestSupport,
                .inlineSnapshotTesting,
            ]
        ),
        .testTarget(
            name: .renderingHTML.tests,
            dependencies: [
                .renderingHTML,
                .renderingHTMLTestSupport,
                .testingPerformance,
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}

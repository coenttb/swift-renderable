// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let pointfreeHtml: Self = "PointFreeHTML"
    static let pointfreeHtmlTestSupport: Self = "PointFreeHTMLTestSupport"
}

extension Target.Dependency {
    static var pointfreeHtml: Self { .target(name: .pointfreeHtml) }
    static var pointfreeHtmlTestSupport: Self { .target(name: .pointfreeHtmlTestSupport) }
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
        .library(name: .pointfreeHtml, targets: [.pointfreeHtml]),
        .library(name: .pointfreeHtmlTestSupport, targets: [.pointfreeHtmlTestSupport]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.3"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-iso-9899", from: "0.1.0"),
        .package(url: "https://github.com/coenttb/swift-testing-performance", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: .pointfreeHtml,
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .incits4_1986,
                .standards,
                .iso9899
            ]
        ),
        .testTarget(
            name: .pointfreeHtml.tests,
            dependencies: [
                .pointfreeHtml,
                .pointfreeHtmlTestSupport,
                .testingPerformance,
            ]
        ),
        .target(
            name: .pointfreeHtmlTestSupport,
            dependencies: [
                .pointfreeHtml,
                .inlineSnapshotTesting,
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

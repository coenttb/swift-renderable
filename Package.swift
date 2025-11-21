// swift-tools-version:6.0
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
    static var dependenciesTestSupport: Self {
        .product(name: "DependenciesTestSupport", package: "swift-dependencies")
    }
    static var inlineSnapshotTesting: Self {
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")
    }
    static var incits4_1986: Self {
        .product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
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
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.3.5"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.3"),
        .package(path: "/Users/coen/Developer/swift-standards/swift-incits-4-1986"),
    ],
    targets: [
        .target(
            name: .pointfreeHtml,
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .incits4_1986,
            ]
        ),
        .testTarget(
            name: .pointfreeHtml.tests,
            dependencies: [
                .pointfreeHtml,
                .pointfreeHtmlTestSupport,
            ]
        ),
        .target(
            name: .pointfreeHtmlTestSupport,
            dependencies: [
                .pointfreeHtml,
                .inlineSnapshotTesting,
                .dependenciesTestSupport,
            ]
        ),
    ]
)

extension String { var tests: Self { self + " Tests" } }

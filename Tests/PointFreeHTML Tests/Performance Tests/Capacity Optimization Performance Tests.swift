//
//  Capacity Optimization Performance Tests.swift
//  pointfree-html
//
//  Performance tests for buffer capacity pre-allocation optimization.
//

import Dependencies
import Testing
import TestingPerformance
@testable import PointFreeHTML

extension `Performance Tests` {

    @Suite
    struct `Capacity Optimization` {

        // MARK: - Without Capacity Reservation (Baseline)

        @Test(.timed(threshold: .seconds(3)))
        func `baseline - no capacity reservation 10K renders`() {
            withDependencies {
                $0.htmlPrinter = HTMLPrinter(.default)
            } operation: {
                for _ in 0..<10_000 {
                    _ = try! String(
                        HTMLDocument {
                            tag("div")
                                .attribute("id", "container")
                                .attribute("class", "content")
                        }
                    )
                }
            }
        }

        @Test(.timed(threshold: .seconds(3)))
        func `baseline - large document no reservation 1K renders`() {
            withDependencies {
                $0.htmlPrinter = HTMLPrinter(.default)
            } operation: {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTMLDocument {
                            tag("div") {
                                for i in 0..<20 {
                                    tag("section")
                                        .attribute("id", "section-\(i)")
                                        .attribute("class", "content-block")
                                        .attribute("data-index", "\(i)")
                                }
                            }
                        }
                    )
                }
            }
        }

        // MARK: - With Capacity Reservation (Optimized)

        @Test(.timed(threshold: .seconds(3)))
        func `optimized - 4KB capacity reservation 10K renders`() {
            withDependencies {
                $0.htmlPrinter = HTMLPrinter(.optimized)
            } operation: {
                for _ in 0..<10_000 {
                    _ = try! String(
                        HTMLDocument {
                            tag("div")
                                .attribute("id", "container")
                                .attribute("class", "content")
                        }
                    )
                }
            }
        }

        @Test(.timed(threshold: .seconds(3)))
        func `optimized - 4KB capacity large document 1K renders`() {
            withDependencies {
                $0.htmlPrinter = HTMLPrinter(.optimized)
            } operation: {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTMLDocument {
                            tag("div") {
                                for i in 0..<20 {
                                    tag("section")
                                        .attribute("id", "section-\(i)")
                                        .attribute("class", "content-block")
                                        .attribute("data-index", "\(i)")
                                }
                            }
                        }
                    )
                }
            }
        }

        // MARK: - Custom Capacity Sizes

        @Test(.timed(threshold: .milliseconds(300)))
        func `small capacity - 512 bytes for small docs 1K renders`() {
            withDependencies {
                $0.htmlPrinter = HTMLPrinter(.init(
                    forceImportant: false,
                    indentation: [],
                    newline: [],
                    reservedCapacity: 512
                ))
            } operation: {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTMLDocument {
                            tag("p") { "Hello, World!" }
                        }
                    )
                }
            }
        }

        @Test(.timed(threshold: .seconds(3)))
        func `large capacity - 16KB for large docs 1K renders`() {
            withDependencies {
                $0.htmlPrinter = HTMLPrinter(.init(
                    forceImportant: false,
                    indentation: [],
                    newline: [],
                    reservedCapacity: 16384
                ))
            } operation: {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTMLDocument {
                            tag("div") {
                                for i in 0..<50 {
                                    tag("article")
                                        .attribute("id", "article-\(i)")
                                        .attribute("class", "post-content")
                                        .attribute("data-author", "author-\(i)")
                                        .attribute("data-date", "2025-01-\(i % 28 + 1)")
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

//
//  Capacity Optimization Performance Tests.swift
//  pointfree-html
//
//  Performance tests for buffer capacity pre-allocation optimization.
//

import Testing
import TestingPerformance
@testable import Rendering_HTML

extension `Performance Tests` {

    @Suite
    struct `Capacity Optimization` {

        // MARK: - Without Capacity Reservation (Baseline)

        @Test(.timed(threshold: .seconds(3)))
        func `baseline - no capacity reservation 10K renders`() {
            HTML.Context.Configuration.$current.withValue(.default) {
                for _ in 0..<10_000 {
                    _ = try! String(
                        HTML.Document {
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
            HTML.Context.Configuration.$current.withValue(.default) {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTML.Document {
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
            HTML.Context.Configuration.$current.withValue(.optimized) {
                for _ in 0..<10_000 {
                    _ = try! String(
                        HTML.Document {
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
            HTML.Context.Configuration.$current.withValue(.optimized) {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTML.Document {
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
            let config = HTML.Context.Configuration(
                forceImportant: false,
                indentation: [],
                newline: [],
                reservedCapacity: 512
            )
            HTML.Context.Configuration.$current.withValue(config) {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTML.Document {
                            tag("p") { "Hello, World!" }
                        }
                    )
                }
            }
        }

        @Test(.timed(threshold: .seconds(3)))
        func `large capacity - 16KB for large docs 1K renders`() {
            let config = HTML.Context.Configuration(
                forceImportant: false,
                indentation: [],
                newline: [],
                reservedCapacity: 16384
            )
            HTML.Context.Configuration.$current.withValue(config) {
                for _ in 0..<1_000 {
                    _ = try! String(
                        HTML.Document {
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

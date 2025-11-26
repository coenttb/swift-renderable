//
//  AsyncChannel Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import AsyncAlgorithms
@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `AsyncChannel Tests` {

    // MARK: - Basic Streaming

    @Test
    func `AsyncChannel streams HTML content`() async {
        struct TestHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Hello, World!")
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncChannel(chunkSize: 4096) { TestHTML() } {
            chunks.append(chunk)
        }

        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
    }

    @Test
    func `AsyncChannel yields complete content`() async {
        struct MultiParagraphHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                Group {
                    tag("p") { HTML.Text("First") }
                    tag("p") { HTML.Text("Second") }
                    tag("p") { HTML.Text("Third") }
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096) { MultiParagraphHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
        #expect(result.contains("Third"))
    }

    // MARK: - Chunk Size

    @Test
    func `AsyncChannel respects chunk size`() async {
        struct LongContentHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 1000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncChannel(chunkSize: 100) { LongContentHTML() } {
            chunks.append(chunk)
            // Each chunk should be at most 100 bytes
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunks.count > 1)
    }

    @Test
    func `AsyncChannel with default chunk size`() async {
        struct SimpleHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
            }
        }

        var chunkCount = 0
        for await _ in AsyncChannel(chunkSize: 4096) { SimpleHTML() } {
            chunkCount += 1
        }

        // Small content should be in one chunk with default size of 4096
        #expect(chunkCount >= 1)
    }

    // MARK: - Configuration

    @Test
    func `AsyncChannel with custom configuration`() async {
        struct StyledHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
                .inlineStyle("color", "red")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096, configuration: .email) { StyledHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        // Inline styles are rendered as class names, verify div is rendered
        #expect(result.contains("<div"))
        #expect(result.contains("Content"))
    }

    @Test
    func `AsyncChannel with nil configuration uses default`() async {
        struct SpanHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("span") {
                    HTML.Text("Test")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096, configuration: nil) { SpanHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
    }

    // MARK: - Empty Content

    @Test
    func `AsyncChannel with empty content`() async {
        struct EmptyHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                Empty()
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096) { EmptyHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    // MARK: - Complex Content

    @Test
    func `AsyncChannel with nested elements`() async {
        struct NestedHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    tag("ul") {
                        tag("li") { HTML.Text("Item 1") }
                        tag("li") { HTML.Text("Item 2") }
                    }
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096) { NestedHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>"))
        #expect(result.contains("Item 1"))
        #expect(result.contains("Item 2"))
    }

    // MARK: - Convenience Method

    @Test
    func `asyncChannel convenience method`() async {
        struct ConvenienceHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Via convenience")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in ConvenienceHTML().asyncChannel(chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("Via convenience"))
    }

    @Test
    func `asyncChannel with configuration`() async {
        struct StyledHTML: HTML.View, AsyncRendering, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Styled")
                }
                .inlineStyle("margin", "0")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in StyledHTML().asyncChannel(chunkSize: 4096, configuration: .email) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("margin"))
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct AsyncChannelPerformance {
        @Test(
//            .disabled("Performance test - enable manually")
        )
        func largeContentStreaming() async {
            let itemCount = 1_000_0000

            struct ListHTML: HTML.View, AsyncRendering, Sendable {
                let items: [String]

                var body: some HTML.View {
                    tag("ul") {
                        for item in items {
                            tag("li") {
                                HTML.Text(item)
                            }
                        }
                    }
                }
            }

            print("Creating \(itemCount) items...")
            print("Time1: \(ContinuousClock.now)")
            let items = (0..<itemCount).map { "Item \($0)" }
            print("Created items, starting render...")
            print("Time2: \(ContinuousClock.now)")
            let html = ListHTML(items: items)
            print("Time3: \(ContinuousClock.now)")
            var totalBytes = 0
            var chunkCount = 0
            let startTime = ContinuousClock.now

            // Use backpressure mode for bounded memory
            for await chunk in html.asyncChannel(chunkSize: 4096) {
                if chunkCount == 0 {
                    print("Time3: \(ContinuousClock.now)")
                }
                totalBytes += chunk.count
                chunkCount += 1

                // Print progress every 1000 chunks
                if chunkCount % 1000 == 0 {
                    print("Progress: \(chunkCount) chunks, \(totalBytes) bytes")
                    print("Time4: \(ContinuousClock.now)")
                }
            }

            let elapsed = ContinuousClock.now - startTime
            print("Completed: \(itemCount) items, \(totalBytes) bytes, \(chunkCount) chunks in \(elapsed)")
            #expect(totalBytes > 0)
        }
    }
}

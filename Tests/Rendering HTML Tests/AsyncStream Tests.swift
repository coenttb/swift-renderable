//
//  AsyncStream Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `AsyncStream Tests` {

    // MARK: - Basic Streaming

    @Test
    func `AsyncStream streams HTML content`() async {
        struct TestHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Hello, World!")
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncStream(chunkSize: 4096) { TestHTML() } {
            chunks.append(chunk)
        }

        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
    }

    @Test
    func `AsyncStream yields complete content`() async {
        struct MultiParagraphHTML: HTML.View, Sendable {
            var body: some HTML.View {
                Group {
                    tag("p") { HTML.Text("First") }
                    tag("p") { HTML.Text("Second") }
                    tag("p") { HTML.Text("Third") }
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(chunkSize: 4096) { MultiParagraphHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
        #expect(result.contains("Third"))
    }

    // MARK: - Chunk Size

    @Test
    func `AsyncStream respects chunk size`() async {
        struct LongContentHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 1000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncStream(chunkSize: 100) { LongContentHTML() } {
            chunks.append(chunk)
            // Each chunk should be at most 100 bytes
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunks.count > 1)
    }

    @Test
    func `AsyncStream with default chunk size`() async {
        struct SimpleHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
            }
        }

        var chunkCount = 0
        for await _ in AsyncStream { SimpleHTML() } {
            chunkCount += 1
        }

        // Small content should be in one chunk with default size of 4096
        #expect(chunkCount >= 1)
    }

    // MARK: - Configuration

    @Test
    func `AsyncStream with custom configuration`() async {
        struct StyledHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
                .inlineStyle("color", "red")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(configuration: .email) { HTML.Document { StyledHTML() } } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("!important"))
    }

    @Test
    func `AsyncStream with nil configuration uses default`() async {
        struct SpanHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("span") {
                    HTML.Text("Test")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(configuration: nil) { SpanHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
    }

    // MARK: - Document Streaming

    @Test
    func `AsyncStream streams HTML document`() async {
        let document = HTML.Document {
            tag("main") {
                HTML.Text("Main content")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(chunkSize: 4096) { document } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<html>"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<body>"))
        #expect(result.contains("Main content"))
    }

    // MARK: - Convenience Method

    @Test
    func `asyncStreamNonThrowing convenience method`() async {
        struct ConvenienceHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Via convenience")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in ConvenienceHTML().asyncStream(chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("Via convenience"))
    }

    @Test
    func `asyncStream with configuration`() async {
        struct StyledHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Styled")
                }
                .inlineStyle("margin", "0")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in HTML.Document { StyledHTML() }.asyncStream(chunkSize: 4096, configuration: .email) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("!important"))
    }

    // MARK: - Empty Content

    @Test
    func `AsyncStream with empty content`() async {
        struct EmptyHTML: HTML.View, Sendable {
            var body: some HTML.View {
                Empty()
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(chunkSize: 4096) { EmptyHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    // MARK: - Complex Content

    @Test
    func `AsyncStream with nested elements`() async {
        struct NestedHTML: HTML.View, Sendable {
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
        for await chunk in AsyncStream(chunkSize: 4096) { NestedHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>"))
        #expect(result.contains("Item 1"))
        #expect(result.contains("Item 2"))
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct AsyncStreamPerformance {
        @Test(
//            .disabled("Performance test - enable manually")
        )
        func largeContentStreaming() async {
            let itemCount = 100_000

            struct ListHTML: HTML.View, Sendable {
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
            let items = (0..<itemCount).map { "Item \($0)" }
            print("Created items, starting render...")

            let html = ListHTML(items: items)

            var totalBytes = 0
            var chunkCount = 0
            let startTime = ContinuousClock.now

            // Use streaming mode (note: AsyncStream can't provide true backpressure)
            for await chunk in AsyncStream(mode: .streaming, chunkSize: 4096) { html } {
                totalBytes += chunk.count
                chunkCount += 1

                // Print progress every 1000 chunks
                if chunkCount % 1000 == 0 {
                    print("Progress: \(chunkCount) chunks, \(totalBytes) bytes")
                }
            }

            let elapsed = ContinuousClock.now - startTime
            print("Completed: \(itemCount) items, \(totalBytes) bytes, \(chunkCount) chunks in \(elapsed)")
            #expect(totalBytes > 0)
        }
    }
}

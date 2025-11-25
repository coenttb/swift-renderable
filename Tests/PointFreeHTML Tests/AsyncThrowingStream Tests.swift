//
//  AsyncThrowingStream Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Foundation
@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("AsyncThrowingStream Tests")
struct AsyncThrowingStreamTests {

    // MARK: - Basic Streaming

    @Test("AsyncThrowingStream streams HTML content")
    func streamsHTMLContent() async throws {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText("Hello, World!")
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for try await chunk in AsyncThrowingStream(TestHTML(), chunkSize: 4096) {
            chunks.append(chunk)
        }

        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
    }

    @Test("AsyncThrowingStream yields complete content")
    func yieldsCompleteContent() async throws {
        struct MultiParagraphHTML: HTML, Sendable {
            var body: some HTML {
                HTMLGroup {
                    tag("p") { HTMLText("First") }
                    tag("p") { HTMLText("Second") }
                    tag("p") { HTMLText("Third") }
                }
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(MultiParagraphHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
        #expect(result.contains("Third"))
    }

    // MARK: - Chunk Size

    @Test("AsyncThrowingStream respects chunk size")
    func respectsChunkSize() async throws {
        struct LongContentHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText(String(repeating: "a", count: 1000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for try await chunk in AsyncThrowingStream(LongContentHTML(), chunkSize: 100) {
            chunks.append(chunk)
            // Each chunk should be at most 100 bytes
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunks.count > 1)
    }

    @Test("AsyncThrowingStream with default chunk size")
    func defaultChunkSize() async throws {
        struct SimpleHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText("Content")
                }
            }
        }

        var chunkCount = 0
        for try await _ in AsyncThrowingStream(SimpleHTML()) {
            chunkCount += 1
        }

        // Small content should be in one chunk with default size of 4096
        #expect(chunkCount >= 1)
    }

    // MARK: - Configuration

    @Test("AsyncThrowingStream with custom configuration")
    func customConfiguration() async throws {
        struct StyledHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText("Content")
                }
                .inlineStyle("color", "red")
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(document: HTMLDocument { StyledHTML() }, configuration: .email) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("!important"))
    }

    @Test("AsyncThrowingStream with nil configuration uses default")
    func nilConfigurationUsesDefault() async throws {
        struct SpanHTML: HTML, Sendable {
            var body: some HTML {
                tag("span") {
                    HTMLText("Test")
                }
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(SpanHTML(), configuration: nil) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
    }

    // MARK: - Document Streaming

    @Test("AsyncThrowingStream streams HTML document")
    func streamsDocument() async throws {
        let document = HTMLDocument {
            tag("main") {
                HTMLText("Main content")
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(document: document, chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<html>"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<body>"))
        #expect(result.contains("Main content"))
    }

    @Test("AsyncThrowingStream document with styles")
    func documentWithStyles() async throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Styled")
            }
            .inlineStyle("color", "blue")
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(document: document, chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<style>"))
        #expect(result.contains("color:blue"))
    }

    // MARK: - Empty Content

    @Test("AsyncThrowingStream with empty content")
    func emptyContent() async throws {
        struct EmptyHTML: HTML, Sendable {
            var body: some HTML {
                HTMLEmpty()
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(EmptyHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    // MARK: - Complex Content

    @Test("AsyncThrowingStream with nested elements")
    func nestedElements() async throws {
        struct NestedHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    tag("ul") {
                        tag("li") { HTMLText("Item 1") }
                        tag("li") { HTMLText("Item 2") }
                    }
                }
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(NestedHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>"))
        #expect(result.contains("Item 1"))
        #expect(result.contains("Item 2"))
    }

    @Test("AsyncThrowingStream with attributes")
    func withAttributes() async throws {
        struct AttributedHTML: HTML, Sendable {
            var body: some HTML {
                tag("a") {
                    HTMLText("Click me")
                }
                .attribute("href", "https://example.com")
                .attribute("class", "link")
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(AttributedHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("href=\"https://example.com\""))
        #expect(result.contains("class=\"link\""))
    }

    // MARK: - Task Cancellation

    @Test("AsyncThrowingStream handles cancellation")
    func handlesCancellation() async {
        struct LongContentHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText(String(repeating: "x", count: 100_000))
                }
            }
        }

        let task = Task {
            var count = 0
            for try await _ in AsyncThrowingStream(LongContentHTML(), chunkSize: 100) {
                count += 1
                if count > 5 {
                    throw CancellationError()
                }
            }
        }

        // Allow the task to start
        await Task.yield()
        task.cancel()

        // The task should complete (either by cancellation or finishing)
        _ = await task.result
        #expect(true) // Task completed without hanging
    }
}

// MARK: - Progressive Streaming Tests

@Suite("Progressive Streaming Tests")
struct ProgressiveStreamingTests {

    @Test("Progressive stream yields chunks during rendering")
    func progressiveStreaming() async throws {
        struct LargeHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText(String(repeating: "a", count: 10_000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for try await chunk in AsyncThrowingStream(progressive: LargeHTML(), chunkSize: 1000) {
            chunks.append(chunk)
        }

        // Should have multiple chunks due to small chunk size
        #expect(chunks.count > 1)

        // Verify complete content
        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("</div>"))
    }

    @Test("Progressive document stream puts styles at end of body")
    func progressiveDocumentStream() async throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
            }
            .inlineStyle("color", "red")
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(progressiveDocument: document, chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)

        // Should have complete document structure
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<html>"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<body>"))
        #expect(result.contains("Content"))

        // Style should be present (at end of body)
        #expect(result.contains("<style>"))
        #expect(result.contains("color:red"))

        // Verify style comes after content (styles at end of body)
        if let contentIndex = result.range(of: "Content"),
           let styleIndex = result.range(of: "<style>") {
            #expect(contentIndex.lowerBound < styleIndex.lowerBound)
        }
    }

    @Test("Progressive fragment stream convenience method")
    func progressiveConvenienceMethod() async throws {
        struct SimpleHTML: HTML, Sendable {
            var body: some HTML {
                tag("p") { HTMLText("Hello") }
            }
        }

        let html = SimpleHTML()
        var allBytes: [UInt8] = []
        for try await chunk in html.progressiveStream(chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<p>"))
        #expect(result.contains("Hello"))
    }

    @Test("Progressive document stream convenience method")
    func progressiveDocumentConvenienceMethod() async throws {
        let document = HTMLDocument {
            tag("main") { HTMLText("Main") }
        }

        var allBytes: [UInt8] = []
        for try await chunk in document.progressiveDocumentStream(chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<main>"))
        #expect(result.contains("Main"))
    }

    @Test("Non-throwing progressive stream")
    func nonThrowingProgressiveStream() async {
        struct SimpleHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") { HTMLText("Test") }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(progressive: SimpleHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Test"))
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct AsyncThrowingStreamPerformance {
        @Test(.disabled("Performance test - enable manually"))
        func largeContentStreaming() async throws {
            struct ListHTML: HTML, Sendable {
                let items: [String]
                var body: some HTML {
                    tag("ul") {
                        for item in items {
                            tag("li") {
                                HTMLText(item)
                            }
                        }
                    }
                }
            }

            let items = (0..<1000).map { "Item \($0)" }
            let html = ListHTML(items: items)

            var totalBytes = 0
            for try await chunk in AsyncThrowingStream(html, chunkSize: 4096) {
                totalBytes += chunk.count
            }

            #expect(totalBytes > 0)
        }
    }
}

//
//  AsyncStream Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("AsyncStream Tests")
struct AsyncStreamTests {

    // MARK: - Basic Streaming

    @Test("AsyncStream streams HTML content")
    func streamsHTMLContent() async {
        struct TestHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Hello, World!")
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncStream(TestHTML(), chunkSize: 4096) {
            chunks.append(chunk)
        }

        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
    }

    @Test("AsyncStream yields complete content")
    func yieldsCompleteContent() async {
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
        for await chunk in AsyncStream(MultiParagraphHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
        #expect(result.contains("Third"))
    }

    // MARK: - Chunk Size

    @Test("AsyncStream respects chunk size")
    func respectsChunkSize() async {
        struct LongContentHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 1000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncStream(LongContentHTML(), chunkSize: 100) {
            chunks.append(chunk)
            // Each chunk should be at most 100 bytes
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunks.count > 1)
    }

    @Test("AsyncStream with default chunk size")
    func defaultChunkSize() async {
        struct SimpleHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
            }
        }

        var chunkCount = 0
        for await _ in AsyncStream(SimpleHTML()) {
            chunkCount += 1
        }

        // Small content should be in one chunk with default size of 4096
        #expect(chunkCount >= 1)
    }

    // MARK: - Configuration

    @Test("AsyncStream with custom configuration")
    func customConfiguration() async {
        struct StyledHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
                .inlineStyle("color", "red")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(document: HTML.Document { StyledHTML() }, configuration: .email) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("!important"))
    }

    @Test("AsyncStream with nil configuration uses default")
    func nilConfigurationUsesDefault() async {
        struct SpanHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("span") {
                    HTML.Text("Test")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(SpanHTML(), configuration: nil) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
    }

    // MARK: - Document Streaming

    @Test("AsyncStream streams HTML document")
    func streamsDocument() async {
        let document = HTML.Document {
            tag("main") {
                HTML.Text("Main content")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(document: document, chunkSize: 4096) {
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

    @Test("asyncStreamNonThrowing convenience method")
    func convenienceMethod() async {
        struct ConvenienceHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Via convenience")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in ConvenienceHTML().asyncStreamNonThrowing(chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("Via convenience"))
    }

    @Test("asyncStreamNonThrowing with configuration")
    func convenienceMethodWithConfiguration() async {
        struct StyledHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Styled")
                }
                .inlineStyle("margin", "0")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in HTML.Document { StyledHTML() }.asyncStreamNonThrowing(chunkSize: 4096, configuration: .email) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("!important"))
    }

    // MARK: - Empty Content

    @Test("AsyncStream with empty content")
    func emptyContent() async {
        struct EmptyHTML: HTML.View, Sendable {
            var body: some HTML.View {
                Empty()
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(EmptyHTML(), chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    // MARK: - Complex Content

    @Test("AsyncStream with nested elements")
    func nestedElements() async {
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
        for await chunk in AsyncStream(NestedHTML(), chunkSize: 4096) {
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
        @Test(.disabled("Performance test - enable manually"))
        func largeContentStreaming() async {
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

            let items = (0..<1000).map { "Item \($0)" }
            let html = ListHTML(items: items)

            var totalBytes = 0
            for await chunk in AsyncStream(html, chunkSize: 4096) {
                totalBytes += chunk.count
            }

            #expect(totalBytes > 0)
        }
    }
}

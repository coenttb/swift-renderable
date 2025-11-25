//
//  Async Streaming Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import PointFreeHTML
import Testing

@Suite("Async HTML Streaming Tests")
struct AsyncStreamingTests {

    // MARK: - Basic Async Streaming

    @Test("asyncStream yields byte chunks")
    func asyncStreamYieldsChunks() async throws {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") { HTMLText("Hello, World!") }
            }
        }

        let html = TestHTML()
        var collectedBytes: [UInt8] = []

        // Using the authoritative init-based API
        for try await chunk in AsyncThrowingStream(html, chunkSize: 10) {
            collectedBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: collectedBytes, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
        #expect(result.contains("</div>"))
    }

    @Test("asyncStream output matches sync bytes")
    func asyncStreamMatchesSyncBytes() async throws {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    tag("h1") { HTMLText("Title") }
                    tag("p") { HTMLText("Paragraph content") }
                }
            }
        }

        let html = TestHTML()

        // Get sync output
        let syncBytes = html.bytes

        // Get async output
        var asyncBytes: [UInt8] = []
        for try await chunk in html.asyncStream() {
            asyncBytes.append(contentsOf: chunk)
        }

        #expect(syncBytes == asyncBytes)
    }

    @Test("asyncStreamNonThrowing yields chunks")
    func asyncStreamNonThrowingYieldsChunks() async {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("span") { HTMLText("Non-throwing test") }
            }
        }

        let html = TestHTML()
        var collectedBytes: [UInt8] = []

        for await chunk in html.asyncStreamNonThrowing(chunkSize: 5) {
            collectedBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: collectedBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
        #expect(result.contains("Non-throwing test"))
    }

    // MARK: - Async Bytes and String

    @Test("asyncBytes returns complete bytes")
    func asyncBytesReturnsCompleteBytes() async {
        let html = tag("p") { HTMLText("Async bytes test") }

        let asyncResult = await html.asyncBytes()
        let syncResult = html.bytes

        #expect(asyncResult == syncResult)
    }

    @Test("asyncString returns complete string")
    func asyncStringReturnsCompleteString() async throws {
        let html = tag("div") {
            tag("h1") { HTMLText("Header") }
            tag("p") { HTMLText("Content") }
        }

        let asyncResult = await html.asyncString()
        let syncResult = String(decoding: html.bytes, as: UTF8.self)

        #expect(asyncResult == syncResult)
    }

    // MARK: - Chunk Size Variations

    @Test("asyncStream respects chunk size")
    func asyncStreamRespectsChunkSize() async throws {
        struct LargeHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLForEach(1...20) { i in
                        tag("p") { HTMLText("Paragraph \(i) with some content") }
                    }
                }
            }
        }

        let html = LargeHTML()
        var chunkCount = 0
        var totalBytes = 0

        for try await chunk in html.asyncStream(chunkSize: 100) {
            chunkCount += 1
            totalBytes += chunk.count
            // Each chunk (except possibly the last) should be at most chunkSize
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunkCount > 1)
        #expect(totalBytes > 0)
    }

    @Test("asyncStream with large chunk size yields fewer chunks")
    func asyncStreamLargeChunkSize() async throws {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") { HTMLText("Small content") }
            }
        }

        let html = TestHTML()
        var chunkCount = 0

        // Very large chunk size should yield single chunk
        for try await _ in html.asyncStream(chunkSize: 100_000) {
            chunkCount += 1
        }

        #expect(chunkCount == 1)
    }

    // MARK: - Complex HTML Streaming

    @Test("asyncStream handles nested HTML")
    func asyncStreamHandlesNestedHTML() async throws {
        struct NestedHTML: HTML, Sendable {
            var body: some HTML {
                tag("html") {
                    tag("head") {
                        tag("title") { HTMLText("Test Page") }
                    }
                    tag("body") {
                        tag("header") {
                            tag("nav") {
                                tag("a") { HTMLText("Home") }.attribute("href", "/")
                                tag("a") { HTMLText("About") }.attribute("href", "/about")
                            }
                        }
                        tag("main") {
                            tag("h1") { HTMLText("Welcome") }
                            tag("p") { HTMLText("This is content.") }
                        }
                        tag("footer") {
                            HTMLText("Copyright 2025")
                        }
                    }
                }
            }
        }

        let html = NestedHTML()
        var asyncBytes: [UInt8] = []

        for try await chunk in html.asyncStream() {
            asyncBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: asyncBytes, as: UTF8.self)
        #expect(result.contains("<html>"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<title>Test Page</title>"))
        #expect(result.contains("<nav>"))
        #expect(result.contains("href=\"/\""))
        #expect(result.contains("<main>"))
        #expect(result.contains("<footer>"))
        #expect(result.contains("</html>"))
    }

    @Test("asyncStream handles attributes and styles")
    func asyncStreamHandlesAttributesAndStyles() async throws {
        struct StyledHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    tag("p") { HTMLText("Styled text") }
                        .attribute("class", "highlight")
                        .inlineStyle("color", "red")
                }
                .attribute("id", "main-container")
            }
        }

        let html = StyledHTML()
        let asyncResult = await html.asyncString()
        let syncResult = html.bytes

        #expect(asyncResult == String(decoding: syncResult, as: UTF8.self))
        #expect(asyncResult.contains("id=\"main-container\""))
        #expect(asyncResult.contains("class=\"highlight\""))
    }

    // MARK: - Custom HTML Types

    @Test("asyncStream works with custom Sendable HTML types")
    func asyncStreamWithCustomTypes() async throws {
        struct Card: HTML, Sendable {
            let title: String
            let content: String

            var body: some HTML {
                tag("article") {
                    tag("h2") { HTMLText(title) }
                    tag("p") { HTMLText(content) }
                }
                .attribute("class", "card")
            }
        }

        let card = Card(title: "Test Card", content: "Card content here")
        var asyncBytes: [UInt8] = []

        for try await chunk in card.asyncStream() {
            asyncBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: asyncBytes, as: UTF8.self)
        #expect(result.contains("<article"))
        #expect(result.contains("class=\"card\""))
        #expect(result.contains("Test Card"))
        #expect(result.contains("Card content here"))
    }

    // MARK: - Conditional Content

    @Test("asyncStream handles conditional content")
    func asyncStreamHandlesConditionalContent() async throws {
        struct ConditionalHTML: HTML, Sendable {
            let showExtra: Bool

            var body: some HTML {
                tag("div") {
                    tag("p") { HTMLText("Always shown") }
                    if showExtra {
                        tag("p") { HTMLText("Extra content") }
                    }
                }
            }
        }

        let withExtra = ConditionalHTML(showExtra: true)
        let withoutExtra = ConditionalHTML(showExtra: false)

        let resultWithExtra = await withExtra.asyncString()
        let resultWithoutExtra = await withoutExtra.asyncString()

        #expect(resultWithExtra.contains("Extra content"))
        #expect(!resultWithoutExtra.contains("Extra content"))
        #expect(resultWithExtra.contains("Always shown"))
        #expect(resultWithoutExtra.contains("Always shown"))
    }

    // MARK: - Empty Content

    @Test("asyncStream handles empty content")
    func asyncStreamHandlesEmptyContent() async throws {
        struct EmptyHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLEmpty()
                }
            }
        }

        let html = EmptyHTML()
        let asyncResult = await html.asyncString()

        #expect(asyncResult.contains("<div>"))
        #expect(asyncResult.contains("</div>"))
    }
}

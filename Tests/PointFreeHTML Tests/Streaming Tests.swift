//
//  Streaming Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import PointFreeHTML
import Testing

@Suite("HTML Streaming Tests")
struct StreamingTests {

    // MARK: - Basic Streaming API

    @Test("serialize(into:) writes bytes to buffer")
    func serializeIntoBuffer() {
        let html = tag("div") { HTMLText("Hello") }

        var buffer: [UInt8] = []
        html.serialize(into: &buffer)

        let result = String(decoding: buffer, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello"))
        #expect(result.contains("</div>"))
    }

    @Test("bytes property returns serialized bytes")
    func bytesProperty() {
        let html = tag("p") { HTMLText("Test content") }

        let bytes = html.bytes
        let result = String(decoding: bytes, as: UTF8.self)

        #expect(result.contains("<p>"))
        #expect(result.contains("Test content"))
        #expect(result.contains("</p>"))
    }

    @Test("streaming output matches HTMLPrinter output")
    func streamingMatchesPrinter() throws {
        let html = tag("div") {
            tag("h1") { HTMLText("Title") }
            tag("p") { HTMLText("Paragraph") }
        }

        // Get output via traditional HTMLPrinter
        let printerOutput = try String(html)

        // Get output via streaming
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    // MARK: - Different Buffer Types

    @Test("works with ContiguousArray buffer")
    func contiguousArrayBuffer() {
        let html = tag("span") { HTMLText("text") }

        var buffer = ContiguousArray<UInt8>()
        html.serialize(into: &buffer)

        let result = String(decoding: Array(buffer), as: UTF8.self)
        #expect(result.contains("<span>"))
        #expect(result.contains("text"))
    }

    @Test("works with Data-like buffer")
    func dataLikeBuffer() {
        let html = tag("div") { HTMLText("content") }

        var buffer: [UInt8] = []
        buffer.reserveCapacity(1000)  // Pre-allocate
        html.serialize(into: &buffer)

        #expect(buffer.count > 0)
        let result = String(decoding: buffer, as: UTF8.self)
        #expect(result.contains("content"))
    }

    // MARK: - Attribute Streaming

    @Test("attributes are streamed correctly")
    func attributeStreaming() throws {
        let html = tag("div") { HTMLText("Hello") }
            .attribute("class", "container")
            .attribute("id", "main")

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
        #expect(streamingOutput.contains("class=\"container\""))
        #expect(streamingOutput.contains("id=\"main\""))
    }

    @Test("attribute escaping in streaming")
    func attributeEscapingStreaming() throws {
        let html = tag("div") { HTMLText("Content") }
            .attribute("data-value", "test\"with<special>&chars")

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    // MARK: - Text Content Streaming

    @Test("text escaping in streaming")
    func textEscapingStreaming() throws {
        let html = tag("p") { HTMLText("Hello <world> & \"friends\"") }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
        #expect(streamingOutput.contains("&lt;"))
        #expect(streamingOutput.contains("&gt;"))
        #expect(streamingOutput.contains("&amp;"))
    }

    // MARK: - Complex HTML Streaming

    @Test("nested elements stream correctly")
    func nestedElementStreaming() throws {
        let html = tag("div") {
            tag("header") {
                tag("nav") {
                    tag("a") { HTMLText("Link 1") }.attribute("href", "/page1")
                    tag("a") { HTMLText("Link 2") }.attribute("href", "/page2")
                }
            }
            tag("main") {
                tag("article") {
                    tag("h1") { HTMLText("Article Title") }
                    tag("p") { HTMLText("First paragraph") }
                    tag("p") { HTMLText("Second paragraph") }
                }
            }
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    @Test("conditional content streams correctly")
    func conditionalContentStreaming() throws {
        let showExtra = true

        let html = tag("div") {
            tag("p") { HTMLText("Always shown") }
            if showExtra {
                tag("p") { HTMLText("Conditionally shown") }
            }
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    @Test("optional content streams correctly")
    func optionalContentStreaming() throws {
        let maybeContent: String? = "Optional text"

        let html = tag("div") {
            if let content = maybeContent {
                tag("p") { HTMLText(content) }
            }
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    // MARK: - Inline Styles Streaming

    @Test("inline styles stream correctly")
    func inlineStyleStreaming() throws {
        let html = tag("div") {
            tag("p") { HTMLText("Styled text") }
                .inlineStyle("color", "red")
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    // MARK: - Raw HTML Streaming

    @Test("raw HTML streams correctly")
    func rawHTMLStreaming() throws {
        let html = tag("div") {
            HTMLRaw("<script>alert('test');</script>")
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
        #expect(streamingOutput.contains("<script>alert('test');</script>"))
    }

    // MARK: - Empty Content Streaming

    @Test("empty content streams correctly")
    func emptyContentStreaming() throws {
        let html = tag("div") {
            HTMLEmpty()
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    // MARK: - Custom HTML Types

    @Test("custom HTML types stream correctly")
    func customHTMLTypeStreaming() throws {
        struct Card: HTML {
            let title: String
            let content: String

            var body: some HTML {
                tag("div") {
                    tag("h2") { HTMLText(title) }
                    tag("p") { HTMLText(content) }
                }
                .attribute("class", "card")
            }
        }

        let html = Card(title: "My Card", content: "Card content here")

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }

    // MARK: - Void Elements

    @Test("void elements stream correctly")
    func voidElementStreaming() throws {
        let html = tag("div") {
            tag("input").attribute("type", "text")
            tag("br")
            tag("img").attribute("src", "image.png")
        }

        let printerOutput = try String(html)
        let streamingOutput = String(decoding: html.bytes, as: UTF8.self)

        #expect(printerOutput == streamingOutput)
    }
}

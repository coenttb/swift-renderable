//
//  ContiguousArray<UInt8> Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("ContiguousArray<UInt8> Tests")
struct ContiguousArrayUInt8Tests {

    // MARK: - Initialization

    @Test("ContiguousArray init from HTML")
    func initFromHTML() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<div>"))
        #expect(string.contains("Content"))
        #expect(string.contains("</div>"))
    }

    @Test("ContiguousArray init from empty HTML")
    func initFromEmptyHTML() throws {
        let html = Empty()
        let bytes = ContiguousArray<UInt8>(html)
        #expect(bytes.isEmpty)
    }

    @Test("ContiguousArray init from HTMLText")
    func initFromHTMLText() throws {
        let html = HTMLText("Hello, World!")
        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string == "Hello, World!")
    }

    // MARK: - Complex HTML

    @Test("ContiguousArray with nested elements")
    func nestedElements() throws {
        let html = tag("article") {
            tag("header") {
                tag("h1") {
                    HTMLText("Title")
                }
            }
            tag("section") {
                tag("p") {
                    HTMLText("Paragraph 1")
                }
                tag("p") {
                    HTMLText("Paragraph 2")
                }
            }
        }
        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<article>"))
        #expect(string.contains("<header>"))
        #expect(string.contains("<section>"))
        #expect(string.contains("Paragraph 1"))
        #expect(string.contains("Paragraph 2"))
    }

    @Test("ContiguousArray with attributes")
    func withAttributes() throws {
        let html = tag("a") {
            HTMLText("Link")
        }
        .attribute("href", "https://example.com")
        .attribute("target", "_blank")

        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("href=\"https://example.com\""))
        #expect(string.contains("target=\"_blank\""))
    }

    // MARK: - Document Rendering

    @Test("ContiguousArray from HTMLDocument")
    func fromHTMLDocument() throws {
        let document = HTMLDocument {
            tag("p") {
                HTMLText("Hello")
            }
        } head: {
            tag("title") {
                HTMLText("Test")
            }
        }

        let bytes = ContiguousArray<UInt8>(document)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<!doctype html>"))
        #expect(string.contains("<title>Test"))
        #expect(string.contains("Hello"))
    }

    // MARK: - Escaping

    @Test("ContiguousArray properly escapes content")
    func properlyEscapes() throws {
        let html = tag("div") {
            HTMLText("Special chars: < > & \"test\"")
        }
        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("&lt;"))
        #expect(string.contains("&gt;"))
        #expect(string.contains("&amp;"))
    }

    @Test("ContiguousArray escapes attribute values")
    func escapesAttributeValues() throws {
        let html = tag("input")
            .attribute("value", "Say \"Hello\" & <bye>")

        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("&quot;Hello&quot;"))
        #expect(string.contains("&amp;"))
        #expect(string.contains("&lt;bye&gt;"))
    }

    // MARK: - Configuration

    @Test("ContiguousArray uses task-local configuration")
    func usesTaskLocalConfiguration() throws {
        let html = tag("div") {
            HTMLText("Content")
        }

        HTMLContext.Rendering.$current.withValue(.pretty) {
            let bytes = ContiguousArray<UInt8>(html)
            let string = String(decoding: bytes, as: UTF8.self)
            // Pretty configuration adds indentation
            #expect(string.contains("<div>"))
        }
    }

    // MARK: - Performance Characteristics

    @Test("ContiguousArray is efficient for large documents")
    func efficientForLargeDocuments() throws {
        // Create a moderately large document
        let html = Group {
            for i in 0..<100 {
                tag("div") {
                    tag("h2") {
                        HTMLText("Section \(i)")
                    }
                    tag("p") {
                        HTMLText("Content for section \(i)")
                    }
                }
            }
        }

        let bytes = ContiguousArray<UInt8>(html)
        #expect(bytes.count > 0)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("Section 0"))
        #expect(string.contains("Section 99"))
    }

    // MARK: - Unicode Support

    @Test("ContiguousArray preserves Unicode")
    func preservesUnicode() throws {
        let html = tag("p") {
            HTMLText("Unicode: 中文 日本語 한국어 🌍")
        }
        let bytes = ContiguousArray<UInt8>(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("中文"))
        #expect(string.contains("日本語"))
        #expect(string.contains("한국어"))
        #expect(string.contains("🌍"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct ContiguousArraySnapshotTests {
        @Test("ContiguousArray document rendering snapshot")
        func documentRenderingSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("main") {
                        tag("h1") {
                            HTMLText("ContiguousArray Test")
                        }
                        tag("p") {
                            HTMLText("Testing canonical byte transformation")
                        }
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>

                    </style>
                  </head>
                  <body>
                <main>
                  <h1>ContiguousArray Test
                  </h1>
                  <p>Testing canonical byte transformation
                  </p>
                </main>
                  </body>
                </html>
                """
            }
        }
    }
}

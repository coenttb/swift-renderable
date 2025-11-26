//
//  [UInt8] Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("[UInt8] Tests")
struct UInt8ArrayTests {

    // MARK: - Synchronous Initialization

    @Test("[UInt8] init from HTML")
    func initFromHTML() throws {
        let html = tag("div") {
            HTML.Text("Hello")
        }
        let bytes = [UInt8](html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<div>"))
        #expect(string.contains("Hello"))
        #expect(string.contains("</div>"))
    }

    @Test("[UInt8] init from empty HTML")
    func initFromEmptyHTML() throws {
        let html = Empty()
        let bytes = [UInt8](html)
        #expect(bytes.isEmpty)
    }

    @Test("[UInt8] init from complex HTML")
    func initFromComplexHTML() throws {
        let html = Group {
            tag("div") {
                tag("h1") {
                    HTML.Text("Title")
                }
                tag("p") {
                    HTML.Text("Content with & special < chars >")
                }
            }
        }
        let bytes = [UInt8](html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("&amp;"))
        #expect(string.contains("&lt;"))
        #expect(string.contains("&gt;"))
    }

    // MARK: - Async Initialization

    @Test("[UInt8] async init from HTML")
    func asyncInitFromHTML() async {
        let html = tag("span") {
            HTML.Text("Async content")
        }
        let bytes = await [UInt8](html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<span>"))
        #expect(string.contains("Async content"))
    }

    @Test("[UInt8] async init with configuration")
    func asyncInitWithConfiguration() async {
        let html = tag("div") {
            HTML.Text("Configured")
        }
        let bytes = await [UInt8](html, configuration: .pretty)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<div>"))
    }

    @Test("[UInt8] async init from document")
    func asyncInitFromDocument() async {
        let document = HTML.Document {
            tag("p") {
                HTML.Text("Document content")
            }
        }
        let bytes = await [UInt8](document: document)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<!doctype html>"))
        #expect(string.contains("Document content"))
    }

    // MARK: - HTML Entity Constants

    @Test("[UInt8] htmlEntityQuot")
    func htmlEntityQuot() {
        let entity = [UInt8].html.doubleQuotationMark
        let string = String(decoding: entity, as: UTF8.self)
        #expect(string == "&quot;")
    }

    @Test("[UInt8] htmlEntityApos")
    func htmlEntityApos() {
        let entity = [UInt8].html.apostrophe
        let string = String(decoding: entity, as: UTF8.self)
        #expect(string == "&#39;")
    }

    @Test("[UInt8] htmlEntityAmp")
    func htmlEntityAmp() {
        let entity = [UInt8].html.ampersand
        let string = String(decoding: entity, as: UTF8.self)
        #expect(string == "&amp;")
    }

    @Test("[UInt8] htmlEntityLt")
    func htmlEntityLt() {
        let entity = [UInt8].html.lessThan
        let string = String(decoding: entity, as: UTF8.self)
        #expect(string == "&lt;")
    }

    @Test("[UInt8] htmlEntityGt")
    func htmlEntityGt() {
        let entity = [UInt8].html.greaterThan
        let string = String(decoding: entity, as: UTF8.self)
        #expect(string == "&gt;")
    }

    // MARK: - asyncBytes Extension

    @Test("HTML asyncBytes method")
    func asyncBytesMethod() async {
        let html = tag("article") {
            HTML.Text("Async bytes content")
        }
        let bytes = await html.asyncBytes()
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<article>"))
        #expect(string.contains("Async bytes content"))
    }

    @Test("HTML asyncBytes with configuration")
    func asyncBytesWithConfiguration() async {
        let html = tag("section") {
            HTML.Text("Configured bytes")
        }
        let bytes = await html.asyncBytes(configuration: .pretty)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<section>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct UInt8ArraySnapshotTests {
        @Test("[UInt8] document rendering snapshot")
        func documentRenderingSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("main") {
                        tag("h1") {
                            HTML.Text("Byte Array Test")
                        }
                        tag("p") {
                            HTML.Text("Testing [UInt8] rendering path")
                        }
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <main>
                      <h1>Byte Array Test
                      </h1>
                      <p>Testing [UInt8] rendering path
                      </p>
                    </main>
                  </body>
                </html>
                """
            }
        }
    }
}

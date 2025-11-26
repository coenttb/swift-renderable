////
////  ContiguousArray<UInt8> Tests.swift
////  pointfree-html
////
////  Created by Coen ten Thije Boonkkamp on 25/11/2025.
////
//
//@testable import Rendering_HTML
//import Rendering_HTML_TestSupport
//import Testing
//
//@Suite("ContiguousArray<UInt8> Tests")
//struct ContiguousArrayUInt8Tests {
//
//    // MARK: - Initialization
//
//    @Test("ContiguousArray init from HTML")
//    func initFromHTML() throws {
//        let html = tag("div") {
//            HTML.Text("Content")
//        }
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("<div>"))
//        #expect(string.contains("Content"))
//        #expect(string.contains("</div>"))
//    }
//
//    @Test("ContiguousArray init from empty HTML")
//    func initFromEmptyHTML() throws {
//        let html = Empty()
//        let bytes = ContiguousArray<UInt8>(html)
//        #expect(bytes.isEmpty)
//    }
//
//    @Test("ContiguousArray init from HTML.Text")
//    func initFromHTMLText() throws {
//        let html = HTML.Text("Hello, World!")
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string == "Hello, World!")
//    }
//
//    // MARK: - Complex HTML
//
//    @Test("ContiguousArray with nested elements")
//    func nestedElements() throws {
//        let html = tag("article") {
//            tag("header") {
//                tag("h1") {
//                    HTML.Text("Title")
//                }
//            }
//            tag("section") {
//                tag("p") {
//                    HTML.Text("Paragraph 1")
//                }
//                tag("p") {
//                    HTML.Text("Paragraph 2")
//                }
//            }
//        }
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("<article>"))
//        #expect(string.contains("<header>"))
//        #expect(string.contains("<section>"))
//        #expect(string.contains("Paragraph 1"))
//        #expect(string.contains("Paragraph 2"))
//    }
//
//    @Test("ContiguousArray with attributes")
//    func withAttributes() throws {
//        let html = tag("a") {
//            HTML.Text("Link")
//        }
//        .attribute("href", "https://example.com")
//        .attribute("target", "_blank")
//
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("href=\"https://example.com\""))
//        #expect(string.contains("target=\"_blank\""))
//    }
//
//    // MARK: - Document Rendering
//
//    @Test("ContiguousArray from HTMLDocument")
//    func fromHTMLDocument() throws {
//        let document = HTML.Document {
//            tag("p") {
//                HTML.Text("Hello")
//            }
//        } head: {
//            tag("title") {
//                HTML.Text("Test")
//            }
//        }
//
//        let bytes = ContiguousArray<UInt8>(document)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("<!doctype html>"))
//        #expect(string.contains("<title>Test"))
//        #expect(string.contains("Hello"))
//    }
//
//    // MARK: - Escaping
//
//    @Test("ContiguousArray properly escapes content")
//    func properlyEscapes() throws {
//        let html = tag("div") {
//            HTML.Text("Special chars: < > & \"test\"")
//        }
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("&lt;"))
//        #expect(string.contains("&gt;"))
//        #expect(string.contains("&amp;"))
//    }
//
//    @Test("ContiguousArray escapes attribute values")
//    func escapesAttributeValues() throws {
//        let html = tag("input")
//            .attribute("value", "Say \"Hello\" & <bye>")
//
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("&quot;Hello&quot;"))
//        #expect(string.contains("&amp;"))
//        #expect(string.contains("&lt;bye&gt;"))
//    }
//
//    // MARK: - Configuration
//
//    @Test("ContiguousArray uses task-local configuration")
//    func usesTaskLocalConfiguration() throws {
//        let html = tag("div") {
//            HTML.Text("Content")
//        }
//
//        HTML.Context.Configuration.$current.withValue(.pretty) {
//            let bytes = ContiguousArray<UInt8>(html)
//            let string = String(decoding: bytes, as: UTF8.self)
//            // Pretty configuration adds indentation
//            #expect(string.contains("<div>"))
//        }
//    }
//
//    // MARK: - Performance Characteristics
//
//    @Test("ContiguousArray is efficient for large documents")
//    func efficientForLargeDocuments() throws {
//        // Create a moderately large document
//        let html = Group {
//            for i in 0..<100 {
//                tag("div") {
//                    tag("h2") {
//                        HTML.Text("Section \(i)")
//                    }
//                    tag("p") {
//                        HTML.Text("Content for section \(i)")
//                    }
//                }
//            }
//        }
//
//        let bytes = ContiguousArray<UInt8>(html)
//        #expect(bytes.count > 0)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("Section 0"))
//        #expect(string.contains("Section 99"))
//    }
//
//    // MARK: - Unicode Support
//
//    @Test("ContiguousArray preserves Unicode")
//    func preservesUnicode() throws {
//        let html = tag("p") {
//            HTML.Text("Unicode: 中文 日本語 한국어 🌍")
//        }
//        let bytes = ContiguousArray<UInt8>(html)
//        let string = String(decoding: bytes, as: UTF8.self)
//        #expect(string.contains("中文"))
//        #expect(string.contains("日本語"))
//        #expect(string.contains("한국어"))
//        #expect(string.contains("🌍"))
//    }
//}
//
//// MARK: - Snapshot Tests
//
//extension `Snapshot Tests` {
//    @Suite
//    struct ContiguousArraySnapshotTests {
//        @Test("ContiguousArray document rendering snapshot")
//        func documentRenderingSnapshot() {
//            assertInlineSnapshot(
//                of: HTML.Document {
//                    tag("main") {
//                        tag("h1") {
//                            HTML.Text("ContiguousArray Test")
//                        }
//                        tag("p") {
//                            HTML.Text("Testing canonical byte transformation")
//                        }
//                    }
//                },
//                as: .html
//            ) {
//                """
//                <!doctype html>
//                <html>
//                  <head>
//                  </head>
//                  <body>
//                    <main>
//                      <h1>ContiguousArray Test
//                      </h1>
//                      <p>Testing canonical byte transformation
//                      </p>
//                    </main>
//                  </body>
//                </html>
//                """
//            }
//        }
//    }
//}

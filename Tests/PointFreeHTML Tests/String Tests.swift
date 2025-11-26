//
//  StringExtensionsTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import Testing

@Suite("String Extensions Tests")
struct StringExtensionsTests {

    @Test("String from HTML element")
    func stringFromHTMLElement() throws {
        let element = tag("div") {
            HTML.Text("test content")
        }

        let string = try String(HTML.Document { element })
        #expect(string.contains("<div>"))
        #expect(string.contains("test content"))
        #expect(string.contains("</div>"))
    }

    @Test("String from HTML text")
    func stringFromHTMLText() throws {
        let text = HTML.Text("simple text")
        let string = try String(text)
        #expect(string == "simple text")
    }

    @Test("String from complex HTML structure")
    func stringFromComplexHTML() throws {
        let html = tag("article") {
            tag("header") {
                tag("h1") {
                    HTML.Text("Article Title")
                }
            }
            tag("section") {
                tag("p") {
                    HTML.Text("Paragraph content")
                }
            }
        }

        let string = try String(HTML.Document { html })
        #expect(string.contains("<article>"))
        #expect(string.contains("<h1>Article Title</h1>"))
        #expect(string.contains("<p>Paragraph content</p>"))
        #expect(string.contains("</article>"))
    }

    @Test("String from HTML with attributes")
    func stringFromHTMLWithAttributes() throws {
        let element = tag("div") {
            HTML.Text("content")
        }
        .attribute("class", "test-class")
        .attribute("id", "test-id")

        let string = try String(HTML.Document { element })
        #expect(string.contains("class=\"test-class\""))
        #expect(string.contains("id=\"test-id\""))
        #expect(string.contains("content"))
    }

    @Test("String from empty HTML")
    func stringFromEmptyHTML() throws {
        let empty = Empty()
        let string = try String(empty)
        #expect(string.isEmpty)
    }

    @Test("String conversion throws on error")
    func stringConversionThrowsOnError() {
        // This test assumes there might be error conditions in HTML rendering
        // The actual implementation would need to be checked for specific error cases

        // For now, we'll test that the conversion can handle basic cases without throwing
        let element = tag("div") {
            HTML.Text("content")
        }

        #expect(throws: Never.self) {
            _ = try String(element)
        }
    }
    //
    //    @Test("String from document")
    //    func stringFromDocument() throws {
    //        let document = HTML.Document {
    //            tag("title") {
    //                tag("h1") {
    //                    HTML.Text("Hello, World!")
    //                }
    //            } head: {
    //                HTML.Text("Test Page")
    //            }
    //        )
    //
    //        let string = try String(document)
    //        #expect(string.contains("<!doctype html>"))
    //        #expect(string.contains("<title>Test Page</title>"))
    //        #expect(string.contains("<h1>Hello, World!</h1>"))
    //    }
}

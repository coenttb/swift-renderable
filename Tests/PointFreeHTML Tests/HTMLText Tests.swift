//
//  HTMLText Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTMLText Tests")
struct HTMLTextTests {

    // MARK: - Initialization

    @Test("HTMLText basic initialization")
    func basicInitialization() throws {
        let text = HTMLText("Hello, World!")
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    @Test("HTMLText empty string")
    func emptyString() throws {
        let text = HTMLText("")
        let rendered = try String(text)
        #expect(rendered.isEmpty)
    }

    @Test("HTMLText string literal initialization")
    func stringLiteralInitialization() throws {
        let text: HTMLText = "Hello from literal"
        let rendered = try String(text)
        #expect(rendered == "Hello from literal")
    }

    @Test("HTMLText string interpolation")
    func stringInterpolation() throws {
        let name = "World"
        let text: HTMLText = "Hello, \(name)!"
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    // MARK: - HTML Escaping

    @Test("HTMLText escapes ampersand")
    func escapesAmpersand() throws {
        let text = HTMLText("Rock & Roll")
        let rendered = try String(text)
        #expect(rendered == "Rock &amp; Roll")
    }

    @Test("HTMLText escapes less than")
    func escapesLessThan() throws {
        let text = HTMLText("a < b")
        let rendered = try String(text)
        #expect(rendered == "a &lt; b")
    }

    @Test("HTMLText escapes greater than")
    func escapesGreaterThan() throws {
        let text = HTMLText("a > b")
        let rendered = try String(text)
        #expect(rendered == "a &gt; b")
    }

    @Test("HTMLText escapes multiple special characters")
    func escapesMultipleSpecialCharacters() throws {
        let text = HTMLText("<script>alert('XSS');</script>")
        let rendered = try String(text)
        #expect(rendered == "&lt;script&gt;alert('XSS');&lt;/script&gt;")
    }

    @Test("HTMLText preserves quotes - not escaped in text content")
    func preservesQuotes() throws {
        let text = HTMLText("He said \"Hello\"")
        let rendered = try String(text)
        #expect(rendered == "He said \"Hello\"")
    }

    @Test("HTMLText preserves single quotes")
    func preservesSingleQuotes() throws {
        let text = HTMLText("It's working")
        let rendered = try String(text)
        #expect(rendered == "It's working")
    }

    // MARK: - Concatenation

    @Test("HTMLText concatenation with + operator")
    func concatenationWithOperator() throws {
        let hello = HTMLText("Hello, ")
        let world = HTMLText("World!")
        let combined = hello + world
        let rendered = try String(combined)
        #expect(rendered == "Hello, World!")
    }

    @Test("HTMLText concatenation preserves escaping")
    func concatenationPreservesEscaping() throws {
        let left = HTMLText("A & B")
        let right = HTMLText(" < C")
        let combined = left + right
        let rendered = try String(combined)
        #expect(rendered == "A &amp; B &lt; C")
    }

    // MARK: - Unicode

    @Test("HTMLText preserves Unicode characters")
    func preservesUnicode() throws {
        let text = HTMLText("Hello, 世界! 🌍")
        let rendered = try String(text)
        #expect(rendered == "Hello, 世界! 🌍")
    }

    @Test("HTMLText preserves emoji")
    func preservesEmoji() throws {
        let text = HTMLText("👍🏽 Great job!")
        let rendered = try String(text)
        #expect(rendered == "👍🏽 Great job!")
    }

    // MARK: - Edge Cases

    @Test("HTMLText with newlines")
    func withNewlines() throws {
        let text = HTMLText("Line 1\nLine 2\nLine 3")
        let rendered = try String(text)
        #expect(rendered == "Line 1\nLine 2\nLine 3")
    }

    @Test("HTMLText with tabs")
    func withTabs() throws {
        let text = HTMLText("Col1\tCol2\tCol3")
        let rendered = try String(text)
        #expect(rendered == "Col1\tCol2\tCol3")
    }

    @Test("HTMLText in document context")
    func inDocumentContext() throws {
        let document = Document {
            tag("p") {
                HTMLText("This is & that")
            }
        }
        let rendered = try String(document)
        #expect(rendered.contains("This is &amp; that"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLTextSnapshotTests {
        @Test("HTMLText basic rendering snapshot")
        func basicRenderingSnapshot() {
            assertInlineSnapshot(
                of: Document {
                    tag("div") {
                        tag("h1") {
                            HTMLText("Welcome & Hello")
                        }
                        tag("p") {
                            HTMLText("This is a paragraph with <special> characters & symbols.")
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
                    <div>
                      <h1>Welcome &amp; Hello
                      </h1>
                      <p>This is a paragraph with &lt;special&gt; characters &amp; symbols.
                      </p>
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("HTMLText with various content types snapshot")
        func variousContentSnapshot() {
            assertInlineSnapshot(
                of: Document {
                    tag("article") {
                        tag("h2") {
                            HTMLText("Code Examples")
                        }
                        tag("p") {
                            HTMLText("In HTML, use &lt;tag&gt; syntax (shown escaped).")
                        }
                        tag("p") {
                            HTMLText("Copyright © 2025 - All rights reserved")
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
                    <article>
                      <h2>Code Examples
                      </h2>
                      <p>In HTML, use &amp;lt;tag&amp;gt; syntax (shown escaped).
                      </p>
                      <p>Copyright © 2025 - All rights reserved
                      </p>
                    </article>
                  </body>
                </html>
                """
            }
        }
    }
}

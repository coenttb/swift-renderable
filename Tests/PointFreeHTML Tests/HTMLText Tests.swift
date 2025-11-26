//
//  HTML.Text Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTML.Text Tests")
struct HTMLTextTests {

    // MARK: - Initialization

    @Test("HTML.Text basic initialization")
    func basicInitialization() throws {
        let text = HTML.Text("Hello, World!")
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    @Test("HTML.Text empty string")
    func emptyString() throws {
        let text = HTML.Text("")
        let rendered = try String(text)
        #expect(rendered.isEmpty)
    }

    @Test("HTML.Text string literal initialization")
    func stringLiteralInitialization() throws {
        let text: HTML.Text = "Hello from literal"
        let rendered = try String(text)
        #expect(rendered == "Hello from literal")
    }

    @Test("HTML.Text string interpolation")
    func stringInterpolation() throws {
        let name = "World"
        let text: HTML.Text = "Hello, \(name)!"
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    // MARK: - HTML Escaping

    @Test("HTML.Text escapes ampersand")
    func escapesAmpersand() throws {
        let text = HTML.Text("Rock & Roll")
        let rendered = try String(text)
        #expect(rendered == "Rock &amp; Roll")
    }

    @Test("HTML.Text escapes less than")
    func escapesLessThan() throws {
        let text = HTML.Text("a < b")
        let rendered = try String(text)
        #expect(rendered == "a &lt; b")
    }

    @Test("HTML.Text escapes greater than")
    func escapesGreaterThan() throws {
        let text = HTML.Text("a > b")
        let rendered = try String(text)
        #expect(rendered == "a &gt; b")
    }

    @Test("HTML.Text escapes multiple special characters")
    func escapesMultipleSpecialCharacters() throws {
        let text = HTML.Text("<script>alert('XSS');</script>")
        let rendered = try String(text)
        #expect(rendered == "&lt;script&gt;alert('XSS');&lt;/script&gt;")
    }

    @Test("HTML.Text preserves quotes - not escaped in text content")
    func preservesQuotes() throws {
        let text = HTML.Text("He said \"Hello\"")
        let rendered = try String(text)
        #expect(rendered == "He said \"Hello\"")
    }

    @Test("HTML.Text preserves single quotes")
    func preservesSingleQuotes() throws {
        let text = HTML.Text("It's working")
        let rendered = try String(text)
        #expect(rendered == "It's working")
    }

    // MARK: - Concatenation

    @Test("HTML.Text concatenation with + operator")
    func concatenationWithOperator() throws {
        let hello = HTML.Text("Hello, ")
        let world = HTML.Text("World!")
        let combined = hello + world
        let rendered = try String(combined)
        #expect(rendered == "Hello, World!")
    }

    @Test("HTML.Text concatenation preserves escaping")
    func concatenationPreservesEscaping() throws {
        let left = HTML.Text("A & B")
        let right = HTML.Text(" < C")
        let combined = left + right
        let rendered = try String(combined)
        #expect(rendered == "A &amp; B &lt; C")
    }

    // MARK: - Unicode

    @Test("HTML.Text preserves Unicode characters")
    func preservesUnicode() throws {
        let text = HTML.Text("Hello, 世界! 🌍")
        let rendered = try String(text)
        #expect(rendered == "Hello, 世界! 🌍")
    }

    @Test("HTML.Text preserves emoji")
    func preservesEmoji() throws {
        let text = HTML.Text("👍🏽 Great job!")
        let rendered = try String(text)
        #expect(rendered == "👍🏽 Great job!")
    }

    // MARK: - Edge Cases

    @Test("HTML.Text with newlines")
    func withNewlines() throws {
        let text = HTML.Text("Line 1\nLine 2\nLine 3")
        let rendered = try String(text)
        #expect(rendered == "Line 1\nLine 2\nLine 3")
    }

    @Test("HTML.Text with tabs")
    func withTabs() throws {
        let text = HTML.Text("Col1\tCol2\tCol3")
        let rendered = try String(text)
        #expect(rendered == "Col1\tCol2\tCol3")
    }

    @Test("HTML.Text in document context")
    func inDocumentContext() throws {
        let document = HTML.Document {
            tag("p") {
                HTML.Text("This is & that")
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
        @Test("HTML.Text basic rendering snapshot")
        func basicRenderingSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h1") {
                            HTML.Text("Welcome & Hello")
                        }
                        tag("p") {
                            HTML.Text("This is a paragraph with <special> characters & symbols.")
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

        @Test("HTML.Text with various content types snapshot")
        func variousContentSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("article") {
                        tag("h2") {
                            HTML.Text("Code Examples")
                        }
                        tag("p") {
                            HTML.Text("In HTML, use &lt;tag&gt; syntax (shown escaped).")
                        }
                        tag("p") {
                            HTML.Text("Copyright © 2025 - All rights reserved")
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

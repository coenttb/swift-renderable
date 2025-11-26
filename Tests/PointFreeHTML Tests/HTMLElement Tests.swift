//
//  HTML.ElementTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTML.Element Tests")
struct HTMLElementTests {

    @Test("HTML.Element with basic tag")
    func basicHTMLElement() throws {
        let element = tag("div") {
            HTML.Text("content")
        }

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("content"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTML.Element empty")
    func emptyHTMLElement() throws {
        let element = tag("div")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTML.Element with multiple children")
    func elementWithMultipleChildren() throws {
        let element = tag("div") {
            HTML.Text("first")
            HTML.Text("second")
        }

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("first"))
        #expect(rendered.contains("second"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTML.Element with nested elements")
    func nestedElements() throws {
        let element = tag("div") {
            tag("p") {
                HTML.Text("paragraph content")
            }
        }

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("paragraph content"))
        #expect(rendered.contains("</p>"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTML.Element with custom tag")
    func customTagElement() throws {
        let element = tag("custom-element") {
            HTML.Text("custom content")
        }

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("<custom-element>"))
        #expect(rendered.contains("custom content"))
        #expect(rendered.contains("</custom-element>"))
    }

    // MARK: - Attribute Escaping Tests (Fast Path Optimization)

    @Test("Attribute with no escaping needed - fast path")
    func attributeNoEscaping() throws {
        let element = tag("div")
            .attribute("id", "simple-id")
            .attribute("class", "container main")
            .attribute("data-value", "12345")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("id=\"simple-id\""))
        #expect(rendered.contains("class=\"container main\""))
        #expect(rendered.contains("data-value=\"12345\""))
    }

    @Test("Attribute with double quotes - requires escaping")
    func attributeWithDoubleQuotes() throws {
        let element = tag("div")
            .attribute("data-message", "He said \"Hello\"")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("data-message=\"He said &quot;Hello&quot;\""))
        #expect(!rendered.contains("He said \"Hello\""))
    }

    @Test("Attribute with single quotes - requires escaping")
    func attributeWithSingleQuotes() throws {
        let element = tag("div")
            .attribute("data-message", "It's working")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("data-message=\"It&#39;s working\""))
    }

    @Test("Attribute with ampersand - requires escaping")
    func attributeWithAmpersand() throws {
        let element = tag("a")
            .attribute("href", "/search?q=foo&bar=baz")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("href=\"/search?q=foo&amp;bar=baz\""))
        #expect(!rendered.contains("&bar="))
    }

    @Test("Attribute with less than - requires escaping")
    func attributeWithLessThan() throws {
        let element = tag("div")
            .attribute("data-condition", "x<10")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("data-condition=\"x&lt;10\""))
        #expect(!rendered.contains("x<10\""))
    }

    @Test("Attribute with greater than - requires escaping")
    func attributeWithGreaterThan() throws {
        let element = tag("div")
            .attribute("data-condition", "x>10")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("data-condition=\"x&gt;10\""))
        #expect(!rendered.contains("x>10\""))
    }

    @Test("Attribute with multiple special characters")
    func attributeWithMultipleSpecialChars() throws {
        let element = tag("div")
            .attribute("data-complex", "<tag attr=\"value\" & 'quotes'>")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("&lt;tag attr=&quot;value&quot; &amp; &#39;quotes&#39;&gt;"))
    }

    @Test("Empty attribute value - boolean attributes")
    func emptyAttributeValue() throws {
        let element = tag("input")
            .attribute("required", "")
            .attribute("disabled", "")

        let rendered = try String(HTML.Document { element })
        // Empty string attributes are rendered as boolean attributes (no value)
        #expect(rendered.contains("required"))
        #expect(rendered.contains("disabled"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLElementSnapshotTests {
        @Test("HTML.Element basic structure snapshot")
        func basicElementSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        HTML.Text("Hello, World!")
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
                    <div>Hello, World!
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("HTML.Element with attributes snapshot")
        func elementWithAttributesSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        HTML.Text("Content with attributes")
                    }
                    .attribute("class", "container")
                    .attribute("id", "main-div")
                    .attribute("data-testid", "test-element")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div class="container" id="main-div" data-testid="test-element">Content with attributes
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("HTML.Element nested structure snapshot")
        func nestedElementSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("article") {
                        tag("header") {
                            tag("h1") {
                                HTML.Text("Article Title")
                            }
                            tag("p") {
                                HTML.Text("By Author Name")
                            }
                        }
                        tag("section") {
                            tag("p") {
                                HTML.Text("This is the first paragraph of the article.")
                            }
                            tag("p") {
                                HTML.Text("This is the second paragraph with more content.")
                            }
                        }
                        tag("footer") {
                            HTML.Text("Published on January 1, 2025")
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
                      <header>
                        <h1>Article Title
                        </h1>
                        <p>By Author Name
                        </p>
                      </header>
                      <section>
                        <p>This is the first paragraph of the article.
                        </p>
                        <p>This is the second paragraph with more content.
                        </p>
                      </section>
                      <footer>Published on January 1, 2025
                      </footer>
                    </article>
                  </body>
                </html>
                """
            }
        }

        @Test("HTML.Element with mixed content snapshot")
        func mixedContentSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        HTML.Text("Text before ")
                        tag("strong") {
                            HTML.Text("bold text")
                        }
                        HTML.Text(" and text after ")
                        tag("em") {
                            HTML.Text("italic text")
                        }
                        HTML.Text(".")
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
                    <div>Text before <strong>bold text</strong> and text after <em>italic text</em>.
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("Attribute escaping snapshot - no escaping needed")
        func attributeEscapingSnapshotNoEscape() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("input")
                        .attribute("type", "text")
                        .attribute("name", "username")
                        .attribute("placeholder", "Enter your name")
                        .attribute("id", "user-input-123")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body><input type="text" name="username" placeholder="Enter your name" id="user-input-123">
                  </body>
                </html>
                """
            }
        }

        @Test("Attribute escaping snapshot - with escaping")
        func attributeEscapingSnapshotWithEscape() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div")
                        .attribute("data-message", "Say \"Hello\" & 'Goodbye'")
                        .attribute("data-condition", "x < 10 && y > 5")
                        .attribute("id", "no-escape-needed")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div data-message="Say &quot;Hello&quot; &amp; &#39;Goodbye&#39;" data-condition="x &lt; 10 &amp;&amp; y &gt; 5" id="no-escape-needed">
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}

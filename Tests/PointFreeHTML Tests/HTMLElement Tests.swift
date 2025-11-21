//
//  HTMLElementTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "HTMLElement Tests",
    .snapshots(record: .missing)
)
struct HTMLElementTests {

    @Test("HTMLElement with basic tag")
    func basicHTMLElement() throws {
        let element = tag("div") {
            HTMLText("content")
        }

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("content"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTMLElement empty")
    func emptyHTMLElement() throws {
        let element = tag("div")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTMLElement with multiple children")
    func elementWithMultipleChildren() throws {
        let element = tag("div") {
            HTMLText("first")
            HTMLText("second")
        }

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("first"))
        #expect(rendered.contains("second"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTMLElement with nested elements")
    func nestedElements() throws {
        let element = tag("div") {
            tag("p") {
                HTMLText("paragraph content")
            }
        }

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("paragraph content"))
        #expect(rendered.contains("</p>"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTMLElement with custom tag")
    func customTagElement() throws {
        let element = tag("custom-element") {
            HTMLText("custom content")
        }

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<custom-element>"))
        #expect(rendered.contains("custom content"))
        #expect(rendered.contains("</custom-element>"))
    }

    // MARK: - Snapshot Tests

    @Test("HTMLElement basic structure snapshot")
    func basicElementSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    HTMLText("Hello, World!")
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
            <div>Hello, World!
            </div>
              </body>
            </html>
            """
        }
    }

    @Test("HTMLElement with attributes snapshot")
    func elementWithAttributesSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    HTMLText("Content with attributes")
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
                <style>

                </style>
              </head>
              <body>
            <div class="container" id="main-div" data-testid="test-element">Content with attributes
            </div>
              </body>
            </html>
            """
        }
    }

    @Test("HTMLElement nested structure snapshot")
    func nestedElementSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("article") {
                    tag("header") {
                        tag("h1") {
                            HTMLText("Article Title")
                        }
                        tag("p") {
                            HTMLText("By Author Name")
                        }
                    }
                    tag("section") {
                        tag("p") {
                            HTMLText("This is the first paragraph of the article.")
                        }
                        tag("p") {
                            HTMLText("This is the second paragraph with more content.")
                        }
                    }
                    tag("footer") {
                        HTMLText("Published on January 1, 2025")
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

    @Test("HTMLElement with mixed content snapshot")
    func mixedContentSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    HTMLText("Text before ")
                    tag("strong") {
                        HTMLText("bold text")
                    }
                    HTMLText(" and text after ")
                    tag("em") {
                        HTMLText("italic text")
                    }
                    HTMLText(".")
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
            <div>Text before <strong>bold text</strong> and text after <em>italic text</em>.
            </div>
              </body>
            </html>
            """
        }
    }

    // MARK: - Attribute Escaping Tests (Fast Path Optimization)

    @Test("Attribute with no escaping needed - fast path")
    func attributeNoEscaping() throws {
        let element = tag("div")
            .attribute("id", "simple-id")
            .attribute("class", "container main")
            .attribute("data-value", "12345")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("id=\"simple-id\""))
        #expect(rendered.contains("class=\"container main\""))
        #expect(rendered.contains("data-value=\"12345\""))
    }

    @Test("Attribute with double quotes - requires escaping")
    func attributeWithDoubleQuotes() throws {
        let element = tag("div")
            .attribute("data-message", "He said \"Hello\"")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("data-message=\"He said &quot;Hello&quot;\""))
        #expect(!rendered.contains("He said \"Hello\""))
    }

    @Test("Attribute with single quotes - requires escaping")
    func attributeWithSingleQuotes() throws {
        let element = tag("div")
            .attribute("data-message", "It's working")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("data-message=\"It&#39;s working\""))
    }

    @Test("Attribute with ampersand - requires escaping")
    func attributeWithAmpersand() throws {
        let element = tag("a")
            .attribute("href", "/search?q=foo&bar=baz")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("href=\"/search?q=foo&amp;bar=baz\""))
        #expect(!rendered.contains("&bar="))
    }

    @Test("Attribute with less than - requires escaping")
    func attributeWithLessThan() throws {
        let element = tag("div")
            .attribute("data-condition", "x<10")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("data-condition=\"x&lt;10\""))
        #expect(!rendered.contains("x<10\""))
    }

    @Test("Attribute with greater than - requires escaping")
    func attributeWithGreaterThan() throws {
        let element = tag("div")
            .attribute("data-condition", "x>10")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("data-condition=\"x&gt;10\""))
        #expect(!rendered.contains("x>10\""))
    }

    @Test("Attribute with multiple special characters")
    func attributeWithMultipleSpecialChars() throws {
        let element = tag("div")
            .attribute("data-complex", "<tag attr=\"value\" & 'quotes'>")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("&lt;tag attr=&quot;value&quot; &amp; &#39;quotes&#39;&gt;"))
    }

    @Test("Attribute escaping snapshot - no escaping needed")
    func attributeEscapingSnapshotNoEscape() {
        assertInlineSnapshot(
            of: HTMLDocument {
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
                <style>

                </style>
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
            of: HTMLDocument {
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
                <style>

                </style>
              </head>
              <body>
            <div data-message="Say &quot;Hello&quot; &amp; &#39;Goodbye&#39;" data-condition="x &lt; 10 &amp;&amp; y &gt; 5" id="no-escape-needed">
            </div>
              </body>
            </html>
            """
        }
    }

    @Test("Empty attribute value - boolean attributes")
    func emptyAttributeValue() throws {
        let element = tag("input")
            .attribute("required", "")
            .attribute("disabled", "")

        let rendered = try String(HTMLDocument { element })
        // Empty string attributes are rendered as boolean attributes (no value)
        #expect(rendered.contains("required"))
        #expect(rendered.contains("disabled"))
    }
}

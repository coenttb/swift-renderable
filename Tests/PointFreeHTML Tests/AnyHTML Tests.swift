//
//  AnyHTML Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("AnyHTML Tests")
struct AnyHTMLTests {

    // MARK: - Initialization

    @Test("AnyHTML wraps HTMLText")
    func wrapsHTMLText() throws {
        let anyHTML = AnyHTML(HTMLText("Hello"))
        let rendered = try String(anyHTML)
        #expect(rendered == "Hello")
    }

    @Test("AnyHTML wraps HTMLElement")
    func wrapsHTMLElement() throws {
        let element = tag("div") {
            HTMLText("Content")
        }
        let anyHTML = AnyHTML(element)
        let rendered = try String(anyHTML)
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("Content"))
        #expect(rendered.contains("</div>"))
    }

    @Test("AnyHTML wraps Empty")
    func wrapsEmpty() throws {
        let anyHTML = AnyHTML(Empty())
        let rendered = try String(anyHTML)
        #expect(rendered.isEmpty)
    }

    @Test("AnyHTML closure initializer")
    func closureInitializer() throws {
        let anyHTML = AnyHTML {
            tag("span") {
                HTMLText("From closure")
            }
        }
        let rendered = try String(anyHTML)
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("From closure"))
    }

    // MARK: - Type Erasure

    @Test("AnyHTML enables heterogeneous collections")
    func heterogeneousCollections() throws {
        let elements: [AnyHTML] = [
            AnyHTML(HTMLText("Text")),
            AnyHTML(tag("div") { HTMLText("Div") }),
            AnyHTML(tag("span") { HTMLText("Span") })
        ]

        let html = Group {
            for element in elements {
                element
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("Text"))
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<span>"))
    }

    @Test("AnyHTML preserves attributes")
    func preservesAttributes() throws {
        let element = tag("a") {
            HTMLText("Link")
        }
        .attribute("href", "/page")
        .attribute("class", "nav-link")

        let anyHTML = AnyHTML(element)
        let rendered = try String(Document { anyHTML })
        #expect(rendered.contains("href=\"/page\""))
        #expect(rendered.contains("class=\"nav-link\""))
    }

    @Test("AnyHTML preserves styles")
    func preservesStyles() throws {
        let element = tag("div") {
            HTMLText("Styled")
        }
        .inlineStyle("color", "red")

        let anyHTML = AnyHTML(element)
        let rendered = try String(Document { anyHTML })
        #expect(rendered.contains("color:red"))
    }

    // MARK: - Nested AnyHTML

    @Test("AnyHTML can wrap AnyHTML")
    func wrapsAnyHTML() throws {
        let inner = AnyHTML(HTMLText("Inner"))
        let outer = AnyHTML(inner)
        let rendered = try String(outer)
        #expect(rendered == "Inner")
    }

    // MARK: - Complex Structures

    @Test("AnyHTML with nested elements")
    func nestedElements() throws {
        let article = tag("article") {
            tag("h1") {
                HTMLText("Title")
            }
            tag("p") {
                HTMLText("Content")
            }
        }

        let anyHTML = AnyHTML(article)
        let rendered = try String(anyHTML)
        #expect(rendered.contains("<article>"))
        #expect(rendered.contains("<h1>"))
        #expect(rendered.contains("<p>"))
    }

    // MARK: - Dynamic Content

    @Test("AnyHTML for dynamic content selection")
    func dynamicContentSelection() throws {
        func createContent(type: String) -> AnyHTML {
            switch type {
            case "header":
                return AnyHTML(tag("h1") { HTMLText("Header") })
            case "paragraph":
                return AnyHTML(tag("p") { HTMLText("Paragraph") })
            default:
                return AnyHTML(HTMLText("Default"))
            }
        }

        let headerRendered = try String(createContent(type: "header"))
        let paragraphRendered = try String(createContent(type: "paragraph"))
        let defaultRendered = try String(createContent(type: "other"))

        #expect(headerRendered.contains("<h1>"))
        #expect(paragraphRendered.contains("<p>"))
        #expect(defaultRendered == "Default")
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct AnyHTMLSnapshotTests {
        @Test("AnyHTML type erasure snapshot")
        func typeErasureSnapshot() {
            let elements: [AnyHTML] = [
                AnyHTML(tag("h1") { HTMLText("Title") }),
                AnyHTML(tag("p") { HTMLText("First paragraph") }),
                AnyHTML(tag("p") { HTMLText("Second paragraph") })
            ]

            assertInlineSnapshot(
                of: Document {
                    tag("article") {
                        for element in elements {
                            element
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
                      <h1>Title
                      </h1>
                      <p>First paragraph
                      </p>
                      <p>Second paragraph
                      </p>
                    </article>
                  </body>
                </html>
                """
            }
        }
    }
}

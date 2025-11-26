//
//  AnyHTML Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `AnyHTML Tests` {

    // MARK: - Initialization

    @Test
    func `AnyHTML wraps HTML.Text`() throws {
        let anyHTML = AnyHTML(HTML.Text("Hello"))
        let rendered = try String(anyHTML)
        #expect(rendered == "Hello")
    }

    @Test
    func `AnyHTML wraps HTML.Element`() throws {
        let element = tag("div") {
            HTML.Text("Content")
        }
        let anyHTML = AnyHTML(element)
        let rendered = try String(anyHTML)
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("Content"))
        #expect(rendered.contains("</div>"))
    }

    @Test
    func `AnyHTML wraps Empty`() throws {
        let anyHTML = AnyHTML(Empty())
        let rendered = try String(anyHTML)
        #expect(rendered.isEmpty)
    }

    @Test
    func `AnyHTML closure initializer`() throws {
        let anyHTML = AnyHTML {
            tag("span") {
                HTML.Text("From closure")
            }
        }
        let rendered = try String(anyHTML)
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("From closure"))
    }

    // MARK: - Type Erasure

    @Test
    func `AnyHTML enables heterogeneous collections`() throws {
        let elements: [AnyHTML] = [
            AnyHTML(HTML.Text("Text")),
            AnyHTML(tag("div") { HTML.Text("Div") }),
            AnyHTML(tag("span") { HTML.Text("Span") })
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

    @Test
    func `AnyHTML preserves attributes`() throws {
        let element = tag("a") {
            HTML.Text("Link")
        }
        .attribute("href", "/page")
        .attribute("class", "nav-link")

        let anyHTML = AnyHTML(element)
        let rendered = try String(HTML.Document { anyHTML })
        #expect(rendered.contains("href=\"/page\""))
        #expect(rendered.contains("class=\"nav-link\""))
    }

    @Test
    func `AnyHTML preserves styles`() throws {
        let element = tag("div") {
            HTML.Text("Styled")
        }
        .inlineStyle("color", "red")

        let anyHTML = AnyHTML(element)
        let rendered = try String(HTML.Document { anyHTML })
        #expect(rendered.contains("color:red"))
    }

    // MARK: - Nested AnyHTML

    @Test
    func `AnyHTML can wrap AnyHTML`() throws {
        let inner = AnyHTML(HTML.Text("Inner"))
        let outer = AnyHTML(inner)
        let rendered = try String(outer)
        #expect(rendered == "Inner")
    }

    // MARK: - Complex Structures

    @Test
    func `AnyHTML with nested elements`() throws {
        let article = tag("article") {
            tag("h1") {
                HTML.Text("Title")
            }
            tag("p") {
                HTML.Text("Content")
            }
        }

        let anyHTML = AnyHTML(article)
        let rendered = try String(anyHTML)
        #expect(rendered.contains("<article>"))
        #expect(rendered.contains("<h1>"))
        #expect(rendered.contains("<p>"))
    }

    // MARK: - Dynamic Content

    @Test
    func `AnyHTML for dynamic content selection`() throws {
        func createContent(type: String) -> AnyHTML {
            switch type {
            case "header":
                return AnyHTML(tag("h1") { HTML.Text("Header") })
            case "paragraph":
                return AnyHTML(tag("p") { HTML.Text("Paragraph") })
            default:
                return AnyHTML(HTML.Text("Default"))
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
        @Test
        func `AnyHTML type erasure snapshot`() {
            let elements: [AnyHTML] = [
                AnyHTML(tag("h1") { HTML.Text("Title") }),
                AnyHTML(tag("p") { HTML.Text("First paragraph") }),
                AnyHTML(tag("p") { HTML.Text("Second paragraph") })
            ]

            assertInlineSnapshot(
                of: HTML.Document {
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

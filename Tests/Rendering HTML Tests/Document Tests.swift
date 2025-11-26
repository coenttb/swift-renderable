//
//  Document Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing
import Foundation

// Note: Document is an internal type, so we test it through HTMLDocument
// which uses Document internally. These tests focus on the document structure
// and assembly behavior that Document provides.

@Suite
struct `Document Tests` {

    // MARK: - Document Structure

    @Test
    func `Document produces valid HTML structure`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
            }
        }

        let rendered = try String(document)

        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("<body>"))
        #expect(rendered.contains("</html>"))
    }

    @Test
    func `Document includes head content`() throws {
        let document = HTML.Document(
            head: { tag("title") { HTML.Text("Page Title") } },
            body: { tag("main") { HTML.Text("Main content") } }
        )

        let rendered = try String(document)

        #expect(rendered.contains("<title>Page Title</title>"))
    }

    @Test
    func `Document includes style tag when styles present`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
            }
            .inlineStyle("color", "red")
        }

        let rendered = try String(document)

        #expect(rendered.contains("<style>"))
        #expect(rendered.contains("</style>"))
        #expect(rendered.contains("color:red"))
    }

    @Test
    func `Document omits style tag when no styles`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
            }
        }

        let rendered = try String(document)

        #expect(!rendered.contains("<style>"))
    }

    // MARK: - Body Content

    @Test
    func `Document renders body content`() throws {
        let document = HTML.Document {
            tag("h1") {
                HTML.Text("Welcome")
            }
            tag("p") {
                HTML.Text("This is a paragraph")
            }
        }

        let rendered = try String(document)

        #expect(rendered.contains("<h1>Welcome</h1>"))
        #expect(rendered.contains("<p>This is a paragraph</p>"))
    }

    @Test
    func `Document preserves body attributes`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
            }
            .attribute("id", "main")
            .attribute("class", "container")
        }

        let rendered = try String(document)

        #expect(rendered.contains("id=\"main\""))
        #expect(rendered.contains("class=\"container\""))
    }

    // MARK: - Stylesheet Collection

    @Test
    func `Document collects styles in stylesheet`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Styled")
            }
            .inlineStyle("color", "red")
            .inlineStyle("margin", "10px")
        }

        let rendered = try String(document)

        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("margin:10px"))
    }

    @Test
    func `Document collects multiple element styles`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("First")
            }
            .inlineStyle("color", "red")

            tag("span") {
                HTML.Text("Second")
            }
            .inlineStyle("color", "blue")
        }

        let rendered = try String(document)

        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:blue"))
    }

    // MARK: - Order

    @Test
    func `Document elements in correct order`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
            }
        }

        let rendered = try String(document)

        // Check order: doctype < html < head < body
        let doctypeIndex = rendered.range(of: "<!doctype html>")?.lowerBound
        let htmlIndex = rendered.range(of: "<html>")?.lowerBound
        let headIndex = rendered.range(of: "<head>")?.lowerBound
        let bodyIndex = rendered.range(of: "<body>")?.lowerBound

        #expect(doctypeIndex != nil)
        #expect(htmlIndex != nil)
        #expect(headIndex != nil)
        #expect(bodyIndex != nil)

        if let d = doctypeIndex, let h = htmlIndex, let hd = headIndex, let b = bodyIndex {
            #expect(d < h)
            #expect(h < hd)
            #expect(hd < b)
        }
    }

    // MARK: - Empty Content

    @Test
    func `Document with empty body`() throws {
        let document = HTML.Document {
            Empty()
        }

        let rendered = try String(document)

        #expect(rendered.contains("<body>"))
        #expect(rendered.contains("</body>"))
    }

    @Test
    func `Document with empty head`() throws {
        let document = HTML.Document(
            head: { Empty() },
            body: { tag("div") { HTML.Text("Body") } }
        )

        let rendered = try String(document)

        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("</head>"))
        // No style tag when no styles are used
        #expect(!rendered.contains("<style>"))
    }

    // MARK: - Complex Documents

    @Test
    func `Document with complex nested content`() throws {
        let document = HTML.Document {
            tag("header") {
                tag("nav") {
                    tag("ul") {
                        tag("li") { tag("a") { HTML.Text("Home") }.attribute("href", "/") }
                        tag("li") { tag("a") { HTML.Text("About") }.attribute("href", "/about") }
                    }
                }
            }
            tag("main") {
                tag("article") {
                    tag("h1") { HTML.Text("Title") }
                    tag("p") { HTML.Text("Content") }
                }
            }
            tag("footer") {
                tag("p") { HTML.Text("Copyright 2024") }
            }
        }

        let rendered = try String(document)

        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<nav>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<article>"))
        #expect(rendered.contains("<footer>"))
    }

    @Test
    func `Document with media query styles`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Responsive")
            }
            .inlineStyle("width", "100%", atRule: .init(rawValue: "@media (min-width: 768px)"), selector: nil, pseudo: nil)
        }

        let rendered = try String(document)

        #expect(rendered.contains("@media (min-width: 768px)"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct DocumentSnapshotTests {
        @Test
        func `Full document snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document(
                    head: {
                        tag("title") {
                            HTML.Text("Test Page")
                        }
                        tag("meta")
                            .attribute("charset", "utf-8")
                    },
                    body: {
                        tag("main") {
                            tag("h1") {
                                HTML.Text("Hello, World!")
                            }
                            tag("p") {
                                HTML.Text("This is a test document.")
                            }
                        }
                    }
                ),
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <title>Test Page
                    </title>
                    <meta charset="utf-8">
                  </head>
                  <body>
                    <main>
                      <h1>Hello, World!
                      </h1>
                      <p>This is a test document.
                      </p>
                    </main>
                  </body>
                </html>
                """
            }
        }
    }
}

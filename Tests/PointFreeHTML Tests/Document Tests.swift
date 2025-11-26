//
//  Document Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing
import Foundation

// Note: Document is an internal type, so we test it through HTMLDocument
// which uses Document internally. These tests focus on the document structure
// and assembly behavior that Document provides.

@Suite("Document Tests")
struct DocumentTests {

    // MARK: - Document Structure

    @Test("Document produces valid HTML structure")
    func validHTMLStructure() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
            }
        }

        let rendered = try String(document)

        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("<body>"))
        #expect(rendered.contains("</html>"))
    }

    @Test("Document includes head content")
    func includesHeadContent() throws {
        let document = HTMLDocument(
            head: { tag("title") { HTMLText("Page Title") } },
            body: { tag("main") { HTMLText("Main content") } }
        )

        let rendered = try String(document)

        #expect(rendered.contains("<title>Page Title</title>"))
    }

    @Test("Document includes style tag when styles present")
    func includesStyleTag() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
            }
            .inlineStyle("color", "red")
        }

        let rendered = try String(document)

        #expect(rendered.contains("<style>"))
        #expect(rendered.contains("</style>"))
        #expect(rendered.contains("color:red"))
    }

    @Test("Document omits style tag when no styles")
    func omitsStyleTagWhenNoStyles() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
            }
        }

        let rendered = try String(document)

        #expect(!rendered.contains("<style>"))
    }

    // MARK: - Body Content

    @Test("Document renders body content")
    func rendersBodyContent() throws {
        let document = HTMLDocument {
            tag("h1") {
                HTMLText("Welcome")
            }
            tag("p") {
                HTMLText("This is a paragraph")
            }
        }

        let rendered = try String(document)

        #expect(rendered.contains("<h1>Welcome</h1>"))
        #expect(rendered.contains("<p>This is a paragraph</p>"))
    }

    @Test("Document preserves body attributes")
    func preservesBodyAttributes() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
            }
            .attribute("id", "main")
            .attribute("class", "container")
        }

        let rendered = try String(document)

        #expect(rendered.contains("id=\"main\""))
        #expect(rendered.contains("class=\"container\""))
    }

    // MARK: - Stylesheet Collection

    @Test("Document collects styles in stylesheet")
    func collectsStylesInStylesheet() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Styled")
            }
            .inlineStyle("color", "red")
            .inlineStyle("margin", "10px")
        }

        let rendered = try String(document)

        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("margin:10px"))
    }

    @Test("Document collects multiple element styles")
    func collectsMultipleElementStyles() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("First")
            }
            .inlineStyle("color", "red")

            tag("span") {
                HTMLText("Second")
            }
            .inlineStyle("color", "blue")
        }

        let rendered = try String(document)

        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:blue"))
    }

    // MARK: - Order

    @Test("Document elements in correct order")
    func elementsInCorrectOrder() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
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

    @Test("Document with empty body")
    func emptyBody() throws {
        let document = HTMLDocument {
            HTMLEmpty()
        }

        let rendered = try String(document)

        #expect(rendered.contains("<body>"))
        #expect(rendered.contains("</body>"))
    }

    @Test("Document with empty head")
    func emptyHead() throws {
        let document = HTMLDocument(
            head: { HTMLEmpty() },
            body: { tag("div") { HTMLText("Body") } }
        )

        let rendered = try String(document)

        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("</head>"))
        // No style tag when no styles are used
        #expect(!rendered.contains("<style>"))
    }

    // MARK: - Complex Documents

    @Test("Document with complex nested content")
    func complexNestedContent() throws {
        let document = HTMLDocument {
            tag("header") {
                tag("nav") {
                    tag("ul") {
                        tag("li") { tag("a") { HTMLText("Home") }.attribute("href", "/") }
                        tag("li") { tag("a") { HTMLText("About") }.attribute("href", "/about") }
                    }
                }
            }
            tag("main") {
                tag("article") {
                    tag("h1") { HTMLText("Title") }
                    tag("p") { HTMLText("Content") }
                }
            }
            tag("footer") {
                tag("p") { HTMLText("Copyright 2024") }
            }
        }

        let rendered = try String(document)

        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<nav>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<article>"))
        #expect(rendered.contains("<footer>"))
    }

    @Test("Document with media query styles")
    func mediaQueryStyles() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Responsive")
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
        @Test("Full document snapshot")
        func fullDocumentSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument(
                    head: {
                        tag("title") {
                            HTMLText("Test Page")
                        }
                        tag("meta")
                            .attribute("charset", "utf-8")
                    },
                    body: {
                        tag("main") {
                            tag("h1") {
                                HTMLText("Hello, World!")
                            }
                            tag("p") {
                                HTMLText("This is a test document.")
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
                    <style>

                    </style>
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

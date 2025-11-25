//
//  HTMLDocument Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("HTMLDocument Tests")
struct HTMLDocumentTests {

    // MARK: - Initialization

    @Test("HTMLDocument with body only")
    func bodyOnly() throws {
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Content")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
        #expect(rendered.contains("<body>"))
        #expect(rendered.contains("Content"))
        #expect(rendered.contains("</body>"))
        #expect(rendered.contains("</html>"))
    }

    @Test("HTMLDocument with head and body")
    func headAndBody() throws {
        let document = HTMLDocument {
            tag("main") {
                HTMLText("Main content")
            }
        } head: {
            tag("title") {
                HTMLText("Page Title")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("<title>Page Title"))
        #expect(rendered.contains("</head>"))
        #expect(rendered.contains("Main content"))
    }

    @Test("HTMLDocument with disfavored initializer - head first")
    func headFirstInitializer() throws {
        let document = HTMLDocument(head: {
            tag("title") {
                HTMLText("Title First")
            }
        }, body: {
            HTMLText("Body content")
        })

        let rendered = try String(document)
        #expect(rendered.contains("Title First"))
        #expect(rendered.contains("Body content"))
    }

    @Test("HTMLDocument with empty head")
    func emptyHead() throws {
        let document = HTMLDocument {
            HTMLText("Just body")
        }

        let rendered = try String(document)
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("</head>"))
        #expect(rendered.contains("Just body"))
    }

    // MARK: - Document Structure

    @Test("HTMLDocument includes doctype")
    func includesDoctype() throws {
        let document = HTMLDocument {
            HTMLEmpty()
        }

        let rendered = try String(document)
        #expect(rendered.hasPrefix("<!doctype html>"))
    }

    @Test("HTMLDocument includes style element in head")
    func includesStyleElement() throws {
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

    // MARK: - Complex Documents

    @Test("HTMLDocument with meta tags")
    func withMetaTags() throws {
        let document = HTMLDocument {
            tag("h1") {
                HTMLText("Hello")
            }
        } head: {
            tag("meta")
                .attribute("charset", "utf-8")
            tag("meta")
                .attribute("name", "viewport")
                .attribute("content", "width=device-width, initial-scale=1")
            tag("title") {
                HTMLText("Test Page")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("charset=\"utf-8\""))
        #expect(rendered.contains("name=\"viewport\""))
        #expect(rendered.contains("width=device-width"))
    }

    @Test("HTMLDocument with multiple body elements")
    func multipleBodyElements() throws {
        let document = HTMLDocument {
            tag("header") {
                HTMLText("Header")
            }
            tag("main") {
                HTMLText("Main")
            }
            tag("footer") {
                HTMLText("Footer")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<footer>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLDocumentSnapshotTests {
        @Test("HTMLDocument complete structure snapshot")
        func completeStructureSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("header") {
                        tag("nav") {
                            tag("a") {
                                HTMLText("Home")
                            }
                            .attribute("href", "/")
                        }
                    }
                    tag("main") {
                        tag("h1") {
                            HTMLText("Welcome")
                        }
                        tag("p") {
                            HTMLText("This is the main content.")
                        }
                    }
                    tag("footer") {
                        tag("p") {
                            HTMLText("© 2025")
                        }
                    }
                } head: {
                    tag("title") {
                        HTMLText("My Page")
                    }
                    tag("meta")
                        .attribute("charset", "utf-8")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <title>My Page
                    </title>
                    <meta charset="utf-8">
                    <style>

                    </style>
                  </head>
                  <body>
                <header>
                  <nav><a href="/">Home</a>
                  </nav>
                </header>
                <main>
                  <h1>Welcome
                  </h1>
                  <p>This is the main content.
                  </p>
                </main>
                <footer>
                  <p>© 2025
                  </p>
                </footer>
                  </body>
                </html>
                """
            }
        }

        @Test("HTMLDocument minimal snapshot")
        func minimalSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    HTMLText("Hello")
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
                  <body>Hello
                  </body>
                </html>
                """
            }
        }
    }
}

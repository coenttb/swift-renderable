//
//  HTML.Document Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.Document Tests` {

    // MARK: - Initialization

    @Test
    func `HTML.Document with body only`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
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

    @Test
    func `HTML.Document with head and body`() throws {
        let document = HTML.Document {
            tag("main") {
                HTML.Text("Main content")
            }
        } head: {
            tag("title") {
                HTML.Text("Page Title")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("<title>Page Title"))
        #expect(rendered.contains("</head>"))
        #expect(rendered.contains("Main content"))
    }

    @Test
    func `HTML.Document with disfavored initializer - head first`() throws {
        let document = HTML.Document(head: {
            tag("title") {
                HTML.Text("Title First")
            }
        }, body: {
            HTML.Text("Body content")
        })

        let rendered = try String(document)
        #expect(rendered.contains("Title First"))
        #expect(rendered.contains("Body content"))
    }

    @Test
    func `HTML.Document with empty head`() throws {
        let document = HTML.Document {
            HTML.Text("Just body")
        }

        let rendered = try String(document)
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("</head>"))
        #expect(rendered.contains("Just body"))
    }

    // MARK: - Document Structure

    @Test
    func `HTML.Document includes doctype`() throws {
        let document = HTML.Document {
            Empty()
        }

        let rendered = try String(document)
        #expect(rendered.hasPrefix("<!doctype html>"))
    }

    @Test
    func `HTML.Document includes style element in head`() throws {
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

    // MARK: - Complex Documents

    @Test
    func `HTML.Document with meta tags`() throws {
        let document = HTML.Document {
            tag("h1") {
                HTML.Text("Hello")
            }
        } head: {
            tag("meta")
                .attribute("charset", "utf-8")
            tag("meta")
                .attribute("name", "viewport")
                .attribute("content", "width=device-width, initial-scale=1")
            tag("title") {
                HTML.Text("Test Page")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("charset=\"utf-8\""))
        #expect(rendered.contains("name=\"viewport\""))
        #expect(rendered.contains("width=device-width"))
    }

    @Test
    func `HTML.Document with multiple body elements`() throws {
        let document = HTML.Document {
            tag("header") {
                HTML.Text("Header")
            }
            tag("main") {
                HTML.Text("Main")
            }
            tag("footer") {
                HTML.Text("Footer")
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
        @Test
        func `HTML.Document complete structure snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("header") {
                        tag("nav") {
                            tag("a") {
                                HTML.Text("Home")
                            }
                            .attribute("href", "/")
                        }
                    }
                    tag("main") {
                        tag("h1") {
                            HTML.Text("Welcome")
                        }
                        tag("p") {
                            HTML.Text("This is the main content.")
                        }
                    }
                    tag("footer") {
                        tag("p") {
                            HTML.Text("© 2025")
                        }
                    }
                } head: {
                    tag("title") {
                        HTML.Text("My Page")
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

        @Test
        func `HTML.Document minimal snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    HTML.Text("Hello")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>Hello
                  </body>
                </html>
                """
            }
        }
    }
}

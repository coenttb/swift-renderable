//
//  _Tuple Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing
import Foundation

@Suite
struct `_Tuple Tests` {

    // MARK: - Basic Tuple Rendering

    @Test
    func `_Tuple renders multiple elements`() throws {
        // _Tuple is created implicitly when you have multiple elements in a builder
        let html = Group {
            tag("h1") {
                HTML.Text("Title")
            }
            tag("p") {
                HTML.Text("Paragraph")
            }
            tag("footer") {
                HTML.Text("Footer")
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<h1>Title</h1>"))
        #expect(rendered.contains("<p>Paragraph</p>"))
        #expect(rendered.contains("<footer>Footer</footer>"))
    }

    @Test
    func `_Tuple with two elements`() throws {
        let html = Group {
            HTML.Text("First")
            HTML.Text("Second")
        }

        let rendered = try String(html)
        #expect(rendered == "FirstSecond")
    }

    @Test
    func `_Tuple with single element`() throws {
        let html = Group {
            tag("div") {
                HTML.Text("Only one")
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("Only one"))
    }

    // MARK: - Attribute Isolation

    @Test
    func `_Tuple isolates attributes between elements`() throws {
        let html = HTML.Document {
            tag("div") {
                HTML.Text("First div")
            }
            .attribute("class", "first")

            tag("div") {
                HTML.Text("Second div")
            }
            .attribute("class", "second")
        }

        let rendered = try String(html)
        #expect(rendered.contains("class=\"first\""))
        #expect(rendered.contains("class=\"second\""))
        // Ensure attributes don't leak between elements
        let firstDivRange = rendered.range(of: "First div")!
        let secondDivRange = rendered.range(of: "Second div")!
        let firstClassRange = rendered.range(of: "class=\"first\"")!
        let secondClassRange = rendered.range(of: "class=\"second\"")!
        #expect(firstClassRange.lowerBound < firstDivRange.lowerBound)
        #expect(secondClassRange.lowerBound < secondDivRange.lowerBound)
    }

    // MARK: - Nested Tuples

    @Test
    func `_Tuple with nested groups`() throws {
        let html = Group {
            tag("header") {
                HTML.Text("Header")
            }
            Group {
                tag("main") {
                    HTML.Text("Main content")
                }
                tag("aside") {
                    HTML.Text("Sidebar")
                }
            }
            tag("footer") {
                HTML.Text("Footer")
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<aside>"))
        #expect(rendered.contains("<footer>"))
    }

    // MARK: - Different Types

    @Test
    func `_Tuple with mixed content types`() throws {
        let html = Group {
            HTML.Text("Plain text")
            tag("br")
            HTML.Raw("<strong>Raw HTML</strong>")
            tag("p") {
                HTML.Text("Paragraph")
            }
        }

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("Plain text"))
        #expect(rendered.contains("<br>"))
        #expect(rendered.contains("<strong>Raw HTML</strong>"))
        #expect(rendered.contains("<p>"))
    }

    @Test
    func `_Tuple with void and regular elements`() throws {
        let html = Group {
            tag("input")
                .attribute("type", "text")
            tag("label") {
                HTML.Text("Name")
            }
            tag("br")
            tag("input")
                .attribute("type", "submit")
        }

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("<label>"))
        #expect(rendered.contains("<br>"))
        #expect(rendered.contains("type=\"submit\""))
    }

    // MARK: - Style Propagation

    @Test
    func `_Tuple propagates styles correctly`() throws {
        let html = HTML.Document {
            tag("div") {
                HTML.Text("First")
            }
            .inlineStyle("color", "red")

            tag("div") {
                HTML.Text("Second")
            }
            .inlineStyle("color", "blue")
        }

        let rendered = try String(html)
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:blue"))
    }

    // MARK: - Complex Structures

    @Test
    func `_Tuple in document structure`() throws {
        let document = HTML.Document {
            tag("header") {
                tag("h1") {
                    HTML.Text("Site Title")
                }
            }
            tag("nav") {
                tag("a") { HTML.Text("Home") }.attribute("href", "/")
                tag("a") { HTML.Text("About") }.attribute("href", "/about")
            }
            tag("main") {
                tag("article") {
                    HTML.Text("Article content")
                }
            }
            tag("footer") {
                HTML.Text("© 2025")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<nav>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<footer>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct _TupleSnapshotTests {
        @Test
        func `_Tuple page layout snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("header") {
                        tag("h1") {
                            HTML.Text("My Website")
                        }
                    }
                    tag("main") {
                        tag("p") {
                            HTML.Text("Welcome to my site.")
                        }
                    }
                    tag("footer") {
                        tag("small") {
                            HTML.Text("© 2025")
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
                    <header>
                      <h1>My Website
                      </h1>
                    </header>
                    <main>
                      <p>Welcome to my site.
                      </p>
                    </main>
                    <footer><small>© 2025</small>
                    </footer>
                  </body>
                </html>
                """
            }
        }
    }
}

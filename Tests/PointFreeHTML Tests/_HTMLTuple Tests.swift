//
//  _HTMLTuple Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing
import Foundation

@Suite("_HTMLTuple Tests")
struct _HTMLTupleTests {

    // MARK: - Basic Tuple Rendering

    @Test("_HTMLTuple renders multiple elements")
    func rendersMultipleElements() throws {
        // _HTMLTuple is created implicitly when you have multiple elements in a builder
        let html = HTMLGroup {
            tag("h1") {
                HTMLText("Title")
            }
            tag("p") {
                HTMLText("Paragraph")
            }
            tag("footer") {
                HTMLText("Footer")
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<h1>Title</h1>"))
        #expect(rendered.contains("<p>Paragraph</p>"))
        #expect(rendered.contains("<footer>Footer</footer>"))
    }

    @Test("_HTMLTuple with two elements")
    func twoElements() throws {
        let html = HTMLGroup {
            HTMLText("First")
            HTMLText("Second")
        }

        let rendered = try String(html)
        #expect(rendered == "FirstSecond")
    }

    @Test("_HTMLTuple with single element")
    func singleElement() throws {
        let html = HTMLGroup {
            tag("div") {
                HTMLText("Only one")
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("Only one"))
    }

    // MARK: - Attribute Isolation

    @Test("_HTMLTuple isolates attributes between elements")
    func isolatesAttributes() throws {
        let html = HTMLDocument {
            tag("div") {
                HTMLText("First div")
            }
            .attribute("class", "first")

            tag("div") {
                HTMLText("Second div")
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

    @Test("_HTMLTuple with nested groups")
    func nestedGroups() throws {
        let html = HTMLGroup {
            tag("header") {
                HTMLText("Header")
            }
            HTMLGroup {
                tag("main") {
                    HTMLText("Main content")
                }
                tag("aside") {
                    HTMLText("Sidebar")
                }
            }
            tag("footer") {
                HTMLText("Footer")
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<aside>"))
        #expect(rendered.contains("<footer>"))
    }

    // MARK: - Different Types

    @Test("_HTMLTuple with mixed content types")
    func mixedContentTypes() throws {
        let html = HTMLGroup {
            HTMLText("Plain text")
            tag("br")
            HTMLRaw("<strong>Raw HTML</strong>")
            tag("p") {
                HTMLText("Paragraph")
            }
        }

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("Plain text"))
        #expect(rendered.contains("<br>"))
        #expect(rendered.contains("<strong>Raw HTML</strong>"))
        #expect(rendered.contains("<p>"))
    }

    @Test("_HTMLTuple with void and regular elements")
    func voidAndRegularElements() throws {
        let html = HTMLGroup {
            tag("input")
                .attribute("type", "text")
            tag("label") {
                HTMLText("Name")
            }
            tag("br")
            tag("input")
                .attribute("type", "submit")
        }

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("<label>"))
        #expect(rendered.contains("<br>"))
        #expect(rendered.contains("type=\"submit\""))
    }

    // MARK: - Style Propagation

    @Test("_HTMLTuple propagates styles correctly")
    func propagatesStyles() throws {
        let html = HTMLDocument {
            tag("div") {
                HTMLText("First")
            }
            .inlineStyle("color", "red")

            tag("div") {
                HTMLText("Second")
            }
            .inlineStyle("color", "blue")
        }

        let rendered = try String(html)
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:blue"))
    }

    // MARK: - Complex Structures

    @Test("_HTMLTuple in document structure")
    func inDocumentStructure() throws {
        let document = HTMLDocument {
            tag("header") {
                tag("h1") {
                    HTMLText("Site Title")
                }
            }
            tag("nav") {
                tag("a") { HTMLText("Home") }.attribute("href", "/")
                tag("a") { HTMLText("About") }.attribute("href", "/about")
            }
            tag("main") {
                tag("article") {
                    HTMLText("Article content")
                }
            }
            tag("footer") {
                HTMLText("© 2025")
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
    struct _HTMLTupleSnapshotTests {
        @Test("_HTMLTuple page layout snapshot")
        func pageLayoutSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("header") {
                        tag("h1") {
                            HTMLText("My Website")
                        }
                    }
                    tag("main") {
                        tag("p") {
                            HTMLText("Welcome to my site.")
                        }
                    }
                    tag("footer") {
                        tag("small") {
                            HTMLText("© 2025")
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

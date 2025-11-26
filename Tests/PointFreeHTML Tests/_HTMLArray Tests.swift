//
//  _HTMLArray Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("_HTMLArray Tests")
struct _HTMLArrayTests {

    // MARK: - Basic Rendering

    @Test("_HTMLArray renders multiple elements")
    func rendersMultipleElements() throws {
        // _HTMLArray is created through HTMLBuilder with for loops
        let html = Group {
            for item in ["A", "B", "C"] {
                tag("li") {
                    HTMLText(item)
                }
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<li>A</li>"))
        #expect(rendered.contains("<li>B</li>"))
        #expect(rendered.contains("<li>C</li>"))
    }

    @Test("_HTMLArray with empty array")
    func emptyArray() throws {
        let items: [String] = []
        let html = Group {
            for item in items {
                tag("li") {
                    HTMLText(item)
                }
            }
        }

        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test("_HTMLArray with single element")
    func singleElement() throws {
        let html = Group {
            for item in ["Only"] {
                tag("span") {
                    HTMLText(item)
                }
            }
        }

        let rendered = try String(html)
        #expect(rendered == "<span>Only</span>")
    }

    // MARK: - Complex Content

    @Test("_HTMLArray with nested elements")
    func nestedElements() throws {
        let items = [("Title 1", "Content 1"), ("Title 2", "Content 2")]
        let html = Group {
            for (title, content) in items {
                tag("article") {
                    tag("h2") {
                        HTMLText(title)
                    }
                    tag("p") {
                        HTMLText(content)
                    }
                }
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<article>"))
        #expect(rendered.contains("Title 1"))
        #expect(rendered.contains("Content 1"))
        #expect(rendered.contains("Title 2"))
        #expect(rendered.contains("Content 2"))
    }

    @Test("_HTMLArray with attributes")
    func withAttributes() throws {
        let items = ["item-1", "item-2", "item-3"]
        let html = Group {
            for id in items {
                tag("div") {
                    HTMLText(id)
                }
                .attribute("id", id)
            }
        }

        let rendered = try String(Document { html })
        #expect(rendered.contains("id=\"item-1\""))
        #expect(rendered.contains("id=\"item-2\""))
        #expect(rendered.contains("id=\"item-3\""))
    }

    @Test("_HTMLArray with indices")
    func withIndices() throws {
        let items = ["First", "Second", "Third"]
        let html = Group {
            for (index, item) in items.enumerated() {
                tag("div") {
                    HTMLText("\(index): \(item)")
                }
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("0: First"))
        #expect(rendered.contains("1: Second"))
        #expect(rendered.contains("2: Third"))
    }

    // MARK: - HTMLForEach Integration

    @Test("_HTMLArray via HTMLForEach")
    func viaHTMLForEach() throws {
        let items = ["Alpha", "Beta", "Gamma"]
        let html = HTMLForEach(items) { item in
            tag("option") {
                HTMLText(item)
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("<option>Alpha</option>"))
        #expect(rendered.contains("<option>Beta</option>"))
        #expect(rendered.contains("<option>Gamma</option>"))
    }

    // MARK: - Context Propagation

    @Test("_HTMLArray propagates context correctly")
    func propagatesContext() throws {
        let items = ["Red", "Blue"]
        let html = Document {
            for item in items {
                tag("span") {
                    HTMLText(item)
                }
                .inlineStyle("color", item.lowercased())
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:blue"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct _HTMLArraySnapshotTests {
        @Test("_HTMLArray list rendering snapshot")
        func listRenderingSnapshot() {
            assertInlineSnapshot(
                of: Document {
                    tag("ul") {
                        for item in ["Home", "About", "Contact"] {
                            tag("li") {
                                tag("a") {
                                    HTMLText(item)
                                }
                                .attribute("href", "/\(item.lowercased())")
                            }
                        }
                    }
                    .attribute("class", "nav-menu")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <ul class="nav-menu">
                      <li><a href="/home">Home</a>
                      </li>
                      <li><a href="/about">About</a>
                      </li>
                      <li><a href="/contact">Contact</a>
                      </li>
                    </ul>
                  </body>
                </html>
                """
            }
        }
    }
}

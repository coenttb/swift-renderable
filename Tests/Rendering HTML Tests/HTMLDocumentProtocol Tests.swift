//
//  HTML.DocumentProtocolTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.DocumentProtocol Tests` {

    @Test
    func `Basic HTML document structure`() throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Body content")
            }
        } head: {
            tag("title") {
                HTML.Text("Test Title")
            }
        }

        let rendered = try String(document)
        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html"))
        #expect(rendered.contains("<head>"))
        #expect(rendered.contains("<title>Test Title</title>"))
        #expect(rendered.contains("</head>"))
        #expect(rendered.contains("<body>"))
        #expect(rendered.contains("Body content"))
        #expect(rendered.contains("</body>"))
        #expect(rendered.contains("</html>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLDocumentProtocolSnapshotTests {
        @Test
        func `Complete HTML document snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("main") {
                        tag("section") {
                            tag("h1") {
                                HTML.Text("Welcome to Our Site")
                            }
                            tag("p") {
                                HTML.Text("This is a complete HTML document with proper structure.")
                            }
                        }
                        tag("aside") {
                            tag("h2") {
                                HTML.Text("Sidebar")
                            }
                            tag("ul") {
                                tag("li") {
                                    HTML.Text("Link 1")
                                }
                                tag("li") {
                                    HTML.Text("Link 2")
                                }
                            }
                        }
                    }
                } head: {
                    tag("title") {
                        HTML.Text("My Website")
                    }
                    tag("meta")
                        .attribute("charset", "utf-8")
                    tag("meta")
                        .attribute("name", "viewport")
                        .attribute("content", "width=device-width, initial-scale=1")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <title>My Website
                    </title>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                  </head>
                  <body>
                    <main>
                      <section>
                        <h1>Welcome to Our Site
                        </h1>
                        <p>This is a complete HTML document with proper structure.
                        </p>
                      </section>
                      <aside>
                        <h2>Sidebar
                        </h2>
                        <ul>
                          <li>Link 1
                          </li>
                          <li>Link 2
                          </li>
                        </ul>
                      </aside>
                    </main>
                  </body>
                </html>
                """
            }
        }
    }
}

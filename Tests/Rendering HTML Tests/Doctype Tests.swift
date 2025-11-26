//
//  Doctype Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Doctype Tests` {

    @Test
    func `Doctype renders HTML5 doctype`() throws {
        let doctype = HTML.Doctype()
        let rendered = try String(doctype)
        #expect(rendered == "<!doctype html>")
    }

    @Test
    func `Doctype in document context`() throws {
        struct TestDocument: HTML.View {
            var body: some HTML.View {
                HTML.Doctype()
                tag("html") {
                    tag("body") {
                        HTML.Text("content")
                    }
                }
            }
        }

        let document = TestDocument()
        let rendered = try String(document)
        #expect(rendered.hasPrefix("<!doctype html>"))
        #expect(rendered.contains("<html>"))
        #expect(rendered.contains("content"))
    }

    @Test
    func `Doctype with other HTML elements`() throws {
        let content = Group {
            HTML.Doctype()
            tag("html") {
                tag("head") {
                    tag("title") {
                        HTML.Text("Test Page")
                    }
                }
                tag("body") {
                    HTML.Text("Body content")
                }
            }
        }

        let rendered = try String(content)
        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<title>Test Page</title>"))
        #expect(rendered.contains("Body content"))
    }

    @Test
    func `Multiple doctypes`() throws {
        let content = Group {
            HTML.Doctype()
            HTML.Doctype()
        }

        let rendered = try String(content)
        #expect(rendered == "<!doctype html><!doctype html>")
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct DoctypeSnapshotTests {
        @Test
        func `Doctype in complete document snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h1") {
                            HTML.Text("HTML5 Document")
                        }
                        tag("p") {
                            HTML.Text("This document starts with a proper HTML5 doctype declaration.")
                        }
                    }
                } head: {
                    tag("title") {
                        HTML.Text("Doctype Example")
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <title>Doctype Example
                    </title>
                  </head>
                  <body>
                    <div>
                      <h1>HTML5 Document
                      </h1>
                      <p>This document starts with a proper HTML5 doctype declaration.
                      </p>
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}

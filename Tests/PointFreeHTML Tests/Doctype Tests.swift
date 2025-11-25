//
//  Doctype Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("Doctype Tests")
struct DoctypeTests {

    @Test("Doctype renders HTML5 doctype")
    func doctypeRendersHTML5() throws {
        let doctype = Doctype()
        let rendered = try String(doctype)
        #expect(rendered == "<!doctype html>")
    }

    @Test("Doctype in document context")
    func doctypeInDocument() throws {
        struct TestDocument: HTML {
            var body: some HTML {
                Doctype()
                tag("html") {
                    tag("body") {
                        HTMLText("content")
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

    @Test("Doctype with other HTML elements")
    func doctypeWithOtherElements() throws {
        let content = HTMLGroup {
            Doctype()
            tag("html") {
                tag("head") {
                    tag("title") {
                        HTMLText("Test Page")
                    }
                }
                tag("body") {
                    HTMLText("Body content")
                }
            }
        }

        let rendered = try String(content)
        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<title>Test Page</title>"))
        #expect(rendered.contains("Body content"))
    }

    @Test("Multiple doctypes")
    func multipleDoctypes() throws {
        let content = HTMLGroup {
            Doctype()
            Doctype()
        }

        let rendered = try String(content)
        #expect(rendered == "<!doctype html><!doctype html>")
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct DoctypeSnapshotTests {
        @Test("Doctype in complete document snapshot")
        func doctypeInDocumentSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        tag("h1") {
                            HTMLText("HTML5 Document")
                        }
                        tag("p") {
                            HTMLText("This document starts with a proper HTML5 doctype declaration.")
                        }
                    }
                } head: {
                    tag("title") {
                        HTMLText("Doctype Example")
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
                    <style>

                    </style>
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

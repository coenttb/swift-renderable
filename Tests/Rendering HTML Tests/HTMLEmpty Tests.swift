//
//  EmptyTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Empty Tests` {

    @Test
    func `Empty renders nothing`() throws {
        let empty = Empty()
        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test
    func `Empty in composition`() throws {
        let group = Group {
            HTML.Text("before")
            Empty()
            HTML.Text("after")
        }

        let rendered = try String(group)
        #expect(rendered == "beforeafter")
    }

    @Test
    func `Empty with attributes does nothing`() throws {
        let empty = Empty()
            .attribute("class", "test")
            .attribute("id", "empty")

        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test
    func `Empty in conditional rendering`() throws {
        struct TestHTML: HTML.View {
            let showContent = false

            var body: some HTML.View {
                if showContent {
                    HTML.Text("visible")
                } else {
                    Empty()
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test
    func `Multiple Empty elements`() throws {
        let group = Group {
            Empty()
            Empty()
            Empty()
        }

        let rendered = try String(group)
        #expect(rendered.isEmpty)
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct EmptySnapshotTests {
        @Test
        func `Empty in conditional content snapshot`() {
            let showContent = false
            let showAlternate = true

            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h1") {
                            HTML.Text("Content Display")
                        }

                        if showContent {
                            tag("section") {
                                HTML.Text("Main content here")
                            }
                        } else {
                            Empty()
                        }

                        if showAlternate {
                            tag("aside") {
                                HTML.Text("Alternate content")
                            }
                        } else {
                            Empty()
                        }

                        tag("footer") {
                            HTML.Text("Footer always shows")
                        }
                    }
                    .attribute("class", "container")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div class="container">
                      <h1>Content Display
                      </h1>
                      <aside>Alternate content
                      </aside>
                      <footer>Footer always shows
                      </footer>
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test
        func `Empty mixed with content snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("article") {
                        tag("h1") {
                            HTML.Text("Article Title")
                        }

                        Empty()  // This should render nothing

                        tag("p") {
                            HTML.Text("First paragraph of content.")
                        }

                        Empty()  // This should render nothing

                        tag("p") {
                            HTML.Text("Second paragraph of content.")
                        }

                        Empty()  // This should render nothing
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
                    <article>
                      <h1>Article Title
                      </h1>
                      <p>First paragraph of content.
                      </p>
                      <p>Second paragraph of content.
                      </p>
                    </article>
                  </body>
                </html>
                """
            }
        }
    }
}

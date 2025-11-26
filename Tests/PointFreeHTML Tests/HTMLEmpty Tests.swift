//
//  EmptyTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Empty Tests")
struct EmptyTests {

    @Test("Empty renders nothing")
    func emptyRendersNothing() throws {
        let empty = Empty()
        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test("Empty in composition")
    func emptyInComposition() throws {
        let group = Group {
            HTMLText("before")
            Empty()
            HTMLText("after")
        }

        let rendered = try String(group)
        #expect(rendered == "beforeafter")
    }

    @Test("Empty with attributes does nothing")
    func emptyWithAttributes() throws {
        let empty = Empty()
            .attribute("class", "test")
            .attribute("id", "empty")

        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test("Empty in conditional rendering")
    func emptyInConditional() throws {
        struct TestHTML: HTML {
            let showContent = false

            var body: some HTML {
                if showContent {
                    HTMLText("visible")
                } else {
                    Empty()
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test("Multiple Empty elements")
    func multipleEmpty() throws {
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
        @Test("Empty in conditional content snapshot")
        func emptyConditionalSnapshot() {
            let showContent = false
            let showAlternate = true

            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        tag("h1") {
                            HTMLText("Content Display")
                        }

                        if showContent {
                            tag("section") {
                                HTMLText("Main content here")
                            }
                        } else {
                            Empty()
                        }

                        if showAlternate {
                            tag("aside") {
                                HTMLText("Alternate content")
                            }
                        } else {
                            Empty()
                        }

                        tag("footer") {
                            HTMLText("Footer always shows")
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
                    <style>

                    </style>
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

        @Test("Empty mixed with content snapshot")
        func emptyMixedContentSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("article") {
                        tag("h1") {
                            HTMLText("Article Title")
                        }

                        Empty()  // This should render nothing

                        tag("p") {
                            HTMLText("First paragraph of content.")
                        }

                        Empty()  // This should render nothing

                        tag("p") {
                            HTMLText("Second paragraph of content.")
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
                    <style>

                    </style>
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

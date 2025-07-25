//
//  HTMLEmptyTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "HTMLEmpty Tests",
    .snapshots(record: .missing)
)
struct HTMLEmptyTests {

    @Test("HTMLEmpty renders nothing")
    func emptyRendersNothing() throws {
        let empty = HTMLEmpty()
        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test("HTMLEmpty in composition")
    func emptyInComposition() throws {
        let group = HTMLGroup {
            HTMLText("before")
            HTMLEmpty()
            HTMLText("after")
        }

        let rendered = try String(group)
        #expect(rendered == "beforeafter")
    }

    @Test("HTMLEmpty with attributes does nothing")
    func emptyWithAttributes() throws {
        let empty = HTMLEmpty()
            .attribute("class", "test")
            .attribute("id", "empty")

        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test("HTMLEmpty in conditional rendering")
    func emptyInConditional() throws {
        struct TestHTML: HTML {
            let showContent = false

            var body: some HTML {
                if showContent {
                    HTMLText("visible")
                } else {
                    HTMLEmpty()
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test("Multiple HTMLEmpty elements")
    func multipleEmpty() throws {
        let group = HTMLGroup {
            HTMLEmpty()
            HTMLEmpty()
            HTMLEmpty()
        }

        let rendered = try String(group)
        #expect(rendered.isEmpty)
    }

    // MARK: - Snapshot Tests

    @Test("HTMLEmpty in conditional content snapshot")
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
                        HTMLEmpty()
                    }

                    if showAlternate {
                        tag("aside") {
                            HTMLText("Alternate content")
                        }
                    } else {
                        HTMLEmpty()
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

    @Test("HTMLEmpty mixed with content snapshot")
    func emptyMixedContentSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("article") {
                    tag("h1") {
                        HTMLText("Article Title")
                    }

                    HTMLEmpty() // This should render nothing

                    tag("p") {
                        HTMLText("First paragraph of content.")
                    }

                    HTMLEmpty() // This should render nothing

                    tag("p") {
                        HTMLText("Second paragraph of content.")
                    }

                    HTMLEmpty() // This should render nothing
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

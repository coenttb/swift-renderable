//
//  HTMLGroupTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "HTMLGroup Tests",
    .snapshots(record: .missing)
)
struct HTMLGroupTests {

    @Test("HTMLGroup with multiple elements")
    func groupWithMultipleElements() throws {
        let group = HTMLGroup {
            HTMLText("first")
            HTMLText("second")
            HTMLText("third")
        }

        let rendered = try String(group)
        #expect(rendered == "firstsecondthird")
    }

    @Test("HTMLGroup with mixed content types")
    func groupWithMixedContent() throws {
        let group = HTMLGroup {
            HTMLText("text")
            tag("span") {
                HTMLText("span content")
            }
            HTMLText("more text")
        }

        let rendered = try String(HTMLDocument { group })
        #expect(rendered.contains("text"))
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("span content"))
        #expect(rendered.contains("</span>"))
        #expect(rendered.contains("more text"))
    }

    @Test("Empty HTMLGroup")
    func emptyGroup() throws {
        let group = HTMLGroup {
            HTMLEmpty()
        }

        let rendered = try String(group)
        #expect(rendered.isEmpty)
    }

    @Test("Nested HTMLGroups")
    func nestedGroups() throws {
        let outerGroup = HTMLGroup {
            HTMLText("outer start")
            HTMLGroup {
                HTMLText("inner1")
                HTMLText("inner2")
            }
            HTMLText("outer end")
        }

        let rendered = try String(outerGroup)
        #expect(rendered == "outer startinner1inner2outer end")
    }

    @Test("HTMLGroup with conditionals")
    func groupWithConditionals() throws {
        struct TestHTML: HTML {
            let showFirst = true
            let showSecond = false

            var body: some HTML {
                HTMLGroup {
                    if showFirst {
                        HTMLText("first")
                    }
                    if showSecond {
                        HTMLText("second")
                    }
                    HTMLText("always")
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "firstalways")
    }

    @Test("HTMLGroup as transparent container")
    func groupAsTransparentContainer() throws {
        let element = tag("div") {
            HTMLGroup {
                tag("p") { HTMLText("paragraph 1") }
                tag("p") { HTMLText("paragraph 2") }
            }
        }

        let rendered = try String(element)
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<p>paragraph 1</p>"))
        #expect(rendered.contains("<p>paragraph 2</p>"))
        #expect(rendered.contains("</div>"))
        #expect(!rendered.contains("<group>") && !rendered.contains("</group>"))
    }

    // MARK: - Snapshot Tests

    @Test("HTMLGroup transparent container snapshot")
    func transparentContainerSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    HTMLGroup {
                        tag("h2") {
                            HTMLText("Section Title")
                        }
                        tag("p") {
                            HTMLText("First paragraph in the group.")
                        }
                        tag("p") {
                            HTMLText("Second paragraph in the group.")
                        }
                        tag("ul") {
                            tag("li") {
                                HTMLText("List item 1")
                            }
                            tag("li") {
                                HTMLText("List item 2")
                            }
                        }
                    }
                }
                .attribute("class", "content-wrapper")
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
            <div class="content-wrapper">
              <h2>Section Title
              </h2>
              <p>First paragraph in the group.
              </p>
              <p>Second paragraph in the group.
              </p>
              <ul>
                <li>List item 1
                </li>
                <li>List item 2
                </li>
              </ul>
            </div>
              </body>
            </html>
            """
        }
    }
}

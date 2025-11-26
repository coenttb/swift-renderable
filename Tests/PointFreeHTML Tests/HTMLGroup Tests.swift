//
//  GroupTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Group Tests")
struct GroupTests {

    @Test("Group with multiple elements")
    func groupWithMultipleElements() throws {
        let group = Group {
            HTML.Text("first")
            HTML.Text("second")
            HTML.Text("third")
        }

        let rendered = try String(group)
        #expect(rendered == "firstsecondthird")
    }

    @Test("Group with mixed content types")
    func groupWithMixedContent() throws {
        let group = Group {
            HTML.Text("text")
            tag("span") {
                HTML.Text("span content")
            }
            HTML.Text("more text")
        }

        let rendered = try String(HTML.Document { group })
        #expect(rendered.contains("text"))
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("span content"))
        #expect(rendered.contains("</span>"))
        #expect(rendered.contains("more text"))
    }

    @Test("Empty Group")
    func emptyGroup() throws {
        let group = Group {
            Empty()
        }

        let rendered = try String(group)
        #expect(rendered.isEmpty)
    }

    @Test("Nested Groups")
    func nestedGroups() throws {
        let outerGroup = Group {
            HTML.Text("outer start")
            Group {
                HTML.Text("inner1")
                HTML.Text("inner2")
            }
            HTML.Text("outer end")
        }

        let rendered = try String(outerGroup)
        #expect(rendered == "outer startinner1inner2outer end")
    }

    @Test("Group with conditionals")
    func groupWithConditionals() throws {
        struct TestHTML: HTML.View {
            let showFirst = true
            let showSecond = false

            var body: some HTML.View {
                Group {
                    if showFirst {
                        HTML.Text("first")
                    }
                    if showSecond {
                        HTML.Text("second")
                    }
                    HTML.Text("always")
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "firstalways")
    }

    @Test("Group as transparent container")
    func groupAsTransparentContainer() throws {
        let element = tag("div") {
            Group {
                tag("p") { HTML.Text("paragraph 1") }
                tag("p") { HTML.Text("paragraph 2") }
            }
        }

        let rendered = try String(element)
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<p>paragraph 1</p>"))
        #expect(rendered.contains("<p>paragraph 2</p>"))
        #expect(rendered.contains("</div>"))
        #expect(!rendered.contains("<group>") && !rendered.contains("</group>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct GroupSnapshotTests {
        @Test("Group transparent container snapshot")
        func transparentContainerSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        Group {
                            tag("h2") {
                                HTML.Text("Section Title")
                            }
                            tag("p") {
                                HTML.Text("First paragraph in the group.")
                            }
                            tag("p") {
                                HTML.Text("Second paragraph in the group.")
                            }
                            tag("ul") {
                                tag("li") {
                                    HTML.Text("List item 1")
                                }
                                tag("li") {
                                    HTML.Text("List item 2")
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
}

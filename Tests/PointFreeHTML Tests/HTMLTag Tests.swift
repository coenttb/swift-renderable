//
//  HTML.Tag Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTML.Tag Tests")
struct HTMLTagTests {

    @Test("HTML.Tag basic functionality")
    func htmlTagBasics() throws {
        let tag: some HTML.View = HTML.Tag("div") {
            HTML.Text("content")
        }

        let rendered = try String(HTML.Document { tag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("content"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTML.TextTag for text content")
    func htmlTextTag() throws {
        let textTag = HTML.TextTag("span") {
            "text content"
        }

        let rendered = try String(HTML.Document { textTag })
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("text content"))
        #expect(rendered.contains("</span>"))
    }

    @Test("HTMLVoidTag self-closing")
    func htmlVoidTag() throws {
        let voidTag = HTML.VoidTag("br")()

        let rendered = try String(HTML.Document { voidTag })
        #expect(rendered.contains("<br"))
        #expect(rendered.contains("/>") || rendered.contains(">"))
        #expect(!rendered.contains("</br>"))
    }

    @Test("HTMLVoidTag with attributes")
    func voidTagWithAttributes() throws {
        let voidTag = HTML.VoidTag("input")()
            .attribute("type", "text")
            .attribute("name", "username")

        let rendered = try String(HTML.Document { voidTag })
        #expect(rendered.contains("<input"))
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("name=\"username\""))
        #expect(!rendered.contains("</input>"))
    }

    @Test("Nested HTML.Tags")
    func nestedTags() throws {
        let outerTag = HTML.Tag("div") {
            HTML.Tag("p") {
                HTML.Text("nested paragraph")
            }
        }

        let rendered = try String(HTML.Document { outerTag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("nested paragraph"))
        #expect(rendered.contains("</p>"))
        #expect(rendered.contains("</div>"))
    }

    @Test("Empty HTML.Tag")
    func emptyTag() throws {
        let tag = HTML.Tag("div")()

        let rendered = try String(HTML.Document { tag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("</div>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLTagSnapshotTests {
        @Test("HTML.Tag semantic structure snapshot")
        func semanticStructureSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("main") {
                        HTML.Tag("header") {
                            HTML.Tag("nav") {
                                HTML.TextTag("h1") {
                                    "Site Navigation"
                                }
                                HTML.Tag("ul") {
                                    HTML.Tag("li") {
                                        HTML.TextTag("a") {
                                            "Home"
                                        }
                                    }
                                    HTML.Tag("li") {
                                        HTML.TextTag("a") {
                                            "About"
                                        }
                                    }
                                }
                            }
                        }

                        HTML.Tag("section") {
                            HTML.TextTag("h2") {
                                "Main Content"
                            }
                            HTML.TextTag("p") {
                                "This demonstrates semantic HTML structure using HTML.Tag components."
                            }
                        }
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
                    <main>
                      <header>
                        <nav>
                          <h1>Site Navigation
                          </h1>
                          <ul>
                            <li><a>Home</a>
                            </li>
                            <li><a>About</a>
                            </li>
                          </ul>
                        </nav>
                      </header>
                      <section>
                        <h2>Main Content
                        </h2>
                        <p>This demonstrates semantic HTML structure using HTML.Tag components.
                        </p>
                      </section>
                    </main>
                  </body>
                </html>
                """
            }
        }

        @Test("HTMLVoidTag form elements snapshot")
        func voidTagFormSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    HTML.Tag("form") {
                        HTML.Tag("fieldset") {
                            HTML.TextTag("legend") {
                                "Contact Information"
                            }

                            HTML.VoidTag("input")()
                                .attribute("type", "text")
                                .attribute("name", "name")
                                .attribute("placeholder", "Your Name")

                            HTML.VoidTag("br")()

                            HTML.VoidTag("input")()
                                .attribute("type", "email")
                                .attribute("name", "email")
                                .attribute("placeholder", "Your Email")

                            HTML.VoidTag("hr")()

                            HTML.Tag("button") {
                                HTML.Text("Submit Form")
                            }
                            .attribute("type", "submit")
                        }
                    }
                    .attribute("method", "post")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <form method="post">
                      <fieldset>
                        <legend>Contact Information
                        </legend><input type="text" name="name" placeholder="Your Name"><br><input type="email" name="email" placeholder="Your Email">
                        <hr><button type="submit">Submit Form</button>
                      </fieldset>
                    </form>
                  </body>
                </html>
                """
            }
        }
    }
}

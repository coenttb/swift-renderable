//
//  HTML.Tag Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.Tag Tests` {

    @Test
    func `HTML.Tag basic functionality`() throws {
        let tag: some HTML.View = HTML.Tag("div") {
            HTML.Text("content")
        }

        let rendered = try String(HTML.Document { tag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("content"))
        #expect(rendered.contains("</div>"))
    }

    @Test
    func `HTML.Tag.Text for text content`() throws {
        let textTag = HTML.Tag.Text("span") {
            "text content"
        }

        let rendered = try String(HTML.Document { textTag })
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("text content"))
        #expect(rendered.contains("</span>"))
    }

    @Test
    func `HTMLVoidTag self-closing`() throws {
        let voidTag = HTML.Tag.Void("br")()

        let rendered = try String(HTML.Document { voidTag })
        #expect(rendered.contains("<br"))
        #expect(rendered.contains("/>") || rendered.contains(">"))
        #expect(!rendered.contains("</br>"))
    }

    @Test
    func `HTMLVoidTag with attributes`() throws {
        let voidTag = HTML.Tag.Void("input")()
            .attribute("type", "text")
            .attribute("name", "username")

        let rendered = try String(HTML.Document { voidTag })
        #expect(rendered.contains("<input"))
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("name=\"username\""))
        #expect(!rendered.contains("</input>"))
    }

    @Test
    func `Nested HTML.Tags`() throws {
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

    @Test
    func `Empty HTML.Tag`() throws {
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
        @Test
        func `HTML.Tag semantic structure snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("main") {
                        HTML.Tag("header") {
                            HTML.Tag("nav") {
                                HTML.Tag.Text("h1") {
                                    "Site Navigation"
                                }
                                HTML.Tag("ul") {
                                    HTML.Tag("li") {
                                        HTML.Tag.Text("a") {
                                            "Home"
                                        }
                                    }
                                    HTML.Tag("li") {
                                        HTML.Tag.Text("a") {
                                            "About"
                                        }
                                    }
                                }
                            }
                        }

                        HTML.Tag("section") {
                            HTML.Tag.Text("h2") {
                                "Main Content"
                            }
                            HTML.Tag.Text("p") {
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

        @Test
        func `HTMLVoidTag form elements snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    HTML.Tag("form") {
                        HTML.Tag("fieldset") {
                            HTML.Tag.Text("legend") {
                                "Contact Information"
                            }

                            HTML.Tag.Void("input")()
                                .attribute("type", "text")
                                .attribute("name", "name")
                                .attribute("placeholder", "Your Name")

                            HTML.Tag.Void("br")()

                            HTML.Tag.Void("input")()
                                .attribute("type", "email")
                                .attribute("name", "email")
                                .attribute("placeholder", "Your Email")

                            HTML.Tag.Void("hr")()

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

//
//  HTMLTag Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTMLTag Tests")
struct HTMLTagTests {

    @Test("HTMLTag basic functionality")
    func htmlTagBasics() throws {
        let tag: some HTML = HTMLTag("div") {
            HTMLText("content")
        }

        let rendered = try String(Document { tag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("content"))
        #expect(rendered.contains("</div>"))
    }

    @Test("HTMLTextTag for text content")
    func htmlTextTag() throws {
        let textTag = HTMLTextTag("span") {
            "text content"
        }

        let rendered = try String(Document { textTag })
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("text content"))
        #expect(rendered.contains("</span>"))
    }

    @Test("HTMLVoidTag self-closing")
    func htmlVoidTag() throws {
        let voidTag = HTMLVoidTag("br")()

        let rendered = try String(Document { voidTag })
        #expect(rendered.contains("<br"))
        #expect(rendered.contains("/>") || rendered.contains(">"))
        #expect(!rendered.contains("</br>"))
    }

    @Test("HTMLVoidTag with attributes")
    func voidTagWithAttributes() throws {
        let voidTag = HTMLVoidTag("input")()
            .attribute("type", "text")
            .attribute("name", "username")

        let rendered = try String(Document { voidTag })
        #expect(rendered.contains("<input"))
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("name=\"username\""))
        #expect(!rendered.contains("</input>"))
    }

    @Test("Nested HTMLTags")
    func nestedTags() throws {
        let outerTag = HTMLTag("div") {
            HTMLTag("p") {
                HTMLText("nested paragraph")
            }
        }

        let rendered = try String(Document { outerTag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("nested paragraph"))
        #expect(rendered.contains("</p>"))
        #expect(rendered.contains("</div>"))
    }

    @Test("Empty HTMLTag")
    func emptyTag() throws {
        let tag = HTMLTag("div")()

        let rendered = try String(Document { tag })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("</div>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLTagSnapshotTests {
        @Test("HTMLTag semantic structure snapshot")
        func semanticStructureSnapshot() {
            assertInlineSnapshot(
                of: Document {
                    tag("main") {
                        HTMLTag("header") {
                            HTMLTag("nav") {
                                HTMLTextTag("h1") {
                                    "Site Navigation"
                                }
                                HTMLTag("ul") {
                                    HTMLTag("li") {
                                        HTMLTextTag("a") {
                                            "Home"
                                        }
                                    }
                                    HTMLTag("li") {
                                        HTMLTextTag("a") {
                                            "About"
                                        }
                                    }
                                }
                            }
                        }

                        HTMLTag("section") {
                            HTMLTextTag("h2") {
                                "Main Content"
                            }
                            HTMLTextTag("p") {
                                "This demonstrates semantic HTML structure using HTMLTag components."
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
                        <p>This demonstrates semantic HTML structure using HTMLTag components.
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
                of: Document {
                    HTMLTag("form") {
                        HTMLTag("fieldset") {
                            HTMLTextTag("legend") {
                                "Contact Information"
                            }

                            HTMLVoidTag("input")()
                                .attribute("type", "text")
                                .attribute("name", "name")
                                .attribute("placeholder", "Your Name")

                            HTMLVoidTag("br")()

                            HTMLVoidTag("input")()
                                .attribute("type", "email")
                                .attribute("name", "email")
                                .attribute("placeholder", "Your Email")

                            HTMLVoidTag("hr")()

                            HTMLTag("button") {
                                HTMLText("Submit Form")
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

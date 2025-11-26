//
//  _HTMLConditional Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("_HTMLConditional Tests")
struct _HTMLConditionalTests {

    // MARK: - Basic Conditionals

    @Test("_HTMLConditional renders true branch")
    func rendersTrueBranch() throws {
        struct TestHTML: HTML {
            let condition = true
            var body: some HTML {
                if condition {
                    tag("div") {
                        HTMLText("True branch")
                    }
                } else {
                    tag("span") {
                        HTMLText("False branch")
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("True branch"))
        #expect(!rendered.contains("<span>"))
        #expect(!rendered.contains("False branch"))
    }

    @Test("_HTMLConditional renders false branch")
    func rendersFalseBranch() throws {
        struct TestHTML: HTML {
            let condition = false
            var body: some HTML {
                if condition {
                    tag("div") {
                        HTMLText("True branch")
                    }
                } else {
                    tag("span") {
                        HTMLText("False branch")
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(!rendered.contains("<div>"))
        #expect(!rendered.contains("True branch"))
        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("False branch"))
    }

    // MARK: - If-Only Conditionals

    @Test("_HTMLConditional if-only true")
    func ifOnlyTrue() throws {
        struct TestHTML: HTML {
            let show = true
            var body: some HTML {
                if show {
                    tag("div") {
                        HTMLText("Shown")
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.contains("Shown"))
    }

    @Test("_HTMLConditional if-only false")
    func ifOnlyFalse() throws {
        struct TestHTML: HTML {
            let show = false
            var body: some HTML {
                if show {
                    tag("div") {
                        HTMLText("Shown")
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.isEmpty)
    }

    // MARK: - Nested Conditionals

    @Test("_HTMLConditional nested conditionals")
    func nestedConditionals() throws {
        struct TestHTML: HTML {
            let outer = true
            let inner = false
            var body: some HTML {
                if outer {
                    tag("div") {
                        if inner {
                            HTMLText("Inner true")
                        } else {
                            HTMLText("Inner false")
                        }
                    }
                } else {
                    HTMLText("Outer false")
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("Inner false"))
        #expect(!rendered.contains("Inner true"))
        #expect(!rendered.contains("Outer false"))
    }

    // MARK: - Conditionals with Attributes

    @Test("_HTMLConditional with attributes")
    func withAttributes() throws {
        struct TestHTML: HTML {
            let isActive = true
            var body: some HTML {
                if isActive {
                    tag("button") {
                        HTMLText("Active")
                    }
                    .attribute("class", "btn-active")
                } else {
                    tag("button") {
                        HTMLText("Inactive")
                    }
                    .attribute("class", "btn-inactive")
                    .attribute("disabled", "")
                }
            }
        }

        let rendered = try String(Document { TestHTML() })
        #expect(rendered.contains("btn-active"))
        #expect(rendered.contains("Active"))
        #expect(!rendered.contains("btn-inactive"))
        #expect(!rendered.contains("disabled"))
    }

    // MARK: - Conditionals with Styles

    @Test("_HTMLConditional with inline styles")
    func withInlineStyles() throws {
        struct TestHTML: HTML {
            let isHighlighted = true
            var body: some HTML {
                if isHighlighted {
                    tag("span") {
                        HTMLText("Highlighted")
                    }
                    .inlineStyle("background-color", "yellow")
                } else {
                    tag("span") {
                        HTMLText("Normal")
                    }
                }
            }
        }

        let rendered = try String(Document { TestHTML() })
        #expect(rendered.contains("background-color:yellow"))
        #expect(rendered.contains("Highlighted"))
    }

    // MARK: - Different Branch Types

    @Test("_HTMLConditional different element types")
    func differentElementTypes() throws {
        struct TestHTML: HTML {
            let useLink = true
            var body: some HTML {
                if useLink {
                    tag("a") {
                        HTMLText("Click here")
                    }
                    .attribute("href", "/page")
                } else {
                    tag("span") {
                        HTMLText("No link")
                    }
                }
            }
        }

        let rendered = try String(Document { TestHTML() })
        #expect(rendered.contains("<a"))
        #expect(rendered.contains("href=\"/page\""))
        #expect(!rendered.contains("<span>"))
    }

    // MARK: - Complex Content

    @Test("_HTMLConditional with complex content")
    func complexContent() throws {
        struct TestHTML: HTML {
            let hasDetails = true
            var body: some HTML {
                tag("article") {
                    tag("h1") {
                        HTMLText("Title")
                    }
                    if hasDetails {
                        tag("section") {
                            tag("h2") {
                                HTMLText("Details")
                            }
                            tag("p") {
                                HTMLText("More information here.")
                            }
                        }
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.contains("<article>"))
        #expect(rendered.contains("<section>"))
        #expect(rendered.contains("Details"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct _HTMLConditionalSnapshotTests {
        @Test("_HTMLConditional true branch snapshot")
        func trueBranchSnapshot() {
            struct ConditionalPage: HTML {
                let isLoggedIn = true
                var body: some HTML {
                    tag("header") {
                        if isLoggedIn {
                            tag("nav") {
                                tag("span") {
                                    HTMLText("Welcome, User!")
                                }
                                tag("a") {
                                    HTMLText("Logout")
                                }
                                .attribute("href", "/logout")
                            }
                        } else {
                            tag("a") {
                                HTMLText("Login")
                            }
                            .attribute("href", "/login")
                        }
                    }
                }
            }

            assertInlineSnapshot(
                of: Document {
                    ConditionalPage()
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <header>
                      <nav><span>Welcome, User!</span><a href="/logout">Logout</a>
                      </nav>
                    </header>
                  </body>
                </html>
                """
            }
        }
    }
}

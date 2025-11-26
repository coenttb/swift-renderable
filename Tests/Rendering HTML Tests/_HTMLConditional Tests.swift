//
//  _Conditional Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `_Conditional Tests` {

    // MARK: - Basic Conditionals

    @Test
    func `_Conditional renders true branch`() throws {
        struct TestHTML: HTML.View {
            let condition = true
            var body: some HTML.View {
                if condition {
                    tag("div") {
                        HTML.Text("True branch")
                    }
                } else {
                    tag("span") {
                        HTML.Text("False branch")
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

    @Test
    func `_Conditional renders false branch`() throws {
        struct TestHTML: HTML.View {
            let condition = false
            var body: some HTML.View {
                if condition {
                    tag("div") {
                        HTML.Text("True branch")
                    }
                } else {
                    tag("span") {
                        HTML.Text("False branch")
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

    @Test
    func `_Conditional if-only true`() throws {
        struct TestHTML: HTML.View {
            let show = true
            var body: some HTML.View {
                if show {
                    tag("div") {
                        HTML.Text("Shown")
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.contains("Shown"))
    }

    @Test
    func `_Conditional if-only false`() throws {
        struct TestHTML: HTML.View {
            let show = false
            var body: some HTML.View {
                if show {
                    tag("div") {
                        HTML.Text("Shown")
                    }
                }
            }
        }

        let rendered = try String(TestHTML())
        #expect(rendered.isEmpty)
    }

    // MARK: - Nested Conditionals

    @Test
    func `_Conditional nested conditionals`() throws {
        struct TestHTML: HTML.View {
            let outer = true
            let inner = false
            var body: some HTML.View {
                if outer {
                    tag("div") {
                        if inner {
                            HTML.Text("Inner true")
                        } else {
                            HTML.Text("Inner false")
                        }
                    }
                } else {
                    HTML.Text("Outer false")
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

    @Test
    func `_Conditional with attributes`() throws {
        struct TestHTML: HTML.View {
            let isActive = true
            var body: some HTML.View {
                if isActive {
                    tag("button") {
                        HTML.Text("Active")
                    }
                    .attribute("class", "btn-active")
                } else {
                    tag("button") {
                        HTML.Text("Inactive")
                    }
                    .attribute("class", "btn-inactive")
                    .attribute("disabled", "")
                }
            }
        }

        let rendered = try String(HTML.Document { TestHTML() })
        #expect(rendered.contains("btn-active"))
        #expect(rendered.contains("Active"))
        #expect(!rendered.contains("btn-inactive"))
        #expect(!rendered.contains("disabled"))
    }

    // MARK: - Conditionals with Styles

    @Test
    func `_Conditional with inline styles`() throws {
        struct TestHTML: HTML.View {
            let isHighlighted = true
            var body: some HTML.View {
                if isHighlighted {
                    tag("span") {
                        HTML.Text("Highlighted")
                    }
                    .inlineStyle("background-color", "yellow")
                } else {
                    tag("span") {
                        HTML.Text("Normal")
                    }
                }
            }
        }

        let rendered = try String(HTML.Document { TestHTML() })
        #expect(rendered.contains("background-color:yellow"))
        #expect(rendered.contains("Highlighted"))
    }

    // MARK: - Different Branch Types

    @Test
    func `_Conditional different element types`() throws {
        struct TestHTML: HTML.View {
            let useLink = true
            var body: some HTML.View {
                if useLink {
                    tag("a") {
                        HTML.Text("Click here")
                    }
                    .attribute("href", "/page")
                } else {
                    tag("span") {
                        HTML.Text("No link")
                    }
                }
            }
        }

        let rendered = try String(HTML.Document { TestHTML() })
        #expect(rendered.contains("<a"))
        #expect(rendered.contains("href=\"/page\""))
        #expect(!rendered.contains("<span>"))
    }

    // MARK: - Complex Content

    @Test
    func `_Conditional with complex content`() throws {
        struct TestHTML: HTML.View {
            let hasDetails = true
            var body: some HTML.View {
                tag("article") {
                    tag("h1") {
                        HTML.Text("Title")
                    }
                    if hasDetails {
                        tag("section") {
                            tag("h2") {
                                HTML.Text("Details")
                            }
                            tag("p") {
                                HTML.Text("More information here.")
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
    struct _ConditionalSnapshotTests {
        @Test
        func `_Conditional true branch snapshot`() {
            struct ConditionalPage: HTML.View {
                let isLoggedIn = true
                var body: some HTML.View {
                    tag("header") {
                        if isLoggedIn {
                            tag("nav") {
                                tag("span") {
                                    HTML.Text("Welcome, User!")
                                }
                                tag("a") {
                                    HTML.Text("Logout")
                                }
                                .attribute("href", "/logout")
                            }
                        } else {
                            tag("a") {
                                HTML.Text("Login")
                            }
                            .attribute("href", "/login")
                        }
                    }
                }
            }

            assertInlineSnapshot(
                of: HTML.Document {
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

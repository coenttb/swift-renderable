//
//  Integration Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting integration tests that verify multiple components work together.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Integration Tests")
struct IntegrationTests {

    // MARK: - Full Page Rendering

    @Test("Complete page with head and body")
    func completePage() throws {
        let document = HTMLDocument(
            head: {
                tag("title") { HTMLText("My Page") }
                tag("meta").attribute("charset", "utf-8")
                tag("meta")
                    .attribute("name", "viewport")
                    .attribute("content", "width=device-width, initial-scale=1")
            },
            body: {
                tag("header") {
                    tag("nav") {
                        tag("a") { HTMLText("Home") }.attribute("href", "/")
                        tag("a") { HTMLText("About") }.attribute("href", "/about")
                    }
                }
                tag("main") {
                    tag("h1") { HTMLText("Welcome") }
                    tag("p") { HTMLText("This is the main content.") }
                }
                tag("footer") {
                    tag("p") { HTMLText("© 2025") }
                }
            }
        )

        let rendered = try String(document)

        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<title>My Page</title>"))
        #expect(rendered.contains("<header>"))
        #expect(rendered.contains("<nav>"))
        #expect(rendered.contains("<main>"))
        #expect(rendered.contains("<footer>"))
    }

    // MARK: - Component Composition

    @Test("Custom components compose correctly")
    func componentComposition() throws {
        struct Button: HTML {
            let label: String
            let action: String

            var body: some HTML {
                tag("button") {
                    HTMLText(label)
                }
                .attribute("onclick", action)
                .attribute("class", "btn")
            }
        }

        struct Card: HTML {
            let title: String
            let content: String

            var body: some HTML {
                tag("article") {
                    tag("h2") { HTMLText(title) }
                    tag("p") { HTMLText(content) }
                    Button(label: "Learn More", action: "handleClick()")
                }
                .attribute("class", "card")
            }
        }

        struct CardList: HTML {
            let cards: [(title: String, content: String)]

            var body: some HTML {
                tag("section") {
                    for card in cards {
                        Card(title: card.title, content: card.content)
                    }
                }
            }
        }

        let html = CardList(cards: [
            ("Card 1", "Content 1"),
            ("Card 2", "Content 2"),
            ("Card 3", "Content 3")
        ])

        let rendered = try String(html)

        #expect(rendered.contains("<section>"))
        #expect(rendered.contains("Card 1"))
        #expect(rendered.contains("Card 2"))
        #expect(rendered.contains("Card 3"))
        #expect(rendered.contains("class=\"card\""))
        #expect(rendered.contains("class=\"btn\""))
    }

    // MARK: - Styles with Media Queries

    @Test("Responsive styles integration")
    func responsiveStyles() throws {
        let html = tag("div") {
            tag("p") { HTMLText("Responsive text") }
        }
        .inlineStyle("width", "100%")
        .inlineStyle("width", "50%", atRule: .init(rawValue: "@media (min-width: 768px)"), selector: nil, pseudo: nil)
        .inlineStyle("width", "33%", atRule: .init(rawValue: "@media (min-width: 1024px)"), selector: nil, pseudo: nil)

        let rendered = try String(Document { html })

        #expect(rendered.contains("width:100%"))
        #expect(rendered.contains("@media (min-width: 768px)"))
        #expect(rendered.contains("@media (min-width: 1024px)"))
    }

    @Test("Pseudo-class styles integration")
    func pseudoClassStyles() throws {
        let html = tag("a") {
            HTMLText("Hover me")
        }
        .attribute("href", "#")
        .inlineStyle("color", "blue")
        .inlineStyle("color", "red", pseudo: .hover)
        .inlineStyle("text-decoration", "underline", pseudo: .hover)

        let rendered = try String(Document { html })

        #expect(rendered.contains("color:blue"))
        #expect(rendered.contains(":hover"))
    }

    // MARK: - Form Integration

    @Test("Complete form rendering")
    func completeForm() throws {
        let html = tag("form") {
            tag("div") {
                tag("label") { HTMLText("Name") }.attribute("for", "name")
                tag("input")
                    .attribute("type", "text")
                    .attribute("id", "name")
                    .attribute("name", "name")
                    .attribute("required", "required")
            }
            tag("div") {
                tag("label") { HTMLText("Email") }.attribute("for", "email")
                tag("input")
                    .attribute("type", "email")
                    .attribute("id", "email")
                    .attribute("name", "email")
            }
            tag("div") {
                tag("label") { HTMLText("Message") }.attribute("for", "message")
                tag("textarea")
                    .attribute("id", "message")
                    .attribute("name", "message")
                    .attribute("rows", "5")
            }
            tag("button") { HTMLText("Submit") }
                .attribute("type", "submit")
        }
        .attribute("method", "post")
        .attribute("action", "/submit")

        let rendered = try String(html)

        #expect(rendered.contains("<form"))
        #expect(rendered.contains("method=\"post\""))
        #expect(rendered.contains("<input"))
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("type=\"email\""))
        #expect(rendered.contains("<textarea"))
        #expect(rendered.contains("<button"))
    }

    // MARK: - Table Integration

    @Test("Data table rendering")
    func dataTable() throws {
        struct Row {
            let name: String
            let value: Int
        }

        let data = [
            Row(name: "Alpha", value: 100),
            Row(name: "Beta", value: 200),
            Row(name: "Gamma", value: 300)
        ]

        let html = tag("table") {
            tag("thead") {
                tag("tr") {
                    tag("th") { HTMLText("Name") }
                    tag("th") { HTMLText("Value") }
                }
            }
            tag("tbody") {
                for row in data {
                    tag("tr") {
                        tag("td") { HTMLText(row.name) }
                        tag("td") { HTMLText(String(row.value)) }
                    }
                }
            }
        }
        .attribute("class", "data-table")

        let rendered = try String(html)

        #expect(rendered.contains("<table"))
        #expect(rendered.contains("<thead>"))
        #expect(rendered.contains("<tbody>"))
        #expect(rendered.contains("Alpha"))
        #expect(rendered.contains("200"))
    }

    // MARK: - Conditional Rendering

    @Test("Conditional components")
    func conditionalComponents() throws {
        struct UserProfile: HTML {
            let user: (name: String, isAdmin: Bool)?

            var body: some HTML {
                tag("div") {
                    if let user = user {
                        tag("h1") { HTMLText("Welcome, \(user.name)") }
                        if user.isAdmin {
                            tag("span") { HTMLText("Admin") }
                                .attribute("class", "badge")
                        }
                    } else {
                        tag("p") { HTMLText("Please log in") }
                    }
                }
            }
        }

        let loggedIn = try String(UserProfile(user: ("Alice", true)))
        let guest = try String(UserProfile(user: nil))

        #expect(loggedIn.contains("Welcome, Alice"))
        #expect(loggedIn.contains("Admin"))
        #expect(guest.contains("Please log in"))
        #expect(!guest.contains("Welcome"))
    }

    // MARK: - Raw HTML Integration

    @Test("Raw HTML within structured content")
    func rawHTMLIntegration() throws {
        let html = tag("div") {
            tag("h1") { HTMLText("Title") }
            HTMLRaw("<hr>")
            tag("p") { HTMLText("Content after raw") }
            HTMLRaw("<!-- This is a comment -->")
        }

        let rendered = try String(html)

        #expect(rendered.contains("<hr>"))
        #expect(rendered.contains("<!-- This is a comment -->"))
        #expect(rendered.contains("<h1>Title</h1>"))
    }

    // MARK: - AnyHTML Integration

    @Test("AnyHTML in heterogeneous collection")
    func anyHTMLCollection() throws {
        let components: [AnyHTML] = [
            AnyHTML(tag("h1") { HTMLText("Header") }),
            AnyHTML(tag("p") { HTMLText("Paragraph") }),
            AnyHTML(tag("ul") {
                tag("li") { HTMLText("Item") }
            })
        ]

        let html = tag("div") {
            for component in components {
                component
            }
        }

        let rendered = try String(html)

        #expect(rendered.contains("<h1>"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("<ul>"))
    }

    // MARK: - Configuration Integration

    @Test("Email configuration applies to full document")
    func emailConfiguration() throws {
        let document = Document {
            tag("div") {
                tag("p") { HTMLText("Email content") }
                    .inlineStyle("color", "black")
            }
            .inlineStyle("max-width", "600px")
        }

        let rendered: String = try HTMLContext.Rendering.$current.withValue(.email) {
            try String(document)
        }

        #expect(rendered.contains("!important"))
    }

    @Test("Pretty configuration produces formatted output")
    func prettyConfiguration() throws {
        let document = Document {
            tag("div") {
                tag("p") { HTMLText("Pretty printed") }
            }
        }

        let rendered: String = HTMLContext.Rendering.$current.withValue(.pretty) {
            try! String(document)
        }

        #expect(rendered.contains("\n"))
    }

    // MARK: - HTMLForEach Integration

    @Test("HTMLForEach with identifiable data")
    func htmlForEachIdentifiable() throws {
        struct Item: Identifiable {
            let id: Int
            let name: String
        }

        let items = [
            Item(id: 1, name: "First"),
            Item(id: 2, name: "Second"),
            Item(id: 3, name: "Third")
        ]

        let html = tag("ul") {
            HTMLForEach(items) { item in
                tag("li") { HTMLText(item.name) }
                    .attribute("data-id", String(item.id))
            }
        }

        let rendered = try String(html)

        #expect(rendered.contains("data-id=\"1\""))
        #expect(rendered.contains("data-id=\"2\""))
        #expect(rendered.contains("First"))
        #expect(rendered.contains("Second"))
    }

    // MARK: - Group Integration

    @Test("Group flattens nested content")
    func groupFlattening() throws {
        let html = tag("div") {
            Group {
                Group {
                    tag("span") { HTMLText("Deeply") }
                }
                Group {
                    tag("span") { HTMLText("Nested") }
                }
            }
        }

        let rendered = try String(html)

        #expect(rendered.contains("Deeply"))
        #expect(rendered.contains("Nested"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct IntegrationSnapshotTests {
        @Test("Full page integration snapshot")
        func fullPageSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument(
                    head: {
                        tag("title") { HTMLText("Integration Test") }
                    },
                    body: {
                        tag("header") {
                            tag("h1") { HTMLText("Welcome") }
                        }
                        tag("main") {
                            tag("article") {
                                tag("h2") { HTMLText("Article Title") }
                                tag("p") { HTMLText("Article content here.") }
                            }
                        }
                        tag("footer") {
                            HTMLText("Footer")
                        }
                    }
                ),
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <title>Integration Test
                    </title>
                  </head>
                  <body>
                    <header>
                      <h1>Welcome
                      </h1>
                    </header>
                    <main>
                      <article>
                        <h2>Article Title
                        </h2>
                        <p>Article content here.
                        </p>
                      </article>
                    </main>
                    <footer>Footer
                    </footer>
                  </body>
                </html>
                """
            }
        }
    }
}

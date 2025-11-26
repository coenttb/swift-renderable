//
//  Integration Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting integration tests that verify multiple components work together.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Integration Tests` {

    // MARK: - Full Page Rendering

    @Test
    func `Complete page with head and body`() throws {
        let document = HTML.Document(
            head: {
                tag("title") { HTML.Text("My Page") }
                tag("meta").attribute("charset", "utf-8")
                tag("meta")
                    .attribute("name", "viewport")
                    .attribute("content", "width=device-width, initial-scale=1")
            },
            body: {
                tag("header") {
                    tag("nav") {
                        tag("a") { HTML.Text("Home") }.attribute("href", "/")
                        tag("a") { HTML.Text("About") }.attribute("href", "/about")
                    }
                }
                tag("main") {
                    tag("h1") { HTML.Text("Welcome") }
                    tag("p") { HTML.Text("This is the main content.") }
                }
                tag("footer") {
                    tag("p") { HTML.Text("© 2025") }
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

    @Test
    func `Custom components compose correctly`() throws {
        struct Button: HTML.View {
            let label: String
            let action: String

            var body: some HTML.View {
                tag("button") {
                    HTML.Text(label)
                }
                .attribute("onclick", action)
                .attribute("class", "btn")
            }
        }

        struct Card: HTML.View {
            let title: String
            let content: String

            var body: some HTML.View {
                tag("article") {
                    tag("h2") { HTML.Text(title) }
                    tag("p") { HTML.Text(content) }
                    Button(label: "Learn More", action: "handleClick()")
                }
                .attribute("class", "card")
            }
        }

        struct CardList: HTML.View {
            let cards: [(title: String, content: String)]

            var body: some HTML.View {
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

    @Test
    func `Responsive styles integration`() throws {
        let html = tag("div") {
            tag("p") { HTML.Text("Responsive text") }
        }
        .inlineStyle("width", "100%")
        .inlineStyle("width", "50%", atRule: .init(rawValue: "@media (min-width: 768px)"), selector: nil, pseudo: nil)
        .inlineStyle("width", "33%", atRule: .init(rawValue: "@media (min-width: 1024px)"), selector: nil, pseudo: nil)

        let rendered = try String(HTML.Document { html })

        #expect(rendered.contains("width:100%"))
        #expect(rendered.contains("@media (min-width: 768px)"))
        #expect(rendered.contains("@media (min-width: 1024px)"))
    }

    @Test
    func `Pseudo-class styles integration`() throws {
        let html = tag("a") {
            HTML.Text("Hover me")
        }
        .attribute("href", "#")
        .inlineStyle("color", "blue")
        .inlineStyle("color", "red", pseudo: .hover)
        .inlineStyle("text-decoration", "underline", pseudo: .hover)

        let rendered = try String(HTML.Document { html })

        #expect(rendered.contains("color:blue"))
        #expect(rendered.contains(":hover"))
    }

    // MARK: - Form Integration

    @Test
    func `Complete form rendering`() throws {
        let html = tag("form") {
            tag("div") {
                tag("label") { HTML.Text("Name") }.attribute("for", "name")
                tag("input")
                    .attribute("type", "text")
                    .attribute("id", "name")
                    .attribute("name", "name")
                    .attribute("required", "required")
            }
            tag("div") {
                tag("label") { HTML.Text("Email") }.attribute("for", "email")
                tag("input")
                    .attribute("type", "email")
                    .attribute("id", "email")
                    .attribute("name", "email")
            }
            tag("div") {
                tag("label") { HTML.Text("Message") }.attribute("for", "message")
                tag("textarea")
                    .attribute("id", "message")
                    .attribute("name", "message")
                    .attribute("rows", "5")
            }
            tag("button") { HTML.Text("Submit") }
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

    @Test
    func `Data table rendering`() throws {
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
                    tag("th") { HTML.Text("Name") }
                    tag("th") { HTML.Text("Value") }
                }
            }
            tag("tbody") {
                for row in data {
                    tag("tr") {
                        tag("td") { HTML.Text(row.name) }
                        tag("td") { HTML.Text(String(row.value)) }
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

    @Test
    func `Conditional components`() throws {
        struct UserProfile: HTML.View {
            let user: (name: String, isAdmin: Bool)?

            var body: some HTML.View {
                tag("div") {
                    if let user = user {
                        tag("h1") { HTML.Text("Welcome, \(user.name)") }
                        if user.isAdmin {
                            tag("span") { HTML.Text("Admin") }
                                .attribute("class", "badge")
                        }
                    } else {
                        tag("p") { HTML.Text("Please log in") }
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

    @Test
    func `Raw HTML within structured content`() throws {
        let html = tag("div") {
            tag("h1") { HTML.Text("Title") }
            HTML.Raw("<hr>")
            tag("p") { HTML.Text("Content after raw") }
            HTML.Raw("<!-- This is a comment -->")
        }

        let rendered = try String(html)

        #expect(rendered.contains("<hr>"))
        #expect(rendered.contains("<!-- This is a comment -->"))
        #expect(rendered.contains("<h1>Title</h1>"))
    }

    // MARK: - AnyHTML Integration

    @Test
    func `AnyHTML in heterogeneous collection`() throws {
        let components: [AnyHTML] = [
            AnyHTML(tag("h1") { HTML.Text("Header") }),
            AnyHTML(tag("p") { HTML.Text("Paragraph") }),
            AnyHTML(tag("ul") {
                tag("li") { HTML.Text("Item") }
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

    @Test
    func `Email configuration applies to full document`() throws {
        let document = HTML.Document {
            tag("div") {
                tag("p") { HTML.Text("Email content") }
                    .inlineStyle("color", "black")
            }
            .inlineStyle("max-width", "600px")
        }

        let rendered: String = try HTML.Context.Configuration.$current.withValue(.email) {
            try String(document)
        }

        #expect(rendered.contains("!important"))
    }

    @Test
    func `Pretty configuration produces formatted output`() throws {
        let document = HTML.Document {
            tag("div") {
                tag("p") { HTML.Text("Pretty printed") }
            }
        }

        let rendered: String = HTML.Context.Configuration.$current.withValue(.pretty) {
            try! String(document)
        }

        #expect(rendered.contains("\n"))
    }

    // MARK: - HTML.ForEach Integration

    @Test
    func `HTML.ForEach with identifiable data`() throws {
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
            HTML.ForEach(items) { item in
                tag("li") { HTML.Text(item.name) }
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

    @Test
    func `Group flattens nested content`() throws {
        let html = tag("div") {
            Group {
                Group {
                    tag("span") { HTML.Text("Deeply") }
                }
                Group {
                    tag("span") { HTML.Text("Nested") }
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
        @Test
        func `Full page integration snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document(
                    head: {
                        tag("title") { HTML.Text("Integration Test") }
                    },
                    body: {
                        tag("header") {
                            tag("h1") { HTML.Text("Welcome") }
                        }
                        tag("main") {
                            tag("article") {
                                tag("h2") { HTML.Text("Article Title") }
                                tag("p") { HTML.Text("Article content here.") }
                            }
                        }
                        tag("footer") {
                            HTML.Text("Footer")
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

//
//  HTML.ForEachTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTML.ForEach Tests")
struct HTMLForEachTests {

    @Test("HTML.ForEach with array of strings")
    func forEachWithStrings() throws {
        let items = ["apple", "banana", "cherry"]
        let forEach = HTML.ForEach(items) { item in
            HTML.Text(item)
        }

        let rendered = try String(forEach)
        #expect(rendered == "applebananacherry")
    }

    @Test("HTML.ForEach with elements")
    func forEachWithElements() throws {
        let items = ["first", "second", "third"]
        let forEach = HTML.ForEach(items) { item in
            tag("li") {
                HTML.Text(item)
            }
        }

        let rendered = try String(HTML.Document { forEach })
        #expect(rendered.contains("<li>first</li>"))
        #expect(rendered.contains("<li>second</li>"))
        #expect(rendered.contains("<li>third</li>"))
    }

    @Test("HTML.ForEach with empty array")
    func forEachWithEmptyArray() throws {
        let items: [String] = []
        let forEach = HTML.ForEach(items) { item in
            HTML.Text(item)
        }

        let rendered = try String(forEach)
        #expect(rendered.isEmpty)
    }

    @Test("HTML.ForEach with numbers")
    func forEachWithNumbers() throws {
        let numbers = [1, 2, 3, 4, 5]
        let forEach = HTML.ForEach(numbers) { number in
            HTML.Text(String(number))
        }

        let rendered = try String(forEach)
        #expect(rendered == "12345")
    }

    @Test("HTML.ForEach nested in elements")
    func forEachNestedInElements() throws {
        let items = ["item1", "item2", "item3"]
        let list = tag("ul") {
            HTML.ForEach(items) { item in
                tag("li") {
                    HTML.Text(item)
                }
            }
        }

        let rendered = try String(HTML.Document { list })
        #expect(rendered.contains("<ul>"))
        #expect(rendered.contains("<li>item1</li>"))
        #expect(rendered.contains("<li>item2</li>"))
        #expect(rendered.contains("<li>item3</li>"))
        #expect(rendered.contains("</ul>"))
    }

    @Test("HTML.ForEach with complex content")
    func forEachWithComplexContent() throws {
        struct Item {
            let title: String
            let description: String
        }

        let items = [
            Item(title: "First", description: "First description"),
            Item(title: "Second", description: "Second description"),
        ]

        let forEach = HTML.ForEach(items) { item in
            tag("div") {
                tag("h3") {
                    HTML.Text(item.title)
                }
                tag("p") {
                    HTML.Text(item.description)
                }
            }
        }

        let rendered = try String(HTML.Document { forEach })
        #expect(rendered.contains("<h3>First</h3>"))
        #expect(rendered.contains("<p>First description</p>"))
        #expect(rendered.contains("<h3>Second</h3>"))
        #expect(rendered.contains("<p>Second description</p>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLForEachSnapshotTests {
        @Test("HTML.ForEach list generation snapshot")
        func forEachListSnapshot() {
            let items = ["Home", "About", "Services", "Contact"]

            assertInlineSnapshot(
                of: HTML.Document {
                    tag("nav") {
                        tag("ul") {
                            HTML.ForEach(items) { item in
                                tag("li") {
                                    tag("a") {
                                        HTML.Text(item)
                                    }
                                    .attribute("href", "#\(item.lowercased())")
                                }
                            }
                        }
                        .attribute("class", "navigation")
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
                    <nav>
                      <ul class="navigation">
                        <li><a href="#home">Home</a>
                        </li>
                        <li><a href="#about">About</a>
                        </li>
                        <li><a href="#services">Services</a>
                        </li>
                        <li><a href="#contact">Contact</a>
                        </li>
                      </ul>
                    </nav>
                  </body>
                </html>
                """
            }
        }

        @Test("HTML.ForEach complex content snapshot")
        func forEachComplexContentSnapshot() {
            struct Product {
                let name: String
                let price: String
                let description: String
            }

            let products = [
                Product(
                    name: "Widget A",
                    price: "$19.99",
                    description: "Essential widget for daily use"
                ),
                Product(
                    name: "Widget B",
                    price: "$29.99",
                    description: "Premium widget with extra features"
                ),
            ]

            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h1") {
                            HTML.Text("Our Products")
                        }
                        HTML.ForEach(products) { product in
                            tag("article") {
                                tag("h2") {
                                    HTML.Text(product.name)
                                }
                                tag("p") {
                                    HTML.Text("Price: \(product.price)")
                                }
                                .attribute("class", "price")
                                tag("p") {
                                    HTML.Text(product.description)
                                }
                                .attribute("class", "description")
                            }
                            .attribute("class", "product-card")
                        }
                    }
                    .attribute("class", "products-container")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div class="products-container">
                      <h1>Our Products
                      </h1>
                      <article class="product-card">
                        <h2>Widget A
                        </h2>
                        <p class="price">Price: $19.99
                        </p>
                        <p class="description">Essential widget for daily use
                        </p>
                      </article>
                      <article class="product-card">
                        <h2>Widget B
                        </h2>
                        <p class="price">Price: $29.99
                        </p>
                        <p class="description">Premium widget with extra features
                        </p>
                      </article>
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}

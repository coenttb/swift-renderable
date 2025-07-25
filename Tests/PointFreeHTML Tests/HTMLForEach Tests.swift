//
//  HTMLForEachTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "HTMLForEach Tests",
    .snapshots(record: .missing)
)
struct HTMLForEachTests {

    @Test("HTMLForEach with array of strings")
    func forEachWithStrings() throws {
        let items = ["apple", "banana", "cherry"]
        let forEach = HTMLForEach(items) { item in
            HTMLText(item)
        }

        let rendered = try String(forEach)
        #expect(rendered == "applebananacherry")
    }

    @Test("HTMLForEach with elements")
    func forEachWithElements() throws {
        let items = ["first", "second", "third"]
        let forEach = HTMLForEach(items) { item in
            tag("li") {
                HTMLText(item)
            }
        }

        let rendered = try String(HTMLDocument { forEach })
        #expect(rendered.contains("<li>first</li>"))
        #expect(rendered.contains("<li>second</li>"))
        #expect(rendered.contains("<li>third</li>"))
    }

    @Test("HTMLForEach with empty array")
    func forEachWithEmptyArray() throws {
        let items: [String] = []
        let forEach = HTMLForEach(items) { item in
            HTMLText(item)
        }

        let rendered = try String(forEach)
        #expect(rendered.isEmpty)
    }

    @Test("HTMLForEach with numbers")
    func forEachWithNumbers() throws {
        let numbers = [1, 2, 3, 4, 5]
        let forEach = HTMLForEach(numbers) { number in
            HTMLText(String(number))
        }

        let rendered = try String(forEach)
        #expect(rendered == "12345")
    }

    @Test("HTMLForEach nested in elements")
    func forEachNestedInElements() throws {
        let items = ["item1", "item2", "item3"]
        let list = tag("ul") {
            HTMLForEach(items) { item in
                tag("li") {
                    HTMLText(item)
                }
            }
        }

        let rendered = try String(HTMLDocument { list })
        #expect(rendered.contains("<ul>"))
        #expect(rendered.contains("<li>item1</li>"))
        #expect(rendered.contains("<li>item2</li>"))
        #expect(rendered.contains("<li>item3</li>"))
        #expect(rendered.contains("</ul>"))
    }

    @Test("HTMLForEach with complex content")
    func forEachWithComplexContent() throws {
        struct Item {
            let title: String
            let description: String
        }

        let items = [
            Item(title: "First", description: "First description"),
            Item(title: "Second", description: "Second description")
        ]

        let forEach = HTMLForEach(items) { item in
            tag("div") {
                tag("h3") {
                    HTMLText(item.title)
                }
                tag("p") {
                    HTMLText(item.description)
                }
            }
        }

        let rendered = try String(HTMLDocument { forEach })
        #expect(rendered.contains("<h3>First</h3>"))
        #expect(rendered.contains("<p>First description</p>"))
        #expect(rendered.contains("<h3>Second</h3>"))
        #expect(rendered.contains("<p>Second description</p>"))
    }

    // MARK: - Snapshot Tests

    @Test("HTMLForEach list generation snapshot")
    func forEachListSnapshot() {
        let items = ["Home", "About", "Services", "Contact"]

        assertInlineSnapshot(
            of: HTMLDocument {
                tag("nav") {
                    tag("ul") {
                        HTMLForEach(items) { item in
                            tag("li") {
                                tag("a") {
                                    HTMLText(item)
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
                <style>

                </style>
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

    @Test("HTMLForEach complex content snapshot")
    func forEachComplexContentSnapshot() {
        struct Product {
            let name: String
            let price: String
            let description: String
        }

        let products = [
            Product(name: "Widget A", price: "$19.99", description: "Essential widget for daily use"),
            Product(name: "Widget B", price: "$29.99", description: "Premium widget with extra features")
        ]

        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    tag("h1") {
                        HTMLText("Our Products")
                    }
                    HTMLForEach(products) { product in
                        tag("article") {
                            tag("h2") {
                                HTMLText(product.name)
                            }
                            tag("p") {
                                HTMLText("Price: \(product.price)")
                            }
                            .attribute("class", "price")
                            tag("p") {
                                HTMLText(product.description)
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
                <style>

                </style>
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

//
//  CustomStringConvertible Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("CustomStringConvertible Tests")
struct CustomStringConvertibleTests {

    // MARK: - Custom Types with CustomStringConvertible

    @Test("HTML type with CustomStringConvertible has description")
    func hasDescription() {
        struct DescribableHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Hello")
                }
            }
        }

        let html = DescribableHTML()
        let description = html.description

        #expect(description.contains("<div>"))
        #expect(description.contains("Hello"))
    }

    @Test("Description matches rendered bytes")
    func descriptionMatchesBytes() {
        struct TestHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("span") {
                    HTML.Text("Test content")
                }
            }
        }

        let html = TestHTML()
        let description = html.description
        let fromBytes = String(decoding: html.bytes, as: UTF8.self)

        #expect(description == fromBytes)
    }

    // MARK: - Complex Content

    @Test("Description with nested elements")
    func nestedElements() {
        struct NestedHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("ul") {
                    tag("li") { HTML.Text("Item 1") }
                    tag("li") { HTML.Text("Item 2") }
                }
            }
        }

        let html = NestedHTML()
        let description = html.description

        #expect(description.contains("<ul>"))
        #expect(description.contains("<li>"))
        #expect(description.contains("Item 1"))
        #expect(description.contains("Item 2"))
    }

    @Test("Description with attributes")
    func withAttributes() {
        struct AttributedHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("a") {
                    HTML.Text("Link")
                }
                .attribute("href", "https://example.com")
            }
        }

        let html = AttributedHTML()
        let description = html.description

        #expect(description.contains("href=\"https://example.com\""))
    }

    // MARK: - Empty Content

    @Test("Description with empty content")
    func emptyContent() {
        struct EmptyHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                Empty()
            }
        }

        let html = EmptyHTML()
        #expect(html.description.isEmpty)
    }

    // MARK: - String Interpolation

    @Test("Can use in string interpolation")
    func stringInterpolation() {
        struct SimpleHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("b") {
                    HTML.Text("bold")
                }
            }
        }

        let html = SimpleHTML()
        let message = "The HTML is: \(html)"

        #expect(message.contains("<b>bold</b>"))
    }

    @Test("Can print to console")
    func printToConsole() {
        struct PrintableHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("p") {
                    HTML.Text("Printable")
                }
            }
        }

        let html = PrintableHTML()
        // This should work without error (testing that description is accessible)
        let output = String(describing: html)

        #expect(output.contains("<p>"))
        #expect(output.contains("Printable"))
    }

    // MARK: - Unicode Content

    @Test("Description with Unicode content")
    func unicodeContent() {
        struct UnicodeHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Héllo Wörld 日本語 🎉")
                }
            }
        }

        let html = UnicodeHTML()
        let description = html.description

        #expect(description.contains("Héllo"))
        #expect(description.contains("Wörld"))
        #expect(description.contains("日本語"))
        #expect(description.contains("🎉"))
    }

    // MARK: - HTML Escaping in Description

    @Test("Description escapes HTML entities")
    func escapesHTMLEntities() {
        struct EscapingHTML: HTML.View, CustomStringConvertible {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("<script>alert('XSS')</script>")
                }
            }
        }

        let html = EscapingHTML()
        let description = html.description

        // Should be escaped
        #expect(description.contains("&lt;script&gt;"))
        // Should NOT contain raw script tags
        #expect(!description.contains("<script>"))
    }

    // MARK: - Type that is HTML but NOT CustomStringConvertible

    @Test("HTML without CustomStringConvertible uses default description")
    func withoutCustomStringConvertible() {
        struct PlainHTML: HTML.View {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Plain")
                }
            }
        }

        let html = PlainHTML()
        // Without CustomStringConvertible, description would be the default struct description
        let defaultDescription = String(describing: html)
        // The default Swift description for a struct is typically "TypeName(...)"
        #expect(defaultDescription.contains("PlainHTML"))
    }
}

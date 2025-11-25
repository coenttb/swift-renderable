//
//  CustomStringConvertible Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("CustomStringConvertible Tests")
struct CustomStringConvertibleTests {

    // MARK: - Custom Types with CustomStringConvertible

    @Test("HTML type with CustomStringConvertible has description")
    func hasDescription() {
        struct DescribableHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("div") {
                    HTMLText("Hello")
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
        struct TestHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("span") {
                    HTMLText("Test content")
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
        struct NestedHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("ul") {
                    tag("li") { HTMLText("Item 1") }
                    tag("li") { HTMLText("Item 2") }
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
        struct AttributedHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("a") {
                    HTMLText("Link")
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
        struct EmptyHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                HTMLEmpty()
            }
        }

        let html = EmptyHTML()
        #expect(html.description.isEmpty)
    }

    // MARK: - String Interpolation

    @Test("Can use in string interpolation")
    func stringInterpolation() {
        struct SimpleHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("b") {
                    HTMLText("bold")
                }
            }
        }

        let html = SimpleHTML()
        let message = "The HTML is: \(html)"

        #expect(message.contains("<b>bold</b>"))
    }

    @Test("Can print to console")
    func printToConsole() {
        struct PrintableHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("p") {
                    HTMLText("Printable")
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
        struct UnicodeHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("div") {
                    HTMLText("Héllo Wörld 日本語 🎉")
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
        struct EscapingHTML: HTML, CustomStringConvertible {
            var body: some HTML {
                tag("div") {
                    HTMLText("<script>alert('XSS')</script>")
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
        struct PlainHTML: HTML {
            var body: some HTML {
                tag("div") {
                    HTMLText("Plain")
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

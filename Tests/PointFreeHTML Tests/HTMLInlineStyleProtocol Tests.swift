//
//  HTMLInlineStyleProtocol Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import RenderingHTML
import RenderingHTMLTestSupport
import Testing

// Note: HTMLInlineStyleProtocol is an internal protocol used for type erasure.
// We test it through the public HTMLInlineStyle type and the inlineStyle modifier.

@Suite("HTMLInlineStyleProtocol Tests")
struct HTMLInlineStyleProtocolTests {

    // MARK: - Style Extraction via inlineStyle

    @Test("inlineStyle creates styled element")
    func inlineStyleCreatesStyledElement() throws {
        let html = tag("div") {
            HTMLText("Styled content")
        }
        .inlineStyle("color", "red")

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("color:red"))
    }

    @Test("Multiple styles are extracted")
    func multipleStylesExtracted() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        .inlineStyle("color", "red")
        .inlineStyle("margin", "10px")
        .inlineStyle("padding", "5px")

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("margin:10px"))
        #expect(rendered.contains("padding:5px"))
    }

    // MARK: - Content Extraction

    @Test("Content is preserved through styling")
    func contentPreserved() throws {
        let html = tag("span") {
            HTMLText("Original content")
        }
        .inlineStyle("font-weight", "bold")

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("Original content"))
        #expect(rendered.contains("<span"))
    }

    @Test("Nested content preserved")
    func nestedContentPreserved() throws {
        let html = tag("div") {
            tag("p") {
                HTMLText("Paragraph")
            }
        }
        .inlineStyle("background", "white")

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("<div"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("Paragraph"))
    }

    // MARK: - Chained Styles

    @Test("Chained styles all apply")
    func chainedStylesApply() throws {
        let html = tag("div") {
            HTMLText("Multi-styled")
        }
        .inlineStyle("color", "blue")
        .inlineStyle("background-color", "yellow")
        .inlineStyle("border", "1px solid black")

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("color:blue"))
        #expect(rendered.contains("background-color:yellow"))
        #expect(rendered.contains("border:1px solid black"))
    }

    // MARK: - Style with Media Queries

    @Test("Style with media query extracted")
    func styleWithMediaQuery() throws {
        let html = tag("div") {
            HTMLText("Responsive")
        }
        .inlineStyle("display", "none", atRule: .init(rawValue: "@media print"), selector: nil, pseudo: nil)

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("@media print"))
        #expect(rendered.contains("display:none"))
    }

    @Test("Multiple media queries")
    func multipleMediaQueries() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        .inlineStyle("width", "100%", atRule: .init(rawValue: "@media (max-width: 768px)"), selector: nil, pseudo: nil)
        .inlineStyle("width", "50%", atRule: .init(rawValue: "@media (min-width: 769px)"), selector: nil, pseudo: nil)

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("@media (max-width: 768px)"))
        #expect(rendered.contains("@media (min-width: 769px)"))
    }

    // MARK: - Pseudo Classes

    @Test("Style with pseudo class")
    func styleWithPseudoClass() throws {
        let html = tag("a") {
            HTMLText("Hover me")
        }
        .attribute("href", "#")
        .inlineStyle("color", "red", pseudo: .hover)

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains(":hover"))
        #expect(rendered.contains("color:red"))
    }

    // MARK: - Empty Styles

    @Test("Empty style value")
    func emptyStyleValue() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        .inlineStyle("color", "")

        // Should still render without crashing
        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("<div"))
    }

    // MARK: - Complex Type Erasure Scenarios

    @Test("Style extraction through type erasure")
    func typeErasureStyleExtraction() throws {
        // AnyHTML should preserve styles
        let original = tag("div") {
            HTMLText("Erased")
        }
        .inlineStyle("color", "green")

        let erased = AnyHTML(original)
        let rendered = try String(HTMLDocument { erased })

        #expect(rendered.contains("color:green"))
        #expect(rendered.contains("Erased"))
    }

    // MARK: - Conditional Styled Content

    @Test("Conditional content with styles")
    func conditionalWithStyles() throws {
        let showFirst = true
        let html = Group {
            if showFirst {
                tag("div") {
                    HTMLText("First")
                }
                .inlineStyle("color", "red")
            } else {
                tag("div") {
                    HTMLText("Second")
                }
                .inlineStyle("color", "blue")
            }
        }

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("color:red"))
        #expect(!rendered.contains("color:blue"))
    }

    // MARK: - Array of Styled Elements

    @Test("Array of styled elements")
    func arrayOfStyledElements() throws {
        let colors = ["red", "green", "blue"]
        let html = Group {
            for color in colors {
                tag("span") {
                    HTMLText(color)
                }
                .inlineStyle("color", color)
            }
        }

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:green"))
        #expect(rendered.contains("color:blue"))
    }
}

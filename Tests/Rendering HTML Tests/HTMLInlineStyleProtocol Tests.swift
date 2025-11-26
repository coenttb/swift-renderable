//
//  HTMLInlineStyleProtocol Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

// Note: HTMLInlineStyleProtocol is an internal protocol used for type erasure.
// We test it through the public HTMLInlineStyle type and the inlineStyle modifier.

@Suite
struct `HTMLInlineStyleProtocol Tests` {

    // MARK: - Style Extraction via inlineStyle

    @Test
    func `inlineStyle creates styled element`() throws {
        let html = tag("div") {
            HTML.Text("Styled content")
        }
        .inlineStyle("color", "red")

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("color:red"))
    }

    @Test
    func `Multiple styles are extracted`() throws {
        let html = tag("div") {
            HTML.Text("Content")
        }
        .inlineStyle("color", "red")
        .inlineStyle("margin", "10px")
        .inlineStyle("padding", "5px")

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("margin:10px"))
        #expect(rendered.contains("padding:5px"))
    }

    // MARK: - Content Extraction

    @Test
    func `Content is preserved through styling`() throws {
        let html = tag("span") {
            HTML.Text("Original content")
        }
        .inlineStyle("font-weight", "bold")

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("Original content"))
        #expect(rendered.contains("<span"))
    }

    @Test
    func `Nested content preserved`() throws {
        let html = tag("div") {
            tag("p") {
                HTML.Text("Paragraph")
            }
        }
        .inlineStyle("background", "white")

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("<div"))
        #expect(rendered.contains("<p>"))
        #expect(rendered.contains("Paragraph"))
    }

    // MARK: - Chained Styles

    @Test
    func `Chained styles all apply`() throws {
        let html = tag("div") {
            HTML.Text("Multi-styled")
        }
        .inlineStyle("color", "blue")
        .inlineStyle("background-color", "yellow")
        .inlineStyle("border", "1px solid black")

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("color:blue"))
        #expect(rendered.contains("background-color:yellow"))
        #expect(rendered.contains("border:1px solid black"))
    }

    // MARK: - Style with Media Queries

    @Test
    func `Style with media query extracted`() throws {
        let html = tag("div") {
            HTML.Text("Responsive")
        }
        .inlineStyle("display", "none", atRule: .init(rawValue: "@media print"), selector: nil, pseudo: nil)

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("@media print"))
        #expect(rendered.contains("display:none"))
    }

    @Test
    func `Multiple media queries`() throws {
        let html = tag("div") {
            HTML.Text("Content")
        }
        .inlineStyle("width", "100%", atRule: .init(rawValue: "@media (max-width: 768px)"), selector: nil, pseudo: nil)
        .inlineStyle("width", "50%", atRule: .init(rawValue: "@media (min-width: 769px)"), selector: nil, pseudo: nil)

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("@media (max-width: 768px)"))
        #expect(rendered.contains("@media (min-width: 769px)"))
    }

    // MARK: - Pseudo Classes

    @Test
    func `Style with pseudo class`() throws {
        let html = tag("a") {
            HTML.Text("Hover me")
        }
        .attribute("href", "#")
        .inlineStyle("color", "red", pseudo: .hover)

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains(":hover"))
        #expect(rendered.contains("color:red"))
    }

    // MARK: - Empty Styles

    @Test
    func `Empty style value`() throws {
        let html = tag("div") {
            HTML.Text("Content")
        }
        .inlineStyle("color", "")

        // Should still render without crashing
        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("<div"))
    }

    // MARK: - Complex Type Erasure Scenarios

    @Test
    func `Style extraction through type erasure`() throws {
        // AnyHTML should preserve styles
        let original = tag("div") {
            HTML.Text("Erased")
        }
        .inlineStyle("color", "green")

        let erased = AnyHTML(original)
        let rendered = try String(HTML.Document { erased })

        #expect(rendered.contains("color:green"))
        #expect(rendered.contains("Erased"))
    }

    // MARK: - Conditional Styled Content

    @Test
    func `Conditional content with styles`() throws {
        let showFirst = true
        let html = Group {
            if showFirst {
                tag("div") {
                    HTML.Text("First")
                }
                .inlineStyle("color", "red")
            } else {
                tag("div") {
                    HTML.Text("Second")
                }
                .inlineStyle("color", "blue")
            }
        }

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("color:red"))
        #expect(!rendered.contains("color:blue"))
    }

    // MARK: - Array of Styled Elements

    @Test
    func `Array of styled elements`() throws {
        let colors = ["red", "green", "blue"]
        let html = Group {
            for color in colors {
                tag("span") {
                    HTML.Text(color)
                }
                .inlineStyle("color", color)
            }
        }

        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("color:green"))
        #expect(rendered.contains("color:blue"))
    }
}

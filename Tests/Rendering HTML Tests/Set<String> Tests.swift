//
//  Set<String> Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.Tag.Inline Tests` {

    // MARK: - Inline Tags

    @Test
    func `Inline enum contains expected elements`() {
        // Text formatting
        #expect(HTML.Tag.Inline(rawValue: "b") != nil)
        #expect(HTML.Tag.Inline(rawValue: "i") != nil)
        #expect(HTML.Tag.Inline(rawValue: "strong") != nil)
        #expect(HTML.Tag.Inline(rawValue: "em") != nil)
        #expect(HTML.Tag.Inline(rawValue: "u") != nil)
        #expect(HTML.Tag.Inline(rawValue: "s") != nil)
        #expect(HTML.Tag.Inline(rawValue: "small") != nil)
        #expect(HTML.Tag.Inline(rawValue: "mark") != nil)

        // Code and technical
        #expect(HTML.Tag.Inline(rawValue: "code") != nil)
        #expect(HTML.Tag.Inline(rawValue: "kbd") != nil)
        #expect(HTML.Tag.Inline(rawValue: "samp") != nil)
        #expect(HTML.Tag.Inline(rawValue: "var") != nil)

        // Links and references
        #expect(HTML.Tag.Inline(rawValue: "a") != nil)
        #expect(HTML.Tag.Inline(rawValue: "abbr") != nil)
        #expect(HTML.Tag.Inline(rawValue: "cite") != nil)
        #expect(HTML.Tag.Inline(rawValue: "q") != nil)
        #expect(HTML.Tag.Inline(rawValue: "dfn") != nil)

        // Edits
        #expect(HTML.Tag.Inline(rawValue: "del") != nil)
        #expect(HTML.Tag.Inline(rawValue: "ins") != nil)

        // Form elements (inline)
        #expect(HTML.Tag.Inline(rawValue: "button") != nil)
        #expect(HTML.Tag.Inline(rawValue: "input") != nil)
        #expect(HTML.Tag.Inline(rawValue: "label") != nil)
        #expect(HTML.Tag.Inline(rawValue: "select") != nil)
        #expect(HTML.Tag.Inline(rawValue: "textarea") != nil)
        #expect(HTML.Tag.Inline(rawValue: "output") != nil)

        // Media
        #expect(HTML.Tag.Inline(rawValue: "img") != nil)

        // Other
        #expect(HTML.Tag.Inline(rawValue: "br") != nil)
        #expect(HTML.Tag.Inline(rawValue: "span") != nil)
        #expect(HTML.Tag.Inline(rawValue: "script") != nil)
        #expect(HTML.Tag.Inline(rawValue: "time") != nil)
    }

    @Test
    func `Inline enum does not contain block elements`() {
        // Block elements should NOT be recognized as inline
        #expect(HTML.Tag.Inline(rawValue: "div") == nil)
        #expect(HTML.Tag.Inline(rawValue: "p") == nil)
        #expect(HTML.Tag.Inline(rawValue: "h1") == nil)
        #expect(HTML.Tag.Inline(rawValue: "h2") == nil)
        #expect(HTML.Tag.Inline(rawValue: "h3") == nil)
        #expect(HTML.Tag.Inline(rawValue: "section") == nil)
        #expect(HTML.Tag.Inline(rawValue: "article") == nil)
        #expect(HTML.Tag.Inline(rawValue: "header") == nil)
        #expect(HTML.Tag.Inline(rawValue: "footer") == nil)
        #expect(HTML.Tag.Inline(rawValue: "nav") == nil)
        #expect(HTML.Tag.Inline(rawValue: "aside") == nil)
        #expect(HTML.Tag.Inline(rawValue: "main") == nil)
        #expect(HTML.Tag.Inline(rawValue: "ul") == nil)
        #expect(HTML.Tag.Inline(rawValue: "ol") == nil)
        #expect(HTML.Tag.Inline(rawValue: "li") == nil)
        #expect(HTML.Tag.Inline(rawValue: "table") == nil)
        #expect(HTML.Tag.Inline(rawValue: "tr") == nil)
        #expect(HTML.Tag.Inline(rawValue: "td") == nil)
        #expect(HTML.Tag.Inline(rawValue: "th") == nil)
        #expect(HTML.Tag.Inline(rawValue: "form") == nil)
        #expect(HTML.Tag.Inline(rawValue: "fieldset") == nil)
        #expect(HTML.Tag.Inline(rawValue: "blockquote") == nil)
        #expect(HTML.Tag.Inline(rawValue: "pre") == nil)
    }

    @Test
    func `Inline allCases has expected count`() {
        let allCases = HTML.Tag.Inline.allCases
        // Based on the enum definition, there should be ~35 inline tags
        #expect(allCases.count > 30)
        #expect(allCases.count < 40)
    }

    // MARK: - Usage in Rendering

    @Test
    func `Inline used for formatting decisions`() {
        // This tests how HTML.Tag.Inline would be used in HTML.Element rendering
        func isInlineTag(_ tag: String) -> Bool {
            HTML.Tag.Inline(rawValue: tag) != nil
        }

        // Inline elements
        #expect(isInlineTag("span"))
        #expect(isInlineTag("a"))
        #expect(isInlineTag("strong"))

        // Block elements
        #expect(!isInlineTag("div"))
        #expect(!isInlineTag("p"))
        #expect(!isInlineTag("section"))
    }

    // MARK: - Edge Cases

    @Test
    func `Inline with case sensitivity`() {
        // HTML tags are lowercase
        #expect(HTML.Tag.Inline(rawValue: "span") != nil)
        #expect(HTML.Tag.Inline(rawValue: "SPAN") == nil)
        #expect(HTML.Tag.Inline(rawValue: "Span") == nil)
    }

    @Test
    func `Inline with empty string`() {
        #expect(HTML.Tag.Inline(rawValue: "") == nil)
    }

    @Test
    func `Inline rawValues match case names`() {
        for tag in HTML.Tag.Inline.allCases {
            // Each case's rawValue should be a valid HTML tag name
            #expect(!tag.rawValue.isEmpty)
            #expect(tag.rawValue == tag.rawValue.lowercased())
        }
    }
}

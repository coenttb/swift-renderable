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
struct `Set<String> Tests` {

    // MARK: - Inline Tags

    @Test
    func `inlineTags contains expected elements`() {
        let inlineTags = Set<String>.inlineTags

        // Text formatting
        #expect(inlineTags.contains("b"))
        #expect(inlineTags.contains("i"))
        #expect(inlineTags.contains("strong"))
        #expect(inlineTags.contains("em"))
        #expect(inlineTags.contains("u"))
        #expect(inlineTags.contains("s"))
        #expect(inlineTags.contains("small"))
        #expect(inlineTags.contains("mark"))

        // Code and technical
        #expect(inlineTags.contains("code"))
        #expect(inlineTags.contains("kbd"))
        #expect(inlineTags.contains("samp"))
        #expect(inlineTags.contains("var"))

        // Links and references
        #expect(inlineTags.contains("a"))
        #expect(inlineTags.contains("abbr"))
        #expect(inlineTags.contains("cite"))
        #expect(inlineTags.contains("q"))
        #expect(inlineTags.contains("dfn"))

        // Edits
        #expect(inlineTags.contains("del"))
        #expect(inlineTags.contains("ins"))

        // Form elements (inline)
        #expect(inlineTags.contains("button"))
        #expect(inlineTags.contains("input"))
        #expect(inlineTags.contains("label"))
        #expect(inlineTags.contains("select"))
        #expect(inlineTags.contains("textarea"))
        #expect(inlineTags.contains("output"))

        // Media
        #expect(inlineTags.contains("img"))

        // Other
        #expect(inlineTags.contains("br"))
        #expect(inlineTags.contains("span"))
        #expect(inlineTags.contains("script"))
        #expect(inlineTags.contains("time"))
    }

    @Test
    func `inlineTags does not contain block elements`() {
        let inlineTags = Set<String>.inlineTags

        // Block elements should NOT be in inlineTags
        #expect(!inlineTags.contains("div"))
        #expect(!inlineTags.contains("p"))
        #expect(!inlineTags.contains("h1"))
        #expect(!inlineTags.contains("h2"))
        #expect(!inlineTags.contains("h3"))
        #expect(!inlineTags.contains("section"))
        #expect(!inlineTags.contains("article"))
        #expect(!inlineTags.contains("header"))
        #expect(!inlineTags.contains("footer"))
        #expect(!inlineTags.contains("nav"))
        #expect(!inlineTags.contains("aside"))
        #expect(!inlineTags.contains("main"))
        #expect(!inlineTags.contains("ul"))
        #expect(!inlineTags.contains("ol"))
        #expect(!inlineTags.contains("li"))
        #expect(!inlineTags.contains("table"))
        #expect(!inlineTags.contains("tr"))
        #expect(!inlineTags.contains("td"))
        #expect(!inlineTags.contains("th"))
        #expect(!inlineTags.contains("form"))
        #expect(!inlineTags.contains("fieldset"))
        #expect(!inlineTags.contains("blockquote"))
        #expect(!inlineTags.contains("pre"))
    }

    @Test
    func `inlineTags has expected count`() {
        let inlineTags = Set<String>.inlineTags
        // Based on the source file, there should be ~35 inline tags
        #expect(inlineTags.count > 30)
        #expect(inlineTags.count < 40)
    }

    // MARK: - Set Operations

    @Test
    func `inlineTags contains operation`() {
        let inlineTags = Set<String>.inlineTags

        #expect(inlineTags.contains("span"))
        #expect(!inlineTags.contains("div"))
    }

    @Test
    func `inlineTags is immutable definition`() {
        // Each access should return the same set
        let tags1 = Set<String>.inlineTags
        let tags2 = Set<String>.inlineTags
        #expect(tags1 == tags2)
    }

    // MARK: - Usage in Rendering

    @Test
    func `inlineTags used for formatting decisions`() {
        // This tests how inlineTags would be used in HTML.Element rendering
        let inlineTags = Set<String>.inlineTags

        func isInlineTag(_ tag: String) -> Bool {
            inlineTags.contains(tag)
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
    func `inlineTags with case sensitivity`() {
        let inlineTags = Set<String>.inlineTags

        // HTML tags are lowercase
        #expect(inlineTags.contains("span"))
        #expect(!inlineTags.contains("SPAN"))
        #expect(!inlineTags.contains("Span"))
    }

    @Test
    func `inlineTags with empty string`() {
        let inlineTags = Set<String>.inlineTags
        #expect(!inlineTags.contains(""))
    }
}

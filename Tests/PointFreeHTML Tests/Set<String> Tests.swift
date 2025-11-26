//
//  Set<String> Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Set<String> Tests")
struct SetStringTests {

    // MARK: - Inline Tags

    @Test("inlineTags contains expected elements")
    func inlineTagsContainsExpectedElements() {
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

    @Test("inlineTags does not contain block elements")
    func inlineTagsDoesNotContainBlockElements() {
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

    @Test("inlineTags has expected count")
    func inlineTagsHasExpectedCount() {
        let inlineTags = Set<String>.inlineTags
        // Based on the source file, there should be ~35 inline tags
        #expect(inlineTags.count > 30)
        #expect(inlineTags.count < 40)
    }

    // MARK: - Set Operations

    @Test("inlineTags contains operation")
    func inlineTagsContainsOperation() {
        let inlineTags = Set<String>.inlineTags

        #expect(inlineTags.contains("span"))
        #expect(!inlineTags.contains("div"))
    }

    @Test("inlineTags is immutable definition")
    func inlineTagsIsImmutableDefinition() {
        // Each access should return the same set
        let tags1 = Set<String>.inlineTags
        let tags2 = Set<String>.inlineTags
        #expect(tags1 == tags2)
    }

    // MARK: - Usage in Rendering

    @Test("inlineTags used for formatting decisions")
    func usedForFormattingDecisions() {
        // This tests how inlineTags would be used in HTMLElement rendering
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

    @Test("inlineTags with case sensitivity")
    func caseSensitivity() {
        let inlineTags = Set<String>.inlineTags

        // HTML tags are lowercase
        #expect(inlineTags.contains("span"))
        #expect(!inlineTags.contains("SPAN"))
        #expect(!inlineTags.contains("Span"))
    }

    @Test("inlineTags with empty string")
    func emptyString() {
        let inlineTags = Set<String>.inlineTags
        #expect(!inlineTags.contains(""))
    }
}

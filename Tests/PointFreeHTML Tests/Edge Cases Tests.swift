//
//  Edge Cases Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting tests for edge cases, boundary conditions, and unusual inputs.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Edge Cases Tests")
struct EdgeCasesTests {

    // MARK: - Empty Content

    @Test("Empty HTMLText renders nothing")
    func emptyHTMLText() throws {
        let html = HTMLText("")
        let rendered = try String(Group { html })
        #expect(rendered.isEmpty)
    }

    @Test("Empty element renders open and close tags")
    func emptyElement() throws {
        let html = tag("div") { Empty() }
        let rendered = try String(html)
        #expect(rendered == "<div></div>")
    }

    @Test("Nested empty elements")
    func nestedEmptyElements() throws {
        let html = tag("div") {
            tag("span") { Empty() }
            tag("p") { Empty() }
        }
        let rendered = try String(html)
        #expect(rendered.contains("<span></span>"))
        #expect(rendered.contains("<p></p>"))
    }

    // MARK: - Whitespace

    @Test("Whitespace-only text is preserved")
    func whitespaceOnlyText() throws {
        let html = HTMLText("   ")
        let rendered = try String(Group { html })
        #expect(rendered == "   ")
    }

    @Test("Newlines in text are preserved")
    func newlinesPreserved() throws {
        let html = HTMLText("Line 1\nLine 2\nLine 3")
        let rendered = try String(Group { html })
        #expect(rendered.contains("\n"))
    }

    @Test("Tabs in text are preserved")
    func tabsPreserved() throws {
        let html = HTMLText("Column1\tColumn2\tColumn3")
        let rendered = try String(Group { html })
        #expect(rendered.contains("\t"))
    }

    // MARK: - Large Content

    @Test("Very long text content")
    func veryLongText() throws {
        let longString = String(repeating: "a", count: 100_000)
        let html = tag("p") { HTMLText(longString) }
        let rendered = try String(html)
        #expect(rendered.count > 100_000)
    }

    @Test("Many nested elements")
    func manyNestedElements() throws {
        func nest(_ depth: Int, content: () -> some HTML) -> some HTML {
            if depth == 0 {
                return AnyHTML(content())
            } else {
                return AnyHTML(tag("div") { nest(depth - 1, content: content) })
            }
        }

        let html = nest(50) { HTMLText("Deep content") }
        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("Deep content"))
    }

    @Test("Many sibling elements")
    func manySiblingElements() throws {
        let html = Group {
            for i in 0..<1000 {
                tag("span") { HTMLText("Item \(i)") }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("Item 0"))
        #expect(rendered.contains("Item 999"))
    }

    // MARK: - Attribute Edge Cases

    @Test("Empty attribute value")
    func emptyAttributeValue() throws {
        let html = tag("input").attribute("value", "")
        let rendered = try String(html)
        // Empty attribute values render as boolean attributes
        #expect(rendered.contains("value"))
    }

    @Test("Boolean attribute")
    func booleanAttribute() throws {
        // Boolean attributes in HTML are represented by presence alone
        // Use empty string or attribute name as value
        let html = tag("input").attribute("disabled", "")
        let rendered = try String(html)
        #expect(rendered.contains("disabled"))
    }

    @Test("Attribute with special characters in name")
    func attributeSpecialCharsName() throws {
        let html = tag("div").attribute("data-test-value", "123")
        let rendered = try String(html)
        #expect(rendered.contains("data-test-value=\"123\""))
    }

    @Test("Multiple same attributes")
    func multipleSameAttributes() throws {
        let html = tag("div")
            .attribute("class", "first")
            .attribute("class", "second")
        let rendered = try String(html)
        // Later attribute should win or be appended
        #expect(rendered.contains("class="))
    }

    // MARK: - Style Edge Cases

    @Test("Empty style value")
    func emptyStyleValue() throws {
        let html = tag("div") { HTMLText("Content") }
            .inlineStyle("color", "")
        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("<div"))
    }

    @Test("Style with special CSS value")
    func styleSpecialCSSValue() throws {
        let html = tag("div") { HTMLText("Content") }
            .inlineStyle("content", "'Hello'")
        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("content:"))
    }

    @Test("Very long style value")
    func veryLongStyleValue() throws {
        let longValue = String(repeating: "a", count: 10_000)
        let html = tag("div") { HTMLText("Content") }
            .inlineStyle("--custom-prop", longValue)
        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("--custom-prop"))
    }

    // MARK: - Conditional Edge Cases

    @Test("All false conditionals")
    func allFalseConditionals() throws {
        let html = Group {
            if false {
                tag("p") { HTMLText("Never shown") }
            }
            if false {
                tag("span") { HTMLText("Also never shown") }
            }
        }
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test("Deeply nested conditionals")
    func deeplyNestedConditionals() throws {
        let a = true
        let b = true
        let c = true

        let html = Group {
            if a {
                if b {
                    if c {
                        tag("p") { HTMLText("All true") }
                    }
                }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("All true"))
    }

    // MARK: - Loop Edge Cases

    @Test("Empty array loop")
    func emptyArrayLoop() throws {
        let items: [String] = []
        let html = Group {
            for item in items {
                tag("li") { HTMLText(item) }
            }
        }
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test("Single item loop")
    func singleItemLoop() throws {
        let items = ["Only one"]
        let html = Group {
            for item in items {
                tag("li") { HTMLText(item) }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("Only one"))
    }

    @Test("Loop with nil values")
    func loopWithNilValues() throws {
        let items: [String?] = ["First", nil, "Third", nil, "Fifth"]
        let html = Group {
            for item in items.compactMap({ $0 }) {
                tag("li") { HTMLText(item) }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("First"))
        #expect(rendered.contains("Third"))
        #expect(rendered.contains("Fifth"))
    }

    // MARK: - Type Erasure Edge Cases

    @Test("Double type erasure")
    func doubleTypeErasure() throws {
        let original = tag("div") { HTMLText("Original") }
        let erased = AnyHTML(original)
        let doubleErased = AnyHTML(erased)
        let rendered = try String(HTMLDocument { doubleErased })
        #expect(rendered.contains("Original"))
    }

    @Test("Type erasure with styles")
    func typeErasureWithStyles() throws {
        let styled = tag("div") { HTMLText("Styled") }
            .inlineStyle("color", "red")
        let erased = AnyHTML(styled)
        let rendered = try String(HTMLDocument { erased })
        #expect(rendered.contains("color:red"))
    }

    // MARK: - Void Element Edge Cases

    @Test("Void element with closing slash")
    func voidElementClosingSlash() throws {
        // Self-closing elements shouldn't have content
        let html = tag("br")
        let rendered = try String(html)
        #expect(rendered.contains("<br>") || rendered.contains("<br/>") || rendered.contains("<br />"))
    }

    @Test("Void element with attributes")
    func voidElementWithAttributes() throws {
        let html = tag("img")
            .attribute("src", "image.png")
            .attribute("alt", "Description")
        let rendered = try String(html)
        #expect(rendered.contains("src=\"image.png\""))
        #expect(rendered.contains("alt=\"Description\""))
    }

    // MARK: - Raw HTML Edge Cases

    @Test("Raw HTML with unbalanced tags")
    func rawHTMLUnbalancedTags() throws {
        let html = tag("div") {
            HTMLRaw("<span>Not closed")
        }
        let rendered = try String(html)
        #expect(rendered.contains("<span>Not closed"))
    }

    @Test("Raw HTML with script")
    func rawHTMLScript() throws {
        let html = HTMLRaw("<script>var x = 1 < 2 && 2 > 1;</script>")
        let rendered = try String(Group { html })
        #expect(rendered.contains("<script>"))
        #expect(rendered.contains("</script>"))
    }

    // MARK: - Document Edge Cases

    @Test("Document with empty head and body")
    func emptyDocument() throws {
        let document = HTMLDocument(
            head: { Empty() },
            body: { Empty() }
        )
        let rendered = try String(document)
        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
    }

    @Test("Document with complex head")
    func documentComplexHead() throws {
        let document = HTMLDocument(
            head: {
                tag("title") { HTMLText("Title") }
                tag("meta").attribute("charset", "utf-8")
                tag("meta").attribute("name", "viewport").attribute("content", "width=device-width")
                tag("link").attribute("rel", "stylesheet").attribute("href", "style.css")
            },
            body: {
                tag("p") { HTMLText("Content") }
            }
        )
        let rendered = try String(document)
        #expect(rendered.contains("<title>Title</title>"))
        #expect(rendered.contains("charset=\"utf-8\""))
        #expect(rendered.contains("viewport"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct EdgeCasesSnapshotTests {
        @Test("Complex edge case snapshot")
        func complexEdgeCase() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        // Empty content
                        Empty()
                        // Whitespace
                        HTMLText("  ")
                        // Nested structure
                        tag("span") {
                            tag("strong") {
                                HTMLText("Nested")
                            }
                        }
                        // Conditional (true)
                        if true {
                            HTMLText("Shown")
                        }
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
                <div>  <span><strong>Nested</strong></span>Shown
                </div>
                  </body>
                </html>
                """
            }
        }
    }
}

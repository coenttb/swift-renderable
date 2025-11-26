//
//  Edge Cases Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting tests for edge cases, boundary conditions, and unusual inputs.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Edge Cases Tests` {

    // MARK: - Empty Content

    @Test
    func `Empty HTML.Text renders nothing`() throws {
        let html = HTML.Text("")
        let rendered = try String(Group { html })
        #expect(rendered.isEmpty)
    }

    @Test
    func `Empty element renders open and close tags`() throws {
        let html = tag("div") { Empty() }
        let rendered = try String(html)
        #expect(rendered == "<div></div>")
    }

    @Test
    func `Nested empty elements`() throws {
        let html = tag("div") {
            tag("span") { Empty() }
            tag("p") { Empty() }
        }
        let rendered = try String(html)
        #expect(rendered.contains("<span></span>"))
        #expect(rendered.contains("<p></p>"))
    }

    // MARK: - Whitespace

    @Test
    func `Whitespace-only text is preserved`() throws {
        let html = HTML.Text("   ")
        let rendered = try String(Group { html })
        #expect(rendered == "   ")
    }

    @Test
    func `Newlines in text are preserved`() throws {
        let html = HTML.Text("Line 1\nLine 2\nLine 3")
        let rendered = try String(Group { html })
        #expect(rendered.contains("\n"))
    }

    @Test
    func `Tabs in text are preserved`() throws {
        let html = HTML.Text("Column1\tColumn2\tColumn3")
        let rendered = try String(Group { html })
        #expect(rendered.contains("\t"))
    }

    // MARK: - Large Content

    @Test
    func `Very long text content`() throws {
        let longString = String(repeating: "a", count: 100_000)
        let html = tag("p") { HTML.Text(longString) }
        let rendered = try String(html)
        #expect(rendered.count > 100_000)
    }

    @Test
    func `Many nested elements`() throws {
        func nest(_ depth: Int, content: () -> some HTML.View) -> some HTML.View {
            if depth == 0 {
                return AnyHTML(content())
            } else {
                return AnyHTML(tag("div") { nest(depth - 1, content: content) })
            }
        }

        let html = nest(50) { HTML.Text("Deep content") }
        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("Deep content"))
    }

    @Test
    func `Many sibling elements`() throws {
        let html = Group {
            for i in 0..<1000 {
                tag("span") { HTML.Text("Item \(i)") }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("Item 0"))
        #expect(rendered.contains("Item 999"))
    }

    // MARK: - Attribute Edge Cases

    @Test
    func `Empty attribute value`() throws {
        let html = tag("input").attribute("value", "")
        let rendered = try String(html)
        // Empty attribute values render as boolean attributes
        #expect(rendered.contains("value"))
    }

    @Test
    func `Boolean attribute`() throws {
        // Boolean attributes in HTML are represented by presence alone
        // Use empty string or attribute name as value
        let html = tag("input").attribute("disabled", "")
        let rendered = try String(html)
        #expect(rendered.contains("disabled"))
    }

    @Test
    func `Attribute with special characters in name`() throws {
        let html = tag("div").attribute("data-test-value", "123")
        let rendered = try String(html)
        #expect(rendered.contains("data-test-value=\"123\""))
    }

    @Test
    func `Multiple same attributes`() throws {
        let html = tag("div")
            .attribute("class", "first")
            .attribute("class", "second")
        let rendered = try String(html)
        // Later attribute should win or be appended
        #expect(rendered.contains("class="))
    }

    // MARK: - Style Edge Cases

    @Test
    func `Empty style value`() throws {
        let html = tag("div") { HTML.Text("Content") }
            .inlineStyle("color", "")
        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("<div"))
    }

    @Test
    func `Style with special CSS value`() throws {
        let html = tag("div") { HTML.Text("Content") }
            .inlineStyle("content", "'Hello'")
        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("content:"))
    }

    @Test
    func `Very long style value`() throws {
        let longValue = String(repeating: "a", count: 10_000)
        let html = tag("div") { HTML.Text("Content") }
            .inlineStyle("--custom-prop", longValue)
        let rendered = try String(HTML.Document { html })
        #expect(rendered.contains("--custom-prop"))
    }

    // MARK: - Conditional Edge Cases

    @Test
    func `All false conditionals`() throws {
        let html = Group {
            if false {
                tag("p") { HTML.Text("Never shown") }
            }
            if false {
                tag("span") { HTML.Text("Also never shown") }
            }
        }
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test
    func `Deeply nested conditionals`() throws {
        let a = true
        let b = true
        let c = true

        let html = Group {
            if a {
                if b {
                    if c {
                        tag("p") { HTML.Text("All true") }
                    }
                }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("All true"))
    }

    // MARK: - Loop Edge Cases

    @Test
    func `Empty array loop`() throws {
        let items: [String] = []
        let html = Group {
            for item in items {
                tag("li") { HTML.Text(item) }
            }
        }
        let rendered = try String(html)
        #expect(rendered.isEmpty)
    }

    @Test
    func `Single item loop`() throws {
        let items = ["Only one"]
        let html = Group {
            for item in items {
                tag("li") { HTML.Text(item) }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("Only one"))
    }

    @Test
    func `Loop with nil values`() throws {
        let items: [String?] = ["First", nil, "Third", nil, "Fifth"]
        let html = Group {
            for item in items.compactMap({ $0 }) {
                tag("li") { HTML.Text(item) }
            }
        }
        let rendered = try String(html)
        #expect(rendered.contains("First"))
        #expect(rendered.contains("Third"))
        #expect(rendered.contains("Fifth"))
    }

    // MARK: - Type Erasure Edge Cases

    @Test
    func `Double type erasure`() throws {
        let original = tag("div") { HTML.Text("Original") }
        let erased = AnyHTML(original)
        let doubleErased = AnyHTML(erased)
        let rendered = try String(HTML.Document { doubleErased })
        #expect(rendered.contains("Original"))
    }

    @Test
    func `Type erasure with styles`() throws {
        let styled = tag("div") { HTML.Text("Styled") }
            .inlineStyle("color", "red")
        let erased = AnyHTML(styled)
        let rendered = try String(HTML.Document { erased })
        #expect(rendered.contains("color:red"))
    }

    // MARK: - Void Element Edge Cases

    @Test
    func `Void element with closing slash`() throws {
        // Self-closing elements shouldn't have content
        let html = tag("br")
        let rendered = try String(html)
        #expect(rendered.contains("<br>") || rendered.contains("<br/>") || rendered.contains("<br />"))
    }

    @Test
    func `Void element with attributes`() throws {
        let html = tag("img")
            .attribute("src", "image.png")
            .attribute("alt", "Description")
        let rendered = try String(html)
        #expect(rendered.contains("src=\"image.png\""))
        #expect(rendered.contains("alt=\"Description\""))
    }

    // MARK: - Raw HTML Edge Cases

    @Test
    func `Raw HTML with unbalanced tags`() throws {
        let html = tag("div") {
            HTML.Raw("<span>Not closed")
        }
        let rendered = try String(html)
        #expect(rendered.contains("<span>Not closed"))
    }

    @Test
    func `Raw HTML with script`() throws {
        let html = HTML.Raw("<script>var x = 1 < 2 && 2 > 1;</script>")
        let rendered = try String(Group { html })
        #expect(rendered.contains("<script>"))
        #expect(rendered.contains("</script>"))
    }

    // MARK: - Document Edge Cases

    @Test
    func `Document with empty head and body`() throws {
        let document = HTML.Document(
            head: { Empty() },
            body: { Empty() }
        )
        let rendered = try String(document)
        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
    }

    @Test
    func `Document with complex head`() throws {
        let document = HTML.Document(
            head: {
                tag("title") { HTML.Text("Title") }
                tag("meta").attribute("charset", "utf-8")
                tag("meta").attribute("name", "viewport").attribute("content", "width=device-width")
                tag("link").attribute("rel", "stylesheet").attribute("href", "style.css")
            },
            body: {
                tag("p") { HTML.Text("Content") }
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
        @Test
        func `Complex edge case snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        // Empty content
                        Empty()
                        // Whitespace
                        HTML.Text("  ")
                        // Nested structure
                        tag("span") {
                            tag("strong") {
                                HTML.Text("Nested")
                            }
                        }
                        // Conditional (true)
                        if true {
                            HTML.Text("Shown")
                        }
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
                    <div>  <span><strong>Nested</strong></span>Shown
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}

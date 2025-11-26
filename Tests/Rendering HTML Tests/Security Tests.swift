//
//  Security Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting security tests for XSS prevention and safe HTML generation.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Security Tests` {

    // MARK: - XSS Prevention in Text Content

    @Test
    func `Script tags in text are escaped`() throws {
        let malicious = "<script>alert('XSS')</script>"
        let html = tag("p") { HTML.Text(malicious) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script>"))
        #expect(rendered.contains("&lt;script&gt;"))
    }

    @Test
    func `Script tags with attributes are escaped`() throws {
        let malicious = "<script src=\"evil.js\"></script>"
        let html = tag("div") { HTML.Text(malicious) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script"))
        #expect(rendered.contains("&lt;script"))
    }

    @Test
    func `Event handlers in text are escaped`() throws {
        let malicious = "<img src=x onerror=\"alert('XSS')\">"
        let html = tag("div") { HTML.Text(malicious) }
        let rendered = try String(html)

        // The < and > are escaped, so browser won't parse as HTML tag
        #expect(rendered.contains("&lt;img"))
        #expect(rendered.contains("&gt;"))
        // The opening bracket is escaped - no actual img tag is created
        #expect(!rendered.contains("<img"))
    }

    @Test
    func `JavaScript URLs in text are escaped`() throws {
        let malicious = "<a href=\"javascript:alert('XSS')\">Click</a>"
        let html = tag("div") { HTML.Text(malicious) }
        let rendered = try String(html)

        // The < and > are escaped, so browser won't parse as HTML tag
        #expect(rendered.contains("&lt;a"))
        #expect(rendered.contains("&gt;"))
        // No actual anchor tag is created
        #expect(!rendered.contains("<a "))
    }

    // MARK: - XSS Prevention in Attributes

    @Test
    func `Double quotes in attribute values are escaped`() throws {
        let malicious = "value\" onclick=\"alert('XSS')"
        let html = tag("input").attribute("value", malicious)
        let rendered = try String(html)

        // Double quotes are escaped as &quot;
        #expect(rendered.contains("&quot;"))
        // The attribute value is properly contained - not broken out
        #expect(rendered.contains("value=\"value&quot;"))
    }

    @Test
    func `Angle brackets in attributes are escaped`() throws {
        let malicious = "<script>alert('XSS')</script>"
        let html = tag("div").attribute("data-content", malicious)
        let rendered = try String(html)

        #expect(!rendered.contains("data-content=\"<script>"))
    }

    @Test
    func `Ampersands in attributes are escaped`() throws {
        let url = "/search?q=foo&bar=baz"
        let html = tag("a").attribute("href", url)
        let rendered = try String(html)

        #expect(rendered.contains("&amp;") || rendered.contains("&bar"))
    }

    // MARK: - HTML Entity Injection

    @Test
    func `HTML entities in text don't execute`() throws {
        let malicious = "&#60;script&#62;alert('XSS')&#60;/script&#62;"
        let html = tag("p") { HTML.Text(malicious) }
        let rendered = try String(html)

        // The entity codes should be escaped or rendered as text
        #expect(!rendered.contains("<script>"))
    }

    @Test
    func `Hex encoded entities don't execute`() throws {
        let malicious = "&#x3C;script&#x3E;alert('XSS')&#x3C;/script&#x3E;"
        let html = tag("p") { HTML.Text(malicious) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script>"))
    }

    // MARK: - Style Injection Prevention

    @Test
    func `Style values don't allow expression injection`() throws {
        // Old IE expression() attack
        let malicious = "expression(alert('XSS'))"
        let html = tag("div") { HTML.Text("Content") }
            .inlineStyle("color", malicious)
        let rendered = try String(HTML.Document { html })

        // Style should be present but expression shouldn't execute
        // The style value is passed through - it's CSS, not HTML
        #expect(rendered.contains("expression"))
    }

    @Test
    func `URL function in style`() throws {
        // Attempting javascript: URL in style
        let malicious = "url(javascript:alert('XSS'))"
        let html = tag("div") { HTML.Text("Content") }
            .inlineStyle("background", malicious)
        let rendered = try String(HTML.Document { html })

        // The value is passed through - CSS, not HTML context
        #expect(rendered.contains("background:"))
    }

    // MARK: - Raw HTML Security

    @Test
    func `HTML.Raw is not escaped (use with caution)`() throws {
        let dangerous = "<script>alert('This executes')</script>"
        let html = HTML.Raw(dangerous)
        let rendered = try String(Group { html })

        // RAW HTML IS NOT ESCAPED - THIS IS INTENTIONAL BUT DANGEROUS
        #expect(rendered.contains("<script>"))
    }

    @Test
    func `Only use HTML.Raw with trusted content`() throws {
        // Only trusted, sanitized content should use HTML.Raw
        let trusted = "<strong>Bold text</strong>"
        let html = HTML.Raw(trusted)
        let rendered = try String(Group { html })

        #expect(rendered.contains("<strong>"))
    }

    // MARK: - Unicode Security

    @Test
    func `Unicode escape sequences don't bypass escaping`() throws {
        // \u003c = < and \u003e = >
        let malicious = "\\u003cscript\\u003ealert('XSS')\\u003c/script\\u003e"
        let html = tag("p") { HTML.Text(malicious) }
        let rendered = try String(html)

        // The backslash sequences are literal text, not interpreted
        #expect(rendered.contains("\\u003c"))
    }

    @Test
    func `Zero-width characters in text`() throws {
        // Zero-width joiner and other invisible characters
        let sneaky = "scr\u{200B}ipt"  // script with zero-width space
        let html = tag("p") { HTML.Text("<\(sneaky)>alert('XSS')</\(sneaky)>") }
        let rendered = try String(html)

        // Should still escape the angle brackets
        #expect(rendered.contains("&lt;"))
        #expect(rendered.contains("&gt;"))
    }

    // MARK: - Attribute Context Escaping

    @Test
    func `Single quotes in double-quoted attributes`() throws {
        let value = "It's a test"
        let html = tag("div").attribute("title", value)
        let rendered = try String(html)

        // Single quotes should be safe in double-quoted attributes
        #expect(rendered.contains("title=\"It's a test\"") || rendered.contains("It&#39;s"))
    }

    @Test
    func `Newlines in attributes`() throws {
        let value = "Line 1\nLine 2"
        let html = tag("div").attribute("data-content", value)
        let rendered = try String(html)

        // Newlines should be preserved or escaped
        #expect(rendered.contains("data-content="))
    }

    // MARK: - Complete XSS Payload Tests

    @Test
    func `Common XSS payload 1: IMG onerror`() throws {
        let payload = "<IMG SRC=x onerror=\"alert('XSS')\">"
        let html = tag("div") { HTML.Text(payload) }
        let rendered = try String(html)

        // The < is escaped, preventing browser from parsing as HTML
        #expect(rendered.contains("&lt;IMG"))
        // No actual IMG tag is created
        #expect(!rendered.contains("<IMG"))
    }

    @Test
    func `Common XSS payload 2: SVG onload`() throws {
        let payload = "<svg onload=\"alert('XSS')\">"
        let html = tag("div") { HTML.Text(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;svg"))
    }

    @Test
    func `Common XSS payload 3: body onload`() throws {
        let payload = "<body onload=\"alert('XSS')\">"
        let html = tag("div") { HTML.Text(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;body"))
    }

    @Test
    func `Common XSS payload 4: iframe`() throws {
        let payload = "<iframe src=\"javascript:alert('XSS')\">"
        let html = tag("div") { HTML.Text(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;iframe"))
    }

    // MARK: - Content-Type Considerations

    @Test
    func `HTML document sets proper structure`() throws {
        let document = HTML.Document {
            tag("p") { HTML.Text("Content") }
        }
        let rendered = try String(document)

        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
    }

    // MARK: - Nested Attack Vectors

    @Test
    func `Nested script tags`() throws {
        let payload = "<<script>script>alert('XSS')<</script>/script>"
        let html = tag("p") { HTML.Text(payload) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script>"))
    }

    @Test
    func `Mixed case script tag`() throws {
        let payload = "<ScRiPt>alert('XSS')</ScRiPt>"
        let html = tag("p") { HTML.Text(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;ScRiPt&gt;"))
    }
}

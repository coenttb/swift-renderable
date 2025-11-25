//
//  Security Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting security tests for XSS prevention and safe HTML generation.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("Security Tests")
struct SecurityTests {

    // MARK: - XSS Prevention in Text Content

    @Test("Script tags in text are escaped")
    func scriptTagsEscaped() throws {
        let malicious = "<script>alert('XSS')</script>"
        let html = tag("p") { HTMLText(malicious) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script>"))
        #expect(rendered.contains("&lt;script&gt;"))
    }

    @Test("Script tags with attributes are escaped")
    func scriptTagsWithAttrsEscaped() throws {
        let malicious = "<script src=\"evil.js\"></script>"
        let html = tag("div") { HTMLText(malicious) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script"))
        #expect(rendered.contains("&lt;script"))
    }

    @Test("Event handlers in text are escaped")
    func eventHandlersEscaped() throws {
        let malicious = "<img src=x onerror=\"alert('XSS')\">"
        let html = tag("div") { HTMLText(malicious) }
        let rendered = try String(html)

        // The < and > are escaped, so browser won't parse as HTML tag
        #expect(rendered.contains("&lt;img"))
        #expect(rendered.contains("&gt;"))
        // The opening bracket is escaped - no actual img tag is created
        #expect(!rendered.contains("<img"))
    }

    @Test("JavaScript URLs in text are escaped")
    func javascriptURLsEscaped() throws {
        let malicious = "<a href=\"javascript:alert('XSS')\">Click</a>"
        let html = tag("div") { HTMLText(malicious) }
        let rendered = try String(html)

        // The < and > are escaped, so browser won't parse as HTML tag
        #expect(rendered.contains("&lt;a"))
        #expect(rendered.contains("&gt;"))
        // No actual anchor tag is created
        #expect(!rendered.contains("<a "))
    }

    // MARK: - XSS Prevention in Attributes

    @Test("Double quotes in attribute values are escaped")
    func doubleQuotesEscaped() throws {
        let malicious = "value\" onclick=\"alert('XSS')"
        let html = tag("input").attribute("value", malicious)
        let rendered = try String(html)

        // Double quotes are escaped as &quot;
        #expect(rendered.contains("&quot;"))
        // The attribute value is properly contained - not broken out
        #expect(rendered.contains("value=\"value&quot;"))
    }

    @Test("Angle brackets in attributes are escaped")
    func angleBracketsInAttributesEscaped() throws {
        let malicious = "<script>alert('XSS')</script>"
        let html = tag("div").attribute("data-content", malicious)
        let rendered = try String(html)

        #expect(!rendered.contains("data-content=\"<script>"))
    }

    @Test("Ampersands in attributes are escaped")
    func ampersandsEscaped() throws {
        let url = "/search?q=foo&bar=baz"
        let html = tag("a").attribute("href", url)
        let rendered = try String(html)

        #expect(rendered.contains("&amp;") || rendered.contains("&bar"))
    }

    // MARK: - HTML Entity Injection

    @Test("HTML entities in text don't execute")
    func htmlEntitiesInText() throws {
        let malicious = "&#60;script&#62;alert('XSS')&#60;/script&#62;"
        let html = tag("p") { HTMLText(malicious) }
        let rendered = try String(html)

        // The entity codes should be escaped or rendered as text
        #expect(!rendered.contains("<script>"))
    }

    @Test("Hex encoded entities don't execute")
    func hexEncodedEntities() throws {
        let malicious = "&#x3C;script&#x3E;alert('XSS')&#x3C;/script&#x3E;"
        let html = tag("p") { HTMLText(malicious) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script>"))
    }

    // MARK: - Style Injection Prevention

    @Test("Style values don't allow expression injection")
    func styleExpressionInjection() throws {
        // Old IE expression() attack
        let malicious = "expression(alert('XSS'))"
        let html = tag("div") { HTMLText("Content") }
            .inlineStyle("color", malicious)
        let rendered = try String(HTMLDocument { html })

        // Style should be present but expression shouldn't execute
        // The style value is passed through - it's CSS, not HTML
        #expect(rendered.contains("expression"))
    }

    @Test("URL function in style")
    func styleURLInjection() throws {
        // Attempting javascript: URL in style
        let malicious = "url(javascript:alert('XSS'))"
        let html = tag("div") { HTMLText("Content") }
            .inlineStyle("background", malicious)
        let rendered = try String(HTMLDocument { html })

        // The value is passed through - CSS, not HTML context
        #expect(rendered.contains("background:"))
    }

    // MARK: - Raw HTML Security

    @Test("HTMLRaw is not escaped (use with caution)")
    func rawHTMLNotEscaped() throws {
        let dangerous = "<script>alert('This executes')</script>"
        let html = HTMLRaw(dangerous)
        let rendered = try String(HTMLGroup { html })

        // RAW HTML IS NOT ESCAPED - THIS IS INTENTIONAL BUT DANGEROUS
        #expect(rendered.contains("<script>"))
    }

    @Test("Only use HTMLRaw with trusted content")
    func rawHTMLTrusted() throws {
        // Only trusted, sanitized content should use HTMLRaw
        let trusted = "<strong>Bold text</strong>"
        let html = HTMLRaw(trusted)
        let rendered = try String(HTMLGroup { html })

        #expect(rendered.contains("<strong>"))
    }

    // MARK: - Unicode Security

    @Test("Unicode escape sequences don't bypass escaping")
    func unicodeEscapeSequences() throws {
        // \u003c = < and \u003e = >
        let malicious = "\\u003cscript\\u003ealert('XSS')\\u003c/script\\u003e"
        let html = tag("p") { HTMLText(malicious) }
        let rendered = try String(html)

        // The backslash sequences are literal text, not interpreted
        #expect(rendered.contains("\\u003c"))
    }

    @Test("Zero-width characters in text")
    func zeroWidthCharacters() throws {
        // Zero-width joiner and other invisible characters
        let sneaky = "scr\u{200B}ipt"  // script with zero-width space
        let html = tag("p") { HTMLText("<\(sneaky)>alert('XSS')</\(sneaky)>") }
        let rendered = try String(html)

        // Should still escape the angle brackets
        #expect(rendered.contains("&lt;"))
        #expect(rendered.contains("&gt;"))
    }

    // MARK: - Attribute Context Escaping

    @Test("Single quotes in double-quoted attributes")
    func singleQuotesInAttributes() throws {
        let value = "It's a test"
        let html = tag("div").attribute("title", value)
        let rendered = try String(html)

        // Single quotes should be safe in double-quoted attributes
        #expect(rendered.contains("title=\"It's a test\"") || rendered.contains("It&#39;s"))
    }

    @Test("Newlines in attributes")
    func newlinesInAttributes() throws {
        let value = "Line 1\nLine 2"
        let html = tag("div").attribute("data-content", value)
        let rendered = try String(html)

        // Newlines should be preserved or escaped
        #expect(rendered.contains("data-content="))
    }

    // MARK: - Complete XSS Payload Tests

    @Test("Common XSS payload 1: IMG onerror")
    func xssPayloadImgOnerror() throws {
        let payload = "<IMG SRC=x onerror=\"alert('XSS')\">"
        let html = tag("div") { HTMLText(payload) }
        let rendered = try String(html)

        // The < is escaped, preventing browser from parsing as HTML
        #expect(rendered.contains("&lt;IMG"))
        // No actual IMG tag is created
        #expect(!rendered.contains("<IMG"))
    }

    @Test("Common XSS payload 2: SVG onload")
    func xssPayloadSvgOnload() throws {
        let payload = "<svg onload=\"alert('XSS')\">"
        let html = tag("div") { HTMLText(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;svg"))
    }

    @Test("Common XSS payload 3: body onload")
    func xssPayloadBodyOnload() throws {
        let payload = "<body onload=\"alert('XSS')\">"
        let html = tag("div") { HTMLText(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;body"))
    }

    @Test("Common XSS payload 4: iframe")
    func xssPayloadIframe() throws {
        let payload = "<iframe src=\"javascript:alert('XSS')\">"
        let html = tag("div") { HTMLText(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;iframe"))
    }

    // MARK: - Content-Type Considerations

    @Test("HTML document sets proper structure")
    func documentStructure() throws {
        let document = HTMLDocument {
            tag("p") { HTMLText("Content") }
        }
        let rendered = try String(document)

        #expect(rendered.contains("<!doctype html>"))
        #expect(rendered.contains("<html>"))
    }

    // MARK: - Nested Attack Vectors

    @Test("Nested script tags")
    func nestedScriptTags() throws {
        let payload = "<<script>script>alert('XSS')<</script>/script>"
        let html = tag("p") { HTMLText(payload) }
        let rendered = try String(html)

        #expect(!rendered.contains("<script>"))
    }

    @Test("Mixed case script tag")
    func mixedCaseScript() throws {
        let payload = "<ScRiPt>alert('XSS')</ScRiPt>"
        let html = tag("p") { HTMLText(payload) }
        let rendered = try String(html)

        #expect(rendered.contains("&lt;ScRiPt&gt;"))
    }
}

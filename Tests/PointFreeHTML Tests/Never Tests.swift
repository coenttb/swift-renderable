//
//  Never Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Never Tests")
struct NeverTests {

    // MARK: - Protocol Conformance

    @Test("Never conforms to HTML")
    func conformsToHTML() {
        // This test verifies that Never conforms to HTML at compile time
        // The conformance enables types with `body: Never` to work properly
        func acceptsHTML<T: HTML.View>(_ type: T.Type) -> Bool {
            return true
        }

        #expect(acceptsHTML(Never.self))
    }

    // MARK: - Usage in Custom Types

    @Test("Never body allows custom rendering")
    func neverBodyAllowsCustomRendering() throws {
        // Types that use custom rendering declare `body: Never`
        // This tests that such types work correctly
        struct CustomHTML: HTML.View {
            var body: Never { fatalError() }

            static func _render<Buffer: RangeReplaceableCollection>(
                _ html: Self,
                into buffer: inout Buffer,
                context: inout HTML.Context
            ) where Buffer.Element == UInt8 {
                buffer.append(contentsOf: "Custom".utf8)
            }
        }

        let rendered = try String(CustomHTML())
        #expect(rendered == "Custom")
    }

    @Test("Never in HTML.Text body")
    func neverInHTMLTextBody() throws {
        // HTML.Text uses `body: Never` because it renders directly
        let text = HTML.Text("Direct render")
        let rendered = try String(text)
        #expect(rendered == "Direct render")
    }

    @Test("Never in Empty body")
    func neverInEmptyBody() throws {
        // Empty uses `body: Never` because it renders nothing
        let empty = Empty()
        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test("Never in HTML.Raw body")
    func neverInHTMLRawBody() throws {
        // HTML.Raw uses `body: Never` because it renders directly
        let raw = HTML.Raw("<b>Bold</b>")
        let rendered = try String(raw)
        #expect(rendered == "<b>Bold</b>")
    }

    // MARK: - Type System

    @Test("Never enables compile-time safety")
    func compiletimeSafety() {
        // Types with `body: Never` indicate they override `_render`
        // This test verifies the type system accepts these types
        func usesHTML<T: HTML.View>(_ html: T) -> String {
            return String(describing: type(of: html))
        }

        let text = HTML.Text("test")
        let empty = Empty()
        let raw = HTML.Raw("raw")

        #expect(usesHTML(text) == "Text")
        #expect(usesHTML(empty) == "Empty")
        #expect(usesHTML(raw) == "Raw")  // HTML.Raw is typealias for Raw
    }
}

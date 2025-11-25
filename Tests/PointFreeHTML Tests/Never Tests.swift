//
//  Never Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("Never Tests")
struct NeverTests {

    // MARK: - Protocol Conformance

    @Test("Never conforms to HTML")
    func conformsToHTML() {
        // This test verifies that Never conforms to HTML at compile time
        // The conformance enables types with `body: Never` to work properly
        func acceptsHTML<T: HTML>(_ type: T.Type) -> Bool {
            return true
        }

        #expect(acceptsHTML(Never.self))
    }

    // MARK: - Usage in Custom Types

    @Test("Never body allows custom rendering")
    func neverBodyAllowsCustomRendering() throws {
        // Types that use custom rendering declare `body: Never`
        // This tests that such types work correctly
        struct CustomHTML: HTML {
            var body: Never { fatalError() }

            static func _render<Buffer: RangeReplaceableCollection>(
                _ html: Self,
                into buffer: inout Buffer,
                context: inout HTMLContext
            ) where Buffer.Element == UInt8 {
                buffer.append(contentsOf: "Custom".utf8)
            }
        }

        let rendered = try String(CustomHTML())
        #expect(rendered == "Custom")
    }

    @Test("Never in HTMLText body")
    func neverInHTMLTextBody() throws {
        // HTMLText uses `body: Never` because it renders directly
        let text = HTMLText("Direct render")
        let rendered = try String(text)
        #expect(rendered == "Direct render")
    }

    @Test("Never in HTMLEmpty body")
    func neverInHTMLEmptyBody() throws {
        // HTMLEmpty uses `body: Never` because it renders nothing
        let empty = HTMLEmpty()
        let rendered = try String(empty)
        #expect(rendered.isEmpty)
    }

    @Test("Never in HTMLRaw body")
    func neverInHTMLRawBody() throws {
        // HTMLRaw uses `body: Never` because it renders directly
        let raw = HTMLRaw("<b>Bold</b>")
        let rendered = try String(raw)
        #expect(rendered == "<b>Bold</b>")
    }

    // MARK: - Type System

    @Test("Never enables compile-time safety")
    func compiletimeSafety() {
        // Types with `body: Never` indicate they override `_render`
        // This test verifies the type system accepts these types
        func usesHTML<T: HTML>(_ html: T) -> String {
            return String(describing: type(of: html))
        }

        let text = HTMLText("test")
        let empty = HTMLEmpty()
        let raw = HTMLRaw("raw")

        #expect(usesHTML(text) == "HTMLText")
        #expect(usesHTML(empty) == "HTMLEmpty")
        #expect(usesHTML(raw) == "HTMLRaw")
    }
}

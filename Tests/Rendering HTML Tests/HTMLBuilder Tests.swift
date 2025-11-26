//
//  HTMLBuilderTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Testing

@Suite
struct `HTMLBuilder Tests` {

    @Test
    func `HTML.Text basic functionality`() throws {
        let text = HTML.Text("Hello, World!")
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    @Test
    func `HTML.Text escapes HTML characters`() throws {
        let text = HTML.Text("<script>alert('xss')</script>")
        let rendered = try String(text)
        #expect(rendered.contains("&lt;script&gt;"))
        #expect(!rendered.contains("<script>"))
    }

    @Test
    func `HTMLBuilder with single element`() throws {
        struct TestHTML: HTML.View {
            var body: some HTML.View {
                HTML.Text("single")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "single")
    }

    @Test
    func `HTMLBuilder with multiple elements`() throws {
        struct TestHTML: HTML.View {
            var body: some HTML.View {
                HTML.Text("first")
                HTML.Text("second")
                HTML.Text("third")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "firstsecondthird")
    }

    @Test
    func `HTMLBuilder conditional rendering - true`() throws {
        struct TestHTML: HTML.View {
            let showContent = true

            var body: some HTML.View {
                if showContent {
                    HTML.Text("visible")
                } else {
                    HTML.Text("hidden")
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "visible")
    }

    @Test
    func `HTMLBuilder conditional rendering - false`() throws {
        struct TestHTML: HTML.View {
            let showContent = false

            var body: some HTML.View {
                if showContent {
                    HTML.Text("visible")
                } else {
                    HTML.Text("hidden")
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "hidden")
    }

    @Test
    func `HTMLBuilder with array of elements`() throws {
        struct TestHTML: HTML.View {
            let items = ["first", "second", "third"]

            var body: some HTML.View {
                for item in items {
                    HTML.Text(item)
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "firstsecondthird")
    }
}

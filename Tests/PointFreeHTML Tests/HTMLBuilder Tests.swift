//
//  HTMLBuilderTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import Testing

@Suite("HTMLBuilder Tests")
struct HTMLBuilderTests {

    @Test("HTML.Text basic functionality")
    func htmlTextBasics() throws {
        let text = HTML.Text("Hello, World!")
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    @Test("HTML.Text escapes HTML characters")
    func htmlTextEscaping() throws {
        let text = HTML.Text("<script>alert('xss')</script>")
        let rendered = try String(text)
        #expect(rendered.contains("&lt;script&gt;"))
        #expect(!rendered.contains("<script>"))
    }

    @Test("HTMLBuilder with single element")
    func builderSingleElement() throws {
        struct TestHTML: HTML.View {
            var body: some HTML.View {
                HTML.Text("single")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "single")
    }

    @Test("HTMLBuilder with multiple elements")
    func builderMultipleElements() throws {
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

    @Test("HTMLBuilder conditional rendering - true")
    func builderConditionalTrue() throws {
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

    @Test("HTMLBuilder conditional rendering - false")
    func builderConditionalFalse() throws {
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

    @Test("HTMLBuilder with array of elements")
    func builderWithArray() throws {
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

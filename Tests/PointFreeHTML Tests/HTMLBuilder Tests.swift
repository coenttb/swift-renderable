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

    @Test("HTMLText basic functionality")
    func htmlTextBasics() throws {
        let text = HTMLText("Hello, World!")
        let rendered = try String(text)
        #expect(rendered == "Hello, World!")
    }

    @Test("HTMLText escapes HTML characters")
    func htmlTextEscaping() throws {
        let text = HTMLText("<script>alert('xss')</script>")
        let rendered = try String(text)
        #expect(rendered.contains("&lt;script&gt;"))
        #expect(!rendered.contains("<script>"))
    }

    @Test("HTMLBuilder with single element")
    func builderSingleElement() throws {
        struct TestHTML: HTML {
            var body: some HTML {
                HTMLText("single")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "single")
    }

    @Test("HTMLBuilder with multiple elements")
    func builderMultipleElements() throws {
        struct TestHTML: HTML {
            var body: some HTML {
                HTMLText("first")
                HTMLText("second")
                HTMLText("third")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "firstsecondthird")
    }

    @Test("HTMLBuilder conditional rendering - true")
    func builderConditionalTrue() throws {
        struct TestHTML: HTML {
            let showContent = true

            var body: some HTML {
                if showContent {
                    HTMLText("visible")
                } else {
                    HTMLText("hidden")
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "visible")
    }

    @Test("HTMLBuilder conditional rendering - false")
    func builderConditionalFalse() throws {
        struct TestHTML: HTML {
            let showContent = false

            var body: some HTML {
                if showContent {
                    HTMLText("visible")
                } else {
                    HTMLText("hidden")
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "hidden")
    }

    @Test("HTMLBuilder with array of elements")
    func builderWithArray() throws {
        struct TestHTML: HTML {
            let items = ["first", "second", "third"]

            var body: some HTML {
                for item in items {
                    HTMLText(item)
                }
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "firstsecondthird")
    }
}

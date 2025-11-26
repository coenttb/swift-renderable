//
//  HTMLTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Testing

@Suite
struct `HTML Protocol Tests` {

    @Test
    func `HTML protocol basic functionality`() throws {
        struct TestHTML: HTML.View {
            var body: some HTML.View {
                HTML.Text("test content")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "test content")
    }

    @Test
    func `AnyHTML type erasure`() throws {
        let html1 = HTML.Text("first")
        let html2 = HTML.Text("second")

        let anyHTML1 = AnyHTML(html1)
        let anyHTML2 = AnyHTML(html2)

        #expect(try String(anyHTML1) == "first")
        #expect(try String(anyHTML2) == "second")
    }

    @Test
    func `HTML composition`() throws {
        struct ParentHTML: HTML.View {
            var body: some HTML.View {
                Group {
                    HTML.Text("parent ")
                    ChildHTML()
                }
            }
        }

        struct ChildHTML: HTML.View {
            var body: some HTML.View {
                HTML.Text("child")
            }
        }

        let html = ParentHTML()
        let rendered = try String(html)
        #expect(rendered == "parent child")
    }
}

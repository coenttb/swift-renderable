//
//  HTMLTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import Testing

@Suite("HTML Protocol Tests")
struct HTMLTests {

    @Test("HTML protocol basic functionality")
    func htmlProtocolBasics() throws {
        struct TestHTML: HTML {
            var body: some HTML {
                HTMLText("test content")
            }
        }

        let html = TestHTML()
        let rendered = try String(html)
        #expect(rendered == "test content")
    }

    @Test("AnyHTML type erasure")
    func anyHTMLTypeErasure() throws {
        let html1 = HTMLText("first")
        let html2 = HTMLText("second")

        let anyHTML1 = AnyHTML(html1)
        let anyHTML2 = AnyHTML(html2)

        #expect(try String(anyHTML1) == "first")
        #expect(try String(anyHTML2) == "second")
    }

    @Test("HTML composition")
    func htmlComposition() throws {
        struct ParentHTML: HTML {
            var body: some HTML {
                HTMLGroup {
                    HTMLText("parent ")
                    ChildHTML()
                }
            }
        }

        struct ChildHTML: HTML {
            var body: some HTML {
                HTMLText("child")
            }
        }

        let html = ParentHTML()
        let rendered = try String(html)
        #expect(rendered == "parent child")
    }
}

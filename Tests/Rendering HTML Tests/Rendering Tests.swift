//
//  Rendering Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//
//  Tests for HTML rendering functionality (formerly HTMLPrinter).
//

import INCITS_4_1986
@testable import Rendering_HTML
import OrderedCollections
import Testing
import Rendering
import Foundation

@Suite
struct `Rendering Tests` {

    @Test
    func `Basic rendering`() throws {
        let element = tag("div") {
            HTML.Text("test content")
        }

        try HTML.Context.Configuration.$current.withValue(.default) {
            let rendered = try String(element)

            #expect(rendered.contains("<div>"))
            #expect(rendered.contains("test content"))
            #expect(rendered.contains("</div>"))
        }
    }

    @Test
    func `Rendering with pretty configuration`() throws {
        let element = tag("div") {
            HTML.Text("content")
        }

        try HTML.Context.Configuration.$current.withValue(.pretty) {
            let rendered = try String(element)

            #expect(!rendered.isEmpty)
            #expect(rendered.contains("content"))
            #expect(rendered.contains("\n"))  // Pretty format includes newlines
        }
    }

    @Test
    func `Empty content rendering`() throws {
        let empty = Empty()

        try HTML.Context.Configuration.$current.withValue(.default) {
            let rendered = try String(empty)

            #expect(rendered.isEmpty)
        }
    }

    @Test
    func `Nested elements rendering`() throws {
        let element = tag("div") {
            tag("p") {
                HTML.Text("nested content")
            }
        }

        HTML.Context.Configuration.$current.withValue(.default) {
            let bytes = ContiguousArray(element)
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(rendered.contains("<div>"))
            #expect(rendered.contains("<p>"))
            #expect(rendered.contains("nested content"))
            #expect(rendered.contains("</p>"))
            #expect(rendered.contains("</div>"))
        }
    }

    @Test
    func `Manual rendering with buffer and context`() throws {
        var buffer: ContiguousArray<UInt8> = []
        var context = HTML.Context(.default)
        let element = tag("span") {
            HTML.Text("manual render")
        }

        HTML.Element._render(element, into: &buffer, context: &context)
        let rendered = String(data: Data(buffer), encoding: .utf8) ?? ""

        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("manual render"))
        #expect(rendered.contains("</span>"))
    }

    @Test
    func `Stylesheet generation via context`() throws {
        var context = HTML.Context(.pretty)

        // Add some styles to test stylesheet generation
        context.styles[HTML.StyleKey(nil, ".test-class")] = "color:red;font-size:16px"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains(".test-class"))
        #expect(stylesheet.contains("color:red"))
        #expect(stylesheet.contains("font-size:16px"))
    }

    @Test
    func `Rendering configuration options`() throws {
        let defaultConfig = HTML.Context.Configuration.default
        let prettyConfig = HTML.Context.Configuration.pretty
        let emailConfig = HTML.Context.Configuration.email

        #expect(defaultConfig.indentation == [])
        #expect(defaultConfig.newline == [])
        #expect(!defaultConfig.forceImportant)

        #expect(prettyConfig.indentation == [.ascii.space, .ascii.space])
        #expect(prettyConfig.newline == [.ascii.lf])
        #expect(!prettyConfig.forceImportant)

        #expect(emailConfig.forceImportant)
    }

    @Test
    func `Document rendering`() throws {
        let document = HTML.Document {
            tag("h1") {
                HTML.Text("Hello World")
            }
        } head: {
            tag("title") {
                HTML.Text("Test")
            }
        }

        try HTML.Context.Configuration.$current.withValue(.default) {
            let rendered = try String(document)

            #expect(rendered.contains("<!doctype html>"))
            #expect(rendered.contains("<title>Test</title>"))
            #expect(rendered.contains("<h1>Hello World</h1>"))
        }
    }
}

//
//  Rendering Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//
//  Tests for HTML rendering functionality (formerly HTMLPrinter).
//

import INCITS_4_1986
@testable import RenderingHTML
import OrderedCollections
import Testing
import Rendering
import Foundation

@Suite("Rendering Tests")
struct RenderingTests {

    @Test("Basic rendering")
    func basicRendering() throws {
        let element = tag("div") {
            HTMLText("test content")
        }

        try HTMLContext.Rendering.$current.withValue(.default) {
            let rendered = try String(element)

            #expect(rendered.contains("<div>"))
            #expect(rendered.contains("test content"))
            #expect(rendered.contains("</div>"))
        }
    }

    @Test("Rendering with pretty configuration")
    func prettyConfiguration() throws {
        let element = tag("div") {
            HTMLText("content")
        }

        try HTMLContext.Rendering.$current.withValue(.pretty) {
            let rendered = try String(element)

            #expect(!rendered.isEmpty)
            #expect(rendered.contains("content"))
            #expect(rendered.contains("\n"))  // Pretty format includes newlines
        }
    }

    @Test("Empty content rendering")
    func emptyContent() throws {
        let empty = Empty()

        try HTMLContext.Rendering.$current.withValue(.default) {
            let rendered = try String(empty)

            #expect(rendered.isEmpty)
        }
    }

    @Test("Nested elements rendering")
    func nestedElements() throws {
        let element = tag("div") {
            tag("p") {
                HTMLText("nested content")
            }
        }

        HTMLContext.Rendering.$current.withValue(.default) {
            let bytes = ContiguousArray(element)
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(rendered.contains("<div>"))
            #expect(rendered.contains("<p>"))
            #expect(rendered.contains("nested content"))
            #expect(rendered.contains("</p>"))
            #expect(rendered.contains("</div>"))
        }
    }

    @Test("Manual rendering with buffer and context")
    func manualRendering() throws {
        var buffer: ContiguousArray<UInt8> = []
        var context = HTMLContext(.default)
        let element = tag("span") {
            HTMLText("manual render")
        }

        HTMLElement._render(element, into: &buffer, context: &context)
        let rendered = String(data: Data(buffer), encoding: .utf8) ?? ""

        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("manual render"))
        #expect(rendered.contains("</span>"))
    }

    @Test("Stylesheet generation via context")
    func stylesheetGeneration() throws {
        var context = HTMLContext(.pretty)

        // Add some styles to test stylesheet generation
        context.styles[StyleKey(nil, ".test-class")] = "color:red;font-size:16px"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains(".test-class"))
        #expect(stylesheet.contains("color:red"))
        #expect(stylesheet.contains("font-size:16px"))
    }

    @Test("Rendering configuration options")
    func configurationOptions() throws {
        let defaultConfig = HTMLContext.Rendering.default
        let prettyConfig = HTMLContext.Rendering.pretty
        let emailConfig = HTMLContext.Rendering.email

        #expect(defaultConfig.indentation == [])
        #expect(defaultConfig.newline == [])
        #expect(!defaultConfig.forceImportant)

        #expect(prettyConfig.indentation == [.ascii.space, .ascii.space])
        #expect(prettyConfig.newline == [.ascii.lf])
        #expect(!prettyConfig.forceImportant)

        #expect(emailConfig.forceImportant)
    }

    @Test("Document rendering")
    func documentRendering() throws {
        let document = HTMLDocument {
            tag("h1") {
                HTMLText("Hello World")
            }
        } head: {
            tag("title") {
                HTMLText("Test")
            }
        }

        try HTMLContext.Rendering.$current.withValue(.default) {
            let rendered = try String(document)

            #expect(rendered.contains("<!doctype html>"))
            #expect(rendered.contains("<title>Test</title>"))
            #expect(rendered.contains("<h1>Hello World</h1>"))
        }
    }
}

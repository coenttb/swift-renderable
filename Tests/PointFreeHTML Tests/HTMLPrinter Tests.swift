//
//  HTMLPrinter Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import Dependencies
import PointFreeHTML
import Testing
import Foundation

@Suite("HTMLPrinter Tests")
struct HTMLPrinterTests {

    @Test("HTMLPrinter basic rendering")
    func basicRendering() throws {
        let element = tag("div") {
            HTMLText("test content")
        }

        withDependencies {
            $0.htmlPrinter = HTMLPrinter(.default)
        } operation: {
            let bytes = element.render()
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(rendered.contains("<div>"))
            #expect(rendered.contains("test content"))
            #expect(rendered.contains("</div>"))
        }
    }

    @Test("HTMLPrinter with pretty configuration")
    func prettyConfiguration() throws {
        let element = tag("div") {
            HTMLText("content")
        }

        withDependencies {
            $0.htmlPrinter = HTMLPrinter(.pretty)
        } operation: {
            let bytes = element.render()
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(!rendered.isEmpty)
            #expect(rendered.contains("content"))
            #expect(rendered.contains("\n")) // Pretty format includes newlines
        }
    }

    @Test("HTMLPrinter empty content")
    func emptyContent() throws {
        let empty = HTMLEmpty()

        withDependencies {
            $0.htmlPrinter = HTMLPrinter(.default)
        } operation: {
            let bytes = empty.render()
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(rendered.isEmpty)
        }
    }

    @Test("HTMLPrinter with nested elements")
    func nestedElements() throws {
        let element = tag("div") {
            tag("p") {
                HTMLText("nested content")
            }
        }

        withDependencies {
            $0.htmlPrinter = HTMLPrinter(.default)
        } operation: {
            let bytes = element.render()
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(rendered.contains("<div>"))
            #expect(rendered.contains("<p>"))
            #expect(rendered.contains("nested content"))
            #expect(rendered.contains("</p>"))
            #expect(rendered.contains("</div>"))
        }
    }

    @Test("HTMLPrinter manual rendering")
    func manualRendering() throws {
        var printer = HTMLPrinter(.default)
        let element = tag("span") {
            HTMLText("manual render")
        }

        HTMLElement._render(element, into: &printer)
        let rendered = String(data: Data(printer.bytes), encoding: .utf8) ?? ""

        #expect(rendered.contains("<span>"))
        #expect(rendered.contains("manual render"))
        #expect(rendered.contains("</span>"))
    }

    @Test("HTMLPrinter stylesheet generation")
    func stylesheetGeneration() throws {
        var printer = HTMLPrinter(.pretty)

        // Add some styles to test stylesheet generation
        printer.styles[nil] = [".test-class": "color:red;font-size:16px"]

        let stylesheet = printer.stylesheet
        #expect(stylesheet.contains(".test-class"))
        #expect(stylesheet.contains("color:red"))
        #expect(stylesheet.contains("font-size:16px"))
    }

    @Test("HTMLPrinter configuration options")
    func configurationOptions() throws {
        let defaultConfig = HTMLPrinter.Configuration.default
        let prettyConfig = HTMLPrinter.Configuration.pretty
        let emailConfig = HTMLPrinter.Configuration.email

        #expect(defaultConfig.indentation == "")
        #expect(defaultConfig.newline == "")
        #expect(!defaultConfig.forceImportant)

        #expect(prettyConfig.indentation == "  ")
        #expect(prettyConfig.newline == "\n")
        #expect(!prettyConfig.forceImportant)

        #expect(emailConfig.forceImportant)
    }

    @Test("HTMLPrinter document rendering")
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

        withDependencies {
            $0.htmlPrinter = HTMLPrinter(.default)
        } operation: {
            let bytes = document.render()
            let rendered = String(data: Data(bytes), encoding: .utf8) ?? ""

            #expect(rendered.contains("<!doctype html>"))
            #expect(rendered.contains("<title>Test</title>"))
            #expect(rendered.contains("<h1>Hello World</h1>"))
        }
    }
}

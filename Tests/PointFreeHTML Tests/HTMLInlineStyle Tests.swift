//
//  HTMLInlineStyleTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTMLInlineStyle Tests")
struct HTMLInlineStyleTests {

    @Test("Basic inline style")
    func basicInlineStyle() throws {
        let styledElement = tag("div") {
            HTMLText("styled content")
        }
        .inlineStyle("color", "red")

        let rendered = try String(HTMLDocument { styledElement })
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("styled content"))
    }

    @Test("Multiple inline styles")
    func multipleInlineStyles() throws {
        let styledElement = tag("div") {
            HTMLText("content")
        }
        .inlineStyle("color", "red")
        .inlineStyle("background-color", "blue")
        .inlineStyle("font-size", "16px")

        let rendered = try String(HTMLDocument { styledElement })
        #expect(rendered.contains("color:red"))
        #expect(rendered.contains("background-color:blue"))
        #expect(rendered.contains("font-size:16px"))
    }

    @Test("Style chaining")
    func styleChaining() throws {
        let styledElement = tag("p") {
            HTMLText("paragraph")
        }
        .inlineStyle("margin", "10px")
        .inlineStyle("padding", "5px")

        let rendered = try String(HTMLDocument { styledElement })
        #expect(rendered.contains("margin:10px"))
        #expect(rendered.contains("padding:5px"))
    }

    @Test("Style with attributes")
    func styleWithAttributes() throws {
        let element = tag("div") {
            HTMLText("content")
        }
        .attribute("class", "test-class")
        .inlineStyle("display", "flex")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("class=\"test-class\""))
        #expect(rendered.contains("display:flex"))
    }

    @Test("Empty style value")
    func emptyStyleValue() throws {
        let styledElement = tag("div") {
            HTMLText("content")
        }
        .inlineStyle("color", "")

        let rendered = try String(HTMLDocument { styledElement })
        // Empty values might be omitted or rendered as empty
        #expect(rendered.contains("content"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLInlineStyleSnapshotTests {
        @Test("Basic inline style snapshot")
        func basicInlineStyleSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        HTMLText("Styled content")
                    }
                    .inlineStyle("color", "red")
                    .inlineStyle("font-size", "18px")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                .color-0{color:red}
                .font-size-1{font-size:18px}

                    </style>
                  </head>
                  <body>
                <div class="color-0 font-size-1">Styled content
                </div>
                  </body>
                </html>
                """
            }
        }

        @Test("Complex styling snapshot")
        func complexStylingSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        tag("h1") {
                            HTMLText("Welcome")
                        }
                        .inlineStyle("color", "navy")
                        .inlineStyle("font-family", "Arial, sans-serif")

                        tag("p") {
                            HTMLText("This paragraph has styling.")
                        }
                        .inlineStyle("color", "#333")
                        .inlineStyle("padding", "10px")
                        .inlineStyle("background-color", "#f5f5f5")
                    }
                    .attribute("class", "container")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                .color-0{color:navy}
                .font-family-1{font-family:Arial, sans-serif}
                .color-2{color:#333}
                .padding-3{padding:10px}
                .background-color-4{background-color:#f5f5f5}

                    </style>
                  </head>
                  <body>
                <div class="container">
                  <h1 class="color-0 font-family-1">Welcome
                  </h1>
                  <p class="color-2 padding-3 background-color-4">This paragraph has styling.
                  </p>
                </div>
                  </body>
                </html>
                """
            }
        }

        @Test("Style with attributes snapshot")
        func styleWithAttributesSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        tag("a") {
                            HTMLText("Styled link")
                        }
                        .attribute("href", "https://example.com")
                        .inlineStyle("color", "#007bff")
                        .inlineStyle("text-decoration", "none")
                    }
                    .inlineStyle("padding", "20px")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                .padding-0{padding:20px}
                .color-1{color:#007bff}
                .text-decoration-2{text-decoration:none}

                    </style>
                  </head>
                  <body>
                <div class="padding-0"><a class="color-1 text-decoration-2" href="https://example.com">Styled link</a>
                </div>
                  </body>
                </html>
                """
            }
        }
    }
}

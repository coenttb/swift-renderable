//
//  HTML.RawTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTML.Raw Tests")
struct HTMLRawTests {

    @Test("HTML.Raw with plain text")
    func rawWithPlainText() throws {
        let raw = HTML.Raw("plain text")
        let rendered = try String(raw)
        #expect(rendered == "plain text")
    }

    @Test("HTML.Raw with HTML tags")
    func rawWithHTMLTags() throws {
        let raw = HTML.Raw("<strong>bold text</strong>")
        let rendered = try String(raw)
        #expect(rendered == "<strong>bold text</strong>")
        #expect(rendered.contains("<strong>"))
        #expect(rendered.contains("</strong>"))
    }

    @Test("HTML.Raw does not escape HTML")
    func rawDoesNotEscape() throws {
        let raw = HTML.Raw("<div class='test'>content</div>")
        let rendered = try String(HTML.Document { raw })
        #expect(rendered.contains("<div class='test'>"))
        #expect(!rendered.contains("&lt;"))
        #expect(!rendered.contains("&gt;"))
    }

    @Test("HTML.Raw with special characters")
    func rawWithSpecialCharacters() throws {
        let raw = HTML.Raw("© 2025 & company <script>alert('test')</script>")
        let rendered = try String(HTML.Document { raw })
        #expect(rendered.contains("© 2025 & company"))
        #expect(rendered.contains("<script>"))
        #expect(!rendered.contains("&copy;"))
        #expect(!rendered.contains("&amp;"))
    }

    @Test("HTML.Raw in composition")
    func rawInComposition() throws {
        let element = tag("div") {
            HTML.Text("Safe text: ")
            HTML.Raw("<em>raw emphasis</em>")
            HTML.Text(" & more safe text")
        }

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("Safe text: "))
        #expect(rendered.contains("<em>raw emphasis</em>"))
        #expect(rendered.contains("&amp; more safe text"))
    }

    @Test("Empty HTML.Raw")
    func emptyRaw() throws {
        let raw = HTML.Raw("")
        let rendered = try String(raw)
        #expect(rendered.isEmpty)
    }

    @Test("HTML.Raw with multiline content")
    func rawWithMultilineContent() throws {
        let content = """
            <div>
                <h1>Title</h1>
                <p>Paragraph</p>
            </div>
            """
        let raw = HTML.Raw(content)
        let rendered = try String(raw)
        #expect(rendered == content)
        #expect(rendered.contains("<h1>Title</h1>"))
        #expect(rendered.contains("<p>Paragraph</p>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLRawSnapshotTests {
        @Test("HTML.Raw embedded content snapshot")
        func rawEmbeddedContentSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h1") {
                            HTML.Text("Blog Post")
                        }

                        tag("div") {
                            HTML.Raw(
                                """
                                <p>This content includes <strong>pre-formatted HTML</strong> that should render as-is.</p>
                                <blockquote cite="https://example.com">
                                    <p>This is a quote with <em>emphasis</em> and a citation.</p>
                                </blockquote>
                                """
                            )
                        }
                        .attribute("class", "raw-content")

                        tag("p") {
                            HTML.Text("This is regular text that will be escaped.")
                        }
                    }
                    .attribute("class", "blog-post")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div class="blog-post">
                      <h1>Blog Post
                      </h1>
                      <div class="raw-content"><p>This content includes <strong>pre-formatted HTML</strong> that should render as-is.</p>
                <blockquote cite="https://example.com">
                    <p>This is a quote with <em>emphasis</em> and a citation.</p>
                </blockquote>
                      </div>
                      <p>This is regular text that will be escaped.
                      </p>
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("HTML.Raw with scripts and styles snapshot")
        func rawWithScriptsSnapshot() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h2") {
                            HTML.Text("Interactive Content")
                        }

                        HTML.Raw(
                            """
                            <div id="interactive-widget">
                                <p>Click the button below:</p>
                                <button onclick="alert('Hello!')">Click Me</button>
                            </div>
                            <style>
                                #interactive-widget {
                                    border: 2px solid #007bff;
                                    padding: 20px;
                                    border-radius: 8px;
                                }
                                #interactive-widget button {
                                    background: #007bff;
                                    color: white;
                                    border: none;
                                    padding: 10px 20px;
                                    border-radius: 4px;
                                }
                            </style>
                            """
                        )

                        tag("p") {
                            HTML.Text("The above widget was inserted as raw HTML.")
                        }
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div>
                      <h2>Interactive Content
                      </h2><div id="interactive-widget">
                    <p>Click the button below:</p>
                    <button onclick="alert('Hello!')">Click Me</button>
                </div>
                <style>
                    #interactive-widget {
                        border: 2px solid #007bff;
                        padding: 20px;
                        border-radius: 8px;
                    }
                    #interactive-widget button {
                        background: #007bff;
                        color: white;
                        border: none;
                        padding: 10px 20px;
                        border-radius: 4px;
                    }
                </style>
                      <p>The above widget was inserted as raw HTML.
                      </p>
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}

//
//  HTMLRawTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "HTMLRaw Tests",
    .snapshots(record: .missing)
)
struct HTMLRawTests {

    @Test("HTMLRaw with plain text")
    func rawWithPlainText() throws {
        let raw = HTMLRaw("plain text")
        let rendered = try String(raw)
        #expect(rendered == "plain text")
    }

    @Test("HTMLRaw with HTML tags")
    func rawWithHTMLTags() throws {
        let raw = HTMLRaw("<strong>bold text</strong>")
        let rendered = try String(raw)
        #expect(rendered == "<strong>bold text</strong>")
        #expect(rendered.contains("<strong>"))
        #expect(rendered.contains("</strong>"))
    }

    @Test("HTMLRaw does not escape HTML")
    func rawDoesNotEscape() throws {
        let raw = HTMLRaw("<div class='test'>content</div>")
        let rendered = try String(HTMLDocument { raw })
        #expect(rendered.contains("<div class='test'>"))
        #expect(!rendered.contains("&lt;"))
        #expect(!rendered.contains("&gt;"))
    }

    @Test("HTMLRaw with special characters")
    func rawWithSpecialCharacters() throws {
        let raw = HTMLRaw("© 2025 & company <script>alert('test')</script>")
        let rendered = try String(HTMLDocument { raw })
        #expect(rendered.contains("© 2025 & company"))
        #expect(rendered.contains("<script>"))
        #expect(!rendered.contains("&copy;"))
        #expect(!rendered.contains("&amp;"))
    }

    @Test("HTMLRaw in composition")
    func rawInComposition() throws {
        let element = tag("div") {
            HTMLText("Safe text: ")
            HTMLRaw("<em>raw emphasis</em>")
            HTMLText(" & more safe text")
        }

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("Safe text: "))
        #expect(rendered.contains("<em>raw emphasis</em>"))
        #expect(rendered.contains("&amp; more safe text"))
    }

    @Test("Empty HTMLRaw")
    func emptyRaw() throws {
        let raw = HTMLRaw("")
        let rendered = try String(raw)
        #expect(rendered.isEmpty)
    }

    @Test("HTMLRaw with multiline content")
    func rawWithMultilineContent() throws {
        let content = """
        <div>
            <h1>Title</h1>
            <p>Paragraph</p>
        </div>
        """
        let raw = HTMLRaw(content)
        let rendered = try String(raw)
        #expect(rendered == content)
        #expect(rendered.contains("<h1>Title</h1>"))
        #expect(rendered.contains("<p>Paragraph</p>"))
    }

    // MARK: - Snapshot Tests

    @Test("HTMLRaw embedded content snapshot")
    func rawEmbeddedContentSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    tag("h1") {
                        HTMLText("Blog Post")
                    }

                    tag("div") {
                        HTMLRaw("""
                        <p>This content includes <strong>pre-formatted HTML</strong> that should render as-is.</p>
                        <blockquote cite="https://example.com">
                            <p>This is a quote with <em>emphasis</em> and a citation.</p>
                        </blockquote>
                        """)
                    }
                    .attribute("class", "raw-content")

                    tag("p") {
                        HTMLText("This is regular text that will be escaped.")
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
                <style>

                </style>
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

    @Test("HTMLRaw with scripts and styles snapshot")
    func rawWithScriptsSnapshot() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    tag("h2") {
                        HTMLText("Interactive Content")
                    }

                    HTMLRaw("""
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
                    """)

                    tag("p") {
                        HTMLText("The above widget was inserted as raw HTML.")
                    }
                }
            },
            as: .html
        ) {
            """
            <!doctype html>
            <html>
              <head>
                <style>

                </style>
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

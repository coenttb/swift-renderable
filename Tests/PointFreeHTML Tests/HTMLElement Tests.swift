//
//  HTMLElementTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
  "HTMLElement Tests",
  .snapshots(record: .missing)
)
struct HTMLElementTests {

  @Test("HTMLElement with basic tag")
  func basicHTMLElement() throws {
    let element = tag("div") {
      HTMLText("content")
    }

    let rendered = try String(HTMLDocument { element })
    #expect(rendered.contains("<div>"))
    #expect(rendered.contains("content"))
    #expect(rendered.contains("</div>"))
  }

  @Test("HTMLElement empty")
  func emptyHTMLElement() throws {
    let element = tag("div")

    let rendered = try String(HTMLDocument { element })
    #expect(rendered.contains("<div>"))
    #expect(rendered.contains("</div>"))
  }

  @Test("HTMLElement with multiple children")
  func elementWithMultipleChildren() throws {
    let element = tag("div") {
      HTMLText("first")
      HTMLText("second")
    }

    let rendered = try String(HTMLDocument { element })
    #expect(rendered.contains("<div>"))
    #expect(rendered.contains("first"))
    #expect(rendered.contains("second"))
    #expect(rendered.contains("</div>"))
  }

  @Test("HTMLElement with nested elements")
  func nestedElements() throws {
    let element = tag("div") {
      tag("p") {
        HTMLText("paragraph content")
      }
    }

    let rendered = try String(HTMLDocument { element })
    #expect(rendered.contains("<div>"))
    #expect(rendered.contains("<p>"))
    #expect(rendered.contains("paragraph content"))
    #expect(rendered.contains("</p>"))
    #expect(rendered.contains("</div>"))
  }

  @Test("HTMLElement with custom tag")
  func customTagElement() throws {
    let element = tag("custom-element") {
      HTMLText("custom content")
    }

    let rendered = try String(HTMLDocument { element })
    #expect(rendered.contains("<custom-element>"))
    #expect(rendered.contains("custom content"))
    #expect(rendered.contains("</custom-element>"))
  }

  // MARK: - Snapshot Tests

  @Test("HTMLElement basic structure snapshot")
  func basicElementSnapshot() {
    assertInlineSnapshot(
      of: HTMLDocument {
        tag("div") {
          HTMLText("Hello, World!")
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
      <div>Hello, World!
      </div>
        </body>
      </html>
      """
    }
  }

  @Test("HTMLElement with attributes snapshot")
  func elementWithAttributesSnapshot() {
    assertInlineSnapshot(
      of: HTMLDocument {
        tag("div") {
          HTMLText("Content with attributes")
        }
        .attribute("class", "container")
        .attribute("id", "main-div")
        .attribute("data-testid", "test-element")
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
      <div class="container" id="main-div" data-testid="test-element">Content with attributes
      </div>
        </body>
      </html>
      """
    }
  }

  @Test("HTMLElement nested structure snapshot")
  func nestedElementSnapshot() {
    assertInlineSnapshot(
      of: HTMLDocument {
        tag("article") {
          tag("header") {
            tag("h1") {
              HTMLText("Article Title")
            }
            tag("p") {
              HTMLText("By Author Name")
            }
          }
          tag("section") {
            tag("p") {
              HTMLText("This is the first paragraph of the article.")
            }
            tag("p") {
              HTMLText("This is the second paragraph with more content.")
            }
          }
          tag("footer") {
            HTMLText("Published on January 1, 2025")
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
      <article>
        <header>
          <h1>Article Title
          </h1>
          <p>By Author Name
          </p>
        </header>
        <section>
          <p>This is the first paragraph of the article.
          </p>
          <p>This is the second paragraph with more content.
          </p>
        </section>
        <footer>Published on January 1, 2025
        </footer>
      </article>
        </body>
      </html>
      """
    }
  }

  @Test("HTMLElement with mixed content snapshot")
  func mixedContentSnapshot() {
    assertInlineSnapshot(
      of: HTMLDocument {
        tag("div") {
          HTMLText("Text before ")
          tag("strong") {
            HTMLText("bold text")
          }
          HTMLText(" and text after ")
          tag("em") {
            HTMLText("italic text")
          }
          HTMLText(".")
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
      <div>Text before <strong>bold text</strong> and text after <em>italic text</em>.
      </div>
        </body>
      </html>
      """
    }
  }
}

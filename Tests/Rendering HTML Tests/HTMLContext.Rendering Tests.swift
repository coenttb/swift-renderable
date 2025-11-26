//
//  HTML.Context.Configuration Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.Context.Configuration Tests` {

    // MARK: - Preset Configurations

    @Test
    func `Configuration.default properties`() {
        let config = HTML.Context.Configuration.default
        #expect(config.forceImportant == false)
        #expect(config.indentation.isEmpty)
        #expect(config.newline.isEmpty)
        #expect(config.reservedCapacity == 1024)
    }

    @Test
    func `Configuration.pretty properties`() {
        let config = HTML.Context.Configuration.pretty
        #expect(config.forceImportant == false)
        #expect(config.indentation == [.ascii.space, .ascii.space])
        #expect(config.newline == [.ascii.lf])
        #expect(config.reservedCapacity == 2048)
    }

    @Test
    func `Configuration.email properties`() {
        let config = HTML.Context.Configuration.email
        #expect(config.forceImportant == true)
        #expect(config.indentation == [.ascii.space])
        #expect(config.newline == [.ascii.lf])
        #expect(config.reservedCapacity == 2048)
    }

    @Test
    func `Configuration.optimized properties`() {
        let config = HTML.Context.Configuration.optimized
        #expect(config.forceImportant == false)
        #expect(config.indentation.isEmpty)
        #expect(config.newline.isEmpty)
        #expect(config.reservedCapacity == 4096)
    }

    // MARK: - Custom Initialization

    @Test
    func `Configuration custom initialization`() {
        let config = HTML.Context.Configuration(
            forceImportant: true,
            indentation: [.ascii.htab], // Tab
            newline: .ascii.crlf, // CRLF
            reservedCapacity: 8192
        )

        #expect(config.forceImportant == true)
        #expect(config.indentation == [.ascii.htab])
        #expect(config.newline == .ascii.crlf)
        #expect(config.reservedCapacity == 8192)
    }

    // MARK: - TaskLocal

    @Test
    func `Configuration TaskLocal current defaults to default`() {
        let current = HTML.Context.Configuration.current
        let defaultConfig = HTML.Context.Configuration.default
        #expect(current.forceImportant == defaultConfig.forceImportant)
        #expect(current.indentation == defaultConfig.indentation)
        #expect(current.newline == defaultConfig.newline)
        #expect(current.reservedCapacity == defaultConfig.reservedCapacity)
    }

    @Test
    func `Configuration TaskLocal withValue scoped`() throws {
        // Outside scope should use default
        #expect(HTML.Context.Configuration.current.forceImportant == false)

        HTML.Context.Configuration.$current.withValue(.email) {
            // Inside scope should use email config
            #expect(HTML.Context.Configuration.current.forceImportant == true)
        }

        // Outside scope should still use default
        #expect(HTML.Context.Configuration.current.forceImportant == false)
    }

    @Test
    func `Configuration TaskLocal affects rendering`() throws {
        let html = tag("div") {
            HTML.Text("Content")
        }
        .inlineStyle("color", "red")

        // Default rendering (no !important)
        let defaultRendered = try String(HTML.Document { html })
        #expect(defaultRendered.contains("color:red}"))
        #expect(!defaultRendered.contains("!important"))

        // Email rendering (with !important)
        let emailRendered: String = try HTML.Context.Configuration.$current.withValue(.email) {
            try String(HTML.Document { html })
        }
        #expect(emailRendered.contains("!important"))
    }

    // MARK: - Sendable

    @Test
    func `Configuration is Sendable`() async {
        let config = HTML.Context.Configuration.pretty

        let result = await Task {
            config.reservedCapacity
        }.value

        #expect(result == 2048)
    }

    // MARK: - Rendering Effects

    @Test
    func `Configuration.default produces minified output`() throws {
        let html = tag("div") {
            tag("p") {
                HTML.Text("Hello")
            }
        }

        let rendered = try String(html)
        // Minified should not have extra newlines between elements
        #expect(!rendered.contains("\n\n"))
    }

    @Test
    func `Configuration.pretty produces formatted output`() throws {
        let html = tag("div") {
            tag("p") {
                HTML.Text("Hello")
            }
        }

        let rendered: String = HTML.Context.Configuration.$current.withValue(.pretty) {
            try! String(html)
        }

        // Pretty should have newlines and indentation
        #expect(rendered.contains("\n"))
    }

    @Test
    func `Configuration.email adds important to styles`() throws {
        let html = tag("div") {
            HTML.Text("Content")
        }
        .inlineStyle("color", "blue")

        let rendered: String = try HTML.Context.Configuration.$current.withValue(.email) {
            try String(HTML.Document { html })
        }

        #expect(rendered.contains("!important"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLContextRenderingSnapshotTests {
        @Test
        func `Configuration.pretty rendering snapshot`() {
            HTML.Context.Configuration.$current.withValue(.pretty) {
                assertInlineSnapshot(
                    of: HTML.Document {
                        tag("main") {
                            tag("h1") {
                                HTML.Text("Pretty Printed")
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
                        <main>
                          <h1>Pretty Printed
                          </h1>
                        </main>
                      </body>
                    </html>
                    """
                }
            }
        }
    }
}

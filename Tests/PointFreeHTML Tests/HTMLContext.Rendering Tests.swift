//
//  HTMLContext.Rendering Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTMLContext.Rendering Tests")
struct HTMLContextRenderingTests {

    // MARK: - Preset Configurations

    @Test("Configuration.default properties")
    func defaultProperties() {
        let config = HTMLContext.Rendering.default
        #expect(config.forceImportant == false)
        #expect(config.indentation.isEmpty)
        #expect(config.newline.isEmpty)
        #expect(config.reservedCapacity == 1024)
    }

    @Test("Configuration.pretty properties")
    func prettyProperties() {
        let config = HTMLContext.Rendering.pretty
        #expect(config.forceImportant == false)
        #expect(config.indentation == [0x20, 0x20]) // Two spaces
        #expect(config.newline == [0x0A]) // LF
        #expect(config.reservedCapacity == 2048)
    }

    @Test("Configuration.email properties")
    func emailProperties() {
        let config = HTMLContext.Rendering.email
        #expect(config.forceImportant == true)
        #expect(config.indentation == [0x20]) // One space
        #expect(config.newline == [0x0A]) // LF
        #expect(config.reservedCapacity == 2048)
    }

    @Test("Configuration.optimized properties")
    func optimizedProperties() {
        let config = HTMLContext.Rendering.optimized
        #expect(config.forceImportant == false)
        #expect(config.indentation.isEmpty)
        #expect(config.newline.isEmpty)
        #expect(config.reservedCapacity == 4096)
    }

    // MARK: - Custom Initialization

    @Test("Configuration custom initialization")
    func customInitialization() {
        let config = HTMLContext.Rendering(
            forceImportant: true,
            indentation: [0x09], // Tab
            newline: [0x0D, 0x0A], // CRLF
            reservedCapacity: 8192
        )

        #expect(config.forceImportant == true)
        #expect(config.indentation == [0x09])
        #expect(config.newline == [0x0D, 0x0A])
        #expect(config.reservedCapacity == 8192)
    }

    // MARK: - TaskLocal

    @Test("Configuration TaskLocal current defaults to default")
    func taskLocalDefaultsToDefault() {
        let current = HTMLContext.Rendering.current
        let defaultConfig = HTMLContext.Rendering.default
        #expect(current.forceImportant == defaultConfig.forceImportant)
        #expect(current.indentation == defaultConfig.indentation)
        #expect(current.newline == defaultConfig.newline)
        #expect(current.reservedCapacity == defaultConfig.reservedCapacity)
    }

    @Test("Configuration TaskLocal withValue scoped")
    func taskLocalWithValueScoped() throws {
        // Outside scope should use default
        #expect(HTMLContext.Rendering.current.forceImportant == false)

        HTMLContext.Rendering.$current.withValue(.email) {
            // Inside scope should use email config
            #expect(HTMLContext.Rendering.current.forceImportant == true)
        }

        // Outside scope should still use default
        #expect(HTMLContext.Rendering.current.forceImportant == false)
    }

    @Test("Configuration TaskLocal affects rendering")
    func taskLocalAffectsRendering() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        .inlineStyle("color", "red")

        // Default rendering (no !important)
        let defaultRendered = try String(Document { html })
        #expect(defaultRendered.contains("color:red}"))
        #expect(!defaultRendered.contains("!important"))

        // Email rendering (with !important)
        let emailRendered: String = try HTMLContext.Rendering.$current.withValue(.email) {
            try String(Document { html })
        }
        #expect(emailRendered.contains("!important"))
    }

    // MARK: - Sendable

    @Test("Configuration is Sendable")
    func isSendable() async {
        let config = HTMLContext.Rendering.pretty

        let result = await Task {
            config.reservedCapacity
        }.value

        #expect(result == 2048)
    }

    // MARK: - Rendering Effects

    @Test("Configuration.default produces minified output")
    func defaultProducesMinifiedOutput() throws {
        let html = tag("div") {
            tag("p") {
                HTMLText("Hello")
            }
        }

        let rendered = try String(html)
        // Minified should not have extra newlines between elements
        #expect(!rendered.contains("\n\n"))
    }

    @Test("Configuration.pretty produces formatted output")
    func prettyProducesFormattedOutput() throws {
        let html = tag("div") {
            tag("p") {
                HTMLText("Hello")
            }
        }

        let rendered: String = HTMLContext.Rendering.$current.withValue(.pretty) {
            try! String(html)
        }

        // Pretty should have newlines and indentation
        #expect(rendered.contains("\n"))
    }

    @Test("Configuration.email adds important to styles")
    func emailAddsImportantToStyles() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        .inlineStyle("color", "blue")

        let rendered: String = try HTMLContext.Rendering.$current.withValue(.email) {
            try String(Document { html })
        }

        #expect(rendered.contains("!important"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLContextRenderingSnapshotTests {
        @Test("Configuration.pretty rendering snapshot")
        func prettyRenderingSnapshot() {
            HTMLContext.Rendering.$current.withValue(.pretty) {
                assertInlineSnapshot(
                    of: Document {
                        tag("main") {
                            tag("h1") {
                                HTMLText("Pretty Printed")
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

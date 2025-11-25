//
//  HTMLPrinter.Configuration Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("HTMLPrinter.Configuration Tests")
struct HTMLPrinterConfigurationTests {

    // MARK: - Preset Configurations

    @Test("Configuration.default properties")
    func defaultProperties() {
        let config = HTMLPrinter.Configuration.default
        #expect(config.forceImportant == false)
        #expect(config.indentation.isEmpty)
        #expect(config.newline.isEmpty)
        #expect(config.reservedCapacity == 1024)
    }

    @Test("Configuration.pretty properties")
    func prettyProperties() {
        let config = HTMLPrinter.Configuration.pretty
        #expect(config.forceImportant == false)
        #expect(config.indentation == [0x20, 0x20]) // Two spaces
        #expect(config.newline == [0x0A]) // LF
        #expect(config.reservedCapacity == 2048)
    }

    @Test("Configuration.email properties")
    func emailProperties() {
        let config = HTMLPrinter.Configuration.email
        #expect(config.forceImportant == true)
        #expect(config.indentation == [0x20]) // One space
        #expect(config.newline == [0x0A]) // LF
        #expect(config.reservedCapacity == 2048)
    }

    @Test("Configuration.optimized properties")
    func optimizedProperties() {
        let config = HTMLPrinter.Configuration.optimized
        #expect(config.forceImportant == false)
        #expect(config.indentation.isEmpty)
        #expect(config.newline.isEmpty)
        #expect(config.reservedCapacity == 4096)
    }

    // MARK: - Custom Initialization

    @Test("Configuration custom initialization")
    func customInitialization() {
        let config = HTMLPrinter.Configuration(
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
        let current = HTMLPrinter.Configuration.current
        let defaultConfig = HTMLPrinter.Configuration.default
        #expect(current.forceImportant == defaultConfig.forceImportant)
        #expect(current.indentation == defaultConfig.indentation)
        #expect(current.newline == defaultConfig.newline)
        #expect(current.reservedCapacity == defaultConfig.reservedCapacity)
    }

    @Test("Configuration TaskLocal withValue scoped")
    func taskLocalWithValueScoped() throws {
        // Outside scope should use default
        #expect(HTMLPrinter.Configuration.current.forceImportant == false)

        HTMLPrinter.Configuration.$current.withValue(.email) {
            // Inside scope should use email config
            #expect(HTMLPrinter.Configuration.current.forceImportant == true)
        }

        // Outside scope should still use default
        #expect(HTMLPrinter.Configuration.current.forceImportant == false)
    }

    @Test("Configuration TaskLocal affects rendering")
    func taskLocalAffectsRendering() throws {
        let html = tag("div") {
            HTMLText("Content")
        }
        .inlineStyle("color", "red")

        // Default rendering (no !important)
        let defaultRendered = try String(HTMLDocument { html })
        #expect(defaultRendered.contains("color:red}"))
        #expect(!defaultRendered.contains("!important"))

        // Email rendering (with !important)
        let emailRendered: String = try HTMLPrinter.Configuration.$current.withValue(.email) {
            try String(HTMLDocument { html })
        }
        #expect(emailRendered.contains("!important"))
    }

    // MARK: - Sendable

    @Test("Configuration is Sendable")
    func isSendable() async {
        let config = HTMLPrinter.Configuration.pretty

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

        let rendered: String = HTMLPrinter.Configuration.$current.withValue(.pretty) {
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

        let rendered: String = try HTMLPrinter.Configuration.$current.withValue(.email) {
            try String(HTMLDocument { html })
        }

        #expect(rendered.contains("!important"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLPrinterConfigurationSnapshotTests {
        @Test("Configuration.pretty rendering snapshot")
        func prettyRenderingSnapshot() {
            HTMLPrinter.Configuration.$current.withValue(.pretty) {
                assertInlineSnapshot(
                    of: HTMLDocument {
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
                        <style>

                        </style>
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

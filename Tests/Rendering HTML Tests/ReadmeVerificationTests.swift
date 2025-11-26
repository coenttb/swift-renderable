@testable import Rendering_HTML
import Testing

@Suite
struct `README Verification Tests` {

    // MARK: - README Lines 22-35: Basic Usage

    @Test
    func `README Basic Usage: Greeting component`() throws {
        struct Greeting: HTML.View {
            let name: String
            var body: some HTML.View {
                tag("h1") { "Hello, \(name)!" }
            }
        }

        let greeting = Greeting(name: "World")
        let htmlString: String = try String(greeting)
        let htmlBytes: ContiguousArray = .init(greeting)

        // Verify the rendered HTML contains expected content
        #expect(htmlString.contains("Hello, World!"))
        #expect(htmlString.contains("<h1>"))
        #expect(!htmlBytes.isEmpty)
    }

    // MARK: - README Lines 53-67: Swift-HTML Integration (PointFreeHTML APIs)

    @Test
    func `README Swift-HTML Integration: PointFreeHTML APIs`() {
        struct StyledComponent: HTML.View {
            var body: some HTML.View {
                tag("div") {
                    tag("a") { "Styled Heading" }
                        .attribute("href", "#")
                        .inlineStyle("color", "blue")
                        .inlineStyle("font-size", "24px")
                        .inlineStyle("margin-bottom", "16px")
                }
            }
        }

        let component = StyledComponent()
        let html = try! String(component)

        // Verify structure
        #expect(html.contains("Styled Heading"))
        #expect(html.contains("href=\"#\""))
    }

    // MARK: - README Lines 73-89: Server Integration

    @Test
    func `README Server Integration: Greeting route logic`() throws {
        // Simulate the route logic without Vapor
        let name = "TestUser"

        struct Greeting: HTML.View {
            let name: String
            var body: some HTML.View {
                tag("h1") { "Hello, \(name)!" }
            }
        }

        let response = try String(Greeting(name: name))

        #expect(response.contains("Hello, TestUser!"))
        #expect(response.contains("<h1>"))
    }

    // MARK: - Core API Tests

    @Test
    func `README Core: HTML protocol conformance`() {
        struct CustomComponent: HTML.View {
            var body: some HTML.View {
                tag("div") { "Content" }
            }
        }

        let component = CustomComponent()
        let html = try! String(component)

        #expect(html.contains("Content"))
        #expect(html.contains("<div>"))
    }

    @Test
    func `README Core: tag function`() {
        let element = tag("p") { "Paragraph text" }
        let html = try! String(element)

        #expect(html.contains("Paragraph text"))
        #expect(html.contains("<p>"))
    }

    @Test
    func `README Core: String rendering`() throws {
        struct Simple: HTML.View {
            var body: some HTML.View {
                tag("span") { "Test" }
            }
        }

        let html = try String(Simple())
        #expect(html.contains("Test"))
    }

    @Test
    func `README Core: Bytes rendering`() {
        struct Simple: HTML.View {
            var body: some HTML.View {
                tag("span") { "Test" }
            }
        }

        let bytes = ContiguousArray(Simple())
        #expect(!bytes.isEmpty)

        // Verify we can convert back to string
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("Test") == true)
    }

    @Test
    func `README Core: Nested components`() {
        struct Inner: HTML.View {
            var body: some HTML.View {
                tag("span") { "Inner" }
            }
        }

        struct Outer: HTML.View {
            var body: some HTML.View {
                tag("div") {
                    Inner()
                }
            }
        }

        let html = try! String(Outer())
        #expect(html.contains("Inner"))
        #expect(html.contains("<div>"))
        #expect(html.contains("<span>"))
    }

    @Test
    func `README Core: HTMLBuilder result builder`() {
        struct MultiElement: HTML.View {
            var body: some HTML.View {
                tag("div") {
                    tag("h1") { "Title" }
                    tag("p") { "Paragraph" }
                }
            }
        }

        let html = try! String(MultiElement())
        #expect(html.contains("Title"))
        #expect(html.contains("Paragraph"))
        #expect(html.contains("<h1>"))
        #expect(html.contains("<p>"))
    }

    @Test
    func `README Core: String interpolation in HTML content`() {
        struct Interpolated: HTML.View {
            let value: String
            var body: some HTML.View {
                tag("p") { "Value: \(value)" }
            }
        }

        let html = try! String(Interpolated(value: "test123"))
        #expect(html.contains("Value: test123"))
    }

    @Test
    func `README Core: Attribute method`() {
        let element = tag("a") { "Link" }
            .attribute("href", "https://example.com")
            .attribute("target", "_blank")

        let html = try! String(element)
        #expect(html.contains("href=\"https://example.com\""))
        #expect(html.contains("target=\"_blank\""))
    }

    @Test
    func `README Core: Inline style method`() {
        let element = tag("div") { "Styled" }
            .inlineStyle("color", "red")
            .inlineStyle("font-size", "16px")

        let html = try! String(element)
        #expect(html.contains("Styled"))
    }
}

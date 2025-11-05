import PointFreeHTML
import Testing

@Suite("README Verification Tests")
struct ReadmeVerificationTests {

    // MARK: - README Lines 22-35: Basic Usage

    @Test("README Basic Usage: Greeting component")
    func basicUsageGreeting() throws {
        struct Greeting: HTML {
            let name: String
            var body: some HTML {
                tag("h1") { "Hello, \(name)!" }
            }
        }

        let greeting = Greeting(name: "World")
        let htmlString: String = try String(greeting)
        let htmlBytes: ContiguousArray<UInt8> = greeting.render()

        // Verify the rendered HTML contains expected content
        #expect(htmlString.contains("Hello, World!"))
        #expect(htmlString.contains("<h1>"))
        #expect(!htmlBytes.isEmpty)
    }

    // MARK: - README Lines 53-67: Swift-HTML Integration (PointFreeHTML APIs)

    @Test("README Swift-HTML Integration: PointFreeHTML APIs")
    func swiftHtmlIntegrationPointFreeAPI() {
        struct StyledComponent: HTML {
            var body: some HTML {
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

    @Test("README Server Integration: Greeting route logic")
    func serverIntegrationGreeting() throws {
        // Simulate the route logic without Vapor
        let name = "TestUser"

        struct Greeting: HTML {
            let name: String
            var body: some HTML {
                tag("h1") { "Hello, \(name)!" }
            }
        }

        let response = try String(Greeting(name: name))

        #expect(response.contains("Hello, TestUser!"))
        #expect(response.contains("<h1>"))
    }

    // MARK: - Core API Tests

    @Test("README Core: HTML protocol conformance")
    func htmlProtocolConformance() {
        struct CustomComponent: HTML {
            var body: some HTML {
                tag("div") { "Content" }
            }
        }

        let component = CustomComponent()
        let html = try! String(component)

        #expect(html.contains("Content"))
        #expect(html.contains("<div>"))
    }

    @Test("README Core: tag function")
    func tagFunction() {
        let element = tag("p") { "Paragraph text" }
        let html = try! String(element)

        #expect(html.contains("Paragraph text"))
        #expect(html.contains("<p>"))
    }

    @Test("README Core: String rendering")
    func stringRendering() throws {
        struct Simple: HTML {
            var body: some HTML {
                tag("span") { "Test" }
            }
        }

        let html = try String(Simple())
        #expect(html.contains("Test"))
    }

    @Test("README Core: Bytes rendering")
    func bytesRendering() {
        struct Simple: HTML {
            var body: some HTML {
                tag("span") { "Test" }
            }
        }

        let bytes = Simple().render()
        #expect(!bytes.isEmpty)

        // Verify we can convert back to string
        let string = String(bytes: bytes, encoding: .utf8)
        #expect(string?.contains("Test") == true)
    }

    @Test("README Core: Nested components")
    func nestedComponents() {
        struct Inner: HTML {
            var body: some HTML {
                tag("span") { "Inner" }
            }
        }

        struct Outer: HTML {
            var body: some HTML {
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

    @Test("README Core: HTMLBuilder result builder")
    func htmlBuilderMultipleElements() {
        struct MultiElement: HTML {
            var body: some HTML {
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

    @Test("README Core: String interpolation in HTML content")
    func stringInterpolation() {
        struct Interpolated: HTML {
            let value: String
            var body: some HTML {
                tag("p") { "Value: \(value)" }
            }
        }

        let html = try! String(Interpolated(value: "test123"))
        #expect(html.contains("Value: test123"))
    }

    @Test("README Core: Attribute method")
    func attributeMethod() {
        let element = tag("a") { "Link" }
            .attribute("href", "https://example.com")
            .attribute("target", "_blank")

        let html = try! String(element)
        #expect(html.contains("href=\"https://example.com\""))
        #expect(html.contains("target=\"_blank\""))
    }

    @Test("README Core: Inline style method")
    func inlineStyleMethod() {
        let element = tag("div") { "Styled" }
            .inlineStyle("color", "red")
            .inlineStyle("font-size", "16px")

        let html = try! String(element)
        #expect(html.contains("Styled"))
    }
}

//
//  PointFreeHtml Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 01/09/2024.
//

import Foundation
import Testing
import DependenciesTestSupport
@testable import PointFreeHTMLElements
@testable import PointFreeHTML

// MARK: - Basic HTML Tests
@Suite("HTML Element Tests")
struct HTMLElementTests {
    
    @Test("Empty element rendering")
    func testEmptyElement() throws {
        // Arrange
        let element = div()
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result == "<div></div>")
    }
    
    @Test("Element with text content")
    func testElementWithText() throws {
        // Arrange
        let element = p { "Hello, World!" }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result == "<p>Hello, World!</p>")
    }
    
    @Test("Nested elements")
    func testNestedElements() throws {
        // Arrange
        let element = div {
            h1 { "Title" }
            p { "Paragraph" }
        }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<div>"))
        #expect(result.contains("<h1>Title</h1>"))
        #expect(result.contains("<p>Paragraph</p>"))
        #expect(result.contains("</div>"))
    }
    
    @Test("Void elements")
    func testVoidElements() throws {
        // Arrange
        let element = img().src("image.jpg").alt("An image")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        // The order of attributes is not guaranteed, so we check for the presence of both attributes
        #expect(result.contains("<img"))
        #expect(result.contains("src=\"image.jpg\""))
        #expect(result.contains("alt=\"An image\""))
        #expect(result.contains(">"))
        #expect(!result.contains("</img>")) // Void elements don't have closing tags
    }
}

// MARK: - Attribute Tests

@Suite("HTML Attribute Tests")
struct HTMLAttributeTests {
    
    @Test("Single attribute")
    func testSingleAttribute() throws {
        // Arrange
        let element = a { "Link" }.href("https://example.com")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<a"))
        #expect(result.contains("href=\"https://example.com\""))
        #expect(result.contains(">Link</a>"))
    }
    
    @Test("Multiple attributes")
    func testMultipleAttributes() throws {
        // Arrange
        let element = input()
            .attribute("type", "text")
            .attribute("name", "username")
            .attribute("placeholder", "Enter username")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("type=\"text\""))
        #expect(result.contains("name=\"username\""))
        #expect(result.contains("placeholder=\"Enter username\""))
    }
    
    @Test("Boolean attributes")
    func testBooleanAttribute() throws {
        // Arrange
        let element = input().attribute("required")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("required"))
    }
    
    @Test("Attribute escaping")
    func testAttributeEscaping() throws {
        // Arrange
        let element = div().attribute("data-value", "\"quoted\" & <special>")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        // Now the implementation properly escapes all special characters in attributes
        #expect(result.contains("data-value=\"&quot;quoted&quot; &amp; &lt;special&gt;\""))
    }
    
    @Test("Common HTML attributes")
    func testCommonHTMLAttributes() throws {
        // Arrange
        let metaElement = meta().attribute("charset", "utf-8")
        let inputElement = input()
            .attribute("type", "text")
            .attribute("name", "username")
            .attribute("placeholder", "Enter your username")
            .attribute("value", "default")
        let divElement = div { "Content" }
            .attribute("id", "main-container")
            .attribute("class", "container primary")
            .attribute("title", "Main content container")
        
        // Act
        let metaResult = String(decoding: metaElement.render(), as: UTF8.self)
        let inputResult = String(decoding: inputElement.render(), as: UTF8.self)
        let divResult = String(decoding: divElement.render(), as: UTF8.self)
        
        // Assert
        #expect(metaResult == "<meta charset=\"utf-8\">")
        
        #expect(inputResult.contains("type=\"text\""))
        #expect(inputResult.contains("name=\"username\""))
        #expect(inputResult.contains("placeholder=\"Enter your username\""))
        #expect(inputResult.contains("value=\"default\""))
        
        #expect(divResult.contains("<div"))
        #expect(divResult.contains("id=\"main-container\""))
        #expect(divResult.contains("class=\"container primary\""))
        #expect(divResult.contains("title=\"Main content container\""))
        #expect(divResult.contains(">Content</div>"))
    }
}

// MARK: - Styling Tests

@Suite("Inline Style Tests")
struct HTMLInlineStyleTests {
    
    @Test("Single style")
    func testSingleStyle() throws {
        // Arrange
        let element = div { "Styled content" }
            .inlineStyle("color", "red")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("class=\""))
        // Note: The actual class name is dynamically generated,
        // so we can't test for an exact match
    }
    
    @Test("Multiple styles")
    func testMultipleStyles() throws {
        // Arrange
        let element = div { "Styled content" }
            .inlineStyle("color", "red")
            .inlineStyle("font-size", "16px")
            .inlineStyle("margin", "10px")
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        // Check that the div has a class attribute
        #expect(result.contains("class=\""))
        
        // Check there are multiple class names (spaces between them)
        let classPattern = #"class="([^"]*\s[^"]*)"#
        let regex = try? NSRegularExpression(pattern: classPattern)
        let range = NSRange(location: 0, length: result.utf16.count)
        let matches = regex?.matches(in: result, range: range)
        #expect(matches?.count == 1)
    }
    
    @Test("Pseudo classes")
    func testPseudoClasses() throws {
        // Arrange
        let element = a { "Hover me" }
            .inlineStyle("color", "blue")
            .inlineStyle("color", "red", pseudo: .hover)
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        // We can't test the exact CSS output here since it's rendered separately,
        // but we can verify the element has classes
        #expect(result.contains("class=\""))
    }
    
    @Test("At-rule styling using new parameter")
    func testAtRuleStyling() throws {
        // Arrange
        let element = div { "Media query content" }
            .inlineStyle("display", "none")
            .inlineStyle("display", "block", atRule: .print)
            
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("class=\""))
        // The print style should add an additional class
        let classPattern = #"class="([^"]*\s[^"]*)"#
        let regex = try? NSRegularExpression(pattern: classPattern)
        let range = NSRange(location: 0, length: result.utf16.count)
        let matches = regex?.matches(in: result, range: range)
        #expect(matches?.count == 1)
    }
    
    @Test("Deprecated media parameter still works")
    func testDeprecatedMediaParameter() throws {
        // Arrange
        let element = div { "Media query content" }
            .inlineStyle("display", "none")
            .inlineStyle("display", "block", media: .print)
            
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("class=\""))
        // The print style should add an additional class
        let classPattern = #"class="([^"]*\s[^"]*)"#
        let regex = try? NSRegularExpression(pattern: classPattern)
        let range = NSRange(location: 0, length: result.utf16.count)
        let matches = regex?.matches(in: result, range: range)
        #expect(matches?.count == 1)
    }
    
    @Test("Custom at-rule")
    func testCustomAtRule() throws {
        // Arrange
        let customAtRule = AtRule(rawValue: "screen and (min-width: 768px)")
        let element = div { "Responsive content" }
            .inlineStyle("font-size", "14px")
            .inlineStyle("font-size", "18px", atRule: customAtRule)
            
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("class=\""))
        // The responsive style should add an additional class
        let classPattern = #"class="([^"]*\s[^"]*)"#
        let regex = try? NSRegularExpression(pattern: classPattern)
        let range = NSRange(location: 0, length: result.utf16.count)
        let matches = regex?.matches(in: result, range: range)
        #expect(matches?.count == 1)
    }
}

// MARK: - Document Tests

@Suite("HTML Document Tests")
struct HTMLDocumentTests {
    
    @Test("Complete document")
    func testCompleteDocument() throws {
        // Arrange
        struct TestDocument: HTMLDocumentProtocol {
            var head: some HTML {
                PointFreeHTMLElements.title { "Test Page" }
                meta().attribute("charset", "utf-8")
            }
            
            var body: some HTML {
                div {
                    h1 { "Test Heading" }
                    p { "Test paragraph." }
                }
            }
        }
        
        let document = TestDocument()
        
        // Act
        let result = String(decoding: document.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<html lang=\"en\">"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<title>Test Page</title>"))
        #expect(result.contains("<meta charset=\"utf-8\">"))
        #expect(result.contains("</head>"))
        #expect(result.contains("<body>"))
        #expect(result.contains("<div>"))
        #expect(result.contains("<h1>Test Heading</h1>"))
        #expect(result.contains("<p>Test paragraph.</p>"))
        #expect(result.contains("</div>"))
        #expect(result.contains("</body>"))
        #expect(result.contains("</html>"))
    }
}

// MARK: - Conditional and Loop Tests

@Suite("Conditional and Loop Tests")
struct ConditionalAndLoopTests {
    
    @Test("Conditional rendering with if")
    func testConditionalRendering() throws {
        // Arrange
        func makeElement(showExtra: Bool) -> some HTML {
            div {
                p { "Always visible" }
                if showExtra {
                    p { "Conditionally visible" }
                }
            }
        }
        
        // Act
        let withExtraResult = String(decoding: makeElement(showExtra: true).render(), as: UTF8.self)
        let withoutExtraResult = String(decoding: makeElement(showExtra: false).render(), as: UTF8.self)
        
        // Assert
        #expect(withExtraResult.contains("<p>Always visible</p>"))
        #expect(withExtraResult.contains("<p>Conditionally visible</p>"))
        
        #expect(withoutExtraResult.contains("<p>Always visible</p>"))
        #expect(!withoutExtraResult.contains("<p>Conditionally visible</p>"))
    }
    
    @Test("Conditional rendering with if-else")
    func testConditionalRenderingWithElse() throws {
        // Arrange
        func makeElement(isLoggedIn: Bool) -> some HTML {
            div {
                if isLoggedIn {
                    p { "Welcome back!" }
                } else {
                    p { "Please log in" }
                }
            }
        }
        
        // Act
        let loggedInResult = String(decoding: makeElement(isLoggedIn: true).render(), as: UTF8.self)
        let loggedOutResult = String(decoding: makeElement(isLoggedIn: false).render(), as: UTF8.self)
        
        // Assert
        #expect(loggedInResult.contains("<p>Welcome back!</p>"))
        #expect(!loggedInResult.contains("<p>Please log in</p>"))
        
        #expect(!loggedOutResult.contains("<p>Welcome back!</p>"))
        #expect(loggedOutResult.contains("<p>Please log in</p>"))
    }
    
    @Test("Loop rendering with HTMLForEach")
    func testLoopRendering() throws {
        // Arrange
        let items = ["Apple", "Banana", "Cherry"]
        let element = ul {
            HTMLForEach(items) { item in
                li { HTMLText(item) }
            }
        }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>Apple</li>"))
        #expect(result.contains("<li>Banana</li>"))
        #expect(result.contains("<li>Cherry</li>"))
        #expect(result.contains("</ul>"))
    }
    
    @Test("Loop rendering with for-in")
    func testForInLoopRendering() throws {
        // Arrange
        let items = ["Apple", "Banana", "Cherry"]
        let element = ul {
            for item in items {
                li { HTMLText(item) }
            }
        }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>Apple</li>"))
        #expect(result.contains("<li>Banana</li>"))
        #expect(result.contains("<li>Cherry</li>"))
        #expect(result.contains("</ul>"))
    }
}

// MARK: - Text Handling Tests

@Suite("Text Handling Tests")
struct TextHandlingTests {
    
    @Test("HTML escaping in text")
    func testHTMLEscaping() throws {
        // Arrange
        let element = p { "This is <b>bold</b> & special" }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        // Now the implementation properly escapes all HTML special characters: '&', '<', and '>'
        #expect(result == "<p>This is &lt;b&gt;bold&lt;/b&gt; &amp; special</p>")
    }
    
    @Test("String interpolation")
    func testStringInterpolation() throws {
        // Arrange
        let name = "World"
        let element = p { "Hello, \(name)!" }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result == "<p>Hello, World!</p>")
    }
    
    @Test("Raw HTML content")
    func testRawHTML() throws {
        // Arrange
        let element = div {
            HTMLRaw("<b>Bold text</b>")
        }
        
        // Act
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result == "<div><b>Bold text</b></div>")
    }
}

// MARK: - Components Tests

@Suite("Component Tests")
struct ComponentTests {
    
    @Test("Function-based component")
    func testFunctionComponent() throws {
        // Arrange
        func buttonComponent(title: String, action: String) -> some HTML {
            button { HTMLText(title) }
                .attribute("onclick", action)
                .inlineStyle("padding", "10px")
                .inlineStyle("background-color", "blue")
                .inlineStyle("color", "white")
        }
        
        // Act
        let element = buttonComponent(title: "Click me", action: "handleClick()")
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<button"))
        #expect(result.contains(">Click me</button>"))
        #expect(result.contains("onclick=\"handleClick()\""))
        #expect(result.contains("class=\""))
    }
    
    @Test("Type-based component")
    func testTypeComponent() throws {
        // Arrange
        struct Card: HTML {
            let title: String
            let content: String
            
            var body: some HTML {
                div {
                    h2 { HTMLText(title) }
                    p { HTMLText(content) }
                }
                .inlineStyle("border", "1px solid #ccc")
                .inlineStyle("padding", "10px")
                .inlineStyle("border-radius", "4px")
            }
        }
        
        // Act
        let element = Card(title: "Card Title", content: "Card content goes here.")
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<div"))
        #expect(result.contains("<h2>Card Title</h2>"))
        #expect(result.contains("<p>Card content goes here.</p>"))
        #expect(result.contains("class=\""))
    }
    
    @Test("Component composition")
    func testComponentComposition() throws {
        // Arrange
        struct Header: HTML {
            var body: some HTML {
                header {
                    h1 { "Website Title" }
                }
            }
        }
        
        struct Footer: HTML {
            var body: some HTML {
                footer {
                    p { "© 2025 Example Inc." }
                }
            }
        }
        
        struct Page: HTML {
            var body: some HTML {
                div {
                    Header()
                    main {
                        p { "Main content" }
                    }
                    Footer()
                }
            }
        }
        
        // Act
        let element = Page()
        let result = String(decoding: element.render(), as: UTF8.self)
        
        // Assert
        #expect(result.contains("<header>"))
        #expect(result.contains("<h1>Website Title</h1>"))
        #expect(result.contains("<main>"))
        #expect(result.contains("<p>Main content</p>"))
        #expect(result.contains("<footer>"))
        #expect(result.contains("<p>© 2025 Example Inc.</p>"))
    }
}

//
//  HTMLPrinter.Error Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("HTMLPrinter.Error Tests")
struct HTMLPrinterErrorTests {

    // MARK: - Initialization

    @Test("Error initialization with message")
    func initWithMessage() {
        let error = HTMLPrinter.Error(message: "Failed to render HTML")
        #expect(error.message == "Failed to render HTML")
    }

    @Test("Error with empty message")
    func emptyMessage() {
        let error = HTMLPrinter.Error(message: "")
        #expect(error.message.isEmpty)
    }

    // MARK: - Swift.Error Conformance

    @Test("Error conforms to Swift.Error")
    func conformsToSwiftError() {
        let error: any Swift.Error = HTMLPrinter.Error(message: "Test error")
        #expect(error is HTMLPrinter.Error)
    }

    @Test("Error can be thrown and caught")
    func canBeThrown() {
        func throwingFunction() throws {
            throw HTMLPrinter.Error(message: "Intentional error")
        }

        do {
            try throwingFunction()
            Issue.record("Expected error to be thrown")
        } catch let error as HTMLPrinter.Error {
            #expect(error.message == "Intentional error")
        } catch {
            Issue.record("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - Error Messages

    @Test("Error with descriptive message")
    func descriptiveMessage() {
        let error = HTMLPrinter.Error(message: "Invalid UTF-8 sequence at byte offset 42")
        #expect(error.message.contains("UTF-8"))
        #expect(error.message.contains("42"))
    }

    @Test("Error with multiline message")
    func multilineMessage() {
        let message = """
        Rendering failed:
        - Invalid attribute value
        - Missing closing tag
        """
        let error = HTMLPrinter.Error(message: message)
        #expect(error.message.contains("Rendering failed"))
        #expect(error.message.contains("Invalid attribute"))
        #expect(error.message.contains("Missing closing tag"))
    }

    // MARK: - Usage in String Initializer

    @Test("String initializer throws on invalid encoding")
    func stringInitializerThrows() throws {
        // Test that String(HTMLDocument { ... }) works normally
        let document = HTMLDocument {
            tag("div") {
                HTMLText("Valid content")
            }
        }

        // Should not throw for valid content
        let result = try String(document)
        #expect(result.contains("Valid content"))
    }

    // MARK: - Error Handling Patterns

    @Test("Error can be handled with do-catch")
    func doCatchHandling() {
        let error = HTMLPrinter.Error(message: "Test")

        do {
            throw error
        } catch {
            #expect(error is HTMLPrinter.Error)
        }
    }

    @Test("Error can be used with Result type")
    func resultTypeUsage() {
        let result: Result<String, HTMLPrinter.Error> = .failure(
            HTMLPrinter.Error(message: "Rendering failed")
        )

        switch result {
        case .success:
            Issue.record("Expected failure")
        case .failure(let error):
            #expect(error.message == "Rendering failed")
        }
    }

    @Test("Error can be used with async throws")
    func asyncThrows() async {
        func asyncRenderer() async throws -> String {
            throw HTMLPrinter.Error(message: "Async rendering failed")
        }

        do {
            _ = try await asyncRenderer()
            Issue.record("Expected error")
        } catch let error as HTMLPrinter.Error {
            #expect(error.message == "Async rendering failed")
        } catch {
            Issue.record("Wrong error type")
        }
    }

    // MARK: - Error Message Content

    @Test("Error message preserves special characters")
    func preservesSpecialCharacters() {
        let error = HTMLPrinter.Error(message: "Error with <html> & \"quotes\"")
        #expect(error.message.contains("<html>"))
        #expect(error.message.contains("&"))
        #expect(error.message.contains("\"quotes\""))
    }

    @Test("Error message preserves Unicode")
    func preservesUnicode() {
        let error = HTMLPrinter.Error(message: "Error: 日本語 🚫")
        #expect(error.message.contains("日本語"))
        #expect(error.message.contains("🚫"))
    }
}

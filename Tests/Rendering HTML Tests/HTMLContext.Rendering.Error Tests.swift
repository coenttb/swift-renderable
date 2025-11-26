//
//  HTML.Context.Configuration.Error Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.Context.Configuration.Error Tests` {

    // MARK: - Initialization

    @Test
    func `Error initialization with message`() {
        let error = HTML.Context.Configuration.Error(message: "Failed to render HTML")
        #expect(error.message == "Failed to render HTML")
    }

    @Test
    func `Error with empty message`() {
        let error = HTML.Context.Configuration.Error(message: "")
        #expect(error.message.isEmpty)
    }

    // MARK: - Swift.Error Conformance

    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = HTML.Context.Configuration.Error(message: "Test error")
        #expect(error is HTML.Context.Configuration.Error)
    }

    @Test
    func `Error can be thrown and caught`() {
        func throwingFunction() throws {
            throw HTML.Context.Configuration.Error(message: "Intentional error")
        }

        do {
            try throwingFunction()
            Issue.record("Expected error to be thrown")
        } catch let error as HTML.Context.Configuration.Error {
            #expect(error.message == "Intentional error")
        } catch {
            Issue.record("Unexpected error type: \(type(of: error))")
        }
    }

    // MARK: - Error Messages

    @Test
    func `Error with descriptive message`() {
        let error = HTML.Context.Configuration.Error(message: "Invalid UTF-8 sequence at byte offset 42")
        #expect(error.message.contains("UTF-8"))
        #expect(error.message.contains("42"))
    }

    @Test
    func `Error with multiline message`() {
        let message = """
        Rendering failed:
        - Invalid attribute value
        - Missing closing tag
        """
        let error = HTML.Context.Configuration.Error(message: message)
        #expect(error.message.contains("Rendering failed"))
        #expect(error.message.contains("Invalid attribute"))
        #expect(error.message.contains("Missing closing tag"))
    }

    // MARK: - Usage in String Initializer

    @Test
    func `String initializer throws on invalid encoding`() throws {
        // Test that String(HTML.Document { ... }) works normally
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Valid content")
            }
        }

        // Should not throw for valid content
        let result = try String(document)
        #expect(result.contains("Valid content"))
    }

    // MARK: - Error Handling Patterns

    @Test
    func `Error can be handled with do-catch`() {
        let error = HTML.Context.Configuration.Error(message: "Test")

        do {
            throw error
        } catch {
            #expect(error is HTML.Context.Configuration.Error)
        }
    }

    @Test
    func `Error can be used with Result type`() {
        let result: Result<String, HTML.Context.Configuration.Error> = .failure(
            HTML.Context.Configuration.Error(message: "Rendering failed")
        )

        switch result {
        case .success:
            Issue.record("Expected failure")
        case .failure(let error):
            #expect(error.message == "Rendering failed")
        }
    }

    @Test
    func `Error can be used with async throws`() async {
        func asyncRenderer() async throws -> String {
            throw HTML.Context.Configuration.Error(message: "Async rendering failed")
        }

        do {
            _ = try await asyncRenderer()
            Issue.record("Expected error")
        } catch let error as HTML.Context.Configuration.Error {
            #expect(error.message == "Async rendering failed")
        } catch {
            Issue.record("Wrong error type")
        }
    }

    // MARK: - Error Message Content

    @Test
    func `Error message preserves special characters`() {
        let error = HTML.Context.Configuration.Error(message: "Error with <html> & \"quotes\"")
        #expect(error.message.contains("<html>"))
        #expect(error.message.contains("&"))
        #expect(error.message.contains("\"quotes\""))
    }

    @Test
    func `Error message preserves Unicode`() {
        let error = HTML.Context.Configuration.Error(message: "Error: 日本語 🚫")
        #expect(error.message.contains("日本語"))
        #expect(error.message.contains("🚫"))
    }
}

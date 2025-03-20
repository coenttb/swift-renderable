//
//  HTMLDocument.swift
//
//
//  Created by Point-Free, Inc
//

import Dependencies

/// A protocol representing a complete HTML document.
///
/// The `HTMLDocument` protocol extends `HTML` to specifically represent
/// a complete HTML document with both head and body sections. This allows
/// for structured creation of full HTML pages with proper doctype, head
/// metadata, and body content.
///
/// Example:
/// ```swift
/// struct MyDocument: HTMLDocument {
///     var head: some HTML {
///         title { "My Web Page" }
///         meta().charset("utf-8")
///         meta().name("viewport").content("width=device-width, initial-scale=1")
///     }
///
///     var body: some HTML {
///         div {
///             h1 { "Welcome to My Website" }
///             p { "This is a complete HTML document." }
///         }
///     }
/// }
/// ```
public protocol HTMLDocument: HTML {
    /// The type of HTML content for the document's head section.
    associatedtype Head: HTML
    
    /// The head section of the HTML document.
    ///
    /// This property defines metadata, title, stylesheets, scripts, and other
    /// elements that should appear in the document's head section.
    @HTMLBuilder
    var head: Head { get }
}

extension HTMLDocument {
    /// Renders the HTML document into the provided printer.
    ///
    /// This method orchestrates the rendering of a complete HTML document:
    /// 1. First renders the body content into a separate printer
    /// 2. Extracts any collected stylesheets from the body rendering
    /// 3. Creates a complete document with doctype, html, head, and body elements
    /// 4. Renders the complete document into the provided printer
    ///
    /// - Parameters:
    ///   - html: The HTML document to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        @Dependency(\.htmlPrinter) var htmlPrinter
        var bodyPrinter = htmlPrinter
        Content._render(html.body, into: &bodyPrinter)
        Document
            ._render(
                Document(head: html.head, stylesheet: bodyPrinter.stylesheet, bodyBytes: bodyPrinter.bytes),
                into: &printer
            )
    }
}

/// A private implementation of an HTML document.
///
/// This struct assembles the different parts of an HTML document (head, stylesheet, body)
/// into a complete HTML document with proper structure.
private struct Document<Head: HTML>: HTML {
    /// The head content for the document.
    let head: Head
    
    /// Collected stylesheet content to be included in the document head.
    let stylesheet: String
    
    /// Pre-rendered bytes for the document body.
    let bodyBytes: ContiguousArray<UInt8>
    
    /// The body content of the document, which assembles the complete HTML structure.
    var body: some HTML {
        // Add the doctype declaration
        Doctype()
        
        // Create the html element with language attribute
        html {
            // Add the head section with metadata and styles
            tag("head") {
                head
                style {
                    stylesheet
                }
            }
            
            // Add the body section with pre-rendered content
            tag("body") {
                HTMLRaw(bodyBytes)
            }
        }
        .attribute("lang", "en")
    }
}

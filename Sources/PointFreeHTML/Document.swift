//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// A private implementation of an HTML document.
///
/// This struct assembles the different parts of an HTML document (head, stylesheet, body)
/// into a complete HTML document with proper structure.
struct Document<Head: HTML>: HTML {
    /// The head content for the document.
    let head: Head

    /// Collected stylesheet bytes to be included in the document head.
    /// Stored as bytes to avoid String allocation round-trip.
    let stylesheetBytes: ContiguousArray<UInt8>

    /// Pre-rendered bytes for the document body.
    let bodyBytes: ContiguousArray<UInt8>

    /// The body content of the document, which assembles the complete HTML structure.
    var body: some HTML {
        // Add the doctype declaration
        Doctype()

        // Create the html element with language attribute
        HTMLTag("html") {
            // Add the head section with metadata and styles
            HTMLTag("head") {
                head
                HTMLTag("style") {
                    // Use HTMLRaw for stylesheet bytes - CSS doesn't need HTML escaping
                    HTMLRaw(stylesheetBytes)
                }
            }

            // Add the body section with pre-rendered content
            HTMLTag("body") {
                HTMLRaw(bodyBytes)
            }
        }
    }
}

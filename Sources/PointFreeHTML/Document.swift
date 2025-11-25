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
    
    /// Collected stylesheet content to be included in the document head.
    let stylesheet: String
    
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
                    HTMLText(stylesheet)
                }
            }
            
            // Add the body section with pre-rendered content
            HTMLTag("body") {
                HTMLRaw(bodyBytes)
            }
        }
    }
}

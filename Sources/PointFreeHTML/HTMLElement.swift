//
//  HTMLElement.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections

/// Represents an HTML element with a tag, attributes, and optional content.
///
/// `HTMLElement` is a fundamental building block in the PointFreeHTML library,
/// representing a standard HTML element with a tag name, attributes, and optional
/// child content. This type handles the rendering of both opening and closing tags,
/// attribute formatting, and proper indentation based on block vs. inline elements.
///
/// Example:
/// ```swift
/// let element = HTMLElement(tag: "div") {
///     p { "Hello, world!" }
/// }
/// ```
///
/// This type is typically not used directly by library consumers, who would
/// instead use the more convenient tag functions like `div`, `span`, `p`, etc.
public struct HTMLElement<Content: HTML>: HTML {
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never {
        fatalError()
    }

    /// The HTML tag name (e.g., "div", "span", "p").
    let tag: String

    /// The optional content contained within this element.
    @HTMLBuilder let content: Content?

    /// Creates a new HTML element with the specified tag and content.
    ///
    /// - Parameters:
    ///   - tag: The HTML tag name (e.g., "div", "span", "p").
    ///   - content: A closure that returns the content of this element.
    ///              If no content is provided, the element will be empty.
    public init(tag: String, @HTMLBuilder content: () -> Content? = { Never?.none }) {
        self.tag = tag
        self.content = content()
    }

    /// Renders this HTML element into the provided printer.
    ///
    /// This method performs the following steps:
    /// 1. Adds indentation if this is a block element
    /// 2. Writes the opening tag with attributes
    /// 3. Renders the content if present
    /// 4. Writes the closing tag (unless this is a void element)
    ///
    /// - Parameters:
    ///   - html: The HTML element to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {

        // Special handling for pre elements to preserve formatting
        let isPreElement = html.tag == "pre"

        // Add newline and indentation for block elements
        if html.isBlock {
            printer.bytes.append(contentsOf: printer.configuration.newline.utf8)
            printer.bytes.append(contentsOf: printer.currentIndentation.utf8)
        }

        // Write opening tag
        printer.bytes.append(UInt8(ascii: "<"))
        printer.bytes.append(contentsOf: html.tag.utf8)

        // Add attributes
        for (name, value) in printer.attributes {
            printer.bytes.append(UInt8(ascii: " "))
            printer.bytes.append(contentsOf: name.utf8)
            if !value.isEmpty {
                printer.bytes.append(contentsOf: "=\"".utf8)
                for byte in value.utf8 {
                    switch byte {
                    case UInt8(ascii: "\""):
                        printer.bytes.append(contentsOf: "&quot;".utf8)
                    case UInt8(ascii: "'"):
                        printer.bytes.append(contentsOf: "&#39;".utf8)
                    case UInt8(ascii: "&"):
                        printer.bytes.append(contentsOf: "&amp;".utf8)
                    case UInt8(ascii: "<"):
                        printer.bytes.append(contentsOf: "&lt;".utf8)
                    case UInt8(ascii: ">"):
                        printer.bytes.append(contentsOf: "&gt;".utf8)
                    default:
                        printer.bytes.append(byte)
                    }
                }
                printer.bytes.append(UInt8(ascii: "\""))
            }
        }
        printer.bytes.append(UInt8(ascii: ">"))

        // Render content if present
        if let content = html.content {
            let oldAttributes = printer.attributes
            let oldIndentation = printer.currentIndentation
            defer {
                printer.attributes = oldAttributes
                printer.currentIndentation = oldIndentation
            }
            printer.attributes.removeAll()
            if html.isBlock && !isPreElement {
                printer.currentIndentation += printer.configuration.indentation
            }
            Content._render(content, into: &printer)
        }

        // Add closing tag unless it's a void element
        if !HTMLVoidTag.allTags.contains(html.tag) {
            if html.isBlock && !isPreElement {
                printer.bytes.append(contentsOf: printer.configuration.newline.utf8)
                printer.bytes.append(contentsOf: printer.currentIndentation.utf8)
            }
            printer.bytes.append(contentsOf: "</".utf8)
            printer.bytes.append(contentsOf: html.tag.utf8)
            printer.bytes.append(UInt8(ascii: ">"))
        }
    }

    /// Determines if this element is a block-level element.
    ///
    /// Block-level elements are rendered with newlines and indentation,
    /// while inline elements are rendered without them.
    private var isBlock: Bool {
        !inlineTags.contains(tag)
    }
}

/// A set of HTML tags that are considered inline elements.
///
/// Inline elements are rendered without additional newlines or indentation,
/// as they typically appear within the flow of text content.
private let inlineTags: Set<String> = [
    "a",
    "abbr",
    "acronym",
    "b",
    "bdo",
    "big",
    "br",
    "button",
    "cite",
    "code",
    "dfn",
    "em",
    "i",
    "img",
    "input",
    "kbd",
    "label",
    "map",
    "object",
    "output",
    "q",
    "samp",
    "script",
    "select",
    "small",
    "span",
    "strong",
    "sub",
    "sup",
    "textarea",
    "time",
    "tt",
    "var"
]

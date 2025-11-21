//
//  HTMLElement.swift
//
//
//  Created by Point-Free, Inc
//

import INCITS_4_1986
import OrderedCollections

// MARK: - HTML Entity Constants

extension [UInt8] {
    /// &quot; - Double quotation mark HTML entity
    fileprivate static let htmlEntityQuot: [UInt8] = [
        UInt8.ascii.ampersand,
        UInt8.ascii.q,
        UInt8.ascii.u,
        UInt8.ascii.o,
        UInt8.ascii.t,
        UInt8.ascii.semicolon
    ]

    /// &#39; - Apostrophe HTML entity
    fileprivate static let htmlEntityApos: [UInt8] = [
        UInt8.ascii.ampersand,
        UInt8.ascii.numberSign,
        UInt8.ascii.3,
        UInt8.ascii.9,
        UInt8.ascii.semicolon
    ]

    /// &amp; - Ampersand HTML entity
    fileprivate static let htmlEntityAmp: [UInt8] = [
        UInt8.ascii.ampersand,
        UInt8.ascii.a,
        UInt8.ascii.m,
        UInt8.ascii.p,
        UInt8.ascii.semicolon
    ]

    /// &lt; - Less-than HTML entity
    fileprivate static let htmlEntityLt: [UInt8] = [
        UInt8.ascii.ampersand,
        UInt8.ascii.l,
        UInt8.ascii.t,
        UInt8.ascii.semicolon
    ]

    /// &gt; - Greater-than HTML entity
    fileprivate static let htmlEntityGt: [UInt8] = [
        UInt8.ascii.ampersand,
        UInt8.ascii.g,
        UInt8.ascii.t,
        UInt8.ascii.semicolon
    ]
}

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
            printer.bytes.append(contentsOf: printer.configuration.newline)
            printer.bytes.append(contentsOf: printer.currentIndentation)
        }

        // Write opening tag
        printer.bytes.append(UInt8.ascii.lessThanSign)
        printer.bytes.append(contentsOf: html.tag.utf8)

        // Add attributes
        for (name, value) in printer.attributes {
            printer.bytes.append(UInt8.ascii.space)
            printer.bytes.append(contentsOf: name.utf8)
            if !value.isEmpty {
                printer.bytes.append(UInt8.ascii.equalsSign)
                printer.bytes.append(UInt8.ascii.dquote)

                // Fast path: check if escaping is needed
                let valueBytes = Array(value.utf8)
                let needsEscaping = valueBytes.contains { byte in
                    byte == UInt8.ascii.dquote || byte == UInt8.ascii.apostrophe ||
                    byte == UInt8.ascii.ampersand || byte == UInt8.ascii.lessThanSign ||
                    byte == UInt8.ascii.greaterThanSign
                }

                if needsEscaping {
                    // Slow path: byte-by-byte escaping
                    for byte in valueBytes {
                        switch byte {
                        case UInt8.ascii.dquote:
                            printer.bytes.append(contentsOf: [UInt8].htmlEntityQuot)
                        case UInt8.ascii.apostrophe:
                            printer.bytes.append(contentsOf: [UInt8].htmlEntityApos)
                        case UInt8.ascii.ampersand:
                            printer.bytes.append(contentsOf: [UInt8].htmlEntityAmp)
                        case UInt8.ascii.lessThanSign:
                            printer.bytes.append(contentsOf: [UInt8].htmlEntityLt)
                        case UInt8.ascii.greaterThanSign:
                            printer.bytes.append(contentsOf: [UInt8].htmlEntityGt)
                        default:
                            printer.bytes.append(byte)
                        }
                    }
                } else {
                    // Fast path: bulk copy when no escaping needed
                    printer.bytes.append(contentsOf: valueBytes)
                }

                printer.bytes.append(UInt8.ascii.dquote)
            }
        }
        printer.bytes.append(UInt8.ascii.greaterThanSign)

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
                printer.bytes.append(contentsOf: printer.configuration.newline)
                printer.bytes.append(contentsOf: printer.currentIndentation)
            }
            printer.bytes.append(UInt8.ascii.lessThanSign)
            printer.bytes.append(UInt8.ascii.slant)
            printer.bytes.append(contentsOf: html.tag.utf8)
            printer.bytes.append(UInt8.ascii.greaterThanSign)
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
    "var",
]

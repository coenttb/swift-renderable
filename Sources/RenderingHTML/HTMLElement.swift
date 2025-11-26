//
//  HTMLElement.swift
//
//
//  Created by Point-Free, Inc
//

import INCITS_4_1986
import OrderedCollections
import Rendering

// MARK: - HTML Entity Constants

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
    /// The HTML tag name (e.g., "div", "span", "p").
    let tag: String
    
    /// The optional content contained within this element.
    @Builder let content: Content?
    
    /// Creates a new HTML element with the specified tag and content.
    ///
    /// - Parameters:
    ///   - tag: The HTML tag name (e.g., "div", "span", "p").
    ///   - content: A closure that returns the content of this element.
    ///              If no content is provided, the element will be empty.
    public init(tag: String, @Builder content: () -> Content? = { Never?.none }) {
        self.tag = tag
        self.content = content()
    }
    
    /// Renders this HTML element into the provided buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        // Special handling for pre elements to preserve formatting
        let isPreElement = html.tag == "pre"
        let htmlIsBlock = html.isBlock
        // Add newline and indentation for block elements
        if htmlIsBlock {
            buffer.append(contentsOf: context.rendering.newline)
            buffer.append(contentsOf: context.currentIndentation)
        }
        
        // Write opening tag
        buffer.append(.ascii.lessThanSign)
        buffer.append(contentsOf: html.tag.utf8)
        
        // Add attributes - single-pass escaping without intermediate allocation
        for (name, value) in context.attributes {
            buffer.append(.ascii.space)
            buffer.append(contentsOf: name.utf8)
            if !value.isEmpty {
                buffer.append(.ascii.equalsSign)
                buffer.append(.ascii.dquote)

                // Single-pass: iterate directly over UTF-8 view, escape as needed
                for byte in value.utf8 {
                    switch byte {
                    case .ascii.dquote:
                        buffer.append(contentsOf: [UInt8].htmlEntityQuot)
                    case .ascii.apostrophe:
                        buffer.append(contentsOf: [UInt8].htmlEntityApos)
                    case .ascii.ampersand:
                        buffer.append(contentsOf: [UInt8].htmlEntityAmp)
                    case .ascii.lessThanSign:
                        buffer.append(contentsOf: [UInt8].htmlEntityLt)
                    case .ascii.greaterThanSign:
                        buffer.append(contentsOf: [UInt8].htmlEntityGt)
                    default:
                        buffer.append(byte)
                    }
                }

                buffer.append(.ascii.dquote)
            }
        }
        buffer.append(.ascii.greaterThanSign)
        
        // Render content if present
        if let content = html.content {
            let oldAttributes = context.attributes
            let oldIndentation = context.currentIndentation
            defer {
                context.attributes = oldAttributes
                context.currentIndentation = oldIndentation
            }
            context.attributes.removeAll()
            if htmlIsBlock && !isPreElement {
                context.currentIndentation += context.rendering.indentation
            }
            Content._render(content, into: &buffer, context: &context)
        }
        
        // Add closing tag unless it's a void element
        if !HTMLVoidTag.allTags.contains(html.tag) {
            if htmlIsBlock && !isPreElement {
                buffer.append(contentsOf: context.rendering.newline)
                buffer.append(contentsOf: context.currentIndentation)
            }
            buffer.append(.ascii.lessThanSign)
            buffer.append(.ascii.slant)
            buffer.append(contentsOf: html.tag.utf8)
            buffer.append(.ascii.greaterThanSign)
        }
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never {
        fatalError()
    }
    
    /// Determines if this element is a block-level element.
    ///
    /// Block-level elements are rendered with newlines and indentation,
    /// while inline elements are rendered without them.
    private var isBlock: Bool {
        !Set<String>.inlineTags.contains(tag)
    }
}

extension HTMLElement: Sendable where Content: Sendable {}



//
//  HTML.Element.swift
//
//
//  Created by Point-Free, Inc
//

import INCITS_4_1986
import OrderedCollections
import Rendering

extension HTML {
    /// Represents an HTML element with a tag, attributes, and optional content.
    ///
    /// `HTML.Element` is a fundamental building block in the PointFreeHTML library,
    /// representing a standard HTML element with a tag name, attributes, and optional
    /// child content. This type handles the rendering of both opening and closing tags,
    /// attribute formatting, and proper indentation based on block vs. inline elements.
    ///
    /// Example:
    /// ```swift
    /// let element = HTML.Element(tag: "div") {
    ///     p { "Hello, world!" }
    /// }
    /// ```
    ///
    /// This type is typically not used directly by library consumers, who would
    /// instead use the more convenient tag functions like `div`, `span`, `p`, etc.
    public struct Element<Content: HTML.View>: HTML.View {
        /// The HTML tag name (e.g., "div", "span", "p").
        let tag: String

        /// The optional content contained within this element.
        @HTML.Builder let content: Content?

        /// Creates a new HTML element with the specified tag and content.
        ///
        /// - Parameters:
        ///   - tag: The HTML tag name (e.g., "div", "span", "p").
        ///   - content: A closure that returns the content of this element.
        ///              If no content is provided, the element will be empty.
        public init(tag: String, @HTML.Builder content: () -> Content? = { Never?.none }) {
            self.tag = tag
            self.content = content()
        }

        /// Renders this HTML element into the provided buffer.
        public static func _render<Buffer: RangeReplaceableCollection>(
            _ html: Self,
            into buffer: inout Buffer,
            context: inout HTML.Context
        ) where Buffer.Element == UInt8 {
            // Special handling for pre elements to preserve formatting
            let isPreElement = html.tag == "pre"
            let htmlIsBlock = html.isBlock
            // Add newline and indentation for block elements
            if htmlIsBlock {
                buffer.append(contentsOf: context.configuration.newline)
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
                            buffer.append(contentsOf: [UInt8].html.doubleQuotationMark)
                        case .ascii.apostrophe:
                            buffer.append(contentsOf: [UInt8].html.apostrophe)
                        case .ascii.ampersand:
                            buffer.append(contentsOf: [UInt8].html.ampersand)
                        case .ascii.lessThanSign:
                            buffer.append(contentsOf: [UInt8].html.lessThan)
                        case .ascii.greaterThanSign:
                            buffer.append(contentsOf: [UInt8].html.greaterThan)
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
                    context.currentIndentation += context.configuration.indentation
                }
                Content._render(content, into: &buffer, context: &context)
            }

            // Add closing tag unless it's a void element
            if !HTML.Tag.Void.allTags.contains(html.tag) {
                if htmlIsBlock && !isPreElement {
                    buffer.append(contentsOf: context.configuration.newline)
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
            HTML.Tag.Inline(rawValue: tag) == nil
        }
    }
}

extension HTML.Element: Sendable where Content: Sendable {}

// MARK: - Async Rendering

extension HTML.Element: AsyncRendering where Content: AsyncRendering {
    /// Async renders this HTML element with backpressure support.
    ///
    /// This implementation mirrors the sync `_render` but uses async writes
    /// to the stream, allowing suspension at strategic points.
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ html: Self,
        into stream: Stream,
        context: inout HTML.Context
    ) async {
        let isPreElement = html.tag == "pre"
        let htmlIsBlock = html.isBlock

        // Build opening tag into local buffer, then write once
        var openTag: [UInt8] = []

        if htmlIsBlock {
            openTag.append(contentsOf: context.configuration.newline)
            openTag.append(contentsOf: context.currentIndentation)
        }

        openTag.append(.ascii.lessThanSign)
        openTag.append(contentsOf: html.tag.utf8)

        // Add attributes
        for (name, value) in context.attributes {
            openTag.append(.ascii.space)
            openTag.append(contentsOf: name.utf8)
            if !value.isEmpty {
                openTag.append(.ascii.equalsSign)
                openTag.append(.ascii.dquote)

                for byte in value.utf8 {
                    switch byte {
                    case .ascii.dquote:
                        openTag.append(contentsOf: [UInt8].html.doubleQuotationMark)
                    case .ascii.apostrophe:
                        openTag.append(contentsOf: [UInt8].html.apostrophe)
                    case .ascii.ampersand:
                        openTag.append(contentsOf: [UInt8].html.ampersand)
                    case .ascii.lessThanSign:
                        openTag.append(contentsOf: [UInt8].html.lessThan)
                    case .ascii.greaterThanSign:
                        openTag.append(contentsOf: [UInt8].html.greaterThan)
                    default:
                        openTag.append(byte)
                    }
                }

                openTag.append(.ascii.dquote)
            }
        }
        openTag.append(.ascii.greaterThanSign)

        await stream.write(openTag)

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
                context.currentIndentation += context.configuration.indentation
            }
            await Content._renderAsync(content, into: stream, context: &context)
        }

        // Add closing tag unless void element
        if !HTML.Tag.Void.allTags.contains(html.tag) {
            var closeTag: [UInt8] = []
            if htmlIsBlock && !isPreElement {
                closeTag.append(contentsOf: context.configuration.newline)
                closeTag.append(contentsOf: context.currentIndentation)
            }
            closeTag.append(.ascii.lessThanSign)
            closeTag.append(.ascii.slant)
            closeTag.append(contentsOf: html.tag.utf8)
            closeTag.append(.ascii.greaterThanSign)

            await stream.write(closeTag)
        }
    }
}



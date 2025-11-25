//
//  HTMLText.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import INCITS_4_1986

/// Represents plain text content in HTML, with proper escaping.
///
/// `HTMLText` handles escaping special characters in text content to ensure
/// proper HTML rendering without security vulnerabilities.
public struct HTMLText: HTML {
    /// The raw text content.
    let text: String

    /// Creates a new HTML text component with the given text.
    ///
    /// - Parameter text: The text content to represent.
    public init(_ text: String) {
        self.text = text
    }

    /// Renders the text content with proper HTML escaping.
    ///
    /// This method escapes special characters (`&`, `<`, `>`) to prevent HTML injection
    /// and ensure the text renders correctly in an HTML document.
    ///
    /// - Parameters:
    ///   - html: The HTML text to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        printer.bytes.reserveCapacity(printer.bytes.count + html.text.utf8.count)
        for byte in html.text.utf8 {
            switch byte {
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
    }

    /// Streaming render - writes directly to any byte buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        for byte in html.text.utf8 {
            switch byte {
            case UInt8.ascii.ampersand:
                buffer.append(contentsOf: [UInt8].htmlEntityAmp)
            case UInt8.ascii.lessThanSign:
                buffer.append(contentsOf: [UInt8].htmlEntityLt)
            case UInt8.ascii.greaterThanSign:
                buffer.append(contentsOf: [UInt8].htmlEntityGt)
            default:
                buffer.append(byte)
            }
        }
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }

    /// Concatenates two HTML text components.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side text.
    ///   - rhs: The right-hand side text.
    /// - Returns: A new HTML text component containing the concatenated text.
    public static func + (lhs: Self, rhs: Self) -> Self {
        HTMLText(lhs.text + rhs.text)
    }
}

/// Allows HTML text to be created from string literals.
extension HTMLText: ExpressibleByStringLiteral {
    /// Creates a new HTML text component from a string literal.
    ///
    /// - Parameter value: The string literal to use as content.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// Allows HTML text to be created with string interpolation.
extension HTMLText: ExpressibleByStringInterpolation {}

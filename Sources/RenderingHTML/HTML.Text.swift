//
//  HTML.Text.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import INCITS_4_1986
import Rendering

extension HTML {
    /// Represents plain text content in HTML, with proper escaping.
    ///
    /// `HTML.Text` handles escaping special characters in text content to ensure
    /// proper HTML rendering without security vulnerabilities.
    public struct Text: HTML.View, Sendable {
        /// The raw text content.
        let text: String

        /// Creates a new HTML text component with the given text.
        ///
        /// - Parameter text: The text content to represent.
        public init(_ text: String) {
            self.text = text
        }

        /// Renders the text content with proper HTML escaping.
        public static func _render<Buffer: RangeReplaceableCollection>(
            _ html: Self,
            into buffer: inout Buffer,
            context: inout HTML.Context
        ) where Buffer.Element == UInt8 {
            for byte in html.text.utf8 {
                switch byte {
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
            HTML.Text(lhs.text + rhs.text)
        }
    }
}

/// Allows HTML text to be created from string literals.
extension HTML.Text: ExpressibleByStringLiteral {
    /// Creates a new HTML text component from a string literal.
    ///
    /// - Parameter value: The string literal to use as content.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// Allows HTML text to be created with string interpolation.
extension HTML.Text: ExpressibleByStringInterpolation {}

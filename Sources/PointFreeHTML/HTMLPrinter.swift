//
//  HTMLPrinter.swift
//
//
//  Created by Point-Free, Inc
//

import INCITS_4_1986
public import OrderedCollections



/// A struct responsible for rendering HTML elements to bytes.
///
/// `HTMLPrinter` is the core rendering engine of the PointFreeHTML library.
/// It maintains the state needed during the rendering process, including
/// attributes, bytes buffer, and styling information. It also handles
/// formatting concerns like indentation and newlines.
///
/// Example:
/// ```swift
/// let content = div { "Hello, world!" }
/// var printer = HTMLPrinter(.pretty)
/// HTML._render(content, into: &printer)
/// let bytes = printer.bytes
/// ```
///
/// Most users will not interact with `HTMLPrinter` directly, but instead
/// use the `render()` method on HTML elements or documents.
public struct HTMLPrinter: Sendable {
    
    /// The buffer of bytes representing the rendered HTML.
    public var bytes: ContiguousArray<UInt8> = []
    
    /// The current set of attributes to apply to the next HTML element.
    public var attributes: OrderedDictionary<String, String> = [:]
    
    /// The collected styles to be rendered in the document's stylesheet.
    ///
    /// Uses a flattened structure with composite keys for better performance.
    /// Previously was `OrderedDictionary<AtRule?, OrderedDictionary<String, String>>`
    /// which required two hash lookups per access.
    public var styles: OrderedDictionary<StyleKey, String> = [:]
    
    /// Configuration for rendering, including formatting options.
    let configuration: Configuration
    
    /// The current indentation level for pretty-printing.
    var currentIndentation: [UInt8] = []
    
    /// Creates a new HTML printer with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to use for rendering.
    ///   Default is no indentation or newlines.
    public init(_ configuration: Configuration = .default) {
        self.configuration = configuration
        if configuration.reservedCapacity > 0 {
            self.bytes.reserveCapacity(configuration.reservedCapacity)
        }
    }
}

extension HTMLPrinter {

    /// Generates a CSS stylesheet from the collected styles as bytes.
    ///
    /// This is the canonical implementation - generates bytes directly without
    /// intermediate String allocation.
    public var stylesheetBytes: ContiguousArray<UInt8> {
        // Group styles by atRule
        var grouped: OrderedDictionary<AtRule?, [(selector: String, style: String)]> = [:]
        for (key, style) in styles {
            grouped[key.atRule, default: []].append((key.selector, style))
        }

        var sheet = ContiguousArray<UInt8>()
        sheet.append(contentsOf: configuration.newline)

        for (mediaQuery, stylesForMedia) in grouped.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
            if let mediaQuery {
                sheet.append(contentsOf: mediaQuery.rawValue.utf8)
                sheet.append(0x7B) // {
                sheet.append(contentsOf: configuration.newline)
            }

            for (selector, style) in stylesForMedia {
                if mediaQuery != nil {
                    sheet.append(contentsOf: configuration.indentation)
                }
                sheet.append(contentsOf: selector.utf8)
                sheet.append(0x7B) // {
                sheet.append(contentsOf: style.utf8)
                if configuration.forceImportant {
                    sheet.append(contentsOf: " !important".utf8)
                }
                sheet.append(0x7D) // }
                sheet.append(contentsOf: configuration.newline)
            }

            if mediaQuery != nil {
                sheet.append(0x7D) // }
                sheet.append(contentsOf: configuration.newline)
            }
        }
        return sheet
    }

    /// Generates a CSS stylesheet from the collected styles.
    ///
    /// Convenience property that converts bytes to String.
    /// Prefer `stylesheetBytes` for performance-critical code.
    public var stylesheet: String {
        String(decoding: stylesheetBytes, as: UTF8.self)
    }
}


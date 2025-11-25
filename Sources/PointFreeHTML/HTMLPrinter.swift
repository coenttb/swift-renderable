//
//  HTMLPrinter.swift
//
//
//  Created by Point-Free, Inc
//

import Dependencies
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
    
    /// Generates a CSS stylesheet from the collected styles.
    ///
    /// This method compiles all styles collected during rendering into a
    /// properly formatted CSS stylesheet string, including media queries
    /// and the option to force the `!important` flag on all styles.
    ///
    /// - Returns: A string containing the CSS stylesheet.
    public var stylesheet: String {
        // Convert byte arrays to strings once for stylesheet generation
        let newlineStr = String(decoding: configuration.newline, as: UTF8.self)
        let indentationStr = String(decoding: configuration.indentation, as: UTF8.self)
        
        // Group styles by atRule
        var grouped: OrderedDictionary<AtRule?, [(selector: String, style: String)]> = [:]
        for (key, style) in styles {
            grouped[key.atRule, default: []].append((key.selector, style))
        }
        
        var sheet = newlineStr
        for (mediaQuery, stylesForMedia) in grouped.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
            var currentIndentation = ""
            if let mediaQuery {
                sheet.append("\(mediaQuery.rawValue){")
                sheet.append(newlineStr)
                currentIndentation.append(indentationStr)
            }
            defer {
                if mediaQuery != nil {
                    sheet.append("}")
                    sheet.append(newlineStr)
                }
            }
            for (selector, style) in stylesForMedia {
                sheet.append(currentIndentation)
                if configuration.forceImportant {
                    sheet.append("\(selector){\(style) !important}")
                } else {
                    sheet.append("\(selector){\(style)}")
                }
                sheet.append(newlineStr)
            }
        }
        return sheet
    }
}


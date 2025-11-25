//
//  HTMLContext.swift
//  pointfree-html
//
//  Rendering context for HTML streaming.
//  Holds state (attributes, styles, indentation) separate from the output buffer.
//

public import OrderedCollections

/// Rendering context for HTML streaming.
///
/// `HTMLContext` holds the state needed during HTML rendering, separate from the output buffer.
/// This separation enables streaming rendering where the buffer can be any `RangeReplaceableCollection<UInt8>`.
///
/// ## Design Philosophy
///
/// The rendering state is decoupled from the output destination:
/// - **Context**: Attributes, styles, indentation, configuration
/// - **Buffer**: Where bytes are written (generic, caller-controlled)
///
/// This enables the same rendering logic to write to `[UInt8]`, `ContiguousArray<UInt8>`,
/// `Data`, `ByteBuffer`, or any other byte buffer.
public struct HTMLContext: Sendable {
    /// The current set of attributes to apply to the next HTML element.
    public var attributes: OrderedDictionary<String, String> = [:]

    /// The collected styles to be rendered in the document's stylesheet.
    public var styles: OrderedDictionary<StyleKey, String> = [:]

    /// Configuration for rendering, including formatting options.
    public let configuration: HTMLPrinter.Configuration

    /// The current indentation level for pretty-printing.
    public var currentIndentation: [UInt8] = []

    /// Creates a new HTML rendering context with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to use for rendering.
    public init(_ configuration: HTMLPrinter.Configuration = .default) {
        self.configuration = configuration
    }

    /// Generates a CSS stylesheet from the collected styles.
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

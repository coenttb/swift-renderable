//
//  HTMLContext.swift
//  pointfree-html
//
//  Rendering context for HTML streaming.
//  Holds state (attributes, styles, indentation) separate from the output buffer.
//

import INCITS_4_1986
public import OrderedCollections

/// Rendering context for HTML streaming.
///
/// `HTMLContext` holds the state needed during HTML rendering, separate from the output buffer.
/// This separation enables streaming rendering where the buffer can be any `RangeReplaceableCollection<UInt8>`.
///
/// ## Design Philosophy
///
/// The rendering state is decoupled from the output destination:
/// - **Context**: Attributes, styles, indentation, rendering configuration
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
    public let rendering: Rendering

    /// The current indentation level for pretty-printing.
    public var currentIndentation: [UInt8] = []

    // MARK: - Style Tracking for Deterministic Class Names

    /// Counter for generating sequential class names.
    /// Each render context starts at 0, ensuring deterministic naming.
    private var styleCounter: Int = 0

    /// Maps seen styles to their assigned class names within this render.
    /// Same style always returns same class name within a single render.
    private var seenStyles: [Style: String] = [:]

    /// Creates a new HTML rendering context with the specified rendering configuration.
    ///
    /// - Parameter rendering: The rendering configuration to use. Defaults to current task-local value.
    public init(_ rendering: Rendering = .current) {
        self.rendering = rendering
    }

    // MARK: - Class Name Generation

    /// Get or create a class name for a style.
    ///
    /// Same style always returns same class name within a render context.
    /// Class names are descriptive and sequential: `color-0`, `margin-1`, etc.
    ///
    /// - Parameter style: The style to get a class name for.
    /// - Returns: A deterministic class name for the style.
    mutating func className(for style: Style) -> String {
        if let existing = seenStyles[style] {
            return existing
        }
        let name = "\(style.property)-\(styleCounter)"
        styleCounter += 1
        seenStyles[style] = name
        return name
    }

    /// Get or create class names for multiple styles.
    ///
    /// Batch version of `className(for:)` for efficiency.
    ///
    /// - Parameter styles: The styles to get class names for.
    /// - Returns: An array of deterministic class names.
    mutating func classNames(for styles: [Style]) -> [String] {
        styles.map { className(for: $0) }
    }

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
        sheet.append(contentsOf: rendering.newline)

        for (mediaQuery, stylesForMedia) in grouped.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
            if let mediaQuery {
                sheet.append(contentsOf: mediaQuery.rawValue.utf8)
                sheet.append(0x7B) // {
                sheet.append(contentsOf: rendering.newline)
            }

            for (selector, style) in stylesForMedia {
                if mediaQuery != nil {
                    sheet.append(contentsOf: rendering.indentation)
                }
                sheet.append(contentsOf: selector.utf8)
                sheet.append(0x7B) // {
                sheet.append(contentsOf: style.utf8)
                if rendering.forceImportant {
                    sheet.append(contentsOf: " !important".utf8)
                }
                sheet.append(0x7D) // }
                sheet.append(contentsOf: rendering.newline)
            }

            if mediaQuery != nil {
                sheet.append(0x7D) // }
                sheet.append(contentsOf: rendering.newline)
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

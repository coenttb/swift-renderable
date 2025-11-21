//
//  HTMLPrinter.swift
//
//
//  Created by Point-Free, Inc
//

import Dependencies
import OrderedCollections

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
    public var styles: OrderedDictionary<AtRule?, OrderedDictionary<String, String>> = [:]

    /// Configuration for rendering, including formatting options.
    let configuration: Configuration

    /// The current indentation level for pretty-printing.
    var currentIndentation = ""

    /// Creates a new HTML printer with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to use for rendering.
    ///   Default is no indentation or newlines.
    public init(_ configuration: Configuration = .default) {
        self.configuration = configuration
    }

    /// Generates a CSS stylesheet from the collected styles.
    ///
    /// This method compiles all styles collected during rendering into a
    /// properly formatted CSS stylesheet string, including media queries
    /// and the option to force the `!important` flag on all styles.
    ///
    /// - Returns: A string containing the CSS stylesheet.
    public var stylesheet: String {
        var sheet = configuration.newline
        for (mediaQuery, styles) in styles.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
            var currentIndentation = ""
            if let mediaQuery {
                sheet.append("\(mediaQuery.rawValue){")
                sheet.append(configuration.newline)
                currentIndentation.append(configuration.indentation)
            }
            defer {
                if mediaQuery != nil {
                    sheet.append("}")
                    sheet.append(configuration.newline)
                }
            }
            for (className, style) in styles {
                sheet.append(currentIndentation)
                if configuration.forceImportant {
                    sheet.append("\(className){\(style) !important}")
                } else {
                    sheet.append("\(className){\(style)}")
                }
                sheet.append(configuration.newline)
            }
        }
        return sheet
    }

    /// Configuration options for HTML rendering.
    ///
    /// This struct provides options to control how HTML is rendered,
    /// including pretty-printing options and special handling for
    /// specific contexts like email.
    public struct Configuration: Sendable {
        /// Whether to add `!important` to all CSS rules.
        package let forceImportant: Bool

        /// The string to use for indentation.
        package let indentation: String

        /// The string to use for newlines.
        package let newline: String

        /// Default configuration with no indentation or newlines.
        public static let `default` = Self(forceImportant: false, indentation: "", newline: "")

        /// Pretty-printing configuration with 2-space indentation and newlines.
        public static let pretty = Self(forceImportant: false, indentation: "  ", newline: "\n")

        /// Configuration optimized for email HTML with forced important styles.
        public static let email = Self(forceImportant: true, indentation: " ", newline: "\n")
    }
}

extension HTML {
    /// Renders this HTML element to bytes.
    ///
    /// This method creates a printer with the current configuration and
    /// renders the HTML element into it, then returns the resulting bytes.
    ///
    /// - Returns: A buffer of bytes representing the rendered HTML.
    ///
    /// - Warning: This method is deprecated. Use the RFC pattern initialization instead:
    ///   ```swift
    ///   // Old (deprecated)
    ///   let bytes = html.render()
    ///
    ///   // New (RFC pattern - zero-copy)
    ///   let bytes = ContiguousArray(html)
    ///
    ///   // Or for String output
    ///   let string = try String(html)
    ///   ```
    @available(*, deprecated, message: "Use ContiguousArray(html) or String(html) instead. The RFC pattern makes bytes canonical and String derived.")
    public func render() -> ContiguousArray<UInt8> {
        @Dependency(\.htmlPrinter) var htmlPrinter
        var printer = htmlPrinter
        Self._render(self, into: &printer)
        return printer.bytes
    }
}

extension HTMLDocumentProtocol {
    /// Renders this HTML document to bytes.
    ///
    /// This method creates a printer with the current configuration and
    /// renders the HTML document into it, then returns the resulting bytes.
    ///
    /// - Returns: A buffer of bytes representing the rendered HTML document.
    ///
    /// - Warning: This method is deprecated. Use the RFC pattern initialization instead:
    ///   ```swift
    ///   // Old (deprecated)
    ///   let bytes = document.render()
    ///
    ///   // New (RFC pattern - zero-copy)
    ///   let bytes = ContiguousArray(document)
    ///
    ///   // Or for String output
    ///   let string = try String(document)
    ///   ```
    @available(*, deprecated, message: "Use ContiguousArray(html) or String(html) instead. The RFC pattern makes bytes canonical and String derived.")
    public func render() -> ContiguousArray<UInt8> {
        @Dependency(\.htmlPrinter) var htmlPrinter
        var printer = htmlPrinter
        Self._render(self, into: &printer)
        return printer.bytes
    }
}

extension DependencyValues {
    /// The HTML printer to use for rendering HTML.
    ///
    /// This dependency allows for customization of HTML rendering
    /// without having to pass a printer explicitly.
    public var htmlPrinter: HTMLPrinter {
        get { self[HTMLPrinterKey.self] }
        set { self[HTMLPrinterKey.self] = newValue }
    }
}

/// Private key for the HTML printer dependency.
private enum HTMLPrinterKey: DependencyKey {
    /// Default printer for production use.
    static var liveValue: HTMLPrinter { HTMLPrinter() }

    /// Pretty-printing printer for preview use.
    static var previewValue: HTMLPrinter { HTMLPrinter(.pretty) }

    /// Pretty-printing printer for test use.
    static var testValue: HTMLPrinter { HTMLPrinter(.default) }
}

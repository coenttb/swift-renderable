//
//  DocType.swift
//
//
//  Created by Point-Free, Inc
//

/// Represents the HTML doctype declaration.
///
/// The `Doctype` struct provides a convenient way to add the HTML5 doctype
/// declaration to an HTML document. This declaration is required for proper
/// rendering and standards compliance in web browsers.
///
/// Example:
/// ```swift
/// var body: some HTML {
///     Doctype()
///     html {
///         // HTML content...
///     }
/// }
/// ```
///
/// - Note: In HTML5, the doctype is simplified to `<!doctype html>` compared
///   to the more complex doctypes in earlier HTML versions.
public struct Doctype: HTML {
    /// Creates a new doctype declaration.
    public init() {}

    /// The body of the doctype declaration, which renders as raw HTML.
    public var body: some HTML {
        HTMLRaw([UInt8].doctypeHTML)
    }
}

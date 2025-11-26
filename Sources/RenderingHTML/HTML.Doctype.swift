//
//  HTML.Doctype.swift
//
//
//  Created by Point-Free, Inc
//

import Rendering

extension HTML {
    /// Represents the HTML doctype declaration.
    ///
    /// The `HTML.Doctype` struct provides a convenient way to add the HTML5 doctype
    /// declaration to an HTML document. This declaration is required for proper
    /// rendering and standards compliance in web browsers.
    ///
    /// Example:
    /// ```swift
    /// var body: some HTML.View {
    ///     HTML.Doctype()
    ///     html {
    ///         // HTML content...
    ///     }
    /// }
    /// ```
    ///
    /// - Note: In HTML5, the doctype is simplified to `<!doctype html>` compared
    ///   to the more complex doctypes in earlier HTML versions.
    public struct Doctype: HTML.View {
        /// Creates a new doctype declaration.
        public init() {}

        /// The body of the doctype declaration, which renders as raw HTML.
        public var body: some HTML.View {
            HTML.Raw([UInt8].doctypeHTML)
        }
    }
}

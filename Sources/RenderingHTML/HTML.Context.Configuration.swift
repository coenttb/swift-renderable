//
//  HTML.Context.Configuration.swift
//  pointfree-html
//
//  Configuration and error types for HTML rendering.
//

import INCITS_4_1986
import Rendering

extension HTML.Context {

    /// Configuration options for HTML rendering.
    ///
    /// This struct provides options to control how HTML is rendered,
    /// including pretty-printing options and special handling for
    /// specific contexts like email.
    ///
    /// ## Task-Local Configuration
    ///
    /// Use the `current` task-local to configure rendering without passing
    /// configuration explicitly:
    ///
    /// ```swift
    /// HTML.Context.Configuration.$current.withValue(.pretty) {
    ///     let html = ContiguousArray(document)
    /// }
    /// ```
    public struct Configuration: Sendable {
        /// Task-local configuration for HTML rendering.
        ///
        /// This enables configuration without explicit parameter passing.
        /// Use `$current.withValue(.pretty) { ... }` to set configuration
        /// for a scope.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Default (minified)
        /// let minified = ContiguousArray(html)
        ///
        /// // Pretty-printed
        /// HTML.Context.Configuration.$current.withValue(.pretty) {
        ///     let pretty = ContiguousArray(html)
        /// }
        /// ```
        @TaskLocal public static var current: Self = .default

        /// Whether to add `!important` to all CSS rules.
        package let forceImportant: Bool

        /// The bytes to use for indentation.
        ///
        /// Stored as bytes to avoid UTF-8 conversion overhead during rendering.
        package let indentation: [UInt8]

        /// The bytes to use for newlines.
        ///
        /// Stored as bytes to avoid UTF-8 conversion overhead during rendering.
        package let newline: [UInt8]

        /// Reserved capacity for the byte buffer (in bytes).
        ///
        /// Pre-allocating capacity avoids multiple reallocations during rendering.
        /// Set to 0 for no reservation (default), or estimate your typical document size.
        ///
        /// ## Typical Sizes
        /// - Small documents (< 1KB): 512 bytes
        /// - Medium documents (1-10KB): 4096 bytes
        /// - Large documents (> 10KB): 16384 bytes
        package let reservedCapacity: Int

        /// Creates a custom HTML rendering configuration.
        ///
        /// - Parameters:
        ///   - forceImportant: Whether to add `!important` to all CSS rules.
        ///   - indentation: The bytes to use for indentation.
        ///   - newline: The bytes to use for newlines.
        ///   - reservedCapacity: Reserved capacity for the byte buffer in bytes.
        public init(
            forceImportant: Bool,
            indentation: [UInt8],
            newline: [UInt8],
            reservedCapacity: Int
        ) {
            self.forceImportant = forceImportant
            self.indentation = indentation
            self.newline = newline
            self.reservedCapacity = reservedCapacity
        }

        /// Default configuration with no indentation or newlines.
        ///
        /// Pre-allocates 1KB to handle most simple documents without reallocation.
        public static let `default` = Self(forceImportant: false, indentation: [], newline: [], reservedCapacity: 1024)

        /// Pretty-printing configuration with 2-space indentation and newlines.
        ///
        /// Pre-allocates 2KB to accommodate additional whitespace from formatting.
        public static let pretty = Self(
            forceImportant: false,
            indentation: [.ascii.space, .ascii.space],
            newline: [.ascii.lf],
            reservedCapacity: 2048
        )

        /// Configuration optimized for email HTML with forced important styles.
        ///
        /// Pre-allocates 2KB as email HTML tends to be verbose with inline styles.
        public static let email = Self(
            forceImportant: true,
            indentation: [.ascii.space],
            newline: [.ascii.lf],
            reservedCapacity: 2048
        )

        /// Performance-optimized configuration for typical documents (~4KB).
        ///
        /// Pre-allocates 4096 bytes to avoid reallocations for most documents.
        /// Use this when rendering performance is critical.
        public static let optimized = Self(forceImportant: false, indentation: [], newline: [], reservedCapacity: 4096)
    }
}

extension HTML.Context.Configuration {
    /// An error type representing HTML rendering failures.
    ///
    /// This error is thrown when there's a problem rendering HTML content
    /// or when the rendered bytes cannot be converted to a string.
    public struct Error: Swift.Error {
        /// A description of what went wrong during HTML rendering.
        public let message: String
    }
}

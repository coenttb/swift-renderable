//
//  Raw.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// Represents raw, unescaped content.
///
/// `Raw` allows you to insert raw content without any escaping or processing.
/// This is useful when you need to include pre-generated content or for special cases
/// where you need to bypass the normal generation mechanism.
///
/// Example:
/// ```swift
/// var body: some Rendering {
///     Group {
///         // Raw, unescaped content
///         Raw("<custom>content</custom>")
///     }
/// }
/// ```
///
/// - Warning: Using `Raw` with user-provided content can lead to security
///   vulnerabilities such as injection attacks. Only use
///   `Raw` with trusted content that you have full control over.
///
/// Note: This is a simple struct. Domain-specific modules (like RenderingHTML)
/// provide the `Rendering` conformance with the appropriate `Context` type.
public struct Raw: Sendable {
    /// The raw bytes to render.
    public let bytes: ContiguousArray<UInt8>

    /// Creates a new raw content component from a string.
    ///
    /// - Parameter string: The string containing raw content.
    public init(_ string: String) {
        self.init(string.utf8)
    }

    /// Creates a new raw content component from a sequence of bytes.
    ///
    /// - Parameter bytes: The bytes containing raw content.
    public init(_ bytes: some Sequence<UInt8>) {
        self.bytes = ContiguousArray(bytes)
    }
}

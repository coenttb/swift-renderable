//
//  HTMLEmpty.swift
//
//
//  Created by Point-Free, Inc
//

/// Represents an empty HTML node that renders nothing.
///
/// `HTMLEmpty` is a utility type that conforms to the `HTML` protocol but
/// renders no content. It's useful in scenarios where you need to provide
/// HTML content but want it to be empty, such as in conditional rendering
/// or as a default placeholder.
///
/// Example:
/// ```swift
/// // Conditionally render content
/// var content: some HTML {
///     if shouldShowGreeting {
///         h1 { "Hello, World!" }
///     } else {
///         HTMLEmpty()
///     }
/// }
/// ```
///
/// - Note: `HTMLEmpty` is automatically used by the `HTMLBuilder` when no
///   content is provided in a builder block.
public struct HTMLEmpty: HTML, Sendable {
    /// Creates a new empty HTML node.
    public init() {}

    /// Renders nothing (no-op for empty content).
    @inlinable
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {}

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

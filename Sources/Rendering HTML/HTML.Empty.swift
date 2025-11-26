//
//  Empty+HTML.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering
public typealias RenderingEmpty = Empty

/// Represents an empty HTML node that renders nothing.
///
/// `Empty` is a utility type that conforms to the `HTML.View` protocol but
/// renders no content. It's useful in scenarios where you need to provide
/// HTML content but want it to be empty, such as in conditional rendering
/// or as a default placeholder.
///
/// Example:
/// ```swift
/// // Conditionally render content
/// var content: some HTML.View {
///     if shouldShowGreeting {
///         h1 { "Hello, World!" }
///     } else {
///         Empty()
///     }
/// }
/// ```
extension HTML {
    public typealias Empty = RenderingEmpty
}

extension HTML.Empty: Renderable {
    public typealias Content = Never
    public typealias Context = HTML.Context

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Empty,
        into buffer: inout Buffer,
        context: inout HTML.Context
    ) where Buffer.Element == UInt8 {
        // Produces no output
    }

    public var body: Never { fatalError() }
}

extension HTML.Empty: HTML.View {}

extension HTML.Empty: AsyncRenderable {
    /// Async renders nothing (empty content).
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: Empty,
        into stream: Stream,
        context: inout HTML.Context
    ) async {
        // Produces no output
    }
}

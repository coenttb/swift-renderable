//
//  Empty.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

/// Represents an empty HTML node that renders nothing.
///
/// `Empty` is a utility type that conforms to the `HTML` protocol but
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
///         Empty()
///     }
/// }
/// ```
extension Empty: Rendering {
    public typealias Content = Never
    public typealias Context = HTMLContext

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Empty,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        // Produces no output
    }

    public var body: Never { fatalError() }
}

extension Empty: HTML {}

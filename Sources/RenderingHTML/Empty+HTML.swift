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
public typealias Empty = _Empty<HTMLContext>

extension Empty: HTML where Context == HTMLContext {}

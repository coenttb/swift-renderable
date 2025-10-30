//
//  HTMLRaw.swift
//
//
//  Created by Point-Free, Inc
//

/// Represents raw, unescaped HTML content.
///
/// `HTMLRaw` allows you to insert raw HTML content without any escaping or processing.
/// This is useful when you need to include pre-generated HTML or for special cases
/// where you need to bypass the normal HTML generation mechanism.
///
/// Example:
/// ```swift
/// var body: some HTML {
///     div {
///         // Normal, escaped content
///         p { "Regular <p> content will be escaped" }
///
///         // Raw, unescaped content
///         HTMLRaw("<script>console.log('This is raw JS');</script>")
///     }
/// }
/// ```
///
/// - Warning: Using `HTMLRaw` with user-provided content can lead to security
///   vulnerabilities such as cross-site scripting (XSS) attacks. Only use
///   `HTMLRaw` with trusted content that you have full control over.
public struct HTMLRaw: HTML {
  /// The raw bytes to render.
  let bytes: ContiguousArray<UInt8>

  /// Creates a new raw HTML component from a string.
  ///
  /// - Parameter string: The string containing raw HTML content.
  public init(_ string: String) {
    self.init(string.utf8)
  }

  /// Creates a new raw HTML component from a sequence of bytes.
  ///
  /// - Parameter bytes: The bytes containing raw HTML content.
  public init(_ bytes: some Sequence<UInt8>) {
    self.bytes = ContiguousArray(bytes)
  }

  /// Renders the raw HTML bytes directly to the printer without any processing.
  ///
  /// - Parameters:
  ///   - html: The raw HTML to render.
  ///   - printer: The printer to render the HTML into.
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    printer.bytes.append(contentsOf: html.bytes)
  }

  /// This type uses direct rendering and doesn't have a body.
  public var body: Never { fatalError() }
}

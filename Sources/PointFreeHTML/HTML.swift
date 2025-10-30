//
//  HTML.swift
//
//
//  Created by Point-Free, Inc
//

/// A protocol representing an HTML element or component that can be rendered.
///
/// The `HTML` protocol is the core abstraction of the PointFreeHTML library,
/// allowing Swift types to represent HTML content in a declarative, composable manner.
/// It uses a component-based architecture similar to SwiftUI, where each component
/// defines its `body` property to build up a hierarchy of HTML elements.
///
/// Example:
/// ```swift
/// struct MyView: HTML {
///     var body: some HTML {
///         div {
///             h1 { "Hello, World!" }
///             p { "This is a paragraph." }
///         }
///     }
/// }
/// ```
///
/// - Note: This protocol is similar in design to SwiftUI's `View` protocol,
///   making it familiar to Swift developers who have worked with SwiftUI.
public protocol HTML {
  /// The type of HTML content that this HTML element or component contains.
  associatedtype Content: HTML

  /// The body of this HTML element or component, defining its structure and content.
  ///
  /// This property uses the `HTMLBuilder` result builder to allow for a declarative
  /// syntax when defining HTML content, similar to how SwiftUI's ViewBuilder works.
  @HTMLBuilder
  var body: Content { get }

  /// Renders this HTML element or component into the provided printer.
  ///
  /// This method is typically not called directly by users of the library,
  /// but is used internally to convert the HTML tree into rendered output.
  ///
  /// - Parameters:
  ///   - html: The HTML element or component to render.
  ///   - printer: The printer to render the HTML into.
  static func _render(_ html: Self, into printer: inout HTMLPrinter)
}

extension HTML {
  /// Default implementation of the render method that delegates to the body's render method.
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    Content._render(html.body, into: &printer)
  }
}

/// Conformance of `Never` to `HTML` to support the type system.
///
/// This conformance is provided to allow the use of the `HTML` protocol in
/// contexts where no content is expected or possible.
extension Never: HTML {
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {}
  public var body: Never { fatalError() }
}

public struct AnyHTML: HTML {
  let base: any HTML
  public init(_ base: any HTML) {
    self.base = base
  }
  public static func _render(_ html: AnyHTML, into printer: inout HTMLPrinter) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &printer)
    }
    render(html.base)
  }
  public var body: Never { fatalError() }
}

extension AnyHTML {
  public init(
    _ closure: () -> any HTML
  ) {
    self = .init(closure())
  }
}

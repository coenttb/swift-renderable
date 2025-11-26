//
//  AnyHTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

/// Type-erased wrapper for any HTML content.
///
/// `AnyHTML` allows you to work with heterogeneous HTML types
/// by erasing their specific type while preserving their rendering behavior.
///
/// Example:
/// ```swift
/// func makeContent(condition: Bool) -> AnyHTML {
///     if condition {
///         AnyHTML(div { "Hello" })
///     } else {
///         AnyHTML(span { "World" })
///     }
/// }
/// ```
public typealias AnyHTML = AnyRendering<HTMLContext>

extension AnyRendering: Rendering where Context == HTMLContext {
    public typealias Content = Never

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: AnyRendering<HTMLContext>,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        var contiguousBuffer = ContiguousArray<UInt8>()
        html.render(into: &contiguousBuffer, context: &context)
        buffer.append(contentsOf: contiguousBuffer)
    }

    public var body: Never { fatalError() }
}

extension AnyRendering: HTML where Context == HTMLContext {}

extension AnyHTML {
    /// Creates a type-erased HTML wrapper from a builder closure.
    ///
    /// - Parameter closure: A closure that returns any HTML content.
    public init(
        @Builder _ closure: () -> any HTML
    ) {
        self.init(closure())
    }
}

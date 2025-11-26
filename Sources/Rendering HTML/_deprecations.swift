//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension HTML.DocumentProtocol {
    /// Renders this HTML document to bytes.
    ///
    /// This method creates a printer with the current configuration and
    /// renders the HTML document into it, then returns the resulting bytes.
    ///
    /// - Returns: A buffer of bytes representing the rendered HTML document.
    ///
    /// - Warning: This method is deprecated. Use the RFC pattern initialization instead:
    ///   ```swift
    ///   // Old (deprecated)
    ///   let bytes = document.render()
    ///
    ///   // New (RFC pattern - zero-copy)
    ///   let bytes = ContiguousArray(document)
    ///
    ///   // Or for String output
    ///   let string = try String(document)
    ///   ```
    @available(*, deprecated, message: "Use ContiguousArray(html) or String(html) instead. The RFC pattern makes bytes canonical and String derived.")
    public func render() -> ContiguousArray<UInt8> {
        var buffer: ContiguousArray<UInt8> = []
        var context = HTML.Context(HTML.Context.Configuration.current)
        Self._render(self, into: &buffer, context: &context)
        return buffer
    }
}

extension HTML.View {
    // For backwards compatibility. Also for future to transform the Media type into an AtRule.
    @available(*, deprecated, message: "change 'pre' to 'selector'")
    @_disfavoredOverload
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        media mediaQuery: HTML.AtRule.Media? = nil,
        pre selector: HTML.Selector? = nil,
        pseudo: HTML.Pseudo? = nil
    ) -> HTML.InlineStyle<Self> {
        HTML.InlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: mediaQuery,
            selector: selector,
            pseudo: pseudo
        )
    }
}

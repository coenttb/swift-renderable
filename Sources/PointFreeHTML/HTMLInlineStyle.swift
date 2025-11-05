//
//  HTMLInlineStyle.swift
//
//
//  Created by Point-Free, Inc
//

import ConcurrencyExtras
import Dependencies
import Foundation
import OrderedCollections

/// Extension to add inline styling capabilities to all HTML elements.
extension HTML {
    /// Applies a CSS style property to an HTML element.
    ///
    /// This method enables a type-safe, declarative approach to styling HTML elements
    /// directly in Swift code. It generates CSS classes and stylesheets automatically.
    ///
    /// Example:
    /// ```swift
    /// div {
    ///     "Hello, World!"
    /// }
    /// .inlineStyle("color", "red")
    /// .inlineStyle("font-weight", "bold", pseudo: .hover)
    /// ```
    ///
    /// - Parameters:
    ///   - property: The CSS property name (e.g., "color", "margin", "font-size").
    ///   - value: The value for the CSS property. Pass nil to omit this style.
    ///   - atRule: Optional media query to apply this style conditionally.
    ///   - pre: Optional selector prefix for more complex CSS selectors.
    ///   - pseudo: Optional pseudo-class or pseudo-element to apply (e.g., `:hover`, `::before`).
    /// - Returns: An HTML element with the specified style applied.
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        atRule: AtRule? = nil,
        selector: Selector? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        HTMLInlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: atRule,
            selector: selector,
            pseudo: pseudo
        )
    }

    @_disfavoredOverload
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        media: AtRule.Media? = nil,
        selector: Selector? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        HTMLInlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: media,
            selector: selector,
            pseudo: pseudo
        )
    }

    // For backwards compatibility. Also for future to transform the Media type into an AtRule.
    @available(*, deprecated, message: "change 'pre' to 'selector'")
    @_disfavoredOverload
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        media mediaQuery: AtRule.Media? = nil,
        pre selector: Selector? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        HTMLInlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: mediaQuery,
            selector: selector,
            pseudo: pseudo
        )
    }

}

/// A wrapper that applies CSS styles to an HTML element.
///
/// `HTMLInlineStyle` applies CSS styles to HTML elements by generating
/// unique class names and collecting the associated styles in a stylesheet.
/// This approach allows for efficient CSS generation and prevents duplication
/// of styles across multiple elements.
///
/// You typically don't create this type directly but use the `inlineStyle` method
/// on HTML elements.
///
/// Example:
/// ```swift
/// div {
///     p { "Styled text" }
///         .inlineStyle("color", "blue")
///         .inlineStyle("margin", "1rem")
/// }
/// ```
public struct HTMLInlineStyle<Content: HTML>: HTML {
    /// The HTML content being styled.
    private let content: Content

    /// The collection of styles to apply.
    private var styles: [Style]

    /// Generator for unique class names based on styles.
    @Dependency(ClassNameGenerator.self) fileprivate var classNameGenerator

    /// Creates a new styled HTML element.
    ///
    /// - Parameters:
    ///   - content: The HTML element to style.
    ///   - property: The CSS property name.
    ///   - value: The value for the CSS property.
    ///   - mediaQuery: Optional media query for conditional styling.
    ///   - selector: Optional selector prefix.
    ///   - pseudo: Optional pseudo-class or pseudo-element.
    init(
        content: Content,
        property: String,
        value: String?,
        atRule: AtRule?,
        selector: Selector? = nil,
        pseudo: Pseudo?
    ) {
        self.content = content
        self.styles =
            value.map {
                [
                    Style(
                        property: property,
                        value: $0,
                        atRule: atRule,
                        selector: selector,
                        pseudo: pseudo
                    )
                ]
            }
            ?? []
    }

    /// Adds an additional style to this element.
    ///
    /// This method allows for chaining multiple styles on a single element.
    ///
    /// Example:
    /// ```swift
    /// div { "Content" }
    ///     .inlineStyle("color", "blue")
    ///     .inlineStyle("font-size", "16px")
    /// ```
    ///
    /// - Parameters:
    ///   - property: The CSS property name.
    ///   - value: The value for the CSS property.
    ///   - mediaQuery: Optional media query for conditional styling.
    ///   - pre: Optional selector prefix.
    ///   - pseudo: Optional pseudo-class or pseudo-element.
    /// - Returns: An HTML element with both the original and new styles applied.
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        atRule: AtRule? = nil,
        selector: Selector? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle {
        var copy = self
        if let value {
            copy.styles.append(
                Style(
                    property: property,
                    value: value,
                    atRule: atRule,
                    selector: selector,
                    pseudo: pseudo
                )
            )
        }
        return copy
    }

    // Optimized rendering with simplified logic
    public static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
        let previousClass = printer.attributes["class"]
        defer { printer.attributes["class"] = previousClass }

        // Collect all styles from nested elements
        var allStyles: [Style] = []
        var coreContent: any HTML = html

        // Flatten style chain
        while let styledElement = coreContent as? any HTMLInlineStyleProtocol {
            allStyles.append(contentsOf: styledElement.extractStyles())
            coreContent = styledElement.extractContent()
        }

        guard !allStyles.isEmpty else {
            coreContent.render(into: &printer)
            return
        }

        // Generate class names and apply styles
        let classNames = html.classNameGenerator.generateBatch(allStyles)
        var classComponents: [String] = []
        classComponents.reserveCapacity(classNames.count)

        for (style, className) in zip(allStyles, classNames) {
            let selector = buildSelector(className: className, style: style)

            // Add to stylesheet if not present
            if printer.styles[style.atRule, default: [:]][selector] == nil {
                printer.styles[style.atRule, default: [:]][selector] =
                    "\(style.property):\(style.value)"
            }

            classComponents.append(className)
        }

        // Apply class names
        if let existingClass = printer.attributes["class"] {
            printer.attributes["class"] =
                "\(existingClass) \(classComponents.joined(separator: " "))"
        } else {
            printer.attributes["class"] = classComponents.joined(separator: " ")
        }

        coreContent.render(into: &printer)
    }

    // Helper function to build CSS selector
    private static func buildSelector(className: String, style: Style) -> String {
        var selector = ".\(className)"

        if let pre = style.selector?.rawValue {
            selector = "\(pre) " + selector
        }

        if let pseudo = style.pseudo?.rawValue {
            selector += pseudo
        }

        return selector
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

private final class StyleManager: @unchecked Sendable {
    static let shared = StyleManager()

    private let state = LockIsolated<(seenStyles: OrderedSet<Style>, styleToIndex: [Style: Int])>(
        ([], [:])
    )

    private init() {}

    func getClassName(for style: Style) -> String {
        let index = state.withValue { state in
            if let cachedIndex = state.styleToIndex[style] {
                return cachedIndex
            } else {
                let index = state.seenStyles.count
                state.seenStyles.append(style)
                state.styleToIndex[style] = index
                return index
            }
        }

        #if DEBUG
            return "\(style.property)-\(index)"
        #else
            return "c\(index)"
        #endif
    }

    func getClassNames(for styles: [Style]) -> [String] {
        guard !styles.isEmpty else { return [] }

        let indices = state.withValue { state in
            var results: [Int] = []
            results.reserveCapacity(styles.count)

            for style in styles {
                let index: Int
                if let cachedIndex = state.styleToIndex[style] {
                    index = cachedIndex
                } else {
                    index = state.seenStyles.count
                    state.seenStyles.append(style)
                    state.styleToIndex[style] = index
                }
                results.append(index)
            }

            return results
        }

        return zip(styles, indices).map { style, index in
            #if DEBUG
                "\(style.property)-\(index)"
            #else
                "c\(index)"
            #endif
        }
    }
}

private struct ClassNameGenerator: DependencyKey {
    var generate: @Sendable (Style) -> String
    var generateBatch: @Sendable ([Style]) -> [String]

    static var liveValue: ClassNameGenerator {
        return Self(
            generate: { style in
                StyleManager.shared.getClassName(for: style)
            },
            generateBatch: { styles in
                StyleManager.shared.getClassNames(for: styles)
            }
        )
    }

    static var testValue: ClassNameGenerator {
        Self(
            generate: { style in
                let hash = classID(
                    style.value
                        + (style.atRule?.rawValue ?? "")
                        + (style.selector?.rawValue ?? "")
                        + (style.pseudo?.rawValue ?? "")
                )
                return "\(style.property)-\(hash)"
            },
            generateBatch: { styles in
                styles.map { style in
                    let hash = classID(
                        style.value
                            + (style.atRule?.rawValue ?? "")
                            + (style.selector?.rawValue ?? "")
                            + (style.pseudo?.rawValue ?? "")
                    )
                    return "\(style.property)-\(hash)"
                }
            }
        )
    }
}

internal struct Style: Hashable, Sendable {
    let property: String
    let value: String
    let atRule: AtRule?
    let selector: Selector?
    let pseudo: Pseudo?
}

// Protocol to enable type erasure for HTMLInlineStyle
protocol HTMLInlineStyleProtocol {
    func extractStyles() -> [Style]
    func extractContent() -> any HTML
}

// Make HTMLInlineStyle conform to the protocol
extension HTMLInlineStyle: HTMLInlineStyleProtocol {
    func extractStyles() -> [Style] {
        return styles
    }

    func extractContent() -> any HTML {
        return content
    }
}

// Add this method to your HTML protocol
extension HTML {
    func render(into printer: inout HTMLPrinter) {
        Self._render(self, into: &printer)
    }
}

private func classID(_ value: String) -> String {
    return encode(murmurHash(value))

    func encode(_ value: UInt32) -> String {
        guard value > 0
        else { return "" }
        var number = value
        var encoded = ""
        encoded.reserveCapacity(Int(log(Double(number)) / log(64)) + 1)
        while number > 0 {
            let index = Int(number % baseCount)
            number /= baseCount
            encoded.append(baseChars[index])
        }

        return encoded
    }
    func murmurHash(_ string: String) -> UInt32 {
        let data = [UInt8](string.utf8)
        let length = data.count
        let c1: UInt32 = 0xcc9e_2d51
        let c2: UInt32 = 0x1b87_3593
        let r1: UInt32 = 15
        let r2: UInt32 = 13
        let m: UInt32 = 5
        let n: UInt32 = 0xe654_6b64

        var hash: UInt32 = 0

        let chunkSize = MemoryLayout<UInt32>.size
        let chunks = length / chunkSize

        for i in 0..<chunks {
            var k: UInt32 = 0
            let offset = i * chunkSize

            for j in 0..<chunkSize {
                k |= UInt32(data[offset + j]) << (j * 8)
            }

            k &*= c1
            k = (k << r1) | (k >> (32 - r1))
            k &*= c2

            hash ^= k
            hash = (hash << r2) | (hash >> (32 - r2))
            hash = hash &* m &+ n
        }

        var k1: UInt32 = 0
        let tailStart = chunks * chunkSize

        switch length & 3 {
        case 3:
            k1 ^= UInt32(data[tailStart + 2]) << 16
            fallthrough
        case 2:
            k1 ^= UInt32(data[tailStart + 1]) << 8
            fallthrough
        case 1:
            k1 ^= UInt32(data[tailStart])
            k1 &*= c1
            k1 = (k1 << r1) | (k1 >> (32 - r1))
            k1 &*= c2
            hash ^= k1
        default:
            break
        }

        hash ^= UInt32(length)
        hash ^= (hash >> 16)
        hash &*= 0x85eb_ca6b
        hash ^= (hash >> 13)
        hash &*= 0xc2b2_ae35
        hash ^= (hash >> 16)

        return hash
    }
}
private let baseChars = Array("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
private let baseCount = UInt32(baseChars.count)

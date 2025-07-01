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
    ///   - mediaQuery: Optional media query to apply this style conditionally.
    ///   - pre: Optional selector prefix for more complex CSS selectors.
    ///   - pseudo: Optional pseudo-class or pseudo-element to apply (e.g., `:hover`, `::before`).
    /// - Returns: An HTML element with the specified style applied.
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        media mediaQuery: MediaQuery? = nil,
        pre: String? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        HTMLInlineStyle(
            content: self,
            property: property,
            value: value,
            mediaQuery: mediaQuery,
            pre: pre,
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
    ///   - pre: Optional selector prefix.
    ///   - pseudo: Optional pseudo-class or pseudo-element.
    init(
        content: Content,
        property: String,
        value: String?,
        mediaQuery: MediaQuery?,
        pre: String? = nil,
        pseudo: Pseudo?
    ) {
        self.content = content
        self.styles =
        value.map {
            [
                Style(
                    property: property,
                    value: $0,
                    media: mediaQuery,
                    preSelector: pre,
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
        media mediaQuery: MediaQuery? = nil,
        pre: String? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle {
        var copy = self
        if let value {
            copy.styles.append(
                Style(
                    property: property,
                    value: value,
                    media: mediaQuery,
                    preSelector: pre,
                    pseudo: pseudo
                )
            )
        }
        return copy
    }
    
    /// Renders this styled HTML element into the provided printer.
    ///
    /// This method:
    /// 1. Saves the current class attribute
    /// 2. Generates unique class names for each style
    /// 3. Adds the styles to the printer's stylesheet
    /// 4. Adds the class names to the element's class attribute
    /// 5. Renders the content
    /// 6. Restores the original class attribute
    ///
    /// - Parameters:
    ///   - html: The styled HTML element to render.
    ///   - printer: The printer to render the HTML into.
//    public static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
//        let previousClass = printer.attributes["class"]  // TODO: should we optimize this?
//        defer {
//            Content._render(html.content, into: &printer)
//            printer.attributes["class"] = previousClass
//        }
//        
//        for style in html.styles {
//            let className = html.classNameGenerator.generate(style)
//            let selector = """
//        \(style.preSelector.map { "\($0) " } ?? "").\(className)\(style.pseudo?.rawValue ?? "")
//        """
//            
//            if printer.styles[style.media, default: [:]][selector] == nil {
//                printer.styles[style.media, default: [:]][selector] = "\(style.property):\(style.value)"
//            }
//            printer
//                .attributes["class", default: ""]
//                .append(printer.attributes.keys.contains("class") ? " \(className)" : className)
//        }
//    }
    // Now update the batched processing render method
    public static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
        let previousClass = printer.attributes["class"]
        
        // Collect all styles from nested HTMLInlineStyle elements
        var allStyles: [Style] = []
        var coreContent: any HTML = html
        
        // Flatten the style chain iteratively using a protocol approach
        while let styledElement = coreContent as? any HTMLInlineStyleProtocol {
            allStyles.append(contentsOf: styledElement.extractStyles())
            coreContent = styledElement.extractContent()
        }
        
        // Process all styles at once
        var classNames: [String] = []
        for style in allStyles {
            let className = html.classNameGenerator.generate(style)
            let selector = """
        \(style.preSelector.map { "\($0) " } ?? "").\(className)\(style.pseudo?.rawValue ?? "")
        """
            
            if printer.styles[style.media, default: [:]][selector] == nil {
                printer.styles[style.media, default: [:]][selector] = "\(style.property):\(style.value)"
            }
            classNames.append(className)
        }
        
        // Apply all class names at once
        if !classNames.isEmpty {
            let existingClass = printer.attributes["class"] ?? ""
            let separator = existingClass.isEmpty ? "" : " "
            printer.attributes["class"] = existingClass + separator + classNames.joined(separator: " ")
        }
        
        // Render the core content using the instance method
        defer { printer.attributes["class"] = previousClass }
        coreContent.render(into: &printer)
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

private struct ClassNameGenerator: DependencyKey {
    var generate: @Sendable (Style) -> String
    
    static var liveValue: ClassNameGenerator {
        let seenStyles = LockIsolated<OrderedSet<Style>>([])
        return Self { style in
            seenStyles.withValue { seenStyles in
                let index =
                seenStyles.firstIndex(of: style)
                ?? {
                    seenStyles.append(style)
                    return seenStyles.count - 1
                }()
#if DEBUG
                return "\(style.property)-\(index)"
#else
                return "c\(index)"
#endif
            }
        }
    }
    
    static var testValue: ClassNameGenerator {
        Self { style in
            let hash = classID(
                style.value
                + (style.media?.rawValue ?? "")
                + (style.preSelector ?? "")
                + (style.pseudo?.rawValue ?? "")
            )
            return "\(style.property)-\(hash)"
        }
    }
}

internal struct Style: Hashable, Sendable {
    let property: String
    let value: String
    let media: MediaQuery?
    let preSelector: String?
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



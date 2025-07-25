//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 16/04/2025.
//

/// Represents CSS pseudo-classes and pseudo-elements for targeting element states and parts.
///
/// `Pseudo` provides a type-safe way to apply CSS pseudo-classes and pseudo-elements
/// in PointFreeHTML. Pseudo-classes target elements in specific states (like `:hover`,
/// `:focus`, `:disabled`), while pseudo-elements target specific parts of elements
/// (like `::before`, `::after`, `::first-line`).
///
/// ## Basic Usage
///
/// ```swift
/// // Most common: using string literals
/// button { "Click me" }
///     .inlineStyle("background-color", "blue")
///     .inlineStyle("background-color", "red", pseudo: ":hover")
/// 
/// // Using static properties (equivalent)
/// let hover: Pseudo = .hover
/// button { "Click me" }
///     .inlineStyle("background-color", "red", pseudo: .hover)
/// 
/// // Pseudo-element for generated content
/// div { "Content" }
///     .inlineStyle("content", "\"★\"", pseudo: "::before")
/// ```
///
/// ## Pseudo-Classes vs Pseudo-Elements
///
/// **Pseudo-classes** (single colon `:`) target elements based on their state:
/// - `:hover` - when user hovers over element
/// - `:focus` - when element has keyboard focus
/// - `:disabled` - when form element is disabled
/// - `:first-child` - first child element
///
/// **Pseudo-elements** (double colon `::`) target parts of elements:
/// - `::before` - generated content before element
/// - `::after` - generated content after element  
/// - `::first-line` - first line of text content
///
/// ## Combining Pseudo-Selectors
///
/// Use the `+` operator to combine multiple pseudo-selectors:
///
/// ```swift
/// // Using string literals (most common)
/// let combined: Pseudo = ":not(:disabled):hover"
/// 
/// // Or combining static properties
/// let notDisabled: Pseudo = .not(.disabled)
/// let combined: Pseudo = notDisabled + .hover
/// 
/// input { "" }
///     .inlineStyle("border-color", "blue", pseudo: .init(rawValue: ":not(:disabled):hover"))
/// // Generates: input:not(:disabled):hover { border-color: blue; }
/// ```
///
/// ## Functional Pseudo-Classes
///
/// Some pseudo-classes accept parameters:
///
/// ```swift
/// // Using string literals (most common)
/// li { "Item" }
///     .inlineStyle("color", "red", pseudo: ":nth-child(odd)")
///     .inlineStyle("color", "blue", pseudo: ":nth-child(2n+1)")
/// 
/// // Using static functions (equivalent)
/// let oddChild: Pseudo = .nthChild("odd")
/// li { "Item" }
///     .inlineStyle("color", "red", pseudo: .nthChild("odd"))
/// 
/// // Negation pseudo-class
/// button { "Button" }
///     .inlineStyle("opacity", "0.5", pseudo: ":not(:enabled)")
/// ```
public struct Pseudo: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    /// The CSS pseudo-class or pseudo-element selector.
    public var rawValue: String
    
    /// Creates a pseudo-selector with the specified CSS selector string.
    ///
    /// - Parameter rawValue: The CSS pseudo-selector string (e.g., ":hover", "::before").
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Creates a pseudo-selector from a string literal.
    ///
    /// This allows you to write:
    /// ```swift
    /// let custom: Pseudo = ":custom-state"
    /// ```
    ///
    /// - Parameter value: The CSS pseudo-selector string.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: - Pseudo-Selector Combination
extension Pseudo {
    /// Combines two pseudo-selectors into a single compound pseudo-selector.
    ///
    /// This operator allows you to chain multiple pseudo-classes or pseudo-elements
    /// together. This is useful for creating complex state-based selectors.
    ///
    /// ```swift
    /// // Using string literals (most common)
    /// let focusedEnabled: Pseudo = ":not(:disabled):focus"
    /// 
    /// // Or combining static properties
    /// let focusedEnabled: Pseudo = .not(.disabled) + .focus
    /// 
    /// input { "" }
    ///     .inlineStyle("border-color", "blue", pseudo: .init(rawValue: ":not(:disabled):focus"))
    /// // Generates: input:not(:disabled):focus { border-color: blue; }
    /// ```
    ///
    /// - Parameters:
    ///   - lhs: The first pseudo-selector.
    ///   - rhs: The second pseudo-selector to combine.
    /// - Returns: A new pseudo-selector representing the combination.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue + rhs.rawValue)
    }
}

// MARK: - Pseudo-Elements
extension Pseudo {
    /// Pseudo-elements target specific parts of elements and create virtual elements.
    /// They use double colon (::) syntax and are used for styling generated content
    /// or specific portions of element content.
    
    /// `::after` pseudo-element creates a virtual element after the element's content.
    ///
    /// Used with the `content` CSS property to insert generated content.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// div { "Text" }
    ///     .inlineStyle("content", "\" (suffix)\"", pseudo: "::after")
    /// 
    /// // Using static property (equivalent)
    /// let after: Pseudo = .after
    /// div { "Text" }
    ///     .inlineStyle("content", "\" (suffix)\"", pseudo: .after)
    /// ```
    public static let after: Self = "::after"
    
    /// `::before` pseudo-element creates a virtual element before the element's content.
    ///
    /// Used with the `content` CSS property to insert generated content.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// div { "Text" }
    ///     .inlineStyle("content", "\"★ \"", pseudo: "::before")
    /// 
    /// // Using static property (equivalent)
    /// let before: Pseudo = .before
    /// div { "Text" }
    ///     .inlineStyle("content", "\"★ \"", pseudo: .before)
    /// ```
    public static let before: Self = "::before"
    
    /// `::first-line` pseudo-element targets the first line of text in a block element.
    ///
    /// Useful for styling drop caps or emphasizing opening lines.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// p { "Long paragraph text..." }
    ///     .inlineStyle("font-weight", "bold", pseudo: "::first-line")
    /// 
    /// // Using static property (equivalent)
    /// let firstLine: Pseudo = .firstLine
    /// p { "Long paragraph text..." }
    ///     .inlineStyle("font-weight", "bold", pseudo: .firstLine)
    /// ```
    public static let firstLine: Self = "::first-line"
}
 
// MARK: - Pseudo-Classes
extension Pseudo {
    /// Pseudo-classes target elements based on their state or position.
    /// They use single colon (:) syntax and are applied when elements
    /// meet specific conditions or are in particular states.
    
    // MARK: Interactive States
    
    /// `:active` targets elements during activation (e.g., mouse click).
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// button { "Click me" }
    ///     .inlineStyle("background-color", "darkblue", pseudo: ":active")
    /// 
    /// // Using static property (equivalent)
    /// let active: Pseudo = .active
    /// button { "Click me" }
    ///     .inlineStyle("background-color", "darkblue", pseudo: .active)
    /// ```
    public static let active: Self = ":active"
    
    /// `:hover` targets elements when the user hovers over them.
    ///
    /// ```swift
    /// a { "Link" }
    ///     .inlineStyle("color", "red", pseudo: ":hover")
    /// ```
    public static let hover: Self = ":hover"
    
    /// `:focus` targets elements that have keyboard focus.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "blue", pseudo: ":focus")
    /// ```
    public static let focus: Self = ":focus"
    
    /// `:visited` targets visited links.
    ///
    /// ```swift
    /// a { "Link" }
    ///     .inlineStyle("color", "purple", pseudo: ":visited")
    /// ```
    public static let visited: Self = ":visited"
    
    /// `:link` targets unvisited links.
    ///
    /// ```swift
    /// a { "Link" }
    ///     .inlineStyle("color", "blue", pseudo: ":link")
    /// ```
    public static let link: Self = ":link"
    
    // MARK: Form States
    
    /// `:checked` targets checked form elements (checkboxes, radio buttons).
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("accent-color", "green", pseudo: ":checked")
    /// ```
    public static let checked: Self = ":checked"
    
    /// `:disabled` targets disabled form elements.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("opacity", "0.5", pseudo: ":disabled")
    /// ```
    public static let disabled: Self = ":disabled"
    
    /// `:enabled` targets enabled form elements.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "black", pseudo: ":enabled")
    /// ```
    public static let enabled: Self = ":enabled"
    
    /// `:required` targets form elements with the required attribute.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "red", pseudo: ":required")
    /// ```
    public static let required: Self = ":required"
    
    /// `:optional` targets form elements without the required attribute.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "gray", pseudo: ":optional")
    /// ```
    public static let optional: Self = ":optional"
    
    /// `:valid` targets form elements with valid values.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "green", pseudo: ":valid")
    /// ```
    public static let valid: Self = ":valid"
    
    /// `:invalid` targets form elements with invalid values.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "red", pseudo: ":invalid")
    /// ```
    public static let invalid: Self = ":invalid"
    
    /// `:in-range` targets input elements whose values are within specified range.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "green", pseudo: ":in-range")
    /// ```
    public static let inRange: Self = ":in-range"
    
    /// `:out-of-range` targets input elements whose values are outside specified range.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("border-color", "red", pseudo: ":out-of-range")
    /// ```
    public static let outOfRange: Self = ":out-of-range"
    
    /// `:read-only` targets read-only form elements.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("background-color", "lightgray", pseudo: ":read-only")
    /// ```
    public static let readOnly: Self = ":read-only"
    
    /// `:read-write` targets editable form elements.
    ///
    /// ```swift
    /// input { "" }
    ///     .inlineStyle("background-color", "white", pseudo: ":read-write")
    /// ```
    public static let readWrite: Self = ":read-write"
    
    // MARK: Structural Pseudo-Classes
    
    /// `:first-child` targets the first child element.
    ///
    /// ```swift
    /// li { "First item" }
    ///     .inlineStyle("font-weight", "bold", pseudo: ":first-child")
    /// ```
    public static let firstChild: Self = ":first-child"
    
    /// `:last-child` targets the last child element.
    ///
    /// ```swift
    /// li { "Last item" }
    ///     .inlineStyle("margin-bottom", "0", pseudo: ":last-child")
    /// ```
    public static let lastChild: Self = ":last-child"
    
    /// `:only-child` targets elements that are the only child of their parent.
    ///
    /// ```swift
    /// p { "Only paragraph" }
    ///     .inlineStyle("text-align", "center", pseudo: ":only-child")
    /// ```
    public static let onlyChild: Self = ":only-child"
    
    /// `:first-of-type` targets the first element of its type among siblings.
    ///
    /// ```swift
    /// h2 { "First heading" }
    ///     .inlineStyle("margin-top", "0", pseudo: ":first-of-type")
    /// ```
    public static let firstOfType: Self = ":first-of-type"
    
    /// `:last-of-type` targets the last element of its type among siblings.
    ///
    /// ```swift
    /// p { "Last paragraph" }
    ///     .inlineStyle("margin-bottom", "0", pseudo: ":last-of-type")
    /// ```
    public static let lastOfType: Self = ":last-of-type"
    
    /// `:only-of-type` targets elements that are the only one of their type among siblings.
    ///
    /// ```swift
    /// img { }
    ///     .inlineStyle("display", "block", pseudo: ":only-of-type")
    /// ```
    public static let onlyOfType: Self = ":only-of-type"
    
    // MARK: Content States
    
    /// `:empty` targets elements with no children or text content.
    ///
    /// ```swift
    /// div { "" }
    ///     .inlineStyle("display", "none", pseudo: ":empty")
    /// ```
    public static let empty: Self = ":empty"
    
    /// `:root` targets the root element of the document (usually `<html>`).
    ///
    /// ```swift
    /// // Apply to document root
    /// let rootStyle = inlineStyle("font-size", "16px", pseudo: ":root")
    /// ```
    public static let root: Self = ":root"
    
    /// `:target` targets elements that are the target of a fragment identifier.
    ///
    /// ```swift
    /// section { "Content" }
    ///     .inlineStyle("background-color", "yellow", pseudo: ":target")
    /// ```
    public static let target: Self = ":target"
    
    // MARK: Language
    
    /// `:lang` base for language pseudo-class (needs parameter).
    ///
    /// Use with specific language codes in custom implementations.
    /// For parameterized version, create custom pseudo-selector.
    public static let lang: Self = ":lang"
    
    // MARK: Functional Pseudo-Classes
    
    /// `:nth-child()` targets elements based on their position among siblings.
    ///
    /// Accepts various patterns:
    /// - Numbers: `1`, `2`, `3`
    /// - Keywords: `odd`, `even`  
    /// - Formulas: `2n+1`, `3n`, `-n+3`
    ///
    /// ```swift
    /// // Using string literals (most common)
    /// tr { }
    ///     .inlineStyle("background-color", "lightgray", pseudo: ":nth-child(even)")
    ///     .inlineStyle("background-color", "white", pseudo: ":nth-child(odd)")
    /// 
    /// // Using static function (equivalent)
    /// let evenChild: Pseudo = .nthChild("even")
    /// tr { }
    ///     .inlineStyle("background-color", "lightgray", pseudo: .nthChild("even"))
    /// ```
    ///
    /// - Parameter n: The nth-child pattern (number, keyword, or formula).
    /// - Returns: A pseudo-selector for the nth child.
    public static func nthChild(_ n: any CustomStringConvertible) -> Self { 
        ":nth-child(\(n))" 
    }
    
    /// `:nth-last-child()` targets elements based on their position from the end.
    ///
    /// ```swift
    /// li { "Item" }
    ///     .inlineStyle("color", "red", pseudo: ":nth-last-child(2)")
    /// ```
    ///
    /// - Parameter n: The nth-last-child pattern.
    /// - Returns: A pseudo-selector for the nth child from the end.
    public static func nthLastChild(_ n: any CustomStringConvertible) -> Self { 
        ":nth-last-child(\(n))" 
    }
    
    /// `:nth-of-type()` targets elements based on their position among siblings of the same type.
    ///
    /// ```swift
    /// h2 { "Heading" }
    ///     .inlineStyle("color", "blue", pseudo: ":nth-of-type(2)")
    /// ```
    ///
    /// - Parameter n: The nth-of-type pattern.
    /// - Returns: A pseudo-selector for the nth element of its type.
    public static func nthOfType(_ n: any CustomStringConvertible) -> Self { 
        ":nth-of-type(\(n))" 
    }
    
    /// `:nth-last-of-type()` targets elements based on their position from the end among same type.
    ///
    /// ```swift
    /// p { "Paragraph" }
    ///     .inlineStyle("margin-bottom", "0", pseudo: ":nth-last-of-type(1)")
    /// ```
    ///
    /// - Parameter n: The nth-last-of-type pattern.
    /// - Returns: A pseudo-selector for the nth element of its type from the end.
    public static func nthLastOfType(_ n: any CustomStringConvertible) -> Self { 
        ":nth-last-of-type(\(n))" 
    }
    
    /// `:is()` matches elements that match any of the provided selectors.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// let headings: Pseudo = ":is(h1, h2, h3)"
    /// 
    /// // Using static function (equivalent)
    /// let headings: Pseudo = .is("h1, h2, h3")
    /// ```
    ///
    /// - Parameter s: A selector list or compound selector.
    /// - Returns: A pseudo-selector that matches any of the provided selectors.
    public static func `is`(_ s: any CustomStringConvertible) -> Self { 
        ":is(\(s))" 
    }
    
    /// `:not()` matches elements that do NOT match the provided selector.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// input { "" }
    ///     .inlineStyle("background-color", "white", pseudo: ":not(:disabled)")
    /// 
    /// // Using static function (equivalent)
    /// let notDisabled: Pseudo = .not(.disabled)
    /// input { "" }
    ///     .inlineStyle("background-color", "white", pseudo: .not(.disabled))
    /// ```
    ///
    /// - Parameter other: The pseudo-selector to negate.
    /// - Returns: A pseudo-selector that matches elements not matching the input.
    public static func not(_ other: Self) -> Self { 
        ":not(\(other.rawValue))" 
    }
}

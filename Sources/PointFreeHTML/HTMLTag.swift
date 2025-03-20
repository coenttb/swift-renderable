//
//  HTMLTag.swift
//
//
//  Created by Point-Free, Inc
//

/// Represents a standard HTML tag that can contain other HTML elements.
///
/// `HTMLTag` provides a convenient way to create HTML elements with a function-call
/// syntax. It supports both empty elements and elements with content.
///
/// Example:
/// ```swift
/// // Empty div
/// let emptyDiv = div()
///
/// // Div with content
/// let contentDiv = div {
///     h1 { "Title" }
///     p { "Paragraph" }
/// }
/// ```
///
/// This struct is primarily used through the predefined tag variables like `div`, `span`,
/// `h1`, etc., but can also be used directly with custom tag names.
public struct HTMLTag: ExpressibleByStringLiteral {
    /// The name of the HTML tag.
    public let rawValue: String
    
    /// Creates a new HTML tag with the specified name.
    ///
    /// - Parameter rawValue: The name of the HTML tag.
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Creates a new HTML tag from a string literal.
    ///
    /// - Parameter value: The string literal representing the tag name.
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    /// Creates an empty HTML element with this tag.
    ///
    /// This allows using tags as functions, e.g. `div()`.
    ///
    /// - Returns: An empty HTML element with this tag.
    public func callAsFunction() -> HTMLElement<HTMLEmpty> {
        tag(self.rawValue)
    }
    
    /// Creates an HTML element with this tag and the provided content.
    ///
    /// This allows using tags as functions with closures, e.g. `div { ... }`.
    ///
    /// - Parameter content: A closure that returns the content for this element.
    /// - Returns: An HTML element with this tag and the provided content.
    public func callAsFunction<T: HTML>(@HTMLBuilder _ content: () -> T) -> HTMLElement<T> {
        tag(self.rawValue, content)
    }
}

/// Represents an HTML tag that typically contains text content.
///
/// `HTMLTextTag` is a specialization of HTML tags for elements that primarily
/// contain text content, such as `title`, `option`, and `textarea`. It provides
/// a simpler API for setting text content.
///
/// Example:
/// ```swift
/// // Empty title
/// let emptyTitle = title()
///
/// // Title with text
/// let contentTitle = title("Page Title")
///
/// // Title with dynamic text
/// let dynamicTitle = title { getPageTitle() }
/// ```
public struct HTMLTextTag: ExpressibleByStringLiteral {
    /// The name of the HTML tag.
    public let rawValue: String
    
    /// Creates a new HTML text tag with the specified name.
    ///
    /// - Parameter rawValue: The name of the HTML tag.
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Creates a new HTML text tag from a string literal.
    ///
    /// - Parameter value: The string literal representing the tag name.
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    /// Creates an HTML element with this tag and the provided text content.
    ///
    /// - Parameter content: The text content for this element.
    /// - Returns: An HTML element with this tag and the provided text content.
    public func callAsFunction(_ content: String = "") -> HTMLElement<HTMLText> {
        tag(self.rawValue) { HTMLText(content) }
    }
    
    /// Creates an HTML element with this tag and dynamically generated text content.
    ///
    /// - Parameter content: A closure that returns the text content for this element.
    /// - Returns: An HTML element with this tag and the provided text content.
    public func callAsFunction(_ content: () -> String) -> HTMLElement<HTMLText> {
        tag(self.rawValue) { HTMLText(content()) }
    }
}

/// Represents an HTML void element that cannot contain content.
///
/// `HTMLVoidTag` is a specialization of HTML tags for elements that are
/// self-closing and cannot contain content, such as `img`, `br`, and `input`.
///
/// Example:
/// ```swift
/// // Create an image element
/// let image = img().src("image.jpg").alt("An image")
///
/// // Create a line break
/// let lineBreak = br()
/// ```
public struct HTMLVoidTag: ExpressibleByStringLiteral {
    /// A set of all HTML void element tag names.
    public static let allTags: Set<String> = [
        "area",
        "base",
        "br",
        "col",
        "command",
        "embed",
        "hr",
        "img",
        "input",
        "keygen",
        "link",
        "meta",
        "param",
        "source",
        "track",
        "wbr",
    ]
    
    /// The name of the HTML void tag.
    public let rawValue: String
    
    /// Creates a new HTML void tag with the specified name.
    ///
    /// - Parameter rawValue: The name of the HTML void tag.
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Creates a new HTML void tag from a string literal.
    ///
    /// - Parameter value: The string literal representing the tag name.
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    /// Creates an HTML void element with this tag.
    ///
    /// - Returns: An HTML void element with this tag.
    public func callAsFunction() -> HTMLElement<HTMLEmpty> {
        tag(self.rawValue) { HTMLEmpty() }
    }
}

/// Creates an HTML element with the specified tag and content.
///
/// This function is the core builder for HTML elements, allowing you to create
/// elements with any tag name and content. It's generally used through the predefined
/// tag variables like `div`, `span`, etc., but can be used directly for custom tags.
///
/// Example:
/// ```swift
/// // Standard tag
/// let div = tag("div") {
///     p { "Content" }
/// }
///
/// // Custom tag
/// let customElement = tag("custom-element") {
///     "Custom content"
/// }
/// ```
///
/// - Parameters:
///   - tag: The name of the HTML tag.
///   - content: A closure that returns the content for this element.
/// - Returns: An HTML element with the specified tag and content.
public func tag<T: HTML>(
    _ tag: String,
    @HTMLBuilder _ content: () -> T = { HTMLEmpty() }
) -> HTMLElement<T> {
    HTMLElement(tag: tag, content: content)
}

public var a: HTMLTag { #function }
public var abbr: HTMLTag { #function }
public var acronym: HTMLTag { #function }
public var address: HTMLTag { #function }
public var applet: HTMLTag { #function }
public var area: HTMLVoidTag { #function }
public var article: HTMLTag { #function }
public var aside: HTMLTag { #function }
public var audio: HTMLTag { #function }
public var b: HTMLTag { #function }
public var base: HTMLVoidTag { #function }
public var basefront: HTMLTag { #function }
public var bdi: HTMLTag { #function }
public var bdo: HTMLTag { #function }
public var big: HTMLTag { #function }
public var blockquote: HTMLTag { #function }
@available(*, unavailable, message: "Use 'HTMLDocument.body', instead.")
public var body: HTMLTag { #function }
public var br: HTMLVoidTag { #function }
public var button: HTMLTag { #function }
public var canvas: HTMLTag { #function }
public var caption: HTMLTag { #function }
public var center: HTMLTag { #function }
public var cite: HTMLTag { #function }
public var code: HTMLTag { #function }
public var col: HTMLVoidTag { #function }
public var colgroup: HTMLTag { #function }
public var command: HTMLVoidTag { #function }
public var data: HTMLTag { #function }
public var datalist: HTMLTag { #function }
public var dd: HTMLTag { #function }
public var del: HTMLTag { #function }
public var details: HTMLTag { #function }
public var dfn: HTMLTag { #function }
public var dialog: HTMLTag { #function }
public var dir: HTMLTag { #function }
public var div: HTMLTag { #function }
public var dl: HTMLTag { #function }
public var dt: HTMLTag { #function }
public var em: HTMLTag { #function }
public var embed: HTMLVoidTag { #function }
public var fieldset: HTMLTag { #function }
public var figcaption: HTMLTag { #function }
public var figure: HTMLTag { #function }
public var font: HTMLTag { #function }
public var footer: HTMLTag { #function }
public var form: HTMLTag { #function }
public var frame: HTMLTag { #function }
public var frameset: HTMLTag { #function }
public var h1: HTMLTag { #function }
public var h2: HTMLTag { #function }
public var h3: HTMLTag { #function }
public var h4: HTMLTag { #function }
public var h5: HTMLTag { #function }
public var h6: HTMLTag { #function }
@available(*, unavailable, message: "Use 'HTMLDocument.head', instead.")
public var head: HTMLTag { #function }
public var header: HTMLTag { #function }
public var hr: HTMLVoidTag { #function }
public var html: HTMLTag { #function }
public var i: HTMLTag { #function }
public var iframe: HTMLTag { #function }
public var img: HTMLVoidTag { #function }
public var input: HTMLVoidTag { #function }
public var ins: HTMLTag { #function }
public var kbd: HTMLTag { #function }
public var keygen: HTMLVoidTag { #function }
public var label: HTMLTag { #function }
public var legend: HTMLTag { #function }
public var li: HTMLTag { #function }
public var link: HTMLVoidTag { #function }
public var main: HTMLTag { #function }
public var map: HTMLTag { #function }
public var mark: HTMLTag { #function }
public var meta: HTMLVoidTag { #function }
public var meter: HTMLTag { #function }
public var nav: HTMLTag { #function }
public var noframes: HTMLTag { #function }
public var noscript: HTMLTag { #function }
public var object: HTMLTag { #function }
public var ol: HTMLTag { #function }
public var optgroup: HTMLTag { #function }
public var option: HTMLTextTag { #function }
public var p: HTMLTag { #function }
public var param: HTMLVoidTag { #function }
public var picture: HTMLTag { #function }
public var pre: HTMLTag { #function }
public var progress: HTMLTag { #function }
public var q: HTMLTag { #function }
public var rp: HTMLTag { #function }
public var rt: HTMLTag { #function }
public var s: HTMLTag { #function }
public var samp: HTMLTag { #function }
public func script(_ text: () -> String = { "" }) -> HTMLElement<HTMLRaw> {
    let text = text()
    var escaped = ""
    escaped.unicodeScalars.reserveCapacity(text.unicodeScalars.count)
    for index in text.unicodeScalars.indices {
        let scalar = text.unicodeScalars[index]
        if scalar == "<",
           text.unicodeScalars[index...].starts(with: "<!--".unicodeScalars)
            || text.unicodeScalars[index...].starts(with: "<script".unicodeScalars)
            || text.unicodeScalars[index...].starts(with: "</script".unicodeScalars)
        {
            escaped.unicodeScalars.append(contentsOf: #"\x3C"#.unicodeScalars)
        } else {
            escaped.unicodeScalars.append(scalar)
        }
    }
    return tag("script") {
        HTMLRaw(escaped)
    }
}
public var section: HTMLTag { #function }
public var select: HTMLTag { #function }
public var small: HTMLTag { #function }
public var source: HTMLVoidTag { #function }
public var span: HTMLTag { #function }
public var strike: HTMLTag { #function }
public var strong: HTMLTag { #function }
public var style: HTMLTextTag { #function }
public var sub: HTMLTag { #function }
public var summary: HTMLTag { #function }
public var sup: HTMLTag { #function }
public var svg: HTMLTag { #function }
public var table: HTMLTag { #function }
public var tbody: HTMLTag { #function }
public var td: HTMLTag { #function }
public var template: HTMLTag { #function }
public var textarea: HTMLTextTag { #function }
public var tfoot: HTMLTag { #function }
public var th: HTMLTag { #function }
public var thead: HTMLTag { #function }
public var time: HTMLTag { #function }
public var title: HTMLTextTag { #function }
public var tr: HTMLTag { #function }
public var track: HTMLVoidTag { #function }
public var tt: HTMLTag { #function }
public var u: HTMLTag { #function }
public var ul: HTMLTag { #function }
public var `var`: HTMLTag { #function }
public var video: HTMLTag { #function }
public var wbr: HTMLVoidTag { #function }

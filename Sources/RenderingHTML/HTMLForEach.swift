//
//  HTMLForEach.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

/// A component that creates HTML content for each element in a collection.
///
/// `HTMLForEach` provides a way to generate HTML content by iterating over
/// a collection and applying a transform to each element. This is similar to
/// using a `for` loop in a result builder context, but provides a more
/// explicit and reusable way to handle collection iteration.
///
/// Example:
/// ```swift
/// let fruits = ["Apple", "Banana", "Cherry"]
///
/// var content: some HTML {
///     ul {
///         HTMLForEach(fruits) { fruit in
///             li { fruit }
///         }
///     }
/// }
/// ```
///
/// This would generate HTML similar to:
/// ```html
/// <ul>
///     <li>Apple</li>
///     <li>Banana</li>
///     <li>Cherry</li>
/// </ul>
/// ```
///
/// - Note: This component works around a bug in `buildArray` that causes
///   build failures when the element is `some HTML`.
public typealias HTMLForEach<Content: HTML> = ForEach<Content>

extension ForEach: HTML where Content: HTML {}

//
//  _HTMLArray.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

/// A container for an array of HTML elements.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// arrays of elements, such as those created by `for` loops.
public typealias _HTMLArray<Element: HTML> = _Array<Element>

extension _Array: HTML where Element: HTML {}

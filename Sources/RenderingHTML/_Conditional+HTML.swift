//
//  _HTMLConditional.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

/// A type to represent conditional HTML content based on if/else conditions.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// conditional content created by `if`/`else` statements.
public typealias _HTMLConditional<First: HTML, Second: HTML> = _Conditional<First, Second>

extension _Conditional: HTML where First: HTML, Second: HTML {}
